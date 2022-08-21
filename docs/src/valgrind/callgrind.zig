<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>valgrind/callgrind.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> valgrind = std.valgrind;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CallgrindClientRequest = <span class="tok-kw">enum</span>(<span class="tok-type">usize</span>) {</span>
<span class="line" id="L5">    DumpStats = valgrind.ToolBase(<span class="tok-str">&quot;CT&quot;</span>),</span>
<span class="line" id="L6">    ZeroStats,</span>
<span class="line" id="L7">    ToggleCollect,</span>
<span class="line" id="L8">    DumpStatsAt,</span>
<span class="line" id="L9">    StartInstrumentation,</span>
<span class="line" id="L10">    StopInstrumentation,</span>
<span class="line" id="L11">};</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">fn</span> <span class="tok-fn">doCallgrindClientRequestExpr</span>(default: <span class="tok-type">usize</span>, request: CallgrindClientRequest, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>, a4: <span class="tok-type">usize</span>, a5: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L14">    <span class="tok-kw">return</span> valgrind.doClientRequest(default, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@enumToInt</span>(request)), a1, a2, a3, a4, a5);</span>
<span class="line" id="L15">}</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">fn</span> <span class="tok-fn">doCallgrindClientRequestStmt</span>(request: CallgrindClientRequest, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>, a4: <span class="tok-type">usize</span>, a5: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L18">    _ = doCallgrindClientRequestExpr(<span class="tok-number">0</span>, request, a1, a2, a3, a4, a5);</span>
<span class="line" id="L19">}</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">/// Dump current state of cost centers, and zero them afterwards</span></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpStats</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L23">    doCallgrindClientRequestStmt(.DumpStats, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L24">}</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// Dump current state of cost centers, and zero them afterwards.</span></span>
<span class="line" id="L27"><span class="tok-comment">/// The argument is appended to a string stating the reason which triggered</span></span>
<span class="line" id="L28"><span class="tok-comment">/// the dump. This string is written as a description field into the</span></span>
<span class="line" id="L29"><span class="tok-comment">/// profile data dump.</span></span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dumpStatsAt</span>(pos_str: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L31">    doCallgrindClientRequestStmt(.DumpStatsAt, <span class="tok-builtin">@ptrToInt</span>(pos_str), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L32">}</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// Zero cost centers</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">zeroStats</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L36">    doCallgrindClientRequestStmt(.ZeroStats, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L37">}</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-comment">/// Toggles collection state.</span></span>
<span class="line" id="L40"><span class="tok-comment">/// The collection state specifies whether the happening of events</span></span>
<span class="line" id="L41"><span class="tok-comment">/// should be noted or if they are to be ignored. Events are noted</span></span>
<span class="line" id="L42"><span class="tok-comment">/// by increment of counters in a cost center</span></span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleCollect</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L44">    doCallgrindClientRequestStmt(.ToggleCollect, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-comment">/// Start full callgrind instrumentation if not already switched on.</span></span>
<span class="line" id="L48"><span class="tok-comment">/// When cache simulation is done, it will flush the simulated cache;</span></span>
<span class="line" id="L49"><span class="tok-comment">/// this will lead to an artificial cache warmup phase afterwards with</span></span>
<span class="line" id="L50"><span class="tok-comment">/// cache misses which would not have happened in reality.</span></span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">startInstrumentation</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L52">    doCallgrindClientRequestStmt(.StartInstrumentation, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L53">}</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-comment">/// Stop full callgrind instrumentation if not already switched off.</span></span>
<span class="line" id="L56"><span class="tok-comment">/// This flushes Valgrinds translation cache, and does no additional</span></span>
<span class="line" id="L57"><span class="tok-comment">/// instrumentation afterwards, which effectivly will run at the same</span></span>
<span class="line" id="L58"><span class="tok-comment">/// speed as the &quot;none&quot; tool (ie. at minimal slowdown).</span></span>
<span class="line" id="L59"><span class="tok-comment">/// Use this to bypass Callgrind aggregation for uninteresting code parts.</span></span>
<span class="line" id="L60"><span class="tok-comment">/// To start Callgrind in this mode to ignore the setup phase, use</span></span>
<span class="line" id="L61"><span class="tok-comment">/// the option &quot;--instr-atstart=no&quot;.</span></span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stopInstrumentation</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L63">    doCallgrindClientRequestStmt(.StopInstrumentation, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L64">}</span>
<span class="line" id="L65"></span>
</code></pre></body>
</html>