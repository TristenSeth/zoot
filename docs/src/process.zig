<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>process.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> child_process = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;child_process.zig&quot;</span>);</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> abort = os.abort;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> exit = os.exit;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> changeCurDir = os.chdir;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> changeCurDirC = os.chdirC;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">/// The result is a slice of `out_buffer`, from index `0`.</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCwd</span>(out_buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L19">    <span class="tok-kw">return</span> os.getcwd(out_buffer);</span>
<span class="line" id="L20">}</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// Caller must free the returned memory.</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getCwdAlloc</span>(allocator: Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L24">    <span class="tok-comment">// The use of MAX_PATH_BYTES here is just a heuristic: most paths will fit</span>
</span>
<span class="line" id="L25">    <span class="tok-comment">// in stack_buf, avoiding an extra allocation in the common case.</span>
</span>
<span class="line" id="L26">    <span class="tok-kw">var</span> stack_buf: [fs.MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">var</span> heap_buf: ?[]<span class="tok-type">u8</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L28">    <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (heap_buf) |buf| allocator.free(buf);</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">var</span> current_buf: []<span class="tok-type">u8</span> = &amp;stack_buf;</span>
<span class="line" id="L31">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L32">        <span class="tok-kw">if</span> (os.getcwd(current_buf)) |slice| {</span>
<span class="line" id="L33">            <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, slice);</span>
<span class="line" id="L34">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L35">            <span class="tok-kw">error</span>.NameTooLong =&gt; {</span>
<span class="line" id="L36">                <span class="tok-comment">// The path is too long to fit in stack_buf. Allocate geometrically</span>
</span>
<span class="line" id="L37">                <span class="tok-comment">// increasing buffers until we find one that works</span>
</span>
<span class="line" id="L38">                <span class="tok-kw">const</span> new_capacity = current_buf.len * <span class="tok-number">2</span>;</span>
<span class="line" id="L39">                <span class="tok-kw">if</span> (heap_buf) |buf| allocator.free(buf);</span>
<span class="line" id="L40">                current_buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, new_capacity);</span>
<span class="line" id="L41">                heap_buf = current_buf;</span>
<span class="line" id="L42">            },</span>
<span class="line" id="L43">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L44">        }</span>
<span class="line" id="L45">    }</span>
<span class="line" id="L46">}</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-kw">test</span> <span class="tok-str">&quot;getCwdAlloc&quot;</span> {</span>
<span class="line" id="L49">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-kw">const</span> cwd = <span class="tok-kw">try</span> getCwdAlloc(testing.allocator);</span>
<span class="line" id="L52">    testing.allocator.free(cwd);</span>
<span class="line" id="L53">}</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnvMap = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L56">    hash_map: HashMap,</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-kw">const</span> HashMap = std.HashMap(</span>
<span class="line" id="L59">        []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L60">        []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L61">        EnvNameHashContext,</span>
<span class="line" id="L62">        std.hash_map.default_max_load_percentage,</span>
<span class="line" id="L63">    );</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Size = HashMap.Size;</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnvNameHashContext = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L68">        <span class="tok-kw">fn</span> <span class="tok-fn">upcase</span>(c: <span class="tok-type">u21</span>) <span class="tok-type">u21</span> {</span>
<span class="line" id="L69">            <span class="tok-kw">if</span> (c &lt;= std.math.maxInt(<span class="tok-type">u16</span>))</span>
<span class="line" id="L70">                <span class="tok-kw">return</span> std.os.windows.ntdll.RtlUpcaseUnicodeChar(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, c));</span>
<span class="line" id="L71">            <span class="tok-kw">return</span> c;</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(self: <span class="tok-builtin">@This</span>(), s: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L75">            _ = self;</span>
<span class="line" id="L76">            <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L77">                <span class="tok-kw">var</span> h = std.hash.Wyhash.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L78">                <span class="tok-kw">var</span> it = std.unicode.Utf8View.initUnchecked(s).iterator();</span>
<span class="line" id="L79">                <span class="tok-kw">while</span> (it.nextCodepoint()) |cp| {</span>
<span class="line" id="L80">                    <span class="tok-kw">const</span> cp_upper = upcase(cp);</span>
<span class="line" id="L81">                    h.update(&amp;[_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L82">                        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (cp_upper &gt;&gt; <span class="tok-number">16</span>) &amp; <span class="tok-number">0xff</span>),</span>
<span class="line" id="L83">                        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (cp_upper &gt;&gt; <span class="tok-number">8</span>) &amp; <span class="tok-number">0xff</span>),</span>
<span class="line" id="L84">                        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, (cp_upper &gt;&gt; <span class="tok-number">0</span>) &amp; <span class="tok-number">0xff</span>),</span>
<span class="line" id="L85">                    });</span>
<span class="line" id="L86">                }</span>
<span class="line" id="L87">                <span class="tok-kw">return</span> h.final();</span>
<span class="line" id="L88">            }</span>
<span class="line" id="L89">            <span class="tok-kw">return</span> std.hash_map.hashString(s);</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: <span class="tok-builtin">@This</span>(), a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L93">            _ = self;</span>
<span class="line" id="L94">            <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L95">                <span class="tok-kw">var</span> it_a = std.unicode.Utf8View.initUnchecked(a).iterator();</span>
<span class="line" id="L96">                <span class="tok-kw">var</span> it_b = std.unicode.Utf8View.initUnchecked(b).iterator();</span>
<span class="line" id="L97">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L98">                    <span class="tok-kw">const</span> c_a = it_a.nextCodepoint() <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L99">                    <span class="tok-kw">const</span> c_b = it_b.nextCodepoint() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L100">                    <span class="tok-kw">if</span> (upcase(c_a) != upcase(c_b))</span>
<span class="line" id="L101">                        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L102">                }</span>
<span class="line" id="L103">                <span class="tok-kw">return</span> <span class="tok-kw">if</span> (it_b.nextCodepoint()) |_| <span class="tok-null">false</span> <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L104">            }</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> std.hash_map.eqlString(a, b);</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107">    };</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">/// Create a EnvMap backed by a specific allocator.</span></span>
<span class="line" id="L110">    <span class="tok-comment">/// That allocator will be used for both backing allocations</span></span>
<span class="line" id="L111">    <span class="tok-comment">/// and string deduplication.</span></span>
<span class="line" id="L112">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator) EnvMap {</span>
<span class="line" id="L113">        <span class="tok-kw">return</span> EnvMap{ .hash_map = HashMap.init(allocator) };</span>
<span class="line" id="L114">    }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    <span class="tok-comment">/// Free the backing storage of the map, as well as all</span></span>
<span class="line" id="L117">    <span class="tok-comment">/// of the stored keys and values.</span></span>
<span class="line" id="L118">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *EnvMap) <span class="tok-type">void</span> {</span>
<span class="line" id="L119">        <span class="tok-kw">var</span> it = self.hash_map.iterator();</span>
<span class="line" id="L120">        <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L121">            self.free(entry.key_ptr.*);</span>
<span class="line" id="L122">            self.free(entry.value_ptr.*);</span>
<span class="line" id="L123">        }</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">        self.hash_map.deinit();</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// Same as `put` but the key and value become owned by the EnvMap rather</span></span>
<span class="line" id="L129">    <span class="tok-comment">/// than being copied.</span></span>
<span class="line" id="L130">    <span class="tok-comment">/// If `putMove` fails, the ownership of key and value does not transfer.</span></span>
<span class="line" id="L131">    <span class="tok-comment">/// On Windows `key` must be a valid UTF-8 string.</span></span>
<span class="line" id="L132">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putMove</span>(self: *EnvMap, key: []<span class="tok-type">u8</span>, value: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L133">        <span class="tok-kw">const</span> get_or_put = <span class="tok-kw">try</span> self.hash_map.getOrPut(key);</span>
<span class="line" id="L134">        <span class="tok-kw">if</span> (get_or_put.found_existing) {</span>
<span class="line" id="L135">            self.free(get_or_put.key_ptr.*);</span>
<span class="line" id="L136">            self.free(get_or_put.value_ptr.*);</span>
<span class="line" id="L137">            get_or_put.key_ptr.* = key;</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139">        get_or_put.value_ptr.* = value;</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-comment">/// `key` and `value` are copied into the EnvMap.</span></span>
<span class="line" id="L143">    <span class="tok-comment">/// On Windows `key` must be a valid UTF-8 string.</span></span>
<span class="line" id="L144">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *EnvMap, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L145">        <span class="tok-kw">const</span> value_copy = <span class="tok-kw">try</span> self.copy(value);</span>
<span class="line" id="L146">        <span class="tok-kw">errdefer</span> self.free(value_copy);</span>
<span class="line" id="L147">        <span class="tok-kw">const</span> get_or_put = <span class="tok-kw">try</span> self.hash_map.getOrPut(key);</span>
<span class="line" id="L148">        <span class="tok-kw">if</span> (get_or_put.found_existing) {</span>
<span class="line" id="L149">            self.free(get_or_put.value_ptr.*);</span>
<span class="line" id="L150">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L151">            get_or_put.key_ptr.* = self.copy(key) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L152">                _ = self.hash_map.remove(key);</span>
<span class="line" id="L153">                <span class="tok-kw">return</span> err;</span>
<span class="line" id="L154">            };</span>
<span class="line" id="L155">        }</span>
<span class="line" id="L156">        get_or_put.value_ptr.* = value_copy;</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-comment">/// Find the address of the value associated with a key.</span></span>
<span class="line" id="L160">    <span class="tok-comment">/// The returned pointer is invalidated if the map resizes.</span></span>
<span class="line" id="L161">    <span class="tok-comment">/// On Windows `key` must be a valid UTF-8 string.</span></span>
<span class="line" id="L162">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: EnvMap, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?*[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L163">        <span class="tok-kw">return</span> self.hash_map.getPtr(key);</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-comment">/// Return the map's copy of the value associated with</span></span>
<span class="line" id="L167">    <span class="tok-comment">/// a key.  The returned string is invalidated if this</span></span>
<span class="line" id="L168">    <span class="tok-comment">/// key is removed from the map.</span></span>
<span class="line" id="L169">    <span class="tok-comment">/// On Windows `key` must be a valid UTF-8 string.</span></span>
<span class="line" id="L170">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: EnvMap, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L171">        <span class="tok-kw">return</span> self.hash_map.get(key);</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">    <span class="tok-comment">/// Removes the item from the map and frees its value.</span></span>
<span class="line" id="L175">    <span class="tok-comment">/// This invalidates the value returned by get() for this key.</span></span>
<span class="line" id="L176">    <span class="tok-comment">/// On Windows `key` must be a valid UTF-8 string.</span></span>
<span class="line" id="L177">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *EnvMap, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L178">        <span class="tok-kw">const</span> kv = self.hash_map.fetchRemove(key) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L179">        self.free(kv.key);</span>
<span class="line" id="L180">        self.free(kv.value);</span>
<span class="line" id="L181">    }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">    <span class="tok-comment">/// Returns the number of KV pairs stored in the map.</span></span>
<span class="line" id="L184">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: EnvMap) HashMap.Size {</span>
<span class="line" id="L185">        <span class="tok-kw">return</span> self.hash_map.count();</span>
<span class="line" id="L186">    }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">    <span class="tok-comment">/// Returns an iterator over entries in the map.</span></span>
<span class="line" id="L189">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *<span class="tok-kw">const</span> EnvMap) HashMap.Iterator {</span>
<span class="line" id="L190">        <span class="tok-kw">return</span> self.hash_map.iterator();</span>
<span class="line" id="L191">    }</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(self: EnvMap, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L194">        self.hash_map.allocator.free(value);</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">    <span class="tok-kw">fn</span> <span class="tok-fn">copy</span>(self: EnvMap, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L198">        <span class="tok-kw">return</span> self.hash_map.allocator.dupe(<span class="tok-type">u8</span>, value);</span>
<span class="line" id="L199">    }</span>
<span class="line" id="L200">};</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">test</span> <span class="tok-str">&quot;EnvMap&quot;</span> {</span>
<span class="line" id="L203">    <span class="tok-kw">var</span> env = EnvMap.init(testing.allocator);</span>
<span class="line" id="L204">    <span class="tok-kw">defer</span> env.deinit();</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">    <span class="tok-kw">try</span> env.put(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>, <span class="tok-str">&quot;hello&quot;</span>);</span>
<span class="line" id="L207">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;hello&quot;</span>, env.get(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>).?);</span>
<span class="line" id="L208">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(EnvMap.Size, <span class="tok-number">1</span>), env.count());</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-comment">// overwrite</span>
</span>
<span class="line" id="L211">    <span class="tok-kw">try</span> env.put(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>, <span class="tok-str">&quot;something&quot;</span>);</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;something&quot;</span>, env.get(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>).?);</span>
<span class="line" id="L213">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(EnvMap.Size, <span class="tok-number">1</span>), env.count());</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">    <span class="tok-comment">// a new longer name to test the Windows-specific conversion buffer</span>
</span>
<span class="line" id="L216">    <span class="tok-kw">try</span> env.put(<span class="tok-str">&quot;SOMETHING_NEW_AND_LONGER&quot;</span>, <span class="tok-str">&quot;1&quot;</span>);</span>
<span class="line" id="L217">    <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;1&quot;</span>, env.get(<span class="tok-str">&quot;SOMETHING_NEW_AND_LONGER&quot;</span>).?);</span>
<span class="line" id="L218">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(EnvMap.Size, <span class="tok-number">2</span>), env.count());</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">    <span class="tok-comment">// case insensitivity on Windows only</span>
</span>
<span class="line" id="L221">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L222">        <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;1&quot;</span>, env.get(<span class="tok-str">&quot;something_New_aNd_LONGER&quot;</span>).?);</span>
<span class="line" id="L223">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L224">        <span class="tok-kw">try</span> testing.expect(<span class="tok-null">null</span> == env.get(<span class="tok-str">&quot;something_New_aNd_LONGER&quot;</span>));</span>
<span class="line" id="L225">    }</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">var</span> it = env.iterator();</span>
<span class="line" id="L228">    <span class="tok-kw">var</span> count: EnvMap.Size = <span class="tok-number">0</span>;</span>
<span class="line" id="L229">    <span class="tok-kw">while</span> (it.next()) |entry| {</span>
<span class="line" id="L230">        <span class="tok-kw">const</span> is_an_expected_name = std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;SOMETHING_NEW&quot;</span>, entry.key_ptr.*) <span class="tok-kw">or</span> std.mem.eql(<span class="tok-type">u8</span>, <span class="tok-str">&quot;SOMETHING_NEW_AND_LONGER&quot;</span>, entry.key_ptr.*);</span>
<span class="line" id="L231">        <span class="tok-kw">try</span> testing.expect(is_an_expected_name);</span>
<span class="line" id="L232">        count += <span class="tok-number">1</span>;</span>
<span class="line" id="L233">    }</span>
<span class="line" id="L234">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(EnvMap.Size, <span class="tok-number">2</span>), count);</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">    env.remove(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> testing.expect(env.get(<span class="tok-str">&quot;SOMETHING_NEW&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(EnvMap.Size, <span class="tok-number">1</span>), env.count());</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">    <span class="tok-comment">// test Unicode case-insensitivity on Windows</span>
</span>
<span class="line" id="L242">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L243">        <span class="tok-kw">try</span> env.put(<span class="tok-str">&quot;КИРиллИЦА&quot;</span>, <span class="tok-str">&quot;something else&quot;</span>);</span>
<span class="line" id="L244">        <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-str">&quot;something else&quot;</span>, env.get(<span class="tok-str">&quot;кириллица&quot;</span>).?);</span>
<span class="line" id="L245">    }</span>
<span class="line" id="L246">}</span>
<span class="line" id="L247"></span>
<span class="line" id="L248"><span class="tok-comment">/// Returns a snapshot of the environment variables of the current process.</span></span>
<span class="line" id="L249"><span class="tok-comment">/// Any modifications to the resulting EnvMap will not be not reflected in the environment, and</span></span>
<span class="line" id="L250"><span class="tok-comment">/// likewise, any future modifications to the environment will not be reflected in the EnvMap.</span></span>
<span class="line" id="L251"><span class="tok-comment">/// Caller owns resulting `EnvMap` and should call its `deinit` fn when done.</span></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEnvMap</span>(allocator: Allocator) !EnvMap {</span>
<span class="line" id="L253">    <span class="tok-kw">var</span> result = EnvMap.init(allocator);</span>
<span class="line" id="L254">    <span class="tok-kw">errdefer</span> result.deinit();</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L257">        <span class="tok-kw">const</span> ptr = os.windows.peb().ProcessParameters.Environment;</span>
<span class="line" id="L258"></span>
<span class="line" id="L259">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L260">        <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L261">            <span class="tok-kw">const</span> key_start = i;</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">            <span class="tok-comment">// There are some special environment variables that start with =,</span>
</span>
<span class="line" id="L264">            <span class="tok-comment">// so we need a special case to not treat = as a key/value separator</span>
</span>
<span class="line" id="L265">            <span class="tok-comment">// if it's the first character.</span>
</span>
<span class="line" id="L266">            <span class="tok-comment">// https://devblogs.microsoft.com/oldnewthing/20100506-00/?p=14133</span>
</span>
<span class="line" id="L267">            <span class="tok-kw">if</span> (ptr[key_start] == <span class="tok-str">'='</span>) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">            <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> ptr[i] != <span class="tok-str">'='</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L270">            <span class="tok-kw">const</span> key_w = ptr[key_start..i];</span>
<span class="line" id="L271">            <span class="tok-kw">const</span> key = <span class="tok-kw">try</span> std.unicode.utf16leToUtf8Alloc(allocator, key_w);</span>
<span class="line" id="L272">            <span class="tok-kw">errdefer</span> allocator.free(key);</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">            <span class="tok-kw">if</span> (ptr[i] == <span class="tok-str">'='</span>) i += <span class="tok-number">1</span>;</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">            <span class="tok-kw">const</span> value_start = i;</span>
<span class="line" id="L277">            <span class="tok-kw">while</span> (ptr[i] != <span class="tok-number">0</span>) : (i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L278">            <span class="tok-kw">const</span> value_w = ptr[value_start..i];</span>
<span class="line" id="L279">            <span class="tok-kw">const</span> value = <span class="tok-kw">try</span> std.unicode.utf16leToUtf8Alloc(allocator, value_w);</span>
<span class="line" id="L280">            <span class="tok-kw">errdefer</span> allocator.free(value);</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">            i += <span class="tok-number">1</span>; <span class="tok-comment">// skip over null byte</span>
</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">            <span class="tok-kw">try</span> result.putMove(key, value);</span>
<span class="line" id="L285">        }</span>
<span class="line" id="L286">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L287">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L288">        <span class="tok-kw">var</span> environ_count: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L289">        <span class="tok-kw">var</span> environ_buf_size: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">        <span class="tok-kw">const</span> environ_sizes_get_ret = os.wasi.environ_sizes_get(&amp;environ_count, &amp;environ_buf_size);</span>
<span class="line" id="L292">        <span class="tok-kw">if</span> (environ_sizes_get_ret != .SUCCESS) {</span>
<span class="line" id="L293">            <span class="tok-kw">return</span> os.unexpectedErrno(environ_sizes_get_ret);</span>
<span class="line" id="L294">        }</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-kw">var</span> environ = <span class="tok-kw">try</span> allocator.alloc([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, environ_count);</span>
<span class="line" id="L297">        <span class="tok-kw">defer</span> allocator.free(environ);</span>
<span class="line" id="L298">        <span class="tok-kw">var</span> environ_buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, environ_buf_size);</span>
<span class="line" id="L299">        <span class="tok-kw">defer</span> allocator.free(environ_buf);</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">        <span class="tok-kw">const</span> environ_get_ret = os.wasi.environ_get(environ.ptr, environ_buf.ptr);</span>
<span class="line" id="L302">        <span class="tok-kw">if</span> (environ_get_ret != .SUCCESS) {</span>
<span class="line" id="L303">            <span class="tok-kw">return</span> os.unexpectedErrno(environ_get_ret);</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305"></span>
<span class="line" id="L306">        <span class="tok-kw">for</span> (environ) |env| {</span>
<span class="line" id="L307">            <span class="tok-kw">const</span> pair = mem.sliceTo(env, <span class="tok-number">0</span>);</span>
<span class="line" id="L308">            <span class="tok-kw">var</span> parts = mem.split(<span class="tok-type">u8</span>, pair, <span class="tok-str">&quot;=&quot;</span>);</span>
<span class="line" id="L309">            <span class="tok-kw">const</span> key = parts.first();</span>
<span class="line" id="L310">            <span class="tok-kw">const</span> value = parts.next().?;</span>
<span class="line" id="L311">            <span class="tok-kw">try</span> result.put(key, value);</span>
<span class="line" id="L312">        }</span>
<span class="line" id="L313">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L314">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L315">        <span class="tok-kw">var</span> ptr = std.c.environ;</span>
<span class="line" id="L316">        <span class="tok-kw">while</span> (ptr[<span class="tok-number">0</span>]) |line| : (ptr += <span class="tok-number">1</span>) {</span>
<span class="line" id="L317">            <span class="tok-kw">var</span> line_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L318">            <span class="tok-kw">while</span> (line[line_i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> line[line_i] != <span class="tok-str">'='</span>) : (line_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L319">            <span class="tok-kw">const</span> key = line[<span class="tok-number">0</span>..line_i];</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">            <span class="tok-kw">var</span> end_i: <span class="tok-type">usize</span> = line_i;</span>
<span class="line" id="L322">            <span class="tok-kw">while</span> (line[end_i] != <span class="tok-number">0</span>) : (end_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L323">            <span class="tok-kw">const</span> value = line[line_i + <span class="tok-number">1</span> .. end_i];</span>
<span class="line" id="L324"></span>
<span class="line" id="L325">            <span class="tok-kw">try</span> result.put(key, value);</span>
<span class="line" id="L326">        }</span>
<span class="line" id="L327">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L328">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L329">        <span class="tok-kw">for</span> (os.environ) |line| {</span>
<span class="line" id="L330">            <span class="tok-kw">var</span> line_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L331">            <span class="tok-kw">while</span> (line[line_i] != <span class="tok-number">0</span> <span class="tok-kw">and</span> line[line_i] != <span class="tok-str">'='</span>) : (line_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L332">            <span class="tok-kw">const</span> key = line[<span class="tok-number">0</span>..line_i];</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">            <span class="tok-kw">var</span> end_i: <span class="tok-type">usize</span> = line_i;</span>
<span class="line" id="L335">            <span class="tok-kw">while</span> (line[end_i] != <span class="tok-number">0</span>) : (end_i += <span class="tok-number">1</span>) {}</span>
<span class="line" id="L336">            <span class="tok-kw">const</span> value = line[line_i + <span class="tok-number">1</span> .. end_i];</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">            <span class="tok-kw">try</span> result.put(key, value);</span>
<span class="line" id="L339">        }</span>
<span class="line" id="L340">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L341">    }</span>
<span class="line" id="L342">}</span>
<span class="line" id="L343"></span>
<span class="line" id="L344"><span class="tok-kw">test</span> <span class="tok-str">&quot;getEnvMap&quot;</span> {</span>
<span class="line" id="L345">    <span class="tok-kw">var</span> env = <span class="tok-kw">try</span> getEnvMap(testing.allocator);</span>
<span class="line" id="L346">    <span class="tok-kw">defer</span> env.deinit();</span>
<span class="line" id="L347">}</span>
<span class="line" id="L348"></span>
<span class="line" id="L349"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetEnvVarOwnedError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L350">    OutOfMemory,</span>
<span class="line" id="L351">    EnvironmentVariableNotFound,</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">    <span class="tok-comment">/// See https://github.com/ziglang/zig/issues/1774</span></span>
<span class="line" id="L354">    InvalidUtf8,</span>
<span class="line" id="L355">};</span>
<span class="line" id="L356"></span>
<span class="line" id="L357"><span class="tok-comment">/// Caller must free returned memory.</span></span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEnvVarOwned</span>(allocator: mem.Allocator, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) GetEnvVarOwnedError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L359">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L360">        <span class="tok-kw">const</span> result_w = blk: {</span>
<span class="line" id="L361">            <span class="tok-kw">const</span> key_w = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16LeWithNull(allocator, key);</span>
<span class="line" id="L362">            <span class="tok-kw">defer</span> allocator.free(key_w);</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">            <span class="tok-kw">break</span> :blk std.os.getenvW(key_w) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EnvironmentVariableNotFound;</span>
<span class="line" id="L365">        };</span>
<span class="line" id="L366">        <span class="tok-kw">return</span> std.unicode.utf16leToUtf8Alloc(allocator, result_w) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L367">            <span class="tok-kw">error</span>.DanglingSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L368">            <span class="tok-kw">error</span>.ExpectedSecondSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L369">            <span class="tok-kw">error</span>.UnexpectedSecondSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L370">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L371">        };</span>
<span class="line" id="L372">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L373">        <span class="tok-kw">const</span> result = os.getenv(key) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EnvironmentVariableNotFound;</span>
<span class="line" id="L374">        <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, result);</span>
<span class="line" id="L375">    }</span>
<span class="line" id="L376">}</span>
<span class="line" id="L377"></span>
<span class="line" id="L378"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasEnvVarConstant</span>(<span class="tok-kw">comptime</span> key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L379">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L380">        <span class="tok-kw">const</span> key_w = <span class="tok-kw">comptime</span> std.unicode.utf8ToUtf16LeStringLiteral(key);</span>
<span class="line" id="L381">        <span class="tok-kw">return</span> std.os.getenvW(key_w) != <span class="tok-null">null</span>;</span>
<span class="line" id="L382">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L383">        <span class="tok-kw">return</span> os.getenv(key) != <span class="tok-null">null</span>;</span>
<span class="line" id="L384">    }</span>
<span class="line" id="L385">}</span>
<span class="line" id="L386"></span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hasEnvVar</span>(allocator: Allocator, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">error</span>{OutOfMemory}!<span class="tok-type">bool</span> {</span>
<span class="line" id="L388">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L389">        <span class="tok-kw">var</span> stack_alloc = std.heap.stackFallback(<span class="tok-number">256</span> * <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>), allocator);</span>
<span class="line" id="L390">        <span class="tok-kw">const</span> key_w = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16LeWithNull(stack_alloc.get(), key);</span>
<span class="line" id="L391">        <span class="tok-kw">defer</span> stack_alloc.allocator.free(key_w);</span>
<span class="line" id="L392">        <span class="tok-kw">return</span> std.os.getenvW(key_w) != <span class="tok-null">null</span>;</span>
<span class="line" id="L393">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L394">        <span class="tok-kw">return</span> os.getenv(key) != <span class="tok-null">null</span>;</span>
<span class="line" id="L395">    }</span>
<span class="line" id="L396">}</span>
<span class="line" id="L397"></span>
<span class="line" id="L398"><span class="tok-kw">test</span> <span class="tok-str">&quot;os.getEnvVarOwned&quot;</span> {</span>
<span class="line" id="L399">    <span class="tok-kw">var</span> ga = std.testing.allocator;</span>
<span class="line" id="L400">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.EnvironmentVariableNotFound, getEnvVarOwned(ga, <span class="tok-str">&quot;BADENV&quot;</span>));</span>
<span class="line" id="L401">}</span>
<span class="line" id="L402"></span>
<span class="line" id="L403"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArgIteratorPosix = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L404">    index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L405">    count: <span class="tok-type">usize</span>,</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitError = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() ArgIteratorPosix {</span>
<span class="line" id="L410">        <span class="tok-kw">return</span> ArgIteratorPosix{</span>
<span class="line" id="L411">            .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L412">            .count = os.argv.len,</span>
<span class="line" id="L413">        };</span>
<span class="line" id="L414">    }</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *ArgIteratorPosix) ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L417">        <span class="tok-kw">if</span> (self.index == self.count) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">        <span class="tok-kw">const</span> s = os.argv[self.index];</span>
<span class="line" id="L420">        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L421">        <span class="tok-kw">return</span> mem.sliceTo(s, <span class="tok-number">0</span>);</span>
<span class="line" id="L422">    }</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skip</span>(self: *ArgIteratorPosix) <span class="tok-type">bool</span> {</span>
<span class="line" id="L425">        <span class="tok-kw">if</span> (self.index == self.count) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L426"></span>
<span class="line" id="L427">        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L428">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L429">    }</span>
<span class="line" id="L430">};</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArgIteratorWasi = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L433">    allocator: mem.Allocator,</span>
<span class="line" id="L434">    index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L435">    args: [][:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L436"></span>
<span class="line" id="L437">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitError = <span class="tok-kw">error</span>{OutOfMemory} || os.UnexpectedError;</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">    <span class="tok-comment">/// You must call deinit to free the internal buffer of the</span></span>
<span class="line" id="L440">    <span class="tok-comment">/// iterator after you are done.</span></span>
<span class="line" id="L441">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator) InitError!ArgIteratorWasi {</span>
<span class="line" id="L442">        <span class="tok-kw">const</span> fetched_args = <span class="tok-kw">try</span> ArgIteratorWasi.internalInit(allocator);</span>
<span class="line" id="L443">        <span class="tok-kw">return</span> ArgIteratorWasi{</span>
<span class="line" id="L444">            .allocator = allocator,</span>
<span class="line" id="L445">            .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L446">            .args = fetched_args,</span>
<span class="line" id="L447">        };</span>
<span class="line" id="L448">    }</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">    <span class="tok-kw">fn</span> <span class="tok-fn">internalInit</span>(allocator: mem.Allocator) InitError![][:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L451">        <span class="tok-kw">const</span> w = os.wasi;</span>
<span class="line" id="L452">        <span class="tok-kw">var</span> count: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L453">        <span class="tok-kw">var</span> buf_size: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">        <span class="tok-kw">switch</span> (w.args_sizes_get(&amp;count, &amp;buf_size)) {</span>
<span class="line" id="L456">            .SUCCESS =&gt; {},</span>
<span class="line" id="L457">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L458">        }</span>
<span class="line" id="L459"></span>
<span class="line" id="L460">        <span class="tok-kw">var</span> argv = <span class="tok-kw">try</span> allocator.alloc([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, count);</span>
<span class="line" id="L461">        <span class="tok-kw">defer</span> allocator.free(argv);</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">        <span class="tok-kw">var</span> argv_buf = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, buf_size);</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-kw">switch</span> (w.args_get(argv.ptr, argv_buf.ptr)) {</span>
<span class="line" id="L466">            .SUCCESS =&gt; {},</span>
<span class="line" id="L467">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L468">        }</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">        <span class="tok-kw">var</span> result_args = <span class="tok-kw">try</span> allocator.alloc([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, count);</span>
<span class="line" id="L471">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L472">        <span class="tok-kw">while</span> (i &lt; count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L473">            result_args[i] = mem.sliceTo(argv[i], <span class="tok-number">0</span>);</span>
<span class="line" id="L474">        }</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">        <span class="tok-kw">return</span> result_args;</span>
<span class="line" id="L477">    }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *ArgIteratorWasi) ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L480">        <span class="tok-kw">if</span> (self.index == self.args.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L481"></span>
<span class="line" id="L482">        <span class="tok-kw">const</span> arg = self.args[self.index];</span>
<span class="line" id="L483">        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L484">        <span class="tok-kw">return</span> arg;</span>
<span class="line" id="L485">    }</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skip</span>(self: *ArgIteratorWasi) <span class="tok-type">bool</span> {</span>
<span class="line" id="L488">        <span class="tok-kw">if</span> (self.index == self.args.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L489"></span>
<span class="line" id="L490">        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L491">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L492">    }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-comment">/// Call to free the internal buffer of the iterator.</span></span>
<span class="line" id="L495">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *ArgIteratorWasi) <span class="tok-type">void</span> {</span>
<span class="line" id="L496">        <span class="tok-kw">const</span> last_item = self.args[self.args.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L497">        <span class="tok-kw">const</span> last_byte_addr = <span class="tok-builtin">@ptrToInt</span>(last_item.ptr) + last_item.len + <span class="tok-number">1</span>; <span class="tok-comment">// null terminated</span>
</span>
<span class="line" id="L498">        <span class="tok-kw">const</span> first_item_ptr = self.args[<span class="tok-number">0</span>].ptr;</span>
<span class="line" id="L499">        <span class="tok-kw">const</span> len = last_byte_addr - <span class="tok-builtin">@ptrToInt</span>(first_item_ptr);</span>
<span class="line" id="L500">        self.allocator.free(first_item_ptr[<span class="tok-number">0</span>..len]);</span>
<span class="line" id="L501">        self.allocator.free(self.args);</span>
<span class="line" id="L502">    }</span>
<span class="line" id="L503">};</span>
<span class="line" id="L504"></span>
<span class="line" id="L505"><span class="tok-comment">/// Optional parameters for `ArgIteratorGeneral`</span></span>
<span class="line" id="L506"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArgIteratorGeneralOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L507">    comments: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L508">    single_quotes: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L509">};</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-comment">/// A general Iterator to parse a string into a set of arguments</span></span>
<span class="line" id="L512"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ArgIteratorGeneral</span>(<span class="tok-kw">comptime</span> options: ArgIteratorGeneralOptions) <span class="tok-type">type</span> {</span>
<span class="line" id="L513">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L514">        allocator: Allocator,</span>
<span class="line" id="L515">        index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L516">        cmd_line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">        <span class="tok-comment">/// Should the cmd_line field be free'd (using the allocator) on deinit()?</span></span>
<span class="line" id="L519">        free_cmd_line_on_deinit: <span class="tok-type">bool</span>,</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">        <span class="tok-comment">/// buffer MUST be long enough to hold the cmd_line plus a null terminator.</span></span>
<span class="line" id="L522">        <span class="tok-comment">/// buffer will we free'd (using the allocator) on deinit()</span></span>
<span class="line" id="L523">        buffer: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L524">        start: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L525">        end: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L526"></span>
<span class="line" id="L527">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L528"></span>
<span class="line" id="L529">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitError = <span class="tok-kw">error</span>{OutOfMemory};</span>
<span class="line" id="L530">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitUtf16leError = <span class="tok-kw">error</span>{ OutOfMemory, InvalidCmdLine };</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">        <span class="tok-comment">/// cmd_line_utf8 MUST remain valid and constant while using this instance</span></span>
<span class="line" id="L533">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: Allocator, cmd_line_utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) InitError!Self {</span>
<span class="line" id="L534">            <span class="tok-kw">var</span> buffer = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, cmd_line_utf8.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L535">            <span class="tok-kw">errdefer</span> allocator.free(buffer);</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L538">                .allocator = allocator,</span>
<span class="line" id="L539">                .cmd_line = cmd_line_utf8,</span>
<span class="line" id="L540">                .free_cmd_line_on_deinit = <span class="tok-null">false</span>,</span>
<span class="line" id="L541">                .buffer = buffer,</span>
<span class="line" id="L542">            };</span>
<span class="line" id="L543">        }</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">        <span class="tok-comment">/// cmd_line_utf8 will be free'd (with the allocator) on deinit()</span></span>
<span class="line" id="L546">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initTakeOwnership</span>(allocator: Allocator, cmd_line_utf8: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) InitError!Self {</span>
<span class="line" id="L547">            <span class="tok-kw">var</span> buffer = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, cmd_line_utf8.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L548">            <span class="tok-kw">errdefer</span> allocator.free(buffer);</span>
<span class="line" id="L549"></span>
<span class="line" id="L550">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L551">                .allocator = allocator,</span>
<span class="line" id="L552">                .cmd_line = cmd_line_utf8,</span>
<span class="line" id="L553">                .free_cmd_line_on_deinit = <span class="tok-null">true</span>,</span>
<span class="line" id="L554">                .buffer = buffer,</span>
<span class="line" id="L555">            };</span>
<span class="line" id="L556">        }</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">        <span class="tok-comment">/// cmd_line_utf16le MUST be encoded UTF16-LE, and is converted to UTF-8 in an internal buffer</span></span>
<span class="line" id="L559">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initUtf16le</span>(allocator: Allocator, cmd_line_utf16le: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) InitUtf16leError!Self {</span>
<span class="line" id="L560">            <span class="tok-kw">var</span> utf16le_slice = mem.sliceTo(cmd_line_utf16le, <span class="tok-number">0</span>);</span>
<span class="line" id="L561">            <span class="tok-kw">var</span> cmd_line = std.unicode.utf16leToUtf8Alloc(allocator, utf16le_slice) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L562">                <span class="tok-kw">error</span>.ExpectedSecondSurrogateHalf,</span>
<span class="line" id="L563">                <span class="tok-kw">error</span>.DanglingSurrogateHalf,</span>
<span class="line" id="L564">                <span class="tok-kw">error</span>.UnexpectedSecondSurrogateHalf,</span>
<span class="line" id="L565">                =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidCmdLine,</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">                <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L568">            };</span>
<span class="line" id="L569">            <span class="tok-kw">errdefer</span> allocator.free(cmd_line);</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">            <span class="tok-kw">var</span> buffer = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, cmd_line.len + <span class="tok-number">1</span>);</span>
<span class="line" id="L572">            <span class="tok-kw">errdefer</span> allocator.free(buffer);</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L575">                .allocator = allocator,</span>
<span class="line" id="L576">                .cmd_line = cmd_line,</span>
<span class="line" id="L577">                .free_cmd_line_on_deinit = <span class="tok-null">true</span>,</span>
<span class="line" id="L578">                .buffer = buffer,</span>
<span class="line" id="L579">            };</span>
<span class="line" id="L580">        }</span>
<span class="line" id="L581"></span>
<span class="line" id="L582">        <span class="tok-comment">// Skips over whitespace in the cmd_line.</span>
</span>
<span class="line" id="L583">        <span class="tok-comment">// Returns false if the terminating sentinel is reached, true otherwise.</span>
</span>
<span class="line" id="L584">        <span class="tok-comment">// Also skips over comments (if supported).</span>
</span>
<span class="line" id="L585">        <span class="tok-kw">fn</span> <span class="tok-fn">skipWhitespace</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L586">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L587">                <span class="tok-kw">const</span> character = <span class="tok-kw">if</span> (self.index != self.cmd_line.len) self.cmd_line[self.index] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L588">                <span class="tok-kw">switch</span> (character) {</span>
<span class="line" id="L589">                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L590">                    <span class="tok-str">' '</span>, <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span>, <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L591">                    <span class="tok-str">'#'</span> =&gt; {</span>
<span class="line" id="L592">                        <span class="tok-kw">if</span> (options.comments) {</span>
<span class="line" id="L593">                            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L594">                                <span class="tok-kw">switch</span> (self.cmd_line[self.index]) {</span>
<span class="line" id="L595">                                    <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L596">                                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L597">                                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L598">                                }</span>
<span class="line" id="L599">                            }</span>
<span class="line" id="L600">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L601">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L602">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L603">                        }</span>
<span class="line" id="L604">                    },</span>
<span class="line" id="L605">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span>,</span>
<span class="line" id="L606">                }</span>
<span class="line" id="L607">            }</span>
<span class="line" id="L608">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L609">        }</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skip</span>(self: *Self) <span class="tok-type">bool</span> {</span>
<span class="line" id="L612">            <span class="tok-kw">if</span> (!self.skipWhitespace()) {</span>
<span class="line" id="L613">                <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L614">            }</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">            <span class="tok-kw">var</span> backslash_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L617">            <span class="tok-kw">var</span> in_quote = <span class="tok-null">false</span>;</span>
<span class="line" id="L618">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L619">                <span class="tok-kw">const</span> character = <span class="tok-kw">if</span> (self.index != self.cmd_line.len) self.cmd_line[self.index] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L620">                <span class="tok-kw">switch</span> (character) {</span>
<span class="line" id="L621">                    <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">true</span>,</span>
<span class="line" id="L622">                    <span class="tok-str">'&quot;'</span>, <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L623">                        <span class="tok-kw">if</span> (!options.single_quotes <span class="tok-kw">and</span> character == <span class="tok-str">'\''</span>) {</span>
<span class="line" id="L624">                            backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L625">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L626">                        }</span>
<span class="line" id="L627">                        <span class="tok-kw">const</span> quote_is_real = backslash_count % <span class="tok-number">2</span> == <span class="tok-number">0</span>;</span>
<span class="line" id="L628">                        <span class="tok-kw">if</span> (quote_is_real) {</span>
<span class="line" id="L629">                            in_quote = !in_quote;</span>
<span class="line" id="L630">                        }</span>
<span class="line" id="L631">                    },</span>
<span class="line" id="L632">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L633">                        backslash_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L634">                    },</span>
<span class="line" id="L635">                    <span class="tok-str">' '</span>, <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L636">                        <span class="tok-kw">if</span> (!in_quote) {</span>
<span class="line" id="L637">                            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L638">                        }</span>
<span class="line" id="L639">                        backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L640">                    },</span>
<span class="line" id="L641">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L642">                        backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L643">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L644">                    },</span>
<span class="line" id="L645">                }</span>
<span class="line" id="L646">            }</span>
<span class="line" id="L647">        }</span>
<span class="line" id="L648"></span>
<span class="line" id="L649">        <span class="tok-comment">/// Returns a slice of the internal buffer that contains the next argument.</span></span>
<span class="line" id="L650">        <span class="tok-comment">/// Returns null when it reaches the end.</span></span>
<span class="line" id="L651">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L652">            <span class="tok-kw">if</span> (!self.skipWhitespace()) {</span>
<span class="line" id="L653">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L654">            }</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">            <span class="tok-kw">var</span> backslash_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L657">            <span class="tok-kw">var</span> in_quote = <span class="tok-null">false</span>;</span>
<span class="line" id="L658">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (self.index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L659">                <span class="tok-kw">const</span> character = <span class="tok-kw">if</span> (self.index != self.cmd_line.len) self.cmd_line[self.index] <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L660">                <span class="tok-kw">switch</span> (character) {</span>
<span class="line" id="L661">                    <span class="tok-number">0</span> =&gt; {</span>
<span class="line" id="L662">                        self.emitBackslashes(backslash_count);</span>
<span class="line" id="L663">                        self.buffer[self.end] = <span class="tok-number">0</span>;</span>
<span class="line" id="L664">                        <span class="tok-kw">var</span> token = self.buffer[self.start..self.end :<span class="tok-number">0</span>];</span>
<span class="line" id="L665">                        self.end += <span class="tok-number">1</span>;</span>
<span class="line" id="L666">                        self.start = self.end;</span>
<span class="line" id="L667">                        <span class="tok-kw">return</span> token;</span>
<span class="line" id="L668">                    },</span>
<span class="line" id="L669">                    <span class="tok-str">'&quot;'</span>, <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L670">                        <span class="tok-kw">if</span> (!options.single_quotes <span class="tok-kw">and</span> character == <span class="tok-str">'\''</span>) {</span>
<span class="line" id="L671">                            self.emitBackslashes(backslash_count);</span>
<span class="line" id="L672">                            backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L673">                            self.emitCharacter(character);</span>
<span class="line" id="L674">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L675">                        }</span>
<span class="line" id="L676">                        <span class="tok-kw">const</span> quote_is_real = backslash_count % <span class="tok-number">2</span> == <span class="tok-number">0</span>;</span>
<span class="line" id="L677">                        self.emitBackslashes(backslash_count / <span class="tok-number">2</span>);</span>
<span class="line" id="L678">                        backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">                        <span class="tok-kw">if</span> (quote_is_real) {</span>
<span class="line" id="L681">                            in_quote = !in_quote;</span>
<span class="line" id="L682">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L683">                            self.emitCharacter(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L684">                        }</span>
<span class="line" id="L685">                    },</span>
<span class="line" id="L686">                    <span class="tok-str">'\\'</span> =&gt; {</span>
<span class="line" id="L687">                        backslash_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L688">                    },</span>
<span class="line" id="L689">                    <span class="tok-str">' '</span>, <span class="tok-str">'\t'</span>, <span class="tok-str">'\r'</span>, <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L690">                        self.emitBackslashes(backslash_count);</span>
<span class="line" id="L691">                        backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L692">                        <span class="tok-kw">if</span> (in_quote) {</span>
<span class="line" id="L693">                            self.emitCharacter(character);</span>
<span class="line" id="L694">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L695">                            self.buffer[self.end] = <span class="tok-number">0</span>;</span>
<span class="line" id="L696">                            <span class="tok-kw">var</span> token = self.buffer[self.start..self.end :<span class="tok-number">0</span>];</span>
<span class="line" id="L697">                            self.end += <span class="tok-number">1</span>;</span>
<span class="line" id="L698">                            self.start = self.end;</span>
<span class="line" id="L699">                            <span class="tok-kw">return</span> token;</span>
<span class="line" id="L700">                        }</span>
<span class="line" id="L701">                    },</span>
<span class="line" id="L702">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L703">                        self.emitBackslashes(backslash_count);</span>
<span class="line" id="L704">                        backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L705">                        self.emitCharacter(character);</span>
<span class="line" id="L706">                    },</span>
<span class="line" id="L707">                }</span>
<span class="line" id="L708">            }</span>
<span class="line" id="L709">        }</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">        <span class="tok-kw">fn</span> <span class="tok-fn">emitBackslashes</span>(self: *Self, emit_count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L712">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L713">            <span class="tok-kw">while</span> (i &lt; emit_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L714">                self.emitCharacter(<span class="tok-str">'\\'</span>);</span>
<span class="line" id="L715">            }</span>
<span class="line" id="L716">        }</span>
<span class="line" id="L717"></span>
<span class="line" id="L718">        <span class="tok-kw">fn</span> <span class="tok-fn">emitCharacter</span>(self: *Self, char: <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L719">            self.buffer[self.end] = char;</span>
<span class="line" id="L720">            self.end += <span class="tok-number">1</span>;</span>
<span class="line" id="L721">        }</span>
<span class="line" id="L722"></span>
<span class="line" id="L723">        <span class="tok-comment">/// Call to free the internal buffer of the iterator.</span></span>
<span class="line" id="L724">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L725">            self.allocator.free(self.buffer);</span>
<span class="line" id="L726"></span>
<span class="line" id="L727">            <span class="tok-kw">if</span> (self.free_cmd_line_on_deinit) {</span>
<span class="line" id="L728">                self.allocator.free(self.cmd_line);</span>
<span class="line" id="L729">            }</span>
<span class="line" id="L730">        }</span>
<span class="line" id="L731">    };</span>
<span class="line" id="L732">}</span>
<span class="line" id="L733"></span>
<span class="line" id="L734"><span class="tok-comment">/// Cross-platform command line argument iterator.</span></span>
<span class="line" id="L735"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArgIterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L736">    <span class="tok-kw">const</span> InnerType = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L737">        .windows =&gt; ArgIteratorGeneral(.{}),</span>
<span class="line" id="L738">        .wasi =&gt; <span class="tok-kw">if</span> (builtin.link_libc) ArgIteratorPosix <span class="tok-kw">else</span> ArgIteratorWasi,</span>
<span class="line" id="L739">        <span class="tok-kw">else</span> =&gt; ArgIteratorPosix,</span>
<span class="line" id="L740">    };</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">    inner: InnerType,</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">    <span class="tok-comment">/// Initialize the args iterator. Consider using initWithAllocator() instead</span></span>
<span class="line" id="L745">    <span class="tok-comment">/// for cross-platform compatibility.</span></span>
<span class="line" id="L746">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() ArgIterator {</span>
<span class="line" id="L747">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L748">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;In WASI, use initWithAllocator instead.&quot;</span>);</span>
<span class="line" id="L749">        }</span>
<span class="line" id="L750">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L751">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;In Windows, use initWithAllocator instead.&quot;</span>);</span>
<span class="line" id="L752">        }</span>
<span class="line" id="L753"></span>
<span class="line" id="L754">        <span class="tok-kw">return</span> ArgIterator{ .inner = InnerType.init() };</span>
<span class="line" id="L755">    }</span>
<span class="line" id="L756"></span>
<span class="line" id="L757">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitError = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L758">        .windows =&gt; InnerType.InitUtf16leError,</span>
<span class="line" id="L759">        <span class="tok-kw">else</span> =&gt; InnerType.InitError,</span>
<span class="line" id="L760">    };</span>
<span class="line" id="L761"></span>
<span class="line" id="L762">    <span class="tok-comment">/// You must deinitialize iterator's internal buffers by calling `deinit` when done.</span></span>
<span class="line" id="L763">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initWithAllocator</span>(allocator: mem.Allocator) InitError!ArgIterator {</span>
<span class="line" id="L764">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L765">            <span class="tok-kw">return</span> ArgIterator{ .inner = <span class="tok-kw">try</span> InnerType.init(allocator) };</span>
<span class="line" id="L766">        }</span>
<span class="line" id="L767">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L768">            <span class="tok-kw">const</span> cmd_line_w = os.windows.kernel32.GetCommandLineW();</span>
<span class="line" id="L769">            <span class="tok-kw">return</span> ArgIterator{ .inner = <span class="tok-kw">try</span> InnerType.initUtf16le(allocator, cmd_line_w) };</span>
<span class="line" id="L770">        }</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">        <span class="tok-kw">return</span> ArgIterator{ .inner = InnerType.init() };</span>
<span class="line" id="L773">    }</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">    <span class="tok-comment">/// Get the next argument. Returns 'null' if we are at the end.</span></span>
<span class="line" id="L776">    <span class="tok-comment">/// Returned slice is pointing to the iterator's internal buffer.</span></span>
<span class="line" id="L777">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *ArgIterator) ?([:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) {</span>
<span class="line" id="L778">        <span class="tok-kw">return</span> self.inner.next();</span>
<span class="line" id="L779">    }</span>
<span class="line" id="L780"></span>
<span class="line" id="L781">    <span class="tok-comment">/// Parse past 1 argument without capturing it.</span></span>
<span class="line" id="L782">    <span class="tok-comment">/// Returns `true` if skipped an arg, `false` if we are at the end.</span></span>
<span class="line" id="L783">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">skip</span>(self: *ArgIterator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L784">        <span class="tok-kw">return</span> self.inner.skip();</span>
<span class="line" id="L785">    }</span>
<span class="line" id="L786"></span>
<span class="line" id="L787">    <span class="tok-comment">/// Call this to free the iterator's internal buffer if the iterator</span></span>
<span class="line" id="L788">    <span class="tok-comment">/// was created with `initWithAllocator` function.</span></span>
<span class="line" id="L789">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *ArgIterator) <span class="tok-type">void</span> {</span>
<span class="line" id="L790">        <span class="tok-comment">// Unless we're targeting WASI or Windows, this is a no-op.</span>
</span>
<span class="line" id="L791">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L792">            self.inner.deinit();</span>
<span class="line" id="L793">        }</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L796">            self.inner.deinit();</span>
<span class="line" id="L797">        }</span>
<span class="line" id="L798">    }</span>
<span class="line" id="L799">};</span>
<span class="line" id="L800"></span>
<span class="line" id="L801"><span class="tok-comment">/// Use argsWithAllocator() for cross-platform code</span></span>
<span class="line" id="L802"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">args</span>() ArgIterator {</span>
<span class="line" id="L803">    <span class="tok-kw">return</span> ArgIterator.init();</span>
<span class="line" id="L804">}</span>
<span class="line" id="L805"></span>
<span class="line" id="L806"><span class="tok-comment">/// You must deinitialize iterator's internal buffers by calling `deinit` when done.</span></span>
<span class="line" id="L807"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">argsWithAllocator</span>(allocator: mem.Allocator) ArgIterator.InitError!ArgIterator {</span>
<span class="line" id="L808">    <span class="tok-kw">return</span> ArgIterator.initWithAllocator(allocator);</span>
<span class="line" id="L809">}</span>
<span class="line" id="L810"></span>
<span class="line" id="L811"><span class="tok-kw">test</span> <span class="tok-str">&quot;args iterator&quot;</span> {</span>
<span class="line" id="L812">    <span class="tok-kw">var</span> ga = std.testing.allocator;</span>
<span class="line" id="L813">    <span class="tok-kw">var</span> it = <span class="tok-kw">try</span> argsWithAllocator(ga);</span>
<span class="line" id="L814">    <span class="tok-kw">defer</span> it.deinit(); <span class="tok-comment">// no-op unless WASI or Windows</span>
</span>
<span class="line" id="L815"></span>
<span class="line" id="L816">    <span class="tok-kw">const</span> prog_name = it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L817">    <span class="tok-kw">const</span> expected_suffix = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L818">        .wasi =&gt; <span class="tok-str">&quot;test.wasm&quot;</span>,</span>
<span class="line" id="L819">        .windows =&gt; <span class="tok-str">&quot;test.exe&quot;</span>,</span>
<span class="line" id="L820">        <span class="tok-kw">else</span> =&gt; <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L821">    };</span>
<span class="line" id="L822">    <span class="tok-kw">const</span> given_suffix = std.fs.path.basename(prog_name);</span>
<span class="line" id="L823"></span>
<span class="line" id="L824">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, expected_suffix, given_suffix));</span>
<span class="line" id="L825">    <span class="tok-kw">try</span> testing.expect(it.skip()); <span class="tok-comment">// Skip over zig_exe_path, passed to the test runner</span>
</span>
<span class="line" id="L826">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L827">    <span class="tok-kw">try</span> testing.expect(!it.skip());</span>
<span class="line" id="L828">}</span>
<span class="line" id="L829"></span>
<span class="line" id="L830"><span class="tok-comment">/// Caller must call argsFree on result.</span></span>
<span class="line" id="L831"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">argsAlloc</span>(allocator: mem.Allocator) ![][:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L832">    <span class="tok-comment">// TODO refactor to only make 1 allocation.</span>
</span>
<span class="line" id="L833">    <span class="tok-kw">var</span> it = <span class="tok-kw">try</span> argsWithAllocator(allocator);</span>
<span class="line" id="L834">    <span class="tok-kw">defer</span> it.deinit();</span>
<span class="line" id="L835"></span>
<span class="line" id="L836">    <span class="tok-kw">var</span> contents = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L837">    <span class="tok-kw">defer</span> contents.deinit();</span>
<span class="line" id="L838"></span>
<span class="line" id="L839">    <span class="tok-kw">var</span> slice_list = std.ArrayList(<span class="tok-type">usize</span>).init(allocator);</span>
<span class="line" id="L840">    <span class="tok-kw">defer</span> slice_list.deinit();</span>
<span class="line" id="L841"></span>
<span class="line" id="L842">    <span class="tok-kw">while</span> (it.next()) |arg| {</span>
<span class="line" id="L843">        <span class="tok-kw">try</span> contents.appendSlice(arg[<span class="tok-number">0</span> .. arg.len + <span class="tok-number">1</span>]);</span>
<span class="line" id="L844">        <span class="tok-kw">try</span> slice_list.append(arg.len);</span>
<span class="line" id="L845">    }</span>
<span class="line" id="L846"></span>
<span class="line" id="L847">    <span class="tok-kw">const</span> contents_slice = contents.items;</span>
<span class="line" id="L848">    <span class="tok-kw">const</span> slice_sizes = slice_list.items;</span>
<span class="line" id="L849">    <span class="tok-kw">const</span> slice_list_bytes = <span class="tok-kw">try</span> math.mul(<span class="tok-type">usize</span>, <span class="tok-builtin">@sizeOf</span>([]<span class="tok-type">u8</span>), slice_sizes.len);</span>
<span class="line" id="L850">    <span class="tok-kw">const</span> total_bytes = <span class="tok-kw">try</span> math.add(<span class="tok-type">usize</span>, slice_list_bytes, contents_slice.len);</span>
<span class="line" id="L851">    <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> allocator.alignedAlloc(<span class="tok-type">u8</span>, <span class="tok-builtin">@alignOf</span>([]<span class="tok-type">u8</span>), total_bytes);</span>
<span class="line" id="L852">    <span class="tok-kw">errdefer</span> allocator.free(buf);</span>
<span class="line" id="L853"></span>
<span class="line" id="L854">    <span class="tok-kw">const</span> result_slice_list = mem.bytesAsSlice([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..slice_list_bytes]);</span>
<span class="line" id="L855">    <span class="tok-kw">const</span> result_contents = buf[slice_list_bytes..];</span>
<span class="line" id="L856">    mem.copy(<span class="tok-type">u8</span>, result_contents, contents_slice);</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">    <span class="tok-kw">var</span> contents_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L859">    <span class="tok-kw">for</span> (slice_sizes) |len, i| {</span>
<span class="line" id="L860">        <span class="tok-kw">const</span> new_index = contents_index + len;</span>
<span class="line" id="L861">        result_slice_list[i] = result_contents[contents_index..new_index :<span class="tok-number">0</span>];</span>
<span class="line" id="L862">        contents_index = new_index + <span class="tok-number">1</span>;</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">    <span class="tok-kw">return</span> result_slice_list;</span>
<span class="line" id="L866">}</span>
<span class="line" id="L867"></span>
<span class="line" id="L868"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">argsFree</span>(allocator: mem.Allocator, args_alloc: []<span class="tok-kw">const</span> [:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L869">    <span class="tok-kw">var</span> total_bytes: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L870">    <span class="tok-kw">for</span> (args_alloc) |arg| {</span>
<span class="line" id="L871">        total_bytes += <span class="tok-builtin">@sizeOf</span>([]<span class="tok-type">u8</span>) + arg.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L872">    }</span>
<span class="line" id="L873">    <span class="tok-kw">const</span> unaligned_allocated_buf = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args_alloc.ptr)[<span class="tok-number">0</span>..total_bytes];</span>
<span class="line" id="L874">    <span class="tok-kw">const</span> aligned_allocated_buf = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>([]<span class="tok-type">u8</span>), unaligned_allocated_buf);</span>
<span class="line" id="L875">    <span class="tok-kw">return</span> allocator.free(aligned_allocated_buf);</span>
<span class="line" id="L876">}</span>
<span class="line" id="L877"></span>
<span class="line" id="L878"><span class="tok-kw">test</span> <span class="tok-str">&quot;general arg parsing&quot;</span> {</span>
<span class="line" id="L879">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;a   b\tc d&quot;</span>, &amp;.{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;d&quot;</span> });</span>
<span class="line" id="L880">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;\&quot;abc\&quot; d e&quot;</span>, &amp;.{ <span class="tok-str">&quot;abc&quot;</span>, <span class="tok-str">&quot;d&quot;</span>, <span class="tok-str">&quot;e&quot;</span> });</span>
<span class="line" id="L881">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;a\\\\\\b d\&quot;e f\&quot;g h&quot;</span>, &amp;.{ <span class="tok-str">&quot;a\\\\\\b&quot;</span>, <span class="tok-str">&quot;de fg&quot;</span>, <span class="tok-str">&quot;h&quot;</span> });</span>
<span class="line" id="L882">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;a\\\\\\\&quot;b c d&quot;</span>, &amp;.{ <span class="tok-str">&quot;a\\\&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;d&quot;</span> });</span>
<span class="line" id="L883">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;a\\\\\\\\\&quot;b c\&quot; d e&quot;</span>, &amp;.{ <span class="tok-str">&quot;a\\\\b c&quot;</span>, <span class="tok-str">&quot;d&quot;</span>, <span class="tok-str">&quot;e&quot;</span> });</span>
<span class="line" id="L884">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;a   b\tc \&quot;d f&quot;</span>, &amp;.{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;d f&quot;</span> });</span>
<span class="line" id="L885">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;j k l\\&quot;</span>, &amp;.{ <span class="tok-str">&quot;j&quot;</span>, <span class="tok-str">&quot;k&quot;</span>, <span class="tok-str">&quot;l\\&quot;</span> });</span>
<span class="line" id="L886">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;\&quot;\&quot; x y z\\\\&quot;</span>, &amp;.{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;x&quot;</span>, <span class="tok-str">&quot;y&quot;</span>, <span class="tok-str">&quot;z\\\\&quot;</span> });</span>
<span class="line" id="L887"></span>
<span class="line" id="L888">    <span class="tok-kw">try</span> testGeneralCmdLine(<span class="tok-str">&quot;\&quot;.\\..\\zig-cache\\build\&quot; \&quot;bin\\zig.exe\&quot; \&quot;.\\..\&quot; \&quot;.\\..\\zig-cache\&quot; \&quot;--help\&quot;&quot;</span>, &amp;.{</span>
<span class="line" id="L889">        <span class="tok-str">&quot;.\\..\\zig-cache\\build&quot;</span>,</span>
<span class="line" id="L890">        <span class="tok-str">&quot;bin\\zig.exe&quot;</span>,</span>
<span class="line" id="L891">        <span class="tok-str">&quot;.\\..&quot;</span>,</span>
<span class="line" id="L892">        <span class="tok-str">&quot;.\\..\\zig-cache&quot;</span>,</span>
<span class="line" id="L893">        <span class="tok-str">&quot;--help&quot;</span>,</span>
<span class="line" id="L894">    });</span>
<span class="line" id="L895"></span>
<span class="line" id="L896">    <span class="tok-kw">try</span> testGeneralCmdLine(</span>
<span class="line" id="L897">        <span class="tok-str">\\ 'foo' &quot;bar&quot;</span></span>

<span class="line" id="L898">    , &amp;.{ <span class="tok-str">&quot;'foo'&quot;</span>, <span class="tok-str">&quot;bar&quot;</span> });</span>
<span class="line" id="L899">}</span>
<span class="line" id="L900"></span>
<span class="line" id="L901"><span class="tok-kw">fn</span> <span class="tok-fn">testGeneralCmdLine</span>(input_cmd_line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_args: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L902">    <span class="tok-kw">var</span> it = <span class="tok-kw">try</span> ArgIteratorGeneral(.{}).init(std.testing.allocator, input_cmd_line);</span>
<span class="line" id="L903">    <span class="tok-kw">defer</span> it.deinit();</span>
<span class="line" id="L904">    <span class="tok-kw">for</span> (expected_args) |expected_arg| {</span>
<span class="line" id="L905">        <span class="tok-kw">const</span> arg = it.next().?;</span>
<span class="line" id="L906">        <span class="tok-kw">try</span> testing.expectEqualStrings(expected_arg, arg);</span>
<span class="line" id="L907">    }</span>
<span class="line" id="L908">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L909">}</span>
<span class="line" id="L910"></span>
<span class="line" id="L911"><span class="tok-kw">test</span> <span class="tok-str">&quot;response file arg parsing&quot;</span> {</span>
<span class="line" id="L912">    <span class="tok-kw">try</span> testResponseFileCmdLine(</span>
<span class="line" id="L913">        <span class="tok-str">\\a b</span></span>

<span class="line" id="L914">        <span class="tok-str">\\c d\</span></span>

<span class="line" id="L915">    , &amp;.{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;d\\&quot;</span> });</span>
<span class="line" id="L916">    <span class="tok-kw">try</span> testResponseFileCmdLine(<span class="tok-str">&quot;a b c d\\&quot;</span>, &amp;.{ <span class="tok-str">&quot;a&quot;</span>, <span class="tok-str">&quot;b&quot;</span>, <span class="tok-str">&quot;c&quot;</span>, <span class="tok-str">&quot;d\\&quot;</span> });</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    <span class="tok-kw">try</span> testResponseFileCmdLine(</span>
<span class="line" id="L919">        <span class="tok-str">\\j</span></span>

<span class="line" id="L920">        <span class="tok-str">\\ k l # this is a comment \\ \\\ \\\\ &quot;none&quot; &quot;\\&quot; &quot;\\\&quot;</span></span>

<span class="line" id="L921">        <span class="tok-str">\\ &quot;m&quot; #another comment</span></span>

<span class="line" id="L922">        <span class="tok-str">\\</span></span>

<span class="line" id="L923">    , &amp;.{ <span class="tok-str">&quot;j&quot;</span>, <span class="tok-str">&quot;k&quot;</span>, <span class="tok-str">&quot;l&quot;</span>, <span class="tok-str">&quot;m&quot;</span> });</span>
<span class="line" id="L924"></span>
<span class="line" id="L925">    <span class="tok-kw">try</span> testResponseFileCmdLine(</span>
<span class="line" id="L926">        <span class="tok-str">\\ &quot;&quot; q &quot;&quot;</span></span>

<span class="line" id="L927">        <span class="tok-str">\\ &quot;r s # t&quot; &quot;u\&quot; v&quot; #another comment</span></span>

<span class="line" id="L928">        <span class="tok-str">\\</span></span>

<span class="line" id="L929">    , &amp;.{ <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;q&quot;</span>, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;r s # t&quot;</span>, <span class="tok-str">&quot;u\&quot; v&quot;</span> });</span>
<span class="line" id="L930"></span>
<span class="line" id="L931">    <span class="tok-kw">try</span> testResponseFileCmdLine(</span>
<span class="line" id="L932">        <span class="tok-str">\\ -l&quot;advapi32&quot; a# b#c d#</span></span>

<span class="line" id="L933">        <span class="tok-str">\\e\\\</span></span>

<span class="line" id="L934">    , &amp;.{ <span class="tok-str">&quot;-ladvapi32&quot;</span>, <span class="tok-str">&quot;a#&quot;</span>, <span class="tok-str">&quot;b#c&quot;</span>, <span class="tok-str">&quot;d#&quot;</span>, <span class="tok-str">&quot;e\\\\\\&quot;</span> });</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">    <span class="tok-kw">try</span> testResponseFileCmdLine(</span>
<span class="line" id="L937">        <span class="tok-str">\\ 'foo' &quot;bar&quot;</span></span>

<span class="line" id="L938">    , &amp;.{ <span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;bar&quot;</span> });</span>
<span class="line" id="L939">}</span>
<span class="line" id="L940"></span>
<span class="line" id="L941"><span class="tok-kw">fn</span> <span class="tok-fn">testResponseFileCmdLine</span>(input_cmd_line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_args: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L942">    <span class="tok-kw">var</span> it = <span class="tok-kw">try</span> ArgIteratorGeneral(.{ .comments = <span class="tok-null">true</span>, .single_quotes = <span class="tok-null">true</span> })</span>
<span class="line" id="L943">        .init(std.testing.allocator, input_cmd_line);</span>
<span class="line" id="L944">    <span class="tok-kw">defer</span> it.deinit();</span>
<span class="line" id="L945">    <span class="tok-kw">for</span> (expected_args) |expected_arg| {</span>
<span class="line" id="L946">        <span class="tok-kw">const</span> arg = it.next().?;</span>
<span class="line" id="L947">        <span class="tok-kw">try</span> testing.expectEqualStrings(expected_arg, arg);</span>
<span class="line" id="L948">    }</span>
<span class="line" id="L949">    <span class="tok-kw">try</span> testing.expect(it.next() == <span class="tok-null">null</span>);</span>
<span class="line" id="L950">}</span>
<span class="line" id="L951"></span>
<span class="line" id="L952"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UserInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L953">    uid: os.uid_t,</span>
<span class="line" id="L954">    gid: os.gid_t,</span>
<span class="line" id="L955">};</span>
<span class="line" id="L956"></span>
<span class="line" id="L957"><span class="tok-comment">/// POSIX function which gets a uid from username.</span></span>
<span class="line" id="L958"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getUserInfo</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !UserInfo {</span>
<span class="line" id="L959">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L960">        .linux, .macos, .watchos, .tvos, .ios, .freebsd, .netbsd, .openbsd, .haiku, .solaris =&gt; posixGetUserInfo(name),</span>
<span class="line" id="L961">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L962">    };</span>
<span class="line" id="L963">}</span>
<span class="line" id="L964"></span>
<span class="line" id="L965"><span class="tok-comment">/// TODO this reads /etc/passwd. But sometimes the user/id mapping is in something else</span></span>
<span class="line" id="L966"><span class="tok-comment">/// like NIS, AD, etc. See `man nss` or look at an strace for `id myuser`.</span></span>
<span class="line" id="L967"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">posixGetUserInfo</span>(name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !UserInfo {</span>
<span class="line" id="L968">    <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> std.fs.openFileAbsolute(<span class="tok-str">&quot;/etc/passwd&quot;</span>, .{});</span>
<span class="line" id="L969">    <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L970"></span>
<span class="line" id="L971">    <span class="tok-kw">const</span> reader = file.reader();</span>
<span class="line" id="L972"></span>
<span class="line" id="L973">    <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L974">        Start,</span>
<span class="line" id="L975">        WaitForNextLine,</span>
<span class="line" id="L976">        SkipPassword,</span>
<span class="line" id="L977">        ReadUserId,</span>
<span class="line" id="L978">        ReadGroupId,</span>
<span class="line" id="L979">    };</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">    <span class="tok-kw">var</span> buf: [std.mem.page_size]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L982">    <span class="tok-kw">var</span> name_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L983">    <span class="tok-kw">var</span> state = State.Start;</span>
<span class="line" id="L984">    <span class="tok-kw">var</span> uid: os.uid_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L985">    <span class="tok-kw">var</span> gid: os.gid_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L986"></span>
<span class="line" id="L987">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L988">        <span class="tok-kw">const</span> amt_read = <span class="tok-kw">try</span> reader.read(buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L989">        <span class="tok-kw">for</span> (buf[<span class="tok-number">0</span>..amt_read]) |byte| {</span>
<span class="line" id="L990">            <span class="tok-kw">switch</span> (state) {</span>
<span class="line" id="L991">                .Start =&gt; <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L992">                    <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L993">                        state = <span class="tok-kw">if</span> (name_index == name.len) State.SkipPassword <span class="tok-kw">else</span> State.WaitForNextLine;</span>
<span class="line" id="L994">                    },</span>
<span class="line" id="L995">                    <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile,</span>
<span class="line" id="L996">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L997">                        <span class="tok-kw">if</span> (name_index == name.len <span class="tok-kw">or</span> name[name_index] != byte) {</span>
<span class="line" id="L998">                            state = .WaitForNextLine;</span>
<span class="line" id="L999">                        }</span>
<span class="line" id="L1000">                        name_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1001">                    },</span>
<span class="line" id="L1002">                },</span>
<span class="line" id="L1003">                .WaitForNextLine =&gt; <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1004">                    <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L1005">                        name_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L1006">                        state = .Start;</span>
<span class="line" id="L1007">                    },</span>
<span class="line" id="L1008">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1009">                },</span>
<span class="line" id="L1010">                .SkipPassword =&gt; <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1011">                    <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile,</span>
<span class="line" id="L1012">                    <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L1013">                        state = .ReadUserId;</span>
<span class="line" id="L1014">                    },</span>
<span class="line" id="L1015">                    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1016">                },</span>
<span class="line" id="L1017">                .ReadUserId =&gt; <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1018">                    <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L1019">                        state = .ReadGroupId;</span>
<span class="line" id="L1020">                    },</span>
<span class="line" id="L1021">                    <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile,</span>
<span class="line" id="L1022">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1023">                        <span class="tok-kw">const</span> digit = <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1024">                            <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; byte - <span class="tok-str">'0'</span>,</span>
<span class="line" id="L1025">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile,</span>
<span class="line" id="L1026">                        };</span>
<span class="line" id="L1027">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(<span class="tok-type">u32</span>, uid, <span class="tok-number">10</span>, &amp;uid)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile;</span>
<span class="line" id="L1028">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u32</span>, uid, digit, &amp;uid)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile;</span>
<span class="line" id="L1029">                    },</span>
<span class="line" id="L1030">                },</span>
<span class="line" id="L1031">                .ReadGroupId =&gt; <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1032">                    <span class="tok-str">'\n'</span>, <span class="tok-str">':'</span> =&gt; {</span>
<span class="line" id="L1033">                        <span class="tok-kw">return</span> UserInfo{</span>
<span class="line" id="L1034">                            .uid = uid,</span>
<span class="line" id="L1035">                            .gid = gid,</span>
<span class="line" id="L1036">                        };</span>
<span class="line" id="L1037">                    },</span>
<span class="line" id="L1038">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1039">                        <span class="tok-kw">const</span> digit = <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1040">                            <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; byte - <span class="tok-str">'0'</span>,</span>
<span class="line" id="L1041">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile,</span>
<span class="line" id="L1042">                        };</span>
<span class="line" id="L1043">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@mulWithOverflow</span>(<span class="tok-type">u32</span>, gid, <span class="tok-number">10</span>, &amp;gid)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile;</span>
<span class="line" id="L1044">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u32</span>, gid, digit, &amp;gid)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.CorruptPasswordFile;</span>
<span class="line" id="L1045">                    },</span>
<span class="line" id="L1046">                },</span>
<span class="line" id="L1047">            }</span>
<span class="line" id="L1048">        }</span>
<span class="line" id="L1049">        <span class="tok-kw">if</span> (amt_read &lt; buf.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UserNotFound;</span>
<span class="line" id="L1050">    }</span>
<span class="line" id="L1051">}</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getBaseAddress</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L1054">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1055">        .linux =&gt; {</span>
<span class="line" id="L1056">            <span class="tok-kw">const</span> base = os.system.getauxval(std.elf.AT_BASE);</span>
<span class="line" id="L1057">            <span class="tok-kw">if</span> (base != <span class="tok-number">0</span>) {</span>
<span class="line" id="L1058">                <span class="tok-kw">return</span> base;</span>
<span class="line" id="L1059">            }</span>
<span class="line" id="L1060">            <span class="tok-kw">const</span> phdr = os.system.getauxval(std.elf.AT_PHDR);</span>
<span class="line" id="L1061">            <span class="tok-kw">return</span> phdr - <span class="tok-builtin">@sizeOf</span>(std.elf.Ehdr);</span>
<span class="line" id="L1062">        },</span>
<span class="line" id="L1063">        .macos, .freebsd, .netbsd =&gt; {</span>
<span class="line" id="L1064">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(&amp;std.c._mh_execute_header);</span>
<span class="line" id="L1065">        },</span>
<span class="line" id="L1066">        .windows =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@ptrToInt</span>(os.windows.kernel32.GetModuleHandleW(<span class="tok-null">null</span>)),</span>
<span class="line" id="L1067">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L1068">    }</span>
<span class="line" id="L1069">}</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071"><span class="tok-comment">/// Caller owns the result value and each inner slice.</span></span>
<span class="line" id="L1072"><span class="tok-comment">/// TODO Remove the `Allocator` requirement from this API, which will remove the `Allocator`</span></span>
<span class="line" id="L1073"><span class="tok-comment">/// requirement from `std.zig.system.NativeTargetInfo.detect`. Most likely this will require</span></span>
<span class="line" id="L1074"><span class="tok-comment">/// introducing a new, lower-level function which takes a callback function, and then this</span></span>
<span class="line" id="L1075"><span class="tok-comment">/// function which takes an allocator can exist on top of it.</span></span>
<span class="line" id="L1076"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSelfExeSharedLibPaths</span>(allocator: Allocator) <span class="tok-kw">error</span>{OutOfMemory}![][:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1077">    <span class="tok-kw">switch</span> (builtin.link_mode) {</span>
<span class="line" id="L1078">        .Static =&gt; <span class="tok-kw">return</span> &amp;[_][:<span class="tok-number">0</span>]<span class="tok-type">u8</span>{},</span>
<span class="line" id="L1079">        .Dynamic =&gt; {},</span>
<span class="line" id="L1080">    }</span>
<span class="line" id="L1081">    <span class="tok-kw">const</span> List = std.ArrayList([:<span class="tok-number">0</span>]<span class="tok-type">u8</span>);</span>
<span class="line" id="L1082">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1083">        .linux,</span>
<span class="line" id="L1084">        .freebsd,</span>
<span class="line" id="L1085">        .netbsd,</span>
<span class="line" id="L1086">        .dragonfly,</span>
<span class="line" id="L1087">        .openbsd,</span>
<span class="line" id="L1088">        .solaris,</span>
<span class="line" id="L1089">        =&gt; {</span>
<span class="line" id="L1090">            <span class="tok-kw">var</span> paths = List.init(allocator);</span>
<span class="line" id="L1091">            <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1092">                <span class="tok-kw">const</span> slice = paths.toOwnedSlice();</span>
<span class="line" id="L1093">                <span class="tok-kw">for</span> (slice) |item| {</span>
<span class="line" id="L1094">                    allocator.free(item);</span>
<span class="line" id="L1095">                }</span>
<span class="line" id="L1096">                allocator.free(slice);</span>
<span class="line" id="L1097">            }</span>
<span class="line" id="L1098">            <span class="tok-kw">try</span> os.dl_iterate_phdr(&amp;paths, <span class="tok-kw">error</span>{OutOfMemory}, <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1099">                <span class="tok-kw">fn</span> <span class="tok-fn">callback</span>(info: *os.dl_phdr_info, size: <span class="tok-type">usize</span>, list: *List) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1100">                    _ = size;</span>
<span class="line" id="L1101">                    <span class="tok-kw">const</span> name = info.dlpi_name <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L1102">                    <span class="tok-kw">if</span> (name[<span class="tok-number">0</span>] == <span class="tok-str">'/'</span>) {</span>
<span class="line" id="L1103">                        <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> list.allocator.dupeZ(<span class="tok-type">u8</span>, mem.sliceTo(name, <span class="tok-number">0</span>));</span>
<span class="line" id="L1104">                        <span class="tok-kw">errdefer</span> list.allocator.free(item);</span>
<span class="line" id="L1105">                        <span class="tok-kw">try</span> list.append(item);</span>
<span class="line" id="L1106">                    }</span>
<span class="line" id="L1107">                }</span>
<span class="line" id="L1108">            }.callback);</span>
<span class="line" id="L1109">            <span class="tok-kw">return</span> paths.toOwnedSlice();</span>
<span class="line" id="L1110">        },</span>
<span class="line" id="L1111">        .macos, .ios, .watchos, .tvos =&gt; {</span>
<span class="line" id="L1112">            <span class="tok-kw">var</span> paths = List.init(allocator);</span>
<span class="line" id="L1113">            <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1114">                <span class="tok-kw">const</span> slice = paths.toOwnedSlice();</span>
<span class="line" id="L1115">                <span class="tok-kw">for</span> (slice) |item| {</span>
<span class="line" id="L1116">                    allocator.free(item);</span>
<span class="line" id="L1117">                }</span>
<span class="line" id="L1118">                allocator.free(slice);</span>
<span class="line" id="L1119">            }</span>
<span class="line" id="L1120">            <span class="tok-kw">const</span> img_count = std.c._dyld_image_count();</span>
<span class="line" id="L1121">            <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1122">            <span class="tok-kw">while</span> (i &lt; img_count) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1123">                <span class="tok-kw">const</span> name = std.c._dyld_get_image_name(i);</span>
<span class="line" id="L1124">                <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> allocator.dupeZ(<span class="tok-type">u8</span>, mem.sliceTo(name, <span class="tok-number">0</span>));</span>
<span class="line" id="L1125">                <span class="tok-kw">errdefer</span> allocator.free(item);</span>
<span class="line" id="L1126">                <span class="tok-kw">try</span> paths.append(item);</span>
<span class="line" id="L1127">            }</span>
<span class="line" id="L1128">            <span class="tok-kw">return</span> paths.toOwnedSlice();</span>
<span class="line" id="L1129">        },</span>
<span class="line" id="L1130">        <span class="tok-comment">// revisit if Haiku implements dl_iterat_phdr (https://dev.haiku-os.org/ticket/15743)</span>
</span>
<span class="line" id="L1131">        .haiku =&gt; {</span>
<span class="line" id="L1132">            <span class="tok-kw">var</span> paths = List.init(allocator);</span>
<span class="line" id="L1133">            <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L1134">                <span class="tok-kw">const</span> slice = paths.toOwnedSlice();</span>
<span class="line" id="L1135">                <span class="tok-kw">for</span> (slice) |item| {</span>
<span class="line" id="L1136">                    allocator.free(item);</span>
<span class="line" id="L1137">                }</span>
<span class="line" id="L1138">                allocator.free(slice);</span>
<span class="line" id="L1139">            }</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141">            <span class="tok-kw">var</span> b = <span class="tok-str">&quot;/boot/system/runtime_loader&quot;</span>;</span>
<span class="line" id="L1142">            <span class="tok-kw">const</span> item = <span class="tok-kw">try</span> allocator.dupeZ(<span class="tok-type">u8</span>, mem.sliceTo(b, <span class="tok-number">0</span>));</span>
<span class="line" id="L1143">            <span class="tok-kw">errdefer</span> allocator.free(item);</span>
<span class="line" id="L1144">            <span class="tok-kw">try</span> paths.append(item);</span>
<span class="line" id="L1145"></span>
<span class="line" id="L1146">            <span class="tok-kw">return</span> paths.toOwnedSlice();</span>
<span class="line" id="L1147">        },</span>
<span class="line" id="L1148">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;getSelfExeSharedLibPaths unimplemented for this target&quot;</span>),</span>
<span class="line" id="L1149">    }</span>
<span class="line" id="L1150">}</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152"><span class="tok-comment">/// Tells whether calling the `execv` or `execve` functions will be a compile error.</span></span>
<span class="line" id="L1153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> can_execv = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1154">    .windows, .haiku, .wasi =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1155">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1156">};</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158"><span class="tok-comment">/// Tells whether spawning child processes is supported (e.g. via ChildProcess)</span></span>
<span class="line" id="L1159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> can_spawn = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1160">    .wasi =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1161">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1162">};</span>
<span class="line" id="L1163"></span>
<span class="line" id="L1164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExecvError = std.os.ExecveError || <span class="tok-kw">error</span>{OutOfMemory};</span>
<span class="line" id="L1165"></span>
<span class="line" id="L1166"><span class="tok-comment">/// Replaces the current process image with the executed process.</span></span>
<span class="line" id="L1167"><span class="tok-comment">/// This function must allocate memory to add a null terminating bytes on path and each arg.</span></span>
<span class="line" id="L1168"><span class="tok-comment">/// It must also convert to KEY=VALUE\0 format for environment variables, and include null</span></span>
<span class="line" id="L1169"><span class="tok-comment">/// pointers after the args and after the environment variables.</span></span>
<span class="line" id="L1170"><span class="tok-comment">/// `argv[0]` is the executable path.</span></span>
<span class="line" id="L1171"><span class="tok-comment">/// This function also uses the PATH environment variable to get the full path to the executable.</span></span>
<span class="line" id="L1172"><span class="tok-comment">/// Due to the heap-allocation, it is illegal to call this function in a fork() child.</span></span>
<span class="line" id="L1173"><span class="tok-comment">/// For that use case, use the `std.os` functions directly.</span></span>
<span class="line" id="L1174"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execv</span>(allocator: mem.Allocator, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ExecvError {</span>
<span class="line" id="L1175">    <span class="tok-kw">return</span> execve(allocator, argv, <span class="tok-null">null</span>);</span>
<span class="line" id="L1176">}</span>
<span class="line" id="L1177"></span>
<span class="line" id="L1178"><span class="tok-comment">/// Replaces the current process image with the executed process.</span></span>
<span class="line" id="L1179"><span class="tok-comment">/// This function must allocate memory to add a null terminating bytes on path and each arg.</span></span>
<span class="line" id="L1180"><span class="tok-comment">/// It must also convert to KEY=VALUE\0 format for environment variables, and include null</span></span>
<span class="line" id="L1181"><span class="tok-comment">/// pointers after the args and after the environment variables.</span></span>
<span class="line" id="L1182"><span class="tok-comment">/// `argv[0]` is the executable path.</span></span>
<span class="line" id="L1183"><span class="tok-comment">/// This function also uses the PATH environment variable to get the full path to the executable.</span></span>
<span class="line" id="L1184"><span class="tok-comment">/// Due to the heap-allocation, it is illegal to call this function in a fork() child.</span></span>
<span class="line" id="L1185"><span class="tok-comment">/// For that use case, use the `std.os` functions directly.</span></span>
<span class="line" id="L1186"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">execve</span>(</span>
<span class="line" id="L1187">    allocator: mem.Allocator,</span>
<span class="line" id="L1188">    argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1189">    env_map: ?*<span class="tok-kw">const</span> EnvMap,</span>
<span class="line" id="L1190">) ExecvError {</span>
<span class="line" id="L1191">    <span class="tok-kw">if</span> (!can_execv) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The target OS does not support execv&quot;</span>);</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193">    <span class="tok-kw">var</span> arena_allocator = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L1194">    <span class="tok-kw">defer</span> arena_allocator.deinit();</span>
<span class="line" id="L1195">    <span class="tok-kw">const</span> arena = arena_allocator.allocator();</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197">    <span class="tok-kw">const</span> argv_buf = <span class="tok-kw">try</span> arena.allocSentinel(?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, argv.len, <span class="tok-null">null</span>);</span>
<span class="line" id="L1198">    <span class="tok-kw">for</span> (argv) |arg, i| argv_buf[i] = (<span class="tok-kw">try</span> arena.dupeZ(<span class="tok-type">u8</span>, arg)).ptr;</span>
<span class="line" id="L1199"></span>
<span class="line" id="L1200">    <span class="tok-kw">const</span> envp = m: {</span>
<span class="line" id="L1201">        <span class="tok-kw">if</span> (env_map) |m| {</span>
<span class="line" id="L1202">            <span class="tok-kw">const</span> envp_buf = <span class="tok-kw">try</span> child_process.createNullDelimitedEnvMap(arena, m);</span>
<span class="line" id="L1203">            <span class="tok-kw">break</span> :m envp_buf.ptr;</span>
<span class="line" id="L1204">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L1205">            <span class="tok-kw">break</span> :m std.c.environ;</span>
<span class="line" id="L1206">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.output_mode == .Exe) {</span>
<span class="line" id="L1207">            <span class="tok-comment">// Then we have Zig start code and this works.</span>
</span>
<span class="line" id="L1208">            <span class="tok-comment">// TODO type-safety for null-termination of `os.environ`.</span>
</span>
<span class="line" id="L1209">            <span class="tok-kw">break</span> :m <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, os.environ.ptr);</span>
<span class="line" id="L1210">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1211">            <span class="tok-comment">// TODO come up with a solution for this.</span>
</span>
<span class="line" id="L1212">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;missing std lib enhancement: std.process.execv implementation has no way to collect the environment variables to forward to the child process&quot;</span>);</span>
<span class="line" id="L1213">        }</span>
<span class="line" id="L1214">    };</span>
<span class="line" id="L1215"></span>
<span class="line" id="L1216">    <span class="tok-kw">return</span> os.execvpeZ_expandArg0(.no_expand, argv_buf.ptr[<span class="tok-number">0</span>].?, argv_buf.ptr, envp);</span>
<span class="line" id="L1217">}</span>
<span class="line" id="L1218"></span>
</code></pre></body>
</html>