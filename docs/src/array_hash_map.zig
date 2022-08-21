<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>array_hash_map.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> assert = debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> trait = meta.trait;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> autoHash = std.hash.autoHash;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Wyhash = std.hash.Wyhash;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> hash_map = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-comment">/// An ArrayHashMap with default hash and equal functions.</span></span>
<span class="line" id="L15"><span class="tok-comment">/// See AutoContext for a description of the hash and equal implementations.</span></span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoArrayHashMap</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">return</span> ArrayHashMap(K, V, AutoContext(K), !autoEqlIsCheap(K));</span>
<span class="line" id="L18">}</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// An ArrayHashMapUnmanaged with default hash and equal functions.</span></span>
<span class="line" id="L21"><span class="tok-comment">/// See AutoContext for a description of the hash and equal implementations.</span></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoArrayHashMapUnmanaged</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L23">    <span class="tok-kw">return</span> ArrayHashMapUnmanaged(K, V, AutoContext(K), !autoEqlIsCheap(K));</span>
<span class="line" id="L24">}</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// Builtin hashmap for strings as keys.</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StringArrayHashMap</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L28">    <span class="tok-kw">return</span> ArrayHashMap([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, V, StringContext, <span class="tok-null">true</span>);</span>
<span class="line" id="L29">}</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">StringArrayHashMapUnmanaged</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L32">    <span class="tok-kw">return</span> ArrayHashMapUnmanaged([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, V, StringContext, <span class="tok-null">true</span>);</span>
<span class="line" id="L33">}</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L37">        _ = self;</span>
<span class="line" id="L38">        <span class="tok-kw">return</span> hashString(s);</span>
<span class="line" id="L39">    }</span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b_index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L41">        _ = self;</span>
<span class="line" id="L42">        _ = b_index;</span>
<span class="line" id="L43">        <span class="tok-kw">return</span> eqlString(a, b);</span>
<span class="line" id="L44">    }</span>
<span class="line" id="L45">};</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqlString</span>(a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L48">    <span class="tok-kw">return</span> mem.eql(<span class="tok-type">u8</span>, a, b);</span>
<span class="line" id="L49">}</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashString</span>(s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L52">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, std.hash.Wyhash.hash(<span class="tok-number">0</span>, s));</span>
<span class="line" id="L53">}</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-comment">/// Insertion order is preserved.</span></span>
<span class="line" id="L56"><span class="tok-comment">/// Deletions perform a &quot;swap removal&quot; on the entries list.</span></span>
<span class="line" id="L57"><span class="tok-comment">/// Modifying the hash map while iterating is allowed, however one must understand</span></span>
<span class="line" id="L58"><span class="tok-comment">/// the (well defined) behavior when mixing insertions and deletions with iteration.</span></span>
<span class="line" id="L59"><span class="tok-comment">/// For a hash map that can be initialized directly that does not store an Allocator</span></span>
<span class="line" id="L60"><span class="tok-comment">/// field, see `ArrayHashMapUnmanaged`.</span></span>
<span class="line" id="L61"><span class="tok-comment">/// When `store_hash` is `false`, this data structure is biased towards cheap `eql`</span></span>
<span class="line" id="L62"><span class="tok-comment">/// functions. It does not store each item's hash in the table. Setting `store_hash`</span></span>
<span class="line" id="L63"><span class="tok-comment">/// to `true` incurs slightly more memory cost by storing each key's hash in the table</span></span>
<span class="line" id="L64"><span class="tok-comment">/// but only has to call `eql` for hash collisions.</span></span>
<span class="line" id="L65"><span class="tok-comment">/// If typical operations (except iteration over entries) need to be faster, prefer</span></span>
<span class="line" id="L66"><span class="tok-comment">/// the alternative `std.HashMap`.</span></span>
<span class="line" id="L67"><span class="tok-comment">/// Context must be a struct type with two member functions:</span></span>
<span class="line" id="L68"><span class="tok-comment">///   hash(self, K) u32</span></span>
<span class="line" id="L69"><span class="tok-comment">///   eql(self, K, K, usize) bool</span></span>
<span class="line" id="L70"><span class="tok-comment">/// Adapted variants of many functions are provided.  These variants</span></span>
<span class="line" id="L71"><span class="tok-comment">/// take a pseudo key instead of a key.  Their context must have the functions:</span></span>
<span class="line" id="L72"><span class="tok-comment">///   hash(self, PseudoKey) u32</span></span>
<span class="line" id="L73"><span class="tok-comment">///   eql(self, PseudoKey, K, usize) bool</span></span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayHashMap</span>(</span>
<span class="line" id="L75">    <span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>,</span>
<span class="line" id="L76">    <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>,</span>
<span class="line" id="L77">    <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>,</span>
<span class="line" id="L78">    <span class="tok-kw">comptime</span> store_hash: <span class="tok-type">bool</span>,</span>
<span class="line" id="L79">) <span class="tok-type">type</span> {</span>
<span class="line" id="L80">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">        unmanaged: Unmanaged,</span>
<span class="line" id="L82">        allocator: Allocator,</span>
<span class="line" id="L83">        ctx: Context,</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-comment">/// The ArrayHashMapUnmanaged type using the same settings as this managed map.</span></span>
<span class="line" id="L86">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Unmanaged = ArrayHashMapUnmanaged(K, V, Context, store_hash);</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-comment">/// Pointers to a key and value in the backing store of this map.</span></span>
<span class="line" id="L89">        <span class="tok-comment">/// Modifying the key is allowed only if it does not change the hash.</span></span>
<span class="line" id="L90">        <span class="tok-comment">/// Modifying the value is allowed.</span></span>
<span class="line" id="L91">        <span class="tok-comment">/// Entry pointers become invalid whenever this ArrayHashMap is modified,</span></span>
<span class="line" id="L92">        <span class="tok-comment">/// unless `ensureTotalCapacity`/`ensureUnusedCapacity` was previously used.</span></span>
<span class="line" id="L93">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = Unmanaged.Entry;</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-comment">/// A KV pair which has been copied out of the backing store</span></span>
<span class="line" id="L96">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KV = Unmanaged.KV;</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">        <span class="tok-comment">/// The Data type used for the MultiArrayList backing this map</span></span>
<span class="line" id="L99">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Data = Unmanaged.Data;</span>
<span class="line" id="L100">        <span class="tok-comment">/// The MultiArrayList type backing this map</span></span>
<span class="line" id="L101">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DataList = Unmanaged.DataList;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-comment">/// The stored hash type, either u32 or void.</span></span>
<span class="line" id="L104">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Hash = Unmanaged.Hash;</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        <span class="tok-comment">/// getOrPut variants return this structure, with pointers</span></span>
<span class="line" id="L107">        <span class="tok-comment">/// to the backing store and a flag to indicate whether an</span></span>
<span class="line" id="L108">        <span class="tok-comment">/// existing entry was found.</span></span>
<span class="line" id="L109">        <span class="tok-comment">/// Modifying the key is allowed only if it does not change the hash.</span></span>
<span class="line" id="L110">        <span class="tok-comment">/// Modifying the value is allowed.</span></span>
<span class="line" id="L111">        <span class="tok-comment">/// Entry pointers become invalid whenever this ArrayHashMap is modified,</span></span>
<span class="line" id="L112">        <span class="tok-comment">/// unless `ensureTotalCapacity`/`ensureUnusedCapacity` was previously used.</span></span>
<span class="line" id="L113">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetOrPutResult = Unmanaged.GetOrPutResult;</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">        <span class="tok-comment">/// An Iterator over Entry pointers.</span></span>
<span class="line" id="L116">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = Unmanaged.Iterator;</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">        <span class="tok-comment">/// Create an ArrayHashMap instance which will use a specified allocator.</span></span>
<span class="line" id="L121">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) Self {</span>
<span class="line" id="L122">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L123">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call initContext instead.&quot;</span>);</span>
<span class="line" id="L124">            <span class="tok-kw">return</span> initContext(allocator, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L125">        }</span>
<span class="line" id="L126">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(allocator: Allocator, ctx: Context) Self {</span>
<span class="line" id="L127">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L128">                .unmanaged = .{},</span>
<span class="line" id="L129">                .allocator = allocator,</span>
<span class="line" id="L130">                .ctx = ctx,</span>
<span class="line" id="L131">            };</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        <span class="tok-comment">/// Frees the backing allocation and leaves the map in an undefined state.</span></span>
<span class="line" id="L135">        <span class="tok-comment">/// Note that this does not free keys or values.  You must take care of that</span></span>
<span class="line" id="L136">        <span class="tok-comment">/// before calling this function, if it is needed.</span></span>
<span class="line" id="L137">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L138">            self.unmanaged.deinit(self.allocator);</span>
<span class="line" id="L139">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L140">        }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">        <span class="tok-comment">/// Clears the map but retains the backing allocation for future use.</span></span>
<span class="line" id="L143">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L144">            <span class="tok-kw">return</span> self.unmanaged.clearRetainingCapacity();</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">        <span class="tok-comment">/// Clears the map and releases the backing allocation</span></span>
<span class="line" id="L148">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L149">            <span class="tok-kw">return</span> self.unmanaged.clearAndFree(self.allocator);</span>
<span class="line" id="L150">        }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">        <span class="tok-comment">/// Returns the number of KV pairs stored in this map.</span></span>
<span class="line" id="L153">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L154">            <span class="tok-kw">return</span> self.unmanaged.count();</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">        <span class="tok-comment">/// Returns the backing array of keys in this map.</span></span>
<span class="line" id="L158">        <span class="tok-comment">/// Modifying the map may invalidate this array.</span></span>
<span class="line" id="L159">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keys</span>(self: Self) []K {</span>
<span class="line" id="L160">            <span class="tok-kw">return</span> self.unmanaged.keys();</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162">        <span class="tok-comment">/// Returns the backing array of values in this map.</span></span>
<span class="line" id="L163">        <span class="tok-comment">/// Modifying the map may invalidate this array.</span></span>
<span class="line" id="L164">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">values</span>(self: Self) []V {</span>
<span class="line" id="L165">            <span class="tok-kw">return</span> self.unmanaged.values();</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-comment">/// Returns an iterator over the pairs in this map.</span></span>
<span class="line" id="L169">        <span class="tok-comment">/// Modifying the map may invalidate this iterator.</span></span>
<span class="line" id="L170">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> Self) Iterator {</span>
<span class="line" id="L171">            <span class="tok-kw">return</span> self.unmanaged.iterator();</span>
<span class="line" id="L172">        }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-comment">/// If key exists this function cannot fail.</span></span>
<span class="line" id="L175">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L176">        <span class="tok-comment">/// `Entry` pointer points to it, and found_existing is true.</span></span>
<span class="line" id="L177">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L178">        <span class="tok-comment">/// the `Entry` pointer points to it. Caller should then initialize</span></span>
<span class="line" id="L179">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L180">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPut</span>(self: *Self, key: K) !GetOrPutResult {</span>
<span class="line" id="L181">            <span class="tok-kw">return</span> self.unmanaged.getOrPutContext(self.allocator, key, self.ctx);</span>
<span class="line" id="L182">        }</span>
<span class="line" id="L183">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) !GetOrPutResult {</span>
<span class="line" id="L184">            <span class="tok-kw">return</span> self.unmanaged.getOrPutContextAdapted(self.allocator, key, ctx, self.ctx);</span>
<span class="line" id="L185">        }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L188">        <span class="tok-comment">/// `Entry` pointer points to it, and found_existing is true.</span></span>
<span class="line" id="L189">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L190">        <span class="tok-comment">/// the `Entry` pointer points to it. Caller should then initialize</span></span>
<span class="line" id="L191">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L192">        <span class="tok-comment">/// If a new entry needs to be stored, this function asserts there</span></span>
<span class="line" id="L193">        <span class="tok-comment">/// is enough capacity to store it.</span></span>
<span class="line" id="L194">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacity</span>(self: *Self, key: K) GetOrPutResult {</span>
<span class="line" id="L195">            <span class="tok-kw">return</span> self.unmanaged.getOrPutAssumeCapacityContext(key, self.ctx);</span>
<span class="line" id="L196">        }</span>
<span class="line" id="L197">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) GetOrPutResult {</span>
<span class="line" id="L198">            <span class="tok-kw">return</span> self.unmanaged.getOrPutAssumeCapacityAdapted(key, ctx);</span>
<span class="line" id="L199">        }</span>
<span class="line" id="L200">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValue</span>(self: *Self, key: K, value: V) !GetOrPutResult {</span>
<span class="line" id="L201">            <span class="tok-kw">return</span> self.unmanaged.getOrPutValueContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L202">        }</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until the</span></span>
<span class="line" id="L207">        <span class="tok-comment">/// `expected_count` will not cause an allocation, and therefore cannot fail.</span></span>
<span class="line" id="L208">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L209">            <span class="tok-kw">return</span> self.unmanaged.ensureTotalCapacityContext(self.allocator, new_capacity, self.ctx);</span>
<span class="line" id="L210">        }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until</span></span>
<span class="line" id="L213">        <span class="tok-comment">/// `additional_count` **more** items will not cause an allocation, and</span></span>
<span class="line" id="L214">        <span class="tok-comment">/// therefore cannot fail.</span></span>
<span class="line" id="L215">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(self: *Self, additional_count: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L216">            <span class="tok-kw">return</span> self.unmanaged.ensureUnusedCapacityContext(self.allocator, additional_count, self.ctx);</span>
<span class="line" id="L217">        }</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-comment">/// Returns the number of total elements which may be present before it is</span></span>
<span class="line" id="L220">        <span class="tok-comment">/// no longer guaranteed that no allocations will be performed.</span></span>
<span class="line" id="L221">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: *Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L222">            <span class="tok-kw">return</span> self.unmanaged.capacity();</span>
<span class="line" id="L223">        }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L226">        <span class="tok-comment">/// existing data, see `getOrPut`.</span></span>
<span class="line" id="L227">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, key: K, value: V) !<span class="tok-type">void</span> {</span>
<span class="line" id="L228">            <span class="tok-kw">return</span> self.unmanaged.putContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L229">        }</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">        <span class="tok-comment">/// Inserts a key-value pair into the hash map, asserting that no previous</span></span>
<span class="line" id="L232">        <span class="tok-comment">/// entry with the same key is already present</span></span>
<span class="line" id="L233">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobber</span>(self: *Self, key: K, value: V) !<span class="tok-type">void</span> {</span>
<span class="line" id="L234">            <span class="tok-kw">return</span> self.unmanaged.putNoClobberContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L235">        }</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L238">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L239">        <span class="tok-comment">/// existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L240">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacity</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L241">            <span class="tok-kw">return</span> self.unmanaged.putAssumeCapacityContext(key, value, self.ctx);</span>
<span class="line" id="L242">        }</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L245">        <span class="tok-comment">/// Asserts that it does not clobber any existing data.</span></span>
<span class="line" id="L246">        <span class="tok-comment">/// To detect if a put would clobber existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L247">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobber</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L248">            <span class="tok-kw">return</span> self.unmanaged.putAssumeCapacityNoClobberContext(key, value, self.ctx);</span>
<span class="line" id="L249">        }</span>
<span class="line" id="L250"></span>
<span class="line" id="L251">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L252">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPut</span>(self: *Self, key: K, value: V) !?KV {</span>
<span class="line" id="L253">            <span class="tok-kw">return</span> self.unmanaged.fetchPutContext(self.allocator, key, value, self.ctx);</span>
<span class="line" id="L254">        }</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L257">        <span class="tok-comment">/// If insertion happuns, asserts there is enough capacity without allocating.</span></span>
<span class="line" id="L258">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacity</span>(self: *Self, key: K, value: V) ?KV {</span>
<span class="line" id="L259">            <span class="tok-kw">return</span> self.unmanaged.fetchPutAssumeCapacityContext(key, value, self.ctx);</span>
<span class="line" id="L260">        }</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">        <span class="tok-comment">/// Finds pointers to the key and value storage associated with a key.</span></span>
<span class="line" id="L263">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntry</span>(self: Self, key: K) ?Entry {</span>
<span class="line" id="L264">            <span class="tok-kw">return</span> self.unmanaged.getEntryContext(key, self.ctx);</span>
<span class="line" id="L265">        }</span>
<span class="line" id="L266">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?Entry {</span>
<span class="line" id="L267">            <span class="tok-kw">return</span> self.unmanaged.getEntryAdapted(key, ctx);</span>
<span class="line" id="L268">        }</span>
<span class="line" id="L269"></span>
<span class="line" id="L270">        <span class="tok-comment">/// Finds the index in the `entries` array where a key is stored</span></span>
<span class="line" id="L271">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndex</span>(self: Self, key: K) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L272">            <span class="tok-kw">return</span> self.unmanaged.getIndexContext(key, self.ctx);</span>
<span class="line" id="L273">        }</span>
<span class="line" id="L274">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndexAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L275">            <span class="tok-kw">return</span> self.unmanaged.getIndexAdapted(key, ctx);</span>
<span class="line" id="L276">        }</span>
<span class="line" id="L277"></span>
<span class="line" id="L278">        <span class="tok-comment">/// Find the value associated with a key</span></span>
<span class="line" id="L279">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: K) ?V {</span>
<span class="line" id="L280">            <span class="tok-kw">return</span> self.unmanaged.getContext(key, self.ctx);</span>
<span class="line" id="L281">        }</span>
<span class="line" id="L282">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?V {</span>
<span class="line" id="L283">            <span class="tok-kw">return</span> self.unmanaged.getAdapted(key, ctx);</span>
<span class="line" id="L284">        }</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">        <span class="tok-comment">/// Find a pointer to the value associated with a key</span></span>
<span class="line" id="L287">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: Self, key: K) ?*V {</span>
<span class="line" id="L288">            <span class="tok-kw">return</span> self.unmanaged.getPtrContext(key, self.ctx);</span>
<span class="line" id="L289">        }</span>
<span class="line" id="L290">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*V {</span>
<span class="line" id="L291">            <span class="tok-kw">return</span> self.unmanaged.getPtrAdapted(key, ctx);</span>
<span class="line" id="L292">        }</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">        <span class="tok-comment">/// Find the actual key associated with an adapted key</span></span>
<span class="line" id="L295">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKey</span>(self: Self, key: K) ?K {</span>
<span class="line" id="L296">            <span class="tok-kw">return</span> self.unmanaged.getKeyContext(key, self.ctx);</span>
<span class="line" id="L297">        }</span>
<span class="line" id="L298">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?K {</span>
<span class="line" id="L299">            <span class="tok-kw">return</span> self.unmanaged.getKeyAdapted(key, ctx);</span>
<span class="line" id="L300">        }</span>
<span class="line" id="L301"></span>
<span class="line" id="L302">        <span class="tok-comment">/// Find a pointer to the actual key associated with an adapted key</span></span>
<span class="line" id="L303">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtr</span>(self: Self, key: K) ?*K {</span>
<span class="line" id="L304">            <span class="tok-kw">return</span> self.unmanaged.getKeyPtrContext(key, self.ctx);</span>
<span class="line" id="L305">        }</span>
<span class="line" id="L306">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*K {</span>
<span class="line" id="L307">            <span class="tok-kw">return</span> self.unmanaged.getKeyPtrAdapted(key, ctx);</span>
<span class="line" id="L308">        }</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">        <span class="tok-comment">/// Check whether a key is stored in the map</span></span>
<span class="line" id="L311">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L312">            <span class="tok-kw">return</span> self.unmanaged.containsContext(key, self.ctx);</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L315">            <span class="tok-kw">return</span> self.unmanaged.containsAdapted(key, ctx);</span>
<span class="line" id="L316">        }</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L319">        <span class="tok-comment">/// the hash map, and then returned from this function. The entry is</span></span>
<span class="line" id="L320">        <span class="tok-comment">/// removed from the underlying array by swapping it with the last</span></span>
<span class="line" id="L321">        <span class="tok-comment">/// element.</span></span>
<span class="line" id="L322">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L323">            <span class="tok-kw">return</span> self.unmanaged.fetchSwapRemoveContext(key, self.ctx);</span>
<span class="line" id="L324">        }</span>
<span class="line" id="L325">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L326">            <span class="tok-kw">return</span> self.unmanaged.fetchSwapRemoveContextAdapted(key, ctx, self.ctx);</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L330">        <span class="tok-comment">/// the hash map, and then returned from this function. The entry is</span></span>
<span class="line" id="L331">        <span class="tok-comment">/// removed from the underlying array by shifting all elements forward</span></span>
<span class="line" id="L332">        <span class="tok-comment">/// thereby maintaining the current ordering.</span></span>
<span class="line" id="L333">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L334">            <span class="tok-kw">return</span> self.unmanaged.fetchOrderedRemoveContext(key, self.ctx);</span>
<span class="line" id="L335">        }</span>
<span class="line" id="L336">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L337">            <span class="tok-kw">return</span> self.unmanaged.fetchOrderedRemoveContextAdapted(key, ctx, self.ctx);</span>
<span class="line" id="L338">        }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L341">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L342">        <span class="tok-comment">/// by swapping it with the last element.  Returns true if an entry</span></span>
<span class="line" id="L343">        <span class="tok-comment">/// was removed, false otherwise.</span></span>
<span class="line" id="L344">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L345">            <span class="tok-kw">return</span> self.unmanaged.swapRemoveContext(key, self.ctx);</span>
<span class="line" id="L346">        }</span>
<span class="line" id="L347">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L348">            <span class="tok-kw">return</span> self.unmanaged.swapRemoveContextAdapted(key, ctx, self.ctx);</span>
<span class="line" id="L349">        }</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L352">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L353">        <span class="tok-comment">/// by shifting all elements forward, thereby maintaining the</span></span>
<span class="line" id="L354">        <span class="tok-comment">/// current ordering.  Returns true if an entry was removed, false otherwise.</span></span>
<span class="line" id="L355">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L356">            <span class="tok-kw">return</span> self.unmanaged.orderedRemoveContext(key, self.ctx);</span>
<span class="line" id="L357">        }</span>
<span class="line" id="L358">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L359">            <span class="tok-kw">return</span> self.unmanaged.orderedRemoveContextAdapted(key, ctx, self.ctx);</span>
<span class="line" id="L360">        }</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">        <span class="tok-comment">/// Deletes the item at the specified index in `entries` from</span></span>
<span class="line" id="L363">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L364">        <span class="tok-comment">/// by swapping it with the last element.</span></span>
<span class="line" id="L365">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveAt</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L366">            self.unmanaged.swapRemoveAtContext(index, self.ctx);</span>
<span class="line" id="L367">        }</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">        <span class="tok-comment">/// Deletes the item at the specified index in `entries` from</span></span>
<span class="line" id="L370">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L371">        <span class="tok-comment">/// by shifting all elements forward, thereby maintaining the</span></span>
<span class="line" id="L372">        <span class="tok-comment">/// current ordering.</span></span>
<span class="line" id="L373">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveAt</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L374">            self.unmanaged.orderedRemoveAtContext(index, self.ctx);</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">        <span class="tok-comment">/// Create a copy of the hash map which can be modified separately.</span></span>
<span class="line" id="L378">        <span class="tok-comment">/// The copy uses the same context and allocator as this instance.</span></span>
<span class="line" id="L379">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: Self) !Self {</span>
<span class="line" id="L380">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(self.allocator, self.ctx);</span>
<span class="line" id="L381">            <span class="tok-kw">return</span> other.promoteContext(self.allocator, self.ctx);</span>
<span class="line" id="L382">        }</span>
<span class="line" id="L383">        <span class="tok-comment">/// Create a copy of the hash map which can be modified separately.</span></span>
<span class="line" id="L384">        <span class="tok-comment">/// The copy uses the same context as this instance, but the specified</span></span>
<span class="line" id="L385">        <span class="tok-comment">/// allocator.</span></span>
<span class="line" id="L386">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithAllocator</span>(self: Self, allocator: Allocator) !Self {</span>
<span class="line" id="L387">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(allocator, self.ctx);</span>
<span class="line" id="L388">            <span class="tok-kw">return</span> other.promoteContext(allocator, self.ctx);</span>
<span class="line" id="L389">        }</span>
<span class="line" id="L390">        <span class="tok-comment">/// Create a copy of the hash map which can be modified separately.</span></span>
<span class="line" id="L391">        <span class="tok-comment">/// The copy uses the same allocator as this instance, but the</span></span>
<span class="line" id="L392">        <span class="tok-comment">/// specified context.</span></span>
<span class="line" id="L393">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithContext</span>(self: Self, ctx: <span class="tok-kw">anytype</span>) !ArrayHashMap(K, V, <span class="tok-builtin">@TypeOf</span>(ctx), store_hash) {</span>
<span class="line" id="L394">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(self.allocator, ctx);</span>
<span class="line" id="L395">            <span class="tok-kw">return</span> other.promoteContext(self.allocator, ctx);</span>
<span class="line" id="L396">        }</span>
<span class="line" id="L397">        <span class="tok-comment">/// Create a copy of the hash map which can be modified separately.</span></span>
<span class="line" id="L398">        <span class="tok-comment">/// The copy uses the specified allocator and context.</span></span>
<span class="line" id="L399">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithAllocatorAndContext</span>(self: Self, allocator: Allocator, ctx: <span class="tok-kw">anytype</span>) !ArrayHashMap(K, V, <span class="tok-builtin">@TypeOf</span>(ctx), store_hash) {</span>
<span class="line" id="L400">            <span class="tok-kw">var</span> other = <span class="tok-kw">try</span> self.unmanaged.cloneContext(allocator, ctx);</span>
<span class="line" id="L401">            <span class="tok-kw">return</span> other.promoteContext(allocator, ctx);</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">        <span class="tok-comment">/// Rebuilds the key indexes. If the underlying entries has been modified directly, users</span></span>
<span class="line" id="L405">        <span class="tok-comment">/// can call `reIndex` to update the indexes to account for these new entries.</span></span>
<span class="line" id="L406">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reIndex</span>(self: *Self) !<span class="tok-type">void</span> {</span>
<span class="line" id="L407">            <span class="tok-kw">return</span> self.unmanaged.reIndexContext(self.allocator, self.ctx);</span>
<span class="line" id="L408">        }</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">        <span class="tok-comment">/// Sorts the entries and then rebuilds the index.</span></span>
<span class="line" id="L411">        <span class="tok-comment">/// `sort_ctx` must have this method:</span></span>
<span class="line" id="L412">        <span class="tok-comment">/// `fn lessThan(ctx: @TypeOf(ctx), a_index: usize, b_index: usize) bool`</span></span>
<span class="line" id="L413">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sort</span>(self: *Self, sort_ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L414">            <span class="tok-kw">return</span> self.unmanaged.sortContext(sort_ctx, self.ctx);</span>
<span class="line" id="L415">        }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">        <span class="tok-comment">/// Shrinks the underlying `Entry` array to `new_len` elements and discards any associated</span></span>
<span class="line" id="L418">        <span class="tok-comment">/// index entries. Keeps capacity the same.</span></span>
<span class="line" id="L419">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L420">            <span class="tok-kw">return</span> self.unmanaged.shrinkRetainingCapacityContext(new_len, self.ctx);</span>
<span class="line" id="L421">        }</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">        <span class="tok-comment">/// Shrinks the underlying `Entry` array to `new_len` elements and discards any associated</span></span>
<span class="line" id="L424">        <span class="tok-comment">/// index entries. Reduces allocated capacity.</span></span>
<span class="line" id="L425">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L426">            <span class="tok-kw">return</span> self.unmanaged.shrinkAndFreeContext(self.allocator, new_len, self.ctx);</span>
<span class="line" id="L427">        }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        <span class="tok-comment">/// Removes the last inserted `Entry` in the hash map and returns it.</span></span>
<span class="line" id="L430">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) KV {</span>
<span class="line" id="L431">            <span class="tok-kw">return</span> self.unmanaged.popContext(self.ctx);</span>
<span class="line" id="L432">        }</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">        <span class="tok-comment">/// Removes the last inserted `Entry` in the hash map and returns it if count is nonzero.</span></span>
<span class="line" id="L435">        <span class="tok-comment">/// Otherwise returns null.</span></span>
<span class="line" id="L436">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?KV {</span>
<span class="line" id="L437">            <span class="tok-kw">return</span> self.unmanaged.popOrNullContext(self.ctx);</span>
<span class="line" id="L438">        }</span>
<span class="line" id="L439">    };</span>
<span class="line" id="L440">}</span>
<span class="line" id="L441"></span>
<span class="line" id="L442"><span class="tok-comment">/// General purpose hash table.</span></span>
<span class="line" id="L443"><span class="tok-comment">/// Insertion order is preserved.</span></span>
<span class="line" id="L444"><span class="tok-comment">/// Deletions perform a &quot;swap removal&quot; on the entries list.</span></span>
<span class="line" id="L445"><span class="tok-comment">/// Modifying the hash map while iterating is allowed, however one must understand</span></span>
<span class="line" id="L446"><span class="tok-comment">/// the (well defined) behavior when mixing insertions and deletions with iteration.</span></span>
<span class="line" id="L447"><span class="tok-comment">/// This type does not store an Allocator field - the Allocator must be passed in</span></span>
<span class="line" id="L448"><span class="tok-comment">/// with each function call that requires it. See `ArrayHashMap` for a type that stores</span></span>
<span class="line" id="L449"><span class="tok-comment">/// an Allocator field for convenience.</span></span>
<span class="line" id="L450"><span class="tok-comment">/// Can be initialized directly using the default field values.</span></span>
<span class="line" id="L451"><span class="tok-comment">/// This type is designed to have low overhead for small numbers of entries. When</span></span>
<span class="line" id="L452"><span class="tok-comment">/// `store_hash` is `false` and the number of entries in the map is less than 9,</span></span>
<span class="line" id="L453"><span class="tok-comment">/// the overhead cost of using `ArrayHashMapUnmanaged` rather than `std.ArrayList` is</span></span>
<span class="line" id="L454"><span class="tok-comment">/// only a single pointer-sized integer.</span></span>
<span class="line" id="L455"><span class="tok-comment">/// When `store_hash` is `false`, this data structure is biased towards cheap `eql`</span></span>
<span class="line" id="L456"><span class="tok-comment">/// functions. It does not store each item's hash in the table. Setting `store_hash`</span></span>
<span class="line" id="L457"><span class="tok-comment">/// to `true` incurs slightly more memory cost by storing each key's hash in the table</span></span>
<span class="line" id="L458"><span class="tok-comment">/// but guarantees only one call to `eql` per insertion/deletion.</span></span>
<span class="line" id="L459"><span class="tok-comment">/// Context must be a struct type with two member functions:</span></span>
<span class="line" id="L460"><span class="tok-comment">///   hash(self, K) u32</span></span>
<span class="line" id="L461"><span class="tok-comment">///   eql(self, K, K) bool</span></span>
<span class="line" id="L462"><span class="tok-comment">/// Adapted variants of many functions are provided.  These variants</span></span>
<span class="line" id="L463"><span class="tok-comment">/// take a pseudo key instead of a key.  Their context must have the functions:</span></span>
<span class="line" id="L464"><span class="tok-comment">///   hash(self, PseudoKey) u32</span></span>
<span class="line" id="L465"><span class="tok-comment">///   eql(self, PseudoKey, K) bool</span></span>
<span class="line" id="L466"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArrayHashMapUnmanaged</span>(</span>
<span class="line" id="L467">    <span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>,</span>
<span class="line" id="L468">    <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>,</span>
<span class="line" id="L469">    <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>,</span>
<span class="line" id="L470">    <span class="tok-kw">comptime</span> store_hash: <span class="tok-type">bool</span>,</span>
<span class="line" id="L471">) <span class="tok-type">type</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L473">        <span class="tok-comment">/// It is permitted to access this field directly.</span></span>
<span class="line" id="L474">        entries: DataList = .{},</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">        <span class="tok-comment">/// When entries length is less than `linear_scan_max`, this remains `null`.</span></span>
<span class="line" id="L477">        <span class="tok-comment">/// Once entries length grows big enough, this field is allocated. There is</span></span>
<span class="line" id="L478">        <span class="tok-comment">/// an IndexHeader followed by an array of Index(I) structs, where I is defined</span></span>
<span class="line" id="L479">        <span class="tok-comment">/// by how many total indexes there are.</span></span>
<span class="line" id="L480">        index_header: ?*IndexHeader = <span class="tok-null">null</span>,</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">        <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L483">            std.hash_map.verifyContext(Context, K, K, <span class="tok-type">u32</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L484">        }</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-comment">/// Modifying the key is allowed only if it does not change the hash.</span></span>
<span class="line" id="L487">        <span class="tok-comment">/// Modifying the value is allowed.</span></span>
<span class="line" id="L488">        <span class="tok-comment">/// Entry pointers become invalid whenever this ArrayHashMap is modified,</span></span>
<span class="line" id="L489">        <span class="tok-comment">/// unless `ensureTotalCapacity`/`ensureUnusedCapacity` was previously used.</span></span>
<span class="line" id="L490">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L491">            key_ptr: *K,</span>
<span class="line" id="L492">            value_ptr: *V,</span>
<span class="line" id="L493">        };</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">        <span class="tok-comment">/// A KV pair which has been copied out of the backing store</span></span>
<span class="line" id="L496">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L497">            key: K,</span>
<span class="line" id="L498">            value: V,</span>
<span class="line" id="L499">        };</span>
<span class="line" id="L500"></span>
<span class="line" id="L501">        <span class="tok-comment">/// The Data type used for the MultiArrayList backing this map</span></span>
<span class="line" id="L502">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Data = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L503">            hash: Hash,</span>
<span class="line" id="L504">            key: K,</span>
<span class="line" id="L505">            value: V,</span>
<span class="line" id="L506">        };</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">        <span class="tok-comment">/// The MultiArrayList type backing this map</span></span>
<span class="line" id="L509">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DataList = std.MultiArrayList(Data);</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">        <span class="tok-comment">/// The stored hash type, either u32 or void.</span></span>
<span class="line" id="L512">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Hash = <span class="tok-kw">if</span> (store_hash) <span class="tok-type">u32</span> <span class="tok-kw">else</span> <span class="tok-type">void</span>;</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">        <span class="tok-comment">/// getOrPut variants return this structure, with pointers</span></span>
<span class="line" id="L515">        <span class="tok-comment">/// to the backing store and a flag to indicate whether an</span></span>
<span class="line" id="L516">        <span class="tok-comment">/// existing entry was found.</span></span>
<span class="line" id="L517">        <span class="tok-comment">/// Modifying the key is allowed only if it does not change the hash.</span></span>
<span class="line" id="L518">        <span class="tok-comment">/// Modifying the value is allowed.</span></span>
<span class="line" id="L519">        <span class="tok-comment">/// Entry pointers become invalid whenever this ArrayHashMap is modified,</span></span>
<span class="line" id="L520">        <span class="tok-comment">/// unless `ensureTotalCapacity`/`ensureUnusedCapacity` was previously used.</span></span>
<span class="line" id="L521">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetOrPutResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L522">            key_ptr: *K,</span>
<span class="line" id="L523">            value_ptr: *V,</span>
<span class="line" id="L524">            found_existing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L525">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L526">        };</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-comment">/// The ArrayHashMap type using the same settings as this managed map.</span></span>
<span class="line" id="L529">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Managed = ArrayHashMap(K, V, Context, store_hash);</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">        <span class="tok-comment">/// Some functions require a context only if hashes are not stored.</span></span>
<span class="line" id="L532">        <span class="tok-comment">/// To keep the api simple, this type is only used internally.</span></span>
<span class="line" id="L533">        <span class="tok-kw">const</span> ByIndexContext = <span class="tok-kw">if</span> (store_hash) <span class="tok-type">void</span> <span class="tok-kw">else</span> Context;</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">        <span class="tok-kw">const</span> linear_scan_max = <span class="tok-number">8</span>;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-kw">const</span> RemovalType = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L540">            swap,</span>
<span class="line" id="L541">            ordered,</span>
<span class="line" id="L542">        };</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">        <span class="tok-comment">/// Convert from an unmanaged map to a managed map.  After calling this,</span></span>
<span class="line" id="L545">        <span class="tok-comment">/// the promoted map should no longer be used.</span></span>
<span class="line" id="L546">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promote</span>(self: Self, allocator: Allocator) Managed {</span>
<span class="line" id="L547">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L548">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call promoteContext instead.&quot;</span>);</span>
<span class="line" id="L549">            <span class="tok-kw">return</span> self.promoteContext(allocator, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L550">        }</span>
<span class="line" id="L551">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promoteContext</span>(self: Self, allocator: Allocator, ctx: Context) Managed {</span>
<span class="line" id="L552">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L553">                .unmanaged = self,</span>
<span class="line" id="L554">                .allocator = allocator,</span>
<span class="line" id="L555">                .ctx = ctx,</span>
<span class="line" id="L556">            };</span>
<span class="line" id="L557">        }</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">        <span class="tok-comment">/// Frees the backing allocation and leaves the map in an undefined state.</span></span>
<span class="line" id="L560">        <span class="tok-comment">/// Note that this does not free keys or values.  You must take care of that</span></span>
<span class="line" id="L561">        <span class="tok-comment">/// before calling this function, if it is needed.</span></span>
<span class="line" id="L562">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L563">            self.entries.deinit(allocator);</span>
<span class="line" id="L564">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L565">                header.free(allocator);</span>
<span class="line" id="L566">            }</span>
<span class="line" id="L567">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L568">        }</span>
<span class="line" id="L569"></span>
<span class="line" id="L570">        <span class="tok-comment">/// Clears the map but retains the backing allocation for future use.</span></span>
<span class="line" id="L571">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearRetainingCapacity</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L572">            self.entries.len = <span class="tok-number">0</span>;</span>
<span class="line" id="L573">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L574">                <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L575">                    .<span class="tok-type">u8</span> =&gt; mem.set(Index(<span class="tok-type">u8</span>), header.indexes(<span class="tok-type">u8</span>), Index(<span class="tok-type">u8</span>).empty),</span>
<span class="line" id="L576">                    .<span class="tok-type">u16</span> =&gt; mem.set(Index(<span class="tok-type">u16</span>), header.indexes(<span class="tok-type">u16</span>), Index(<span class="tok-type">u16</span>).empty),</span>
<span class="line" id="L577">                    .<span class="tok-type">u32</span> =&gt; mem.set(Index(<span class="tok-type">u32</span>), header.indexes(<span class="tok-type">u32</span>), Index(<span class="tok-type">u32</span>).empty),</span>
<span class="line" id="L578">                }</span>
<span class="line" id="L579">            }</span>
<span class="line" id="L580">        }</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">        <span class="tok-comment">/// Clears the map and releases the backing allocation</span></span>
<span class="line" id="L583">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearAndFree</span>(self: *Self, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L584">            self.entries.shrinkAndFree(allocator, <span class="tok-number">0</span>);</span>
<span class="line" id="L585">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L586">                header.free(allocator);</span>
<span class="line" id="L587">                self.index_header = <span class="tok-null">null</span>;</span>
<span class="line" id="L588">            }</span>
<span class="line" id="L589">        }</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">        <span class="tok-comment">/// Returns the number of KV pairs stored in this map.</span></span>
<span class="line" id="L592">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L593">            <span class="tok-kw">return</span> self.entries.len;</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">        <span class="tok-comment">/// Returns the backing array of keys in this map.</span></span>
<span class="line" id="L597">        <span class="tok-comment">/// Modifying the map may invalidate this array.</span></span>
<span class="line" id="L598">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keys</span>(self: Self) []K {</span>
<span class="line" id="L599">            <span class="tok-kw">return</span> self.entries.items(.key);</span>
<span class="line" id="L600">        }</span>
<span class="line" id="L601">        <span class="tok-comment">/// Returns the backing array of values in this map.</span></span>
<span class="line" id="L602">        <span class="tok-comment">/// Modifying the map may invalidate this array.</span></span>
<span class="line" id="L603">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">values</span>(self: Self) []V {</span>
<span class="line" id="L604">            <span class="tok-kw">return</span> self.entries.items(.value);</span>
<span class="line" id="L605">        }</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">        <span class="tok-comment">/// Returns an iterator over the pairs in this map.</span></span>
<span class="line" id="L608">        <span class="tok-comment">/// Modifying the map may invalidate this iterator.</span></span>
<span class="line" id="L609">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: Self) Iterator {</span>
<span class="line" id="L610">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L611">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L612">                .keys = slice.items(.key).ptr,</span>
<span class="line" id="L613">                .values = slice.items(.value).ptr,</span>
<span class="line" id="L614">                .len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, slice.len),</span>
<span class="line" id="L615">            };</span>
<span class="line" id="L616">        }</span>
<span class="line" id="L617">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L618">            keys: [*]K,</span>
<span class="line" id="L619">            values: [*]V,</span>
<span class="line" id="L620">            len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L621">            index: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(it: *Iterator) ?Entry {</span>
<span class="line" id="L624">                <span class="tok-kw">if</span> (it.index &gt;= it.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L625">                <span class="tok-kw">const</span> result = Entry{</span>
<span class="line" id="L626">                    .key_ptr = &amp;it.keys[it.index],</span>
<span class="line" id="L627">                    <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L628">                    .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;it.values[it.index],</span>
<span class="line" id="L629">                };</span>
<span class="line" id="L630">                it.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L631">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L632">            }</span>
<span class="line" id="L633"></span>
<span class="line" id="L634">            <span class="tok-comment">/// Reset the iterator to the initial index</span></span>
<span class="line" id="L635">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(it: *Iterator) <span class="tok-type">void</span> {</span>
<span class="line" id="L636">                it.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L637">            }</span>
<span class="line" id="L638">        };</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">        <span class="tok-comment">/// If key exists this function cannot fail.</span></span>
<span class="line" id="L641">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L642">        <span class="tok-comment">/// `Entry` pointer points to it, and found_existing is true.</span></span>
<span class="line" id="L643">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L644">        <span class="tok-comment">/// the `Entry` pointer points to it. Caller should then initialize</span></span>
<span class="line" id="L645">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L646">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPut</span>(self: *Self, allocator: Allocator, key: K) !GetOrPutResult {</span>
<span class="line" id="L647">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L648">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutContext instead.&quot;</span>);</span>
<span class="line" id="L649">            <span class="tok-kw">return</span> self.getOrPutContext(allocator, key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L650">        }</span>
<span class="line" id="L651">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutContext</span>(self: *Self, allocator: Allocator, key: K, ctx: Context) !GetOrPutResult {</span>
<span class="line" id="L652">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.getOrPutContextAdapted(allocator, key, ctx, ctx);</span>
<span class="line" id="L653">            <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L654">                gop.key_ptr.* = key;</span>
<span class="line" id="L655">            }</span>
<span class="line" id="L656">            <span class="tok-kw">return</span> gop;</span>
<span class="line" id="L657">        }</span>
<span class="line" id="L658">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAdapted</span>(self: *Self, allocator: Allocator, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>) !GetOrPutResult {</span>
<span class="line" id="L659">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L660">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L661">            <span class="tok-kw">return</span> self.getOrPutContextAdapted(allocator, key, key_ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L662">        }</span>
<span class="line" id="L663">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutContextAdapted</span>(self: *Self, allocator: Allocator, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) !GetOrPutResult {</span>
<span class="line" id="L664">            self.ensureTotalCapacityContext(allocator, self.entries.len + <span class="tok-number">1</span>, ctx) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L665">                <span class="tok-comment">// &quot;If key exists this function cannot fail.&quot;</span>
</span>
<span class="line" id="L666">                <span class="tok-kw">const</span> index = self.getIndexAdapted(key, key_ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> err;</span>
<span class="line" id="L667">                <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L668">                <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L669">                    .key_ptr = &amp;slice.items(.key)[index],</span>
<span class="line" id="L670">                    <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L671">                    .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;slice.items(.value)[index],</span>
<span class="line" id="L672">                    .found_existing = <span class="tok-null">true</span>,</span>
<span class="line" id="L673">                    .index = index,</span>
<span class="line" id="L674">                };</span>
<span class="line" id="L675">            };</span>
<span class="line" id="L676">            <span class="tok-kw">return</span> self.getOrPutAssumeCapacityAdapted(key, key_ctx);</span>
<span class="line" id="L677">        }</span>
<span class="line" id="L678"></span>
<span class="line" id="L679">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L680">        <span class="tok-comment">/// `Entry` pointer points to it, and found_existing is true.</span></span>
<span class="line" id="L681">        <span class="tok-comment">/// Otherwise, puts a new item with undefined value, and</span></span>
<span class="line" id="L682">        <span class="tok-comment">/// the `Entry` pointer points to it. Caller should then initialize</span></span>
<span class="line" id="L683">        <span class="tok-comment">/// the value (but not the key).</span></span>
<span class="line" id="L684">        <span class="tok-comment">/// If a new entry needs to be stored, this function asserts there</span></span>
<span class="line" id="L685">        <span class="tok-comment">/// is enough capacity to store it.</span></span>
<span class="line" id="L686">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacity</span>(self: *Self, key: K) GetOrPutResult {</span>
<span class="line" id="L687">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L688">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L689">            <span class="tok-kw">return</span> self.getOrPutAssumeCapacityContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L690">        }</span>
<span class="line" id="L691">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityContext</span>(self: *Self, key: K, ctx: Context) GetOrPutResult {</span>
<span class="line" id="L692">            <span class="tok-kw">const</span> gop = self.getOrPutAssumeCapacityAdapted(key, ctx);</span>
<span class="line" id="L693">            <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L694">                gop.key_ptr.* = key;</span>
<span class="line" id="L695">            }</span>
<span class="line" id="L696">            <span class="tok-kw">return</span> gop;</span>
<span class="line" id="L697">        }</span>
<span class="line" id="L698">        <span class="tok-comment">/// If there is an existing item with `key`, then the result</span></span>
<span class="line" id="L699">        <span class="tok-comment">/// `Entry` pointers point to it, and found_existing is true.</span></span>
<span class="line" id="L700">        <span class="tok-comment">/// Otherwise, puts a new item with undefined key and value, and</span></span>
<span class="line" id="L701">        <span class="tok-comment">/// the `Entry` pointers point to it. Caller must then initialize</span></span>
<span class="line" id="L702">        <span class="tok-comment">/// both the key and the value.</span></span>
<span class="line" id="L703">        <span class="tok-comment">/// If a new entry needs to be stored, this function asserts there</span></span>
<span class="line" id="L704">        <span class="tok-comment">/// is enough capacity to store it.</span></span>
<span class="line" id="L705">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutAssumeCapacityAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) GetOrPutResult {</span>
<span class="line" id="L706">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L707">                <span class="tok-comment">// Linear scan.</span>
</span>
<span class="line" id="L708">                <span class="tok-kw">const</span> h = <span class="tok-kw">if</span> (store_hash) checkedHash(ctx, key) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L709">                <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L710">                <span class="tok-kw">const</span> hashes_array = slice.items(.hash);</span>
<span class="line" id="L711">                <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L712">                <span class="tok-kw">for</span> (keys_array) |*item_key, i| {</span>
<span class="line" id="L713">                    <span class="tok-kw">if</span> (hashes_array[i] == h <span class="tok-kw">and</span> checkedEql(ctx, key, item_key.*, i)) {</span>
<span class="line" id="L714">                        <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L715">                            .key_ptr = item_key,</span>
<span class="line" id="L716">                            <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L717">                            .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;slice.items(.value)[i],</span>
<span class="line" id="L718">                            .found_existing = <span class="tok-null">true</span>,</span>
<span class="line" id="L719">                            .index = i,</span>
<span class="line" id="L720">                        };</span>
<span class="line" id="L721">                    }</span>
<span class="line" id="L722">                }</span>
<span class="line" id="L723"></span>
<span class="line" id="L724">                <span class="tok-kw">const</span> index = self.entries.addOneAssumeCapacity();</span>
<span class="line" id="L725">                <span class="tok-comment">// unsafe indexing because the length changed</span>
</span>
<span class="line" id="L726">                <span class="tok-kw">if</span> (store_hash) hashes_array.ptr[index] = h;</span>
<span class="line" id="L727"></span>
<span class="line" id="L728">                <span class="tok-kw">return</span> GetOrPutResult{</span>
<span class="line" id="L729">                    .key_ptr = &amp;keys_array.ptr[index],</span>
<span class="line" id="L730">                    <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L731">                    .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;slice.items(.value).ptr[index],</span>
<span class="line" id="L732">                    .found_existing = <span class="tok-null">false</span>,</span>
<span class="line" id="L733">                    .index = index,</span>
<span class="line" id="L734">                };</span>
<span class="line" id="L735">            };</span>
<span class="line" id="L736"></span>
<span class="line" id="L737">            <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L738">                .<span class="tok-type">u8</span> =&gt; <span class="tok-kw">return</span> self.getOrPutInternal(key, ctx, header, <span class="tok-type">u8</span>),</span>
<span class="line" id="L739">                .<span class="tok-type">u16</span> =&gt; <span class="tok-kw">return</span> self.getOrPutInternal(key, ctx, header, <span class="tok-type">u16</span>),</span>
<span class="line" id="L740">                .<span class="tok-type">u32</span> =&gt; <span class="tok-kw">return</span> self.getOrPutInternal(key, ctx, header, <span class="tok-type">u32</span>),</span>
<span class="line" id="L741">            }</span>
<span class="line" id="L742">        }</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValue</span>(self: *Self, allocator: Allocator, key: K, value: V) !GetOrPutResult {</span>
<span class="line" id="L745">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L746">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getOrPutValueContext instead.&quot;</span>);</span>
<span class="line" id="L747">            <span class="tok-kw">return</span> self.getOrPutValueContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L748">        }</span>
<span class="line" id="L749">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutValueContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) !GetOrPutResult {</span>
<span class="line" id="L750">            <span class="tok-kw">const</span> res = <span class="tok-kw">try</span> self.getOrPutContextAdapted(allocator, key, ctx, ctx);</span>
<span class="line" id="L751">            <span class="tok-kw">if</span> (!res.found_existing) {</span>
<span class="line" id="L752">                res.key_ptr.* = key;</span>
<span class="line" id="L753">                res.value_ptr.* = value;</span>
<span class="line" id="L754">            }</span>
<span class="line" id="L755">            <span class="tok-kw">return</span> res;</span>
<span class="line" id="L756">        }</span>
<span class="line" id="L757"></span>
<span class="line" id="L758">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ensureCapacity = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;deprecated; call `ensureUnusedCapacity` or `ensureTotalCapacity`&quot;</span>);</span>
<span class="line" id="L759"></span>
<span class="line" id="L760">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until the</span></span>
<span class="line" id="L761">        <span class="tok-comment">/// `expected_count` will not cause an allocation, and therefore cannot fail.</span></span>
<span class="line" id="L762">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacity</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L763">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L764">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call ensureTotalCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L765">            <span class="tok-kw">return</span> self.ensureTotalCapacityContext(allocator, new_capacity, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L766">        }</span>
<span class="line" id="L767">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureTotalCapacityContext</span>(self: *Self, allocator: Allocator, new_capacity: <span class="tok-type">usize</span>, ctx: Context) !<span class="tok-type">void</span> {</span>
<span class="line" id="L768">            <span class="tok-kw">if</span> (new_capacity &lt;= linear_scan_max) {</span>
<span class="line" id="L769">                <span class="tok-kw">try</span> self.entries.ensureTotalCapacity(allocator, new_capacity);</span>
<span class="line" id="L770">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L771">            }</span>
<span class="line" id="L772"></span>
<span class="line" id="L773">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L774">                <span class="tok-kw">if</span> (new_capacity &lt;= header.capacity()) {</span>
<span class="line" id="L775">                    <span class="tok-kw">try</span> self.entries.ensureTotalCapacity(allocator, new_capacity);</span>
<span class="line" id="L776">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L777">                }</span>
<span class="line" id="L778">            }</span>
<span class="line" id="L779"></span>
<span class="line" id="L780">            <span class="tok-kw">const</span> new_bit_index = <span class="tok-kw">try</span> IndexHeader.findBitIndex(new_capacity);</span>
<span class="line" id="L781">            <span class="tok-kw">const</span> new_header = <span class="tok-kw">try</span> IndexHeader.alloc(allocator, new_bit_index);</span>
<span class="line" id="L782">            <span class="tok-kw">try</span> self.entries.ensureTotalCapacity(allocator, new_capacity);</span>
<span class="line" id="L783"></span>
<span class="line" id="L784">            <span class="tok-kw">if</span> (self.index_header) |old_header| old_header.free(allocator);</span>
<span class="line" id="L785">            self.insertAllEntriesIntoNewHeader(<span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, new_header);</span>
<span class="line" id="L786">            self.index_header = new_header;</span>
<span class="line" id="L787">        }</span>
<span class="line" id="L788"></span>
<span class="line" id="L789">        <span class="tok-comment">/// Increases capacity, guaranteeing that insertions up until</span></span>
<span class="line" id="L790">        <span class="tok-comment">/// `additional_count` **more** items will not cause an allocation, and</span></span>
<span class="line" id="L791">        <span class="tok-comment">/// therefore cannot fail.</span></span>
<span class="line" id="L792">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacity</span>(</span>
<span class="line" id="L793">            self: *Self,</span>
<span class="line" id="L794">            allocator: Allocator,</span>
<span class="line" id="L795">            additional_capacity: <span class="tok-type">usize</span>,</span>
<span class="line" id="L796">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L797">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L798">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call ensureTotalCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L799">            <span class="tok-kw">return</span> self.ensureUnusedCapacityContext(allocator, additional_capacity, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L800">        }</span>
<span class="line" id="L801">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureUnusedCapacityContext</span>(</span>
<span class="line" id="L802">            self: *Self,</span>
<span class="line" id="L803">            allocator: Allocator,</span>
<span class="line" id="L804">            additional_capacity: <span class="tok-type">usize</span>,</span>
<span class="line" id="L805">            ctx: Context,</span>
<span class="line" id="L806">        ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L807">            <span class="tok-kw">return</span> self.ensureTotalCapacityContext(allocator, self.count() + additional_capacity, ctx);</span>
<span class="line" id="L808">        }</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">        <span class="tok-comment">/// Returns the number of total elements which may be present before it is</span></span>
<span class="line" id="L811">        <span class="tok-comment">/// no longer guaranteed that no allocations will be performed.</span></span>
<span class="line" id="L812">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L813">            <span class="tok-kw">const</span> entry_cap = self.entries.capacity;</span>
<span class="line" id="L814">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> math.min(linear_scan_max, entry_cap);</span>
<span class="line" id="L815">            <span class="tok-kw">const</span> indexes_cap = header.capacity();</span>
<span class="line" id="L816">            <span class="tok-kw">return</span> math.min(entry_cap, indexes_cap);</span>
<span class="line" id="L817">        }</span>
<span class="line" id="L818"></span>
<span class="line" id="L819">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L820">        <span class="tok-comment">/// existing data, see `getOrPut`.</span></span>
<span class="line" id="L821">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, allocator: Allocator, key: K, value: V) !<span class="tok-type">void</span> {</span>
<span class="line" id="L822">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L823">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putContext instead.&quot;</span>);</span>
<span class="line" id="L824">            <span class="tok-kw">return</span> self.putContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L825">        }</span>
<span class="line" id="L826">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) !<span class="tok-type">void</span> {</span>
<span class="line" id="L827">            <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.getOrPutContext(allocator, key, ctx);</span>
<span class="line" id="L828">            result.value_ptr.* = value;</span>
<span class="line" id="L829">        }</span>
<span class="line" id="L830"></span>
<span class="line" id="L831">        <span class="tok-comment">/// Inserts a key-value pair into the hash map, asserting that no previous</span></span>
<span class="line" id="L832">        <span class="tok-comment">/// entry with the same key is already present</span></span>
<span class="line" id="L833">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobber</span>(self: *Self, allocator: Allocator, key: K, value: V) !<span class="tok-type">void</span> {</span>
<span class="line" id="L834">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L835">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putNoClobberContext instead.&quot;</span>);</span>
<span class="line" id="L836">            <span class="tok-kw">return</span> self.putNoClobberContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L837">        }</span>
<span class="line" id="L838">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putNoClobberContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) !<span class="tok-type">void</span> {</span>
<span class="line" id="L839">            <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.getOrPutContext(allocator, key, ctx);</span>
<span class="line" id="L840">            assert(!result.found_existing);</span>
<span class="line" id="L841">            result.value_ptr.* = value;</span>
<span class="line" id="L842">        }</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L845">        <span class="tok-comment">/// Clobbers any existing data. To detect if a put would clobber</span></span>
<span class="line" id="L846">        <span class="tok-comment">/// existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L847">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacity</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L848">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L849">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L850">            <span class="tok-kw">return</span> self.putAssumeCapacityContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L851">        }</span>
<span class="line" id="L852">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityContext</span>(self: *Self, key: K, value: V, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L853">            <span class="tok-kw">const</span> result = self.getOrPutAssumeCapacityContext(key, ctx);</span>
<span class="line" id="L854">            result.value_ptr.* = value;</span>
<span class="line" id="L855">        }</span>
<span class="line" id="L856"></span>
<span class="line" id="L857">        <span class="tok-comment">/// Asserts there is enough capacity to store the new key-value pair.</span></span>
<span class="line" id="L858">        <span class="tok-comment">/// Asserts that it does not clobber any existing data.</span></span>
<span class="line" id="L859">        <span class="tok-comment">/// To detect if a put would clobber existing data, see `getOrPutAssumeCapacity`.</span></span>
<span class="line" id="L860">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobber</span>(self: *Self, key: K, value: V) <span class="tok-type">void</span> {</span>
<span class="line" id="L861">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L862">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call putAssumeCapacityNoClobberContext instead.&quot;</span>);</span>
<span class="line" id="L863">            <span class="tok-kw">return</span> self.putAssumeCapacityNoClobberContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L864">        }</span>
<span class="line" id="L865">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putAssumeCapacityNoClobberContext</span>(self: *Self, key: K, value: V, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L866">            <span class="tok-kw">const</span> result = self.getOrPutAssumeCapacityContext(key, ctx);</span>
<span class="line" id="L867">            assert(!result.found_existing);</span>
<span class="line" id="L868">            result.value_ptr.* = value;</span>
<span class="line" id="L869">        }</span>
<span class="line" id="L870"></span>
<span class="line" id="L871">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L872">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPut</span>(self: *Self, allocator: Allocator, key: K, value: V) !?KV {</span>
<span class="line" id="L873">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L874">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchPutContext instead.&quot;</span>);</span>
<span class="line" id="L875">            <span class="tok-kw">return</span> self.fetchPutContext(allocator, key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L876">        }</span>
<span class="line" id="L877">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutContext</span>(self: *Self, allocator: Allocator, key: K, value: V, ctx: Context) !?KV {</span>
<span class="line" id="L878">            <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.getOrPutContext(allocator, key, ctx);</span>
<span class="line" id="L879">            <span class="tok-kw">var</span> result: ?KV = <span class="tok-null">null</span>;</span>
<span class="line" id="L880">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L881">                result = KV{</span>
<span class="line" id="L882">                    .key = gop.key_ptr.*,</span>
<span class="line" id="L883">                    .value = gop.value_ptr.*,</span>
<span class="line" id="L884">                };</span>
<span class="line" id="L885">            }</span>
<span class="line" id="L886">            gop.value_ptr.* = value;</span>
<span class="line" id="L887">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L888">        }</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">        <span class="tok-comment">/// Inserts a new `Entry` into the hash map, returning the previous one, if any.</span></span>
<span class="line" id="L891">        <span class="tok-comment">/// If insertion happens, asserts there is enough capacity without allocating.</span></span>
<span class="line" id="L892">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacity</span>(self: *Self, key: K, value: V) ?KV {</span>
<span class="line" id="L893">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L894">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchPutAssumeCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L895">            <span class="tok-kw">return</span> self.fetchPutAssumeCapacityContext(key, value, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L896">        }</span>
<span class="line" id="L897">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPutAssumeCapacityContext</span>(self: *Self, key: K, value: V, ctx: Context) ?KV {</span>
<span class="line" id="L898">            <span class="tok-kw">const</span> gop = self.getOrPutAssumeCapacityContext(key, ctx);</span>
<span class="line" id="L899">            <span class="tok-kw">var</span> result: ?KV = <span class="tok-null">null</span>;</span>
<span class="line" id="L900">            <span class="tok-kw">if</span> (gop.found_existing) {</span>
<span class="line" id="L901">                result = KV{</span>
<span class="line" id="L902">                    .key = gop.key_ptr.*,</span>
<span class="line" id="L903">                    .value = gop.value_ptr.*,</span>
<span class="line" id="L904">                };</span>
<span class="line" id="L905">            }</span>
<span class="line" id="L906">            gop.value_ptr.* = value;</span>
<span class="line" id="L907">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L908">        }</span>
<span class="line" id="L909"></span>
<span class="line" id="L910">        <span class="tok-comment">/// Finds pointers to the key and value storage associated with a key.</span></span>
<span class="line" id="L911">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntry</span>(self: Self, key: K) ?Entry {</span>
<span class="line" id="L912">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L913">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getEntryContext instead.&quot;</span>);</span>
<span class="line" id="L914">            <span class="tok-kw">return</span> self.getEntryContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L915">        }</span>
<span class="line" id="L916">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryContext</span>(self: Self, key: K, ctx: Context) ?Entry {</span>
<span class="line" id="L917">            <span class="tok-kw">return</span> self.getEntryAdapted(key, ctx);</span>
<span class="line" id="L918">        }</span>
<span class="line" id="L919">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?Entry {</span>
<span class="line" id="L920">            <span class="tok-kw">const</span> index = self.getIndexAdapted(key, ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L921">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L922">            <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L923">                .key_ptr = &amp;slice.items(.key)[index],</span>
<span class="line" id="L924">                <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L925">                .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;slice.items(.value)[index],</span>
<span class="line" id="L926">            };</span>
<span class="line" id="L927">        }</span>
<span class="line" id="L928"></span>
<span class="line" id="L929">        <span class="tok-comment">/// Finds the index in the `entries` array where a key is stored</span></span>
<span class="line" id="L930">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndex</span>(self: Self, key: K) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L931">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L932">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getIndexContext instead.&quot;</span>);</span>
<span class="line" id="L933">            <span class="tok-kw">return</span> self.getIndexContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L934">        }</span>
<span class="line" id="L935">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndexContext</span>(self: Self, key: K, ctx: Context) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L936">            <span class="tok-kw">return</span> self.getIndexAdapted(key, ctx);</span>
<span class="line" id="L937">        }</span>
<span class="line" id="L938">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getIndexAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L939">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L940">                <span class="tok-comment">// Linear scan.</span>
</span>
<span class="line" id="L941">                <span class="tok-kw">const</span> h = <span class="tok-kw">if</span> (store_hash) checkedHash(ctx, key) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L942">                <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L943">                <span class="tok-kw">const</span> hashes_array = slice.items(.hash);</span>
<span class="line" id="L944">                <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L945">                <span class="tok-kw">for</span> (keys_array) |*item_key, i| {</span>
<span class="line" id="L946">                    <span class="tok-kw">if</span> (hashes_array[i] == h <span class="tok-kw">and</span> checkedEql(ctx, key, item_key.*, i)) {</span>
<span class="line" id="L947">                        <span class="tok-kw">return</span> i;</span>
<span class="line" id="L948">                    }</span>
<span class="line" id="L949">                }</span>
<span class="line" id="L950">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L951">            };</span>
<span class="line" id="L952">            <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L953">                .<span class="tok-type">u8</span> =&gt; <span class="tok-kw">return</span> self.getIndexWithHeaderGeneric(key, ctx, header, <span class="tok-type">u8</span>),</span>
<span class="line" id="L954">                .<span class="tok-type">u16</span> =&gt; <span class="tok-kw">return</span> self.getIndexWithHeaderGeneric(key, ctx, header, <span class="tok-type">u16</span>),</span>
<span class="line" id="L955">                .<span class="tok-type">u32</span> =&gt; <span class="tok-kw">return</span> self.getIndexWithHeaderGeneric(key, ctx, header, <span class="tok-type">u32</span>),</span>
<span class="line" id="L956">            }</span>
<span class="line" id="L957">        }</span>
<span class="line" id="L958">        <span class="tok-kw">fn</span> <span class="tok-fn">getIndexWithHeaderGeneric</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L959">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L960">            <span class="tok-kw">const</span> slot = self.getSlotByKey(key, ctx, header, I, indexes) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L961">            <span class="tok-kw">return</span> indexes[slot].entry_index;</span>
<span class="line" id="L962">        }</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">        <span class="tok-comment">/// Find the value associated with a key</span></span>
<span class="line" id="L965">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: K) ?V {</span>
<span class="line" id="L966">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L967">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getContext instead.&quot;</span>);</span>
<span class="line" id="L968">            <span class="tok-kw">return</span> self.getContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L969">        }</span>
<span class="line" id="L970">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getContext</span>(self: Self, key: K, ctx: Context) ?V {</span>
<span class="line" id="L971">            <span class="tok-kw">return</span> self.getAdapted(key, ctx);</span>
<span class="line" id="L972">        }</span>
<span class="line" id="L973">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?V {</span>
<span class="line" id="L974">            <span class="tok-kw">const</span> index = self.getIndexAdapted(key, ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L975">            <span class="tok-kw">return</span> self.values()[index];</span>
<span class="line" id="L976">        }</span>
<span class="line" id="L977"></span>
<span class="line" id="L978">        <span class="tok-comment">/// Find a pointer to the value associated with a key</span></span>
<span class="line" id="L979">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: Self, key: K) ?*V {</span>
<span class="line" id="L980">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L981">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getPtrContext instead.&quot;</span>);</span>
<span class="line" id="L982">            <span class="tok-kw">return</span> self.getPtrContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L983">        }</span>
<span class="line" id="L984">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrContext</span>(self: Self, key: K, ctx: Context) ?*V {</span>
<span class="line" id="L985">            <span class="tok-kw">return</span> self.getPtrAdapted(key, ctx);</span>
<span class="line" id="L986">        }</span>
<span class="line" id="L987">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*V {</span>
<span class="line" id="L988">            <span class="tok-kw">const</span> index = self.getIndexAdapted(key, ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L989">            <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L990">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-builtin">@as</span>(*V, <span class="tok-null">undefined</span>) <span class="tok-kw">else</span> &amp;self.values()[index];</span>
<span class="line" id="L991">        }</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">        <span class="tok-comment">/// Find the actual key associated with an adapted key</span></span>
<span class="line" id="L994">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKey</span>(self: Self, key: K) ?K {</span>
<span class="line" id="L995">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L996">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getKeyContext instead.&quot;</span>);</span>
<span class="line" id="L997">            <span class="tok-kw">return</span> self.getKeyContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L998">        }</span>
<span class="line" id="L999">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyContext</span>(self: Self, key: K, ctx: Context) ?K {</span>
<span class="line" id="L1000">            <span class="tok-kw">return</span> self.getKeyAdapted(key, ctx);</span>
<span class="line" id="L1001">        }</span>
<span class="line" id="L1002">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?K {</span>
<span class="line" id="L1003">            <span class="tok-kw">const</span> index = self.getIndexAdapted(key, ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1004">            <span class="tok-kw">return</span> self.keys()[index];</span>
<span class="line" id="L1005">        }</span>
<span class="line" id="L1006"></span>
<span class="line" id="L1007">        <span class="tok-comment">/// Find a pointer to the actual key associated with an adapted key</span></span>
<span class="line" id="L1008">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtr</span>(self: Self, key: K) ?*K {</span>
<span class="line" id="L1009">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1010">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call getKeyPtrContext instead.&quot;</span>);</span>
<span class="line" id="L1011">            <span class="tok-kw">return</span> self.getKeyPtrContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1012">        }</span>
<span class="line" id="L1013">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrContext</span>(self: Self, key: K, ctx: Context) ?*K {</span>
<span class="line" id="L1014">            <span class="tok-kw">return</span> self.getKeyPtrAdapted(key, ctx);</span>
<span class="line" id="L1015">        }</span>
<span class="line" id="L1016">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getKeyPtrAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?*K {</span>
<span class="line" id="L1017">            <span class="tok-kw">const</span> index = self.getIndexAdapted(key, ctx) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1018">            <span class="tok-kw">return</span> &amp;self.keys()[index];</span>
<span class="line" id="L1019">        }</span>
<span class="line" id="L1020"></span>
<span class="line" id="L1021">        <span class="tok-comment">/// Check whether a key is stored in the map</span></span>
<span class="line" id="L1022">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1023">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1024">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call containsContext instead.&quot;</span>);</span>
<span class="line" id="L1025">            <span class="tok-kw">return</span> self.containsContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1026">        }</span>
<span class="line" id="L1027">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsContext</span>(self: Self, key: K, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1028">            <span class="tok-kw">return</span> self.containsAdapted(key, ctx);</span>
<span class="line" id="L1029">        }</span>
<span class="line" id="L1030">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">containsAdapted</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1031">            <span class="tok-kw">return</span> self.getIndexAdapted(key, ctx) != <span class="tok-null">null</span>;</span>
<span class="line" id="L1032">        }</span>
<span class="line" id="L1033"></span>
<span class="line" id="L1034">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1035">        <span class="tok-comment">/// the hash map, and then returned from this function. The entry is</span></span>
<span class="line" id="L1036">        <span class="tok-comment">/// removed from the underlying array by swapping it with the last</span></span>
<span class="line" id="L1037">        <span class="tok-comment">/// element.</span></span>
<span class="line" id="L1038">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L1039">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1040">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchSwapRemoveContext instead.&quot;</span>);</span>
<span class="line" id="L1041">            <span class="tok-kw">return</span> self.fetchSwapRemoveContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1042">        }</span>
<span class="line" id="L1043">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemoveContext</span>(self: *Self, key: K, ctx: Context) ?KV {</span>
<span class="line" id="L1044">            <span class="tok-kw">return</span> self.fetchSwapRemoveContextAdapted(key, ctx, ctx);</span>
<span class="line" id="L1045">        }</span>
<span class="line" id="L1046">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L1047">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1048">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchSwapRemoveContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L1049">            <span class="tok-kw">return</span> self.fetchSwapRemoveContextAdapted(key, ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1050">        }</span>
<span class="line" id="L1051">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchSwapRemoveContextAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) ?KV {</span>
<span class="line" id="L1052">            <span class="tok-kw">return</span> self.fetchRemoveByKey(key, key_ctx, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .swap);</span>
<span class="line" id="L1053">        }</span>
<span class="line" id="L1054"></span>
<span class="line" id="L1055">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1056">        <span class="tok-comment">/// the hash map, and then returned from this function. The entry is</span></span>
<span class="line" id="L1057">        <span class="tok-comment">/// removed from the underlying array by shifting all elements forward</span></span>
<span class="line" id="L1058">        <span class="tok-comment">/// thereby maintaining the current ordering.</span></span>
<span class="line" id="L1059">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemove</span>(self: *Self, key: K) ?KV {</span>
<span class="line" id="L1060">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1061">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchOrderedRemoveContext instead.&quot;</span>);</span>
<span class="line" id="L1062">            <span class="tok-kw">return</span> self.fetchOrderedRemoveContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1063">        }</span>
<span class="line" id="L1064">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemoveContext</span>(self: *Self, key: K, ctx: Context) ?KV {</span>
<span class="line" id="L1065">            <span class="tok-kw">return</span> self.fetchOrderedRemoveContextAdapted(key, ctx, ctx);</span>
<span class="line" id="L1066">        }</span>
<span class="line" id="L1067">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) ?KV {</span>
<span class="line" id="L1068">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1069">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call fetchOrderedRemoveContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L1070">            <span class="tok-kw">return</span> self.fetchOrderedRemoveContextAdapted(key, ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1071">        }</span>
<span class="line" id="L1072">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchOrderedRemoveContextAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) ?KV {</span>
<span class="line" id="L1073">            <span class="tok-kw">return</span> self.fetchRemoveByKey(key, key_ctx, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .ordered);</span>
<span class="line" id="L1074">        }</span>
<span class="line" id="L1075"></span>
<span class="line" id="L1076">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1077">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L1078">        <span class="tok-comment">/// by swapping it with the last element.  Returns true if an entry</span></span>
<span class="line" id="L1079">        <span class="tok-comment">/// was removed, false otherwise.</span></span>
<span class="line" id="L1080">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1081">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1082">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call swapRemoveContext instead.&quot;</span>);</span>
<span class="line" id="L1083">            <span class="tok-kw">return</span> self.swapRemoveContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1084">        }</span>
<span class="line" id="L1085">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveContext</span>(self: *Self, key: K, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1086">            <span class="tok-kw">return</span> self.swapRemoveContextAdapted(key, ctx, ctx);</span>
<span class="line" id="L1087">        }</span>
<span class="line" id="L1088">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1089">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1090">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call swapRemoveContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L1091">            <span class="tok-kw">return</span> self.swapRemoveContextAdapted(key, ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1092">        }</span>
<span class="line" id="L1093">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveContextAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1094">            <span class="tok-kw">return</span> self.removeByKey(key, key_ctx, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .swap);</span>
<span class="line" id="L1095">        }</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097">        <span class="tok-comment">/// If there is an `Entry` with a matching key, it is deleted from</span></span>
<span class="line" id="L1098">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L1099">        <span class="tok-comment">/// by shifting all elements forward, thereby maintaining the</span></span>
<span class="line" id="L1100">        <span class="tok-comment">/// current ordering.  Returns true if an entry was removed, false otherwise.</span></span>
<span class="line" id="L1101">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemove</span>(self: *Self, key: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1102">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Context) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1103">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call orderedRemoveContext instead.&quot;</span>);</span>
<span class="line" id="L1104">            <span class="tok-kw">return</span> self.orderedRemoveContext(key, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1105">        }</span>
<span class="line" id="L1106">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveContext</span>(self: *Self, key: K, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1107">            <span class="tok-kw">return</span> self.orderedRemoveContextAdapted(key, ctx, ctx);</span>
<span class="line" id="L1108">        }</span>
<span class="line" id="L1109">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1110">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1111">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call orderedRemoveContextAdapted instead.&quot;</span>);</span>
<span class="line" id="L1112">            <span class="tok-kw">return</span> self.orderedRemoveContextAdapted(key, ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1113">        }</span>
<span class="line" id="L1114">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveContextAdapted</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: Context) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1115">            <span class="tok-kw">return</span> self.removeByKey(key, key_ctx, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .ordered);</span>
<span class="line" id="L1116">        }</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">        <span class="tok-comment">/// Deletes the item at the specified index in `entries` from</span></span>
<span class="line" id="L1119">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L1120">        <span class="tok-comment">/// by swapping it with the last element.</span></span>
<span class="line" id="L1121">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveAt</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1122">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1123">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call swapRemoveAtContext instead.&quot;</span>);</span>
<span class="line" id="L1124">            <span class="tok-kw">return</span> self.swapRemoveAtContext(index, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1125">        }</span>
<span class="line" id="L1126">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">swapRemoveAtContext</span>(self: *Self, index: <span class="tok-type">usize</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1127">            self.removeByIndex(index, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .swap);</span>
<span class="line" id="L1128">        }</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">        <span class="tok-comment">/// Deletes the item at the specified index in `entries` from</span></span>
<span class="line" id="L1131">        <span class="tok-comment">/// the hash map. The entry is removed from the underlying array</span></span>
<span class="line" id="L1132">        <span class="tok-comment">/// by shifting all elements forward, thereby maintaining the</span></span>
<span class="line" id="L1133">        <span class="tok-comment">/// current ordering.</span></span>
<span class="line" id="L1134">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveAt</span>(self: *Self, index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1135">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1136">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call orderedRemoveAtContext instead.&quot;</span>);</span>
<span class="line" id="L1137">            <span class="tok-kw">return</span> self.orderedRemoveAtContext(index, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1138">        }</span>
<span class="line" id="L1139">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderedRemoveAtContext</span>(self: *Self, index: <span class="tok-type">usize</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1140">            self.removeByIndex(index, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, .ordered);</span>
<span class="line" id="L1141">        }</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143">        <span class="tok-comment">/// Create a copy of the hash map which can be modified separately.</span></span>
<span class="line" id="L1144">        <span class="tok-comment">/// The copy uses the same context and allocator as this instance.</span></span>
<span class="line" id="L1145">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: Self, allocator: Allocator) !Self {</span>
<span class="line" id="L1146">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1147">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call cloneContext instead.&quot;</span>);</span>
<span class="line" id="L1148">            <span class="tok-kw">return</span> self.cloneContext(allocator, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1149">        }</span>
<span class="line" id="L1150">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneContext</span>(self: Self, allocator: Allocator, ctx: Context) !Self {</span>
<span class="line" id="L1151">            <span class="tok-kw">var</span> other: Self = .{};</span>
<span class="line" id="L1152">            other.entries = <span class="tok-kw">try</span> self.entries.clone(allocator);</span>
<span class="line" id="L1153">            <span class="tok-kw">errdefer</span> other.entries.deinit(allocator);</span>
<span class="line" id="L1154"></span>
<span class="line" id="L1155">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L1156">                <span class="tok-kw">const</span> new_header = <span class="tok-kw">try</span> IndexHeader.alloc(allocator, header.bit_index);</span>
<span class="line" id="L1157">                other.insertAllEntriesIntoNewHeader(<span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, new_header);</span>
<span class="line" id="L1158">                other.index_header = new_header;</span>
<span class="line" id="L1159">            }</span>
<span class="line" id="L1160">            <span class="tok-kw">return</span> other;</span>
<span class="line" id="L1161">        }</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163">        <span class="tok-comment">/// Rebuilds the key indexes. If the underlying entries has been modified directly, users</span></span>
<span class="line" id="L1164">        <span class="tok-comment">/// can call `reIndex` to update the indexes to account for these new entries.</span></span>
<span class="line" id="L1165">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reIndex</span>(self: *Self, allocator: Allocator) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1166">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1167">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call reIndexContext instead.&quot;</span>);</span>
<span class="line" id="L1168">            <span class="tok-kw">return</span> self.reIndexContext(allocator, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1169">        }</span>
<span class="line" id="L1170">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reIndexContext</span>(self: *Self, allocator: Allocator, ctx: Context) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1171">            <span class="tok-kw">if</span> (self.entries.capacity &lt;= linear_scan_max) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1172">            <span class="tok-comment">// We're going to rebuild the index header and replace the existing one (if any). The</span>
</span>
<span class="line" id="L1173">            <span class="tok-comment">// indexes should sized such that they will be at most 60% full.</span>
</span>
<span class="line" id="L1174">            <span class="tok-kw">const</span> bit_index = <span class="tok-kw">try</span> IndexHeader.findBitIndex(self.entries.capacity);</span>
<span class="line" id="L1175">            <span class="tok-kw">const</span> new_header = <span class="tok-kw">try</span> IndexHeader.alloc(allocator, bit_index);</span>
<span class="line" id="L1176">            <span class="tok-kw">if</span> (self.index_header) |header| header.free(allocator);</span>
<span class="line" id="L1177">            self.insertAllEntriesIntoNewHeader(<span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, new_header);</span>
<span class="line" id="L1178">            self.index_header = new_header;</span>
<span class="line" id="L1179">        }</span>
<span class="line" id="L1180"></span>
<span class="line" id="L1181">        <span class="tok-comment">/// Sorts the entries and then rebuilds the index.</span></span>
<span class="line" id="L1182">        <span class="tok-comment">/// `sort_ctx` must have this method:</span></span>
<span class="line" id="L1183">        <span class="tok-comment">/// `fn lessThan(ctx: @TypeOf(ctx), a_index: usize, b_index: usize) bool`</span></span>
<span class="line" id="L1184">        <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">sort</span>(self: *Self, sort_ctx: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1185">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1186">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call sortContext instead.&quot;</span>);</span>
<span class="line" id="L1187">            <span class="tok-kw">return</span> self.sortContext(sort_ctx, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1188">        }</span>
<span class="line" id="L1189"></span>
<span class="line" id="L1190">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sortContext</span>(self: *Self, sort_ctx: <span class="tok-kw">anytype</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1191">            self.entries.sort(sort_ctx);</span>
<span class="line" id="L1192">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L1193">            header.reset();</span>
<span class="line" id="L1194">            self.insertAllEntriesIntoNewHeader(<span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, header);</span>
<span class="line" id="L1195">        }</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197">        <span class="tok-comment">/// Shrinks the underlying `Entry` array to `new_len` elements and discards any associated</span></span>
<span class="line" id="L1198">        <span class="tok-comment">/// index entries. Keeps capacity the same.</span></span>
<span class="line" id="L1199">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacity</span>(self: *Self, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1200">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1201">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call shrinkRetainingCapacityContext instead.&quot;</span>);</span>
<span class="line" id="L1202">            <span class="tok-kw">return</span> self.shrinkRetainingCapacityContext(new_len, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1203">        }</span>
<span class="line" id="L1204">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkRetainingCapacityContext</span>(self: *Self, new_len: <span class="tok-type">usize</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1205">            <span class="tok-comment">// Remove index entries from the new length onwards.</span>
</span>
<span class="line" id="L1206">            <span class="tok-comment">// Explicitly choose to ONLY remove index entries and not the underlying array list</span>
</span>
<span class="line" id="L1207">            <span class="tok-comment">// entries as we're going to remove them in the subsequent shrink call.</span>
</span>
<span class="line" id="L1208">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L1209">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = new_len;</span>
<span class="line" id="L1210">                <span class="tok-kw">while</span> (i &lt; self.entries.len) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L1211">                    self.removeFromIndexByIndex(i, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, header);</span>
<span class="line" id="L1212">            }</span>
<span class="line" id="L1213">            self.entries.shrinkRetainingCapacity(new_len);</span>
<span class="line" id="L1214">        }</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216">        <span class="tok-comment">/// Shrinks the underlying `Entry` array to `new_len` elements and discards any associated</span></span>
<span class="line" id="L1217">        <span class="tok-comment">/// index entries. Reduces allocated capacity.</span></span>
<span class="line" id="L1218">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFree</span>(self: *Self, allocator: Allocator, new_len: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1219">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1220">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call shrinkAndFreeContext instead.&quot;</span>);</span>
<span class="line" id="L1221">            <span class="tok-kw">return</span> self.shrinkAndFreeContext(allocator, new_len, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1222">        }</span>
<span class="line" id="L1223">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shrinkAndFreeContext</span>(self: *Self, allocator: Allocator, new_len: <span class="tok-type">usize</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1224">            <span class="tok-comment">// Remove index entries from the new length onwards.</span>
</span>
<span class="line" id="L1225">            <span class="tok-comment">// Explicitly choose to ONLY remove index entries and not the underlying array list</span>
</span>
<span class="line" id="L1226">            <span class="tok-comment">// entries as we're going to remove them in the subsequent shrink call.</span>
</span>
<span class="line" id="L1227">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L1228">                <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = new_len;</span>
<span class="line" id="L1229">                <span class="tok-kw">while</span> (i &lt; self.entries.len) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L1230">                    self.removeFromIndexByIndex(i, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, header);</span>
<span class="line" id="L1231">            }</span>
<span class="line" id="L1232">            self.entries.shrinkAndFree(allocator, new_len);</span>
<span class="line" id="L1233">        }</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235">        <span class="tok-comment">/// Removes the last inserted `Entry` in the hash map and returns it.</span></span>
<span class="line" id="L1236">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pop</span>(self: *Self) KV {</span>
<span class="line" id="L1237">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1238">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call popContext instead.&quot;</span>);</span>
<span class="line" id="L1239">            <span class="tok-kw">return</span> self.popContext(<span class="tok-null">undefined</span>);</span>
<span class="line" id="L1240">        }</span>
<span class="line" id="L1241">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popContext</span>(self: *Self, ctx: Context) KV {</span>
<span class="line" id="L1242">            <span class="tok-kw">const</span> item = self.entries.get(self.entries.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L1243">            <span class="tok-kw">if</span> (self.index_header) |header|</span>
<span class="line" id="L1244">                self.removeFromIndexByIndex(self.entries.len - <span class="tok-number">1</span>, <span class="tok-kw">if</span> (store_hash) {} <span class="tok-kw">else</span> ctx, header);</span>
<span class="line" id="L1245">            self.entries.len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1246">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1247">                .key = item.key,</span>
<span class="line" id="L1248">                .value = item.value,</span>
<span class="line" id="L1249">            };</span>
<span class="line" id="L1250">        }</span>
<span class="line" id="L1251"></span>
<span class="line" id="L1252">        <span class="tok-comment">/// Removes the last inserted `Entry` in the hash map and returns it if count is nonzero.</span></span>
<span class="line" id="L1253">        <span class="tok-comment">/// Otherwise returns null.</span></span>
<span class="line" id="L1254">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNull</span>(self: *Self) ?KV {</span>
<span class="line" id="L1255">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1256">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call popContext instead.&quot;</span>);</span>
<span class="line" id="L1257">            <span class="tok-kw">return</span> self.popOrNullContext(<span class="tok-null">undefined</span>);</span>
<span class="line" id="L1258">        }</span>
<span class="line" id="L1259">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">popOrNullContext</span>(self: *Self, ctx: Context) ?KV {</span>
<span class="line" id="L1260">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.entries.len == <span class="tok-number">0</span>) <span class="tok-null">null</span> <span class="tok-kw">else</span> self.popContext(ctx);</span>
<span class="line" id="L1261">        }</span>
<span class="line" id="L1262"></span>
<span class="line" id="L1263">        <span class="tok-comment">// ------------------ No pub fns below this point ------------------</span>
</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265">        <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemoveByKey</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: ByIndexContext, <span class="tok-kw">comptime</span> removal_type: RemovalType) ?KV {</span>
<span class="line" id="L1266">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1267">                <span class="tok-comment">// Linear scan.</span>
</span>
<span class="line" id="L1268">                <span class="tok-kw">const</span> key_hash = <span class="tok-kw">if</span> (store_hash) key_ctx.hash(key) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1269">                <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1270">                <span class="tok-kw">const</span> hashes_array = <span class="tok-kw">if</span> (store_hash) slice.items(.hash) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1271">                <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L1272">                <span class="tok-kw">for</span> (keys_array) |*item_key, i| {</span>
<span class="line" id="L1273">                    <span class="tok-kw">const</span> hash_match = <span class="tok-kw">if</span> (store_hash) hashes_array[i] == key_hash <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1274">                    <span class="tok-kw">if</span> (hash_match <span class="tok-kw">and</span> key_ctx.eql(key, item_key.*, i)) {</span>
<span class="line" id="L1275">                        <span class="tok-kw">const</span> removed_entry: KV = .{</span>
<span class="line" id="L1276">                            .key = keys_array[i],</span>
<span class="line" id="L1277">                            .value = slice.items(.value)[i],</span>
<span class="line" id="L1278">                        };</span>
<span class="line" id="L1279">                        <span class="tok-kw">switch</span> (removal_type) {</span>
<span class="line" id="L1280">                            .swap =&gt; self.entries.swapRemove(i),</span>
<span class="line" id="L1281">                            .ordered =&gt; self.entries.orderedRemove(i),</span>
<span class="line" id="L1282">                        }</span>
<span class="line" id="L1283">                        <span class="tok-kw">return</span> removed_entry;</span>
<span class="line" id="L1284">                    }</span>
<span class="line" id="L1285">                }</span>
<span class="line" id="L1286">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1287">            };</span>
<span class="line" id="L1288">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1289">                .<span class="tok-type">u8</span> =&gt; self.fetchRemoveByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u8</span>, removal_type),</span>
<span class="line" id="L1290">                .<span class="tok-type">u16</span> =&gt; self.fetchRemoveByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u16</span>, removal_type),</span>
<span class="line" id="L1291">                .<span class="tok-type">u32</span> =&gt; self.fetchRemoveByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u32</span>, removal_type),</span>
<span class="line" id="L1292">            };</span>
<span class="line" id="L1293">        }</span>
<span class="line" id="L1294">        <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemoveByKeyGeneric</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> removal_type: RemovalType) ?KV {</span>
<span class="line" id="L1295">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1296">            <span class="tok-kw">const</span> entry_index = self.removeFromIndexByKey(key, key_ctx, header, I, indexes) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1297">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1298">            <span class="tok-kw">const</span> removed_entry: KV = .{</span>
<span class="line" id="L1299">                .key = slice.items(.key)[entry_index],</span>
<span class="line" id="L1300">                .value = slice.items(.value)[entry_index],</span>
<span class="line" id="L1301">            };</span>
<span class="line" id="L1302">            self.removeFromArrayAndUpdateIndex(entry_index, ctx, header, I, indexes, removal_type);</span>
<span class="line" id="L1303">            <span class="tok-kw">return</span> removed_entry;</span>
<span class="line" id="L1304">        }</span>
<span class="line" id="L1305"></span>
<span class="line" id="L1306">        <span class="tok-kw">fn</span> <span class="tok-fn">removeByKey</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: ByIndexContext, <span class="tok-kw">comptime</span> removal_type: RemovalType) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1307">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1308">                <span class="tok-comment">// Linear scan.</span>
</span>
<span class="line" id="L1309">                <span class="tok-kw">const</span> key_hash = <span class="tok-kw">if</span> (store_hash) key_ctx.hash(key) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1310">                <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1311">                <span class="tok-kw">const</span> hashes_array = <span class="tok-kw">if</span> (store_hash) slice.items(.hash) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1312">                <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L1313">                <span class="tok-kw">for</span> (keys_array) |*item_key, i| {</span>
<span class="line" id="L1314">                    <span class="tok-kw">const</span> hash_match = <span class="tok-kw">if</span> (store_hash) hashes_array[i] == key_hash <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1315">                    <span class="tok-kw">if</span> (hash_match <span class="tok-kw">and</span> key_ctx.eql(key, item_key.*, i)) {</span>
<span class="line" id="L1316">                        <span class="tok-kw">switch</span> (removal_type) {</span>
<span class="line" id="L1317">                            .swap =&gt; self.entries.swapRemove(i),</span>
<span class="line" id="L1318">                            .ordered =&gt; self.entries.orderedRemove(i),</span>
<span class="line" id="L1319">                        }</span>
<span class="line" id="L1320">                        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1321">                    }</span>
<span class="line" id="L1322">                }</span>
<span class="line" id="L1323">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1324">            };</span>
<span class="line" id="L1325">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1326">                .<span class="tok-type">u8</span> =&gt; self.removeByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u8</span>, removal_type),</span>
<span class="line" id="L1327">                .<span class="tok-type">u16</span> =&gt; self.removeByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u16</span>, removal_type),</span>
<span class="line" id="L1328">                .<span class="tok-type">u32</span> =&gt; self.removeByKeyGeneric(key, key_ctx, ctx, header, <span class="tok-type">u32</span>, removal_type),</span>
<span class="line" id="L1329">            };</span>
<span class="line" id="L1330">        }</span>
<span class="line" id="L1331">        <span class="tok-kw">fn</span> <span class="tok-fn">removeByKeyGeneric</span>(self: *Self, key: <span class="tok-kw">anytype</span>, key_ctx: <span class="tok-kw">anytype</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> removal_type: RemovalType) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1332">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1333">            <span class="tok-kw">const</span> entry_index = self.removeFromIndexByKey(key, key_ctx, header, I, indexes) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1334">            self.removeFromArrayAndUpdateIndex(entry_index, ctx, header, I, indexes, removal_type);</span>
<span class="line" id="L1335">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1336">        }</span>
<span class="line" id="L1337"></span>
<span class="line" id="L1338">        <span class="tok-kw">fn</span> <span class="tok-fn">removeByIndex</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, <span class="tok-kw">comptime</span> removal_type: RemovalType) <span class="tok-type">void</span> {</span>
<span class="line" id="L1339">            assert(entry_index &lt; self.entries.len);</span>
<span class="line" id="L1340">            <span class="tok-kw">const</span> header = self.index_header <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L1341">                <span class="tok-kw">switch</span> (removal_type) {</span>
<span class="line" id="L1342">                    .swap =&gt; self.entries.swapRemove(entry_index),</span>
<span class="line" id="L1343">                    .ordered =&gt; self.entries.orderedRemove(entry_index),</span>
<span class="line" id="L1344">                }</span>
<span class="line" id="L1345">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L1346">            };</span>
<span class="line" id="L1347">            <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1348">                .<span class="tok-type">u8</span> =&gt; self.removeByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u8</span>, removal_type),</span>
<span class="line" id="L1349">                .<span class="tok-type">u16</span> =&gt; self.removeByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u16</span>, removal_type),</span>
<span class="line" id="L1350">                .<span class="tok-type">u32</span> =&gt; self.removeByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u32</span>, removal_type),</span>
<span class="line" id="L1351">            }</span>
<span class="line" id="L1352">        }</span>
<span class="line" id="L1353">        <span class="tok-kw">fn</span> <span class="tok-fn">removeByIndexGeneric</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> removal_type: RemovalType) <span class="tok-type">void</span> {</span>
<span class="line" id="L1354">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1355">            self.removeFromIndexByIndexGeneric(entry_index, ctx, header, I, indexes);</span>
<span class="line" id="L1356">            self.removeFromArrayAndUpdateIndex(entry_index, ctx, header, I, indexes, removal_type);</span>
<span class="line" id="L1357">        }</span>
<span class="line" id="L1358"></span>
<span class="line" id="L1359">        <span class="tok-kw">fn</span> <span class="tok-fn">removeFromArrayAndUpdateIndex</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I), <span class="tok-kw">comptime</span> removal_type: RemovalType) <span class="tok-type">void</span> {</span>
<span class="line" id="L1360">            <span class="tok-kw">const</span> last_index = self.entries.len - <span class="tok-number">1</span>; <span class="tok-comment">// overflow =&gt; remove from empty map</span>
</span>
<span class="line" id="L1361">            <span class="tok-kw">switch</span> (removal_type) {</span>
<span class="line" id="L1362">                .swap =&gt; {</span>
<span class="line" id="L1363">                    <span class="tok-kw">if</span> (last_index != entry_index) {</span>
<span class="line" id="L1364">                        <span class="tok-comment">// Because of the swap remove, now we need to update the index that was</span>
</span>
<span class="line" id="L1365">                        <span class="tok-comment">// pointing to the last entry and is now pointing to this removed item slot.</span>
</span>
<span class="line" id="L1366">                        self.updateEntryIndex(header, last_index, entry_index, ctx, I, indexes);</span>
<span class="line" id="L1367">                    }</span>
<span class="line" id="L1368">                    <span class="tok-comment">// updateEntryIndex reads from the old entry index,</span>
</span>
<span class="line" id="L1369">                    <span class="tok-comment">// so it needs to run before removal.</span>
</span>
<span class="line" id="L1370">                    self.entries.swapRemove(entry_index);</span>
<span class="line" id="L1371">                },</span>
<span class="line" id="L1372">                .ordered =&gt; {</span>
<span class="line" id="L1373">                    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = entry_index;</span>
<span class="line" id="L1374">                    <span class="tok-kw">while</span> (i &lt; last_index) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1375">                        <span class="tok-comment">// Because of the ordered remove, everything from the entry index onwards has</span>
</span>
<span class="line" id="L1376">                        <span class="tok-comment">// been shifted forward so we'll need to update the index entries.</span>
</span>
<span class="line" id="L1377">                        self.updateEntryIndex(header, i + <span class="tok-number">1</span>, i, ctx, I, indexes);</span>
<span class="line" id="L1378">                    }</span>
<span class="line" id="L1379">                    <span class="tok-comment">// updateEntryIndex reads from the old entry index,</span>
</span>
<span class="line" id="L1380">                    <span class="tok-comment">// so it needs to run before removal.</span>
</span>
<span class="line" id="L1381">                    self.entries.orderedRemove(entry_index);</span>
<span class="line" id="L1382">                },</span>
<span class="line" id="L1383">            }</span>
<span class="line" id="L1384">        }</span>
<span class="line" id="L1385"></span>
<span class="line" id="L1386">        <span class="tok-kw">fn</span> <span class="tok-fn">updateEntryIndex</span>(</span>
<span class="line" id="L1387">            self: *Self,</span>
<span class="line" id="L1388">            header: *IndexHeader,</span>
<span class="line" id="L1389">            old_entry_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1390">            new_entry_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1391">            ctx: ByIndexContext,</span>
<span class="line" id="L1392">            <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>,</span>
<span class="line" id="L1393">            indexes: []Index(I),</span>
<span class="line" id="L1394">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L1395">            <span class="tok-kw">const</span> slot = self.getSlotByIndex(old_entry_index, ctx, header, I, indexes);</span>
<span class="line" id="L1396">            indexes[slot].entry_index = <span class="tok-builtin">@intCast</span>(I, new_entry_index);</span>
<span class="line" id="L1397">        }</span>
<span class="line" id="L1398"></span>
<span class="line" id="L1399">        <span class="tok-kw">fn</span> <span class="tok-fn">removeFromIndexByIndex</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, header: *IndexHeader) <span class="tok-type">void</span> {</span>
<span class="line" id="L1400">            <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1401">                .<span class="tok-type">u8</span> =&gt; self.removeFromIndexByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u8</span>, header.indexes(<span class="tok-type">u8</span>)),</span>
<span class="line" id="L1402">                .<span class="tok-type">u16</span> =&gt; self.removeFromIndexByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u16</span>, header.indexes(<span class="tok-type">u16</span>)),</span>
<span class="line" id="L1403">                .<span class="tok-type">u32</span> =&gt; self.removeFromIndexByIndexGeneric(entry_index, ctx, header, <span class="tok-type">u32</span>, header.indexes(<span class="tok-type">u32</span>)),</span>
<span class="line" id="L1404">            }</span>
<span class="line" id="L1405">        }</span>
<span class="line" id="L1406">        <span class="tok-kw">fn</span> <span class="tok-fn">removeFromIndexByIndexGeneric</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I)) <span class="tok-type">void</span> {</span>
<span class="line" id="L1407">            <span class="tok-kw">const</span> slot = self.getSlotByIndex(entry_index, ctx, header, I, indexes);</span>
<span class="line" id="L1408">            removeSlot(slot, header, I, indexes);</span>
<span class="line" id="L1409">        }</span>
<span class="line" id="L1410"></span>
<span class="line" id="L1411">        <span class="tok-kw">fn</span> <span class="tok-fn">removeFromIndexByKey</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I)) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1412">            <span class="tok-kw">const</span> slot = self.getSlotByKey(key, ctx, header, I, indexes) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1413">            <span class="tok-kw">const</span> removed_entry_index = indexes[slot].entry_index;</span>
<span class="line" id="L1414">            removeSlot(slot, header, I, indexes);</span>
<span class="line" id="L1415">            <span class="tok-kw">return</span> removed_entry_index;</span>
<span class="line" id="L1416">        }</span>
<span class="line" id="L1417"></span>
<span class="line" id="L1418">        <span class="tok-kw">fn</span> <span class="tok-fn">removeSlot</span>(removed_slot: <span class="tok-type">usize</span>, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I)) <span class="tok-type">void</span> {</span>
<span class="line" id="L1419">            <span class="tok-kw">const</span> start_index = removed_slot +% <span class="tok-number">1</span>;</span>
<span class="line" id="L1420">            <span class="tok-kw">const</span> end_index = start_index +% indexes.len;</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422">            <span class="tok-kw">var</span> last_slot = removed_slot;</span>
<span class="line" id="L1423">            <span class="tok-kw">var</span> index: <span class="tok-type">usize</span> = start_index;</span>
<span class="line" id="L1424">            <span class="tok-kw">while</span> (index != end_index) : (index +%= <span class="tok-number">1</span>) {</span>
<span class="line" id="L1425">                <span class="tok-kw">const</span> slot = header.constrainIndex(index);</span>
<span class="line" id="L1426">                <span class="tok-kw">const</span> slot_data = indexes[slot];</span>
<span class="line" id="L1427">                <span class="tok-kw">if</span> (slot_data.isEmpty() <span class="tok-kw">or</span> slot_data.distance_from_start_index == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1428">                    indexes[last_slot].setEmpty();</span>
<span class="line" id="L1429">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L1430">                }</span>
<span class="line" id="L1431">                indexes[last_slot] = .{</span>
<span class="line" id="L1432">                    .entry_index = slot_data.entry_index,</span>
<span class="line" id="L1433">                    .distance_from_start_index = slot_data.distance_from_start_index - <span class="tok-number">1</span>,</span>
<span class="line" id="L1434">                };</span>
<span class="line" id="L1435">                last_slot = slot;</span>
<span class="line" id="L1436">            }</span>
<span class="line" id="L1437">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1438">        }</span>
<span class="line" id="L1439"></span>
<span class="line" id="L1440">        <span class="tok-kw">fn</span> <span class="tok-fn">getSlotByIndex</span>(self: *Self, entry_index: <span class="tok-type">usize</span>, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I)) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1441">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1442">            <span class="tok-kw">const</span> h = <span class="tok-kw">if</span> (store_hash) slice.items(.hash)[entry_index] <span class="tok-kw">else</span> checkedHash(ctx, slice.items(.key)[entry_index]);</span>
<span class="line" id="L1443">            <span class="tok-kw">const</span> start_index = safeTruncate(<span class="tok-type">usize</span>, h);</span>
<span class="line" id="L1444">            <span class="tok-kw">const</span> end_index = start_index +% indexes.len;</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446">            <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L1447">            <span class="tok-kw">var</span> distance_from_start_index: I = <span class="tok-number">0</span>;</span>
<span class="line" id="L1448">            <span class="tok-kw">while</span> (index != end_index) : ({</span>
<span class="line" id="L1449">                index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1450">                distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1451">            }) {</span>
<span class="line" id="L1452">                <span class="tok-kw">const</span> slot = header.constrainIndex(index);</span>
<span class="line" id="L1453">                <span class="tok-kw">const</span> slot_data = indexes[slot];</span>
<span class="line" id="L1454"></span>
<span class="line" id="L1455">                <span class="tok-comment">// This is the fundamental property of the array hash map index.  If this</span>
</span>
<span class="line" id="L1456">                <span class="tok-comment">// assert fails, it probably means that the entry was not in the index.</span>
</span>
<span class="line" id="L1457">                assert(!slot_data.isEmpty());</span>
<span class="line" id="L1458">                assert(slot_data.distance_from_start_index &gt;= distance_from_start_index);</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460">                <span class="tok-kw">if</span> (slot_data.entry_index == entry_index) {</span>
<span class="line" id="L1461">                    <span class="tok-kw">return</span> slot;</span>
<span class="line" id="L1462">                }</span>
<span class="line" id="L1463">            }</span>
<span class="line" id="L1464">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1465">        }</span>
<span class="line" id="L1466"></span>
<span class="line" id="L1467">        <span class="tok-comment">/// Must `ensureTotalCapacity`/`ensureUnusedCapacity` before calling this.</span></span>
<span class="line" id="L1468">        <span class="tok-kw">fn</span> <span class="tok-fn">getOrPutInternal</span>(self: *Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) GetOrPutResult {</span>
<span class="line" id="L1469">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1470">            <span class="tok-kw">const</span> hashes_array = <span class="tok-kw">if</span> (store_hash) slice.items(.hash) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1471">            <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L1472">            <span class="tok-kw">const</span> values_array = slice.items(.value);</span>
<span class="line" id="L1473">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1474"></span>
<span class="line" id="L1475">            <span class="tok-kw">const</span> h = checkedHash(ctx, key);</span>
<span class="line" id="L1476">            <span class="tok-kw">const</span> start_index = safeTruncate(<span class="tok-type">usize</span>, h);</span>
<span class="line" id="L1477">            <span class="tok-kw">const</span> end_index = start_index +% indexes.len;</span>
<span class="line" id="L1478"></span>
<span class="line" id="L1479">            <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L1480">            <span class="tok-kw">var</span> distance_from_start_index: I = <span class="tok-number">0</span>;</span>
<span class="line" id="L1481">            <span class="tok-kw">while</span> (index != end_index) : ({</span>
<span class="line" id="L1482">                index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1483">                distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1484">            }) {</span>
<span class="line" id="L1485">                <span class="tok-kw">var</span> slot = header.constrainIndex(index);</span>
<span class="line" id="L1486">                <span class="tok-kw">var</span> slot_data = indexes[slot];</span>
<span class="line" id="L1487"></span>
<span class="line" id="L1488">                <span class="tok-comment">// If the slot is empty, there can be no more items in this run.</span>
</span>
<span class="line" id="L1489">                <span class="tok-comment">// We didn't find a matching item, so this must be new.</span>
</span>
<span class="line" id="L1490">                <span class="tok-comment">// Put it in the empty slot.</span>
</span>
<span class="line" id="L1491">                <span class="tok-kw">if</span> (slot_data.isEmpty()) {</span>
<span class="line" id="L1492">                    <span class="tok-kw">const</span> new_index = self.entries.addOneAssumeCapacity();</span>
<span class="line" id="L1493">                    indexes[slot] = .{</span>
<span class="line" id="L1494">                        .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1495">                        .entry_index = <span class="tok-builtin">@intCast</span>(I, new_index),</span>
<span class="line" id="L1496">                    };</span>
<span class="line" id="L1497"></span>
<span class="line" id="L1498">                    <span class="tok-comment">// update the hash if applicable</span>
</span>
<span class="line" id="L1499">                    <span class="tok-kw">if</span> (store_hash) hashes_array.ptr[new_index] = h;</span>
<span class="line" id="L1500"></span>
<span class="line" id="L1501">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1502">                        .found_existing = <span class="tok-null">false</span>,</span>
<span class="line" id="L1503">                        .key_ptr = &amp;keys_array.ptr[new_index],</span>
<span class="line" id="L1504">                        <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L1505">                        .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;values_array.ptr[new_index],</span>
<span class="line" id="L1506">                        .index = new_index,</span>
<span class="line" id="L1507">                    };</span>
<span class="line" id="L1508">                }</span>
<span class="line" id="L1509"></span>
<span class="line" id="L1510">                <span class="tok-comment">// This pointer survives the following append because we call</span>
</span>
<span class="line" id="L1511">                <span class="tok-comment">// entries.ensureTotalCapacity before getOrPutInternal.</span>
</span>
<span class="line" id="L1512">                <span class="tok-kw">const</span> i = slot_data.entry_index;</span>
<span class="line" id="L1513">                <span class="tok-kw">const</span> hash_match = <span class="tok-kw">if</span> (store_hash) h == hashes_array[i] <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1514">                <span class="tok-kw">if</span> (hash_match <span class="tok-kw">and</span> checkedEql(ctx, key, keys_array[i], i)) {</span>
<span class="line" id="L1515">                    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1516">                        .found_existing = <span class="tok-null">true</span>,</span>
<span class="line" id="L1517">                        .key_ptr = &amp;keys_array[slot_data.entry_index],</span>
<span class="line" id="L1518">                        <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L1519">                        .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;values_array[slot_data.entry_index],</span>
<span class="line" id="L1520">                        .index = slot_data.entry_index,</span>
<span class="line" id="L1521">                    };</span>
<span class="line" id="L1522">                }</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524">                <span class="tok-comment">// If the entry is closer to its target than our current distance,</span>
</span>
<span class="line" id="L1525">                <span class="tok-comment">// the entry we are looking for does not exist.  It would be in</span>
</span>
<span class="line" id="L1526">                <span class="tok-comment">// this slot instead if it was here.  So stop looking, and switch</span>
</span>
<span class="line" id="L1527">                <span class="tok-comment">// to insert mode.</span>
</span>
<span class="line" id="L1528">                <span class="tok-kw">if</span> (slot_data.distance_from_start_index &lt; distance_from_start_index) {</span>
<span class="line" id="L1529">                    <span class="tok-comment">// In this case, we did not find the item. We will put a new entry.</span>
</span>
<span class="line" id="L1530">                    <span class="tok-comment">// However, we will use this index for the new entry, and move</span>
</span>
<span class="line" id="L1531">                    <span class="tok-comment">// the previous index down the line, to keep the max distance_from_start_index</span>
</span>
<span class="line" id="L1532">                    <span class="tok-comment">// as small as possible.</span>
</span>
<span class="line" id="L1533">                    <span class="tok-kw">const</span> new_index = self.entries.addOneAssumeCapacity();</span>
<span class="line" id="L1534">                    <span class="tok-kw">if</span> (store_hash) hashes_array.ptr[new_index] = h;</span>
<span class="line" id="L1535">                    indexes[slot] = .{</span>
<span class="line" id="L1536">                        .entry_index = <span class="tok-builtin">@intCast</span>(I, new_index),</span>
<span class="line" id="L1537">                        .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1538">                    };</span>
<span class="line" id="L1539">                    distance_from_start_index = slot_data.distance_from_start_index;</span>
<span class="line" id="L1540">                    <span class="tok-kw">var</span> displaced_index = slot_data.entry_index;</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542">                    <span class="tok-comment">// Find somewhere to put the index we replaced by shifting</span>
</span>
<span class="line" id="L1543">                    <span class="tok-comment">// following indexes backwards.</span>
</span>
<span class="line" id="L1544">                    index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1545">                    distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1546">                    <span class="tok-kw">while</span> (index != end_index) : ({</span>
<span class="line" id="L1547">                        index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1548">                        distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1549">                    }) {</span>
<span class="line" id="L1550">                        slot = header.constrainIndex(index);</span>
<span class="line" id="L1551">                        slot_data = indexes[slot];</span>
<span class="line" id="L1552">                        <span class="tok-kw">if</span> (slot_data.isEmpty()) {</span>
<span class="line" id="L1553">                            indexes[slot] = .{</span>
<span class="line" id="L1554">                                .entry_index = displaced_index,</span>
<span class="line" id="L1555">                                .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1556">                            };</span>
<span class="line" id="L1557">                            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L1558">                                .found_existing = <span class="tok-null">false</span>,</span>
<span class="line" id="L1559">                                .key_ptr = &amp;keys_array.ptr[new_index],</span>
<span class="line" id="L1560">                                <span class="tok-comment">// workaround for #6974</span>
</span>
<span class="line" id="L1561">                                .value_ptr = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(*V) == <span class="tok-number">0</span>) <span class="tok-null">undefined</span> <span class="tok-kw">else</span> &amp;values_array.ptr[new_index],</span>
<span class="line" id="L1562">                                .index = new_index,</span>
<span class="line" id="L1563">                            };</span>
<span class="line" id="L1564">                        }</span>
<span class="line" id="L1565"></span>
<span class="line" id="L1566">                        <span class="tok-kw">if</span> (slot_data.distance_from_start_index &lt; distance_from_start_index) {</span>
<span class="line" id="L1567">                            indexes[slot] = .{</span>
<span class="line" id="L1568">                                .entry_index = displaced_index,</span>
<span class="line" id="L1569">                                .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1570">                            };</span>
<span class="line" id="L1571">                            displaced_index = slot_data.entry_index;</span>
<span class="line" id="L1572">                            distance_from_start_index = slot_data.distance_from_start_index;</span>
<span class="line" id="L1573">                        }</span>
<span class="line" id="L1574">                    }</span>
<span class="line" id="L1575">                    <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1576">                }</span>
<span class="line" id="L1577">            }</span>
<span class="line" id="L1578">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1579">        }</span>
<span class="line" id="L1580"></span>
<span class="line" id="L1581">        <span class="tok-kw">fn</span> <span class="tok-fn">getSlotByKey</span>(self: Self, key: <span class="tok-kw">anytype</span>, ctx: <span class="tok-kw">anytype</span>, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, indexes: []Index(I)) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L1582">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1583">            <span class="tok-kw">const</span> hashes_array = <span class="tok-kw">if</span> (store_hash) slice.items(.hash) <span class="tok-kw">else</span> {};</span>
<span class="line" id="L1584">            <span class="tok-kw">const</span> keys_array = slice.items(.key);</span>
<span class="line" id="L1585">            <span class="tok-kw">const</span> h = checkedHash(ctx, key);</span>
<span class="line" id="L1586"></span>
<span class="line" id="L1587">            <span class="tok-kw">const</span> start_index = safeTruncate(<span class="tok-type">usize</span>, h);</span>
<span class="line" id="L1588">            <span class="tok-kw">const</span> end_index = start_index +% indexes.len;</span>
<span class="line" id="L1589"></span>
<span class="line" id="L1590">            <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L1591">            <span class="tok-kw">var</span> distance_from_start_index: I = <span class="tok-number">0</span>;</span>
<span class="line" id="L1592">            <span class="tok-kw">while</span> (index != end_index) : ({</span>
<span class="line" id="L1593">                index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1594">                distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1595">            }) {</span>
<span class="line" id="L1596">                <span class="tok-kw">const</span> slot = header.constrainIndex(index);</span>
<span class="line" id="L1597">                <span class="tok-kw">const</span> slot_data = indexes[slot];</span>
<span class="line" id="L1598">                <span class="tok-kw">if</span> (slot_data.isEmpty() <span class="tok-kw">or</span> slot_data.distance_from_start_index &lt; distance_from_start_index)</span>
<span class="line" id="L1599">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L1600"></span>
<span class="line" id="L1601">                <span class="tok-kw">const</span> i = slot_data.entry_index;</span>
<span class="line" id="L1602">                <span class="tok-kw">const</span> hash_match = <span class="tok-kw">if</span> (store_hash) h == hashes_array[i] <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1603">                <span class="tok-kw">if</span> (hash_match <span class="tok-kw">and</span> checkedEql(ctx, key, keys_array[i], i))</span>
<span class="line" id="L1604">                    <span class="tok-kw">return</span> slot;</span>
<span class="line" id="L1605">            }</span>
<span class="line" id="L1606">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1607">        }</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609">        <span class="tok-kw">fn</span> <span class="tok-fn">insertAllEntriesIntoNewHeader</span>(self: *Self, ctx: ByIndexContext, header: *IndexHeader) <span class="tok-type">void</span> {</span>
<span class="line" id="L1610">            <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1611">                .<span class="tok-type">u8</span> =&gt; <span class="tok-kw">return</span> self.insertAllEntriesIntoNewHeaderGeneric(ctx, header, <span class="tok-type">u8</span>),</span>
<span class="line" id="L1612">                .<span class="tok-type">u16</span> =&gt; <span class="tok-kw">return</span> self.insertAllEntriesIntoNewHeaderGeneric(ctx, header, <span class="tok-type">u16</span>),</span>
<span class="line" id="L1613">                .<span class="tok-type">u32</span> =&gt; <span class="tok-kw">return</span> self.insertAllEntriesIntoNewHeaderGeneric(ctx, header, <span class="tok-type">u32</span>),</span>
<span class="line" id="L1614">            }</span>
<span class="line" id="L1615">        }</span>
<span class="line" id="L1616">        <span class="tok-kw">fn</span> <span class="tok-fn">insertAllEntriesIntoNewHeaderGeneric</span>(self: *Self, ctx: ByIndexContext, header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1617">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1618">            <span class="tok-kw">const</span> items = <span class="tok-kw">if</span> (store_hash) slice.items(.hash) <span class="tok-kw">else</span> slice.items(.key);</span>
<span class="line" id="L1619">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1620"></span>
<span class="line" id="L1621">            entry_loop: <span class="tok-kw">for</span> (items) |key, i| {</span>
<span class="line" id="L1622">                <span class="tok-kw">const</span> h = <span class="tok-kw">if</span> (store_hash) key <span class="tok-kw">else</span> checkedHash(ctx, key);</span>
<span class="line" id="L1623">                <span class="tok-kw">const</span> start_index = safeTruncate(<span class="tok-type">usize</span>, h);</span>
<span class="line" id="L1624">                <span class="tok-kw">const</span> end_index = start_index +% indexes.len;</span>
<span class="line" id="L1625">                <span class="tok-kw">var</span> index = start_index;</span>
<span class="line" id="L1626">                <span class="tok-kw">var</span> entry_index = <span class="tok-builtin">@intCast</span>(I, i);</span>
<span class="line" id="L1627">                <span class="tok-kw">var</span> distance_from_start_index: I = <span class="tok-number">0</span>;</span>
<span class="line" id="L1628">                <span class="tok-kw">while</span> (index != end_index) : ({</span>
<span class="line" id="L1629">                    index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L1630">                    distance_from_start_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1631">                }) {</span>
<span class="line" id="L1632">                    <span class="tok-kw">const</span> slot = header.constrainIndex(index);</span>
<span class="line" id="L1633">                    <span class="tok-kw">const</span> next_index = indexes[slot];</span>
<span class="line" id="L1634">                    <span class="tok-kw">if</span> (next_index.isEmpty()) {</span>
<span class="line" id="L1635">                        indexes[slot] = .{</span>
<span class="line" id="L1636">                            .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1637">                            .entry_index = entry_index,</span>
<span class="line" id="L1638">                        };</span>
<span class="line" id="L1639">                        <span class="tok-kw">continue</span> :entry_loop;</span>
<span class="line" id="L1640">                    }</span>
<span class="line" id="L1641">                    <span class="tok-kw">if</span> (next_index.distance_from_start_index &lt; distance_from_start_index) {</span>
<span class="line" id="L1642">                        indexes[slot] = .{</span>
<span class="line" id="L1643">                            .distance_from_start_index = distance_from_start_index,</span>
<span class="line" id="L1644">                            .entry_index = entry_index,</span>
<span class="line" id="L1645">                        };</span>
<span class="line" id="L1646">                        distance_from_start_index = next_index.distance_from_start_index;</span>
<span class="line" id="L1647">                        entry_index = next_index.entry_index;</span>
<span class="line" id="L1648">                    }</span>
<span class="line" id="L1649">                }</span>
<span class="line" id="L1650">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1651">            }</span>
<span class="line" id="L1652">        }</span>
<span class="line" id="L1653"></span>
<span class="line" id="L1654">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkedHash</span>(ctx: <span class="tok-kw">anytype</span>, key: <span class="tok-kw">anytype</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1655">            <span class="tok-kw">comptime</span> std.hash_map.verifyContext(<span class="tok-builtin">@TypeOf</span>(ctx), <span class="tok-builtin">@TypeOf</span>(key), K, <span class="tok-type">u32</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L1656">            <span class="tok-comment">// If you get a compile error on the next line, it means that</span>
</span>
<span class="line" id="L1657">            <span class="tok-kw">const</span> hash = ctx.hash(key); <span class="tok-comment">// your generic hash function doesn't accept your key</span>
</span>
<span class="line" id="L1658">            <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(hash) != <span class="tok-type">u32</span>) {</span>
<span class="line" id="L1659">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic hash function that returns the wrong type!\n&quot;</span> ++</span>
<span class="line" id="L1660">                    <span class="tok-builtin">@typeName</span>(<span class="tok-type">u32</span>) ++ <span class="tok-str">&quot; was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(hash)));</span>
<span class="line" id="L1661">            }</span>
<span class="line" id="L1662">            <span class="tok-kw">return</span> hash;</span>
<span class="line" id="L1663">        }</span>
<span class="line" id="L1664">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkedEql</span>(ctx: <span class="tok-kw">anytype</span>, a: <span class="tok-kw">anytype</span>, b: K, b_index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1665">            <span class="tok-kw">comptime</span> std.hash_map.verifyContext(<span class="tok-builtin">@TypeOf</span>(ctx), <span class="tok-builtin">@TypeOf</span>(a), K, <span class="tok-type">u32</span>, <span class="tok-null">true</span>);</span>
<span class="line" id="L1666">            <span class="tok-comment">// If you get a compile error on the next line, it means that</span>
</span>
<span class="line" id="L1667">            <span class="tok-kw">const</span> eql = ctx.eql(a, b, b_index); <span class="tok-comment">// your generic eql function doesn't accept (self, adapt key, K, index)</span>
</span>
<span class="line" id="L1668">            <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(eql) != <span class="tok-type">bool</span>) {</span>
<span class="line" id="L1669">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(ctx)) ++ <span class="tok-str">&quot; has a generic eql function that returns the wrong type!\n&quot;</span> ++</span>
<span class="line" id="L1670">                    <span class="tok-builtin">@typeName</span>(<span class="tok-type">bool</span>) ++ <span class="tok-str">&quot; was expected, but found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(eql)));</span>
<span class="line" id="L1671">            }</span>
<span class="line" id="L1672">            <span class="tok-kw">return</span> eql;</span>
<span class="line" id="L1673">        }</span>
<span class="line" id="L1674"></span>
<span class="line" id="L1675">        <span class="tok-kw">fn</span> <span class="tok-fn">dumpState</span>(self: Self, <span class="tok-kw">comptime</span> keyFmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> valueFmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1676">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(ByIndexContext) != <span class="tok-number">0</span>)</span>
<span class="line" id="L1677">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot infer context &quot;</span> ++ <span class="tok-builtin">@typeName</span>(Context) ++ <span class="tok-str">&quot;, call dumpStateContext instead.&quot;</span>);</span>
<span class="line" id="L1678">            self.dumpStateContext(keyFmt, valueFmt, <span class="tok-null">undefined</span>);</span>
<span class="line" id="L1679">        }</span>
<span class="line" id="L1680">        <span class="tok-kw">fn</span> <span class="tok-fn">dumpStateContext</span>(self: Self, <span class="tok-kw">comptime</span> keyFmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> valueFmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ctx: Context) <span class="tok-type">void</span> {</span>
<span class="line" id="L1681">            <span class="tok-kw">const</span> p = std.debug.print;</span>
<span class="line" id="L1682">            p(<span class="tok-str">&quot;{s}:\n&quot;</span>, .{<span class="tok-builtin">@typeName</span>(Self)});</span>
<span class="line" id="L1683">            <span class="tok-kw">const</span> slice = self.entries.slice();</span>
<span class="line" id="L1684">            <span class="tok-kw">const</span> hash_status = <span class="tok-kw">if</span> (store_hash) <span class="tok-str">&quot;stored&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;computed&quot;</span>;</span>
<span class="line" id="L1685">            p(<span class="tok-str">&quot;  len={} capacity={} hashes {s}\n&quot;</span>, .{ slice.len, slice.capacity, hash_status });</span>
<span class="line" id="L1686">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1687">            <span class="tok-kw">const</span> mask: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (self.index_header) |header| header.mask() <span class="tok-kw">else</span> ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1688">            <span class="tok-kw">while</span> (i &lt; slice.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1689">                <span class="tok-kw">const</span> hash = <span class="tok-kw">if</span> (store_hash) slice.items(.hash)[i] <span class="tok-kw">else</span> checkedHash(ctx, slice.items(.key)[i]);</span>
<span class="line" id="L1690">                <span class="tok-kw">if</span> (store_hash) {</span>
<span class="line" id="L1691">                    p(</span>
<span class="line" id="L1692">                        <span class="tok-str">&quot;  [{}]: key=&quot;</span> ++ keyFmt ++ <span class="tok-str">&quot; value=&quot;</span> ++ valueFmt ++ <span class="tok-str">&quot; hash=0x{x} slot=[0x{x}]\n&quot;</span>,</span>
<span class="line" id="L1693">                        .{ i, slice.items(.key)[i], slice.items(.value)[i], hash, hash &amp; mask },</span>
<span class="line" id="L1694">                    );</span>
<span class="line" id="L1695">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1696">                    p(</span>
<span class="line" id="L1697">                        <span class="tok-str">&quot;  [{}]: key=&quot;</span> ++ keyFmt ++ <span class="tok-str">&quot; value=&quot;</span> ++ valueFmt ++ <span class="tok-str">&quot; slot=[0x{x}]\n&quot;</span>,</span>
<span class="line" id="L1698">                        .{ i, slice.items(.key)[i], slice.items(.value)[i], hash &amp; mask },</span>
<span class="line" id="L1699">                    );</span>
<span class="line" id="L1700">                }</span>
<span class="line" id="L1701">            }</span>
<span class="line" id="L1702">            <span class="tok-kw">if</span> (self.index_header) |header| {</span>
<span class="line" id="L1703">                p(<span class="tok-str">&quot;\n&quot;</span>, .{});</span>
<span class="line" id="L1704">                <span class="tok-kw">switch</span> (header.capacityIndexType()) {</span>
<span class="line" id="L1705">                    .<span class="tok-type">u8</span> =&gt; dumpIndex(header, <span class="tok-type">u8</span>),</span>
<span class="line" id="L1706">                    .<span class="tok-type">u16</span> =&gt; dumpIndex(header, <span class="tok-type">u16</span>),</span>
<span class="line" id="L1707">                    .<span class="tok-type">u32</span> =&gt; dumpIndex(header, <span class="tok-type">u32</span>),</span>
<span class="line" id="L1708">                }</span>
<span class="line" id="L1709">            }</span>
<span class="line" id="L1710">        }</span>
<span class="line" id="L1711">        <span class="tok-kw">fn</span> <span class="tok-fn">dumpIndex</span>(header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1712">            <span class="tok-kw">const</span> p = std.debug.print;</span>
<span class="line" id="L1713">            p(<span class="tok-str">&quot;  index len=0x{x} type={}\n&quot;</span>, .{ header.length(), header.capacityIndexType() });</span>
<span class="line" id="L1714">            <span class="tok-kw">const</span> indexes = header.indexes(I);</span>
<span class="line" id="L1715">            <span class="tok-kw">if</span> (indexes.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1716">            <span class="tok-kw">var</span> is_empty = <span class="tok-null">false</span>;</span>
<span class="line" id="L1717">            <span class="tok-kw">for</span> (indexes) |idx, i| {</span>
<span class="line" id="L1718">                <span class="tok-kw">if</span> (idx.isEmpty()) {</span>
<span class="line" id="L1719">                    is_empty = <span class="tok-null">true</span>;</span>
<span class="line" id="L1720">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1721">                    <span class="tok-kw">if</span> (is_empty) {</span>
<span class="line" id="L1722">                        is_empty = <span class="tok-null">false</span>;</span>
<span class="line" id="L1723">                        p(<span class="tok-str">&quot;  ...\n&quot;</span>, .{});</span>
<span class="line" id="L1724">                    }</span>
<span class="line" id="L1725">                    p(<span class="tok-str">&quot;  [0x{x}]: [{}] +{}\n&quot;</span>, .{ i, idx.entry_index, idx.distance_from_start_index });</span>
<span class="line" id="L1726">                }</span>
<span class="line" id="L1727">            }</span>
<span class="line" id="L1728">            <span class="tok-kw">if</span> (is_empty) {</span>
<span class="line" id="L1729">                p(<span class="tok-str">&quot;  ...\n&quot;</span>, .{});</span>
<span class="line" id="L1730">            }</span>
<span class="line" id="L1731">        }</span>
<span class="line" id="L1732">    };</span>
<span class="line" id="L1733">}</span>
<span class="line" id="L1734"></span>
<span class="line" id="L1735"><span class="tok-kw">const</span> CapacityIndexType = <span class="tok-kw">enum</span> { <span class="tok-type">u8</span>, <span class="tok-type">u16</span>, <span class="tok-type">u32</span> };</span>
<span class="line" id="L1736"></span>
<span class="line" id="L1737"><span class="tok-kw">fn</span> <span class="tok-fn">capacityIndexType</span>(bit_index: <span class="tok-type">u8</span>) CapacityIndexType {</span>
<span class="line" id="L1738">    <span class="tok-kw">if</span> (bit_index &lt;= <span class="tok-number">8</span>)</span>
<span class="line" id="L1739">        <span class="tok-kw">return</span> .<span class="tok-type">u8</span>;</span>
<span class="line" id="L1740">    <span class="tok-kw">if</span> (bit_index &lt;= <span class="tok-number">16</span>)</span>
<span class="line" id="L1741">        <span class="tok-kw">return</span> .<span class="tok-type">u16</span>;</span>
<span class="line" id="L1742">    assert(bit_index &lt;= <span class="tok-number">32</span>);</span>
<span class="line" id="L1743">    <span class="tok-kw">return</span> .<span class="tok-type">u32</span>;</span>
<span class="line" id="L1744">}</span>
<span class="line" id="L1745"></span>
<span class="line" id="L1746"><span class="tok-kw">fn</span> <span class="tok-fn">capacityIndexSize</span>(bit_index: <span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1747">    <span class="tok-kw">switch</span> (capacityIndexType(bit_index)) {</span>
<span class="line" id="L1748">        .<span class="tok-type">u8</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(Index(<span class="tok-type">u8</span>)),</span>
<span class="line" id="L1749">        .<span class="tok-type">u16</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(Index(<span class="tok-type">u16</span>)),</span>
<span class="line" id="L1750">        .<span class="tok-type">u32</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(Index(<span class="tok-type">u32</span>)),</span>
<span class="line" id="L1751">    }</span>
<span class="line" id="L1752">}</span>
<span class="line" id="L1753"></span>
<span class="line" id="L1754"><span class="tok-comment">/// @truncate fails if the target type is larger than the</span></span>
<span class="line" id="L1755"><span class="tok-comment">/// target value.  This causes problems when one of the types</span></span>
<span class="line" id="L1756"><span class="tok-comment">/// is usize, which may be larger or smaller than u32 on different</span></span>
<span class="line" id="L1757"><span class="tok-comment">/// systems.  This version of truncate is safe to use if either</span></span>
<span class="line" id="L1758"><span class="tok-comment">/// parameter has dynamic size, and will perform widening conversion</span></span>
<span class="line" id="L1759"><span class="tok-comment">/// when needed.  Both arguments must have the same signedness.</span></span>
<span class="line" id="L1760"><span class="tok-kw">fn</span> <span class="tok-fn">safeTruncate</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, val: <span class="tok-kw">anytype</span>) T {</span>
<span class="line" id="L1761">    <span class="tok-kw">if</span> (<span class="tok-builtin">@bitSizeOf</span>(T) &gt;= <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-builtin">@TypeOf</span>(val)))</span>
<span class="line" id="L1762">        <span class="tok-kw">return</span> val;</span>
<span class="line" id="L1763">    <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(T, val);</span>
<span class="line" id="L1764">}</span>
<span class="line" id="L1765"></span>
<span class="line" id="L1766"><span class="tok-comment">/// A single entry in the lookup acceleration structure.  These structs</span></span>
<span class="line" id="L1767"><span class="tok-comment">/// are found in an array after the IndexHeader.  Hashes index into this</span></span>
<span class="line" id="L1768"><span class="tok-comment">/// array, and linear probing is used for collisions.</span></span>
<span class="line" id="L1769"><span class="tok-kw">fn</span> <span class="tok-fn">Index</span>(<span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L1770">    <span class="tok-kw">return</span> <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1771">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L1772"></span>
<span class="line" id="L1773">        <span class="tok-comment">/// The index of this entry in the backing store.  If the index is</span></span>
<span class="line" id="L1774">        <span class="tok-comment">/// empty, this is empty_sentinel.</span></span>
<span class="line" id="L1775">        entry_index: I,</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777">        <span class="tok-comment">/// The distance between this slot and its ideal placement.  This is</span></span>
<span class="line" id="L1778">        <span class="tok-comment">/// used to keep maximum scan length small.  This value is undefined</span></span>
<span class="line" id="L1779">        <span class="tok-comment">/// if the index is empty.</span></span>
<span class="line" id="L1780">        distance_from_start_index: I,</span>
<span class="line" id="L1781"></span>
<span class="line" id="L1782">        <span class="tok-comment">/// The special entry_index value marking an empty slot.</span></span>
<span class="line" id="L1783">        <span class="tok-kw">const</span> empty_sentinel = ~<span class="tok-builtin">@as</span>(I, <span class="tok-number">0</span>);</span>
<span class="line" id="L1784"></span>
<span class="line" id="L1785">        <span class="tok-comment">/// A constant empty index</span></span>
<span class="line" id="L1786">        <span class="tok-kw">const</span> empty = Self{</span>
<span class="line" id="L1787">            .entry_index = empty_sentinel,</span>
<span class="line" id="L1788">            .distance_from_start_index = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1789">        };</span>
<span class="line" id="L1790"></span>
<span class="line" id="L1791">        <span class="tok-comment">/// Checks if a slot is empty</span></span>
<span class="line" id="L1792">        <span class="tok-kw">fn</span> <span class="tok-fn">isEmpty</span>(idx: Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1793">            <span class="tok-kw">return</span> idx.entry_index == empty_sentinel;</span>
<span class="line" id="L1794">        }</span>
<span class="line" id="L1795"></span>
<span class="line" id="L1796">        <span class="tok-comment">/// Sets a slot to empty</span></span>
<span class="line" id="L1797">        <span class="tok-kw">fn</span> <span class="tok-fn">setEmpty</span>(idx: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L1798">            idx.entry_index = empty_sentinel;</span>
<span class="line" id="L1799">            idx.distance_from_start_index = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1800">        }</span>
<span class="line" id="L1801">    };</span>
<span class="line" id="L1802">}</span>
<span class="line" id="L1803"></span>
<span class="line" id="L1804"><span class="tok-comment">/// the byte size of the index must fit in a usize.  This is a power of two</span></span>
<span class="line" id="L1805"><span class="tok-comment">/// length * the size of an Index(u32).  The index is 8 bytes (3 bits repr)</span></span>
<span class="line" id="L1806"><span class="tok-comment">/// and max_usize + 1 is not representable, so we need to subtract out 4 bits.</span></span>
<span class="line" id="L1807"><span class="tok-kw">const</span> max_representable_index_len = <span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>) - <span class="tok-number">4</span>;</span>
<span class="line" id="L1808"><span class="tok-kw">const</span> max_bit_index = math.min(<span class="tok-number">32</span>, max_representable_index_len);</span>
<span class="line" id="L1809"><span class="tok-kw">const</span> min_bit_index = <span class="tok-number">5</span>;</span>
<span class="line" id="L1810"><span class="tok-kw">const</span> max_capacity = (<span class="tok-number">1</span> &lt;&lt; max_bit_index) - <span class="tok-number">1</span>;</span>
<span class="line" id="L1811"><span class="tok-kw">const</span> index_capacities = blk: {</span>
<span class="line" id="L1812">    <span class="tok-kw">var</span> caps: [max_bit_index + <span class="tok-number">1</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1813">    <span class="tok-kw">for</span> (caps[<span class="tok-number">0</span>..max_bit_index]) |*item, i| {</span>
<span class="line" id="L1814">        item.* = (<span class="tok-number">1</span> &lt;&lt; i) * <span class="tok-number">3</span> / <span class="tok-number">5</span>;</span>
<span class="line" id="L1815">    }</span>
<span class="line" id="L1816">    caps[max_bit_index] = max_capacity;</span>
<span class="line" id="L1817">    <span class="tok-kw">break</span> :blk caps;</span>
<span class="line" id="L1818">};</span>
<span class="line" id="L1819"></span>
<span class="line" id="L1820"><span class="tok-comment">/// This struct is trailed by two arrays of length indexes_len</span></span>
<span class="line" id="L1821"><span class="tok-comment">/// of integers, whose integer size is determined by indexes_len.</span></span>
<span class="line" id="L1822"><span class="tok-comment">/// These arrays are indexed by constrainIndex(hash).  The</span></span>
<span class="line" id="L1823"><span class="tok-comment">/// entryIndexes array contains the index in the dense backing store</span></span>
<span class="line" id="L1824"><span class="tok-comment">/// where the entry's data can be found.  Entries which are not in</span></span>
<span class="line" id="L1825"><span class="tok-comment">/// use have their index value set to emptySentinel(I).</span></span>
<span class="line" id="L1826"><span class="tok-comment">/// The entryDistances array stores the distance between an entry</span></span>
<span class="line" id="L1827"><span class="tok-comment">/// and its ideal hash bucket.  This is used when adding elements</span></span>
<span class="line" id="L1828"><span class="tok-comment">/// to balance the maximum scan length.</span></span>
<span class="line" id="L1829"><span class="tok-kw">const</span> IndexHeader = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1830">    <span class="tok-comment">/// This field tracks the total number of items in the arrays following</span></span>
<span class="line" id="L1831">    <span class="tok-comment">/// this header.  It is the bit index of the power of two number of indices.</span></span>
<span class="line" id="L1832">    <span class="tok-comment">/// This value is between min_bit_index and max_bit_index, inclusive.</span></span>
<span class="line" id="L1833">    bit_index: <span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>)),</span>
<span class="line" id="L1834"></span>
<span class="line" id="L1835">    <span class="tok-comment">/// Map from an incrementing index to an index slot in the attached arrays.</span></span>
<span class="line" id="L1836">    <span class="tok-kw">fn</span> <span class="tok-fn">constrainIndex</span>(header: IndexHeader, i: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1837">        <span class="tok-comment">// This is an optimization for modulo of power of two integers;</span>
</span>
<span class="line" id="L1838">        <span class="tok-comment">// it requires `indexes_len` to always be a power of two.</span>
</span>
<span class="line" id="L1839">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, i &amp; header.mask());</span>
<span class="line" id="L1840">    }</span>
<span class="line" id="L1841"></span>
<span class="line" id="L1842">    <span class="tok-comment">/// Returns the attached array of indexes.  I must match the type</span></span>
<span class="line" id="L1843">    <span class="tok-comment">/// returned by capacityIndexType.</span></span>
<span class="line" id="L1844">    <span class="tok-kw">fn</span> <span class="tok-fn">indexes</span>(header: *IndexHeader, <span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>) []Index(I) {</span>
<span class="line" id="L1845">        <span class="tok-kw">const</span> start_ptr = <span class="tok-builtin">@ptrCast</span>([*]Index(I), <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, header) + <span class="tok-builtin">@sizeOf</span>(IndexHeader));</span>
<span class="line" id="L1846">        <span class="tok-kw">return</span> start_ptr[<span class="tok-number">0</span>..header.length()];</span>
<span class="line" id="L1847">    }</span>
<span class="line" id="L1848"></span>
<span class="line" id="L1849">    <span class="tok-comment">/// Returns the type used for the index arrays.</span></span>
<span class="line" id="L1850">    <span class="tok-kw">fn</span> <span class="tok-fn">capacityIndexType</span>(header: IndexHeader) CapacityIndexType {</span>
<span class="line" id="L1851">        <span class="tok-kw">return</span> hash_map.capacityIndexType(header.bit_index);</span>
<span class="line" id="L1852">    }</span>
<span class="line" id="L1853"></span>
<span class="line" id="L1854">    <span class="tok-kw">fn</span> <span class="tok-fn">capacity</span>(self: IndexHeader) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1855">        <span class="tok-kw">return</span> index_capacities[self.bit_index];</span>
<span class="line" id="L1856">    }</span>
<span class="line" id="L1857">    <span class="tok-kw">fn</span> <span class="tok-fn">length</span>(self: IndexHeader) <span class="tok-type">usize</span> {</span>
<span class="line" id="L1858">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(math.Log2Int(<span class="tok-type">usize</span>), self.bit_index);</span>
<span class="line" id="L1859">    }</span>
<span class="line" id="L1860">    <span class="tok-kw">fn</span> <span class="tok-fn">mask</span>(self: IndexHeader) <span class="tok-type">u32</span> {</span>
<span class="line" id="L1861">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.length() - <span class="tok-number">1</span>);</span>
<span class="line" id="L1862">    }</span>
<span class="line" id="L1863"></span>
<span class="line" id="L1864">    <span class="tok-kw">fn</span> <span class="tok-fn">findBitIndex</span>(desired_capacity: <span class="tok-type">usize</span>) !<span class="tok-type">u8</span> {</span>
<span class="line" id="L1865">        <span class="tok-kw">if</span> (desired_capacity &gt; max_capacity) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory;</span>
<span class="line" id="L1866">        <span class="tok-kw">var</span> new_bit_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, std.math.log2_int_ceil(<span class="tok-type">usize</span>, desired_capacity));</span>
<span class="line" id="L1867">        <span class="tok-kw">if</span> (desired_capacity &gt; index_capacities[new_bit_index]) new_bit_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1868">        <span class="tok-kw">if</span> (new_bit_index &lt; min_bit_index) new_bit_index = min_bit_index;</span>
<span class="line" id="L1869">        assert(desired_capacity &lt;= index_capacities[new_bit_index]);</span>
<span class="line" id="L1870">        <span class="tok-kw">return</span> new_bit_index;</span>
<span class="line" id="L1871">    }</span>
<span class="line" id="L1872"></span>
<span class="line" id="L1873">    <span class="tok-comment">/// Allocates an index header, and fills the entryIndexes array with empty.</span></span>
<span class="line" id="L1874">    <span class="tok-comment">/// The distance array contents are undefined.</span></span>
<span class="line" id="L1875">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(allocator: Allocator, new_bit_index: <span class="tok-type">u8</span>) !*IndexHeader {</span>
<span class="line" id="L1876">        <span class="tok-kw">const</span> len = <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(math.Log2Int(<span class="tok-type">usize</span>), new_bit_index);</span>
<span class="line" id="L1877">        <span class="tok-kw">const</span> index_size = hash_map.capacityIndexSize(new_bit_index);</span>
<span class="line" id="L1878">        <span class="tok-kw">const</span> nbytes = <span class="tok-builtin">@sizeOf</span>(IndexHeader) + index_size * len;</span>
<span class="line" id="L1879">        <span class="tok-kw">const</span> bytes = <span class="tok-kw">try</span> allocator.allocAdvanced(<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>(IndexHeader), nbytes, .exact);</span>
<span class="line" id="L1880">        <span class="tok-builtin">@memset</span>(bytes.ptr + <span class="tok-builtin">@sizeOf</span>(IndexHeader), <span class="tok-number">0xff</span>, bytes.len - <span class="tok-builtin">@sizeOf</span>(IndexHeader));</span>
<span class="line" id="L1881">        <span class="tok-kw">const</span> result = <span class="tok-builtin">@ptrCast</span>(*IndexHeader, bytes.ptr);</span>
<span class="line" id="L1882">        result.* = .{</span>
<span class="line" id="L1883">            .bit_index = new_bit_index,</span>
<span class="line" id="L1884">        };</span>
<span class="line" id="L1885">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L1886">    }</span>
<span class="line" id="L1887"></span>
<span class="line" id="L1888">    <span class="tok-comment">/// Releases the memory for a header and its associated arrays.</span></span>
<span class="line" id="L1889">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(header: *IndexHeader, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L1890">        <span class="tok-kw">const</span> index_size = hash_map.capacityIndexSize(header.bit_index);</span>
<span class="line" id="L1891">        <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(IndexHeader)) <span class="tok-type">u8</span>, header);</span>
<span class="line" id="L1892">        <span class="tok-kw">const</span> slice = ptr[<span class="tok-number">0</span> .. <span class="tok-builtin">@sizeOf</span>(IndexHeader) + header.length() * index_size];</span>
<span class="line" id="L1893">        allocator.free(slice);</span>
<span class="line" id="L1894">    }</span>
<span class="line" id="L1895"></span>
<span class="line" id="L1896">    <span class="tok-comment">/// Puts an IndexHeader into the state that it would be in after being freshly allocated.</span></span>
<span class="line" id="L1897">    <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(header: *IndexHeader) <span class="tok-type">void</span> {</span>
<span class="line" id="L1898">        <span class="tok-kw">const</span> index_size = hash_map.capacityIndexSize(header.bit_index);</span>
<span class="line" id="L1899">        <span class="tok-kw">const</span> ptr = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(IndexHeader)) <span class="tok-type">u8</span>, header);</span>
<span class="line" id="L1900">        <span class="tok-kw">const</span> nbytes = <span class="tok-builtin">@sizeOf</span>(IndexHeader) + header.length() * index_size;</span>
<span class="line" id="L1901">        <span class="tok-builtin">@memset</span>(ptr + <span class="tok-builtin">@sizeOf</span>(IndexHeader), <span class="tok-number">0xff</span>, nbytes - <span class="tok-builtin">@sizeOf</span>(IndexHeader));</span>
<span class="line" id="L1902">    }</span>
<span class="line" id="L1903"></span>
<span class="line" id="L1904">    <span class="tok-comment">// Verify that the header has sufficient alignment to produce aligned arrays.</span>
</span>
<span class="line" id="L1905">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L1906">        <span class="tok-kw">if</span> (<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>) &gt; <span class="tok-builtin">@alignOf</span>(IndexHeader))</span>
<span class="line" id="L1907">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;IndexHeader must have a larger alignment than its indexes!&quot;</span>);</span>
<span class="line" id="L1908">    }</span>
<span class="line" id="L1909">};</span>
<span class="line" id="L1910"></span>
<span class="line" id="L1911"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic hash map usage&quot;</span> {</span>
<span class="line" id="L1912">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1913">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L1914"></span>
<span class="line" id="L1915">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">1</span>, <span class="tok-number">11</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1916">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">2</span>, <span class="tok-number">22</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1917">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">3</span>, <span class="tok-number">33</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1918">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">4</span>, <span class="tok-number">44</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1919"></span>
<span class="line" id="L1920">    <span class="tok-kw">try</span> map.putNoClobber(<span class="tok-number">5</span>, <span class="tok-number">55</span>);</span>
<span class="line" id="L1921">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">5</span>, <span class="tok-number">66</span>)).?.value == <span class="tok-number">55</span>);</span>
<span class="line" id="L1922">    <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(<span class="tok-number">5</span>, <span class="tok-number">55</span>)).?.value == <span class="tok-number">66</span>);</span>
<span class="line" id="L1923"></span>
<span class="line" id="L1924">    <span class="tok-kw">const</span> gop1 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">5</span>);</span>
<span class="line" id="L1925">    <span class="tok-kw">try</span> testing.expect(gop1.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L1926">    <span class="tok-kw">try</span> testing.expect(gop1.value_ptr.* == <span class="tok-number">55</span>);</span>
<span class="line" id="L1927">    <span class="tok-kw">try</span> testing.expect(gop1.index == <span class="tok-number">4</span>);</span>
<span class="line" id="L1928">    gop1.value_ptr.* = <span class="tok-number">77</span>;</span>
<span class="line" id="L1929">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">5</span>).?.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L1930"></span>
<span class="line" id="L1931">    <span class="tok-kw">const</span> gop2 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">99</span>);</span>
<span class="line" id="L1932">    <span class="tok-kw">try</span> testing.expect(gop2.found_existing == <span class="tok-null">false</span>);</span>
<span class="line" id="L1933">    <span class="tok-kw">try</span> testing.expect(gop2.index == <span class="tok-number">5</span>);</span>
<span class="line" id="L1934">    gop2.value_ptr.* = <span class="tok-number">42</span>;</span>
<span class="line" id="L1935">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">99</span>).?.value_ptr.* == <span class="tok-number">42</span>);</span>
<span class="line" id="L1936"></span>
<span class="line" id="L1937">    <span class="tok-kw">const</span> gop3 = <span class="tok-kw">try</span> map.getOrPutValue(<span class="tok-number">5</span>, <span class="tok-number">5</span>);</span>
<span class="line" id="L1938">    <span class="tok-kw">try</span> testing.expect(gop3.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L1939"></span>
<span class="line" id="L1940">    <span class="tok-kw">const</span> gop4 = <span class="tok-kw">try</span> map.getOrPutValue(<span class="tok-number">100</span>, <span class="tok-number">41</span>);</span>
<span class="line" id="L1941">    <span class="tok-kw">try</span> testing.expect(gop4.value_ptr.* == <span class="tok-number">41</span>);</span>
<span class="line" id="L1942"></span>
<span class="line" id="L1943">    <span class="tok-kw">try</span> testing.expect(map.contains(<span class="tok-number">2</span>));</span>
<span class="line" id="L1944">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">2</span>).?.value_ptr.* == <span class="tok-number">22</span>);</span>
<span class="line" id="L1945">    <span class="tok-kw">try</span> testing.expect(map.get(<span class="tok-number">2</span>).? == <span class="tok-number">22</span>);</span>
<span class="line" id="L1946"></span>
<span class="line" id="L1947">    <span class="tok-kw">const</span> rmv1 = map.fetchSwapRemove(<span class="tok-number">2</span>);</span>
<span class="line" id="L1948">    <span class="tok-kw">try</span> testing.expect(rmv1.?.key == <span class="tok-number">2</span>);</span>
<span class="line" id="L1949">    <span class="tok-kw">try</span> testing.expect(rmv1.?.value == <span class="tok-number">22</span>);</span>
<span class="line" id="L1950">    <span class="tok-kw">try</span> testing.expect(map.fetchSwapRemove(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1951">    <span class="tok-kw">try</span> testing.expect(map.swapRemove(<span class="tok-number">2</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L1952">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1953">    <span class="tok-kw">try</span> testing.expect(map.get(<span class="tok-number">2</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1954"></span>
<span class="line" id="L1955">    <span class="tok-comment">// Since we've used `swapRemove` above, the index of this entry should remain unchanged.</span>
</span>
<span class="line" id="L1956">    <span class="tok-kw">try</span> testing.expect(map.getIndex(<span class="tok-number">100</span>).? == <span class="tok-number">1</span>);</span>
<span class="line" id="L1957">    <span class="tok-kw">const</span> gop5 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">5</span>);</span>
<span class="line" id="L1958">    <span class="tok-kw">try</span> testing.expect(gop5.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L1959">    <span class="tok-kw">try</span> testing.expect(gop5.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L1960">    <span class="tok-kw">try</span> testing.expect(gop5.index == <span class="tok-number">4</span>);</span>
<span class="line" id="L1961"></span>
<span class="line" id="L1962">    <span class="tok-comment">// Whereas, if we do an `orderedRemove`, it should move the index forward one spot.</span>
</span>
<span class="line" id="L1963">    <span class="tok-kw">const</span> rmv2 = map.fetchOrderedRemove(<span class="tok-number">100</span>);</span>
<span class="line" id="L1964">    <span class="tok-kw">try</span> testing.expect(rmv2.?.key == <span class="tok-number">100</span>);</span>
<span class="line" id="L1965">    <span class="tok-kw">try</span> testing.expect(rmv2.?.value == <span class="tok-number">41</span>);</span>
<span class="line" id="L1966">    <span class="tok-kw">try</span> testing.expect(map.fetchOrderedRemove(<span class="tok-number">100</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1967">    <span class="tok-kw">try</span> testing.expect(map.orderedRemove(<span class="tok-number">100</span>) == <span class="tok-null">false</span>);</span>
<span class="line" id="L1968">    <span class="tok-kw">try</span> testing.expect(map.getEntry(<span class="tok-number">100</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1969">    <span class="tok-kw">try</span> testing.expect(map.get(<span class="tok-number">100</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L1970">    <span class="tok-kw">const</span> gop6 = <span class="tok-kw">try</span> map.getOrPut(<span class="tok-number">5</span>);</span>
<span class="line" id="L1971">    <span class="tok-kw">try</span> testing.expect(gop6.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L1972">    <span class="tok-kw">try</span> testing.expect(gop6.value_ptr.* == <span class="tok-number">77</span>);</span>
<span class="line" id="L1973">    <span class="tok-kw">try</span> testing.expect(gop6.index == <span class="tok-number">3</span>);</span>
<span class="line" id="L1974"></span>
<span class="line" id="L1975">    <span class="tok-kw">try</span> testing.expect(map.swapRemove(<span class="tok-number">3</span>));</span>
<span class="line" id="L1976">}</span>
<span class="line" id="L1977"></span>
<span class="line" id="L1978"><span class="tok-kw">test</span> <span class="tok-str">&quot;iterator hash map&quot;</span> {</span>
<span class="line" id="L1979">    <span class="tok-kw">var</span> reset_map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L1980">    <span class="tok-kw">defer</span> reset_map.deinit();</span>
<span class="line" id="L1981"></span>
<span class="line" id="L1982">    <span class="tok-comment">// test ensureTotalCapacity with a 0 parameter</span>
</span>
<span class="line" id="L1983">    <span class="tok-kw">try</span> reset_map.ensureTotalCapacity(<span class="tok-number">0</span>);</span>
<span class="line" id="L1984"></span>
<span class="line" id="L1985">    <span class="tok-kw">try</span> reset_map.putNoClobber(<span class="tok-number">0</span>, <span class="tok-number">11</span>);</span>
<span class="line" id="L1986">    <span class="tok-kw">try</span> reset_map.putNoClobber(<span class="tok-number">1</span>, <span class="tok-number">22</span>);</span>
<span class="line" id="L1987">    <span class="tok-kw">try</span> reset_map.putNoClobber(<span class="tok-number">2</span>, <span class="tok-number">33</span>);</span>
<span class="line" id="L1988"></span>
<span class="line" id="L1989">    <span class="tok-kw">var</span> keys = [_]<span class="tok-type">i32</span>{</span>
<span class="line" id="L1990">        <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L1991">    };</span>
<span class="line" id="L1992"></span>
<span class="line" id="L1993">    <span class="tok-kw">var</span> values = [_]<span class="tok-type">i32</span>{</span>
<span class="line" id="L1994">        <span class="tok-number">11</span>, <span class="tok-number">33</span>, <span class="tok-number">22</span>,</span>
<span class="line" id="L1995">    };</span>
<span class="line" id="L1996"></span>
<span class="line" id="L1997">    <span class="tok-kw">var</span> buffer = [_]<span class="tok-type">i32</span>{</span>
<span class="line" id="L1998">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L1999">    };</span>
<span class="line" id="L2000"></span>
<span class="line" id="L2001">    <span class="tok-kw">var</span> it = reset_map.iterator();</span>
<span class="line" id="L2002">    <span class="tok-kw">const</span> first_entry = it.next().?;</span>
<span class="line" id="L2003">    it.reset();</span>
<span class="line" id="L2004"></span>
<span class="line" id="L2005">    <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2006">    <span class="tok-kw">while</span> (it.next()) |entry| : (count += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2007">        buffer[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, entry.key_ptr.*)] = entry.value_ptr.*;</span>
<span class="line" id="L2008">    }</span>
<span class="line" id="L2009">    <span class="tok-kw">try</span> testing.expect(count == <span class="tok-number">3</span>);</span>
<span class="line" id="L2010">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L2011"></span>
<span class="line" id="L2012">    <span class="tok-kw">for</span> (buffer) |_, i| {</span>
<span class="line" id="L2013">        <span class="tok-kw">try</span> testing.expect(buffer[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, keys[i])] == values[i]);</span>
<span class="line" id="L2014">    }</span>
<span class="line" id="L2015"></span>
<span class="line" id="L2016">    it.reset();</span>
<span class="line" id="L2017">    count = <span class="tok-number">0</span>;</span>
<span class="line" id="L2018">    <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L2019">        buffer[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, entry.key_ptr.*)] = entry.value_ptr.*;</span>
<span class="line" id="L2020">        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L2021">        <span class="tok-kw">if</span> (count &gt;= <span class="tok-number">2</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L2022">    }</span>
<span class="line" id="L2023"></span>
<span class="line" id="L2024">    <span class="tok-kw">for</span> (buffer[<span class="tok-number">0</span>..<span class="tok-number">2</span>]) |_, i| {</span>
<span class="line" id="L2025">        <span class="tok-kw">try</span> testing.expect(buffer[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, keys[i])] == values[i]);</span>
<span class="line" id="L2026">    }</span>
<span class="line" id="L2027"></span>
<span class="line" id="L2028">    it.reset();</span>
<span class="line" id="L2029">    <span class="tok-kw">var</span> entry = it.next().?;</span>
<span class="line" id="L2030">    <span class="tok-kw">try</span> testing.expect(entry.key_ptr.* == first_entry.key_ptr.*);</span>
<span class="line" id="L2031">    <span class="tok-kw">try</span> testing.expect(entry.value_ptr.* == first_entry.value_ptr.*);</span>
<span class="line" id="L2032">}</span>
<span class="line" id="L2033"></span>
<span class="line" id="L2034"><span class="tok-kw">test</span> <span class="tok-str">&quot;ensure capacity&quot;</span> {</span>
<span class="line" id="L2035">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2036">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2037"></span>
<span class="line" id="L2038">    <span class="tok-kw">try</span> map.ensureTotalCapacity(<span class="tok-number">20</span>);</span>
<span class="line" id="L2039">    <span class="tok-kw">const</span> initial_capacity = map.capacity();</span>
<span class="line" id="L2040">    <span class="tok-kw">try</span> testing.expect(initial_capacity &gt;= <span class="tok-number">20</span>);</span>
<span class="line" id="L2041">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2042">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2043">        <span class="tok-kw">try</span> testing.expect(map.fetchPutAssumeCapacity(i, i + <span class="tok-number">10</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2044">    }</span>
<span class="line" id="L2045">    <span class="tok-comment">// shouldn't resize from putAssumeCapacity</span>
</span>
<span class="line" id="L2046">    <span class="tok-kw">try</span> testing.expect(initial_capacity == map.capacity());</span>
<span class="line" id="L2047">}</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049"><span class="tok-kw">test</span> <span class="tok-str">&quot;big map&quot;</span> {</span>
<span class="line" id="L2050">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2051">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2052"></span>
<span class="line" id="L2053">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2054">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2055">        <span class="tok-kw">try</span> map.put(i, i + <span class="tok-number">10</span>);</span>
<span class="line" id="L2056">    }</span>
<span class="line" id="L2057"></span>
<span class="line" id="L2058">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2059">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2060">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, i + <span class="tok-number">10</span>), map.get(i));</span>
<span class="line" id="L2061">    }</span>
<span class="line" id="L2062">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2063">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), map.get(i));</span>
<span class="line" id="L2064">    }</span>
<span class="line" id="L2065"></span>
<span class="line" id="L2066">    i = <span class="tok-number">4</span>;</span>
<span class="line" id="L2067">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">12</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2068">        <span class="tok-kw">try</span> map.put(i, i + <span class="tok-number">12</span>);</span>
<span class="line" id="L2069">    }</span>
<span class="line" id="L2070"></span>
<span class="line" id="L2071">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2072">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2073">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, i + <span class="tok-number">10</span>), map.get(i));</span>
<span class="line" id="L2074">    }</span>
<span class="line" id="L2075">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">12</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2076">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, i + <span class="tok-number">12</span>), map.get(i));</span>
<span class="line" id="L2077">    }</span>
<span class="line" id="L2078">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2079">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), map.get(i));</span>
<span class="line" id="L2080">    }</span>
<span class="line" id="L2081"></span>
<span class="line" id="L2082">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2083">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2084">        <span class="tok-kw">try</span> testing.expect(map.orderedRemove(i));</span>
<span class="line" id="L2085">    }</span>
<span class="line" id="L2086">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2087">        <span class="tok-kw">try</span> testing.expect(map.swapRemove(i));</span>
<span class="line" id="L2088">    }</span>
<span class="line" id="L2089"></span>
<span class="line" id="L2090">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2091">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2092">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), map.get(i));</span>
<span class="line" id="L2093">    }</span>
<span class="line" id="L2094">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">12</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2095">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, i + <span class="tok-number">12</span>), map.get(i));</span>
<span class="line" id="L2096">    }</span>
<span class="line" id="L2097">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2098">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(?<span class="tok-type">i32</span>, <span class="tok-null">null</span>), map.get(i));</span>
<span class="line" id="L2099">    }</span>
<span class="line" id="L2100">}</span>
<span class="line" id="L2101"></span>
<span class="line" id="L2102"><span class="tok-kw">test</span> <span class="tok-str">&quot;clone&quot;</span> {</span>
<span class="line" id="L2103">    <span class="tok-kw">var</span> original = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2104">    <span class="tok-kw">defer</span> original.deinit();</span>
<span class="line" id="L2105"></span>
<span class="line" id="L2106">    <span class="tok-comment">// put more than `linear_scan_max` so we can test that the index header is properly cloned</span>
</span>
<span class="line" id="L2107">    <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2108">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2109">        <span class="tok-kw">try</span> original.putNoClobber(i, i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2110">    }</span>
<span class="line" id="L2111"></span>
<span class="line" id="L2112">    <span class="tok-kw">var</span> copy = <span class="tok-kw">try</span> original.clone();</span>
<span class="line" id="L2113">    <span class="tok-kw">defer</span> copy.deinit();</span>
<span class="line" id="L2114"></span>
<span class="line" id="L2115">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2116">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2117">        <span class="tok-kw">try</span> testing.expect(original.get(i).? == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2118">        <span class="tok-kw">try</span> testing.expect(copy.get(i).? == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2119">        <span class="tok-kw">try</span> testing.expect(original.getPtr(i).? != copy.getPtr(i).?);</span>
<span class="line" id="L2120">    }</span>
<span class="line" id="L2121"></span>
<span class="line" id="L2122">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2123">        <span class="tok-kw">try</span> testing.expect(original.get(i) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2124">        <span class="tok-kw">try</span> testing.expect(copy.get(i) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2125">    }</span>
<span class="line" id="L2126">}</span>
<span class="line" id="L2127"></span>
<span class="line" id="L2128"><span class="tok-kw">test</span> <span class="tok-str">&quot;shrink&quot;</span> {</span>
<span class="line" id="L2129">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2130">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2131"></span>
<span class="line" id="L2132">    <span class="tok-comment">// This test is more interesting if we insert enough entries to allocate the index header.</span>
</span>
<span class="line" id="L2133">    <span class="tok-kw">const</span> num_entries = <span class="tok-number">20</span>;</span>
<span class="line" id="L2134">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2135">    <span class="tok-kw">while</span> (i &lt; num_entries) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L2136">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(i, i * <span class="tok-number">10</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2137"></span>
<span class="line" id="L2138">    <span class="tok-kw">try</span> testing.expect(map.unmanaged.index_header != <span class="tok-null">null</span>);</span>
<span class="line" id="L2139">    <span class="tok-kw">try</span> testing.expect(map.count() == num_entries);</span>
<span class="line" id="L2140"></span>
<span class="line" id="L2141">    <span class="tok-comment">// Test `shrinkRetainingCapacity`.</span>
</span>
<span class="line" id="L2142">    map.shrinkRetainingCapacity(<span class="tok-number">17</span>);</span>
<span class="line" id="L2143">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">17</span>);</span>
<span class="line" id="L2144">    <span class="tok-kw">try</span> testing.expect(map.capacity() == <span class="tok-number">20</span>);</span>
<span class="line" id="L2145">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2146">    <span class="tok-kw">while</span> (i &lt; num_entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2147">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> map.getOrPut(i);</span>
<span class="line" id="L2148">        <span class="tok-kw">if</span> (i &lt; <span class="tok-number">17</span>) {</span>
<span class="line" id="L2149">            <span class="tok-kw">try</span> testing.expect(gop.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L2150">            <span class="tok-kw">try</span> testing.expect(gop.value_ptr.* == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2151">        } <span class="tok-kw">else</span> <span class="tok-kw">try</span> testing.expect(gop.found_existing == <span class="tok-null">false</span>);</span>
<span class="line" id="L2152">    }</span>
<span class="line" id="L2153"></span>
<span class="line" id="L2154">    <span class="tok-comment">// Test `shrinkAndFree`.</span>
</span>
<span class="line" id="L2155">    map.shrinkAndFree(<span class="tok-number">15</span>);</span>
<span class="line" id="L2156">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">15</span>);</span>
<span class="line" id="L2157">    <span class="tok-kw">try</span> testing.expect(map.capacity() == <span class="tok-number">15</span>);</span>
<span class="line" id="L2158">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2159">    <span class="tok-kw">while</span> (i &lt; num_entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2160">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> map.getOrPut(i);</span>
<span class="line" id="L2161">        <span class="tok-kw">if</span> (i &lt; <span class="tok-number">15</span>) {</span>
<span class="line" id="L2162">            <span class="tok-kw">try</span> testing.expect(gop.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L2163">            <span class="tok-kw">try</span> testing.expect(gop.value_ptr.* == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2164">        } <span class="tok-kw">else</span> <span class="tok-kw">try</span> testing.expect(gop.found_existing == <span class="tok-null">false</span>);</span>
<span class="line" id="L2165">    }</span>
<span class="line" id="L2166">}</span>
<span class="line" id="L2167"></span>
<span class="line" id="L2168"><span class="tok-kw">test</span> <span class="tok-str">&quot;pop&quot;</span> {</span>
<span class="line" id="L2169">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2170">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2171"></span>
<span class="line" id="L2172">    <span class="tok-comment">// Insert just enough entries so that the map expands. Afterwards,</span>
</span>
<span class="line" id="L2173">    <span class="tok-comment">// pop all entries out of the map.</span>
</span>
<span class="line" id="L2174"></span>
<span class="line" id="L2175">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2176">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">9</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2177">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(i, i)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2178">    }</span>
<span class="line" id="L2179"></span>
<span class="line" id="L2180">    <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L2181">        <span class="tok-kw">const</span> pop = map.pop();</span>
<span class="line" id="L2182">        <span class="tok-kw">try</span> testing.expect(pop.key == i - <span class="tok-number">1</span> <span class="tok-kw">and</span> pop.value == i - <span class="tok-number">1</span>);</span>
<span class="line" id="L2183">    }</span>
<span class="line" id="L2184">}</span>
<span class="line" id="L2185"></span>
<span class="line" id="L2186"><span class="tok-kw">test</span> <span class="tok-str">&quot;popOrNull&quot;</span> {</span>
<span class="line" id="L2187">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2188">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2189"></span>
<span class="line" id="L2190">    <span class="tok-comment">// Insert just enough entries so that the map expands. Afterwards,</span>
</span>
<span class="line" id="L2191">    <span class="tok-comment">// pop all entries out of the map.</span>
</span>
<span class="line" id="L2192"></span>
<span class="line" id="L2193">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2194">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">9</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2195">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(i, i)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2196">    }</span>
<span class="line" id="L2197"></span>
<span class="line" id="L2198">    <span class="tok-kw">while</span> (map.popOrNull()) |pop| {</span>
<span class="line" id="L2199">        <span class="tok-kw">try</span> testing.expect(pop.key == i - <span class="tok-number">1</span> <span class="tok-kw">and</span> pop.value == i - <span class="tok-number">1</span>);</span>
<span class="line" id="L2200">        i -= <span class="tok-number">1</span>;</span>
<span class="line" id="L2201">    }</span>
<span class="line" id="L2202"></span>
<span class="line" id="L2203">    <span class="tok-kw">try</span> testing.expect(map.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L2204">}</span>
<span class="line" id="L2205"></span>
<span class="line" id="L2206"><span class="tok-kw">test</span> <span class="tok-str">&quot;reIndex&quot;</span> {</span>
<span class="line" id="L2207">    <span class="tok-kw">var</span> map = ArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>, AutoContext(<span class="tok-type">i32</span>), <span class="tok-null">true</span>).init(std.testing.allocator);</span>
<span class="line" id="L2208">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2209"></span>
<span class="line" id="L2210">    <span class="tok-comment">// Populate via the API.</span>
</span>
<span class="line" id="L2211">    <span class="tok-kw">const</span> num_indexed_entries = <span class="tok-number">20</span>;</span>
<span class="line" id="L2212">    <span class="tok-kw">var</span> i: <span class="tok-type">i32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2213">    <span class="tok-kw">while</span> (i &lt; num_indexed_entries) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L2214">        <span class="tok-kw">try</span> testing.expect((<span class="tok-kw">try</span> map.fetchPut(i, i * <span class="tok-number">10</span>)) == <span class="tok-null">null</span>);</span>
<span class="line" id="L2215"></span>
<span class="line" id="L2216">    <span class="tok-comment">// Make sure we allocated an index header.</span>
</span>
<span class="line" id="L2217">    <span class="tok-kw">try</span> testing.expect(map.unmanaged.index_header != <span class="tok-null">null</span>);</span>
<span class="line" id="L2218"></span>
<span class="line" id="L2219">    <span class="tok-comment">// Now write to the underlying array list directly.</span>
</span>
<span class="line" id="L2220">    <span class="tok-kw">const</span> num_unindexed_entries = <span class="tok-number">20</span>;</span>
<span class="line" id="L2221">    <span class="tok-kw">const</span> hash = getAutoHashFn(<span class="tok-type">i32</span>, <span class="tok-type">void</span>);</span>
<span class="line" id="L2222">    <span class="tok-kw">var</span> al = &amp;map.unmanaged.entries;</span>
<span class="line" id="L2223">    <span class="tok-kw">while</span> (i &lt; num_indexed_entries + num_unindexed_entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2224">        <span class="tok-kw">try</span> al.append(std.testing.allocator, .{</span>
<span class="line" id="L2225">            .key = i,</span>
<span class="line" id="L2226">            .value = i * <span class="tok-number">10</span>,</span>
<span class="line" id="L2227">            .hash = hash({}, i),</span>
<span class="line" id="L2228">        });</span>
<span class="line" id="L2229">    }</span>
<span class="line" id="L2230"></span>
<span class="line" id="L2231">    <span class="tok-comment">// After reindexing, we should see everything.</span>
</span>
<span class="line" id="L2232">    <span class="tok-kw">try</span> map.reIndex();</span>
<span class="line" id="L2233">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L2234">    <span class="tok-kw">while</span> (i &lt; num_indexed_entries + num_unindexed_entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L2235">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> map.getOrPut(i);</span>
<span class="line" id="L2236">        <span class="tok-kw">try</span> testing.expect(gop.found_existing == <span class="tok-null">true</span>);</span>
<span class="line" id="L2237">        <span class="tok-kw">try</span> testing.expect(gop.value_ptr.* == i * <span class="tok-number">10</span>);</span>
<span class="line" id="L2238">        <span class="tok-kw">try</span> testing.expect(gop.index == i);</span>
<span class="line" id="L2239">    }</span>
<span class="line" id="L2240">}</span>
<span class="line" id="L2241"></span>
<span class="line" id="L2242"><span class="tok-kw">test</span> <span class="tok-str">&quot;auto store_hash&quot;</span> {</span>
<span class="line" id="L2243">    <span class="tok-kw">const</span> HasCheapEql = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>);</span>
<span class="line" id="L2244">    <span class="tok-kw">const</span> HasExpensiveEql = AutoArrayHashMap([<span class="tok-number">32</span>]<span class="tok-type">i32</span>, <span class="tok-type">i32</span>);</span>
<span class="line" id="L2245">    <span class="tok-kw">try</span> testing.expect(meta.fieldInfo(HasCheapEql.Data, .hash).field_type == <span class="tok-type">void</span>);</span>
<span class="line" id="L2246">    <span class="tok-kw">try</span> testing.expect(meta.fieldInfo(HasExpensiveEql.Data, .hash).field_type != <span class="tok-type">void</span>);</span>
<span class="line" id="L2247"></span>
<span class="line" id="L2248">    <span class="tok-kw">const</span> HasCheapEqlUn = AutoArrayHashMapUnmanaged(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>);</span>
<span class="line" id="L2249">    <span class="tok-kw">const</span> HasExpensiveEqlUn = AutoArrayHashMapUnmanaged([<span class="tok-number">32</span>]<span class="tok-type">i32</span>, <span class="tok-type">i32</span>);</span>
<span class="line" id="L2250">    <span class="tok-kw">try</span> testing.expect(meta.fieldInfo(HasCheapEqlUn.Data, .hash).field_type == <span class="tok-type">void</span>);</span>
<span class="line" id="L2251">    <span class="tok-kw">try</span> testing.expect(meta.fieldInfo(HasExpensiveEqlUn.Data, .hash).field_type != <span class="tok-type">void</span>);</span>
<span class="line" id="L2252">}</span>
<span class="line" id="L2253"></span>
<span class="line" id="L2254"><span class="tok-kw">test</span> <span class="tok-str">&quot;sort&quot;</span> {</span>
<span class="line" id="L2255">    <span class="tok-kw">var</span> map = AutoArrayHashMap(<span class="tok-type">i32</span>, <span class="tok-type">i32</span>).init(std.testing.allocator);</span>
<span class="line" id="L2256">    <span class="tok-kw">defer</span> map.deinit();</span>
<span class="line" id="L2257"></span>
<span class="line" id="L2258">    <span class="tok-kw">for</span> ([_]<span class="tok-type">i32</span>{ <span class="tok-number">8</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">10</span>, <span class="tok-number">2</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">16</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">17</span>, <span class="tok-number">7</span> }) |x| {</span>
<span class="line" id="L2259">        <span class="tok-kw">try</span> map.put(x, x * <span class="tok-number">3</span>);</span>
<span class="line" id="L2260">    }</span>
<span class="line" id="L2261"></span>
<span class="line" id="L2262">    <span class="tok-kw">const</span> C = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2263">        keys: []<span class="tok-type">i32</span>,</span>
<span class="line" id="L2264"></span>
<span class="line" id="L2265">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lessThan</span>(ctx: <span class="tok-builtin">@This</span>(), a_index: <span class="tok-type">usize</span>, b_index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2266">            <span class="tok-kw">return</span> ctx.keys[a_index] &lt; ctx.keys[b_index];</span>
<span class="line" id="L2267">        }</span>
<span class="line" id="L2268">    };</span>
<span class="line" id="L2269"></span>
<span class="line" id="L2270">    map.sort(C{ .keys = map.keys() });</span>
<span class="line" id="L2271"></span>
<span class="line" id="L2272">    <span class="tok-kw">var</span> x: <span class="tok-type">i32</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L2273">    <span class="tok-kw">for</span> (map.keys()) |key, i| {</span>
<span class="line" id="L2274">        <span class="tok-kw">try</span> testing.expect(key == x);</span>
<span class="line" id="L2275">        <span class="tok-kw">try</span> testing.expect(map.values()[i] == x * <span class="tok-number">3</span>);</span>
<span class="line" id="L2276">        x += <span class="tok-number">1</span>;</span>
<span class="line" id="L2277">    }</span>
<span class="line" id="L2278">}</span>
<span class="line" id="L2279"></span>
<span class="line" id="L2280"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getHashPtrAddrFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K) <span class="tok-type">u32</span>) {</span>
<span class="line" id="L2281">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2282">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(ctx: Context, key: K) <span class="tok-type">u32</span> {</span>
<span class="line" id="L2283">            _ = ctx;</span>
<span class="line" id="L2284">            <span class="tok-kw">return</span> getAutoHashFn(<span class="tok-type">usize</span>, <span class="tok-type">void</span>)({}, <span class="tok-builtin">@ptrToInt</span>(key));</span>
<span class="line" id="L2285">        }</span>
<span class="line" id="L2286">    }.hash;</span>
<span class="line" id="L2287">}</span>
<span class="line" id="L2288"></span>
<span class="line" id="L2289"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getTrivialEqlFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K, K) <span class="tok-type">bool</span>) {</span>
<span class="line" id="L2290">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2291">        <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(ctx: Context, a: K, b: K) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2292">            _ = ctx;</span>
<span class="line" id="L2293">            <span class="tok-kw">return</span> a == b;</span>
<span class="line" id="L2294">        }</span>
<span class="line" id="L2295">    }.eql;</span>
<span class="line" id="L2296">}</span>
<span class="line" id="L2297"></span>
<span class="line" id="L2298"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">AutoContext</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L2299">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2300">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> hash = getAutoHashFn(K, <span class="tok-builtin">@This</span>());</span>
<span class="line" id="L2301">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> eql = getAutoEqlFn(K, <span class="tok-builtin">@This</span>());</span>
<span class="line" id="L2302">    };</span>
<span class="line" id="L2303">}</span>
<span class="line" id="L2304"></span>
<span class="line" id="L2305"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAutoHashFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K) <span class="tok-type">u32</span>) {</span>
<span class="line" id="L2306">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2307">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(ctx: Context, key: K) <span class="tok-type">u32</span> {</span>
<span class="line" id="L2308">            _ = ctx;</span>
<span class="line" id="L2309">            <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> trait.hasUniqueRepresentation(K)) {</span>
<span class="line" id="L2310">                <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, Wyhash.hash(<span class="tok-number">0</span>, std.mem.asBytes(&amp;key)));</span>
<span class="line" id="L2311">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2312">                <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L2313">                autoHash(&amp;hasher, key);</span>
<span class="line" id="L2314">                <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, hasher.final());</span>
<span class="line" id="L2315">            }</span>
<span class="line" id="L2316">        }</span>
<span class="line" id="L2317">    }.hash;</span>
<span class="line" id="L2318">}</span>
<span class="line" id="L2319"></span>
<span class="line" id="L2320"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAutoEqlFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>) (<span class="tok-kw">fn</span> (Context, K, K, <span class="tok-type">usize</span>) <span class="tok-type">bool</span>) {</span>
<span class="line" id="L2321">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2322">        <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(ctx: Context, a: K, b: K, b_index: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2323">            _ = b_index;</span>
<span class="line" id="L2324">            _ = ctx;</span>
<span class="line" id="L2325">            <span class="tok-kw">return</span> meta.eql(a, b);</span>
<span class="line" id="L2326">        }</span>
<span class="line" id="L2327">    }.eql;</span>
<span class="line" id="L2328">}</span>
<span class="line" id="L2329"></span>
<span class="line" id="L2330"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">autoEqlIsCheap</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L2331">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(K)) {</span>
<span class="line" id="L2332">        .Bool,</span>
<span class="line" id="L2333">        .Int,</span>
<span class="line" id="L2334">        .Float,</span>
<span class="line" id="L2335">        .Pointer,</span>
<span class="line" id="L2336">        .ComptimeFloat,</span>
<span class="line" id="L2337">        .ComptimeInt,</span>
<span class="line" id="L2338">        .Enum,</span>
<span class="line" id="L2339">        .Fn,</span>
<span class="line" id="L2340">        .ErrorSet,</span>
<span class="line" id="L2341">        .AnyFrame,</span>
<span class="line" id="L2342">        .EnumLiteral,</span>
<span class="line" id="L2343">        =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L2344">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L2345">    };</span>
<span class="line" id="L2346">}</span>
<span class="line" id="L2347"></span>
<span class="line" id="L2348"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAutoHashStratFn</span>(<span class="tok-kw">comptime</span> K: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Context: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> strategy: std.hash.Strategy) (<span class="tok-kw">fn</span> (Context, K) <span class="tok-type">u32</span>) {</span>
<span class="line" id="L2349">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2350">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(ctx: Context, key: K) <span class="tok-type">u32</span> {</span>
<span class="line" id="L2351">            _ = ctx;</span>
<span class="line" id="L2352">            <span class="tok-kw">var</span> hasher = Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L2353">            std.hash.autoHashStrat(&amp;hasher, key, strategy);</span>
<span class="line" id="L2354">            <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, hasher.final());</span>
<span class="line" id="L2355">        }</span>
<span class="line" id="L2356">    }.hash;</span>
<span class="line" id="L2357">}</span>
<span class="line" id="L2358"></span>
</code></pre></body>
</html>