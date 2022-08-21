<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/darwin.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Target = std.Target;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Version = std.builtin.Version;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> macos = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;darwin/macos.zig&quot;</span>);</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Check if SDK is installed on Darwin without triggering CLT installation popup window.</span></span>
<span class="line" id="L10"><span class="tok-comment">/// Note: simply invoking `xcrun` will inevitably trigger the CLT installation popup.</span></span>
<span class="line" id="L11"><span class="tok-comment">/// Therefore, we resort to the same tool used by Homebrew, namely, invoking `xcode-select --print-path`</span></span>
<span class="line" id="L12"><span class="tok-comment">/// and checking if the status is nonzero or the returned string in nonempty.</span></span>
<span class="line" id="L13"><span class="tok-comment">/// https://github.com/Homebrew/brew/blob/e119bdc571dcb000305411bc1e26678b132afb98/Library/Homebrew/brew.sh#L630</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDarwinSDKInstalled</span>(allocator: Allocator) <span class="tok-type">bool</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">const</span> argv = &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/usr/bin/xcode-select&quot;</span>, <span class="tok-str">&quot;--print-path&quot;</span> };</span>
<span class="line" id="L16">    <span class="tok-kw">const</span> result = std.ChildProcess.exec(.{ .allocator = allocator, .argv = argv }) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L17">    <span class="tok-kw">defer</span> {</span>
<span class="line" id="L18">        allocator.free(result.stderr);</span>
<span class="line" id="L19">        allocator.free(result.stdout);</span>
<span class="line" id="L20">    }</span>
<span class="line" id="L21">    <span class="tok-kw">if</span> (result.stderr.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> result.term.Exited != <span class="tok-number">0</span>) {</span>
<span class="line" id="L22">        <span class="tok-comment">// We don't actually care if there were errors as this is best-effort check anyhow.</span>
</span>
<span class="line" id="L23">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L24">    }</span>
<span class="line" id="L25">    <span class="tok-kw">return</span> result.stdout.len &gt; <span class="tok-number">0</span>;</span>
<span class="line" id="L26">}</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// Detect SDK on Darwin.</span></span>
<span class="line" id="L29"><span class="tok-comment">/// Calls `xcrun --sdk &lt;target_sdk&gt; --show-sdk-path` which fetches the path to the SDK sysroot (if any).</span></span>
<span class="line" id="L30"><span class="tok-comment">/// Subsequently calls `xcrun --sdk &lt;target_sdk&gt; --show-sdk-version` which fetches version of the SDK.</span></span>
<span class="line" id="L31"><span class="tok-comment">/// The caller needs to deinit the resulting struct.</span></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDarwinSDK</span>(allocator: Allocator, target: Target) ?DarwinSDK {</span>
<span class="line" id="L33">    <span class="tok-kw">const</span> is_simulator_abi = target.abi == .simulator;</span>
<span class="line" id="L34">    <span class="tok-kw">const</span> sdk = <span class="tok-kw">switch</span> (target.os.tag) {</span>
<span class="line" id="L35">        .macos =&gt; <span class="tok-str">&quot;macosx&quot;</span>,</span>
<span class="line" id="L36">        .ios =&gt; <span class="tok-kw">if</span> (is_simulator_abi) <span class="tok-str">&quot;iphonesimulator&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;iphoneos&quot;</span>,</span>
<span class="line" id="L37">        .watchos =&gt; <span class="tok-kw">if</span> (is_simulator_abi) <span class="tok-str">&quot;watchsimulator&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;watchos&quot;</span>,</span>
<span class="line" id="L38">        .tvos =&gt; <span class="tok-kw">if</span> (is_simulator_abi) <span class="tok-str">&quot;appletvsimulator&quot;</span> <span class="tok-kw">else</span> <span class="tok-str">&quot;appletvos&quot;</span>,</span>
<span class="line" id="L39">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L40">    };</span>
<span class="line" id="L41">    <span class="tok-kw">const</span> path = path: {</span>
<span class="line" id="L42">        <span class="tok-kw">const</span> argv = &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/usr/bin/xcrun&quot;</span>, <span class="tok-str">&quot;--sdk&quot;</span>, sdk, <span class="tok-str">&quot;--show-sdk-path&quot;</span> };</span>
<span class="line" id="L43">        <span class="tok-kw">const</span> result = std.ChildProcess.exec(.{ .allocator = allocator, .argv = argv }) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L44">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L45">            allocator.free(result.stderr);</span>
<span class="line" id="L46">            allocator.free(result.stdout);</span>
<span class="line" id="L47">        }</span>
<span class="line" id="L48">        <span class="tok-kw">if</span> (result.stderr.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> result.term.Exited != <span class="tok-number">0</span>) {</span>
<span class="line" id="L49">            <span class="tok-comment">// We don't actually care if there were errors as this is best-effort check anyhow</span>
</span>
<span class="line" id="L50">            <span class="tok-comment">// and in the worst case the user can specify the sysroot manually.</span>
</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53">        <span class="tok-kw">const</span> path = allocator.dupe(<span class="tok-type">u8</span>, mem.trimRight(<span class="tok-type">u8</span>, result.stdout, <span class="tok-str">&quot;\r\n&quot;</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L54">        <span class="tok-kw">break</span> :path path;</span>
<span class="line" id="L55">    };</span>
<span class="line" id="L56">    <span class="tok-kw">const</span> version = version: {</span>
<span class="line" id="L57">        <span class="tok-kw">const</span> argv = &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ <span class="tok-str">&quot;/usr/bin/xcrun&quot;</span>, <span class="tok-str">&quot;--sdk&quot;</span>, sdk, <span class="tok-str">&quot;--show-sdk-version&quot;</span> };</span>
<span class="line" id="L58">        <span class="tok-kw">const</span> result = std.ChildProcess.exec(.{ .allocator = allocator, .argv = argv }) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L59">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L60">            allocator.free(result.stderr);</span>
<span class="line" id="L61">            allocator.free(result.stdout);</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63">        <span class="tok-kw">if</span> (result.stderr.len != <span class="tok-number">0</span> <span class="tok-kw">or</span> result.term.Exited != <span class="tok-number">0</span>) {</span>
<span class="line" id="L64">            <span class="tok-comment">// We don't actually care if there were errors as this is best-effort check anyhow</span>
</span>
<span class="line" id="L65">            <span class="tok-comment">// and in the worst case the user can specify the sysroot manually.</span>
</span>
<span class="line" id="L66">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L67">        }</span>
<span class="line" id="L68">        <span class="tok-kw">const</span> raw_version = mem.trimRight(<span class="tok-type">u8</span>, result.stdout, <span class="tok-str">&quot;\r\n&quot;</span>);</span>
<span class="line" id="L69">        <span class="tok-kw">const</span> version = Version.parse(raw_version) <span class="tok-kw">catch</span> Version{</span>
<span class="line" id="L70">            .major = <span class="tok-number">0</span>,</span>
<span class="line" id="L71">            .minor = <span class="tok-number">0</span>,</span>
<span class="line" id="L72">        };</span>
<span class="line" id="L73">        <span class="tok-kw">break</span> :version version;</span>
<span class="line" id="L74">    };</span>
<span class="line" id="L75">    <span class="tok-kw">return</span> DarwinSDK{</span>
<span class="line" id="L76">        .path = path,</span>
<span class="line" id="L77">        .version = version,</span>
<span class="line" id="L78">    };</span>
<span class="line" id="L79">}</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DarwinSDK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L82">    path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L83">    version: Version,</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: DarwinSDK, allocator: Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L86">        allocator.free(self.path);</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88">};</span>
<span class="line" id="L89"></span>
<span class="line" id="L90"><span class="tok-kw">test</span> {</span>
<span class="line" id="L91">    _ = macos;</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
</code></pre></body>
</html>