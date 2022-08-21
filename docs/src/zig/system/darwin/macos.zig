<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/darwin/macos.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> Target = std.Target;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// Detect macOS version.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// `target_os` is not modified in case of error.</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detect</span>(target_os: *Target.Os) !<span class="tok-type">void</span> {</span>
<span class="line" id="L13">    <span class="tok-comment">// Drop use of osproductversion sysctl because:</span>
</span>
<span class="line" id="L14">    <span class="tok-comment">//   1. only available 10.13.4 High Sierra and later</span>
</span>
<span class="line" id="L15">    <span class="tok-comment">//   2. when used from a binary built against &lt; SDK 11.0 it returns 10.16 and masks Big Sur 11.x version</span>
</span>
<span class="line" id="L16">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L17">    <span class="tok-comment">// NEW APPROACH, STEP 1, parse file:</span>
</span>
<span class="line" id="L18">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L19">    <span class="tok-comment">//   /System/Library/CoreServices/SystemVersion.plist</span>
</span>
<span class="line" id="L20">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L21">    <span class="tok-comment">// NOTE: Historically `SystemVersion.plist` first appeared circa '2003</span>
</span>
<span class="line" id="L22">    <span class="tok-comment">// with the release of Mac OS X 10.3.0 Panther.</span>
</span>
<span class="line" id="L23">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L24">    <span class="tok-comment">// and if it contains a `10.16` value where the `16` is `&gt;= 16` then it is non-canonical,</span>
</span>
<span class="line" id="L25">    <span class="tok-comment">// discarded, and we move on to next step. Otherwise we accept the version.</span>
</span>
<span class="line" id="L26">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L27">    <span class="tok-comment">// BACKGROUND: `10.(16+)` is not a proper version and does not have enough fidelity to</span>
</span>
<span class="line" id="L28">    <span class="tok-comment">// indicate minor/point version of Big Sur and later. It is a context-sensitive result</span>
</span>
<span class="line" id="L29">    <span class="tok-comment">// issued by the kernel for backwards compatibility purposes. Likely the kernel checks</span>
</span>
<span class="line" id="L30">    <span class="tok-comment">// if the executable was linked against an SDK older than Big Sur.</span>
</span>
<span class="line" id="L31">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L32">    <span class="tok-comment">// STEP 2, parse next file:</span>
</span>
<span class="line" id="L33">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L34">    <span class="tok-comment">//   /System/Library/CoreServices/.SystemVersionPlatform.plist</span>
</span>
<span class="line" id="L35">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L36">    <span class="tok-comment">// NOTE: Historically `SystemVersionPlatform.plist` first appeared circa '2020</span>
</span>
<span class="line" id="L37">    <span class="tok-comment">// with the release of macOS 11.0 Big Sur.</span>
</span>
<span class="line" id="L38">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L39">    <span class="tok-comment">// Accessing the content via this path circumvents a context-sensitive result and</span>
</span>
<span class="line" id="L40">    <span class="tok-comment">// yields a canonical Big Sur version.</span>
</span>
<span class="line" id="L41">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L42">    <span class="tok-comment">// At this time there is no other known way for a &lt; SDK 11.0 executable to obtain a</span>
</span>
<span class="line" id="L43">    <span class="tok-comment">// canonical Big Sur version.</span>
</span>
<span class="line" id="L44">    <span class="tok-comment">//</span>
</span>
<span class="line" id="L45">    <span class="tok-comment">// This implementation uses a reasonably simplified approach to parse .plist file</span>
</span>
<span class="line" id="L46">    <span class="tok-comment">// that while it is an xml document, we have good history on the file and its format</span>
</span>
<span class="line" id="L47">    <span class="tok-comment">// such that I am comfortable with implementing a minimalistic parser.</span>
</span>
<span class="line" id="L48">    <span class="tok-comment">// Things like string and general escapes are not supported.</span>
</span>
<span class="line" id="L49">    <span class="tok-kw">const</span> prefixSlash = <span class="tok-str">&quot;/System/Library/CoreServices/&quot;</span>;</span>
<span class="line" id="L50">    <span class="tok-kw">const</span> paths = [_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{</span>
<span class="line" id="L51">        prefixSlash ++ <span class="tok-str">&quot;SystemVersion.plist&quot;</span>,</span>
<span class="line" id="L52">        prefixSlash ++ <span class="tok-str">&quot;.SystemVersionPlatform.plist&quot;</span>,</span>
<span class="line" id="L53">    };</span>
<span class="line" id="L54">    <span class="tok-kw">for</span> (paths) |path| {</span>
<span class="line" id="L55">        <span class="tok-comment">// approx. 4 times historical file size</span>
</span>
<span class="line" id="L56">        <span class="tok-kw">var</span> buf: [<span class="tok-number">2048</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">if</span> (std.fs.cwd().readFile(path, &amp;buf)) |bytes| {</span>
<span class="line" id="L59">            <span class="tok-kw">if</span> (parseSystemVersion(bytes)) |ver| {</span>
<span class="line" id="L60">                <span class="tok-comment">// never return non-canonical `10.(16+)`</span>
</span>
<span class="line" id="L61">                <span class="tok-kw">if</span> (!(ver.major == <span class="tok-number">10</span> <span class="tok-kw">and</span> ver.minor &gt;= <span class="tok-number">16</span>)) {</span>
<span class="line" id="L62">                    target_os.version_range.semver.min = ver;</span>
<span class="line" id="L63">                    target_os.version_range.semver.max = ver;</span>
<span class="line" id="L64">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L65">                }</span>
<span class="line" id="L66">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L67">            } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L68">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail;</span>
<span class="line" id="L69">            }</span>
<span class="line" id="L70">        } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L71">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail;</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73">    }</span>
<span class="line" id="L74">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OSVersionDetectionFail;</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">fn</span> <span class="tok-fn">parseSystemVersion</span>(buf: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !std.builtin.Version {</span>
<span class="line" id="L78">    <span class="tok-kw">var</span> svt = SystemVersionTokenizer{ .bytes = buf };</span>
<span class="line" id="L79">    <span class="tok-kw">try</span> svt.skipUntilTag(.start, <span class="tok-str">&quot;dict&quot;</span>);</span>
<span class="line" id="L80">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L81">        <span class="tok-kw">try</span> svt.skipUntilTag(.start, <span class="tok-str">&quot;key&quot;</span>);</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> content = <span class="tok-kw">try</span> svt.expectContent();</span>
<span class="line" id="L83">        <span class="tok-kw">try</span> svt.skipUntilTag(.end, <span class="tok-str">&quot;key&quot;</span>);</span>
<span class="line" id="L84">        <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, content, <span class="tok-str">&quot;ProductVersion&quot;</span>)) <span class="tok-kw">break</span>;</span>
<span class="line" id="L85">    }</span>
<span class="line" id="L86">    <span class="tok-kw">try</span> svt.skipUntilTag(.start, <span class="tok-str">&quot;string&quot;</span>);</span>
<span class="line" id="L87">    <span class="tok-kw">const</span> ver = <span class="tok-kw">try</span> svt.expectContent();</span>
<span class="line" id="L88">    <span class="tok-kw">try</span> svt.skipUntilTag(.end, <span class="tok-str">&quot;string&quot;</span>);</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-kw">return</span> std.builtin.Version.parse(ver);</span>
<span class="line" id="L91">}</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">const</span> SystemVersionTokenizer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L94">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L95">    index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L96">    state: State = .begin,</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *<span class="tok-builtin">@This</span>()) !?Token {</span>
<span class="line" id="L99">        <span class="tok-kw">var</span> mark: <span class="tok-type">usize</span> = self.index;</span>
<span class="line" id="L100">        <span class="tok-kw">var</span> tag = Tag{};</span>
<span class="line" id="L101">        <span class="tok-kw">var</span> content: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">        <span class="tok-kw">while</span> (self.index &lt; self.bytes.len) {</span>
<span class="line" id="L104">            <span class="tok-kw">const</span> char = self.bytes[self.index];</span>
<span class="line" id="L105">            <span class="tok-kw">switch</span> (self.state) {</span>
<span class="line" id="L106">                .begin =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L107">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L108">                        self.state = .tag0;</span>
<span class="line" id="L109">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L110">                        tag = Tag{};</span>
<span class="line" id="L111">                        mark = self.index;</span>
<span class="line" id="L112">                    },</span>
<span class="line" id="L113">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L114">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L115">                    },</span>
<span class="line" id="L116">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L117">                        self.state = .content;</span>
<span class="line" id="L118">                        content = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L119">                        mark = self.index;</span>
<span class="line" id="L120">                    },</span>
<span class="line" id="L121">                },</span>
<span class="line" id="L122">                .tag0 =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L123">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L124">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L125">                    },</span>
<span class="line" id="L126">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L127">                        self.state = .begin;</span>
<span class="line" id="L128">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L129">                        tag.name = self.bytes[mark..self.index];</span>
<span class="line" id="L130">                        <span class="tok-kw">return</span> Token{ .tag = tag };</span>
<span class="line" id="L131">                    },</span>
<span class="line" id="L132">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L133">                        self.state = .tag_string;</span>
<span class="line" id="L134">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L135">                    },</span>
<span class="line" id="L136">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L137">                        self.state = .tag0_end_or_empty;</span>
<span class="line" id="L138">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L139">                    },</span>
<span class="line" id="L140">                    <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span> =&gt; {</span>
<span class="line" id="L141">                        self.state = .tagN;</span>
<span class="line" id="L142">                        tag.kind = .start;</span>
<span class="line" id="L143">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L144">                    },</span>
<span class="line" id="L145">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L146">                        self.state = .tagN;</span>
<span class="line" id="L147">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L148">                    },</span>
<span class="line" id="L149">                },</span>
<span class="line" id="L150">                .tag0_end_or_empty =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L151">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L152">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L153">                    },</span>
<span class="line" id="L154">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L155">                        self.state = .begin;</span>
<span class="line" id="L156">                        tag.kind = .empty;</span>
<span class="line" id="L157">                        tag.name = self.bytes[self.index..self.index];</span>
<span class="line" id="L158">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L159">                        <span class="tok-kw">return</span> Token{ .tag = tag };</span>
<span class="line" id="L160">                    },</span>
<span class="line" id="L161">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L162">                        self.state = .tagN;</span>
<span class="line" id="L163">                        tag.kind = .end;</span>
<span class="line" id="L164">                        mark = self.index;</span>
<span class="line" id="L165">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L166">                    },</span>
<span class="line" id="L167">                },</span>
<span class="line" id="L168">                .tagN =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L169">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L170">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L171">                    },</span>
<span class="line" id="L172">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L173">                        self.state = .begin;</span>
<span class="line" id="L174">                        tag.name = self.bytes[mark..self.index];</span>
<span class="line" id="L175">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L176">                        <span class="tok-kw">return</span> Token{ .tag = tag };</span>
<span class="line" id="L177">                    },</span>
<span class="line" id="L178">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L179">                        self.state = .tag_string;</span>
<span class="line" id="L180">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L181">                    },</span>
<span class="line" id="L182">                    <span class="tok-str">'/'</span> =&gt; {</span>
<span class="line" id="L183">                        self.state = .tagN_end;</span>
<span class="line" id="L184">                        tag.kind = .end;</span>
<span class="line" id="L185">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L186">                    },</span>
<span class="line" id="L187">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L188">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L189">                    },</span>
<span class="line" id="L190">                },</span>
<span class="line" id="L191">                .tagN_end =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L192">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L193">                        self.state = .begin;</span>
<span class="line" id="L194">                        tag.name = self.bytes[mark..self.index];</span>
<span class="line" id="L195">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L196">                        <span class="tok-kw">return</span> Token{ .tag = tag };</span>
<span class="line" id="L197">                    },</span>
<span class="line" id="L198">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L199">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L200">                    },</span>
<span class="line" id="L201">                },</span>
<span class="line" id="L202">                .tag_string =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L203">                    <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L204">                        self.state = .tagN;</span>
<span class="line" id="L205">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L206">                    },</span>
<span class="line" id="L207">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L208">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L209">                    },</span>
<span class="line" id="L210">                },</span>
<span class="line" id="L211">                .content =&gt; <span class="tok-kw">switch</span> (char) {</span>
<span class="line" id="L212">                    <span class="tok-str">'&lt;'</span> =&gt; {</span>
<span class="line" id="L213">                        self.state = .tag0;</span>
<span class="line" id="L214">                        content = self.bytes[mark..self.index];</span>
<span class="line" id="L215">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L216">                        tag = Tag{};</span>
<span class="line" id="L217">                        mark = self.index;</span>
<span class="line" id="L218">                        <span class="tok-kw">return</span> Token{ .content = content };</span>
<span class="line" id="L219">                    },</span>
<span class="line" id="L220">                    <span class="tok-str">'&gt;'</span> =&gt; {</span>
<span class="line" id="L221">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadToken;</span>
<span class="line" id="L222">                    },</span>
<span class="line" id="L223">                    <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L224">                        self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L225">                    },</span>
<span class="line" id="L226">                },</span>
<span class="line" id="L227">            }</span>
<span class="line" id="L228">        }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L231">    }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-kw">fn</span> <span class="tok-fn">expectContent</span>(self: *<span class="tok-builtin">@This</span>()) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L234">        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> self.next()) |tok| {</span>
<span class="line" id="L235">            <span class="tok-kw">switch</span> (tok) {</span>
<span class="line" id="L236">                .content =&gt; |content| {</span>
<span class="line" id="L237">                    <span class="tok-kw">return</span> content;</span>
<span class="line" id="L238">                },</span>
<span class="line" id="L239">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L240">            }</span>
<span class="line" id="L241">        }</span>
<span class="line" id="L242">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedToken;</span>
<span class="line" id="L243">    }</span>
<span class="line" id="L244"></span>
<span class="line" id="L245">    <span class="tok-kw">fn</span> <span class="tok-fn">skipUntilTag</span>(self: *<span class="tok-builtin">@This</span>(), kind: Tag.Kind, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L246">        <span class="tok-kw">while</span> (<span class="tok-kw">try</span> self.next()) |tok| {</span>
<span class="line" id="L247">            <span class="tok-kw">switch</span> (tok) {</span>
<span class="line" id="L248">                .tag =&gt; |tag| {</span>
<span class="line" id="L249">                    <span class="tok-kw">if</span> (tag.kind == kind <span class="tok-kw">and</span> std.mem.eql(<span class="tok-type">u8</span>, tag.name, name)) <span class="tok-kw">return</span>;</span>
<span class="line" id="L250">                },</span>
<span class="line" id="L251">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L252">            }</span>
<span class="line" id="L253">        }</span>
<span class="line" id="L254">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TagNotFound;</span>
<span class="line" id="L255">    }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-kw">const</span> State = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L258">        begin,</span>
<span class="line" id="L259">        tag0,</span>
<span class="line" id="L260">        tag0_end_or_empty,</span>
<span class="line" id="L261">        tagN,</span>
<span class="line" id="L262">        tagN_end,</span>
<span class="line" id="L263">        tag_string,</span>
<span class="line" id="L264">        content,</span>
<span class="line" id="L265">    };</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">    <span class="tok-kw">const</span> Token = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L268">        tag: Tag,</span>
<span class="line" id="L269">        content: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L270">    };</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">    <span class="tok-kw">const</span> Tag = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L273">        kind: Kind = .unknown,</span>
<span class="line" id="L274">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-str">&quot;&quot;</span>,</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">        <span class="tok-kw">const</span> Kind = <span class="tok-kw">enum</span> { unknown, start, end, empty };</span>
<span class="line" id="L277">    };</span>
<span class="line" id="L278">};</span>
<span class="line" id="L279"></span>
<span class="line" id="L280"><span class="tok-kw">test</span> <span class="tok-str">&quot;detect&quot;</span> {</span>
<span class="line" id="L281">    <span class="tok-kw">const</span> cases = .{</span>
<span class="line" id="L282">        .{</span>
<span class="line" id="L283">            <span class="tok-str">\\&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;</span></span>

<span class="line" id="L284">            <span class="tok-str">\\&lt;!DOCTYPE plist PUBLIC &quot;-//Apple Computer//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;</span></span>

<span class="line" id="L285">            <span class="tok-str">\\&lt;plist version=&quot;1.0&quot;&gt;</span></span>

<span class="line" id="L286">            <span class="tok-str">\\&lt;dict&gt;</span></span>

<span class="line" id="L287">            <span class="tok-str">\\    &lt;key&gt;ProductBuildVersion&lt;/key&gt;</span></span>

<span class="line" id="L288">            <span class="tok-str">\\    &lt;string&gt;7B85&lt;/string&gt;</span></span>

<span class="line" id="L289">            <span class="tok-str">\\    &lt;key&gt;ProductCopyright&lt;/key&gt;</span></span>

<span class="line" id="L290">            <span class="tok-str">\\    &lt;string&gt;Apple Computer, Inc. 1983-2003&lt;/string&gt;</span></span>

<span class="line" id="L291">            <span class="tok-str">\\    &lt;key&gt;ProductName&lt;/key&gt;</span></span>

<span class="line" id="L292">            <span class="tok-str">\\    &lt;string&gt;Mac OS X&lt;/string&gt;</span></span>

<span class="line" id="L293">            <span class="tok-str">\\    &lt;key&gt;ProductUserVisibleVersion&lt;/key&gt;</span></span>

<span class="line" id="L294">            <span class="tok-str">\\    &lt;string&gt;10.3&lt;/string&gt;</span></span>

<span class="line" id="L295">            <span class="tok-str">\\    &lt;key&gt;ProductVersion&lt;/key&gt;</span></span>

<span class="line" id="L296">            <span class="tok-str">\\    &lt;string&gt;10.3&lt;/string&gt;</span></span>

<span class="line" id="L297">            <span class="tok-str">\\&lt;/dict&gt;</span></span>

<span class="line" id="L298">            <span class="tok-str">\\&lt;/plist&gt;</span></span>

<span class="line" id="L299">            ,</span>
<span class="line" id="L300">            .{ .major = <span class="tok-number">10</span>, .minor = <span class="tok-number">3</span> },</span>
<span class="line" id="L301">        },</span>
<span class="line" id="L302">        .{</span>
<span class="line" id="L303">            <span class="tok-str">\\&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;</span></span>

<span class="line" id="L304">            <span class="tok-str">\\&lt;!DOCTYPE plist PUBLIC &quot;-//Apple Computer//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;</span></span>

<span class="line" id="L305">            <span class="tok-str">\\&lt;plist version=&quot;1.0&quot;&gt;</span></span>

<span class="line" id="L306">            <span class="tok-str">\\&lt;dict&gt;</span></span>

<span class="line" id="L307">            <span class="tok-str">\\	&lt;key&gt;ProductBuildVersion&lt;/key&gt;</span></span>

<span class="line" id="L308">            <span class="tok-str">\\	&lt;string&gt;7W98&lt;/string&gt;</span></span>

<span class="line" id="L309">            <span class="tok-str">\\	&lt;key&gt;ProductCopyright&lt;/key&gt;</span></span>

<span class="line" id="L310">            <span class="tok-str">\\	&lt;string&gt;Apple Computer, Inc. 1983-2004&lt;/string&gt;</span></span>

<span class="line" id="L311">            <span class="tok-str">\\	&lt;key&gt;ProductName&lt;/key&gt;</span></span>

<span class="line" id="L312">            <span class="tok-str">\\	&lt;string&gt;Mac OS X&lt;/string&gt;</span></span>

<span class="line" id="L313">            <span class="tok-str">\\	&lt;key&gt;ProductUserVisibleVersion&lt;/key&gt;</span></span>

<span class="line" id="L314">            <span class="tok-str">\\	&lt;string&gt;10.3.9&lt;/string&gt;</span></span>

<span class="line" id="L315">            <span class="tok-str">\\	&lt;key&gt;ProductVersion&lt;/key&gt;</span></span>

<span class="line" id="L316">            <span class="tok-str">\\	&lt;string&gt;10.3.9&lt;/string&gt;</span></span>

<span class="line" id="L317">            <span class="tok-str">\\&lt;/dict&gt;</span></span>

<span class="line" id="L318">            <span class="tok-str">\\&lt;/plist&gt;</span></span>

<span class="line" id="L319">            ,</span>
<span class="line" id="L320">            .{ .major = <span class="tok-number">10</span>, .minor = <span class="tok-number">3</span>, .patch = <span class="tok-number">9</span> },</span>
<span class="line" id="L321">        },</span>
<span class="line" id="L322">        .{</span>
<span class="line" id="L323">            <span class="tok-str">\\&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;</span></span>

<span class="line" id="L324">            <span class="tok-str">\\&lt;!DOCTYPE plist PUBLIC &quot;-//Apple//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;</span></span>

<span class="line" id="L325">            <span class="tok-str">\\&lt;plist version=&quot;1.0&quot;&gt;</span></span>

<span class="line" id="L326">            <span class="tok-str">\\&lt;dict&gt;</span></span>

<span class="line" id="L327">            <span class="tok-str">\\	&lt;key&gt;ProductBuildVersion&lt;/key&gt;</span></span>

<span class="line" id="L328">            <span class="tok-str">\\	&lt;string&gt;19G68&lt;/string&gt;</span></span>

<span class="line" id="L329">            <span class="tok-str">\\	&lt;key&gt;ProductCopyright&lt;/key&gt;</span></span>

<span class="line" id="L330">            <span class="tok-str">\\	&lt;string&gt;1983-2020 Apple Inc.&lt;/string&gt;</span></span>

<span class="line" id="L331">            <span class="tok-str">\\	&lt;key&gt;ProductName&lt;/key&gt;</span></span>

<span class="line" id="L332">            <span class="tok-str">\\	&lt;string&gt;Mac OS X&lt;/string&gt;</span></span>

<span class="line" id="L333">            <span class="tok-str">\\	&lt;key&gt;ProductUserVisibleVersion&lt;/key&gt;</span></span>

<span class="line" id="L334">            <span class="tok-str">\\	&lt;string&gt;10.15.6&lt;/string&gt;</span></span>

<span class="line" id="L335">            <span class="tok-str">\\	&lt;key&gt;ProductVersion&lt;/key&gt;</span></span>

<span class="line" id="L336">            <span class="tok-str">\\	&lt;string&gt;10.15.6&lt;/string&gt;</span></span>

<span class="line" id="L337">            <span class="tok-str">\\	&lt;key&gt;iOSSupportVersion&lt;/key&gt;</span></span>

<span class="line" id="L338">            <span class="tok-str">\\	&lt;string&gt;13.6&lt;/string&gt;</span></span>

<span class="line" id="L339">            <span class="tok-str">\\&lt;/dict&gt;</span></span>

<span class="line" id="L340">            <span class="tok-str">\\&lt;/plist&gt;</span></span>

<span class="line" id="L341">            ,</span>
<span class="line" id="L342">            .{ .major = <span class="tok-number">10</span>, .minor = <span class="tok-number">15</span>, .patch = <span class="tok-number">6</span> },</span>
<span class="line" id="L343">        },</span>
<span class="line" id="L344">        .{</span>
<span class="line" id="L345">            <span class="tok-str">\\&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;</span></span>

<span class="line" id="L346">            <span class="tok-str">\\&lt;!DOCTYPE plist PUBLIC &quot;-//Apple//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;</span></span>

<span class="line" id="L347">            <span class="tok-str">\\&lt;plist version=&quot;1.0&quot;&gt;</span></span>

<span class="line" id="L348">            <span class="tok-str">\\&lt;dict&gt;</span></span>

<span class="line" id="L349">            <span class="tok-str">\\	&lt;key&gt;ProductBuildVersion&lt;/key&gt;</span></span>

<span class="line" id="L350">            <span class="tok-str">\\	&lt;string&gt;20A2408&lt;/string&gt;</span></span>

<span class="line" id="L351">            <span class="tok-str">\\	&lt;key&gt;ProductCopyright&lt;/key&gt;</span></span>

<span class="line" id="L352">            <span class="tok-str">\\	&lt;string&gt;1983-2020 Apple Inc.&lt;/string&gt;</span></span>

<span class="line" id="L353">            <span class="tok-str">\\	&lt;key&gt;ProductName&lt;/key&gt;</span></span>

<span class="line" id="L354">            <span class="tok-str">\\	&lt;string&gt;macOS&lt;/string&gt;</span></span>

<span class="line" id="L355">            <span class="tok-str">\\	&lt;key&gt;ProductUserVisibleVersion&lt;/key&gt;</span></span>

<span class="line" id="L356">            <span class="tok-str">\\	&lt;string&gt;11.0&lt;/string&gt;</span></span>

<span class="line" id="L357">            <span class="tok-str">\\	&lt;key&gt;ProductVersion&lt;/key&gt;</span></span>

<span class="line" id="L358">            <span class="tok-str">\\	&lt;string&gt;11.0&lt;/string&gt;</span></span>

<span class="line" id="L359">            <span class="tok-str">\\	&lt;key&gt;iOSSupportVersion&lt;/key&gt;</span></span>

<span class="line" id="L360">            <span class="tok-str">\\	&lt;string&gt;14.2&lt;/string&gt;</span></span>

<span class="line" id="L361">            <span class="tok-str">\\&lt;/dict&gt;</span></span>

<span class="line" id="L362">            <span class="tok-str">\\&lt;/plist&gt;</span></span>

<span class="line" id="L363">            ,</span>
<span class="line" id="L364">            .{ .major = <span class="tok-number">11</span>, .minor = <span class="tok-number">0</span> },</span>
<span class="line" id="L365">        },</span>
<span class="line" id="L366">        .{</span>
<span class="line" id="L367">            <span class="tok-str">\\&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;</span></span>

<span class="line" id="L368">            <span class="tok-str">\\&lt;!DOCTYPE plist PUBLIC &quot;-//Apple//DTD PLIST 1.0//EN&quot; &quot;http://www.apple.com/DTDs/PropertyList-1.0.dtd&quot;&gt;</span></span>

<span class="line" id="L369">            <span class="tok-str">\\&lt;plist version=&quot;1.0&quot;&gt;</span></span>

<span class="line" id="L370">            <span class="tok-str">\\&lt;dict&gt;</span></span>

<span class="line" id="L371">            <span class="tok-str">\\	&lt;key&gt;ProductBuildVersion&lt;/key&gt;</span></span>

<span class="line" id="L372">            <span class="tok-str">\\	&lt;string&gt;20C63&lt;/string&gt;</span></span>

<span class="line" id="L373">            <span class="tok-str">\\	&lt;key&gt;ProductCopyright&lt;/key&gt;</span></span>

<span class="line" id="L374">            <span class="tok-str">\\	&lt;string&gt;1983-2020 Apple Inc.&lt;/string&gt;</span></span>

<span class="line" id="L375">            <span class="tok-str">\\	&lt;key&gt;ProductName&lt;/key&gt;</span></span>

<span class="line" id="L376">            <span class="tok-str">\\	&lt;string&gt;macOS&lt;/string&gt;</span></span>

<span class="line" id="L377">            <span class="tok-str">\\	&lt;key&gt;ProductUserVisibleVersion&lt;/key&gt;</span></span>

<span class="line" id="L378">            <span class="tok-str">\\	&lt;string&gt;11.1&lt;/string&gt;</span></span>

<span class="line" id="L379">            <span class="tok-str">\\	&lt;key&gt;ProductVersion&lt;/key&gt;</span></span>

<span class="line" id="L380">            <span class="tok-str">\\	&lt;string&gt;11.1&lt;/string&gt;</span></span>

<span class="line" id="L381">            <span class="tok-str">\\	&lt;key&gt;iOSSupportVersion&lt;/key&gt;</span></span>

<span class="line" id="L382">            <span class="tok-str">\\	&lt;string&gt;14.3&lt;/string&gt;</span></span>

<span class="line" id="L383">            <span class="tok-str">\\&lt;/dict&gt;</span></span>

<span class="line" id="L384">            <span class="tok-str">\\&lt;/plist&gt;</span></span>

<span class="line" id="L385">            ,</span>
<span class="line" id="L386">            .{ .major = <span class="tok-number">11</span>, .minor = <span class="tok-number">1</span> },</span>
<span class="line" id="L387">        },</span>
<span class="line" id="L388">    };</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (cases) |case| {</span>
<span class="line" id="L391">        <span class="tok-kw">const</span> ver0 = <span class="tok-kw">try</span> parseSystemVersion(case[<span class="tok-number">0</span>]);</span>
<span class="line" id="L392">        <span class="tok-kw">const</span> ver1: std.builtin.Version = case[<span class="tok-number">1</span>];</span>
<span class="line" id="L393">        <span class="tok-kw">try</span> testVersionEquality(ver1, ver0);</span>
<span class="line" id="L394">    }</span>
<span class="line" id="L395">}</span>
<span class="line" id="L396"></span>
<span class="line" id="L397"><span class="tok-kw">fn</span> <span class="tok-fn">testVersionEquality</span>(expected: std.builtin.Version, got: std.builtin.Version) !<span class="tok-type">void</span> {</span>
<span class="line" id="L398">    <span class="tok-kw">var</span> b_expected: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L399">    <span class="tok-kw">const</span> s_expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-kw">try</span> std.fmt.bufPrint(b_expected[<span class="tok-number">0</span>..], <span class="tok-str">&quot;{}&quot;</span>, .{expected});</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">var</span> b_got: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L402">    <span class="tok-kw">const</span> s_got: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-kw">try</span> std.fmt.bufPrint(b_got[<span class="tok-number">0</span>..], <span class="tok-str">&quot;{}&quot;</span>, .{got});</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">    <span class="tok-kw">try</span> testing.expectEqualStrings(s_expected, s_got);</span>
<span class="line" id="L405">}</span>
<span class="line" id="L406"></span>
<span class="line" id="L407"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detectNativeCpuAndFeatures</span>() ?Target.Cpu {</span>
<span class="line" id="L408">    <span class="tok-kw">var</span> cpu_family: std.c.CPUFAMILY = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L409">    <span class="tok-kw">var</span> len: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(std.c.CPUFAMILY);</span>
<span class="line" id="L410">    os.sysctlbynameZ(<span class="tok-str">&quot;hw.cpufamily&quot;</span>, &amp;cpu_family, &amp;len, <span class="tok-null">null</span>, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L411">        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L412">        <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// only when setting values,</span>
</span>
<span class="line" id="L413">        <span class="tok-kw">error</span>.SystemResources =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// memory already on the stack</span>
</span>
<span class="line" id="L414">        <span class="tok-kw">error</span>.UnknownName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// constant, known good value</span>
</span>
<span class="line" id="L415">        <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// EFAULT: stack should be safe, EISDIR/ENOTDIR: constant, known good value</span>
</span>
<span class="line" id="L416">    };</span>
<span class="line" id="L417"></span>
<span class="line" id="L418">    <span class="tok-kw">const</span> current_arch = builtin.cpu.arch;</span>
<span class="line" id="L419">    <span class="tok-kw">switch</span> (current_arch) {</span>
<span class="line" id="L420">        .aarch64, .aarch64_be, .aarch64_32 =&gt; {</span>
<span class="line" id="L421">            <span class="tok-kw">const</span> model = <span class="tok-kw">switch</span> (cpu_family) {</span>
<span class="line" id="L422">                .ARM_FIRESTORM_ICESTORM =&gt; &amp;Target.aarch64.cpu.apple_a14,</span>
<span class="line" id="L423">                .ARM_LIGHTNING_THUNDER =&gt; &amp;Target.aarch64.cpu.apple_a13,</span>
<span class="line" id="L424">                .ARM_VORTEX_TEMPEST =&gt; &amp;Target.aarch64.cpu.apple_a12,</span>
<span class="line" id="L425">                .ARM_MONSOON_MISTRAL =&gt; &amp;Target.aarch64.cpu.apple_a11,</span>
<span class="line" id="L426">                .ARM_HURRICANE =&gt; &amp;Target.aarch64.cpu.apple_a10,</span>
<span class="line" id="L427">                .ARM_TWISTER =&gt; &amp;Target.aarch64.cpu.apple_a9,</span>
<span class="line" id="L428">                .ARM_TYPHOON =&gt; &amp;Target.aarch64.cpu.apple_a8,</span>
<span class="line" id="L429">                .ARM_CYCLONE =&gt; &amp;Target.aarch64.cpu.cyclone,</span>
<span class="line" id="L430">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L431">            };</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">            <span class="tok-kw">return</span> Target.Cpu{</span>
<span class="line" id="L434">                .arch = current_arch,</span>
<span class="line" id="L435">                .model = model,</span>
<span class="line" id="L436">                .features = model.features,</span>
<span class="line" id="L437">            };</span>
<span class="line" id="L438">        },</span>
<span class="line" id="L439">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L440">    }</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
</code></pre></body>
</html>