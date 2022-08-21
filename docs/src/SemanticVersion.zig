<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>SemanticVersion.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! A software version formatted according to the Semantic Version 2 specification.</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! See: https://semver.org</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Version = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L7"></span>
<span class="line" id="L8">major: <span class="tok-type">usize</span>,</span>
<span class="line" id="L9">minor: <span class="tok-type">usize</span>,</span>
<span class="line" id="L10">patch: <span class="tok-type">usize</span>,</span>
<span class="line" id="L11">pre: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L12">build: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Range = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    min: Version,</span>
<span class="line" id="L16">    max: Version,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">includesVersion</span>(self: Range, ver: Version) <span class="tok-type">bool</span> {</span>
<span class="line" id="L19">        <span class="tok-kw">if</span> (self.min.order(ver) == .gt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L20">        <span class="tok-kw">if</span> (self.max.order(ver) == .lt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L21">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// Checks if system is guaranteed to be at least `version` or older than `version`.</span></span>
<span class="line" id="L25">    <span class="tok-comment">/// Returns `null` if a runtime check is required.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: Range, ver: Version) ?<span class="tok-type">bool</span> {</span>
<span class="line" id="L27">        <span class="tok-kw">if</span> (self.min.order(ver) != .lt) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L28">        <span class="tok-kw">if</span> (self.max.order(ver) == .lt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L29">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L30">    }</span>
<span class="line" id="L31">};</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(lhs: Version, rhs: Version) std.math.Order {</span>
<span class="line" id="L34">    <span class="tok-kw">if</span> (lhs.major &lt; rhs.major) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L35">    <span class="tok-kw">if</span> (lhs.major &gt; rhs.major) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L36">    <span class="tok-kw">if</span> (lhs.minor &lt; rhs.minor) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L37">    <span class="tok-kw">if</span> (lhs.minor &gt; rhs.minor) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L38">    <span class="tok-kw">if</span> (lhs.patch &lt; rhs.patch) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L39">    <span class="tok-kw">if</span> (lhs.patch &gt; rhs.patch) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L40">    <span class="tok-kw">if</span> (lhs.pre != <span class="tok-null">null</span> <span class="tok-kw">and</span> rhs.pre == <span class="tok-null">null</span>) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L41">    <span class="tok-kw">if</span> (lhs.pre == <span class="tok-null">null</span> <span class="tok-kw">and</span> rhs.pre == <span class="tok-null">null</span>) <span class="tok-kw">return</span> .eq;</span>
<span class="line" id="L42">    <span class="tok-kw">if</span> (lhs.pre == <span class="tok-null">null</span> <span class="tok-kw">and</span> rhs.pre != <span class="tok-null">null</span>) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">// Iterate over pre-release identifiers until a difference is found.</span>
</span>
<span class="line" id="L45">    <span class="tok-kw">var</span> lhs_pre_it = std.mem.split(<span class="tok-type">u8</span>, lhs.pre.?, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L46">    <span class="tok-kw">var</span> rhs_pre_it = std.mem.split(<span class="tok-type">u8</span>, rhs.pre.?, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L47">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> next_lid = lhs_pre_it.next();</span>
<span class="line" id="L49">        <span class="tok-kw">const</span> next_rid = rhs_pre_it.next();</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">        <span class="tok-comment">// A larger set of pre-release fields has a higher precedence than a smaller set.</span>
</span>
<span class="line" id="L52">        <span class="tok-kw">if</span> (next_lid == <span class="tok-null">null</span> <span class="tok-kw">and</span> next_rid != <span class="tok-null">null</span>) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L53">        <span class="tok-kw">if</span> (next_lid == <span class="tok-null">null</span> <span class="tok-kw">and</span> next_rid == <span class="tok-null">null</span>) <span class="tok-kw">return</span> .eq;</span>
<span class="line" id="L54">        <span class="tok-kw">if</span> (next_lid != <span class="tok-null">null</span> <span class="tok-kw">and</span> next_rid == <span class="tok-null">null</span>) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">const</span> lid = next_lid.?; <span class="tok-comment">// Left identifier</span>
</span>
<span class="line" id="L57">        <span class="tok-kw">const</span> rid = next_rid.?; <span class="tok-comment">// Right identifier</span>
</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">        <span class="tok-comment">// Attempt to parse identifiers as numbers. Overflows are checked by parse.</span>
</span>
<span class="line" id="L60">        <span class="tok-kw">const</span> lnum: ?<span class="tok-type">usize</span> = std.fmt.parseUnsigned(<span class="tok-type">usize</span>, lid, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L61">            <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L62">            <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L63">        };</span>
<span class="line" id="L64">        <span class="tok-kw">const</span> rnum: ?<span class="tok-type">usize</span> = std.fmt.parseUnsigned(<span class="tok-type">usize</span>, rid, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L65">            <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L66">            <span class="tok-kw">error</span>.Overflow =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L67">        };</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">        <span class="tok-comment">// Numeric identifiers always have lower precedence than non-numeric identifiers.</span>
</span>
<span class="line" id="L70">        <span class="tok-kw">if</span> (lnum != <span class="tok-null">null</span> <span class="tok-kw">and</span> rnum == <span class="tok-null">null</span>) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L71">        <span class="tok-kw">if</span> (lnum == <span class="tok-null">null</span> <span class="tok-kw">and</span> rnum != <span class="tok-null">null</span>) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">        <span class="tok-comment">// Identifiers consisting of only digits are compared numerically.</span>
</span>
<span class="line" id="L74">        <span class="tok-comment">// Identifiers with letters or hyphens are compared lexically in ASCII sort order.</span>
</span>
<span class="line" id="L75">        <span class="tok-kw">if</span> (lnum != <span class="tok-null">null</span> <span class="tok-kw">and</span> rnum != <span class="tok-null">null</span>) {</span>
<span class="line" id="L76">            <span class="tok-kw">if</span> (lnum.? &lt; rnum.?) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L77">            <span class="tok-kw">if</span> (lnum.? &gt; rnum.?) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L78">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L79">            <span class="tok-kw">const</span> ord = std.mem.order(<span class="tok-type">u8</span>, lid, rid);</span>
<span class="line" id="L80">            <span class="tok-kw">if</span> (ord != .eq) <span class="tok-kw">return</span> ord;</span>
<span class="line" id="L81">        }</span>
<span class="line" id="L82">    }</span>
<span class="line" id="L83">}</span>
<span class="line" id="L84"></span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Version {</span>
<span class="line" id="L86">    <span class="tok-comment">// Parse the required major, minor, and patch numbers.</span>
</span>
<span class="line" id="L87">    <span class="tok-kw">const</span> extra_index = std.mem.indexOfAny(<span class="tok-type">u8</span>, text, <span class="tok-str">&quot;-+&quot;</span>);</span>
<span class="line" id="L88">    <span class="tok-kw">const</span> required = text[<span class="tok-number">0</span>..(extra_index <span class="tok-kw">orelse</span> text.len)];</span>
<span class="line" id="L89">    <span class="tok-kw">var</span> it = std.mem.split(<span class="tok-type">u8</span>, required, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L90">    <span class="tok-kw">var</span> ver = Version{</span>
<span class="line" id="L91">        .major = <span class="tok-kw">try</span> parseNum(it.first()),</span>
<span class="line" id="L92">        .minor = <span class="tok-kw">try</span> parseNum(it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion),</span>
<span class="line" id="L93">        .patch = <span class="tok-kw">try</span> parseNum(it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion),</span>
<span class="line" id="L94">    };</span>
<span class="line" id="L95">    <span class="tok-kw">if</span> (it.next() != <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L96">    <span class="tok-kw">if</span> (extra_index == <span class="tok-null">null</span>) <span class="tok-kw">return</span> ver;</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-comment">// Slice optional pre-release or build metadata components.</span>
</span>
<span class="line" id="L99">    <span class="tok-kw">const</span> extra: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = text[extra_index.?..text.len];</span>
<span class="line" id="L100">    <span class="tok-kw">if</span> (extra[<span class="tok-number">0</span>] == <span class="tok-str">'-'</span>) {</span>
<span class="line" id="L101">        <span class="tok-kw">const</span> build_index = std.mem.indexOfScalar(<span class="tok-type">u8</span>, extra, <span class="tok-str">'+'</span>);</span>
<span class="line" id="L102">        ver.pre = extra[<span class="tok-number">1</span>..(build_index <span class="tok-kw">orelse</span> extra.len)];</span>
<span class="line" id="L103">        <span class="tok-kw">if</span> (build_index) |idx| ver.build = extra[(idx + <span class="tok-number">1</span>)..];</span>
<span class="line" id="L104">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L105">        ver.build = extra[<span class="tok-number">1</span>..];</span>
<span class="line" id="L106">    }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">    <span class="tok-comment">// Check validity of optional pre-release identifiers.</span>
</span>
<span class="line" id="L109">    <span class="tok-comment">// See: https://semver.org/#spec-item-9</span>
</span>
<span class="line" id="L110">    <span class="tok-kw">if</span> (ver.pre) |pre| {</span>
<span class="line" id="L111">        it = std.mem.split(<span class="tok-type">u8</span>, pre, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L112">        <span class="tok-kw">while</span> (it.next()) |id| {</span>
<span class="line" id="L113">            <span class="tok-comment">// Identifiers MUST NOT be empty.</span>
</span>
<span class="line" id="L114">            <span class="tok-kw">if</span> (id.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">            <span class="tok-comment">// Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].</span>
</span>
<span class="line" id="L117">            <span class="tok-kw">for</span> (id) |c| <span class="tok-kw">if</span> (!std.ascii.isAlNum(c) <span class="tok-kw">and</span> c != <span class="tok-str">'-'</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">            <span class="tok-comment">// Numeric identifiers MUST NOT include leading zeroes.</span>
</span>
<span class="line" id="L120">            <span class="tok-kw">const</span> is_num = <span class="tok-kw">for</span> (id) |c| {</span>
<span class="line" id="L121">                <span class="tok-kw">if</span> (!std.ascii.isDigit(c)) <span class="tok-kw">break</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L122">            } <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L123">            <span class="tok-kw">if</span> (is_num) _ = <span class="tok-kw">try</span> parseNum(id);</span>
<span class="line" id="L124">        }</span>
<span class="line" id="L125">    }</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-comment">// Check validity of optional build metadata identifiers.</span>
</span>
<span class="line" id="L128">    <span class="tok-comment">// See: https://semver.org/#spec-item-10</span>
</span>
<span class="line" id="L129">    <span class="tok-kw">if</span> (ver.build) |build| {</span>
<span class="line" id="L130">        it = std.mem.split(<span class="tok-type">u8</span>, build, <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L131">        <span class="tok-kw">while</span> (it.next()) |id| {</span>
<span class="line" id="L132">            <span class="tok-comment">// Identifiers MUST NOT be empty.</span>
</span>
<span class="line" id="L133">            <span class="tok-kw">if</span> (id.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">            <span class="tok-comment">// Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-].</span>
</span>
<span class="line" id="L136">            <span class="tok-kw">for</span> (id) |c| <span class="tok-kw">if</span> (!std.ascii.isAlNum(c) <span class="tok-kw">and</span> c != <span class="tok-str">'-'</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">return</span> ver;</span>
<span class="line" id="L141">}</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">fn</span> <span class="tok-fn">parseNum</span>(text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L144">    <span class="tok-comment">// Leading zeroes are not allowed.</span>
</span>
<span class="line" id="L145">    <span class="tok-kw">if</span> (text.len &gt; <span class="tok-number">1</span> <span class="tok-kw">and</span> text[<span class="tok-number">0</span>] == <span class="tok-str">'0'</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">return</span> std.fmt.parseUnsigned(<span class="tok-type">usize</span>, text, <span class="tok-number">10</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L148">        <span class="tok-kw">error</span>.InvalidCharacter =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion,</span>
<span class="line" id="L149">        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L150">    };</span>
<span class="line" id="L151">}</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L154">    self: Version,</span>
<span class="line" id="L155">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L156">    options: std.fmt.FormatOptions,</span>
<span class="line" id="L157">    out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L158">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L159">    _ = options;</span>
<span class="line" id="L160">    <span class="tok-kw">if</span> (fmt.len != <span class="tok-number">0</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unknown format string: '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L161">    <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{d}.{d}.{d}&quot;</span>, .{ self.major, self.minor, self.patch });</span>
<span class="line" id="L162">    <span class="tok-kw">if</span> (self.pre) |pre| <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;-{s}&quot;</span>, .{pre});</span>
<span class="line" id="L163">    <span class="tok-kw">if</span> (self.build) |build| <span class="tok-kw">try</span> std.fmt.format(out_stream, <span class="tok-str">&quot;+{s}&quot;</span>, .{build});</span>
<span class="line" id="L164">}</span>
<span class="line" id="L165"></span>
<span class="line" id="L166"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L167"><span class="tok-kw">const</span> expectError = std.testing.expectError;</span>
<span class="line" id="L168"></span>
<span class="line" id="L169"><span class="tok-kw">test</span> <span class="tok-str">&quot;SemanticVersion format&quot;</span> {</span>
<span class="line" id="L170">    <span class="tok-comment">// Test vectors are from https://github.com/semver/semver.org/issues/59#issuecomment-390854010.</span>
</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-comment">// Valid version strings should be accepted.</span>
</span>
<span class="line" id="L173">    <span class="tok-kw">for</span> ([_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L174">        <span class="tok-str">&quot;0.0.4&quot;</span>,</span>
<span class="line" id="L175">        <span class="tok-str">&quot;1.2.3&quot;</span>,</span>
<span class="line" id="L176">        <span class="tok-str">&quot;10.20.30&quot;</span>,</span>
<span class="line" id="L177">        <span class="tok-str">&quot;1.1.2-prerelease+meta&quot;</span>,</span>
<span class="line" id="L178">        <span class="tok-str">&quot;1.1.2+meta&quot;</span>,</span>
<span class="line" id="L179">        <span class="tok-str">&quot;1.1.2+meta-valid&quot;</span>,</span>
<span class="line" id="L180">        <span class="tok-str">&quot;1.0.0-alpha&quot;</span>,</span>
<span class="line" id="L181">        <span class="tok-str">&quot;1.0.0-beta&quot;</span>,</span>
<span class="line" id="L182">        <span class="tok-str">&quot;1.0.0-alpha.beta&quot;</span>,</span>
<span class="line" id="L183">        <span class="tok-str">&quot;1.0.0-alpha.beta.1&quot;</span>,</span>
<span class="line" id="L184">        <span class="tok-str">&quot;1.0.0-alpha.1&quot;</span>,</span>
<span class="line" id="L185">        <span class="tok-str">&quot;1.0.0-alpha0.valid&quot;</span>,</span>
<span class="line" id="L186">        <span class="tok-str">&quot;1.0.0-alpha.0valid&quot;</span>,</span>
<span class="line" id="L187">        <span class="tok-str">&quot;1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay&quot;</span>,</span>
<span class="line" id="L188">        <span class="tok-str">&quot;1.0.0-rc.1+build.1&quot;</span>,</span>
<span class="line" id="L189">        <span class="tok-str">&quot;2.0.0-rc.1+build.123&quot;</span>,</span>
<span class="line" id="L190">        <span class="tok-str">&quot;1.2.3-beta&quot;</span>,</span>
<span class="line" id="L191">        <span class="tok-str">&quot;10.2.3-DEV-SNAPSHOT&quot;</span>,</span>
<span class="line" id="L192">        <span class="tok-str">&quot;1.2.3-SNAPSHOT-123&quot;</span>,</span>
<span class="line" id="L193">        <span class="tok-str">&quot;1.0.0&quot;</span>,</span>
<span class="line" id="L194">        <span class="tok-str">&quot;2.0.0&quot;</span>,</span>
<span class="line" id="L195">        <span class="tok-str">&quot;1.1.7&quot;</span>,</span>
<span class="line" id="L196">        <span class="tok-str">&quot;2.0.0+build.1848&quot;</span>,</span>
<span class="line" id="L197">        <span class="tok-str">&quot;2.0.1-alpha.1227&quot;</span>,</span>
<span class="line" id="L198">        <span class="tok-str">&quot;1.0.0-alpha+beta&quot;</span>,</span>
<span class="line" id="L199">        <span class="tok-str">&quot;1.2.3----RC-SNAPSHOT.12.9.1--.12+788&quot;</span>,</span>
<span class="line" id="L200">        <span class="tok-str">&quot;1.2.3----R-S.12.9.1--.12+meta&quot;</span>,</span>
<span class="line" id="L201">        <span class="tok-str">&quot;1.2.3----RC-SNAPSHOT.12.9.1--.12&quot;</span>,</span>
<span class="line" id="L202">        <span class="tok-str">&quot;1.0.0+0.build.1-rc.10000aaa-kk-0.1&quot;</span>,</span>
<span class="line" id="L203">    }) |valid| <span class="tok-kw">try</span> std.testing.expectFmt(valid, <span class="tok-str">&quot;{}&quot;</span>, .{<span class="tok-kw">try</span> parse(valid)});</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    <span class="tok-comment">// Invalid version strings should be rejected.</span>
</span>
<span class="line" id="L206">    <span class="tok-kw">for</span> ([_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L207">        <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L208">        <span class="tok-str">&quot;1&quot;</span>,</span>
<span class="line" id="L209">        <span class="tok-str">&quot;1.2&quot;</span>,</span>
<span class="line" id="L210">        <span class="tok-str">&quot;1.2.3-0123&quot;</span>,</span>
<span class="line" id="L211">        <span class="tok-str">&quot;1.2.3-0123.0123&quot;</span>,</span>
<span class="line" id="L212">        <span class="tok-str">&quot;1.1.2+.123&quot;</span>,</span>
<span class="line" id="L213">        <span class="tok-str">&quot;+invalid&quot;</span>,</span>
<span class="line" id="L214">        <span class="tok-str">&quot;-invalid&quot;</span>,</span>
<span class="line" id="L215">        <span class="tok-str">&quot;-invalid+invalid&quot;</span>,</span>
<span class="line" id="L216">        <span class="tok-str">&quot;-invalid.01&quot;</span>,</span>
<span class="line" id="L217">        <span class="tok-str">&quot;alpha&quot;</span>,</span>
<span class="line" id="L218">        <span class="tok-str">&quot;alpha.beta&quot;</span>,</span>
<span class="line" id="L219">        <span class="tok-str">&quot;alpha.beta.1&quot;</span>,</span>
<span class="line" id="L220">        <span class="tok-str">&quot;alpha.1&quot;</span>,</span>
<span class="line" id="L221">        <span class="tok-str">&quot;alpha+beta&quot;</span>,</span>
<span class="line" id="L222">        <span class="tok-str">&quot;alpha_beta&quot;</span>,</span>
<span class="line" id="L223">        <span class="tok-str">&quot;alpha.&quot;</span>,</span>
<span class="line" id="L224">        <span class="tok-str">&quot;alpha..&quot;</span>,</span>
<span class="line" id="L225">        <span class="tok-str">&quot;beta\\&quot;</span>,</span>
<span class="line" id="L226">        <span class="tok-str">&quot;1.0.0-alpha_beta&quot;</span>,</span>
<span class="line" id="L227">        <span class="tok-str">&quot;-alpha.&quot;</span>,</span>
<span class="line" id="L228">        <span class="tok-str">&quot;1.0.0-alpha..&quot;</span>,</span>
<span class="line" id="L229">        <span class="tok-str">&quot;1.0.0-alpha..1&quot;</span>,</span>
<span class="line" id="L230">        <span class="tok-str">&quot;1.0.0-alpha...1&quot;</span>,</span>
<span class="line" id="L231">        <span class="tok-str">&quot;1.0.0-alpha....1&quot;</span>,</span>
<span class="line" id="L232">        <span class="tok-str">&quot;1.0.0-alpha.....1&quot;</span>,</span>
<span class="line" id="L233">        <span class="tok-str">&quot;1.0.0-alpha......1&quot;</span>,</span>
<span class="line" id="L234">        <span class="tok-str">&quot;1.0.0-alpha.......1&quot;</span>,</span>
<span class="line" id="L235">        <span class="tok-str">&quot;01.1.1&quot;</span>,</span>
<span class="line" id="L236">        <span class="tok-str">&quot;1.01.1&quot;</span>,</span>
<span class="line" id="L237">        <span class="tok-str">&quot;1.1.01&quot;</span>,</span>
<span class="line" id="L238">        <span class="tok-str">&quot;1.2&quot;</span>,</span>
<span class="line" id="L239">        <span class="tok-str">&quot;1.2.3.DEV&quot;</span>,</span>
<span class="line" id="L240">        <span class="tok-str">&quot;1.2-SNAPSHOT&quot;</span>,</span>
<span class="line" id="L241">        <span class="tok-str">&quot;1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788&quot;</span>,</span>
<span class="line" id="L242">        <span class="tok-str">&quot;1.2-RC-SNAPSHOT&quot;</span>,</span>
<span class="line" id="L243">        <span class="tok-str">&quot;-1.0.3-gamma+b7718&quot;</span>,</span>
<span class="line" id="L244">        <span class="tok-str">&quot;+justmeta&quot;</span>,</span>
<span class="line" id="L245">        <span class="tok-str">&quot;9.8.7+meta+meta&quot;</span>,</span>
<span class="line" id="L246">        <span class="tok-str">&quot;9.8.7-whatever+meta+meta&quot;</span>,</span>
<span class="line" id="L247">    }) |invalid| <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.InvalidVersion, parse(invalid));</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-comment">// Valid version string that may overflow.</span>
</span>
<span class="line" id="L250">    <span class="tok-kw">const</span> big_valid = <span class="tok-str">&quot;99999999999999999999999.999999999999999999.99999999999999999&quot;</span>;</span>
<span class="line" id="L251">    <span class="tok-kw">if</span> (parse(big_valid)) |ver| {</span>
<span class="line" id="L252">        <span class="tok-kw">try</span> std.testing.expectFmt(big_valid, <span class="tok-str">&quot;{}&quot;</span>, .{ver});</span>
<span class="line" id="L253">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">try</span> expect(err == <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-comment">// Invalid version string that may overflow.</span>
</span>
<span class="line" id="L256">    <span class="tok-kw">const</span> big_invalid = <span class="tok-str">&quot;99999999999999999999999.999999999999999999.99999999999999999----RC-SNAPSHOT.12.09.1--------------------------------..12&quot;</span>;</span>
<span class="line" id="L257">    <span class="tok-kw">if</span> (parse(big_invalid)) |ver| std.debug.panic(<span class="tok-str">&quot;expected error, found {}&quot;</span>, .{ver}) <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L258">}</span>
<span class="line" id="L259"></span>
<span class="line" id="L260"><span class="tok-kw">test</span> <span class="tok-str">&quot;SemanticVersion precedence&quot;</span> {</span>
<span class="line" id="L261">    <span class="tok-comment">// SemVer 2 spec 11.2 example: 1.0.0 &lt; 2.0.0 &lt; 2.1.0 &lt; 2.1.1.</span>
</span>
<span class="line" id="L262">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;2.0.0&quot;</span>)) == .lt);</span>
<span class="line" id="L263">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;2.0.0&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;2.1.0&quot;</span>)) == .lt);</span>
<span class="line" id="L264">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;2.1.0&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;2.1.1&quot;</span>)) == .lt);</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-comment">// SemVer 2 spec 11.3 example: 1.0.0-alpha &lt; 1.0.0.</span>
</span>
<span class="line" id="L267">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0&quot;</span>)) == .lt);</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-comment">// SemVer 2 spec 11.4 example: 1.0.0-alpha &lt; 1.0.0-alpha.1 &lt; 1.0.0-alpha.beta &lt; 1.0.0-beta &lt;</span>
</span>
<span class="line" id="L270">    <span class="tok-comment">// 1.0.0-beta.2 &lt; 1.0.0-beta.11 &lt; 1.0.0-rc.1 &lt; 1.0.0.</span>
</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha.1&quot;</span>)) == .lt);</span>
<span class="line" id="L272">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha.1&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha.beta&quot;</span>)) == .lt);</span>
<span class="line" id="L273">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-alpha.beta&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta&quot;</span>)) == .lt);</span>
<span class="line" id="L274">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta.2&quot;</span>)) == .lt);</span>
<span class="line" id="L275">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta.2&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta.11&quot;</span>)) == .lt);</span>
<span class="line" id="L276">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-beta.11&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-rc.1&quot;</span>)) == .lt);</span>
<span class="line" id="L277">    <span class="tok-kw">try</span> expect(order(<span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0-rc.1&quot;</span>), <span class="tok-kw">try</span> parse(<span class="tok-str">&quot;1.0.0&quot;</span>)) == .lt);</span>
<span class="line" id="L278">}</span>
<span class="line" id="L279"></span>
<span class="line" id="L280"><span class="tok-kw">test</span> <span class="tok-str">&quot;zig_version&quot;</span> {</span>
<span class="line" id="L281">    <span class="tok-comment">// An approximate Zig build that predates this test.</span>
</span>
<span class="line" id="L282">    <span class="tok-kw">const</span> older_version = .{ .major = <span class="tok-number">0</span>, .minor = <span class="tok-number">8</span>, .patch = <span class="tok-number">0</span>, .pre = <span class="tok-str">&quot;dev.874&quot;</span> };</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">    <span class="tok-comment">// Simulated compatibility check using Zig version.</span>
</span>
<span class="line" id="L285">    <span class="tok-kw">const</span> compatible = <span class="tok-kw">comptime</span> <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_version.order(older_version) == .gt;</span>
<span class="line" id="L286">    <span class="tok-kw">if</span> (!compatible) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;zig_version test failed&quot;</span>);</span>
<span class="line" id="L287">}</span>
<span class="line" id="L288"></span>
</code></pre></body>
</html>