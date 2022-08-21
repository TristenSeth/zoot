<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>meta.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> trait = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;meta/trait.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TrailerFlags = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;meta/trailer_flags.zig&quot;</span>).TrailerFlags;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> Type = std.builtin.Type;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.TrailerFlags&quot;</span> {</span>
<span class="line" id="L14">    _ = TrailerFlags;</span>
<span class="line" id="L15">}</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tagName</span>(v: <span class="tok-kw">anytype</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(v);</span>
<span class="line" id="L19">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L20">        .ErrorSet =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@errorName</span>(v),</span>
<span class="line" id="L21">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@tagName</span>(v),</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.tagName&quot;</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L27">        A,</span>
<span class="line" id="L28">        B,</span>
<span class="line" id="L29">    };</span>
<span class="line" id="L30">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L31">        C = <span class="tok-number">33</span>,</span>
<span class="line" id="L32">        D,</span>
<span class="line" id="L33">    };</span>
<span class="line" id="L34">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L35">        G: <span class="tok-type">u8</span>,</span>
<span class="line" id="L36">        H: <span class="tok-type">u16</span>,</span>
<span class="line" id="L37">    };</span>
<span class="line" id="L38">    <span class="tok-kw">const</span> U2 = <span class="tok-kw">union</span>(E2) {</span>
<span class="line" id="L39">        C: <span class="tok-type">u8</span>,</span>
<span class="line" id="L40">        D: <span class="tok-type">u16</span>,</span>
<span class="line" id="L41">    };</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-kw">var</span> u1g = U1{ .G = <span class="tok-number">0</span> };</span>
<span class="line" id="L44">    <span class="tok-kw">var</span> u1h = U1{ .H = <span class="tok-number">0</span> };</span>
<span class="line" id="L45">    <span class="tok-kw">var</span> u2a = U2{ .C = <span class="tok-number">0</span> };</span>
<span class="line" id="L46">    <span class="tok-kw">var</span> u2b = U2{ .D = <span class="tok-number">0</span> };</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(E1.A), <span class="tok-str">&quot;A&quot;</span>));</span>
<span class="line" id="L49">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(E1.B), <span class="tok-str">&quot;B&quot;</span>));</span>
<span class="line" id="L50">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(E2.C), <span class="tok-str">&quot;C&quot;</span>));</span>
<span class="line" id="L51">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(E2.D), <span class="tok-str">&quot;D&quot;</span>));</span>
<span class="line" id="L52">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(<span class="tok-kw">error</span>.E), <span class="tok-str">&quot;E&quot;</span>));</span>
<span class="line" id="L53">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(<span class="tok-kw">error</span>.F), <span class="tok-str">&quot;F&quot;</span>));</span>
<span class="line" id="L54">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(u1g), <span class="tok-str">&quot;G&quot;</span>));</span>
<span class="line" id="L55">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(u1h), <span class="tok-str">&quot;H&quot;</span>));</span>
<span class="line" id="L56">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(u2a), <span class="tok-str">&quot;C&quot;</span>));</span>
<span class="line" id="L57">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, tagName(u2b), <span class="tok-str">&quot;D&quot;</span>));</span>
<span class="line" id="L58">}</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stringToEnum</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?T {</span>
<span class="line" id="L61">    <span class="tok-comment">// Using ComptimeStringMap here is more performant, but it will start to take too</span>
</span>
<span class="line" id="L62">    <span class="tok-comment">// long to compile if the enum is large enough, due to the current limits of comptime</span>
</span>
<span class="line" id="L63">    <span class="tok-comment">// performance when doing things like constructing lookup maps at comptime.</span>
</span>
<span class="line" id="L64">    <span class="tok-comment">// TODO The '100' here is arbitrary and should be increased when possible:</span>
</span>
<span class="line" id="L65">    <span class="tok-comment">// - https://github.com/ziglang/zig/issues/4055</span>
</span>
<span class="line" id="L66">    <span class="tok-comment">// - https://github.com/ziglang/zig/issues/3863</span>
</span>
<span class="line" id="L67">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(T).Enum.fields.len &lt;= <span class="tok-number">100</span>) {</span>
<span class="line" id="L68">        <span class="tok-kw">const</span> kvs = <span class="tok-kw">comptime</span> build_kvs: {</span>
<span class="line" id="L69">            <span class="tok-comment">// In order to generate an array of structs that play nice with anonymous</span>
</span>
<span class="line" id="L70">            <span class="tok-comment">// list literals, we need to give them &quot;0&quot; and &quot;1&quot; field names.</span>
</span>
<span class="line" id="L71">            <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/4335</span>
</span>
<span class="line" id="L72">            <span class="tok-kw">const</span> EnumKV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L73">                @&quot;0&quot;: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L74">                @&quot;1&quot;: T,</span>
<span class="line" id="L75">            };</span>
<span class="line" id="L76">            <span class="tok-kw">var</span> kvs_array: [<span class="tok-builtin">@typeInfo</span>(T).Enum.fields.len]EnumKV = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L77">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(T).Enum.fields) |enumField, i| {</span>
<span class="line" id="L78">                kvs_array[i] = .{ .@&quot;0&quot; = enumField.name, .@&quot;1&quot; = <span class="tok-builtin">@field</span>(T, enumField.name) };</span>
<span class="line" id="L79">            }</span>
<span class="line" id="L80">            <span class="tok-kw">break</span> :build_kvs kvs_array[<span class="tok-number">0</span>..];</span>
<span class="line" id="L81">        };</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> map = std.ComptimeStringMap(T, kvs);</span>
<span class="line" id="L83">        <span class="tok-kw">return</span> map.get(str);</span>
<span class="line" id="L84">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L85">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(T).Enum.fields) |enumField| {</span>
<span class="line" id="L86">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, str, enumField.name)) {</span>
<span class="line" id="L87">                <span class="tok-kw">return</span> <span class="tok-builtin">@field</span>(T, enumField.name);</span>
<span class="line" id="L88">            }</span>
<span class="line" id="L89">        }</span>
<span class="line" id="L90">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.stringToEnum&quot;</span> {</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L96">        A,</span>
<span class="line" id="L97">        B,</span>
<span class="line" id="L98">    };</span>
<span class="line" id="L99">    <span class="tok-kw">try</span> testing.expect(E1.A == stringToEnum(E1, <span class="tok-str">&quot;A&quot;</span>).?);</span>
<span class="line" id="L100">    <span class="tok-kw">try</span> testing.expect(E1.B == stringToEnum(E1, <span class="tok-str">&quot;B&quot;</span>).?);</span>
<span class="line" id="L101">    <span class="tok-kw">try</span> testing.expect(<span class="tok-null">null</span> == stringToEnum(E1, <span class="tok-str">&quot;C&quot;</span>));</span>
<span class="line" id="L102">}</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-comment">/// Deprecated, use `@bitSizeOf()`.</span></span>
<span class="line" id="L105"><span class="tok-comment">/// TODO Remove this after zig 0.10.0 is released.</span></span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bitCount</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L107">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L108">        .Bool =&gt; <span class="tok-number">1</span>,</span>
<span class="line" id="L109">        .Int =&gt; |info| info.bits,</span>
<span class="line" id="L110">        .Float =&gt; |info| info.bits,</span>
<span class="line" id="L111">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected bool, int or float type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L112">    };</span>
<span class="line" id="L113">}</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.bitCount&quot;</span> {</span>
<span class="line" id="L116">    <span class="tok-kw">try</span> testing.expect(bitCount(<span class="tok-type">u8</span>) == <span class="tok-number">8</span>);</span>
<span class="line" id="L117">    <span class="tok-kw">try</span> testing.expect(bitCount(<span class="tok-type">f32</span>) == <span class="tok-number">32</span>);</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-comment">/// Returns the alignment of type T.</span></span>
<span class="line" id="L121"><span class="tok-comment">/// Note that if T is a pointer or function type the result is different than</span></span>
<span class="line" id="L122"><span class="tok-comment">/// the one returned by @alignOf(T).</span></span>
<span class="line" id="L123"><span class="tok-comment">/// If T is a pointer type the alignment of the type it points to is returned.</span></span>
<span class="line" id="L124"><span class="tok-comment">/// If T is a function type the alignment a target-dependent value is returned.</span></span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alignment</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L126">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L127">        .Optional =&gt; |info| <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L128">            .Pointer, .Fn =&gt; alignment(info.child),</span>
<span class="line" id="L129">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@alignOf</span>(T),</span>
<span class="line" id="L130">        },</span>
<span class="line" id="L131">        .Pointer =&gt; |info| info.alignment,</span>
<span class="line" id="L132">        .Fn =&gt; |info| info.alignment,</span>
<span class="line" id="L133">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@alignOf</span>(T),</span>
<span class="line" id="L134">    };</span>
<span class="line" id="L135">}</span>
<span class="line" id="L136"></span>
<span class="line" id="L137"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.alignment&quot;</span> {</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> testing.expect(alignment(<span class="tok-type">u8</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L139">    <span class="tok-kw">try</span> testing.expect(alignment(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">u8</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L140">    <span class="tok-kw">try</span> testing.expect(alignment(*<span class="tok-kw">align</span>(<span class="tok-number">2</span>) <span class="tok-type">u8</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L141">    <span class="tok-kw">try</span> testing.expect(alignment([]<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">u8</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L142">    <span class="tok-kw">try</span> testing.expect(alignment([]<span class="tok-kw">align</span>(<span class="tok-number">2</span>) <span class="tok-type">u8</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L143">    <span class="tok-kw">try</span> testing.expect(alignment(<span class="tok-kw">fn</span> () <span class="tok-type">void</span>) &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> testing.expect(alignment(<span class="tok-kw">fn</span> () <span class="tok-kw">align</span>(<span class="tok-number">128</span>) <span class="tok-type">void</span>) == <span class="tok-number">128</span>);</span>
<span class="line" id="L145">}</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Child</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L148">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L149">        .Array =&gt; |info| info.child,</span>
<span class="line" id="L150">        .Vector =&gt; |info| info.child,</span>
<span class="line" id="L151">        .Pointer =&gt; |info| info.child,</span>
<span class="line" id="L152">        .Optional =&gt; |info| info.child,</span>
<span class="line" id="L153">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected pointer, optional, array or vector type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L154">    };</span>
<span class="line" id="L155">}</span>
<span class="line" id="L156"></span>
<span class="line" id="L157"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.Child&quot;</span> {</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> testing.expect(Child([<span class="tok-number">1</span>]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L159">    <span class="tok-kw">try</span> testing.expect(Child(*<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L160">    <span class="tok-kw">try</span> testing.expect(Child([]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L161">    <span class="tok-kw">try</span> testing.expect(Child(?<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> testing.expect(Child(Vector(<span class="tok-number">2</span>, <span class="tok-type">u8</span>)) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L163">}</span>
<span class="line" id="L164"></span>
<span class="line" id="L165"><span class="tok-comment">/// Given a &quot;memory span&quot; type, returns the &quot;element type&quot;.</span></span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Elem</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L167">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L168">        .Array =&gt; |info| <span class="tok-kw">return</span> info.child,</span>
<span class="line" id="L169">        .Vector =&gt; |info| <span class="tok-kw">return</span> info.child,</span>
<span class="line" id="L170">        .Pointer =&gt; |info| <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L171">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L172">                .Array =&gt; |array_info| <span class="tok-kw">return</span> array_info.child,</span>
<span class="line" id="L173">                .Vector =&gt; |vector_info| <span class="tok-kw">return</span> vector_info.child,</span>
<span class="line" id="L174">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L175">            },</span>
<span class="line" id="L176">            .Many, .C, .Slice =&gt; <span class="tok-kw">return</span> info.child,</span>
<span class="line" id="L177">        },</span>
<span class="line" id="L178">        .Optional =&gt; |info| <span class="tok-kw">return</span> Elem(info.child),</span>
<span class="line" id="L179">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L180">    }</span>
<span class="line" id="L181">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected pointer, slice, array or vector type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L182">}</span>
<span class="line" id="L183"></span>
<span class="line" id="L184"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.Elem&quot;</span> {</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> testing.expect(Elem([<span class="tok-number">1</span>]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L186">    <span class="tok-kw">try</span> testing.expect(Elem([*]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> testing.expect(Elem([]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> testing.expect(Elem(*[<span class="tok-number">10</span>]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L189">    <span class="tok-kw">try</span> testing.expect(Elem(Vector(<span class="tok-number">2</span>, <span class="tok-type">u8</span>)) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> testing.expect(Elem(*Vector(<span class="tok-number">2</span>, <span class="tok-type">u8</span>)) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L191">    <span class="tok-kw">try</span> testing.expect(Elem(?[*]<span class="tok-type">u8</span>) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L192">}</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-comment">/// Given a type which can have a sentinel e.g. `[:0]u8`, returns the sentinel value,</span></span>
<span class="line" id="L195"><span class="tok-comment">/// or `null` if there is not one.</span></span>
<span class="line" id="L196"><span class="tok-comment">/// Types which cannot possibly have a sentinel will be a compile error.</span></span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sentinel</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ?Elem(T) {</span>
<span class="line" id="L198">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L199">        .Array =&gt; |info| {</span>
<span class="line" id="L200">            <span class="tok-kw">const</span> sentinel_ptr = info.sentinel <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L201">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> info.child, sentinel_ptr).*;</span>
<span class="line" id="L202">        },</span>
<span class="line" id="L203">        .Pointer =&gt; |info| {</span>
<span class="line" id="L204">            <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L205">                .Many, .Slice =&gt; {</span>
<span class="line" id="L206">                    <span class="tok-kw">const</span> sentinel_ptr = info.sentinel <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L207">                    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> info.child, sentinel_ptr).*;</span>
<span class="line" id="L208">                },</span>
<span class="line" id="L209">                .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L210">                    .Array =&gt; |array_info| {</span>
<span class="line" id="L211">                        <span class="tok-kw">const</span> sentinel_ptr = array_info.sentinel <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L212">                        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> array_info.child, sentinel_ptr).*;</span>
<span class="line" id="L213">                    },</span>
<span class="line" id="L214">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L215">                },</span>
<span class="line" id="L216">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L217">            }</span>
<span class="line" id="L218">        },</span>
<span class="line" id="L219">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L220">    }</span>
<span class="line" id="L221">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;' cannot possibly have a sentinel&quot;</span>);</span>
<span class="line" id="L222">}</span>
<span class="line" id="L223"></span>
<span class="line" id="L224"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.sentinel&quot;</span> {</span>
<span class="line" id="L225">    <span class="tok-kw">try</span> testSentinel();</span>
<span class="line" id="L226">    <span class="tok-kw">comptime</span> <span class="tok-kw">try</span> testSentinel();</span>
<span class="line" id="L227">}</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-kw">fn</span> <span class="tok-fn">testSentinel</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L230">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), sentinel([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).?);</span>
<span class="line" id="L231">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), sentinel([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).?);</span>
<span class="line" id="L232">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), sentinel([<span class="tok-number">5</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).?);</span>
<span class="line" id="L233">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0</span>), sentinel(*<span class="tok-kw">const</span> [<span class="tok-number">5</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>).?);</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-kw">try</span> testing.expect(sentinel([]<span class="tok-type">u8</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> testing.expect(sentinel([*]<span class="tok-type">u8</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> testing.expect(sentinel([<span class="tok-number">5</span>]<span class="tok-type">u8</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> testing.expect(sentinel(*<span class="tok-kw">const</span> [<span class="tok-number">5</span>]<span class="tok-type">u8</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L239">}</span>
<span class="line" id="L240"></span>
<span class="line" id="L241"><span class="tok-comment">/// Given a &quot;memory span&quot; type, returns the same type except with the given sentinel value.</span></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Sentinel</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> sentinel_val: Elem(T)) <span class="tok-type">type</span> {</span>
<span class="line" id="L243">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L244">        .Pointer =&gt; |info| <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L245">            .One =&gt; <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L246">                .Array =&gt; |array_info| <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L247">                    .Pointer = .{</span>
<span class="line" id="L248">                        .size = info.size,</span>
<span class="line" id="L249">                        .is_const = info.is_const,</span>
<span class="line" id="L250">                        .is_volatile = info.is_volatile,</span>
<span class="line" id="L251">                        .alignment = info.alignment,</span>
<span class="line" id="L252">                        .address_space = info.address_space,</span>
<span class="line" id="L253">                        .child = <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L254">                            .Array = .{</span>
<span class="line" id="L255">                                .len = array_info.len,</span>
<span class="line" id="L256">                                .child = array_info.child,</span>
<span class="line" id="L257">                                .sentinel = &amp;sentinel_val,</span>
<span class="line" id="L258">                            },</span>
<span class="line" id="L259">                        }),</span>
<span class="line" id="L260">                        .is_allowzero = info.is_allowzero,</span>
<span class="line" id="L261">                        .sentinel = info.sentinel,</span>
<span class="line" id="L262">                    },</span>
<span class="line" id="L263">                }),</span>
<span class="line" id="L264">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L265">            },</span>
<span class="line" id="L266">            .Many, .Slice =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L267">                .Pointer = .{</span>
<span class="line" id="L268">                    .size = info.size,</span>
<span class="line" id="L269">                    .is_const = info.is_const,</span>
<span class="line" id="L270">                    .is_volatile = info.is_volatile,</span>
<span class="line" id="L271">                    .alignment = info.alignment,</span>
<span class="line" id="L272">                    .address_space = info.address_space,</span>
<span class="line" id="L273">                    .child = info.child,</span>
<span class="line" id="L274">                    .is_allowzero = info.is_allowzero,</span>
<span class="line" id="L275">                    .sentinel = &amp;sentinel_val,</span>
<span class="line" id="L276">                },</span>
<span class="line" id="L277">            }),</span>
<span class="line" id="L278">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L279">        },</span>
<span class="line" id="L280">        .Optional =&gt; |info| <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L281">            .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L282">                .Many =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L283">                    .Optional = .{</span>
<span class="line" id="L284">                        .child = <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L285">                            .Pointer = .{</span>
<span class="line" id="L286">                                .size = ptr_info.size,</span>
<span class="line" id="L287">                                .is_const = ptr_info.is_const,</span>
<span class="line" id="L288">                                .is_volatile = ptr_info.is_volatile,</span>
<span class="line" id="L289">                                .alignment = ptr_info.alignment,</span>
<span class="line" id="L290">                                .address_space = ptr_info.address_space,</span>
<span class="line" id="L291">                                .child = ptr_info.child,</span>
<span class="line" id="L292">                                .is_allowzero = ptr_info.is_allowzero,</span>
<span class="line" id="L293">                                .sentinel = &amp;sentinel_val,</span>
<span class="line" id="L294">                            },</span>
<span class="line" id="L295">                        }),</span>
<span class="line" id="L296">                    },</span>
<span class="line" id="L297">                }),</span>
<span class="line" id="L298">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L299">            },</span>
<span class="line" id="L300">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L301">        },</span>
<span class="line" id="L302">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to derive a sentinel pointer type from &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L305">}</span>
<span class="line" id="L306"></span>
<span class="line" id="L307"><span class="tok-comment">/// Takes a Slice or Many Pointer and returns it with the Type modified to have the given sentinel value.</span></span>
<span class="line" id="L308"><span class="tok-comment">/// This function assumes the caller has verified the memory contains the sentinel value.</span></span>
<span class="line" id="L309"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">assumeSentinel</span>(p: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> sentinel_val: Elem(<span class="tok-builtin">@TypeOf</span>(p))) Sentinel(<span class="tok-builtin">@TypeOf</span>(p), sentinel_val) {</span>
<span class="line" id="L310">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(p);</span>
<span class="line" id="L311">    <span class="tok-kw">const</span> ReturnType = Sentinel(T, sentinel_val);</span>
<span class="line" id="L312">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L313">        .Pointer =&gt; |info| <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L314">            .Slice =&gt; <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L315">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(ReturnType, p)</span>
<span class="line" id="L316">            <span class="tok-kw">else</span></span>
<span class="line" id="L317">                <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(ReturnType, p),</span>
<span class="line" id="L318">            .Many, .One =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(ReturnType, p),</span>
<span class="line" id="L319">            .C =&gt; {},</span>
<span class="line" id="L320">        },</span>
<span class="line" id="L321">        .Optional =&gt; |info| <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(info.child)) {</span>
<span class="line" id="L322">            .Pointer =&gt; |ptr_info| <span class="tok-kw">switch</span> (ptr_info.size) {</span>
<span class="line" id="L323">                .Many =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(ReturnType, p),</span>
<span class="line" id="L324">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L325">            },</span>
<span class="line" id="L326">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L327">        },</span>
<span class="line" id="L328">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L329">    }</span>
<span class="line" id="L330">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to derive a sentinel pointer type from &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L331">}</span>
<span class="line" id="L332"></span>
<span class="line" id="L333"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.assumeSentinel&quot;</span> {</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testing.expect([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([*]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L335">    <span class="tok-kw">try</span> testing.expect([:<span class="tok-number">0</span>]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> testing.expect([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> testing.expect([:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L338">    <span class="tok-kw">try</span> testing.expect([*:<span class="tok-number">0</span>]<span class="tok-type">u16</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([*]<span class="tok-type">u16</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L339">    <span class="tok-kw">try</span> testing.expect([:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L340">    <span class="tok-kw">try</span> testing.expect([*:<span class="tok-number">3</span>]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([*:<span class="tok-number">1</span>]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">3</span>)));</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> testing.expect([:<span class="tok-null">null</span>]?[*]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([]?[*]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-null">null</span>)));</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> testing.expect([*:<span class="tok-null">null</span>]?[*]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>([*]?[*]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-null">null</span>)));</span>
<span class="line" id="L343">    <span class="tok-kw">try</span> testing.expect(*[<span class="tok-number">10</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>(*[<span class="tok-number">10</span>]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> testing.expect(?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> == <span class="tok-builtin">@TypeOf</span>(assumeSentinel(<span class="tok-builtin">@as</span>(?[*]<span class="tok-type">u8</span>, <span class="tok-null">undefined</span>), <span class="tok-number">0</span>)));</span>
<span class="line" id="L345">}</span>
<span class="line" id="L346"></span>
<span class="line" id="L347"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containerLayout</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) Type.ContainerLayout {</span>
<span class="line" id="L348">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L349">        .Struct =&gt; |info| info.layout,</span>
<span class="line" id="L350">        .Enum =&gt; |info| info.layout,</span>
<span class="line" id="L351">        .Union =&gt; |info| info.layout,</span>
<span class="line" id="L352">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct, enum or union type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L353">    };</span>
<span class="line" id="L354">}</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.containerLayout&quot;</span> {</span>
<span class="line" id="L357">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L358">        A,</span>
<span class="line" id="L359">    };</span>
<span class="line" id="L360">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L361">    <span class="tok-kw">const</span> S2 = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L362">    <span class="tok-kw">const</span> S3 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L363">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L364">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L365">    };</span>
<span class="line" id="L366">    <span class="tok-kw">const</span> U2 = <span class="tok-kw">packed</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L367">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L368">    };</span>
<span class="line" id="L369">    <span class="tok-kw">const</span> U3 = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L370">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L371">    };</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">    <span class="tok-kw">try</span> testing.expect(containerLayout(E1) == .Auto);</span>
<span class="line" id="L374">    <span class="tok-kw">try</span> testing.expect(containerLayout(S1) == .Auto);</span>
<span class="line" id="L375">    <span class="tok-kw">try</span> testing.expect(containerLayout(S2) == .Packed);</span>
<span class="line" id="L376">    <span class="tok-kw">try</span> testing.expect(containerLayout(S3) == .Extern);</span>
<span class="line" id="L377">    <span class="tok-kw">try</span> testing.expect(containerLayout(U1) == .Auto);</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> testing.expect(containerLayout(U2) == .Packed);</span>
<span class="line" id="L379">    <span class="tok-kw">try</span> testing.expect(containerLayout(U3) == .Extern);</span>
<span class="line" id="L380">}</span>
<span class="line" id="L381"></span>
<span class="line" id="L382"><span class="tok-comment">/// Instead of this function, prefer to use e.g. `@typeInfo(foo).Struct.decls`</span></span>
<span class="line" id="L383"><span class="tok-comment">/// directly when you know what kind of type it is.</span></span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">declarations</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) []<span class="tok-kw">const</span> Type.Declaration {</span>
<span class="line" id="L385">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L386">        .Struct =&gt; |info| info.decls,</span>
<span class="line" id="L387">        .Enum =&gt; |info| info.decls,</span>
<span class="line" id="L388">        .Union =&gt; |info| info.decls,</span>
<span class="line" id="L389">        .Opaque =&gt; |info| info.decls,</span>
<span class="line" id="L390">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct, enum, union, or opaque type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L391">    };</span>
<span class="line" id="L392">}</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.declarations&quot;</span> {</span>
<span class="line" id="L395">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L396">        A,</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L399">    };</span>
<span class="line" id="L400">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L401">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L402">    };</span>
<span class="line" id="L403">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L404">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L407">    };</span>
<span class="line" id="L408">    <span class="tok-kw">const</span> O1 = <span class="tok-kw">opaque</span> {</span>
<span class="line" id="L409">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L410">    };</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">const</span> decls = <span class="tok-kw">comptime</span> [_][]<span class="tok-kw">const</span> Type.Declaration{</span>
<span class="line" id="L413">        declarations(E1),</span>
<span class="line" id="L414">        declarations(S1),</span>
<span class="line" id="L415">        declarations(U1),</span>
<span class="line" id="L416">        declarations(O1),</span>
<span class="line" id="L417">    };</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (decls) |decl| {</span>
<span class="line" id="L420">        <span class="tok-kw">try</span> testing.expect(decl.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L421">        <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, decl[<span class="tok-number">0</span>].name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L422">    }</span>
<span class="line" id="L423">}</span>
<span class="line" id="L424"></span>
<span class="line" id="L425"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">declarationInfo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> decl_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Type.Declaration {</span>
<span class="line" id="L426">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> declarations(T)) |decl| {</span>
<span class="line" id="L427">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, decl.name, decl_name))</span>
<span class="line" id="L428">            <span class="tok-kw">return</span> decl;</span>
<span class="line" id="L429">    }</span>
<span class="line" id="L430"></span>
<span class="line" id="L431">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;'&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;' has no declaration '&quot;</span> ++ decl_name ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L432">}</span>
<span class="line" id="L433"></span>
<span class="line" id="L434"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.declarationInfo&quot;</span> {</span>
<span class="line" id="L435">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L436">        A,</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L439">    };</span>
<span class="line" id="L440">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L441">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L442">    };</span>
<span class="line" id="L443">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L444">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">        <span class="tok-kw">fn</span> <span class="tok-fn">a</span>() <span class="tok-type">void</span> {}</span>
<span class="line" id="L447">    };</span>
<span class="line" id="L448"></span>
<span class="line" id="L449">    <span class="tok-kw">const</span> infos = <span class="tok-kw">comptime</span> [_]Type.Declaration{</span>
<span class="line" id="L450">        declarationInfo(E1, <span class="tok-str">&quot;a&quot;</span>),</span>
<span class="line" id="L451">        declarationInfo(S1, <span class="tok-str">&quot;a&quot;</span>),</span>
<span class="line" id="L452">        declarationInfo(U1, <span class="tok-str">&quot;a&quot;</span>),</span>
<span class="line" id="L453">    };</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (infos) |info| {</span>
<span class="line" id="L456">        <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, info.name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L457">        <span class="tok-kw">try</span> testing.expect(!info.is_pub);</span>
<span class="line" id="L458">    }</span>
<span class="line" id="L459">}</span>
<span class="line" id="L460"></span>
<span class="line" id="L461"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fields</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L462">    .Struct =&gt; []<span class="tok-kw">const</span> Type.StructField,</span>
<span class="line" id="L463">    .Union =&gt; []<span class="tok-kw">const</span> Type.UnionField,</span>
<span class="line" id="L464">    .ErrorSet =&gt; []<span class="tok-kw">const</span> Type.Error,</span>
<span class="line" id="L465">    .Enum =&gt; []<span class="tok-kw">const</span> Type.EnumField,</span>
<span class="line" id="L466">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct, union, error set or enum type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L467">} {</span>
<span class="line" id="L468">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L469">        .Struct =&gt; |info| info.fields,</span>
<span class="line" id="L470">        .Union =&gt; |info| info.fields,</span>
<span class="line" id="L471">        .Enum =&gt; |info| info.fields,</span>
<span class="line" id="L472">        .ErrorSet =&gt; |errors| errors.?, <span class="tok-comment">// must be non global error set</span>
</span>
<span class="line" id="L473">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct, union, error set or enum type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L474">    };</span>
<span class="line" id="L475">}</span>
<span class="line" id="L476"></span>
<span class="line" id="L477"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.fields&quot;</span> {</span>
<span class="line" id="L478">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L479">        A,</span>
<span class="line" id="L480">    };</span>
<span class="line" id="L481">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">error</span>{A};</span>
<span class="line" id="L482">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L483">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L484">    };</span>
<span class="line" id="L485">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L486">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L487">    };</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">    <span class="tok-kw">const</span> e1f = <span class="tok-kw">comptime</span> fields(E1);</span>
<span class="line" id="L490">    <span class="tok-kw">const</span> e2f = <span class="tok-kw">comptime</span> fields(E2);</span>
<span class="line" id="L491">    <span class="tok-kw">const</span> sf = <span class="tok-kw">comptime</span> fields(S1);</span>
<span class="line" id="L492">    <span class="tok-kw">const</span> uf = <span class="tok-kw">comptime</span> fields(U1);</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-kw">try</span> testing.expect(e1f.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L495">    <span class="tok-kw">try</span> testing.expect(e2f.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L496">    <span class="tok-kw">try</span> testing.expect(sf.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L497">    <span class="tok-kw">try</span> testing.expect(uf.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L498">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, e1f[<span class="tok-number">0</span>].name, <span class="tok-str">&quot;A&quot;</span>));</span>
<span class="line" id="L499">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, e2f[<span class="tok-number">0</span>].name, <span class="tok-str">&quot;A&quot;</span>));</span>
<span class="line" id="L500">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, sf[<span class="tok-number">0</span>].name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L501">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, uf[<span class="tok-number">0</span>].name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L502">    <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> sf[<span class="tok-number">0</span>].field_type == <span class="tok-type">u8</span>);</span>
<span class="line" id="L503">    <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> uf[<span class="tok-number">0</span>].field_type == <span class="tok-type">u8</span>);</span>
<span class="line" id="L504">}</span>
<span class="line" id="L505"></span>
<span class="line" id="L506"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fieldInfo</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> field: FieldEnum(T)) <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L507">    .Struct =&gt; Type.StructField,</span>
<span class="line" id="L508">    .Union =&gt; Type.UnionField,</span>
<span class="line" id="L509">    .ErrorSet =&gt; Type.Error,</span>
<span class="line" id="L510">    .Enum =&gt; Type.EnumField,</span>
<span class="line" id="L511">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct, union, error set or enum type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L512">} {</span>
<span class="line" id="L513">    <span class="tok-kw">return</span> fields(T)[<span class="tok-builtin">@enumToInt</span>(field)];</span>
<span class="line" id="L514">}</span>
<span class="line" id="L515"></span>
<span class="line" id="L516"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.fieldInfo&quot;</span> {</span>
<span class="line" id="L517">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L518">        A,</span>
<span class="line" id="L519">    };</span>
<span class="line" id="L520">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">error</span>{A};</span>
<span class="line" id="L521">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L522">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L523">    };</span>
<span class="line" id="L524">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L525">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L526">    };</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">    <span class="tok-kw">const</span> e1f = fieldInfo(E1, .A);</span>
<span class="line" id="L529">    <span class="tok-kw">const</span> e2f = fieldInfo(E2, .A);</span>
<span class="line" id="L530">    <span class="tok-kw">const</span> sf = fieldInfo(S1, .a);</span>
<span class="line" id="L531">    <span class="tok-kw">const</span> uf = fieldInfo(U1, .a);</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, e1f.name, <span class="tok-str">&quot;A&quot;</span>));</span>
<span class="line" id="L534">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, e2f.name, <span class="tok-str">&quot;A&quot;</span>));</span>
<span class="line" id="L535">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, sf.name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L536">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, uf.name, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L537">    <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> sf.field_type == <span class="tok-type">u8</span>);</span>
<span class="line" id="L538">    <span class="tok-kw">try</span> testing.expect(<span class="tok-kw">comptime</span> uf.field_type == <span class="tok-type">u8</span>);</span>
<span class="line" id="L539">}</span>
<span class="line" id="L540"></span>
<span class="line" id="L541"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fieldNames</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) *<span class="tok-kw">const</span> [fields(T).len][]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L542">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L543">        <span class="tok-kw">const</span> fieldInfos = fields(T);</span>
<span class="line" id="L544">        <span class="tok-kw">var</span> names: [fieldInfos.len][]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L545">        <span class="tok-kw">for</span> (fieldInfos) |field, i| {</span>
<span class="line" id="L546">            names[i] = field.name;</span>
<span class="line" id="L547">        }</span>
<span class="line" id="L548">        <span class="tok-kw">return</span> &amp;names;</span>
<span class="line" id="L549">    }</span>
<span class="line" id="L550">}</span>
<span class="line" id="L551"></span>
<span class="line" id="L552"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.fieldNames&quot;</span> {</span>
<span class="line" id="L553">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> { A, B };</span>
<span class="line" id="L554">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">error</span>{A};</span>
<span class="line" id="L555">    <span class="tok-kw">const</span> S1 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L556">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L557">    };</span>
<span class="line" id="L558">    <span class="tok-kw">const</span> U1 = <span class="tok-kw">union</span> {</span>
<span class="line" id="L559">        a: <span class="tok-type">u8</span>,</span>
<span class="line" id="L560">        b: <span class="tok-type">void</span>,</span>
<span class="line" id="L561">    };</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">    <span class="tok-kw">const</span> e1names = fieldNames(E1);</span>
<span class="line" id="L564">    <span class="tok-kw">const</span> e2names = fieldNames(E2);</span>
<span class="line" id="L565">    <span class="tok-kw">const</span> s1names = fieldNames(S1);</span>
<span class="line" id="L566">    <span class="tok-kw">const</span> u1names = fieldNames(U1);</span>
<span class="line" id="L567"></span>
<span class="line" id="L568">    <span class="tok-kw">try</span> testing.expect(e1names.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, e1names[<span class="tok-number">0</span>], <span class="tok-str">&quot;A&quot;</span>);</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, e1names[<span class="tok-number">1</span>], <span class="tok-str">&quot;B&quot;</span>);</span>
<span class="line" id="L571">    <span class="tok-kw">try</span> testing.expect(e2names.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L572">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, e2names[<span class="tok-number">0</span>], <span class="tok-str">&quot;A&quot;</span>);</span>
<span class="line" id="L573">    <span class="tok-kw">try</span> testing.expect(s1names.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L574">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, s1names[<span class="tok-number">0</span>], <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L575">    <span class="tok-kw">try</span> testing.expect(u1names.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L576">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, u1names[<span class="tok-number">0</span>], <span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L577">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, u1names[<span class="tok-number">1</span>], <span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L578">}</span>
<span class="line" id="L579"></span>
<span class="line" id="L580"><span class="tok-comment">/// Given an enum or error set type, returns a pointer to an array containing all tags for that</span></span>
<span class="line" id="L581"><span class="tok-comment">/// enum or error set.</span></span>
<span class="line" id="L582"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tags</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) *<span class="tok-kw">const</span> [fields(T).len]T {</span>
<span class="line" id="L583">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L584">        <span class="tok-kw">const</span> fieldInfos = fields(T);</span>
<span class="line" id="L585">        <span class="tok-kw">var</span> res: [fieldInfos.len]T = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L586">        <span class="tok-kw">for</span> (fieldInfos) |field, i| {</span>
<span class="line" id="L587">            res[i] = <span class="tok-builtin">@field</span>(T, field.name);</span>
<span class="line" id="L588">        }</span>
<span class="line" id="L589">        <span class="tok-kw">return</span> &amp;res;</span>
<span class="line" id="L590">    }</span>
<span class="line" id="L591">}</span>
<span class="line" id="L592"></span>
<span class="line" id="L593"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.tags&quot;</span> {</span>
<span class="line" id="L594">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> { A, B };</span>
<span class="line" id="L595">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">error</span>{A};</span>
<span class="line" id="L596"></span>
<span class="line" id="L597">    <span class="tok-kw">const</span> e1_tags = tags(E1);</span>
<span class="line" id="L598">    <span class="tok-kw">const</span> e2_tags = tags(E2);</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">    <span class="tok-kw">try</span> testing.expect(e1_tags.len == <span class="tok-number">2</span>);</span>
<span class="line" id="L601">    <span class="tok-kw">try</span> testing.expectEqual(E1.A, e1_tags[<span class="tok-number">0</span>]);</span>
<span class="line" id="L602">    <span class="tok-kw">try</span> testing.expectEqual(E1.B, e1_tags[<span class="tok-number">1</span>]);</span>
<span class="line" id="L603">    <span class="tok-kw">try</span> testing.expect(e2_tags.len == <span class="tok-number">1</span>);</span>
<span class="line" id="L604">    <span class="tok-kw">try</span> testing.expectEqual(E2.A, e2_tags[<span class="tok-number">0</span>]);</span>
<span class="line" id="L605">}</span>
<span class="line" id="L606"></span>
<span class="line" id="L607"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">FieldEnum</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L608">    <span class="tok-kw">const</span> field_infos = fields(T);</span>
<span class="line" id="L609">    <span class="tok-kw">var</span> enumFields: [field_infos.len]std.builtin.Type.EnumField = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L610">    <span class="tok-kw">var</span> decls = [_]std.builtin.Type.Declaration{};</span>
<span class="line" id="L611">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (field_infos) |field, i| {</span>
<span class="line" id="L612">        enumFields[i] = .{</span>
<span class="line" id="L613">            .name = field.name,</span>
<span class="line" id="L614">            .value = i,</span>
<span class="line" id="L615">        };</span>
<span class="line" id="L616">    }</span>
<span class="line" id="L617">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L618">        .Enum = .{</span>
<span class="line" id="L619">            .layout = .Auto,</span>
<span class="line" id="L620">            .tag_type = std.math.IntFittingRange(<span class="tok-number">0</span>, field_infos.len - <span class="tok-number">1</span>),</span>
<span class="line" id="L621">            .fields = &amp;enumFields,</span>
<span class="line" id="L622">            .decls = &amp;decls,</span>
<span class="line" id="L623">            .is_exhaustive = <span class="tok-null">true</span>,</span>
<span class="line" id="L624">        },</span>
<span class="line" id="L625">    });</span>
<span class="line" id="L626">}</span>
<span class="line" id="L627"></span>
<span class="line" id="L628"><span class="tok-kw">fn</span> <span class="tok-fn">expectEqualEnum</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L629">    <span class="tok-comment">// TODO: https://github.com/ziglang/zig/issues/7419</span>
</span>
<span class="line" id="L630">    <span class="tok-comment">// testing.expectEqual(@typeInfo(expected).Enum, @typeInfo(actual).Enum);</span>
</span>
<span class="line" id="L631">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L632">        <span class="tok-builtin">@typeInfo</span>(expected).Enum.layout,</span>
<span class="line" id="L633">        <span class="tok-builtin">@typeInfo</span>(actual).Enum.layout,</span>
<span class="line" id="L634">    );</span>
<span class="line" id="L635">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L636">        <span class="tok-builtin">@typeInfo</span>(expected).Enum.tag_type,</span>
<span class="line" id="L637">        <span class="tok-builtin">@typeInfo</span>(actual).Enum.tag_type,</span>
<span class="line" id="L638">    );</span>
<span class="line" id="L639">    <span class="tok-comment">// For comparing decls and fields, we cannot use the meta eql function here</span>
</span>
<span class="line" id="L640">    <span class="tok-comment">// because the language does not guarantee that the slice pointers for field names</span>
</span>
<span class="line" id="L641">    <span class="tok-comment">// and decl names will be the same.</span>
</span>
<span class="line" id="L642">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L643">        <span class="tok-kw">const</span> expected_fields = <span class="tok-builtin">@typeInfo</span>(expected).Enum.fields;</span>
<span class="line" id="L644">        <span class="tok-kw">const</span> actual_fields = <span class="tok-builtin">@typeInfo</span>(actual).Enum.fields;</span>
<span class="line" id="L645">        <span class="tok-kw">if</span> (expected_fields.len != actual_fields.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FailedTest;</span>
<span class="line" id="L646">        <span class="tok-kw">for</span> (expected_fields) |expected_field, i| {</span>
<span class="line" id="L647">            <span class="tok-kw">const</span> actual_field = actual_fields[i];</span>
<span class="line" id="L648">            <span class="tok-kw">try</span> testing.expectEqual(expected_field.value, actual_field.value);</span>
<span class="line" id="L649">            <span class="tok-kw">try</span> testing.expectEqualStrings(expected_field.name, actual_field.name);</span>
<span class="line" id="L650">        }</span>
<span class="line" id="L651">    }</span>
<span class="line" id="L652">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L653">        <span class="tok-kw">const</span> expected_decls = <span class="tok-builtin">@typeInfo</span>(expected).Enum.decls;</span>
<span class="line" id="L654">        <span class="tok-kw">const</span> actual_decls = <span class="tok-builtin">@typeInfo</span>(actual).Enum.decls;</span>
<span class="line" id="L655">        <span class="tok-kw">if</span> (expected_decls.len != actual_decls.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FailedTest;</span>
<span class="line" id="L656">        <span class="tok-kw">for</span> (expected_decls) |expected_decl, i| {</span>
<span class="line" id="L657">            <span class="tok-kw">const</span> actual_decl = actual_decls[i];</span>
<span class="line" id="L658">            <span class="tok-kw">try</span> testing.expectEqual(expected_decl.is_pub, actual_decl.is_pub);</span>
<span class="line" id="L659">            <span class="tok-kw">try</span> testing.expectEqualStrings(expected_decl.name, actual_decl.name);</span>
<span class="line" id="L660">        }</span>
<span class="line" id="L661">    }</span>
<span class="line" id="L662">    <span class="tok-kw">try</span> testing.expectEqual(</span>
<span class="line" id="L663">        <span class="tok-builtin">@typeInfo</span>(expected).Enum.is_exhaustive,</span>
<span class="line" id="L664">        <span class="tok-builtin">@typeInfo</span>(actual).Enum.is_exhaustive,</span>
<span class="line" id="L665">    );</span>
<span class="line" id="L666">}</span>
<span class="line" id="L667"></span>
<span class="line" id="L668"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.FieldEnum&quot;</span> {</span>
<span class="line" id="L669">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a }, FieldEnum(<span class="tok-kw">struct</span> { a: <span class="tok-type">u8</span> }));</span>
<span class="line" id="L670">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a, b, c }, FieldEnum(<span class="tok-kw">struct</span> { a: <span class="tok-type">u8</span>, b: <span class="tok-type">void</span>, c: <span class="tok-type">f32</span> }));</span>
<span class="line" id="L671">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a, b, c }, FieldEnum(<span class="tok-kw">union</span> { a: <span class="tok-type">u8</span>, b: <span class="tok-type">void</span>, c: <span class="tok-type">f32</span> }));</span>
<span class="line" id="L672">}</span>
<span class="line" id="L673"></span>
<span class="line" id="L674"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">DeclEnum</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L675">    <span class="tok-kw">const</span> fieldInfos = std.meta.declarations(T);</span>
<span class="line" id="L676">    <span class="tok-kw">var</span> enumDecls: [fieldInfos.len]std.builtin.Type.EnumField = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L677">    <span class="tok-kw">var</span> decls = [_]std.builtin.Type.Declaration{};</span>
<span class="line" id="L678">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fieldInfos) |field, i| {</span>
<span class="line" id="L679">        enumDecls[i] = .{ .name = field.name, .value = i };</span>
<span class="line" id="L680">    }</span>
<span class="line" id="L681">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L682">        .Enum = .{</span>
<span class="line" id="L683">            .layout = .Auto,</span>
<span class="line" id="L684">            .tag_type = std.math.IntFittingRange(<span class="tok-number">0</span>, fieldInfos.len - <span class="tok-number">1</span>),</span>
<span class="line" id="L685">            .fields = &amp;enumDecls,</span>
<span class="line" id="L686">            .decls = &amp;decls,</span>
<span class="line" id="L687">            .is_exhaustive = <span class="tok-null">true</span>,</span>
<span class="line" id="L688">        },</span>
<span class="line" id="L689">    });</span>
<span class="line" id="L690">}</span>
<span class="line" id="L691"></span>
<span class="line" id="L692"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.DeclEnum&quot;</span> {</span>
<span class="line" id="L693">    <span class="tok-kw">const</span> A = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L694">        <span class="tok-kw">const</span> a: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L695">    };</span>
<span class="line" id="L696">    <span class="tok-kw">const</span> B = <span class="tok-kw">union</span> {</span>
<span class="line" id="L697">        foo: <span class="tok-type">void</span>,</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">        <span class="tok-kw">const</span> a: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L700">        <span class="tok-kw">const</span> b: <span class="tok-type">void</span> = {};</span>
<span class="line" id="L701">        <span class="tok-kw">const</span> c: <span class="tok-type">f32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L702">    };</span>
<span class="line" id="L703">    <span class="tok-kw">const</span> C = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L704">        bar,</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">        <span class="tok-kw">const</span> a: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L707">        <span class="tok-kw">const</span> b: <span class="tok-type">void</span> = {};</span>
<span class="line" id="L708">        <span class="tok-kw">const</span> c: <span class="tok-type">f32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L709">    };</span>
<span class="line" id="L710">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a }, DeclEnum(A));</span>
<span class="line" id="L711">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a, b, c }, DeclEnum(B));</span>
<span class="line" id="L712">    <span class="tok-kw">try</span> expectEqualEnum(<span class="tok-kw">enum</span> { a, b, c }, DeclEnum(C));</span>
<span class="line" id="L713">}</span>
<span class="line" id="L714"></span>
<span class="line" id="L715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TagType = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use Tag&quot;</span>);</span>
<span class="line" id="L716"></span>
<span class="line" id="L717"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Tag</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L718">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L719">        .Enum =&gt; |info| info.tag_type,</span>
<span class="line" id="L720">        .Union =&gt; |info| info.tag_type <span class="tok-kw">orelse</span> <span class="tok-builtin">@compileError</span>(<span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot; has no tag type&quot;</span>),</span>
<span class="line" id="L721">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected enum or union type, found '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(T) ++ <span class="tok-str">&quot;'&quot;</span>),</span>
<span class="line" id="L722">    };</span>
<span class="line" id="L723">}</span>
<span class="line" id="L724"></span>
<span class="line" id="L725"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.Tag&quot;</span> {</span>
<span class="line" id="L726">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L727">        C = <span class="tok-number">33</span>,</span>
<span class="line" id="L728">        D,</span>
<span class="line" id="L729">    };</span>
<span class="line" id="L730">    <span class="tok-kw">const</span> U = <span class="tok-kw">union</span>(E) {</span>
<span class="line" id="L731">        C: <span class="tok-type">u8</span>,</span>
<span class="line" id="L732">        D: <span class="tok-type">u16</span>,</span>
<span class="line" id="L733">    };</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">    <span class="tok-kw">try</span> testing.expect(Tag(E) == <span class="tok-type">u8</span>);</span>
<span class="line" id="L736">    <span class="tok-kw">try</span> testing.expect(Tag(U) == E);</span>
<span class="line" id="L737">}</span>
<span class="line" id="L738"></span>
<span class="line" id="L739"><span class="tok-comment">///Returns the active tag of a tagged union</span></span>
<span class="line" id="L740"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">activeTag</span>(u: <span class="tok-kw">anytype</span>) Tag(<span class="tok-builtin">@TypeOf</span>(u)) {</span>
<span class="line" id="L741">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(u);</span>
<span class="line" id="L742">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(Tag(T), u);</span>
<span class="line" id="L743">}</span>
<span class="line" id="L744"></span>
<span class="line" id="L745"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.activeTag&quot;</span> {</span>
<span class="line" id="L746">    <span class="tok-kw">const</span> UE = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L747">        Int,</span>
<span class="line" id="L748">        Float,</span>
<span class="line" id="L749">    };</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">    <span class="tok-kw">const</span> U = <span class="tok-kw">union</span>(UE) {</span>
<span class="line" id="L752">        Int: <span class="tok-type">u32</span>,</span>
<span class="line" id="L753">        Float: <span class="tok-type">f32</span>,</span>
<span class="line" id="L754">    };</span>
<span class="line" id="L755"></span>
<span class="line" id="L756">    <span class="tok-kw">var</span> u = U{ .Int = <span class="tok-number">32</span> };</span>
<span class="line" id="L757">    <span class="tok-kw">try</span> testing.expect(activeTag(u) == UE.Int);</span>
<span class="line" id="L758"></span>
<span class="line" id="L759">    u = U{ .Float = <span class="tok-number">112.9876</span> };</span>
<span class="line" id="L760">    <span class="tok-kw">try</span> testing.expect(activeTag(u) == UE.Float);</span>
<span class="line" id="L761">}</span>
<span class="line" id="L762"></span>
<span class="line" id="L763"><span class="tok-kw">const</span> TagPayloadType = TagPayload;</span>
<span class="line" id="L764"></span>
<span class="line" id="L765"><span class="tok-comment">///Given a tagged union type, and an enum, return the type of the union</span></span>
<span class="line" id="L766"><span class="tok-comment">/// field corresponding to the enum tag.</span></span>
<span class="line" id="L767"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TagPayload</span>(<span class="tok-kw">comptime</span> U: <span class="tok-type">type</span>, tag: Tag(U)) <span class="tok-type">type</span> {</span>
<span class="line" id="L768">    <span class="tok-kw">comptime</span> debug.assert(trait.is(.Union)(U));</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(U).Union;</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field_info| {</span>
<span class="line" id="L773">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> mem.eql(<span class="tok-type">u8</span>, field_info.name, <span class="tok-builtin">@tagName</span>(tag)))</span>
<span class="line" id="L774">            <span class="tok-kw">return</span> field_info.field_type;</span>
<span class="line" id="L775">    }</span>
<span class="line" id="L776"></span>
<span class="line" id="L777">    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L778">}</span>
<span class="line" id="L779"></span>
<span class="line" id="L780"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.TagPayload&quot;</span> {</span>
<span class="line" id="L781">    <span class="tok-kw">const</span> Event = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L782">        Moved: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L783">            from: <span class="tok-type">i32</span>,</span>
<span class="line" id="L784">            to: <span class="tok-type">i32</span>,</span>
<span class="line" id="L785">        },</span>
<span class="line" id="L786">    };</span>
<span class="line" id="L787">    <span class="tok-kw">const</span> MovedEvent = TagPayload(Event, Event.Moved);</span>
<span class="line" id="L788">    <span class="tok-kw">var</span> e: Event = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L789">    <span class="tok-kw">try</span> testing.expect(MovedEvent == <span class="tok-builtin">@TypeOf</span>(e.Moved));</span>
<span class="line" id="L790">}</span>
<span class="line" id="L791"></span>
<span class="line" id="L792"><span class="tok-comment">/// Compares two of any type for equality. Containers are compared on a field-by-field basis,</span></span>
<span class="line" id="L793"><span class="tok-comment">/// where possible. Pointers are not followed.</span></span>
<span class="line" id="L794"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-builtin">@TypeOf</span>(a)) <span class="tok-type">bool</span> {</span>
<span class="line" id="L795">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(a);</span>
<span class="line" id="L796"></span>
<span class="line" id="L797">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L798">        .Struct =&gt; |info| {</span>
<span class="line" id="L799">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field_info| {</span>
<span class="line" id="L800">                <span class="tok-kw">if</span> (!eql(<span class="tok-builtin">@field</span>(a, field_info.name), <span class="tok-builtin">@field</span>(b, field_info.name))) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L801">            }</span>
<span class="line" id="L802">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L803">        },</span>
<span class="line" id="L804">        .ErrorUnion =&gt; {</span>
<span class="line" id="L805">            <span class="tok-kw">if</span> (a) |a_p| {</span>
<span class="line" id="L806">                <span class="tok-kw">if</span> (b) |b_p| <span class="tok-kw">return</span> eql(a_p, b_p) <span class="tok-kw">else</span> |_| <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L807">            } <span class="tok-kw">else</span> |a_e| {</span>
<span class="line" id="L808">                <span class="tok-kw">if</span> (b) |_| <span class="tok-kw">return</span> <span class="tok-null">false</span> <span class="tok-kw">else</span> |b_e| <span class="tok-kw">return</span> a_e == b_e;</span>
<span class="line" id="L809">            }</span>
<span class="line" id="L810">        },</span>
<span class="line" id="L811">        .Union =&gt; |info| {</span>
<span class="line" id="L812">            <span class="tok-kw">if</span> (info.tag_type) |UnionTag| {</span>
<span class="line" id="L813">                <span class="tok-kw">const</span> tag_a = activeTag(a);</span>
<span class="line" id="L814">                <span class="tok-kw">const</span> tag_b = activeTag(b);</span>
<span class="line" id="L815">                <span class="tok-kw">if</span> (tag_a != tag_b) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L816"></span>
<span class="line" id="L817">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field_info| {</span>
<span class="line" id="L818">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(UnionTag, field_info.name) == tag_a) {</span>
<span class="line" id="L819">                        <span class="tok-kw">return</span> eql(<span class="tok-builtin">@field</span>(a, field_info.name), <span class="tok-builtin">@field</span>(b, field_info.name));</span>
<span class="line" id="L820">                    }</span>
<span class="line" id="L821">                }</span>
<span class="line" id="L822">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L823">            }</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot compare untagged union type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L826">        },</span>
<span class="line" id="L827">        .Array =&gt; {</span>
<span class="line" id="L828">            <span class="tok-kw">if</span> (a.len != b.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L829">            <span class="tok-kw">for</span> (a) |e, i|</span>
<span class="line" id="L830">                <span class="tok-kw">if</span> (!eql(e, b[i])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L831">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L832">        },</span>
<span class="line" id="L833">        .Vector =&gt; |info| {</span>
<span class="line" id="L834">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L835">            <span class="tok-kw">while</span> (i &lt; info.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L836">                <span class="tok-kw">if</span> (!eql(a[i], b[i])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L837">            }</span>
<span class="line" id="L838">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L839">        },</span>
<span class="line" id="L840">        .Pointer =&gt; |info| {</span>
<span class="line" id="L841">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (info.size) {</span>
<span class="line" id="L842">                .One, .Many, .C =&gt; a == b,</span>
<span class="line" id="L843">                .Slice =&gt; a.ptr == b.ptr <span class="tok-kw">and</span> a.len == b.len,</span>
<span class="line" id="L844">            };</span>
<span class="line" id="L845">        },</span>
<span class="line" id="L846">        .Optional =&gt; {</span>
<span class="line" id="L847">            <span class="tok-kw">if</span> (a == <span class="tok-null">null</span> <span class="tok-kw">and</span> b == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L848">            <span class="tok-kw">if</span> (a == <span class="tok-null">null</span> <span class="tok-kw">or</span> b == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L849">            <span class="tok-kw">return</span> eql(a.?, b.?);</span>
<span class="line" id="L850">        },</span>
<span class="line" id="L851">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> a == b,</span>
<span class="line" id="L852">    }</span>
<span class="line" id="L853">}</span>
<span class="line" id="L854"></span>
<span class="line" id="L855"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.eql&quot;</span> {</span>
<span class="line" id="L856">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L857">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L858">        b: <span class="tok-type">f64</span>,</span>
<span class="line" id="L859">        c: [<span class="tok-number">5</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L860">    };</span>
<span class="line" id="L861"></span>
<span class="line" id="L862">    <span class="tok-kw">const</span> U = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L863">        s: S,</span>
<span class="line" id="L864">        f: ?<span class="tok-type">f32</span>,</span>
<span class="line" id="L865">    };</span>
<span class="line" id="L866"></span>
<span class="line" id="L867">    <span class="tok-kw">const</span> s_1 = S{</span>
<span class="line" id="L868">        .a = <span class="tok-number">134</span>,</span>
<span class="line" id="L869">        .b = <span class="tok-number">123.3</span>,</span>
<span class="line" id="L870">        .c = <span class="tok-str">&quot;12345&quot;</span>.*,</span>
<span class="line" id="L871">    };</span>
<span class="line" id="L872"></span>
<span class="line" id="L873">    <span class="tok-kw">var</span> s_3 = S{</span>
<span class="line" id="L874">        .a = <span class="tok-number">134</span>,</span>
<span class="line" id="L875">        .b = <span class="tok-number">123.3</span>,</span>
<span class="line" id="L876">        .c = <span class="tok-str">&quot;12345&quot;</span>.*,</span>
<span class="line" id="L877">    };</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">    <span class="tok-kw">const</span> u_1 = U{ .f = <span class="tok-number">24</span> };</span>
<span class="line" id="L880">    <span class="tok-kw">const</span> u_2 = U{ .s = s_1 };</span>
<span class="line" id="L881">    <span class="tok-kw">const</span> u_3 = U{ .f = <span class="tok-number">24</span> };</span>
<span class="line" id="L882"></span>
<span class="line" id="L883">    <span class="tok-kw">try</span> testing.expect(eql(s_1, s_3));</span>
<span class="line" id="L884">    <span class="tok-kw">try</span> testing.expect(eql(&amp;s_1, &amp;s_1));</span>
<span class="line" id="L885">    <span class="tok-kw">try</span> testing.expect(!eql(&amp;s_1, &amp;s_3));</span>
<span class="line" id="L886">    <span class="tok-kw">try</span> testing.expect(eql(u_1, u_3));</span>
<span class="line" id="L887">    <span class="tok-kw">try</span> testing.expect(!eql(u_1, u_2));</span>
<span class="line" id="L888"></span>
<span class="line" id="L889">    <span class="tok-kw">var</span> a1 = <span class="tok-str">&quot;abcdef&quot;</span>.*;</span>
<span class="line" id="L890">    <span class="tok-kw">var</span> a2 = <span class="tok-str">&quot;abcdef&quot;</span>.*;</span>
<span class="line" id="L891">    <span class="tok-kw">var</span> a3 = <span class="tok-str">&quot;ghijkl&quot;</span>.*;</span>
<span class="line" id="L892"></span>
<span class="line" id="L893">    <span class="tok-kw">try</span> testing.expect(eql(a1, a2));</span>
<span class="line" id="L894">    <span class="tok-kw">try</span> testing.expect(!eql(a1, a3));</span>
<span class="line" id="L895">    <span class="tok-kw">try</span> testing.expect(!eql(a1[<span class="tok-number">0</span>..], a2[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L896"></span>
<span class="line" id="L897">    <span class="tok-kw">const</span> EU = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L898">        <span class="tok-kw">fn</span> <span class="tok-fn">tst</span>(err: <span class="tok-type">bool</span>) !<span class="tok-type">u8</span> {</span>
<span class="line" id="L899">            <span class="tok-kw">if</span> (err) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Error;</span>
<span class="line" id="L900">            <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L901">        }</span>
<span class="line" id="L902">    };</span>
<span class="line" id="L903"></span>
<span class="line" id="L904">    <span class="tok-kw">try</span> testing.expect(eql(EU.tst(<span class="tok-null">true</span>), EU.tst(<span class="tok-null">true</span>)));</span>
<span class="line" id="L905">    <span class="tok-kw">try</span> testing.expect(eql(EU.tst(<span class="tok-null">false</span>), EU.tst(<span class="tok-null">false</span>)));</span>
<span class="line" id="L906">    <span class="tok-kw">try</span> testing.expect(!eql(EU.tst(<span class="tok-null">false</span>), EU.tst(<span class="tok-null">true</span>)));</span>
<span class="line" id="L907"></span>
<span class="line" id="L908">    <span class="tok-kw">var</span> v1 = <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L909">    <span class="tok-kw">var</span> v2 = <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L910">    <span class="tok-kw">var</span> v3 = <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-kw">try</span> testing.expect(eql(v1, v2));</span>
<span class="line" id="L913">    <span class="tok-kw">try</span> testing.expect(!eql(v1, v3));</span>
<span class="line" id="L914">}</span>
<span class="line" id="L915"></span>
<span class="line" id="L916"><span class="tok-kw">test</span> <span class="tok-str">&quot;intToEnum with error return&quot;</span> {</span>
<span class="line" id="L917">    <span class="tok-kw">const</span> E1 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L918">        A,</span>
<span class="line" id="L919">    };</span>
<span class="line" id="L920">    <span class="tok-kw">const</span> E2 = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L921">        A,</span>
<span class="line" id="L922">        B,</span>
<span class="line" id="L923">    };</span>
<span class="line" id="L924"></span>
<span class="line" id="L925">    <span class="tok-kw">var</span> zero: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L926">    <span class="tok-kw">var</span> one: <span class="tok-type">u16</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L927">    <span class="tok-kw">try</span> testing.expect(intToEnum(E1, zero) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span> == E1.A);</span>
<span class="line" id="L928">    <span class="tok-kw">try</span> testing.expect(intToEnum(E2, one) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span> == E2.B);</span>
<span class="line" id="L929">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.InvalidEnumTag, intToEnum(E1, one));</span>
<span class="line" id="L930">}</span>
<span class="line" id="L931"></span>
<span class="line" id="L932"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IntToEnumError = <span class="tok-kw">error</span>{InvalidEnumTag};</span>
<span class="line" id="L933"></span>
<span class="line" id="L934"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intToEnum</span>(<span class="tok-kw">comptime</span> EnumTag: <span class="tok-type">type</span>, tag_int: <span class="tok-kw">anytype</span>) IntToEnumError!EnumTag {</span>
<span class="line" id="L935">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(EnumTag).Enum.fields) |f| {</span>
<span class="line" id="L936">        <span class="tok-kw">const</span> this_tag_value = <span class="tok-builtin">@field</span>(EnumTag, f.name);</span>
<span class="line" id="L937">        <span class="tok-kw">if</span> (tag_int == <span class="tok-builtin">@enumToInt</span>(this_tag_value)) {</span>
<span class="line" id="L938">            <span class="tok-kw">return</span> this_tag_value;</span>
<span class="line" id="L939">        }</span>
<span class="line" id="L940">    }</span>
<span class="line" id="L941">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidEnumTag;</span>
<span class="line" id="L942">}</span>
<span class="line" id="L943"></span>
<span class="line" id="L944"><span class="tok-comment">/// Given a type and a name, return the field index according to source order.</span></span>
<span class="line" id="L945"><span class="tok-comment">/// Returns `null` if the field is not found.</span></span>
<span class="line" id="L946"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fieldIndex</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?<span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L947">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields(T)) |field, i| {</span>
<span class="line" id="L948">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, field.name, name))</span>
<span class="line" id="L949">            <span class="tok-kw">return</span> i;</span>
<span class="line" id="L950">    }</span>
<span class="line" id="L951">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L952">}</span>
<span class="line" id="L953"></span>
<span class="line" id="L954"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> refAllDecls = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;refAllDecls has been moved from std.meta to std.testing&quot;</span>);</span>
<span class="line" id="L955"></span>
<span class="line" id="L956"><span class="tok-comment">/// Returns a slice of pointers to public declarations of a namespace.</span></span>
<span class="line" id="L957"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">declList</span>(<span class="tok-kw">comptime</span> Namespace: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Decl: <span class="tok-type">type</span>) []<span class="tok-kw">const</span> *<span class="tok-kw">const</span> Decl {</span>
<span class="line" id="L958">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L959">        <span class="tok-kw">fn</span> <span class="tok-fn">declNameLessThan</span>(context: <span class="tok-type">void</span>, lhs: *<span class="tok-kw">const</span> Decl, rhs: *<span class="tok-kw">const</span> Decl) <span class="tok-type">bool</span> {</span>
<span class="line" id="L960">            _ = context;</span>
<span class="line" id="L961">            <span class="tok-kw">return</span> mem.lessThan(<span class="tok-type">u8</span>, lhs.name, rhs.name);</span>
<span class="line" id="L962">        }</span>
<span class="line" id="L963">    };</span>
<span class="line" id="L964">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L965">        <span class="tok-kw">const</span> decls = declarations(Namespace);</span>
<span class="line" id="L966">        <span class="tok-kw">var</span> array: [decls.len]*<span class="tok-kw">const</span> Decl = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L967">        <span class="tok-kw">for</span> (decls) |decl, i| {</span>
<span class="line" id="L968">            array[i] = &amp;<span class="tok-builtin">@field</span>(Namespace, decl.name);</span>
<span class="line" id="L969">        }</span>
<span class="line" id="L970">        std.sort.sort(*<span class="tok-kw">const</span> Decl, &amp;array, {}, S.declNameLessThan);</span>
<span class="line" id="L971">        <span class="tok-kw">return</span> &amp;array;</span>
<span class="line" id="L972">    }</span>
<span class="line" id="L973">}</span>
<span class="line" id="L974"></span>
<span class="line" id="L975"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IntType = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;replaced by std.meta.Int&quot;</span>);</span>
<span class="line" id="L976"></span>
<span class="line" id="L977"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Int</span>(<span class="tok-kw">comptime</span> signedness: std.builtin.Signedness, <span class="tok-kw">comptime</span> bit_count: <span class="tok-type">u16</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L978">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L979">        .Int = .{</span>
<span class="line" id="L980">            .signedness = signedness,</span>
<span class="line" id="L981">            .bits = bit_count,</span>
<span class="line" id="L982">        },</span>
<span class="line" id="L983">    });</span>
<span class="line" id="L984">}</span>
<span class="line" id="L985"></span>
<span class="line" id="L986"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Float</span>(<span class="tok-kw">comptime</span> bit_count: <span class="tok-type">u8</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L987">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L988">        .Float = .{ .bits = bit_count },</span>
<span class="line" id="L989">    });</span>
<span class="line" id="L990">}</span>
<span class="line" id="L991"></span>
<span class="line" id="L992"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.meta.Float&quot;</span> {</span>
<span class="line" id="L993">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">f16</span>, Float(<span class="tok-number">16</span>));</span>
<span class="line" id="L994">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">f32</span>, Float(<span class="tok-number">32</span>));</span>
<span class="line" id="L995">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">f64</span>, Float(<span class="tok-number">64</span>));</span>
<span class="line" id="L996">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">f128</span>, Float(<span class="tok-number">128</span>));</span>
<span class="line" id="L997">}</span>
<span class="line" id="L998"></span>
<span class="line" id="L999"><span class="tok-comment">/// Deprecated. Use `@Vector`.</span></span>
<span class="line" id="L1000"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Vector</span>(<span class="tok-kw">comptime</span> len: <span class="tok-type">u32</span>, <span class="tok-kw">comptime</span> child: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1001">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L1002">        .Vector = .{</span>
<span class="line" id="L1003">            .len = len,</span>
<span class="line" id="L1004">            .child = child,</span>
<span class="line" id="L1005">        },</span>
<span class="line" id="L1006">    });</span>
<span class="line" id="L1007">}</span>
<span class="line" id="L1008"></span>
<span class="line" id="L1009"><span class="tok-comment">/// For a given function type, returns a tuple type which fields will</span></span>
<span class="line" id="L1010"><span class="tok-comment">/// correspond to the argument types.</span></span>
<span class="line" id="L1011"><span class="tok-comment">///</span></span>
<span class="line" id="L1012"><span class="tok-comment">/// Examples:</span></span>
<span class="line" id="L1013"><span class="tok-comment">/// - `ArgsTuple(fn() void)` ⇒ `tuple { }`</span></span>
<span class="line" id="L1014"><span class="tok-comment">/// - `ArgsTuple(fn(a: u32) u32)` ⇒ `tuple { u32 }`</span></span>
<span class="line" id="L1015"><span class="tok-comment">/// - `ArgsTuple(fn(a: u32, b: f16) noreturn)` ⇒ `tuple { u32, f16 }`</span></span>
<span class="line" id="L1016"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArgsTuple</span>(<span class="tok-kw">comptime</span> Function: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1017">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(Function);</span>
<span class="line" id="L1018">    <span class="tok-kw">if</span> (info != .Fn)</span>
<span class="line" id="L1019">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ArgsTuple expects a function type&quot;</span>);</span>
<span class="line" id="L1020"></span>
<span class="line" id="L1021">    <span class="tok-kw">const</span> function_info = info.Fn;</span>
<span class="line" id="L1022">    <span class="tok-kw">if</span> (function_info.is_generic)</span>
<span class="line" id="L1023">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create ArgsTuple for generic function&quot;</span>);</span>
<span class="line" id="L1024">    <span class="tok-kw">if</span> (function_info.is_var_args)</span>
<span class="line" id="L1025">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create ArgsTuple for variadic function&quot;</span>);</span>
<span class="line" id="L1026"></span>
<span class="line" id="L1027">    <span class="tok-kw">var</span> argument_field_list: [function_info.args.len]<span class="tok-type">type</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1028">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (function_info.args) |arg, i| {</span>
<span class="line" id="L1029">        <span class="tok-kw">const</span> T = arg.arg_type.?;</span>
<span class="line" id="L1030">        argument_field_list[i] = T;</span>
<span class="line" id="L1031">    }</span>
<span class="line" id="L1032"></span>
<span class="line" id="L1033">    <span class="tok-kw">return</span> CreateUniqueTuple(argument_field_list.len, argument_field_list);</span>
<span class="line" id="L1034">}</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036"><span class="tok-comment">/// For a given anonymous list of types, returns a new tuple type</span></span>
<span class="line" id="L1037"><span class="tok-comment">/// with those types as fields.</span></span>
<span class="line" id="L1038"><span class="tok-comment">///</span></span>
<span class="line" id="L1039"><span class="tok-comment">/// Examples:</span></span>
<span class="line" id="L1040"><span class="tok-comment">/// - `Tuple(&amp;[_]type {})` ⇒ `tuple { }`</span></span>
<span class="line" id="L1041"><span class="tok-comment">/// - `Tuple(&amp;[_]type {f32})` ⇒ `tuple { f32 }`</span></span>
<span class="line" id="L1042"><span class="tok-comment">/// - `Tuple(&amp;[_]type {f32,u32})` ⇒ `tuple { f32, u32 }`</span></span>
<span class="line" id="L1043"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Tuple</span>(<span class="tok-kw">comptime</span> types: []<span class="tok-kw">const</span> <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1044">    <span class="tok-kw">return</span> CreateUniqueTuple(types.len, types[<span class="tok-number">0</span>..types.len].*);</span>
<span class="line" id="L1045">}</span>
<span class="line" id="L1046"></span>
<span class="line" id="L1047"><span class="tok-kw">fn</span> <span class="tok-fn">CreateUniqueTuple</span>(<span class="tok-kw">comptime</span> N: <span class="tok-type">comptime_int</span>, <span class="tok-kw">comptime</span> types: [N]<span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1048">    <span class="tok-kw">var</span> tuple_fields: [types.len]std.builtin.Type.StructField = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1049">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (types) |T, i| {</span>
<span class="line" id="L1050">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">10_000</span>);</span>
<span class="line" id="L1051">        <span class="tok-kw">var</span> num_buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1052">        tuple_fields[i] = .{</span>
<span class="line" id="L1053">            .name = std.fmt.bufPrint(&amp;num_buf, <span class="tok-str">&quot;{d}&quot;</span>, .{i}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1054">            .field_type = T,</span>
<span class="line" id="L1055">            .default_value = <span class="tok-null">null</span>,</span>
<span class="line" id="L1056">            .is_comptime = <span class="tok-null">false</span>,</span>
<span class="line" id="L1057">            .alignment = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) &gt; <span class="tok-number">0</span>) <span class="tok-builtin">@alignOf</span>(T) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1058">        };</span>
<span class="line" id="L1059">    }</span>
<span class="line" id="L1060"></span>
<span class="line" id="L1061">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L1062">        .Struct = .{</span>
<span class="line" id="L1063">            .is_tuple = <span class="tok-null">true</span>,</span>
<span class="line" id="L1064">            .layout = .Auto,</span>
<span class="line" id="L1065">            .decls = &amp;.{},</span>
<span class="line" id="L1066">            .fields = &amp;tuple_fields,</span>
<span class="line" id="L1067">        },</span>
<span class="line" id="L1068">    });</span>
<span class="line" id="L1069">}</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071"><span class="tok-kw">const</span> TupleTester = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1072">    <span class="tok-kw">fn</span> <span class="tok-fn">assertTypeEqual</span>(<span class="tok-kw">comptime</span> Expected: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Actual: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1073">        <span class="tok-kw">if</span> (Expected != Actual)</span>
<span class="line" id="L1074">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Expected) ++ <span class="tok-str">&quot;, but got type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Actual));</span>
<span class="line" id="L1075">    }</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077">    <span class="tok-kw">fn</span> <span class="tok-fn">assertTuple</span>(<span class="tok-kw">comptime</span> expected: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> Actual: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1078">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(Actual);</span>
<span class="line" id="L1079">        <span class="tok-kw">if</span> (info != .Struct)</span>
<span class="line" id="L1080">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected struct type&quot;</span>);</span>
<span class="line" id="L1081">        <span class="tok-kw">if</span> (!info.Struct.is_tuple)</span>
<span class="line" id="L1082">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Struct type must be a tuple type&quot;</span>);</span>
<span class="line" id="L1083"></span>
<span class="line" id="L1084">        <span class="tok-kw">const</span> fields_list = std.meta.fields(Actual);</span>
<span class="line" id="L1085">        <span class="tok-kw">if</span> (expected.len != fields_list.len)</span>
<span class="line" id="L1086">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Argument count mismatch&quot;</span>);</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (fields_list) |fld, i| {</span>
<span class="line" id="L1089">            <span class="tok-kw">if</span> (expected[i] != fld.field_type) {</span>
<span class="line" id="L1090">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Field &quot;</span> ++ fld.name ++ <span class="tok-str">&quot; expected to be type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(expected[i]) ++ <span class="tok-str">&quot;, but was type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(fld.field_type));</span>
<span class="line" id="L1091">            }</span>
<span class="line" id="L1092">        }</span>
<span class="line" id="L1093">    }</span>
<span class="line" id="L1094">};</span>
<span class="line" id="L1095"></span>
<span class="line" id="L1096"><span class="tok-kw">test</span> <span class="tok-str">&quot;ArgsTuple&quot;</span> {</span>
<span class="line" id="L1097">    TupleTester.assertTuple(.{}, ArgsTuple(<span class="tok-kw">fn</span> () <span class="tok-type">void</span>));</span>
<span class="line" id="L1098">    TupleTester.assertTuple(.{<span class="tok-type">u32</span>}, ArgsTuple(<span class="tok-kw">fn</span> (a: <span class="tok-type">u32</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L1099">    TupleTester.assertTuple(.{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span> }, ArgsTuple(<span class="tok-kw">fn</span> (a: <span class="tok-type">u32</span>, b: <span class="tok-type">f16</span>) <span class="tok-type">noreturn</span>));</span>
<span class="line" id="L1100">    TupleTester.assertTuple(.{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span>, []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-type">void</span> }, ArgsTuple(<span class="tok-kw">fn</span> (a: <span class="tok-type">u32</span>, b: <span class="tok-type">f16</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-type">void</span>) <span class="tok-type">noreturn</span>));</span>
<span class="line" id="L1101">}</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103"><span class="tok-kw">test</span> <span class="tok-str">&quot;Tuple&quot;</span> {</span>
<span class="line" id="L1104">    TupleTester.assertTuple(.{}, Tuple(&amp;[_]<span class="tok-type">type</span>{}));</span>
<span class="line" id="L1105">    TupleTester.assertTuple(.{<span class="tok-type">u32</span>}, Tuple(&amp;[_]<span class="tok-type">type</span>{<span class="tok-type">u32</span>}));</span>
<span class="line" id="L1106">    TupleTester.assertTuple(.{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span> }, Tuple(&amp;[_]<span class="tok-type">type</span>{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span> }));</span>
<span class="line" id="L1107">    TupleTester.assertTuple(.{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span>, []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-type">void</span> }, Tuple(&amp;[_]<span class="tok-type">type</span>{ <span class="tok-type">u32</span>, <span class="tok-type">f16</span>, []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-type">void</span> }));</span>
<span class="line" id="L1108">}</span>
<span class="line" id="L1109"></span>
<span class="line" id="L1110"><span class="tok-kw">test</span> <span class="tok-str">&quot;Tuple deduplication&quot;</span> {</span>
<span class="line" id="L1111">    <span class="tok-kw">const</span> T1 = std.meta.Tuple(&amp;.{ <span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i8</span> });</span>
<span class="line" id="L1112">    <span class="tok-kw">const</span> T2 = std.meta.Tuple(&amp;.{ <span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i8</span> });</span>
<span class="line" id="L1113">    <span class="tok-kw">const</span> T3 = std.meta.Tuple(&amp;.{ <span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i7</span> });</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">    <span class="tok-kw">if</span> (T1 != T2) {</span>
<span class="line" id="L1116">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.meta.Tuple doesn't deduplicate tuple types.&quot;</span>);</span>
<span class="line" id="L1117">    }</span>
<span class="line" id="L1118">    <span class="tok-kw">if</span> (T1 == T3) {</span>
<span class="line" id="L1119">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.meta.Tuple fails to generate different types.&quot;</span>);</span>
<span class="line" id="L1120">    }</span>
<span class="line" id="L1121">}</span>
<span class="line" id="L1122"></span>
<span class="line" id="L1123"><span class="tok-kw">test</span> <span class="tok-str">&quot;ArgsTuple forwarding&quot;</span> {</span>
<span class="line" id="L1124">    <span class="tok-kw">const</span> T1 = std.meta.Tuple(&amp;.{ <span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i8</span> });</span>
<span class="line" id="L1125">    <span class="tok-kw">const</span> T2 = std.meta.ArgsTuple(<span class="tok-kw">fn</span> (<span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i8</span>) <span class="tok-type">void</span>);</span>
<span class="line" id="L1126">    <span class="tok-kw">const</span> T3 = std.meta.ArgsTuple(<span class="tok-kw">fn</span> (<span class="tok-type">u32</span>, <span class="tok-type">f32</span>, <span class="tok-type">i8</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span>);</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128">    <span class="tok-kw">if</span> (T1 != T2) {</span>
<span class="line" id="L1129">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.meta.ArgsTuple produces different types than std.meta.Tuple&quot;</span>);</span>
<span class="line" id="L1130">    }</span>
<span class="line" id="L1131">    <span class="tok-kw">if</span> (T1 != T3) {</span>
<span class="line" id="L1132">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.meta.ArgsTuple produces different types for the same argument lists.&quot;</span>);</span>
<span class="line" id="L1133">    }</span>
<span class="line" id="L1134">}</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136"><span class="tok-comment">/// TODO: https://github.com/ziglang/zig/issues/425</span></span>
<span class="line" id="L1137"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">globalOption</span>(<span class="tok-kw">comptime</span> name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) ?T {</span>
<span class="line" id="L1138">    <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(root, name))</span>
<span class="line" id="L1139">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1140">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(T, <span class="tok-builtin">@field</span>(root, name));</span>
<span class="line" id="L1141">}</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143"><span class="tok-comment">/// Returns whether `error_union` contains an error.</span></span>
<span class="line" id="L1144"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isError</span>(error_union: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1145">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (error_union) |_| <span class="tok-null">false</span> <span class="tok-kw">else</span> |_| <span class="tok-null">true</span>;</span>
<span class="line" id="L1146">}</span>
<span class="line" id="L1147"></span>
<span class="line" id="L1148"><span class="tok-kw">test</span> <span class="tok-str">&quot;isError&quot;</span> {</span>
<span class="line" id="L1149">    <span class="tok-kw">try</span> std.testing.expect(isError(math.absInt(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">128</span>))));</span>
<span class="line" id="L1150">    <span class="tok-kw">try</span> std.testing.expect(!isError(math.absInt(<span class="tok-builtin">@as</span>(<span class="tok-type">i8</span>, -<span class="tok-number">127</span>))));</span>
<span class="line" id="L1151">}</span>
<span class="line" id="L1152"></span>
</code></pre></body>
</html>