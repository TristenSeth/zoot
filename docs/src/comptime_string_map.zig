<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>comptime_string_map.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// Comptime string map optimized for small sets of disparate string keys.</span></span>
<span class="line" id="L5"><span class="tok-comment">/// Works by separating the keys by length at comptime and only checking strings of</span></span>
<span class="line" id="L6"><span class="tok-comment">/// equal length at runtime.</span></span>
<span class="line" id="L7"><span class="tok-comment">///</span></span>
<span class="line" id="L8"><span class="tok-comment">/// `kvs` expects a list literal containing list literals or an array/slice of structs</span></span>
<span class="line" id="L9"><span class="tok-comment">/// where `.@&quot;0&quot;` is the `[]const u8` key and `.@&quot;1&quot;` is the associated value of type `V`.</span></span>
<span class="line" id="L10"><span class="tok-comment">/// TODO: https://github.com/ziglang/zig/issues/4335</span></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ComptimeStringMap</span>(<span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> kvs_list: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L12">    <span class="tok-kw">const</span> precomputed = <span class="tok-kw">comptime</span> blk: {</span>
<span class="line" id="L13">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">2000</span>);</span>
<span class="line" id="L14">        <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">            key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L16">            value: V,</span>
<span class="line" id="L17">        };</span>
<span class="line" id="L18">        <span class="tok-kw">var</span> sorted_kvs: [kvs_list.len]KV = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L19">        <span class="tok-kw">const</span> lenAsc = (<span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">            <span class="tok-kw">fn</span> <span class="tok-fn">lenAsc</span>(context: <span class="tok-type">void</span>, a: KV, b: KV) <span class="tok-type">bool</span> {</span>
<span class="line" id="L21">                _ = context;</span>
<span class="line" id="L22">                <span class="tok-kw">return</span> a.key.len &lt; b.key.len;</span>
<span class="line" id="L23">            }</span>
<span class="line" id="L24">        }).lenAsc;</span>
<span class="line" id="L25">        <span class="tok-kw">for</span> (kvs_list) |kv, i| {</span>
<span class="line" id="L26">            <span class="tok-kw">if</span> (V != <span class="tok-type">void</span>) {</span>
<span class="line" id="L27">                sorted_kvs[i] = .{ .key = kv.@&quot;0&quot;, .value = kv.@&quot;1&quot; };</span>
<span class="line" id="L28">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L29">                sorted_kvs[i] = .{ .key = kv.@&quot;0&quot;, .value = {} };</span>
<span class="line" id="L30">            }</span>
<span class="line" id="L31">        }</span>
<span class="line" id="L32">        std.sort.sort(KV, &amp;sorted_kvs, {}, lenAsc);</span>
<span class="line" id="L33">        <span class="tok-kw">const</span> min_len = sorted_kvs[<span class="tok-number">0</span>].key.len;</span>
<span class="line" id="L34">        <span class="tok-kw">const</span> max_len = sorted_kvs[sorted_kvs.len - <span class="tok-number">1</span>].key.len;</span>
<span class="line" id="L35">        <span class="tok-kw">var</span> len_indexes: [max_len + <span class="tok-number">1</span>]<span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L36">        <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L37">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L38">        <span class="tok-kw">while</span> (len &lt;= max_len) : (len += <span class="tok-number">1</span>) {</span>
<span class="line" id="L39">            <span class="tok-comment">// find the first keyword len == len</span>
</span>
<span class="line" id="L40">            <span class="tok-kw">while</span> (len &gt; sorted_kvs[i].key.len) {</span>
<span class="line" id="L41">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L42">            }</span>
<span class="line" id="L43">            len_indexes[len] = i;</span>
<span class="line" id="L44">        }</span>
<span class="line" id="L45">        <span class="tok-kw">break</span> :blk .{</span>
<span class="line" id="L46">            .min_len = min_len,</span>
<span class="line" id="L47">            .max_len = max_len,</span>
<span class="line" id="L48">            .sorted_kvs = sorted_kvs,</span>
<span class="line" id="L49">            .len_indexes = len_indexes,</span>
<span class="line" id="L50">        };</span>
<span class="line" id="L51">    };</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L54">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> kvs = precomputed.sorted_kvs;</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">has</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L57">            <span class="tok-kw">return</span> get(str) != <span class="tok-null">null</span>;</span>
<span class="line" id="L58">        }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?V {</span>
<span class="line" id="L61">            <span class="tok-kw">if</span> (str.len &lt; precomputed.min_len <span class="tok-kw">or</span> str.len &gt; precomputed.max_len)</span>
<span class="line" id="L62">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">            <span class="tok-kw">var</span> i = precomputed.len_indexes[str.len];</span>
<span class="line" id="L65">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L66">                <span class="tok-kw">const</span> kv = precomputed.sorted_kvs[i];</span>
<span class="line" id="L67">                <span class="tok-kw">if</span> (kv.key.len != str.len)</span>
<span class="line" id="L68">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L69">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, kv.key, str))</span>
<span class="line" id="L70">                    <span class="tok-kw">return</span> kv.value;</span>
<span class="line" id="L71">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L72">                <span class="tok-kw">if</span> (i &gt;= precomputed.sorted_kvs.len)</span>
<span class="line" id="L73">                    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L74">            }</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76">    };</span>
<span class="line" id="L77">}</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">const</span> TestEnum = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L80">    A,</span>
<span class="line" id="L81">    B,</span>
<span class="line" id="L82">    C,</span>
<span class="line" id="L83">    D,</span>
<span class="line" id="L84">    E,</span>
<span class="line" id="L85">};</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">test</span> <span class="tok-str">&quot;ComptimeStringMap list literal of list literals&quot;</span> {</span>
<span class="line" id="L88">    <span class="tok-kw">const</span> map = ComptimeStringMap(TestEnum, .{</span>
<span class="line" id="L89">        .{ <span class="tok-str">&quot;these&quot;</span>, .D },</span>
<span class="line" id="L90">        .{ <span class="tok-str">&quot;have&quot;</span>, .A },</span>
<span class="line" id="L91">        .{ <span class="tok-str">&quot;nothing&quot;</span>, .B },</span>
<span class="line" id="L92">        .{ <span class="tok-str">&quot;incommon&quot;</span>, .C },</span>
<span class="line" id="L93">        .{ <span class="tok-str">&quot;samelen&quot;</span>, .E },</span>
<span class="line" id="L94">    });</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">try</span> testMap(map);</span>
<span class="line" id="L97">}</span>
<span class="line" id="L98"></span>
<span class="line" id="L99"><span class="tok-kw">test</span> <span class="tok-str">&quot;ComptimeStringMap array of structs&quot;</span> {</span>
<span class="line" id="L100">    <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L101">        @&quot;0&quot;: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L102">        @&quot;1&quot;: TestEnum,</span>
<span class="line" id="L103">    };</span>
<span class="line" id="L104">    <span class="tok-kw">const</span> map = ComptimeStringMap(TestEnum, [_]KV{</span>
<span class="line" id="L105">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;these&quot;</span>, .@&quot;1&quot; = .D },</span>
<span class="line" id="L106">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;have&quot;</span>, .@&quot;1&quot; = .A },</span>
<span class="line" id="L107">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;nothing&quot;</span>, .@&quot;1&quot; = .B },</span>
<span class="line" id="L108">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;incommon&quot;</span>, .@&quot;1&quot; = .C },</span>
<span class="line" id="L109">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;samelen&quot;</span>, .@&quot;1&quot; = .E },</span>
<span class="line" id="L110">    });</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">try</span> testMap(map);</span>
<span class="line" id="L113">}</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">test</span> <span class="tok-str">&quot;ComptimeStringMap slice of structs&quot;</span> {</span>
<span class="line" id="L116">    <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L117">        @&quot;0&quot;: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L118">        @&quot;1&quot;: TestEnum,</span>
<span class="line" id="L119">    };</span>
<span class="line" id="L120">    <span class="tok-kw">const</span> slice: []<span class="tok-kw">const</span> KV = &amp;[_]KV{</span>
<span class="line" id="L121">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;these&quot;</span>, .@&quot;1&quot; = .D },</span>
<span class="line" id="L122">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;have&quot;</span>, .@&quot;1&quot; = .A },</span>
<span class="line" id="L123">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;nothing&quot;</span>, .@&quot;1&quot; = .B },</span>
<span class="line" id="L124">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;incommon&quot;</span>, .@&quot;1&quot; = .C },</span>
<span class="line" id="L125">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;samelen&quot;</span>, .@&quot;1&quot; = .E },</span>
<span class="line" id="L126">    };</span>
<span class="line" id="L127">    <span class="tok-kw">const</span> map = ComptimeStringMap(TestEnum, slice);</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">try</span> testMap(map);</span>
<span class="line" id="L130">}</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">fn</span> <span class="tok-fn">testMap</span>(<span class="tok-kw">comptime</span> map: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L133">    <span class="tok-kw">try</span> std.testing.expectEqual(TestEnum.A, map.get(<span class="tok-str">&quot;have&quot;</span>).?);</span>
<span class="line" id="L134">    <span class="tok-kw">try</span> std.testing.expectEqual(TestEnum.B, map.get(<span class="tok-str">&quot;nothing&quot;</span>).?);</span>
<span class="line" id="L135">    <span class="tok-kw">try</span> std.testing.expect(<span class="tok-null">null</span> == map.get(<span class="tok-str">&quot;missing&quot;</span>));</span>
<span class="line" id="L136">    <span class="tok-kw">try</span> std.testing.expectEqual(TestEnum.D, map.get(<span class="tok-str">&quot;these&quot;</span>).?);</span>
<span class="line" id="L137">    <span class="tok-kw">try</span> std.testing.expectEqual(TestEnum.E, map.get(<span class="tok-str">&quot;samelen&quot;</span>).?);</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">    <span class="tok-kw">try</span> std.testing.expect(!map.has(<span class="tok-str">&quot;missing&quot;</span>));</span>
<span class="line" id="L140">    <span class="tok-kw">try</span> std.testing.expect(map.has(<span class="tok-str">&quot;these&quot;</span>));</span>
<span class="line" id="L141">}</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">test</span> <span class="tok-str">&quot;ComptimeStringMap void value type, slice of structs&quot;</span> {</span>
<span class="line" id="L144">    <span class="tok-kw">const</span> KV = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L145">        @&quot;0&quot;: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L146">    };</span>
<span class="line" id="L147">    <span class="tok-kw">const</span> slice: []<span class="tok-kw">const</span> KV = &amp;[_]KV{</span>
<span class="line" id="L148">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;these&quot;</span> },</span>
<span class="line" id="L149">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;have&quot;</span> },</span>
<span class="line" id="L150">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;nothing&quot;</span> },</span>
<span class="line" id="L151">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;incommon&quot;</span> },</span>
<span class="line" id="L152">        .{ .@&quot;0&quot; = <span class="tok-str">&quot;samelen&quot;</span> },</span>
<span class="line" id="L153">    };</span>
<span class="line" id="L154">    <span class="tok-kw">const</span> map = ComptimeStringMap(<span class="tok-type">void</span>, slice);</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">    <span class="tok-kw">try</span> testSet(map);</span>
<span class="line" id="L157">}</span>
<span class="line" id="L158"></span>
<span class="line" id="L159"><span class="tok-kw">test</span> <span class="tok-str">&quot;ComptimeStringMap void value type, list literal of list literals&quot;</span> {</span>
<span class="line" id="L160">    <span class="tok-kw">const</span> map = ComptimeStringMap(<span class="tok-type">void</span>, .{</span>
<span class="line" id="L161">        .{<span class="tok-str">&quot;these&quot;</span>},</span>
<span class="line" id="L162">        .{<span class="tok-str">&quot;have&quot;</span>},</span>
<span class="line" id="L163">        .{<span class="tok-str">&quot;nothing&quot;</span>},</span>
<span class="line" id="L164">        .{<span class="tok-str">&quot;incommon&quot;</span>},</span>
<span class="line" id="L165">        .{<span class="tok-str">&quot;samelen&quot;</span>},</span>
<span class="line" id="L166">    });</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-kw">try</span> testSet(map);</span>
<span class="line" id="L169">}</span>
<span class="line" id="L170"></span>
<span class="line" id="L171"><span class="tok-kw">fn</span> <span class="tok-fn">testSet</span>(<span class="tok-kw">comptime</span> map: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L172">    <span class="tok-kw">try</span> std.testing.expectEqual({}, map.get(<span class="tok-str">&quot;have&quot;</span>).?);</span>
<span class="line" id="L173">    <span class="tok-kw">try</span> std.testing.expectEqual({}, map.get(<span class="tok-str">&quot;nothing&quot;</span>).?);</span>
<span class="line" id="L174">    <span class="tok-kw">try</span> std.testing.expect(<span class="tok-null">null</span> == map.get(<span class="tok-str">&quot;missing&quot;</span>));</span>
<span class="line" id="L175">    <span class="tok-kw">try</span> std.testing.expectEqual({}, map.get(<span class="tok-str">&quot;these&quot;</span>).?);</span>
<span class="line" id="L176">    <span class="tok-kw">try</span> std.testing.expectEqual({}, map.get(<span class="tok-str">&quot;samelen&quot;</span>).?);</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-kw">try</span> std.testing.expect(!map.has(<span class="tok-str">&quot;missing&quot;</span>));</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> std.testing.expect(map.has(<span class="tok-str">&quot;these&quot;</span>));</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
</code></pre></body>
</html>