<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fs/get_app_data_dir.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> unicode = std.unicode;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetAppDataDirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L9">    OutOfMemory,</span>
<span class="line" id="L10">    AppDataDirUnavailable,</span>
<span class="line" id="L11">};</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L14"><span class="tok-comment">/// TODO determine if we can remove the allocator requirement</span></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAppDataDir</span>(allocator: mem.Allocator, appname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) GetAppDataDirError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L16">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L17">        .windows =&gt; {</span>
<span class="line" id="L18">            <span class="tok-kw">var</span> dir_path_ptr: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L19">            <span class="tok-kw">switch</span> (os.windows.shell32.SHGetKnownFolderPath(</span>
<span class="line" id="L20">                &amp;os.windows.FOLDERID_LocalAppData,</span>
<span class="line" id="L21">                os.windows.KF_FLAG_CREATE,</span>
<span class="line" id="L22">                <span class="tok-null">null</span>,</span>
<span class="line" id="L23">                &amp;dir_path_ptr,</span>
<span class="line" id="L24">            )) {</span>
<span class="line" id="L25">                os.windows.S_OK =&gt; {</span>
<span class="line" id="L26">                    <span class="tok-kw">defer</span> os.windows.ole32.CoTaskMemFree(<span class="tok-builtin">@ptrCast</span>(*<span class="tok-type">anyopaque</span>, dir_path_ptr));</span>
<span class="line" id="L27">                    <span class="tok-kw">const</span> global_dir = unicode.utf16leToUtf8Alloc(allocator, mem.sliceTo(dir_path_ptr, <span class="tok-number">0</span>)) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L28">                        <span class="tok-kw">error</span>.UnexpectedSecondSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable,</span>
<span class="line" id="L29">                        <span class="tok-kw">error</span>.ExpectedSecondSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable,</span>
<span class="line" id="L30">                        <span class="tok-kw">error</span>.DanglingSurrogateHalf =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable,</span>
<span class="line" id="L31">                        <span class="tok-kw">error</span>.OutOfMemory =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L32">                    };</span>
<span class="line" id="L33">                    <span class="tok-kw">defer</span> allocator.free(global_dir);</span>
<span class="line" id="L34">                    <span class="tok-kw">return</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ global_dir, appname });</span>
<span class="line" id="L35">                },</span>
<span class="line" id="L36">                os.windows.E_OUTOFMEMORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.OutOfMemory,</span>
<span class="line" id="L37">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable,</span>
<span class="line" id="L38">            }</span>
<span class="line" id="L39">        },</span>
<span class="line" id="L40">        .macos =&gt; {</span>
<span class="line" id="L41">            <span class="tok-kw">const</span> home_dir = os.getenv(<span class="tok-str">&quot;HOME&quot;</span>) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L42">                <span class="tok-comment">// TODO look in /etc/passwd</span>
</span>
<span class="line" id="L43">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable;</span>
<span class="line" id="L44">            };</span>
<span class="line" id="L45">            <span class="tok-kw">return</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ home_dir, <span class="tok-str">&quot;Library&quot;</span>, <span class="tok-str">&quot;Application Support&quot;</span>, appname });</span>
<span class="line" id="L46">        },</span>
<span class="line" id="L47">        .linux, .freebsd, .netbsd, .dragonfly, .openbsd, .solaris =&gt; {</span>
<span class="line" id="L48">            <span class="tok-kw">if</span> (os.getenv(<span class="tok-str">&quot;XDG_DATA_HOME&quot;</span>)) |xdg| {</span>
<span class="line" id="L49">                <span class="tok-kw">return</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ xdg, appname });</span>
<span class="line" id="L50">            }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">            <span class="tok-kw">const</span> home_dir = os.getenv(<span class="tok-str">&quot;HOME&quot;</span>) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L53">                <span class="tok-comment">// TODO look in /etc/passwd</span>
</span>
<span class="line" id="L54">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable;</span>
<span class="line" id="L55">            };</span>
<span class="line" id="L56">            <span class="tok-kw">return</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ home_dir, <span class="tok-str">&quot;.local&quot;</span>, <span class="tok-str">&quot;share&quot;</span>, appname });</span>
<span class="line" id="L57">        },</span>
<span class="line" id="L58">        .haiku =&gt; {</span>
<span class="line" id="L59">            <span class="tok-kw">var</span> dir_path_ptr: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L60">            <span class="tok-comment">// TODO look into directory_which</span>
</span>
<span class="line" id="L61">            <span class="tok-kw">const</span> be_user_settings = <span class="tok-number">0xbbe</span>;</span>
<span class="line" id="L62">            <span class="tok-kw">const</span> rc = os.system.find_directory(be_user_settings, -<span class="tok-number">1</span>, <span class="tok-null">true</span>, dir_path_ptr, <span class="tok-number">1</span>);</span>
<span class="line" id="L63">            <span class="tok-kw">const</span> settings_dir = <span class="tok-kw">try</span> allocator.dupeZ(<span class="tok-type">u8</span>, mem.sliceTo(dir_path_ptr, <span class="tok-number">0</span>));</span>
<span class="line" id="L64">            <span class="tok-kw">defer</span> allocator.free(settings_dir);</span>
<span class="line" id="L65">            <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L66">                <span class="tok-number">0</span> =&gt; <span class="tok-kw">return</span> fs.path.join(allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ settings_dir, appname }),</span>
<span class="line" id="L67">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AppDataDirUnavailable,</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69">        },</span>
<span class="line" id="L70">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported OS&quot;</span>),</span>
<span class="line" id="L71">    }</span>
<span class="line" id="L72">}</span>
<span class="line" id="L73"></span>
<span class="line" id="L74"><span class="tok-kw">test</span> <span class="tok-str">&quot;getAppDataDir&quot;</span> {</span>
<span class="line" id="L75">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-comment">// We can't actually validate the result</span>
</span>
<span class="line" id="L78">    <span class="tok-kw">const</span> dir = getAppDataDir(std.testing.allocator, <span class="tok-str">&quot;zig&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L79">    <span class="tok-kw">defer</span> std.testing.allocator.free(dir);</span>
<span class="line" id="L80">}</span>
<span class="line" id="L81"></span>
</code></pre></body>
</html>