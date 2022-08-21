<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/fmt.zig - source view</title>
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
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// Print the string as a Zig identifier escaping it with @&quot;&quot; syntax if needed.</span></span>
<span class="line" id="L5"><span class="tok-kw">fn</span> <span class="tok-fn">formatId</span>(</span>
<span class="line" id="L6">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L7">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L8">    options: std.fmt.FormatOptions,</span>
<span class="line" id="L9">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L10">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L11">    _ = fmt;</span>
<span class="line" id="L12">    <span class="tok-kw">if</span> (isValidId(bytes)) {</span>
<span class="line" id="L13">        <span class="tok-kw">return</span> writer.writeAll(bytes);</span>
<span class="line" id="L14">    }</span>
<span class="line" id="L15">    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;@\&quot;&quot;</span>);</span>
<span class="line" id="L16">    <span class="tok-kw">try</span> formatEscapes(bytes, <span class="tok-str">&quot;&quot;</span>, options, writer);</span>
<span class="line" id="L17">    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L18">}</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// Return a Formatter for a Zig identifier</span></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtId</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatId) {</span>
<span class="line" id="L22">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L23">}</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isValidId</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">if</span> (bytes.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, bytes, <span class="tok-str">&quot;_&quot;</span>)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L28">    <span class="tok-kw">for</span> (bytes) |c, i| {</span>
<span class="line" id="L29">        <span class="tok-kw">switch</span> (c) {</span>
<span class="line" id="L30">            <span class="tok-str">'_'</span>, <span class="tok-str">'a'</span>...<span class="tok-str">'z'</span>, <span class="tok-str">'A'</span>...<span class="tok-str">'Z'</span> =&gt; {},</span>
<span class="line" id="L31">            <span class="tok-str">'0'</span>...<span class="tok-str">'9'</span> =&gt; <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L32">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">    }</span>
<span class="line" id="L35">    <span class="tok-kw">return</span> std.zig.Token.getKeyword(bytes) == <span class="tok-null">null</span>;</span>
<span class="line" id="L36">}</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-kw">test</span> <span class="tok-str">&quot;isValidId&quot;</span> {</span>
<span class="line" id="L39">    <span class="tok-kw">try</span> std.testing.expect(!isValidId(<span class="tok-str">&quot;&quot;</span>));</span>
<span class="line" id="L40">    <span class="tok-kw">try</span> std.testing.expect(isValidId(<span class="tok-str">&quot;foobar&quot;</span>));</span>
<span class="line" id="L41">    <span class="tok-kw">try</span> std.testing.expect(!isValidId(<span class="tok-str">&quot;a b c&quot;</span>));</span>
<span class="line" id="L42">    <span class="tok-kw">try</span> std.testing.expect(!isValidId(<span class="tok-str">&quot;3d&quot;</span>));</span>
<span class="line" id="L43">    <span class="tok-kw">try</span> std.testing.expect(!isValidId(<span class="tok-str">&quot;enum&quot;</span>));</span>
<span class="line" id="L44">    <span class="tok-kw">try</span> std.testing.expect(isValidId(<span class="tok-str">&quot;i386&quot;</span>));</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-comment">/// Print the string as escaped contents of a double quoted or single-quoted string.</span></span>
<span class="line" id="L48"><span class="tok-comment">/// Format `{}` treats contents as a double-quoted string.</span></span>
<span class="line" id="L49"><span class="tok-comment">/// Format `{'}` treats contents as a single-quoted string.</span></span>
<span class="line" id="L50"><span class="tok-kw">fn</span> <span class="tok-fn">formatEscapes</span>(</span>
<span class="line" id="L51">    bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L52">    <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L53">    options: std.fmt.FormatOptions,</span>
<span class="line" id="L54">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L55">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L56">    _ = options;</span>
<span class="line" id="L57">    <span class="tok-kw">for</span> (bytes) |byte| <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L58">        <span class="tok-str">'\n'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\n&quot;</span>),</span>
<span class="line" id="L59">        <span class="tok-str">'\r'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\r&quot;</span>),</span>
<span class="line" id="L60">        <span class="tok-str">'\t'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\t&quot;</span>),</span>
<span class="line" id="L61">        <span class="tok-str">'\\'</span> =&gt; <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\\\&quot;</span>),</span>
<span class="line" id="L62">        <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L63">            <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">1</span> <span class="tok-kw">and</span> fmt[<span class="tok-number">0</span>] == <span class="tok-str">'\''</span>) {</span>
<span class="line" id="L64">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L65">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L66">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\\&quot;&quot;</span>);</span>
<span class="line" id="L67">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L68">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected {} or {'}, found {&quot;</span> ++ fmt ++ <span class="tok-str">&quot;}&quot;</span>);</span>
<span class="line" id="L69">            }</span>
<span class="line" id="L70">        },</span>
<span class="line" id="L71">        <span class="tok-str">'\''</span> =&gt; {</span>
<span class="line" id="L72">            <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">1</span> <span class="tok-kw">and</span> fmt[<span class="tok-number">0</span>] == <span class="tok-str">'\''</span>) {</span>
<span class="line" id="L73">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\'&quot;</span>);</span>
<span class="line" id="L74">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L75">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\''</span>);</span>
<span class="line" id="L76">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L77">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected {} or {'}, found {&quot;</span> ++ fmt ++ <span class="tok-str">&quot;}&quot;</span>);</span>
<span class="line" id="L78">            }</span>
<span class="line" id="L79">        },</span>
<span class="line" id="L80">        <span class="tok-str">' '</span>, <span class="tok-str">'!'</span>, <span class="tok-str">'#'</span>...<span class="tok-str">'&amp;'</span>, <span class="tok-str">'('</span>...<span class="tok-str">'['</span>, <span class="tok-str">']'</span>...<span class="tok-str">'~'</span> =&gt; <span class="tok-kw">try</span> writer.writeByte(byte),</span>
<span class="line" id="L81">        <span class="tok-comment">// Use hex escapes for rest any unprintable characters.</span>
</span>
<span class="line" id="L82">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L83">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\\x&quot;</span>);</span>
<span class="line" id="L84">            <span class="tok-kw">try</span> std.fmt.formatInt(byte, <span class="tok-number">16</span>, .lower, .{ .width = <span class="tok-number">2</span>, .fill = <span class="tok-str">'0'</span> }, writer);</span>
<span class="line" id="L85">        },</span>
<span class="line" id="L86">    };</span>
<span class="line" id="L87">}</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-comment">/// Return a Formatter for Zig Escapes of a double quoted string.</span></span>
<span class="line" id="L90"><span class="tok-comment">/// The format specifier must be one of:</span></span>
<span class="line" id="L91"><span class="tok-comment">///  * `{}` treats contents as a double-quoted string.</span></span>
<span class="line" id="L92"><span class="tok-comment">///  * `{'}` treats contents as a single-quoted string.</span></span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fmtEscapes</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.fmt.Formatter(formatEscapes) {</span>
<span class="line" id="L94">    <span class="tok-kw">return</span> .{ .data = bytes };</span>
<span class="line" id="L95">}</span>
<span class="line" id="L96"></span>
<span class="line" id="L97"><span class="tok-kw">test</span> <span class="tok-str">&quot;escape invalid identifiers&quot;</span> {</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> expectFmt = std.testing.expectFmt;</span>
<span class="line" id="L99">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;@\&quot;while\&quot;&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtId(<span class="tok-str">&quot;while&quot;</span>)});</span>
<span class="line" id="L100">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;hello&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtId(<span class="tok-str">&quot;hello&quot;</span>)});</span>
<span class="line" id="L101">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;@\&quot;11\\\&quot;23\&quot;&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtId(<span class="tok-str">&quot;11\&quot;23&quot;</span>)});</span>
<span class="line" id="L102">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;@\&quot;11\\x0f23\&quot;&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtId(<span class="tok-str">&quot;11\x0F23&quot;</span>)});</span>
<span class="line" id="L103">    <span class="tok-kw">try</span> expectFmt(<span class="tok-str">&quot;\\x0f&quot;</span>, <span class="tok-str">&quot;{}&quot;</span>, .{fmtEscapes(<span class="tok-str">&quot;\x0f&quot;</span>)});</span>
<span class="line" id="L104">    <span class="tok-kw">try</span> expectFmt(</span>
<span class="line" id="L105">        <span class="tok-str">\\&quot; \\ hi \x07 \x11 &quot; derp \'&quot;</span></span>

<span class="line" id="L106">    , <span class="tok-str">&quot;\&quot;{'}\&quot;&quot;</span>, .{fmtEscapes(<span class="tok-str">&quot; \\ hi \x07 \x11 \&quot; derp '&quot;</span>)});</span>
<span class="line" id="L107">    <span class="tok-kw">try</span> expectFmt(</span>
<span class="line" id="L108">        <span class="tok-str">\\&quot; \\ hi \x07 \x11 \&quot; derp '&quot;</span></span>

<span class="line" id="L109">    , <span class="tok-str">&quot;\&quot;{}\&quot;&quot;</span>, .{fmtEscapes(<span class="tok-str">&quot; \\ hi \x07 \x11 \&quot; derp '&quot;</span>)});</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
</code></pre></body>
</html>