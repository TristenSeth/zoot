<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash_map.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> autoHash = std.hash.autoHash;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> trait = meta.trait;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Wyhash = std.hash.Wyhash;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAutoHashFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K) <span class="tok-type">u64</span>) {</span>
<span class="line" id="L14">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L15">        assert(<span class="tok-builtin">@hasDecl</span>(std, <span class="tok-str">&quot;StringHashMap&quot;</span>)); <span class="tok-comment">// detect when the following message needs updated</span>
</span>
<span class="line" id="L16">        <span class="tok-kw">if</span> (K == []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) {</span>
<span class="line" id="L17">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.auto_hash.autoHash does not allow slices here (&quot;</span> ++</span>
<span class="line" id="L18">                <span class="tok-builtin">@typeName</span>(K) ++</span>
<span class="line" id="L19">                <span class="tok-str">&quot;) because the intent is unclear. &quot;</span> ++</span>
<span class="line" id="L20">                <span class="tok-str">&quot;Consider using std.StringHashMap for hashing the contents of []const u8. &quot;</span> ++</span>
<span class="line" id="L21">                <span class="tok-str">&quot;Alternatively, consider using std.auto_hash.hash or providing your own hash function instead.&quot;</span>);</span>
<span class="line" id="L22">        }</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L26">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(ctx: Context, key: K) <span class="tok-type">u64</span> {</span>
<span class="line" id="L27">            _ = ctx;</span>
<span class="line" id="L28">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> trait.hasUniqueRepresentation(K)) {</span>
<span class="line" id="L29">                <span class="tok-kw">return</span> Wyhash.hash(<span class="tok-number">0</span>, std.mem.asBytes(&amp;key));</span>
<span class="line" id="L30">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L31">                <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L32">                autoHash(&amp;hasher, key);</span>
<span class="line" id="L33">                <span class="tok-kw">return</span> hasher.final();</span>
<span class="line" id="L34">            }</span>
<span class="line" id="L35">        }</span>
<span class="line" id="L36">    }.hash;</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAutoEqlFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K, K) <span class="tok-type">bool</span>) {</span>
<span class="line" id="L40">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L41">        <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(ctx: Context, a: K, b: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L42">            _ = ctx;</span>
<span class="line" id="L43">            <span class="tok-kw">return</span> meta.eql(a, b);</span>
<span class="line" id="L44">        }</span>
<span class="line" id="L45">    }.eql;</span>
<span class="line" id="L46">}</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoHashMap</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L49">    <span class="tok-kw">return</span> HashMap(K, V, AutoContext(K), default_max_load_percentage);</span>
<span class="line" id="L50">}</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoHashMapUnmanaged</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L53">    <span class="tok-kw">return</span> HashMapUnmanaged(K, V, AutoContext(K), default_max_load_percentage);</span>
<span class="line" id="L54">}</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoContext</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L57">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L58">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hash = getAutoHashFn(K, <span class="tok-builtin">@This</span>());</span>
<span class="line" id="L59">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> eql = getAutoEqlFn(K, <span class="tok-builtin">@This</span>());</span>
<span class="line" id="L60">    };</span>
<span class="line" id="L61">}</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">/// Builtin hashmap for strings as keys.</span></span>
<span class="line" id="L64"><span class="tok-comment">/// Key memory is managed by the caller.  Keys and values</span></span>
<span class="line" id="L65"><span class="tok-comment">/// will not automatically be freed.</span></span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StringHashMap</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L67">    <span class="tok-kw">return</span> HashMap([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, V, StringContext, default_max_load_percentage);</span>
<span class="line" id="L68">}</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-comment">/// Key memory is managed by the caller.  Keys and values</span></span>
<span class="line" id="L71"><span class="tok-comment">/// will not automatically be freed.</span></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StringHashMapUnmanaged</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L73">    <span class="tok-kw">return</span> HashMapUnmanaged([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, V, StringContext, default_max_load_percentage);</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L77">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L78">        _ = self;</span>
<span class="line" id="L79">        <span class="tok-kw">return</span> hashString(s);</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L82">        _ = self;</span>
<span class="line" id="L83">        <span class="tok-kw">return</span> eqlString(a, b);</span>
<span class="line" id="L84">    }</span>
<span class="line" id="L85">};</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqlString</span>(a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L88">    <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, a, b);</span>
<span class="line" id="L89">}</span>
<span class="line" id="L90"></span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashString</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L92">    <span class="tok-kw">return</span> std.hash.Wyhash.hash(<span class="tok-number">0</span>, s);</span>
<span class="line" id="L93">}</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringIndexContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L96">    bytes: *std.ArrayListUnmanaged(<span class="tok-type">u8</span>),</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), a: <span class="tok-type">u32</span>, b: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L99">        _ = self;</span>
<span class="line" id="L100">        <span class="tok-kw">return</span> a == b;</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), x: <span class="tok-type">u32</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L104">        <span class="tok-kw">const</span> x_slice = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self.bytes.items.ptr) + x, <span class="tok-number">0</span>);</span>
<span class="line" id="L105">        <span class="tok-kw">return</span> hashString(x_slice);</span>
<span class="line" id="L106">    }</span>
<span class="line" id="L107">};</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringIndexAdapter = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L110">    bytes: *std.ArrayListUnmanaged(<span class="tok-type">u8</span>),</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), a_slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: <span class="tok-type">u32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L113">        <span class="tok-kw">const</span> b_slice = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self.bytes.items.ptr) + b, <span class="tok-number">0</span>);</span>
<span class="line" id="L114">        <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, a_slice, b_slice);</span>
<span class="line" id="L115">    }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), adapted_key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L118">        _ = self;</span>
<span class="line" id="L119">        <span class="tok-kw">return</span> hashString(adapted_key);</span>
<span class="line" id="L120">    }</span>
<span class="line" id="L121">};</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DefaultMaxLoadPercentage = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; use `default_max_load_percentage`&quot;</span>);</span>
<span class="line" id="L124"></span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> default_max_load_percentage = <span class="tok-number">80</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127"><span class="tok-comment">/// This function issues a compile error with a helpful message if there</span></span>
<span class="line" id="L128"><span class="tok-comment">/// is a problem with the provided context type.  A context must have the following</span></span>
<span class="line" id="L129"><span class="tok-comment">/// member functions:</span></span>
<span class="line" id="L130"><span class="tok-comment">///   - hash(self, PseudoKey) Hash</span></span>
<span class="line" id="L131"><span class="tok-comment">///   - eql(self, PseudoKey, Key) bool</span></span>
<span class="line" id="L132"><span class="tok-comment">/// If you are passing a context to a *Adapted function, PseudoKey is the type</span></span>
<span class="line" id="L133"><span class="tok-comment">/// of the key parameter.  Otherwise, when creating a HashMap or HashMapUnmanaged</span></span>
<span class="line" id="L134"><span class="tok-comment">/// type, PseudoKey = Key = K.</span></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verifyContext</span>(</span>
<span class="line" id="L136">    <span class="tok-kw">comptime</span> RawContext: <span class="tok-type">type</span>,</span>
<span class="line" id="L137">    <span class="tok-kw">comptime</span> PseudoKey: <span class="tok-type">type</span>,</span>
<span class="line" id="L138">    <span class="tok-kw">comptime</span> Key: <span class="tok-type">type</span>,</span>
<span class="line" id="L139">    <span class="tok-kw">comptime</span> Hash: <span class="tok-type">type</span>,</span>
<span class="line" id="L140">    <span class="tok-kw">comptime</span> is_array: <span class="tok-type">bool</span>,</span>
<span class="line" id="L141">) <span class="tok-type">void</span> {</span>
<span class="line" id="L142">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L143">        <span class="tok-kw">var</span> allow_const_ptr = <span class="tok-null">false</span>;</span>
<span class="line" id="L144">        <span class="tok-kw">var</span> allow_mutable_ptr = <span class="tok-null">false</span>;</span>
<span class="line" id="L145">        <span class="tok-comment">// Context is the actual namespace type.  RawContext may be a pointer to Context.</span>
</span>
<span class="line" id="L146">        <span class="tok-kw">var</span> Context = RawContext;</span>
<span class="line" id="L147">        <span class="tok-comment">// Make sure the context is a namespace type which may have member functions</span>
</span>
<span class="line" id="L148">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Context)) {</span>
<span class="line" id="L149">            .Struct, .Union, .Enum =&gt; {},</span>
<span class="line" id="L150">            <span class="tok-comment">// Special-case .Opaque for a better error message</span>
</span>
<span class="line" id="L151">            .Opaque =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Hash context must be a type with hash and eql member functions.  Cannot use &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; because it is opaque.  Use a pointer instead.&quot;</span>),</span>
<span class="line" id="L152">            .Pointer =&gt; |ptr| {</span>
<span class="line" id="L153">                <span class="tok-kw">if</span> (ptr.size != .One) {</span>
<span class="line" id="L154">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Hash context must be a type with hash and eql member functions.  Cannot use &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; because it is not a single pointer.&quot;</span>);</span>
<span class="line" id="L155">                }</span>
<span class="line" id="L156">                Context = ptr.child;</span>
<span class="line" id="L157">                allow_const_ptr = <span class="tok-null">true</span>;</span>
<span class="line" id="L158">                allow_mutable_ptr = !ptr.is_const;</span>
<span class="line" id="L159">                <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(Context)) {</span>
<span class="line" id="L160">                    .Struct, .Union, .Enum, .Opaque =&gt; {},</span>
<span class="line" id="L161">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Hash context must be a type with hash and eql member functions.  Cannot use &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context)),</span>
<span class="line" id="L162">                }</span>
<span class="line" id="L163">            },</span>
<span class="line" id="L164">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Hash context must be a type with hash and eql member functions.  Cannot use &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context)),</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-comment">// Keep track of multiple errors so we can report them all.</span>
</span>
<span class="line" id="L168">        <span class="tok-kw">var</span> errors: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">        <span class="tok-comment">// Put common errors here, they will only be evaluated</span>
</span>
<span class="line" id="L171">        <span class="tok-comment">// if the error is actually triggered.</span>
</span>
<span class="line" id="L172">        <span class="tok-kw">const</span> lazy = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L173">            <span class="tok-kw">const</span> prefix = <span class="tok-str">&quot;\n  &quot;</span>;</span>
<span class="line" id="L174">            <span class="tok-kw">const</span> deep_prefix = prefix ++ <span class="tok-str">&quot;  &quot;</span>;</span>
<span class="line" id="L175">            <span class="tok-kw">const</span> hash_signature = <span class="tok-str">&quot;fn (self, &quot;</span> ++ <span class="tok-builtin">@typeName</span>(PseudoKey) ++ <span class="tok-str">&quot;) &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Hash);</span>
<span class="line" id="L176">            <span class="tok-kw">const</span> index_param = <span class="tok-kw">if</span> (is_array) <span class="tok-str">&quot;, b_index: usize&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L177">            <span class="tok-kw">const</span> eql_signature = <span class="tok-str">&quot;fn (self, &quot;</span> ++ <span class="tok-builtin">@typeName</span>(PseudoKey) ++ <span class="tok-str">&quot;, &quot;</span> ++</span>
<span class="line" id="L178">                <span class="tok-builtin">@typeName</span>(Key) ++ index_param ++ <span class="tok-str">&quot;) bool&quot;</span>;</span>
<span class="line" id="L179">            <span class="tok-kw">const</span> err_invalid_hash_signature = prefix ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;.hash must be &quot;</span> ++ hash_signature ++</span>
<span class="line" id="L180">                deep_prefix ++ <span class="tok-str">&quot;but is actually &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(Context.hash));</span>
<span class="line" id="L181">            <span class="tok-kw">const</span> err_invalid_eql_signature = prefix ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;.eql must be &quot;</span> ++ eql_signature ++</span>
<span class="line" id="L182">                deep_prefix ++ <span class="tok-str">&quot;but is actually &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(Context.eql));</span>
<span class="line" id="L183">        };</span>
<span class="line" id="L184"></span>
<span class="line" id="L185">        <span class="tok-comment">// Verify Context.hash(self, PseudoKey) =&gt; Hash</span>
</span>
<span class="line" id="L186">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(Context, <span class="tok-str">&quot;hash&quot;</span>)) {</span>
<span class="line" id="L187">            <span class="tok-kw">const</span> hash = Context.hash;</span>
<span class="line" id="L188">            <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(hash));</span>
<span class="line" id="L189">            <span class="tok-kw">if</span> (info == .Fn) {</span>
<span class="line" id="L190">                <span class="tok-kw">const</span> func = info.Fn;</span>
<span class="line" id="L191">                <span class="tok-kw">if</span> (func.args.len != <span class="tok-number">2</span>) {</span>
<span class="line" id="L192">                    errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L193">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L194">                    <span class="tok-kw">var</span> emitted_signature = <span class="tok-null">false</span>;</span>
<span class="line" id="L195">                    <span class="tok-kw">if</span> (func.args[<span class="tok-number">0</span>].arg_type) |Self| {</span>
<span class="line" id="L196">                        <span class="tok-kw">if</span> (Self == Context) {</span>
<span class="line" id="L197">                            <span class="tok-comment">// pass, this is always fine.</span>
</span>
<span class="line" id="L198">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (Self == *<span class="tok-kw">const</span> Context) {</span>
<span class="line" id="L199">                            <span class="tok-kw">if</span> (!allow_const_ptr) {</span>
<span class="line" id="L200">                                <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L201">                                    errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L202">                                    emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L203">                                }</span>
<span class="line" id="L204">                                errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L205">                                errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be a pointer because it is passed by value.&quot;</span>;</span>
<span class="line" id="L206">                            }</span>
<span class="line" id="L207">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (Self == *Context) {</span>
<span class="line" id="L208">                            <span class="tok-kw">if</span> (!allow_mutable_ptr) {</span>
<span class="line" id="L209">                                <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L210">                                    errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L211">                                    emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L212">                                }</span>
<span class="line" id="L213">                                <span class="tok-kw">if</span> (!allow_const_ptr) {</span>
<span class="line" id="L214">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L215">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be a pointer because it is passed by value.&quot;</span>;</span>
<span class="line" id="L216">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L217">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*<span class="tok-kw">const</span> Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L218">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be non-const because it is passed by const pointer.&quot;</span>;</span>
<span class="line" id="L219">                                }</span>
<span class="line" id="L220">                            }</span>
<span class="line" id="L221">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L222">                            <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L223">                                errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L224">                                emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L225">                            }</span>
<span class="line" id="L226">                            errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context);</span>
<span class="line" id="L227">                            <span class="tok-kw">if</span> (allow_const_ptr) {</span>
<span class="line" id="L228">                                errors = errors ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*<span class="tok-kw">const</span> Context);</span>
<span class="line" id="L229">                                <span class="tok-kw">if</span> (allow_mutable_ptr) {</span>
<span class="line" id="L230">                                    errors = errors ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*Context);</span>
<span class="line" id="L231">                                }</span>
<span class="line" id="L232">                            }</span>
<span class="line" id="L233">                            errors = errors ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L234">                        }</span>
<span class="line" id="L235">                    }</span>
<span class="line" id="L236">                    <span class="tok-kw">if</span> (func.args[<span class="tok-number">1</span>].arg_type != <span class="tok-null">null</span> <span class="tok-kw">and</span> func.args[<span class="tok-number">1</span>].arg_type.? != PseudoKey) {</span>
<span class="line" id="L237">                        <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L238">                            errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L239">                            emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L240">                        }</span>
<span class="line" id="L241">                        errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Second parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(PseudoKey) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(func.args[<span class="tok-number">1</span>].arg_type.?);</span>
<span class="line" id="L242">                    }</span>
<span class="line" id="L243">                    <span class="tok-kw">if</span> (func.return_type != <span class="tok-null">null</span> <span class="tok-kw">and</span> func.return_type.? != Hash) {</span>
<span class="line" id="L244">                        <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L245">                            errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L246">                            emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L247">                        }</span>
<span class="line" id="L248">                        errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Return type must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Hash) ++ <span class="tok-str">&quot;, but was &quot;</span> ++ <span class="tok-builtin">@typeName</span>(func.return_type.?);</span>
<span class="line" id="L249">                    }</span>
<span class="line" id="L250">                    <span class="tok-comment">// If any of these are generic (null), we cannot verify them.</span>
</span>
<span class="line" id="L251">                    <span class="tok-comment">// The call sites check the return type, but cannot check the</span>
</span>
<span class="line" id="L252">                    <span class="tok-comment">// parameters.  This may cause compile errors with generic hash/eql functions.</span>
</span>
<span class="line" id="L253">                }</span>
<span class="line" id="L254">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L255">                errors = errors ++ lazy.err_invalid_hash_signature;</span>
<span class="line" id="L256">            }</span>
<span class="line" id="L257">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L258">            errors = errors ++ lazy.prefix ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; must declare a hash function with signature &quot;</span> ++ lazy.hash_signature;</span>
<span class="line" id="L259">        }</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">        <span class="tok-comment">// Verify Context.eql(self, PseudoKey, Key) =&gt; bool</span>
</span>
<span class="line" id="L262">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(Context, <span class="tok-str">&quot;eql&quot;</span>)) {</span>
<span class="line" id="L263">            <span class="tok-kw">const</span> eql = Context.eql;</span>
<span class="line" id="L264">            <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(eql));</span>
<span class="line" id="L265">            <span class="tok-kw">if</span> (info == .Fn) {</span>
<span class="line" id="L266">                <span class="tok-kw">const</span> func = info.Fn;</span>
<span class="line" id="L267">                <span class="tok-kw">const</span> args_len = <span class="tok-kw">if</span> (is_array) <span class="tok-number">4</span> <span class="tok-kw">else</span> <span class="tok-number">3</span>;</span>
<span class="line" id="L268">                <span class="tok-kw">if</span> (func.args.len != args_len) {</span>
<span class="line" id="L269">                    errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L270">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L271">                    <span class="tok-kw">var</span> emitted_signature = <span class="tok-null">false</span>;</span>
<span class="line" id="L272">                    <span class="tok-kw">if</span> (func.args[<span class="tok-number">0</span>].arg_type) |Self| {</span>
<span class="line" id="L273">                        <span class="tok-kw">if</span> (Self == Context) {</span>
<span class="line" id="L274">                            <span class="tok-comment">// pass, this is always fine.</span>
</span>
<span class="line" id="L275">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (Self == *<span class="tok-kw">const</span> Context) {</span>
<span class="line" id="L276">                            <span class="tok-kw">if</span> (!allow_const_ptr) {</span>
<span class="line" id="L277">                                <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L278">                                    errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L279">                                    emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L280">                                }</span>
<span class="line" id="L281">                                errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L282">                                errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be a pointer because it is passed by value.&quot;</span>;</span>
<span class="line" id="L283">                            }</span>
<span class="line" id="L284">                        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (Self == *Context) {</span>
<span class="line" id="L285">                            <span class="tok-kw">if</span> (!allow_mutable_ptr) {</span>
<span class="line" id="L286">                                <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L287">                                    errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L288">                                    emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L289">                                }</span>
<span class="line" id="L290">                                <span class="tok-kw">if</span> (!allow_const_ptr) {</span>
<span class="line" id="L291">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L292">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be a pointer because it is passed by value.&quot;</span>;</span>
<span class="line" id="L293">                                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L294">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*<span class="tok-kw">const</span> Context) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L295">                                    errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Note: Cannot be non-const because it is passed by const pointer.&quot;</span>;</span>
<span class="line" id="L296">                                }</span>
<span class="line" id="L297">                            }</span>
<span class="line" id="L298">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L299">                            <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L300">                                errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L301">                                emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L302">                            }</span>
<span class="line" id="L303">                            errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;First parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context);</span>
<span class="line" id="L304">                            <span class="tok-kw">if</span> (allow_const_ptr) {</span>
<span class="line" id="L305">                                errors = errors ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*<span class="tok-kw">const</span> Context);</span>
<span class="line" id="L306">                                <span class="tok-kw">if</span> (allow_mutable_ptr) {</span>
<span class="line" id="L307">                                    errors = errors ++ <span class="tok-str">&quot; or &quot;</span> ++ <span class="tok-builtin">@typeName</span>(*Context);</span>
<span class="line" id="L308">                                }</span>
<span class="line" id="L309">                            }</span>
<span class="line" id="L310">                            errors = errors ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Self);</span>
<span class="line" id="L311">                        }</span>
<span class="line" id="L312">                    }</span>
<span class="line" id="L313">                    <span class="tok-kw">if</span> (func.args[<span class="tok-number">1</span>].arg_type.? != PseudoKey) {</span>
<span class="line" id="L314">                        <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L315">                            errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L316">                            emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L317">                        }</span>
<span class="line" id="L318">                        errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Second parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(PseudoKey) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(func.args[<span class="tok-number">1</span>].arg_type.?);</span>
<span class="line" id="L319">                    }</span>
<span class="line" id="L320">                    <span class="tok-kw">if</span> (func.args[<span class="tok-number">2</span>].arg_type.? != Key) {</span>
<span class="line" id="L321">                        <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L322">                            errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L323">                            emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L324">                        }</span>
<span class="line" id="L325">                        errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Third parameter must be &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Key) ++ <span class="tok-str">&quot;, but is &quot;</span> ++ <span class="tok-builtin">@typeName</span>(func.args[<span class="tok-number">2</span>].arg_type.?);</span>
<span class="line" id="L326">                    }</span>
<span class="line" id="L327">                    <span class="tok-kw">if</span> (func.return_type.? != <span class="tok-type">bool</span>) {</span>
<span class="line" id="L328">                        <span class="tok-kw">if</span> (!emitted_signature) {</span>
<span class="line" id="L329">                            errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L330">                            emitted_signature = <span class="tok-null">true</span>;</span>
<span class="line" id="L331">                        }</span>
<span class="line" id="L332">                        errors = errors ++ lazy.deep_prefix ++ <span class="tok-str">&quot;Return type must be bool, but was &quot;</span> ++ <span class="tok-builtin">@typeName</span>(func.return_type.?);</span>
<span class="line" id="L333">                    }</span>
<span class="line" id="L334">                    <span class="tok-comment">// If any of these are generic (null), we cannot verify them.</span>
</span>
<span class="line" id="L335">                    <span class="tok-comment">// The call sites check the return type, but cannot check the</span>
</span>
<span class="line" id="L336">                    <span class="tok-comment">// parameters.  This may cause compile errors with generic hash/eql functions.</span>
</span>
<span class="line" id="L337">                }</span>
<span class="line" id="L338">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L339">                errors = errors ++ lazy.err_invalid_eql_signature;</span>
<span class="line" id="L340">            }</span>
<span class="line" id="L341">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L342">            errors = errors ++ lazy.prefix ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot; must declare a eql function with signature &quot;</span> ++ lazy.eql_signature;</span>
<span class="line" id="L343">        }</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">        <span class="tok-kw">if</span> (errors.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L346">            <span class="tok-comment">// errors begins with a newline (from lazy.prefix)</span>
</span>
<span class="line" id="L347">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Problems found with hash context type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;:&quot;</span> ++ errors);</span>
<span class="line" id="L348">        }</span>
<span class="line" id="L349">    }</span>
<span class="line" id="L350">}</span>
<span class="line" id="L351"></span>
<span class="line" id="L352"><span class="tok-comment">/// General purpose hash table.</span></span>
<span class="line" id="L353"><span class="tok-comment">/// No order is guaranteed and any modification invalidates live iterators.</span></span>
<span class="line" id="L354"><span class="tok-comment">/// It provides fast operations (lookup, insertion, deletion) with quite high</span></span>
<span class="line" id="L355"><span class="tok-comment">/// load factors (up to 80% by default) for a low memory usage.</span></span>
<span class="line" id="L356"><span class="tok-comment">/// For a hash map that can be initialized directly that does not store an Allocator</span></span>
<span class="line" id="L357"><span class="tok-comment">/// field, see `HashMapUnmanaged`.</span></span>
<span class="line" id="L358"><span class="tok-comment">/// If iterating over the table entries is a strong usecase and needs to be fast,</span></span>
<span class="line" id="L359"><span class="tok-comment">/// prefer the alternative `std.ArrayHashMap`.</span></span>
<span class="line" id="L360"><span class="tok-comment">/// Context must be a struct type with two member functions:</span></span>
<span class="line" id="L361"><span class="tok-comment">///   hash(self, K) u64</span></span>
<span class="line" id="L362"><span class="tok-comment">///   eql(self, K, K) bool</span></span>
<span class="line" id="L363"><span class="tok-comment">/// Adapted variants of many functions are provided.  These variants</span></span>
<span class="line" id="L364"><span class="tok-comment">/// take a pseudo key instead of a key.  Their context must have the functions:</span></span>
<span class="line" id="L365"><span class="tok-comment">///   hash(self, PseudoKey) u64</span></span>
<span class="line" id="L366"><span class="tok-comment">///   eql(self, PseudoKey, K) bool</span></span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HashMap</span>(</span>
<span class="line" id="L368">    <span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>,</span>
<span class="line" id="L369">    <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>,</span>
<span class="line" id="L370">    <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>,</span>
<span class="line" id="L371">    <span class="tok-kw">comptime</span> max_load_percentage: <span class="tok-type">u64</span>,</span>
<span class="line" id="L372">) <span class="tok-type">type</span> {</span>
<span class="line" id="L373">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L374">        unmanaged: Unmanaged,</span>
<span class="line" id="L375">        allocator: Allocator,</span>
<span class="line" id="L376">        ctx: Context,</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L379">            verifyContext(Context, K, K, <span class="tok-type">u64</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L380">        }</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-comment">/// The type of the unmanaged hash map underlying this wrapper</span></span>
<span class="line" id="L383">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Unmanaged = HashMapUnmanaged(K, V, Context, max_load_percentage);</span>
<span class="line" id="L384">        <span class="tok-comment">/// An entry, containing pointers to a key and value stored in the map</span></span>
<span class="line" id="L385">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = Unmanaged.Entry;</span>
<span class="line" id="L386">        <span class="tok-comment">/// A copy of a key and value which are no longer in the map</span></span>
<span class="line" id="L387">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KV = Unmanaged.KV;</span>
<span class="line" id="L388">        <span class="tok-comment">/// The integer type that is the result of hashing</span></span>
<span class="line" id="L389">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Hash = Unmanaged.Hash;</span>
<span class="line" id="L390">        <span class="tok-comment">/// The iterator type returned by iterator()</span></span>
<span class="line" id="L391">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = Unmanaged.Iterator;</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyIterator = Unmanaged.KeyIterator;</span>
<span class="line" id="L394">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ValueIterator = Unmanaged.ValueIterator;</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">        <span class="tok-comment">/// The integer type used to store the size of the map</span></span>
<span class="line" id="L397">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Size = Unmanaged.Size;</span>
<span class="line" id="L398">        <span class="tok-comment">/// The type returned from getOrPut and variants</span></span>
<span class="line" id="L399">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetOrPutResult = Unmanaged.GetOrPutResult;</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">        <span class="tok-comment">/// Create a managed hash map with an empty context.</span></span>
<span class="line" id="L404">        <span class="tok-comment">/// If the context is not zero-sized, you must use</span></span>
<span class="line" id="L405">        <span class="tok-comment">/// initContext(allocator, ctx) instead.</span></span>
<span class="line" id="L406">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) Self {</span>
<span class="line" id="L407">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L408">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context must be specified! Call initContext(allocator, ctx) instead.&quot;</span>);</span>
<span class="line" id="L409">            }</span>
<span class="line" id="L410">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L411">                .unmanaged = .{},</span>
<span class="line" id="L412">                .allocator = allocator,</span>
<span class="line" id="L413">                .ctx = <span class="tok-null">undefined</span>, <span class="tok-comment">// ctx is zero-sized so this is safe.</span>
</span>
<span class="line" id="L414">            };</span>
<span class="line" id="L415">        }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">        <span class="tok-comment">/// Create a managed hash map with a context</span></span>
<span class="line" id="L418">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(allocator: Allocator, ctx: Context) Self {</span>
<span class="line" id="L419">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L420">                .unmanaged = .{},</span>
<span class="line" id="L421">                .allocator = allocator,</span>
<span class="line" id="L422">                .ctx = ctx,</span>
<span class="line" id="L423">            };</span>
<span class="line" id="L424">        }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">        <span class="tok-comment">/// Release the backing array and invalidate this map.</span></span>
<span class="line" id="L427">        <span class="tok-comment">/// This does *not* deinit keys, values, or the context!</span></span>
<span class="line" id="L428">        <span class="tok-comment">/// If your keys or values need to be released, ensure</span></span>
<span class="line" id="L429">        <span class="tok-comment">/// that that is done before calling this function.</span></span>
<span class="line" id="L430">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L431">            self.unmanaged.deinit(self.allocator);</span>
<span class="line" id="L432">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">        <span class="tok-comment">/// Empty the map, but keep the backing allocation for future use.</span></span>
<span class="line" id="L436">        <span class="tok-comment">/// This does *not* free keys or values! Be sure to</span></span>
<span class="line" id="L437">        <span class="tok-comment">/// release them if they need deinitialization before</span></span>
<span class="line" id="L438">        <span class="tok-comment">/// calling this function.</span></span>
<span class="line" id="L439">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L440">            <span class="tok-kw">return</span> self.unmanaged.clearRetainingCapacity();</span>
<span class="line" id="L441">        }</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">        <span class="tok-comment">/// Empty the map and release the backing allocation.</span></span>
<span class="line" id="L444">        <span class="tok-comment">/// This does *not* free keys or values! Be sure to</span></span>
<span class="line" id="L445">        <span class="tok-comment">/// release them if they need deinitialization before</span></span>
<span class="line" id="L446">        <span class="tok-comment">/// calling this function.</span></span>
<span class="line" id="L447">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L448">            <span class="tok-kw">return</span> self.unmanaged.clearAndFree(self.allocator);</span>
<span class="line" id="L449">        }</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">        <span class="tok-comment">/// Return the number of items in the map.</span></span>
<span class="line" id="L452">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) Size {</span>
<span class="line" id="L453">            <span class="tok-kw">return</span> self.unmanaged.count();</span>
<span class="line" id="L454">        }</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">        <span class="tok-comment">/// Create an iterator over the entries in the map.</span></span>
<span class="line" id="L457">        <span class="tok-comment">/// The iterator is invalidated if the map is modified.</span></span>
<span class="line" id="L458">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self) Iterator {</span>
<span class="line" id="L459">            <span class="tok-kw">return</span> self.unmanaged.iterator();</span>
<span class="line" id="L460">        }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-comment">/// Create an iterator over the keys in the map.</span></span>
<span class="line" id="L463">        <span class="tok-comment">/// The iterator is invalidated if the map is modified.</span></span>
<span class="line" id="L464">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyIterator</span>(self: *<span class="tok-kw">const</span> Self) KeyIterator {</span>
<span class="line" id="L465">            <span class="tok-kw">return</span> self.unmanaged.keyIterator();</span>
<span class="line" id="L466">        }</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">        <span class="tok-comment">/// Create an iterator over the values in the map.</span></span>
<span class="line" id="L469">        <span class="tok-comment">/// The iterator is invalidated if the map is modified.</span></span>
<span class="line" id="L470">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">valueIterator</span>(self: *<span class="tok-kw">const</span> Self) ValueIterator {</span>
<span class="line" id="L471">            <span class="tok-kw">return</span> self.unmanaged.valueIterator();</span>
<span class="line" id="L472">        }</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">        <span class="tok-comment">/// If key exists this function cannot fail.</span></span>
<span class="line" id="L475">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L476">        <span class="tok-comment">/// `Entry` pointers point to it, and found_existing is true.</span></span>
<span class="line" id="L477">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L478">        <span class="tok-comment">/// the `Entry` pointers point to it. Caller should then initialize</span></span>
<span class="line" id="L479">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L480">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPut</span>(self: *Self, key: K) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L481">            <span class="tok-kw">return</span> self.unmanaged.getOrPutContext(self.allocator, key, self.ctx);</span>
<span class="line" id="L482">        }</span>
<span class="line" id="L483"></span>
<span class="line" id="L484">        <span class="tok-comment">/// If key exists this function cannot fail.</span></span>
<span class="line" id="L485">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L486">        <span class="tok-comment">/// `Entry` pointers point to it, and found_existing is true.</span></span>
<span class="line" id="L487">        <span class="tok-comment">/// Otherwise, puts a new item with undefined key and value, and</span></span>
<span class="line" id="L488">        <span class="tok-comment">/// the `Entry` pointers point to it. Caller must then initialize</span></span>
<span class="line" id="L489">        <span class="tok-comment">/// the key and value.</span></span>
<span class="line" id="L490">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L491">            <span class="tok-kw">return</span> self.unmanaged.getOrPutContextAdapted(self.allocator, key, ctx, self.ctx);</span>
<span class="line" id="L492">        }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L495">        <span class="tok-comment">/// `Entry` pointers point to it, and found_existing is true.</span></span>
<span class="line" id="L496">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L497">        <span class="tok-comment">/// the `Entry` pointers point to it. Caller should then initialize</span></span>
<span class="line" id="L498">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L499">        <span class="tok-comment">/// If a new entry needs to be stored, this function asserts there</span></span>
<span class="line" id="L500">        <span class="tok-comment">/// is enough capacity to store it.</span></span>
<span class="line" id="L501">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacity</span>(self: *Self, key: K) GetOrPutResult {</span>
<span class="line" id="L502">            <span class="tok-kw">return</span> self.unmanaged.getOrPutAssumeCapacityContext(key, self.ctx);</span>
<span class="line" id="L503">        }</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L506">        <span class="tok-comment">/// `Entry` pointers point to it, and found_existing is true.</span></span>
<span class="line" id="L507">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L508">        <span class="tok-comment">/// the `Entry` pointers point to it. Caller must then initialize</span></span>
<span class="line" id="L509">        <span class="tok-comment">/// the key and value.</span></span>
<span class="line" id="L510">        <span class="tok-comment">/// If a new entry needs to be stored, this function asserts there</span></span>
<span class="line" id="L511">        <span class="tok-comment">/// is enough capacity to store it.</span></span>
<span class="line" id="L512">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) GetOrPutResult {</span>
<span class="line" id="L513">            <span class="tok-kw">return</span> self.unmanaged.getOrPutAssumeCapacityAdapted(self.allocator, key, ctx);</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValue</span>(self: *Self, key: K, value: V) Allocator.Error!Entry {</span>
<span class="line" id="L517">            <span class="tok-kw">return</span> self.unmanaged.getOrPutValueContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L518">        }</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until the</span></span>
<span class="line" id="L523">        <span class="tok-comment">/// `expected_count` will not cause an allocation, and therefore cannot fail.</span></span>
<span class="line" id="L524">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, expected_count: Size) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L525">            <span class="tok-kw">return</span> self.unmanaged.ensureTotalCapacityContext(self.allocator, expected_count, self.ctx);</span>
<span class="line" id="L526">        }</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until</span></span>
<span class="line" id="L529">        <span class="tok-comment">/// `additional_count` **more** items will not cause an allocation, and</span></span>
<span class="line" id="L530">        <span class="tok-comment">/// therefore cannot fail.</span></span>
<span class="line" id="L531">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, additional_count: Size) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L532">            <span class="tok-kw">return</span> self.unmanaged.ensureUnusedCapacityContext(self.allocator, additional_count, self.ctx);</span>
<span class="line" id="L533">        }</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">        <span class="tok-comment">/// Returns the number of total elements which may be present before it is</span></span>
<span class="line" id="L536">        <span class="tok-comment">/// no longer guaranteed that no allocations will be performed.</span></span>
<span class="line" id="L537">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: *Self) Size {</span>
<span class="line" id="L538">            <span class="tok-kw">return</span> self.unmanaged.capacity();</span>
<span class="line" id="L539">        }</span>
<span class="line" id="L540"></span>
<span class="line" id="L541">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L542">        <span class="tok-comment">/// existing data, see `getOrPut`.</span></span>
<span class="line" id="L543">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, key: K, value: V) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L544">            <span class="tok-kw">return</span> self.unmanaged.putContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L545">        }</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">        <span class="tok-comment">/// Inserts a key-value pair into the hash map, asserting that no previous</span></span>
<span class="line" id="L548">        <span class="tok-comment">/// entry with the same key is already present</span></span>
<span class="line" id="L549">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobber</span>(self: *Self, key: K, value: V) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L550">            <span class="tok-kw">return</span> self.unmanaged.putNoClobberContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L551">        }</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L554">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L555">        <span class="tok-comment">/// existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L556">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacity</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L557">            <span class="tok-kw">return</span> self.unmanaged.putAssumeCapacityContext(key, value, self.ctx);</span>
<span class="line" id="L558">        }</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L561">        <span class="tok-comment">/// Asserts that it does not clobber any existing data.</span></span>
<span class="line" id="L562">        <span class="tok-comment">/// To detect if a put would clobber existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L563">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobber</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L564">            <span class="tok-kw">return</span> self.unmanaged.putAssumeCapacityNoClobberContext(key, value, self.ctx);</span>
<span class="line" id="L565">        }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L568">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPut</span>(self: *Self, key: K, value: V) Allocator.Error!?KV {</span>
<span class="line" id="L569">            <span class="tok-kw">return</span> self.unmanaged.fetchPutContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L570">        }</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L573">        <span class="tok-comment">/// If insertion happuns, asserts there is enough capacity without allocating.</span></span>
<span class="line" id="L574">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacity</span>(self: *Self, key: K, value: V) ?KV {</span>
<span class="line" id="L575">            <span class="tok-kw">return</span> self.unmanaged.fetchPutAssumeCapacityContext(key, value, self.ctx);</span>
<span class="line" id="L576">        }</span>
<span class="line" id="L577"></span>
<span class="line" id="L578">        <span class="tok-comment">/// Removes a value from the map and returns the removed kv pair.</span></span>
<span class="line" id="L579">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L580">            <span class="tok-kw">return</span> self.unmanaged.fetchRemoveContext(key, self.ctx);</span>
<span class="line" id="L581">        }</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L584">            <span class="tok-kw">return</span> self.unmanaged.fetchRemoveAdapted(key, ctx);</span>
<span class="line" id="L585">        }</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">        <span class="tok-comment">/// Finds the value associated with a key in the map</span></span>
<span class="line" id="L588">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: K) ?V {</span>
<span class="line" id="L589">            <span class="tok-kw">return</span> self.unmanaged.getContext(key, self.ctx);</span>
<span class="line" id="L590">        }</span>
<span class="line" id="L591">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?V {</span>
<span class="line" id="L592">            <span class="tok-kw">return</span> self.unmanaged.getAdapted(key, ctx);</span>
<span class="line" id="L593">        }</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: Self, key: K) ?*V {</span>
<span class="line" id="L596">            <span class="tok-kw">return</span> self.unmanaged.getPtrContext(key, self.ctx);</span>
<span class="line" id="L597">        }</span>
<span class="line" id="L598">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*V {</span>
<span class="line" id="L599">            <span class="tok-kw">return</span> self.unmanaged.getPtrAdapted(key, ctx);</span>
<span class="line" id="L600">        }</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">        <span class="tok-comment">/// Finds the actual key associated with an adapted key in the map</span></span>
<span class="line" id="L603">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKey</span>(self: Self, key: K) ?K {</span>
<span class="line" id="L604">            <span class="tok-kw">return</span> self.unmanaged.getKeyContext(key, self.ctx);</span>
<span class="line" id="L605">        }</span>
<span class="line" id="L606">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?K {</span>
<span class="line" id="L607">            <span class="tok-kw">return</span> self.unmanaged.getKeyAdapted(key, ctx);</span>
<span class="line" id="L608">        }</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtr</span>(self: Self, key: K) ?*K {</span>
<span class="line" id="L611">            <span class="tok-kw">return</span> self.unmanaged.getKeyPtrContext(key, self.ctx);</span>
<span class="line" id="L612">        }</span>
<span class="line" id="L613">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*K {</span>
<span class="line" id="L614">            <span class="tok-kw">return</span> self.unmanaged.getKeyPtrAdapted(key, ctx);</span>
<span class="line" id="L615">        }</span>
<span class="line" id="L616"></span>
<span class="line" id="L617">        <span class="tok-comment">/// Finds the key and value associated with a key in the map</span></span>
<span class="line" id="L618">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntry</span>(self: Self, key: K) ?Entry {</span>
<span class="line" id="L619">            <span class="tok-kw">return</span> self.unmanaged.getEntryContext(key, self.ctx);</span>
<span class="line" id="L620">        }</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?Entry {</span>
<span class="line" id="L623">            <span class="tok-kw">return</span> self.unmanaged.getEntryAdapted(key, ctx);</span>
<span class="line" id="L624">        }</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">        <span class="tok-comment">/// Check if the map contains a key</span></span>
<span class="line" id="L627">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L628">            <span class="tok-kw">return</span> self.unmanaged.containsContext(key, self.ctx);</span>
<span class="line" id="L629">        }</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L632">            <span class="tok-kw">return</span> self.unmanaged.containsAdapted(key, ctx);</span>
<span class="line" id="L633">        }</span>
<span class="line" id="L634"></span>
<span class="line" id="L635">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L636">        <span class="tok-comment">/// the hash map, and this function returns true.  Otherwise this</span></span>
<span class="line" id="L637">        <span class="tok-comment">/// function returns false.</span></span>
<span class="line" id="L638">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L639">            <span class="tok-kw">return</span> self.unmanaged.removeContext(key, self.ctx);</span>
<span class="line" id="L640">        }</span>
<span class="line" id="L641"></span>
<span class="line" id="L642">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L643">            <span class="tok-kw">return</span> self.unmanaged.removeAdapted(key, ctx);</span>
<span class="line" id="L644">        }</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">        <span class="tok-comment">/// Delete the entry with key pointed to by keyPtr from the hash map.</span></span>
<span class="line" id="L647">        <span class="tok-comment">/// keyPtr is assumed to be a valid pointer to a key that is present</span></span>
<span class="line" id="L648">        <span class="tok-comment">/// in the hash map.</span></span>
<span class="line" id="L649">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeByPtr</span>(self: *Self, keyPtr: *K) <span class="tok-type">void</span> {</span>
<span class="line" id="L650">            self.unmanaged.removeByPtr(keyPtr);</span>
<span class="line" id="L651">        }</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">        <span class="tok-comment">/// Creates a copy of this map, using the same allocator</span></span>
<span class="line" id="L654">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: Self) Allocator.Error!Self {</span>
<span class="line" id="L655">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(self.allocator, self.ctx);</span>
<span class="line" id="L656">            <span class="tok-kw">return</span> other.promoteContext(self.allocator, self.ctx);</span>
<span class="line" id="L657">        }</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">        <span class="tok-comment">/// Creates a copy of this map, using a specified allocator</span></span>
<span class="line" id="L660">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithAllocator</span>(self: Self, new_allocator: Allocator) Allocator.Error!Self {</span>
<span class="line" id="L661">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(new_allocator, self.ctx);</span>
<span class="line" id="L662">            <span class="tok-kw">return</span> other.promoteContext(new_allocator, self.ctx);</span>
<span class="line" id="L663">        }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">        <span class="tok-comment">/// Creates a copy of this map, using a specified context</span></span>
<span class="line" id="L666">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithContext</span>(self: Self, new_ctx: <span class="tok-kw">anytype</span>) Allocator.Error!HashMap(K, V, <span class="tok-builtin">@TypeOf</span>(new_ctx), max_load_percentage) {</span>
<span class="line" id="L667">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(self.allocator, new_ctx);</span>
<span class="line" id="L668">            <span class="tok-kw">return</span> other.promoteContext(self.allocator, new_ctx);</span>
<span class="line" id="L669">        }</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">        <span class="tok-comment">/// Creates a copy of this map, using a specified allocator and context.</span></span>
<span class="line" id="L672">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithAllocatorAndContext</span>(</span>
<span class="line" id="L673">            self: Self,</span>
<span class="line" id="L674">            new_allocator: Allocator,</span>
<span class="line" id="L675">            new_ctx: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L676">        ) Allocator.Error!HashMap(K, V, <span class="tok-builtin">@TypeOf</span>(new_ctx), max_load_percentage) {</span>
<span class="line" id="L677">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(new_allocator, new_ctx);</span>
<span class="line" id="L678">            <span class="tok-kw">return</span> other.promoteContext(new_allocator, new_ctx);</span>
<span class="line" id="L679">        }</span>
<span class="line" id="L680">    };</span>
<span class="line" id="L681">}</span>
<span class="line" id="L682"></span>
<span class="line" id="L683"><span class="tok-comment">/// A HashMap based on open addressing and linear probing.</span></span>
<span class="line" id="L684"><span class="tok-comment">/// A lookup or modification typically occurs only 2 cache misses.</span></span>
<span class="line" id="L685"><span class="tok-comment">/// No order is guaranteed and any modification invalidates live iterators.</span></span>
<span class="line" id="L686"><span class="tok-comment">/// It achieves good performance with quite high load factors (by default,</span></span>
<span class="line" id="L687"><span class="tok-comment">/// grow is triggered at 80% full) and only one byte of overhead per element.</span></span>
<span class="line" id="L688"><span class="tok-comment">/// The struct itself is only 16 bytes for a small footprint. This comes at</span></span>
<span class="line" id="L689"><span class="tok-comment">/// the price of handling size with u32, which should be reasonnable enough</span></span>
<span class="line" id="L690"><span class="tok-comment">/// for almost all uses.</span></span>
<span class="line" id="L691"><span class="tok-comment">/// Deletions are achieved with tombstones.</span></span>
<span class="line" id="L692"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">HashMapUnmanaged</span>(</span>
<span class="line" id="L693">    <span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>,</span>
<span class="line" id="L694">    <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>,</span>
<span class="line" id="L695">    <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>,</span>
<span class="line" id="L696">    <span class="tok-kw">comptime</span> max_load_percentage: <span class="tok-type">u64</span>,</span>
<span class="line" id="L697">) <span class="tok-type">type</span> {</span>
<span class="line" id="L698">    <span class="tok-kw">if</span> (max_load_percentage &lt;= <span class="tok-number">0</span> <span class="tok-kw">or</span> max_load_percentage &gt;= <span class="tok-number">100</span>)</span>
<span class="line" id="L699">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;max_load_percentage must be between 0 and 100.&quot;</span>);</span>
<span class="line" id="L700">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L701">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L704">            verifyContext(Context, K, K, <span class="tok-type">u64</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L705">        }</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">        <span class="tok-comment">// This is actually a midway pointer to the single buffer containing</span>
</span>
<span class="line" id="L708">        <span class="tok-comment">// a `Header` field, the `Metadata`s and `Entry`s.</span>
</span>
<span class="line" id="L709">        <span class="tok-comment">// At `-@sizeOf(Header)` is the Header field.</span>
</span>
<span class="line" id="L710">        <span class="tok-comment">// At `sizeOf(Metadata) * capacity + offset`, which is pointed to by</span>
</span>
<span class="line" id="L711">        <span class="tok-comment">// self.header().entries, is the array of entries.</span>
</span>
<span class="line" id="L712">        <span class="tok-comment">// This means that the hashmap only holds one live allocation, to</span>
</span>
<span class="line" id="L713">        <span class="tok-comment">// reduce memory fragmentation and struct size.</span>
</span>
<span class="line" id="L714">        <span class="tok-comment">/// Pointer to the metadata.</span></span>
<span class="line" id="L715">        metadata: ?[*]Metadata = <span class="tok-null">null</span>,</span>
<span class="line" id="L716"></span>
<span class="line" id="L717">        <span class="tok-comment">/// Current number of elements in the hashmap.</span></span>
<span class="line" id="L718">        size: Size = <span class="tok-number">0</span>,</span>
<span class="line" id="L719"></span>
<span class="line" id="L720">        <span class="tok-comment">// Having a countdown to grow reduces the number of instructions to</span>
</span>
<span class="line" id="L721">        <span class="tok-comment">// execute when determining if the hashmap has enough capacity already.</span>
</span>
<span class="line" id="L722">        <span class="tok-comment">/// Number of available slots before a grow is needed to satisfy the</span></span>
<span class="line" id="L723">        <span class="tok-comment">/// `max_load_percentage`.</span></span>
<span class="line" id="L724">        available: Size = <span class="tok-number">0</span>,</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">        <span class="tok-comment">// This is purely empirical and not a /very smart magic constant™/.</span>
</span>
<span class="line" id="L727">        <span class="tok-comment">/// Capacity of the first grow when bootstrapping the hashmap.</span></span>
<span class="line" id="L728">        <span class="tok-kw">const</span> minimal_capacity = <span class="tok-number">8</span>;</span>
<span class="line" id="L729"></span>
<span class="line" id="L730">        <span class="tok-comment">// This hashmap is specially designed for sizes that fit in a u32.</span>
</span>
<span class="line" id="L731">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Size = <span class="tok-type">u32</span>;</span>
<span class="line" id="L732"></span>
<span class="line" id="L733">        <span class="tok-comment">// u64 hashes guarantee us that the fingerprint bits will never be used</span>
</span>
<span class="line" id="L734">        <span class="tok-comment">// to compute the index of a slot, maximizing the use of entropy.</span>
</span>
<span class="line" id="L735">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Hash = <span class="tok-type">u64</span>;</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L738">            key_ptr: *K,</span>
<span class="line" id="L739">            value_ptr: *V,</span>
<span class="line" id="L740">        };</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L743">            key: K,</span>
<span class="line" id="L744">            value: V,</span>
<span class="line" id="L745">        };</span>
<span class="line" id="L746"></span>
<span class="line" id="L747">        <span class="tok-kw">const</span> Header = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L748">            values: [*]V,</span>
<span class="line" id="L749">            keys: [*]K,</span>
<span class="line" id="L750">            capacity: Size,</span>
<span class="line" id="L751">        };</span>
<span class="line" id="L752"></span>
<span class="line" id="L753">        <span class="tok-comment">/// Metadata for a slot. It can be in three states: empty, used or</span></span>
<span class="line" id="L754">        <span class="tok-comment">/// tombstone. Tombstones indicate that an entry was previously used,</span></span>
<span class="line" id="L755">        <span class="tok-comment">/// they are a simple way to handle removal.</span></span>
<span class="line" id="L756">        <span class="tok-comment">/// To this state, we add 7 bits from the slot's key hash. These are</span></span>
<span class="line" id="L757">        <span class="tok-comment">/// used as a fast way to disambiguate between entries without</span></span>
<span class="line" id="L758">        <span class="tok-comment">/// having to use the equality function. If two fingerprints are</span></span>
<span class="line" id="L759">        <span class="tok-comment">/// different, we know that we don't have to compare the keys at all.</span></span>
<span class="line" id="L760">        <span class="tok-comment">/// The 7 bits are the highest ones from a 64 bit hash. This way, not</span></span>
<span class="line" id="L761">        <span class="tok-comment">/// only we use the `log2(capacity)` lowest bits from the hash to determine</span></span>
<span class="line" id="L762">        <span class="tok-comment">/// a slot index, but we use 7 more bits to quickly resolve collisions</span></span>
<span class="line" id="L763">        <span class="tok-comment">/// when multiple elements with different hashes end up wanting to be in the same slot.</span></span>
<span class="line" id="L764">        <span class="tok-comment">/// Not using the equality function means we don't have to read into</span></span>
<span class="line" id="L765">        <span class="tok-comment">/// the entries array, likely avoiding a cache miss and a potentially</span></span>
<span class="line" id="L766">        <span class="tok-comment">/// costly function call.</span></span>
<span class="line" id="L767">        <span class="tok-kw">const</span> Metadata = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L768">            <span class="tok-kw">const</span> FingerPrint = <span class="tok-type">u7</span>;</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">            <span class="tok-kw">const</span> free: FingerPrint = <span class="tok-number">0</span>;</span>
<span class="line" id="L771">            <span class="tok-kw">const</span> tombstone: FingerPrint = <span class="tok-number">1</span>;</span>
<span class="line" id="L772"></span>
<span class="line" id="L773">            fingerprint: FingerPrint = free,</span>
<span class="line" id="L774">            used: <span class="tok-type">u1</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">            <span class="tok-kw">const</span> slot_free = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, Metadata{ .fingerprint = free });</span>
<span class="line" id="L777">            <span class="tok-kw">const</span> slot_tombstone = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, Metadata{ .fingerprint = tombstone });</span>
<span class="line" id="L778"></span>
<span class="line" id="L779">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUsed</span>(self: Metadata) <span class="tok-type">bool</span> {</span>
<span class="line" id="L780">                <span class="tok-kw">return</span> self.used == <span class="tok-number">1</span>;</span>
<span class="line" id="L781">            }</span>
<span class="line" id="L782"></span>
<span class="line" id="L783">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isTombstone</span>(self: Metadata) <span class="tok-type">bool</span> {</span>
<span class="line" id="L784">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, self) == slot_tombstone;</span>
<span class="line" id="L785">            }</span>
<span class="line" id="L786"></span>
<span class="line" id="L787">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isFree</span>(self: Metadata) <span class="tok-type">bool</span> {</span>
<span class="line" id="L788">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u8</span>, self) == slot_free;</span>
<span class="line" id="L789">            }</span>
<span class="line" id="L790"></span>
<span class="line" id="L791">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">takeFingerprint</span>(hash: Hash) FingerPrint {</span>
<span class="line" id="L792">                <span class="tok-kw">const</span> hash_bits = <span class="tok-builtin">@typeInfo</span>(Hash).Int.bits;</span>
<span class="line" id="L793">                <span class="tok-kw">const</span> fp_bits = <span class="tok-builtin">@typeInfo</span>(FingerPrint).Int.bits;</span>
<span class="line" id="L794">                <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(FingerPrint, hash &gt;&gt; (hash_bits - fp_bits));</span>
<span class="line" id="L795">            }</span>
<span class="line" id="L796"></span>
<span class="line" id="L797">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(self: *Metadata, fp: FingerPrint) <span class="tok-type">void</span> {</span>
<span class="line" id="L798">                self.used = <span class="tok-number">1</span>;</span>
<span class="line" id="L799">                self.fingerprint = fp;</span>
<span class="line" id="L800">            }</span>
<span class="line" id="L801"></span>
<span class="line" id="L802">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Metadata) <span class="tok-type">void</span> {</span>
<span class="line" id="L803">                self.used = <span class="tok-number">0</span>;</span>
<span class="line" id="L804">                self.fingerprint = tombstone;</span>
<span class="line" id="L805">            }</span>
<span class="line" id="L806">        };</span>
<span class="line" id="L807"></span>
<span class="line" id="L808">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L809">            assert(<span class="tok-builtin">@sizeOf</span>(Metadata) == <span class="tok-number">1</span>);</span>
<span class="line" id="L810">            assert(<span class="tok-builtin">@alignOf</span>(Metadata) == <span class="tok-number">1</span>);</span>
<span class="line" id="L811">        }</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L814">            hm: *<span class="tok-kw">const</span> Self,</span>
<span class="line" id="L815">            index: Size = <span class="tok-number">0</span>,</span>
<span class="line" id="L816"></span>
<span class="line" id="L817">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *Iterator) ?Entry {</span>
<span class="line" id="L818">                assert(it.index &lt;= it.hm.capacity());</span>
<span class="line" id="L819">                <span class="tok-kw">if</span> (it.hm.size == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L820"></span>
<span class="line" id="L821">                <span class="tok-kw">const</span> cap = it.hm.capacity();</span>
<span class="line" id="L822">                <span class="tok-kw">const</span> end = it.hm.metadata.? + cap;</span>
<span class="line" id="L823">                <span class="tok-kw">var</span> metadata = it.hm.metadata.? + it.index;</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">                <span class="tok-kw">while</span> (metadata != end) : ({</span>
<span class="line" id="L826">                    metadata += <span class="tok-number">1</span>;</span>
<span class="line" id="L827">                    it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L828">                }) {</span>
<span class="line" id="L829">                    <span class="tok-kw">if</span> (metadata[<span class="tok-number">0</span>].isUsed()) {</span>
<span class="line" id="L830">                        <span class="tok-kw">const</span> key = &amp;it.hm.keys()[it.index];</span>
<span class="line" id="L831">                        <span class="tok-kw">const</span> value = &amp;it.hm.values()[it.index];</span>
<span class="line" id="L832">                        it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L833">                        <span class="tok-kw">return</span> Entry{ .key_ptr = key, .value_ptr = value };</span>
<span class="line" id="L834">                    }</span>
<span class="line" id="L835">                }</span>
<span class="line" id="L836"></span>
<span class="line" id="L837">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L838">            }</span>
<span class="line" id="L839">        };</span>
<span class="line" id="L840"></span>
<span class="line" id="L841">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyIterator = FieldIterator(K);</span>
<span class="line" id="L842">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ValueIterator = FieldIterator(V);</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">        <span class="tok-kw">fn</span> <span class="tok-fn">FieldIterator</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L845">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L846">                len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L847">                metadata: [*]<span class="tok-kw">const</span> Metadata,</span>
<span class="line" id="L848">                items: [*]T,</span>
<span class="line" id="L849"></span>
<span class="line" id="L850">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *<span class="tok-builtin">@This</span>()) ?*T {</span>
<span class="line" id="L851">                    <span class="tok-kw">while</span> (self.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L852">                        self.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L853">                        <span class="tok-kw">const</span> used = self.metadata[<span class="tok-number">0</span>].isUsed();</span>
<span class="line" id="L854">                        <span class="tok-kw">const</span> item = &amp;self.items[<span class="tok-number">0</span>];</span>
<span class="line" id="L855">                        self.metadata += <span class="tok-number">1</span>;</span>
<span class="line" id="L856">                        self.items += <span class="tok-number">1</span>;</span>
<span class="line" id="L857">                        <span class="tok-kw">if</span> (used) {</span>
<span class="line" id="L858">                            <span class="tok-kw">return</span> item;</span>
<span class="line" id="L859">                        }</span>
<span class="line" id="L860">                    }</span>
<span class="line" id="L861">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L862">                }</span>
<span class="line" id="L863">            };</span>
<span class="line" id="L864">        }</span>
<span class="line" id="L865"></span>
<span class="line" id="L866">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetOrPutResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L867">            key_ptr: *K,</span>
<span class="line" id="L868">            value_ptr: *V,</span>
<span class="line" id="L869">            found_existing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L870">        };</span>
<span class="line" id="L871"></span>
<span class="line" id="L872">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Managed = HashMap(K, V, Context, max_load_percentage);</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promote</span>(self: Self, allocator: Allocator) Managed {</span>
<span class="line" id="L875">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L876">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call promoteContext instead.&quot;</span>);</span>
<span class="line" id="L877">            <span class="tok-kw">return</span> promoteContext(self, allocator, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L878">        }</span>
<span class="line" id="L879"></span>
<span class="line" id="L880">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promoteContext</span>(self: Self, allocator: Allocator, ctx: Context) Managed {</span>
<span class="line" id="L881">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L882">                .unmanaged = self,</span>
<span class="line" id="L883">                .allocator = allocator,</span>
<span class="line" id="L884">                .ctx = ctx,</span>
<span class="line" id="L885">            };</span>
<span class="line" id="L886">        }</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">        <span class="tok-kw">fn</span> <span class="tok-fn">isUnderMaxLoadPercentage</span>(size: Size, cap: Size) <span class="tok-type">bool</span> {</span>
<span class="line" id="L889">            <span class="tok-kw">return</span> size * <span class="tok-number">100</span> &lt; max_load_percentage * cap;</span>
<span class="line" id="L890">        }</span>
<span class="line" id="L891"></span>
<span class="line" id="L892">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L893">            self.deallocate(allocator);</span>
<span class="line" id="L894">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L895">        }</span>
<span class="line" id="L896"></span>
<span class="line" id="L897">        <span class="tok-kw">fn</span> <span class="tok-fn">capacityForSize</span>(size: Size) Size {</span>
<span class="line" id="L898">            <span class="tok-kw">var</span> new_cap = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, size) * <span class="tok-number">100</span>) / max_load_percentage + <span class="tok-number">1</span>);</span>
<span class="line" id="L899">            new_cap = math.ceilPowerOfTwo(<span class="tok-type">u32</span>, new_cap) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L900">            <span class="tok-kw">return</span> new_cap;</span>
<span class="line" id="L901">        }</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L904"></span>
<span class="line" id="L905">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, allocator: Allocator, new_size: Size) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L906">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L907">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call ensureTotalCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L908">            <span class="tok-kw">return</span> ensureTotalCapacityContext(self, allocator, new_size, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L909">        }</span>
<span class="line" id="L910">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacityContext</span>(self: *Self, allocator: Allocator, new_size: Size, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L911">            <span class="tok-kw">if</span> (new_size &gt; self.size)</span>
<span class="line" id="L912">                <span class="tok-kw">try</span> self.growIfNeeded(allocator, new_size - self.size, ctx);</span>
<span class="line" id="L913">        }</span>
<span class="line" id="L914"></span>
<span class="line" id="L915">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, allocator: Allocator, additional_size: Size) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L916">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L917">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call ensureUnusedCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L918">            <span class="tok-kw">return</span> ensureUnusedCapacityContext(self, allocator, additional_size, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L919">        }</span>
<span class="line" id="L920">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacityContext</span>(self: *Self, allocator: Allocator, additional_size: Size, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L921">            <span class="tok-kw">return</span> ensureTotalCapacityContext(self, allocator, self.count() + additional_size, ctx);</span>
<span class="line" id="L922">        }</span>
<span class="line" id="L923"></span>
<span class="line" id="L924">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L925">            <span class="tok-kw">if</span> (self.metadata) |_| {</span>
<span class="line" id="L926">                self.initMetadatas();</span>
<span class="line" id="L927">                self.size = <span class="tok-number">0</span>;</span>
<span class="line" id="L928">                self.available = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, (self.capacity() * max_load_percentage) / <span class="tok-number">100</span>);</span>
<span class="line" id="L929">            }</span>
<span class="line" id="L930">        }</span>
<span class="line" id="L931"></span>
<span class="line" id="L932">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L933">            self.deallocate(allocator);</span>
<span class="line" id="L934">            self.size = <span class="tok-number">0</span>;</span>
<span class="line" id="L935">            self.available = <span class="tok-number">0</span>;</span>
<span class="line" id="L936">        }</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: *<span class="tok-kw">const</span> Self) Size {</span>
<span class="line" id="L939">            <span class="tok-kw">return</span> self.size;</span>
<span class="line" id="L940">        }</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        <span class="tok-kw">fn</span> <span class="tok-fn">header</span>(self: *<span class="tok-kw">const</span> Self) *Header {</span>
<span class="line" id="L943">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*Header, <span class="tok-builtin">@ptrCast</span>([*]Header, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Header), self.metadata.?)) - <span class="tok-number">1</span>);</span>
<span class="line" id="L944">        }</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">        <span class="tok-kw">fn</span> <span class="tok-fn">keys</span>(self: *<span class="tok-kw">const</span> Self) [*]K {</span>
<span class="line" id="L947">            <span class="tok-kw">return</span> self.header().keys;</span>
<span class="line" id="L948">        }</span>
<span class="line" id="L949"></span>
<span class="line" id="L950">        <span class="tok-kw">fn</span> <span class="tok-fn">values</span>(self: *<span class="tok-kw">const</span> Self) [*]V {</span>
<span class="line" id="L951">            <span class="tok-kw">return</span> self.header().values;</span>
<span class="line" id="L952">        }</span>
<span class="line" id="L953"></span>
<span class="line" id="L954">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: *<span class="tok-kw">const</span> Self) Size {</span>
<span class="line" id="L955">            <span class="tok-kw">if</span> (self.metadata == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">            <span class="tok-kw">return</span> self.header().capacity;</span>
<span class="line" id="L958">        }</span>
<span class="line" id="L959"></span>
<span class="line" id="L960">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self) Iterator {</span>
<span class="line" id="L961">            <span class="tok-kw">return</span> .{ .hm = self };</span>
<span class="line" id="L962">        }</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyIterator</span>(self: *<span class="tok-kw">const</span> Self) KeyIterator {</span>
<span class="line" id="L965">            <span class="tok-kw">if</span> (self.metadata) |metadata| {</span>
<span class="line" id="L966">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L967">                    .len = self.capacity(),</span>
<span class="line" id="L968">                    .metadata = metadata,</span>
<span class="line" id="L969">                    .items = self.keys(),</span>
<span class="line" id="L970">                };</span>
<span class="line" id="L971">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L972">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L973">                    .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L974">                    .metadata = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L975">                    .items = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L976">                };</span>
<span class="line" id="L977">            }</span>
<span class="line" id="L978">        }</span>
<span class="line" id="L979"></span>
<span class="line" id="L980">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">valueIterator</span>(self: *<span class="tok-kw">const</span> Self) ValueIterator {</span>
<span class="line" id="L981">            <span class="tok-kw">if</span> (self.metadata) |metadata| {</span>
<span class="line" id="L982">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L983">                    .len = self.capacity(),</span>
<span class="line" id="L984">                    .metadata = metadata,</span>
<span class="line" id="L985">                    .items = self.values(),</span>
<span class="line" id="L986">                };</span>
<span class="line" id="L987">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L988">                <span class="tok-kw">return</span> .{</span>
<span class="line" id="L989">                    .len = <span class="tok-number">0</span>,</span>
<span class="line" id="L990">                    .metadata = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L991">                    .items = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L992">                };</span>
<span class="line" id="L993">            }</span>
<span class="line" id="L994">        }</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">        <span class="tok-comment">/// Insert an entry in the map. Assumes it is not already present.</span></span>
<span class="line" id="L997">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobber</span>(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L998">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L999">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putNoClobberContext instead.&quot;</span>);</span>
<span class="line" id="L1000">            <span class="tok-kw">return</span> self.putNoClobberContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1001">        }</span>
<span class="line" id="L1002">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobberContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1003">            assert(!self.containsContext(key, ctx));</span>
<span class="line" id="L1004">            <span class="tok-kw">try</span> self.growIfNeeded(allocator, <span class="tok-number">1</span>, ctx);</span>
<span class="line" id="L1005"></span>
<span class="line" id="L1006">            self.putAssumeCapacityNoClobberContext(key, value, ctx);</span>
<span class="line" id="L1007">        }</span>
<span class="line" id="L1008"></span>
<span class="line" id="L1009">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L1010">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L1011">        <span class="tok-comment">/// existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L1012">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacity</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L1013">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1014">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L1015">            <span class="tok-kw">return</span> self.putAssumeCapacityContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1016">        }</span>
<span class="line" id="L1017">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityContext</span>(self: *Self, key: K, value: V, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1018">            <span class="tok-kw">const</span> gop = self.getOrPutAssumeCapacityContext(key, ctx);</span>
<span class="line" id="L1019">            gop.value_ptr.* = value;</span>
<span class="line" id="L1020">        }</span>
<span class="line" id="L1021"></span>
<span class="line" id="L1022">        <span class="tok-comment">/// Insert an entry in the map. Assumes it is not already present,</span></span>
<span class="line" id="L1023">        <span class="tok-comment">/// and that no allocation is needed.</span></span>
<span class="line" id="L1024">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobber</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L1025">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1026">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putAssumeCapacityNoClobberContext instead.&quot;</span>);</span>
<span class="line" id="L1027">            <span class="tok-kw">return</span> self.putAssumeCapacityNoClobberContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1028">        }</span>
<span class="line" id="L1029">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobberContext</span>(self: *Self, key: K, value: V, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1030">            assert(!self.containsContext(key, ctx));</span>
<span class="line" id="L1031"></span>
<span class="line" id="L1032">            <span class="tok-kw">const</span> hash = ctx.hash(key);</span>
<span class="line" id="L1033">            <span class="tok-kw">const</span> mask = self.capacity() - <span class="tok-number">1</span>;</span>
<span class="line" id="L1034">            <span class="tok-kw">var</span> idx = <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, hash &amp; mask);</span>
<span class="line" id="L1035"></span>
<span class="line" id="L1036">            <span class="tok-kw">var</span> metadata = self.metadata.? + idx;</span>
<span class="line" id="L1037">            <span class="tok-kw">while</span> (metadata[<span class="tok-number">0</span>].isUsed()) {</span>
<span class="line" id="L1038">                idx = (idx + <span class="tok-number">1</span>) &amp; mask;</span>
<span class="line" id="L1039">                metadata = self.metadata.? + idx;</span>
<span class="line" id="L1040">            }</span>
<span class="line" id="L1041"></span>
<span class="line" id="L1042">            assert(self.available &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1043">            self.available -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1044"></span>
<span class="line" id="L1045">            <span class="tok-kw">const</span> fingerprint = Metadata.takeFingerprint(hash);</span>
<span class="line" id="L1046">            metadata[<span class="tok-number">0</span>].fill(fingerprint);</span>
<span class="line" id="L1047">            self.keys()[idx] = key;</span>
<span class="line" id="L1048">            self.values()[idx] = value;</span>
<span class="line" id="L1049"></span>
<span class="line" id="L1050">            self.size += <span class="tok-number">1</span>;</span>
<span class="line" id="L1051">        }</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L1054">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPut</span>(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!?KV {</span>
<span class="line" id="L1055">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1056">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchPutContext instead.&quot;</span>);</span>
<span class="line" id="L1057">            <span class="tok-kw">return</span> self.fetchPutContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1058">        }</span>
<span class="line" id="L1059">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!?KV {</span>
<span class="line" id="L1060">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.getOrPutContext(allocator, key, ctx);</span>
<span class="line" id="L1061">            <span class="tok-kw">var</span> result: ?KV = <span class="tok-null">null</span>;</span>
<span class="line" id="L1062">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L1063">                result = KV{</span>
<span class="line" id="L1064">                    .key = gop.key_ptr.*,</span>
<span class="line" id="L1065">                    .value = gop.value_ptr.*,</span>
<span class="line" id="L1066">                };</span>
<span class="line" id="L1067">            }</span>
<span class="line" id="L1068">            gop.value_ptr.* = value;</span>
<span class="line" id="L1069">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1070">        }</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L1073">        <span class="tok-comment">/// If insertion happens, asserts there is enough capacity without allocating.</span></span>
<span class="line" id="L1074">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacity</span>(self: *Self, key: K, value: V) ?KV {</span>
<span class="line" id="L1075">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1076">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchPutAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L1077">            <span class="tok-kw">return</span> self.fetchPutAssumeCapacityContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1078">        }</span>
<span class="line" id="L1079">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacityContext</span>(self: *Self, key: K, value: V, ctx: Context) ?KV {</span>
<span class="line" id="L1080">            <span class="tok-kw">const</span> gop = self.getOrPutAssumeCapacityContext(key, ctx);</span>
<span class="line" id="L1081">            <span class="tok-kw">var</span> result: ?KV = <span class="tok-null">null</span>;</span>
<span class="line" id="L1082">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L1083">                result = KV{</span>
<span class="line" id="L1084">                    .key = gop.key_ptr.*,</span>
<span class="line" id="L1085">                    .value = gop.value_ptr.*,</span>
<span class="line" id="L1086">                };</span>
<span class="line" id="L1087">            }</span>
<span class="line" id="L1088">            gop.value_ptr.* = value;</span>
<span class="line" id="L1089">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1090">        }</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1093">        <span class="tok-comment">/// the hash map, and then returned from this function.</span></span>
<span class="line" id="L1094">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L1095">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1096">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchRemoveContext instead.&quot;</span>);</span>
<span class="line" id="L1097">            <span class="tok-kw">return</span> self.fetchRemoveContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1098">        }</span>
<span class="line" id="L1099">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemoveContext</span>(self: *Self, key: K, ctx: Context) ?KV {</span>
<span class="line" id="L1100">            <span class="tok-kw">return</span> self.fetchRemoveAdapted(key, ctx);</span>
<span class="line" id="L1101">        }</span>
<span class="line" id="L1102">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L1103">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1104">                <span class="tok-kw">const</span> old_key = &amp;self.keys()[idx];</span>
<span class="line" id="L1105">                <span class="tok-kw">const</span> old_val = &amp;self.values()[idx];</span>
<span class="line" id="L1106">                <span class="tok-kw">const</span> result = KV{</span>
<span class="line" id="L1107">                    .key = old_key.*,</span>
<span class="line" id="L1108">                    .value = old_val.*,</span>
<span class="line" id="L1109">                };</span>
<span class="line" id="L1110">                self.metadata.?[idx].remove();</span>
<span class="line" id="L1111">                old_key.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1112">                old_val.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1113">                self.size -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1114">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1115">            }</span>
<span class="line" id="L1116"></span>
<span class="line" id="L1117">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1118">        }</span>
<span class="line" id="L1119"></span>
<span class="line" id="L1120">        <span class="tok-comment">/// Find the index containing the data for the given key.</span></span>
<span class="line" id="L1121">        <span class="tok-comment">/// Whether this function returns null is almost always</span></span>
<span class="line" id="L1122">        <span class="tok-comment">/// branched on after this function returns, and this function</span></span>
<span class="line" id="L1123">        <span class="tok-comment">/// returns null/not null from separate code paths.  We</span></span>
<span class="line" id="L1124">        <span class="tok-comment">/// want the optimizer to remove that branch and instead directly</span></span>
<span class="line" id="L1125">        <span class="tok-comment">/// fuse the basic blocks after the branch to the basic blocks</span></span>
<span class="line" id="L1126">        <span class="tok-comment">/// from this function.  To encourage that, this function is</span></span>
<span class="line" id="L1127">        <span class="tok-comment">/// marked as inline.</span></span>
<span class="line" id="L1128">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndex</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1129">            <span class="tok-kw">comptime</span> verifyContext(<span class="tok-builtin">@TypeOf</span>(ctx), <span class="tok-builtin">@TypeOf</span>(key), K, Hash, <span class="tok-null">false</span>);</span>
<span class="line" id="L1130"></span>
<span class="line" id="L1131">            <span class="tok-kw">if</span> (self.size == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1132">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1133">            }</span>
<span class="line" id="L1134"></span>
<span class="line" id="L1135">            <span class="tok-comment">// If you get a compile error on this line, it means that your generic hash</span>
</span>
<span class="line" id="L1136">            <span class="tok-comment">// function is invalid for these parameters.</span>
</span>
<span class="line" id="L1137">            <span class="tok-kw">const</span> hash = ctx.hash(key);</span>
<span class="line" id="L1138">            <span class="tok-comment">// verifyContext can't verify the return type of generic hash functions,</span>
</span>
<span class="line" id="L1139">            <span class="tok-comment">// so we need to double-check it here.</span>
</span>
<span class="line" id="L1140">            <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(hash) != Hash) {</span>
<span class="line" id="L1141">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic hash function that returns the wrong type! &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Hash) ++ <span class="tok-str">&quot; was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(hash)));</span>
<span class="line" id="L1142">            }</span>
<span class="line" id="L1143">            <span class="tok-kw">const</span> mask = self.capacity() - <span class="tok-number">1</span>;</span>
<span class="line" id="L1144">            <span class="tok-kw">const</span> fingerprint = Metadata.takeFingerprint(hash);</span>
<span class="line" id="L1145">            <span class="tok-comment">// Don't loop indefinitely when there are no empty slots.</span>
</span>
<span class="line" id="L1146">            <span class="tok-kw">var</span> limit = self.capacity();</span>
<span class="line" id="L1147">            <span class="tok-kw">var</span> idx = <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, hash &amp; mask);</span>
<span class="line" id="L1148"></span>
<span class="line" id="L1149">            <span class="tok-kw">var</span> metadata = self.metadata.? + idx;</span>
<span class="line" id="L1150">            <span class="tok-kw">while</span> (!metadata[<span class="tok-number">0</span>].isFree() <span class="tok-kw">and</span> limit != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1151">                <span class="tok-kw">if</span> (metadata[<span class="tok-number">0</span>].isUsed() <span class="tok-kw">and</span> metadata[<span class="tok-number">0</span>].fingerprint == fingerprint) {</span>
<span class="line" id="L1152">                    <span class="tok-kw">const</span> test_key = &amp;self.keys()[idx];</span>
<span class="line" id="L1153">                    <span class="tok-comment">// If you get a compile error on this line, it means that your generic eql</span>
</span>
<span class="line" id="L1154">                    <span class="tok-comment">// function is invalid for these parameters.</span>
</span>
<span class="line" id="L1155">                    <span class="tok-kw">const</span> eql = ctx.eql(key, test_key.*);</span>
<span class="line" id="L1156">                    <span class="tok-comment">// verifyContext can't verify the return type of generic eql functions,</span>
</span>
<span class="line" id="L1157">                    <span class="tok-comment">// so we need to double-check it here.</span>
</span>
<span class="line" id="L1158">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(eql) != <span class="tok-type">bool</span>) {</span>
<span class="line" id="L1159">                        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic eql function that returns the wrong type! bool was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(eql)));</span>
<span class="line" id="L1160">                    }</span>
<span class="line" id="L1161">                    <span class="tok-kw">if</span> (eql) {</span>
<span class="line" id="L1162">                        <span class="tok-kw">return</span> idx;</span>
<span class="line" id="L1163">                    }</span>
<span class="line" id="L1164">                }</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166">                limit -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1167">                idx = (idx + <span class="tok-number">1</span>) &amp; mask;</span>
<span class="line" id="L1168">                metadata = self.metadata.? + idx;</span>
<span class="line" id="L1169">            }</span>
<span class="line" id="L1170"></span>
<span class="line" id="L1171">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1172">        }</span>
<span class="line" id="L1173"></span>
<span class="line" id="L1174">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntry</span>(self: Self, key: K) ?Entry {</span>
<span class="line" id="L1175">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1176">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getEntryContext instead.&quot;</span>);</span>
<span class="line" id="L1177">            <span class="tok-kw">return</span> self.getEntryContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1178">        }</span>
<span class="line" id="L1179">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryContext</span>(self: Self, key: K, ctx: Context) ?Entry {</span>
<span class="line" id="L1180">            <span class="tok-kw">return</span> self.getEntryAdapted(key, ctx);</span>
<span class="line" id="L1181">        }</span>
<span class="line" id="L1182">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?Entry {</span>
<span class="line" id="L1183">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1184">                <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L1185">                    .key_ptr = &amp;self.keys()[idx],</span>
<span class="line" id="L1186">                    .value_ptr = &amp;self.values()[idx],</span>
<span class="line" id="L1187">                };</span>
<span class="line" id="L1188">            }</span>
<span class="line" id="L1189">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1190">        }</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">        <span class="tok-comment">/// Insert an entry if the associated key is not already present, otherwise update preexisting value.</span></span>
<span class="line" id="L1193">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1194">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1195">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putContext instead.&quot;</span>);</span>
<span class="line" id="L1196">            <span class="tok-kw">return</span> self.putContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1197">        }</span>
<span class="line" id="L1198">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1199">            <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.getOrPutContext(allocator, key, ctx);</span>
<span class="line" id="L1200">            result.value_ptr.* = value;</span>
<span class="line" id="L1201">        }</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203">        <span class="tok-comment">/// Get an optional pointer to the actual key associated with adapted key, if present.</span></span>
<span class="line" id="L1204">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtr</span>(self: Self, key: K) ?*K {</span>
<span class="line" id="L1205">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1206">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getKeyPtrContext instead.&quot;</span>);</span>
<span class="line" id="L1207">            <span class="tok-kw">return</span> self.getKeyPtrContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1208">        }</span>
<span class="line" id="L1209">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrContext</span>(self: Self, key: K, ctx: Context) ?*K {</span>
<span class="line" id="L1210">            <span class="tok-kw">return</span> self.getKeyPtrAdapted(key, ctx);</span>
<span class="line" id="L1211">        }</span>
<span class="line" id="L1212">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*K {</span>
<span class="line" id="L1213">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1214">                <span class="tok-kw">return</span> &amp;self.keys()[idx];</span>
<span class="line" id="L1215">            }</span>
<span class="line" id="L1216">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1217">        }</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219">        <span class="tok-comment">/// Get a copy of the actual key associated with adapted key, if present.</span></span>
<span class="line" id="L1220">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKey</span>(self: Self, key: K) ?K {</span>
<span class="line" id="L1221">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1222">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getKeyContext instead.&quot;</span>);</span>
<span class="line" id="L1223">            <span class="tok-kw">return</span> self.getKeyContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1224">        }</span>
<span class="line" id="L1225">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyContext</span>(self: Self, key: K, ctx: Context) ?K {</span>
<span class="line" id="L1226">            <span class="tok-kw">return</span> self.getKeyAdapted(key, ctx);</span>
<span class="line" id="L1227">        }</span>
<span class="line" id="L1228">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?K {</span>
<span class="line" id="L1229">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1230">                <span class="tok-kw">return</span> self.keys()[idx];</span>
<span class="line" id="L1231">            }</span>
<span class="line" id="L1232">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1233">        }</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235">        <span class="tok-comment">/// Get an optional pointer to the value associated with key, if present.</span></span>
<span class="line" id="L1236">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: Self, key: K) ?*V {</span>
<span class="line" id="L1237">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1238">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getPtrContext instead.&quot;</span>);</span>
<span class="line" id="L1239">            <span class="tok-kw">return</span> self.getPtrContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1240">        }</span>
<span class="line" id="L1241">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrContext</span>(self: Self, key: K, ctx: Context) ?*V {</span>
<span class="line" id="L1242">            <span class="tok-kw">return</span> self.getPtrAdapted(key, ctx);</span>
<span class="line" id="L1243">        }</span>
<span class="line" id="L1244">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*V {</span>
<span class="line" id="L1245">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1246">                <span class="tok-kw">return</span> &amp;self.values()[idx];</span>
<span class="line" id="L1247">            }</span>
<span class="line" id="L1248">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1249">        }</span>
<span class="line" id="L1250"></span>
<span class="line" id="L1251">        <span class="tok-comment">/// Get a copy of the value associated with key, if present.</span></span>
<span class="line" id="L1252">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: K) ?V {</span>
<span class="line" id="L1253">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1254">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getContext instead.&quot;</span>);</span>
<span class="line" id="L1255">            <span class="tok-kw">return</span> self.getContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1256">        }</span>
<span class="line" id="L1257">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getContext</span>(self: Self, key: K, ctx: Context) ?V {</span>
<span class="line" id="L1258">            <span class="tok-kw">return</span> self.getAdapted(key, ctx);</span>
<span class="line" id="L1259">        }</span>
<span class="line" id="L1260">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?V {</span>
<span class="line" id="L1261">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1262">                <span class="tok-kw">return</span> self.values()[idx];</span>
<span class="line" id="L1263">            }</span>
<span class="line" id="L1264">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1265">        }</span>
<span class="line" id="L1266"></span>
<span class="line" id="L1267">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPut</span>(self: *Self, allocator: Allocator, key: K) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L1268">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1269">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutContext instead.&quot;</span>);</span>
<span class="line" id="L1270">            <span class="tok-kw">return</span> self.getOrPutContext(allocator, key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1271">        }</span>
<span class="line" id="L1272">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutContext</span>(self: *Self, allocator: Allocator, key: K, ctx: Context) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L1273">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.getOrPutContextAdapted(allocator, key, ctx, ctx);</span>
<span class="line" id="L1274">            <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L1275">                gop.key_ptr.* = key;</span>
<span class="line" id="L1276">            }</span>
<span class="line" id="L1277">            <span class="tok-kw">return</span> gop;</span>
<span class="line" id="L1278">        }</span>
<span class="line" id="L1279">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAdapted</span>(self: *Self, allocator: Allocator, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L1280">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1281">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L1282">            <span class="tok-kw">return</span> self.getOrPutContextAdapted(allocator, key, key_ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1283">        }</span>
<span class="line" id="L1284">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutContextAdapted</span>(self: *Self, allocator: Allocator, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) Allocator.Error!GetOrPutResult {</span>
<span class="line" id="L1285">            self.growIfNeeded(allocator, <span class="tok-number">1</span>, ctx) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L1286">                <span class="tok-comment">// If allocation fails, try to do the lookup anyway.</span>
</span>
<span class="line" id="L1287">                <span class="tok-comment">// If we find an existing item, we can return it.</span>
</span>
<span class="line" id="L1288">                <span class="tok-comment">// Otherwise return the error, we could not add another.</span>
</span>
<span class="line" id="L1289">                <span class="tok-kw">const</span> index = self.getIndex(key, key_ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1290">                <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L1291">                    .key_ptr = &amp;self.keys()[index],</span>
<span class="line" id="L1292">                    .value_ptr = &amp;self.values()[index],</span>
<span class="line" id="L1293">                    .found_existing = <span class="tok-null">true</span>,</span>
<span class="line" id="L1294">                };</span>
<span class="line" id="L1295">            };</span>
<span class="line" id="L1296">            <span class="tok-kw">return</span> self.getOrPutAssumeCapacityAdapted(key, key_ctx);</span>
<span class="line" id="L1297">        }</span>
<span class="line" id="L1298"></span>
<span class="line" id="L1299">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacity</span>(self: *Self, key: K) GetOrPutResult {</span>
<span class="line" id="L1300">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1301">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L1302">            <span class="tok-kw">return</span> self.getOrPutAssumeCapacityContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1303">        }</span>
<span class="line" id="L1304">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityContext</span>(self: *Self, key: K, ctx: Context) GetOrPutResult {</span>
<span class="line" id="L1305">            <span class="tok-kw">const</span> result = self.getOrPutAssumeCapacityAdapted(key, ctx);</span>
<span class="line" id="L1306">            <span class="tok-kw">if</span> (!result.found_existing) {</span>
<span class="line" id="L1307">                result.key_ptr.* = key;</span>
<span class="line" id="L1308">            }</span>
<span class="line" id="L1309">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1310">        }</span>
<span class="line" id="L1311">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) GetOrPutResult {</span>
<span class="line" id="L1312">            <span class="tok-kw">comptime</span> verifyContext(<span class="tok-builtin">@TypeOf</span>(ctx), <span class="tok-builtin">@TypeOf</span>(key), K, Hash, <span class="tok-null">false</span>);</span>
<span class="line" id="L1313"></span>
<span class="line" id="L1314">            <span class="tok-comment">// If you get a compile error on this line, it means that your generic hash</span>
</span>
<span class="line" id="L1315">            <span class="tok-comment">// function is invalid for these parameters.</span>
</span>
<span class="line" id="L1316">            <span class="tok-kw">const</span> hash = ctx.hash(key);</span>
<span class="line" id="L1317">            <span class="tok-comment">// verifyContext can't verify the return type of generic hash functions,</span>
</span>
<span class="line" id="L1318">            <span class="tok-comment">// so we need to double-check it here.</span>
</span>
<span class="line" id="L1319">            <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(hash) != Hash) {</span>
<span class="line" id="L1320">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic hash function that returns the wrong type! &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Hash) ++ <span class="tok-str">&quot; was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(hash)));</span>
<span class="line" id="L1321">            }</span>
<span class="line" id="L1322">            <span class="tok-kw">const</span> mask = self.capacity() - <span class="tok-number">1</span>;</span>
<span class="line" id="L1323">            <span class="tok-kw">const</span> fingerprint = Metadata.takeFingerprint(hash);</span>
<span class="line" id="L1324">            <span class="tok-kw">var</span> limit = self.capacity();</span>
<span class="line" id="L1325">            <span class="tok-kw">var</span> idx = <span class="tok-builtin">@truncate</span>(<span class="tok-type">usize</span>, hash &amp; mask);</span>
<span class="line" id="L1326"></span>
<span class="line" id="L1327">            <span class="tok-kw">var</span> first_tombstone_idx: <span class="tok-type">usize</span> = self.capacity(); <span class="tok-comment">// invalid index</span>
</span>
<span class="line" id="L1328">            <span class="tok-kw">var</span> metadata = self.metadata.? + idx;</span>
<span class="line" id="L1329">            <span class="tok-kw">while</span> (!metadata[<span class="tok-number">0</span>].isFree() <span class="tok-kw">and</span> limit != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1330">                <span class="tok-kw">if</span> (metadata[<span class="tok-number">0</span>].isUsed() <span class="tok-kw">and</span> metadata[<span class="tok-number">0</span>].fingerprint == fingerprint) {</span>
<span class="line" id="L1331">                    <span class="tok-kw">const</span> test_key = &amp;self.keys()[idx];</span>
<span class="line" id="L1332">                    <span class="tok-comment">// If you get a compile error on this line, it means that your generic eql</span>
</span>
<span class="line" id="L1333">                    <span class="tok-comment">// function is invalid for these parameters.</span>
</span>
<span class="line" id="L1334">                    <span class="tok-kw">const</span> eql = ctx.eql(key, test_key.*);</span>
<span class="line" id="L1335">                    <span class="tok-comment">// verifyContext can't verify the return type of generic eql functions,</span>
</span>
<span class="line" id="L1336">                    <span class="tok-comment">// so we need to double-check it here.</span>
</span>
<span class="line" id="L1337">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(eql) != <span class="tok-type">bool</span>) {</span>
<span class="line" id="L1338">                        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic eql function that returns the wrong type! bool was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(eql)));</span>
<span class="line" id="L1339">                    }</span>
<span class="line" id="L1340">                    <span class="tok-kw">if</span> (eql) {</span>
<span class="line" id="L1341">                        <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L1342">                            .key_ptr = test_key,</span>
<span class="line" id="L1343">                            .value_ptr = &amp;self.values()[idx],</span>
<span class="line" id="L1344">                            .found_existing = <span class="tok-null">true</span>,</span>
<span class="line" id="L1345">                        };</span>
<span class="line" id="L1346">                    }</span>
<span class="line" id="L1347">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (first_tombstone_idx == self.capacity() <span class="tok-kw">and</span> metadata[<span class="tok-number">0</span>].isTombstone()) {</span>
<span class="line" id="L1348">                    first_tombstone_idx = idx;</span>
<span class="line" id="L1349">                }</span>
<span class="line" id="L1350"></span>
<span class="line" id="L1351">                limit -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1352">                idx = (idx + <span class="tok-number">1</span>) &amp; mask;</span>
<span class="line" id="L1353">                metadata = self.metadata.? + idx;</span>
<span class="line" id="L1354">            }</span>
<span class="line" id="L1355"></span>
<span class="line" id="L1356">            <span class="tok-kw">if</span> (first_tombstone_idx &lt; self.capacity()) {</span>
<span class="line" id="L1357">                <span class="tok-comment">// Cheap try to lower probing lengths after deletions. Recycle a tombstone.</span>
</span>
<span class="line" id="L1358">                idx = first_tombstone_idx;</span>
<span class="line" id="L1359">                metadata = self.metadata.? + idx;</span>
<span class="line" id="L1360">            }</span>
<span class="line" id="L1361">            <span class="tok-comment">// We're using a slot previously free or a tombstone.</span>
</span>
<span class="line" id="L1362">            self.available -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364">            metadata[<span class="tok-number">0</span>].fill(fingerprint);</span>
<span class="line" id="L1365">            <span class="tok-kw">const</span> new_key = &amp;self.keys()[idx];</span>
<span class="line" id="L1366">            <span class="tok-kw">const</span> new_value = &amp;self.values()[idx];</span>
<span class="line" id="L1367">            new_key.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1368">            new_value.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1369">            self.size += <span class="tok-number">1</span>;</span>
<span class="line" id="L1370"></span>
<span class="line" id="L1371">            <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L1372">                .key_ptr = new_key,</span>
<span class="line" id="L1373">                .value_ptr = new_value,</span>
<span class="line" id="L1374">                .found_existing = <span class="tok-null">false</span>,</span>
<span class="line" id="L1375">            };</span>
<span class="line" id="L1376">        }</span>
<span class="line" id="L1377"></span>
<span class="line" id="L1378">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValue</span>(self: *Self, allocator: Allocator, key: K, value: V) Allocator.Error!Entry {</span>
<span class="line" id="L1379">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1380">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutValueContext instead.&quot;</span>);</span>
<span class="line" id="L1381">            <span class="tok-kw">return</span> self.getOrPutValueContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1382">        }</span>
<span class="line" id="L1383">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValueContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) Allocator.Error!Entry {</span>
<span class="line" id="L1384">            <span class="tok-kw">const</span> res = <span class="tok-kw">try</span> self.getOrPutAdapted(allocator, key, ctx);</span>
<span class="line" id="L1385">            <span class="tok-kw">if</span> (!res.found_existing) {</span>
<span class="line" id="L1386">                res.key_ptr.* = key;</span>
<span class="line" id="L1387">                res.value_ptr.* = value;</span>
<span class="line" id="L1388">            }</span>
<span class="line" id="L1389">            <span class="tok-kw">return</span> Entry{ .key_ptr = res.key_ptr, .value_ptr = res.value_ptr };</span>
<span class="line" id="L1390">        }</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392">        <span class="tok-comment">/// Return true if there is a value associated with key in the map.</span></span>
<span class="line" id="L1393">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: *<span class="tok-kw">const</span> Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1394">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1395">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call containsContext instead.&quot;</span>);</span>
<span class="line" id="L1396">            <span class="tok-kw">return</span> self.containsContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1397">        }</span>
<span class="line" id="L1398">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsContext</span>(self: *<span class="tok-kw">const</span> Self, key: K, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1399">            <span class="tok-kw">return</span> self.containsAdapted(key, ctx);</span>
<span class="line" id="L1400">        }</span>
<span class="line" id="L1401">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsAdapted</span>(self: *<span class="tok-kw">const</span> Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1402">            <span class="tok-kw">return</span> self.getIndex(key, ctx) != <span class="tok-null">null</span>;</span>
<span class="line" id="L1403">        }</span>
<span class="line" id="L1404"></span>
<span class="line" id="L1405">        <span class="tok-kw">fn</span> <span class="tok-fn">removeByIndex</span>(self: *Self, idx: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1406">            self.metadata.?[idx].remove();</span>
<span class="line" id="L1407">            self.keys()[idx] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1408">            self.values()[idx] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1409">            self.size -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1410">            self.available += <span class="tok-number">1</span>;</span>
<span class="line" id="L1411">        }</span>
<span class="line" id="L1412"></span>
<span class="line" id="L1413">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1414">        <span class="tok-comment">/// the hash map, and this function returns true.  Otherwise this</span></span>
<span class="line" id="L1415">        <span class="tok-comment">/// function returns false.</span></span>
<span class="line" id="L1416">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1417">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1418">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call removeContext instead.&quot;</span>);</span>
<span class="line" id="L1419">            <span class="tok-kw">return</span> self.removeContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1420">        }</span>
<span class="line" id="L1421">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeContext</span>(self: *Self, key: K, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1422">            <span class="tok-kw">return</span> self.removeAdapted(key, ctx);</span>
<span class="line" id="L1423">        }</span>
<span class="line" id="L1424">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1425">            <span class="tok-kw">if</span> (self.getIndex(key, ctx)) |idx| {</span>
<span class="line" id="L1426">                self.removeByIndex(idx);</span>
<span class="line" id="L1427">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1428">            }</span>
<span class="line" id="L1429"></span>
<span class="line" id="L1430">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1431">        }</span>
<span class="line" id="L1432"></span>
<span class="line" id="L1433">        <span class="tok-comment">/// Delete the entry with key pointed to by keyPtr from the hash map.</span></span>
<span class="line" id="L1434">        <span class="tok-comment">/// keyPtr is assumed to be a valid pointer to a key that is present</span></span>
<span class="line" id="L1435">        <span class="tok-comment">/// in the hash map.</span></span>
<span class="line" id="L1436">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removeByPtr</span>(self: *Self, keyPtr: *K) <span class="tok-type">void</span> {</span>
<span class="line" id="L1437">            <span class="tok-comment">// TODO: replace with pointer subtraction once supported by zig</span>
</span>
<span class="line" id="L1438">            <span class="tok-comment">// if @sizeOf(K) == 0 then there is at most one item in the hash</span>
</span>
<span class="line" id="L1439">            <span class="tok-comment">// map, which is assumed to exist as keyPtr must be valid.  This</span>
</span>
<span class="line" id="L1440">            <span class="tok-comment">// item must be at index 0.</span>
</span>
<span class="line" id="L1441">            <span class="tok-kw">const</span> idx = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(K) &gt; <span class="tok-number">0</span>)</span>
<span class="line" id="L1442">                (<span class="tok-builtin">@ptrToInt</span>(keyPtr) - <span class="tok-builtin">@ptrToInt</span>(self.keys())) / <span class="tok-builtin">@sizeOf</span>(K)</span>
<span class="line" id="L1443">            <span class="tok-kw">else</span></span>
<span class="line" id="L1444">                <span class="tok-number">0</span>;</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446">            self.removeByIndex(idx);</span>
<span class="line" id="L1447">        }</span>
<span class="line" id="L1448"></span>
<span class="line" id="L1449">        <span class="tok-kw">fn</span> <span class="tok-fn">initMetadatas</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L1450">            <span class="tok-builtin">@memset</span>(<span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self.metadata.?), <span class="tok-number">0</span>, <span class="tok-builtin">@sizeOf</span>(Metadata) * self.capacity());</span>
<span class="line" id="L1451">        }</span>
<span class="line" id="L1452"></span>
<span class="line" id="L1453">        <span class="tok-comment">// This counts the number of occupied slots (not counting tombstones), which is</span>
</span>
<span class="line" id="L1454">        <span class="tok-comment">// what has to stay under the max_load_percentage of capacity.</span>
</span>
<span class="line" id="L1455">        <span class="tok-kw">fn</span> <span class="tok-fn">load</span>(self: *<span class="tok-kw">const</span> Self) Size {</span>
<span class="line" id="L1456">            <span class="tok-kw">const</span> max_load = (self.capacity() * max_load_percentage) / <span class="tok-number">100</span>;</span>
<span class="line" id="L1457">            assert(max_load &gt;= self.available);</span>
<span class="line" id="L1458">            <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(Size, max_load - self.available);</span>
<span class="line" id="L1459">        }</span>
<span class="line" id="L1460"></span>
<span class="line" id="L1461">        <span class="tok-kw">fn</span> <span class="tok-fn">growIfNeeded</span>(self: *Self, allocator: Allocator, new_count: Size, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1462">            <span class="tok-kw">if</span> (new_count &gt; self.available) {</span>
<span class="line" id="L1463">                <span class="tok-kw">try</span> self.grow(allocator, capacityForSize(self.load() + new_count), ctx);</span>
<span class="line" id="L1464">            }</span>
<span class="line" id="L1465">        }</span>
<span class="line" id="L1466"></span>
<span class="line" id="L1467">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: Self, allocator: Allocator) Allocator.Error!Self {</span>
<span class="line" id="L1468">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1469">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call cloneContext instead.&quot;</span>);</span>
<span class="line" id="L1470">            <span class="tok-kw">return</span> self.cloneContext(allocator, <span class="tok-builtin">@as</span>(Context, <span class="tok-null">undefined</span>));</span>
<span class="line" id="L1471">        }</span>
<span class="line" id="L1472">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneContext</span>(self: Self, allocator: Allocator, new_ctx: <span class="tok-kw">anytype</span>) Allocator.Error!HashMapUnmanaged(K, V, <span class="tok-builtin">@TypeOf</span>(new_ctx), max_load_percentage) {</span>
<span class="line" id="L1473">            <span class="tok-kw">var</span> other = HashMapUnmanaged(K, V, <span class="tok-builtin">@TypeOf</span>(new_ctx), max_load_percentage){};</span>
<span class="line" id="L1474">            <span class="tok-kw">if</span> (self.size == <span class="tok-number">0</span>)</span>
<span class="line" id="L1475">                <span class="tok-kw">return</span> other;</span>
<span class="line" id="L1476"></span>
<span class="line" id="L1477">            <span class="tok-kw">const</span> new_cap = capacityForSize(self.size);</span>
<span class="line" id="L1478">            <span class="tok-kw">try</span> other.allocate(allocator, new_cap);</span>
<span class="line" id="L1479">            other.initMetadatas();</span>
<span class="line" id="L1480">            other.available = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, (new_cap * max_load_percentage) / <span class="tok-number">100</span>);</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482">            <span class="tok-kw">var</span> i: Size = <span class="tok-number">0</span>;</span>
<span class="line" id="L1483">            <span class="tok-kw">var</span> metadata = self.metadata.?;</span>
<span class="line" id="L1484">            <span class="tok-kw">var</span> keys_ptr = self.keys();</span>
<span class="line" id="L1485">            <span class="tok-kw">var</span> values_ptr = self.values();</span>
<span class="line" id="L1486">            <span class="tok-kw">while</span> (i &lt; self.capacity()) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1487">                <span class="tok-kw">if</span> (metadata[i].isUsed()) {</span>
<span class="line" id="L1488">                    other.putAssumeCapacityNoClobberContext(keys_ptr[i], values_ptr[i], new_ctx);</span>
<span class="line" id="L1489">                    <span class="tok-kw">if</span> (other.size == self.size)</span>
<span class="line" id="L1490">                        <span class="tok-kw">break</span>;</span>
<span class="line" id="L1491">                }</span>
<span class="line" id="L1492">            }</span>
<span class="line" id="L1493"></span>
<span class="line" id="L1494">            <span class="tok-kw">return</span> other;</span>
<span class="line" id="L1495">        }</span>
<span class="line" id="L1496"></span>
<span class="line" id="L1497">        <span class="tok-kw">fn</span> <span class="tok-fn">grow</span>(self: *Self, allocator: Allocator, new_capacity: Size, ctx: Context) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1498">            <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L1499">            <span class="tok-kw">const</span> new_cap = std.math.max(new_capacity, minimal_capacity);</span>
<span class="line" id="L1500">            assert(new_cap &gt; self.capacity());</span>
<span class="line" id="L1501">            assert(std.math.isPowerOfTwo(new_cap));</span>
<span class="line" id="L1502"></span>
<span class="line" id="L1503">            <span class="tok-kw">var</span> map = Self{};</span>
<span class="line" id="L1504">            <span class="tok-kw">defer</span> map.deinit(allocator);</span>
<span class="line" id="L1505">            <span class="tok-kw">try</span> map.allocate(allocator, new_cap);</span>
<span class="line" id="L1506">            map.initMetadatas();</span>
<span class="line" id="L1507">            map.available = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, (new_cap * max_load_percentage) / <span class="tok-number">100</span>);</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">            <span class="tok-kw">if</span> (self.size != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1510">                <span class="tok-kw">const</span> old_capacity = self.capacity();</span>
<span class="line" id="L1511">                <span class="tok-kw">var</span> i: Size = <span class="tok-number">0</span>;</span>
<span class="line" id="L1512">                <span class="tok-kw">var</span> metadata = self.metadata.?;</span>
<span class="line" id="L1513">                <span class="tok-kw">var</span> keys_ptr = self.keys();</span>
<span class="line" id="L1514">                <span class="tok-kw">var</span> values_ptr = self.values();</span>
<span class="line" id="L1515">                <span class="tok-kw">while</span> (i &lt; old_capacity) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1516">                    <span class="tok-kw">if</span> (metadata[i].isUsed()) {</span>
<span class="line" id="L1517">                        map.putAssumeCapacityNoClobberContext(keys_ptr[i], values_ptr[i], ctx);</span>
<span class="line" id="L1518">                        <span class="tok-kw">if</span> (map.size == self.size)</span>
<span class="line" id="L1519">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L1520">                    }</span>
<span class="line" id="L1521">                }</span>
<span class="line" id="L1522">            }</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524">            self.size = <span class="tok-number">0</span>;</span>
<span class="line" id="L1525">            std.mem.swap(Self, self, &amp;map);</span>
<span class="line" id="L1526">        }</span>
<span class="line" id="L1527"></span>
<span class="line" id="L1528">        <span class="tok-kw">fn</span> <span class="tok-fn">allocate</span>(self: *Self, allocator: Allocator, new_capacity: Size) Allocator.Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L1529">            <span class="tok-kw">const</span> header_align = <span class="tok-builtin">@alignOf</span>(Header);</span>
<span class="line" id="L1530">            <span class="tok-kw">const</span> key_align = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(K) == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(K);</span>
<span class="line" id="L1531">            <span class="tok-kw">const</span> val_align = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(V) == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(V);</span>
<span class="line" id="L1532">            <span class="tok-kw">const</span> max_align = <span class="tok-kw">comptime</span> math.max3(header_align, key_align, val_align);</span>
<span class="line" id="L1533"></span>
<span class="line" id="L1534">            <span class="tok-kw">const</span> meta_size = <span class="tok-builtin">@sizeOf</span>(Header) + new_capacity * <span class="tok-builtin">@sizeOf</span>(Metadata);</span>
<span class="line" id="L1535">            <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@alignOf</span>(Metadata) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1536"></span>
<span class="line" id="L1537">            <span class="tok-kw">const</span> keys_start = std.mem.alignForward(meta_size, key_align);</span>
<span class="line" id="L1538">            <span class="tok-kw">const</span> keys_end = keys_start + new_capacity * <span class="tok-builtin">@sizeOf</span>(K);</span>
<span class="line" id="L1539"></span>
<span class="line" id="L1540">            <span class="tok-kw">const</span> vals_start = std.mem.alignForward(keys_end, val_align);</span>
<span class="line" id="L1541">            <span class="tok-kw">const</span> vals_end = vals_start + new_capacity * <span class="tok-builtin">@sizeOf</span>(V);</span>
<span class="line" id="L1542"></span>
<span class="line" id="L1543">            <span class="tok-kw">const</span> total_size = std.mem.alignForward(vals_end, max_align);</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545">            <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, max_align, total_size);</span>
<span class="line" id="L1546">            <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrToInt</span>(slice.ptr);</span>
<span class="line" id="L1547"></span>
<span class="line" id="L1548">            <span class="tok-kw">const</span> metadata = ptr + <span class="tok-builtin">@sizeOf</span>(Header);</span>
<span class="line" id="L1549"></span>
<span class="line" id="L1550">            <span class="tok-kw">const</span> hdr = <span class="tok-builtin">@intToPtr</span>(*Header, ptr);</span>
<span class="line" id="L1551">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>([*]V) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1552">                hdr.values = <span class="tok-builtin">@intToPtr</span>([*]V, ptr + vals_start);</span>
<span class="line" id="L1553">            }</span>
<span class="line" id="L1554">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>([*]K) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1555">                hdr.keys = <span class="tok-builtin">@intToPtr</span>([*]K, ptr + keys_start);</span>
<span class="line" id="L1556">            }</span>
<span class="line" id="L1557">            hdr.capacity = new_capacity;</span>
<span class="line" id="L1558">            self.metadata = <span class="tok-builtin">@intToPtr</span>([*]Metadata, metadata);</span>
<span class="line" id="L1559">        }</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561">        <span class="tok-kw">fn</span> <span class="tok-fn">deallocate</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1562">            <span class="tok-kw">if</span> (self.metadata == <span class="tok-null">null</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1563"></span>
<span class="line" id="L1564">            <span class="tok-kw">const</span> header_align = <span class="tok-builtin">@alignOf</span>(Header);</span>
<span class="line" id="L1565">            <span class="tok-kw">const</span> key_align = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(K) == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(K);</span>
<span class="line" id="L1566">            <span class="tok-kw">const</span> val_align = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(V) == <span class="tok-number">0</span>) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(V);</span>
<span class="line" id="L1567">            <span class="tok-kw">const</span> max_align = <span class="tok-kw">comptime</span> math.max3(header_align, key_align, val_align);</span>
<span class="line" id="L1568"></span>
<span class="line" id="L1569">            <span class="tok-kw">const</span> cap = self.capacity();</span>
<span class="line" id="L1570">            <span class="tok-kw">const</span> meta_size = <span class="tok-builtin">@sizeOf</span>(Header) + cap * <span class="tok-builtin">@sizeOf</span>(Metadata);</span>
<span class="line" id="L1571">            <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@alignOf</span>(Metadata) == <span class="tok-number">1</span>);</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573">            <span class="tok-kw">const</span> keys_start = std.mem.alignForward(meta_size, key_align);</span>
<span class="line" id="L1574">            <span class="tok-kw">const</span> keys_end = keys_start + cap * <span class="tok-builtin">@sizeOf</span>(K);</span>
<span class="line" id="L1575"></span>
<span class="line" id="L1576">            <span class="tok-kw">const</span> vals_start = std.mem.alignForward(keys_end, val_align);</span>
<span class="line" id="L1577">            <span class="tok-kw">const</span> vals_end = vals_start + cap * <span class="tok-builtin">@sizeOf</span>(V);</span>
<span class="line" id="L1578"></span>
<span class="line" id="L1579">            <span class="tok-kw">const</span> total_size = std.mem.alignForward(vals_end, max_align);</span>
<span class="line" id="L1580"></span>
<span class="line" id="L1581">            <span class="tok-kw">const</span> slice = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-kw">align</span>(max_align) <span class="tok-type">u8</span>, <span class="tok-builtin">@ptrToInt</span>(self.header()))[<span class="tok-number">0</span>..total_size];</span>
<span class="line" id="L1582">            allocator.free(slice);</span>
<span class="line" id="L1583"></span>
<span class="line" id="L1584">            self.metadata = <span class="tok-null">null</span>;</span>
<span class="line" id="L1585">            self.available = <span class="tok-number">0</span>;</span>
<span class="line" id="L1586">        }</span>
<span class="line" id="L1587"></span>
<span class="line" id="L1588">        <span class="tok-comment">/// This function is used in tools/zig-gdb.py to fetch the header type to facilitate</span></span>
<span class="line" id="L1589">        <span class="tok-comment">/// fancy debug printing for this type.</span></span>
<span class="line" id="L1590">        <span class="tok-kw">fn</span> <span class="tok-fn">gdbHelper</span>(self: *Self, hdr: *Header) <span class="tok-type">void</span> {</span>
<span class="line" id="L1591">            _ = self;</span>
<span class="line" id="L1592">            _ = hdr;</span>
<span class="line" id="L1593">        }</span>
<span class="line" id="L1594"></span>
<span class="line" id="L1595">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L1596">            <span class="tok-kw">if</span> (builtin.mode == .Debug) {</span>
<span class="line" id="L1597">                _ = gdbHelper;</span>
<span class="line" id="L1598">            }</span>
<span class="line" id="L1599">        }</span>
<span class="line" id="L1600">    };</span>
<span class="line" id="L1601">}</span>
<span class="line" id="L1602"></span>
<span class="line" id="L1603"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L1604"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L1605"><span class="tok-kw">const</span> expectEqual = std.testing.expectEqual;</span>
<span class="line" id="L1606"></span>
<span class="line" id="L1607"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map basic usage&quot;</span> {</span>
<span class="line" id="L1608">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1609">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1610"></span>
<span class="line" id="L1611">    <span class="tok-kw">const</span> count = <span class="tok-number">5</span>;</span>
<span class="line" id="L1612">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1613">    <span class="tok-kw">var</span> total: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1614">    <span class="tok-kw">while</span> (i &lt; count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1615">        <span class="tok-kw">try</span> map.put(i, i);</span>
<span class="line" id="L1616">        total += i;</span>
<span class="line" id="L1617">    }</span>
<span class="line" id="L1618"></span>
<span class="line" id="L1619">    <span class="tok-kw">var</span> sum: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1620">    <span class="tok-kw">var</span> it = map.iterator();</span>
<span class="line" id="L1621">    <span class="tok-kw">while</span> (it.next()) |kv| {</span>
<span class="line" id="L1622">        sum += kv.key_ptr.*;</span>
<span class="line" id="L1623">    }</span>
<span class="line" id="L1624">    <span class="tok-kw">try</span> expectEqual(total, sum);</span>
<span class="line" id="L1625"></span>
<span class="line" id="L1626">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1627">    sum = <span class="tok-number">0</span>;</span>
<span class="line" id="L1628">    <span class="tok-kw">while</span> (i &lt; count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1629">        <span class="tok-kw">try</span> expectEqual(i, map.get(i).?);</span>
<span class="line" id="L1630">        sum += map.get(i).?;</span>
<span class="line" id="L1631">    }</span>
<span class="line" id="L1632">    <span class="tok-kw">try</span> expectEqual(total, sum);</span>
<span class="line" id="L1633">}</span>
<span class="line" id="L1634"></span>
<span class="line" id="L1635"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map ensureTotalCapacity&quot;</span> {</span>
<span class="line" id="L1636">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1637">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1638"></span>
<span class="line" id="L1639">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">20</span>);</span>
<span class="line" id="L1640">    <span class="tok-kw">const</span> initial_capacity = map.capacity();</span>
<span class="line" id="L1641">    <span class="tok-kw">try</span> testing.expect(initial_capacity &gt;= <span class="tok-number">20</span>);</span>
<span class="line" id="L1642">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1643">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1644">        <span class="tok-kw">try</span> testing.expect(map.fetchPutAssumeCapacity(i, i + <span class="tok-number">10</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1645">    }</span>
<span class="line" id="L1646">    <span class="tok-comment">// shouldn't resize from putAssumeCapacity</span>
</span>
<span class="line" id="L1647">    <span class="tok-kw">try</span> testing.expect(initial_capacity == map.capacity());</span>
<span class="line" id="L1648">}</span>
<span class="line" id="L1649"></span>
<span class="line" id="L1650"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map ensureUnusedCapacity with tombstones&quot;</span> {</span>
<span class="line" id="L1651">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1652">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1653"></span>
<span class="line" id="L1654">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1655">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1656">        <span class="tok-kw">try</span> map.ensureUnusedCapacity(<span class="tok-number">1</span>);</span>
<span class="line" id="L1657">        map.putAssumeCapacity(i, i);</span>
<span class="line" id="L1658">        _ = map.remove(i);</span>
<span class="line" id="L1659">    }</span>
<span class="line" id="L1660">}</span>
<span class="line" id="L1661"></span>
<span class="line" id="L1662"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map clearRetainingCapacity&quot;</span> {</span>
<span class="line" id="L1663">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1664">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1665"></span>
<span class="line" id="L1666">    map.clearRetainingCapacity();</span>
<span class="line" id="L1667"></span>
<span class="line" id="L1668">    <span class="tok-kw">try</span> map.put(<span class="tok-number">1</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L1669">    <span class="tok-kw">try</span> expectEqual(map.get(<span class="tok-number">1</span>).?, <span class="tok-number">1</span>);</span>
<span class="line" id="L1670">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1671"></span>
<span class="line" id="L1672">    map.clearRetainingCapacity();</span>
<span class="line" id="L1673">    map.putAssumeCapacity(<span class="tok-number">1</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L1674">    <span class="tok-kw">try</span> expectEqual(map.get(<span class="tok-number">1</span>).?, <span class="tok-number">1</span>);</span>
<span class="line" id="L1675">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677">    <span class="tok-kw">const</span> cap = map.capacity();</span>
<span class="line" id="L1678">    <span class="tok-kw">try</span> expect(cap &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L1679"></span>
<span class="line" id="L1680">    map.clearRetainingCapacity();</span>
<span class="line" id="L1681">    map.clearRetainingCapacity();</span>
<span class="line" id="L1682">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">0</span>);</span>
<span class="line" id="L1683">    <span class="tok-kw">try</span> expectEqual(map.capacity(), cap);</span>
<span class="line" id="L1684">    <span class="tok-kw">try</span> expect(!map.contains(<span class="tok-number">1</span>));</span>
<span class="line" id="L1685">}</span>
<span class="line" id="L1686"></span>
<span class="line" id="L1687"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map grow&quot;</span> {</span>
<span class="line" id="L1688">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1689">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1690"></span>
<span class="line" id="L1691">    <span class="tok-kw">const</span> growTo = <span class="tok-number">12456</span>;</span>
<span class="line" id="L1692"></span>
<span class="line" id="L1693">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1694">    <span class="tok-kw">while</span> (i &lt; growTo) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1695">        <span class="tok-kw">try</span> map.put(i, i);</span>
<span class="line" id="L1696">    }</span>
<span class="line" id="L1697">    <span class="tok-kw">try</span> expectEqual(map.count(), growTo);</span>
<span class="line" id="L1698"></span>
<span class="line" id="L1699">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1700">    <span class="tok-kw">var</span> it = map.iterator();</span>
<span class="line" id="L1701">    <span class="tok-kw">while</span> (it.next()) |kv| {</span>
<span class="line" id="L1702">        <span class="tok-kw">try</span> expectEqual(kv.key_ptr.*, kv.value_ptr.*);</span>
<span class="line" id="L1703">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1704">    }</span>
<span class="line" id="L1705">    <span class="tok-kw">try</span> expectEqual(i, growTo);</span>
<span class="line" id="L1706"></span>
<span class="line" id="L1707">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1708">    <span class="tok-kw">while</span> (i &lt; growTo) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1709">        <span class="tok-kw">try</span> expectEqual(map.get(i).?, i);</span>
<span class="line" id="L1710">    }</span>
<span class="line" id="L1711">}</span>
<span class="line" id="L1712"></span>
<span class="line" id="L1713"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map clone&quot;</span> {</span>
<span class="line" id="L1714">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1715">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1716"></span>
<span class="line" id="L1717">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> map.clone();</span>
<span class="line" id="L1718">    <span class="tok-kw">defer</span> a.deinit();</span>
<span class="line" id="L1719"></span>
<span class="line" id="L1720">    <span class="tok-kw">try</span> expectEqual(a.count(), <span class="tok-number">0</span>);</span>
<span class="line" id="L1721"></span>
<span class="line" id="L1722">    <span class="tok-kw">try</span> a.put(<span class="tok-number">1</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L1723">    <span class="tok-kw">try</span> a.put(<span class="tok-number">2</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L1724">    <span class="tok-kw">try</span> a.put(<span class="tok-number">3</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L1725"></span>
<span class="line" id="L1726">    <span class="tok-kw">var</span> b = <span class="tok-kw">try</span> a.clone();</span>
<span class="line" id="L1727">    <span class="tok-kw">defer</span> b.deinit();</span>
<span class="line" id="L1728"></span>
<span class="line" id="L1729">    <span class="tok-kw">try</span> expectEqual(b.count(), <span class="tok-number">3</span>);</span>
<span class="line" id="L1730">    <span class="tok-kw">try</span> expectEqual(b.get(<span class="tok-number">1</span>).?, <span class="tok-number">1</span>);</span>
<span class="line" id="L1731">    <span class="tok-kw">try</span> expectEqual(b.get(<span class="tok-number">2</span>).?, <span class="tok-number">2</span>);</span>
<span class="line" id="L1732">    <span class="tok-kw">try</span> expectEqual(b.get(<span class="tok-number">3</span>).?, <span class="tok-number">3</span>);</span>
<span class="line" id="L1733">}</span>
<span class="line" id="L1734"></span>
<span class="line" id="L1735"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map ensureTotalCapacity with existing elements&quot;</span> {</span>
<span class="line" id="L1736">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1737">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1738"></span>
<span class="line" id="L1739">    <span class="tok-kw">try</span> map.put(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1740">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1741">    <span class="tok-kw">try</span> expectEqual(map.capacity(), <span class="tok-builtin">@TypeOf</span>(map).Unmanaged.minimal_capacity);</span>
<span class="line" id="L1742"></span>
<span class="line" id="L1743">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">65</span>);</span>
<span class="line" id="L1744">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">1</span>);</span>
<span class="line" id="L1745">    <span class="tok-kw">try</span> expectEqual(map.capacity(), <span class="tok-number">128</span>);</span>
<span class="line" id="L1746">}</span>
<span class="line" id="L1747"></span>
<span class="line" id="L1748"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map ensureTotalCapacity satisfies max load factor&quot;</span> {</span>
<span class="line" id="L1749">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1750">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">127</span>);</span>
<span class="line" id="L1753">    <span class="tok-kw">try</span> expectEqual(map.capacity(), <span class="tok-number">256</span>);</span>
<span class="line" id="L1754">}</span>
<span class="line" id="L1755"></span>
<span class="line" id="L1756"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map remove&quot;</span> {</span>
<span class="line" id="L1757">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1758">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1759"></span>
<span class="line" id="L1760">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1761">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1762">        <span class="tok-kw">try</span> map.put(i, i);</span>
<span class="line" id="L1763">    }</span>
<span class="line" id="L1764"></span>
<span class="line" id="L1765">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1766">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1767">        <span class="tok-kw">if</span> (i % <span class="tok-number">3</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1768">            _ = map.remove(i);</span>
<span class="line" id="L1769">        }</span>
<span class="line" id="L1770">    }</span>
<span class="line" id="L1771">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">10</span>);</span>
<span class="line" id="L1772">    <span class="tok-kw">var</span> it = map.iterator();</span>
<span class="line" id="L1773">    <span class="tok-kw">while</span> (it.next()) |kv| {</span>
<span class="line" id="L1774">        <span class="tok-kw">try</span> expectEqual(kv.key_ptr.*, kv.value_ptr.*);</span>
<span class="line" id="L1775">        <span class="tok-kw">try</span> expect(kv.key_ptr.* % <span class="tok-number">3</span> != <span class="tok-number">0</span>);</span>
<span class="line" id="L1776">    }</span>
<span class="line" id="L1777"></span>
<span class="line" id="L1778">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1779">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1780">        <span class="tok-kw">if</span> (i % <span class="tok-number">3</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1781">            <span class="tok-kw">try</span> expect(!map.contains(i));</span>
<span class="line" id="L1782">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1783">            <span class="tok-kw">try</span> expectEqual(map.get(i).?, i);</span>
<span class="line" id="L1784">        }</span>
<span class="line" id="L1785">    }</span>
<span class="line" id="L1786">}</span>
<span class="line" id="L1787"></span>
<span class="line" id="L1788"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map reverse removes&quot;</span> {</span>
<span class="line" id="L1789">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1790">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1791"></span>
<span class="line" id="L1792">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1793">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1794">        <span class="tok-kw">try</span> map.putNoClobber(i, i);</span>
<span class="line" id="L1795">    }</span>
<span class="line" id="L1796"></span>
<span class="line" id="L1797">    i = <span class="tok-number">16</span>;</span>
<span class="line" id="L1798">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1799">        _ = map.remove(i - <span class="tok-number">1</span>);</span>
<span class="line" id="L1800">        <span class="tok-kw">try</span> expect(!map.contains(i - <span class="tok-number">1</span>));</span>
<span class="line" id="L1801">        <span class="tok-kw">var</span> j: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1802">        <span class="tok-kw">while</span> (j &lt; i - <span class="tok-number">1</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1803">            <span class="tok-kw">try</span> expectEqual(map.get(j).?, j);</span>
<span class="line" id="L1804">        }</span>
<span class="line" id="L1805">    }</span>
<span class="line" id="L1806"></span>
<span class="line" id="L1807">    <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">0</span>);</span>
<span class="line" id="L1808">}</span>
<span class="line" id="L1809"></span>
<span class="line" id="L1810"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map multiple removes on same metadata&quot;</span> {</span>
<span class="line" id="L1811">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1812">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1813"></span>
<span class="line" id="L1814">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1815">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1816">        <span class="tok-kw">try</span> map.put(i, i);</span>
<span class="line" id="L1817">    }</span>
<span class="line" id="L1818"></span>
<span class="line" id="L1819">    _ = map.remove(<span class="tok-number">7</span>);</span>
<span class="line" id="L1820">    _ = map.remove(<span class="tok-number">15</span>);</span>
<span class="line" id="L1821">    _ = map.remove(<span class="tok-number">14</span>);</span>
<span class="line" id="L1822">    _ = map.remove(<span class="tok-number">13</span>);</span>
<span class="line" id="L1823">    <span class="tok-kw">try</span> expect(!map.contains(<span class="tok-number">7</span>));</span>
<span class="line" id="L1824">    <span class="tok-kw">try</span> expect(!map.contains(<span class="tok-number">15</span>));</span>
<span class="line" id="L1825">    <span class="tok-kw">try</span> expect(!map.contains(<span class="tok-number">14</span>));</span>
<span class="line" id="L1826">    <span class="tok-kw">try</span> expect(!map.contains(<span class="tok-number">13</span>));</span>
<span class="line" id="L1827"></span>
<span class="line" id="L1828">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1829">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">13</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1830">        <span class="tok-kw">if</span> (i == <span class="tok-number">7</span>) {</span>
<span class="line" id="L1831">            <span class="tok-kw">try</span> expect(!map.contains(i));</span>
<span class="line" id="L1832">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1833">            <span class="tok-kw">try</span> expectEqual(map.get(i).?, i);</span>
<span class="line" id="L1834">        }</span>
<span class="line" id="L1835">    }</span>
<span class="line" id="L1836"></span>
<span class="line" id="L1837">    <span class="tok-kw">try</span> map.put(<span class="tok-number">15</span>, <span class="tok-number">15</span>);</span>
<span class="line" id="L1838">    <span class="tok-kw">try</span> map.put(<span class="tok-number">13</span>, <span class="tok-number">13</span>);</span>
<span class="line" id="L1839">    <span class="tok-kw">try</span> map.put(<span class="tok-number">14</span>, <span class="tok-number">14</span>);</span>
<span class="line" id="L1840">    <span class="tok-kw">try</span> map.put(<span class="tok-number">7</span>, <span class="tok-number">7</span>);</span>
<span class="line" id="L1841">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1842">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1843">        <span class="tok-kw">try</span> expectEqual(map.get(i).?, i);</span>
<span class="line" id="L1844">    }</span>
<span class="line" id="L1845">}</span>
<span class="line" id="L1846"></span>
<span class="line" id="L1847"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map put and remove loop in random order&quot;</span> {</span>
<span class="line" id="L1848">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1849">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1850"></span>
<span class="line" id="L1851">    <span class="tok-kw">var</span> keys = std.ArrayList(<span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1852">    <span class="tok-kw">defer</span> keys.deinit();</span>
<span class="line" id="L1853"></span>
<span class="line" id="L1854">    <span class="tok-kw">const</span> size = <span class="tok-number">32</span>;</span>
<span class="line" id="L1855">    <span class="tok-kw">const</span> iterations = <span class="tok-number">100</span>;</span>
<span class="line" id="L1856"></span>
<span class="line" id="L1857">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1858">    <span class="tok-kw">while</span> (i &lt; size) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1859">        <span class="tok-kw">try</span> keys.append(i);</span>
<span class="line" id="L1860">    }</span>
<span class="line" id="L1861">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L1862">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L1863"></span>
<span class="line" id="L1864">    <span class="tok-kw">while</span> (i &lt; iterations) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1865">        random.shuffle(<span class="tok-type">u32</span>, keys.items);</span>
<span class="line" id="L1866"></span>
<span class="line" id="L1867">        <span class="tok-kw">for</span> (keys.items) |key| {</span>
<span class="line" id="L1868">            <span class="tok-kw">try</span> map.put(key, key);</span>
<span class="line" id="L1869">        }</span>
<span class="line" id="L1870">        <span class="tok-kw">try</span> expectEqual(map.count(), size);</span>
<span class="line" id="L1871"></span>
<span class="line" id="L1872">        <span class="tok-kw">for</span> (keys.items) |key| {</span>
<span class="line" id="L1873">            _ = map.remove(key);</span>
<span class="line" id="L1874">        }</span>
<span class="line" id="L1875">        <span class="tok-kw">try</span> expectEqual(map.count(), <span class="tok-number">0</span>);</span>
<span class="line" id="L1876">    }</span>
<span class="line" id="L1877">}</span>
<span class="line" id="L1878"></span>
<span class="line" id="L1879"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map remove one million elements in random order&quot;</span> {</span>
<span class="line" id="L1880">    <span class="tok-kw">const</span> Map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L1881">    <span class="tok-kw">const</span> n = <span class="tok-number">1000</span> * <span class="tok-number">1000</span>;</span>
<span class="line" id="L1882">    <span class="tok-kw">var</span> map = Map.init(std.heap.page_allocator);</span>
<span class="line" id="L1883">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1884"></span>
<span class="line" id="L1885">    <span class="tok-kw">var</span> keys = std.ArrayList(<span class="tok-type">u32</span>).init(std.heap.page_allocator);</span>
<span class="line" id="L1886">    <span class="tok-kw">defer</span> keys.deinit();</span>
<span class="line" id="L1887"></span>
<span class="line" id="L1888">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1889">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1890">        keys.append(i) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1891">    }</span>
<span class="line" id="L1892"></span>
<span class="line" id="L1893">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L1894">    <span class="tok-kw">const</span> random = prng.random();</span>
<span class="line" id="L1895">    random.shuffle(<span class="tok-type">u32</span>, keys.items);</span>
<span class="line" id="L1896"></span>
<span class="line" id="L1897">    <span class="tok-kw">for</span> (keys.items) |key| {</span>
<span class="line" id="L1898">        map.put(key, key) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1899">    }</span>
<span class="line" id="L1900"></span>
<span class="line" id="L1901">    random.shuffle(<span class="tok-type">u32</span>, keys.items);</span>
<span class="line" id="L1902">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1903">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1904">        <span class="tok-kw">const</span> key = keys.items[i];</span>
<span class="line" id="L1905">        _ = map.remove(key);</span>
<span class="line" id="L1906">    }</span>
<span class="line" id="L1907">}</span>
<span class="line" id="L1908"></span>
<span class="line" id="L1909"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map put&quot;</span> {</span>
<span class="line" id="L1910">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1911">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1912"></span>
<span class="line" id="L1913">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1914">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1915">        <span class="tok-kw">try</span> map.put(i, i);</span>
<span class="line" id="L1916">    }</span>
<span class="line" id="L1917"></span>
<span class="line" id="L1918">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1919">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1920">        <span class="tok-kw">try</span> expectEqual(map.get(i).?, i);</span>
<span class="line" id="L1921">    }</span>
<span class="line" id="L1922"></span>
<span class="line" id="L1923">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1924">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1925">        <span class="tok-kw">try</span> map.put(i, i * <span class="tok-number">16</span> + <span class="tok-number">1</span>);</span>
<span class="line" id="L1926">    }</span>
<span class="line" id="L1927"></span>
<span class="line" id="L1928">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1929">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1930">        <span class="tok-kw">try</span> expectEqual(map.get(i).?, i * <span class="tok-number">16</span> + <span class="tok-number">1</span>);</span>
<span class="line" id="L1931">    }</span>
<span class="line" id="L1932">}</span>
<span class="line" id="L1933"></span>
<span class="line" id="L1934"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map putAssumeCapacity&quot;</span> {</span>
<span class="line" id="L1935">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1936">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1937"></span>
<span class="line" id="L1938">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">20</span>);</span>
<span class="line" id="L1939">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1940">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1941">        map.putAssumeCapacityNoClobber(i, i);</span>
<span class="line" id="L1942">    }</span>
<span class="line" id="L1943"></span>
<span class="line" id="L1944">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1945">    <span class="tok-kw">var</span> sum = i;</span>
<span class="line" id="L1946">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1947">        sum += map.getPtr(i).?.*;</span>
<span class="line" id="L1948">    }</span>
<span class="line" id="L1949">    <span class="tok-kw">try</span> expectEqual(sum, <span class="tok-number">190</span>);</span>
<span class="line" id="L1950"></span>
<span class="line" id="L1951">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1952">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1953">        map.putAssumeCapacity(i, <span class="tok-number">1</span>);</span>
<span class="line" id="L1954">    }</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1957">    sum = i;</span>
<span class="line" id="L1958">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1959">        sum += map.get(i).?;</span>
<span class="line" id="L1960">    }</span>
<span class="line" id="L1961">    <span class="tok-kw">try</span> expectEqual(sum, <span class="tok-number">20</span>);</span>
<span class="line" id="L1962">}</span>
<span class="line" id="L1963"></span>
<span class="line" id="L1964"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map repeat putAssumeCapacity/remove&quot;</span> {</span>
<span class="line" id="L1965">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1966">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1967"></span>
<span class="line" id="L1968">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">20</span>);</span>
<span class="line" id="L1969">    <span class="tok-kw">const</span> limit = map.unmanaged.available;</span>
<span class="line" id="L1970"></span>
<span class="line" id="L1971">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1972">    <span class="tok-kw">while</span> (i &lt; limit) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1973">        map.putAssumeCapacityNoClobber(i, i);</span>
<span class="line" id="L1974">    }</span>
<span class="line" id="L1975"></span>
<span class="line" id="L1976">    <span class="tok-comment">// Repeatedly delete/insert an entry without resizing the map.</span>
</span>
<span class="line" id="L1977">    <span class="tok-comment">// Put to different keys so entries don't land in the just-freed slot.</span>
</span>
<span class="line" id="L1978">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L1979">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span> * limit) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1980">        <span class="tok-kw">try</span> testing.expect(map.remove(i));</span>
<span class="line" id="L1981">        <span class="tok-kw">if</span> (i % <span class="tok-number">2</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1982">            map.putAssumeCapacityNoClobber(limit + i, i);</span>
<span class="line" id="L1983">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1984">            map.putAssumeCapacity(limit + i, i);</span>
<span class="line" id="L1985">        }</span>
<span class="line" id="L1986">    }</span>
<span class="line" id="L1987"></span>
<span class="line" id="L1988">    i = <span class="tok-number">9</span> * limit;</span>
<span class="line" id="L1989">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span> * limit) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1990">        <span class="tok-kw">try</span> expectEqual(map.get(limit + i), i);</span>
<span class="line" id="L1991">    }</span>
<span class="line" id="L1992">    <span class="tok-kw">try</span> expectEqual(map.unmanaged.available, <span class="tok-number">0</span>);</span>
<span class="line" id="L1993">    <span class="tok-kw">try</span> expectEqual(map.unmanaged.count(), limit);</span>
<span class="line" id="L1994">}</span>
<span class="line" id="L1995"></span>
<span class="line" id="L1996"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map getOrPut&quot;</span> {</span>
<span class="line" id="L1997">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u32</span>, <span class="tok-type">u32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1998">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1999"></span>
<span class="line" id="L2000">    <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2001">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2002">        <span class="tok-kw">try</span> map.put(i * <span class="tok-number">2</span>, <span class="tok-number">2</span>);</span>
<span class="line" id="L2003">    }</span>
<span class="line" id="L2004"></span>
<span class="line" id="L2005">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2006">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2007">        _ = <span class="tok-kw">try</span> map.getOrPutValue(i, <span class="tok-number">1</span>);</span>
<span class="line" id="L2008">    }</span>
<span class="line" id="L2009"></span>
<span class="line" id="L2010">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2011">    <span class="tok-kw">var</span> sum = i;</span>
<span class="line" id="L2012">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2013">        sum += map.get(i).?;</span>
<span class="line" id="L2014">    }</span>
<span class="line" id="L2015"></span>
<span class="line" id="L2016">    <span class="tok-kw">try</span> expectEqual(sum, <span class="tok-number">30</span>);</span>
<span class="line" id="L2017">}</span>
<span class="line" id="L2018"></span>
<span class="line" id="L2019"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map basic hash map usage&quot;</span> {</span>
<span class="line" id="L2020">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2021">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2022"></span>
<span class="line" id="L2023">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">1</span>, <span class="tok-number">11</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2024">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">2</span>, <span class="tok-number">22</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2025">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">3</span>, <span class="tok-number">33</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2026">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">4</span>, <span class="tok-number">44</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2027"></span>
<span class="line" id="L2028">    <span class="tok-kw">try</span> map.putNoClobber(<span class="tok-number">5</span>, <span class="tok-number">55</span>);</span>
<span class="line" id="L2029">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">5</span>, <span class="tok-number">66</span>)).?.value == <span class="tok-number">55</span>);</span>
<span class="line" id="L2030">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">5</span>, <span class="tok-number">55</span>)).?.value == <span class="tok-number">66</span>);</span>
<span class="line" id="L2031"></span>
<span class="line" id="L2032">    <span class="tok-kw">const</span> gop1 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">5</span>);</span>
<span class="line" id="L2033">    <span class="tok-kw">try</span> testing.expect(gop1.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L2034">    <span class="tok-kw">try</span> testing.expect(gop1.value_ptr.* == <span class="tok-number">55</span>);</span>
<span class="line" id="L2035">    gop1.value_ptr.* = <span class="tok-number">77</span>;</span>
<span class="line" id="L2036">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">5</span>).?.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L2037"></span>
<span class="line" id="L2038">    <span class="tok-kw">const</span> gop2 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">99</span>);</span>
<span class="line" id="L2039">    <span class="tok-kw">try</span> testing.expect(gop2.found_existing == <span class="tok-null">false</span>);</span>
<span class="line" id="L2040">    gop2.value_ptr.* = <span class="tok-number">42</span>;</span>
<span class="line" id="L2041">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">99</span>).?.value_ptr.* == <span class="tok-number">42</span>);</span>
<span class="line" id="L2042"></span>
<span class="line" id="L2043">    <span class="tok-kw">const</span> gop3 = <span class="tok-kw">try</span> map.getOrPutValue(<span class="tok-number">5</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L2044">    <span class="tok-kw">try</span> testing.expect(gop3.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L2045"></span>
<span class="line" id="L2046">    <span class="tok-kw">const</span> gop4 = <span class="tok-kw">try</span> map.getOrPutValue(<span class="tok-number">100</span>, <span class="tok-number">41</span>);</span>
<span class="line" id="L2047">    <span class="tok-kw">try</span> testing.expect(gop4.value_ptr.* == <span class="tok-number">41</span>);</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049">    <span class="tok-kw">try</span> testing.expect(map.contains(<span class="tok-number">2</span>));</span>
<span class="line" id="L2050">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">2</span>).?.value_ptr.* == <span class="tok-number">22</span>);</span>
<span class="line" id="L2051">    <span class="tok-kw">try</span> testing.expect(map.get(<span class="tok-number">2</span>).? == <span class="tok-number">22</span>);</span>
<span class="line" id="L2052"></span>
<span class="line" id="L2053">    <span class="tok-kw">const</span> rmv1 = map.fetchRemove(<span class="tok-number">2</span>);</span>
<span class="line" id="L2054">    <span class="tok-kw">try</span> testing.expect(rmv1.?.key == <span class="tok-number">2</span>);</span>
<span class="line" id="L2055">    <span class="tok-kw">try</span> testing.expect(rmv1.?.value == <span class="tok-number">22</span>);</span>
<span class="line" id="L2056">    <span class="tok-kw">try</span> testing.expect(map.fetchRemove(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2057">    <span class="tok-kw">try</span> testing.expect(map.remove(<span class="tok-number">2</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L2058">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2059">    <span class="tok-kw">try</span> testing.expect(map.get(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2060"></span>
<span class="line" id="L2061">    <span class="tok-kw">try</span> testing.expect(map.remove(<span class="tok-number">3</span>) == <span class="tok-null">true</span>);</span>
<span class="line" id="L2062">}</span>
<span class="line" id="L2063"></span>
<span class="line" id="L2064"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map clone&quot;</span> {</span>
<span class="line" id="L2065">    <span class="tok-kw">var</span> original = AutoHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2066">    <span class="tok-kw">defer</span> original.deinit();</span>
<span class="line" id="L2067"></span>
<span class="line" id="L2068">    <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2069">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2070">        <span class="tok-kw">try</span> original.putNoClobber(i, i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2071">    }</span>
<span class="line" id="L2072"></span>
<span class="line" id="L2073">    <span class="tok-kw">var</span> copy = <span class="tok-kw">try</span> original.clone();</span>
<span class="line" id="L2074">    <span class="tok-kw">defer</span> copy.deinit();</span>
<span class="line" id="L2075"></span>
<span class="line" id="L2076">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2077">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2078">        <span class="tok-kw">try</span> testing.expect(copy.get(i).? == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2079">    }</span>
<span class="line" id="L2080">}</span>
<span class="line" id="L2081"></span>
<span class="line" id="L2082"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map getOrPutAdapted&quot;</span> {</span>
<span class="line" id="L2083">    <span class="tok-kw">const</span> AdaptedContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2084">        <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), adapted_key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, test_key: <span class="tok-type">u64</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2085">            _ = self;</span>
<span class="line" id="L2086">            <span class="tok-kw">return</span> std.fmt.parseInt(<span class="tok-type">u64</span>, adapted_key, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span> == test_key;</span>
<span class="line" id="L2087">        }</span>
<span class="line" id="L2088">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), adapted_key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L2089">            _ = self;</span>
<span class="line" id="L2090">            <span class="tok-kw">const</span> key = std.fmt.parseInt(<span class="tok-type">u64</span>, adapted_key, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2091">            <span class="tok-kw">return</span> (AutoContext(<span class="tok-type">u64</span>){}).hash(key);</span>
<span class="line" id="L2092">        }</span>
<span class="line" id="L2093">    };</span>
<span class="line" id="L2094">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u64</span>, <span class="tok-type">u64</span>).init(testing.allocator);</span>
<span class="line" id="L2095">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2096"></span>
<span class="line" id="L2097">    <span class="tok-kw">const</span> keys = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L2098">        <span class="tok-str">&quot;1231&quot;</span>,</span>
<span class="line" id="L2099">        <span class="tok-str">&quot;4564&quot;</span>,</span>
<span class="line" id="L2100">        <span class="tok-str">&quot;7894&quot;</span>,</span>
<span class="line" id="L2101">        <span class="tok-str">&quot;1132&quot;</span>,</span>
<span class="line" id="L2102">        <span class="tok-str">&quot;65235&quot;</span>,</span>
<span class="line" id="L2103">        <span class="tok-str">&quot;95462&quot;</span>,</span>
<span class="line" id="L2104">        <span class="tok-str">&quot;0112305&quot;</span>,</span>
<span class="line" id="L2105">        <span class="tok-str">&quot;00658&quot;</span>,</span>
<span class="line" id="L2106">        <span class="tok-str">&quot;0&quot;</span>,</span>
<span class="line" id="L2107">        <span class="tok-str">&quot;2&quot;</span>,</span>
<span class="line" id="L2108">    };</span>
<span class="line" id="L2109"></span>
<span class="line" id="L2110">    <span class="tok-kw">var</span> real_keys: [keys.len]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2111"></span>
<span class="line" id="L2112">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (keys) |key_str, i| {</span>
<span class="line" id="L2113">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> map.getOrPutAdapted(key_str, AdaptedContext{});</span>
<span class="line" id="L2114">        <span class="tok-kw">try</span> testing.expect(!result.found_existing);</span>
<span class="line" id="L2115">        real_keys[i] = std.fmt.parseInt(<span class="tok-type">u64</span>, key_str, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2116">        result.key_ptr.* = real_keys[i];</span>
<span class="line" id="L2117">        result.value_ptr.* = i * <span class="tok-number">2</span>;</span>
<span class="line" id="L2118">    }</span>
<span class="line" id="L2119"></span>
<span class="line" id="L2120">    <span class="tok-kw">try</span> testing.expectEqual(map.count(), keys.len);</span>
<span class="line" id="L2121"></span>
<span class="line" id="L2122">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (keys) |key_str, i| {</span>
<span class="line" id="L2123">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> map.getOrPutAdapted(key_str, AdaptedContext{});</span>
<span class="line" id="L2124">        <span class="tok-kw">try</span> testing.expect(result.found_existing);</span>
<span class="line" id="L2125">        <span class="tok-kw">try</span> testing.expectEqual(real_keys[i], result.key_ptr.*);</span>
<span class="line" id="L2126">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, i) * <span class="tok-number">2</span>, result.value_ptr.*);</span>
<span class="line" id="L2127">        <span class="tok-kw">try</span> testing.expectEqual(real_keys[i], map.getKeyAdapted(key_str, AdaptedContext{}).?);</span>
<span class="line" id="L2128">    }</span>
<span class="line" id="L2129">}</span>
<span class="line" id="L2130"></span>
<span class="line" id="L2131"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map ensureUnusedCapacity&quot;</span> {</span>
<span class="line" id="L2132">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u64</span>, <span class="tok-type">u64</span>).init(testing.allocator);</span>
<span class="line" id="L2133">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2134"></span>
<span class="line" id="L2135">    <span class="tok-kw">try</span> map.ensureUnusedCapacity(<span class="tok-number">32</span>);</span>
<span class="line" id="L2136">    <span class="tok-kw">const</span> capacity = map.capacity();</span>
<span class="line" id="L2137">    <span class="tok-kw">try</span> map.ensureUnusedCapacity(<span class="tok-number">32</span>);</span>
<span class="line" id="L2138"></span>
<span class="line" id="L2139">    <span class="tok-comment">// Repeated ensureUnusedCapacity() calls with no insertions between</span>
</span>
<span class="line" id="L2140">    <span class="tok-comment">// should not change the capacity.</span>
</span>
<span class="line" id="L2141">    <span class="tok-kw">try</span> testing.expectEqual(capacity, map.capacity());</span>
<span class="line" id="L2142">}</span>
<span class="line" id="L2143"></span>
<span class="line" id="L2144"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map removeByPtr&quot;</span> {</span>
<span class="line" id="L2145">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">i32</span>, <span class="tok-type">u64</span>).init(testing.allocator);</span>
<span class="line" id="L2146">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2147"></span>
<span class="line" id="L2148">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2149"></span>
<span class="line" id="L2150">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2151">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2152">        <span class="tok-kw">try</span> map.put(i, <span class="tok-number">0</span>);</span>
<span class="line" id="L2153">    }</span>
<span class="line" id="L2154"></span>
<span class="line" id="L2155">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">10</span>);</span>
<span class="line" id="L2156"></span>
<span class="line" id="L2157">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2158">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2159">        <span class="tok-kw">const</span> keyPtr = map.getKeyPtr(i);</span>
<span class="line" id="L2160">        <span class="tok-kw">try</span> testing.expect(keyPtr != <span class="tok-null">null</span>);</span>
<span class="line" id="L2161"></span>
<span class="line" id="L2162">        <span class="tok-kw">if</span> (keyPtr) |ptr| {</span>
<span class="line" id="L2163">            map.removeByPtr(ptr);</span>
<span class="line" id="L2164">        }</span>
<span class="line" id="L2165">    }</span>
<span class="line" id="L2166"></span>
<span class="line" id="L2167">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L2168">}</span>
<span class="line" id="L2169"></span>
<span class="line" id="L2170"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.hash_map removeByPtr 0 sized key&quot;</span> {</span>
<span class="line" id="L2171">    <span class="tok-kw">var</span> map = AutoHashMap(<span class="tok-type">u0</span>, <span class="tok-type">u64</span>).init(testing.allocator);</span>
<span class="line" id="L2172">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2173"></span>
<span class="line" id="L2174">    <span class="tok-kw">try</span> map.put(<span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2175"></span>
<span class="line" id="L2176">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">1</span>);</span>
<span class="line" id="L2177"></span>
<span class="line" id="L2178">    <span class="tok-kw">const</span> keyPtr = map.getKeyPtr(<span class="tok-number">0</span>);</span>
<span class="line" id="L2179">    <span class="tok-kw">try</span> testing.expect(keyPtr != <span class="tok-null">null</span>);</span>
<span class="line" id="L2180"></span>
<span class="line" id="L2181">    <span class="tok-kw">if</span> (keyPtr) |ptr| {</span>
<span class="line" id="L2182">        map.removeByPtr(ptr);</span>
<span class="line" id="L2183">    }</span>
<span class="line" id="L2184"></span>
<span class="line" id="L2185">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L2186">}</span>
<span class="line" id="L2187"></span>
</code></pre></body>
</html>