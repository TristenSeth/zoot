<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Progress.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This API non-allocating, non-fallible, and thread-safe.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! The tradeoff is that users of this API must provide the storage</span></span>
<span class="line" id="L3"><span class="tok-comment">//! for each `Progress.Node`.</span></span>
<span class="line" id="L4"><span class="tok-comment">//!</span></span>
<span class="line" id="L5"><span class="tok-comment">//! Initialize the struct directly, overriding these fields as desired:</span></span>
<span class="line" id="L6"><span class="tok-comment">//! * `refresh_rate_ms`</span></span>
<span class="line" id="L7"><span class="tok-comment">//! * `initial_delay_ms`</span></span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> Progress = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// `null` if the current node (and its children) should</span></span>
<span class="line" id="L17"><span class="tok-comment">/// not print on update()</span></span>
<span class="line" id="L18">terminal: ?std.fs.File = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// Is this a windows API terminal (note: this is not the same as being run on windows</span></span>
<span class="line" id="L21"><span class="tok-comment">/// because other terminals exist like MSYS/git-bash)</span></span>
<span class="line" id="L22">is_windows_terminal: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-comment">/// Whether the terminal supports ANSI escape codes.</span></span>
<span class="line" id="L25">supports_ansi_escape_codes: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-comment">/// If the terminal is &quot;dumb&quot;, don't print output.</span></span>
<span class="line" id="L28"><span class="tok-comment">/// This can be useful if you don't want to print all</span></span>
<span class="line" id="L29"><span class="tok-comment">/// the stages of code generation if there are a lot.</span></span>
<span class="line" id="L30"><span class="tok-comment">/// You should not use it if the user should see output</span></span>
<span class="line" id="L31"><span class="tok-comment">/// for example showing the user what tests run.</span></span>
<span class="line" id="L32">dont_print_on_dumb: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">root: Node = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-comment">/// Keeps track of how much time has passed since the beginning.</span></span>
<span class="line" id="L37"><span class="tok-comment">/// Used to compare with `initial_delay_ms` and `refresh_rate_ms`.</span></span>
<span class="line" id="L38">timer: ?std.time.Timer = <span class="tok-null">null</span>,</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-comment">/// When the previous refresh was written to the terminal.</span></span>
<span class="line" id="L41"><span class="tok-comment">/// Used to compare with `refresh_rate_ms`.</span></span>
<span class="line" id="L42">prev_refresh_timestamp: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-comment">/// This buffer represents the maximum number of bytes written to the terminal</span></span>
<span class="line" id="L45"><span class="tok-comment">/// with each refresh.</span></span>
<span class="line" id="L46">output_buffer: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-comment">/// How many nanoseconds between writing updates to the terminal.</span></span>
<span class="line" id="L49">refresh_rate_ns: <span class="tok-type">u64</span> = <span class="tok-number">50</span> * std.time.ns_per_ms,</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">/// How many nanoseconds to keep the output hidden</span></span>
<span class="line" id="L52">initial_delay_ns: <span class="tok-type">u64</span> = <span class="tok-number">500</span> * std.time.ns_per_ms,</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">done: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-comment">/// Protects the `refresh` function, as well as `node.recently_updated_child`.</span></span>
<span class="line" id="L57"><span class="tok-comment">/// Without this, callsites would call `Node.end` and then free `Node` memory</span></span>
<span class="line" id="L58"><span class="tok-comment">/// while it was still being accessed by the `refresh` function.</span></span>
<span class="line" id="L59">update_mutex: std.Thread.Mutex = .{},</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-comment">/// Keeps track of how many columns in the terminal have been output, so that</span></span>
<span class="line" id="L62"><span class="tok-comment">/// we can move the cursor back later.</span></span>
<span class="line" id="L63">columns_written: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L64"></span>
<span class="line" id="L65"><span class="tok-comment">/// Represents one unit of progress. Each node can have children nodes, or</span></span>
<span class="line" id="L66"><span class="tok-comment">/// one can use integers with `update`.</span></span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Node = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L68">    context: *Progress,</span>
<span class="line" id="L69">    parent: ?*Node,</span>
<span class="line" id="L70">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L71">    <span class="tok-comment">/// Must be handled atomically to be thread-safe.</span></span>
<span class="line" id="L72">    recently_updated_child: ?*Node = <span class="tok-null">null</span>,</span>
<span class="line" id="L73">    <span class="tok-comment">/// Must be handled atomically to be thread-safe. 0 means null.</span></span>
<span class="line" id="L74">    unprotected_estimated_total_items: <span class="tok-type">usize</span>,</span>
<span class="line" id="L75">    <span class="tok-comment">/// Must be handled atomically to be thread-safe.</span></span>
<span class="line" id="L76">    unprotected_completed_items: <span class="tok-type">usize</span>,</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-comment">/// Create a new child progress node. Thread-safe.</span></span>
<span class="line" id="L79">    <span class="tok-comment">/// Call `Node.end` when done.</span></span>
<span class="line" id="L80">    <span class="tok-comment">/// TODO solve https://github.com/ziglang/zig/issues/2765 and then change this</span></span>
<span class="line" id="L81">    <span class="tok-comment">/// API to set `self.parent.recently_updated_child` with the return value.</span></span>
<span class="line" id="L82">    <span class="tok-comment">/// Until that is fixed you probably want to call `activate` on the return value.</span></span>
<span class="line" id="L83">    <span class="tok-comment">/// Passing 0 for `estimated_total_items` means unknown.</span></span>
<span class="line" id="L84">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">start</span>(self: *Node, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, estimated_total_items: <span class="tok-type">usize</span>) Node {</span>
<span class="line" id="L85">        <span class="tok-kw">return</span> Node{</span>
<span class="line" id="L86">            .context = self.context,</span>
<span class="line" id="L87">            .parent = self,</span>
<span class="line" id="L88">            .name = name,</span>
<span class="line" id="L89">            .unprotected_estimated_total_items = estimated_total_items,</span>
<span class="line" id="L90">            .unprotected_completed_items = <span class="tok-number">0</span>,</span>
<span class="line" id="L91">        };</span>
<span class="line" id="L92">    }</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-comment">/// This is the same as calling `start` and then `end` on the returned `Node`. Thread-safe.</span></span>
<span class="line" id="L95">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">completeOne</span>(self: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L96">        <span class="tok-kw">if</span> (self.parent) |parent| {</span>
<span class="line" id="L97">            <span class="tok-builtin">@atomicStore</span>(?*Node, &amp;parent.recently_updated_child, self, .Release);</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;self.unprotected_completed_items, .Add, <span class="tok-number">1</span>, .Monotonic);</span>
<span class="line" id="L100">        self.context.maybeRefresh();</span>
<span class="line" id="L101">    }</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-comment">/// Finish a started `Node`. Thread-safe.</span></span>
<span class="line" id="L104">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">end</span>(self: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L105">        self.context.maybeRefresh();</span>
<span class="line" id="L106">        <span class="tok-kw">if</span> (self.parent) |parent| {</span>
<span class="line" id="L107">            {</span>
<span class="line" id="L108">                self.context.update_mutex.lock();</span>
<span class="line" id="L109">                <span class="tok-kw">defer</span> self.context.update_mutex.unlock();</span>
<span class="line" id="L110">                _ = <span class="tok-builtin">@cmpxchgStrong</span>(?*Node, &amp;parent.recently_updated_child, self, <span class="tok-null">null</span>, .Monotonic, .Monotonic);</span>
<span class="line" id="L111">            }</span>
<span class="line" id="L112">            parent.completeOne();</span>
<span class="line" id="L113">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L114">            self.context.update_mutex.lock();</span>
<span class="line" id="L115">            <span class="tok-kw">defer</span> self.context.update_mutex.unlock();</span>
<span class="line" id="L116">            self.context.done = <span class="tok-null">true</span>;</span>
<span class="line" id="L117">            self.context.refreshWithHeldLock();</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119">    }</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">    <span class="tok-comment">/// Tell the parent node that this node is actively being worked on. Thread-safe.</span></span>
<span class="line" id="L122">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">activate</span>(self: *Node) <span class="tok-type">void</span> {</span>
<span class="line" id="L123">        <span class="tok-kw">if</span> (self.parent) |parent| {</span>
<span class="line" id="L124">            <span class="tok-builtin">@atomicStore</span>(?*Node, &amp;parent.recently_updated_child, self, .Release);</span>
<span class="line" id="L125">            self.context.maybeRefresh();</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-comment">/// Thread-safe. 0 means unknown.</span></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setEstimatedTotalItems</span>(self: *Node, count: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L131">        <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">usize</span>, &amp;self.unprotected_estimated_total_items, count, .Monotonic);</span>
<span class="line" id="L132">    }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-comment">/// Thread-safe.</span></span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setCompletedItems</span>(self: *Node, completed_items: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L136">        <span class="tok-builtin">@atomicStore</span>(<span class="tok-type">usize</span>, &amp;self.unprotected_completed_items, completed_items, .Monotonic);</span>
<span class="line" id="L137">    }</span>
<span class="line" id="L138">};</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-comment">/// Create a new progress node.</span></span>
<span class="line" id="L141"><span class="tok-comment">/// Call `Node.end` when done.</span></span>
<span class="line" id="L142"><span class="tok-comment">/// TODO solve https://github.com/ziglang/zig/issues/2765 and then change this</span></span>
<span class="line" id="L143"><span class="tok-comment">/// API to return Progress rather than accept it as a parameter.</span></span>
<span class="line" id="L144"><span class="tok-comment">/// `estimated_total_items` value of 0 means unknown.</span></span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">start</span>(self: *Progress, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, estimated_total_items: <span class="tok-type">usize</span>) *Node {</span>
<span class="line" id="L146">    <span class="tok-kw">const</span> stderr = std.io.getStdErr();</span>
<span class="line" id="L147">    self.terminal = <span class="tok-null">null</span>;</span>
<span class="line" id="L148">    <span class="tok-kw">if</span> (stderr.supportsAnsiEscapeCodes()) {</span>
<span class="line" id="L149">        self.terminal = stderr;</span>
<span class="line" id="L150">        self.supports_ansi_escape_codes = <span class="tok-null">true</span>;</span>
<span class="line" id="L151">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">and</span> stderr.isTty()) {</span>
<span class="line" id="L152">        self.is_windows_terminal = <span class="tok-null">true</span>;</span>
<span class="line" id="L153">        self.terminal = stderr;</span>
<span class="line" id="L154">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag != .windows) {</span>
<span class="line" id="L155">        <span class="tok-comment">// we are in a &quot;dumb&quot; terminal like in acme or writing to a file</span>
</span>
<span class="line" id="L156">        self.terminal = stderr;</span>
<span class="line" id="L157">    }</span>
<span class="line" id="L158">    self.root = Node{</span>
<span class="line" id="L159">        .context = self,</span>
<span class="line" id="L160">        .parent = <span class="tok-null">null</span>,</span>
<span class="line" id="L161">        .name = name,</span>
<span class="line" id="L162">        .unprotected_estimated_total_items = estimated_total_items,</span>
<span class="line" id="L163">        .unprotected_completed_items = <span class="tok-number">0</span>,</span>
<span class="line" id="L164">    };</span>
<span class="line" id="L165">    self.columns_written = <span class="tok-number">0</span>;</span>
<span class="line" id="L166">    self.prev_refresh_timestamp = <span class="tok-number">0</span>;</span>
<span class="line" id="L167">    self.timer = std.time.Timer.start() <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L168">    self.done = <span class="tok-null">false</span>;</span>
<span class="line" id="L169">    <span class="tok-kw">return</span> &amp;self.root;</span>
<span class="line" id="L170">}</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-comment">/// Updates the terminal if enough time has passed since last update. Thread-safe.</span></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">maybeRefresh</span>(self: *Progress) <span class="tok-type">void</span> {</span>
<span class="line" id="L174">    <span class="tok-kw">if</span> (self.timer) |*timer| {</span>
<span class="line" id="L175">        <span class="tok-kw">const</span> now = timer.read();</span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (now &lt; self.initial_delay_ns) <span class="tok-kw">return</span>;</span>
<span class="line" id="L177">        <span class="tok-kw">if</span> (!self.update_mutex.tryLock()) <span class="tok-kw">return</span>;</span>
<span class="line" id="L178">        <span class="tok-kw">defer</span> self.update_mutex.unlock();</span>
<span class="line" id="L179">        <span class="tok-comment">// TODO I have observed this to happen sometimes. I think we need to follow Rust's</span>
</span>
<span class="line" id="L180">        <span class="tok-comment">// lead and guarantee monotonically increasing times in the std lib itself.</span>
</span>
<span class="line" id="L181">        <span class="tok-kw">if</span> (now &lt; self.prev_refresh_timestamp) <span class="tok-kw">return</span>;</span>
<span class="line" id="L182">        <span class="tok-kw">if</span> (now - self.prev_refresh_timestamp &lt; self.refresh_rate_ns) <span class="tok-kw">return</span>;</span>
<span class="line" id="L183">        <span class="tok-kw">return</span> self.refreshWithHeldLock();</span>
<span class="line" id="L184">    }</span>
<span class="line" id="L185">}</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-comment">/// Updates the terminal and resets `self.next_refresh_timestamp`. Thread-safe.</span></span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">refresh</span>(self: *Progress) <span class="tok-type">void</span> {</span>
<span class="line" id="L189">    <span class="tok-kw">if</span> (!self.update_mutex.tryLock()) <span class="tok-kw">return</span>;</span>
<span class="line" id="L190">    <span class="tok-kw">defer</span> self.update_mutex.unlock();</span>
<span class="line" id="L191"></span>
<span class="line" id="L192">    <span class="tok-kw">return</span> self.refreshWithHeldLock();</span>
<span class="line" id="L193">}</span>
<span class="line" id="L194"></span>
<span class="line" id="L195"><span class="tok-kw">fn</span> <span class="tok-fn">refreshWithHeldLock</span>(self: *Progress) <span class="tok-type">void</span> {</span>
<span class="line" id="L196">    <span class="tok-kw">const</span> is_dumb = !self.supports_ansi_escape_codes <span class="tok-kw">and</span> !self.is_windows_terminal;</span>
<span class="line" id="L197">    <span class="tok-kw">if</span> (is_dumb <span class="tok-kw">and</span> self.dont_print_on_dumb) <span class="tok-kw">return</span>;</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    <span class="tok-kw">const</span> file = self.terminal <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L202">    <span class="tok-kw">if</span> (self.columns_written &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L203">        <span class="tok-comment">// restore the cursor position by moving the cursor</span>
</span>
<span class="line" id="L204">        <span class="tok-comment">// `columns_written` cells to the left, then clear the rest of the</span>
</span>
<span class="line" id="L205">        <span class="tok-comment">// line</span>
</span>
<span class="line" id="L206">        <span class="tok-kw">if</span> (self.supports_ansi_escape_codes) {</span>
<span class="line" id="L207">            end += (std.fmt.bufPrint(self.output_buffer[end..], <span class="tok-str">&quot;\x1b[{d}D&quot;</span>, .{self.columns_written}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>).len;</span>
<span class="line" id="L208">            end += (std.fmt.bufPrint(self.output_buffer[end..], <span class="tok-str">&quot;\x1b[0K&quot;</span>, .{}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>).len;</span>
<span class="line" id="L209">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .windows) winapi: {</span>
<span class="line" id="L210">            std.debug.assert(self.is_windows_terminal);</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">            <span class="tok-kw">var</span> info: windows.CONSOLE_SCREEN_BUFFER_INFO = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L213">            <span class="tok-kw">if</span> (windows.kernel32.GetConsoleScreenBufferInfo(file.handle, &amp;info) != windows.TRUE)</span>
<span class="line" id="L214">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">            <span class="tok-kw">var</span> cursor_pos = windows.COORD{</span>
<span class="line" id="L217">                .X = info.dwCursorPosition.X - <span class="tok-builtin">@intCast</span>(windows.SHORT, self.columns_written),</span>
<span class="line" id="L218">                .Y = info.dwCursorPosition.Y,</span>
<span class="line" id="L219">            };</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">            <span class="tok-kw">if</span> (cursor_pos.X &lt; <span class="tok-number">0</span>)</span>
<span class="line" id="L222">                cursor_pos.X = <span class="tok-number">0</span>;</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">            <span class="tok-kw">const</span> fill_chars = <span class="tok-builtin">@intCast</span>(windows.DWORD, info.dwSize.X - cursor_pos.X);</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">            <span class="tok-kw">var</span> written: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L227">            <span class="tok-kw">if</span> (windows.kernel32.FillConsoleOutputAttribute(</span>
<span class="line" id="L228">                file.handle,</span>
<span class="line" id="L229">                info.wAttributes,</span>
<span class="line" id="L230">                fill_chars,</span>
<span class="line" id="L231">                cursor_pos,</span>
<span class="line" id="L232">                &amp;written,</span>
<span class="line" id="L233">            ) != windows.TRUE) {</span>
<span class="line" id="L234">                <span class="tok-comment">// Stop trying to write to this file.</span>
</span>
<span class="line" id="L235">                self.terminal = <span class="tok-null">null</span>;</span>
<span class="line" id="L236">                <span class="tok-kw">break</span> :winapi;</span>
<span class="line" id="L237">            }</span>
<span class="line" id="L238">            <span class="tok-kw">if</span> (windows.kernel32.FillConsoleOutputCharacterW(</span>
<span class="line" id="L239">                file.handle,</span>
<span class="line" id="L240">                <span class="tok-str">' '</span>,</span>
<span class="line" id="L241">                fill_chars,</span>
<span class="line" id="L242">                cursor_pos,</span>
<span class="line" id="L243">                &amp;written,</span>
<span class="line" id="L244">            ) != windows.TRUE) <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">            <span class="tok-kw">if</span> (windows.kernel32.SetConsoleCursorPosition(file.handle, cursor_pos) != windows.TRUE)</span>
<span class="line" id="L247">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L248">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L249">            <span class="tok-comment">// we are in a &quot;dumb&quot; terminal like in acme or writing to a file</span>
</span>
<span class="line" id="L250">            self.output_buffer[end] = <span class="tok-str">'\n'</span>;</span>
<span class="line" id="L251">            end += <span class="tok-number">1</span>;</span>
<span class="line" id="L252">        }</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">        self.columns_written = <span class="tok-number">0</span>;</span>
<span class="line" id="L255">    }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-kw">if</span> (!self.done) {</span>
<span class="line" id="L258">        <span class="tok-kw">var</span> need_ellipse = <span class="tok-null">false</span>;</span>
<span class="line" id="L259">        <span class="tok-kw">var</span> maybe_node: ?*Node = &amp;self.root;</span>
<span class="line" id="L260">        <span class="tok-kw">while</span> (maybe_node) |node| {</span>
<span class="line" id="L261">            <span class="tok-kw">if</span> (need_ellipse) {</span>
<span class="line" id="L262">                self.bufWrite(&amp;end, <span class="tok-str">&quot;... &quot;</span>, .{});</span>
<span class="line" id="L263">            }</span>
<span class="line" id="L264">            need_ellipse = <span class="tok-null">false</span>;</span>
<span class="line" id="L265">            <span class="tok-kw">const</span> eti = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;node.unprotected_estimated_total_items, .Monotonic);</span>
<span class="line" id="L266">            <span class="tok-kw">const</span> completed_items = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;node.unprotected_completed_items, .Monotonic);</span>
<span class="line" id="L267">            <span class="tok-kw">const</span> current_item = completed_items + <span class="tok-number">1</span>;</span>
<span class="line" id="L268">            <span class="tok-kw">if</span> (node.name.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> eti &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L269">                <span class="tok-kw">if</span> (node.name.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L270">                    self.bufWrite(&amp;end, <span class="tok-str">&quot;{s}&quot;</span>, .{node.name});</span>
<span class="line" id="L271">                    need_ellipse = <span class="tok-null">true</span>;</span>
<span class="line" id="L272">                }</span>
<span class="line" id="L273">                <span class="tok-kw">if</span> (eti &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L274">                    <span class="tok-kw">if</span> (need_ellipse) self.bufWrite(&amp;end, <span class="tok-str">&quot; &quot;</span>, .{});</span>
<span class="line" id="L275">                    self.bufWrite(&amp;end, <span class="tok-str">&quot;[{d}/{d}] &quot;</span>, .{ current_item, eti });</span>
<span class="line" id="L276">                    need_ellipse = <span class="tok-null">false</span>;</span>
<span class="line" id="L277">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (completed_items != <span class="tok-number">0</span>) {</span>
<span class="line" id="L278">                    <span class="tok-kw">if</span> (need_ellipse) self.bufWrite(&amp;end, <span class="tok-str">&quot; &quot;</span>, .{});</span>
<span class="line" id="L279">                    self.bufWrite(&amp;end, <span class="tok-str">&quot;[{d}] &quot;</span>, .{current_item});</span>
<span class="line" id="L280">                    need_ellipse = <span class="tok-null">false</span>;</span>
<span class="line" id="L281">                }</span>
<span class="line" id="L282">            }</span>
<span class="line" id="L283">            maybe_node = <span class="tok-builtin">@atomicLoad</span>(?*Node, &amp;node.recently_updated_child, .Acquire);</span>
<span class="line" id="L284">        }</span>
<span class="line" id="L285">        <span class="tok-kw">if</span> (need_ellipse) {</span>
<span class="line" id="L286">            self.bufWrite(&amp;end, <span class="tok-str">&quot;... &quot;</span>, .{});</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">    _ = file.write(self.output_buffer[<span class="tok-number">0</span>..end]) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L291">        <span class="tok-comment">// Stop trying to write to this file once it errors.</span>
</span>
<span class="line" id="L292">        self.terminal = <span class="tok-null">null</span>;</span>
<span class="line" id="L293">    };</span>
<span class="line" id="L294">    <span class="tok-kw">if</span> (self.timer) |*timer| {</span>
<span class="line" id="L295">        self.prev_refresh_timestamp = timer.read();</span>
<span class="line" id="L296">    }</span>
<span class="line" id="L297">}</span>
<span class="line" id="L298"></span>
<span class="line" id="L299"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">log</span>(self: *Progress, <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L300">    <span class="tok-kw">const</span> file = self.terminal <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L301">        std.debug.print(format, args);</span>
<span class="line" id="L302">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L303">    };</span>
<span class="line" id="L304">    self.refresh();</span>
<span class="line" id="L305">    file.writer().print(format, args) <span class="tok-kw">catch</span> {</span>
<span class="line" id="L306">        self.terminal = <span class="tok-null">null</span>;</span>
<span class="line" id="L307">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L308">    };</span>
<span class="line" id="L309">    self.columns_written = <span class="tok-number">0</span>;</span>
<span class="line" id="L310">}</span>
<span class="line" id="L311"></span>
<span class="line" id="L312"><span class="tok-kw">fn</span> <span class="tok-fn">bufWrite</span>(self: *Progress, end: *<span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L313">    <span class="tok-kw">if</span> (std.fmt.bufPrint(self.output_buffer[end.*..], format, args)) |written| {</span>
<span class="line" id="L314">        <span class="tok-kw">const</span> amt = written.len;</span>
<span class="line" id="L315">        end.* += amt;</span>
<span class="line" id="L316">        self.columns_written += amt;</span>
<span class="line" id="L317">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L318">        <span class="tok-kw">error</span>.NoSpaceLeft =&gt; {</span>
<span class="line" id="L319">            self.columns_written += self.output_buffer.len - end.*;</span>
<span class="line" id="L320">            end.* = self.output_buffer.len;</span>
<span class="line" id="L321">            <span class="tok-kw">const</span> suffix = <span class="tok-str">&quot;... &quot;</span>;</span>
<span class="line" id="L322">            std.mem.copy(<span class="tok-type">u8</span>, self.output_buffer[self.output_buffer.len - suffix.len ..], suffix);</span>
<span class="line" id="L323">        },</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325">}</span>
<span class="line" id="L326"></span>
<span class="line" id="L327"><span class="tok-kw">test</span> <span class="tok-str">&quot;basic functionality&quot;</span> {</span>
<span class="line" id="L328">    <span class="tok-kw">var</span> disable = <span class="tok-null">true</span>;</span>
<span class="line" id="L329">    <span class="tok-kw">if</span> (disable) {</span>
<span class="line" id="L330">        <span class="tok-comment">// This test is disabled because it uses time.sleep() and is therefore slow. It also</span>
</span>
<span class="line" id="L331">        <span class="tok-comment">// prints bogus progress data to stderr.</span>
</span>
<span class="line" id="L332">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334">    <span class="tok-kw">var</span> progress = Progress{};</span>
<span class="line" id="L335">    <span class="tok-kw">const</span> root_node = progress.start(<span class="tok-str">&quot;&quot;</span>, <span class="tok-number">100</span>);</span>
<span class="line" id="L336">    <span class="tok-kw">defer</span> root_node.end();</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">    <span class="tok-kw">const</span> speed_factor = std.time.ns_per_ms;</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">const</span> sub_task_names = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L341">        <span class="tok-str">&quot;reticulating splines&quot;</span>,</span>
<span class="line" id="L342">        <span class="tok-str">&quot;adjusting shoes&quot;</span>,</span>
<span class="line" id="L343">        <span class="tok-str">&quot;climbing towers&quot;</span>,</span>
<span class="line" id="L344">        <span class="tok-str">&quot;pouring juice&quot;</span>,</span>
<span class="line" id="L345">    };</span>
<span class="line" id="L346">    <span class="tok-kw">var</span> next_sub_task: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L349">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L350">        <span class="tok-kw">var</span> node = root_node.start(sub_task_names[next_sub_task], <span class="tok-number">5</span>);</span>
<span class="line" id="L351">        node.activate();</span>
<span class="line" id="L352">        next_sub_task = (next_sub_task + <span class="tok-number">1</span>) % sub_task_names.len;</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">        node.completeOne();</span>
<span class="line" id="L355">        std.time.sleep(<span class="tok-number">5</span> * speed_factor);</span>
<span class="line" id="L356">        node.completeOne();</span>
<span class="line" id="L357">        node.completeOne();</span>
<span class="line" id="L358">        std.time.sleep(<span class="tok-number">5</span> * speed_factor);</span>
<span class="line" id="L359">        node.completeOne();</span>
<span class="line" id="L360">        node.completeOne();</span>
<span class="line" id="L361">        std.time.sleep(<span class="tok-number">5</span> * speed_factor);</span>
<span class="line" id="L362"></span>
<span class="line" id="L363">        node.end();</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">        std.time.sleep(<span class="tok-number">5</span> * speed_factor);</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367">    {</span>
<span class="line" id="L368">        <span class="tok-kw">var</span> node = root_node.start(<span class="tok-str">&quot;this is a really long name designed to activate the truncation code. let's find out if it works&quot;</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L369">        node.activate();</span>
<span class="line" id="L370">        std.time.sleep(<span class="tok-number">10</span> * speed_factor);</span>
<span class="line" id="L371">        progress.refresh();</span>
<span class="line" id="L372">        std.time.sleep(<span class="tok-number">10</span> * speed_factor);</span>
<span class="line" id="L373">        node.end();</span>
<span class="line" id="L374">    }</span>
<span class="line" id="L375">}</span>
<span class="line" id="L376"></span>
</code></pre></body>
</html>