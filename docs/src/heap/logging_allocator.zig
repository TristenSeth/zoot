<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>heap/logging_allocator.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// This allocator is used in front of another allocator and logs to `std.log`</span></span>
<span class="line" id="L5"><span class="tok-comment">/// on every call to the allocator.</span></span>
<span class="line" id="L6"><span class="tok-comment">/// For logging to a `std.io.Writer` see `std.heap.LogToWriterAllocator`</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LoggingAllocator</span>(</span>
<span class="line" id="L8">    <span class="tok-kw">comptime</span> success_log_level: std.log.Level,</span>
<span class="line" id="L9">    <span class="tok-kw">comptime</span> failure_log_level: std.log.Level,</span>
<span class="line" id="L10">) <span class="tok-type">type</span> {</span>
<span class="line" id="L11">    <span class="tok-kw">return</span> ScopedLoggingAllocator(.default, success_log_level, failure_log_level);</span>
<span class="line" id="L12">}</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-comment">/// This allocator is used in front of another allocator and logs to `std.log`</span></span>
<span class="line" id="L15"><span class="tok-comment">/// with the given scope on every call to the allocator.</span></span>
<span class="line" id="L16"><span class="tok-comment">/// For logging to a `std.io.Writer` see `std.heap.LogToWriterAllocator`</span></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ScopedLoggingAllocator</span>(</span>
<span class="line" id="L18">    <span class="tok-kw">comptime</span> scope: <span class="tok-builtin">@Type</span>(.EnumLiteral),</span>
<span class="line" id="L19">    <span class="tok-kw">comptime</span> success_log_level: std.log.Level,</span>
<span class="line" id="L20">    <span class="tok-kw">comptime</span> failure_log_level: std.log.Level,</span>
<span class="line" id="L21">) <span class="tok-type">type</span> {</span>
<span class="line" id="L22">    <span class="tok-kw">const</span> log = std.log.scoped(scope);</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L25">        parent_allocator: Allocator,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(parent_allocator: Allocator) Self {</span>
<span class="line" id="L30">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L31">                .parent_allocator = parent_allocator,</span>
<span class="line" id="L32">            };</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *Self) Allocator {</span>
<span class="line" id="L36">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L37">        }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-comment">// This function is required as the `std.log.log` function is not public</span>
</span>
<span class="line" id="L40">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">logHelper</span>(<span class="tok-kw">comptime</span> log_level: std.log.Level, <span class="tok-kw">comptime</span> format: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L41">            <span class="tok-kw">switch</span> (log_level) {</span>
<span class="line" id="L42">                .err =&gt; log.err(format, args),</span>
<span class="line" id="L43">                .warn =&gt; log.warn(format, args),</span>
<span class="line" id="L44">                .info =&gt; log.info(format, args),</span>
<span class="line" id="L45">                .debug =&gt; log.debug(format, args),</span>
<span class="line" id="L46">            }</span>
<span class="line" id="L47">        }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L50">            self: *Self,</span>
<span class="line" id="L51">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L52">            ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L53">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L54">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L55">        ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L56">            <span class="tok-kw">const</span> result = self.parent_allocator.rawAlloc(len, ptr_align, len_align, ra);</span>
<span class="line" id="L57">            <span class="tok-kw">if</span> (result) |_| {</span>
<span class="line" id="L58">                logHelper(</span>
<span class="line" id="L59">                    success_log_level,</span>
<span class="line" id="L60">                    <span class="tok-str">&quot;alloc - success - len: {}, ptr_align: {}, len_align: {}&quot;</span>,</span>
<span class="line" id="L61">                    .{ len, ptr_align, len_align },</span>
<span class="line" id="L62">                );</span>
<span class="line" id="L63">            } <span class="tok-kw">else</span> |err| {</span>
<span class="line" id="L64">                logHelper(</span>
<span class="line" id="L65">                    failure_log_level,</span>
<span class="line" id="L66">                    <span class="tok-str">&quot;alloc - failure: {s} - len: {}, ptr_align: {}, len_align: {}&quot;</span>,</span>
<span class="line" id="L67">                    .{ <span class="tok-builtin">@errorName</span>(err), len, ptr_align, len_align },</span>
<span class="line" id="L68">                );</span>
<span class="line" id="L69">            }</span>
<span class="line" id="L70">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L71">        }</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">        <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L74">            self: *Self,</span>
<span class="line" id="L75">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L76">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L77">            new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L78">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L79">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L80">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L81">            <span class="tok-kw">if</span> (self.parent_allocator.rawResize(buf, buf_align, new_len, len_align, ra)) |resized_len| {</span>
<span class="line" id="L82">                <span class="tok-kw">if</span> (new_len &lt;= buf.len) {</span>
<span class="line" id="L83">                    logHelper(</span>
<span class="line" id="L84">                        success_log_level,</span>
<span class="line" id="L85">                        <span class="tok-str">&quot;shrink - success - {} to {}, len_align: {}, buf_align: {}&quot;</span>,</span>
<span class="line" id="L86">                        .{ buf.len, new_len, len_align, buf_align },</span>
<span class="line" id="L87">                    );</span>
<span class="line" id="L88">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L89">                    logHelper(</span>
<span class="line" id="L90">                        success_log_level,</span>
<span class="line" id="L91">                        <span class="tok-str">&quot;expand - success - {} to {}, len_align: {}, buf_align: {}&quot;</span>,</span>
<span class="line" id="L92">                        .{ buf.len, new_len, len_align, buf_align },</span>
<span class="line" id="L93">                    );</span>
<span class="line" id="L94">                }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">                <span class="tok-kw">return</span> resized_len;</span>
<span class="line" id="L97">            }</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">            std.debug.assert(new_len &gt; buf.len);</span>
<span class="line" id="L100">            logHelper(</span>
<span class="line" id="L101">                failure_log_level,</span>
<span class="line" id="L102">                <span class="tok-str">&quot;expand - failure - {} to {}, len_align: {}, buf_align: {}&quot;</span>,</span>
<span class="line" id="L103">                .{ buf.len, new_len, len_align, buf_align },</span>
<span class="line" id="L104">            );</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L109">            self: *Self,</span>
<span class="line" id="L110">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L111">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L112">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L113">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L114">            self.parent_allocator.rawFree(buf, buf_align, ra);</span>
<span class="line" id="L115">            logHelper(success_log_level, <span class="tok-str">&quot;free - len: {}&quot;</span>, .{buf.len});</span>
<span class="line" id="L116">        }</span>
<span class="line" id="L117">    };</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-comment">/// This allocator is used in front of another allocator and logs to `std.log`</span></span>
<span class="line" id="L121"><span class="tok-comment">/// on every call to the allocator.</span></span>
<span class="line" id="L122"><span class="tok-comment">/// For logging to a `std.io.Writer` see `std.heap.LogToWriterAllocator`</span></span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">loggingAllocator</span>(parent_allocator: Allocator) LoggingAllocator(.debug, .err) {</span>
<span class="line" id="L124">    <span class="tok-kw">return</span> LoggingAllocator(.debug, .err).init(parent_allocator);</span>
<span class="line" id="L125">}</span>
<span class="line" id="L126"></span>
</code></pre></body>
</html>