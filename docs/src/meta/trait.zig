<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>meta/trait.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> meta = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../meta.zig&quot;</span>);</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TraitFn = <span class="tok-kw">fn</span> (<span class="tok-type">type</span>) <span class="tok-type">bool</span>;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">multiTrait</span>(<span class="tok-kw">comptime</span> traits: <span class="tok-kw">anytype</span>) TraitFn {</span>
<span class="line" id="L11">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L13">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (traits) |t|</span>
<span class="line" id="L14">                <span class="tok-kw">if</span> (!t(T)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L15">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L16">        }</span>
<span class="line" id="L17">    };</span>
<span class="line" id="L18">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L19">}</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">test</span> <span class="tok-str">&quot;multiTrait&quot;</span> {</span>
<span class="line" id="L22">    <span class="tok-kw">const</span> Vector2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L23">        <span class="tok-kw">const</span> MyType = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        x: <span class="tok-type">u8</span>,</span>
<span class="line" id="L26">        y: <span class="tok-type">u8</span>,</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(self: MyType, other: MyType) MyType {</span>
<span class="line" id="L29">            <span class="tok-kw">return</span> MyType{</span>
<span class="line" id="L30">                .x = self.x + other.x,</span>
<span class="line" id="L31">                .y = self.y + other.y,</span>
<span class="line" id="L32">            };</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">    };</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">const</span> isVector = multiTrait(.{</span>
<span class="line" id="L37">        hasFn(<span class="tok-str">&quot;add&quot;</span>),</span>
<span class="line" id="L38">        hasField(<span class="tok-str">&quot;x&quot;</span>),</span>
<span class="line" id="L39">        hasField(<span class="tok-str">&quot;y&quot;</span>),</span>
<span class="line" id="L40">    });</span>
<span class="line" id="L41">    <span class="tok-kw">try</span> testing.expect(isVector(Vector2));</span>
<span class="line" id="L42">    <span class="tok-kw">try</span> testing.expect(!isVector(<span class="tok-type">u8</span>));</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasFn</span>(<span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) TraitFn {</span>
<span class="line" id="L46">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L47">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L48">            <span class="tok-kw">if</span> (!<span class="tok-kw">comptime</span> isContainer(T)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L49">            <span class="tok-kw">if</span> (!<span class="tok-kw">comptime</span> <span class="tok-builtin">@hasDecl</span>(T, name)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L50">            <span class="tok-kw">const</span> DeclType = <span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@field</span>(T, name));</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(DeclType) == .Fn;</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53">    };</span>
<span class="line" id="L54">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L55">}</span>
<span class="line" id="L56"></span>
<span class="line" id="L57"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasFn&quot;</span> {</span>
<span class="line" id="L58">    <span class="tok-kw">const</span> TestStruct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L59">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">useless</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L60">    };</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-kw">try</span> testing.expect(hasFn(<span class="tok-str">&quot;useless&quot;</span>)(TestStruct));</span>
<span class="line" id="L63">    <span class="tok-kw">try</span> testing.expect(!hasFn(<span class="tok-str">&quot;append&quot;</span>)(TestStruct));</span>
<span class="line" id="L64">    <span class="tok-kw">try</span> testing.expect(!hasFn(<span class="tok-str">&quot;useless&quot;</span>)(<span class="tok-type">u8</span>));</span>
<span class="line" id="L65">}</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasField</span>(<span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) TraitFn {</span>
<span class="line" id="L68">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L69">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L70">            <span class="tok-kw">const</span> fields = <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L71">                .Struct =&gt; |s| s.fields,</span>
<span class="line" id="L72">                .Union =&gt; |u| u.fields,</span>
<span class="line" id="L73">                .Enum =&gt; |e| e.fields,</span>
<span class="line" id="L74">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L75">            };</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields) |field| {</span>
<span class="line" id="L78">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, field.name, name)) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L79">            }</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L82">        }</span>
<span class="line" id="L83">    };</span>
<span class="line" id="L84">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L85">}</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasField&quot;</span> {</span>
<span class="line" id="L88">    <span class="tok-kw">const</span> TestStruct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L89">        value: <span class="tok-type">u32</span>,</span>
<span class="line" id="L90">    };</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">try</span> testing.expect(hasField(<span class="tok-str">&quot;value&quot;</span>)(TestStruct));</span>
<span class="line" id="L93">    <span class="tok-kw">try</span> testing.expect(!hasField(<span class="tok-str">&quot;value&quot;</span>)(*TestStruct));</span>
<span class="line" id="L94">    <span class="tok-kw">try</span> testing.expect(!hasField(<span class="tok-str">&quot;x&quot;</span>)(TestStruct));</span>
<span class="line" id="L95">    <span class="tok-kw">try</span> testing.expect(!hasField(<span class="tok-str">&quot;x&quot;</span>)(**TestStruct));</span>
<span class="line" id="L96">    <span class="tok-kw">try</span> testing.expect(!hasField(<span class="tok-str">&quot;value&quot;</span>)(<span class="tok-type">u8</span>));</span>
<span class="line" id="L97">}</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">is</span>(<span class="tok-kw">comptime</span> id: std.builtin.TypeId) TraitFn {</span>
<span class="line" id="L100">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L101">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L102">            <span class="tok-kw">return</span> id == <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L103">        }</span>
<span class="line" id="L104">    };</span>
<span class="line" id="L105">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L106">}</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-kw">test</span> <span class="tok-str">&quot;is&quot;</span> {</span>
<span class="line" id="L109">    <span class="tok-kw">try</span> testing.expect(is(.Int)(<span class="tok-type">u8</span>));</span>
<span class="line" id="L110">    <span class="tok-kw">try</span> testing.expect(!is(.Int)(<span class="tok-type">f32</span>));</span>
<span class="line" id="L111">    <span class="tok-kw">try</span> testing.expect(is(.Pointer)(*<span class="tok-type">u8</span>));</span>
<span class="line" id="L112">    <span class="tok-kw">try</span> testing.expect(is(.Void)(<span class="tok-type">void</span>));</span>
<span class="line" id="L113">    <span class="tok-kw">try</span> testing.expect(!is(.Optional)(<span class="tok-type">anyerror</span>));</span>
<span class="line" id="L114">}</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPtrTo</span>(<span class="tok-kw">comptime</span> id: std.builtin.TypeId) TraitFn {</span>
<span class="line" id="L117">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L118">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L119">            <span class="tok-kw">if</span> (!<span class="tok-kw">comptime</span> isSingleItemPtr(T)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L120">            <span class="tok-kw">return</span> id == <span class="tok-builtin">@typeInfo</span>(meta.Child(T));</span>
<span class="line" id="L121">        }</span>
<span class="line" id="L122">    };</span>
<span class="line" id="L123">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L124">}</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-kw">test</span> <span class="tok-str">&quot;isPtrTo&quot;</span> {</span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expect(!isPtrTo(.Struct)(<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L128">    <span class="tok-kw">try</span> testing.expect(isPtrTo(.Struct)(*<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L129">    <span class="tok-kw">try</span> testing.expect(!isPtrTo(.Struct)(**<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L130">}</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSliceOf</span>(<span class="tok-kw">comptime</span> id: std.builtin.TypeId) TraitFn {</span>
<span class="line" id="L133">    <span class="tok-kw">const</span> Closure = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L134">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">trait</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L135">            <span class="tok-kw">if</span> (!<span class="tok-kw">comptime</span> isSlice(T)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L136">            <span class="tok-kw">return</span> id == <span class="tok-builtin">@typeInfo</span>(meta.Child(T));</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138">    };</span>
<span class="line" id="L139">    <span class="tok-kw">return</span> Closure.trait;</span>
<span class="line" id="L140">}</span>
<span class="line" id="L141"></span>
<span class="line" id="L142"><span class="tok-kw">test</span> <span class="tok-str">&quot;isSliceOf&quot;</span> {</span>
<span class="line" id="L143">    <span class="tok-kw">try</span> testing.expect(!isSliceOf(.Struct)(<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> testing.expect(isSliceOf(.Struct)([]<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> testing.expect(!isSliceOf(.Struct)([][]<span class="tok-kw">struct</span> {}));</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-comment">///////////Strait trait Fns</span>
</span>
<span class="line" id="L149"></span>
<span class="line" id="L150"><span class="tok-comment">//@TODO:</span>
</span>
<span class="line" id="L151"><span class="tok-comment">// Somewhat limited since we can't apply this logic to normal variables, fields, or</span>
</span>
<span class="line" id="L152"><span class="tok-comment">//  Fns yet. Should be isExternType?</span>
</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isExtern</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L154">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L155">        .Struct =&gt; |s| s.layout == .Extern,</span>
<span class="line" id="L156">        .Union =&gt; |u| u.layout == .Extern,</span>
<span class="line" id="L157">        .Enum =&gt; |e| e.layout == .Extern,</span>
<span class="line" id="L158">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L159">    };</span>
<span class="line" id="L160">}</span>
<span class="line" id="L161"></span>
<span class="line" id="L162"><span class="tok-kw">test</span> <span class="tok-str">&quot;isExtern&quot;</span> {</span>
<span class="line" id="L163">    <span class="tok-kw">const</span> TestExStruct = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L164">    <span class="tok-kw">const</span> TestStruct = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-kw">try</span> testing.expect(isExtern(TestExStruct));</span>
<span class="line" id="L167">    <span class="tok-kw">try</span> testing.expect(!isExtern(TestStruct));</span>
<span class="line" id="L168">    <span class="tok-kw">try</span> testing.expect(!isExtern(<span class="tok-type">u8</span>));</span>
<span class="line" id="L169">}</span>
<span class="line" id="L170"></span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPacked</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L172">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L173">        .Struct =&gt; |s| s.layout == .Packed,</span>
<span class="line" id="L174">        .Union =&gt; |u| u.layout == .Packed,</span>
<span class="line" id="L175">        .Enum =&gt; |e| e.layout == .Packed,</span>
<span class="line" id="L176">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L177">    };</span>
<span class="line" id="L178">}</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-kw">test</span> <span class="tok-str">&quot;isPacked&quot;</span> {</span>
<span class="line" id="L181">    <span class="tok-kw">const</span> TestPStruct = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L182">    <span class="tok-kw">const</span> TestStruct = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">try</span> testing.expect(isPacked(TestPStruct));</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> testing.expect(!isPacked(TestStruct));</span>
<span class="line" id="L186">    <span class="tok-kw">try</span> testing.expect(!isPacked(<span class="tok-type">u8</span>));</span>
<span class="line" id="L187">}</span>
<span class="line" id="L188"></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUnsignedInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L190">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L191">        .Int =&gt; |i| i.signedness == .unsigned,</span>
<span class="line" id="L192">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L193">    };</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">test</span> <span class="tok-str">&quot;isUnsignedInt&quot;</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">try</span> testing.expect(isUnsignedInt(<span class="tok-type">u32</span>) == <span class="tok-null">true</span>);</span>
<span class="line" id="L198">    <span class="tok-kw">try</span> testing.expect(isUnsignedInt(<span class="tok-type">comptime_int</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L199">    <span class="tok-kw">try</span> testing.expect(isUnsignedInt(<span class="tok-type">i64</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L200">    <span class="tok-kw">try</span> testing.expect(isUnsignedInt(<span class="tok-type">f64</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSignedInt</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L204">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L205">        .ComptimeInt =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L206">        .Int =&gt; |i| i.signedness == .signed,</span>
<span class="line" id="L207">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L208">    };</span>
<span class="line" id="L209">}</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-kw">test</span> <span class="tok-str">&quot;isSignedInt&quot;</span> {</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> testing.expect(isSignedInt(<span class="tok-type">u32</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L213">    <span class="tok-kw">try</span> testing.expect(isSignedInt(<span class="tok-type">comptime_int</span>) == <span class="tok-null">true</span>);</span>
<span class="line" id="L214">    <span class="tok-kw">try</span> testing.expect(isSignedInt(<span class="tok-type">i64</span>) == <span class="tok-null">true</span>);</span>
<span class="line" id="L215">    <span class="tok-kw">try</span> testing.expect(isSignedInt(<span class="tok-type">f64</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L216">}</span>
<span class="line" id="L217"></span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSingleItemPtr</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L219">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> is(.Pointer)(T)) {</span>
<span class="line" id="L220">        <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(T).Pointer.size == .One;</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L223">}</span>
<span class="line" id="L224"></span>
<span class="line" id="L225"><span class="tok-kw">test</span> <span class="tok-str">&quot;isSingleItemPtr&quot;</span> {</span>
<span class="line" id="L226">    <span class="tok-kw">const</span> array = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L227">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testing.expect(isSingleItemPtr(<span class="tok-builtin">@TypeOf</span>(&amp;array[<span class="tok-number">0</span>])));</span>
<span class="line" id="L228">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testing.expect(!isSingleItemPtr(<span class="tok-builtin">@TypeOf</span>(array)));</span>
<span class="line" id="L229">    <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L230">    <span class="tok-kw">try</span> testing.expect(!isSingleItemPtr(<span class="tok-builtin">@TypeOf</span>(array[runtime_zero..<span class="tok-number">1</span>])));</span>
<span class="line" id="L231">}</span>
<span class="line" id="L232"></span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isManyItemPtr</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L234">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> is(.Pointer)(T)) {</span>
<span class="line" id="L235">        <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(T).Pointer.size == .Many;</span>
<span class="line" id="L236">    }</span>
<span class="line" id="L237">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L238">}</span>
<span class="line" id="L239"></span>
<span class="line" id="L240"><span class="tok-kw">test</span> <span class="tok-str">&quot;isManyItemPtr&quot;</span> {</span>
<span class="line" id="L241">    <span class="tok-kw">const</span> array = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L242">    <span class="tok-kw">const</span> mip = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;array[<span class="tok-number">0</span>]);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> testing.expect(isManyItemPtr(<span class="tok-builtin">@TypeOf</span>(mip)));</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> testing.expect(!isManyItemPtr(<span class="tok-builtin">@TypeOf</span>(array)));</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> testing.expect(!isManyItemPtr(<span class="tok-builtin">@TypeOf</span>(array[<span class="tok-number">0</span>..<span class="tok-number">1</span>])));</span>
<span class="line" id="L246">}</span>
<span class="line" id="L247"></span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSlice</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L249">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> is(.Pointer)(T)) {</span>
<span class="line" id="L250">        <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(T).Pointer.size == .Slice;</span>
<span class="line" id="L251">    }</span>
<span class="line" id="L252">    <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L253">}</span>
<span class="line" id="L254"></span>
<span class="line" id="L255"><span class="tok-kw">test</span> <span class="tok-str">&quot;isSlice&quot;</span> {</span>
<span class="line" id="L256">    <span class="tok-kw">const</span> array = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L257">    <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L258">    <span class="tok-kw">try</span> testing.expect(isSlice(<span class="tok-builtin">@TypeOf</span>(array[runtime_zero..])));</span>
<span class="line" id="L259">    <span class="tok-kw">try</span> testing.expect(!isSlice(<span class="tok-builtin">@TypeOf</span>(array)));</span>
<span class="line" id="L260">    <span class="tok-kw">try</span> testing.expect(!isSlice(<span class="tok-builtin">@TypeOf</span>(&amp;array[<span class="tok-number">0</span>])));</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isIndexable</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L264">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> is(.Pointer)(T)) {</span>
<span class="line" id="L265">        <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Pointer.size == .One) {</span>
<span class="line" id="L266">            <span class="tok-kw">return</span> (<span class="tok-kw">comptime</span> is(.Array)(meta.Child(T)));</span>
<span class="line" id="L267">        }</span>
<span class="line" id="L268">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L269">    }</span>
<span class="line" id="L270">    <span class="tok-kw">return</span> <span class="tok-kw">comptime</span> is(.Array)(T) <span class="tok-kw">or</span> is(.Vector)(T) <span class="tok-kw">or</span> isTuple(T);</span>
<span class="line" id="L271">}</span>
<span class="line" id="L272"></span>
<span class="line" id="L273"><span class="tok-kw">test</span> <span class="tok-str">&quot;isIndexable&quot;</span> {</span>
<span class="line" id="L274">    <span class="tok-kw">const</span> array = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">10</span>;</span>
<span class="line" id="L275">    <span class="tok-kw">const</span> slice = <span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;array);</span>
<span class="line" id="L276">    <span class="tok-kw">const</span> vector: meta.Vector(<span class="tok-number">2</span>, <span class="tok-type">u32</span>) = [_]<span class="tok-type">u32</span>{<span class="tok-number">0</span>} ** <span class="tok-number">2</span>;</span>
<span class="line" id="L277">    <span class="tok-kw">const</span> tuple = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> };</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">    <span class="tok-kw">try</span> testing.expect(isIndexable(<span class="tok-builtin">@TypeOf</span>(array)));</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> testing.expect(isIndexable(<span class="tok-builtin">@TypeOf</span>(&amp;array)));</span>
<span class="line" id="L281">    <span class="tok-kw">try</span> testing.expect(isIndexable(<span class="tok-builtin">@TypeOf</span>(slice)));</span>
<span class="line" id="L282">    <span class="tok-kw">try</span> testing.expect(!isIndexable(meta.Child(<span class="tok-builtin">@TypeOf</span>(slice))));</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> testing.expect(isIndexable(<span class="tok-builtin">@TypeOf</span>(vector)));</span>
<span class="line" id="L284">    <span class="tok-kw">try</span> testing.expect(isIndexable(<span class="tok-builtin">@TypeOf</span>(tuple)));</span>
<span class="line" id="L285">}</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isNumber</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L288">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L289">        .Int, .Float, .ComptimeInt, .ComptimeFloat =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L290">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L291">    };</span>
<span class="line" id="L292">}</span>
<span class="line" id="L293"></span>
<span class="line" id="L294"><span class="tok-kw">test</span> <span class="tok-str">&quot;isNumber&quot;</span> {</span>
<span class="line" id="L295">    <span class="tok-kw">const</span> NotANumber = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L296">        number: <span class="tok-type">u8</span>,</span>
<span class="line" id="L297">    };</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    <span class="tok-kw">try</span> testing.expect(isNumber(<span class="tok-type">u32</span>));</span>
<span class="line" id="L300">    <span class="tok-kw">try</span> testing.expect(isNumber(<span class="tok-type">f32</span>));</span>
<span class="line" id="L301">    <span class="tok-kw">try</span> testing.expect(isNumber(<span class="tok-type">u64</span>));</span>
<span class="line" id="L302">    <span class="tok-kw">try</span> testing.expect(isNumber(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102</span>)));</span>
<span class="line" id="L303">    <span class="tok-kw">try</span> testing.expect(isNumber(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102.123</span>)));</span>
<span class="line" id="L304">    <span class="tok-kw">try</span> testing.expect(!isNumber([]<span class="tok-type">u8</span>));</span>
<span class="line" id="L305">    <span class="tok-kw">try</span> testing.expect(!isNumber(NotANumber));</span>
<span class="line" id="L306">}</span>
<span class="line" id="L307"></span>
<span class="line" id="L308"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isIntegral</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L309">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L310">        .Int, .ComptimeInt =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L311">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L312">    };</span>
<span class="line" id="L313">}</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-kw">test</span> <span class="tok-str">&quot;isIntegral&quot;</span> {</span>
<span class="line" id="L316">    <span class="tok-kw">try</span> testing.expect(isIntegral(<span class="tok-type">u32</span>));</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> testing.expect(!isIntegral(<span class="tok-type">f32</span>));</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> testing.expect(isIntegral(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102</span>)));</span>
<span class="line" id="L319">    <span class="tok-kw">try</span> testing.expect(!isIntegral(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102.123</span>)));</span>
<span class="line" id="L320">    <span class="tok-kw">try</span> testing.expect(!isIntegral(*<span class="tok-type">u8</span>));</span>
<span class="line" id="L321">    <span class="tok-kw">try</span> testing.expect(!isIntegral([]<span class="tok-type">u8</span>));</span>
<span class="line" id="L322">}</span>
<span class="line" id="L323"></span>
<span class="line" id="L324"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isFloat</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L325">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L326">        .Float, .ComptimeFloat =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L327">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L328">    };</span>
<span class="line" id="L329">}</span>
<span class="line" id="L330"></span>
<span class="line" id="L331"><span class="tok-kw">test</span> <span class="tok-str">&quot;isFloat&quot;</span> {</span>
<span class="line" id="L332">    <span class="tok-kw">try</span> testing.expect(!isFloat(<span class="tok-type">u32</span>));</span>
<span class="line" id="L333">    <span class="tok-kw">try</span> testing.expect(isFloat(<span class="tok-type">f32</span>));</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testing.expect(!isFloat(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102</span>)));</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> testing.expect(isFloat(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">102.123</span>)));</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> testing.expect(!isFloat(*<span class="tok-type">f64</span>));</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> testing.expect(!isFloat([]<span class="tok-type">f32</span>));</span>
<span class="line" id="L338">}</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isConstPtr</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L341">    <span class="tok-kw">if</span> (!<span class="tok-kw">comptime</span> is(.Pointer)(T)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L342">    <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(T).Pointer.is_const;</span>
<span class="line" id="L343">}</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-kw">test</span> <span class="tok-str">&quot;isConstPtr&quot;</span> {</span>
<span class="line" id="L346">    <span class="tok-kw">var</span> t = <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L347">    <span class="tok-kw">const</span> c = <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L348">    <span class="tok-kw">try</span> testing.expect(isConstPtr(*<span class="tok-kw">const</span> <span class="tok-builtin">@TypeOf</span>(t)));</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expect(isConstPtr(<span class="tok-builtin">@TypeOf</span>(&amp;c)));</span>
<span class="line" id="L350">    <span class="tok-kw">try</span> testing.expect(!isConstPtr(*<span class="tok-builtin">@TypeOf</span>(t)));</span>
<span class="line" id="L351">    <span class="tok-kw">try</span> testing.expect(!isConstPtr(<span class="tok-builtin">@TypeOf</span>(<span class="tok-number">6</span>)));</span>
<span class="line" id="L352">}</span>
<span class="line" id="L353"></span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isContainer</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L355">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L356">        .Struct, .Union, .Enum, .Opaque =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L357">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L358">    };</span>
<span class="line" id="L359">}</span>
<span class="line" id="L360"></span>
<span class="line" id="L361"><span class="tok-kw">test</span> <span class="tok-str">&quot;isContainer&quot;</span> {</span>
<span class="line" id="L362">    <span class="tok-kw">const</span> TestStruct = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L363">    <span class="tok-kw">const</span> TestUnion = <span class="tok-kw">union</span> {</span>
<span class="line" id="L364">        a: <span class="tok-type">void</span>,</span>
<span class="line" id="L365">    };</span>
<span class="line" id="L366">    <span class="tok-kw">const</span> TestEnum = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L367">        A,</span>
<span class="line" id="L368">        B,</span>
<span class="line" id="L369">    };</span>
<span class="line" id="L370">    <span class="tok-kw">const</span> TestOpaque = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">    <span class="tok-kw">try</span> testing.expect(isContainer(TestStruct));</span>
<span class="line" id="L373">    <span class="tok-kw">try</span> testing.expect(isContainer(TestUnion));</span>
<span class="line" id="L374">    <span class="tok-kw">try</span> testing.expect(isContainer(TestEnum));</span>
<span class="line" id="L375">    <span class="tok-kw">try</span> testing.expect(isContainer(TestOpaque));</span>
<span class="line" id="L376">    <span class="tok-kw">try</span> testing.expect(!isContainer(<span class="tok-type">u8</span>));</span>
<span class="line" id="L377">}</span>
<span class="line" id="L378"></span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isTuple</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L380">    <span class="tok-kw">return</span> is(.Struct)(T) <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(T).Struct.is_tuple;</span>
<span class="line" id="L381">}</span>
<span class="line" id="L382"></span>
<span class="line" id="L383"><span class="tok-kw">test</span> <span class="tok-str">&quot;isTuple&quot;</span> {</span>
<span class="line" id="L384">    <span class="tok-kw">const</span> t1 = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L385">    <span class="tok-kw">const</span> t2 = .{ .a = <span class="tok-number">0</span> };</span>
<span class="line" id="L386">    <span class="tok-kw">const</span> t3 = .{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> };</span>
<span class="line" id="L387">    <span class="tok-kw">try</span> testing.expect(!isTuple(t1));</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> testing.expect(!isTuple(<span class="tok-builtin">@TypeOf</span>(t2)));</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expect(isTuple(<span class="tok-builtin">@TypeOf</span>(t3)));</span>
<span class="line" id="L390">}</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-comment">/// Returns true if the passed type will coerce to []const u8.</span></span>
<span class="line" id="L393"><span class="tok-comment">/// Any of the following are considered strings:</span></span>
<span class="line" id="L394"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L395"><span class="tok-comment">/// []const u8, [:S]const u8, *const [N]u8, *const [N:S]u8,</span></span>
<span class="line" id="L396"><span class="tok-comment">/// []u8, [:S]u8, *[:S]u8, *[N:S]u8.</span></span>
<span class="line" id="L397"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L398"><span class="tok-comment">/// These types are not considered strings:</span></span>
<span class="line" id="L399"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L400"><span class="tok-comment">/// u8, [N]u8, [*]const u8, [*:0]const u8,</span></span>
<span class="line" id="L401"><span class="tok-comment">/// [*]const [N]u8, []const u16, []const i8,</span></span>
<span class="line" id="L402"><span class="tok-comment">/// *const u8, ?[]const u8, ?*const [N]u8.</span></span>
<span class="line" id="L403"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L404"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isZigString</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L405">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L406">        <span class="tok-comment">// Only pointer types can be strings, no optionals</span>
</span>
<span class="line" id="L407">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T);</span>
<span class="line" id="L408">        <span class="tok-kw">if</span> (info != .Pointer) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">        <span class="tok-kw">const</span> ptr = &amp;info.Pointer;</span>
<span class="line" id="L411">        <span class="tok-comment">// Check for CV qualifiers that would prevent coerction to []const u8</span>
</span>
<span class="line" id="L412">        <span class="tok-kw">if</span> (ptr.is_volatile <span class="tok-kw">or</span> ptr.is_allowzero) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-comment">// If it's already a slice, simple check.</span>
</span>
<span class="line" id="L415">        <span class="tok-kw">if</span> (ptr.size == .Slice) {</span>
<span class="line" id="L416">            <span class="tok-kw">return</span> ptr.child == <span class="tok-type">u8</span>;</span>
<span class="line" id="L417">        }</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">        <span class="tok-comment">// Otherwise check if it's an array type that coerces to slice.</span>
</span>
<span class="line" id="L420">        <span class="tok-kw">if</span> (ptr.size == .One) {</span>
<span class="line" id="L421">            <span class="tok-kw">const</span> child = <span class="tok-builtin">@typeInfo</span>(ptr.child);</span>
<span class="line" id="L422">            <span class="tok-kw">if</span> (child == .Array) {</span>
<span class="line" id="L423">                <span class="tok-kw">const</span> arr = &amp;child.Array;</span>
<span class="line" id="L424">                <span class="tok-kw">return</span> arr.child == <span class="tok-type">u8</span>;</span>
<span class="line" id="L425">            }</span>
<span class="line" id="L426">        }</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L429">    }</span>
<span class="line" id="L430">}</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-kw">test</span> <span class="tok-str">&quot;isZigString&quot;</span> {</span>
<span class="line" id="L433">    <span class="tok-kw">try</span> testing.expect(isZigString([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L434">    <span class="tok-kw">try</span> testing.expect(isZigString([]<span class="tok-type">u8</span>));</span>
<span class="line" id="L435">    <span class="tok-kw">try</span> testing.expect(isZigString([:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L436">    <span class="tok-kw">try</span> testing.expect(isZigString([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L437">    <span class="tok-kw">try</span> testing.expect(isZigString([:<span class="tok-number">5</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L438">    <span class="tok-kw">try</span> testing.expect(isZigString([:<span class="tok-number">5</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L439">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L440">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">0</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">0</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L443">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">0</span>:<span class="tok-number">5</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L444">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">0</span>:<span class="tok-number">5</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L445">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">10</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L446">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">10</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L447">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">10</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L448">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">10</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L449">    <span class="tok-kw">try</span> testing.expect(isZigString(*<span class="tok-kw">const</span> [<span class="tok-number">10</span>:<span class="tok-number">5</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L450">    <span class="tok-kw">try</span> testing.expect(isZigString(*[<span class="tok-number">10</span>:<span class="tok-number">5</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">    <span class="tok-kw">try</span> testing.expect(!isZigString(<span class="tok-type">u8</span>));</span>
<span class="line" id="L453">    <span class="tok-kw">try</span> testing.expect(!isZigString([<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L454">    <span class="tok-kw">try</span> testing.expect(!isZigString([<span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L455">    <span class="tok-kw">try</span> testing.expect(!isZigString([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L456">    <span class="tok-kw">try</span> testing.expect(!isZigString([*]<span class="tok-kw">const</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L457">    <span class="tok-kw">try</span> testing.expect(!isZigString([*c]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L458">    <span class="tok-kw">try</span> testing.expect(!isZigString([*c]<span class="tok-kw">const</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L459">    <span class="tok-kw">try</span> testing.expect(!isZigString([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L460">    <span class="tok-kw">try</span> testing.expect(!isZigString([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L461">    <span class="tok-kw">try</span> testing.expect(!isZigString(*[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L462">    <span class="tok-kw">try</span> testing.expect(!isZigString(?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L463">    <span class="tok-kw">try</span> testing.expect(!isZigString(?*<span class="tok-kw">const</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L464">    <span class="tok-kw">try</span> testing.expect(!isZigString([]<span class="tok-kw">allowzero</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L465">    <span class="tok-kw">try</span> testing.expect(!isZigString([]<span class="tok-kw">volatile</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L466">    <span class="tok-kw">try</span> testing.expect(!isZigString(*<span class="tok-kw">allowzero</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L467">    <span class="tok-kw">try</span> testing.expect(!isZigString(*<span class="tok-kw">volatile</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>));</span>
<span class="line" id="L468">}</span>
<span class="line" id="L469"></span>
<span class="line" id="L470"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasDecls</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> names: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L471">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L472">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(T, name))</span>
<span class="line" id="L473">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L474">    }</span>
<span class="line" id="L475">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L476">}</span>
<span class="line" id="L477"></span>
<span class="line" id="L478"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasDecls&quot;</span> {</span>
<span class="line" id="L479">    <span class="tok-kw">const</span> TestStruct1 = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L480">    <span class="tok-kw">const</span> TestStruct2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L481">        <span class="tok-kw">pub</span> <span class="tok-kw">var</span> a: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L482">        <span class="tok-kw">pub</span> <span class="tok-kw">var</span> b: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L483">        c: <span class="tok-type">bool</span>,</span>
<span class="line" id="L484">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">useless</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L485">    };</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">    <span class="tok-kw">const</span> tuple = .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> };</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">    <span class="tok-kw">try</span> testing.expect(!hasDecls(TestStruct1, .{<span class="tok-str">&quot;a&quot;</span>}));</span>
<span class="line" id="L490">    <span class="tok-kw">try</span> testing.expect(hasDecls(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span> }));</span>
<span class="line" id="L491">    <span class="tok-kw">try</span> testing.expect(hasDecls(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;useless&quot;</span> }));</span>
<span class="line" id="L492">    <span class="tok-kw">try</span> testing.expect(!hasDecls(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }));</span>
<span class="line" id="L493">    <span class="tok-kw">try</span> testing.expect(!hasDecls(TestStruct2, tuple));</span>
<span class="line" id="L494">}</span>
<span class="line" id="L495"></span>
<span class="line" id="L496"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasFields</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> names: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L497">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L498">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasField</span>(T, name))</span>
<span class="line" id="L499">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L500">    }</span>
<span class="line" id="L501">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L502">}</span>
<span class="line" id="L503"></span>
<span class="line" id="L504"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasFields&quot;</span> {</span>
<span class="line" id="L505">    <span class="tok-kw">const</span> TestStruct1 = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L506">    <span class="tok-kw">const</span> TestStruct2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L507">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L508">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L509">        c: <span class="tok-type">bool</span>,</span>
<span class="line" id="L510">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">useless</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L511">    };</span>
<span class="line" id="L512"></span>
<span class="line" id="L513">    <span class="tok-kw">const</span> tuple = .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> };</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">    <span class="tok-kw">try</span> testing.expect(!hasFields(TestStruct1, .{<span class="tok-str">&quot;a&quot;</span>}));</span>
<span class="line" id="L516">    <span class="tok-kw">try</span> testing.expect(hasFields(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span> }));</span>
<span class="line" id="L517">    <span class="tok-kw">try</span> testing.expect(hasFields(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }));</span>
<span class="line" id="L518">    <span class="tok-kw">try</span> testing.expect(hasFields(TestStruct2, tuple));</span>
<span class="line" id="L519">    <span class="tok-kw">try</span> testing.expect(!hasFields(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;useless&quot;</span> }));</span>
<span class="line" id="L520">}</span>
<span class="line" id="L521"></span>
<span class="line" id="L522"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasFunctions</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> names: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L523">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (names) |name| {</span>
<span class="line" id="L524">        <span class="tok-kw">if</span> (!hasFn(name)(T))</span>
<span class="line" id="L525">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L526">    }</span>
<span class="line" id="L527">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L528">}</span>
<span class="line" id="L529"></span>
<span class="line" id="L530"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasFunctions&quot;</span> {</span>
<span class="line" id="L531">    <span class="tok-kw">const</span> TestStruct1 = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L532">    <span class="tok-kw">const</span> TestStruct2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L533">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L534">        <span class="tok-kw">fn</span> <span class="tok-fn">b</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L535">    };</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-kw">const</span> tuple = .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> };</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    <span class="tok-kw">try</span> testing.expect(!hasFunctions(TestStruct1, .{<span class="tok-str">&quot;a&quot;</span>}));</span>
<span class="line" id="L540">    <span class="tok-kw">try</span> testing.expect(hasFunctions(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span> }));</span>
<span class="line" id="L541">    <span class="tok-kw">try</span> testing.expect(!hasFunctions(TestStruct2, .{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span> }));</span>
<span class="line" id="L542">    <span class="tok-kw">try</span> testing.expect(!hasFunctions(TestStruct2, tuple));</span>
<span class="line" id="L543">}</span>
<span class="line" id="L544"></span>
<span class="line" id="L545"><span class="tok-comment">/// True if every value of the type `T` has a unique bit pattern representing it.</span></span>
<span class="line" id="L546"><span class="tok-comment">/// In other words, `T` has no unused bits and no padding.</span></span>
<span class="line" id="L547"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasUniqueRepresentation</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L548">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L549">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>, <span class="tok-comment">// TODO can we know if it's true for some of these types ?</span>
</span>
<span class="line" id="L550"></span>
<span class="line" id="L551">        .AnyFrame,</span>
<span class="line" id="L552">        .BoundFn,</span>
<span class="line" id="L553">        .Enum,</span>
<span class="line" id="L554">        .ErrorSet,</span>
<span class="line" id="L555">        .Fn,</span>
<span class="line" id="L556">        =&gt; <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">        .Bool =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">        .Int =&gt; |info| <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(T) * <span class="tok-number">8</span> == info.bits,</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">        .Pointer =&gt; |info| <span class="tok-kw">return</span> info.size != .Slice,</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">        .Array =&gt; |info| <span class="tok-kw">return</span> <span class="tok-kw">comptime</span> hasUniqueRepresentation(info.child),</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">        .Struct =&gt; |info| {</span>
<span class="line" id="L567">            <span class="tok-kw">var</span> sum_size = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field| {</span>
<span class="line" id="L570">                <span class="tok-kw">const</span> FieldType = field.field_type;</span>
<span class="line" id="L571">                <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> !hasUniqueRepresentation(FieldType)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L572">                sum_size += <span class="tok-builtin">@sizeOf</span>(FieldType);</span>
<span class="line" id="L573">            }</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">            <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(T) == sum_size;</span>
<span class="line" id="L576">        },</span>
<span class="line" id="L577"></span>
<span class="line" id="L578">        .Vector =&gt; |info| <span class="tok-kw">return</span> <span class="tok-kw">comptime</span> hasUniqueRepresentation(info.child) <span class="tok-kw">and</span></span>
<span class="line" id="L579">            <span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-builtin">@sizeOf</span>(info.child) * info.len,</span>
<span class="line" id="L580">    }</span>
<span class="line" id="L581">}</span>
<span class="line" id="L582"></span>
<span class="line" id="L583"><span class="tok-kw">test</span> <span class="tok-str">&quot;hasUniqueRepresentation&quot;</span> {</span>
<span class="line" id="L584">    <span class="tok-kw">const</span> TestStruct1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L585">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L586">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L587">    };</span>
<span class="line" id="L588"></span>
<span class="line" id="L589">    <span class="tok-kw">try</span> testing.expect(hasUniqueRepresentation(TestStruct1));</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">    <span class="tok-kw">const</span> TestStruct2 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L592">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L593">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L594">    };</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestStruct2));</span>
<span class="line" id="L597"></span>
<span class="line" id="L598">    <span class="tok-kw">const</span> TestStruct3 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L599">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L600">        b: <span class="tok-type">u32</span>,</span>
<span class="line" id="L601">    };</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    <span class="tok-kw">try</span> testing.expect(hasUniqueRepresentation(TestStruct3));</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">    <span class="tok-kw">const</span> TestStruct4 = <span class="tok-kw">struct</span> { a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> };</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestStruct4));</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">    <span class="tok-kw">const</span> TestStruct5 = <span class="tok-kw">struct</span> { a: TestStruct4 };</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestStruct5));</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">    <span class="tok-kw">const</span> TestUnion1 = <span class="tok-kw">packed</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L614">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L615">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L616">    };</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestUnion1));</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">    <span class="tok-kw">const</span> TestUnion2 = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L621">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L622">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L623">    };</span>
<span class="line" id="L624"></span>
<span class="line" id="L625">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestUnion2));</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">    <span class="tok-kw">const</span> TestUnion3 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L628">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L629">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L630">    };</span>
<span class="line" id="L631"></span>
<span class="line" id="L632">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestUnion3));</span>
<span class="line" id="L633"></span>
<span class="line" id="L634">    <span class="tok-kw">const</span> TestUnion4 = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L635">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L636">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L637">    };</span>
<span class="line" id="L638"></span>
<span class="line" id="L639">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(TestUnion4));</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">i0</span>, <span class="tok-type">u8</span>, <span class="tok-type">i16</span>, <span class="tok-type">u32</span>, <span class="tok-type">i64</span> }) |T| {</span>
<span class="line" id="L642">        <span class="tok-kw">try</span> testing.expect(hasUniqueRepresentation(T));</span>
<span class="line" id="L643">    }</span>
<span class="line" id="L644">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">i1</span>, <span class="tok-type">u9</span>, <span class="tok-type">i17</span>, <span class="tok-type">u33</span>, <span class="tok-type">i24</span> }) |T| {</span>
<span class="line" id="L645">        <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation(T));</span>
<span class="line" id="L646">    }</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation([]<span class="tok-type">u8</span>));</span>
<span class="line" id="L649">    <span class="tok-kw">try</span> testing.expect(!hasUniqueRepresentation([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">    <span class="tok-kw">try</span> testing.expect(hasUniqueRepresentation(<span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u16</span>)));</span>
<span class="line" id="L652">}</span>
<span class="line" id="L653"></span>
</code></pre></body>
</html>