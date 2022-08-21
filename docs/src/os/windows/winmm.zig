<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/winmm.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> UINT = windows.UINT;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> BYTE = windows.BYTE;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMRESULT = UINT;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_BASE = <span class="tok-number">0</span>;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMERR_BASE = <span class="tok-number">96</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_ERROR = MMSYSERR_BASE + <span class="tok-number">1</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_BADDEVICEID = MMSYSERR_BASE + <span class="tok-number">2</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_NOTENABLED = MMSYSERR_BASE + <span class="tok-number">3</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_ALLOCATED = MMSYSERR_BASE + <span class="tok-number">4</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_INVALHANDLE = MMSYSERR_BASE + <span class="tok-number">5</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_NODRIVER = MMSYSERR_BASE + <span class="tok-number">6</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_NOMEM = MMSYSERR_BASE + <span class="tok-number">7</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_NOTSUPPORTED = MMSYSERR_BASE + <span class="tok-number">8</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_BADERRNUM = MMSYSERR_BASE + <span class="tok-number">9</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_INVALFLAG = MMSYSERR_BASE + <span class="tok-number">10</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_INVALPARAM = MMSYSERR_BASE + <span class="tok-number">11</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_HANDLEBUSY = MMSYSERR_BASE + <span class="tok-number">12</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_INVALIDALIAS = MMSYSERR_BASE + <span class="tok-number">13</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_BADDB = MMSYSERR_BASE + <span class="tok-number">14</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_KEYNOTFOUND = MMSYSERR_BASE + <span class="tok-number">15</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_READERROR = MMSYSERR_BASE + <span class="tok-number">16</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_WRITEERROR = MMSYSERR_BASE + <span class="tok-number">17</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_DELETEERROR = MMSYSERR_BASE + <span class="tok-number">18</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_VALNOTFOUND = MMSYSERR_BASE + <span class="tok-number">19</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_NODRIVERCB = MMSYSERR_BASE + <span class="tok-number">20</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_MOREDATA = MMSYSERR_BASE + <span class="tok-number">21</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMSYSERR_LASTERROR = MMSYSERR_BASE + <span class="tok-number">21</span>;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MMTIME = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L35">    wType: UINT,</span>
<span class="line" id="L36">    u: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L37">        ms: DWORD,</span>
<span class="line" id="L38">        sample: DWORD,</span>
<span class="line" id="L39">        cb: DWORD,</span>
<span class="line" id="L40">        ticks: DWORD,</span>
<span class="line" id="L41">        smpte: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L42">            hour: BYTE,</span>
<span class="line" id="L43">            min: BYTE,</span>
<span class="line" id="L44">            sec: BYTE,</span>
<span class="line" id="L45">            frame: BYTE,</span>
<span class="line" id="L46">            fps: BYTE,</span>
<span class="line" id="L47">            dummy: BYTE,</span>
<span class="line" id="L48">            pad: [<span class="tok-number">2</span>]BYTE,</span>
<span class="line" id="L49">        },</span>
<span class="line" id="L50">        midi: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L51">            songptrpos: DWORD,</span>
<span class="line" id="L52">        },</span>
<span class="line" id="L53">    },</span>
<span class="line" id="L54">};</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPMMTIME = *MMTIME;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_MS = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_SAMPLES = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_BYTES = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_SMPTE = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_MIDI = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIME_TICKS = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">// timeapi.h</span>
</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMECAPS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> { wPeriodMin: UINT, wPeriodMax: UINT };</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPTIMECAPS = *TIMECAPS;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMERR_NOERROR = <span class="tok-number">0</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMERR_NOCANDO = TIMERR_BASE + <span class="tok-number">1</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMERR_STRUCT = TIMERR_BASE + <span class="tok-number">33</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;winmm&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeBeginPeriod</span>(uPeriod: UINT) <span class="tok-kw">callconv</span>(WINAPI) MMRESULT;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;winmm&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeEndPeriod</span>(uPeriod: UINT) <span class="tok-kw">callconv</span>(WINAPI) MMRESULT;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;winmm&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeGetDevCaps</span>(ptc: LPTIMECAPS, cbtc: UINT) <span class="tok-kw">callconv</span>(WINAPI) MMRESULT;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;winmm&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeGetSystemTime</span>(pmmt: LPMMTIME, cbmmt: UINT) <span class="tok-kw">callconv</span>(WINAPI) MMRESULT;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;winmm&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">timeGetTime</span>() <span class="tok-kw">callconv</span>(WINAPI) DWORD;</span>
<span class="line" id="L74"></span>
</code></pre></body>
</html>