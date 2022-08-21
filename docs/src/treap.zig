<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>treap.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Order = std.math.Order;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Treap</span>(<span class="tok-kw">comptime</span> Key: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> compareFn: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">        <span class="tok-comment">// Allow for compareFn to be fn(anytype, anytype) anytype</span>
</span>
<span class="line" id="L11">        <span class="tok-comment">// which allows the convenient use of std.math.order.</span>
</span>
<span class="line" id="L12">        <span class="tok-kw">fn</span> <span class="tok-fn">compare</span>(a: Key, b: Key) Order {</span>
<span class="line" id="L13">            <span class="tok-kw">return</span> compareFn(a, b);</span>
<span class="line" id="L14">        }</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        root: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L17">        prng: Prng = .{},</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-comment">/// A customized pseudo random number generator for the treap.</span></span>
<span class="line" id="L20">        <span class="tok-comment">/// This just helps reducing the memory size of the treap itself</span></span>
<span class="line" id="L21">        <span class="tok-comment">/// as std.rand.DefaultPrng requires larger state (while producing better entropy for randomness to be fair).</span></span>
<span class="line" id="L22">        <span class="tok-kw">const</span> Prng = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L23">            xorshift: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">            <span class="tok-kw">fn</span> <span class="tok-fn">random</span>(self: *Prng, seed: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L26">                <span class="tok-comment">// Lazily seed the prng state</span>
</span>
<span class="line" id="L27">                <span class="tok-kw">if</span> (self.xorshift == <span class="tok-number">0</span>) {</span>
<span class="line" id="L28">                    self.xorshift = seed;</span>
<span class="line" id="L29">                }</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">                <span class="tok-comment">// Since we're using usize, decide the shifts by the integer's bit width.</span>
</span>
<span class="line" id="L32">                <span class="tok-kw">const</span> shifts = <span class="tok-kw">switch</span> (<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L33">                    <span class="tok-number">64</span> =&gt; .{ <span class="tok-number">13</span>, <span class="tok-number">7</span>, <span class="tok-number">17</span> },</span>
<span class="line" id="L34">                    <span class="tok-number">32</span> =&gt; .{ <span class="tok-number">13</span>, <span class="tok-number">17</span>, <span class="tok-number">5</span> },</span>
<span class="line" id="L35">                    <span class="tok-number">16</span> =&gt; .{ <span class="tok-number">7</span>, <span class="tok-number">9</span>, <span class="tok-number">8</span> },</span>
<span class="line" id="L36">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;platform not supported&quot;</span>),</span>
<span class="line" id="L37">                };</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">                self.xorshift ^= self.xorshift &gt;&gt; shifts[<span class="tok-number">0</span>];</span>
<span class="line" id="L40">                self.xorshift ^= self.xorshift &lt;&lt; shifts[<span class="tok-number">1</span>];</span>
<span class="line" id="L41">                self.xorshift ^= self.xorshift &gt;&gt; shifts[<span class="tok-number">2</span>];</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">                assert(self.xorshift != <span class="tok-number">0</span>);</span>
<span class="line" id="L44">                <span class="tok-kw">return</span> self.xorshift;</span>
<span class="line" id="L45">            }</span>
<span class="line" id="L46">        };</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">        <span class="tok-comment">/// A Node represents an item or point in the treap with a uniquely associated key.</span></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L50">            key: Key,</span>
<span class="line" id="L51">            priority: <span class="tok-type">usize</span>,</span>
<span class="line" id="L52">            parent: ?*Node,</span>
<span class="line" id="L53">            children: [<span class="tok-number">2</span>]?*Node,</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-comment">/// Returns the smallest Node by key in the treap if there is one.</span></span>
<span class="line" id="L57">        <span class="tok-comment">/// Use `getEntryForExisting()` to replace/remove this Node from the treap.</span></span>
<span class="line" id="L58">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getMin</span>(self: Self) ?*Node {</span>
<span class="line" id="L59">            <span class="tok-kw">var</span> node = self.root;</span>
<span class="line" id="L60">            <span class="tok-kw">while</span> (node) |current| {</span>
<span class="line" id="L61">                node = current.children[<span class="tok-number">0</span>] <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L62">            }</span>
<span class="line" id="L63">            <span class="tok-kw">return</span> node;</span>
<span class="line" id="L64">        }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-comment">/// Returns the largest Node by key in the treap if there is one.</span></span>
<span class="line" id="L67">        <span class="tok-comment">/// Use `getEntryForExisting()` to replace/remove this Node from the treap.</span></span>
<span class="line" id="L68">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getMax</span>(self: Self) ?*Node {</span>
<span class="line" id="L69">            <span class="tok-kw">var</span> node = self.root;</span>
<span class="line" id="L70">            <span class="tok-kw">while</span> (node) |current| {</span>
<span class="line" id="L71">                node = current.children[<span class="tok-number">1</span>] <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L72">            }</span>
<span class="line" id="L73">            <span class="tok-kw">return</span> node;</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">        <span class="tok-comment">/// Lookup the Entry for the given key in the treap.</span></span>
<span class="line" id="L77">        <span class="tok-comment">/// The Entry act's as a slot in the treap to insert/replace/remove the node associated with the key.</span></span>
<span class="line" id="L78">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryFor</span>(self: *Self, key: Key) Entry {</span>
<span class="line" id="L79">            <span class="tok-kw">var</span> parent: ?*Node = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L80">            <span class="tok-kw">const</span> node = self.find(key, &amp;parent);</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">            <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L83">                .key = key,</span>
<span class="line" id="L84">                .treap = self,</span>
<span class="line" id="L85">                .node = node,</span>
<span class="line" id="L86">                .context = .{ .inserted_under = parent },</span>
<span class="line" id="L87">            };</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-comment">/// Get an entry for a Node that currently exists in the treap.</span></span>
<span class="line" id="L91">        <span class="tok-comment">/// It is undefined behavior if the Node is not currently inserted in the treap.</span></span>
<span class="line" id="L92">        <span class="tok-comment">/// The Entry act's as a slot in the treap to insert/replace/remove the node associated with the key.</span></span>
<span class="line" id="L93">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getEntryForExisting</span>(self: *Self, node: *Node) Entry {</span>
<span class="line" id="L94">            assert(node.priority != <span class="tok-number">0</span>);</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">            <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L97">                .key = node.key,</span>
<span class="line" id="L98">                .treap = self,</span>
<span class="line" id="L99">                .node = node,</span>
<span class="line" id="L100">                .context = .{ .inserted_under = node.parent },</span>
<span class="line" id="L101">            };</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">        <span class="tok-comment">/// An Entry represents a slot in the treap associated with a given key.</span></span>
<span class="line" id="L105">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L106">            <span class="tok-comment">/// The associated key for this entry.</span></span>
<span class="line" id="L107">            key: Key,</span>
<span class="line" id="L108">            <span class="tok-comment">/// A reference to the treap this entry is apart of.</span></span>
<span class="line" id="L109">            treap: *Self,</span>
<span class="line" id="L110">            <span class="tok-comment">/// The current node at this entry.</span></span>
<span class="line" id="L111">            node: ?*Node,</span>
<span class="line" id="L112">            <span class="tok-comment">/// The current state of the entry.</span></span>
<span class="line" id="L113">            context: <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L114">                <span class="tok-comment">/// A find() was called for this entry and the position in the treap is known.</span></span>
<span class="line" id="L115">                inserted_under: ?*Node,</span>
<span class="line" id="L116">                <span class="tok-comment">/// The entry's node was removed from the treap and a lookup must occur again for modification.</span></span>
<span class="line" id="L117">                removed,</span>
<span class="line" id="L118">            },</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">            <span class="tok-comment">/// Update's the Node at this Entry in the treap with the new node.</span></span>
<span class="line" id="L121">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Entry, new_node: ?*Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L122">                <span class="tok-comment">// Update the entry's node reference after updating the treap below.</span>
</span>
<span class="line" id="L123">                <span class="tok-kw">defer</span> self.node = new_node;</span>
<span class="line" id="L124"></span>
<span class="line" id="L125">                <span class="tok-kw">if</span> (self.node) |old| {</span>
<span class="line" id="L126">                    <span class="tok-kw">if</span> (new_node) |new| {</span>
<span class="line" id="L127">                        self.treap.replace(old, new);</span>
<span class="line" id="L128">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L129">                    }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">                    self.treap.remove(old);</span>
<span class="line" id="L132">                    self.context = .removed;</span>
<span class="line" id="L133">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L134">                }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">                <span class="tok-kw">if</span> (new_node) |new| {</span>
<span class="line" id="L137">                    <span class="tok-comment">// A previous treap.remove() could have rebalanced the nodes</span>
</span>
<span class="line" id="L138">                    <span class="tok-comment">// so when inserting after a removal, we have to re-lookup the parent again.</span>
</span>
<span class="line" id="L139">                    <span class="tok-comment">// This lookup shouldn't find a node because we're yet to insert it..</span>
</span>
<span class="line" id="L140">                    <span class="tok-kw">var</span> parent: ?*Node = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L141">                    <span class="tok-kw">switch</span> (self.context) {</span>
<span class="line" id="L142">                        .inserted_under =&gt; |p| parent = p,</span>
<span class="line" id="L143">                        .removed =&gt; assert(self.treap.find(self.key, &amp;parent) == <span class="tok-null">null</span>),</span>
<span class="line" id="L144">                    }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">                    self.treap.insert(self.key, parent, new);</span>
<span class="line" id="L147">                    self.context = .{ .inserted_under = parent };</span>
<span class="line" id="L148">                }</span>
<span class="line" id="L149">            }</span>
<span class="line" id="L150">        };</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">        <span class="tok-kw">fn</span> <span class="tok-fn">find</span>(self: Self, key: Key, parent_ref: *?*Node) ?*Node {</span>
<span class="line" id="L153">            <span class="tok-kw">var</span> node = self.root;</span>
<span class="line" id="L154">            parent_ref.* = <span class="tok-null">null</span>;</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">            <span class="tok-comment">// basic binary search while tracking the parent.</span>
</span>
<span class="line" id="L157">            <span class="tok-kw">while</span> (node) |current| {</span>
<span class="line" id="L158">                <span class="tok-kw">const</span> order = compare(key, current.key);</span>
<span class="line" id="L159">                <span class="tok-kw">if</span> (order == .eq) <span class="tok-kw">break</span>;</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">                parent_ref.* = current;</span>
<span class="line" id="L162">                node = current.children[<span class="tok-builtin">@boolToInt</span>(order == .gt)];</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">            <span class="tok-kw">return</span> node;</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">        <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Self, key: Key, parent: ?*Node, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L169">            <span class="tok-comment">// generate a random priority &amp; prepare the node to be inserted into the tree</span>
</span>
<span class="line" id="L170">            node.key = key;</span>
<span class="line" id="L171">            node.priority = self.prng.random(<span class="tok-builtin">@ptrToInt</span>(node));</span>
<span class="line" id="L172">            node.parent = parent;</span>
<span class="line" id="L173">            node.children = [_]?*Node{ <span class="tok-null">null</span>, <span class="tok-null">null</span> };</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">            <span class="tok-comment">// point the parent at the new node</span>
</span>
<span class="line" id="L176">            <span class="tok-kw">const</span> link = <span class="tok-kw">if</span> (parent) |p| &amp;p.children[<span class="tok-builtin">@boolToInt</span>(compare(key, p.key) == .gt)] <span class="tok-kw">else</span> &amp;self.root;</span>
<span class="line" id="L177">            assert(link.* == <span class="tok-null">null</span>);</span>
<span class="line" id="L178">            link.* = node;</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">            <span class="tok-comment">// rotate the node up into the tree to balance it according to its priority</span>
</span>
<span class="line" id="L181">            <span class="tok-kw">while</span> (node.parent) |p| {</span>
<span class="line" id="L182">                <span class="tok-kw">if</span> (p.priority &lt;= node.priority) <span class="tok-kw">break</span>;</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">                <span class="tok-kw">const</span> is_right = p.children[<span class="tok-number">1</span>] == node;</span>
<span class="line" id="L185">                assert(p.children[<span class="tok-builtin">@boolToInt</span>(is_right)] == node);</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">                <span class="tok-kw">const</span> rotate_right = !is_right;</span>
<span class="line" id="L188">                self.rotate(p, rotate_right);</span>
<span class="line" id="L189">            }</span>
<span class="line" id="L190">        }</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">        <span class="tok-kw">fn</span> <span class="tok-fn">replace</span>(self: *Self, old: *Node, new: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L193">            <span class="tok-comment">// copy over the values from the old node</span>
</span>
<span class="line" id="L194">            new.key = old.key;</span>
<span class="line" id="L195">            new.priority = old.priority;</span>
<span class="line" id="L196">            new.parent = old.parent;</span>
<span class="line" id="L197">            new.children = old.children;</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">            <span class="tok-comment">// point the parent at the new node</span>
</span>
<span class="line" id="L200">            <span class="tok-kw">const</span> link = <span class="tok-kw">if</span> (old.parent) |p| &amp;p.children[<span class="tok-builtin">@boolToInt</span>(p.children[<span class="tok-number">1</span>] == old)] <span class="tok-kw">else</span> &amp;self.root;</span>
<span class="line" id="L201">            assert(link.* == old);</span>
<span class="line" id="L202">            link.* = new;</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">            <span class="tok-comment">// point the children's parent at the new node</span>
</span>
<span class="line" id="L205">            <span class="tok-kw">for</span> (old.children) |child_node| {</span>
<span class="line" id="L206">                <span class="tok-kw">const</span> child = child_node <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L207">                assert(child.parent == old);</span>
<span class="line" id="L208">                child.parent = new;</span>
<span class="line" id="L209">            }</span>
<span class="line" id="L210">        }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">        <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, node: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L213">            <span class="tok-comment">// rotate the node down to be a leaf of the tree for removal, respecting priorities.</span>
</span>
<span class="line" id="L214">            <span class="tok-kw">while</span> (node.children[<span class="tok-number">0</span>] <span class="tok-kw">orelse</span> node.children[<span class="tok-number">1</span>]) |_| {</span>
<span class="line" id="L215">                self.rotate(node, rotate_right: {</span>
<span class="line" id="L216">                    <span class="tok-kw">const</span> right = node.children[<span class="tok-number">1</span>] <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :rotate_right <span class="tok-null">true</span>;</span>
<span class="line" id="L217">                    <span class="tok-kw">const</span> left = node.children[<span class="tok-number">0</span>] <span class="tok-kw">orelse</span> <span class="tok-kw">break</span> :rotate_right <span class="tok-null">false</span>;</span>
<span class="line" id="L218">                    <span class="tok-kw">break</span> :rotate_right (left.priority &lt; right.priority);</span>
<span class="line" id="L219">                });</span>
<span class="line" id="L220">            }</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">            <span class="tok-comment">// node is a now a leaf; remove by nulling out the parent's reference to it.</span>
</span>
<span class="line" id="L223">            <span class="tok-kw">const</span> link = <span class="tok-kw">if</span> (node.parent) |p| &amp;p.children[<span class="tok-builtin">@boolToInt</span>(p.children[<span class="tok-number">1</span>] == node)] <span class="tok-kw">else</span> &amp;self.root;</span>
<span class="line" id="L224">            assert(link.* == node);</span>
<span class="line" id="L225">            link.* = <span class="tok-null">null</span>;</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">            <span class="tok-comment">// clean up after ourselves</span>
</span>
<span class="line" id="L228">            node.key = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L229">            node.priority = <span class="tok-number">0</span>;</span>
<span class="line" id="L230">            node.parent = <span class="tok-null">null</span>;</span>
<span class="line" id="L231">            node.children = [_]?*Node{ <span class="tok-null">null</span>, <span class="tok-null">null</span> };</span>
<span class="line" id="L232">        }</span>
<span class="line" id="L233"></span>
<span class="line" id="L234">        <span class="tok-kw">fn</span> <span class="tok-fn">rotate</span>(self: *Self, node: *Node, right: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L235">            <span class="tok-comment">// if right, converts the following:</span>
</span>
<span class="line" id="L236">            <span class="tok-comment">//      parent -&gt; (node (target YY adjacent) XX)</span>
</span>
<span class="line" id="L237">            <span class="tok-comment">//      parent -&gt; (target YY (node adjacent XX))</span>
</span>
<span class="line" id="L238">            <span class="tok-comment">//</span>
</span>
<span class="line" id="L239">            <span class="tok-comment">// if left (!right), converts the following:</span>
</span>
<span class="line" id="L240">            <span class="tok-comment">//      parent -&gt; (node (target YY adjacent) XX)</span>
</span>
<span class="line" id="L241">            <span class="tok-comment">//      parent -&gt; (target YY (node adjacent XX))</span>
</span>
<span class="line" id="L242">            <span class="tok-kw">const</span> parent = node.parent;</span>
<span class="line" id="L243">            <span class="tok-kw">const</span> target = node.children[<span class="tok-builtin">@boolToInt</span>(!right)] <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L244">            <span class="tok-kw">const</span> adjacent = target.children[<span class="tok-builtin">@boolToInt</span>(right)];</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">            <span class="tok-comment">// rotate the children</span>
</span>
<span class="line" id="L247">            target.children[<span class="tok-builtin">@boolToInt</span>(right)] = node;</span>
<span class="line" id="L248">            node.children[<span class="tok-builtin">@boolToInt</span>(!right)] = adjacent;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">            <span class="tok-comment">// rotate the parents</span>
</span>
<span class="line" id="L251">            node.parent = target;</span>
<span class="line" id="L252">            target.parent = parent;</span>
<span class="line" id="L253">            <span class="tok-kw">if</span> (adjacent) |adj| adj.parent = node;</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">            <span class="tok-comment">// fix the parent link</span>
</span>
<span class="line" id="L256">            <span class="tok-kw">const</span> link = <span class="tok-kw">if</span> (parent) |p| &amp;p.children[<span class="tok-builtin">@boolToInt</span>(p.children[<span class="tok-number">1</span>] == node)] <span class="tok-kw">else</span> &amp;self.root;</span>
<span class="line" id="L257">            assert(link.* == node);</span>
<span class="line" id="L258">            link.* = target;</span>
<span class="line" id="L259">        }</span>
<span class="line" id="L260">    };</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-comment">// For iterating a slice in a random order</span>
</span>
<span class="line" id="L264"><span class="tok-comment">// https://lemire.me/blog/2017/09/18/visiting-all-values-in-an-array-exactly-once-in-random-order/</span>
</span>
<span class="line" id="L265"><span class="tok-kw">fn</span> <span class="tok-fn">SliceIterRandomOrder</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L266">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L267">        rng: std.rand.Random,</span>
<span class="line" id="L268">        slice: []T,</span>
<span class="line" id="L269">        index: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L270">        offset: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L271">        co_prime: <span class="tok-type">usize</span>,</span>
<span class="line" id="L272"></span>
<span class="line" id="L273">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(slice: []T, rng: std.rand.Random) Self {</span>
<span class="line" id="L276">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L277">                .rng = rng,</span>
<span class="line" id="L278">                .slice = slice,</span>
<span class="line" id="L279">                .co_prime = blk: {</span>
<span class="line" id="L280">                    <span class="tok-kw">if</span> (slice.len == <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk <span class="tok-number">0</span>;</span>
<span class="line" id="L281">                    <span class="tok-kw">var</span> prime = slice.len / <span class="tok-number">2</span>;</span>
<span class="line" id="L282">                    <span class="tok-kw">while</span> (prime &lt; slice.len) : (prime += <span class="tok-number">1</span>) {</span>
<span class="line" id="L283">                        <span class="tok-kw">var</span> gcd = [_]<span class="tok-type">usize</span>{ prime, slice.len };</span>
<span class="line" id="L284">                        <span class="tok-kw">while</span> (gcd[<span class="tok-number">1</span>] != <span class="tok-number">0</span>) {</span>
<span class="line" id="L285">                            <span class="tok-kw">const</span> temp = gcd;</span>
<span class="line" id="L286">                            gcd = [_]<span class="tok-type">usize</span>{ temp[<span class="tok-number">1</span>], temp[<span class="tok-number">0</span>] % temp[<span class="tok-number">1</span>] };</span>
<span class="line" id="L287">                        }</span>
<span class="line" id="L288">                        <span class="tok-kw">if</span> (gcd[<span class="tok-number">0</span>] == <span class="tok-number">1</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L289">                    }</span>
<span class="line" id="L290">                    <span class="tok-kw">break</span> :blk prime;</span>
<span class="line" id="L291">                },</span>
<span class="line" id="L292">            };</span>
<span class="line" id="L293">        }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L296">            self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L297">            self.offset = self.rng.int(<span class="tok-type">usize</span>);</span>
<span class="line" id="L298">        }</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) ?*T {</span>
<span class="line" id="L301">            <span class="tok-kw">if</span> (self.index &gt;= self.slice.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L302">            <span class="tok-kw">defer</span> self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L303">            <span class="tok-kw">return</span> &amp;self.slice[((self.index *% self.co_prime) +% self.offset) % self.slice.len];</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305">    };</span>
<span class="line" id="L306">}</span>
<span class="line" id="L307"></span>
<span class="line" id="L308"><span class="tok-kw">const</span> TestTreap = Treap(<span class="tok-type">u64</span>, std.math.order);</span>
<span class="line" id="L309"><span class="tok-kw">const</span> TestNode = TestTreap.Node;</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.Treap: insert, find, replace, remove&quot;</span> {</span>
<span class="line" id="L312">    <span class="tok-kw">var</span> treap = TestTreap{};</span>
<span class="line" id="L313">    <span class="tok-kw">var</span> nodes: [<span class="tok-number">10</span>]TestNode = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">var</span> prng = std.rand.DefaultPrng.init(<span class="tok-number">0xdeadbeef</span>);</span>
<span class="line" id="L316">    <span class="tok-kw">var</span> iter = SliceIterRandomOrder(TestNode).init(&amp;nodes, prng.random());</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-comment">// insert check</span>
</span>
<span class="line" id="L319">    iter.reset();</span>
<span class="line" id="L320">    <span class="tok-kw">while</span> (iter.next()) |node| {</span>
<span class="line" id="L321">        <span class="tok-kw">const</span> key = prng.random().int(<span class="tok-type">u64</span>);</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">        <span class="tok-comment">// make sure the current entry is empty.</span>
</span>
<span class="line" id="L324">        <span class="tok-kw">var</span> entry = treap.getEntryFor(key);</span>
<span class="line" id="L325">        <span class="tok-kw">try</span> testing.expectEqual(entry.key, key);</span>
<span class="line" id="L326">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, <span class="tok-null">null</span>);</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">        <span class="tok-comment">// insert the entry and make sure the fields are correct.</span>
</span>
<span class="line" id="L329">        entry.set(node);</span>
<span class="line" id="L330">        <span class="tok-kw">try</span> testing.expectEqual(node.key, key);</span>
<span class="line" id="L331">        <span class="tok-kw">try</span> testing.expectEqual(entry.key, key);</span>
<span class="line" id="L332">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-comment">// find check</span>
</span>
<span class="line" id="L336">    iter.reset();</span>
<span class="line" id="L337">    <span class="tok-kw">while</span> (iter.next()) |node| {</span>
<span class="line" id="L338">        <span class="tok-kw">const</span> key = node.key;</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">        <span class="tok-comment">// find the entry by-key and by-node after having been inserted.</span>
</span>
<span class="line" id="L341">        <span class="tok-kw">var</span> entry = treap.getEntryFor(node.key);</span>
<span class="line" id="L342">        <span class="tok-kw">try</span> testing.expectEqual(entry.key, key);</span>
<span class="line" id="L343">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L344">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryForExisting(node).node);</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    <span class="tok-comment">// replace check</span>
</span>
<span class="line" id="L348">    iter.reset();</span>
<span class="line" id="L349">    <span class="tok-kw">while</span> (iter.next()) |node| {</span>
<span class="line" id="L350">        <span class="tok-kw">const</span> key = node.key;</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">        <span class="tok-comment">// find the entry by node since we already know it exists</span>
</span>
<span class="line" id="L353">        <span class="tok-kw">var</span> entry = treap.getEntryForExisting(node);</span>
<span class="line" id="L354">        <span class="tok-kw">try</span> testing.expectEqual(entry.key, key);</span>
<span class="line" id="L355">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">        <span class="tok-kw">var</span> stub_node: TestNode = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">        <span class="tok-comment">// replace the node with a stub_node and ensure future finds point to the stub_node.</span>
</span>
<span class="line" id="L360">        entry.set(&amp;stub_node);</span>
<span class="line" id="L361">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, &amp;stub_node);</span>
<span class="line" id="L362">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryFor(key).node);</span>
<span class="line" id="L363">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryForExisting(&amp;stub_node).node);</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">        <span class="tok-comment">// replace the stub_node back to the node and ensure future finds point to the old node.</span>
</span>
<span class="line" id="L366">        entry.set(node);</span>
<span class="line" id="L367">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L368">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryFor(key).node);</span>
<span class="line" id="L369">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryForExisting(node).node);</span>
<span class="line" id="L370">    }</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">    <span class="tok-comment">// remove check</span>
</span>
<span class="line" id="L373">    iter.reset();</span>
<span class="line" id="L374">    <span class="tok-kw">while</span> (iter.next()) |node| {</span>
<span class="line" id="L375">        <span class="tok-kw">const</span> key = node.key;</span>
<span class="line" id="L376"></span>
<span class="line" id="L377">        <span class="tok-comment">// find the entry by node since we already know it exists</span>
</span>
<span class="line" id="L378">        <span class="tok-kw">var</span> entry = treap.getEntryForExisting(node);</span>
<span class="line" id="L379">        <span class="tok-kw">try</span> testing.expectEqual(entry.key, key);</span>
<span class="line" id="L380">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-comment">// remove the node at the entry and ensure future finds point to it being removed.</span>
</span>
<span class="line" id="L383">        entry.set(<span class="tok-null">null</span>);</span>
<span class="line" id="L384">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, <span class="tok-null">null</span>);</span>
<span class="line" id="L385">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryFor(key).node);</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">        <span class="tok-comment">// insert the node back and ensure future finds point to the inserted node</span>
</span>
<span class="line" id="L388">        entry.set(node);</span>
<span class="line" id="L389">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, node);</span>
<span class="line" id="L390">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryFor(key).node);</span>
<span class="line" id="L391">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryForExisting(node).node);</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-comment">// remove the node again and make sure it was cleared after the insert</span>
</span>
<span class="line" id="L394">        entry.set(<span class="tok-null">null</span>);</span>
<span class="line" id="L395">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, <span class="tok-null">null</span>);</span>
<span class="line" id="L396">        <span class="tok-kw">try</span> testing.expectEqual(entry.node, treap.getEntryFor(key).node);</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398">}</span>
<span class="line" id="L399"></span>
</code></pre></body>
</html>