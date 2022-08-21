<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash/auto_hash.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Describes how pointer types should be hashed.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashStrategy = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L8">    <span class="tok-comment">/// Do not follow pointers, only hash their value.</span></span>
<span class="line" id="L9">    Shallow,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-comment">/// Follow pointers, hash the pointee content.</span></span>
<span class="line" id="L12">    <span class="tok-comment">/// Only dereferences one level, ie. it is changed into .Shallow when a</span></span>
<span class="line" id="L13">    <span class="tok-comment">/// pointer type is encountered.</span></span>
<span class="line" id="L14">    Deep,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-comment">/// Follow pointers, hash the pointee content.</span></span>
<span class="line" id="L17">    <span class="tok-comment">/// Dereferences all pointers encountered.</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// Assumes no cycle.</span></span>
<span class="line" id="L19">    DeepRecursive,</span>
<span class="line" id="L20">};</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Helper function to hash a pointer and mutate the strategy if needed.</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashPointer</span>(hasher: <span class="tok-kw">anytype</span>, key: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> strat: HashStrategy) <span class="tok-type">void</span> {</span>
<span class="line" id="L24">    <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(key));</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-kw">switch</span> (info.Pointer.size) {</span>
<span class="line" id="L27">        .One =&gt; <span class="tok-kw">switch</span> (strat) {</span>
<span class="line" id="L28">            .Shallow =&gt; hash(hasher, <span class="tok-builtin">@ptrToInt</span>(key), .Shallow),</span>
<span class="line" id="L29">            .Deep =&gt; hash(hasher, key.*, .Shallow),</span>
<span class="line" id="L30">            .DeepRecursive =&gt; hash(hasher, key.*, .DeepRecursive),</span>
<span class="line" id="L31">        },</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">        .Slice =&gt; {</span>
<span class="line" id="L34">            <span class="tok-kw">switch</span> (strat) {</span>
<span class="line" id="L35">                .Shallow =&gt; {</span>
<span class="line" id="L36">                    hashPointer(hasher, key.ptr, .Shallow);</span>
<span class="line" id="L37">                },</span>
<span class="line" id="L38">                .Deep =&gt; hashArray(hasher, key, .Shallow),</span>
<span class="line" id="L39">                .DeepRecursive =&gt; hashArray(hasher, key, .DeepRecursive),</span>
<span class="line" id="L40">            }</span>
<span class="line" id="L41">            hash(hasher, key.len, .Shallow);</span>
<span class="line" id="L42">        },</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">        .Many,</span>
<span class="line" id="L45">        .C,</span>
<span class="line" id="L46">        =&gt; <span class="tok-kw">switch</span> (strat) {</span>
<span class="line" id="L47">            .Shallow =&gt; hash(hasher, <span class="tok-builtin">@ptrToInt</span>(key), .Shallow),</span>
<span class="line" id="L48">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(</span>
<span class="line" id="L49">                <span class="tok-str">\\ unknown-length pointers and C pointers cannot be hashed deeply.</span></span>

<span class="line" id="L50">                <span class="tok-str">\\ Consider providing your own hash function.</span></span>

<span class="line" id="L51">            ),</span>
<span class="line" id="L52">        },</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54">}</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-comment">/// Helper function to hash a set of contiguous objects, from an array or slice.</span></span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashArray</span>(hasher: <span class="tok-kw">anytype</span>, key: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> strat: HashStrategy) <span class="tok-type">void</span> {</span>
<span class="line" id="L58">    <span class="tok-kw">for</span> (key) |element| {</span>
<span class="line" id="L59">        hash(hasher, element, strat);</span>
<span class="line" id="L60">    }</span>
<span class="line" id="L61">}</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">/// Provides generic hashing for any eligible type.</span></span>
<span class="line" id="L64"><span class="tok-comment">/// Strategy is provided to determine if pointers should be followed or not.</span></span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(hasher: <span class="tok-kw">anytype</span>, key: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> strat: HashStrategy) <span class="tok-type">void</span> {</span>
<span class="line" id="L66">    <span class="tok-kw">const</span> Key = <span class="tok-builtin">@TypeOf</span>(key);</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">    <span class="tok-kw">if</span> (strat == .Shallow <span class="tok-kw">and</span> <span class="tok-kw">comptime</span> meta.trait.hasUniqueRepresentation(Key)) {</span>
<span class="line" id="L69">        <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hasher.update, .{mem.asBytes(&amp;key)});</span>
<span class="line" id="L70">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L71">    }</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Key)) {</span>
<span class="line" id="L74">        .NoReturn,</span>
<span class="line" id="L75">        .Opaque,</span>
<span class="line" id="L76">        .Undefined,</span>
<span class="line" id="L77">        .Null,</span>
<span class="line" id="L78">        .ComptimeFloat,</span>
<span class="line" id="L79">        .ComptimeInt,</span>
<span class="line" id="L80">        .Type,</span>
<span class="line" id="L81">        .EnumLiteral,</span>
<span class="line" id="L82">        .Frame,</span>
<span class="line" id="L83">        .Float,</span>
<span class="line" id="L84">        =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unable to hash type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Key)),</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">        .Void =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-comment">// Help the optimizer see that hashing an int is easy by inlining!</span>
</span>
<span class="line" id="L89">        <span class="tok-comment">// TODO Check if the situation is better after #561 is resolved.</span>
</span>
<span class="line" id="L90">        .Int =&gt; {</span>
<span class="line" id="L91">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> meta.trait.hasUniqueRepresentation(Key)) {</span>
<span class="line" id="L92">                <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hasher.update, .{std.mem.asBytes(&amp;key)});</span>
<span class="line" id="L93">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L94">                <span class="tok-comment">// Take only the part containing the key value, the remaining</span>
</span>
<span class="line" id="L95">                <span class="tok-comment">// bytes are undefined and must not be hashed!</span>
</span>
<span class="line" id="L96">                <span class="tok-kw">const</span> byte_size = <span class="tok-kw">comptime</span> std.math.divCeil(<span class="tok-type">comptime_int</span>, <span class="tok-builtin">@bitSizeOf</span>(Key), <span class="tok-number">8</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L97">                <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hasher.update, .{std.mem.asBytes(&amp;key)[<span class="tok-number">0</span>..byte_size]});</span>
<span class="line" id="L98">            }</span>
<span class="line" id="L99">        },</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">        .Bool =&gt; hash(hasher, <span class="tok-builtin">@boolToInt</span>(key), strat),</span>
<span class="line" id="L102">        .Enum =&gt; hash(hasher, <span class="tok-builtin">@enumToInt</span>(key), strat),</span>
<span class="line" id="L103">        .ErrorSet =&gt; hash(hasher, <span class="tok-builtin">@errorToInt</span>(key), strat),</span>
<span class="line" id="L104">        .AnyFrame, .BoundFn, .Fn =&gt; hash(hasher, <span class="tok-builtin">@ptrToInt</span>(key), strat),</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        .Pointer =&gt; <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, hashPointer, .{ hasher, key, strat }),</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        .Optional =&gt; <span class="tok-kw">if</span> (key) |k| hash(hasher, k, strat),</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        .Array =&gt; hashArray(hasher, key, strat),</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        .Vector =&gt; |info| {</span>
<span class="line" id="L113">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> meta.trait.hasUniqueRepresentation(Key)) {</span>
<span class="line" id="L114">                hasher.update(mem.asBytes(&amp;key));</span>
<span class="line" id="L115">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L116">                <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L117">                <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; info.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L118">                    hash(hasher, key[i], strat);</span>
<span class="line" id="L119">                }</span>
<span class="line" id="L120">            }</span>
<span class="line" id="L121">        },</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">        .Struct =&gt; |info| {</span>
<span class="line" id="L124">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field| {</span>
<span class="line" id="L125">                <span class="tok-comment">// We reuse the hash of the previous field as the seed for the</span>
</span>
<span class="line" id="L126">                <span class="tok-comment">// next one so that they're dependant.</span>
</span>
<span class="line" id="L127">                hash(hasher, <span class="tok-builtin">@field</span>(key, field.name), strat);</span>
<span class="line" id="L128">            }</span>
<span class="line" id="L129">        },</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">        .Union =&gt; |info| {</span>
<span class="line" id="L132">            <span class="tok-kw">if</span> (info.tag_type) |tag_type| {</span>
<span class="line" id="L133">                <span class="tok-kw">const</span> tag = meta.activeTag(key);</span>
<span class="line" id="L134">                hash(hasher, tag, strat);</span>
<span class="line" id="L135">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field| {</span>
<span class="line" id="L136">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(tag_type, field.name) == tag) {</span>
<span class="line" id="L137">                        <span class="tok-kw">if</span> (field.field_type != <span class="tok-type">void</span>) {</span>
<span class="line" id="L138">                            hash(hasher, <span class="tok-builtin">@field</span>(key, field.name), strat);</span>
<span class="line" id="L139">                        }</span>
<span class="line" id="L140">                        <span class="tok-comment">// TODO use a labelled break when it does not crash the compiler. cf #2908</span>
</span>
<span class="line" id="L141">                        <span class="tok-comment">// break :blk;</span>
</span>
<span class="line" id="L142">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L143">                    }</span>
<span class="line" id="L144">                }</span>
<span class="line" id="L145">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L146">            } <span class="tok-kw">else</span> <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cannot hash untagged union type: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Key) ++ <span class="tok-str">&quot;, provide your own hash function&quot;</span>);</span>
<span class="line" id="L147">        },</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">        .ErrorUnion =&gt; blk: {</span>
<span class="line" id="L150">            <span class="tok-kw">const</span> payload = key <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L151">                hash(hasher, err, strat);</span>
<span class="line" id="L152">                <span class="tok-kw">break</span> :blk;</span>
<span class="line" id="L153">            };</span>
<span class="line" id="L154">            hash(hasher, payload, strat);</span>
<span class="line" id="L155">        },</span>
<span class="line" id="L156">    }</span>
<span class="line" id="L157">}</span>
<span class="line" id="L158"></span>
<span class="line" id="L159"><span class="tok-kw">fn</span> <span class="tok-fn">typeContainsSlice</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L160">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L161">        <span class="tok-kw">if</span> (meta.trait.isSlice(K)) {</span>
<span class="line" id="L162">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L163">        }</span>
<span class="line" id="L164">        <span class="tok-kw">if</span> (meta.trait.is(.Struct)(K)) {</span>
<span class="line" id="L165">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(K).Struct.fields) |field| {</span>
<span class="line" id="L166">                <span class="tok-kw">if</span> (typeContainsSlice(field.field_type)) {</span>
<span class="line" id="L167">                    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L168">                }</span>
<span class="line" id="L169">            }</span>
<span class="line" id="L170">        }</span>
<span class="line" id="L171">        <span class="tok-kw">if</span> (meta.trait.is(.Union)(K)) {</span>
<span class="line" id="L172">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(K).Union.fields) |field| {</span>
<span class="line" id="L173">                <span class="tok-kw">if</span> (typeContainsSlice(field.field_type)) {</span>
<span class="line" id="L174">                    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L175">                }</span>
<span class="line" id="L176">            }</span>
<span class="line" id="L177">        }</span>
<span class="line" id="L178">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L179">    }</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-comment">/// Provides generic hashing for any eligible type.</span></span>
<span class="line" id="L183"><span class="tok-comment">/// Only hashes `key` itself, pointers are not followed.</span></span>
<span class="line" id="L184"><span class="tok-comment">/// Slices as well as unions and structs containing slices are rejected to avoid</span></span>
<span class="line" id="L185"><span class="tok-comment">/// ambiguity on the user's intention.</span></span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">autoHash</span>(hasher: <span class="tok-kw">anytype</span>, key: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L187">    <span class="tok-kw">const</span> Key = <span class="tok-builtin">@TypeOf</span>(key);</span>
<span class="line" id="L188">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> typeContainsSlice(Key)) {</span>
<span class="line" id="L189">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.hash.autoHash does not allow slices as well as unions and structs containing slices here (&quot;</span> ++ <span class="tok-builtin">@typeName</span>(Key) ++</span>
<span class="line" id="L190">            <span class="tok-str">&quot;) because the intent is unclear. Consider using std.hash.autoHashStrat or providing your own hash function instead.&quot;</span>);</span>
<span class="line" id="L191">    }</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    hash(hasher, key, .Shallow);</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L197"><span class="tok-kw">const</span> Wyhash = std.hash.Wyhash;</span>
<span class="line" id="L198"></span>
<span class="line" id="L199"><span class="tok-kw">fn</span> <span class="tok-fn">testHash</span>(key: <span class="tok-kw">anytype</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L200">    <span class="tok-comment">// Any hash could be used here, for testing autoHash.</span>
</span>
<span class="line" id="L201">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L202">    hash(&amp;hasher, key, .Shallow);</span>
<span class="line" id="L203">    <span class="tok-kw">return</span> hasher.final();</span>
<span class="line" id="L204">}</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-kw">fn</span> <span class="tok-fn">testHashShallow</span>(key: <span class="tok-kw">anytype</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L207">    <span class="tok-comment">// Any hash could be used here, for testing autoHash.</span>
</span>
<span class="line" id="L208">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L209">    hash(&amp;hasher, key, .Shallow);</span>
<span class="line" id="L210">    <span class="tok-kw">return</span> hasher.final();</span>
<span class="line" id="L211">}</span>
<span class="line" id="L212"></span>
<span class="line" id="L213"><span class="tok-kw">fn</span> <span class="tok-fn">testHashDeep</span>(key: <span class="tok-kw">anytype</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L214">    <span class="tok-comment">// Any hash could be used here, for testing autoHash.</span>
</span>
<span class="line" id="L215">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L216">    hash(&amp;hasher, key, .Deep);</span>
<span class="line" id="L217">    <span class="tok-kw">return</span> hasher.final();</span>
<span class="line" id="L218">}</span>
<span class="line" id="L219"></span>
<span class="line" id="L220"><span class="tok-kw">fn</span> <span class="tok-fn">testHashDeepRecursive</span>(key: <span class="tok-kw">anytype</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L221">    <span class="tok-comment">// Any hash could be used here, for testing autoHash.</span>
</span>
<span class="line" id="L222">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L223">    hash(&amp;hasher, key, .DeepRecursive);</span>
<span class="line" id="L224">    <span class="tok-kw">return</span> hasher.final();</span>
<span class="line" id="L225">}</span>
<span class="line" id="L226"></span>
<span class="line" id="L227"><span class="tok-kw">test</span> <span class="tok-str">&quot;typeContainsSlice&quot;</span> {</span>
<span class="line" id="L228">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L229">        <span class="tok-kw">try</span> testing.expect(!typeContainsSlice(meta.Tag(std.builtin.Type)));</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">        <span class="tok-kw">try</span> testing.expect(typeContainsSlice([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>));</span>
<span class="line" id="L232">        <span class="tok-kw">try</span> testing.expect(!typeContainsSlice(<span class="tok-type">u8</span>));</span>
<span class="line" id="L233">        <span class="tok-kw">const</span> A = <span class="tok-kw">struct</span> { x: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> };</span>
<span class="line" id="L234">        <span class="tok-kw">const</span> B = <span class="tok-kw">struct</span> { a: A };</span>
<span class="line" id="L235">        <span class="tok-kw">const</span> C = <span class="tok-kw">struct</span> { b: B };</span>
<span class="line" id="L236">        <span class="tok-kw">const</span> D = <span class="tok-kw">struct</span> { x: <span class="tok-type">u8</span> };</span>
<span class="line" id="L237">        <span class="tok-kw">try</span> testing.expect(typeContainsSlice(A));</span>
<span class="line" id="L238">        <span class="tok-kw">try</span> testing.expect(typeContainsSlice(B));</span>
<span class="line" id="L239">        <span class="tok-kw">try</span> testing.expect(typeContainsSlice(C));</span>
<span class="line" id="L240">        <span class="tok-kw">try</span> testing.expect(!typeContainsSlice(D));</span>
<span class="line" id="L241">    }</span>
<span class="line" id="L242">}</span>
<span class="line" id="L243"></span>
<span class="line" id="L244"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash pointer&quot;</span> {</span>
<span class="line" id="L245">    <span class="tok-kw">const</span> array = [_]<span class="tok-type">u32</span>{ <span class="tok-number">123</span>, <span class="tok-number">123</span>, <span class="tok-number">123</span> };</span>
<span class="line" id="L246">    <span class="tok-kw">const</span> a = &amp;array[<span class="tok-number">0</span>];</span>
<span class="line" id="L247">    <span class="tok-kw">const</span> b = &amp;array[<span class="tok-number">1</span>];</span>
<span class="line" id="L248">    <span class="tok-kw">const</span> c = &amp;array[<span class="tok-number">2</span>];</span>
<span class="line" id="L249">    <span class="tok-kw">const</span> d = a;</span>
<span class="line" id="L250"></span>
<span class="line" id="L251">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) == testHashShallow(d));</span>
<span class="line" id="L252">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) != testHashShallow(c));</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) != testHashShallow(b));</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(a));</span>
<span class="line" id="L256">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(c));</span>
<span class="line" id="L257">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(b));</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">    <span class="tok-kw">try</span> testing.expect(testHashDeepRecursive(a) == testHashDeepRecursive(a));</span>
<span class="line" id="L260">    <span class="tok-kw">try</span> testing.expect(testHashDeepRecursive(a) == testHashDeepRecursive(c));</span>
<span class="line" id="L261">    <span class="tok-kw">try</span> testing.expect(testHashDeepRecursive(a) == testHashDeepRecursive(b));</span>
<span class="line" id="L262">}</span>
<span class="line" id="L263"></span>
<span class="line" id="L264"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash slice shallow&quot;</span> {</span>
<span class="line" id="L265">    <span class="tok-comment">// Allocate one array dynamically so that we're assured it is not merged</span>
</span>
<span class="line" id="L266">    <span class="tok-comment">// with the other by the optimization passes.</span>
</span>
<span class="line" id="L267">    <span class="tok-kw">const</span> array1 = <span class="tok-kw">try</span> std.testing.allocator.create([<span class="tok-number">6</span>]<span class="tok-type">u32</span>);</span>
<span class="line" id="L268">    <span class="tok-kw">defer</span> std.testing.allocator.destroy(array1);</span>
<span class="line" id="L269">    array1.* = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L270">    <span class="tok-kw">const</span> array2 = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L271">    <span class="tok-comment">// TODO audit deep/shallow - maybe it has the wrong behavior with respect to array pointers and slices</span>
</span>
<span class="line" id="L272">    <span class="tok-kw">var</span> runtime_zero: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L273">    <span class="tok-kw">const</span> a = array1[runtime_zero..];</span>
<span class="line" id="L274">    <span class="tok-kw">const</span> b = array2[runtime_zero..];</span>
<span class="line" id="L275">    <span class="tok-kw">const</span> c = array1[runtime_zero..<span class="tok-number">3</span>];</span>
<span class="line" id="L276">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) == testHashShallow(a));</span>
<span class="line" id="L277">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) != testHashShallow(array1));</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) != testHashShallow(b));</span>
<span class="line" id="L279">    <span class="tok-kw">try</span> testing.expect(testHashShallow(a) != testHashShallow(c));</span>
<span class="line" id="L280">}</span>
<span class="line" id="L281"></span>
<span class="line" id="L282"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash slice deep&quot;</span> {</span>
<span class="line" id="L283">    <span class="tok-comment">// Allocate one array dynamically so that we're assured it is not merged</span>
</span>
<span class="line" id="L284">    <span class="tok-comment">// with the other by the optimization passes.</span>
</span>
<span class="line" id="L285">    <span class="tok-kw">const</span> array1 = <span class="tok-kw">try</span> std.testing.allocator.create([<span class="tok-number">6</span>]<span class="tok-type">u32</span>);</span>
<span class="line" id="L286">    <span class="tok-kw">defer</span> std.testing.allocator.destroy(array1);</span>
<span class="line" id="L287">    array1.* = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L288">    <span class="tok-kw">const</span> array2 = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> };</span>
<span class="line" id="L289">    <span class="tok-kw">const</span> a = array1[<span class="tok-number">0</span>..];</span>
<span class="line" id="L290">    <span class="tok-kw">const</span> b = array2[<span class="tok-number">0</span>..];</span>
<span class="line" id="L291">    <span class="tok-kw">const</span> c = array1[<span class="tok-number">0</span>..<span class="tok-number">3</span>];</span>
<span class="line" id="L292">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(a));</span>
<span class="line" id="L293">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(array1));</span>
<span class="line" id="L294">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) == testHashDeep(b));</span>
<span class="line" id="L295">    <span class="tok-kw">try</span> testing.expect(testHashDeep(a) != testHashDeep(c));</span>
<span class="line" id="L296">}</span>
<span class="line" id="L297"></span>
<span class="line" id="L298"><span class="tok-kw">test</span> <span class="tok-str">&quot;hash struct deep&quot;</span> {</span>
<span class="line" id="L299">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L300">        a: <span class="tok-type">u32</span>,</span>
<span class="line" id="L301">        b: <span class="tok-type">u16</span>,</span>
<span class="line" id="L302">        c: *<span class="tok-type">bool</span>,</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L305"></span>
<span class="line" id="L306">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator, a_: <span class="tok-type">u32</span>, b_: <span class="tok-type">u16</span>, c_: <span class="tok-type">bool</span>) !Self {</span>
<span class="line" id="L307">            <span class="tok-kw">const</span> ptr = <span class="tok-kw">try</span> allocator.create(<span class="tok-type">bool</span>);</span>
<span class="line" id="L308">            ptr.* = c_;</span>
<span class="line" id="L309">            <span class="tok-kw">return</span> Self{ .a = a_, .b = b_, .c = ptr };</span>
<span class="line" id="L310">        }</span>
<span class="line" id="L311">    };</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L314">    <span class="tok-kw">const</span> foo = <span class="tok-kw">try</span> Foo.init(allocator, <span class="tok-number">123</span>, <span class="tok-number">10</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L315">    <span class="tok-kw">const</span> bar = <span class="tok-kw">try</span> Foo.init(allocator, <span class="tok-number">123</span>, <span class="tok-number">10</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L316">    <span class="tok-kw">const</span> baz = <span class="tok-kw">try</span> Foo.init(allocator, <span class="tok-number">123</span>, <span class="tok-number">10</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L317">    <span class="tok-kw">defer</span> allocator.destroy(foo.c);</span>
<span class="line" id="L318">    <span class="tok-kw">defer</span> allocator.destroy(bar.c);</span>
<span class="line" id="L319">    <span class="tok-kw">defer</span> allocator.destroy(baz.c);</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-kw">try</span> testing.expect(testHashDeep(foo) == testHashDeep(bar));</span>
<span class="line" id="L322">    <span class="tok-kw">try</span> testing.expect(testHashDeep(foo) != testHashDeep(baz));</span>
<span class="line" id="L323">    <span class="tok-kw">try</span> testing.expect(testHashDeep(bar) != testHashDeep(baz));</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L326">    <span class="tok-kw">const</span> h = testHashDeep(foo);</span>
<span class="line" id="L327">    autoHash(&amp;hasher, foo.a);</span>
<span class="line" id="L328">    autoHash(&amp;hasher, foo.b);</span>
<span class="line" id="L329">    autoHash(&amp;hasher, foo.c.*);</span>
<span class="line" id="L330">    <span class="tok-kw">try</span> testing.expectEqual(h, hasher.final());</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">    <span class="tok-kw">const</span> h2 = testHashDeepRecursive(&amp;foo);</span>
<span class="line" id="L333">    <span class="tok-kw">try</span> testing.expect(h2 != testHashDeep(&amp;foo));</span>
<span class="line" id="L334">    <span class="tok-kw">try</span> testing.expect(h2 == testHashDeep(foo));</span>
<span class="line" id="L335">}</span>
<span class="line" id="L336"></span>
<span class="line" id="L337"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash optional&quot;</span> {</span>
<span class="line" id="L338">    <span class="tok-kw">const</span> a: ?<span class="tok-type">u32</span> = <span class="tok-number">123</span>;</span>
<span class="line" id="L339">    <span class="tok-kw">const</span> b: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L340">    <span class="tok-kw">try</span> testing.expectEqual(testHash(a), testHash(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">123</span>)));</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(b));</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> testing.expectEqual(testHash(b), <span class="tok-number">0</span>);</span>
<span class="line" id="L343">}</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash array&quot;</span> {</span>
<span class="line" id="L346">    <span class="tok-kw">const</span> a = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> };</span>
<span class="line" id="L347">    <span class="tok-kw">const</span> h = testHash(a);</span>
<span class="line" id="L348">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L349">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L350">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L351">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L352">    <span class="tok-kw">try</span> testing.expectEqual(h, hasher.final());</span>
<span class="line" id="L353">}</span>
<span class="line" id="L354"></span>
<span class="line" id="L355"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash multi-dimensional array&quot;</span> {</span>
<span class="line" id="L356">    <span class="tok-kw">const</span> a = [_][]<span class="tok-kw">const</span> <span class="tok-type">u32</span>{ &amp;.{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span> }, &amp;.{ <span class="tok-number">4</span>, <span class="tok-number">5</span> } };</span>
<span class="line" id="L357">    <span class="tok-kw">const</span> b = [_][]<span class="tok-kw">const</span> <span class="tok-type">u32</span>{ &amp;.{ <span class="tok-number">1</span>, <span class="tok-number">2</span> }, &amp;.{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span> } };</span>
<span class="line" id="L358">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(b));</span>
<span class="line" id="L359">}</span>
<span class="line" id="L360"></span>
<span class="line" id="L361"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash struct&quot;</span> {</span>
<span class="line" id="L362">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L363">        a: <span class="tok-type">u32</span> = <span class="tok-number">1</span>,</span>
<span class="line" id="L364">        b: <span class="tok-type">u32</span> = <span class="tok-number">2</span>,</span>
<span class="line" id="L365">        c: <span class="tok-type">u32</span> = <span class="tok-number">3</span>,</span>
<span class="line" id="L366">    };</span>
<span class="line" id="L367">    <span class="tok-kw">const</span> f = Foo{};</span>
<span class="line" id="L368">    <span class="tok-kw">const</span> h = testHash(f);</span>
<span class="line" id="L369">    <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L370">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>));</span>
<span class="line" id="L371">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L372">    autoHash(&amp;hasher, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">3</span>));</span>
<span class="line" id="L373">    <span class="tok-kw">try</span> testing.expectEqual(h, hasher.final());</span>
<span class="line" id="L374">}</span>
<span class="line" id="L375"></span>
<span class="line" id="L376"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash union&quot;</span> {</span>
<span class="line" id="L377">    <span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L378">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage2_llvm <span class="tok-kw">and</span> builtin.mode == .ReleaseSafe) {</span>
<span class="line" id="L379">        <span class="tok-comment">// https://github.com/ziglang/zig/issues/12178</span>
</span>
<span class="line" id="L380">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L381">    }</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L384">        A: <span class="tok-type">u32</span>,</span>
<span class="line" id="L385">        B: <span class="tok-type">bool</span>,</span>
<span class="line" id="L386">        C: <span class="tok-type">u32</span>,</span>
<span class="line" id="L387">        D: <span class="tok-type">void</span>,</span>
<span class="line" id="L388">    };</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-kw">const</span> a = Foo{ .A = <span class="tok-number">18</span> };</span>
<span class="line" id="L391">    <span class="tok-kw">var</span> b = Foo{ .B = <span class="tok-null">true</span> };</span>
<span class="line" id="L392">    <span class="tok-kw">const</span> c = Foo{ .C = <span class="tok-number">18</span> };</span>
<span class="line" id="L393">    <span class="tok-kw">const</span> d: Foo = .D;</span>
<span class="line" id="L394">    <span class="tok-kw">try</span> testing.expect(testHash(a) == testHash(a));</span>
<span class="line" id="L395">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(b));</span>
<span class="line" id="L396">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(c));</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(d));</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    b = Foo{ .A = <span class="tok-number">18</span> };</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> testing.expect(testHash(a) == testHash(b));</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">    b = .D;</span>
<span class="line" id="L403">    <span class="tok-kw">try</span> testing.expect(testHash(d) == testHash(b));</span>
<span class="line" id="L404">}</span>
<span class="line" id="L405"></span>
<span class="line" id="L406"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash vector&quot;</span> {</span>
<span class="line" id="L407">    <span class="tok-kw">const</span> a: meta.Vector(<span class="tok-number">4</span>, <span class="tok-type">u32</span>) = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L408">    <span class="tok-kw">const</span> b: meta.Vector(<span class="tok-number">4</span>, <span class="tok-type">u32</span>) = [_]<span class="tok-type">u32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L409">    <span class="tok-kw">try</span> testing.expect(testHash(a) == testHash(a));</span>
<span class="line" id="L410">    <span class="tok-kw">try</span> testing.expect(testHash(a) != testHash(b));</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">const</span> c: meta.Vector(<span class="tok-number">4</span>, <span class="tok-type">u31</span>) = [_]<span class="tok-type">u31</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span> };</span>
<span class="line" id="L413">    <span class="tok-kw">const</span> d: meta.Vector(<span class="tok-number">4</span>, <span class="tok-type">u31</span>) = [_]<span class="tok-type">u31</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">5</span> };</span>
<span class="line" id="L414">    <span class="tok-kw">try</span> testing.expect(testHash(c) == testHash(c));</span>
<span class="line" id="L415">    <span class="tok-kw">try</span> testing.expect(testHash(c) != testHash(d));</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">test</span> <span class="tok-str">&quot;testHash error union&quot;</span> {</span>
<span class="line" id="L419">    <span class="tok-kw">const</span> Errors = <span class="tok-kw">error</span>{Test};</span>
<span class="line" id="L420">    <span class="tok-kw">const</span> Foo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L421">        a: <span class="tok-type">u32</span> = <span class="tok-number">1</span>,</span>
<span class="line" id="L422">        b: <span class="tok-type">u32</span> = <span class="tok-number">2</span>,</span>
<span class="line" id="L423">        c: <span class="tok-type">u32</span> = <span class="tok-number">3</span>,</span>
<span class="line" id="L424">    };</span>
<span class="line" id="L425">    <span class="tok-kw">const</span> f = Foo{};</span>
<span class="line" id="L426">    <span class="tok-kw">const</span> g: Errors!Foo = Errors.Test;</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> testing.expect(testHash(f) != testHash(g));</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> testing.expect(testHash(f) == testHash(Foo{}));</span>
<span class="line" id="L429">    <span class="tok-kw">try</span> testing.expect(testHash(g) == testHash(Errors.Test));</span>
<span class="line" id="L430">}</span>
<span class="line" id="L431"></span>
</code></pre></body>
</html>