<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>testing.zig - source view</title>
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
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> print = std.debug.print;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FailingAllocator = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;testing/failing_allocator.zig&quot;</span>).FailingAllocator;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// This should only be used in temporary test programs.</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> allocator = allocator_instance.allocator();</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> allocator_instance = b: {</span>
<span class="line" id="L12">    <span class="tok-kw">if</span> (!builtin.is_test)</span>
<span class="line" id="L13">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot use testing allocator outside of test block&quot;</span>);</span>
<span class="line" id="L14">    <span class="tok-kw">break</span> :b std.heap.GeneralPurposeAllocator(.{}){};</span>
<span class="line" id="L15">};</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> failing_allocator = failing_allocator_instance.allocator();</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> failing_allocator_instance = FailingAllocator.init(base_allocator_instance.allocator(), <span class="tok-number">0</span>);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> base_allocator_instance = std.heap.FixedBufferAllocator.init(<span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-comment">/// TODO https://github.com/ziglang/zig/issues/5738</span></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> log_level = std.log.Level.warn;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// This is available to any test that wants to execute Zig in a child process.</span></span>
<span class="line" id="L26"><span class="tok-comment">/// It will be the same executable that is running `zig test`.</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> zig_exe_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// This function is intended to be used only in tests. It prints diagnostics to stderr</span></span>
<span class="line" id="L30"><span class="tok-comment">/// and then returns a test failure error when actual_error_union is not expected_error.</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectError</span>(expected_error: <span class="tok-type">anyerror</span>, actual_error_union: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L32">    <span class="tok-kw">if</span> (actual_error_union) |actual_payload| {</span>
<span class="line" id="L33">        std.debug.print(<span class="tok-str">&quot;expected error.{s}, found {any}\n&quot;</span>, .{ <span class="tok-builtin">@errorName</span>(expected_error), actual_payload });</span>
<span class="line" id="L34">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestUnexpectedError;</span>
<span class="line" id="L35">    } <span class="tok-kw">else</span> |actual_error| {</span>
<span class="line" id="L36">        <span class="tok-kw">if</span> (expected_error != actual_error) {</span>
<span class="line" id="L37">            std.debug.print(<span class="tok-str">&quot;expected error.{s}, found error.{s}\n&quot;</span>, .{</span>
<span class="line" id="L38">                <span class="tok-builtin">@errorName</span>(expected_error),</span>
<span class="line" id="L39">                <span class="tok-builtin">@errorName</span>(actual_error),</span>
<span class="line" id="L40">            });</span>
<span class="line" id="L41">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedError;</span>
<span class="line" id="L42">        }</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44">}</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-comment">/// This function is intended to be used only in tests. When the two values are not</span></span>
<span class="line" id="L47"><span class="tok-comment">/// equal, prints diagnostics to stderr to show exactly how they are not equal,</span></span>
<span class="line" id="L48"><span class="tok-comment">/// then returns a test failure error.</span></span>
<span class="line" id="L49"><span class="tok-comment">/// `actual` is casted to the type of `expected`.</span></span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectEqual</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L51">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(actual))) {</span>
<span class="line" id="L52">        .NoReturn,</span>
<span class="line" id="L53">        .BoundFn,</span>
<span class="line" id="L54">        .Opaque,</span>
<span class="line" id="L55">        .Frame,</span>
<span class="line" id="L56">        .AnyFrame,</span>
<span class="line" id="L57">        =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;value of type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(actual)) ++ <span class="tok-str">&quot; encountered&quot;</span>),</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">        .Undefined,</span>
<span class="line" id="L60">        .Null,</span>
<span class="line" id="L61">        .Void,</span>
<span class="line" id="L62">        =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">        .Type =&gt; {</span>
<span class="line" id="L65">            <span class="tok-kw">if</span> (actual != expected) {</span>
<span class="line" id="L66">                std.debug.print(<span class="tok-str">&quot;expected type {s}, found type {s}\n&quot;</span>, .{ <span class="tok-builtin">@typeName</span>(expected), <span class="tok-builtin">@typeName</span>(actual) });</span>
<span class="line" id="L67">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69">        },</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        .Bool,</span>
<span class="line" id="L72">        .Int,</span>
<span class="line" id="L73">        .Float,</span>
<span class="line" id="L74">        .ComptimeFloat,</span>
<span class="line" id="L75">        .ComptimeInt,</span>
<span class="line" id="L76">        .EnumLiteral,</span>
<span class="line" id="L77">        .Enum,</span>
<span class="line" id="L78">        .Fn,</span>
<span class="line" id="L79">        .ErrorSet,</span>
<span class="line" id="L80">        =&gt; {</span>
<span class="line" id="L81">            <span class="tok-kw">if</span> (actual != expected) {</span>
<span class="line" id="L82">                std.debug.print(<span class="tok-str">&quot;expected {}, found {}\n&quot;</span>, .{ expected, actual });</span>
<span class="line" id="L83">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L84">            }</span>
<span class="line" id="L85">        },</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        .Pointer =&gt; |pointer| {</span>
<span class="line" id="L88">            <span class="tok-kw">switch</span> (pointer.size) {</span>
<span class="line" id="L89">                .One, .Many, .C =&gt; {</span>
<span class="line" id="L90">                    <span class="tok-kw">if</span> (actual != expected) {</span>
<span class="line" id="L91">                        std.debug.print(<span class="tok-str">&quot;expected {*}, found {*}\n&quot;</span>, .{ expected, actual });</span>
<span class="line" id="L92">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L93">                    }</span>
<span class="line" id="L94">                },</span>
<span class="line" id="L95">                .Slice =&gt; {</span>
<span class="line" id="L96">                    <span class="tok-kw">if</span> (actual.ptr != expected.ptr) {</span>
<span class="line" id="L97">                        std.debug.print(<span class="tok-str">&quot;expected slice ptr {*}, found {*}\n&quot;</span>, .{ expected.ptr, actual.ptr });</span>
<span class="line" id="L98">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L99">                    }</span>
<span class="line" id="L100">                    <span class="tok-kw">if</span> (actual.len != expected.len) {</span>
<span class="line" id="L101">                        std.debug.print(<span class="tok-str">&quot;expected slice len {}, found {}\n&quot;</span>, .{ expected.len, actual.len });</span>
<span class="line" id="L102">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L103">                    }</span>
<span class="line" id="L104">                },</span>
<span class="line" id="L105">            }</span>
<span class="line" id="L106">        },</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        .Array =&gt; |array| <span class="tok-kw">try</span> expectEqualSlices(array.child, &amp;expected, &amp;actual),</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        .Vector =&gt; |info| {</span>
<span class="line" id="L111">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L112">            <span class="tok-kw">while</span> (i &lt; info.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L113">                <span class="tok-kw">if</span> (!std.meta.eql(expected[i], actual[i])) {</span>
<span class="line" id="L114">                    std.debug.print(<span class="tok-str">&quot;index {} incorrect. expected {}, found {}\n&quot;</span>, .{</span>
<span class="line" id="L115">                        i, expected[i], actual[i],</span>
<span class="line" id="L116">                    });</span>
<span class="line" id="L117">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L118">                }</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120">        },</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        .Struct =&gt; |structType| {</span>
<span class="line" id="L123">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (structType.fields) |field| {</span>
<span class="line" id="L124">                <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@field</span>(expected, field.name), <span class="tok-builtin">@field</span>(actual, field.name));</span>
<span class="line" id="L125">            }</span>
<span class="line" id="L126">        },</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        .Union =&gt; |union_info| {</span>
<span class="line" id="L129">            <span class="tok-kw">if</span> (union_info.tag_type == <span class="tok-null">null</span>) {</span>
<span class="line" id="L130">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to compare untagged union values&quot;</span>);</span>
<span class="line" id="L131">            }</span>
<span class="line" id="L132"></span>
<span class="line" id="L133">            <span class="tok-kw">const</span> Tag = std.meta.Tag(<span class="tok-builtin">@TypeOf</span>(expected));</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">            <span class="tok-kw">const</span> expectedTag = <span class="tok-builtin">@as</span>(Tag, expected);</span>
<span class="line" id="L136">            <span class="tok-kw">const</span> actualTag = <span class="tok-builtin">@as</span>(Tag, actual);</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">            <span class="tok-kw">try</span> expectEqual(expectedTag, actualTag);</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">            <span class="tok-comment">// we only reach this loop if the tags are equal</span>
</span>
<span class="line" id="L141">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (std.meta.fields(<span class="tok-builtin">@TypeOf</span>(actual))) |fld| {</span>
<span class="line" id="L142">                <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, fld.name, <span class="tok-builtin">@tagName</span>(actualTag))) {</span>
<span class="line" id="L143">                    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@field</span>(expected, fld.name), <span class="tok-builtin">@field</span>(actual, fld.name));</span>
<span class="line" id="L144">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L145">                }</span>
<span class="line" id="L146">            }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">            <span class="tok-comment">// we iterate over *all* union fields</span>
</span>
<span class="line" id="L149">            <span class="tok-comment">// =&gt; we should never get here as the loop above is</span>
</span>
<span class="line" id="L150">            <span class="tok-comment">//    including all possible values.</span>
</span>
<span class="line" id="L151">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L152">        },</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">        .Optional =&gt; {</span>
<span class="line" id="L155">            <span class="tok-kw">if</span> (expected) |expected_payload| {</span>
<span class="line" id="L156">                <span class="tok-kw">if</span> (actual) |actual_payload| {</span>
<span class="line" id="L157">                    <span class="tok-kw">try</span> expectEqual(expected_payload, actual_payload);</span>
<span class="line" id="L158">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L159">                    std.debug.print(<span class="tok-str">&quot;expected {any}, found null\n&quot;</span>, .{expected_payload});</span>
<span class="line" id="L160">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L161">                }</span>
<span class="line" id="L162">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L163">                <span class="tok-kw">if</span> (actual) |actual_payload| {</span>
<span class="line" id="L164">                    std.debug.print(<span class="tok-str">&quot;expected null, found {any}\n&quot;</span>, .{actual_payload});</span>
<span class="line" id="L165">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L166">                }</span>
<span class="line" id="L167">            }</span>
<span class="line" id="L168">        },</span>
<span class="line" id="L169"></span>
<span class="line" id="L170">        .ErrorUnion =&gt; {</span>
<span class="line" id="L171">            <span class="tok-kw">if</span> (expected) |expected_payload| {</span>
<span class="line" id="L172">                <span class="tok-kw">if</span> (actual) |actual_payload| {</span>
<span class="line" id="L173">                    <span class="tok-kw">try</span> expectEqual(expected_payload, actual_payload);</span>
<span class="line" id="L174">                } <span class="tok-kw">else</span> |actual_err| {</span>
<span class="line" id="L175">                    std.debug.print(<span class="tok-str">&quot;expected {any}, found {}\n&quot;</span>, .{ expected_payload, actual_err });</span>
<span class="line" id="L176">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L177">                }</span>
<span class="line" id="L178">            } <span class="tok-kw">else</span> |expected_err| {</span>
<span class="line" id="L179">                <span class="tok-kw">if</span> (actual) |actual_payload| {</span>
<span class="line" id="L180">                    std.debug.print(<span class="tok-str">&quot;expected {}, found {any}\n&quot;</span>, .{ expected_err, actual_payload });</span>
<span class="line" id="L181">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L182">                } <span class="tok-kw">else</span> |actual_err| {</span>
<span class="line" id="L183">                    <span class="tok-kw">try</span> expectEqual(expected_err, actual_err);</span>
<span class="line" id="L184">                }</span>
<span class="line" id="L185">            }</span>
<span class="line" id="L186">        },</span>
<span class="line" id="L187">    }</span>
<span class="line" id="L188">}</span>
<span class="line" id="L189"></span>
<span class="line" id="L190"><span class="tok-kw">test</span> <span class="tok-str">&quot;expectEqual.union(enum)&quot;</span> {</span>
<span class="line" id="L191">    <span class="tok-kw">const</span> T = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L192">        a: <span class="tok-type">i32</span>,</span>
<span class="line" id="L193">        b: <span class="tok-type">f32</span>,</span>
<span class="line" id="L194">    };</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    <span class="tok-kw">const</span> a10 = T{ .a = <span class="tok-number">10</span> };</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">    <span class="tok-kw">try</span> expectEqual(a10, a10);</span>
<span class="line" id="L199">}</span>
<span class="line" id="L200"></span>
<span class="line" id="L201"><span class="tok-comment">/// This function is intended to be used only in tests. When the formatted result of the template</span></span>
<span class="line" id="L202"><span class="tok-comment">/// and its arguments does not equal the expected text, it prints diagnostics to stderr to show how</span></span>
<span class="line" id="L203"><span class="tok-comment">/// they are not equal, then returns an error.</span></span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectFmt</span>(expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> template: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L205">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> std.fmt.allocPrint(allocator, template, args);</span>
<span class="line" id="L206">    <span class="tok-kw">defer</span> allocator.free(result);</span>
<span class="line" id="L207">    <span class="tok-kw">if</span> (std.mem.eql(<span class="tok-type">u8</span>, result, expected)) <span class="tok-kw">return</span>;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    print(<span class="tok-str">&quot;\n====== expected this output: =========\n&quot;</span>, .{});</span>
<span class="line" id="L210">    print(<span class="tok-str">&quot;{s}&quot;</span>, .{expected});</span>
<span class="line" id="L211">    print(<span class="tok-str">&quot;\n======== instead found this: =========\n&quot;</span>, .{});</span>
<span class="line" id="L212">    print(<span class="tok-str">&quot;{s}&quot;</span>, .{result});</span>
<span class="line" id="L213">    print(<span class="tok-str">&quot;\n======================================\n&quot;</span>, .{});</span>
<span class="line" id="L214">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedFmt;</span>
<span class="line" id="L215">}</span>
<span class="line" id="L216"></span>
<span class="line" id="L217"><span class="tok-comment">/// This function is intended to be used only in tests. When the actual value is</span></span>
<span class="line" id="L218"><span class="tok-comment">/// not approximately equal to the expected value, prints diagnostics to stderr</span></span>
<span class="line" id="L219"><span class="tok-comment">/// to show exactly how they are not equal, then returns a test failure error.</span></span>
<span class="line" id="L220"><span class="tok-comment">/// See `math.approxEqAbs` for more informations on the tolerance parameter.</span></span>
<span class="line" id="L221"><span class="tok-comment">/// The types must be floating point</span></span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectApproxEqAbs</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected), tolerance: <span class="tok-builtin">@TypeOf</span>(expected)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L223">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(expected);</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L226">        .Float =&gt; <span class="tok-kw">if</span> (!math.approxEqAbs(T, expected, actual, tolerance)) {</span>
<span class="line" id="L227">            std.debug.print(<span class="tok-str">&quot;actual {}, not within absolute tolerance {} of expected {}\n&quot;</span>, .{ actual, tolerance, expected });</span>
<span class="line" id="L228">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedApproxEqAbs;</span>
<span class="line" id="L229">        },</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">        .ComptimeFloat =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot approximately compare two comptime_float values&quot;</span>),</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to compare non floating point values&quot;</span>),</span>
<span class="line" id="L234">    }</span>
<span class="line" id="L235">}</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-kw">test</span> <span class="tok-str">&quot;expectApproxEqAbs&quot;</span> {</span>
<span class="line" id="L238">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L239">        <span class="tok-kw">const</span> pos_x: T = <span class="tok-number">12.0</span>;</span>
<span class="line" id="L240">        <span class="tok-kw">const</span> pos_y: T = <span class="tok-number">12.06</span>;</span>
<span class="line" id="L241">        <span class="tok-kw">const</span> neg_x: T = -<span class="tok-number">12.0</span>;</span>
<span class="line" id="L242">        <span class="tok-kw">const</span> neg_y: T = -<span class="tok-number">12.06</span>;</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">        <span class="tok-kw">try</span> expectApproxEqAbs(pos_x, pos_y, <span class="tok-number">0.1</span>);</span>
<span class="line" id="L245">        <span class="tok-kw">try</span> expectApproxEqAbs(neg_x, neg_y, <span class="tok-number">0.1</span>);</span>
<span class="line" id="L246">    }</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-comment">/// This function is intended to be used only in tests. When the actual value is</span></span>
<span class="line" id="L250"><span class="tok-comment">/// not approximately equal to the expected value, prints diagnostics to stderr</span></span>
<span class="line" id="L251"><span class="tok-comment">/// to show exactly how they are not equal, then returns a test failure error.</span></span>
<span class="line" id="L252"><span class="tok-comment">/// See `math.approxEqRel` for more informations on the tolerance parameter.</span></span>
<span class="line" id="L253"><span class="tok-comment">/// The types must be floating point</span></span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectApproxEqRel</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected), tolerance: <span class="tok-builtin">@TypeOf</span>(expected)) !<span class="tok-type">void</span> {</span>
<span class="line" id="L255">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(expected);</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L258">        .Float =&gt; <span class="tok-kw">if</span> (!math.approxEqRel(T, expected, actual, tolerance)) {</span>
<span class="line" id="L259">            std.debug.print(<span class="tok-str">&quot;actual {}, not within relative tolerance {} of expected {}\n&quot;</span>, .{ actual, tolerance, expected });</span>
<span class="line" id="L260">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedApproxEqRel;</span>
<span class="line" id="L261">        },</span>
<span class="line" id="L262"></span>
<span class="line" id="L263">        .ComptimeFloat =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot approximately compare two comptime_float values&quot;</span>),</span>
<span class="line" id="L264"></span>
<span class="line" id="L265">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unable to compare non floating point values&quot;</span>),</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267">}</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-kw">test</span> <span class="tok-str">&quot;expectApproxEqRel&quot;</span> {</span>
<span class="line" id="L270">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> ([_]<span class="tok-type">type</span>{ <span class="tok-type">f16</span>, <span class="tok-type">f32</span>, <span class="tok-type">f64</span>, <span class="tok-type">f128</span> }) |T| {</span>
<span class="line" id="L271">        <span class="tok-kw">const</span> eps_value = <span class="tok-kw">comptime</span> math.epsilon(T);</span>
<span class="line" id="L272">        <span class="tok-kw">const</span> sqrt_eps_value = <span class="tok-kw">comptime</span> <span class="tok-builtin">@sqrt</span>(eps_value);</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">        <span class="tok-kw">const</span> pos_x: T = <span class="tok-number">12.0</span>;</span>
<span class="line" id="L275">        <span class="tok-kw">const</span> pos_y: T = pos_x + <span class="tok-number">2</span> * eps_value;</span>
<span class="line" id="L276">        <span class="tok-kw">const</span> neg_x: T = -<span class="tok-number">12.0</span>;</span>
<span class="line" id="L277">        <span class="tok-kw">const</span> neg_y: T = neg_x - <span class="tok-number">2</span> * eps_value;</span>
<span class="line" id="L278"></span>
<span class="line" id="L279">        <span class="tok-kw">try</span> expectApproxEqRel(pos_x, pos_y, sqrt_eps_value);</span>
<span class="line" id="L280">        <span class="tok-kw">try</span> expectApproxEqRel(neg_x, neg_y, sqrt_eps_value);</span>
<span class="line" id="L281">    }</span>
<span class="line" id="L282">}</span>
<span class="line" id="L283"></span>
<span class="line" id="L284"><span class="tok-comment">/// This function is intended to be used only in tests. When the two slices are not</span></span>
<span class="line" id="L285"><span class="tok-comment">/// equal, prints diagnostics to stderr to show exactly how they are not equal,</span></span>
<span class="line" id="L286"><span class="tok-comment">/// then returns a test failure error.</span></span>
<span class="line" id="L287"><span class="tok-comment">/// If your inputs are UTF-8 encoded strings, consider calling `expectEqualStrings` instead.</span></span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectEqualSlices</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, expected: []<span class="tok-kw">const</span> T, actual: []<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L289">    <span class="tok-comment">// TODO better printing of the difference</span>
</span>
<span class="line" id="L290">    <span class="tok-comment">// If the arrays are small enough we could print the whole thing</span>
</span>
<span class="line" id="L291">    <span class="tok-comment">// If the child type is u8 and no weird bytes, we could print it as strings</span>
</span>
<span class="line" id="L292">    <span class="tok-comment">// Even for the length difference, it would be useful to see the values of the slices probably.</span>
</span>
<span class="line" id="L293">    <span class="tok-kw">if</span> (expected.len != actual.len) {</span>
<span class="line" id="L294">        std.debug.print(<span class="tok-str">&quot;slice lengths differ. expected {d}, found {d}\n&quot;</span>, .{ expected.len, actual.len });</span>
<span class="line" id="L295">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L296">    }</span>
<span class="line" id="L297">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L298">    <span class="tok-kw">while</span> (i &lt; expected.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L299">        <span class="tok-kw">if</span> (!std.meta.eql(expected[i], actual[i])) {</span>
<span class="line" id="L300">            std.debug.print(<span class="tok-str">&quot;index {} incorrect. expected {any}, found {any}\n&quot;</span>, .{ i, expected[i], actual[i] });</span>
<span class="line" id="L301">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L302">        }</span>
<span class="line" id="L303">    }</span>
<span class="line" id="L304">}</span>
<span class="line" id="L305"></span>
<span class="line" id="L306"><span class="tok-comment">/// This function is intended to be used only in tests. Checks that two slices or two arrays are equal,</span></span>
<span class="line" id="L307"><span class="tok-comment">/// including that their sentinel (if any) are the same. Will error if given another type.</span></span>
<span class="line" id="L308"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectEqualSentinel</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> sentinel: T, expected: [:sentinel]<span class="tok-kw">const</span> T, actual: [:sentinel]<span class="tok-kw">const</span> T) !<span class="tok-type">void</span> {</span>
<span class="line" id="L309">    <span class="tok-kw">try</span> expectEqualSlices(T, expected, actual);</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">    <span class="tok-kw">const</span> expected_value_sentinel = blk: {</span>
<span class="line" id="L312">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(expected))) {</span>
<span class="line" id="L313">            .Pointer =&gt; {</span>
<span class="line" id="L314">                <span class="tok-kw">break</span> :blk expected[expected.len];</span>
<span class="line" id="L315">            },</span>
<span class="line" id="L316">            .Array =&gt; |array_info| {</span>
<span class="line" id="L317">                <span class="tok-kw">const</span> indexable_outside_of_bounds = <span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> array_info.child, &amp;expected);</span>
<span class="line" id="L318">                <span class="tok-kw">break</span> :blk indexable_outside_of_bounds[indexable_outside_of_bounds.len];</span>
<span class="line" id="L319">            },</span>
<span class="line" id="L320">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L321">        }</span>
<span class="line" id="L322">    };</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    <span class="tok-kw">const</span> actual_value_sentinel = blk: {</span>
<span class="line" id="L325">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(actual))) {</span>
<span class="line" id="L326">            .Pointer =&gt; {</span>
<span class="line" id="L327">                <span class="tok-kw">break</span> :blk actual[actual.len];</span>
<span class="line" id="L328">            },</span>
<span class="line" id="L329">            .Array =&gt; |array_info| {</span>
<span class="line" id="L330">                <span class="tok-kw">const</span> indexable_outside_of_bounds = <span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> array_info.child, &amp;actual);</span>
<span class="line" id="L331">                <span class="tok-kw">break</span> :blk indexable_outside_of_bounds[indexable_outside_of_bounds.len];</span>
<span class="line" id="L332">            },</span>
<span class="line" id="L333">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L334">        }</span>
<span class="line" id="L335">    };</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">if</span> (!std.meta.eql(sentinel, expected_value_sentinel)) {</span>
<span class="line" id="L338">        std.debug.print(<span class="tok-str">&quot;expectEqualSentinel: 'expected' sentinel in memory is different from its type sentinel. type sentinel {}, in memory sentinel {}\n&quot;</span>, .{ sentinel, expected_value_sentinel });</span>
<span class="line" id="L339">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L340">    }</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-kw">if</span> (!std.meta.eql(sentinel, actual_value_sentinel)) {</span>
<span class="line" id="L343">        std.debug.print(<span class="tok-str">&quot;expectEqualSentinel: 'actual' sentinel in memory is different from its type sentinel. type sentinel {}, in memory sentinel {}\n&quot;</span>, .{ sentinel, actual_value_sentinel });</span>
<span class="line" id="L344">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L345">    }</span>
<span class="line" id="L346">}</span>
<span class="line" id="L347"></span>
<span class="line" id="L348"><span class="tok-comment">/// This function is intended to be used only in tests.</span></span>
<span class="line" id="L349"><span class="tok-comment">/// When `ok` is false, returns a test failure error.</span></span>
<span class="line" id="L350"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expect</span>(ok: <span class="tok-type">bool</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L351">    <span class="tok-kw">if</span> (!ok) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestUnexpectedResult;</span>
<span class="line" id="L352">}</span>
<span class="line" id="L353"></span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TmpDir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L355">    dir: std.fs.Dir,</span>
<span class="line" id="L356">    parent_dir: std.fs.Dir,</span>
<span class="line" id="L357">    sub_path: [sub_path_len]<span class="tok-type">u8</span>,</span>
<span class="line" id="L358"></span>
<span class="line" id="L359">    <span class="tok-kw">const</span> random_bytes_count = <span class="tok-number">12</span>;</span>
<span class="line" id="L360">    <span class="tok-kw">const</span> sub_path_len = std.fs.base64_encoder.calcSize(random_bytes_count);</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cleanup</span>(self: *TmpDir) <span class="tok-type">void</span> {</span>
<span class="line" id="L363">        self.dir.close();</span>
<span class="line" id="L364">        self.parent_dir.deleteTree(&amp;self.sub_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L365">        self.parent_dir.close();</span>
<span class="line" id="L366">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L367">    }</span>
<span class="line" id="L368">};</span>
<span class="line" id="L369"></span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TmpIterableDir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L371">    iterable_dir: std.fs.IterableDir,</span>
<span class="line" id="L372">    parent_dir: std.fs.Dir,</span>
<span class="line" id="L373">    sub_path: [sub_path_len]<span class="tok-type">u8</span>,</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">    <span class="tok-kw">const</span> random_bytes_count = <span class="tok-number">12</span>;</span>
<span class="line" id="L376">    <span class="tok-kw">const</span> sub_path_len = std.fs.base64_encoder.calcSize(random_bytes_count);</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cleanup</span>(self: *TmpIterableDir) <span class="tok-type">void</span> {</span>
<span class="line" id="L379">        self.iterable_dir.close();</span>
<span class="line" id="L380">        self.parent_dir.deleteTree(&amp;self.sub_path) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L381">        self.parent_dir.close();</span>
<span class="line" id="L382">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L383">    }</span>
<span class="line" id="L384">};</span>
<span class="line" id="L385"></span>
<span class="line" id="L386"><span class="tok-kw">fn</span> <span class="tok-fn">getCwdOrWasiPreopen</span>() std.fs.Dir {</span>
<span class="line" id="L387">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L388">        <span class="tok-kw">var</span> preopens = std.fs.wasi.PreopenList.init(allocator);</span>
<span class="line" id="L389">        <span class="tok-kw">defer</span> preopens.deinit();</span>
<span class="line" id="L390">        preopens.populate(<span class="tok-null">null</span>) <span class="tok-kw">catch</span></span>
<span class="line" id="L391">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to populate preopens&quot;</span>);</span>
<span class="line" id="L392">        <span class="tok-kw">const</span> preopen = preopens.find(std.fs.wasi.PreopenType{ .Dir = <span class="tok-str">&quot;.&quot;</span> }) <span class="tok-kw">orelse</span></span>
<span class="line" id="L393">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: didn't find '.' in the preopens&quot;</span>);</span>
<span class="line" id="L394"></span>
<span class="line" id="L395">        <span class="tok-kw">return</span> std.fs.Dir{ .fd = preopen.fd };</span>
<span class="line" id="L396">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L397">        <span class="tok-kw">return</span> std.fs.cwd();</span>
<span class="line" id="L398">    }</span>
<span class="line" id="L399">}</span>
<span class="line" id="L400"></span>
<span class="line" id="L401"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tmpDir</span>(opts: std.fs.Dir.OpenDirOptions) TmpDir {</span>
<span class="line" id="L402">    <span class="tok-kw">var</span> random_bytes: [TmpDir.random_bytes_count]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L403">    std.crypto.random.bytes(&amp;random_bytes);</span>
<span class="line" id="L404">    <span class="tok-kw">var</span> sub_path: [TmpDir.sub_path_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L405">    _ = std.fs.base64_encoder.encode(&amp;sub_path, &amp;random_bytes);</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">var</span> cwd = getCwdOrWasiPreopen();</span>
<span class="line" id="L408">    <span class="tok-kw">var</span> cache_dir = cwd.makeOpenPath(<span class="tok-str">&quot;zig-cache&quot;</span>, .{}) <span class="tok-kw">catch</span></span>
<span class="line" id="L409">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open zig-cache dir&quot;</span>);</span>
<span class="line" id="L410">    <span class="tok-kw">defer</span> cache_dir.close();</span>
<span class="line" id="L411">    <span class="tok-kw">var</span> parent_dir = cache_dir.makeOpenPath(<span class="tok-str">&quot;tmp&quot;</span>, .{}) <span class="tok-kw">catch</span></span>
<span class="line" id="L412">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open zig-cache/tmp dir&quot;</span>);</span>
<span class="line" id="L413">    <span class="tok-kw">var</span> dir = parent_dir.makeOpenPath(&amp;sub_path, opts) <span class="tok-kw">catch</span></span>
<span class="line" id="L414">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open the tmp dir&quot;</span>);</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L417">        .dir = dir,</span>
<span class="line" id="L418">        .parent_dir = parent_dir,</span>
<span class="line" id="L419">        .sub_path = sub_path,</span>
<span class="line" id="L420">    };</span>
<span class="line" id="L421">}</span>
<span class="line" id="L422"></span>
<span class="line" id="L423"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tmpIterableDir</span>(opts: std.fs.Dir.OpenDirOptions) TmpIterableDir {</span>
<span class="line" id="L424">    <span class="tok-kw">var</span> random_bytes: [TmpIterableDir.random_bytes_count]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L425">    std.crypto.random.bytes(&amp;random_bytes);</span>
<span class="line" id="L426">    <span class="tok-kw">var</span> sub_path: [TmpIterableDir.sub_path_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L427">    _ = std.fs.base64_encoder.encode(&amp;sub_path, &amp;random_bytes);</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">    <span class="tok-kw">var</span> cwd = getCwdOrWasiPreopen();</span>
<span class="line" id="L430">    <span class="tok-kw">var</span> cache_dir = cwd.makeOpenPath(<span class="tok-str">&quot;zig-cache&quot;</span>, .{}) <span class="tok-kw">catch</span></span>
<span class="line" id="L431">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open zig-cache dir&quot;</span>);</span>
<span class="line" id="L432">    <span class="tok-kw">defer</span> cache_dir.close();</span>
<span class="line" id="L433">    <span class="tok-kw">var</span> parent_dir = cache_dir.makeOpenPath(<span class="tok-str">&quot;tmp&quot;</span>, .{}) <span class="tok-kw">catch</span></span>
<span class="line" id="L434">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open zig-cache/tmp dir&quot;</span>);</span>
<span class="line" id="L435">    <span class="tok-kw">var</span> dir = parent_dir.makeOpenPathIterable(&amp;sub_path, opts) <span class="tok-kw">catch</span></span>
<span class="line" id="L436">        <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;unable to make tmp dir for testing: unable to make and open the tmp dir&quot;</span>);</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L439">        .iterable_dir = dir,</span>
<span class="line" id="L440">        .parent_dir = parent_dir,</span>
<span class="line" id="L441">        .sub_path = sub_path,</span>
<span class="line" id="L442">    };</span>
<span class="line" id="L443">}</span>
<span class="line" id="L444"></span>
<span class="line" id="L445"><span class="tok-kw">test</span> <span class="tok-str">&quot;expectEqual nested array&quot;</span> {</span>
<span class="line" id="L446">    <span class="tok-kw">const</span> a = [<span class="tok-number">2</span>][<span class="tok-number">2</span>]<span class="tok-type">f32</span>{</span>
<span class="line" id="L447">        [_]<span class="tok-type">f32</span>{ <span class="tok-number">1.0</span>, <span class="tok-number">0.0</span> },</span>
<span class="line" id="L448">        [_]<span class="tok-type">f32</span>{ <span class="tok-number">0.0</span>, <span class="tok-number">1.0</span> },</span>
<span class="line" id="L449">    };</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">    <span class="tok-kw">const</span> b = [<span class="tok-number">2</span>][<span class="tok-number">2</span>]<span class="tok-type">f32</span>{</span>
<span class="line" id="L452">        [_]<span class="tok-type">f32</span>{ <span class="tok-number">1.0</span>, <span class="tok-number">0.0</span> },</span>
<span class="line" id="L453">        [_]<span class="tok-type">f32</span>{ <span class="tok-number">0.0</span>, <span class="tok-number">1.0</span> },</span>
<span class="line" id="L454">    };</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-kw">try</span> expectEqual(a, b);</span>
<span class="line" id="L457">}</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-kw">test</span> <span class="tok-str">&quot;expectEqual vector&quot;</span> {</span>
<span class="line" id="L460">    <span class="tok-kw">var</span> a = <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L461">    <span class="tok-kw">var</span> b = <span class="tok-builtin">@splat</span>(<span class="tok-number">4</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>));</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">    <span class="tok-kw">try</span> expectEqual(a, b);</span>
<span class="line" id="L464">}</span>
<span class="line" id="L465"></span>
<span class="line" id="L466"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectEqualStrings</span>(expected: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, actual: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L467">    <span class="tok-kw">if</span> (std.mem.indexOfDiff(<span class="tok-type">u8</span>, actual, expected)) |diff_index| {</span>
<span class="line" id="L468">        print(<span class="tok-str">&quot;\n====== expected this output: =========\n&quot;</span>, .{});</span>
<span class="line" id="L469">        printWithVisibleNewlines(expected);</span>
<span class="line" id="L470">        print(<span class="tok-str">&quot;\n======== instead found this: =========\n&quot;</span>, .{});</span>
<span class="line" id="L471">        printWithVisibleNewlines(actual);</span>
<span class="line" id="L472">        print(<span class="tok-str">&quot;\n======================================\n&quot;</span>, .{});</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">        <span class="tok-kw">var</span> diff_line_number: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L475">        <span class="tok-kw">for</span> (expected[<span class="tok-number">0</span>..diff_index]) |value| {</span>
<span class="line" id="L476">            <span class="tok-kw">if</span> (value == <span class="tok-str">'\n'</span>) diff_line_number += <span class="tok-number">1</span>;</span>
<span class="line" id="L477">        }</span>
<span class="line" id="L478">        print(<span class="tok-str">&quot;First difference occurs on line {d}:\n&quot;</span>, .{diff_line_number});</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">        print(<span class="tok-str">&quot;expected:\n&quot;</span>, .{});</span>
<span class="line" id="L481">        printIndicatorLine(expected, diff_index);</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">        print(<span class="tok-str">&quot;found:\n&quot;</span>, .{});</span>
<span class="line" id="L484">        printIndicatorLine(actual, diff_index);</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEqual;</span>
<span class="line" id="L487">    }</span>
<span class="line" id="L488">}</span>
<span class="line" id="L489"></span>
<span class="line" id="L490"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectStringStartsWith</span>(actual: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_starts_with: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L491">    <span class="tok-kw">if</span> (std.mem.startsWith(<span class="tok-type">u8</span>, actual, expected_starts_with))</span>
<span class="line" id="L492">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-kw">const</span> shortened_actual = <span class="tok-kw">if</span> (actual.len &gt;= expected_starts_with.len)</span>
<span class="line" id="L495">        actual[<span class="tok-number">0</span>..expected_starts_with.len]</span>
<span class="line" id="L496">    <span class="tok-kw">else</span></span>
<span class="line" id="L497">        actual;</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">    print(<span class="tok-str">&quot;\n====== expected to start with: =========\n&quot;</span>, .{});</span>
<span class="line" id="L500">    printWithVisibleNewlines(expected_starts_with);</span>
<span class="line" id="L501">    print(<span class="tok-str">&quot;\n====== instead ended with: ===========\n&quot;</span>, .{});</span>
<span class="line" id="L502">    printWithVisibleNewlines(shortened_actual);</span>
<span class="line" id="L503">    print(<span class="tok-str">&quot;\n========= full output: ==============\n&quot;</span>, .{});</span>
<span class="line" id="L504">    printWithVisibleNewlines(actual);</span>
<span class="line" id="L505">    print(<span class="tok-str">&quot;\n======================================\n&quot;</span>, .{});</span>
<span class="line" id="L506"></span>
<span class="line" id="L507">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedStartsWith;</span>
<span class="line" id="L508">}</span>
<span class="line" id="L509"></span>
<span class="line" id="L510"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expectStringEndsWith</span>(actual: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_ends_with: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L511">    <span class="tok-kw">if</span> (std.mem.endsWith(<span class="tok-type">u8</span>, actual, expected_ends_with))</span>
<span class="line" id="L512">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">    <span class="tok-kw">const</span> shortened_actual = <span class="tok-kw">if</span> (actual.len &gt;= expected_ends_with.len)</span>
<span class="line" id="L515">        actual[(actual.len - expected_ends_with.len)..]</span>
<span class="line" id="L516">    <span class="tok-kw">else</span></span>
<span class="line" id="L517">        actual;</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">    print(<span class="tok-str">&quot;\n====== expected to end with: =========\n&quot;</span>, .{});</span>
<span class="line" id="L520">    printWithVisibleNewlines(expected_ends_with);</span>
<span class="line" id="L521">    print(<span class="tok-str">&quot;\n====== instead ended with: ===========\n&quot;</span>, .{});</span>
<span class="line" id="L522">    printWithVisibleNewlines(shortened_actual);</span>
<span class="line" id="L523">    print(<span class="tok-str">&quot;\n========= full output: ==============\n&quot;</span>, .{});</span>
<span class="line" id="L524">    printWithVisibleNewlines(actual);</span>
<span class="line" id="L525">    print(<span class="tok-str">&quot;\n======================================\n&quot;</span>, .{});</span>
<span class="line" id="L526"></span>
<span class="line" id="L527">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestExpectedEndsWith;</span>
<span class="line" id="L528">}</span>
<span class="line" id="L529"></span>
<span class="line" id="L530"><span class="tok-kw">fn</span> <span class="tok-fn">printIndicatorLine</span>(source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, indicator_index: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L531">    <span class="tok-kw">const</span> line_begin_index = <span class="tok-kw">if</span> (std.mem.lastIndexOfScalar(<span class="tok-type">u8</span>, source[<span class="tok-number">0</span>..indicator_index], <span class="tok-str">'\n'</span>)) |line_begin|</span>
<span class="line" id="L532">        line_begin + <span class="tok-number">1</span></span>
<span class="line" id="L533">    <span class="tok-kw">else</span></span>
<span class="line" id="L534">        <span class="tok-number">0</span>;</span>
<span class="line" id="L535">    <span class="tok-kw">const</span> line_end_index = <span class="tok-kw">if</span> (std.mem.indexOfScalar(<span class="tok-type">u8</span>, source[indicator_index..], <span class="tok-str">'\n'</span>)) |line_end|</span>
<span class="line" id="L536">        (indicator_index + line_end)</span>
<span class="line" id="L537">    <span class="tok-kw">else</span></span>
<span class="line" id="L538">        source.len;</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">    printLine(source[line_begin_index..line_end_index]);</span>
<span class="line" id="L541">    {</span>
<span class="line" id="L542">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = line_begin_index;</span>
<span class="line" id="L543">        <span class="tok-kw">while</span> (i &lt; indicator_index) : (i += <span class="tok-number">1</span>)</span>
<span class="line" id="L544">            print(<span class="tok-str">&quot; &quot;</span>, .{});</span>
<span class="line" id="L545">    }</span>
<span class="line" id="L546">    <span class="tok-kw">if</span> (indicator_index &gt;= source.len)</span>
<span class="line" id="L547">        print(<span class="tok-str">&quot;^ (end of string)\n&quot;</span>, .{})</span>
<span class="line" id="L548">    <span class="tok-kw">else</span></span>
<span class="line" id="L549">        print(<span class="tok-str">&quot;^ ('\\x{x:0&gt;2}')\n&quot;</span>, .{source[indicator_index]});</span>
<span class="line" id="L550">}</span>
<span class="line" id="L551"></span>
<span class="line" id="L552"><span class="tok-kw">fn</span> <span class="tok-fn">printWithVisibleNewlines</span>(source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L553">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L554">    <span class="tok-kw">while</span> (std.mem.indexOfScalar(<span class="tok-type">u8</span>, source[i..], <span class="tok-str">'\n'</span>)) |nl| : (i += nl + <span class="tok-number">1</span>) {</span>
<span class="line" id="L555">        printLine(source[i .. i + nl]);</span>
<span class="line" id="L556">    }</span>
<span class="line" id="L557">    print(<span class="tok-str">&quot;{s}␃\n&quot;</span>, .{source[i..]}); <span class="tok-comment">// End of Text symbol (ETX)</span>
</span>
<span class="line" id="L558">}</span>
<span class="line" id="L559"></span>
<span class="line" id="L560"><span class="tok-kw">fn</span> <span class="tok-fn">printLine</span>(line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L561">    <span class="tok-kw">if</span> (line.len != <span class="tok-number">0</span>) <span class="tok-kw">switch</span> (line[line.len - <span class="tok-number">1</span>]) {</span>
<span class="line" id="L562">        <span class="tok-str">' '</span>, <span class="tok-str">'\t'</span> =&gt; <span class="tok-kw">return</span> print(<span class="tok-str">&quot;{s}⏎\n&quot;</span>, .{line}), <span class="tok-comment">// Carriage return symbol,</span>
</span>
<span class="line" id="L563">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L564">    };</span>
<span class="line" id="L565">    print(<span class="tok-str">&quot;{s}\n&quot;</span>, .{line});</span>
<span class="line" id="L566">}</span>
<span class="line" id="L567"></span>
<span class="line" id="L568"><span class="tok-kw">test</span> {</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> expectEqualStrings(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;foo&quot;</span>);</span>
<span class="line" id="L570">}</span>
<span class="line" id="L571"></span>
<span class="line" id="L572"><span class="tok-comment">/// Exhaustively check that allocation failures within `test_fn` are handled without</span></span>
<span class="line" id="L573"><span class="tok-comment">/// introducing memory leaks. If used with the `testing.allocator` as the `backing_allocator`,</span></span>
<span class="line" id="L574"><span class="tok-comment">/// it will also be able to detect double frees, etc (when runtime safety is enabled).</span></span>
<span class="line" id="L575"><span class="tok-comment">///</span></span>
<span class="line" id="L576"><span class="tok-comment">/// The provided `test_fn` must have a `std.mem.Allocator` as its first argument,</span></span>
<span class="line" id="L577"><span class="tok-comment">/// and must have a return type of `!void`. Any extra arguments of `test_fn` can</span></span>
<span class="line" id="L578"><span class="tok-comment">/// be provided via the `extra_args` tuple.</span></span>
<span class="line" id="L579"><span class="tok-comment">///</span></span>
<span class="line" id="L580"><span class="tok-comment">/// Any relevant state shared between runs of `test_fn` *must* be reset within `test_fn`.</span></span>
<span class="line" id="L581"><span class="tok-comment">///</span></span>
<span class="line" id="L582"><span class="tok-comment">/// The strategy employed is to:</span></span>
<span class="line" id="L583"><span class="tok-comment">/// - Run the test function once to get the total number of allocations.</span></span>
<span class="line" id="L584"><span class="tok-comment">/// - Then, iterate and run the function X more times, incrementing</span></span>
<span class="line" id="L585"><span class="tok-comment">///   the failing index each iteration (where X is the total number of</span></span>
<span class="line" id="L586"><span class="tok-comment">///   allocations determined previously)</span></span>
<span class="line" id="L587"><span class="tok-comment">///</span></span>
<span class="line" id="L588"><span class="tok-comment">/// Expects that `test_fn` has a deterministic number of memory allocations:</span></span>
<span class="line" id="L589"><span class="tok-comment">/// - If an allocation was made to fail during a run of `test_fn`, but `test_fn`</span></span>
<span class="line" id="L590"><span class="tok-comment">///   didn't return `error.OutOfMemory`, then `error.SwallowedOutOfMemoryError`</span></span>
<span class="line" id="L591"><span class="tok-comment">///   is returned from `checkAllAllocationFailures`. You may want to ignore this</span></span>
<span class="line" id="L592"><span class="tok-comment">///   depending on whether or not the code you're testing includes some strategies</span></span>
<span class="line" id="L593"><span class="tok-comment">///   for recovering from `error.OutOfMemory`.</span></span>
<span class="line" id="L594"><span class="tok-comment">/// - If a run of `test_fn` with an expected allocation failure executes without</span></span>
<span class="line" id="L595"><span class="tok-comment">///   an allocation failure being induced, then `error.NondeterministicMemoryUsage`</span></span>
<span class="line" id="L596"><span class="tok-comment">///   is returned. This error means that there are allocation points that won't be</span></span>
<span class="line" id="L597"><span class="tok-comment">///   tested by the strategy this function employs (that is, there are sometimes more</span></span>
<span class="line" id="L598"><span class="tok-comment">///   points of allocation than the initial run of `test_fn` detects).</span></span>
<span class="line" id="L599"><span class="tok-comment">///</span></span>
<span class="line" id="L600"><span class="tok-comment">/// ---</span></span>
<span class="line" id="L601"><span class="tok-comment">///</span></span>
<span class="line" id="L602"><span class="tok-comment">/// Here's an example using a simple test case that will cause a leak when the</span></span>
<span class="line" id="L603"><span class="tok-comment">/// allocation of `bar` fails (but will pass normally):</span></span>
<span class="line" id="L604"><span class="tok-comment">///</span></span>
<span class="line" id="L605"><span class="tok-comment">/// ```zig</span></span>
<span class="line" id="L606"><span class="tok-comment">/// test {</span></span>
<span class="line" id="L607"><span class="tok-comment">///     const length: usize = 10;</span></span>
<span class="line" id="L608"><span class="tok-comment">///     const allocator = std.testing.allocator;</span></span>
<span class="line" id="L609"><span class="tok-comment">///     var foo = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L610"><span class="tok-comment">///     var bar = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L611"><span class="tok-comment">///</span></span>
<span class="line" id="L612"><span class="tok-comment">///     allocator.free(foo);</span></span>
<span class="line" id="L613"><span class="tok-comment">///     allocator.free(bar);</span></span>
<span class="line" id="L614"><span class="tok-comment">/// }</span></span>
<span class="line" id="L615"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L616"><span class="tok-comment">///</span></span>
<span class="line" id="L617"><span class="tok-comment">/// The test case can be converted to something that this function can use by</span></span>
<span class="line" id="L618"><span class="tok-comment">/// doing:</span></span>
<span class="line" id="L619"><span class="tok-comment">///</span></span>
<span class="line" id="L620"><span class="tok-comment">/// ```zig</span></span>
<span class="line" id="L621"><span class="tok-comment">/// fn testImpl(allocator: std.mem.Allocator, length: usize) !void {</span></span>
<span class="line" id="L622"><span class="tok-comment">///     var foo = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L623"><span class="tok-comment">///     var bar = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L624"><span class="tok-comment">///</span></span>
<span class="line" id="L625"><span class="tok-comment">///     allocator.free(foo);</span></span>
<span class="line" id="L626"><span class="tok-comment">///     allocator.free(bar);</span></span>
<span class="line" id="L627"><span class="tok-comment">/// }</span></span>
<span class="line" id="L628"><span class="tok-comment">///</span></span>
<span class="line" id="L629"><span class="tok-comment">/// test {</span></span>
<span class="line" id="L630"><span class="tok-comment">///     const length: usize = 10;</span></span>
<span class="line" id="L631"><span class="tok-comment">///     const allocator = std.testing.allocator;</span></span>
<span class="line" id="L632"><span class="tok-comment">///     try std.testing.checkAllAllocationFailures(allocator, testImpl, .{length});</span></span>
<span class="line" id="L633"><span class="tok-comment">/// }</span></span>
<span class="line" id="L634"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L635"><span class="tok-comment">///</span></span>
<span class="line" id="L636"><span class="tok-comment">/// Running this test will show that `foo` is leaked when the allocation of</span></span>
<span class="line" id="L637"><span class="tok-comment">/// `bar` fails. The simplest fix, in this case, would be to use defer like so:</span></span>
<span class="line" id="L638"><span class="tok-comment">///</span></span>
<span class="line" id="L639"><span class="tok-comment">/// ```zig</span></span>
<span class="line" id="L640"><span class="tok-comment">/// fn testImpl(allocator: std.mem.Allocator, length: usize) !void {</span></span>
<span class="line" id="L641"><span class="tok-comment">///     var foo = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L642"><span class="tok-comment">///     defer allocator.free(foo);</span></span>
<span class="line" id="L643"><span class="tok-comment">///     var bar = try allocator.alloc(u8, length);</span></span>
<span class="line" id="L644"><span class="tok-comment">///     defer allocator.free(bar);</span></span>
<span class="line" id="L645"><span class="tok-comment">/// }</span></span>
<span class="line" id="L646"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L647"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkAllAllocationFailures</span>(backing_allocator: std.mem.Allocator, <span class="tok-kw">comptime</span> test_fn: <span class="tok-kw">anytype</span>, extra_args: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L648">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(test_fn)).Fn.return_type.?)) {</span>
<span class="line" id="L649">        .ErrorUnion =&gt; |info| {</span>
<span class="line" id="L650">            <span class="tok-kw">if</span> (info.payload != <span class="tok-type">void</span>) {</span>
<span class="line" id="L651">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Return type must be !void&quot;</span>);</span>
<span class="line" id="L652">            }</span>
<span class="line" id="L653">        },</span>
<span class="line" id="L654">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Return type must be !void&quot;</span>),</span>
<span class="line" id="L655">    }</span>
<span class="line" id="L656">    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(extra_args)) != .Struct) {</span>
<span class="line" id="L657">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Expected tuple or struct argument, found &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(extra_args)));</span>
<span class="line" id="L658">    }</span>
<span class="line" id="L659"></span>
<span class="line" id="L660">    <span class="tok-kw">const</span> ArgsTuple = std.meta.ArgsTuple(<span class="tok-builtin">@TypeOf</span>(test_fn));</span>
<span class="line" id="L661">    <span class="tok-kw">const</span> fn_args_fields = <span class="tok-builtin">@typeInfo</span>(ArgsTuple).Struct.fields;</span>
<span class="line" id="L662">    <span class="tok-kw">if</span> (fn_args_fields.len == <span class="tok-number">0</span> <span class="tok-kw">or</span> fn_args_fields[<span class="tok-number">0</span>].field_type != std.mem.Allocator) {</span>
<span class="line" id="L663">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The provided function must have an &quot;</span> ++ <span class="tok-builtin">@typeName</span>(std.mem.Allocator) ++ <span class="tok-str">&quot; as its first argument&quot;</span>);</span>
<span class="line" id="L664">    }</span>
<span class="line" id="L665">    <span class="tok-kw">const</span> expected_args_tuple_len = fn_args_fields.len - <span class="tok-number">1</span>;</span>
<span class="line" id="L666">    <span class="tok-kw">if</span> (extra_args.len != expected_args_tuple_len) {</span>
<span class="line" id="L667">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;The provided function expects &quot;</span> ++ (<span class="tok-kw">comptime</span> std.fmt.comptimePrint(<span class="tok-str">&quot;{d}&quot;</span>, .{expected_args_tuple_len})) ++ <span class="tok-str">&quot; extra arguments, but the provided tuple contains &quot;</span> ++ (<span class="tok-kw">comptime</span> std.fmt.comptimePrint(<span class="tok-str">&quot;{d}&quot;</span>, .{extra_args.len})));</span>
<span class="line" id="L668">    }</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    <span class="tok-comment">// Setup the tuple that will actually be used with @call (we'll need to insert</span>
</span>
<span class="line" id="L671">    <span class="tok-comment">// the failing allocator in field @&quot;0&quot; before each @call)</span>
</span>
<span class="line" id="L672">    <span class="tok-kw">var</span> args: ArgsTuple = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L673">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(extra_args)).Struct.fields) |field, i| {</span>
<span class="line" id="L674">        <span class="tok-kw">const</span> arg_i_str = <span class="tok-kw">comptime</span> str: {</span>
<span class="line" id="L675">            <span class="tok-kw">var</span> str_buf: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L676">            <span class="tok-kw">const</span> args_i = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L677">            <span class="tok-kw">const</span> str_len = std.fmt.formatIntBuf(&amp;str_buf, args_i, <span class="tok-number">10</span>, .lower, .{});</span>
<span class="line" id="L678">            <span class="tok-kw">break</span> :str str_buf[<span class="tok-number">0</span>..str_len];</span>
<span class="line" id="L679">        };</span>
<span class="line" id="L680">        <span class="tok-builtin">@field</span>(args, arg_i_str) = <span class="tok-builtin">@field</span>(extra_args, field.name);</span>
<span class="line" id="L681">    }</span>
<span class="line" id="L682"></span>
<span class="line" id="L683">    <span class="tok-comment">// Try it once with unlimited memory, make sure it works</span>
</span>
<span class="line" id="L684">    <span class="tok-kw">const</span> needed_alloc_count = x: {</span>
<span class="line" id="L685">        <span class="tok-kw">var</span> failing_allocator_inst = std.testing.FailingAllocator.init(backing_allocator, std.math.maxInt(<span class="tok-type">usize</span>));</span>
<span class="line" id="L686">        args.@&quot;0&quot; = failing_allocator_inst.allocator();</span>
<span class="line" id="L687"></span>
<span class="line" id="L688">        <span class="tok-kw">try</span> <span class="tok-builtin">@call</span>(.{}, test_fn, args);</span>
<span class="line" id="L689">        <span class="tok-kw">break</span> :x failing_allocator_inst.index;</span>
<span class="line" id="L690">    };</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">    <span class="tok-kw">var</span> fail_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L693">    <span class="tok-kw">while</span> (fail_index &lt; needed_alloc_count) : (fail_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L694">        <span class="tok-kw">var</span> failing_allocator_inst = std.testing.FailingAllocator.init(backing_allocator, fail_index);</span>
<span class="line" id="L695">        args.@&quot;0&quot; = failing_allocator_inst.allocator();</span>
<span class="line" id="L696"></span>
<span class="line" id="L697">        <span class="tok-kw">if</span> (<span class="tok-builtin">@call</span>(.{}, test_fn, args)) |_| {</span>
<span class="line" id="L698">            <span class="tok-kw">if</span> (failing_allocator_inst.has_induced_failure) {</span>
<span class="line" id="L699">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SwallowedOutOfMemoryError;</span>
<span class="line" id="L700">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L701">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NondeterministicMemoryUsage;</span>
<span class="line" id="L702">            }</span>
<span class="line" id="L703">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L704">            <span class="tok-kw">error</span>.OutOfMemory =&gt; {</span>
<span class="line" id="L705">                <span class="tok-kw">if</span> (failing_allocator_inst.allocated_bytes != failing_allocator_inst.freed_bytes) {</span>
<span class="line" id="L706">                    print(</span>
<span class="line" id="L707">                        <span class="tok-str">&quot;\nfail_index: {d}/{d}\nallocated bytes: {d}\nfreed bytes: {d}\nallocations: {d}\ndeallocations: {d}\nallocation that was made to fail: {s}&quot;</span>,</span>
<span class="line" id="L708">                        .{</span>
<span class="line" id="L709">                            fail_index,</span>
<span class="line" id="L710">                            needed_alloc_count,</span>
<span class="line" id="L711">                            failing_allocator_inst.allocated_bytes,</span>
<span class="line" id="L712">                            failing_allocator_inst.freed_bytes,</span>
<span class="line" id="L713">                            failing_allocator_inst.allocations,</span>
<span class="line" id="L714">                            failing_allocator_inst.deallocations,</span>
<span class="line" id="L715">                            failing_allocator_inst.getStackTrace(),</span>
<span class="line" id="L716">                        },</span>
<span class="line" id="L717">                    );</span>
<span class="line" id="L718">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MemoryLeakDetected;</span>
<span class="line" id="L719">                }</span>
<span class="line" id="L720">            },</span>
<span class="line" id="L721">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L722">        }</span>
<span class="line" id="L723">    }</span>
<span class="line" id="L724">}</span>
<span class="line" id="L725"></span>
<span class="line" id="L726"><span class="tok-comment">/// Given a type, reference all the declarations inside, so that the semantic analyzer sees them.</span></span>
<span class="line" id="L727"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">refAllDecls</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L728">    <span class="tok-kw">if</span> (!builtin.is_test) <span class="tok-kw">return</span>;</span>
<span class="line" id="L729">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> std.meta.declarations(T)) |decl| {</span>
<span class="line" id="L730">        <span class="tok-kw">if</span> (decl.is_pub) _ = <span class="tok-builtin">@field</span>(T, decl.name);</span>
<span class="line" id="L731">    }</span>
<span class="line" id="L732">}</span>
<span class="line" id="L733"></span>
<span class="line" id="L734"><span class="tok-comment">/// Given a type, and Recursively reference all the declarations inside, so that the semantic analyzer sees them.</span></span>
<span class="line" id="L735"><span class="tok-comment">/// For deep types, you may use `@setEvalBranchQuota`</span></span>
<span class="line" id="L736"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">refAllDeclsRecursive</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L737">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-kw">comptime</span> std.meta.declarations(T)) |decl| {</span>
<span class="line" id="L738">        <span class="tok-kw">if</span> (decl.is_pub) {</span>
<span class="line" id="L739">            <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(<span class="tok-builtin">@field</span>(T, decl.name)) == <span class="tok-type">type</span>) {</span>
<span class="line" id="L740">                <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@field</span>(T, decl.name))) {</span>
<span class="line" id="L741">                    .Struct, .Enum, .Union, .Opaque =&gt; refAllDeclsRecursive(<span class="tok-builtin">@field</span>(T, decl.name)),</span>
<span class="line" id="L742">                    <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L743">                }</span>
<span class="line" id="L744">            }</span>
<span class="line" id="L745">            _ = <span class="tok-builtin">@field</span>(T, decl.name);</span>
<span class="line" id="L746">        }</span>
<span class="line" id="L747">    }</span>
<span class="line" id="L748">}</span>
<span class="line" id="L749"></span>
</code></pre></body>
</html>