<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>buf_set.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> StringHashMap = std.StringHashMap;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mem.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">/// A BufSet is a set of strings.  The BufSet duplicates</span></span>
<span class="line" id="L8"><span class="tok-comment">/// strings internally, and never takes ownership of strings</span></span>
<span class="line" id="L9"><span class="tok-comment">/// which are passed to it.</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufSet = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L11">    hash_map: BufSetHashMap,</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-kw">const</span> BufSetHashMap = StringHashMap(<span class="tok-type">void</span>);</span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = BufSetHashMap.KeyIterator;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-comment">/// Create a BufSet using an allocator.  The allocator will</span></span>
<span class="line" id="L17">    <span class="tok-comment">/// be used internally for both backing allocations and</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// string duplication.</span></span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(a: Allocator) BufSet {</span>
<span class="line" id="L20">        <span class="tok-kw">var</span> self = BufSet{ .hash_map = BufSetHashMap.init(a) };</span>
<span class="line" id="L21">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// Free a BufSet along with all stored keys.</span></span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *BufSet) <span class="tok-type">void</span> {</span>
<span class="line" id="L26">        <span class="tok-kw">var</span> it = self.hash_map.keyIterator();</span>
<span class="line" id="L27">        <span class="tok-kw">while</span> (it.next()) |key_ptr| {</span>
<span class="line" id="L28">            self.free(key_ptr.*);</span>
<span class="line" id="L29">        }</span>
<span class="line" id="L30">        self.hash_map.deinit();</span>
<span class="line" id="L31">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">/// Insert an item into the BufSet.  The item will be</span></span>
<span class="line" id="L35">    <span class="tok-comment">/// copied, so the caller may delete or reuse the</span></span>
<span class="line" id="L36">    <span class="tok-comment">/// passed string immediately.</span></span>
<span class="line" id="L37">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *BufSet, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L38">        <span class="tok-kw">const</span> gop = <span class="tok-kw">try</span> self.hash_map.getOrPut(value);</span>
<span class="line" id="L39">        <span class="tok-kw">if</span> (!gop.found_existing) {</span>
<span class="line" id="L40">            gop.key_ptr.* = self.copy(value) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L41">                _ = self.hash_map.remove(value);</span>
<span class="line" id="L42">                <span class="tok-kw">return</span> err;</span>
<span class="line" id="L43">            };</span>
<span class="line" id="L44">        }</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">/// Check if the set contains an item matching the passed string</span></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: BufSet, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L49">        <span class="tok-kw">return</span> self.hash_map.contains(value);</span>
<span class="line" id="L50">    }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-comment">/// Remove an item from the set.</span></span>
<span class="line" id="L53">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *BufSet, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">        <span class="tok-kw">const</span> kv = self.hash_map.fetchRemove(value) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L55">        self.free(kv.key);</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">/// Returns the number of items stored in the set</span></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: *<span class="tok-kw">const</span> BufSet) <span class="tok-type">usize</span> {</span>
<span class="line" id="L60">        <span class="tok-kw">return</span> self.hash_map.count();</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-comment">/// Returns an iterator over the items stored in the set.</span></span>
<span class="line" id="L64">    <span class="tok-comment">/// Iteration order is arbitrary.</span></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> BufSet) Iterator {</span>
<span class="line" id="L66">        <span class="tok-kw">return</span> self.hash_map.keyIterator();</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-comment">/// Get the allocator used by this set</span></span>
<span class="line" id="L70">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *<span class="tok-kw">const</span> BufSet) Allocator {</span>
<span class="line" id="L71">        <span class="tok-kw">return</span> self.hash_map.allocator;</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-comment">/// Creates a copy of this BufSet, using a specified allocator.</span></span>
<span class="line" id="L75">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cloneWithAllocator</span>(</span>
<span class="line" id="L76">        self: *<span class="tok-kw">const</span> BufSet,</span>
<span class="line" id="L77">        new_allocator: Allocator,</span>
<span class="line" id="L78">    ) Allocator.Error!BufSet {</span>
<span class="line" id="L79">        <span class="tok-kw">var</span> cloned_hashmap = <span class="tok-kw">try</span> self.hash_map.cloneWithAllocator(new_allocator);</span>
<span class="line" id="L80">        <span class="tok-kw">var</span> cloned = BufSet{ .hash_map = cloned_hashmap };</span>
<span class="line" id="L81">        <span class="tok-kw">var</span> it = cloned.hash_map.keyIterator();</span>
<span class="line" id="L82">        <span class="tok-kw">while</span> (it.next()) |key_ptr| {</span>
<span class="line" id="L83">            key_ptr.* = <span class="tok-kw">try</span> cloned.copy(key_ptr.*);</span>
<span class="line" id="L84">        }</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">        <span class="tok-kw">return</span> cloned;</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-comment">/// Creates a copy of this BufSet, using the same allocator.</span></span>
<span class="line" id="L90">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clone</span>(self: *<span class="tok-kw">const</span> BufSet) Allocator.Error!BufSet {</span>
<span class="line" id="L91">        <span class="tok-kw">return</span> self.cloneWithAllocator(self.allocator());</span>
<span class="line" id="L92">    }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(self: *<span class="tok-kw">const</span> BufSet, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L95">        self.hash_map.allocator.free(value);</span>
<span class="line" id="L96">    }</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(self: *<span class="tok-kw">const</span> BufSet, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L99">        <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> self.hash_map.allocator.alloc(<span class="tok-type">u8</span>, value.len);</span>
<span class="line" id="L100">        mem.copy(<span class="tok-type">u8</span>, result, value);</span>
<span class="line" id="L101">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L102">    }</span>
<span class="line" id="L103">};</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-kw">test</span> <span class="tok-str">&quot;BufSet&quot;</span> {</span>
<span class="line" id="L106">    <span class="tok-kw">var</span> bufset = BufSet.init(std.testing.allocator);</span>
<span class="line" id="L107">    <span class="tok-kw">defer</span> bufset.deinit();</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-kw">try</span> bufset.insert(<span class="tok-str">&quot;x&quot;</span>);</span>
<span class="line" id="L110">    <span class="tok-kw">try</span> testing.expect(bufset.count() == <span class="tok-number">1</span>);</span>
<span class="line" id="L111">    bufset.remove(<span class="tok-str">&quot;x&quot;</span>);</span>
<span class="line" id="L112">    <span class="tok-kw">try</span> testing.expect(bufset.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-kw">try</span> bufset.insert(<span class="tok-str">&quot;x&quot;</span>);</span>
<span class="line" id="L115">    <span class="tok-kw">try</span> bufset.insert(<span class="tok-str">&quot;y&quot;</span>);</span>
<span class="line" id="L116">    <span class="tok-kw">try</span> bufset.insert(<span class="tok-str">&quot;z&quot;</span>);</span>
<span class="line" id="L117">}</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-kw">test</span> <span class="tok-str">&quot;BufSet clone&quot;</span> {</span>
<span class="line" id="L120">    <span class="tok-kw">var</span> original = BufSet.init(testing.allocator);</span>
<span class="line" id="L121">    <span class="tok-kw">defer</span> original.deinit();</span>
<span class="line" id="L122">    <span class="tok-kw">try</span> original.insert(<span class="tok-str">&quot;x&quot;</span>);</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-kw">var</span> cloned = <span class="tok-kw">try</span> original.clone();</span>
<span class="line" id="L125">    <span class="tok-kw">defer</span> cloned.deinit();</span>
<span class="line" id="L126">    cloned.remove(<span class="tok-str">&quot;x&quot;</span>);</span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expect(original.count() == <span class="tok-number">1</span>);</span>
<span class="line" id="L128">    <span class="tok-kw">try</span> testing.expect(cloned.count() == <span class="tok-number">0</span>);</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L131">        <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L132">        original.cloneWithAllocator(testing.failing_allocator),</span>
<span class="line" id="L133">    );</span>
<span class="line" id="L134">}</span>
<span class="line" id="L135"></span>
<span class="line" id="L136"><span class="tok-kw">test</span> <span class="tok-str">&quot;BufSet.clone with arena&quot;</span> {</span>
<span class="line" id="L137">    <span class="tok-kw">var</span> allocator = std.testing.allocator;</span>
<span class="line" id="L138">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L139">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-kw">var</span> buf = BufSet.init(allocator);</span>
<span class="line" id="L142">    <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L143">    <span class="tok-kw">try</span> buf.insert(<span class="tok-str">&quot;member1&quot;</span>);</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> buf.insert(<span class="tok-str">&quot;member2&quot;</span>);</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    _ = <span class="tok-kw">try</span> buf.cloneWithAllocator(arena.allocator());</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
</code></pre></body>
</html>