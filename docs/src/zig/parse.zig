<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/parse.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Ast = std.zig.Ast;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Node = Ast.Node;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> AstError = Ast.Error;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> TokenIndex = Ast.TokenIndex;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> Token = std.zig.Token;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{ParseError} || Allocator.Error;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Result should be freed with tree.deinit() when there are</span></span>
<span class="line" id="L13"><span class="tok-comment">/// no more references to any of the tokens or nodes.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(gpa: Allocator, source: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Allocator.Error!Ast {</span>
<span class="line" id="L15">    <span class="tok-kw">var</span> tokens = Ast.TokenList{};</span>
<span class="line" id="L16">    <span class="tok-kw">defer</span> tokens.deinit(gpa);</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-comment">// Empirically, the zig std lib has an 8:1 ratio of source bytes to token count.</span>
</span>
<span class="line" id="L19">    <span class="tok-kw">const</span> estimated_token_count = source.len / <span class="tok-number">8</span>;</span>
<span class="line" id="L20">    <span class="tok-kw">try</span> tokens.ensureTotalCapacity(gpa, estimated_token_count);</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    <span class="tok-kw">var</span> tokenizer = std.zig.Tokenizer.init(source);</span>
<span class="line" id="L23">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L24">        <span class="tok-kw">const</span> token = tokenizer.next();</span>
<span class="line" id="L25">        <span class="tok-kw">try</span> tokens.append(gpa, .{</span>
<span class="line" id="L26">            .tag = token.tag,</span>
<span class="line" id="L27">            .start = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, token.loc.start),</span>
<span class="line" id="L28">        });</span>
<span class="line" id="L29">        <span class="tok-kw">if</span> (token.tag == .eof) <span class="tok-kw">break</span>;</span>
<span class="line" id="L30">    }</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">var</span> parser: Parser = .{</span>
<span class="line" id="L33">        .source = source,</span>
<span class="line" id="L34">        .gpa = gpa,</span>
<span class="line" id="L35">        .token_tags = tokens.items(.tag),</span>
<span class="line" id="L36">        .token_starts = tokens.items(.start),</span>
<span class="line" id="L37">        .errors = .{},</span>
<span class="line" id="L38">        .nodes = .{},</span>
<span class="line" id="L39">        .extra_data = .{},</span>
<span class="line" id="L40">        .scratch = .{},</span>
<span class="line" id="L41">        .tok_i = <span class="tok-number">0</span>,</span>
<span class="line" id="L42">    };</span>
<span class="line" id="L43">    <span class="tok-kw">defer</span> parser.errors.deinit(gpa);</span>
<span class="line" id="L44">    <span class="tok-kw">defer</span> parser.nodes.deinit(gpa);</span>
<span class="line" id="L45">    <span class="tok-kw">defer</span> parser.extra_data.deinit(gpa);</span>
<span class="line" id="L46">    <span class="tok-kw">defer</span> parser.scratch.deinit(gpa);</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-comment">// Empirically, Zig source code has a 2:1 ratio of tokens to AST nodes.</span>
</span>
<span class="line" id="L49">    <span class="tok-comment">// Make sure at least 1 so we can use appendAssumeCapacity on the root node below.</span>
</span>
<span class="line" id="L50">    <span class="tok-kw">const</span> estimated_node_count = (tokens.len + <span class="tok-number">2</span>) / <span class="tok-number">2</span>;</span>
<span class="line" id="L51">    <span class="tok-kw">try</span> parser.nodes.ensureTotalCapacity(gpa, estimated_node_count);</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">// Root node must be index 0.</span>
</span>
<span class="line" id="L54">    <span class="tok-comment">// Root &lt;- skip ContainerMembers eof</span>
</span>
<span class="line" id="L55">    parser.nodes.appendAssumeCapacity(.{</span>
<span class="line" id="L56">        .tag = .root,</span>
<span class="line" id="L57">        .main_token = <span class="tok-number">0</span>,</span>
<span class="line" id="L58">        .data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L59">    });</span>
<span class="line" id="L60">    <span class="tok-kw">const</span> root_members = <span class="tok-kw">try</span> parser.parseContainerMembers();</span>
<span class="line" id="L61">    <span class="tok-kw">const</span> root_decls = <span class="tok-kw">try</span> root_members.toSpan(&amp;parser);</span>
<span class="line" id="L62">    <span class="tok-kw">if</span> (parser.token_tags[parser.tok_i] != .eof) {</span>
<span class="line" id="L63">        <span class="tok-kw">try</span> parser.warnExpected(.eof);</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65">    parser.nodes.items(.data)[<span class="tok-number">0</span>] = .{</span>
<span class="line" id="L66">        .lhs = root_decls.start,</span>
<span class="line" id="L67">        .rhs = root_decls.end,</span>
<span class="line" id="L68">    };</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">    <span class="tok-comment">// TODO experiment with compacting the MultiArrayList slices here</span>
</span>
<span class="line" id="L71">    <span class="tok-kw">return</span> Ast{</span>
<span class="line" id="L72">        .source = source,</span>
<span class="line" id="L73">        .tokens = tokens.toOwnedSlice(),</span>
<span class="line" id="L74">        .nodes = parser.nodes.toOwnedSlice(),</span>
<span class="line" id="L75">        .extra_data = parser.extra_data.toOwnedSlice(gpa),</span>
<span class="line" id="L76">        .errors = parser.errors.toOwnedSlice(gpa),</span>
<span class="line" id="L77">    };</span>
<span class="line" id="L78">}</span>
<span class="line" id="L79"></span>
<span class="line" id="L80"><span class="tok-kw">const</span> null_node: Node.Index = <span class="tok-number">0</span>;</span>
<span class="line" id="L81"></span>
<span class="line" id="L82"><span class="tok-comment">/// Represents in-progress parsing, will be converted to an Ast after completion.</span></span>
<span class="line" id="L83"><span class="tok-kw">const</span> Parser = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L84">    gpa: Allocator,</span>
<span class="line" id="L85">    source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L86">    token_tags: []<span class="tok-kw">const</span> Token.Tag,</span>
<span class="line" id="L87">    token_starts: []<span class="tok-kw">const</span> Ast.ByteOffset,</span>
<span class="line" id="L88">    tok_i: TokenIndex,</span>
<span class="line" id="L89">    errors: std.ArrayListUnmanaged(AstError),</span>
<span class="line" id="L90">    nodes: Ast.NodeList,</span>
<span class="line" id="L91">    extra_data: std.ArrayListUnmanaged(Node.Index),</span>
<span class="line" id="L92">    scratch: std.ArrayListUnmanaged(Node.Index),</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">const</span> SmallSpan = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L95">        zero_or_one: Node.Index,</span>
<span class="line" id="L96">        multi: Node.SubRange,</span>
<span class="line" id="L97">    };</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-kw">const</span> Members = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L100">        len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L101">        lhs: Node.Index,</span>
<span class="line" id="L102">        rhs: Node.Index,</span>
<span class="line" id="L103">        trailing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">        <span class="tok-kw">fn</span> <span class="tok-fn">toSpan</span>(self: Members, p: *Parser) !Node.SubRange {</span>
<span class="line" id="L106">            <span class="tok-kw">if</span> (self.len &lt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L107">                <span class="tok-kw">const</span> nodes = [<span class="tok-number">2</span>]Node.Index{ self.lhs, self.rhs };</span>
<span class="line" id="L108">                <span class="tok-kw">return</span> p.listToSpan(nodes[<span class="tok-number">0</span>..self.len]);</span>
<span class="line" id="L109">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L110">                <span class="tok-kw">return</span> Node.SubRange{ .start = self.lhs, .end = self.rhs };</span>
<span class="line" id="L111">            }</span>
<span class="line" id="L112">        }</span>
<span class="line" id="L113">    };</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">fn</span> <span class="tok-fn">listToSpan</span>(p: *Parser, list: []<span class="tok-kw">const</span> Node.Index) !Node.SubRange {</span>
<span class="line" id="L116">        <span class="tok-kw">try</span> p.extra_data.appendSlice(p.gpa, list);</span>
<span class="line" id="L117">        <span class="tok-kw">return</span> Node.SubRange{</span>
<span class="line" id="L118">            .start = <span class="tok-builtin">@intCast</span>(Node.Index, p.extra_data.items.len - list.len),</span>
<span class="line" id="L119">            .end = <span class="tok-builtin">@intCast</span>(Node.Index, p.extra_data.items.len),</span>
<span class="line" id="L120">        };</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">fn</span> <span class="tok-fn">addNode</span>(p: *Parser, elem: Ast.NodeList.Elem) Allocator.Error!Node.Index {</span>
<span class="line" id="L124">        <span class="tok-kw">const</span> result = <span class="tok-builtin">@intCast</span>(Node.Index, p.nodes.len);</span>
<span class="line" id="L125">        <span class="tok-kw">try</span> p.nodes.append(p.gpa, elem);</span>
<span class="line" id="L126">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">fn</span> <span class="tok-fn">setNode</span>(p: *Parser, i: <span class="tok-type">usize</span>, elem: Ast.NodeList.Elem) Node.Index {</span>
<span class="line" id="L130">        p.nodes.set(i, elem);</span>
<span class="line" id="L131">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Node.Index, i);</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">fn</span> <span class="tok-fn">reserveNode</span>(p: *Parser) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L135">        <span class="tok-kw">try</span> p.nodes.resize(p.gpa, p.nodes.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L136">        <span class="tok-kw">return</span> p.nodes.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L137">    }</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-kw">fn</span> <span class="tok-fn">addExtra</span>(p: *Parser, extra: <span class="tok-kw">anytype</span>) Allocator.Error!Node.Index {</span>
<span class="line" id="L140">        <span class="tok-kw">const</span> fields = std.meta.fields(<span class="tok-builtin">@TypeOf</span>(extra));</span>
<span class="line" id="L141">        <span class="tok-kw">try</span> p.extra_data.ensureUnusedCapacity(p.gpa, fields.len);</span>
<span class="line" id="L142">        <span class="tok-kw">const</span> result = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, p.extra_data.items.len);</span>
<span class="line" id="L143">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field| {</span>
<span class="line" id="L144">            <span class="tok-kw">comptime</span> assert(field.field_type == Node.Index);</span>
<span class="line" id="L145">            p.extra_data.appendAssumeCapacity(<span class="tok-builtin">@field</span>(extra, field.name));</span>
<span class="line" id="L146">        }</span>
<span class="line" id="L147">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L148">    }</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">fn</span> <span class="tok-fn">warnExpected</span>(p: *Parser, expected_token: Token.Tag) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L151">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L152">        <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L153">            .tag = .expected_token,</span>
<span class="line" id="L154">            .token = p.tok_i,</span>
<span class="line" id="L155">            .extra = .{ .expected_tag = expected_token },</span>
<span class="line" id="L156">        });</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-kw">fn</span> <span class="tok-fn">warn</span>(p: *Parser, error_tag: AstError.Tag) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L160">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L161">        <span class="tok-kw">try</span> p.warnMsg(.{ .tag = error_tag, .token = p.tok_i });</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-kw">fn</span> <span class="tok-fn">warnMsg</span>(p: *Parser, msg: Ast.Error) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">void</span> {</span>
<span class="line" id="L165">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L166">        <span class="tok-kw">switch</span> (msg.tag) {</span>
<span class="line" id="L167">            .expected_semi_after_decl,</span>
<span class="line" id="L168">            .expected_semi_after_stmt,</span>
<span class="line" id="L169">            .expected_comma_after_field,</span>
<span class="line" id="L170">            .expected_comma_after_arg,</span>
<span class="line" id="L171">            .expected_comma_after_param,</span>
<span class="line" id="L172">            .expected_comma_after_initializer,</span>
<span class="line" id="L173">            .expected_comma_after_switch_prong,</span>
<span class="line" id="L174">            .expected_semi_or_else,</span>
<span class="line" id="L175">            .expected_semi_or_lbrace,</span>
<span class="line" id="L176">            .expected_token,</span>
<span class="line" id="L177">            .expected_block,</span>
<span class="line" id="L178">            .expected_block_or_assignment,</span>
<span class="line" id="L179">            .expected_block_or_expr,</span>
<span class="line" id="L180">            .expected_block_or_field,</span>
<span class="line" id="L181">            .expected_expr,</span>
<span class="line" id="L182">            .expected_expr_or_assignment,</span>
<span class="line" id="L183">            .expected_fn,</span>
<span class="line" id="L184">            .expected_inlinable,</span>
<span class="line" id="L185">            .expected_labelable,</span>
<span class="line" id="L186">            .expected_param_list,</span>
<span class="line" id="L187">            .expected_prefix_expr,</span>
<span class="line" id="L188">            .expected_primary_type_expr,</span>
<span class="line" id="L189">            .expected_pub_item,</span>
<span class="line" id="L190">            .expected_return_type,</span>
<span class="line" id="L191">            .expected_suffix_op,</span>
<span class="line" id="L192">            .expected_type_expr,</span>
<span class="line" id="L193">            .expected_var_decl,</span>
<span class="line" id="L194">            .expected_var_decl_or_fn,</span>
<span class="line" id="L195">            .expected_loop_payload,</span>
<span class="line" id="L196">            .expected_container,</span>
<span class="line" id="L197">            =&gt; <span class="tok-kw">if</span> (msg.token != <span class="tok-number">0</span> <span class="tok-kw">and</span> !p.tokensOnSameLine(msg.token - <span class="tok-number">1</span>, msg.token)) {</span>
<span class="line" id="L198">                <span class="tok-kw">var</span> copy = msg;</span>
<span class="line" id="L199">                copy.token_is_prev = <span class="tok-null">true</span>;</span>
<span class="line" id="L200">                copy.token -= <span class="tok-number">1</span>;</span>
<span class="line" id="L201">                <span class="tok-kw">return</span> p.errors.append(p.gpa, copy);</span>
<span class="line" id="L202">            },</span>
<span class="line" id="L203">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L204">        }</span>
<span class="line" id="L205">        <span class="tok-kw">try</span> p.errors.append(p.gpa, msg);</span>
<span class="line" id="L206">    }</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">    <span class="tok-kw">fn</span> <span class="tok-fn">fail</span>(p: *Parser, tag: Ast.Error.Tag) <span class="tok-kw">error</span>{ ParseError, OutOfMemory } {</span>
<span class="line" id="L209">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L210">        <span class="tok-kw">return</span> p.failMsg(.{ .tag = tag, .token = p.tok_i });</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    <span class="tok-kw">fn</span> <span class="tok-fn">failExpected</span>(p: *Parser, expected_token: Token.Tag) <span class="tok-kw">error</span>{ ParseError, OutOfMemory } {</span>
<span class="line" id="L214">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L215">        <span class="tok-kw">return</span> p.failMsg(.{</span>
<span class="line" id="L216">            .tag = .expected_token,</span>
<span class="line" id="L217">            .token = p.tok_i,</span>
<span class="line" id="L218">            .extra = .{ .expected_tag = expected_token },</span>
<span class="line" id="L219">        });</span>
<span class="line" id="L220">    }</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    <span class="tok-kw">fn</span> <span class="tok-fn">failMsg</span>(p: *Parser, msg: Ast.Error) <span class="tok-kw">error</span>{ ParseError, OutOfMemory } {</span>
<span class="line" id="L223">        <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L224">        <span class="tok-kw">try</span> p.warnMsg(msg);</span>
<span class="line" id="L225">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ParseError;</span>
<span class="line" id="L226">    }</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    <span class="tok-comment">/// ContainerMembers &lt;- ContainerDeclarations (ContainerField COMMA)* (ContainerField / ContainerDeclarations)</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// ContainerDeclarations</span></span>
<span class="line" id="L230">    <span class="tok-comment">///     &lt;- TestDecl ContainerDeclarations</span></span>
<span class="line" id="L231">    <span class="tok-comment">///      / TopLevelComptime ContainerDeclarations</span></span>
<span class="line" id="L232">    <span class="tok-comment">///      / KEYWORD_pub? TopLevelDecl ContainerDeclarations</span></span>
<span class="line" id="L233">    <span class="tok-comment">///      /</span></span>
<span class="line" id="L234">    <span class="tok-comment">/// TopLevelComptime &lt;- KEYWORD_comptime Block</span></span>
<span class="line" id="L235">    <span class="tok-kw">fn</span> <span class="tok-fn">parseContainerMembers</span>(p: *Parser) !Members {</span>
<span class="line" id="L236">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L237">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">        <span class="tok-kw">var</span> field_state: <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L240">            <span class="tok-comment">/// No fields have been seen.</span></span>
<span class="line" id="L241">            none,</span>
<span class="line" id="L242">            <span class="tok-comment">/// Currently parsing fields.</span></span>
<span class="line" id="L243">            seen,</span>
<span class="line" id="L244">            <span class="tok-comment">/// Saw fields and then a declaration after them.</span></span>
<span class="line" id="L245">            <span class="tok-comment">/// Payload is first token of previous declaration.</span></span>
<span class="line" id="L246">            end: Node.Index,</span>
<span class="line" id="L247">            <span class="tok-comment">/// There was a declaration between fields, don't report more errors.</span></span>
<span class="line" id="L248">            err,</span>
<span class="line" id="L249">        } = .none;</span>
<span class="line" id="L250"></span>
<span class="line" id="L251">        <span class="tok-kw">var</span> last_field: TokenIndex = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">        <span class="tok-comment">// Skip container doc comments.</span>
</span>
<span class="line" id="L254">        <span class="tok-kw">while</span> (p.eatToken(.container_doc_comment)) |_| {}</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">        <span class="tok-kw">var</span> trailing = <span class="tok-null">false</span>;</span>
<span class="line" id="L257">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L258">            <span class="tok-kw">const</span> doc_comment = <span class="tok-kw">try</span> p.eatDocComments();</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L261">                .keyword_test =&gt; {</span>
<span class="line" id="L262">                    <span class="tok-kw">if</span> (doc_comment) |some| {</span>
<span class="line" id="L263">                        <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .test_doc_comment, .token = some });</span>
<span class="line" id="L264">                    }</span>
<span class="line" id="L265">                    <span class="tok-kw">const</span> test_decl_node = <span class="tok-kw">try</span> p.expectTestDeclRecoverable();</span>
<span class="line" id="L266">                    <span class="tok-kw">if</span> (test_decl_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L267">                        <span class="tok-kw">if</span> (field_state == .seen) {</span>
<span class="line" id="L268">                            field_state = .{ .end = test_decl_node };</span>
<span class="line" id="L269">                        }</span>
<span class="line" id="L270">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, test_decl_node);</span>
<span class="line" id="L271">                    }</span>
<span class="line" id="L272">                    trailing = <span class="tok-null">false</span>;</span>
<span class="line" id="L273">                },</span>
<span class="line" id="L274">                .keyword_comptime =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L275">                    .identifier =&gt; {</span>
<span class="line" id="L276">                        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L277">                        <span class="tok-kw">const</span> identifier = p.tok_i;</span>
<span class="line" id="L278">                        <span class="tok-kw">defer</span> last_field = identifier;</span>
<span class="line" id="L279">                        <span class="tok-kw">const</span> container_field = <span class="tok-kw">try</span> p.expectContainerFieldRecoverable();</span>
<span class="line" id="L280">                        <span class="tok-kw">if</span> (container_field != <span class="tok-number">0</span>) {</span>
<span class="line" id="L281">                            <span class="tok-kw">switch</span> (field_state) {</span>
<span class="line" id="L282">                                .none =&gt; field_state = .seen,</span>
<span class="line" id="L283">                                .err, .seen =&gt; {},</span>
<span class="line" id="L284">                                .end =&gt; |node| {</span>
<span class="line" id="L285">                                    <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L286">                                        .tag = .decl_between_fields,</span>
<span class="line" id="L287">                                        .token = p.nodes.items(.main_token)[node],</span>
<span class="line" id="L288">                                    });</span>
<span class="line" id="L289">                                    <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L290">                                        .tag = .previous_field,</span>
<span class="line" id="L291">                                        .is_note = <span class="tok-null">true</span>,</span>
<span class="line" id="L292">                                        .token = last_field,</span>
<span class="line" id="L293">                                    });</span>
<span class="line" id="L294">                                    <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L295">                                        .tag = .next_field,</span>
<span class="line" id="L296">                                        .is_note = <span class="tok-null">true</span>,</span>
<span class="line" id="L297">                                        .token = identifier,</span>
<span class="line" id="L298">                                    });</span>
<span class="line" id="L299">                                    <span class="tok-comment">// Continue parsing; error will be reported later.</span>
</span>
<span class="line" id="L300">                                    field_state = .err;</span>
<span class="line" id="L301">                                },</span>
<span class="line" id="L302">                            }</span>
<span class="line" id="L303">                            <span class="tok-kw">try</span> p.scratch.append(p.gpa, container_field);</span>
<span class="line" id="L304">                            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L305">                                .comma =&gt; {</span>
<span class="line" id="L306">                                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L307">                                    trailing = <span class="tok-null">true</span>;</span>
<span class="line" id="L308">                                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L309">                                },</span>
<span class="line" id="L310">                                .r_brace, .eof =&gt; {</span>
<span class="line" id="L311">                                    trailing = <span class="tok-null">false</span>;</span>
<span class="line" id="L312">                                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L313">                                },</span>
<span class="line" id="L314">                                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L315">                            }</span>
<span class="line" id="L316">                            <span class="tok-comment">// There is not allowed to be a decl after a field with no comma.</span>
</span>
<span class="line" id="L317">                            <span class="tok-comment">// Report error but recover parser.</span>
</span>
<span class="line" id="L318">                            <span class="tok-kw">try</span> p.warn(.expected_comma_after_field);</span>
<span class="line" id="L319">                            p.findNextContainerMember();</span>
<span class="line" id="L320">                        }</span>
<span class="line" id="L321">                    },</span>
<span class="line" id="L322">                    .l_brace =&gt; {</span>
<span class="line" id="L323">                        <span class="tok-kw">if</span> (doc_comment) |some| {</span>
<span class="line" id="L324">                            <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .test_doc_comment, .token = some });</span>
<span class="line" id="L325">                        }</span>
<span class="line" id="L326">                        <span class="tok-kw">const</span> comptime_token = p.nextToken();</span>
<span class="line" id="L327">                        <span class="tok-kw">const</span> block = p.parseBlock() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L328">                            <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L329">                            <span class="tok-kw">error</span>.ParseError =&gt; blk: {</span>
<span class="line" id="L330">                                p.findNextContainerMember();</span>
<span class="line" id="L331">                                <span class="tok-kw">break</span> :blk null_node;</span>
<span class="line" id="L332">                            },</span>
<span class="line" id="L333">                        };</span>
<span class="line" id="L334">                        <span class="tok-kw">if</span> (block != <span class="tok-number">0</span>) {</span>
<span class="line" id="L335">                            <span class="tok-kw">const</span> comptime_node = <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L336">                                .tag = .@&quot;comptime&quot;,</span>
<span class="line" id="L337">                                .main_token = comptime_token,</span>
<span class="line" id="L338">                                .data = .{</span>
<span class="line" id="L339">                                    .lhs = block,</span>
<span class="line" id="L340">                                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L341">                                },</span>
<span class="line" id="L342">                            });</span>
<span class="line" id="L343">                            <span class="tok-kw">if</span> (field_state == .seen) {</span>
<span class="line" id="L344">                                field_state = .{ .end = comptime_node };</span>
<span class="line" id="L345">                            }</span>
<span class="line" id="L346">                            <span class="tok-kw">try</span> p.scratch.append(p.gpa, comptime_node);</span>
<span class="line" id="L347">                        }</span>
<span class="line" id="L348">                        trailing = <span class="tok-null">false</span>;</span>
<span class="line" id="L349">                    },</span>
<span class="line" id="L350">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L351">                        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L352">                        <span class="tok-kw">try</span> p.warn(.expected_block_or_field);</span>
<span class="line" id="L353">                    },</span>
<span class="line" id="L354">                },</span>
<span class="line" id="L355">                .keyword_pub =&gt; {</span>
<span class="line" id="L356">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L357">                    <span class="tok-kw">const</span> top_level_decl = <span class="tok-kw">try</span> p.expectTopLevelDeclRecoverable();</span>
<span class="line" id="L358">                    <span class="tok-kw">if</span> (top_level_decl != <span class="tok-number">0</span>) {</span>
<span class="line" id="L359">                        <span class="tok-kw">if</span> (field_state == .seen) {</span>
<span class="line" id="L360">                            field_state = .{ .end = top_level_decl };</span>
<span class="line" id="L361">                        }</span>
<span class="line" id="L362">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, top_level_decl);</span>
<span class="line" id="L363">                    }</span>
<span class="line" id="L364">                    trailing = p.token_tags[p.tok_i - <span class="tok-number">1</span>] == .semicolon;</span>
<span class="line" id="L365">                },</span>
<span class="line" id="L366">                .keyword_usingnamespace =&gt; {</span>
<span class="line" id="L367">                    <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.expectUsingNamespaceRecoverable();</span>
<span class="line" id="L368">                    <span class="tok-kw">if</span> (node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L369">                        <span class="tok-kw">if</span> (field_state == .seen) {</span>
<span class="line" id="L370">                            field_state = .{ .end = node };</span>
<span class="line" id="L371">                        }</span>
<span class="line" id="L372">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, node);</span>
<span class="line" id="L373">                    }</span>
<span class="line" id="L374">                    trailing = p.token_tags[p.tok_i - <span class="tok-number">1</span>] == .semicolon;</span>
<span class="line" id="L375">                },</span>
<span class="line" id="L376">                .keyword_const,</span>
<span class="line" id="L377">                .keyword_var,</span>
<span class="line" id="L378">                .keyword_threadlocal,</span>
<span class="line" id="L379">                .keyword_export,</span>
<span class="line" id="L380">                .keyword_extern,</span>
<span class="line" id="L381">                .keyword_inline,</span>
<span class="line" id="L382">                .keyword_noinline,</span>
<span class="line" id="L383">                .keyword_fn,</span>
<span class="line" id="L384">                =&gt; {</span>
<span class="line" id="L385">                    <span class="tok-kw">const</span> top_level_decl = <span class="tok-kw">try</span> p.expectTopLevelDeclRecoverable();</span>
<span class="line" id="L386">                    <span class="tok-kw">if</span> (top_level_decl != <span class="tok-number">0</span>) {</span>
<span class="line" id="L387">                        <span class="tok-kw">if</span> (field_state == .seen) {</span>
<span class="line" id="L388">                            field_state = .{ .end = top_level_decl };</span>
<span class="line" id="L389">                        }</span>
<span class="line" id="L390">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, top_level_decl);</span>
<span class="line" id="L391">                    }</span>
<span class="line" id="L392">                    trailing = p.token_tags[p.tok_i - <span class="tok-number">1</span>] == .semicolon;</span>
<span class="line" id="L393">                },</span>
<span class="line" id="L394">                .identifier =&gt; {</span>
<span class="line" id="L395">                    <span class="tok-kw">const</span> identifier = p.tok_i;</span>
<span class="line" id="L396">                    <span class="tok-kw">defer</span> last_field = identifier;</span>
<span class="line" id="L397">                    <span class="tok-kw">const</span> container_field = <span class="tok-kw">try</span> p.expectContainerFieldRecoverable();</span>
<span class="line" id="L398">                    <span class="tok-kw">if</span> (container_field != <span class="tok-number">0</span>) {</span>
<span class="line" id="L399">                        <span class="tok-kw">switch</span> (field_state) {</span>
<span class="line" id="L400">                            .none =&gt; field_state = .seen,</span>
<span class="line" id="L401">                            .err, .seen =&gt; {},</span>
<span class="line" id="L402">                            .end =&gt; |node| {</span>
<span class="line" id="L403">                                <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L404">                                    .tag = .decl_between_fields,</span>
<span class="line" id="L405">                                    .token = p.nodes.items(.main_token)[node],</span>
<span class="line" id="L406">                                });</span>
<span class="line" id="L407">                                <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L408">                                    .tag = .previous_field,</span>
<span class="line" id="L409">                                    .is_note = <span class="tok-null">true</span>,</span>
<span class="line" id="L410">                                    .token = last_field,</span>
<span class="line" id="L411">                                });</span>
<span class="line" id="L412">                                <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L413">                                    .tag = .next_field,</span>
<span class="line" id="L414">                                    .is_note = <span class="tok-null">true</span>,</span>
<span class="line" id="L415">                                    .token = identifier,</span>
<span class="line" id="L416">                                });</span>
<span class="line" id="L417">                                <span class="tok-comment">// Continue parsing; error will be reported later.</span>
</span>
<span class="line" id="L418">                                field_state = .err;</span>
<span class="line" id="L419">                            },</span>
<span class="line" id="L420">                        }</span>
<span class="line" id="L421">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, container_field);</span>
<span class="line" id="L422">                        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L423">                            .comma =&gt; {</span>
<span class="line" id="L424">                                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L425">                                trailing = <span class="tok-null">true</span>;</span>
<span class="line" id="L426">                                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L427">                            },</span>
<span class="line" id="L428">                            .r_brace, .eof =&gt; {</span>
<span class="line" id="L429">                                trailing = <span class="tok-null">false</span>;</span>
<span class="line" id="L430">                                <span class="tok-kw">break</span>;</span>
<span class="line" id="L431">                            },</span>
<span class="line" id="L432">                            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L433">                        }</span>
<span class="line" id="L434">                        <span class="tok-comment">// There is not allowed to be a decl after a field with no comma.</span>
</span>
<span class="line" id="L435">                        <span class="tok-comment">// Report error but recover parser.</span>
</span>
<span class="line" id="L436">                        <span class="tok-kw">try</span> p.warn(.expected_comma_after_field);</span>
<span class="line" id="L437">                        p.findNextContainerMember();</span>
<span class="line" id="L438">                    }</span>
<span class="line" id="L439">                },</span>
<span class="line" id="L440">                .eof, .r_brace =&gt; {</span>
<span class="line" id="L441">                    <span class="tok-kw">if</span> (doc_comment) |tok| {</span>
<span class="line" id="L442">                        <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L443">                            .tag = .unattached_doc_comment,</span>
<span class="line" id="L444">                            .token = tok,</span>
<span class="line" id="L445">                        });</span>
<span class="line" id="L446">                    }</span>
<span class="line" id="L447">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L448">                },</span>
<span class="line" id="L449">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L450">                    <span class="tok-kw">const</span> c_container = p.parseCStyleContainer() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L451">                        <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L452">                        <span class="tok-kw">error</span>.ParseError =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L453">                    };</span>
<span class="line" id="L454">                    <span class="tok-kw">if</span> (!c_container) {</span>
<span class="line" id="L455">                        <span class="tok-kw">try</span> p.warn(.expected_container_members);</span>
<span class="line" id="L456">                        <span class="tok-comment">// This was likely not supposed to end yet; try to find the next declaration.</span>
</span>
<span class="line" id="L457">                        p.findNextContainerMember();</span>
<span class="line" id="L458">                    }</span>
<span class="line" id="L459">                },</span>
<span class="line" id="L460">            }</span>
<span class="line" id="L461">        }</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">        <span class="tok-kw">const</span> items = p.scratch.items[scratch_top..];</span>
<span class="line" id="L464">        <span class="tok-kw">switch</span> (items.len) {</span>
<span class="line" id="L465">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> Members{</span>
<span class="line" id="L466">                .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L467">                .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L468">                .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L469">                .trailing = trailing,</span>
<span class="line" id="L470">            },</span>
<span class="line" id="L471">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> Members{</span>
<span class="line" id="L472">                .len = <span class="tok-number">1</span>,</span>
<span class="line" id="L473">                .lhs = items[<span class="tok-number">0</span>],</span>
<span class="line" id="L474">                .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L475">                .trailing = trailing,</span>
<span class="line" id="L476">            },</span>
<span class="line" id="L477">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> Members{</span>
<span class="line" id="L478">                .len = <span class="tok-number">2</span>,</span>
<span class="line" id="L479">                .lhs = items[<span class="tok-number">0</span>],</span>
<span class="line" id="L480">                .rhs = items[<span class="tok-number">1</span>],</span>
<span class="line" id="L481">                .trailing = trailing,</span>
<span class="line" id="L482">            },</span>
<span class="line" id="L483">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L484">                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(items);</span>
<span class="line" id="L485">                <span class="tok-kw">return</span> Members{</span>
<span class="line" id="L486">                    .len = items.len,</span>
<span class="line" id="L487">                    .lhs = span.start,</span>
<span class="line" id="L488">                    .rhs = span.end,</span>
<span class="line" id="L489">                    .trailing = trailing,</span>
<span class="line" id="L490">                };</span>
<span class="line" id="L491">            },</span>
<span class="line" id="L492">        }</span>
<span class="line" id="L493">    }</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-comment">/// Attempts to find next container member by searching for certain tokens</span></span>
<span class="line" id="L496">    <span class="tok-kw">fn</span> <span class="tok-fn">findNextContainerMember</span>(p: *Parser) <span class="tok-type">void</span> {</span>
<span class="line" id="L497">        <span class="tok-kw">var</span> level: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L498">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L499">            <span class="tok-kw">const</span> tok = p.nextToken();</span>
<span class="line" id="L500">            <span class="tok-kw">switch</span> (p.token_tags[tok]) {</span>
<span class="line" id="L501">                <span class="tok-comment">// Any of these can start a new top level declaration.</span>
</span>
<span class="line" id="L502">                .keyword_test,</span>
<span class="line" id="L503">                .keyword_comptime,</span>
<span class="line" id="L504">                .keyword_pub,</span>
<span class="line" id="L505">                .keyword_export,</span>
<span class="line" id="L506">                .keyword_extern,</span>
<span class="line" id="L507">                .keyword_inline,</span>
<span class="line" id="L508">                .keyword_noinline,</span>
<span class="line" id="L509">                .keyword_usingnamespace,</span>
<span class="line" id="L510">                .keyword_threadlocal,</span>
<span class="line" id="L511">                .keyword_const,</span>
<span class="line" id="L512">                .keyword_var,</span>
<span class="line" id="L513">                .keyword_fn,</span>
<span class="line" id="L514">                =&gt; {</span>
<span class="line" id="L515">                    <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L516">                        p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L517">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L518">                    }</span>
<span class="line" id="L519">                },</span>
<span class="line" id="L520">                .identifier =&gt; {</span>
<span class="line" id="L521">                    <span class="tok-kw">if</span> (p.token_tags[tok + <span class="tok-number">1</span>] == .comma <span class="tok-kw">and</span> level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L522">                        p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L523">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L524">                    }</span>
<span class="line" id="L525">                },</span>
<span class="line" id="L526">                .comma, .semicolon =&gt; {</span>
<span class="line" id="L527">                    <span class="tok-comment">// this decl was likely meant to end here</span>
</span>
<span class="line" id="L528">                    <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L529">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L530">                    }</span>
<span class="line" id="L531">                },</span>
<span class="line" id="L532">                .l_paren, .l_bracket, .l_brace =&gt; level += <span class="tok-number">1</span>,</span>
<span class="line" id="L533">                .r_paren, .r_bracket =&gt; {</span>
<span class="line" id="L534">                    <span class="tok-kw">if</span> (level != <span class="tok-number">0</span>) level -= <span class="tok-number">1</span>;</span>
<span class="line" id="L535">                },</span>
<span class="line" id="L536">                .r_brace =&gt; {</span>
<span class="line" id="L537">                    <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L538">                        <span class="tok-comment">// end of container, exit</span>
</span>
<span class="line" id="L539">                        p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L540">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L541">                    }</span>
<span class="line" id="L542">                    level -= <span class="tok-number">1</span>;</span>
<span class="line" id="L543">                },</span>
<span class="line" id="L544">                .eof =&gt; {</span>
<span class="line" id="L545">                    p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L546">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L547">                },</span>
<span class="line" id="L548">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L549">            }</span>
<span class="line" id="L550">        }</span>
<span class="line" id="L551">    }</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">    <span class="tok-comment">/// Attempts to find the next statement by searching for a semicolon</span></span>
<span class="line" id="L554">    <span class="tok-kw">fn</span> <span class="tok-fn">findNextStmt</span>(p: *Parser) <span class="tok-type">void</span> {</span>
<span class="line" id="L555">        <span class="tok-kw">var</span> level: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L556">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L557">            <span class="tok-kw">const</span> tok = p.nextToken();</span>
<span class="line" id="L558">            <span class="tok-kw">switch</span> (p.token_tags[tok]) {</span>
<span class="line" id="L559">                .l_brace =&gt; level += <span class="tok-number">1</span>,</span>
<span class="line" id="L560">                .r_brace =&gt; {</span>
<span class="line" id="L561">                    <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L562">                        p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L563">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L564">                    }</span>
<span class="line" id="L565">                    level -= <span class="tok-number">1</span>;</span>
<span class="line" id="L566">                },</span>
<span class="line" id="L567">                .semicolon =&gt; {</span>
<span class="line" id="L568">                    <span class="tok-kw">if</span> (level == <span class="tok-number">0</span>) {</span>
<span class="line" id="L569">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L570">                    }</span>
<span class="line" id="L571">                },</span>
<span class="line" id="L572">                .eof =&gt; {</span>
<span class="line" id="L573">                    p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L574">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L575">                },</span>
<span class="line" id="L576">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L577">            }</span>
<span class="line" id="L578">        }</span>
<span class="line" id="L579">    }</span>
<span class="line" id="L580"></span>
<span class="line" id="L581">    <span class="tok-comment">/// TestDecl &lt;- KEYWORD_test (STRINGLITERALSINGLE / IDENTIFIER)? Block</span></span>
<span class="line" id="L582">    <span class="tok-kw">fn</span> <span class="tok-fn">expectTestDecl</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L583">        <span class="tok-kw">const</span> test_token = p.assertToken(.keyword_test);</span>
<span class="line" id="L584">        <span class="tok-kw">const</span> name_token = <span class="tok-kw">switch</span> (p.token_tags[p.nextToken()]) {</span>
<span class="line" id="L585">            .string_literal, .identifier =&gt; p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L586">            <span class="tok-kw">else</span> =&gt; blk: {</span>
<span class="line" id="L587">                p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L588">                <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>;</span>
<span class="line" id="L589">            },</span>
<span class="line" id="L590">        };</span>
<span class="line" id="L591">        <span class="tok-kw">const</span> block_node = <span class="tok-kw">try</span> p.parseBlock();</span>
<span class="line" id="L592">        <span class="tok-kw">if</span> (block_node == <span class="tok-number">0</span>) <span class="tok-kw">return</span> p.fail(.expected_block);</span>
<span class="line" id="L593">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L594">            .tag = .test_decl,</span>
<span class="line" id="L595">            .main_token = test_token,</span>
<span class="line" id="L596">            .data = .{</span>
<span class="line" id="L597">                .lhs = name_token <span class="tok-kw">orelse</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L598">                .rhs = block_node,</span>
<span class="line" id="L599">            },</span>
<span class="line" id="L600">        });</span>
<span class="line" id="L601">    }</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    <span class="tok-kw">fn</span> <span class="tok-fn">expectTestDeclRecoverable</span>(p: *Parser) <span class="tok-kw">error</span>{OutOfMemory}!Node.Index {</span>
<span class="line" id="L604">        <span class="tok-kw">return</span> p.expectTestDecl() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L605">            <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L606">            <span class="tok-kw">error</span>.ParseError =&gt; {</span>
<span class="line" id="L607">                p.findNextContainerMember();</span>
<span class="line" id="L608">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L609">            },</span>
<span class="line" id="L610">        };</span>
<span class="line" id="L611">    }</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">    <span class="tok-comment">/// TopLevelDecl</span></span>
<span class="line" id="L614">    <span class="tok-comment">///     &lt;- (KEYWORD_export / KEYWORD_extern STRINGLITERALSINGLE? / (KEYWORD_inline / KEYWORD_noinline))? FnProto (SEMICOLON / Block)</span></span>
<span class="line" id="L615">    <span class="tok-comment">///      / (KEYWORD_export / KEYWORD_extern STRINGLITERALSINGLE?)? KEYWORD_threadlocal? VarDecl</span></span>
<span class="line" id="L616">    <span class="tok-comment">///      / KEYWORD_usingnamespace Expr SEMICOLON</span></span>
<span class="line" id="L617">    <span class="tok-kw">fn</span> <span class="tok-fn">expectTopLevelDecl</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L618">        <span class="tok-kw">const</span> extern_export_inline_token = p.nextToken();</span>
<span class="line" id="L619">        <span class="tok-kw">var</span> is_extern: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L620">        <span class="tok-kw">var</span> expect_fn: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L621">        <span class="tok-kw">var</span> expect_var_or_fn: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L622">        <span class="tok-kw">switch</span> (p.token_tags[extern_export_inline_token]) {</span>
<span class="line" id="L623">            .keyword_extern =&gt; {</span>
<span class="line" id="L624">                _ = p.eatToken(.string_literal);</span>
<span class="line" id="L625">                is_extern = <span class="tok-null">true</span>;</span>
<span class="line" id="L626">                expect_var_or_fn = <span class="tok-null">true</span>;</span>
<span class="line" id="L627">            },</span>
<span class="line" id="L628">            .keyword_export =&gt; expect_var_or_fn = <span class="tok-null">true</span>,</span>
<span class="line" id="L629">            .keyword_inline, .keyword_noinline =&gt; expect_fn = <span class="tok-null">true</span>,</span>
<span class="line" id="L630">            <span class="tok-kw">else</span> =&gt; p.tok_i -= <span class="tok-number">1</span>,</span>
<span class="line" id="L631">        }</span>
<span class="line" id="L632">        <span class="tok-kw">const</span> fn_proto = <span class="tok-kw">try</span> p.parseFnProto();</span>
<span class="line" id="L633">        <span class="tok-kw">if</span> (fn_proto != <span class="tok-number">0</span>) {</span>
<span class="line" id="L634">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L635">                .semicolon =&gt; {</span>
<span class="line" id="L636">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L637">                    <span class="tok-kw">return</span> fn_proto;</span>
<span class="line" id="L638">                },</span>
<span class="line" id="L639">                .l_brace =&gt; {</span>
<span class="line" id="L640">                    <span class="tok-kw">const</span> fn_decl_index = <span class="tok-kw">try</span> p.reserveNode();</span>
<span class="line" id="L641">                    <span class="tok-kw">const</span> body_block = <span class="tok-kw">try</span> p.parseBlock();</span>
<span class="line" id="L642">                    assert(body_block != <span class="tok-number">0</span>);</span>
<span class="line" id="L643">                    <span class="tok-kw">if</span> (is_extern) {</span>
<span class="line" id="L644">                        <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .extern_fn_body, .token = extern_export_inline_token });</span>
<span class="line" id="L645">                        <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L646">                    }</span>
<span class="line" id="L647">                    <span class="tok-kw">return</span> p.setNode(fn_decl_index, .{</span>
<span class="line" id="L648">                        .tag = .fn_decl,</span>
<span class="line" id="L649">                        .main_token = p.nodes.items(.main_token)[fn_proto],</span>
<span class="line" id="L650">                        .data = .{</span>
<span class="line" id="L651">                            .lhs = fn_proto,</span>
<span class="line" id="L652">                            .rhs = body_block,</span>
<span class="line" id="L653">                        },</span>
<span class="line" id="L654">                    });</span>
<span class="line" id="L655">                },</span>
<span class="line" id="L656">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L657">                    <span class="tok-comment">// Since parseBlock only return error.ParseError on</span>
</span>
<span class="line" id="L658">                    <span class="tok-comment">// a missing '}' we can assume this function was</span>
</span>
<span class="line" id="L659">                    <span class="tok-comment">// supposed to end here.</span>
</span>
<span class="line" id="L660">                    <span class="tok-kw">try</span> p.warn(.expected_semi_or_lbrace);</span>
<span class="line" id="L661">                    <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L662">                },</span>
<span class="line" id="L663">            }</span>
<span class="line" id="L664">        }</span>
<span class="line" id="L665">        <span class="tok-kw">if</span> (expect_fn) {</span>
<span class="line" id="L666">            <span class="tok-kw">try</span> p.warn(.expected_fn);</span>
<span class="line" id="L667">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ParseError;</span>
<span class="line" id="L668">        }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">        <span class="tok-kw">const</span> thread_local_token = p.eatToken(.keyword_threadlocal);</span>
<span class="line" id="L671">        <span class="tok-kw">const</span> var_decl = <span class="tok-kw">try</span> p.parseVarDecl();</span>
<span class="line" id="L672">        <span class="tok-kw">if</span> (var_decl != <span class="tok-number">0</span>) {</span>
<span class="line" id="L673">            <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_decl, <span class="tok-null">false</span>);</span>
<span class="line" id="L674">            <span class="tok-kw">return</span> var_decl;</span>
<span class="line" id="L675">        }</span>
<span class="line" id="L676">        <span class="tok-kw">if</span> (thread_local_token != <span class="tok-null">null</span>) {</span>
<span class="line" id="L677">            <span class="tok-kw">return</span> p.fail(.expected_var_decl);</span>
<span class="line" id="L678">        }</span>
<span class="line" id="L679">        <span class="tok-kw">if</span> (expect_var_or_fn) {</span>
<span class="line" id="L680">            <span class="tok-kw">return</span> p.fail(.expected_var_decl_or_fn);</span>
<span class="line" id="L681">        }</span>
<span class="line" id="L682">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] != .keyword_usingnamespace) {</span>
<span class="line" id="L683">            <span class="tok-kw">return</span> p.fail(.expected_pub_item);</span>
<span class="line" id="L684">        }</span>
<span class="line" id="L685">        <span class="tok-kw">return</span> p.expectUsingNamespace();</span>
<span class="line" id="L686">    }</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">    <span class="tok-kw">fn</span> <span class="tok-fn">expectTopLevelDeclRecoverable</span>(p: *Parser) <span class="tok-kw">error</span>{OutOfMemory}!Node.Index {</span>
<span class="line" id="L689">        <span class="tok-kw">return</span> p.expectTopLevelDecl() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L690">            <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L691">            <span class="tok-kw">error</span>.ParseError =&gt; {</span>
<span class="line" id="L692">                p.findNextContainerMember();</span>
<span class="line" id="L693">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L694">            },</span>
<span class="line" id="L695">        };</span>
<span class="line" id="L696">    }</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">    <span class="tok-kw">fn</span> <span class="tok-fn">expectUsingNamespace</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L699">        <span class="tok-kw">const</span> usingnamespace_token = p.assertToken(.keyword_usingnamespace);</span>
<span class="line" id="L700">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L701">        <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_decl, <span class="tok-null">false</span>);</span>
<span class="line" id="L702">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L703">            .tag = .@&quot;usingnamespace&quot;,</span>
<span class="line" id="L704">            .main_token = usingnamespace_token,</span>
<span class="line" id="L705">            .data = .{</span>
<span class="line" id="L706">                .lhs = expr,</span>
<span class="line" id="L707">                .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L708">            },</span>
<span class="line" id="L709">        });</span>
<span class="line" id="L710">    }</span>
<span class="line" id="L711"></span>
<span class="line" id="L712">    <span class="tok-kw">fn</span> <span class="tok-fn">expectUsingNamespaceRecoverable</span>(p: *Parser) <span class="tok-kw">error</span>{OutOfMemory}!Node.Index {</span>
<span class="line" id="L713">        <span class="tok-kw">return</span> p.expectUsingNamespace() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L714">            <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L715">            <span class="tok-kw">error</span>.ParseError =&gt; {</span>
<span class="line" id="L716">                p.findNextContainerMember();</span>
<span class="line" id="L717">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L718">            },</span>
<span class="line" id="L719">        };</span>
<span class="line" id="L720">    }</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">    <span class="tok-comment">/// FnProto &lt;- KEYWORD_fn IDENTIFIER? LPAREN ParamDeclList RPAREN ByteAlign? AddrSpace? LinkSection? CallConv? EXCLAMATIONMARK? TypeExpr</span></span>
<span class="line" id="L723">    <span class="tok-kw">fn</span> <span class="tok-fn">parseFnProto</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L724">        <span class="tok-kw">const</span> fn_token = p.eatToken(.keyword_fn) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">        <span class="tok-comment">// We want the fn proto node to be before its children in the array.</span>
</span>
<span class="line" id="L727">        <span class="tok-kw">const</span> fn_proto_index = <span class="tok-kw">try</span> p.reserveNode();</span>
<span class="line" id="L728"></span>
<span class="line" id="L729">        _ = p.eatToken(.identifier);</span>
<span class="line" id="L730">        <span class="tok-kw">const</span> params = <span class="tok-kw">try</span> p.parseParamDeclList();</span>
<span class="line" id="L731">        <span class="tok-kw">const</span> align_expr = <span class="tok-kw">try</span> p.parseByteAlign();</span>
<span class="line" id="L732">        <span class="tok-kw">const</span> addrspace_expr = <span class="tok-kw">try</span> p.parseAddrSpace();</span>
<span class="line" id="L733">        <span class="tok-kw">const</span> section_expr = <span class="tok-kw">try</span> p.parseLinkSection();</span>
<span class="line" id="L734">        <span class="tok-kw">const</span> callconv_expr = <span class="tok-kw">try</span> p.parseCallconv();</span>
<span class="line" id="L735">        _ = p.eatToken(.bang);</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">        <span class="tok-kw">const</span> return_type_expr = <span class="tok-kw">try</span> p.parseTypeExpr();</span>
<span class="line" id="L738">        <span class="tok-kw">if</span> (return_type_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L739">            <span class="tok-comment">// most likely the user forgot to specify the return type.</span>
</span>
<span class="line" id="L740">            <span class="tok-comment">// Mark return type as invalid and try to continue.</span>
</span>
<span class="line" id="L741">            <span class="tok-kw">try</span> p.warn(.expected_return_type);</span>
<span class="line" id="L742">        }</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">        <span class="tok-kw">if</span> (align_expr == <span class="tok-number">0</span> <span class="tok-kw">and</span> section_expr == <span class="tok-number">0</span> <span class="tok-kw">and</span> callconv_expr == <span class="tok-number">0</span> <span class="tok-kw">and</span> addrspace_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L745">            <span class="tok-kw">switch</span> (params) {</span>
<span class="line" id="L746">                .zero_or_one =&gt; |param| <span class="tok-kw">return</span> p.setNode(fn_proto_index, .{</span>
<span class="line" id="L747">                    .tag = .fn_proto_simple,</span>
<span class="line" id="L748">                    .main_token = fn_token,</span>
<span class="line" id="L749">                    .data = .{</span>
<span class="line" id="L750">                        .lhs = param,</span>
<span class="line" id="L751">                        .rhs = return_type_expr,</span>
<span class="line" id="L752">                    },</span>
<span class="line" id="L753">                }),</span>
<span class="line" id="L754">                .multi =&gt; |span| {</span>
<span class="line" id="L755">                    <span class="tok-kw">return</span> p.setNode(fn_proto_index, .{</span>
<span class="line" id="L756">                        .tag = .fn_proto_multi,</span>
<span class="line" id="L757">                        .main_token = fn_token,</span>
<span class="line" id="L758">                        .data = .{</span>
<span class="line" id="L759">                            .lhs = <span class="tok-kw">try</span> p.addExtra(Node.SubRange{</span>
<span class="line" id="L760">                                .start = span.start,</span>
<span class="line" id="L761">                                .end = span.end,</span>
<span class="line" id="L762">                            }),</span>
<span class="line" id="L763">                            .rhs = return_type_expr,</span>
<span class="line" id="L764">                        },</span>
<span class="line" id="L765">                    });</span>
<span class="line" id="L766">                },</span>
<span class="line" id="L767">            }</span>
<span class="line" id="L768">        }</span>
<span class="line" id="L769">        <span class="tok-kw">switch</span> (params) {</span>
<span class="line" id="L770">            .zero_or_one =&gt; |param| <span class="tok-kw">return</span> p.setNode(fn_proto_index, .{</span>
<span class="line" id="L771">                .tag = .fn_proto_one,</span>
<span class="line" id="L772">                .main_token = fn_token,</span>
<span class="line" id="L773">                .data = .{</span>
<span class="line" id="L774">                    .lhs = <span class="tok-kw">try</span> p.addExtra(Node.FnProtoOne{</span>
<span class="line" id="L775">                        .param = param,</span>
<span class="line" id="L776">                        .align_expr = align_expr,</span>
<span class="line" id="L777">                        .addrspace_expr = addrspace_expr,</span>
<span class="line" id="L778">                        .section_expr = section_expr,</span>
<span class="line" id="L779">                        .callconv_expr = callconv_expr,</span>
<span class="line" id="L780">                    }),</span>
<span class="line" id="L781">                    .rhs = return_type_expr,</span>
<span class="line" id="L782">                },</span>
<span class="line" id="L783">            }),</span>
<span class="line" id="L784">            .multi =&gt; |span| {</span>
<span class="line" id="L785">                <span class="tok-kw">return</span> p.setNode(fn_proto_index, .{</span>
<span class="line" id="L786">                    .tag = .fn_proto,</span>
<span class="line" id="L787">                    .main_token = fn_token,</span>
<span class="line" id="L788">                    .data = .{</span>
<span class="line" id="L789">                        .lhs = <span class="tok-kw">try</span> p.addExtra(Node.FnProto{</span>
<span class="line" id="L790">                            .params_start = span.start,</span>
<span class="line" id="L791">                            .params_end = span.end,</span>
<span class="line" id="L792">                            .align_expr = align_expr,</span>
<span class="line" id="L793">                            .addrspace_expr = addrspace_expr,</span>
<span class="line" id="L794">                            .section_expr = section_expr,</span>
<span class="line" id="L795">                            .callconv_expr = callconv_expr,</span>
<span class="line" id="L796">                        }),</span>
<span class="line" id="L797">                        .rhs = return_type_expr,</span>
<span class="line" id="L798">                    },</span>
<span class="line" id="L799">                });</span>
<span class="line" id="L800">            },</span>
<span class="line" id="L801">        }</span>
<span class="line" id="L802">    }</span>
<span class="line" id="L803"></span>
<span class="line" id="L804">    <span class="tok-comment">/// VarDecl &lt;- (KEYWORD_const / KEYWORD_var) IDENTIFIER (COLON TypeExpr)? ByteAlign? AddrSpace? LinkSection? (EQUAL Expr)? SEMICOLON</span></span>
<span class="line" id="L805">    <span class="tok-kw">fn</span> <span class="tok-fn">parseVarDecl</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L806">        <span class="tok-kw">const</span> mut_token = p.eatToken(.keyword_const) <span class="tok-kw">orelse</span></span>
<span class="line" id="L807">            p.eatToken(.keyword_var) <span class="tok-kw">orelse</span></span>
<span class="line" id="L808">            <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">        _ = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L811">        <span class="tok-kw">const</span> type_node: Node.Index = <span class="tok-kw">if</span> (p.eatToken(.colon) == <span class="tok-null">null</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L812">        <span class="tok-kw">const</span> align_node = <span class="tok-kw">try</span> p.parseByteAlign();</span>
<span class="line" id="L813">        <span class="tok-kw">const</span> addrspace_node = <span class="tok-kw">try</span> p.parseAddrSpace();</span>
<span class="line" id="L814">        <span class="tok-kw">const</span> section_node = <span class="tok-kw">try</span> p.parseLinkSection();</span>
<span class="line" id="L815">        <span class="tok-kw">const</span> init_node: Node.Index = <span class="tok-kw">if</span> (p.eatToken(.equal) == <span class="tok-null">null</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L816">        <span class="tok-kw">if</span> (section_node == <span class="tok-number">0</span> <span class="tok-kw">and</span> addrspace_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L817">            <span class="tok-kw">if</span> (align_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L818">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L819">                    .tag = .simple_var_decl,</span>
<span class="line" id="L820">                    .main_token = mut_token,</span>
<span class="line" id="L821">                    .data = .{</span>
<span class="line" id="L822">                        .lhs = type_node,</span>
<span class="line" id="L823">                        .rhs = init_node,</span>
<span class="line" id="L824">                    },</span>
<span class="line" id="L825">                });</span>
<span class="line" id="L826">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (type_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L827">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L828">                    .tag = .aligned_var_decl,</span>
<span class="line" id="L829">                    .main_token = mut_token,</span>
<span class="line" id="L830">                    .data = .{</span>
<span class="line" id="L831">                        .lhs = align_node,</span>
<span class="line" id="L832">                        .rhs = init_node,</span>
<span class="line" id="L833">                    },</span>
<span class="line" id="L834">                });</span>
<span class="line" id="L835">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L836">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L837">                    .tag = .local_var_decl,</span>
<span class="line" id="L838">                    .main_token = mut_token,</span>
<span class="line" id="L839">                    .data = .{</span>
<span class="line" id="L840">                        .lhs = <span class="tok-kw">try</span> p.addExtra(Node.LocalVarDecl{</span>
<span class="line" id="L841">                            .type_node = type_node,</span>
<span class="line" id="L842">                            .align_node = align_node,</span>
<span class="line" id="L843">                        }),</span>
<span class="line" id="L844">                        .rhs = init_node,</span>
<span class="line" id="L845">                    },</span>
<span class="line" id="L846">                });</span>
<span class="line" id="L847">            }</span>
<span class="line" id="L848">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L849">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L850">                .tag = .global_var_decl,</span>
<span class="line" id="L851">                .main_token = mut_token,</span>
<span class="line" id="L852">                .data = .{</span>
<span class="line" id="L853">                    .lhs = <span class="tok-kw">try</span> p.addExtra(Node.GlobalVarDecl{</span>
<span class="line" id="L854">                        .type_node = type_node,</span>
<span class="line" id="L855">                        .align_node = align_node,</span>
<span class="line" id="L856">                        .addrspace_node = addrspace_node,</span>
<span class="line" id="L857">                        .section_node = section_node,</span>
<span class="line" id="L858">                    }),</span>
<span class="line" id="L859">                    .rhs = init_node,</span>
<span class="line" id="L860">                },</span>
<span class="line" id="L861">            });</span>
<span class="line" id="L862">        }</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">    <span class="tok-comment">/// ContainerField &lt;- KEYWORD_comptime? IDENTIFIER (COLON TypeExpr ByteAlign?)? (EQUAL Expr)?</span></span>
<span class="line" id="L866">    <span class="tok-kw">fn</span> <span class="tok-fn">expectContainerField</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L867">        _ = p.eatToken(.keyword_comptime);</span>
<span class="line" id="L868">        <span class="tok-kw">const</span> name_token = p.assertToken(.identifier);</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">        <span class="tok-kw">var</span> align_expr: Node.Index = <span class="tok-number">0</span>;</span>
<span class="line" id="L871">        <span class="tok-kw">var</span> type_expr: Node.Index = <span class="tok-number">0</span>;</span>
<span class="line" id="L872">        <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L873">            type_expr = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L874">            align_expr = <span class="tok-kw">try</span> p.parseByteAlign();</span>
<span class="line" id="L875">        }</span>
<span class="line" id="L876"></span>
<span class="line" id="L877">        <span class="tok-kw">const</span> value_expr: Node.Index = <span class="tok-kw">if</span> (p.eatToken(.equal) == <span class="tok-null">null</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">        <span class="tok-kw">if</span> (align_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L880">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L881">                .tag = .container_field_init,</span>
<span class="line" id="L882">                .main_token = name_token,</span>
<span class="line" id="L883">                .data = .{</span>
<span class="line" id="L884">                    .lhs = type_expr,</span>
<span class="line" id="L885">                    .rhs = value_expr,</span>
<span class="line" id="L886">                },</span>
<span class="line" id="L887">            });</span>
<span class="line" id="L888">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (value_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L889">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L890">                .tag = .container_field_align,</span>
<span class="line" id="L891">                .main_token = name_token,</span>
<span class="line" id="L892">                .data = .{</span>
<span class="line" id="L893">                    .lhs = type_expr,</span>
<span class="line" id="L894">                    .rhs = align_expr,</span>
<span class="line" id="L895">                },</span>
<span class="line" id="L896">            });</span>
<span class="line" id="L897">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L898">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L899">                .tag = .container_field,</span>
<span class="line" id="L900">                .main_token = name_token,</span>
<span class="line" id="L901">                .data = .{</span>
<span class="line" id="L902">                    .lhs = type_expr,</span>
<span class="line" id="L903">                    .rhs = <span class="tok-kw">try</span> p.addExtra(Node.ContainerField{</span>
<span class="line" id="L904">                        .value_expr = value_expr,</span>
<span class="line" id="L905">                        .align_expr = align_expr,</span>
<span class="line" id="L906">                    }),</span>
<span class="line" id="L907">                },</span>
<span class="line" id="L908">            });</span>
<span class="line" id="L909">        }</span>
<span class="line" id="L910">    }</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-kw">fn</span> <span class="tok-fn">expectContainerFieldRecoverable</span>(p: *Parser) <span class="tok-kw">error</span>{OutOfMemory}!Node.Index {</span>
<span class="line" id="L913">        <span class="tok-kw">return</span> p.expectContainerField() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L914">            <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L915">            <span class="tok-kw">error</span>.ParseError =&gt; {</span>
<span class="line" id="L916">                p.findNextContainerMember();</span>
<span class="line" id="L917">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L918">            },</span>
<span class="line" id="L919">        };</span>
<span class="line" id="L920">    }</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">    <span class="tok-comment">/// Statement</span></span>
<span class="line" id="L923">    <span class="tok-comment">///     &lt;- KEYWORD_comptime? VarDecl</span></span>
<span class="line" id="L924">    <span class="tok-comment">///      / KEYWORD_comptime BlockExprStatement</span></span>
<span class="line" id="L925">    <span class="tok-comment">///      / KEYWORD_nosuspend BlockExprStatement</span></span>
<span class="line" id="L926">    <span class="tok-comment">///      / KEYWORD_suspend BlockExprStatement</span></span>
<span class="line" id="L927">    <span class="tok-comment">///      / KEYWORD_defer BlockExprStatement</span></span>
<span class="line" id="L928">    <span class="tok-comment">///      / KEYWORD_errdefer Payload? BlockExprStatement</span></span>
<span class="line" id="L929">    <span class="tok-comment">///      / IfStatement</span></span>
<span class="line" id="L930">    <span class="tok-comment">///      / LabeledStatement</span></span>
<span class="line" id="L931">    <span class="tok-comment">///      / SwitchExpr</span></span>
<span class="line" id="L932">    <span class="tok-comment">///      / AssignExpr SEMICOLON</span></span>
<span class="line" id="L933">    <span class="tok-kw">fn</span> <span class="tok-fn">parseStatement</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L934">        <span class="tok-kw">const</span> comptime_token = p.eatToken(.keyword_comptime);</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">        <span class="tok-kw">const</span> var_decl = <span class="tok-kw">try</span> p.parseVarDecl();</span>
<span class="line" id="L937">        <span class="tok-kw">if</span> (var_decl != <span class="tok-number">0</span>) {</span>
<span class="line" id="L938">            <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_decl, <span class="tok-null">true</span>);</span>
<span class="line" id="L939">            <span class="tok-kw">return</span> var_decl;</span>
<span class="line" id="L940">        }</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        <span class="tok-kw">if</span> (comptime_token) |token| {</span>
<span class="line" id="L943">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L944">                .tag = .@&quot;comptime&quot;,</span>
<span class="line" id="L945">                .main_token = token,</span>
<span class="line" id="L946">                .data = .{</span>
<span class="line" id="L947">                    .lhs = <span class="tok-kw">try</span> p.expectBlockExprStatement(),</span>
<span class="line" id="L948">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L949">                },</span>
<span class="line" id="L950">            });</span>
<span class="line" id="L951">        }</span>
<span class="line" id="L952"></span>
<span class="line" id="L953">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L954">            .keyword_nosuspend =&gt; {</span>
<span class="line" id="L955">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L956">                    .tag = .@&quot;nosuspend&quot;,</span>
<span class="line" id="L957">                    .main_token = p.nextToken(),</span>
<span class="line" id="L958">                    .data = .{</span>
<span class="line" id="L959">                        .lhs = <span class="tok-kw">try</span> p.expectBlockExprStatement(),</span>
<span class="line" id="L960">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L961">                    },</span>
<span class="line" id="L962">                });</span>
<span class="line" id="L963">            },</span>
<span class="line" id="L964">            .keyword_suspend =&gt; {</span>
<span class="line" id="L965">                <span class="tok-kw">const</span> token = p.nextToken();</span>
<span class="line" id="L966">                <span class="tok-kw">const</span> block_expr = <span class="tok-kw">try</span> p.expectBlockExprStatement();</span>
<span class="line" id="L967">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L968">                    .tag = .@&quot;suspend&quot;,</span>
<span class="line" id="L969">                    .main_token = token,</span>
<span class="line" id="L970">                    .data = .{</span>
<span class="line" id="L971">                        .lhs = block_expr,</span>
<span class="line" id="L972">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L973">                    },</span>
<span class="line" id="L974">                });</span>
<span class="line" id="L975">            },</span>
<span class="line" id="L976">            .keyword_defer =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L977">                .tag = .@&quot;defer&quot;,</span>
<span class="line" id="L978">                .main_token = p.nextToken(),</span>
<span class="line" id="L979">                .data = .{</span>
<span class="line" id="L980">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L981">                    .rhs = <span class="tok-kw">try</span> p.expectBlockExprStatement(),</span>
<span class="line" id="L982">                },</span>
<span class="line" id="L983">            }),</span>
<span class="line" id="L984">            .keyword_errdefer =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L985">                .tag = .@&quot;errdefer&quot;,</span>
<span class="line" id="L986">                .main_token = p.nextToken(),</span>
<span class="line" id="L987">                .data = .{</span>
<span class="line" id="L988">                    .lhs = <span class="tok-kw">try</span> p.parsePayload(),</span>
<span class="line" id="L989">                    .rhs = <span class="tok-kw">try</span> p.expectBlockExprStatement(),</span>
<span class="line" id="L990">                },</span>
<span class="line" id="L991">            }),</span>
<span class="line" id="L992">            .keyword_switch =&gt; <span class="tok-kw">return</span> p.expectSwitchExpr(),</span>
<span class="line" id="L993">            .keyword_if =&gt; <span class="tok-kw">return</span> p.expectIfStatement(),</span>
<span class="line" id="L994">            .keyword_enum, .keyword_struct, .keyword_union =&gt; {</span>
<span class="line" id="L995">                <span class="tok-kw">const</span> identifier = p.tok_i + <span class="tok-number">1</span>;</span>
<span class="line" id="L996">                <span class="tok-kw">if</span> (<span class="tok-kw">try</span> p.parseCStyleContainer()) {</span>
<span class="line" id="L997">                    <span class="tok-comment">// Return something so that `expectStatement` is happy.</span>
</span>
<span class="line" id="L998">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L999">                        .tag = .identifier,</span>
<span class="line" id="L1000">                        .main_token = identifier,</span>
<span class="line" id="L1001">                        .data = .{</span>
<span class="line" id="L1002">                            .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1003">                            .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1004">                        },</span>
<span class="line" id="L1005">                    });</span>
<span class="line" id="L1006">                }</span>
<span class="line" id="L1007">            },</span>
<span class="line" id="L1008">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1009">        }</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011">        <span class="tok-kw">const</span> labeled_statement = <span class="tok-kw">try</span> p.parseLabeledStatement();</span>
<span class="line" id="L1012">        <span class="tok-kw">if</span> (labeled_statement != <span class="tok-number">0</span>) <span class="tok-kw">return</span> labeled_statement;</span>
<span class="line" id="L1013"></span>
<span class="line" id="L1014">        <span class="tok-kw">const</span> assign_expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1015">        <span class="tok-kw">if</span> (assign_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1016">            <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_stmt, <span class="tok-null">true</span>);</span>
<span class="line" id="L1017">            <span class="tok-kw">return</span> assign_expr;</span>
<span class="line" id="L1018">        }</span>
<span class="line" id="L1019"></span>
<span class="line" id="L1020">        <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1021">    }</span>
<span class="line" id="L1022"></span>
<span class="line" id="L1023">    <span class="tok-kw">fn</span> <span class="tok-fn">expectStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1024">        <span class="tok-kw">const</span> statement = <span class="tok-kw">try</span> p.parseStatement();</span>
<span class="line" id="L1025">        <span class="tok-kw">if</span> (statement == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1026">            <span class="tok-kw">return</span> p.fail(.expected_statement);</span>
<span class="line" id="L1027">        }</span>
<span class="line" id="L1028">        <span class="tok-kw">return</span> statement;</span>
<span class="line" id="L1029">    }</span>
<span class="line" id="L1030"></span>
<span class="line" id="L1031">    <span class="tok-comment">/// If a parse error occurs, reports an error, but then finds the next statement</span></span>
<span class="line" id="L1032">    <span class="tok-comment">/// and returns that one instead. If a parse error occurs but there is no following</span></span>
<span class="line" id="L1033">    <span class="tok-comment">/// statement, returns 0.</span></span>
<span class="line" id="L1034">    <span class="tok-kw">fn</span> <span class="tok-fn">expectStatementRecoverable</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1035">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1036">            <span class="tok-kw">return</span> p.expectStatement() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1037">                <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L1038">                <span class="tok-kw">error</span>.ParseError =&gt; {</span>
<span class="line" id="L1039">                    p.findNextStmt(); <span class="tok-comment">// Try to skip to the next statement.</span>
</span>
<span class="line" id="L1040">                    <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1041">                        .r_brace =&gt; <span class="tok-kw">return</span> null_node,</span>
<span class="line" id="L1042">                        .eof =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ParseError,</span>
<span class="line" id="L1043">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1044">                    }</span>
<span class="line" id="L1045">                },</span>
<span class="line" id="L1046">            };</span>
<span class="line" id="L1047">        }</span>
<span class="line" id="L1048">    }</span>
<span class="line" id="L1049"></span>
<span class="line" id="L1050">    <span class="tok-comment">/// IfStatement</span></span>
<span class="line" id="L1051">    <span class="tok-comment">///     &lt;- IfPrefix BlockExpr ( KEYWORD_else Payload? Statement )?</span></span>
<span class="line" id="L1052">    <span class="tok-comment">///      / IfPrefix AssignExpr ( SEMICOLON / KEYWORD_else Payload? Statement )</span></span>
<span class="line" id="L1053">    <span class="tok-kw">fn</span> <span class="tok-fn">expectIfStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1054">        <span class="tok-kw">const</span> if_token = p.assertToken(.keyword_if);</span>
<span class="line" id="L1055">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L1056">        <span class="tok-kw">const</span> condition = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L1057">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L1058">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L1059"></span>
<span class="line" id="L1060">        <span class="tok-comment">// TODO propose to change the syntax so that semicolons are always required</span>
</span>
<span class="line" id="L1061">        <span class="tok-comment">// inside if statements, even if there is an `else`.</span>
</span>
<span class="line" id="L1062">        <span class="tok-kw">var</span> else_required = <span class="tok-null">false</span>;</span>
<span class="line" id="L1063">        <span class="tok-kw">const</span> then_expr = blk: {</span>
<span class="line" id="L1064">            <span class="tok-kw">const</span> block_expr = <span class="tok-kw">try</span> p.parseBlockExpr();</span>
<span class="line" id="L1065">            <span class="tok-kw">if</span> (block_expr != <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk block_expr;</span>
<span class="line" id="L1066">            <span class="tok-kw">const</span> assign_expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1067">            <span class="tok-kw">if</span> (assign_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1068">                <span class="tok-kw">return</span> p.fail(.expected_block_or_assignment);</span>
<span class="line" id="L1069">            }</span>
<span class="line" id="L1070">            <span class="tok-kw">if</span> (p.eatToken(.semicolon)) |_| {</span>
<span class="line" id="L1071">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1072">                    .tag = .if_simple,</span>
<span class="line" id="L1073">                    .main_token = if_token,</span>
<span class="line" id="L1074">                    .data = .{</span>
<span class="line" id="L1075">                        .lhs = condition,</span>
<span class="line" id="L1076">                        .rhs = assign_expr,</span>
<span class="line" id="L1077">                    },</span>
<span class="line" id="L1078">                });</span>
<span class="line" id="L1079">            }</span>
<span class="line" id="L1080">            else_required = <span class="tok-null">true</span>;</span>
<span class="line" id="L1081">            <span class="tok-kw">break</span> :blk assign_expr;</span>
<span class="line" id="L1082">        };</span>
<span class="line" id="L1083">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1084">            <span class="tok-kw">if</span> (else_required) {</span>
<span class="line" id="L1085">                <span class="tok-kw">try</span> p.warn(.expected_semi_or_else);</span>
<span class="line" id="L1086">            }</span>
<span class="line" id="L1087">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1088">                .tag = .if_simple,</span>
<span class="line" id="L1089">                .main_token = if_token,</span>
<span class="line" id="L1090">                .data = .{</span>
<span class="line" id="L1091">                    .lhs = condition,</span>
<span class="line" id="L1092">                    .rhs = then_expr,</span>
<span class="line" id="L1093">                },</span>
<span class="line" id="L1094">            });</span>
<span class="line" id="L1095">        };</span>
<span class="line" id="L1096">        _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L1097">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectStatement();</span>
<span class="line" id="L1098">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1099">            .tag = .@&quot;if&quot;,</span>
<span class="line" id="L1100">            .main_token = if_token,</span>
<span class="line" id="L1101">            .data = .{</span>
<span class="line" id="L1102">                .lhs = condition,</span>
<span class="line" id="L1103">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.If{</span>
<span class="line" id="L1104">                    .then_expr = then_expr,</span>
<span class="line" id="L1105">                    .else_expr = else_expr,</span>
<span class="line" id="L1106">                }),</span>
<span class="line" id="L1107">            },</span>
<span class="line" id="L1108">        });</span>
<span class="line" id="L1109">    }</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">    <span class="tok-comment">/// LabeledStatement &lt;- BlockLabel? (Block / LoopStatement)</span></span>
<span class="line" id="L1112">    <span class="tok-kw">fn</span> <span class="tok-fn">parseLabeledStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1113">        <span class="tok-kw">const</span> label_token = p.parseBlockLabel();</span>
<span class="line" id="L1114">        <span class="tok-kw">const</span> block = <span class="tok-kw">try</span> p.parseBlock();</span>
<span class="line" id="L1115">        <span class="tok-kw">if</span> (block != <span class="tok-number">0</span>) <span class="tok-kw">return</span> block;</span>
<span class="line" id="L1116"></span>
<span class="line" id="L1117">        <span class="tok-kw">const</span> loop_stmt = <span class="tok-kw">try</span> p.parseLoopStatement();</span>
<span class="line" id="L1118">        <span class="tok-kw">if</span> (loop_stmt != <span class="tok-number">0</span>) <span class="tok-kw">return</span> loop_stmt;</span>
<span class="line" id="L1119"></span>
<span class="line" id="L1120">        <span class="tok-kw">if</span> (label_token != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1121">            <span class="tok-kw">return</span> p.fail(.expected_labelable);</span>
<span class="line" id="L1122">        }</span>
<span class="line" id="L1123"></span>
<span class="line" id="L1124">        <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1125">    }</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127">    <span class="tok-comment">/// LoopStatement &lt;- KEYWORD_inline? (ForStatement / WhileStatement)</span></span>
<span class="line" id="L1128">    <span class="tok-kw">fn</span> <span class="tok-fn">parseLoopStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1129">        <span class="tok-kw">const</span> inline_token = p.eatToken(.keyword_inline);</span>
<span class="line" id="L1130"></span>
<span class="line" id="L1131">        <span class="tok-kw">const</span> for_statement = <span class="tok-kw">try</span> p.parseForStatement();</span>
<span class="line" id="L1132">        <span class="tok-kw">if</span> (for_statement != <span class="tok-number">0</span>) <span class="tok-kw">return</span> for_statement;</span>
<span class="line" id="L1133"></span>
<span class="line" id="L1134">        <span class="tok-kw">const</span> while_statement = <span class="tok-kw">try</span> p.parseWhileStatement();</span>
<span class="line" id="L1135">        <span class="tok-kw">if</span> (while_statement != <span class="tok-number">0</span>) <span class="tok-kw">return</span> while_statement;</span>
<span class="line" id="L1136"></span>
<span class="line" id="L1137">        <span class="tok-kw">if</span> (inline_token == <span class="tok-null">null</span>) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1138"></span>
<span class="line" id="L1139">        <span class="tok-comment">// If we've seen &quot;inline&quot;, there should have been a &quot;for&quot; or &quot;while&quot;</span>
</span>
<span class="line" id="L1140">        <span class="tok-kw">return</span> p.fail(.expected_inlinable);</span>
<span class="line" id="L1141">    }</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143">    <span class="tok-comment">/// ForPrefix &lt;- KEYWORD_for LPAREN Expr RPAREN PtrIndexPayload</span></span>
<span class="line" id="L1144">    <span class="tok-comment">/// ForStatement</span></span>
<span class="line" id="L1145">    <span class="tok-comment">///     &lt;- ForPrefix BlockExpr ( KEYWORD_else Statement )?</span></span>
<span class="line" id="L1146">    <span class="tok-comment">///      / ForPrefix AssignExpr ( SEMICOLON / KEYWORD_else Statement )</span></span>
<span class="line" id="L1147">    <span class="tok-kw">fn</span> <span class="tok-fn">parseForStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1148">        <span class="tok-kw">const</span> for_token = p.eatToken(.keyword_for) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1149">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L1150">        <span class="tok-kw">const</span> array_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L1151">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L1152">        <span class="tok-kw">const</span> found_payload = <span class="tok-kw">try</span> p.parsePtrIndexPayload();</span>
<span class="line" id="L1153">        <span class="tok-kw">if</span> (found_payload == <span class="tok-number">0</span>) <span class="tok-kw">try</span> p.warn(.expected_loop_payload);</span>
<span class="line" id="L1154"></span>
<span class="line" id="L1155">        <span class="tok-comment">// TODO propose to change the syntax so that semicolons are always required</span>
</span>
<span class="line" id="L1156">        <span class="tok-comment">// inside while statements, even if there is an `else`.</span>
</span>
<span class="line" id="L1157">        <span class="tok-kw">var</span> else_required = <span class="tok-null">false</span>;</span>
<span class="line" id="L1158">        <span class="tok-kw">const</span> then_expr = blk: {</span>
<span class="line" id="L1159">            <span class="tok-kw">const</span> block_expr = <span class="tok-kw">try</span> p.parseBlockExpr();</span>
<span class="line" id="L1160">            <span class="tok-kw">if</span> (block_expr != <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk block_expr;</span>
<span class="line" id="L1161">            <span class="tok-kw">const</span> assign_expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1162">            <span class="tok-kw">if</span> (assign_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1163">                <span class="tok-kw">return</span> p.fail(.expected_block_or_assignment);</span>
<span class="line" id="L1164">            }</span>
<span class="line" id="L1165">            <span class="tok-kw">if</span> (p.eatToken(.semicolon)) |_| {</span>
<span class="line" id="L1166">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1167">                    .tag = .for_simple,</span>
<span class="line" id="L1168">                    .main_token = for_token,</span>
<span class="line" id="L1169">                    .data = .{</span>
<span class="line" id="L1170">                        .lhs = array_expr,</span>
<span class="line" id="L1171">                        .rhs = assign_expr,</span>
<span class="line" id="L1172">                    },</span>
<span class="line" id="L1173">                });</span>
<span class="line" id="L1174">            }</span>
<span class="line" id="L1175">            else_required = <span class="tok-null">true</span>;</span>
<span class="line" id="L1176">            <span class="tok-kw">break</span> :blk assign_expr;</span>
<span class="line" id="L1177">        };</span>
<span class="line" id="L1178">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1179">            <span class="tok-kw">if</span> (else_required) {</span>
<span class="line" id="L1180">                <span class="tok-kw">try</span> p.warn(.expected_semi_or_else);</span>
<span class="line" id="L1181">            }</span>
<span class="line" id="L1182">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1183">                .tag = .for_simple,</span>
<span class="line" id="L1184">                .main_token = for_token,</span>
<span class="line" id="L1185">                .data = .{</span>
<span class="line" id="L1186">                    .lhs = array_expr,</span>
<span class="line" id="L1187">                    .rhs = then_expr,</span>
<span class="line" id="L1188">                },</span>
<span class="line" id="L1189">            });</span>
<span class="line" id="L1190">        };</span>
<span class="line" id="L1191">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1192">            .tag = .@&quot;for&quot;,</span>
<span class="line" id="L1193">            .main_token = for_token,</span>
<span class="line" id="L1194">            .data = .{</span>
<span class="line" id="L1195">                .lhs = array_expr,</span>
<span class="line" id="L1196">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.If{</span>
<span class="line" id="L1197">                    .then_expr = then_expr,</span>
<span class="line" id="L1198">                    .else_expr = <span class="tok-kw">try</span> p.expectStatement(),</span>
<span class="line" id="L1199">                }),</span>
<span class="line" id="L1200">            },</span>
<span class="line" id="L1201">        });</span>
<span class="line" id="L1202">    }</span>
<span class="line" id="L1203"></span>
<span class="line" id="L1204">    <span class="tok-comment">/// WhilePrefix &lt;- KEYWORD_while LPAREN Expr RPAREN PtrPayload? WhileContinueExpr?</span></span>
<span class="line" id="L1205">    <span class="tok-comment">/// WhileStatement</span></span>
<span class="line" id="L1206">    <span class="tok-comment">///     &lt;- WhilePrefix BlockExpr ( KEYWORD_else Payload? Statement )?</span></span>
<span class="line" id="L1207">    <span class="tok-comment">///      / WhilePrefix AssignExpr ( SEMICOLON / KEYWORD_else Payload? Statement )</span></span>
<span class="line" id="L1208">    <span class="tok-kw">fn</span> <span class="tok-fn">parseWhileStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1209">        <span class="tok-kw">const</span> while_token = p.eatToken(.keyword_while) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1210">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L1211">        <span class="tok-kw">const</span> condition = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L1212">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L1213">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L1214">        <span class="tok-kw">const</span> cont_expr = <span class="tok-kw">try</span> p.parseWhileContinueExpr();</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216">        <span class="tok-comment">// TODO propose to change the syntax so that semicolons are always required</span>
</span>
<span class="line" id="L1217">        <span class="tok-comment">// inside while statements, even if there is an `else`.</span>
</span>
<span class="line" id="L1218">        <span class="tok-kw">var</span> else_required = <span class="tok-null">false</span>;</span>
<span class="line" id="L1219">        <span class="tok-kw">const</span> then_expr = blk: {</span>
<span class="line" id="L1220">            <span class="tok-kw">const</span> block_expr = <span class="tok-kw">try</span> p.parseBlockExpr();</span>
<span class="line" id="L1221">            <span class="tok-kw">if</span> (block_expr != <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk block_expr;</span>
<span class="line" id="L1222">            <span class="tok-kw">const</span> assign_expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1223">            <span class="tok-kw">if</span> (assign_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1224">                <span class="tok-kw">return</span> p.fail(.expected_block_or_assignment);</span>
<span class="line" id="L1225">            }</span>
<span class="line" id="L1226">            <span class="tok-kw">if</span> (p.eatToken(.semicolon)) |_| {</span>
<span class="line" id="L1227">                <span class="tok-kw">if</span> (cont_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1228">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1229">                        .tag = .while_simple,</span>
<span class="line" id="L1230">                        .main_token = while_token,</span>
<span class="line" id="L1231">                        .data = .{</span>
<span class="line" id="L1232">                            .lhs = condition,</span>
<span class="line" id="L1233">                            .rhs = assign_expr,</span>
<span class="line" id="L1234">                        },</span>
<span class="line" id="L1235">                    });</span>
<span class="line" id="L1236">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1237">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1238">                        .tag = .while_cont,</span>
<span class="line" id="L1239">                        .main_token = while_token,</span>
<span class="line" id="L1240">                        .data = .{</span>
<span class="line" id="L1241">                            .lhs = condition,</span>
<span class="line" id="L1242">                            .rhs = <span class="tok-kw">try</span> p.addExtra(Node.WhileCont{</span>
<span class="line" id="L1243">                                .cont_expr = cont_expr,</span>
<span class="line" id="L1244">                                .then_expr = assign_expr,</span>
<span class="line" id="L1245">                            }),</span>
<span class="line" id="L1246">                        },</span>
<span class="line" id="L1247">                    });</span>
<span class="line" id="L1248">                }</span>
<span class="line" id="L1249">            }</span>
<span class="line" id="L1250">            else_required = <span class="tok-null">true</span>;</span>
<span class="line" id="L1251">            <span class="tok-kw">break</span> :blk assign_expr;</span>
<span class="line" id="L1252">        };</span>
<span class="line" id="L1253">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1254">            <span class="tok-kw">if</span> (else_required) {</span>
<span class="line" id="L1255">                <span class="tok-kw">try</span> p.warn(.expected_semi_or_else);</span>
<span class="line" id="L1256">            }</span>
<span class="line" id="L1257">            <span class="tok-kw">if</span> (cont_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1258">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1259">                    .tag = .while_simple,</span>
<span class="line" id="L1260">                    .main_token = while_token,</span>
<span class="line" id="L1261">                    .data = .{</span>
<span class="line" id="L1262">                        .lhs = condition,</span>
<span class="line" id="L1263">                        .rhs = then_expr,</span>
<span class="line" id="L1264">                    },</span>
<span class="line" id="L1265">                });</span>
<span class="line" id="L1266">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1267">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1268">                    .tag = .while_cont,</span>
<span class="line" id="L1269">                    .main_token = while_token,</span>
<span class="line" id="L1270">                    .data = .{</span>
<span class="line" id="L1271">                        .lhs = condition,</span>
<span class="line" id="L1272">                        .rhs = <span class="tok-kw">try</span> p.addExtra(Node.WhileCont{</span>
<span class="line" id="L1273">                            .cont_expr = cont_expr,</span>
<span class="line" id="L1274">                            .then_expr = then_expr,</span>
<span class="line" id="L1275">                        }),</span>
<span class="line" id="L1276">                    },</span>
<span class="line" id="L1277">                });</span>
<span class="line" id="L1278">            }</span>
<span class="line" id="L1279">        };</span>
<span class="line" id="L1280">        _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L1281">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectStatement();</span>
<span class="line" id="L1282">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1283">            .tag = .@&quot;while&quot;,</span>
<span class="line" id="L1284">            .main_token = while_token,</span>
<span class="line" id="L1285">            .data = .{</span>
<span class="line" id="L1286">                .lhs = condition,</span>
<span class="line" id="L1287">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.While{</span>
<span class="line" id="L1288">                    .cont_expr = cont_expr,</span>
<span class="line" id="L1289">                    .then_expr = then_expr,</span>
<span class="line" id="L1290">                    .else_expr = else_expr,</span>
<span class="line" id="L1291">                }),</span>
<span class="line" id="L1292">            },</span>
<span class="line" id="L1293">        });</span>
<span class="line" id="L1294">    }</span>
<span class="line" id="L1295"></span>
<span class="line" id="L1296">    <span class="tok-comment">/// BlockExprStatement</span></span>
<span class="line" id="L1297">    <span class="tok-comment">///     &lt;- BlockExpr</span></span>
<span class="line" id="L1298">    <span class="tok-comment">///      / AssignExpr SEMICOLON</span></span>
<span class="line" id="L1299">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBlockExprStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1300">        <span class="tok-kw">const</span> block_expr = <span class="tok-kw">try</span> p.parseBlockExpr();</span>
<span class="line" id="L1301">        <span class="tok-kw">if</span> (block_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1302">            <span class="tok-kw">return</span> block_expr;</span>
<span class="line" id="L1303">        }</span>
<span class="line" id="L1304">        <span class="tok-kw">const</span> assign_expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1305">        <span class="tok-kw">if</span> (assign_expr != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1306">            <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_stmt, <span class="tok-null">true</span>);</span>
<span class="line" id="L1307">            <span class="tok-kw">return</span> assign_expr;</span>
<span class="line" id="L1308">        }</span>
<span class="line" id="L1309">        <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1310">    }</span>
<span class="line" id="L1311"></span>
<span class="line" id="L1312">    <span class="tok-kw">fn</span> <span class="tok-fn">expectBlockExprStatement</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1313">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parseBlockExprStatement();</span>
<span class="line" id="L1314">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1315">            <span class="tok-kw">return</span> p.fail(.expected_block_or_expr);</span>
<span class="line" id="L1316">        }</span>
<span class="line" id="L1317">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1318">    }</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">    <span class="tok-comment">/// BlockExpr &lt;- BlockLabel? Block</span></span>
<span class="line" id="L1321">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBlockExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1322">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1323">            .identifier =&gt; {</span>
<span class="line" id="L1324">                <span class="tok-kw">if</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>] == .colon <span class="tok-kw">and</span></span>
<span class="line" id="L1325">                    p.token_tags[p.tok_i + <span class="tok-number">2</span>] == .l_brace)</span>
<span class="line" id="L1326">                {</span>
<span class="line" id="L1327">                    p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L1328">                    <span class="tok-kw">return</span> p.parseBlock();</span>
<span class="line" id="L1329">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1330">                    <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1331">                }</span>
<span class="line" id="L1332">            },</span>
<span class="line" id="L1333">            .l_brace =&gt; <span class="tok-kw">return</span> p.parseBlock(),</span>
<span class="line" id="L1334">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> null_node,</span>
<span class="line" id="L1335">        }</span>
<span class="line" id="L1336">    }</span>
<span class="line" id="L1337"></span>
<span class="line" id="L1338">    <span class="tok-comment">/// AssignExpr &lt;- Expr (AssignOp Expr)?</span></span>
<span class="line" id="L1339">    <span class="tok-comment">/// AssignOp</span></span>
<span class="line" id="L1340">    <span class="tok-comment">///     &lt;- ASTERISKEQUAL</span></span>
<span class="line" id="L1341">    <span class="tok-comment">///      / SLASHEQUAL</span></span>
<span class="line" id="L1342">    <span class="tok-comment">///      / PERCENTEQUAL</span></span>
<span class="line" id="L1343">    <span class="tok-comment">///      / PLUSEQUAL</span></span>
<span class="line" id="L1344">    <span class="tok-comment">///      / MINUSEQUAL</span></span>
<span class="line" id="L1345">    <span class="tok-comment">///      / LARROW2EQUAL</span></span>
<span class="line" id="L1346">    <span class="tok-comment">///      / RARROW2EQUAL</span></span>
<span class="line" id="L1347">    <span class="tok-comment">///      / AMPERSANDEQUAL</span></span>
<span class="line" id="L1348">    <span class="tok-comment">///      / CARETEQUAL</span></span>
<span class="line" id="L1349">    <span class="tok-comment">///      / PIPEEQUAL</span></span>
<span class="line" id="L1350">    <span class="tok-comment">///      / ASTERISKPERCENTEQUAL</span></span>
<span class="line" id="L1351">    <span class="tok-comment">///      / PLUSPERCENTEQUAL</span></span>
<span class="line" id="L1352">    <span class="tok-comment">///      / MINUSPERCENTEQUAL</span></span>
<span class="line" id="L1353">    <span class="tok-comment">///      / EQUAL</span></span>
<span class="line" id="L1354">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAssignExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1355">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.parseExpr();</span>
<span class="line" id="L1356">        <span class="tok-kw">if</span> (expr == <span class="tok-number">0</span>) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1357"></span>
<span class="line" id="L1358">        <span class="tok-kw">const</span> tag: Node.Tag = <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1359">            .asterisk_equal =&gt; .assign_mul,</span>
<span class="line" id="L1360">            .slash_equal =&gt; .assign_div,</span>
<span class="line" id="L1361">            .percent_equal =&gt; .assign_mod,</span>
<span class="line" id="L1362">            .plus_equal =&gt; .assign_add,</span>
<span class="line" id="L1363">            .minus_equal =&gt; .assign_sub,</span>
<span class="line" id="L1364">            .angle_bracket_angle_bracket_left_equal =&gt; .assign_shl,</span>
<span class="line" id="L1365">            .angle_bracket_angle_bracket_left_pipe_equal =&gt; .assign_shl_sat,</span>
<span class="line" id="L1366">            .angle_bracket_angle_bracket_right_equal =&gt; .assign_shr,</span>
<span class="line" id="L1367">            .ampersand_equal =&gt; .assign_bit_and,</span>
<span class="line" id="L1368">            .caret_equal =&gt; .assign_bit_xor,</span>
<span class="line" id="L1369">            .pipe_equal =&gt; .assign_bit_or,</span>
<span class="line" id="L1370">            .asterisk_percent_equal =&gt; .assign_mul_wrap,</span>
<span class="line" id="L1371">            .plus_percent_equal =&gt; .assign_add_wrap,</span>
<span class="line" id="L1372">            .minus_percent_equal =&gt; .assign_sub_wrap,</span>
<span class="line" id="L1373">            .asterisk_pipe_equal =&gt; .assign_mul_sat,</span>
<span class="line" id="L1374">            .plus_pipe_equal =&gt; .assign_add_sat,</span>
<span class="line" id="L1375">            .minus_pipe_equal =&gt; .assign_sub_sat,</span>
<span class="line" id="L1376">            .equal =&gt; .assign,</span>
<span class="line" id="L1377">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> expr,</span>
<span class="line" id="L1378">        };</span>
<span class="line" id="L1379">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1380">            .tag = tag,</span>
<span class="line" id="L1381">            .main_token = p.nextToken(),</span>
<span class="line" id="L1382">            .data = .{</span>
<span class="line" id="L1383">                .lhs = expr,</span>
<span class="line" id="L1384">                .rhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L1385">            },</span>
<span class="line" id="L1386">        });</span>
<span class="line" id="L1387">    }</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389">    <span class="tok-kw">fn</span> <span class="tok-fn">expectAssignExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1390">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L1391">        <span class="tok-kw">if</span> (expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1392">            <span class="tok-kw">return</span> p.fail(.expected_expr_or_assignment);</span>
<span class="line" id="L1393">        }</span>
<span class="line" id="L1394">        <span class="tok-kw">return</span> expr;</span>
<span class="line" id="L1395">    }</span>
<span class="line" id="L1396"></span>
<span class="line" id="L1397">    <span class="tok-kw">fn</span> <span class="tok-fn">parseExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1398">        <span class="tok-kw">return</span> p.parseExprPrecedence(<span class="tok-number">0</span>);</span>
<span class="line" id="L1399">    }</span>
<span class="line" id="L1400"></span>
<span class="line" id="L1401">    <span class="tok-kw">fn</span> <span class="tok-fn">expectExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1402">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parseExpr();</span>
<span class="line" id="L1403">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1404">            <span class="tok-kw">return</span> p.fail(.expected_expr);</span>
<span class="line" id="L1405">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1406">            <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1407">        }</span>
<span class="line" id="L1408">    }</span>
<span class="line" id="L1409"></span>
<span class="line" id="L1410">    <span class="tok-kw">const</span> Assoc = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L1411">        left,</span>
<span class="line" id="L1412">        none,</span>
<span class="line" id="L1413">    };</span>
<span class="line" id="L1414"></span>
<span class="line" id="L1415">    <span class="tok-kw">const</span> OperInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1416">        prec: <span class="tok-type">i8</span>,</span>
<span class="line" id="L1417">        tag: Node.Tag,</span>
<span class="line" id="L1418">        assoc: Assoc = Assoc.left,</span>
<span class="line" id="L1419">    };</span>
<span class="line" id="L1420"></span>
<span class="line" id="L1421">    <span class="tok-comment">// A table of binary operator information. Higher precedence numbers are</span>
</span>
<span class="line" id="L1422">    <span class="tok-comment">// stickier. All operators at the same precedence level should have the same</span>
</span>
<span class="line" id="L1423">    <span class="tok-comment">// associativity.</span>
</span>
<span class="line" id="L1424">    <span class="tok-kw">const</span> operTable = std.enums.directEnumArrayDefault(Token.Tag, OperInfo, .{ .prec = -<span class="tok-number">1</span>, .tag = Node.Tag.root }, <span class="tok-number">0</span>, .{</span>
<span class="line" id="L1425">        .keyword_or = .{ .prec = <span class="tok-number">10</span>, .tag = .bool_or },</span>
<span class="line" id="L1426"></span>
<span class="line" id="L1427">        .keyword_and = .{ .prec = <span class="tok-number">20</span>, .tag = .bool_and },</span>
<span class="line" id="L1428"></span>
<span class="line" id="L1429">        .equal_equal = .{ .prec = <span class="tok-number">30</span>, .tag = .equal_equal, .assoc = Assoc.none },</span>
<span class="line" id="L1430">        .bang_equal = .{ .prec = <span class="tok-number">30</span>, .tag = .bang_equal, .assoc = Assoc.none },</span>
<span class="line" id="L1431">        .angle_bracket_left = .{ .prec = <span class="tok-number">30</span>, .tag = .less_than, .assoc = Assoc.none },</span>
<span class="line" id="L1432">        .angle_bracket_right = .{ .prec = <span class="tok-number">30</span>, .tag = .greater_than, .assoc = Assoc.none },</span>
<span class="line" id="L1433">        .angle_bracket_left_equal = .{ .prec = <span class="tok-number">30</span>, .tag = .less_or_equal, .assoc = Assoc.none },</span>
<span class="line" id="L1434">        .angle_bracket_right_equal = .{ .prec = <span class="tok-number">30</span>, .tag = .greater_or_equal, .assoc = Assoc.none },</span>
<span class="line" id="L1435"></span>
<span class="line" id="L1436">        .ampersand = .{ .prec = <span class="tok-number">40</span>, .tag = .bit_and },</span>
<span class="line" id="L1437">        .caret = .{ .prec = <span class="tok-number">40</span>, .tag = .bit_xor },</span>
<span class="line" id="L1438">        .pipe = .{ .prec = <span class="tok-number">40</span>, .tag = .bit_or },</span>
<span class="line" id="L1439">        .keyword_orelse = .{ .prec = <span class="tok-number">40</span>, .tag = .@&quot;orelse&quot; },</span>
<span class="line" id="L1440">        .keyword_catch = .{ .prec = <span class="tok-number">40</span>, .tag = .@&quot;catch&quot; },</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442">        .angle_bracket_angle_bracket_left = .{ .prec = <span class="tok-number">50</span>, .tag = .shl },</span>
<span class="line" id="L1443">        .angle_bracket_angle_bracket_left_pipe = .{ .prec = <span class="tok-number">50</span>, .tag = .shl_sat },</span>
<span class="line" id="L1444">        .angle_bracket_angle_bracket_right = .{ .prec = <span class="tok-number">50</span>, .tag = .shr },</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446">        .plus = .{ .prec = <span class="tok-number">60</span>, .tag = .add },</span>
<span class="line" id="L1447">        .minus = .{ .prec = <span class="tok-number">60</span>, .tag = .sub },</span>
<span class="line" id="L1448">        .plus_plus = .{ .prec = <span class="tok-number">60</span>, .tag = .array_cat },</span>
<span class="line" id="L1449">        .plus_percent = .{ .prec = <span class="tok-number">60</span>, .tag = .add_wrap },</span>
<span class="line" id="L1450">        .minus_percent = .{ .prec = <span class="tok-number">60</span>, .tag = .sub_wrap },</span>
<span class="line" id="L1451">        .plus_pipe = .{ .prec = <span class="tok-number">60</span>, .tag = .add_sat },</span>
<span class="line" id="L1452">        .minus_pipe = .{ .prec = <span class="tok-number">60</span>, .tag = .sub_sat },</span>
<span class="line" id="L1453"></span>
<span class="line" id="L1454">        .pipe_pipe = .{ .prec = <span class="tok-number">70</span>, .tag = .merge_error_sets },</span>
<span class="line" id="L1455">        .asterisk = .{ .prec = <span class="tok-number">70</span>, .tag = .mul },</span>
<span class="line" id="L1456">        .slash = .{ .prec = <span class="tok-number">70</span>, .tag = .div },</span>
<span class="line" id="L1457">        .percent = .{ .prec = <span class="tok-number">70</span>, .tag = .mod },</span>
<span class="line" id="L1458">        .asterisk_asterisk = .{ .prec = <span class="tok-number">70</span>, .tag = .array_mult },</span>
<span class="line" id="L1459">        .asterisk_percent = .{ .prec = <span class="tok-number">70</span>, .tag = .mul_wrap },</span>
<span class="line" id="L1460">        .asterisk_pipe = .{ .prec = <span class="tok-number">70</span>, .tag = .mul_sat },</span>
<span class="line" id="L1461">    });</span>
<span class="line" id="L1462"></span>
<span class="line" id="L1463">    <span class="tok-kw">fn</span> <span class="tok-fn">parseExprPrecedence</span>(p: *Parser, min_prec: <span class="tok-type">i32</span>) Error!Node.Index {</span>
<span class="line" id="L1464">        assert(min_prec &gt;= <span class="tok-number">0</span>);</span>
<span class="line" id="L1465">        <span class="tok-kw">var</span> node = <span class="tok-kw">try</span> p.parsePrefixExpr();</span>
<span class="line" id="L1466">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1467">            <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1468">        }</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">        <span class="tok-kw">var</span> banned_prec: <span class="tok-type">i8</span> = -<span class="tok-number">1</span>;</span>
<span class="line" id="L1471"></span>
<span class="line" id="L1472">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1473">            <span class="tok-kw">const</span> tok_tag = p.token_tags[p.tok_i];</span>
<span class="line" id="L1474">            <span class="tok-kw">const</span> info = operTable[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@enumToInt</span>(tok_tag))];</span>
<span class="line" id="L1475">            <span class="tok-kw">if</span> (info.prec &lt; min_prec) {</span>
<span class="line" id="L1476">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L1477">            }</span>
<span class="line" id="L1478">            <span class="tok-kw">if</span> (info.prec == banned_prec) {</span>
<span class="line" id="L1479">                <span class="tok-kw">return</span> p.fail(.chained_comparison_operators);</span>
<span class="line" id="L1480">            }</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482">            <span class="tok-kw">const</span> oper_token = p.nextToken();</span>
<span class="line" id="L1483">            <span class="tok-comment">// Special-case handling for &quot;catch&quot;</span>
</span>
<span class="line" id="L1484">            <span class="tok-kw">if</span> (tok_tag == .keyword_catch) {</span>
<span class="line" id="L1485">                _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L1486">            }</span>
<span class="line" id="L1487">            <span class="tok-kw">const</span> rhs = <span class="tok-kw">try</span> p.parseExprPrecedence(info.prec + <span class="tok-number">1</span>);</span>
<span class="line" id="L1488">            <span class="tok-kw">if</span> (rhs == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1489">                <span class="tok-kw">try</span> p.warn(.expected_expr);</span>
<span class="line" id="L1490">                <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1491">            }</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493">            {</span>
<span class="line" id="L1494">                <span class="tok-kw">const</span> tok_len = tok_tag.lexeme().?.len;</span>
<span class="line" id="L1495">                <span class="tok-kw">const</span> char_before = p.source[p.token_starts[oper_token] - <span class="tok-number">1</span>];</span>
<span class="line" id="L1496">                <span class="tok-kw">const</span> char_after = p.source[p.token_starts[oper_token] + tok_len];</span>
<span class="line" id="L1497">                <span class="tok-kw">if</span> (tok_tag == .ampersand <span class="tok-kw">and</span> char_after == <span class="tok-str">'&amp;'</span>) {</span>
<span class="line" id="L1498">                    <span class="tok-comment">// without types we don't know if '&amp;&amp;' was intended as 'bitwise_and address_of', or a c-style logical_and</span>
</span>
<span class="line" id="L1499">                    <span class="tok-comment">// The best the parser can do is recommend changing it to 'and' or ' &amp; &amp;'</span>
</span>
<span class="line" id="L1500">                    <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .invalid_ampersand_ampersand, .token = oper_token });</span>
<span class="line" id="L1501">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.ascii.isSpace(char_before) != std.ascii.isSpace(char_after)) {</span>
<span class="line" id="L1502">                    <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .mismatched_binary_op_whitespace, .token = oper_token });</span>
<span class="line" id="L1503">                }</span>
<span class="line" id="L1504">            }</span>
<span class="line" id="L1505"></span>
<span class="line" id="L1506">            node = <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L1507">                .tag = info.tag,</span>
<span class="line" id="L1508">                .main_token = oper_token,</span>
<span class="line" id="L1509">                .data = .{</span>
<span class="line" id="L1510">                    .lhs = node,</span>
<span class="line" id="L1511">                    .rhs = rhs,</span>
<span class="line" id="L1512">                },</span>
<span class="line" id="L1513">            });</span>
<span class="line" id="L1514"></span>
<span class="line" id="L1515">            <span class="tok-kw">if</span> (info.assoc == Assoc.none) {</span>
<span class="line" id="L1516">                banned_prec = info.prec;</span>
<span class="line" id="L1517">            }</span>
<span class="line" id="L1518">        }</span>
<span class="line" id="L1519"></span>
<span class="line" id="L1520">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1521">    }</span>
<span class="line" id="L1522"></span>
<span class="line" id="L1523">    <span class="tok-comment">/// PrefixExpr &lt;- PrefixOp* PrimaryExpr</span></span>
<span class="line" id="L1524">    <span class="tok-comment">/// PrefixOp</span></span>
<span class="line" id="L1525">    <span class="tok-comment">///     &lt;- EXCLAMATIONMARK</span></span>
<span class="line" id="L1526">    <span class="tok-comment">///      / MINUS</span></span>
<span class="line" id="L1527">    <span class="tok-comment">///      / TILDE</span></span>
<span class="line" id="L1528">    <span class="tok-comment">///      / MINUSPERCENT</span></span>
<span class="line" id="L1529">    <span class="tok-comment">///      / AMPERSAND</span></span>
<span class="line" id="L1530">    <span class="tok-comment">///      / KEYWORD_try</span></span>
<span class="line" id="L1531">    <span class="tok-comment">///      / KEYWORD_await</span></span>
<span class="line" id="L1532">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePrefixExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1533">        <span class="tok-kw">const</span> tag: Node.Tag = <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1534">            .bang =&gt; .bool_not,</span>
<span class="line" id="L1535">            .minus =&gt; .negation,</span>
<span class="line" id="L1536">            .tilde =&gt; .bit_not,</span>
<span class="line" id="L1537">            .minus_percent =&gt; .negation_wrap,</span>
<span class="line" id="L1538">            .ampersand =&gt; .address_of,</span>
<span class="line" id="L1539">            .keyword_try =&gt; .@&quot;try&quot;,</span>
<span class="line" id="L1540">            .keyword_await =&gt; .@&quot;await&quot;,</span>
<span class="line" id="L1541">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.parsePrimaryExpr(),</span>
<span class="line" id="L1542">        };</span>
<span class="line" id="L1543">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1544">            .tag = tag,</span>
<span class="line" id="L1545">            .main_token = p.nextToken(),</span>
<span class="line" id="L1546">            .data = .{</span>
<span class="line" id="L1547">                .lhs = <span class="tok-kw">try</span> p.expectPrefixExpr(),</span>
<span class="line" id="L1548">                .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1549">            },</span>
<span class="line" id="L1550">        });</span>
<span class="line" id="L1551">    }</span>
<span class="line" id="L1552"></span>
<span class="line" id="L1553">    <span class="tok-kw">fn</span> <span class="tok-fn">expectPrefixExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1554">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parsePrefixExpr();</span>
<span class="line" id="L1555">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1556">            <span class="tok-kw">return</span> p.fail(.expected_prefix_expr);</span>
<span class="line" id="L1557">        }</span>
<span class="line" id="L1558">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1559">    }</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561">    <span class="tok-comment">/// TypeExpr &lt;- PrefixTypeOp* ErrorUnionExpr</span></span>
<span class="line" id="L1562">    <span class="tok-comment">/// PrefixTypeOp</span></span>
<span class="line" id="L1563">    <span class="tok-comment">///     &lt;- QUESTIONMARK</span></span>
<span class="line" id="L1564">    <span class="tok-comment">///      / KEYWORD_anyframe MINUSRARROW</span></span>
<span class="line" id="L1565">    <span class="tok-comment">///      / SliceTypeStart (ByteAlign / AddrSpace / KEYWORD_const / KEYWORD_volatile / KEYWORD_allowzero)*</span></span>
<span class="line" id="L1566">    <span class="tok-comment">///      / PtrTypeStart (AddrSpace / KEYWORD_align LPAREN Expr (COLON INTEGER COLON INTEGER)? RPAREN / KEYWORD_const / KEYWORD_volatile / KEYWORD_allowzero)*</span></span>
<span class="line" id="L1567">    <span class="tok-comment">///      / ArrayTypeStart</span></span>
<span class="line" id="L1568">    <span class="tok-comment">/// SliceTypeStart &lt;- LBRACKET (COLON Expr)? RBRACKET</span></span>
<span class="line" id="L1569">    <span class="tok-comment">/// PtrTypeStart</span></span>
<span class="line" id="L1570">    <span class="tok-comment">///     &lt;- ASTERISK</span></span>
<span class="line" id="L1571">    <span class="tok-comment">///      / ASTERISK2</span></span>
<span class="line" id="L1572">    <span class="tok-comment">///      / LBRACKET ASTERISK (LETTERC / COLON Expr)? RBRACKET</span></span>
<span class="line" id="L1573">    <span class="tok-comment">/// ArrayTypeStart &lt;- LBRACKET Expr (COLON Expr)? RBRACKET</span></span>
<span class="line" id="L1574">    <span class="tok-kw">fn</span> <span class="tok-fn">parseTypeExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1575">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1576">            .question_mark =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1577">                .tag = .optional_type,</span>
<span class="line" id="L1578">                .main_token = p.nextToken(),</span>
<span class="line" id="L1579">                .data = .{</span>
<span class="line" id="L1580">                    .lhs = <span class="tok-kw">try</span> p.expectTypeExpr(),</span>
<span class="line" id="L1581">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1582">                },</span>
<span class="line" id="L1583">            }),</span>
<span class="line" id="L1584">            .keyword_anyframe =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L1585">                .arrow =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1586">                    .tag = .anyframe_type,</span>
<span class="line" id="L1587">                    .main_token = p.nextToken(),</span>
<span class="line" id="L1588">                    .data = .{</span>
<span class="line" id="L1589">                        .lhs = p.nextToken(),</span>
<span class="line" id="L1590">                        .rhs = <span class="tok-kw">try</span> p.expectTypeExpr(),</span>
<span class="line" id="L1591">                    },</span>
<span class="line" id="L1592">                }),</span>
<span class="line" id="L1593">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.parseErrorUnionExpr(),</span>
<span class="line" id="L1594">            },</span>
<span class="line" id="L1595">            .asterisk =&gt; {</span>
<span class="line" id="L1596">                <span class="tok-kw">const</span> asterisk = p.nextToken();</span>
<span class="line" id="L1597">                <span class="tok-kw">const</span> mods = <span class="tok-kw">try</span> p.parsePtrModifiers();</span>
<span class="line" id="L1598">                <span class="tok-kw">const</span> elem_type = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L1599">                <span class="tok-kw">if</span> (mods.bit_range_start != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1600">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1601">                        .tag = .ptr_type_bit_range,</span>
<span class="line" id="L1602">                        .main_token = asterisk,</span>
<span class="line" id="L1603">                        .data = .{</span>
<span class="line" id="L1604">                            .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrTypeBitRange{</span>
<span class="line" id="L1605">                                .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1606">                                .align_node = mods.align_node,</span>
<span class="line" id="L1607">                                .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1608">                                .bit_range_start = mods.bit_range_start,</span>
<span class="line" id="L1609">                                .bit_range_end = mods.bit_range_end,</span>
<span class="line" id="L1610">                            }),</span>
<span class="line" id="L1611">                            .rhs = elem_type,</span>
<span class="line" id="L1612">                        },</span>
<span class="line" id="L1613">                    });</span>
<span class="line" id="L1614">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mods.addrspace_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1615">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1616">                        .tag = .ptr_type,</span>
<span class="line" id="L1617">                        .main_token = asterisk,</span>
<span class="line" id="L1618">                        .data = .{</span>
<span class="line" id="L1619">                            .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrType{</span>
<span class="line" id="L1620">                                .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1621">                                .align_node = mods.align_node,</span>
<span class="line" id="L1622">                                .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1623">                            }),</span>
<span class="line" id="L1624">                            .rhs = elem_type,</span>
<span class="line" id="L1625">                        },</span>
<span class="line" id="L1626">                    });</span>
<span class="line" id="L1627">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1628">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1629">                        .tag = .ptr_type_aligned,</span>
<span class="line" id="L1630">                        .main_token = asterisk,</span>
<span class="line" id="L1631">                        .data = .{</span>
<span class="line" id="L1632">                            .lhs = mods.align_node,</span>
<span class="line" id="L1633">                            .rhs = elem_type,</span>
<span class="line" id="L1634">                        },</span>
<span class="line" id="L1635">                    });</span>
<span class="line" id="L1636">                }</span>
<span class="line" id="L1637">            },</span>
<span class="line" id="L1638">            .asterisk_asterisk =&gt; {</span>
<span class="line" id="L1639">                <span class="tok-kw">const</span> asterisk = p.nextToken();</span>
<span class="line" id="L1640">                <span class="tok-kw">const</span> mods = <span class="tok-kw">try</span> p.parsePtrModifiers();</span>
<span class="line" id="L1641">                <span class="tok-kw">const</span> elem_type = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L1642">                <span class="tok-kw">const</span> inner: Node.Index = inner: {</span>
<span class="line" id="L1643">                    <span class="tok-kw">if</span> (mods.bit_range_start != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1644">                        <span class="tok-kw">break</span> :inner <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L1645">                            .tag = .ptr_type_bit_range,</span>
<span class="line" id="L1646">                            .main_token = asterisk,</span>
<span class="line" id="L1647">                            .data = .{</span>
<span class="line" id="L1648">                                .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrTypeBitRange{</span>
<span class="line" id="L1649">                                    .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1650">                                    .align_node = mods.align_node,</span>
<span class="line" id="L1651">                                    .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1652">                                    .bit_range_start = mods.bit_range_start,</span>
<span class="line" id="L1653">                                    .bit_range_end = mods.bit_range_end,</span>
<span class="line" id="L1654">                                }),</span>
<span class="line" id="L1655">                                .rhs = elem_type,</span>
<span class="line" id="L1656">                            },</span>
<span class="line" id="L1657">                        });</span>
<span class="line" id="L1658">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mods.addrspace_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1659">                        <span class="tok-kw">break</span> :inner <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L1660">                            .tag = .ptr_type,</span>
<span class="line" id="L1661">                            .main_token = asterisk,</span>
<span class="line" id="L1662">                            .data = .{</span>
<span class="line" id="L1663">                                .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrType{</span>
<span class="line" id="L1664">                                    .sentinel = <span class="tok-number">0</span>,</span>
<span class="line" id="L1665">                                    .align_node = mods.align_node,</span>
<span class="line" id="L1666">                                    .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1667">                                }),</span>
<span class="line" id="L1668">                                .rhs = elem_type,</span>
<span class="line" id="L1669">                            },</span>
<span class="line" id="L1670">                        });</span>
<span class="line" id="L1671">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1672">                        <span class="tok-kw">break</span> :inner <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L1673">                            .tag = .ptr_type_aligned,</span>
<span class="line" id="L1674">                            .main_token = asterisk,</span>
<span class="line" id="L1675">                            .data = .{</span>
<span class="line" id="L1676">                                .lhs = mods.align_node,</span>
<span class="line" id="L1677">                                .rhs = elem_type,</span>
<span class="line" id="L1678">                            },</span>
<span class="line" id="L1679">                        });</span>
<span class="line" id="L1680">                    }</span>
<span class="line" id="L1681">                };</span>
<span class="line" id="L1682">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1683">                    .tag = .ptr_type_aligned,</span>
<span class="line" id="L1684">                    .main_token = asterisk,</span>
<span class="line" id="L1685">                    .data = .{</span>
<span class="line" id="L1686">                        .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L1687">                        .rhs = inner,</span>
<span class="line" id="L1688">                    },</span>
<span class="line" id="L1689">                });</span>
<span class="line" id="L1690">            },</span>
<span class="line" id="L1691">            .l_bracket =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L1692">                .asterisk =&gt; {</span>
<span class="line" id="L1693">                    _ = p.nextToken();</span>
<span class="line" id="L1694">                    <span class="tok-kw">const</span> asterisk = p.nextToken();</span>
<span class="line" id="L1695">                    <span class="tok-kw">var</span> sentinel: Node.Index = <span class="tok-number">0</span>;</span>
<span class="line" id="L1696">                    <span class="tok-kw">if</span> (p.eatToken(.identifier)) |ident| {</span>
<span class="line" id="L1697">                        <span class="tok-kw">const</span> ident_slice = p.source[p.token_starts[ident]..p.token_starts[ident + <span class="tok-number">1</span>]];</span>
<span class="line" id="L1698">                        <span class="tok-kw">if</span> (!std.mem.eql(<span class="tok-type">u8</span>, std.mem.trimRight(<span class="tok-type">u8</span>, ident_slice, &amp;std.ascii.spaces), <span class="tok-str">&quot;c&quot;</span>)) {</span>
<span class="line" id="L1699">                            p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1700">                        }</span>
<span class="line" id="L1701">                    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L1702">                        sentinel = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L1703">                    }</span>
<span class="line" id="L1704">                    _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L1705">                    <span class="tok-kw">const</span> mods = <span class="tok-kw">try</span> p.parsePtrModifiers();</span>
<span class="line" id="L1706">                    <span class="tok-kw">const</span> elem_type = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L1707">                    <span class="tok-kw">if</span> (mods.bit_range_start == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1708">                        <span class="tok-kw">if</span> (sentinel == <span class="tok-number">0</span> <span class="tok-kw">and</span> mods.addrspace_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1709">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1710">                                .tag = .ptr_type_aligned,</span>
<span class="line" id="L1711">                                .main_token = asterisk,</span>
<span class="line" id="L1712">                                .data = .{</span>
<span class="line" id="L1713">                                    .lhs = mods.align_node,</span>
<span class="line" id="L1714">                                    .rhs = elem_type,</span>
<span class="line" id="L1715">                                },</span>
<span class="line" id="L1716">                            });</span>
<span class="line" id="L1717">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mods.align_node == <span class="tok-number">0</span> <span class="tok-kw">and</span> mods.addrspace_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1718">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1719">                                .tag = .ptr_type_sentinel,</span>
<span class="line" id="L1720">                                .main_token = asterisk,</span>
<span class="line" id="L1721">                                .data = .{</span>
<span class="line" id="L1722">                                    .lhs = sentinel,</span>
<span class="line" id="L1723">                                    .rhs = elem_type,</span>
<span class="line" id="L1724">                                },</span>
<span class="line" id="L1725">                            });</span>
<span class="line" id="L1726">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1727">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1728">                                .tag = .ptr_type,</span>
<span class="line" id="L1729">                                .main_token = asterisk,</span>
<span class="line" id="L1730">                                .data = .{</span>
<span class="line" id="L1731">                                    .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrType{</span>
<span class="line" id="L1732">                                        .sentinel = sentinel,</span>
<span class="line" id="L1733">                                        .align_node = mods.align_node,</span>
<span class="line" id="L1734">                                        .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1735">                                    }),</span>
<span class="line" id="L1736">                                    .rhs = elem_type,</span>
<span class="line" id="L1737">                                },</span>
<span class="line" id="L1738">                            });</span>
<span class="line" id="L1739">                        }</span>
<span class="line" id="L1740">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1741">                        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1742">                            .tag = .ptr_type_bit_range,</span>
<span class="line" id="L1743">                            .main_token = asterisk,</span>
<span class="line" id="L1744">                            .data = .{</span>
<span class="line" id="L1745">                                .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrTypeBitRange{</span>
<span class="line" id="L1746">                                    .sentinel = sentinel,</span>
<span class="line" id="L1747">                                    .align_node = mods.align_node,</span>
<span class="line" id="L1748">                                    .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1749">                                    .bit_range_start = mods.bit_range_start,</span>
<span class="line" id="L1750">                                    .bit_range_end = mods.bit_range_end,</span>
<span class="line" id="L1751">                                }),</span>
<span class="line" id="L1752">                                .rhs = elem_type,</span>
<span class="line" id="L1753">                            },</span>
<span class="line" id="L1754">                        });</span>
<span class="line" id="L1755">                    }</span>
<span class="line" id="L1756">                },</span>
<span class="line" id="L1757">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1758">                    <span class="tok-kw">const</span> lbracket = p.nextToken();</span>
<span class="line" id="L1759">                    <span class="tok-kw">const</span> len_expr = <span class="tok-kw">try</span> p.parseExpr();</span>
<span class="line" id="L1760">                    <span class="tok-kw">const</span> sentinel: Node.Index = <span class="tok-kw">if</span> (p.eatToken(.colon)) |_|</span>
<span class="line" id="L1761">                        <span class="tok-kw">try</span> p.expectExpr()</span>
<span class="line" id="L1762">                    <span class="tok-kw">else</span></span>
<span class="line" id="L1763">                        <span class="tok-number">0</span>;</span>
<span class="line" id="L1764">                    _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L1765">                    <span class="tok-kw">if</span> (len_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1766">                        <span class="tok-kw">const</span> mods = <span class="tok-kw">try</span> p.parsePtrModifiers();</span>
<span class="line" id="L1767">                        <span class="tok-kw">const</span> elem_type = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L1768">                        <span class="tok-kw">if</span> (mods.bit_range_start != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1769">                            <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L1770">                                .tag = .invalid_bit_range,</span>
<span class="line" id="L1771">                                .token = p.nodes.items(.main_token)[mods.bit_range_start],</span>
<span class="line" id="L1772">                            });</span>
<span class="line" id="L1773">                        }</span>
<span class="line" id="L1774">                        <span class="tok-kw">if</span> (sentinel == <span class="tok-number">0</span> <span class="tok-kw">and</span> mods.addrspace_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1775">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1776">                                .tag = .ptr_type_aligned,</span>
<span class="line" id="L1777">                                .main_token = lbracket,</span>
<span class="line" id="L1778">                                .data = .{</span>
<span class="line" id="L1779">                                    .lhs = mods.align_node,</span>
<span class="line" id="L1780">                                    .rhs = elem_type,</span>
<span class="line" id="L1781">                                },</span>
<span class="line" id="L1782">                            });</span>
<span class="line" id="L1783">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mods.align_node == <span class="tok-number">0</span> <span class="tok-kw">and</span> mods.addrspace_node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1784">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1785">                                .tag = .ptr_type_sentinel,</span>
<span class="line" id="L1786">                                .main_token = lbracket,</span>
<span class="line" id="L1787">                                .data = .{</span>
<span class="line" id="L1788">                                    .lhs = sentinel,</span>
<span class="line" id="L1789">                                    .rhs = elem_type,</span>
<span class="line" id="L1790">                                },</span>
<span class="line" id="L1791">                            });</span>
<span class="line" id="L1792">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1793">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1794">                                .tag = .ptr_type,</span>
<span class="line" id="L1795">                                .main_token = lbracket,</span>
<span class="line" id="L1796">                                .data = .{</span>
<span class="line" id="L1797">                                    .lhs = <span class="tok-kw">try</span> p.addExtra(Node.PtrType{</span>
<span class="line" id="L1798">                                        .sentinel = sentinel,</span>
<span class="line" id="L1799">                                        .align_node = mods.align_node,</span>
<span class="line" id="L1800">                                        .addrspace_node = mods.addrspace_node,</span>
<span class="line" id="L1801">                                    }),</span>
<span class="line" id="L1802">                                    .rhs = elem_type,</span>
<span class="line" id="L1803">                                },</span>
<span class="line" id="L1804">                            });</span>
<span class="line" id="L1805">                        }</span>
<span class="line" id="L1806">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1807">                        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1808">                            .keyword_align,</span>
<span class="line" id="L1809">                            .keyword_const,</span>
<span class="line" id="L1810">                            .keyword_volatile,</span>
<span class="line" id="L1811">                            .keyword_allowzero,</span>
<span class="line" id="L1812">                            .keyword_addrspace,</span>
<span class="line" id="L1813">                            =&gt; <span class="tok-kw">return</span> p.fail(.ptr_mod_on_array_child_type),</span>
<span class="line" id="L1814">                            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1815">                        }</span>
<span class="line" id="L1816">                        <span class="tok-kw">const</span> elem_type = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L1817">                        <span class="tok-kw">if</span> (sentinel == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1818">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1819">                                .tag = .array_type,</span>
<span class="line" id="L1820">                                .main_token = lbracket,</span>
<span class="line" id="L1821">                                .data = .{</span>
<span class="line" id="L1822">                                    .lhs = len_expr,</span>
<span class="line" id="L1823">                                    .rhs = elem_type,</span>
<span class="line" id="L1824">                                },</span>
<span class="line" id="L1825">                            });</span>
<span class="line" id="L1826">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1827">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1828">                                .tag = .array_type_sentinel,</span>
<span class="line" id="L1829">                                .main_token = lbracket,</span>
<span class="line" id="L1830">                                .data = .{</span>
<span class="line" id="L1831">                                    .lhs = len_expr,</span>
<span class="line" id="L1832">                                    .rhs = <span class="tok-kw">try</span> p.addExtra(.{</span>
<span class="line" id="L1833">                                        .elem_type = elem_type,</span>
<span class="line" id="L1834">                                        .sentinel = sentinel,</span>
<span class="line" id="L1835">                                    }),</span>
<span class="line" id="L1836">                                },</span>
<span class="line" id="L1837">                            });</span>
<span class="line" id="L1838">                        }</span>
<span class="line" id="L1839">                    }</span>
<span class="line" id="L1840">                },</span>
<span class="line" id="L1841">            },</span>
<span class="line" id="L1842">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.parseErrorUnionExpr(),</span>
<span class="line" id="L1843">        }</span>
<span class="line" id="L1844">    }</span>
<span class="line" id="L1845"></span>
<span class="line" id="L1846">    <span class="tok-kw">fn</span> <span class="tok-fn">expectTypeExpr</span>(p: *Parser) Error!Node.Index {</span>
<span class="line" id="L1847">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parseTypeExpr();</span>
<span class="line" id="L1848">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1849">            <span class="tok-kw">return</span> p.fail(.expected_type_expr);</span>
<span class="line" id="L1850">        }</span>
<span class="line" id="L1851">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L1852">    }</span>
<span class="line" id="L1853"></span>
<span class="line" id="L1854">    <span class="tok-comment">/// PrimaryExpr</span></span>
<span class="line" id="L1855">    <span class="tok-comment">///     &lt;- AsmExpr</span></span>
<span class="line" id="L1856">    <span class="tok-comment">///      / IfExpr</span></span>
<span class="line" id="L1857">    <span class="tok-comment">///      / KEYWORD_break BreakLabel? Expr?</span></span>
<span class="line" id="L1858">    <span class="tok-comment">///      / KEYWORD_comptime Expr</span></span>
<span class="line" id="L1859">    <span class="tok-comment">///      / KEYWORD_nosuspend Expr</span></span>
<span class="line" id="L1860">    <span class="tok-comment">///      / KEYWORD_continue BreakLabel?</span></span>
<span class="line" id="L1861">    <span class="tok-comment">///      / KEYWORD_resume Expr</span></span>
<span class="line" id="L1862">    <span class="tok-comment">///      / KEYWORD_return Expr?</span></span>
<span class="line" id="L1863">    <span class="tok-comment">///      / BlockLabel? LoopExpr</span></span>
<span class="line" id="L1864">    <span class="tok-comment">///      / Block</span></span>
<span class="line" id="L1865">    <span class="tok-comment">///      / CurlySuffixExpr</span></span>
<span class="line" id="L1866">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePrimaryExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1867">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1868">            .keyword_asm =&gt; <span class="tok-kw">return</span> p.expectAsmExpr(),</span>
<span class="line" id="L1869">            .keyword_if =&gt; <span class="tok-kw">return</span> p.parseIfExpr(),</span>
<span class="line" id="L1870">            .keyword_break =&gt; {</span>
<span class="line" id="L1871">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1872">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1873">                    .tag = .@&quot;break&quot;,</span>
<span class="line" id="L1874">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1875">                    .data = .{</span>
<span class="line" id="L1876">                        .lhs = <span class="tok-kw">try</span> p.parseBreakLabel(),</span>
<span class="line" id="L1877">                        .rhs = <span class="tok-kw">try</span> p.parseExpr(),</span>
<span class="line" id="L1878">                    },</span>
<span class="line" id="L1879">                });</span>
<span class="line" id="L1880">            },</span>
<span class="line" id="L1881">            .keyword_continue =&gt; {</span>
<span class="line" id="L1882">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1883">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1884">                    .tag = .@&quot;continue&quot;,</span>
<span class="line" id="L1885">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1886">                    .data = .{</span>
<span class="line" id="L1887">                        .lhs = <span class="tok-kw">try</span> p.parseBreakLabel(),</span>
<span class="line" id="L1888">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1889">                    },</span>
<span class="line" id="L1890">                });</span>
<span class="line" id="L1891">            },</span>
<span class="line" id="L1892">            .keyword_comptime =&gt; {</span>
<span class="line" id="L1893">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1894">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1895">                    .tag = .@&quot;comptime&quot;,</span>
<span class="line" id="L1896">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1897">                    .data = .{</span>
<span class="line" id="L1898">                        .lhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L1899">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1900">                    },</span>
<span class="line" id="L1901">                });</span>
<span class="line" id="L1902">            },</span>
<span class="line" id="L1903">            .keyword_nosuspend =&gt; {</span>
<span class="line" id="L1904">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1905">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1906">                    .tag = .@&quot;nosuspend&quot;,</span>
<span class="line" id="L1907">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1908">                    .data = .{</span>
<span class="line" id="L1909">                        .lhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L1910">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1911">                    },</span>
<span class="line" id="L1912">                });</span>
<span class="line" id="L1913">            },</span>
<span class="line" id="L1914">            .keyword_resume =&gt; {</span>
<span class="line" id="L1915">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1916">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1917">                    .tag = .@&quot;resume&quot;,</span>
<span class="line" id="L1918">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1919">                    .data = .{</span>
<span class="line" id="L1920">                        .lhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L1921">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1922">                    },</span>
<span class="line" id="L1923">                });</span>
<span class="line" id="L1924">            },</span>
<span class="line" id="L1925">            .keyword_return =&gt; {</span>
<span class="line" id="L1926">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1927">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L1928">                    .tag = .@&quot;return&quot;,</span>
<span class="line" id="L1929">                    .main_token = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L1930">                    .data = .{</span>
<span class="line" id="L1931">                        .lhs = <span class="tok-kw">try</span> p.parseExpr(),</span>
<span class="line" id="L1932">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1933">                    },</span>
<span class="line" id="L1934">                });</span>
<span class="line" id="L1935">            },</span>
<span class="line" id="L1936">            .identifier =&gt; {</span>
<span class="line" id="L1937">                <span class="tok-kw">if</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>] == .colon) {</span>
<span class="line" id="L1938">                    <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">2</span>]) {</span>
<span class="line" id="L1939">                        .keyword_inline =&gt; {</span>
<span class="line" id="L1940">                            p.tok_i += <span class="tok-number">3</span>;</span>
<span class="line" id="L1941">                            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1942">                                .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForExpr(),</span>
<span class="line" id="L1943">                                .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileExpr(),</span>
<span class="line" id="L1944">                                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.fail(.expected_inlinable),</span>
<span class="line" id="L1945">                            }</span>
<span class="line" id="L1946">                        },</span>
<span class="line" id="L1947">                        .keyword_for =&gt; {</span>
<span class="line" id="L1948">                            p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L1949">                            <span class="tok-kw">return</span> p.parseForExpr();</span>
<span class="line" id="L1950">                        },</span>
<span class="line" id="L1951">                        .keyword_while =&gt; {</span>
<span class="line" id="L1952">                            p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L1953">                            <span class="tok-kw">return</span> p.parseWhileExpr();</span>
<span class="line" id="L1954">                        },</span>
<span class="line" id="L1955">                        .l_brace =&gt; {</span>
<span class="line" id="L1956">                            p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L1957">                            <span class="tok-kw">return</span> p.parseBlock();</span>
<span class="line" id="L1958">                        },</span>
<span class="line" id="L1959">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.parseCurlySuffixExpr(),</span>
<span class="line" id="L1960">                    }</span>
<span class="line" id="L1961">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1962">                    <span class="tok-kw">return</span> p.parseCurlySuffixExpr();</span>
<span class="line" id="L1963">                }</span>
<span class="line" id="L1964">            },</span>
<span class="line" id="L1965">            .keyword_inline =&gt; {</span>
<span class="line" id="L1966">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1967">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L1968">                    .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForExpr(),</span>
<span class="line" id="L1969">                    .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileExpr(),</span>
<span class="line" id="L1970">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.fail(.expected_inlinable),</span>
<span class="line" id="L1971">                }</span>
<span class="line" id="L1972">            },</span>
<span class="line" id="L1973">            .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForExpr(),</span>
<span class="line" id="L1974">            .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileExpr(),</span>
<span class="line" id="L1975">            .l_brace =&gt; <span class="tok-kw">return</span> p.parseBlock(),</span>
<span class="line" id="L1976">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.parseCurlySuffixExpr(),</span>
<span class="line" id="L1977">        }</span>
<span class="line" id="L1978">    }</span>
<span class="line" id="L1979"></span>
<span class="line" id="L1980">    <span class="tok-comment">/// IfExpr &lt;- IfPrefix Expr (KEYWORD_else Payload? Expr)?</span></span>
<span class="line" id="L1981">    <span class="tok-kw">fn</span> <span class="tok-fn">parseIfExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1982">        <span class="tok-kw">return</span> p.parseIf(expectExpr);</span>
<span class="line" id="L1983">    }</span>
<span class="line" id="L1984"></span>
<span class="line" id="L1985">    <span class="tok-comment">/// Block &lt;- LBRACE Statement* RBRACE</span></span>
<span class="line" id="L1986">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBlock</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L1987">        <span class="tok-kw">const</span> lbrace = p.eatToken(.l_brace) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L1988">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L1989">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L1990">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1991">            <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == .r_brace) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1992">            <span class="tok-kw">const</span> statement = <span class="tok-kw">try</span> p.expectStatementRecoverable();</span>
<span class="line" id="L1993">            <span class="tok-kw">if</span> (statement == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1994">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, statement);</span>
<span class="line" id="L1995">        }</span>
<span class="line" id="L1996">        _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L1997">        <span class="tok-kw">const</span> semicolon = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .semicolon);</span>
<span class="line" id="L1998">        <span class="tok-kw">const</span> statements = p.scratch.items[scratch_top..];</span>
<span class="line" id="L1999">        <span class="tok-kw">switch</span> (statements.len) {</span>
<span class="line" id="L2000">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2001">                .tag = .block_two,</span>
<span class="line" id="L2002">                .main_token = lbrace,</span>
<span class="line" id="L2003">                .data = .{</span>
<span class="line" id="L2004">                    .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2005">                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2006">                },</span>
<span class="line" id="L2007">            }),</span>
<span class="line" id="L2008">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2009">                .tag = <span class="tok-kw">if</span> (semicolon) .block_two_semicolon <span class="tok-kw">else</span> .block_two,</span>
<span class="line" id="L2010">                .main_token = lbrace,</span>
<span class="line" id="L2011">                .data = .{</span>
<span class="line" id="L2012">                    .lhs = statements[<span class="tok-number">0</span>],</span>
<span class="line" id="L2013">                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2014">                },</span>
<span class="line" id="L2015">            }),</span>
<span class="line" id="L2016">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2017">                .tag = <span class="tok-kw">if</span> (semicolon) .block_two_semicolon <span class="tok-kw">else</span> .block_two,</span>
<span class="line" id="L2018">                .main_token = lbrace,</span>
<span class="line" id="L2019">                .data = .{</span>
<span class="line" id="L2020">                    .lhs = statements[<span class="tok-number">0</span>],</span>
<span class="line" id="L2021">                    .rhs = statements[<span class="tok-number">1</span>],</span>
<span class="line" id="L2022">                },</span>
<span class="line" id="L2023">            }),</span>
<span class="line" id="L2024">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2025">                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(statements);</span>
<span class="line" id="L2026">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2027">                    .tag = <span class="tok-kw">if</span> (semicolon) .block_semicolon <span class="tok-kw">else</span> .block,</span>
<span class="line" id="L2028">                    .main_token = lbrace,</span>
<span class="line" id="L2029">                    .data = .{</span>
<span class="line" id="L2030">                        .lhs = span.start,</span>
<span class="line" id="L2031">                        .rhs = span.end,</span>
<span class="line" id="L2032">                    },</span>
<span class="line" id="L2033">                });</span>
<span class="line" id="L2034">            },</span>
<span class="line" id="L2035">        }</span>
<span class="line" id="L2036">    }</span>
<span class="line" id="L2037"></span>
<span class="line" id="L2038">    <span class="tok-comment">/// ForPrefix &lt;- KEYWORD_for LPAREN Expr RPAREN PtrIndexPayload</span></span>
<span class="line" id="L2039">    <span class="tok-comment">/// ForExpr &lt;- ForPrefix Expr (KEYWORD_else Expr)?</span></span>
<span class="line" id="L2040">    <span class="tok-kw">fn</span> <span class="tok-fn">parseForExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2041">        <span class="tok-kw">const</span> for_token = p.eatToken(.keyword_for) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2042">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2043">        <span class="tok-kw">const</span> array_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2044">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2045">        <span class="tok-kw">const</span> found_payload = <span class="tok-kw">try</span> p.parsePtrIndexPayload();</span>
<span class="line" id="L2046">        <span class="tok-kw">if</span> (found_payload == <span class="tok-number">0</span>) <span class="tok-kw">try</span> p.warn(.expected_loop_payload);</span>
<span class="line" id="L2047"></span>
<span class="line" id="L2048">        <span class="tok-kw">const</span> then_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2049">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L2050">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2051">                .tag = .for_simple,</span>
<span class="line" id="L2052">                .main_token = for_token,</span>
<span class="line" id="L2053">                .data = .{</span>
<span class="line" id="L2054">                    .lhs = array_expr,</span>
<span class="line" id="L2055">                    .rhs = then_expr,</span>
<span class="line" id="L2056">                },</span>
<span class="line" id="L2057">            });</span>
<span class="line" id="L2058">        };</span>
<span class="line" id="L2059">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2060">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2061">            .tag = .@&quot;for&quot;,</span>
<span class="line" id="L2062">            .main_token = for_token,</span>
<span class="line" id="L2063">            .data = .{</span>
<span class="line" id="L2064">                .lhs = array_expr,</span>
<span class="line" id="L2065">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.If{</span>
<span class="line" id="L2066">                    .then_expr = then_expr,</span>
<span class="line" id="L2067">                    .else_expr = else_expr,</span>
<span class="line" id="L2068">                }),</span>
<span class="line" id="L2069">            },</span>
<span class="line" id="L2070">        });</span>
<span class="line" id="L2071">    }</span>
<span class="line" id="L2072"></span>
<span class="line" id="L2073">    <span class="tok-comment">/// WhilePrefix &lt;- KEYWORD_while LPAREN Expr RPAREN PtrPayload? WhileContinueExpr?</span></span>
<span class="line" id="L2074">    <span class="tok-comment">/// WhileExpr &lt;- WhilePrefix Expr (KEYWORD_else Payload? Expr)?</span></span>
<span class="line" id="L2075">    <span class="tok-kw">fn</span> <span class="tok-fn">parseWhileExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2076">        <span class="tok-kw">const</span> while_token = p.eatToken(.keyword_while) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2077">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2078">        <span class="tok-kw">const</span> condition = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2079">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2080">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L2081">        <span class="tok-kw">const</span> cont_expr = <span class="tok-kw">try</span> p.parseWhileContinueExpr();</span>
<span class="line" id="L2082"></span>
<span class="line" id="L2083">        <span class="tok-kw">const</span> then_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2084">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L2085">            <span class="tok-kw">if</span> (cont_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2086">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2087">                    .tag = .while_simple,</span>
<span class="line" id="L2088">                    .main_token = while_token,</span>
<span class="line" id="L2089">                    .data = .{</span>
<span class="line" id="L2090">                        .lhs = condition,</span>
<span class="line" id="L2091">                        .rhs = then_expr,</span>
<span class="line" id="L2092">                    },</span>
<span class="line" id="L2093">                });</span>
<span class="line" id="L2094">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2095">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2096">                    .tag = .while_cont,</span>
<span class="line" id="L2097">                    .main_token = while_token,</span>
<span class="line" id="L2098">                    .data = .{</span>
<span class="line" id="L2099">                        .lhs = condition,</span>
<span class="line" id="L2100">                        .rhs = <span class="tok-kw">try</span> p.addExtra(Node.WhileCont{</span>
<span class="line" id="L2101">                            .cont_expr = cont_expr,</span>
<span class="line" id="L2102">                            .then_expr = then_expr,</span>
<span class="line" id="L2103">                        }),</span>
<span class="line" id="L2104">                    },</span>
<span class="line" id="L2105">                });</span>
<span class="line" id="L2106">            }</span>
<span class="line" id="L2107">        };</span>
<span class="line" id="L2108">        _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L2109">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2110">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2111">            .tag = .@&quot;while&quot;,</span>
<span class="line" id="L2112">            .main_token = while_token,</span>
<span class="line" id="L2113">            .data = .{</span>
<span class="line" id="L2114">                .lhs = condition,</span>
<span class="line" id="L2115">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.While{</span>
<span class="line" id="L2116">                    .cont_expr = cont_expr,</span>
<span class="line" id="L2117">                    .then_expr = then_expr,</span>
<span class="line" id="L2118">                    .else_expr = else_expr,</span>
<span class="line" id="L2119">                }),</span>
<span class="line" id="L2120">            },</span>
<span class="line" id="L2121">        });</span>
<span class="line" id="L2122">    }</span>
<span class="line" id="L2123"></span>
<span class="line" id="L2124">    <span class="tok-comment">/// CurlySuffixExpr &lt;- TypeExpr InitList?</span></span>
<span class="line" id="L2125">    <span class="tok-comment">/// InitList</span></span>
<span class="line" id="L2126">    <span class="tok-comment">///     &lt;- LBRACE FieldInit (COMMA FieldInit)* COMMA? RBRACE</span></span>
<span class="line" id="L2127">    <span class="tok-comment">///      / LBRACE Expr (COMMA Expr)* COMMA? RBRACE</span></span>
<span class="line" id="L2128">    <span class="tok-comment">///      / LBRACE RBRACE</span></span>
<span class="line" id="L2129">    <span class="tok-kw">fn</span> <span class="tok-fn">parseCurlySuffixExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2130">        <span class="tok-kw">const</span> lhs = <span class="tok-kw">try</span> p.parseTypeExpr();</span>
<span class="line" id="L2131">        <span class="tok-kw">if</span> (lhs == <span class="tok-number">0</span>) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2132">        <span class="tok-kw">const</span> lbrace = p.eatToken(.l_brace) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> lhs;</span>
<span class="line" id="L2133"></span>
<span class="line" id="L2134">        <span class="tok-comment">// If there are 0 or 1 items, we can use ArrayInitOne/StructInitOne;</span>
</span>
<span class="line" id="L2135">        <span class="tok-comment">// otherwise we use the full ArrayInit/StructInit.</span>
</span>
<span class="line" id="L2136"></span>
<span class="line" id="L2137">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L2138">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L2139">        <span class="tok-kw">const</span> field_init = <span class="tok-kw">try</span> p.parseFieldInit();</span>
<span class="line" id="L2140">        <span class="tok-kw">if</span> (field_init != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2141">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, field_init);</span>
<span class="line" id="L2142">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2143">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2144">                    .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2145">                    .r_brace =&gt; {</span>
<span class="line" id="L2146">                        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2147">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L2148">                    },</span>
<span class="line" id="L2149">                    .colon, .r_paren, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_brace),</span>
<span class="line" id="L2150">                    <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2151">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_initializer),</span>
<span class="line" id="L2152">                }</span>
<span class="line" id="L2153">                <span class="tok-kw">if</span> (p.eatToken(.r_brace)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2154">                <span class="tok-kw">const</span> next = <span class="tok-kw">try</span> p.expectFieldInit();</span>
<span class="line" id="L2155">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, next);</span>
<span class="line" id="L2156">            }</span>
<span class="line" id="L2157">            <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2158">            <span class="tok-kw">const</span> inits = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2159">            <span class="tok-kw">switch</span> (inits.len) {</span>
<span class="line" id="L2160">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2161">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2162">                    .tag = <span class="tok-kw">if</span> (comma) .struct_init_one_comma <span class="tok-kw">else</span> .struct_init_one,</span>
<span class="line" id="L2163">                    .main_token = lbrace,</span>
<span class="line" id="L2164">                    .data = .{</span>
<span class="line" id="L2165">                        .lhs = lhs,</span>
<span class="line" id="L2166">                        .rhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2167">                    },</span>
<span class="line" id="L2168">                }),</span>
<span class="line" id="L2169">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2170">                    .tag = <span class="tok-kw">if</span> (comma) .struct_init_comma <span class="tok-kw">else</span> .struct_init,</span>
<span class="line" id="L2171">                    .main_token = lbrace,</span>
<span class="line" id="L2172">                    .data = .{</span>
<span class="line" id="L2173">                        .lhs = lhs,</span>
<span class="line" id="L2174">                        .rhs = <span class="tok-kw">try</span> p.addExtra(<span class="tok-kw">try</span> p.listToSpan(inits)),</span>
<span class="line" id="L2175">                    },</span>
<span class="line" id="L2176">                }),</span>
<span class="line" id="L2177">            }</span>
<span class="line" id="L2178">        }</span>
<span class="line" id="L2179"></span>
<span class="line" id="L2180">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2181">            <span class="tok-kw">if</span> (p.eatToken(.r_brace)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2182">            <span class="tok-kw">const</span> elem_init = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2183">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, elem_init);</span>
<span class="line" id="L2184">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2185">                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2186">                .r_brace =&gt; {</span>
<span class="line" id="L2187">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2188">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L2189">                },</span>
<span class="line" id="L2190">                .colon, .r_paren, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_brace),</span>
<span class="line" id="L2191">                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2192">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_initializer),</span>
<span class="line" id="L2193">            }</span>
<span class="line" id="L2194">        }</span>
<span class="line" id="L2195">        <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2196">        <span class="tok-kw">const</span> inits = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2197">        <span class="tok-kw">switch</span> (inits.len) {</span>
<span class="line" id="L2198">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2199">                .tag = .struct_init_one,</span>
<span class="line" id="L2200">                .main_token = lbrace,</span>
<span class="line" id="L2201">                .data = .{</span>
<span class="line" id="L2202">                    .lhs = lhs,</span>
<span class="line" id="L2203">                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2204">                },</span>
<span class="line" id="L2205">            }),</span>
<span class="line" id="L2206">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2207">                .tag = <span class="tok-kw">if</span> (comma) .array_init_one_comma <span class="tok-kw">else</span> .array_init_one,</span>
<span class="line" id="L2208">                .main_token = lbrace,</span>
<span class="line" id="L2209">                .data = .{</span>
<span class="line" id="L2210">                    .lhs = lhs,</span>
<span class="line" id="L2211">                    .rhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2212">                },</span>
<span class="line" id="L2213">            }),</span>
<span class="line" id="L2214">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2215">                .tag = <span class="tok-kw">if</span> (comma) .array_init_comma <span class="tok-kw">else</span> .array_init,</span>
<span class="line" id="L2216">                .main_token = lbrace,</span>
<span class="line" id="L2217">                .data = .{</span>
<span class="line" id="L2218">                    .lhs = lhs,</span>
<span class="line" id="L2219">                    .rhs = <span class="tok-kw">try</span> p.addExtra(<span class="tok-kw">try</span> p.listToSpan(inits)),</span>
<span class="line" id="L2220">                },</span>
<span class="line" id="L2221">            }),</span>
<span class="line" id="L2222">        }</span>
<span class="line" id="L2223">    }</span>
<span class="line" id="L2224"></span>
<span class="line" id="L2225">    <span class="tok-comment">/// ErrorUnionExpr &lt;- SuffixExpr (EXCLAMATIONMARK TypeExpr)?</span></span>
<span class="line" id="L2226">    <span class="tok-kw">fn</span> <span class="tok-fn">parseErrorUnionExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2227">        <span class="tok-kw">const</span> suffix_expr = <span class="tok-kw">try</span> p.parseSuffixExpr();</span>
<span class="line" id="L2228">        <span class="tok-kw">if</span> (suffix_expr == <span class="tok-number">0</span>) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2229">        <span class="tok-kw">const</span> bang = p.eatToken(.bang) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> suffix_expr;</span>
<span class="line" id="L2230">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2231">            .tag = .error_union,</span>
<span class="line" id="L2232">            .main_token = bang,</span>
<span class="line" id="L2233">            .data = .{</span>
<span class="line" id="L2234">                .lhs = suffix_expr,</span>
<span class="line" id="L2235">                .rhs = <span class="tok-kw">try</span> p.expectTypeExpr(),</span>
<span class="line" id="L2236">            },</span>
<span class="line" id="L2237">        });</span>
<span class="line" id="L2238">    }</span>
<span class="line" id="L2239"></span>
<span class="line" id="L2240">    <span class="tok-comment">/// SuffixExpr</span></span>
<span class="line" id="L2241">    <span class="tok-comment">///     &lt;- KEYWORD_async PrimaryTypeExpr SuffixOp* FnCallArguments</span></span>
<span class="line" id="L2242">    <span class="tok-comment">///      / PrimaryTypeExpr (SuffixOp / FnCallArguments)*</span></span>
<span class="line" id="L2243">    <span class="tok-comment">/// FnCallArguments &lt;- LPAREN ExprList RPAREN</span></span>
<span class="line" id="L2244">    <span class="tok-comment">/// ExprList &lt;- (Expr COMMA)* Expr?</span></span>
<span class="line" id="L2245">    <span class="tok-kw">fn</span> <span class="tok-fn">parseSuffixExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2246">        <span class="tok-kw">if</span> (p.eatToken(.keyword_async)) |_| {</span>
<span class="line" id="L2247">            <span class="tok-kw">var</span> res = <span class="tok-kw">try</span> p.expectPrimaryTypeExpr();</span>
<span class="line" id="L2248">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2249">                <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parseSuffixOp(res);</span>
<span class="line" id="L2250">                <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L2251">                res = node;</span>
<span class="line" id="L2252">            }</span>
<span class="line" id="L2253">            <span class="tok-kw">const</span> lparen = p.eatToken(.l_paren) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L2254">                <span class="tok-kw">try</span> p.warn(.expected_param_list);</span>
<span class="line" id="L2255">                <span class="tok-kw">return</span> res;</span>
<span class="line" id="L2256">            };</span>
<span class="line" id="L2257">            <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L2258">            <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L2259">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2260">                <span class="tok-kw">if</span> (p.eatToken(.r_paren)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2261">                <span class="tok-kw">const</span> param = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2262">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, param);</span>
<span class="line" id="L2263">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2264">                    .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2265">                    .r_paren =&gt; {</span>
<span class="line" id="L2266">                        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2267">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L2268">                    },</span>
<span class="line" id="L2269">                    .colon, .r_brace, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_paren),</span>
<span class="line" id="L2270">                    <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2271">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_arg),</span>
<span class="line" id="L2272">                }</span>
<span class="line" id="L2273">            }</span>
<span class="line" id="L2274">            <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2275">            <span class="tok-kw">const</span> params = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2276">            <span class="tok-kw">switch</span> (params.len) {</span>
<span class="line" id="L2277">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2278">                    .tag = <span class="tok-kw">if</span> (comma) .async_call_one_comma <span class="tok-kw">else</span> .async_call_one,</span>
<span class="line" id="L2279">                    .main_token = lparen,</span>
<span class="line" id="L2280">                    .data = .{</span>
<span class="line" id="L2281">                        .lhs = res,</span>
<span class="line" id="L2282">                        .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2283">                    },</span>
<span class="line" id="L2284">                }),</span>
<span class="line" id="L2285">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2286">                    .tag = <span class="tok-kw">if</span> (comma) .async_call_one_comma <span class="tok-kw">else</span> .async_call_one,</span>
<span class="line" id="L2287">                    .main_token = lparen,</span>
<span class="line" id="L2288">                    .data = .{</span>
<span class="line" id="L2289">                        .lhs = res,</span>
<span class="line" id="L2290">                        .rhs = params[<span class="tok-number">0</span>],</span>
<span class="line" id="L2291">                    },</span>
<span class="line" id="L2292">                }),</span>
<span class="line" id="L2293">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2294">                    .tag = <span class="tok-kw">if</span> (comma) .async_call_comma <span class="tok-kw">else</span> .async_call,</span>
<span class="line" id="L2295">                    .main_token = lparen,</span>
<span class="line" id="L2296">                    .data = .{</span>
<span class="line" id="L2297">                        .lhs = res,</span>
<span class="line" id="L2298">                        .rhs = <span class="tok-kw">try</span> p.addExtra(<span class="tok-kw">try</span> p.listToSpan(params)),</span>
<span class="line" id="L2299">                    },</span>
<span class="line" id="L2300">                }),</span>
<span class="line" id="L2301">            }</span>
<span class="line" id="L2302">        }</span>
<span class="line" id="L2303"></span>
<span class="line" id="L2304">        <span class="tok-kw">var</span> res = <span class="tok-kw">try</span> p.parsePrimaryTypeExpr();</span>
<span class="line" id="L2305">        <span class="tok-kw">if</span> (res == <span class="tok-number">0</span>) <span class="tok-kw">return</span> res;</span>
<span class="line" id="L2306">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2307">            <span class="tok-kw">const</span> suffix_op = <span class="tok-kw">try</span> p.parseSuffixOp(res);</span>
<span class="line" id="L2308">            <span class="tok-kw">if</span> (suffix_op != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2309">                res = suffix_op;</span>
<span class="line" id="L2310">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2311">            }</span>
<span class="line" id="L2312">            <span class="tok-kw">const</span> lparen = p.eatToken(.l_paren) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> res;</span>
<span class="line" id="L2313">            <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L2314">            <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L2315">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2316">                <span class="tok-kw">if</span> (p.eatToken(.r_paren)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2317">                <span class="tok-kw">const</span> param = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2318">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, param);</span>
<span class="line" id="L2319">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2320">                    .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2321">                    .r_paren =&gt; {</span>
<span class="line" id="L2322">                        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2323">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L2324">                    },</span>
<span class="line" id="L2325">                    .colon, .r_brace, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_paren),</span>
<span class="line" id="L2326">                    <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2327">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_arg),</span>
<span class="line" id="L2328">                }</span>
<span class="line" id="L2329">            }</span>
<span class="line" id="L2330">            <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2331">            <span class="tok-kw">const</span> params = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2332">            res = <span class="tok-kw">switch</span> (params.len) {</span>
<span class="line" id="L2333">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L2334">                    .tag = <span class="tok-kw">if</span> (comma) .call_one_comma <span class="tok-kw">else</span> .call_one,</span>
<span class="line" id="L2335">                    .main_token = lparen,</span>
<span class="line" id="L2336">                    .data = .{</span>
<span class="line" id="L2337">                        .lhs = res,</span>
<span class="line" id="L2338">                        .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2339">                    },</span>
<span class="line" id="L2340">                }),</span>
<span class="line" id="L2341">                <span class="tok-number">1</span> =&gt; <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L2342">                    .tag = <span class="tok-kw">if</span> (comma) .call_one_comma <span class="tok-kw">else</span> .call_one,</span>
<span class="line" id="L2343">                    .main_token = lparen,</span>
<span class="line" id="L2344">                    .data = .{</span>
<span class="line" id="L2345">                        .lhs = res,</span>
<span class="line" id="L2346">                        .rhs = params[<span class="tok-number">0</span>],</span>
<span class="line" id="L2347">                    },</span>
<span class="line" id="L2348">                }),</span>
<span class="line" id="L2349">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.addNode(.{</span>
<span class="line" id="L2350">                    .tag = <span class="tok-kw">if</span> (comma) .call_comma <span class="tok-kw">else</span> .call,</span>
<span class="line" id="L2351">                    .main_token = lparen,</span>
<span class="line" id="L2352">                    .data = .{</span>
<span class="line" id="L2353">                        .lhs = res,</span>
<span class="line" id="L2354">                        .rhs = <span class="tok-kw">try</span> p.addExtra(<span class="tok-kw">try</span> p.listToSpan(params)),</span>
<span class="line" id="L2355">                    },</span>
<span class="line" id="L2356">                }),</span>
<span class="line" id="L2357">            };</span>
<span class="line" id="L2358">        }</span>
<span class="line" id="L2359">    }</span>
<span class="line" id="L2360"></span>
<span class="line" id="L2361">    <span class="tok-comment">/// PrimaryTypeExpr</span></span>
<span class="line" id="L2362">    <span class="tok-comment">///     &lt;- BUILTINIDENTIFIER FnCallArguments</span></span>
<span class="line" id="L2363">    <span class="tok-comment">///      / CHAR_LITERAL</span></span>
<span class="line" id="L2364">    <span class="tok-comment">///      / ContainerDecl</span></span>
<span class="line" id="L2365">    <span class="tok-comment">///      / DOT IDENTIFIER</span></span>
<span class="line" id="L2366">    <span class="tok-comment">///      / DOT InitList</span></span>
<span class="line" id="L2367">    <span class="tok-comment">///      / ErrorSetDecl</span></span>
<span class="line" id="L2368">    <span class="tok-comment">///      / FLOAT</span></span>
<span class="line" id="L2369">    <span class="tok-comment">///      / FnProto</span></span>
<span class="line" id="L2370">    <span class="tok-comment">///      / GroupedExpr</span></span>
<span class="line" id="L2371">    <span class="tok-comment">///      / LabeledTypeExpr</span></span>
<span class="line" id="L2372">    <span class="tok-comment">///      / IDENTIFIER</span></span>
<span class="line" id="L2373">    <span class="tok-comment">///      / IfTypeExpr</span></span>
<span class="line" id="L2374">    <span class="tok-comment">///      / INTEGER</span></span>
<span class="line" id="L2375">    <span class="tok-comment">///      / KEYWORD_comptime TypeExpr</span></span>
<span class="line" id="L2376">    <span class="tok-comment">///      / KEYWORD_error DOT IDENTIFIER</span></span>
<span class="line" id="L2377">    <span class="tok-comment">///      / KEYWORD_anyframe</span></span>
<span class="line" id="L2378">    <span class="tok-comment">///      / KEYWORD_unreachable</span></span>
<span class="line" id="L2379">    <span class="tok-comment">///      / STRINGLITERAL</span></span>
<span class="line" id="L2380">    <span class="tok-comment">///      / SwitchExpr</span></span>
<span class="line" id="L2381">    <span class="tok-comment">/// ContainerDecl &lt;- (KEYWORD_extern / KEYWORD_packed)? ContainerDeclAuto</span></span>
<span class="line" id="L2382">    <span class="tok-comment">/// ContainerDeclAuto &lt;- ContainerDeclType LBRACE ContainerMembers RBRACE</span></span>
<span class="line" id="L2383">    <span class="tok-comment">/// InitList</span></span>
<span class="line" id="L2384">    <span class="tok-comment">///     &lt;- LBRACE FieldInit (COMMA FieldInit)* COMMA? RBRACE</span></span>
<span class="line" id="L2385">    <span class="tok-comment">///      / LBRACE Expr (COMMA Expr)* COMMA? RBRACE</span></span>
<span class="line" id="L2386">    <span class="tok-comment">///      / LBRACE RBRACE</span></span>
<span class="line" id="L2387">    <span class="tok-comment">/// ErrorSetDecl &lt;- KEYWORD_error LBRACE IdentifierList RBRACE</span></span>
<span class="line" id="L2388">    <span class="tok-comment">/// GroupedExpr &lt;- LPAREN Expr RPAREN</span></span>
<span class="line" id="L2389">    <span class="tok-comment">/// IfTypeExpr &lt;- IfPrefix TypeExpr (KEYWORD_else Payload? TypeExpr)?</span></span>
<span class="line" id="L2390">    <span class="tok-comment">/// LabeledTypeExpr</span></span>
<span class="line" id="L2391">    <span class="tok-comment">///     &lt;- BlockLabel Block</span></span>
<span class="line" id="L2392">    <span class="tok-comment">///      / BlockLabel? LoopTypeExpr</span></span>
<span class="line" id="L2393">    <span class="tok-comment">/// LoopTypeExpr &lt;- KEYWORD_inline? (ForTypeExpr / WhileTypeExpr)</span></span>
<span class="line" id="L2394">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePrimaryTypeExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2395">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2396">            .char_literal =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2397">                .tag = .char_literal,</span>
<span class="line" id="L2398">                .main_token = p.nextToken(),</span>
<span class="line" id="L2399">                .data = .{</span>
<span class="line" id="L2400">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2401">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2402">                },</span>
<span class="line" id="L2403">            }),</span>
<span class="line" id="L2404">            .integer_literal =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2405">                .tag = .integer_literal,</span>
<span class="line" id="L2406">                .main_token = p.nextToken(),</span>
<span class="line" id="L2407">                .data = .{</span>
<span class="line" id="L2408">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2409">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2410">                },</span>
<span class="line" id="L2411">            }),</span>
<span class="line" id="L2412">            .float_literal =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2413">                .tag = .float_literal,</span>
<span class="line" id="L2414">                .main_token = p.nextToken(),</span>
<span class="line" id="L2415">                .data = .{</span>
<span class="line" id="L2416">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2417">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2418">                },</span>
<span class="line" id="L2419">            }),</span>
<span class="line" id="L2420">            .keyword_unreachable =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2421">                .tag = .unreachable_literal,</span>
<span class="line" id="L2422">                .main_token = p.nextToken(),</span>
<span class="line" id="L2423">                .data = .{</span>
<span class="line" id="L2424">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2425">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2426">                },</span>
<span class="line" id="L2427">            }),</span>
<span class="line" id="L2428">            .keyword_anyframe =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2429">                .tag = .anyframe_literal,</span>
<span class="line" id="L2430">                .main_token = p.nextToken(),</span>
<span class="line" id="L2431">                .data = .{</span>
<span class="line" id="L2432">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2433">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2434">                },</span>
<span class="line" id="L2435">            }),</span>
<span class="line" id="L2436">            .string_literal =&gt; {</span>
<span class="line" id="L2437">                <span class="tok-kw">const</span> main_token = p.nextToken();</span>
<span class="line" id="L2438">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2439">                    .tag = .string_literal,</span>
<span class="line" id="L2440">                    .main_token = main_token,</span>
<span class="line" id="L2441">                    .data = .{</span>
<span class="line" id="L2442">                        .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2443">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2444">                    },</span>
<span class="line" id="L2445">                });</span>
<span class="line" id="L2446">            },</span>
<span class="line" id="L2447"></span>
<span class="line" id="L2448">            .builtin =&gt; <span class="tok-kw">return</span> p.parseBuiltinCall(),</span>
<span class="line" id="L2449">            .keyword_fn =&gt; <span class="tok-kw">return</span> p.parseFnProto(),</span>
<span class="line" id="L2450">            .keyword_if =&gt; <span class="tok-kw">return</span> p.parseIf(expectTypeExpr),</span>
<span class="line" id="L2451">            .keyword_switch =&gt; <span class="tok-kw">return</span> p.expectSwitchExpr(),</span>
<span class="line" id="L2452"></span>
<span class="line" id="L2453">            .keyword_extern,</span>
<span class="line" id="L2454">            .keyword_packed,</span>
<span class="line" id="L2455">            =&gt; {</span>
<span class="line" id="L2456">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2457">                <span class="tok-kw">return</span> p.parseContainerDeclAuto();</span>
<span class="line" id="L2458">            },</span>
<span class="line" id="L2459"></span>
<span class="line" id="L2460">            .keyword_struct,</span>
<span class="line" id="L2461">            .keyword_opaque,</span>
<span class="line" id="L2462">            .keyword_enum,</span>
<span class="line" id="L2463">            .keyword_union,</span>
<span class="line" id="L2464">            =&gt; <span class="tok-kw">return</span> p.parseContainerDeclAuto(),</span>
<span class="line" id="L2465"></span>
<span class="line" id="L2466">            .keyword_comptime =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2467">                .tag = .@&quot;comptime&quot;,</span>
<span class="line" id="L2468">                .main_token = p.nextToken(),</span>
<span class="line" id="L2469">                .data = .{</span>
<span class="line" id="L2470">                    .lhs = <span class="tok-kw">try</span> p.expectTypeExpr(),</span>
<span class="line" id="L2471">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2472">                },</span>
<span class="line" id="L2473">            }),</span>
<span class="line" id="L2474">            .multiline_string_literal_line =&gt; {</span>
<span class="line" id="L2475">                <span class="tok-kw">const</span> first_line = p.nextToken();</span>
<span class="line" id="L2476">                <span class="tok-kw">while</span> (p.token_tags[p.tok_i] == .multiline_string_literal_line) {</span>
<span class="line" id="L2477">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2478">                }</span>
<span class="line" id="L2479">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2480">                    .tag = .multiline_string_literal,</span>
<span class="line" id="L2481">                    .main_token = first_line,</span>
<span class="line" id="L2482">                    .data = .{</span>
<span class="line" id="L2483">                        .lhs = first_line,</span>
<span class="line" id="L2484">                        .rhs = p.tok_i - <span class="tok-number">1</span>,</span>
<span class="line" id="L2485">                    },</span>
<span class="line" id="L2486">                });</span>
<span class="line" id="L2487">            },</span>
<span class="line" id="L2488">            .identifier =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L2489">                .colon =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">2</span>]) {</span>
<span class="line" id="L2490">                    .keyword_inline =&gt; {</span>
<span class="line" id="L2491">                        p.tok_i += <span class="tok-number">3</span>;</span>
<span class="line" id="L2492">                        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2493">                            .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForTypeExpr(),</span>
<span class="line" id="L2494">                            .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileTypeExpr(),</span>
<span class="line" id="L2495">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.fail(.expected_inlinable),</span>
<span class="line" id="L2496">                        }</span>
<span class="line" id="L2497">                    },</span>
<span class="line" id="L2498">                    .keyword_for =&gt; {</span>
<span class="line" id="L2499">                        p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2500">                        <span class="tok-kw">return</span> p.parseForTypeExpr();</span>
<span class="line" id="L2501">                    },</span>
<span class="line" id="L2502">                    .keyword_while =&gt; {</span>
<span class="line" id="L2503">                        p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2504">                        <span class="tok-kw">return</span> p.parseWhileTypeExpr();</span>
<span class="line" id="L2505">                    },</span>
<span class="line" id="L2506">                    .l_brace =&gt; {</span>
<span class="line" id="L2507">                        p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2508">                        <span class="tok-kw">return</span> p.parseBlock();</span>
<span class="line" id="L2509">                    },</span>
<span class="line" id="L2510">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2511">                        .tag = .identifier,</span>
<span class="line" id="L2512">                        .main_token = p.nextToken(),</span>
<span class="line" id="L2513">                        .data = .{</span>
<span class="line" id="L2514">                            .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2515">                            .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2516">                        },</span>
<span class="line" id="L2517">                    }),</span>
<span class="line" id="L2518">                },</span>
<span class="line" id="L2519">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2520">                    .tag = .identifier,</span>
<span class="line" id="L2521">                    .main_token = p.nextToken(),</span>
<span class="line" id="L2522">                    .data = .{</span>
<span class="line" id="L2523">                        .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2524">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2525">                    },</span>
<span class="line" id="L2526">                }),</span>
<span class="line" id="L2527">            },</span>
<span class="line" id="L2528">            .keyword_inline =&gt; {</span>
<span class="line" id="L2529">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2530">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2531">                    .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForTypeExpr(),</span>
<span class="line" id="L2532">                    .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileTypeExpr(),</span>
<span class="line" id="L2533">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.fail(.expected_inlinable),</span>
<span class="line" id="L2534">                }</span>
<span class="line" id="L2535">            },</span>
<span class="line" id="L2536">            .keyword_for =&gt; <span class="tok-kw">return</span> p.parseForTypeExpr(),</span>
<span class="line" id="L2537">            .keyword_while =&gt; <span class="tok-kw">return</span> p.parseWhileTypeExpr(),</span>
<span class="line" id="L2538">            .period =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L2539">                .identifier =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2540">                    .tag = .enum_literal,</span>
<span class="line" id="L2541">                    .data = .{</span>
<span class="line" id="L2542">                        .lhs = p.nextToken(), <span class="tok-comment">// dot</span>
</span>
<span class="line" id="L2543">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2544">                    },</span>
<span class="line" id="L2545">                    .main_token = p.nextToken(), <span class="tok-comment">// identifier</span>
</span>
<span class="line" id="L2546">                }),</span>
<span class="line" id="L2547">                .l_brace =&gt; {</span>
<span class="line" id="L2548">                    <span class="tok-kw">const</span> lbrace = p.tok_i + <span class="tok-number">1</span>;</span>
<span class="line" id="L2549">                    p.tok_i = lbrace + <span class="tok-number">1</span>;</span>
<span class="line" id="L2550"></span>
<span class="line" id="L2551">                    <span class="tok-comment">// If there are 0, 1, or 2 items, we can use ArrayInitDotTwo/StructInitDotTwo;</span>
</span>
<span class="line" id="L2552">                    <span class="tok-comment">// otherwise we use the full ArrayInitDot/StructInitDot.</span>
</span>
<span class="line" id="L2553"></span>
<span class="line" id="L2554">                    <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L2555">                    <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L2556">                    <span class="tok-kw">const</span> field_init = <span class="tok-kw">try</span> p.parseFieldInit();</span>
<span class="line" id="L2557">                    <span class="tok-kw">if</span> (field_init != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2558">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, field_init);</span>
<span class="line" id="L2559">                        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2560">                            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2561">                                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2562">                                .r_brace =&gt; {</span>
<span class="line" id="L2563">                                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2564">                                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L2565">                                },</span>
<span class="line" id="L2566">                                .colon, .r_paren, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_brace),</span>
<span class="line" id="L2567">                                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2568">                                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_initializer),</span>
<span class="line" id="L2569">                            }</span>
<span class="line" id="L2570">                            <span class="tok-kw">if</span> (p.eatToken(.r_brace)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2571">                            <span class="tok-kw">const</span> next = <span class="tok-kw">try</span> p.expectFieldInit();</span>
<span class="line" id="L2572">                            <span class="tok-kw">try</span> p.scratch.append(p.gpa, next);</span>
<span class="line" id="L2573">                        }</span>
<span class="line" id="L2574">                        <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2575">                        <span class="tok-kw">const</span> inits = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2576">                        <span class="tok-kw">switch</span> (inits.len) {</span>
<span class="line" id="L2577">                            <span class="tok-number">0</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2578">                            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2579">                                .tag = <span class="tok-kw">if</span> (comma) .struct_init_dot_two_comma <span class="tok-kw">else</span> .struct_init_dot_two,</span>
<span class="line" id="L2580">                                .main_token = lbrace,</span>
<span class="line" id="L2581">                                .data = .{</span>
<span class="line" id="L2582">                                    .lhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2583">                                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2584">                                },</span>
<span class="line" id="L2585">                            }),</span>
<span class="line" id="L2586">                            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2587">                                .tag = <span class="tok-kw">if</span> (comma) .struct_init_dot_two_comma <span class="tok-kw">else</span> .struct_init_dot_two,</span>
<span class="line" id="L2588">                                .main_token = lbrace,</span>
<span class="line" id="L2589">                                .data = .{</span>
<span class="line" id="L2590">                                    .lhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2591">                                    .rhs = inits[<span class="tok-number">1</span>],</span>
<span class="line" id="L2592">                                },</span>
<span class="line" id="L2593">                            }),</span>
<span class="line" id="L2594">                            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2595">                                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(inits);</span>
<span class="line" id="L2596">                                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2597">                                    .tag = <span class="tok-kw">if</span> (comma) .struct_init_dot_comma <span class="tok-kw">else</span> .struct_init_dot,</span>
<span class="line" id="L2598">                                    .main_token = lbrace,</span>
<span class="line" id="L2599">                                    .data = .{</span>
<span class="line" id="L2600">                                        .lhs = span.start,</span>
<span class="line" id="L2601">                                        .rhs = span.end,</span>
<span class="line" id="L2602">                                    },</span>
<span class="line" id="L2603">                                });</span>
<span class="line" id="L2604">                            },</span>
<span class="line" id="L2605">                        }</span>
<span class="line" id="L2606">                    }</span>
<span class="line" id="L2607"></span>
<span class="line" id="L2608">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2609">                        <span class="tok-kw">if</span> (p.eatToken(.r_brace)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2610">                        <span class="tok-kw">const</span> elem_init = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2611">                        <span class="tok-kw">try</span> p.scratch.append(p.gpa, elem_init);</span>
<span class="line" id="L2612">                        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2613">                            .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2614">                            .r_brace =&gt; {</span>
<span class="line" id="L2615">                                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2616">                                <span class="tok-kw">break</span>;</span>
<span class="line" id="L2617">                            },</span>
<span class="line" id="L2618">                            .colon, .r_paren, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_brace),</span>
<span class="line" id="L2619">                            <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2620">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_initializer),</span>
<span class="line" id="L2621">                        }</span>
<span class="line" id="L2622">                    }</span>
<span class="line" id="L2623">                    <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L2624">                    <span class="tok-kw">const</span> inits = p.scratch.items[scratch_top..];</span>
<span class="line" id="L2625">                    <span class="tok-kw">switch</span> (inits.len) {</span>
<span class="line" id="L2626">                        <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2627">                            .tag = .struct_init_dot_two,</span>
<span class="line" id="L2628">                            .main_token = lbrace,</span>
<span class="line" id="L2629">                            .data = .{</span>
<span class="line" id="L2630">                                .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2631">                                .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2632">                            },</span>
<span class="line" id="L2633">                        }),</span>
<span class="line" id="L2634">                        <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2635">                            .tag = <span class="tok-kw">if</span> (comma) .array_init_dot_two_comma <span class="tok-kw">else</span> .array_init_dot_two,</span>
<span class="line" id="L2636">                            .main_token = lbrace,</span>
<span class="line" id="L2637">                            .data = .{</span>
<span class="line" id="L2638">                                .lhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2639">                                .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L2640">                            },</span>
<span class="line" id="L2641">                        }),</span>
<span class="line" id="L2642">                        <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2643">                            .tag = <span class="tok-kw">if</span> (comma) .array_init_dot_two_comma <span class="tok-kw">else</span> .array_init_dot_two,</span>
<span class="line" id="L2644">                            .main_token = lbrace,</span>
<span class="line" id="L2645">                            .data = .{</span>
<span class="line" id="L2646">                                .lhs = inits[<span class="tok-number">0</span>],</span>
<span class="line" id="L2647">                                .rhs = inits[<span class="tok-number">1</span>],</span>
<span class="line" id="L2648">                            },</span>
<span class="line" id="L2649">                        }),</span>
<span class="line" id="L2650">                        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2651">                            <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(inits);</span>
<span class="line" id="L2652">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2653">                                .tag = <span class="tok-kw">if</span> (comma) .array_init_dot_comma <span class="tok-kw">else</span> .array_init_dot,</span>
<span class="line" id="L2654">                                .main_token = lbrace,</span>
<span class="line" id="L2655">                                .data = .{</span>
<span class="line" id="L2656">                                    .lhs = span.start,</span>
<span class="line" id="L2657">                                    .rhs = span.end,</span>
<span class="line" id="L2658">                                },</span>
<span class="line" id="L2659">                            });</span>
<span class="line" id="L2660">                        },</span>
<span class="line" id="L2661">                    }</span>
<span class="line" id="L2662">                },</span>
<span class="line" id="L2663">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> null_node,</span>
<span class="line" id="L2664">            },</span>
<span class="line" id="L2665">            .keyword_error =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L2666">                .l_brace =&gt; {</span>
<span class="line" id="L2667">                    <span class="tok-kw">const</span> error_token = p.tok_i;</span>
<span class="line" id="L2668">                    p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2669">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2670">                        <span class="tok-kw">if</span> (p.eatToken(.r_brace)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L2671">                        _ = <span class="tok-kw">try</span> p.eatDocComments();</span>
<span class="line" id="L2672">                        _ = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L2673">                        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2674">                            .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2675">                            .r_brace =&gt; {</span>
<span class="line" id="L2676">                                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L2677">                                <span class="tok-kw">break</span>;</span>
<span class="line" id="L2678">                            },</span>
<span class="line" id="L2679">                            .colon, .r_paren, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_brace),</span>
<span class="line" id="L2680">                            <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2681">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_field),</span>
<span class="line" id="L2682">                        }</span>
<span class="line" id="L2683">                    }</span>
<span class="line" id="L2684">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2685">                        .tag = .error_set_decl,</span>
<span class="line" id="L2686">                        .main_token = error_token,</span>
<span class="line" id="L2687">                        .data = .{</span>
<span class="line" id="L2688">                            .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L2689">                            .rhs = p.tok_i - <span class="tok-number">1</span>, <span class="tok-comment">// rbrace</span>
</span>
<span class="line" id="L2690">                        },</span>
<span class="line" id="L2691">                    });</span>
<span class="line" id="L2692">                },</span>
<span class="line" id="L2693">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L2694">                    <span class="tok-kw">const</span> main_token = p.nextToken();</span>
<span class="line" id="L2695">                    <span class="tok-kw">const</span> period = p.eatToken(.period);</span>
<span class="line" id="L2696">                    <span class="tok-kw">if</span> (period == <span class="tok-null">null</span>) <span class="tok-kw">try</span> p.warnExpected(.period);</span>
<span class="line" id="L2697">                    <span class="tok-kw">const</span> identifier = p.eatToken(.identifier);</span>
<span class="line" id="L2698">                    <span class="tok-kw">if</span> (identifier == <span class="tok-null">null</span>) <span class="tok-kw">try</span> p.warnExpected(.identifier);</span>
<span class="line" id="L2699">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2700">                        .tag = .error_value,</span>
<span class="line" id="L2701">                        .main_token = main_token,</span>
<span class="line" id="L2702">                        .data = .{</span>
<span class="line" id="L2703">                            .lhs = period <span class="tok-kw">orelse</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L2704">                            .rhs = identifier <span class="tok-kw">orelse</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L2705">                        },</span>
<span class="line" id="L2706">                    });</span>
<span class="line" id="L2707">                },</span>
<span class="line" id="L2708">            },</span>
<span class="line" id="L2709">            .l_paren =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2710">                .tag = .grouped_expression,</span>
<span class="line" id="L2711">                .main_token = p.nextToken(),</span>
<span class="line" id="L2712">                .data = .{</span>
<span class="line" id="L2713">                    .lhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L2714">                    .rhs = <span class="tok-kw">try</span> p.expectToken(.r_paren),</span>
<span class="line" id="L2715">                },</span>
<span class="line" id="L2716">            }),</span>
<span class="line" id="L2717">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> null_node,</span>
<span class="line" id="L2718">        }</span>
<span class="line" id="L2719">    }</span>
<span class="line" id="L2720"></span>
<span class="line" id="L2721">    <span class="tok-kw">fn</span> <span class="tok-fn">expectPrimaryTypeExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2722">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parsePrimaryTypeExpr();</span>
<span class="line" id="L2723">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2724">            <span class="tok-kw">return</span> p.fail(.expected_primary_type_expr);</span>
<span class="line" id="L2725">        }</span>
<span class="line" id="L2726">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L2727">    }</span>
<span class="line" id="L2728"></span>
<span class="line" id="L2729">    <span class="tok-comment">/// ForPrefix &lt;- KEYWORD_for LPAREN Expr RPAREN PtrIndexPayload</span></span>
<span class="line" id="L2730">    <span class="tok-comment">/// ForTypeExpr &lt;- ForPrefix TypeExpr (KEYWORD_else TypeExpr)?</span></span>
<span class="line" id="L2731">    <span class="tok-kw">fn</span> <span class="tok-fn">parseForTypeExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2732">        <span class="tok-kw">const</span> for_token = p.eatToken(.keyword_for) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2733">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2734">        <span class="tok-kw">const</span> array_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2735">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2736">        <span class="tok-kw">const</span> found_payload = <span class="tok-kw">try</span> p.parsePtrIndexPayload();</span>
<span class="line" id="L2737">        <span class="tok-kw">if</span> (found_payload == <span class="tok-number">0</span>) <span class="tok-kw">try</span> p.warn(.expected_loop_payload);</span>
<span class="line" id="L2738"></span>
<span class="line" id="L2739">        <span class="tok-kw">const</span> then_expr = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L2740">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L2741">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2742">                .tag = .for_simple,</span>
<span class="line" id="L2743">                .main_token = for_token,</span>
<span class="line" id="L2744">                .data = .{</span>
<span class="line" id="L2745">                    .lhs = array_expr,</span>
<span class="line" id="L2746">                    .rhs = then_expr,</span>
<span class="line" id="L2747">                },</span>
<span class="line" id="L2748">            });</span>
<span class="line" id="L2749">        };</span>
<span class="line" id="L2750">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L2751">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2752">            .tag = .@&quot;for&quot;,</span>
<span class="line" id="L2753">            .main_token = for_token,</span>
<span class="line" id="L2754">            .data = .{</span>
<span class="line" id="L2755">                .lhs = array_expr,</span>
<span class="line" id="L2756">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.If{</span>
<span class="line" id="L2757">                    .then_expr = then_expr,</span>
<span class="line" id="L2758">                    .else_expr = else_expr,</span>
<span class="line" id="L2759">                }),</span>
<span class="line" id="L2760">            },</span>
<span class="line" id="L2761">        });</span>
<span class="line" id="L2762">    }</span>
<span class="line" id="L2763"></span>
<span class="line" id="L2764">    <span class="tok-comment">/// WhilePrefix &lt;- KEYWORD_while LPAREN Expr RPAREN PtrPayload? WhileContinueExpr?</span></span>
<span class="line" id="L2765">    <span class="tok-comment">/// WhileTypeExpr &lt;- WhilePrefix TypeExpr (KEYWORD_else Payload? TypeExpr)?</span></span>
<span class="line" id="L2766">    <span class="tok-kw">fn</span> <span class="tok-fn">parseWhileTypeExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2767">        <span class="tok-kw">const</span> while_token = p.eatToken(.keyword_while) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2768">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2769">        <span class="tok-kw">const</span> condition = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2770">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2771">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L2772">        <span class="tok-kw">const</span> cont_expr = <span class="tok-kw">try</span> p.parseWhileContinueExpr();</span>
<span class="line" id="L2773"></span>
<span class="line" id="L2774">        <span class="tok-kw">const</span> then_expr = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L2775">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L2776">            <span class="tok-kw">if</span> (cont_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L2777">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2778">                    .tag = .while_simple,</span>
<span class="line" id="L2779">                    .main_token = while_token,</span>
<span class="line" id="L2780">                    .data = .{</span>
<span class="line" id="L2781">                        .lhs = condition,</span>
<span class="line" id="L2782">                        .rhs = then_expr,</span>
<span class="line" id="L2783">                    },</span>
<span class="line" id="L2784">                });</span>
<span class="line" id="L2785">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2786">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2787">                    .tag = .while_cont,</span>
<span class="line" id="L2788">                    .main_token = while_token,</span>
<span class="line" id="L2789">                    .data = .{</span>
<span class="line" id="L2790">                        .lhs = condition,</span>
<span class="line" id="L2791">                        .rhs = <span class="tok-kw">try</span> p.addExtra(Node.WhileCont{</span>
<span class="line" id="L2792">                            .cont_expr = cont_expr,</span>
<span class="line" id="L2793">                            .then_expr = then_expr,</span>
<span class="line" id="L2794">                        }),</span>
<span class="line" id="L2795">                    },</span>
<span class="line" id="L2796">                });</span>
<span class="line" id="L2797">            }</span>
<span class="line" id="L2798">        };</span>
<span class="line" id="L2799">        _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L2800">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L2801">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2802">            .tag = .@&quot;while&quot;,</span>
<span class="line" id="L2803">            .main_token = while_token,</span>
<span class="line" id="L2804">            .data = .{</span>
<span class="line" id="L2805">                .lhs = condition,</span>
<span class="line" id="L2806">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.While{</span>
<span class="line" id="L2807">                    .cont_expr = cont_expr,</span>
<span class="line" id="L2808">                    .then_expr = then_expr,</span>
<span class="line" id="L2809">                    .else_expr = else_expr,</span>
<span class="line" id="L2810">                }),</span>
<span class="line" id="L2811">            },</span>
<span class="line" id="L2812">        });</span>
<span class="line" id="L2813">    }</span>
<span class="line" id="L2814"></span>
<span class="line" id="L2815">    <span class="tok-comment">/// SwitchExpr &lt;- KEYWORD_switch LPAREN Expr RPAREN LBRACE SwitchProngList RBRACE</span></span>
<span class="line" id="L2816">    <span class="tok-kw">fn</span> <span class="tok-fn">expectSwitchExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2817">        <span class="tok-kw">const</span> switch_token = p.assertToken(.keyword_switch);</span>
<span class="line" id="L2818">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2819">        <span class="tok-kw">const</span> expr_node = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2820">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2821">        _ = <span class="tok-kw">try</span> p.expectToken(.l_brace);</span>
<span class="line" id="L2822">        <span class="tok-kw">const</span> cases = <span class="tok-kw">try</span> p.parseSwitchProngList();</span>
<span class="line" id="L2823">        <span class="tok-kw">const</span> trailing_comma = p.token_tags[p.tok_i - <span class="tok-number">1</span>] == .comma;</span>
<span class="line" id="L2824">        _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L2825"></span>
<span class="line" id="L2826">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2827">            .tag = <span class="tok-kw">if</span> (trailing_comma) .switch_comma <span class="tok-kw">else</span> .@&quot;switch&quot;,</span>
<span class="line" id="L2828">            .main_token = switch_token,</span>
<span class="line" id="L2829">            .data = .{</span>
<span class="line" id="L2830">                .lhs = expr_node,</span>
<span class="line" id="L2831">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.SubRange{</span>
<span class="line" id="L2832">                    .start = cases.start,</span>
<span class="line" id="L2833">                    .end = cases.end,</span>
<span class="line" id="L2834">                }),</span>
<span class="line" id="L2835">            },</span>
<span class="line" id="L2836">        });</span>
<span class="line" id="L2837">    }</span>
<span class="line" id="L2838"></span>
<span class="line" id="L2839">    <span class="tok-comment">/// AsmExpr &lt;- KEYWORD_asm KEYWORD_volatile? LPAREN Expr AsmOutput? RPAREN</span></span>
<span class="line" id="L2840">    <span class="tok-comment">/// AsmOutput &lt;- COLON AsmOutputList AsmInput?</span></span>
<span class="line" id="L2841">    <span class="tok-comment">/// AsmInput &lt;- COLON AsmInputList AsmClobbers?</span></span>
<span class="line" id="L2842">    <span class="tok-comment">/// AsmClobbers &lt;- COLON StringList</span></span>
<span class="line" id="L2843">    <span class="tok-comment">/// StringList &lt;- (STRINGLITERAL COMMA)* STRINGLITERAL?</span></span>
<span class="line" id="L2844">    <span class="tok-comment">/// AsmOutputList &lt;- (AsmOutputItem COMMA)* AsmOutputItem?</span></span>
<span class="line" id="L2845">    <span class="tok-comment">/// AsmInputList &lt;- (AsmInputItem COMMA)* AsmInputItem?</span></span>
<span class="line" id="L2846">    <span class="tok-kw">fn</span> <span class="tok-fn">expectAsmExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2847">        <span class="tok-kw">const</span> asm_token = p.assertToken(.keyword_asm);</span>
<span class="line" id="L2848">        _ = p.eatToken(.keyword_volatile);</span>
<span class="line" id="L2849">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2850">        <span class="tok-kw">const</span> template = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2851"></span>
<span class="line" id="L2852">        <span class="tok-kw">if</span> (p.eatToken(.r_paren)) |rparen| {</span>
<span class="line" id="L2853">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2854">                .tag = .asm_simple,</span>
<span class="line" id="L2855">                .main_token = asm_token,</span>
<span class="line" id="L2856">                .data = .{</span>
<span class="line" id="L2857">                    .lhs = template,</span>
<span class="line" id="L2858">                    .rhs = rparen,</span>
<span class="line" id="L2859">                },</span>
<span class="line" id="L2860">            });</span>
<span class="line" id="L2861">        }</span>
<span class="line" id="L2862"></span>
<span class="line" id="L2863">        _ = <span class="tok-kw">try</span> p.expectToken(.colon);</span>
<span class="line" id="L2864"></span>
<span class="line" id="L2865">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L2866">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L2867"></span>
<span class="line" id="L2868">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2869">            <span class="tok-kw">const</span> output_item = <span class="tok-kw">try</span> p.parseAsmOutputItem();</span>
<span class="line" id="L2870">            <span class="tok-kw">if</span> (output_item == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L2871">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, output_item);</span>
<span class="line" id="L2872">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2873">                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2874">                <span class="tok-comment">// All possible delimiters.</span>
</span>
<span class="line" id="L2875">                .colon, .r_paren, .r_brace, .r_bracket =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L2876">                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2877">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warnExpected(.comma),</span>
<span class="line" id="L2878">            }</span>
<span class="line" id="L2879">        }</span>
<span class="line" id="L2880">        <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L2881">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2882">                <span class="tok-kw">const</span> input_item = <span class="tok-kw">try</span> p.parseAsmInputItem();</span>
<span class="line" id="L2883">                <span class="tok-kw">if</span> (input_item == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L2884">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, input_item);</span>
<span class="line" id="L2885">                <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2886">                    .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2887">                    <span class="tok-comment">// All possible delimiters.</span>
</span>
<span class="line" id="L2888">                    .colon, .r_paren, .r_brace, .r_bracket =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L2889">                    <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2890">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warnExpected(.comma),</span>
<span class="line" id="L2891">                }</span>
<span class="line" id="L2892">            }</span>
<span class="line" id="L2893">            <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L2894">                <span class="tok-kw">while</span> (p.eatToken(.string_literal)) |_| {</span>
<span class="line" id="L2895">                    <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L2896">                        .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L2897">                        .colon, .r_paren, .r_brace, .r_bracket =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L2898">                        <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L2899">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warnExpected(.comma),</span>
<span class="line" id="L2900">                    }</span>
<span class="line" id="L2901">                }</span>
<span class="line" id="L2902">            }</span>
<span class="line" id="L2903">        }</span>
<span class="line" id="L2904">        <span class="tok-kw">const</span> rparen = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2905">        <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(p.scratch.items[scratch_top..]);</span>
<span class="line" id="L2906">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2907">            .tag = .@&quot;asm&quot;,</span>
<span class="line" id="L2908">            .main_token = asm_token,</span>
<span class="line" id="L2909">            .data = .{</span>
<span class="line" id="L2910">                .lhs = template,</span>
<span class="line" id="L2911">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.Asm{</span>
<span class="line" id="L2912">                    .items_start = span.start,</span>
<span class="line" id="L2913">                    .items_end = span.end,</span>
<span class="line" id="L2914">                    .rparen = rparen,</span>
<span class="line" id="L2915">                }),</span>
<span class="line" id="L2916">            },</span>
<span class="line" id="L2917">        });</span>
<span class="line" id="L2918">    }</span>
<span class="line" id="L2919"></span>
<span class="line" id="L2920">    <span class="tok-comment">/// AsmOutputItem &lt;- LBRACKET IDENTIFIER RBRACKET STRINGLITERAL LPAREN (MINUSRARROW TypeExpr / IDENTIFIER) RPAREN</span></span>
<span class="line" id="L2921">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAsmOutputItem</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2922">        _ = p.eatToken(.l_bracket) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2923">        <span class="tok-kw">const</span> identifier = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L2924">        _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L2925">        _ = <span class="tok-kw">try</span> p.expectToken(.string_literal);</span>
<span class="line" id="L2926">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2927">        <span class="tok-kw">const</span> type_expr: Node.Index = blk: {</span>
<span class="line" id="L2928">            <span class="tok-kw">if</span> (p.eatToken(.arrow)) |_| {</span>
<span class="line" id="L2929">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> p.expectTypeExpr();</span>
<span class="line" id="L2930">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2931">                _ = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L2932">                <span class="tok-kw">break</span> :blk null_node;</span>
<span class="line" id="L2933">            }</span>
<span class="line" id="L2934">        };</span>
<span class="line" id="L2935">        <span class="tok-kw">const</span> rparen = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2936">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2937">            .tag = .asm_output,</span>
<span class="line" id="L2938">            .main_token = identifier,</span>
<span class="line" id="L2939">            .data = .{</span>
<span class="line" id="L2940">                .lhs = type_expr,</span>
<span class="line" id="L2941">                .rhs = rparen,</span>
<span class="line" id="L2942">            },</span>
<span class="line" id="L2943">        });</span>
<span class="line" id="L2944">    }</span>
<span class="line" id="L2945"></span>
<span class="line" id="L2946">    <span class="tok-comment">/// AsmInputItem &lt;- LBRACKET IDENTIFIER RBRACKET STRINGLITERAL LPAREN Expr RPAREN</span></span>
<span class="line" id="L2947">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAsmInputItem</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2948">        _ = p.eatToken(.l_bracket) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2949">        <span class="tok-kw">const</span> identifier = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L2950">        _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L2951">        _ = <span class="tok-kw">try</span> p.expectToken(.string_literal);</span>
<span class="line" id="L2952">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L2953">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L2954">        <span class="tok-kw">const</span> rparen = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L2955">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L2956">            .tag = .asm_input,</span>
<span class="line" id="L2957">            .main_token = identifier,</span>
<span class="line" id="L2958">            .data = .{</span>
<span class="line" id="L2959">                .lhs = expr,</span>
<span class="line" id="L2960">                .rhs = rparen,</span>
<span class="line" id="L2961">            },</span>
<span class="line" id="L2962">        });</span>
<span class="line" id="L2963">    }</span>
<span class="line" id="L2964"></span>
<span class="line" id="L2965">    <span class="tok-comment">/// BreakLabel &lt;- COLON IDENTIFIER</span></span>
<span class="line" id="L2966">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBreakLabel</span>(p: *Parser) !TokenIndex {</span>
<span class="line" id="L2967">        _ = p.eatToken(.colon) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(TokenIndex, <span class="tok-number">0</span>);</span>
<span class="line" id="L2968">        <span class="tok-kw">return</span> p.expectToken(.identifier);</span>
<span class="line" id="L2969">    }</span>
<span class="line" id="L2970"></span>
<span class="line" id="L2971">    <span class="tok-comment">/// BlockLabel &lt;- IDENTIFIER COLON</span></span>
<span class="line" id="L2972">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBlockLabel</span>(p: *Parser) TokenIndex {</span>
<span class="line" id="L2973">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == .identifier <span class="tok-kw">and</span></span>
<span class="line" id="L2974">            p.token_tags[p.tok_i + <span class="tok-number">1</span>] == .colon)</span>
<span class="line" id="L2975">        {</span>
<span class="line" id="L2976">            <span class="tok-kw">const</span> identifier = p.tok_i;</span>
<span class="line" id="L2977">            p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L2978">            <span class="tok-kw">return</span> identifier;</span>
<span class="line" id="L2979">        }</span>
<span class="line" id="L2980">        <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2981">    }</span>
<span class="line" id="L2982"></span>
<span class="line" id="L2983">    <span class="tok-comment">/// FieldInit &lt;- DOT IDENTIFIER EQUAL Expr</span></span>
<span class="line" id="L2984">    <span class="tok-kw">fn</span> <span class="tok-fn">parseFieldInit</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2985">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i + <span class="tok-number">0</span>] == .period <span class="tok-kw">and</span></span>
<span class="line" id="L2986">            p.token_tags[p.tok_i + <span class="tok-number">1</span>] == .identifier <span class="tok-kw">and</span></span>
<span class="line" id="L2987">            p.token_tags[p.tok_i + <span class="tok-number">2</span>] == .equal)</span>
<span class="line" id="L2988">        {</span>
<span class="line" id="L2989">            p.tok_i += <span class="tok-number">3</span>;</span>
<span class="line" id="L2990">            <span class="tok-kw">return</span> p.expectExpr();</span>
<span class="line" id="L2991">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2992">            <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L2993">        }</span>
<span class="line" id="L2994">    }</span>
<span class="line" id="L2995"></span>
<span class="line" id="L2996">    <span class="tok-kw">fn</span> <span class="tok-fn">expectFieldInit</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L2997">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] != .period <span class="tok-kw">or</span></span>
<span class="line" id="L2998">            p.token_tags[p.tok_i + <span class="tok-number">1</span>] != .identifier <span class="tok-kw">or</span></span>
<span class="line" id="L2999">            p.token_tags[p.tok_i + <span class="tok-number">2</span>] != .equal)</span>
<span class="line" id="L3000">            <span class="tok-kw">return</span> p.fail(.expected_initializer);</span>
<span class="line" id="L3001"></span>
<span class="line" id="L3002">        p.tok_i += <span class="tok-number">3</span>;</span>
<span class="line" id="L3003">        <span class="tok-kw">return</span> p.expectExpr();</span>
<span class="line" id="L3004">    }</span>
<span class="line" id="L3005"></span>
<span class="line" id="L3006">    <span class="tok-comment">/// WhileContinueExpr &lt;- COLON LPAREN AssignExpr RPAREN</span></span>
<span class="line" id="L3007">    <span class="tok-kw">fn</span> <span class="tok-fn">parseWhileContinueExpr</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3008">        _ = p.eatToken(.colon) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L3009">            <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == .l_paren <span class="tok-kw">and</span></span>
<span class="line" id="L3010">                p.tokensOnSameLine(p.tok_i - <span class="tok-number">1</span>, p.tok_i))</span>
<span class="line" id="L3011">                <span class="tok-kw">return</span> p.fail(.expected_continue_expr);</span>
<span class="line" id="L3012">            <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3013">        };</span>
<span class="line" id="L3014">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3015">        <span class="tok-kw">const</span> node = <span class="tok-kw">try</span> p.parseAssignExpr();</span>
<span class="line" id="L3016">        <span class="tok-kw">if</span> (node == <span class="tok-number">0</span>) <span class="tok-kw">return</span> p.fail(.expected_expr_or_assignment);</span>
<span class="line" id="L3017">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3018">        <span class="tok-kw">return</span> node;</span>
<span class="line" id="L3019">    }</span>
<span class="line" id="L3020"></span>
<span class="line" id="L3021">    <span class="tok-comment">/// LinkSection &lt;- KEYWORD_linksection LPAREN Expr RPAREN</span></span>
<span class="line" id="L3022">    <span class="tok-kw">fn</span> <span class="tok-fn">parseLinkSection</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3023">        _ = p.eatToken(.keyword_linksection) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3024">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3025">        <span class="tok-kw">const</span> expr_node = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3026">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3027">        <span class="tok-kw">return</span> expr_node;</span>
<span class="line" id="L3028">    }</span>
<span class="line" id="L3029"></span>
<span class="line" id="L3030">    <span class="tok-comment">/// CallConv &lt;- KEYWORD_callconv LPAREN Expr RPAREN</span></span>
<span class="line" id="L3031">    <span class="tok-kw">fn</span> <span class="tok-fn">parseCallconv</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3032">        _ = p.eatToken(.keyword_callconv) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3033">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3034">        <span class="tok-kw">const</span> expr_node = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3035">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3036">        <span class="tok-kw">return</span> expr_node;</span>
<span class="line" id="L3037">    }</span>
<span class="line" id="L3038"></span>
<span class="line" id="L3039">    <span class="tok-comment">/// AddrSpace &lt;- KEYWORD_addrspace LPAREN Expr RPAREN</span></span>
<span class="line" id="L3040">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAddrSpace</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3041">        _ = p.eatToken(.keyword_addrspace) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3042">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3043">        <span class="tok-kw">const</span> expr_node = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3044">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3045">        <span class="tok-kw">return</span> expr_node;</span>
<span class="line" id="L3046">    }</span>
<span class="line" id="L3047"></span>
<span class="line" id="L3048">    <span class="tok-comment">/// ParamDecl</span></span>
<span class="line" id="L3049">    <span class="tok-comment">///     &lt;- (KEYWORD_noalias / KEYWORD_comptime)? (IDENTIFIER COLON)? ParamType</span></span>
<span class="line" id="L3050">    <span class="tok-comment">///     / DOT3</span></span>
<span class="line" id="L3051">    <span class="tok-comment">/// ParamType</span></span>
<span class="line" id="L3052">    <span class="tok-comment">///     &lt;- Keyword_anytype</span></span>
<span class="line" id="L3053">    <span class="tok-comment">///      / TypeExpr</span></span>
<span class="line" id="L3054">    <span class="tok-comment">/// This function can return null nodes and then still return nodes afterwards,</span></span>
<span class="line" id="L3055">    <span class="tok-comment">/// such as in the case of anytype and `...`. Caller must look for rparen to find</span></span>
<span class="line" id="L3056">    <span class="tok-comment">/// out when there are no more param decls left.</span></span>
<span class="line" id="L3057">    <span class="tok-kw">fn</span> <span class="tok-fn">expectParamDecl</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3058">        _ = <span class="tok-kw">try</span> p.eatDocComments();</span>
<span class="line" id="L3059">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3060">            .keyword_noalias, .keyword_comptime =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L3061">            .ellipsis3 =&gt; {</span>
<span class="line" id="L3062">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3063">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3064">            },</span>
<span class="line" id="L3065">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L3066">        }</span>
<span class="line" id="L3067">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == .identifier <span class="tok-kw">and</span></span>
<span class="line" id="L3068">            p.token_tags[p.tok_i + <span class="tok-number">1</span>] == .colon)</span>
<span class="line" id="L3069">        {</span>
<span class="line" id="L3070">            p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L3071">        }</span>
<span class="line" id="L3072">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3073">            .keyword_anytype =&gt; {</span>
<span class="line" id="L3074">                p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3075">                <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3076">            },</span>
<span class="line" id="L3077">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.expectTypeExpr(),</span>
<span class="line" id="L3078">        }</span>
<span class="line" id="L3079">    }</span>
<span class="line" id="L3080"></span>
<span class="line" id="L3081">    <span class="tok-comment">/// Payload &lt;- PIPE IDENTIFIER PIPE</span></span>
<span class="line" id="L3082">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePayload</span>(p: *Parser) !TokenIndex {</span>
<span class="line" id="L3083">        _ = p.eatToken(.pipe) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(TokenIndex, <span class="tok-number">0</span>);</span>
<span class="line" id="L3084">        <span class="tok-kw">const</span> identifier = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L3085">        _ = <span class="tok-kw">try</span> p.expectToken(.pipe);</span>
<span class="line" id="L3086">        <span class="tok-kw">return</span> identifier;</span>
<span class="line" id="L3087">    }</span>
<span class="line" id="L3088"></span>
<span class="line" id="L3089">    <span class="tok-comment">/// PtrPayload &lt;- PIPE ASTERISK? IDENTIFIER PIPE</span></span>
<span class="line" id="L3090">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePtrPayload</span>(p: *Parser) !TokenIndex {</span>
<span class="line" id="L3091">        _ = p.eatToken(.pipe) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(TokenIndex, <span class="tok-number">0</span>);</span>
<span class="line" id="L3092">        _ = p.eatToken(.asterisk);</span>
<span class="line" id="L3093">        <span class="tok-kw">const</span> identifier = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L3094">        _ = <span class="tok-kw">try</span> p.expectToken(.pipe);</span>
<span class="line" id="L3095">        <span class="tok-kw">return</span> identifier;</span>
<span class="line" id="L3096">    }</span>
<span class="line" id="L3097"></span>
<span class="line" id="L3098">    <span class="tok-comment">/// PtrIndexPayload &lt;- PIPE ASTERISK? IDENTIFIER (COMMA IDENTIFIER)? PIPE</span></span>
<span class="line" id="L3099">    <span class="tok-comment">/// Returns the first identifier token, if any.</span></span>
<span class="line" id="L3100">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePtrIndexPayload</span>(p: *Parser) !TokenIndex {</span>
<span class="line" id="L3101">        _ = p.eatToken(.pipe) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(TokenIndex, <span class="tok-number">0</span>);</span>
<span class="line" id="L3102">        _ = p.eatToken(.asterisk);</span>
<span class="line" id="L3103">        <span class="tok-kw">const</span> identifier = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L3104">        <span class="tok-kw">if</span> (p.eatToken(.comma) != <span class="tok-null">null</span>) {</span>
<span class="line" id="L3105">            _ = <span class="tok-kw">try</span> p.expectToken(.identifier);</span>
<span class="line" id="L3106">        }</span>
<span class="line" id="L3107">        _ = <span class="tok-kw">try</span> p.expectToken(.pipe);</span>
<span class="line" id="L3108">        <span class="tok-kw">return</span> identifier;</span>
<span class="line" id="L3109">    }</span>
<span class="line" id="L3110"></span>
<span class="line" id="L3111">    <span class="tok-comment">/// SwitchProng &lt;- SwitchCase EQUALRARROW PtrPayload? AssignExpr</span></span>
<span class="line" id="L3112">    <span class="tok-comment">/// SwitchCase</span></span>
<span class="line" id="L3113">    <span class="tok-comment">///     &lt;- SwitchItem (COMMA SwitchItem)* COMMA?</span></span>
<span class="line" id="L3114">    <span class="tok-comment">///      / KEYWORD_else</span></span>
<span class="line" id="L3115">    <span class="tok-kw">fn</span> <span class="tok-fn">parseSwitchProng</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3116">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L3117">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L3118"></span>
<span class="line" id="L3119">        <span class="tok-kw">if</span> (p.eatToken(.keyword_else) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L3120">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3121">                <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> p.parseSwitchItem();</span>
<span class="line" id="L3122">                <span class="tok-kw">if</span> (item == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L3123">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, item);</span>
<span class="line" id="L3124">                <span class="tok-kw">if</span> (p.eatToken(.comma) == <span class="tok-null">null</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L3125">            }</span>
<span class="line" id="L3126">            <span class="tok-kw">if</span> (scratch_top == p.scratch.items.len) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3127">        }</span>
<span class="line" id="L3128">        <span class="tok-kw">const</span> arrow_token = <span class="tok-kw">try</span> p.expectToken(.equal_angle_bracket_right);</span>
<span class="line" id="L3129">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L3130"></span>
<span class="line" id="L3131">        <span class="tok-kw">const</span> items = p.scratch.items[scratch_top..];</span>
<span class="line" id="L3132">        <span class="tok-kw">switch</span> (items.len) {</span>
<span class="line" id="L3133">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3134">                .tag = .switch_case_one,</span>
<span class="line" id="L3135">                .main_token = arrow_token,</span>
<span class="line" id="L3136">                .data = .{</span>
<span class="line" id="L3137">                    .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L3138">                    .rhs = <span class="tok-kw">try</span> p.expectAssignExpr(),</span>
<span class="line" id="L3139">                },</span>
<span class="line" id="L3140">            }),</span>
<span class="line" id="L3141">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3142">                .tag = .switch_case_one,</span>
<span class="line" id="L3143">                .main_token = arrow_token,</span>
<span class="line" id="L3144">                .data = .{</span>
<span class="line" id="L3145">                    .lhs = items[<span class="tok-number">0</span>],</span>
<span class="line" id="L3146">                    .rhs = <span class="tok-kw">try</span> p.expectAssignExpr(),</span>
<span class="line" id="L3147">                },</span>
<span class="line" id="L3148">            }),</span>
<span class="line" id="L3149">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3150">                .tag = .switch_case,</span>
<span class="line" id="L3151">                .main_token = arrow_token,</span>
<span class="line" id="L3152">                .data = .{</span>
<span class="line" id="L3153">                    .lhs = <span class="tok-kw">try</span> p.addExtra(<span class="tok-kw">try</span> p.listToSpan(items)),</span>
<span class="line" id="L3154">                    .rhs = <span class="tok-kw">try</span> p.expectAssignExpr(),</span>
<span class="line" id="L3155">                },</span>
<span class="line" id="L3156">            }),</span>
<span class="line" id="L3157">        }</span>
<span class="line" id="L3158">    }</span>
<span class="line" id="L3159"></span>
<span class="line" id="L3160">    <span class="tok-comment">/// SwitchItem &lt;- Expr (DOT3 Expr)?</span></span>
<span class="line" id="L3161">    <span class="tok-kw">fn</span> <span class="tok-fn">parseSwitchItem</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3162">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.parseExpr();</span>
<span class="line" id="L3163">        <span class="tok-kw">if</span> (expr == <span class="tok-number">0</span>) <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3164"></span>
<span class="line" id="L3165">        <span class="tok-kw">if</span> (p.eatToken(.ellipsis3)) |token| {</span>
<span class="line" id="L3166">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3167">                .tag = .switch_range,</span>
<span class="line" id="L3168">                .main_token = token,</span>
<span class="line" id="L3169">                .data = .{</span>
<span class="line" id="L3170">                    .lhs = expr,</span>
<span class="line" id="L3171">                    .rhs = <span class="tok-kw">try</span> p.expectExpr(),</span>
<span class="line" id="L3172">                },</span>
<span class="line" id="L3173">            });</span>
<span class="line" id="L3174">        }</span>
<span class="line" id="L3175">        <span class="tok-kw">return</span> expr;</span>
<span class="line" id="L3176">    }</span>
<span class="line" id="L3177"></span>
<span class="line" id="L3178">    <span class="tok-kw">const</span> PtrModifiers = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L3179">        align_node: Node.Index,</span>
<span class="line" id="L3180">        addrspace_node: Node.Index,</span>
<span class="line" id="L3181">        bit_range_start: Node.Index,</span>
<span class="line" id="L3182">        bit_range_end: Node.Index,</span>
<span class="line" id="L3183">    };</span>
<span class="line" id="L3184"></span>
<span class="line" id="L3185">    <span class="tok-kw">fn</span> <span class="tok-fn">parsePtrModifiers</span>(p: *Parser) !PtrModifiers {</span>
<span class="line" id="L3186">        <span class="tok-kw">var</span> result: PtrModifiers = .{</span>
<span class="line" id="L3187">            .align_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L3188">            .addrspace_node = <span class="tok-number">0</span>,</span>
<span class="line" id="L3189">            .bit_range_start = <span class="tok-number">0</span>,</span>
<span class="line" id="L3190">            .bit_range_end = <span class="tok-number">0</span>,</span>
<span class="line" id="L3191">        };</span>
<span class="line" id="L3192">        <span class="tok-kw">var</span> saw_const = <span class="tok-null">false</span>;</span>
<span class="line" id="L3193">        <span class="tok-kw">var</span> saw_volatile = <span class="tok-null">false</span>;</span>
<span class="line" id="L3194">        <span class="tok-kw">var</span> saw_allowzero = <span class="tok-null">false</span>;</span>
<span class="line" id="L3195">        <span class="tok-kw">var</span> saw_addrspace = <span class="tok-null">false</span>;</span>
<span class="line" id="L3196">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3197">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3198">                .keyword_align =&gt; {</span>
<span class="line" id="L3199">                    <span class="tok-kw">if</span> (result.align_node != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3200">                        <span class="tok-kw">try</span> p.warn(.extra_align_qualifier);</span>
<span class="line" id="L3201">                    }</span>
<span class="line" id="L3202">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3203">                    _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3204">                    result.align_node = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3205"></span>
<span class="line" id="L3206">                    <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L3207">                        result.bit_range_start = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3208">                        _ = <span class="tok-kw">try</span> p.expectToken(.colon);</span>
<span class="line" id="L3209">                        result.bit_range_end = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3210">                    }</span>
<span class="line" id="L3211"></span>
<span class="line" id="L3212">                    _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3213">                },</span>
<span class="line" id="L3214">                .keyword_const =&gt; {</span>
<span class="line" id="L3215">                    <span class="tok-kw">if</span> (saw_const) {</span>
<span class="line" id="L3216">                        <span class="tok-kw">try</span> p.warn(.extra_const_qualifier);</span>
<span class="line" id="L3217">                    }</span>
<span class="line" id="L3218">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3219">                    saw_const = <span class="tok-null">true</span>;</span>
<span class="line" id="L3220">                },</span>
<span class="line" id="L3221">                .keyword_volatile =&gt; {</span>
<span class="line" id="L3222">                    <span class="tok-kw">if</span> (saw_volatile) {</span>
<span class="line" id="L3223">                        <span class="tok-kw">try</span> p.warn(.extra_volatile_qualifier);</span>
<span class="line" id="L3224">                    }</span>
<span class="line" id="L3225">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3226">                    saw_volatile = <span class="tok-null">true</span>;</span>
<span class="line" id="L3227">                },</span>
<span class="line" id="L3228">                .keyword_allowzero =&gt; {</span>
<span class="line" id="L3229">                    <span class="tok-kw">if</span> (saw_allowzero) {</span>
<span class="line" id="L3230">                        <span class="tok-kw">try</span> p.warn(.extra_allowzero_qualifier);</span>
<span class="line" id="L3231">                    }</span>
<span class="line" id="L3232">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3233">                    saw_allowzero = <span class="tok-null">true</span>;</span>
<span class="line" id="L3234">                },</span>
<span class="line" id="L3235">                .keyword_addrspace =&gt; {</span>
<span class="line" id="L3236">                    <span class="tok-kw">if</span> (saw_addrspace) {</span>
<span class="line" id="L3237">                        <span class="tok-kw">try</span> p.warn(.extra_addrspace_qualifier);</span>
<span class="line" id="L3238">                    }</span>
<span class="line" id="L3239">                    result.addrspace_node = <span class="tok-kw">try</span> p.parseAddrSpace();</span>
<span class="line" id="L3240">                },</span>
<span class="line" id="L3241">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L3242">            }</span>
<span class="line" id="L3243">        }</span>
<span class="line" id="L3244">    }</span>
<span class="line" id="L3245"></span>
<span class="line" id="L3246">    <span class="tok-comment">/// SuffixOp</span></span>
<span class="line" id="L3247">    <span class="tok-comment">///     &lt;- LBRACKET Expr (DOT2 (Expr? (COLON Expr)?)?)? RBRACKET</span></span>
<span class="line" id="L3248">    <span class="tok-comment">///      / DOT IDENTIFIER</span></span>
<span class="line" id="L3249">    <span class="tok-comment">///      / DOTASTERISK</span></span>
<span class="line" id="L3250">    <span class="tok-comment">///      / DOTQUESTIONMARK</span></span>
<span class="line" id="L3251">    <span class="tok-kw">fn</span> <span class="tok-fn">parseSuffixOp</span>(p: *Parser, lhs: Node.Index) !Node.Index {</span>
<span class="line" id="L3252">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3253">            .l_bracket =&gt; {</span>
<span class="line" id="L3254">                <span class="tok-kw">const</span> lbracket = p.nextToken();</span>
<span class="line" id="L3255">                <span class="tok-kw">const</span> index_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3256"></span>
<span class="line" id="L3257">                <span class="tok-kw">if</span> (p.eatToken(.ellipsis2)) |_| {</span>
<span class="line" id="L3258">                    <span class="tok-kw">const</span> end_expr = <span class="tok-kw">try</span> p.parseExpr();</span>
<span class="line" id="L3259">                    <span class="tok-kw">if</span> (p.eatToken(.colon)) |_| {</span>
<span class="line" id="L3260">                        <span class="tok-kw">const</span> sentinel = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3261">                        _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L3262">                        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3263">                            .tag = .slice_sentinel,</span>
<span class="line" id="L3264">                            .main_token = lbracket,</span>
<span class="line" id="L3265">                            .data = .{</span>
<span class="line" id="L3266">                                .lhs = lhs,</span>
<span class="line" id="L3267">                                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.SliceSentinel{</span>
<span class="line" id="L3268">                                    .start = index_expr,</span>
<span class="line" id="L3269">                                    .end = end_expr,</span>
<span class="line" id="L3270">                                    .sentinel = sentinel,</span>
<span class="line" id="L3271">                                }),</span>
<span class="line" id="L3272">                            },</span>
<span class="line" id="L3273">                        });</span>
<span class="line" id="L3274">                    }</span>
<span class="line" id="L3275">                    _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L3276">                    <span class="tok-kw">if</span> (end_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3277">                        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3278">                            .tag = .slice_open,</span>
<span class="line" id="L3279">                            .main_token = lbracket,</span>
<span class="line" id="L3280">                            .data = .{</span>
<span class="line" id="L3281">                                .lhs = lhs,</span>
<span class="line" id="L3282">                                .rhs = index_expr,</span>
<span class="line" id="L3283">                            },</span>
<span class="line" id="L3284">                        });</span>
<span class="line" id="L3285">                    }</span>
<span class="line" id="L3286">                    <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3287">                        .tag = .slice,</span>
<span class="line" id="L3288">                        .main_token = lbracket,</span>
<span class="line" id="L3289">                        .data = .{</span>
<span class="line" id="L3290">                            .lhs = lhs,</span>
<span class="line" id="L3291">                            .rhs = <span class="tok-kw">try</span> p.addExtra(Node.Slice{</span>
<span class="line" id="L3292">                                .start = index_expr,</span>
<span class="line" id="L3293">                                .end = end_expr,</span>
<span class="line" id="L3294">                            }),</span>
<span class="line" id="L3295">                        },</span>
<span class="line" id="L3296">                    });</span>
<span class="line" id="L3297">                }</span>
<span class="line" id="L3298">                _ = <span class="tok-kw">try</span> p.expectToken(.r_bracket);</span>
<span class="line" id="L3299">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3300">                    .tag = .array_access,</span>
<span class="line" id="L3301">                    .main_token = lbracket,</span>
<span class="line" id="L3302">                    .data = .{</span>
<span class="line" id="L3303">                        .lhs = lhs,</span>
<span class="line" id="L3304">                        .rhs = index_expr,</span>
<span class="line" id="L3305">                    },</span>
<span class="line" id="L3306">                });</span>
<span class="line" id="L3307">            },</span>
<span class="line" id="L3308">            .period_asterisk =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3309">                .tag = .deref,</span>
<span class="line" id="L3310">                .main_token = p.nextToken(),</span>
<span class="line" id="L3311">                .data = .{</span>
<span class="line" id="L3312">                    .lhs = lhs,</span>
<span class="line" id="L3313">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L3314">                },</span>
<span class="line" id="L3315">            }),</span>
<span class="line" id="L3316">            .invalid_periodasterisks =&gt; {</span>
<span class="line" id="L3317">                <span class="tok-kw">try</span> p.warn(.asterisk_after_ptr_deref);</span>
<span class="line" id="L3318">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3319">                    .tag = .deref,</span>
<span class="line" id="L3320">                    .main_token = p.nextToken(),</span>
<span class="line" id="L3321">                    .data = .{</span>
<span class="line" id="L3322">                        .lhs = lhs,</span>
<span class="line" id="L3323">                        .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L3324">                    },</span>
<span class="line" id="L3325">                });</span>
<span class="line" id="L3326">            },</span>
<span class="line" id="L3327">            .period =&gt; <span class="tok-kw">switch</span> (p.token_tags[p.tok_i + <span class="tok-number">1</span>]) {</span>
<span class="line" id="L3328">                .identifier =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3329">                    .tag = .field_access,</span>
<span class="line" id="L3330">                    .main_token = p.nextToken(),</span>
<span class="line" id="L3331">                    .data = .{</span>
<span class="line" id="L3332">                        .lhs = lhs,</span>
<span class="line" id="L3333">                        .rhs = p.nextToken(),</span>
<span class="line" id="L3334">                    },</span>
<span class="line" id="L3335">                }),</span>
<span class="line" id="L3336">                .question_mark =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3337">                    .tag = .unwrap_optional,</span>
<span class="line" id="L3338">                    .main_token = p.nextToken(),</span>
<span class="line" id="L3339">                    .data = .{</span>
<span class="line" id="L3340">                        .lhs = lhs,</span>
<span class="line" id="L3341">                        .rhs = p.nextToken(),</span>
<span class="line" id="L3342">                    },</span>
<span class="line" id="L3343">                }),</span>
<span class="line" id="L3344">                .l_brace =&gt; {</span>
<span class="line" id="L3345">                    <span class="tok-comment">// this a misplaced `.{`, handle the error somewhere else</span>
</span>
<span class="line" id="L3346">                    <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3347">                },</span>
<span class="line" id="L3348">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L3349">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3350">                    <span class="tok-kw">try</span> p.warn(.expected_suffix_op);</span>
<span class="line" id="L3351">                    <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3352">                },</span>
<span class="line" id="L3353">            },</span>
<span class="line" id="L3354">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> null_node,</span>
<span class="line" id="L3355">        }</span>
<span class="line" id="L3356">    }</span>
<span class="line" id="L3357"></span>
<span class="line" id="L3358">    <span class="tok-comment">/// Caller must have already verified the first token.</span></span>
<span class="line" id="L3359">    <span class="tok-comment">/// ContainerDeclAuto &lt;- ContainerDeclType LBRACE container_doc_comment? ContainerMembers RBRACE</span></span>
<span class="line" id="L3360">    <span class="tok-comment">///</span></span>
<span class="line" id="L3361">    <span class="tok-comment">/// ContainerDeclType</span></span>
<span class="line" id="L3362">    <span class="tok-comment">///     &lt;- KEYWORD_struct (LPAREN Expr RPAREN)?</span></span>
<span class="line" id="L3363">    <span class="tok-comment">///      / KEYWORD_opaque</span></span>
<span class="line" id="L3364">    <span class="tok-comment">///      / KEYWORD_enum (LPAREN Expr RPAREN)?</span></span>
<span class="line" id="L3365">    <span class="tok-comment">///      / KEYWORD_union (LPAREN (KEYWORD_enum (LPAREN Expr RPAREN)? / Expr) RPAREN)?</span></span>
<span class="line" id="L3366">    <span class="tok-kw">fn</span> <span class="tok-fn">parseContainerDeclAuto</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3367">        <span class="tok-kw">const</span> main_token = p.nextToken();</span>
<span class="line" id="L3368">        <span class="tok-kw">const</span> arg_expr = <span class="tok-kw">switch</span> (p.token_tags[main_token]) {</span>
<span class="line" id="L3369">            .keyword_opaque =&gt; null_node,</span>
<span class="line" id="L3370">            .keyword_struct, .keyword_enum =&gt; blk: {</span>
<span class="line" id="L3371">                <span class="tok-kw">if</span> (p.eatToken(.l_paren)) |_| {</span>
<span class="line" id="L3372">                    <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3373">                    _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3374">                    <span class="tok-kw">break</span> :blk expr;</span>
<span class="line" id="L3375">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3376">                    <span class="tok-kw">break</span> :blk null_node;</span>
<span class="line" id="L3377">                }</span>
<span class="line" id="L3378">            },</span>
<span class="line" id="L3379">            .keyword_union =&gt; blk: {</span>
<span class="line" id="L3380">                <span class="tok-kw">if</span> (p.eatToken(.l_paren)) |_| {</span>
<span class="line" id="L3381">                    <span class="tok-kw">if</span> (p.eatToken(.keyword_enum)) |_| {</span>
<span class="line" id="L3382">                        <span class="tok-kw">if</span> (p.eatToken(.l_paren)) |_| {</span>
<span class="line" id="L3383">                            <span class="tok-kw">const</span> enum_tag_expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3384">                            _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3385">                            _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3386"></span>
<span class="line" id="L3387">                            _ = <span class="tok-kw">try</span> p.expectToken(.l_brace);</span>
<span class="line" id="L3388">                            <span class="tok-kw">const</span> members = <span class="tok-kw">try</span> p.parseContainerMembers();</span>
<span class="line" id="L3389">                            <span class="tok-kw">const</span> members_span = <span class="tok-kw">try</span> members.toSpan(p);</span>
<span class="line" id="L3390">                            _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L3391">                            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3392">                                .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3393">                                    <span class="tok-null">true</span> =&gt; .tagged_union_enum_tag_trailing,</span>
<span class="line" id="L3394">                                    <span class="tok-null">false</span> =&gt; .tagged_union_enum_tag,</span>
<span class="line" id="L3395">                                },</span>
<span class="line" id="L3396">                                .main_token = main_token,</span>
<span class="line" id="L3397">                                .data = .{</span>
<span class="line" id="L3398">                                    .lhs = enum_tag_expr,</span>
<span class="line" id="L3399">                                    .rhs = <span class="tok-kw">try</span> p.addExtra(members_span),</span>
<span class="line" id="L3400">                                },</span>
<span class="line" id="L3401">                            });</span>
<span class="line" id="L3402">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3403">                            _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3404"></span>
<span class="line" id="L3405">                            _ = <span class="tok-kw">try</span> p.expectToken(.l_brace);</span>
<span class="line" id="L3406">                            <span class="tok-kw">const</span> members = <span class="tok-kw">try</span> p.parseContainerMembers();</span>
<span class="line" id="L3407">                            _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L3408">                            <span class="tok-kw">if</span> (members.len &lt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L3409">                                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3410">                                    .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3411">                                        <span class="tok-null">true</span> =&gt; .tagged_union_two_trailing,</span>
<span class="line" id="L3412">                                        <span class="tok-null">false</span> =&gt; .tagged_union_two,</span>
<span class="line" id="L3413">                                    },</span>
<span class="line" id="L3414">                                    .main_token = main_token,</span>
<span class="line" id="L3415">                                    .data = .{</span>
<span class="line" id="L3416">                                        .lhs = members.lhs,</span>
<span class="line" id="L3417">                                        .rhs = members.rhs,</span>
<span class="line" id="L3418">                                    },</span>
<span class="line" id="L3419">                                });</span>
<span class="line" id="L3420">                            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3421">                                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> members.toSpan(p);</span>
<span class="line" id="L3422">                                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3423">                                    .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3424">                                        <span class="tok-null">true</span> =&gt; .tagged_union_trailing,</span>
<span class="line" id="L3425">                                        <span class="tok-null">false</span> =&gt; .tagged_union,</span>
<span class="line" id="L3426">                                    },</span>
<span class="line" id="L3427">                                    .main_token = main_token,</span>
<span class="line" id="L3428">                                    .data = .{</span>
<span class="line" id="L3429">                                        .lhs = span.start,</span>
<span class="line" id="L3430">                                        .rhs = span.end,</span>
<span class="line" id="L3431">                                    },</span>
<span class="line" id="L3432">                                });</span>
<span class="line" id="L3433">                            }</span>
<span class="line" id="L3434">                        }</span>
<span class="line" id="L3435">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3436">                        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3437">                        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3438">                        <span class="tok-kw">break</span> :blk expr;</span>
<span class="line" id="L3439">                    }</span>
<span class="line" id="L3440">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3441">                    <span class="tok-kw">break</span> :blk null_node;</span>
<span class="line" id="L3442">                }</span>
<span class="line" id="L3443">            },</span>
<span class="line" id="L3444">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L3445">                p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L3446">                <span class="tok-kw">return</span> p.fail(.expected_container);</span>
<span class="line" id="L3447">            },</span>
<span class="line" id="L3448">        };</span>
<span class="line" id="L3449">        _ = <span class="tok-kw">try</span> p.expectToken(.l_brace);</span>
<span class="line" id="L3450">        <span class="tok-kw">const</span> members = <span class="tok-kw">try</span> p.parseContainerMembers();</span>
<span class="line" id="L3451">        _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L3452">        <span class="tok-kw">if</span> (arg_expr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L3453">            <span class="tok-kw">if</span> (members.len &lt;= <span class="tok-number">2</span>) {</span>
<span class="line" id="L3454">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3455">                    .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3456">                        <span class="tok-null">true</span> =&gt; .container_decl_two_trailing,</span>
<span class="line" id="L3457">                        <span class="tok-null">false</span> =&gt; .container_decl_two,</span>
<span class="line" id="L3458">                    },</span>
<span class="line" id="L3459">                    .main_token = main_token,</span>
<span class="line" id="L3460">                    .data = .{</span>
<span class="line" id="L3461">                        .lhs = members.lhs,</span>
<span class="line" id="L3462">                        .rhs = members.rhs,</span>
<span class="line" id="L3463">                    },</span>
<span class="line" id="L3464">                });</span>
<span class="line" id="L3465">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3466">                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> members.toSpan(p);</span>
<span class="line" id="L3467">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3468">                    .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3469">                        <span class="tok-null">true</span> =&gt; .container_decl_trailing,</span>
<span class="line" id="L3470">                        <span class="tok-null">false</span> =&gt; .container_decl,</span>
<span class="line" id="L3471">                    },</span>
<span class="line" id="L3472">                    .main_token = main_token,</span>
<span class="line" id="L3473">                    .data = .{</span>
<span class="line" id="L3474">                        .lhs = span.start,</span>
<span class="line" id="L3475">                        .rhs = span.end,</span>
<span class="line" id="L3476">                    },</span>
<span class="line" id="L3477">                });</span>
<span class="line" id="L3478">            }</span>
<span class="line" id="L3479">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L3480">            <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> members.toSpan(p);</span>
<span class="line" id="L3481">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3482">                .tag = <span class="tok-kw">switch</span> (members.trailing) {</span>
<span class="line" id="L3483">                    <span class="tok-null">true</span> =&gt; .container_decl_arg_trailing,</span>
<span class="line" id="L3484">                    <span class="tok-null">false</span> =&gt; .container_decl_arg,</span>
<span class="line" id="L3485">                },</span>
<span class="line" id="L3486">                .main_token = main_token,</span>
<span class="line" id="L3487">                .data = .{</span>
<span class="line" id="L3488">                    .lhs = arg_expr,</span>
<span class="line" id="L3489">                    .rhs = <span class="tok-kw">try</span> p.addExtra(Node.SubRange{</span>
<span class="line" id="L3490">                        .start = span.start,</span>
<span class="line" id="L3491">                        .end = span.end,</span>
<span class="line" id="L3492">                    }),</span>
<span class="line" id="L3493">                },</span>
<span class="line" id="L3494">            });</span>
<span class="line" id="L3495">        }</span>
<span class="line" id="L3496">    }</span>
<span class="line" id="L3497"></span>
<span class="line" id="L3498">    <span class="tok-comment">/// Give a helpful error message for those transitioning from</span></span>
<span class="line" id="L3499">    <span class="tok-comment">/// C's 'struct Foo {};' to Zig's 'const Foo = struct {};'.</span></span>
<span class="line" id="L3500">    <span class="tok-kw">fn</span> <span class="tok-fn">parseCStyleContainer</span>(p: *Parser) Error!<span class="tok-type">bool</span> {</span>
<span class="line" id="L3501">        <span class="tok-kw">const</span> main_token = p.tok_i;</span>
<span class="line" id="L3502">        <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3503">            .keyword_enum, .keyword_union, .keyword_struct =&gt; {},</span>
<span class="line" id="L3504">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L3505">        }</span>
<span class="line" id="L3506">        <span class="tok-kw">const</span> identifier = p.tok_i + <span class="tok-number">1</span>;</span>
<span class="line" id="L3507">        <span class="tok-kw">if</span> (p.token_tags[identifier] != .identifier) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L3508">        p.tok_i += <span class="tok-number">2</span>;</span>
<span class="line" id="L3509"></span>
<span class="line" id="L3510">        <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L3511">            .tag = .c_style_container,</span>
<span class="line" id="L3512">            .token = identifier,</span>
<span class="line" id="L3513">            .extra = .{ .expected_tag = p.token_tags[main_token] },</span>
<span class="line" id="L3514">        });</span>
<span class="line" id="L3515">        <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L3516">            .tag = .zig_style_container,</span>
<span class="line" id="L3517">            .is_note = <span class="tok-null">true</span>,</span>
<span class="line" id="L3518">            .token = identifier,</span>
<span class="line" id="L3519">            .extra = .{ .expected_tag = p.token_tags[main_token] },</span>
<span class="line" id="L3520">        });</span>
<span class="line" id="L3521"></span>
<span class="line" id="L3522">        _ = <span class="tok-kw">try</span> p.expectToken(.l_brace);</span>
<span class="line" id="L3523">        _ = <span class="tok-kw">try</span> p.parseContainerMembers();</span>
<span class="line" id="L3524">        _ = <span class="tok-kw">try</span> p.expectToken(.r_brace);</span>
<span class="line" id="L3525">        <span class="tok-kw">try</span> p.expectSemicolon(.expected_semi_after_decl, <span class="tok-null">true</span>);</span>
<span class="line" id="L3526">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L3527">    }</span>
<span class="line" id="L3528"></span>
<span class="line" id="L3529">    <span class="tok-comment">/// Holds temporary data until we are ready to construct the full ContainerDecl AST node.</span></span>
<span class="line" id="L3530">    <span class="tok-comment">/// ByteAlign &lt;- KEYWORD_align LPAREN Expr RPAREN</span></span>
<span class="line" id="L3531">    <span class="tok-kw">fn</span> <span class="tok-fn">parseByteAlign</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3532">        _ = p.eatToken(.keyword_align) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3533">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3534">        <span class="tok-kw">const</span> expr = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3535">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3536">        <span class="tok-kw">return</span> expr;</span>
<span class="line" id="L3537">    }</span>
<span class="line" id="L3538"></span>
<span class="line" id="L3539">    <span class="tok-comment">/// SwitchProngList &lt;- (SwitchProng COMMA)* SwitchProng?</span></span>
<span class="line" id="L3540">    <span class="tok-kw">fn</span> <span class="tok-fn">parseSwitchProngList</span>(p: *Parser) !Node.SubRange {</span>
<span class="line" id="L3541">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L3542">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L3543"></span>
<span class="line" id="L3544">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3545">            <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> parseSwitchProng(p);</span>
<span class="line" id="L3546">            <span class="tok-kw">if</span> (item == <span class="tok-number">0</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L3547"></span>
<span class="line" id="L3548">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, item);</span>
<span class="line" id="L3549"></span>
<span class="line" id="L3550">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3551">                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L3552">                <span class="tok-comment">// All possible delimiters.</span>
</span>
<span class="line" id="L3553">                .colon, .r_paren, .r_brace, .r_bracket =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L3554">                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L3555">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_switch_prong),</span>
<span class="line" id="L3556">            }</span>
<span class="line" id="L3557">        }</span>
<span class="line" id="L3558">        <span class="tok-kw">return</span> p.listToSpan(p.scratch.items[scratch_top..]);</span>
<span class="line" id="L3559">    }</span>
<span class="line" id="L3560"></span>
<span class="line" id="L3561">    <span class="tok-comment">/// ParamDeclList &lt;- (ParamDecl COMMA)* ParamDecl?</span></span>
<span class="line" id="L3562">    <span class="tok-kw">fn</span> <span class="tok-fn">parseParamDeclList</span>(p: *Parser) !SmallSpan {</span>
<span class="line" id="L3563">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3564">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L3565">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L3566">        <span class="tok-kw">var</span> varargs: <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) { none, seen, nonfinal: TokenIndex } = .none;</span>
<span class="line" id="L3567">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3568">            <span class="tok-kw">if</span> (p.eatToken(.r_paren)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L3569">            <span class="tok-kw">if</span> (varargs == .seen) varargs = .{ .nonfinal = p.tok_i };</span>
<span class="line" id="L3570">            <span class="tok-kw">const</span> param = <span class="tok-kw">try</span> p.expectParamDecl();</span>
<span class="line" id="L3571">            <span class="tok-kw">if</span> (param != <span class="tok-number">0</span>) {</span>
<span class="line" id="L3572">                <span class="tok-kw">try</span> p.scratch.append(p.gpa, param);</span>
<span class="line" id="L3573">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (p.token_tags[p.tok_i - <span class="tok-number">1</span>] == .ellipsis3) {</span>
<span class="line" id="L3574">                <span class="tok-kw">if</span> (varargs == .none) varargs = .seen;</span>
<span class="line" id="L3575">            }</span>
<span class="line" id="L3576">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3577">                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L3578">                .r_paren =&gt; {</span>
<span class="line" id="L3579">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3580">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L3581">                },</span>
<span class="line" id="L3582">                .colon, .r_brace, .r_bracket =&gt; <span class="tok-kw">return</span> p.failExpected(.r_paren),</span>
<span class="line" id="L3583">                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L3584">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_param),</span>
<span class="line" id="L3585">            }</span>
<span class="line" id="L3586">        }</span>
<span class="line" id="L3587">        <span class="tok-kw">if</span> (varargs == .nonfinal) {</span>
<span class="line" id="L3588">            <span class="tok-kw">try</span> p.warnMsg(.{ .tag = .varargs_nonfinal, .token = varargs.nonfinal });</span>
<span class="line" id="L3589">        }</span>
<span class="line" id="L3590">        <span class="tok-kw">const</span> params = p.scratch.items[scratch_top..];</span>
<span class="line" id="L3591">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (params.len) {</span>
<span class="line" id="L3592">            <span class="tok-number">0</span> =&gt; SmallSpan{ .zero_or_one = <span class="tok-number">0</span> },</span>
<span class="line" id="L3593">            <span class="tok-number">1</span> =&gt; SmallSpan{ .zero_or_one = params[<span class="tok-number">0</span>] },</span>
<span class="line" id="L3594">            <span class="tok-kw">else</span> =&gt; SmallSpan{ .multi = <span class="tok-kw">try</span> p.listToSpan(params) },</span>
<span class="line" id="L3595">        };</span>
<span class="line" id="L3596">    }</span>
<span class="line" id="L3597"></span>
<span class="line" id="L3598">    <span class="tok-comment">/// FnCallArguments &lt;- LPAREN ExprList RPAREN</span></span>
<span class="line" id="L3599">    <span class="tok-comment">/// ExprList &lt;- (Expr COMMA)* Expr?</span></span>
<span class="line" id="L3600">    <span class="tok-kw">fn</span> <span class="tok-fn">parseBuiltinCall</span>(p: *Parser) !Node.Index {</span>
<span class="line" id="L3601">        <span class="tok-kw">const</span> builtin_token = p.assertToken(.builtin);</span>
<span class="line" id="L3602">        <span class="tok-kw">if</span> (p.token_tags[p.nextToken()] != .l_paren) {</span>
<span class="line" id="L3603">            p.tok_i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L3604">            <span class="tok-kw">try</span> p.warn(.expected_param_list);</span>
<span class="line" id="L3605">            <span class="tok-comment">// Pretend this was an identifier so we can continue parsing.</span>
</span>
<span class="line" id="L3606">            <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3607">                .tag = .identifier,</span>
<span class="line" id="L3608">                .main_token = builtin_token,</span>
<span class="line" id="L3609">                .data = .{</span>
<span class="line" id="L3610">                    .lhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L3611">                    .rhs = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L3612">                },</span>
<span class="line" id="L3613">            });</span>
<span class="line" id="L3614">        }</span>
<span class="line" id="L3615">        <span class="tok-kw">const</span> scratch_top = p.scratch.items.len;</span>
<span class="line" id="L3616">        <span class="tok-kw">defer</span> p.scratch.shrinkRetainingCapacity(scratch_top);</span>
<span class="line" id="L3617">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L3618">            <span class="tok-kw">if</span> (p.eatToken(.r_paren)) |_| <span class="tok-kw">break</span>;</span>
<span class="line" id="L3619">            <span class="tok-kw">const</span> param = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3620">            <span class="tok-kw">try</span> p.scratch.append(p.gpa, param);</span>
<span class="line" id="L3621">            <span class="tok-kw">switch</span> (p.token_tags[p.tok_i]) {</span>
<span class="line" id="L3622">                .comma =&gt; p.tok_i += <span class="tok-number">1</span>,</span>
<span class="line" id="L3623">                .r_paren =&gt; {</span>
<span class="line" id="L3624">                    p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3625">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L3626">                },</span>
<span class="line" id="L3627">                <span class="tok-comment">// Likely just a missing comma; give error but continue parsing.</span>
</span>
<span class="line" id="L3628">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">try</span> p.warn(.expected_comma_after_arg),</span>
<span class="line" id="L3629">            }</span>
<span class="line" id="L3630">        }</span>
<span class="line" id="L3631">        <span class="tok-kw">const</span> comma = (p.token_tags[p.tok_i - <span class="tok-number">2</span>] == .comma);</span>
<span class="line" id="L3632">        <span class="tok-kw">const</span> params = p.scratch.items[scratch_top..];</span>
<span class="line" id="L3633">        <span class="tok-kw">switch</span> (params.len) {</span>
<span class="line" id="L3634">            <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3635">                .tag = .builtin_call_two,</span>
<span class="line" id="L3636">                .main_token = builtin_token,</span>
<span class="line" id="L3637">                .data = .{</span>
<span class="line" id="L3638">                    .lhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L3639">                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L3640">                },</span>
<span class="line" id="L3641">            }),</span>
<span class="line" id="L3642">            <span class="tok-number">1</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3643">                .tag = <span class="tok-kw">if</span> (comma) .builtin_call_two_comma <span class="tok-kw">else</span> .builtin_call_two,</span>
<span class="line" id="L3644">                .main_token = builtin_token,</span>
<span class="line" id="L3645">                .data = .{</span>
<span class="line" id="L3646">                    .lhs = params[<span class="tok-number">0</span>],</span>
<span class="line" id="L3647">                    .rhs = <span class="tok-number">0</span>,</span>
<span class="line" id="L3648">                },</span>
<span class="line" id="L3649">            }),</span>
<span class="line" id="L3650">            <span class="tok-number">2</span> =&gt; <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3651">                .tag = <span class="tok-kw">if</span> (comma) .builtin_call_two_comma <span class="tok-kw">else</span> .builtin_call_two,</span>
<span class="line" id="L3652">                .main_token = builtin_token,</span>
<span class="line" id="L3653">                .data = .{</span>
<span class="line" id="L3654">                    .lhs = params[<span class="tok-number">0</span>],</span>
<span class="line" id="L3655">                    .rhs = params[<span class="tok-number">1</span>],</span>
<span class="line" id="L3656">                },</span>
<span class="line" id="L3657">            }),</span>
<span class="line" id="L3658">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L3659">                <span class="tok-kw">const</span> span = <span class="tok-kw">try</span> p.listToSpan(params);</span>
<span class="line" id="L3660">                <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3661">                    .tag = <span class="tok-kw">if</span> (comma) .builtin_call_comma <span class="tok-kw">else</span> .builtin_call,</span>
<span class="line" id="L3662">                    .main_token = builtin_token,</span>
<span class="line" id="L3663">                    .data = .{</span>
<span class="line" id="L3664">                        .lhs = span.start,</span>
<span class="line" id="L3665">                        .rhs = span.end,</span>
<span class="line" id="L3666">                    },</span>
<span class="line" id="L3667">                });</span>
<span class="line" id="L3668">            },</span>
<span class="line" id="L3669">        }</span>
<span class="line" id="L3670">    }</span>
<span class="line" id="L3671"></span>
<span class="line" id="L3672">    <span class="tok-comment">/// KEYWORD_if LPAREN Expr RPAREN PtrPayload? Body (KEYWORD_else Payload? Body)?</span></span>
<span class="line" id="L3673">    <span class="tok-kw">fn</span> <span class="tok-fn">parseIf</span>(p: *Parser, bodyParseFn: <span class="tok-kw">fn</span> (p: *Parser) Error!Node.Index) !Node.Index {</span>
<span class="line" id="L3674">        <span class="tok-kw">const</span> if_token = p.eatToken(.keyword_if) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> null_node;</span>
<span class="line" id="L3675">        _ = <span class="tok-kw">try</span> p.expectToken(.l_paren);</span>
<span class="line" id="L3676">        <span class="tok-kw">const</span> condition = <span class="tok-kw">try</span> p.expectExpr();</span>
<span class="line" id="L3677">        _ = <span class="tok-kw">try</span> p.expectToken(.r_paren);</span>
<span class="line" id="L3678">        _ = <span class="tok-kw">try</span> p.parsePtrPayload();</span>
<span class="line" id="L3679"></span>
<span class="line" id="L3680">        <span class="tok-kw">const</span> then_expr = <span class="tok-kw">try</span> bodyParseFn(p);</span>
<span class="line" id="L3681">        assert(then_expr != <span class="tok-number">0</span>);</span>
<span class="line" id="L3682"></span>
<span class="line" id="L3683">        _ = p.eatToken(.keyword_else) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3684">            .tag = .if_simple,</span>
<span class="line" id="L3685">            .main_token = if_token,</span>
<span class="line" id="L3686">            .data = .{</span>
<span class="line" id="L3687">                .lhs = condition,</span>
<span class="line" id="L3688">                .rhs = then_expr,</span>
<span class="line" id="L3689">            },</span>
<span class="line" id="L3690">        });</span>
<span class="line" id="L3691">        _ = <span class="tok-kw">try</span> p.parsePayload();</span>
<span class="line" id="L3692">        <span class="tok-kw">const</span> else_expr = <span class="tok-kw">try</span> bodyParseFn(p);</span>
<span class="line" id="L3693">        assert(then_expr != <span class="tok-number">0</span>);</span>
<span class="line" id="L3694"></span>
<span class="line" id="L3695">        <span class="tok-kw">return</span> p.addNode(.{</span>
<span class="line" id="L3696">            .tag = .@&quot;if&quot;,</span>
<span class="line" id="L3697">            .main_token = if_token,</span>
<span class="line" id="L3698">            .data = .{</span>
<span class="line" id="L3699">                .lhs = condition,</span>
<span class="line" id="L3700">                .rhs = <span class="tok-kw">try</span> p.addExtra(Node.If{</span>
<span class="line" id="L3701">                    .then_expr = then_expr,</span>
<span class="line" id="L3702">                    .else_expr = else_expr,</span>
<span class="line" id="L3703">                }),</span>
<span class="line" id="L3704">            },</span>
<span class="line" id="L3705">        });</span>
<span class="line" id="L3706">    }</span>
<span class="line" id="L3707"></span>
<span class="line" id="L3708">    <span class="tok-comment">/// Skips over doc comment tokens. Returns the first one, if any.</span></span>
<span class="line" id="L3709">    <span class="tok-kw">fn</span> <span class="tok-fn">eatDocComments</span>(p: *Parser) !?TokenIndex {</span>
<span class="line" id="L3710">        <span class="tok-kw">if</span> (p.eatToken(.doc_comment)) |tok| {</span>
<span class="line" id="L3711">            <span class="tok-kw">var</span> first_line = tok;</span>
<span class="line" id="L3712">            <span class="tok-kw">if</span> (tok &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> tokensOnSameLine(p, tok - <span class="tok-number">1</span>, tok)) {</span>
<span class="line" id="L3713">                <span class="tok-kw">try</span> p.warnMsg(.{</span>
<span class="line" id="L3714">                    .tag = .same_line_doc_comment,</span>
<span class="line" id="L3715">                    .token = tok,</span>
<span class="line" id="L3716">                });</span>
<span class="line" id="L3717">                first_line = p.eatToken(.doc_comment) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3718">            }</span>
<span class="line" id="L3719">            <span class="tok-kw">while</span> (p.eatToken(.doc_comment)) |_| {}</span>
<span class="line" id="L3720">            <span class="tok-kw">return</span> first_line;</span>
<span class="line" id="L3721">        }</span>
<span class="line" id="L3722">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3723">    }</span>
<span class="line" id="L3724"></span>
<span class="line" id="L3725">    <span class="tok-kw">fn</span> <span class="tok-fn">tokensOnSameLine</span>(p: *Parser, token1: TokenIndex, token2: TokenIndex) <span class="tok-type">bool</span> {</span>
<span class="line" id="L3726">        <span class="tok-kw">return</span> std.mem.indexOfScalar(<span class="tok-type">u8</span>, p.source[p.token_starts[token1]..p.token_starts[token2]], <span class="tok-str">'\n'</span>) == <span class="tok-null">null</span>;</span>
<span class="line" id="L3727">    }</span>
<span class="line" id="L3728"></span>
<span class="line" id="L3729">    <span class="tok-kw">fn</span> <span class="tok-fn">eatToken</span>(p: *Parser, tag: Token.Tag) ?TokenIndex {</span>
<span class="line" id="L3730">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == tag) p.nextToken() <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L3731">    }</span>
<span class="line" id="L3732"></span>
<span class="line" id="L3733">    <span class="tok-kw">fn</span> <span class="tok-fn">assertToken</span>(p: *Parser, tag: Token.Tag) TokenIndex {</span>
<span class="line" id="L3734">        <span class="tok-kw">const</span> token = p.nextToken();</span>
<span class="line" id="L3735">        assert(p.token_tags[token] == tag);</span>
<span class="line" id="L3736">        <span class="tok-kw">return</span> token;</span>
<span class="line" id="L3737">    }</span>
<span class="line" id="L3738"></span>
<span class="line" id="L3739">    <span class="tok-kw">fn</span> <span class="tok-fn">expectToken</span>(p: *Parser, tag: Token.Tag) Error!TokenIndex {</span>
<span class="line" id="L3740">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] != tag) {</span>
<span class="line" id="L3741">            <span class="tok-kw">return</span> p.failMsg(.{</span>
<span class="line" id="L3742">                .tag = .expected_token,</span>
<span class="line" id="L3743">                .token = p.tok_i,</span>
<span class="line" id="L3744">                .extra = .{ .expected_tag = tag },</span>
<span class="line" id="L3745">            });</span>
<span class="line" id="L3746">        }</span>
<span class="line" id="L3747">        <span class="tok-kw">return</span> p.nextToken();</span>
<span class="line" id="L3748">    }</span>
<span class="line" id="L3749"></span>
<span class="line" id="L3750">    <span class="tok-kw">fn</span> <span class="tok-fn">expectSemicolon</span>(p: *Parser, error_tag: AstError.Tag, recoverable: <span class="tok-type">bool</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L3751">        <span class="tok-kw">if</span> (p.token_tags[p.tok_i] == .semicolon) {</span>
<span class="line" id="L3752">            _ = p.nextToken();</span>
<span class="line" id="L3753">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L3754">        }</span>
<span class="line" id="L3755">        <span class="tok-kw">try</span> p.warn(error_tag);</span>
<span class="line" id="L3756">        <span class="tok-kw">if</span> (!recoverable) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ParseError;</span>
<span class="line" id="L3757">    }</span>
<span class="line" id="L3758"></span>
<span class="line" id="L3759">    <span class="tok-kw">fn</span> <span class="tok-fn">nextToken</span>(p: *Parser) TokenIndex {</span>
<span class="line" id="L3760">        <span class="tok-kw">const</span> result = p.tok_i;</span>
<span class="line" id="L3761">        p.tok_i += <span class="tok-number">1</span>;</span>
<span class="line" id="L3762">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L3763">    }</span>
<span class="line" id="L3764">};</span>
<span class="line" id="L3765"></span>
<span class="line" id="L3766"><span class="tok-kw">test</span> {</span>
<span class="line" id="L3767">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;parser_test.zig&quot;</span>);</span>
<span class="line" id="L3768">}</span>
<span class="line" id="L3769"></span>
</code></pre></body>
</html>