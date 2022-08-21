<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>c/tokenizer.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Token = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5">    id: Id,</span>
<span class="line" id="L6">    start: <span class="tok-type">usize</span>,</span>
<span class="line" id="L7">    end: <span class="tok-type">usize</span>,</span>
<span class="line" id="L8"></span>
<span class="line" id="L9">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Id = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L10">        Invalid,</span>
<span class="line" id="L11">        Eof,</span>
<span class="line" id="L12">        Nl,</span>
<span class="line" id="L13">        Identifier,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">        <span class="tok-comment">/// special case for #include &lt;...&gt;</span></span>
<span class="line" id="L16">        MacroString,</span>
<span class="line" id="L17">        StringLiteral: StrKind,</span>
<span class="line" id="L18">        CharLiteral: StrKind,</span>
<span class="line" id="L19">        IntegerLiteral: NumSuffix,</span>
<span class="line" id="L20">        FloatLiteral: NumSuffix,</span>
<span class="line" id="L21">        Bang,</span>
<span class="line" id="L22">        BangEqual,</span>
<span class="line" id="L23">        Pipe,</span>
<span class="line" id="L24">        PipePipe,</span>
<span class="line" id="L25">        PipeEqual,</span>
<span class="line" id="L26">        Equal,</span>
<span class="line" id="L27">        EqualEqual,</span>
<span class="line" id="L28">        LParen,</span>
<span class="line" id="L29">        RParen,</span>
<span class="line" id="L30">        LBrace,</span>
<span class="line" id="L31">        RBrace,</span>
<span class="line" id="L32">        LBracket,</span>
<span class="line" id="L33">        RBracket,</span>
<span class="line" id="L34">        Period,</span>
<span class="line" id="L35">        Ellipsis,</span>
<span class="line" id="L36">        Caret,</span>
<span class="line" id="L37">        CaretEqual,</span>
<span class="line" id="L38">        Plus,</span>
<span class="line" id="L39">        PlusPlus,</span>
<span class="line" id="L40">        PlusEqual,</span>
<span class="line" id="L41">        Minus,</span>
<span class="line" id="L42">        MinusMinus,</span>
<span class="line" id="L43">        MinusEqual,</span>
<span class="line" id="L44">        Asterisk,</span>
<span class="line" id="L45">        AsteriskEqual,</span>
<span class="line" id="L46">        Percent,</span>
<span class="line" id="L47">        PercentEqual,</span>
<span class="line" id="L48">        Arrow,</span>
<span class="line" id="L49">        Colon,</span>
<span class="line" id="L50">        Semicolon,</span>
<span class="line" id="L51">        Slash,</span>
<span class="line" id="L52">        SlashEqual,</span>
<span class="line" id="L53">        Comma,</span>
<span class="line" id="L54">        Ampersand,</span>
<span class="line" id="L55">        AmpersandAmpersand,</span>
<span class="line" id="L56">        AmpersandEqual,</span>
<span class="line" id="L57">        QuestionMark,</span>
<span class="line" id="L58">        AngleBracketLeft,</span>
<span class="line" id="L59">        AngleBracketLeftEqual,</span>
<span class="line" id="L60">        AngleBracketAngleBracketLeft,</span>
<span class="line" id="L61">        AngleBracketAngleBracketLeftEqual,</span>
<span class="line" id="L62">        AngleBracketRight,</span>
<span class="line" id="L63">        AngleBracketRightEqual,</span>
<span class="line" id="L64">        AngleBracketAngleBracketRight,</span>
<span class="line" id="L65">        AngleBracketAngleBracketRightEqual,</span>
<span class="line" id="L66">        Tilde,</span>
<span class="line" id="L67">        LineComment,</span>
<span class="line" id="L68">        MultiLineComment,</span>
<span class="line" id="L69">        Hash,</span>
<span class="line" id="L70">        HashHash,</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">        Keyword_auto,</span>
<span class="line" id="L73">        Keyword_break,</span>
<span class="line" id="L74">        Keyword_case,</span>
<span class="line" id="L75">        Keyword_char,</span>
<span class="line" id="L76">        Keyword_const,</span>
<span class="line" id="L77">        Keyword_continue,</span>
<span class="line" id="L78">        Keyword_default,</span>
<span class="line" id="L79">        Keyword_do,</span>
<span class="line" id="L80">        Keyword_double,</span>
<span class="line" id="L81">        Keyword_else,</span>
<span class="line" id="L82">        Keyword_enum,</span>
<span class="line" id="L83">        Keyword_extern,</span>
<span class="line" id="L84">        Keyword_float,</span>
<span class="line" id="L85">        Keyword_for,</span>
<span class="line" id="L86">        Keyword_goto,</span>
<span class="line" id="L87">        Keyword_if,</span>
<span class="line" id="L88">        Keyword_int,</span>
<span class="line" id="L89">        Keyword_long,</span>
<span class="line" id="L90">        Keyword_register,</span>
<span class="line" id="L91">        Keyword_return,</span>
<span class="line" id="L92">        Keyword_short,</span>
<span class="line" id="L93">        Keyword_signed,</span>
<span class="line" id="L94">        Keyword_sizeof,</span>
<span class="line" id="L95">        Keyword_static,</span>
<span class="line" id="L96">        Keyword_struct,</span>
<span class="line" id="L97">        Keyword_switch,</span>
<span class="line" id="L98">        Keyword_typedef,</span>
<span class="line" id="L99">        Keyword_union,</span>
<span class="line" id="L100">        Keyword_unsigned,</span>
<span class="line" id="L101">        Keyword_void,</span>
<span class="line" id="L102">        Keyword_volatile,</span>
<span class="line" id="L103">        Keyword_while,</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">        <span class="tok-comment">// ISO C99</span>
</span>
<span class="line" id="L106">        Keyword_bool,</span>
<span class="line" id="L107">        Keyword_complex,</span>
<span class="line" id="L108">        Keyword_imaginary,</span>
<span class="line" id="L109">        Keyword_inline,</span>
<span class="line" id="L110">        Keyword_restrict,</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        <span class="tok-comment">// ISO C11</span>
</span>
<span class="line" id="L113">        Keyword_alignas,</span>
<span class="line" id="L114">        Keyword_alignof,</span>
<span class="line" id="L115">        Keyword_atomic,</span>
<span class="line" id="L116">        Keyword_generic,</span>
<span class="line" id="L117">        Keyword_noreturn,</span>
<span class="line" id="L118">        Keyword_static_assert,</span>
<span class="line" id="L119">        Keyword_thread_local,</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">        <span class="tok-comment">// Preprocessor directives</span>
</span>
<span class="line" id="L122">        Keyword_include,</span>
<span class="line" id="L123">        Keyword_define,</span>
<span class="line" id="L124">        Keyword_ifdef,</span>
<span class="line" id="L125">        Keyword_ifndef,</span>
<span class="line" id="L126">        Keyword_error,</span>
<span class="line" id="L127">        Keyword_pragma,</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symbol</span>(id: Id) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L130">            <span class="tok-kw">return</span> symbolName(id);</span>
<span class="line" id="L131">        }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symbolName</span>(id: std.meta.Tag(Id)) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L134">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (id) {</span>
<span class="line" id="L135">                .Invalid =&gt; <span class="tok-str">&quot;Invalid&quot;</span>,</span>
<span class="line" id="L136">                .Eof =&gt; <span class="tok-str">&quot;Eof&quot;</span>,</span>
<span class="line" id="L137">                .Nl =&gt; <span class="tok-str">&quot;NewLine&quot;</span>,</span>
<span class="line" id="L138">                .Identifier =&gt; <span class="tok-str">&quot;Identifier&quot;</span>,</span>
<span class="line" id="L139">                .MacroString =&gt; <span class="tok-str">&quot;MacroString&quot;</span>,</span>
<span class="line" id="L140">                .StringLiteral =&gt; <span class="tok-str">&quot;StringLiteral&quot;</span>,</span>
<span class="line" id="L141">                .CharLiteral =&gt; <span class="tok-str">&quot;CharLiteral&quot;</span>,</span>
<span class="line" id="L142">                .IntegerLiteral =&gt; <span class="tok-str">&quot;IntegerLiteral&quot;</span>,</span>
<span class="line" id="L143">                .FloatLiteral =&gt; <span class="tok-str">&quot;FloatLiteral&quot;</span>,</span>
<span class="line" id="L144">                .LineComment =&gt; <span class="tok-str">&quot;LineComment&quot;</span>,</span>
<span class="line" id="L145">                .MultiLineComment =&gt; <span class="tok-str">&quot;MultiLineComment&quot;</span>,</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">                .Bang =&gt; <span class="tok-str">&quot;!&quot;</span>,</span>
<span class="line" id="L148">                .BangEqual =&gt; <span class="tok-str">&quot;!=&quot;</span>,</span>
<span class="line" id="L149">                .Pipe =&gt; <span class="tok-str">&quot;|&quot;</span>,</span>
<span class="line" id="L150">                .PipePipe =&gt; <span class="tok-str">&quot;||&quot;</span>,</span>
<span class="line" id="L151">                .PipeEqual =&gt; <span class="tok-str">&quot;|=&quot;</span>,</span>
<span class="line" id="L152">                .Equal =&gt; <span class="tok-str">&quot;=&quot;</span>,</span>
<span class="line" id="L153">                .EqualEqual =&gt; <span class="tok-str">&quot;==&quot;</span>,</span>
<span class="line" id="L154">                .LParen =&gt; <span class="tok-str">&quot;(&quot;</span>,</span>
<span class="line" id="L155">                .RParen =&gt; <span class="tok-str">&quot;)&quot;</span>,</span>
<span class="line" id="L156">                .LBrace =&gt; <span class="tok-str">&quot;{&quot;</span>,</span>
<span class="line" id="L157">                .RBrace =&gt; <span class="tok-str">&quot;}&quot;</span>,</span>
<span class="line" id="L158">                .LBracket =&gt; <span class="tok-str">&quot;[&quot;</span>,</span>
<span class="line" id="L159">                .RBracket =&gt; <span class="tok-str">&quot;]&quot;</span>,</span>
<span class="line" id="L160">                .Period =&gt; <span class="tok-str">&quot;.&quot;</span>,</span>
<span class="line" id="L161">                .Ellipsis =&gt; <span class="tok-str">&quot;...&quot;</span>,</span>
<span class="line" id="L162">                .Caret =&gt; <span class="tok-str">&quot;^&quot;</span>,</span>
<span class="line" id="L163">                .CaretEqual =&gt; <span class="tok-str">&quot;^=&quot;</span>,</span>
<span class="line" id="L164">                .Plus =&gt; <span class="tok-str">&quot;+&quot;</span>,</span>
<span class="line" id="L165">                .PlusPlus =&gt; <span class="tok-str">&quot;++&quot;</span>,</span>
<span class="line" id="L166">                .PlusEqual =&gt; <span class="tok-str">&quot;+=&quot;</span>,</span>
<span class="line" id="L167">                .Minus =&gt; <span class="tok-str">&quot;-&quot;</span>,</span>
<span class="line" id="L168">                .MinusMinus =&gt; <span class="tok-str">&quot;--&quot;</span>,</span>
<span class="line" id="L169">                .MinusEqual =&gt; <span class="tok-str">&quot;-=&quot;</span>,</span>
<span class="line" id="L170">                .Asterisk =&gt; <span class="tok-str">&quot;*&quot;</span>,</span>
<span class="line" id="L171">                .AsteriskEqual =&gt; <span class="tok-str">&quot;*=&quot;</span>,</span>
<span class="line" id="L172">                .Percent =&gt; <span class="tok-str">&quot;%&quot;</span>,</span>
<span class="line" id="L173">                .PercentEqual =&gt; <span class="tok-str">&quot;%=&quot;</span>,</span>
<span class="line" id="L174">                .Arrow =&gt; <span class="tok-str">&quot;-&gt;&quot;</span>,</span>
<span class="line" id="L175">                .Colon =&gt; <span class="tok-str">&quot;:&quot;</span>,</span>
<span class="line" id="L176">                .Semicolon =&gt; <span class="tok-str">&quot;;&quot;</span>,</span>
<span class="line" id="L177">                .Slash =&gt; <span class="tok-str">&quot;/&quot;</span>,</span>
<span class="line" id="L178">                .SlashEqual =&gt; <span class="tok-str">&quot;/=&quot;</span>,</span>
<span class="line" id="L179">                .Comma =&gt; <span class="tok-str">&quot;,&quot;</span>,</span>
<span class="line" id="L180">                .Ampersand =&gt; <span class="tok-str">&quot;&amp;&quot;</span>,</span>
<span class="line" id="L181">                .AmpersandAmpersand =&gt; <span class="tok-str">&quot;&amp;&amp;&quot;</span>,</span>
<span class="line" id="L182">                .AmpersandEqual =&gt; <span class="tok-str">&quot;&amp;=&quot;</span>,</span>
<span class="line" id="L183">                .QuestionMark =&gt; <span class="tok-str">&quot;?&quot;</span>,</span>
<span class="line" id="L184">                .AngleBracketLeft =&gt; <span class="tok-str">&quot;&lt;&quot;</span>,</span>
<span class="line" id="L185">                .AngleBracketLeftEqual =&gt; <span class="tok-str">&quot;&lt;=&quot;</span>,</span>
<span class="line" id="L186">                .AngleBracketAngleBracketLeft =&gt; <span class="tok-str">&quot;&lt;&lt;&quot;</span>,</span>
<span class="line" id="L187">                .AngleBracketAngleBracketLeftEqual =&gt; <span class="tok-str">&quot;&lt;&lt;=&quot;</span>,</span>
<span class="line" id="L188">                .AngleBracketRight =&gt; <span class="tok-str">&quot;&gt;&quot;</span>,</span>
<span class="line" id="L189">                .AngleBracketRightEqual =&gt; <span class="tok-str">&quot;&gt;=&quot;</span>,</span>
<span class="line" id="L190">                .AngleBracketAngleBracketRight =&gt; <span class="tok-str">&quot;&gt;&gt;&quot;</span>,</span>
<span class="line" id="L191">                .AngleBracketAngleBracketRightEqual =&gt; <span class="tok-str">&quot;&gt;&gt;=&quot;</span>,</span>
<span class="line" id="L192">                .Tilde =&gt; <span class="tok-str">&quot;~&quot;</span>,</span>
<span class="line" id="L193">                .Hash =&gt; <span class="tok-str">&quot;#&quot;</span>,</span>
<span class="line" id="L194">                .HashHash =&gt; <span class="tok-str">&quot;##&quot;</span>,</span>
<span class="line" id="L195">                .Keyword_auto =&gt; <span class="tok-str">&quot;auto&quot;</span>,</span>
<span class="line" id="L196">                .Keyword_break =&gt; <span class="tok-str">&quot;break&quot;</span>,</span>
<span class="line" id="L197">                .Keyword_case =&gt; <span class="tok-str">&quot;case&quot;</span>,</span>
<span class="line" id="L198">                .Keyword_char =&gt; <span class="tok-str">&quot;char&quot;</span>,</span>
<span class="line" id="L199">                .Keyword_const =&gt; <span class="tok-str">&quot;const&quot;</span>,</span>
<span class="line" id="L200">                .Keyword_continue =&gt; <span class="tok-str">&quot;continue&quot;</span>,</span>
<span class="line" id="L201">                .Keyword_default =&gt; <span class="tok-str">&quot;default&quot;</span>,</span>
<span class="line" id="L202">                .Keyword_do =&gt; <span class="tok-str">&quot;do&quot;</span>,</span>
<span class="line" id="L203">                .Keyword_double =&gt; <span class="tok-str">&quot;double&quot;</span>,</span>
<span class="line" id="L204">                .Keyword_else =&gt; <span class="tok-str">&quot;else&quot;</span>,</span>
<span class="line" id="L205">                .Keyword_enum =&gt; <span class="tok-str">&quot;enum&quot;</span>,</span>
<span class="line" id="L206">                .Keyword_extern =&gt; <span class="tok-str">&quot;extern&quot;</span>,</span>
<span class="line" id="L207">                .Keyword_float =&gt; <span class="tok-str">&quot;float&quot;</span>,</span>
<span class="line" id="L208">                .Keyword_for =&gt; <span class="tok-str">&quot;for&quot;</span>,</span>
<span class="line" id="L209">                .Keyword_goto =&gt; <span class="tok-str">&quot;goto&quot;</span>,</span>
<span class="line" id="L210">                .Keyword_if =&gt; <span class="tok-str">&quot;if&quot;</span>,</span>
<span class="line" id="L211">                .Keyword_int =&gt; <span class="tok-str">&quot;int&quot;</span>,</span>
<span class="line" id="L212">                .Keyword_long =&gt; <span class="tok-str">&quot;long&quot;</span>,</span>
<span class="line" id="L213">                .Keyword_register =&gt; <span class="tok-str">&quot;register&quot;</span>,</span>
<span class="line" id="L214">                .Keyword_return =&gt; <span class="tok-str">&quot;return&quot;</span>,</span>
<span class="line" id="L215">                .Keyword_short =&gt; <span class="tok-str">&quot;short&quot;</span>,</span>
<span class="line" id="L216">                .Keyword_signed =&gt; <span class="tok-str">&quot;signed&quot;</span>,</span>
<span class="line" id="L217">                .Keyword_sizeof =&gt; <span class="tok-str">&quot;sizeof&quot;</span>,</span>
<span class="line" id="L218">                .Keyword_static =&gt; <span class="tok-str">&quot;static&quot;</span>,</span>
<span class="line" id="L219">                .Keyword_struct =&gt; <span class="tok-str">&quot;struct&quot;</span>,</span>
<span class="line" id="L220">                .Keyword_switch =&gt; <span class="tok-str">&quot;switch&quot;</span>,</span>
<span class="line" id="L221">                .Keyword_typedef =&gt; <span class="tok-str">&quot;typedef&quot;</span>,</span>
<span class="line" id="L222">                .Keyword_union =&gt; <span class="tok-str">&quot;union&quot;</span>,</span>
<span class="line" id="L223">                .Keyword_unsigned =&gt; <span class="tok-str">&quot;unsigned&quot;</span>,</span>
<span class="line" id="L224">                .Keyword_void =&gt; <span class="tok-str">&quot;void&quot;</span>,</span>
<span class="line" id="L225">                .Keyword_volatile =&gt; <span class="tok-str">&quot;volatile&quot;</span>,</span>
<span class="line" id="L226">                .Keyword_while =&gt; <span class="tok-str">&quot;while&quot;</span>,</span>
<span class="line" id="L227">                .Keyword_bool =&gt; <span class="tok-str">&quot;_Bool&quot;</span>,</span>
<span class="line" id="L228">                .Keyword_complex =&gt; <span class="tok-str">&quot;_Complex&quot;</span>,</span>
<span class="line" id="L229">                .Keyword_imaginary =&gt; <span class="tok-str">&quot;_Imaginary&quot;</span>,</span>
<span class="line" id="L230">                .Keyword_inline =&gt; <span class="tok-str">&quot;inline&quot;</span>,</span>
<span class="line" id="L231">                .Keyword_restrict =&gt; <span class="tok-str">&quot;restrict&quot;</span>,</span>
<span class="line" id="L232">                .Keyword_alignas =&gt; <span class="tok-str">&quot;_Alignas&quot;</span>,</span>
<span class="line" id="L233">                .Keyword_alignof =&gt; <span class="tok-str">&quot;_Alignof&quot;</span>,</span>
<span class="line" id="L234">                .Keyword_atomic =&gt; <span class="tok-str">&quot;_Atomic&quot;</span>,</span>
<span class="line" id="L235">                .Keyword_generic =&gt; <span class="tok-str">&quot;_Generic&quot;</span>,</span>
<span class="line" id="L236">                .Keyword_noreturn =&gt; <span class="tok-str">&quot;_Noreturn&quot;</span>,</span>
<span class="line" id="L237">                .Keyword_static_assert =&gt; <span class="tok-str">&quot;_Static_assert&quot;</span>,</span>
<span class="line" id="L238">                .Keyword_thread_local =&gt; <span class="tok-str">&quot;_Thread_local&quot;</span>,</span>
<span class="line" id="L239">                .Keyword_include =&gt; <span class="tok-str">&quot;include&quot;</span>,</span>
<span class="line" id="L240">                .Keyword_define =&gt; <span class="tok-str">&quot;define&quot;</span>,</span>
<span class="line" id="L241">                .Keyword_ifdef =&gt; <span class="tok-str">&quot;ifdef&quot;</span>,</span>
<span class="line" id="L242">                .Keyword_ifndef =&gt; <span class="tok-str">&quot;ifndef&quot;</span>,</span>
<span class="line" id="L243">                .Keyword_error =&gt; <span class="tok-str">&quot;error&quot;</span>,</span>
<span class="line" id="L244">                .Keyword_pragma =&gt; <span class="tok-str">&quot;pragma&quot;</span>,</span>
<span class="line" id="L245">            };</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247">    };</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-comment">// TODO extensions</span>
</span>
<span class="line" id="L250">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> keywords = std.ComptimeStringMap(Id, .{</span>
<span class="line" id="L251">        .{ <span class="tok-str">&quot;auto&quot;</span>, .Keyword_auto },</span>
<span class="line" id="L252">        .{ <span class="tok-str">&quot;break&quot;</span>, .Keyword_break },</span>
<span class="line" id="L253">        .{ <span class="tok-str">&quot;case&quot;</span>, .Keyword_case },</span>
<span class="line" id="L254">        .{ <span class="tok-str">&quot;char&quot;</span>, .Keyword_char },</span>
<span class="line" id="L255">        .{ <span class="tok-str">&quot;const&quot;</span>, .Keyword_const },</span>
<span class="line" id="L256">        .{ <span class="tok-str">&quot;continue&quot;</span>, .Keyword_continue },</span>
<span class="line" id="L257">        .{ <span class="tok-str">&quot;default&quot;</span>, .Keyword_default },</span>
<span class="line" id="L258">        .{ <span class="tok-str">&quot;do&quot;</span>, .Keyword_do },</span>
<span class="line" id="L259">        .{ <span class="tok-str">&quot;double&quot;</span>, .Keyword_double },</span>
<span class="line" id="L260">        .{ <span class="tok-str">&quot;else&quot;</span>, .Keyword_else },</span>
<span class="line" id="L261">        .{ <span class="tok-str">&quot;enum&quot;</span>, .Keyword_enum },</span>
<span class="line" id="L262">        .{ <span class="tok-str">&quot;extern&quot;</span>, .Keyword_extern },</span>
<span class="line" id="L263">        .{ <span class="tok-str">&quot;float&quot;</span>, .Keyword_float },</span>
<span class="line" id="L264">        .{ <span class="tok-str">&quot;for&quot;</span>, .Keyword_for },</span>
<span class="line" id="L265">        .{ <span class="tok-str">&quot;goto&quot;</span>, .Keyword_goto },</span>
<span class="line" id="L266">        .{ <span class="tok-str">&quot;if&quot;</span>, .Keyword_if },</span>
<span class="line" id="L267">        .{ <span class="tok-str">&quot;int&quot;</span>, .Keyword_int },</span>
<span class="line" id="L268">        .{ <span class="tok-str">&quot;long&quot;</span>, .Keyword_long },</span>
<span class="line" id="L269">        .{ <span class="tok-str">&quot;register&quot;</span>, .Keyword_register },</span>
<span class="line" id="L270">        .{ <span class="tok-str">&quot;return&quot;</span>, .Keyword_return },</span>
<span class="line" id="L271">        .{ <span class="tok-str">&quot;short&quot;</span>, .Keyword_short },</span>
<span class="line" id="L272">        .{ <span class="tok-str">&quot;signed&quot;</span>, .Keyword_signed },</span>
<span class="line" id="L273">        .{ <span class="tok-str">&quot;sizeof&quot;</span>, .Keyword_sizeof },</span>
<span class="line" id="L274">        .{ <span class="tok-str">&quot;static&quot;</span>, .Keyword_static },</span>
<span class="line" id="L275">        .{ <span class="tok-str">&quot;struct&quot;</span>, .Keyword_struct },</span>
<span class="line" id="L276">        .{ <span class="tok-str">&quot;switch&quot;</span>, .Keyword_switch },</span>
<span class="line" id="L277">        .{ <span class="tok-str">&quot;typedef&quot;</span>, .Keyword_typedef },</span>
<span class="line" id="L278">        .{ <span class="tok-str">&quot;union&quot;</span>, .Keyword_union },</span>
<span class="line" id="L279">        .{ <span class="tok-str">&quot;unsigned&quot;</span>, .Keyword_unsigned },</span>
<span class="line" id="L280">        .{ <span class="tok-str">&quot;void&quot;</span>, .Keyword_void },</span>
<span class="line" id="L281">        .{ <span class="tok-str">&quot;volatile&quot;</span>, .Keyword_volatile },</span>
<span class="line" id="L282">        .{ <span class="tok-str">&quot;while&quot;</span>, .Keyword_while },</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">        <span class="tok-comment">// ISO C99</span>
</span>
<span class="line" id="L285">        .{ <span class="tok-str">&quot;_Bool&quot;</span>, .Keyword_bool },</span>
<span class="line" id="L286">        .{ <span class="tok-str">&quot;_Complex&quot;</span>, .Keyword_complex },</span>
<span class="line" id="L287">        .{ <span class="tok-str">&quot;_Imaginary&quot;</span>, .Keyword_imaginary },</span>
<span class="line" id="L288">        .{ <span class="tok-str">&quot;inline&quot;</span>, .Keyword_inline },</span>
<span class="line" id="L289">        .{ <span class="tok-str">&quot;restrict&quot;</span>, .Keyword_restrict },</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">        <span class="tok-comment">// ISO C11</span>
</span>
<span class="line" id="L292">        .{ <span class="tok-str">&quot;_Alignas&quot;</span>, .Keyword_alignas },</span>
<span class="line" id="L293">        .{ <span class="tok-str">&quot;_Alignof&quot;</span>, .Keyword_alignof },</span>
<span class="line" id="L294">        .{ <span class="tok-str">&quot;_Atomic&quot;</span>, .Keyword_atomic },</span>
<span class="line" id="L295">        .{ <span class="tok-str">&quot;_Generic&quot;</span>, .Keyword_generic },</span>
<span class="line" id="L296">        .{ <span class="tok-str">&quot;_Noreturn&quot;</span>, .Keyword_noreturn },</span>
<span class="line" id="L297">        .{ <span class="tok-str">&quot;_Static_assert&quot;</span>, .Keyword_static_assert },</span>
<span class="line" id="L298">        .{ <span class="tok-str">&quot;_Thread_local&quot;</span>, .Keyword_thread_local },</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">        <span class="tok-comment">// Preprocessor directives</span>
</span>
<span class="line" id="L301">        .{ <span class="tok-str">&quot;include&quot;</span>, .Keyword_include },</span>
<span class="line" id="L302">        .{ <span class="tok-str">&quot;define&quot;</span>, .Keyword_define },</span>
<span class="line" id="L303">        .{ <span class="tok-str">&quot;ifdef&quot;</span>, .Keyword_ifdef },</span>
<span class="line" id="L304">        .{ <span class="tok-str">&quot;ifndef&quot;</span>, .Keyword_ifndef },</span>
<span class="line" id="L305">        .{ <span class="tok-str">&quot;error&quot;</span>, .Keyword_error },</span>
<span class="line" id="L306">        .{ <span class="tok-str">&quot;pragma&quot;</span>, .Keyword_pragma },</span>
<span class="line" id="L307">    });</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-comment">// TODO do this in the preprocessor</span>
</span>
<span class="line" id="L310">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyword</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, pp_directive: <span class="tok-type">bool</span>) ?Id {</span>
<span class="line" id="L311">        <span class="tok-kw">if</span> (keywords.get(bytes)) |id| {</span>
<span class="line" id="L312">            <span class="tok-kw">switch</span> (id) {</span>
<span class="line" id="L313">                .Keyword_include,</span>
<span class="line" id="L314">                .Keyword_define,</span>
<span class="line" id="L315">                .Keyword_ifdef,</span>
<span class="line" id="L316">                .Keyword_ifndef,</span>
<span class="line" id="L317">                .Keyword_error,</span>
<span class="line" id="L318">                .Keyword_pragma,</span>
<span class="line" id="L319">                =&gt; <span class="tok-kw">if</span> (!pp_directive) <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L320">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L321">            }</span>
<span class="line" id="L322">            <span class="tok-kw">return</span> id;</span>
<span class="line" id="L323">        }</span>
<span class="line" id="L324">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NumSuffix = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L328">        none,</span>
<span class="line" id="L329">        f,</span>
<span class="line" id="L330">        l,</span>
<span class="line" id="L331">        u,</span>
<span class="line" id="L332">        lu,</span>
<span class="line" id="L333">        ll,</span>
<span class="line" id="L334">        llu,</span>
<span class="line" id="L335">    };</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StrKind = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L338">        none,</span>
<span class="line" id="L339">        wide,</span>
<span class="line" id="L340">        utf_8,</span>
<span class="line" id="L341">        utf_16,</span>
<span class="line" id="L342">        utf_32,</span>
<span class="line" id="L343">    };</span>
<span class="line" id="L344">};</span>
<span class="line" id="L345"></span>
<span class="line" id="L346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tokenizer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L347">    buffer: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L348">    index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L349">    prev_tok_id: std.meta.Tag(Token.Id) = .Invalid,</span>
<span class="line" id="L350">    pp_directive: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Tokenizer) Token {</span>
<span class="line" id="L353">        <span class="tok-kw">var</span> result = Token{</span>
<span class="line" id="L354">            .id = .Eof,</span>
<span class="line" id="L355">            .start = self.index,</span>
<span class="line" id="L356">            .end = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L357">        };</span>
<span class="line" id="L358">        <span class="tok-kw">var</span> state: <span class="tok-kw">enum</span> {</span>
<span class="line" id="L359">            Start,</span>
<span class="line" id="L360">            Cr,</span>
<span class="line" id="L361">            BackSlash,</span>
<span class="line" id="L362">            BackSlashCr,</span>
<span class="line" id="L363">            u,</span>
<span class="line" id="L364">            <span class="tok-type">u8</span>,</span>
<span class="line" id="L365">            U,</span>
<span class="line" id="L366">            L,</span>
<span class="line" id="L367">            StringLiteral,</span>
<span class="line" id="L368">            CharLiteralStart,</span>
<span class="line" id="L369">            CharLiteral,</span>
<span class="line" id="L370">            EscapeSequence,</span>
<span class="line" id="L371">            CrEscape,</span>
<span class="line" id="L372">            OctalEscape,</span>
<span class="line" id="L373">            HexEscape,</span>
<span class="line" id="L374">            UnicodeEscape,</span>
<span class="line" id="L375">            Identifier,</span>
<span class="line" id="L376">            Equal,</span>
<span class="line" id="L377">            Bang,</span>
<span class="line" id="L378">            Pipe,</span>
<span class="line" id="L379">            Percent,</span>
<span class="line" id="L380">            Asterisk,</span>
<span class="line" id="L381">            Plus,</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">            <span class="tok-comment">/// special case for #include &lt;...&gt;</span></span>
<span class="line" id="L384">            MacroString,</span>
<span class="line" id="L385">            AngleBracketLeft,</span>
<span class="line" id="L386">            AngleBracketAngleBracketLeft,</span>
<span class="line" id="L387">            AngleBracketRight,</span>
<span class="line" id="L388">            AngleBracketAngleBracketRight,</span>
<span class="line" id="L389">            Caret,</span>
<span class="line" id="L390">            Period,</span>
<span class="line" id="L391">            Period2,</span>
<span class="line" id="L392">            Minus,</span>
<span class="line" id="L393">            Slash,</span>
<span class="line" id="L394">            Ampersand,</span>
<span class="line" id="L395">            Hash,</span>
<span class="line" id="L396">            LineComment,</span>
<span class="line" id="L397">            MultiLineComment,</span>
<span class="line" id="L398">            MultiLineCommentAsterisk,</span>
<span class="line" id="L399">            Zero,</span>
<span class="line" id="L400">            IntegerLiteralOct,</span>
<span class="line" id="L401">            IntegerLiteralBinary,</span>
<span class="line" id="L402">            IntegerLiteralBinaryFirst,</span>
<span class="line" id="L403">            IntegerLiteralHex,</span>
<span class="line" id="L404">            IntegerLiteralHexFirst,</span>
<span class="line" id="L405">            IntegerLiteral,</span>
<span class="line" id="L406">            IntegerSuffix,</span>
<span class="line" id="L407">            IntegerSuffixU,</span>
<span class="line" id="L408">            IntegerSuffixL,</span>
<span class="line" id="L409">            IntegerSuffixLL,</span>
<span class="line" id="L410">            IntegerSuffixUL,</span>
<span class="line" id="L411">            FloatFraction,</span>
<span class="line" id="L412">            FloatFractionHex,</span>
<span class="line" id="L413">            FloatExponent,</span>
<span class="line" id="L414">            FloatExponentDigits,</span>
<span class="line" id="L415">            FloatSuffix,</span>
<span class="line" id="L416">        } = .Start;</span>
<span class="line" id="L417">        <span class="tok-kw">var</span> string = <span class="tok-null">false</span>;</span>
<span class="line" id="L418">        <span class="tok-kw">var</span> counter: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L419">        <span class="tok-kw">while</span> (self.index &lt; self.buffer.len) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L420">            <span class="tok-kw">const</span> c = self.buffer[self.index];</span>
<span class="line" id="L421">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L422">                .Start =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L423">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L424">                        self.pp_directive = <span class="tok-null">false</span>;</span>
<span class="line" id="L425">                        result.id = .Nl;</span>
<span class="line" id="L426">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L427">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L428">                    },</span>
<span class="line" id="L429">                    <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L430">                        state = .Cr;</span>
<span class="line" id="L431">                    },</span>
<span class="line" id="L432">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L433">                        result.id = .{ .StringLiteral = .none };</span>
<span class="line" id="L434">                        state = .StringLiteral;</span>
<span class="line" id="L435">                    },</span>
<span class="line" id="L436">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L437">                        result.id = .{ .CharLiteral = .none };</span>
<span class="line" id="L438">                        state = .CharLiteralStart;</span>
<span class="line" id="L439">                    },</span>
<span class="line" id="L440">                    <span class="tok-str">'u'</span> =&gt; {</span>
<span class="line" id="L441">                        state = .u;</span>
<span class="line" id="L442">                    },</span>
<span class="line" id="L443">                    <span class="tok-str">'U'</span> =&gt; {</span>
<span class="line" id="L444">                        state = .U;</span>
<span class="line" id="L445">                    },</span>
<span class="line" id="L446">                    <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L447">                        state = .L;</span>
<span class="line" id="L448">                    },</span>
<span class="line" id="L449">                    <span class="tok-str">'a'</span>...<span class="tok-str">'t'</span>, <span class="tok-str">'v'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'K'</span>, <span class="tok-str">'M'</span>...<span class="tok-str">'T'</span>, <span class="tok-str">'V'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span>, <span class="tok-str">'$'</span> =&gt; {</span>
<span class="line" id="L450">                        state = .Identifier;</span>
<span class="line" id="L451">                    },</span>
<span class="line" id="L452">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L453">                        state = .Equal;</span>
<span class="line" id="L454">                    },</span>
<span class="line" id="L455">                    <span class="tok-str">'!'</span> =&gt; {</span>
<span class="line" id="L456">                        state = .Bang;</span>
<span class="line" id="L457">                    },</span>
<span class="line" id="L458">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L459">                        state = .Pipe;</span>
<span class="line" id="L460">                    },</span>
<span class="line" id="L461">                    <span class="tok-str">'('</span> =&gt; {</span>
<span class="line" id="L462">                        result.id = .LParen;</span>
<span class="line" id="L463">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L464">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L465">                    },</span>
<span class="line" id="L466">                    <span class="tok-str">')'</span> =&gt; {</span>
<span class="line" id="L467">                        result.id = .RParen;</span>
<span class="line" id="L468">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L469">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L470">                    },</span>
<span class="line" id="L471">                    <span class="tok-str">'['</span> =&gt; {</span>
<span class="line" id="L472">                        result.id = .LBracket;</span>
<span class="line" id="L473">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L474">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L475">                    },</span>
<span class="line" id="L476">                    <span class="tok-str">']'</span> =&gt; {</span>
<span class="line" id="L477">                        result.id = .RBracket;</span>
<span class="line" id="L478">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L479">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L480">                    },</span>
<span class="line" id="L481">                    <span class="tok-str">';'</span> =&gt; {</span>
<span class="line" id="L482">                        result.id = .Semicolon;</span>
<span class="line" id="L483">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L484">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L485">                    },</span>
<span class="line" id="L486">                    <span class="tok-str">','</span> =&gt; {</span>
<span class="line" id="L487">                        result.id = .Comma;</span>
<span class="line" id="L488">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L489">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L490">                    },</span>
<span class="line" id="L491">                    <span class="tok-str">'?'</span> =&gt; {</span>
<span class="line" id="L492">                        result.id = .QuestionMark;</span>
<span class="line" id="L493">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L494">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L495">                    },</span>
<span class="line" id="L496">                    <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L497">                        result.id = .Colon;</span>
<span class="line" id="L498">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L499">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L500">                    },</span>
<span class="line" id="L501">                    <span class="tok-str">'%'</span> =&gt; {</span>
<span class="line" id="L502">                        state = .Percent;</span>
<span class="line" id="L503">                    },</span>
<span class="line" id="L504">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L505">                        state = .Asterisk;</span>
<span class="line" id="L506">                    },</span>
<span class="line" id="L507">                    <span class="tok-str">'+'</span> =&gt; {</span>
<span class="line" id="L508">                        state = .Plus;</span>
<span class="line" id="L509">                    },</span>
<span class="line" id="L510">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L511">                        <span class="tok-kw">if</span> (self.prev_tok_id == .Keyword_include)</span>
<span class="line" id="L512">                            state = .MacroString</span>
<span class="line" id="L513">                        <span class="tok-kw">else</span></span>
<span class="line" id="L514">                            state = .AngleBracketLeft;</span>
<span class="line" id="L515">                    },</span>
<span class="line" id="L516">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L517">                        state = .AngleBracketRight;</span>
<span class="line" id="L518">                    },</span>
<span class="line" id="L519">                    <span class="tok-str">'^'</span> =&gt; {</span>
<span class="line" id="L520">                        state = .Caret;</span>
<span class="line" id="L521">                    },</span>
<span class="line" id="L522">                    <span class="tok-str">'{'</span> =&gt; {</span>
<span class="line" id="L523">                        result.id = .LBrace;</span>
<span class="line" id="L524">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L525">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L526">                    },</span>
<span class="line" id="L527">                    <span class="tok-str">'}'</span> =&gt; {</span>
<span class="line" id="L528">                        result.id = .RBrace;</span>
<span class="line" id="L529">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L530">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L531">                    },</span>
<span class="line" id="L532">                    <span class="tok-str">'~'</span> =&gt; {</span>
<span class="line" id="L533">                        result.id = .Tilde;</span>
<span class="line" id="L534">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L535">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L536">                    },</span>
<span class="line" id="L537">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L538">                        state = .Period;</span>
<span class="line" id="L539">                    },</span>
<span class="line" id="L540">                    <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L541">                        state = .Minus;</span>
<span class="line" id="L542">                    },</span>
<span class="line" id="L543">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L544">                        state = .Slash;</span>
<span class="line" id="L545">                    },</span>
<span class="line" id="L546">                    <span class="tok-str">'&amp;'</span> =&gt; {</span>
<span class="line" id="L547">                        state = .Ampersand;</span>
<span class="line" id="L548">                    },</span>
<span class="line" id="L549">                    <span class="tok-str">'#'</span> =&gt; {</span>
<span class="line" id="L550">                        state = .Hash;</span>
<span class="line" id="L551">                    },</span>
<span class="line" id="L552">                    <span class="tok-str">'0'</span> =&gt; {</span>
<span class="line" id="L553">                        state = .Zero;</span>
<span class="line" id="L554">                    },</span>
<span class="line" id="L555">                    <span class="tok-str">'1'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L556">                        state = .IntegerLiteral;</span>
<span class="line" id="L557">                    },</span>
<span class="line" id="L558">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L559">                        state = .BackSlash;</span>
<span class="line" id="L560">                    },</span>
<span class="line" id="L561">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\x0B'</span>, <span class="tok-str">'\x0C'</span>, <span class="tok-str">' '</span> =&gt; {</span>
<span class="line" id="L562">                        result.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L563">                    },</span>
<span class="line" id="L564">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L565">                        <span class="tok-comment">// TODO handle invalid bytes better</span>
</span>
<span class="line" id="L566">                        result.id = .Invalid;</span>
<span class="line" id="L567">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L568">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L569">                    },</span>
<span class="line" id="L570">                },</span>
<span class="line" id="L571">                .Cr =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L572">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L573">                        self.pp_directive = <span class="tok-null">false</span>;</span>
<span class="line" id="L574">                        result.id = .Nl;</span>
<span class="line" id="L575">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L576">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L577">                    },</span>
<span class="line" id="L578">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L579">                        result.id = .Invalid;</span>
<span class="line" id="L580">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L581">                    },</span>
<span class="line" id="L582">                },</span>
<span class="line" id="L583">                .BackSlash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L584">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L585">                        result.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L586">                        state = .Start;</span>
<span class="line" id="L587">                    },</span>
<span class="line" id="L588">                    <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L589">                        state = .BackSlashCr;</span>
<span class="line" id="L590">                    },</span>
<span class="line" id="L591">                    <span class="tok-str">'\t'</span>, <span class="tok-str">'\x0B'</span>, <span class="tok-str">'\x0C'</span>, <span class="tok-str">' '</span> =&gt; {</span>
<span class="line" id="L592">                        <span class="tok-comment">// TODO warn</span>
</span>
<span class="line" id="L593">                    },</span>
<span class="line" id="L594">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L595">                        result.id = .Invalid;</span>
<span class="line" id="L596">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L597">                    },</span>
<span class="line" id="L598">                },</span>
<span class="line" id="L599">                .BackSlashCr =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L600">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L601">                        result.start = self.index + <span class="tok-number">1</span>;</span>
<span class="line" id="L602">                        state = .Start;</span>
<span class="line" id="L603">                    },</span>
<span class="line" id="L604">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L605">                        result.id = .Invalid;</span>
<span class="line" id="L606">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L607">                    },</span>
<span class="line" id="L608">                },</span>
<span class="line" id="L609">                .u =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L610">                    <span class="tok-str">'8'</span> =&gt; {</span>
<span class="line" id="L611">                        state = .<span class="tok-type">u8</span>;</span>
<span class="line" id="L612">                    },</span>
<span class="line" id="L613">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L614">                        result.id = .{ .CharLiteral = .utf_16 };</span>
<span class="line" id="L615">                        state = .CharLiteralStart;</span>
<span class="line" id="L616">                    },</span>
<span class="line" id="L617">                    <span class="tok-str">'\&quot;'</span> =&gt; {</span>
<span class="line" id="L618">                        result.id = .{ .StringLiteral = .utf_16 };</span>
<span class="line" id="L619">                        state = .StringLiteral;</span>
<span class="line" id="L620">                    },</span>
<span class="line" id="L621">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L622">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L623">                        state = .Identifier;</span>
<span class="line" id="L624">                    },</span>
<span class="line" id="L625">                },</span>
<span class="line" id="L626">                .<span class="tok-type">u8</span> =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L627">                    <span class="tok-str">'\&quot;'</span> =&gt; {</span>
<span class="line" id="L628">                        result.id = .{ .StringLiteral = .utf_8 };</span>
<span class="line" id="L629">                        state = .StringLiteral;</span>
<span class="line" id="L630">                    },</span>
<span class="line" id="L631">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L632">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L633">                        state = .Identifier;</span>
<span class="line" id="L634">                    },</span>
<span class="line" id="L635">                },</span>
<span class="line" id="L636">                .U =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L637">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L638">                        result.id = .{ .CharLiteral = .utf_32 };</span>
<span class="line" id="L639">                        state = .CharLiteralStart;</span>
<span class="line" id="L640">                    },</span>
<span class="line" id="L641">                    <span class="tok-str">'\&quot;'</span> =&gt; {</span>
<span class="line" id="L642">                        result.id = .{ .StringLiteral = .utf_32 };</span>
<span class="line" id="L643">                        state = .StringLiteral;</span>
<span class="line" id="L644">                    },</span>
<span class="line" id="L645">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L646">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L647">                        state = .Identifier;</span>
<span class="line" id="L648">                    },</span>
<span class="line" id="L649">                },</span>
<span class="line" id="L650">                .L =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L651">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L652">                        result.id = .{ .CharLiteral = .wide };</span>
<span class="line" id="L653">                        state = .CharLiteralStart;</span>
<span class="line" id="L654">                    },</span>
<span class="line" id="L655">                    <span class="tok-str">'\&quot;'</span> =&gt; {</span>
<span class="line" id="L656">                        result.id = .{ .StringLiteral = .wide };</span>
<span class="line" id="L657">                        state = .StringLiteral;</span>
<span class="line" id="L658">                    },</span>
<span class="line" id="L659">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L660">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L661">                        state = .Identifier;</span>
<span class="line" id="L662">                    },</span>
<span class="line" id="L663">                },</span>
<span class="line" id="L664">                .StringLiteral =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L665">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L666">                        string = <span class="tok-null">true</span>;</span>
<span class="line" id="L667">                        state = .EscapeSequence;</span>
<span class="line" id="L668">                    },</span>
<span class="line" id="L669">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L670">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L671">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L672">                    },</span>
<span class="line" id="L673">                    <span class="tok-str">'\n'</span>, <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L674">                        result.id = .Invalid;</span>
<span class="line" id="L675">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L676">                    },</span>
<span class="line" id="L677">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L678">                },</span>
<span class="line" id="L679">                .CharLiteralStart =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L680">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L681">                        string = <span class="tok-null">false</span>;</span>
<span class="line" id="L682">                        state = .EscapeSequence;</span>
<span class="line" id="L683">                    },</span>
<span class="line" id="L684">                    <span class="tok-str">'\''</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L685">                        result.id = .Invalid;</span>
<span class="line" id="L686">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L687">                    },</span>
<span class="line" id="L688">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L689">                        state = .CharLiteral;</span>
<span class="line" id="L690">                    },</span>
<span class="line" id="L691">                },</span>
<span class="line" id="L692">                .CharLiteral =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L693">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L694">                        string = <span class="tok-null">false</span>;</span>
<span class="line" id="L695">                        state = .EscapeSequence;</span>
<span class="line" id="L696">                    },</span>
<span class="line" id="L697">                    <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L698">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L699">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L700">                    },</span>
<span class="line" id="L701">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L702">                        result.id = .Invalid;</span>
<span class="line" id="L703">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L704">                    },</span>
<span class="line" id="L705">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L706">                },</span>
<span class="line" id="L707">                .EscapeSequence =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L708">                    <span class="tok-str">'\''</span>, <span class="tok-str">'&quot;'</span>, <span class="tok-str">'?'</span>, <span class="tok-str">'\\'</span>, <span class="tok-str">'a'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'f'</span>, <span class="tok-str">'n'</span>, <span class="tok-str">'r'</span>, <span class="tok-str">'t'</span>, <span class="tok-str">'v'</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L709">                        state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L710">                    },</span>
<span class="line" id="L711">                    <span class="tok-str">'\r'</span> =&gt; {</span>
<span class="line" id="L712">                        state = .CrEscape;</span>
<span class="line" id="L713">                    },</span>
<span class="line" id="L714">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; {</span>
<span class="line" id="L715">                        counter = <span class="tok-number">1</span>;</span>
<span class="line" id="L716">                        state = .OctalEscape;</span>
<span class="line" id="L717">                    },</span>
<span class="line" id="L718">                    <span class="tok-str">'x'</span> =&gt; {</span>
<span class="line" id="L719">                        state = .HexEscape;</span>
<span class="line" id="L720">                    },</span>
<span class="line" id="L721">                    <span class="tok-str">'u'</span> =&gt; {</span>
<span class="line" id="L722">                        counter = <span class="tok-number">4</span>;</span>
<span class="line" id="L723">                        state = .OctalEscape;</span>
<span class="line" id="L724">                    },</span>
<span class="line" id="L725">                    <span class="tok-str">'U'</span> =&gt; {</span>
<span class="line" id="L726">                        counter = <span class="tok-number">8</span>;</span>
<span class="line" id="L727">                        state = .OctalEscape;</span>
<span class="line" id="L728">                    },</span>
<span class="line" id="L729">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L730">                        result.id = .Invalid;</span>
<span class="line" id="L731">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L732">                    },</span>
<span class="line" id="L733">                },</span>
<span class="line" id="L734">                .CrEscape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L735">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L736">                        state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L737">                    },</span>
<span class="line" id="L738">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L739">                        result.id = .Invalid;</span>
<span class="line" id="L740">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L741">                    },</span>
<span class="line" id="L742">                },</span>
<span class="line" id="L743">                .OctalEscape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L744">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; {</span>
<span class="line" id="L745">                        counter += <span class="tok-number">1</span>;</span>
<span class="line" id="L746">                        <span class="tok-kw">if</span> (counter == <span class="tok-number">3</span>) {</span>
<span class="line" id="L747">                            state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L748">                        }</span>
<span class="line" id="L749">                    },</span>
<span class="line" id="L750">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L751">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L752">                        state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L753">                    },</span>
<span class="line" id="L754">                },</span>
<span class="line" id="L755">                .HexEscape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L756">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L757">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L758">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L759">                        state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L760">                    },</span>
<span class="line" id="L761">                },</span>
<span class="line" id="L762">                .UnicodeEscape =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L763">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L764">                        counter -= <span class="tok-number">1</span>;</span>
<span class="line" id="L765">                        <span class="tok-kw">if</span> (counter == <span class="tok-number">0</span>) {</span>
<span class="line" id="L766">                            state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L767">                        }</span>
<span class="line" id="L768">                    },</span>
<span class="line" id="L769">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L770">                        <span class="tok-kw">if</span> (counter != <span class="tok-number">0</span>) {</span>
<span class="line" id="L771">                            result.id = .Invalid;</span>
<span class="line" id="L772">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L773">                        }</span>
<span class="line" id="L774">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L775">                        state = <span class="tok-kw">if</span> (string) .StringLiteral <span class="tok-kw">else</span> .CharLiteral;</span>
<span class="line" id="L776">                    },</span>
<span class="line" id="L777">                },</span>
<span class="line" id="L778">                .Identifier =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L779">                    <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'_'</span>, <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'$'</span> =&gt; {},</span>
<span class="line" id="L780">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L781">                        result.id = Token.getKeyword(self.buffer[result.start..self.index], self.prev_tok_id == .Hash <span class="tok-kw">and</span> !self.pp_directive) <span class="tok-kw">orelse</span> .Identifier;</span>
<span class="line" id="L782">                        <span class="tok-kw">if</span> (self.prev_tok_id == .Hash)</span>
<span class="line" id="L783">                            self.pp_directive = <span class="tok-null">true</span>;</span>
<span class="line" id="L784">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L785">                    },</span>
<span class="line" id="L786">                },</span>
<span class="line" id="L787">                .Equal =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L788">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L789">                        result.id = .EqualEqual;</span>
<span class="line" id="L790">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L791">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L792">                    },</span>
<span class="line" id="L793">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L794">                        result.id = .Equal;</span>
<span class="line" id="L795">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L796">                    },</span>
<span class="line" id="L797">                },</span>
<span class="line" id="L798">                .Bang =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L799">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L800">                        result.id = .BangEqual;</span>
<span class="line" id="L801">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L802">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L803">                    },</span>
<span class="line" id="L804">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L805">                        result.id = .Bang;</span>
<span class="line" id="L806">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L807">                    },</span>
<span class="line" id="L808">                },</span>
<span class="line" id="L809">                .Pipe =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L810">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L811">                        result.id = .PipeEqual;</span>
<span class="line" id="L812">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L813">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L814">                    },</span>
<span class="line" id="L815">                    <span class="tok-str">'|'</span> =&gt; {</span>
<span class="line" id="L816">                        result.id = .PipePipe;</span>
<span class="line" id="L817">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L818">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L819">                    },</span>
<span class="line" id="L820">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L821">                        result.id = .Pipe;</span>
<span class="line" id="L822">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L823">                    },</span>
<span class="line" id="L824">                },</span>
<span class="line" id="L825">                .Percent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L826">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L827">                        result.id = .PercentEqual;</span>
<span class="line" id="L828">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L829">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L830">                    },</span>
<span class="line" id="L831">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L832">                        result.id = .Percent;</span>
<span class="line" id="L833">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L834">                    },</span>
<span class="line" id="L835">                },</span>
<span class="line" id="L836">                .Asterisk =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L837">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L838">                        result.id = .AsteriskEqual;</span>
<span class="line" id="L839">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L840">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L841">                    },</span>
<span class="line" id="L842">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L843">                        result.id = .Asterisk;</span>
<span class="line" id="L844">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L845">                    },</span>
<span class="line" id="L846">                },</span>
<span class="line" id="L847">                .Plus =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L848">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L849">                        result.id = .PlusEqual;</span>
<span class="line" id="L850">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L851">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L852">                    },</span>
<span class="line" id="L853">                    <span class="tok-str">'+'</span> =&gt; {</span>
<span class="line" id="L854">                        result.id = .PlusPlus;</span>
<span class="line" id="L855">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L856">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L857">                    },</span>
<span class="line" id="L858">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L859">                        result.id = .Plus;</span>
<span class="line" id="L860">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L861">                    },</span>
<span class="line" id="L862">                },</span>
<span class="line" id="L863">                .MacroString =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L864">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L865">                        result.id = .MacroString;</span>
<span class="line" id="L866">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L867">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L868">                    },</span>
<span class="line" id="L869">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L870">                },</span>
<span class="line" id="L871">                .AngleBracketLeft =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L872">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L873">                        state = .AngleBracketAngleBracketLeft;</span>
<span class="line" id="L874">                    },</span>
<span class="line" id="L875">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L876">                        result.id = .AngleBracketLeftEqual;</span>
<span class="line" id="L877">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L878">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L879">                    },</span>
<span class="line" id="L880">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L881">                        result.id = .AngleBracketLeft;</span>
<span class="line" id="L882">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L883">                    },</span>
<span class="line" id="L884">                },</span>
<span class="line" id="L885">                .AngleBracketAngleBracketLeft =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L886">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L887">                        result.id = .AngleBracketAngleBracketLeftEqual;</span>
<span class="line" id="L888">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L889">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L890">                    },</span>
<span class="line" id="L891">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L892">                        result.id = .AngleBracketAngleBracketLeft;</span>
<span class="line" id="L893">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L894">                    },</span>
<span class="line" id="L895">                },</span>
<span class="line" id="L896">                .AngleBracketRight =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L897">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L898">                        state = .AngleBracketAngleBracketRight;</span>
<span class="line" id="L899">                    },</span>
<span class="line" id="L900">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L901">                        result.id = .AngleBracketRightEqual;</span>
<span class="line" id="L902">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L903">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L904">                    },</span>
<span class="line" id="L905">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L906">                        result.id = .AngleBracketRight;</span>
<span class="line" id="L907">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L908">                    },</span>
<span class="line" id="L909">                },</span>
<span class="line" id="L910">                .AngleBracketAngleBracketRight =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L911">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L912">                        result.id = .AngleBracketAngleBracketRightEqual;</span>
<span class="line" id="L913">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L914">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L915">                    },</span>
<span class="line" id="L916">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L917">                        result.id = .AngleBracketAngleBracketRight;</span>
<span class="line" id="L918">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L919">                    },</span>
<span class="line" id="L920">                },</span>
<span class="line" id="L921">                .Caret =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L922">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L923">                        result.id = .CaretEqual;</span>
<span class="line" id="L924">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L925">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L926">                    },</span>
<span class="line" id="L927">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L928">                        result.id = .Caret;</span>
<span class="line" id="L929">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L930">                    },</span>
<span class="line" id="L931">                },</span>
<span class="line" id="L932">                .Period =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L933">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L934">                        state = .Period2;</span>
<span class="line" id="L935">                    },</span>
<span class="line" id="L936">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L937">                        state = .FloatFraction;</span>
<span class="line" id="L938">                    },</span>
<span class="line" id="L939">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L940">                        result.id = .Period;</span>
<span class="line" id="L941">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L942">                    },</span>
<span class="line" id="L943">                },</span>
<span class="line" id="L944">                .Period2 =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L945">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L946">                        result.id = .Ellipsis;</span>
<span class="line" id="L947">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L948">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L949">                    },</span>
<span class="line" id="L950">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L951">                        result.id = .Period;</span>
<span class="line" id="L952">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L953">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L954">                    },</span>
<span class="line" id="L955">                },</span>
<span class="line" id="L956">                .Minus =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L957">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L958">                        result.id = .Arrow;</span>
<span class="line" id="L959">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L960">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L961">                    },</span>
<span class="line" id="L962">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L963">                        result.id = .MinusEqual;</span>
<span class="line" id="L964">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L965">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L966">                    },</span>
<span class="line" id="L967">                    <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L968">                        result.id = .MinusMinus;</span>
<span class="line" id="L969">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L970">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L971">                    },</span>
<span class="line" id="L972">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L973">                        result.id = .Minus;</span>
<span class="line" id="L974">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L975">                    },</span>
<span class="line" id="L976">                },</span>
<span class="line" id="L977">                .Slash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L978">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L979">                        state = .LineComment;</span>
<span class="line" id="L980">                    },</span>
<span class="line" id="L981">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L982">                        state = .MultiLineComment;</span>
<span class="line" id="L983">                    },</span>
<span class="line" id="L984">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L985">                        result.id = .SlashEqual;</span>
<span class="line" id="L986">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L987">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L988">                    },</span>
<span class="line" id="L989">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L990">                        result.id = .Slash;</span>
<span class="line" id="L991">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L992">                    },</span>
<span class="line" id="L993">                },</span>
<span class="line" id="L994">                .Ampersand =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L995">                    <span class="tok-str">'&amp;'</span> =&gt; {</span>
<span class="line" id="L996">                        result.id = .AmpersandAmpersand;</span>
<span class="line" id="L997">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L998">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L999">                    },</span>
<span class="line" id="L1000">                    <span class="tok-str">'='</span> =&gt; {</span>
<span class="line" id="L1001">                        result.id = .AmpersandEqual;</span>
<span class="line" id="L1002">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1003">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1004">                    },</span>
<span class="line" id="L1005">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1006">                        result.id = .Ampersand;</span>
<span class="line" id="L1007">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1008">                    },</span>
<span class="line" id="L1009">                },</span>
<span class="line" id="L1010">                .Hash =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1011">                    <span class="tok-str">'#'</span> =&gt; {</span>
<span class="line" id="L1012">                        result.id = .HashHash;</span>
<span class="line" id="L1013">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1014">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1015">                    },</span>
<span class="line" id="L1016">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1017">                        result.id = .Hash;</span>
<span class="line" id="L1018">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1019">                    },</span>
<span class="line" id="L1020">                },</span>
<span class="line" id="L1021">                .LineComment =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1022">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L1023">                        result.id = .LineComment;</span>
<span class="line" id="L1024">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1025">                    },</span>
<span class="line" id="L1026">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1027">                },</span>
<span class="line" id="L1028">                .MultiLineComment =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1029">                    <span class="tok-str">'*'</span> =&gt; {</span>
<span class="line" id="L1030">                        state = .MultiLineCommentAsterisk;</span>
<span class="line" id="L1031">                    },</span>
<span class="line" id="L1032">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L1033">                },</span>
<span class="line" id="L1034">                .MultiLineCommentAsterisk =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1035">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L1036">                        result.id = .MultiLineComment;</span>
<span class="line" id="L1037">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1038">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1039">                    },</span>
<span class="line" id="L1040">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1041">                        state = .MultiLineComment;</span>
<span class="line" id="L1042">                    },</span>
<span class="line" id="L1043">                },</span>
<span class="line" id="L1044">                .Zero =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1045">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1046">                        state = .IntegerLiteralOct;</span>
<span class="line" id="L1047">                    },</span>
<span class="line" id="L1048">                    <span class="tok-str">'b'</span>, <span class="tok-str">'B'</span> =&gt; {</span>
<span class="line" id="L1049">                        state = .IntegerLiteralBinaryFirst;</span>
<span class="line" id="L1050">                    },</span>
<span class="line" id="L1051">                    <span class="tok-str">'x'</span>, <span class="tok-str">'X'</span> =&gt; {</span>
<span class="line" id="L1052">                        state = .IntegerLiteralHexFirst;</span>
<span class="line" id="L1053">                    },</span>
<span class="line" id="L1054">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1055">                        state = .FloatFraction;</span>
<span class="line" id="L1056">                    },</span>
<span class="line" id="L1057">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1058">                        state = .IntegerSuffix;</span>
<span class="line" id="L1059">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1060">                    },</span>
<span class="line" id="L1061">                },</span>
<span class="line" id="L1062">                .IntegerLiteralOct =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1063">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; {},</span>
<span class="line" id="L1064">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1065">                        state = .IntegerSuffix;</span>
<span class="line" id="L1066">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1067">                    },</span>
<span class="line" id="L1068">                },</span>
<span class="line" id="L1069">                .IntegerLiteralBinaryFirst =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1070">                    <span class="tok-str">'0'</span>...<span class="tok-str">'7'</span> =&gt; state = .IntegerLiteralBinary,</span>
<span class="line" id="L1071">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1072">                        result.id = .Invalid;</span>
<span class="line" id="L1073">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1074">                    },</span>
<span class="line" id="L1075">                },</span>
<span class="line" id="L1076">                .IntegerLiteralBinary =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1077">                    <span class="tok-str">'0'</span>, <span class="tok-str">'1'</span> =&gt; {},</span>
<span class="line" id="L1078">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1079">                        state = .IntegerSuffix;</span>
<span class="line" id="L1080">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1081">                    },</span>
<span class="line" id="L1082">                },</span>
<span class="line" id="L1083">                .IntegerLiteralHexFirst =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1084">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; state = .IntegerLiteralHex,</span>
<span class="line" id="L1085">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1086">                        state = .FloatFractionHex;</span>
<span class="line" id="L1087">                    },</span>
<span class="line" id="L1088">                    <span class="tok-str">'p'</span>, <span class="tok-str">'P'</span> =&gt; {</span>
<span class="line" id="L1089">                        state = .FloatExponent;</span>
<span class="line" id="L1090">                    },</span>
<span class="line" id="L1091">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1092">                        result.id = .Invalid;</span>
<span class="line" id="L1093">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1094">                    },</span>
<span class="line" id="L1095">                },</span>
<span class="line" id="L1096">                .IntegerLiteralHex =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1097">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L1098">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1099">                        state = .FloatFractionHex;</span>
<span class="line" id="L1100">                    },</span>
<span class="line" id="L1101">                    <span class="tok-str">'p'</span>, <span class="tok-str">'P'</span> =&gt; {</span>
<span class="line" id="L1102">                        state = .FloatExponent;</span>
<span class="line" id="L1103">                    },</span>
<span class="line" id="L1104">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1105">                        state = .IntegerSuffix;</span>
<span class="line" id="L1106">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1107">                    },</span>
<span class="line" id="L1108">                },</span>
<span class="line" id="L1109">                .IntegerLiteral =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1110">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L1111">                    <span class="tok-str">'.'</span> =&gt; {</span>
<span class="line" id="L1112">                        state = .FloatFraction;</span>
<span class="line" id="L1113">                    },</span>
<span class="line" id="L1114">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L1115">                        state = .FloatExponent;</span>
<span class="line" id="L1116">                    },</span>
<span class="line" id="L1117">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1118">                        state = .IntegerSuffix;</span>
<span class="line" id="L1119">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1120">                    },</span>
<span class="line" id="L1121">                },</span>
<span class="line" id="L1122">                .IntegerSuffix =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1123">                    <span class="tok-str">'u'</span>, <span class="tok-str">'U'</span> =&gt; {</span>
<span class="line" id="L1124">                        state = .IntegerSuffixU;</span>
<span class="line" id="L1125">                    },</span>
<span class="line" id="L1126">                    <span class="tok-str">'l'</span>, <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L1127">                        state = .IntegerSuffixL;</span>
<span class="line" id="L1128">                    },</span>
<span class="line" id="L1129">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1130">                        result.id = .{ .IntegerLiteral = .none };</span>
<span class="line" id="L1131">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1132">                    },</span>
<span class="line" id="L1133">                },</span>
<span class="line" id="L1134">                .IntegerSuffixU =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1135">                    <span class="tok-str">'l'</span>, <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L1136">                        state = .IntegerSuffixUL;</span>
<span class="line" id="L1137">                    },</span>
<span class="line" id="L1138">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1139">                        result.id = .{ .IntegerLiteral = .u };</span>
<span class="line" id="L1140">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1141">                    },</span>
<span class="line" id="L1142">                },</span>
<span class="line" id="L1143">                .IntegerSuffixL =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1144">                    <span class="tok-str">'l'</span>, <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L1145">                        state = .IntegerSuffixLL;</span>
<span class="line" id="L1146">                    },</span>
<span class="line" id="L1147">                    <span class="tok-str">'u'</span>, <span class="tok-str">'U'</span> =&gt; {</span>
<span class="line" id="L1148">                        result.id = .{ .IntegerLiteral = .lu };</span>
<span class="line" id="L1149">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1150">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1151">                    },</span>
<span class="line" id="L1152">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1153">                        result.id = .{ .IntegerLiteral = .l };</span>
<span class="line" id="L1154">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1155">                    },</span>
<span class="line" id="L1156">                },</span>
<span class="line" id="L1157">                .IntegerSuffixLL =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1158">                    <span class="tok-str">'u'</span>, <span class="tok-str">'U'</span> =&gt; {</span>
<span class="line" id="L1159">                        result.id = .{ .IntegerLiteral = .llu };</span>
<span class="line" id="L1160">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1161">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1162">                    },</span>
<span class="line" id="L1163">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1164">                        result.id = .{ .IntegerLiteral = .ll };</span>
<span class="line" id="L1165">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1166">                    },</span>
<span class="line" id="L1167">                },</span>
<span class="line" id="L1168">                .IntegerSuffixUL =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1169">                    <span class="tok-str">'l'</span>, <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L1170">                        result.id = .{ .IntegerLiteral = .llu };</span>
<span class="line" id="L1171">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1172">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1173">                    },</span>
<span class="line" id="L1174">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1175">                        result.id = .{ .IntegerLiteral = .lu };</span>
<span class="line" id="L1176">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1177">                    },</span>
<span class="line" id="L1178">                },</span>
<span class="line" id="L1179">                .FloatFraction =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1180">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {},</span>
<span class="line" id="L1181">                    <span class="tok-str">'e'</span>, <span class="tok-str">'E'</span> =&gt; {</span>
<span class="line" id="L1182">                        state = .FloatExponent;</span>
<span class="line" id="L1183">                    },</span>
<span class="line" id="L1184">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1185">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1186">                        state = .FloatSuffix;</span>
<span class="line" id="L1187">                    },</span>
<span class="line" id="L1188">                },</span>
<span class="line" id="L1189">                .FloatFractionHex =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1190">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'f'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'F'</span> =&gt; {},</span>
<span class="line" id="L1191">                    <span class="tok-str">'p'</span>, <span class="tok-str">'P'</span> =&gt; {</span>
<span class="line" id="L1192">                        state = .FloatExponent;</span>
<span class="line" id="L1193">                    },</span>
<span class="line" id="L1194">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1195">                        result.id = .Invalid;</span>
<span class="line" id="L1196">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1197">                    },</span>
<span class="line" id="L1198">                },</span>
<span class="line" id="L1199">                .FloatExponent =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1200">                    <span class="tok-str">'+'</span>, <span class="tok-str">'-'</span> =&gt; {</span>
<span class="line" id="L1201">                        state = .FloatExponentDigits;</span>
<span class="line" id="L1202">                    },</span>
<span class="line" id="L1203">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1204">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1205">                        state = .FloatExponentDigits;</span>
<span class="line" id="L1206">                    },</span>
<span class="line" id="L1207">                },</span>
<span class="line" id="L1208">                .FloatExponentDigits =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1209">                    <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; {</span>
<span class="line" id="L1210">                        counter += <span class="tok-number">1</span>;</span>
<span class="line" id="L1211">                    },</span>
<span class="line" id="L1212">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1213">                        <span class="tok-kw">if</span> (counter == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1214">                            result.id = .Invalid;</span>
<span class="line" id="L1215">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L1216">                        }</span>
<span class="line" id="L1217">                        self.index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1218">                        state = .FloatSuffix;</span>
<span class="line" id="L1219">                    },</span>
<span class="line" id="L1220">                },</span>
<span class="line" id="L1221">                .FloatSuffix =&gt; <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L1222">                    <span class="tok-str">'l'</span>, <span class="tok-str">'L'</span> =&gt; {</span>
<span class="line" id="L1223">                        result.id = .{ .FloatLiteral = .l };</span>
<span class="line" id="L1224">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1225">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1226">                    },</span>
<span class="line" id="L1227">                    <span class="tok-str">'f'</span>, <span class="tok-str">'F'</span> =&gt; {</span>
<span class="line" id="L1228">                        result.id = .{ .FloatLiteral = .f };</span>
<span class="line" id="L1229">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1230">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1231">                    },</span>
<span class="line" id="L1232">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1233">                        result.id = .{ .FloatLiteral = .none };</span>
<span class="line" id="L1234">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1235">                    },</span>
<span class="line" id="L1236">                },</span>
<span class="line" id="L1237">            }</span>
<span class="line" id="L1238">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.index == self.buffer.len) {</span>
<span class="line" id="L1239">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L1240">                .Start =&gt; {},</span>
<span class="line" id="L1241">                .u, .<span class="tok-type">u8</span>, .U, .L, .Identifier =&gt; {</span>
<span class="line" id="L1242">                    result.id = Token.getKeyword(self.buffer[result.start..self.index], self.prev_tok_id == .Hash <span class="tok-kw">and</span> !self.pp_directive) <span class="tok-kw">orelse</span> .Identifier;</span>
<span class="line" id="L1243">                },</span>
<span class="line" id="L1244"></span>
<span class="line" id="L1245">                .Cr,</span>
<span class="line" id="L1246">                .BackSlash,</span>
<span class="line" id="L1247">                .BackSlashCr,</span>
<span class="line" id="L1248">                .Period2,</span>
<span class="line" id="L1249">                .StringLiteral,</span>
<span class="line" id="L1250">                .CharLiteralStart,</span>
<span class="line" id="L1251">                .CharLiteral,</span>
<span class="line" id="L1252">                .EscapeSequence,</span>
<span class="line" id="L1253">                .CrEscape,</span>
<span class="line" id="L1254">                .OctalEscape,</span>
<span class="line" id="L1255">                .HexEscape,</span>
<span class="line" id="L1256">                .UnicodeEscape,</span>
<span class="line" id="L1257">                .MultiLineComment,</span>
<span class="line" id="L1258">                .MultiLineCommentAsterisk,</span>
<span class="line" id="L1259">                .FloatExponent,</span>
<span class="line" id="L1260">                .MacroString,</span>
<span class="line" id="L1261">                .IntegerLiteralBinaryFirst,</span>
<span class="line" id="L1262">                .IntegerLiteralHexFirst,</span>
<span class="line" id="L1263">                =&gt; result.id = .Invalid,</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265">                .FloatExponentDigits =&gt; result.id = <span class="tok-kw">if</span> (counter == <span class="tok-number">0</span>) .Invalid <span class="tok-kw">else</span> .{ .FloatLiteral = .none },</span>
<span class="line" id="L1266"></span>
<span class="line" id="L1267">                .FloatFraction,</span>
<span class="line" id="L1268">                .FloatFractionHex,</span>
<span class="line" id="L1269">                =&gt; result.id = .{ .FloatLiteral = .none },</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">                .IntegerLiteralOct,</span>
<span class="line" id="L1272">                .IntegerLiteralBinary,</span>
<span class="line" id="L1273">                .IntegerLiteralHex,</span>
<span class="line" id="L1274">                .IntegerLiteral,</span>
<span class="line" id="L1275">                .IntegerSuffix,</span>
<span class="line" id="L1276">                .Zero,</span>
<span class="line" id="L1277">                =&gt; result.id = .{ .IntegerLiteral = .none },</span>
<span class="line" id="L1278">                .IntegerSuffixU =&gt; result.id = .{ .IntegerLiteral = .u },</span>
<span class="line" id="L1279">                .IntegerSuffixL =&gt; result.id = .{ .IntegerLiteral = .l },</span>
<span class="line" id="L1280">                .IntegerSuffixLL =&gt; result.id = .{ .IntegerLiteral = .ll },</span>
<span class="line" id="L1281">                .IntegerSuffixUL =&gt; result.id = .{ .IntegerLiteral = .lu },</span>
<span class="line" id="L1282"></span>
<span class="line" id="L1283">                .FloatSuffix =&gt; result.id = .{ .FloatLiteral = .none },</span>
<span class="line" id="L1284">                .Equal =&gt; result.id = .Equal,</span>
<span class="line" id="L1285">                .Bang =&gt; result.id = .Bang,</span>
<span class="line" id="L1286">                .Minus =&gt; result.id = .Minus,</span>
<span class="line" id="L1287">                .Slash =&gt; result.id = .Slash,</span>
<span class="line" id="L1288">                .Ampersand =&gt; result.id = .Ampersand,</span>
<span class="line" id="L1289">                .Hash =&gt; result.id = .Hash,</span>
<span class="line" id="L1290">                .Period =&gt; result.id = .Period,</span>
<span class="line" id="L1291">                .Pipe =&gt; result.id = .Pipe,</span>
<span class="line" id="L1292">                .AngleBracketAngleBracketRight =&gt; result.id = .AngleBracketAngleBracketRight,</span>
<span class="line" id="L1293">                .AngleBracketRight =&gt; result.id = .AngleBracketRight,</span>
<span class="line" id="L1294">                .AngleBracketAngleBracketLeft =&gt; result.id = .AngleBracketAngleBracketLeft,</span>
<span class="line" id="L1295">                .AngleBracketLeft =&gt; result.id = .AngleBracketLeft,</span>
<span class="line" id="L1296">                .Plus =&gt; result.id = .Plus,</span>
<span class="line" id="L1297">                .Percent =&gt; result.id = .Percent,</span>
<span class="line" id="L1298">                .Caret =&gt; result.id = .Caret,</span>
<span class="line" id="L1299">                .Asterisk =&gt; result.id = .Asterisk,</span>
<span class="line" id="L1300">                .LineComment =&gt; result.id = .LineComment,</span>
<span class="line" id="L1301">            }</span>
<span class="line" id="L1302">        }</span>
<span class="line" id="L1303"></span>
<span class="line" id="L1304">        self.prev_tok_id = result.id;</span>
<span class="line" id="L1305">        result.end = self.index;</span>
<span class="line" id="L1306">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1307">    }</span>
<span class="line" id="L1308">};</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310"><span class="tok-kw">test</span> <span class="tok-str">&quot;operators&quot;</span> {</span>
<span class="line" id="L1311">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1312">        <span class="tok-str">\\ ! != | || |= = ==</span></span>

<span class="line" id="L1313">        <span class="tok-str">\\ ( ) { } [ ] . .. ...</span></span>

<span class="line" id="L1314">        <span class="tok-str">\\ ^ ^= + ++ += - -- -=</span></span>

<span class="line" id="L1315">        <span class="tok-str">\\ * *= % %= -&gt; : ; / /=</span></span>

<span class="line" id="L1316">        <span class="tok-str">\\ , &amp; &amp;&amp; &amp;= ? &lt; &lt;= &lt;&lt;</span></span>

<span class="line" id="L1317">        <span class="tok-str">\\  &lt;&lt;= &gt; &gt;= &gt;&gt; &gt;&gt;= ~ # ##</span></span>

<span class="line" id="L1318">        <span class="tok-str">\\</span></span>

<span class="line" id="L1319">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1320">        .Bang,</span>
<span class="line" id="L1321">        .BangEqual,</span>
<span class="line" id="L1322">        .Pipe,</span>
<span class="line" id="L1323">        .PipePipe,</span>
<span class="line" id="L1324">        .PipeEqual,</span>
<span class="line" id="L1325">        .Equal,</span>
<span class="line" id="L1326">        .EqualEqual,</span>
<span class="line" id="L1327">        .Nl,</span>
<span class="line" id="L1328">        .LParen,</span>
<span class="line" id="L1329">        .RParen,</span>
<span class="line" id="L1330">        .LBrace,</span>
<span class="line" id="L1331">        .RBrace,</span>
<span class="line" id="L1332">        .LBracket,</span>
<span class="line" id="L1333">        .RBracket,</span>
<span class="line" id="L1334">        .Period,</span>
<span class="line" id="L1335">        .Period,</span>
<span class="line" id="L1336">        .Period,</span>
<span class="line" id="L1337">        .Ellipsis,</span>
<span class="line" id="L1338">        .Nl,</span>
<span class="line" id="L1339">        .Caret,</span>
<span class="line" id="L1340">        .CaretEqual,</span>
<span class="line" id="L1341">        .Plus,</span>
<span class="line" id="L1342">        .PlusPlus,</span>
<span class="line" id="L1343">        .PlusEqual,</span>
<span class="line" id="L1344">        .Minus,</span>
<span class="line" id="L1345">        .MinusMinus,</span>
<span class="line" id="L1346">        .MinusEqual,</span>
<span class="line" id="L1347">        .Nl,</span>
<span class="line" id="L1348">        .Asterisk,</span>
<span class="line" id="L1349">        .AsteriskEqual,</span>
<span class="line" id="L1350">        .Percent,</span>
<span class="line" id="L1351">        .PercentEqual,</span>
<span class="line" id="L1352">        .Arrow,</span>
<span class="line" id="L1353">        .Colon,</span>
<span class="line" id="L1354">        .Semicolon,</span>
<span class="line" id="L1355">        .Slash,</span>
<span class="line" id="L1356">        .SlashEqual,</span>
<span class="line" id="L1357">        .Nl,</span>
<span class="line" id="L1358">        .Comma,</span>
<span class="line" id="L1359">        .Ampersand,</span>
<span class="line" id="L1360">        .AmpersandAmpersand,</span>
<span class="line" id="L1361">        .AmpersandEqual,</span>
<span class="line" id="L1362">        .QuestionMark,</span>
<span class="line" id="L1363">        .AngleBracketLeft,</span>
<span class="line" id="L1364">        .AngleBracketLeftEqual,</span>
<span class="line" id="L1365">        .AngleBracketAngleBracketLeft,</span>
<span class="line" id="L1366">        .Nl,</span>
<span class="line" id="L1367">        .AngleBracketAngleBracketLeftEqual,</span>
<span class="line" id="L1368">        .AngleBracketRight,</span>
<span class="line" id="L1369">        .AngleBracketRightEqual,</span>
<span class="line" id="L1370">        .AngleBracketAngleBracketRight,</span>
<span class="line" id="L1371">        .AngleBracketAngleBracketRightEqual,</span>
<span class="line" id="L1372">        .Tilde,</span>
<span class="line" id="L1373">        .Hash,</span>
<span class="line" id="L1374">        .HashHash,</span>
<span class="line" id="L1375">        .Nl,</span>
<span class="line" id="L1376">    });</span>
<span class="line" id="L1377">}</span>
<span class="line" id="L1378"></span>
<span class="line" id="L1379"><span class="tok-kw">test</span> <span class="tok-str">&quot;keywords&quot;</span> {</span>
<span class="line" id="L1380">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1381">        <span class="tok-str">\\auto break case char const continue default do</span></span>

<span class="line" id="L1382">        <span class="tok-str">\\double else enum extern float for goto if int</span></span>

<span class="line" id="L1383">        <span class="tok-str">\\long register return short signed sizeof static</span></span>

<span class="line" id="L1384">        <span class="tok-str">\\struct switch typedef union unsigned void volatile</span></span>

<span class="line" id="L1385">        <span class="tok-str">\\while _Bool _Complex _Imaginary inline restrict _Alignas</span></span>

<span class="line" id="L1386">        <span class="tok-str">\\_Alignof _Atomic _Generic _Noreturn _Static_assert _Thread_local</span></span>

<span class="line" id="L1387">        <span class="tok-str">\\</span></span>

<span class="line" id="L1388">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1389">        .Keyword_auto,</span>
<span class="line" id="L1390">        .Keyword_break,</span>
<span class="line" id="L1391">        .Keyword_case,</span>
<span class="line" id="L1392">        .Keyword_char,</span>
<span class="line" id="L1393">        .Keyword_const,</span>
<span class="line" id="L1394">        .Keyword_continue,</span>
<span class="line" id="L1395">        .Keyword_default,</span>
<span class="line" id="L1396">        .Keyword_do,</span>
<span class="line" id="L1397">        .Nl,</span>
<span class="line" id="L1398">        .Keyword_double,</span>
<span class="line" id="L1399">        .Keyword_else,</span>
<span class="line" id="L1400">        .Keyword_enum,</span>
<span class="line" id="L1401">        .Keyword_extern,</span>
<span class="line" id="L1402">        .Keyword_float,</span>
<span class="line" id="L1403">        .Keyword_for,</span>
<span class="line" id="L1404">        .Keyword_goto,</span>
<span class="line" id="L1405">        .Keyword_if,</span>
<span class="line" id="L1406">        .Keyword_int,</span>
<span class="line" id="L1407">        .Nl,</span>
<span class="line" id="L1408">        .Keyword_long,</span>
<span class="line" id="L1409">        .Keyword_register,</span>
<span class="line" id="L1410">        .Keyword_return,</span>
<span class="line" id="L1411">        .Keyword_short,</span>
<span class="line" id="L1412">        .Keyword_signed,</span>
<span class="line" id="L1413">        .Keyword_sizeof,</span>
<span class="line" id="L1414">        .Keyword_static,</span>
<span class="line" id="L1415">        .Nl,</span>
<span class="line" id="L1416">        .Keyword_struct,</span>
<span class="line" id="L1417">        .Keyword_switch,</span>
<span class="line" id="L1418">        .Keyword_typedef,</span>
<span class="line" id="L1419">        .Keyword_union,</span>
<span class="line" id="L1420">        .Keyword_unsigned,</span>
<span class="line" id="L1421">        .Keyword_void,</span>
<span class="line" id="L1422">        .Keyword_volatile,</span>
<span class="line" id="L1423">        .Nl,</span>
<span class="line" id="L1424">        .Keyword_while,</span>
<span class="line" id="L1425">        .Keyword_bool,</span>
<span class="line" id="L1426">        .Keyword_complex,</span>
<span class="line" id="L1427">        .Keyword_imaginary,</span>
<span class="line" id="L1428">        .Keyword_inline,</span>
<span class="line" id="L1429">        .Keyword_restrict,</span>
<span class="line" id="L1430">        .Keyword_alignas,</span>
<span class="line" id="L1431">        .Nl,</span>
<span class="line" id="L1432">        .Keyword_alignof,</span>
<span class="line" id="L1433">        .Keyword_atomic,</span>
<span class="line" id="L1434">        .Keyword_generic,</span>
<span class="line" id="L1435">        .Keyword_noreturn,</span>
<span class="line" id="L1436">        .Keyword_static_assert,</span>
<span class="line" id="L1437">        .Keyword_thread_local,</span>
<span class="line" id="L1438">        .Nl,</span>
<span class="line" id="L1439">    });</span>
<span class="line" id="L1440">}</span>
<span class="line" id="L1441"></span>
<span class="line" id="L1442"><span class="tok-kw">test</span> <span class="tok-str">&quot;preprocessor keywords&quot;</span> {</span>
<span class="line" id="L1443">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1444">        <span class="tok-str">\\#include &lt;test&gt;</span></span>

<span class="line" id="L1445">        <span class="tok-str">\\#define #include &lt;1</span></span>

<span class="line" id="L1446">        <span class="tok-str">\\#ifdef</span></span>

<span class="line" id="L1447">        <span class="tok-str">\\#ifndef</span></span>

<span class="line" id="L1448">        <span class="tok-str">\\#error</span></span>

<span class="line" id="L1449">        <span class="tok-str">\\#pragma</span></span>

<span class="line" id="L1450">        <span class="tok-str">\\</span></span>

<span class="line" id="L1451">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1452">        .Hash,</span>
<span class="line" id="L1453">        .Keyword_include,</span>
<span class="line" id="L1454">        .MacroString,</span>
<span class="line" id="L1455">        .Nl,</span>
<span class="line" id="L1456">        .Hash,</span>
<span class="line" id="L1457">        .Keyword_define,</span>
<span class="line" id="L1458">        .Hash,</span>
<span class="line" id="L1459">        .Identifier,</span>
<span class="line" id="L1460">        .AngleBracketLeft,</span>
<span class="line" id="L1461">        .{ .IntegerLiteral = .none },</span>
<span class="line" id="L1462">        .Nl,</span>
<span class="line" id="L1463">        .Hash,</span>
<span class="line" id="L1464">        .Keyword_ifdef,</span>
<span class="line" id="L1465">        .Nl,</span>
<span class="line" id="L1466">        .Hash,</span>
<span class="line" id="L1467">        .Keyword_ifndef,</span>
<span class="line" id="L1468">        .Nl,</span>
<span class="line" id="L1469">        .Hash,</span>
<span class="line" id="L1470">        .Keyword_error,</span>
<span class="line" id="L1471">        .Nl,</span>
<span class="line" id="L1472">        .Hash,</span>
<span class="line" id="L1473">        .Keyword_pragma,</span>
<span class="line" id="L1474">        .Nl,</span>
<span class="line" id="L1475">    });</span>
<span class="line" id="L1476">}</span>
<span class="line" id="L1477"></span>
<span class="line" id="L1478"><span class="tok-kw">test</span> <span class="tok-str">&quot;line continuation&quot;</span> {</span>
<span class="line" id="L1479">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1480">        <span class="tok-str">\\#define foo \</span></span>

<span class="line" id="L1481">        <span class="tok-str">\\  bar</span></span>

<span class="line" id="L1482">        <span class="tok-str">\\&quot;foo\</span></span>

<span class="line" id="L1483">        <span class="tok-str">\\ bar&quot;</span></span>

<span class="line" id="L1484">        <span class="tok-str">\\#define &quot;foo&quot;</span></span>

<span class="line" id="L1485">        <span class="tok-str">\\ &quot;bar&quot;</span></span>

<span class="line" id="L1486">        <span class="tok-str">\\#define &quot;foo&quot; \</span></span>

<span class="line" id="L1487">        <span class="tok-str">\\ &quot;bar&quot;</span></span>

<span class="line" id="L1488">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1489">        .Hash,</span>
<span class="line" id="L1490">        .Keyword_define,</span>
<span class="line" id="L1491">        .Identifier,</span>
<span class="line" id="L1492">        .Identifier,</span>
<span class="line" id="L1493">        .Nl,</span>
<span class="line" id="L1494">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1495">        .Nl,</span>
<span class="line" id="L1496">        .Hash,</span>
<span class="line" id="L1497">        .Keyword_define,</span>
<span class="line" id="L1498">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1499">        .Nl,</span>
<span class="line" id="L1500">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1501">        .Nl,</span>
<span class="line" id="L1502">        .Hash,</span>
<span class="line" id="L1503">        .Keyword_define,</span>
<span class="line" id="L1504">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1505">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1506">    });</span>
<span class="line" id="L1507">}</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509"><span class="tok-kw">test</span> <span class="tok-str">&quot;string prefix&quot;</span> {</span>
<span class="line" id="L1510">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1511">        <span class="tok-str">\\&quot;foo&quot;</span></span>

<span class="line" id="L1512">        <span class="tok-str">\\u&quot;foo&quot;</span></span>

<span class="line" id="L1513">        <span class="tok-str">\\u8&quot;foo&quot;</span></span>

<span class="line" id="L1514">        <span class="tok-str">\\U&quot;foo&quot;</span></span>

<span class="line" id="L1515">        <span class="tok-str">\\L&quot;foo&quot;</span></span>

<span class="line" id="L1516">        <span class="tok-str">\\'foo'</span></span>

<span class="line" id="L1517">        <span class="tok-str">\\u'foo'</span></span>

<span class="line" id="L1518">        <span class="tok-str">\\U'foo'</span></span>

<span class="line" id="L1519">        <span class="tok-str">\\L'foo'</span></span>

<span class="line" id="L1520">        <span class="tok-str">\\</span></span>

<span class="line" id="L1521">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1522">        .{ .StringLiteral = .none },</span>
<span class="line" id="L1523">        .Nl,</span>
<span class="line" id="L1524">        .{ .StringLiteral = .utf_16 },</span>
<span class="line" id="L1525">        .Nl,</span>
<span class="line" id="L1526">        .{ .StringLiteral = .utf_8 },</span>
<span class="line" id="L1527">        .Nl,</span>
<span class="line" id="L1528">        .{ .StringLiteral = .utf_32 },</span>
<span class="line" id="L1529">        .Nl,</span>
<span class="line" id="L1530">        .{ .StringLiteral = .wide },</span>
<span class="line" id="L1531">        .Nl,</span>
<span class="line" id="L1532">        .{ .CharLiteral = .none },</span>
<span class="line" id="L1533">        .Nl,</span>
<span class="line" id="L1534">        .{ .CharLiteral = .utf_16 },</span>
<span class="line" id="L1535">        .Nl,</span>
<span class="line" id="L1536">        .{ .CharLiteral = .utf_32 },</span>
<span class="line" id="L1537">        .Nl,</span>
<span class="line" id="L1538">        .{ .CharLiteral = .wide },</span>
<span class="line" id="L1539">        .Nl,</span>
<span class="line" id="L1540">    });</span>
<span class="line" id="L1541">}</span>
<span class="line" id="L1542"></span>
<span class="line" id="L1543"><span class="tok-kw">test</span> <span class="tok-str">&quot;num suffixes&quot;</span> {</span>
<span class="line" id="L1544">    <span class="tok-kw">try</span> expectTokens(</span>
<span class="line" id="L1545">        <span class="tok-str">\\ 1.0f 1.0L 1.0 .0 1.</span></span>

<span class="line" id="L1546">        <span class="tok-str">\\ 0l 0lu 0ll 0llu 0</span></span>

<span class="line" id="L1547">        <span class="tok-str">\\ 1u 1ul 1ull 1</span></span>

<span class="line" id="L1548">        <span class="tok-str">\\ 0x 0b</span></span>

<span class="line" id="L1549">        <span class="tok-str">\\</span></span>

<span class="line" id="L1550">    , &amp;[_]Token.Id{</span>
<span class="line" id="L1551">        .{ .FloatLiteral = .f },</span>
<span class="line" id="L1552">        .{ .FloatLiteral = .l },</span>
<span class="line" id="L1553">        .{ .FloatLiteral = .none },</span>
<span class="line" id="L1554">        .{ .FloatLiteral = .none },</span>
<span class="line" id="L1555">        .{ .FloatLiteral = .none },</span>
<span class="line" id="L1556">        .Nl,</span>
<span class="line" id="L1557">        .{ .IntegerLiteral = .l },</span>
<span class="line" id="L1558">        .{ .IntegerLiteral = .lu },</span>
<span class="line" id="L1559">        .{ .IntegerLiteral = .ll },</span>
<span class="line" id="L1560">        .{ .IntegerLiteral = .llu },</span>
<span class="line" id="L1561">        .{ .IntegerLiteral = .none },</span>
<span class="line" id="L1562">        .Nl,</span>
<span class="line" id="L1563">        .{ .IntegerLiteral = .u },</span>
<span class="line" id="L1564">        .{ .IntegerLiteral = .lu },</span>
<span class="line" id="L1565">        .{ .IntegerLiteral = .llu },</span>
<span class="line" id="L1566">        .{ .IntegerLiteral = .none },</span>
<span class="line" id="L1567">        .Nl,</span>
<span class="line" id="L1568">        .Invalid,</span>
<span class="line" id="L1569">        .Invalid,</span>
<span class="line" id="L1570">        .Nl,</span>
<span class="line" id="L1571">    });</span>
<span class="line" id="L1572">}</span>
<span class="line" id="L1573"></span>
<span class="line" id="L1574"><span class="tok-kw">fn</span> <span class="tok-fn">expectTokens</span>(source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_tokens: []<span class="tok-kw">const</span> Token.Id) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1575">    <span class="tok-kw">var</span> tokenizer = Tokenizer{</span>
<span class="line" id="L1576">        .buffer = source,</span>
<span class="line" id="L1577">    };</span>
<span class="line" id="L1578">    <span class="tok-kw">for</span> (expected_tokens) |expected_token_id| {</span>
<span class="line" id="L1579">        <span class="tok-kw">const</span> token = tokenizer.next();</span>
<span class="line" id="L1580">        <span class="tok-kw">if</span> (!std.meta.eql(token.id, expected_token_id)) {</span>
<span class="line" id="L1581">            std.debug.panic(<span class="tok-str">&quot;expected {s}, found {s}\n&quot;</span>, .{ <span class="tok-builtin">@tagName</span>(expected_token_id), <span class="tok-builtin">@tagName</span>(token.id) });</span>
<span class="line" id="L1582">        }</span>
<span class="line" id="L1583">    }</span>
<span class="line" id="L1584">    <span class="tok-kw">const</span> last_token = tokenizer.next();</span>
<span class="line" id="L1585">    <span class="tok-kw">try</span> std.testing.expect(last_token.id == .Eof);</span>
<span class="line" id="L1586">}</span>
<span class="line" id="L1587"></span>
</code></pre></body>
</html>