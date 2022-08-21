<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>time.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> epoch = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;time/epoch.zig&quot;</span>);</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-comment">/// Spurious wakeups are possible and no precision of timing is guaranteed.</span></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sleep</span>(nanoseconds: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L12">    <span class="tok-comment">// TODO: opting out of async sleeping?</span>
</span>
<span class="line" id="L13">    <span class="tok-kw">if</span> (std.io.is_async) {</span>
<span class="line" id="L14">        <span class="tok-kw">return</span> std.event.Loop.instance.?.sleep(nanoseconds);</span>
<span class="line" id="L15">    }</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L18">        <span class="tok-kw">const</span> big_ms_from_ns = nanoseconds / ns_per_ms;</span>
<span class="line" id="L19">        <span class="tok-kw">const</span> ms = math.cast(os.windows.DWORD, big_ms_from_ns) <span class="tok-kw">orelse</span> math.maxInt(os.windows.DWORD);</span>
<span class="line" id="L20">        os.windows.kernel32.Sleep(ms);</span>
<span class="line" id="L21">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L25">        <span class="tok-kw">const</span> w = std.os.wasi;</span>
<span class="line" id="L26">        <span class="tok-kw">const</span> userdata: w.userdata_t = <span class="tok-number">0x0123_45678</span>;</span>
<span class="line" id="L27">        <span class="tok-kw">const</span> clock = w.subscription_clock_t{</span>
<span class="line" id="L28">            .id = w.CLOCK.MONOTONIC,</span>
<span class="line" id="L29">            .timeout = nanoseconds,</span>
<span class="line" id="L30">            .precision = <span class="tok-number">0</span>,</span>
<span class="line" id="L31">            .flags = <span class="tok-number">0</span>,</span>
<span class="line" id="L32">        };</span>
<span class="line" id="L33">        <span class="tok-kw">const</span> in = w.subscription_t{</span>
<span class="line" id="L34">            .userdata = userdata,</span>
<span class="line" id="L35">            .u = w.subscription_u_t{</span>
<span class="line" id="L36">                .tag = w.EVENTTYPE_CLOCK,</span>
<span class="line" id="L37">                .u = w.subscription_u_u_t{</span>
<span class="line" id="L38">                    .clock = clock,</span>
<span class="line" id="L39">                },</span>
<span class="line" id="L40">            },</span>
<span class="line" id="L41">        };</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-kw">var</span> event: w.event_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L44">        <span class="tok-kw">var</span> nevents: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L45">        _ = w.poll_oneoff(&amp;in, &amp;event, <span class="tok-number">1</span>, &amp;nevents);</span>
<span class="line" id="L46">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L47">    }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-kw">const</span> s = nanoseconds / ns_per_s;</span>
<span class="line" id="L50">    <span class="tok-kw">const</span> ns = nanoseconds % ns_per_s;</span>
<span class="line" id="L51">    std.os.nanosleep(s, ns);</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-kw">test</span> <span class="tok-str">&quot;sleep&quot;</span> {</span>
<span class="line" id="L55">    sleep(<span class="tok-number">1</span>);</span>
<span class="line" id="L56">}</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-comment">/// Get a calendar timestamp, in seconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L59"><span class="tok-comment">/// Precision of timing depends on the hardware and operating system.</span></span>
<span class="line" id="L60"><span class="tok-comment">/// The return value is signed because it is possible to have a date that is</span></span>
<span class="line" id="L61"><span class="tok-comment">/// before the epoch.</span></span>
<span class="line" id="L62"><span class="tok-comment">/// See `std.os.clock_gettime` for a POSIX timestamp.</span></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">timestamp</span>() <span class="tok-type">i64</span> {</span>
<span class="line" id="L64">    <span class="tok-kw">return</span> <span class="tok-builtin">@divFloor</span>(milliTimestamp(), ms_per_s);</span>
<span class="line" id="L65">}</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-comment">/// Get a calendar timestamp, in milliseconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L68"><span class="tok-comment">/// Precision of timing depends on the hardware and operating system.</span></span>
<span class="line" id="L69"><span class="tok-comment">/// The return value is signed because it is possible to have a date that is</span></span>
<span class="line" id="L70"><span class="tok-comment">/// before the epoch.</span></span>
<span class="line" id="L71"><span class="tok-comment">/// See `std.os.clock_gettime` for a POSIX timestamp.</span></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">milliTimestamp</span>() <span class="tok-type">i64</span> {</span>
<span class="line" id="L73">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, <span class="tok-builtin">@divFloor</span>(nanoTimestamp(), ns_per_ms));</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-comment">/// Get a calendar timestamp, in nanoseconds, relative to UTC 1970-01-01.</span></span>
<span class="line" id="L77"><span class="tok-comment">/// Precision of timing depends on the hardware and operating system.</span></span>
<span class="line" id="L78"><span class="tok-comment">/// On Windows this has a maximum granularity of 100 nanoseconds.</span></span>
<span class="line" id="L79"><span class="tok-comment">/// The return value is signed because it is possible to have a date that is</span></span>
<span class="line" id="L80"><span class="tok-comment">/// before the epoch.</span></span>
<span class="line" id="L81"><span class="tok-comment">/// See `std.os.clock_gettime` for a POSIX timestamp.</span></span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nanoTimestamp</span>() <span class="tok-type">i128</span> {</span>
<span class="line" id="L83">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L84">        <span class="tok-comment">// FileTime has a granularity of 100 nanoseconds and uses the NTFS/Windows epoch,</span>
</span>
<span class="line" id="L85">        <span class="tok-comment">// which is 1601-01-01.</span>
</span>
<span class="line" id="L86">        <span class="tok-kw">const</span> epoch_adj = epoch.windows * (ns_per_s / <span class="tok-number">100</span>);</span>
<span class="line" id="L87">        <span class="tok-kw">var</span> ft: os.windows.FILETIME = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L88">        os.windows.kernel32.GetSystemTimeAsFileTime(&amp;ft);</span>
<span class="line" id="L89">        <span class="tok-kw">const</span> ft64 = (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, ft.dwHighDateTime) &lt;&lt; <span class="tok-number">32</span>) | ft.dwLowDateTime;</span>
<span class="line" id="L90">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i64</span>, ft64) + epoch_adj) * <span class="tok-number">100</span>;</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L94">        <span class="tok-kw">var</span> ns: os.wasi.timestamp_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L95">        <span class="tok-kw">const</span> err = os.wasi.clock_time_get(os.wasi.CLOCK.REALTIME, <span class="tok-number">1</span>, &amp;ns);</span>
<span class="line" id="L96">        assert(err == .SUCCESS);</span>
<span class="line" id="L97">        <span class="tok-kw">return</span> ns;</span>
<span class="line" id="L98">    }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-kw">var</span> ts: os.timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L101">    os.clock_gettime(os.CLOCK.REALTIME, &amp;ts) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L102">        <span class="tok-kw">error</span>.UnsupportedClock, <span class="tok-kw">error</span>.Unexpected =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>, <span class="tok-comment">// &quot;Precision of timing depends on hardware and OS&quot;.</span>
</span>
<span class="line" id="L103">    };</span>
<span class="line" id="L104">    <span class="tok-kw">return</span> (<span class="tok-builtin">@as</span>(<span class="tok-type">i128</span>, ts.tv_sec) * ns_per_s) + ts.tv_nsec;</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">test</span> <span class="tok-str">&quot;timestamp&quot;</span> {</span>
<span class="line" id="L108">    <span class="tok-kw">const</span> margin = ns_per_ms * <span class="tok-number">50</span>;</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    <span class="tok-kw">const</span> time_0 = milliTimestamp();</span>
<span class="line" id="L111">    sleep(ns_per_ms);</span>
<span class="line" id="L112">    <span class="tok-kw">const</span> time_1 = milliTimestamp();</span>
<span class="line" id="L113">    <span class="tok-kw">const</span> interval = time_1 - time_0;</span>
<span class="line" id="L114">    <span class="tok-kw">try</span> testing.expect(interval &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L115">    <span class="tok-comment">// Tests should not depend on timings: skip test if outside margin.</span>
</span>
<span class="line" id="L116">    <span class="tok-kw">if</span> (!(interval &lt; margin)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L117">}</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-comment">// Divisions of a nanosecond.</span>
</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_us = <span class="tok-number">1000</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_ms = <span class="tok-number">1000</span> * ns_per_us;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_s = <span class="tok-number">1000</span> * ns_per_ms;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_min = <span class="tok-number">60</span> * ns_per_s;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_hour = <span class="tok-number">60</span> * ns_per_min;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_day = <span class="tok-number">24</span> * ns_per_hour;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ns_per_week = <span class="tok-number">7</span> * ns_per_day;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-comment">// Divisions of a microsecond.</span>
</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_ms = <span class="tok-number">1000</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_s = <span class="tok-number">1000</span> * us_per_ms;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_min = <span class="tok-number">60</span> * us_per_s;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_hour = <span class="tok-number">60</span> * us_per_min;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_day = <span class="tok-number">24</span> * us_per_hour;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> us_per_week = <span class="tok-number">7</span> * us_per_day;</span>
<span class="line" id="L135"></span>
<span class="line" id="L136"><span class="tok-comment">// Divisions of a millisecond.</span>
</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ms_per_s = <span class="tok-number">1000</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ms_per_min = <span class="tok-number">60</span> * ms_per_s;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ms_per_hour = <span class="tok-number">60</span> * ms_per_min;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ms_per_day = <span class="tok-number">24</span> * ms_per_hour;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ms_per_week = <span class="tok-number">7</span> * ms_per_day;</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-comment">// Divisions of a second.</span>
</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> s_per_min = <span class="tok-number">60</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> s_per_hour = s_per_min * <span class="tok-number">60</span>;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> s_per_day = s_per_hour * <span class="tok-number">24</span>;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> s_per_week = s_per_day * <span class="tok-number">7</span>;</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-comment">/// An Instant represents a timestamp with respect to the currently</span></span>
<span class="line" id="L150"><span class="tok-comment">/// executing program that ticks during suspend and can be used to</span></span>
<span class="line" id="L151"><span class="tok-comment">/// record elapsed time unlike `nanoTimestamp`.</span></span>
<span class="line" id="L152"><span class="tok-comment">///</span></span>
<span class="line" id="L153"><span class="tok-comment">/// It tries to sample the system's fastest and most precise timer available.</span></span>
<span class="line" id="L154"><span class="tok-comment">/// It also tries to be monotonic, but this is not a guarantee due to OS/hardware bugs.</span></span>
<span class="line" id="L155"><span class="tok-comment">/// If you need monotonic readings for elapsed time, consider `Timer` instead.</span></span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Instant = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L157">    timestamp: <span class="tok-kw">if</span> (is_posix) os.timespec <span class="tok-kw">else</span> <span class="tok-type">u64</span>,</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">    <span class="tok-comment">// true if we should use clock_gettime()</span>
</span>
<span class="line" id="L160">    <span class="tok-kw">const</span> is_posix = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L161">        .wasi =&gt; builtin.link_libc,</span>
<span class="line" id="L162">        .windows =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L163">        <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L164">    };</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-comment">/// Queries the system for the current moment of time as an Instant.</span></span>
<span class="line" id="L167">    <span class="tok-comment">/// This is not guaranteed to be monotonic or steadily increasing, but for most implementations it is.</span></span>
<span class="line" id="L168">    <span class="tok-comment">/// Returns `error.Unsupported` when a suitable clock is not detected.</span></span>
<span class="line" id="L169">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">now</span>() <span class="tok-kw">error</span>{Unsupported}!Instant {</span>
<span class="line" id="L170">        <span class="tok-comment">// QPC on windows doesn't fail on &gt;= XP/2000 and includes time suspended.</span>
</span>
<span class="line" id="L171">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L172">            <span class="tok-kw">return</span> Instant{ .timestamp = os.windows.QueryPerformanceCounter() };</span>
<span class="line" id="L173">        }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">        <span class="tok-comment">// On WASI without libc, use clock_time_get directly.</span>
</span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L177">            <span class="tok-kw">var</span> ns: os.wasi.timestamp_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L178">            <span class="tok-kw">const</span> rc = os.wasi.clock_time_get(os.wasi.CLOCK.MONOTONIC, <span class="tok-number">1</span>, &amp;ns);</span>
<span class="line" id="L179">            <span class="tok-kw">if</span> (rc != .SUCCESS) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L180">            <span class="tok-kw">return</span> Instant{ .timestamp = ns };</span>
<span class="line" id="L181">        }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        <span class="tok-comment">// On darwin, use UPTIME_RAW instead of MONOTONIC as it ticks while suspended.</span>
</span>
<span class="line" id="L184">        <span class="tok-comment">// On linux, use BOOTTIME instead of MONOTONIC as it ticks while suspended.</span>
</span>
<span class="line" id="L185">        <span class="tok-comment">// On freebsd derivatives, use MONOTONIC_FAST as currently there's no precision tradeoff.</span>
</span>
<span class="line" id="L186">        <span class="tok-comment">// On other posix systems, MONOTONIC is generally the fastest and ticks while suspended.</span>
</span>
<span class="line" id="L187">        <span class="tok-kw">const</span> clock_id = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L188">            .macos, .ios, .tvos, .watchos =&gt; os.CLOCK.UPTIME_RAW,</span>
<span class="line" id="L189">            .freebsd, .dragonfly =&gt; os.CLOCK.MONOTONIC_FAST,</span>
<span class="line" id="L190">            .linux =&gt; os.CLOCK.BOOTTIME,</span>
<span class="line" id="L191">            <span class="tok-kw">else</span> =&gt; os.CLOCK.MONOTONIC,</span>
<span class="line" id="L192">        };</span>
<span class="line" id="L193"></span>
<span class="line" id="L194">        <span class="tok-kw">var</span> ts: os.timespec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L195">        os.clock_gettime(clock_id, &amp;ts) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unsupported;</span>
<span class="line" id="L196">        <span class="tok-kw">return</span> Instant{ .timestamp = ts };</span>
<span class="line" id="L197">    }</span>
<span class="line" id="L198"></span>
<span class="line" id="L199">    <span class="tok-comment">/// Quickly compares two instances between each other.</span></span>
<span class="line" id="L200">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(self: Instant, other: Instant) std.math.Order {</span>
<span class="line" id="L201">        <span class="tok-comment">// windows and wasi timestamps are in u64 which is easily comparible</span>
</span>
<span class="line" id="L202">        <span class="tok-kw">if</span> (!is_posix) {</span>
<span class="line" id="L203">            <span class="tok-kw">return</span> std.math.order(self.timestamp, other.timestamp);</span>
<span class="line" id="L204">        }</span>
<span class="line" id="L205"></span>
<span class="line" id="L206">        <span class="tok-kw">var</span> ord = std.math.order(self.timestamp.tv_sec, other.timestamp.tv_sec);</span>
<span class="line" id="L207">        <span class="tok-kw">if</span> (ord == .eq) {</span>
<span class="line" id="L208">            ord = std.math.order(self.timestamp.tv_nsec, other.timestamp.tv_nsec);</span>
<span class="line" id="L209">        }</span>
<span class="line" id="L210">        <span class="tok-kw">return</span> ord;</span>
<span class="line" id="L211">    }</span>
<span class="line" id="L212"></span>
<span class="line" id="L213">    <span class="tok-comment">/// Returns elapsed time in nanoseconds since the `earlier` Instant.</span></span>
<span class="line" id="L214">    <span class="tok-comment">/// This assumes that the `earlier` Instant represents a moment in time before or equal to `self`.</span></span>
<span class="line" id="L215">    <span class="tok-comment">/// This also assumes that the time that has passed between both Instants fits inside a u64 (~585 yrs).</span></span>
<span class="line" id="L216">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">since</span>(self: Instant, earlier: Instant) <span class="tok-type">u64</span> {</span>
<span class="line" id="L217">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L218">            <span class="tok-comment">// We don't need to cache QPF as it's internally just a memory read to KUSER_SHARED_DATA</span>
</span>
<span class="line" id="L219">            <span class="tok-comment">// (a read-only page of info updated and mapped by the kernel to all processes):</span>
</span>
<span class="line" id="L220">            <span class="tok-comment">// https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/ntddk/ns-ntddk-kuser_shared_data</span>
</span>
<span class="line" id="L221">            <span class="tok-comment">// https://www.geoffchappell.com/studies/windows/km/ntoskrnl/inc/api/ntexapi_x/kuser_shared_data/index.htm</span>
</span>
<span class="line" id="L222">            <span class="tok-kw">const</span> qpc = self.timestamp - earlier.timestamp;</span>
<span class="line" id="L223">            <span class="tok-kw">const</span> qpf = os.windows.QueryPerformanceFrequency();</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">            <span class="tok-comment">// 10Mhz (1 qpc tick every 100ns) is a common enough QPF value that we can optimize on it.</span>
</span>
<span class="line" id="L226">            <span class="tok-comment">// https://github.com/microsoft/STL/blob/785143a0c73f030238ef618890fd4d6ae2b3a3a0/stl/inc/chrono#L694-L701</span>
</span>
<span class="line" id="L227">            <span class="tok-kw">const</span> common_qpf = <span class="tok-number">10_000_000</span>;</span>
<span class="line" id="L228">            <span class="tok-kw">if</span> (qpf == common_qpf) {</span>
<span class="line" id="L229">                <span class="tok-kw">return</span> qpc * (ns_per_s / common_qpf);</span>
<span class="line" id="L230">            }</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">            <span class="tok-comment">// Convert to ns using fixed point.</span>
</span>
<span class="line" id="L233">            <span class="tok-kw">const</span> scale = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, std.time.ns_per_s &lt;&lt; <span class="tok-number">32</span>) / <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, qpf);</span>
<span class="line" id="L234">            <span class="tok-kw">const</span> result = (<span class="tok-builtin">@as</span>(<span class="tok-type">u96</span>, qpc) * scale) &gt;&gt; <span class="tok-number">32</span>;</span>
<span class="line" id="L235">            <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, result);</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">        <span class="tok-comment">// WASI timestamps are directly in nanoseconds</span>
</span>
<span class="line" id="L239">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L240">            <span class="tok-kw">return</span> self.timestamp - earlier.timestamp;</span>
<span class="line" id="L241">        }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">        <span class="tok-comment">// Convert timespec diff to ns</span>
</span>
<span class="line" id="L244">        <span class="tok-kw">const</span> seconds = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, self.timestamp.tv_sec - earlier.timestamp.tv_sec);</span>
<span class="line" id="L245">        <span class="tok-kw">const</span> elapsed = (seconds * ns_per_s) + <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, self.timestamp.tv_nsec);</span>
<span class="line" id="L246">        <span class="tok-kw">return</span> elapsed - <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, earlier.timestamp.tv_nsec);</span>
<span class="line" id="L247">    }</span>
<span class="line" id="L248">};</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-comment">/// A monotonic, high performance timer.</span></span>
<span class="line" id="L251"><span class="tok-comment">///</span></span>
<span class="line" id="L252"><span class="tok-comment">/// Timer.start() is used to initalize the timer</span></span>
<span class="line" id="L253"><span class="tok-comment">/// and gives the caller an opportunity to check for the existence of a supported clock.</span></span>
<span class="line" id="L254"><span class="tok-comment">/// Once a supported clock is discovered,</span></span>
<span class="line" id="L255"><span class="tok-comment">/// it is assumed that it will be available for the duration of the Timer's use.</span></span>
<span class="line" id="L256"><span class="tok-comment">///</span></span>
<span class="line" id="L257"><span class="tok-comment">/// Monotonicity is ensured by saturating on the most previous sample.</span></span>
<span class="line" id="L258"><span class="tok-comment">/// This means that while timings reported are monotonic,</span></span>
<span class="line" id="L259"><span class="tok-comment">/// they're not guaranteed to tick at a steady rate as this is up to the underlying system.</span></span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Timer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L261">    started: Instant,</span>
<span class="line" id="L262">    previous: Instant,</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{TimerUnsupported};</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-comment">/// Initialize the timer by querying for a supported clock.</span></span>
<span class="line" id="L267">    <span class="tok-comment">/// Returns `error.TimerUnsupported` when such a clock is unavailable.</span></span>
<span class="line" id="L268">    <span class="tok-comment">/// This should only fail in hostile environments such as linux seccomp misuse.</span></span>
<span class="line" id="L269">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">start</span>() Error!Timer {</span>
<span class="line" id="L270">        <span class="tok-kw">const</span> current = Instant.now() <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TimerUnsupported;</span>
<span class="line" id="L271">        <span class="tok-kw">return</span> Timer{ .started = current, .previous = current };</span>
<span class="line" id="L272">    }</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-comment">/// Reads the timer value since start or the last reset in nanoseconds.</span></span>
<span class="line" id="L275">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *Timer) <span class="tok-type">u64</span> {</span>
<span class="line" id="L276">        <span class="tok-kw">const</span> current = self.sample();</span>
<span class="line" id="L277">        <span class="tok-kw">return</span> current.since(self.started);</span>
<span class="line" id="L278">    }</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-comment">/// Resets the timer value to 0/now.</span></span>
<span class="line" id="L281">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Timer) <span class="tok-type">void</span> {</span>
<span class="line" id="L282">        <span class="tok-kw">const</span> current = self.sample();</span>
<span class="line" id="L283">        self.started = current;</span>
<span class="line" id="L284">    }</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">    <span class="tok-comment">/// Returns the current value of the timer in nanoseconds, then resets it.</span></span>
<span class="line" id="L287">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lap</span>(self: *Timer) <span class="tok-type">u64</span> {</span>
<span class="line" id="L288">        <span class="tok-kw">const</span> current = self.sample();</span>
<span class="line" id="L289">        <span class="tok-kw">defer</span> self.started = current;</span>
<span class="line" id="L290">        <span class="tok-kw">return</span> current.since(self.started);</span>
<span class="line" id="L291">    }</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-comment">/// Returns an Instant sampled at the callsite that is</span></span>
<span class="line" id="L294">    <span class="tok-comment">/// guaranteed to be monotonic with respect to the timer's starting point.</span></span>
<span class="line" id="L295">    <span class="tok-kw">fn</span> <span class="tok-fn">sample</span>(self: *Timer) Instant {</span>
<span class="line" id="L296">        <span class="tok-kw">const</span> current = Instant.now() <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L297">        <span class="tok-kw">if</span> (current.order(self.previous) == .gt) {</span>
<span class="line" id="L298">            self.previous = current;</span>
<span class="line" id="L299">        }</span>
<span class="line" id="L300">        <span class="tok-kw">return</span> self.previous;</span>
<span class="line" id="L301">    }</span>
<span class="line" id="L302">};</span>
<span class="line" id="L303"></span>
<span class="line" id="L304"><span class="tok-kw">test</span> <span class="tok-str">&quot;Timer + Instant&quot;</span> {</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> margin = ns_per_ms * <span class="tok-number">150</span>;</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">var</span> timer = <span class="tok-kw">try</span> Timer.start();</span>
<span class="line" id="L308">    sleep(<span class="tok-number">10</span> * ns_per_ms);</span>
<span class="line" id="L309">    <span class="tok-kw">const</span> time_0 = timer.read();</span>
<span class="line" id="L310">    <span class="tok-kw">try</span> testing.expect(time_0 &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L311">    <span class="tok-comment">// Tests should not depend on timings: skip test if outside margin.</span>
</span>
<span class="line" id="L312">    <span class="tok-kw">if</span> (!(time_0 &lt; margin)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    <span class="tok-kw">const</span> time_1 = timer.lap();</span>
<span class="line" id="L315">    <span class="tok-kw">try</span> testing.expect(time_1 &gt;= time_0);</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    timer.reset();</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> testing.expect(timer.read() &lt; time_1);</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">test</span> {</span>
<span class="line" id="L322">    _ = epoch;</span>
<span class="line" id="L323">}</span>
<span class="line" id="L324"></span>
</code></pre></body>
</html>