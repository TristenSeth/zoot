<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/user32.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> GetLastError = windows.kernel32.GetLastError;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> SetLastError = windows.kernel32.SetLastError;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> unexpectedError = windows.unexpectedError;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> HWND = windows.HWND;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> UINT = windows.UINT;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> HDC = windows.HDC;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> LONG = windows.LONG;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> LONG_PTR = windows.LONG_PTR;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> RECT = windows.RECT;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> BOOL = windows.BOOL;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> TRUE = windows.TRUE;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> HMENU = windows.HMENU;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> HINSTANCE = windows.HINSTANCE;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> LPVOID = windows.LPVOID;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> ATOM = windows.ATOM;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> WPARAM = windows.WPARAM;</span>
<span class="line" id="L24"><span class="tok-kw">const</span> LRESULT = windows.LRESULT;</span>
<span class="line" id="L25"><span class="tok-kw">const</span> HICON = windows.HICON;</span>
<span class="line" id="L26"><span class="tok-kw">const</span> LPARAM = windows.LPARAM;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> POINT = windows.POINT;</span>
<span class="line" id="L28"><span class="tok-kw">const</span> HCURSOR = windows.HCURSOR;</span>
<span class="line" id="L29"><span class="tok-kw">const</span> HBRUSH = windows.HBRUSH;</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-kw">fn</span> <span class="tok-fn">selectSymbol</span>(<span class="tok-kw">comptime</span> function_static: <span class="tok-kw">anytype</span>, function_dynamic: <span class="tok-builtin">@TypeOf</span>(function_static), <span class="tok-kw">comptime</span> os: std.Target.Os.WindowsVersion) <span class="tok-builtin">@TypeOf</span>(function_static) {</span>
<span class="line" id="L32">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L33">        <span class="tok-kw">const</span> sym_ok = builtin.os.isAtLeast(.windows, os);</span>
<span class="line" id="L34">        <span class="tok-kw">if</span> (sym_ok == <span class="tok-null">true</span>) <span class="tok-kw">return</span> function_static;</span>
<span class="line" id="L35">        <span class="tok-kw">if</span> (sym_ok == <span class="tok-null">null</span>) <span class="tok-kw">return</span> function_dynamic;</span>
<span class="line" id="L36">        <span class="tok-kw">if</span> (sym_ok == <span class="tok-null">false</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Target OS range does not support function, at least &quot;</span> ++ <span class="tok-builtin">@tagName</span>(os) ++ <span class="tok-str">&quot; is required&quot;</span>);</span>
<span class="line" id="L37">    }</span>
<span class="line" id="L38">}</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-comment">// === Messages ===</span>
</span>
<span class="line" id="L41"></span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WNDPROC = <span class="tok-kw">fn</span> (hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM) <span class="tok-kw">callconv</span>(WINAPI) LRESULT;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L45">    hWnd: ?HWND,</span>
<span class="line" id="L46">    message: UINT,</span>
<span class="line" id="L47">    wParam: WPARAM,</span>
<span class="line" id="L48">    lParam: LPARAM,</span>
<span class="line" id="L49">    time: DWORD,</span>
<span class="line" id="L50">    pt: POINT,</span>
<span class="line" id="L51">    lPrivate: DWORD,</span>
<span class="line" id="L52">};</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-comment">// Compiled by the WINE team @ https://wiki.winehq.org/List_Of_Windows_Messages</span>
</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NULL = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CREATE = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DESTROY = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOVE = <span class="tok-number">0x0003</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SIZE = <span class="tok-number">0x0005</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ACTIVATE = <span class="tok-number">0x0006</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETFOCUS = <span class="tok-number">0x0007</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_KILLFOCUS = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ENABLE = <span class="tok-number">0x000A</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETREDRAW = <span class="tok-number">0x000B</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETTEXT = <span class="tok-number">0x000C</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETTEXT = <span class="tok-number">0x000D</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETTEXTLENGTH = <span class="tok-number">0x000E</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PAINT = <span class="tok-number">0x000F</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CLOSE = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUERYENDSESSION = <span class="tok-number">0x0011</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUIT = <span class="tok-number">0x0012</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUERYOPEN = <span class="tok-number">0x0013</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ERASEBKGND = <span class="tok-number">0x0014</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSCOLORCHANGE = <span class="tok-number">0x0015</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ENDSESSION = <span class="tok-number">0x0016</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SHOWWINDOW = <span class="tok-number">0x0018</span>;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLOR = <span class="tok-number">0x0019</span>;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_WININICHANGE = <span class="tok-number">0x001A</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DEVMODECHANGE = <span class="tok-number">0x001B</span>;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ACTIVATEAPP = <span class="tok-number">0x001C</span>;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_FONTCHANGE = <span class="tok-number">0x001D</span>;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_TIMECHANGE = <span class="tok-number">0x001E</span>;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CANCELMODE = <span class="tok-number">0x001F</span>;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETCURSOR = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSEACTIVATE = <span class="tok-number">0x0021</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHILDACTIVATE = <span class="tok-number">0x0022</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUEUESYNC = <span class="tok-number">0x0023</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETMINMAXINFO = <span class="tok-number">0x0024</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PAINTICON = <span class="tok-number">0x0026</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ICONERASEBKGND = <span class="tok-number">0x0027</span>;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NEXTDLGCTL = <span class="tok-number">0x0028</span>;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SPOOLERSTATUS = <span class="tok-number">0x002A</span>;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DRAWITEM = <span class="tok-number">0x002B</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MEASUREITEM = <span class="tok-number">0x002C</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DELETEITEM = <span class="tok-number">0x002D</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_VKEYTOITEM = <span class="tok-number">0x002E</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHARTOITEM = <span class="tok-number">0x002F</span>;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETFONT = <span class="tok-number">0x0030</span>;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETFONT = <span class="tok-number">0x0031</span>;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETHOTKEY = <span class="tok-number">0x0032</span>;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETHOTKEY = <span class="tok-number">0x0033</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUERYDRAGICON = <span class="tok-number">0x0037</span>;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COMPAREITEM = <span class="tok-number">0x0039</span>;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETOBJECT = <span class="tok-number">0x003D</span>;</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COMPACTING = <span class="tok-number">0x0041</span>;</span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COMMNOTIFY = <span class="tok-number">0x0044</span>;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_WINDOWPOSCHANGING = <span class="tok-number">0x0046</span>;</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_WINDOWPOSCHANGED = <span class="tok-number">0x0047</span>;</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_POWER = <span class="tok-number">0x0048</span>;</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COPYGLOBALDATA = <span class="tok-number">0x0049</span>;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COPYDATA = <span class="tok-number">0x004A</span>;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CANCELJOURNAL = <span class="tok-number">0x004B</span>;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NOTIFY = <span class="tok-number">0x004E</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INPUTLANGCHANGEREQUEST = <span class="tok-number">0x0050</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INPUTLANGCHANGE = <span class="tok-number">0x0051</span>;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_TCARD = <span class="tok-number">0x0052</span>;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HELP = <span class="tok-number">0x0053</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_USERCHANGED = <span class="tok-number">0x0054</span>;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NOTIFYFORMAT = <span class="tok-number">0x0055</span>;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CONTEXTMENU = <span class="tok-number">0x007B</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_STYLECHANGING = <span class="tok-number">0x007C</span>;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_STYLECHANGED = <span class="tok-number">0x007D</span>;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DISPLAYCHANGE = <span class="tok-number">0x007E</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETICON = <span class="tok-number">0x007F</span>;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SETICON = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCCREATE = <span class="tok-number">0x0081</span>;</span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCDESTROY = <span class="tok-number">0x0082</span>;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCCALCSIZE = <span class="tok-number">0x0083</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCHITTEST = <span class="tok-number">0x0084</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCPAINT = <span class="tok-number">0x0085</span>;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCACTIVATE = <span class="tok-number">0x0086</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GETDLGCODE = <span class="tok-number">0x0087</span>;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYNCPAINT = <span class="tok-number">0x0088</span>;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMOUSEMOVE = <span class="tok-number">0x00A0</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCLBUTTONDOWN = <span class="tok-number">0x00A1</span>;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCLBUTTONUP = <span class="tok-number">0x00A2</span>;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCLBUTTONDBLCLK = <span class="tok-number">0x00A3</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCRBUTTONDOWN = <span class="tok-number">0x00A4</span>;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCRBUTTONUP = <span class="tok-number">0x00A5</span>;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCRBUTTONDBLCLK = <span class="tok-number">0x00A6</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMBUTTONDOWN = <span class="tok-number">0x00A7</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMBUTTONUP = <span class="tok-number">0x00A8</span>;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMBUTTONDBLCLK = <span class="tok-number">0x00A9</span>;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCXBUTTONDOWN = <span class="tok-number">0x00AB</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCXBUTTONUP = <span class="tok-number">0x00AC</span>;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCXBUTTONDBLCLK = <span class="tok-number">0x00AD</span>;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETSEL = <span class="tok-number">0x00B0</span>;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETSEL = <span class="tok-number">0x00B1</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETRECT = <span class="tok-number">0x00B2</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETRECT = <span class="tok-number">0x00B3</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETRECTNP = <span class="tok-number">0x00B4</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SCROLL = <span class="tok-number">0x00B5</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_LINESCROLL = <span class="tok-number">0x00B6</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SCROLLCARET = <span class="tok-number">0x00B7</span>;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETMODIFY = <span class="tok-number">0x00B8</span>;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETMODIFY = <span class="tok-number">0x00B9</span>;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETLINECOUNT = <span class="tok-number">0x00BA</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_LINEINDEX = <span class="tok-number">0x00BB</span>;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETHANDLE = <span class="tok-number">0x00BC</span>;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETHANDLE = <span class="tok-number">0x00BD</span>;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTHUMB = <span class="tok-number">0x00BE</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_LINELENGTH = <span class="tok-number">0x00C1</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_REPLACESEL = <span class="tok-number">0x00C2</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETFONT = <span class="tok-number">0x00C3</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETLINE = <span class="tok-number">0x00C4</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_LIMITTEXT = <span class="tok-number">0x00C5</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETLIMITTEXT = <span class="tok-number">0x00C5</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_CANUNDO = <span class="tok-number">0x00C6</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_UNDO = <span class="tok-number">0x00C7</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FMTLINES = <span class="tok-number">0x00C8</span>;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_LINEFROMCHAR = <span class="tok-number">0x00C9</span>;</span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETWORDBREAK = <span class="tok-number">0x00CA</span>;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETTABSTOPS = <span class="tok-number">0x00CB</span>;</span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPASSWORDCHAR = <span class="tok-number">0x00CC</span>;</span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_EMPTYUNDOBUFFER = <span class="tok-number">0x00CD</span>;</span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETFIRSTVISIBLELINE = <span class="tok-number">0x00CE</span>;</span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETREADONLY = <span class="tok-number">0x00CF</span>;</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETWORDBREAKPROC = <span class="tok-number">0x00D0</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETWORDBREAKPROC = <span class="tok-number">0x00D1</span>;</span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETPASSWORDCHAR = <span class="tok-number">0x00D2</span>;</span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETMARGINS = <span class="tok-number">0x00D3</span>;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETMARGINS = <span class="tok-number">0x00D4</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETLIMITTEXT = <span class="tok-number">0x00D5</span>;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_POSFROMCHAR = <span class="tok-number">0x00D6</span>;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_CHARFROMPOS = <span class="tok-number">0x00D7</span>;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETIMESTATUS = <span class="tok-number">0x00D8</span>;</span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMESTATUS = <span class="tok-number">0x00D9</span>;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_SETPOS = <span class="tok-number">0x00E0</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_GETPOS = <span class="tok-number">0x00E1</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_SETRANGE = <span class="tok-number">0x00E2</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_GETRANGE = <span class="tok-number">0x00E3</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_ENABLE_ARROWS = <span class="tok-number">0x00E4</span>;</span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_SETRANGEREDRAW = <span class="tok-number">0x00E6</span>;</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_SETSCROLLINFO = <span class="tok-number">0x00E9</span>;</span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_GETSCROLLINFO = <span class="tok-number">0x00EA</span>;</span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SBM_GETSCROLLBARINFO = <span class="tok-number">0x00EB</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_GETCHECK = <span class="tok-number">0x00F0</span>;</span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_SETCHECK = <span class="tok-number">0x00F1</span>;</span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_GETSTATE = <span class="tok-number">0x00F2</span>;</span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_SETSTATE = <span class="tok-number">0x00F3</span>;</span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_SETSTYLE = <span class="tok-number">0x00F4</span>;</span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_CLICK = <span class="tok-number">0x00F5</span>;</span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_GETIMAGE = <span class="tok-number">0x00F6</span>;</span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_SETIMAGE = <span class="tok-number">0x00F7</span>;</span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BM_SETDONTCLICK = <span class="tok-number">0x00F8</span>;</span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INPUT = <span class="tok-number">0x00FF</span>;</span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_KEYDOWN = <span class="tok-number">0x0100</span>;</span>
<span class="line" id="L208"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_KEYUP = <span class="tok-number">0x0101</span>;</span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHAR = <span class="tok-number">0x0102</span>;</span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DEADCHAR = <span class="tok-number">0x0103</span>;</span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSKEYDOWN = <span class="tok-number">0x0104</span>;</span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSKEYUP = <span class="tok-number">0x0105</span>;</span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSCHAR = <span class="tok-number">0x0106</span>;</span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSDEADCHAR = <span class="tok-number">0x0107</span>;</span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_UNICHAR = <span class="tok-number">0x0109</span>;</span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_WNT_CONVERTREQUESTEX = <span class="tok-number">0x0109</span>;</span>
<span class="line" id="L217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CONVERTREQUEST = <span class="tok-number">0x010A</span>;</span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CONVERTRESULT = <span class="tok-number">0x010B</span>;</span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INTERIM = <span class="tok-number">0x010C</span>;</span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_STARTCOMPOSITION = <span class="tok-number">0x010D</span>;</span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_ENDCOMPOSITION = <span class="tok-number">0x010E</span>;</span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_COMPOSITION = <span class="tok-number">0x010F</span>;</span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INITDIALOG = <span class="tok-number">0x0110</span>;</span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COMMAND = <span class="tok-number">0x0111</span>;</span>
<span class="line" id="L225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSCOMMAND = <span class="tok-number">0x0112</span>;</span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_TIMER = <span class="tok-number">0x0113</span>;</span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HSCROLL = <span class="tok-number">0x0114</span>;</span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_VSCROLL = <span class="tok-number">0x0115</span>;</span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INITMENU = <span class="tok-number">0x0116</span>;</span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_INITMENUPOPUP = <span class="tok-number">0x0117</span>;</span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SYSTIMER = <span class="tok-number">0x0118</span>;</span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENUSELECT = <span class="tok-number">0x011F</span>;</span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENUCHAR = <span class="tok-number">0x0120</span>;</span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ENTERIDLE = <span class="tok-number">0x0121</span>;</span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENURBUTTONUP = <span class="tok-number">0x0122</span>;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENUDRAG = <span class="tok-number">0x0123</span>;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENUGETOBJECT = <span class="tok-number">0x0124</span>;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_UNINITMENUPOPUP = <span class="tok-number">0x0125</span>;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MENUCOMMAND = <span class="tok-number">0x0126</span>;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHANGEUISTATE = <span class="tok-number">0x0127</span>;</span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_UPDATEUISTATE = <span class="tok-number">0x0128</span>;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUERYUISTATE = <span class="tok-number">0x0129</span>;</span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORMSGBOX = <span class="tok-number">0x0132</span>;</span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLOREDIT = <span class="tok-number">0x0133</span>;</span>
<span class="line" id="L245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORLISTBOX = <span class="tok-number">0x0134</span>;</span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORBTN = <span class="tok-number">0x0135</span>;</span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORDLG = <span class="tok-number">0x0136</span>;</span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORSCROLLBAR = <span class="tok-number">0x0137</span>;</span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLCOLORSTATIC = <span class="tok-number">0x0138</span>;</span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSEMOVE = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_LBUTTONDOWN = <span class="tok-number">0x0201</span>;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_LBUTTONUP = <span class="tok-number">0x0202</span>;</span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_LBUTTONDBLCLK = <span class="tok-number">0x0203</span>;</span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RBUTTONDOWN = <span class="tok-number">0x0204</span>;</span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RBUTTONUP = <span class="tok-number">0x0205</span>;</span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RBUTTONDBLCLK = <span class="tok-number">0x0206</span>;</span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MBUTTONDOWN = <span class="tok-number">0x0207</span>;</span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MBUTTONUP = <span class="tok-number">0x0208</span>;</span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MBUTTONDBLCLK = <span class="tok-number">0x0209</span>;</span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSEWHEEL = <span class="tok-number">0x020A</span>;</span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_XBUTTONDOWN = <span class="tok-number">0x020B</span>;</span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_XBUTTONUP = <span class="tok-number">0x020C</span>;</span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_XBUTTONDBLCLK = <span class="tok-number">0x020D</span>;</span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSEHWHEEL = <span class="tok-number">0x020E</span>;</span>
<span class="line" id="L265"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PARENTNOTIFY = <span class="tok-number">0x0210</span>;</span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ENTERMENULOOP = <span class="tok-number">0x0211</span>;</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_EXITMENULOOP = <span class="tok-number">0x0212</span>;</span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NEXTMENU = <span class="tok-number">0x0213</span>;</span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SIZING = <span class="tok-number">0x0214</span>;</span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAPTURECHANGED = <span class="tok-number">0x0215</span>;</span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOVING = <span class="tok-number">0x0216</span>;</span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_POWERBROADCAST = <span class="tok-number">0x0218</span>;</span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DEVICECHANGE = <span class="tok-number">0x0219</span>;</span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDICREATE = <span class="tok-number">0x0220</span>;</span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIDESTROY = <span class="tok-number">0x0221</span>;</span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIACTIVATE = <span class="tok-number">0x0222</span>;</span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIRESTORE = <span class="tok-number">0x0223</span>;</span>
<span class="line" id="L278"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDINEXT = <span class="tok-number">0x0224</span>;</span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIMAXIMIZE = <span class="tok-number">0x0225</span>;</span>
<span class="line" id="L280"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDITILE = <span class="tok-number">0x0226</span>;</span>
<span class="line" id="L281"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDICASCADE = <span class="tok-number">0x0227</span>;</span>
<span class="line" id="L282"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIICONARRANGE = <span class="tok-number">0x0228</span>;</span>
<span class="line" id="L283"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIGETACTIVE = <span class="tok-number">0x0229</span>;</span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDISETMENU = <span class="tok-number">0x0230</span>;</span>
<span class="line" id="L285"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ENTERSIZEMOVE = <span class="tok-number">0x0231</span>;</span>
<span class="line" id="L286"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_EXITSIZEMOVE = <span class="tok-number">0x0232</span>;</span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DROPFILES = <span class="tok-number">0x0233</span>;</span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MDIREFRESHMENU = <span class="tok-number">0x0234</span>;</span>
<span class="line" id="L289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_REPORT = <span class="tok-number">0x0280</span>;</span>
<span class="line" id="L290"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_SETCONTEXT = <span class="tok-number">0x0281</span>;</span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_NOTIFY = <span class="tok-number">0x0282</span>;</span>
<span class="line" id="L292"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_CONTROL = <span class="tok-number">0x0283</span>;</span>
<span class="line" id="L293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_COMPOSITIONFULL = <span class="tok-number">0x0284</span>;</span>
<span class="line" id="L294"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_SELECT = <span class="tok-number">0x0285</span>;</span>
<span class="line" id="L295"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_CHAR = <span class="tok-number">0x0286</span>;</span>
<span class="line" id="L296"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_REQUEST = <span class="tok-number">0x0288</span>;</span>
<span class="line" id="L297"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IMEKEYDOWN = <span class="tok-number">0x0290</span>;</span>
<span class="line" id="L298"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_KEYDOWN = <span class="tok-number">0x0290</span>;</span>
<span class="line" id="L299"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IMEKEYUP = <span class="tok-number">0x0291</span>;</span>
<span class="line" id="L300"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_IME_KEYUP = <span class="tok-number">0x0291</span>;</span>
<span class="line" id="L301"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMOUSEHOVER = <span class="tok-number">0x02A0</span>;</span>
<span class="line" id="L302"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSEHOVER = <span class="tok-number">0x02A1</span>;</span>
<span class="line" id="L303"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_NCMOUSELEAVE = <span class="tok-number">0x02A2</span>;</span>
<span class="line" id="L304"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_MOUSELEAVE = <span class="tok-number">0x02A3</span>;</span>
<span class="line" id="L305"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CUT = <span class="tok-number">0x0300</span>;</span>
<span class="line" id="L306"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_COPY = <span class="tok-number">0x0301</span>;</span>
<span class="line" id="L307"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PASTE = <span class="tok-number">0x0302</span>;</span>
<span class="line" id="L308"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CLEAR = <span class="tok-number">0x0303</span>;</span>
<span class="line" id="L309"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_UNDO = <span class="tok-number">0x0304</span>;</span>
<span class="line" id="L310"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RENDERFORMAT = <span class="tok-number">0x0305</span>;</span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RENDERALLFORMATS = <span class="tok-number">0x0306</span>;</span>
<span class="line" id="L312"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DESTROYCLIPBOARD = <span class="tok-number">0x0307</span>;</span>
<span class="line" id="L313"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_DRAWCLIPBOARD = <span class="tok-number">0x0308</span>;</span>
<span class="line" id="L314"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PAINTCLIPBOARD = <span class="tok-number">0x0309</span>;</span>
<span class="line" id="L315"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_VSCROLLCLIPBOARD = <span class="tok-number">0x030A</span>;</span>
<span class="line" id="L316"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SIZECLIPBOARD = <span class="tok-number">0x030B</span>;</span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_ASKCBFORMATNAME = <span class="tok-number">0x030C</span>;</span>
<span class="line" id="L318"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHANGECBCHAIN = <span class="tok-number">0x030D</span>;</span>
<span class="line" id="L319"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HSCROLLCLIPBOARD = <span class="tok-number">0x030E</span>;</span>
<span class="line" id="L320"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_QUERYNEWPALETTE = <span class="tok-number">0x030F</span>;</span>
<span class="line" id="L321"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PALETTEISCHANGING = <span class="tok-number">0x0310</span>;</span>
<span class="line" id="L322"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PALETTECHANGED = <span class="tok-number">0x0311</span>;</span>
<span class="line" id="L323"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HOTKEY = <span class="tok-number">0x0312</span>;</span>
<span class="line" id="L324"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PRINT = <span class="tok-number">0x0317</span>;</span>
<span class="line" id="L325"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PRINTCLIENT = <span class="tok-number">0x0318</span>;</span>
<span class="line" id="L326"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_APPCOMMAND = <span class="tok-number">0x0319</span>;</span>
<span class="line" id="L327"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RCRESULT = <span class="tok-number">0x0381</span>;</span>
<span class="line" id="L328"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HOOKRCRESULT = <span class="tok-number">0x0382</span>;</span>
<span class="line" id="L329"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_GLOBALRCCHANGE = <span class="tok-number">0x0383</span>;</span>
<span class="line" id="L330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PENMISCINFO = <span class="tok-number">0x0383</span>;</span>
<span class="line" id="L331"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_SKB = <span class="tok-number">0x0384</span>;</span>
<span class="line" id="L332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_HEDITCTL = <span class="tok-number">0x0385</span>;</span>
<span class="line" id="L333"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PENCTL = <span class="tok-number">0x0385</span>;</span>
<span class="line" id="L334"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PENMISC = <span class="tok-number">0x0386</span>;</span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CTLINIT = <span class="tok-number">0x0387</span>;</span>
<span class="line" id="L336"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PENEVENT = <span class="tok-number">0x0388</span>;</span>
<span class="line" id="L337"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CARET_CREATE = <span class="tok-number">0x03E0</span>;</span>
<span class="line" id="L338"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CARET_DESTROY = <span class="tok-number">0x03E1</span>;</span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CARET_BLINK = <span class="tok-number">0x03E2</span>;</span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_FDINPUT = <span class="tok-number">0x03F0</span>;</span>
<span class="line" id="L341"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_FDOUTPUT = <span class="tok-number">0x03F1</span>;</span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_FDEXCEPT = <span class="tok-number">0x03F2</span>;</span>
<span class="line" id="L343"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DDM_SETFMT = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L344"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DM_GETDEFID = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L345"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NIN_SELECT = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETPOS = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L347"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_PAGESETUPDLG = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L348"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_USER = <span class="tok-number">0x0400</span>;</span>
<span class="line" id="L349"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_INSERTITEMA = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L350"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DDM_DRAW = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DM_SETDEFID = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L352"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HKM_SETHOTKEY = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L353"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_SETRANGE = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_INSERTBANDA = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETTEXTA = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L356"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ENABLEBUTTON = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETRANGEMIN = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ACTIVATE = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHOOSEFONT_GETLOGFONT = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_FULLPAGERECT = <span class="tok-number">0x0401</span>;</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_SETIMAGELIST = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L362"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DDM_CLOSE = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L363"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DM_REPOSITION = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L364"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HKM_GETHOTKEY = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L365"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_SETPOS = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L366"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_DELETEBAND = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTEXTA = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_CHECKBUTTON = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETRANGEMAX = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_MINMARGINRECT = <span class="tok-number">0x0402</span>;</span>
<span class="line" id="L371"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETIMAGELIST = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DDM_BEGIN = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L373"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HKM_SETRULES = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L374"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_DELTAPOS = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBARINFO = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L376"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTEXTLENGTHA = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L377"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETTIC = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L378"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_PRESSBUTTON = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETDELAYTIME = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L380"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_MARGINRECT = <span class="tok-number">0x0403</span>;</span>
<span class="line" id="L381"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETITEMA = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L382"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DDM_END = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L383"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_SETSTEP = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETBARINFO = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L385"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETPARTS = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L386"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_HIDEBUTTON = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETTIC = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L388"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ADDTOOLA = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L389"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_GREEKTEXTRECT = <span class="tok-number">0x0404</span>;</span>
<span class="line" id="L390"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_SETITEMA = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_STEPIT = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_INDETERMINATE = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L393"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETPOS = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_DELTOOLA = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L395"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_ENVSTAMPRECT = <span class="tok-number">0x0405</span>;</span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETCOMBOCONTROL = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_SETRANGE32 = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L398"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETBANDINFOA = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L399"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETPARTS = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L400"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_MARKBUTTON = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L401"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETRANGE = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L402"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_NEWTOOLRECTA = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L403"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_PSD_YAFULLPAGERECT = <span class="tok-number">0x0406</span>;</span>
<span class="line" id="L404"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETEDITCONTROL = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L405"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_GETRANGE = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L406"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETPARENT = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L407"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETBORDERS = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L408"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETRANGEMIN = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L409"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_RELAYEVENT = <span class="tok-number">0x0407</span>;</span>
<span class="line" id="L410"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_SETEXSTYLE = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L411"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_GETPOS = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L412"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_HITTEST = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L413"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETMINHEIGHT = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L414"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETRANGEMAX = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L415"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTOOLINFOA = <span class="tok-number">0x0408</span>;</span>
<span class="line" id="L416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETEXSTYLE = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L417"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETEXTENDEDSTYLE = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L418"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PBM_SETBARCOLOR = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L419"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETRECT = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L420"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SIMPLE = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L421"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONENABLED = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L422"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_CLEARTICS = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L423"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTOOLINFOA = <span class="tok-number">0x0409</span>;</span>
<span class="line" id="L424"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_HASEDITCHANGED = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L425"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_INSERTBANDW = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L426"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETRECT = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L427"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONCHECKED = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L428"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETSEL = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L429"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_HITTESTA = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L430"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIZ_QUERYNUMPAGES = <span class="tok-number">0x040A</span>;</span>
<span class="line" id="L431"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_INSERTITEMW = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L432"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETBANDINFOW = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L433"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETTEXTW = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONPRESSED = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L435"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETSELSTART = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L436"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTEXTA = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L437"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIZ_NEXT = <span class="tok-number">0x040B</span>;</span>
<span class="line" id="L438"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_SETITEMW = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L439"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBANDCOUNT = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L440"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTEXTLENGTHW = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L441"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONHIDDEN = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L442"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETSELEND = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L443"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_UPDATETIPTEXTA = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L444"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WIZ_PREV = <span class="tok-number">0x040C</span>;</span>
<span class="line" id="L445"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_GETITEMW = <span class="tok-number">0x040D</span>;</span>
<span class="line" id="L446"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETROWCOUNT = <span class="tok-number">0x040D</span>;</span>
<span class="line" id="L447"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTEXTW = <span class="tok-number">0x040D</span>;</span>
<span class="line" id="L448"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONINDETERMINATE = <span class="tok-number">0x040D</span>;</span>
<span class="line" id="L449"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTOOLCOUNT = <span class="tok-number">0x040D</span>;</span>
<span class="line" id="L450"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CBEM_SETEXTENDEDSTYLE = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L451"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETROWHEIGHT = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L452"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_ISSIMPLE = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L453"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ISBUTTONHIGHLIGHTED = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L454"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETPTICS = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L455"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ENUMTOOLSA = <span class="tok-number">0x040E</span>;</span>
<span class="line" id="L456"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETICON = <span class="tok-number">0x040F</span>;</span>
<span class="line" id="L457"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETTICPOS = <span class="tok-number">0x040F</span>;</span>
<span class="line" id="L458"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETCURRENTTOOLA = <span class="tok-number">0x040F</span>;</span>
<span class="line" id="L459"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_IDTOINDEX = <span class="tok-number">0x0410</span>;</span>
<span class="line" id="L460"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETTIPTEXTA = <span class="tok-number">0x0410</span>;</span>
<span class="line" id="L461"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETNUMTICS = <span class="tok-number">0x0410</span>;</span>
<span class="line" id="L462"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_WINDOWFROMPOINT = <span class="tok-number">0x0410</span>;</span>
<span class="line" id="L463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETTOOLTIPS = <span class="tok-number">0x0411</span>;</span>
<span class="line" id="L464"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_SETTIPTEXTW = <span class="tok-number">0x0411</span>;</span>
<span class="line" id="L465"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETSELSTART = <span class="tok-number">0x0411</span>;</span>
<span class="line" id="L466"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETSTATE = <span class="tok-number">0x0411</span>;</span>
<span class="line" id="L467"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_TRACKACTIVATE = <span class="tok-number">0x0411</span>;</span>
<span class="line" id="L468"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETTOOLTIPS = <span class="tok-number">0x0412</span>;</span>
<span class="line" id="L469"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTIPTEXTA = <span class="tok-number">0x0412</span>;</span>
<span class="line" id="L470"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETSTATE = <span class="tok-number">0x0412</span>;</span>
<span class="line" id="L471"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETSELEND = <span class="tok-number">0x0412</span>;</span>
<span class="line" id="L472"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_TRACKPOSITION = <span class="tok-number">0x0412</span>;</span>
<span class="line" id="L473"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETBKCOLOR = <span class="tok-number">0x0413</span>;</span>
<span class="line" id="L474"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETTIPTEXTW = <span class="tok-number">0x0413</span>;</span>
<span class="line" id="L475"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ADDBITMAP = <span class="tok-number">0x0413</span>;</span>
<span class="line" id="L476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_CLEARSEL = <span class="tok-number">0x0413</span>;</span>
<span class="line" id="L477"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTIPBKCOLOR = <span class="tok-number">0x0413</span>;</span>
<span class="line" id="L478"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBKCOLOR = <span class="tok-number">0x0414</span>;</span>
<span class="line" id="L479"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SB_GETICON = <span class="tok-number">0x0414</span>;</span>
<span class="line" id="L480"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ADDBUTTONSA = <span class="tok-number">0x0414</span>;</span>
<span class="line" id="L481"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETTICFREQ = <span class="tok-number">0x0414</span>;</span>
<span class="line" id="L482"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTIPTEXTCOLOR = <span class="tok-number">0x0414</span>;</span>
<span class="line" id="L483"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETTEXTCOLOR = <span class="tok-number">0x0415</span>;</span>
<span class="line" id="L484"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_INSERTBUTTONA = <span class="tok-number">0x0415</span>;</span>
<span class="line" id="L485"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETPAGESIZE = <span class="tok-number">0x0415</span>;</span>
<span class="line" id="L486"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETDELAYTIME = <span class="tok-number">0x0415</span>;</span>
<span class="line" id="L487"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETTEXTCOLOR = <span class="tok-number">0x0416</span>;</span>
<span class="line" id="L488"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_DELETEBUTTON = <span class="tok-number">0x0416</span>;</span>
<span class="line" id="L489"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETPAGESIZE = <span class="tok-number">0x0416</span>;</span>
<span class="line" id="L490"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTIPBKCOLOR = <span class="tok-number">0x0416</span>;</span>
<span class="line" id="L491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SIZETORECT = <span class="tok-number">0x0417</span>;</span>
<span class="line" id="L492"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTON = <span class="tok-number">0x0417</span>;</span>
<span class="line" id="L493"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETLINESIZE = <span class="tok-number">0x0417</span>;</span>
<span class="line" id="L494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTIPTEXTCOLOR = <span class="tok-number">0x0417</span>;</span>
<span class="line" id="L495"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_BEGINDRAG = <span class="tok-number">0x0418</span>;</span>
<span class="line" id="L496"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_BUTTONCOUNT = <span class="tok-number">0x0418</span>;</span>
<span class="line" id="L497"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETLINESIZE = <span class="tok-number">0x0418</span>;</span>
<span class="line" id="L498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETMAXTIPWIDTH = <span class="tok-number">0x0418</span>;</span>
<span class="line" id="L499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_ENDDRAG = <span class="tok-number">0x0419</span>;</span>
<span class="line" id="L500"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_COMMANDTOINDEX = <span class="tok-number">0x0419</span>;</span>
<span class="line" id="L501"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETTHUMBRECT = <span class="tok-number">0x0419</span>;</span>
<span class="line" id="L502"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETMAXTIPWIDTH = <span class="tok-number">0x0419</span>;</span>
<span class="line" id="L503"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_DRAGMOVE = <span class="tok-number">0x041A</span>;</span>
<span class="line" id="L504"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETCHANNELRECT = <span class="tok-number">0x041A</span>;</span>
<span class="line" id="L505"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SAVERESTOREA = <span class="tok-number">0x041A</span>;</span>
<span class="line" id="L506"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETMARGIN = <span class="tok-number">0x041A</span>;</span>
<span class="line" id="L507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBARHEIGHT = <span class="tok-number">0x041B</span>;</span>
<span class="line" id="L508"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_CUSTOMIZE = <span class="tok-number">0x041B</span>;</span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETTHUMBLENGTH = <span class="tok-number">0x041B</span>;</span>
<span class="line" id="L510"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETMARGIN = <span class="tok-number">0x041B</span>;</span>
<span class="line" id="L511"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBANDINFOW = <span class="tok-number">0x041C</span>;</span>
<span class="line" id="L512"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ADDSTRINGA = <span class="tok-number">0x041C</span>;</span>
<span class="line" id="L513"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETTHUMBLENGTH = <span class="tok-number">0x041C</span>;</span>
<span class="line" id="L514"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_POP = <span class="tok-number">0x041C</span>;</span>
<span class="line" id="L515"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBANDINFOA = <span class="tok-number">0x041D</span>;</span>
<span class="line" id="L516"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETITEMRECT = <span class="tok-number">0x041D</span>;</span>
<span class="line" id="L517"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETTOOLTIPS = <span class="tok-number">0x041D</span>;</span>
<span class="line" id="L518"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_UPDATE = <span class="tok-number">0x041D</span>;</span>
<span class="line" id="L519"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_MINIMIZEBAND = <span class="tok-number">0x041E</span>;</span>
<span class="line" id="L520"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_BUTTONSTRUCTSIZE = <span class="tok-number">0x041E</span>;</span>
<span class="line" id="L521"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETTOOLTIPS = <span class="tok-number">0x041E</span>;</span>
<span class="line" id="L522"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETBUBBLESIZE = <span class="tok-number">0x041E</span>;</span>
<span class="line" id="L523"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_MAXIMIZEBAND = <span class="tok-number">0x041F</span>;</span>
<span class="line" id="L524"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETTIPSIDE = <span class="tok-number">0x041F</span>;</span>
<span class="line" id="L525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETBUTTONSIZE = <span class="tok-number">0x041F</span>;</span>
<span class="line" id="L526"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ADJUSTRECT = <span class="tok-number">0x041F</span>;</span>
<span class="line" id="L527"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_SETBUDDY = <span class="tok-number">0x0420</span>;</span>
<span class="line" id="L528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETBITMAPSIZE = <span class="tok-number">0x0420</span>;</span>
<span class="line" id="L529"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTITLEA = <span class="tok-number">0x0420</span>;</span>
<span class="line" id="L530"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG_FTS_JUMP_VA = <span class="tok-number">0x0421</span>;</span>
<span class="line" id="L531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_AUTOSIZE = <span class="tok-number">0x0421</span>;</span>
<span class="line" id="L532"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TBM_GETBUDDY = <span class="tok-number">0x0421</span>;</span>
<span class="line" id="L533"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTITLEW = <span class="tok-number">0x0421</span>;</span>
<span class="line" id="L534"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETBANDBORDERS = <span class="tok-number">0x0422</span>;</span>
<span class="line" id="L535"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG_FTS_JUMP_QWORD = <span class="tok-number">0x0423</span>;</span>
<span class="line" id="L536"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SHOWBAND = <span class="tok-number">0x0423</span>;</span>
<span class="line" id="L537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETTOOLTIPS = <span class="tok-number">0x0423</span>;</span>
<span class="line" id="L538"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG_REINDEX_REQUEST = <span class="tok-number">0x0424</span>;</span>
<span class="line" id="L539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETTOOLTIPS = <span class="tok-number">0x0424</span>;</span>
<span class="line" id="L540"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG_FTS_WHERE_IS_IT = <span class="tok-number">0x0425</span>;</span>
<span class="line" id="L541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_SETPALETTE = <span class="tok-number">0x0425</span>;</span>
<span class="line" id="L542"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETPARENT = <span class="tok-number">0x0425</span>;</span>
<span class="line" id="L543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_GETPALETTE = <span class="tok-number">0x0426</span>;</span>
<span class="line" id="L544"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_MOVEBAND = <span class="tok-number">0x0427</span>;</span>
<span class="line" id="L545"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETROWS = <span class="tok-number">0x0427</span>;</span>
<span class="line" id="L546"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETROWS = <span class="tok-number">0x0428</span>;</span>
<span class="line" id="L547"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBITMAPFLAGS = <span class="tok-number">0x0429</span>;</span>
<span class="line" id="L548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETCMDID = <span class="tok-number">0x042A</span>;</span>
<span class="line" id="L549"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RB_PUSHCHEVRON = <span class="tok-number">0x042B</span>;</span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_CHANGEBITMAP = <span class="tok-number">0x042B</span>;</span>
<span class="line" id="L551"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBITMAP = <span class="tok-number">0x042C</span>;</span>
<span class="line" id="L552"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG_GET_DEFFONT = <span class="tok-number">0x042D</span>;</span>
<span class="line" id="L553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTONTEXTA = <span class="tok-number">0x042D</span>;</span>
<span class="line" id="L554"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_REPLACEBITMAP = <span class="tok-number">0x042E</span>;</span>
<span class="line" id="L555"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETINDENT = <span class="tok-number">0x042F</span>;</span>
<span class="line" id="L556"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETIMAGELIST = <span class="tok-number">0x0430</span>;</span>
<span class="line" id="L557"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETIMAGELIST = <span class="tok-number">0x0431</span>;</span>
<span class="line" id="L558"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_LOADIMAGES = <span class="tok-number">0x0432</span>;</span>
<span class="line" id="L559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_CANPASTE = <span class="tok-number">0x0432</span>;</span>
<span class="line" id="L560"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ADDTOOLW = <span class="tok-number">0x0432</span>;</span>
<span class="line" id="L561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_DISPLAYBAND = <span class="tok-number">0x0433</span>;</span>
<span class="line" id="L562"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETRECT = <span class="tok-number">0x0433</span>;</span>
<span class="line" id="L563"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_DELTOOLW = <span class="tok-number">0x0433</span>;</span>
<span class="line" id="L564"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_EXGETSEL = <span class="tok-number">0x0434</span>;</span>
<span class="line" id="L565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETHOTIMAGELIST = <span class="tok-number">0x0434</span>;</span>
<span class="line" id="L566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_NEWTOOLRECTW = <span class="tok-number">0x0434</span>;</span>
<span class="line" id="L567"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_EXLIMITTEXT = <span class="tok-number">0x0435</span>;</span>
<span class="line" id="L568"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETHOTIMAGELIST = <span class="tok-number">0x0435</span>;</span>
<span class="line" id="L569"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTOOLINFOW = <span class="tok-number">0x0435</span>;</span>
<span class="line" id="L570"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_EXLINEFROMCHAR = <span class="tok-number">0x0436</span>;</span>
<span class="line" id="L571"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETDISABLEDIMAGELIST = <span class="tok-number">0x0436</span>;</span>
<span class="line" id="L572"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_SETTOOLINFOW = <span class="tok-number">0x0436</span>;</span>
<span class="line" id="L573"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_EXSETSEL = <span class="tok-number">0x0437</span>;</span>
<span class="line" id="L574"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETDISABLEDIMAGELIST = <span class="tok-number">0x0437</span>;</span>
<span class="line" id="L575"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_HITTESTW = <span class="tok-number">0x0437</span>;</span>
<span class="line" id="L576"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FINDTEXT = <span class="tok-number">0x0438</span>;</span>
<span class="line" id="L577"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETSTYLE = <span class="tok-number">0x0438</span>;</span>
<span class="line" id="L578"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETTEXTW = <span class="tok-number">0x0438</span>;</span>
<span class="line" id="L579"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FORMATRANGE = <span class="tok-number">0x0439</span>;</span>
<span class="line" id="L580"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETSTYLE = <span class="tok-number">0x0439</span>;</span>
<span class="line" id="L581"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_UPDATETIPTEXTW = <span class="tok-number">0x0439</span>;</span>
<span class="line" id="L582"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETCHARFORMAT = <span class="tok-number">0x043A</span>;</span>
<span class="line" id="L583"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTONSIZE = <span class="tok-number">0x043A</span>;</span>
<span class="line" id="L584"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_ENUMTOOLSW = <span class="tok-number">0x043A</span>;</span>
<span class="line" id="L585"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETEVENTMASK = <span class="tok-number">0x043B</span>;</span>
<span class="line" id="L586"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETBUTTONWIDTH = <span class="tok-number">0x043B</span>;</span>
<span class="line" id="L587"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TTM_GETCURRENTTOOLW = <span class="tok-number">0x043B</span>;</span>
<span class="line" id="L588"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETOLEINTERFACE = <span class="tok-number">0x043C</span>;</span>
<span class="line" id="L589"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETMAXTEXTROWS = <span class="tok-number">0x043C</span>;</span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETPARAFORMAT = <span class="tok-number">0x043D</span>;</span>
<span class="line" id="L591"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETTEXTROWS = <span class="tok-number">0x043D</span>;</span>
<span class="line" id="L592"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETSELTEXT = <span class="tok-number">0x043E</span>;</span>
<span class="line" id="L593"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETOBJECT = <span class="tok-number">0x043E</span>;</span>
<span class="line" id="L594"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_HIDESELECTION = <span class="tok-number">0x043F</span>;</span>
<span class="line" id="L595"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTONINFOW = <span class="tok-number">0x043F</span>;</span>
<span class="line" id="L596"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_PASTESPECIAL = <span class="tok-number">0x0440</span>;</span>
<span class="line" id="L597"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETBUTTONINFOW = <span class="tok-number">0x0440</span>;</span>
<span class="line" id="L598"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_REQUESTRESIZE = <span class="tok-number">0x0441</span>;</span>
<span class="line" id="L599"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTONINFOA = <span class="tok-number">0x0441</span>;</span>
<span class="line" id="L600"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SELECTIONTYPE = <span class="tok-number">0x0442</span>;</span>
<span class="line" id="L601"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETBUTTONINFOA = <span class="tok-number">0x0442</span>;</span>
<span class="line" id="L602"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETBKGNDCOLOR = <span class="tok-number">0x0443</span>;</span>
<span class="line" id="L603"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_INSERTBUTTONW = <span class="tok-number">0x0443</span>;</span>
<span class="line" id="L604"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETCHARFORMAT = <span class="tok-number">0x0444</span>;</span>
<span class="line" id="L605"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ADDBUTTONSW = <span class="tok-number">0x0444</span>;</span>
<span class="line" id="L606"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETEVENTMASK = <span class="tok-number">0x0445</span>;</span>
<span class="line" id="L607"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_HITTEST = <span class="tok-number">0x0445</span>;</span>
<span class="line" id="L608"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETOLECALLBACK = <span class="tok-number">0x0446</span>;</span>
<span class="line" id="L609"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETDRAWTEXTFLAGS = <span class="tok-number">0x0446</span>;</span>
<span class="line" id="L610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPARAFORMAT = <span class="tok-number">0x0447</span>;</span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETHOTITEM = <span class="tok-number">0x0447</span>;</span>
<span class="line" id="L612"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETTARGETDEVICE = <span class="tok-number">0x0448</span>;</span>
<span class="line" id="L613"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETHOTITEM = <span class="tok-number">0x0448</span>;</span>
<span class="line" id="L614"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_STREAMIN = <span class="tok-number">0x0449</span>;</span>
<span class="line" id="L615"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETANCHORHIGHLIGHT = <span class="tok-number">0x0449</span>;</span>
<span class="line" id="L616"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_STREAMOUT = <span class="tok-number">0x044A</span>;</span>
<span class="line" id="L617"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETANCHORHIGHLIGHT = <span class="tok-number">0x044A</span>;</span>
<span class="line" id="L618"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTEXTRANGE = <span class="tok-number">0x044B</span>;</span>
<span class="line" id="L619"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETBUTTONTEXTW = <span class="tok-number">0x044B</span>;</span>
<span class="line" id="L620"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FINDWORDBREAK = <span class="tok-number">0x044C</span>;</span>
<span class="line" id="L621"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SAVERESTOREW = <span class="tok-number">0x044C</span>;</span>
<span class="line" id="L622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETOPTIONS = <span class="tok-number">0x044D</span>;</span>
<span class="line" id="L623"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_ADDSTRINGW = <span class="tok-number">0x044D</span>;</span>
<span class="line" id="L624"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETOPTIONS = <span class="tok-number">0x044E</span>;</span>
<span class="line" id="L625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_MAPACCELERATORA = <span class="tok-number">0x044E</span>;</span>
<span class="line" id="L626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FINDTEXTEX = <span class="tok-number">0x044F</span>;</span>
<span class="line" id="L627"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETINSERTMARK = <span class="tok-number">0x044F</span>;</span>
<span class="line" id="L628"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETWORDBREAKPROCEX = <span class="tok-number">0x0450</span>;</span>
<span class="line" id="L629"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETINSERTMARK = <span class="tok-number">0x0450</span>;</span>
<span class="line" id="L630"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETWORDBREAKPROCEX = <span class="tok-number">0x0451</span>;</span>
<span class="line" id="L631"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_INSERTMARKHITTEST = <span class="tok-number">0x0451</span>;</span>
<span class="line" id="L632"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETUNDOLIMIT = <span class="tok-number">0x0452</span>;</span>
<span class="line" id="L633"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_MOVEBUTTON = <span class="tok-number">0x0452</span>;</span>
<span class="line" id="L634"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETMAXSIZE = <span class="tok-number">0x0453</span>;</span>
<span class="line" id="L635"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_REDO = <span class="tok-number">0x0454</span>;</span>
<span class="line" id="L636"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETEXTENDEDSTYLE = <span class="tok-number">0x0454</span>;</span>
<span class="line" id="L637"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_CANREDO = <span class="tok-number">0x0455</span>;</span>
<span class="line" id="L638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETEXTENDEDSTYLE = <span class="tok-number">0x0455</span>;</span>
<span class="line" id="L639"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETUNDONAME = <span class="tok-number">0x0456</span>;</span>
<span class="line" id="L640"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETPADDING = <span class="tok-number">0x0456</span>;</span>
<span class="line" id="L641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETREDONAME = <span class="tok-number">0x0457</span>;</span>
<span class="line" id="L642"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETPADDING = <span class="tok-number">0x0457</span>;</span>
<span class="line" id="L643"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_STOPGROUPTYPING = <span class="tok-number">0x0458</span>;</span>
<span class="line" id="L644"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_SETINSERTMARKCOLOR = <span class="tok-number">0x0458</span>;</span>
<span class="line" id="L645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETTEXTMODE = <span class="tok-number">0x0459</span>;</span>
<span class="line" id="L646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETINSERTMARKCOLOR = <span class="tok-number">0x0459</span>;</span>
<span class="line" id="L647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTEXTMODE = <span class="tok-number">0x045A</span>;</span>
<span class="line" id="L648"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_MAPACCELERATORW = <span class="tok-number">0x045A</span>;</span>
<span class="line" id="L649"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_AUTOURLDETECT = <span class="tok-number">0x045B</span>;</span>
<span class="line" id="L650"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETSTRINGW = <span class="tok-number">0x045B</span>;</span>
<span class="line" id="L651"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETAUTOURLDETECT = <span class="tok-number">0x045C</span>;</span>
<span class="line" id="L652"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TB_GETSTRINGA = <span class="tok-number">0x045C</span>;</span>
<span class="line" id="L653"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPALETTE = <span class="tok-number">0x045D</span>;</span>
<span class="line" id="L654"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTEXTEX = <span class="tok-number">0x045E</span>;</span>
<span class="line" id="L655"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTEXTLENGTHEX = <span class="tok-number">0x045F</span>;</span>
<span class="line" id="L656"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SHOWSCROLLBAR = <span class="tok-number">0x0460</span>;</span>
<span class="line" id="L657"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETTEXTEX = <span class="tok-number">0x0461</span>;</span>
<span class="line" id="L658"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAPI_REPLY = <span class="tok-number">0x0463</span>;</span>
<span class="line" id="L659"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACM_OPENA = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L660"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BFFM_SETSTATUSTEXTA = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_GETSPEC = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L662"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPUNCTUATION = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L663"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_CLEARADDRESS = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L664"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_UNICODE_START = <span class="tok-number">0x0464</span>;</span>
<span class="line" id="L665"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACM_PLAY = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L666"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BFFM_ENABLEOK = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_GETFILEPATH = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L668"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETPUNCTUATION = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L669"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_SETADDRESS = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L670"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETCURSEL = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L671"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETRANGE = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L672"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHOOSEFONT_SETLOGFONT = <span class="tok-number">0x0465</span>;</span>
<span class="line" id="L673"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACM_STOP = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L674"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BFFM_SETSELECTIONA = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L675"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_GETFOLDERPATH = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L676"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETWORDWRAPMODE = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L677"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_GETADDRESS = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L678"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_REMOVEPAGE = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L679"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETRANGE = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L680"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_SET_CALLBACK_ERRORW = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L681"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CHOOSEFONT_SETFLAGS = <span class="tok-number">0x0466</span>;</span>
<span class="line" id="L682"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACM_OPENW = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L683"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BFFM_SETSELECTIONW = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L684"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_GETFOLDERIDLIST = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L685"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETWORDWRAPMODE = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L686"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_SETRANGE = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L687"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_ADDPAGE = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L688"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETPOS = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L689"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_SET_CALLBACK_STATUSW = <span class="tok-number">0x0467</span>;</span>
<span class="line" id="L690"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BFFM_SETSTATUSTEXTW = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L691"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_SETCONTROLTEXT = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L692"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETIMECOLOR = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L693"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_SETFOCUS = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L694"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_CHANGED = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L695"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETPOS = <span class="tok-number">0x0468</span>;</span>
<span class="line" id="L696"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_HIDECONTROL = <span class="tok-number">0x0469</span>;</span>
<span class="line" id="L697"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMECOLOR = <span class="tok-number">0x0469</span>;</span>
<span class="line" id="L698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPM_ISBLANK = <span class="tok-number">0x0469</span>;</span>
<span class="line" id="L699"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_RESTARTWINDOWS = <span class="tok-number">0x0469</span>;</span>
<span class="line" id="L700"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETBUDDY = <span class="tok-number">0x0469</span>;</span>
<span class="line" id="L701"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CDM_SETDEFEXT = <span class="tok-number">0x046A</span>;</span>
<span class="line" id="L702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETIMEOPTIONS = <span class="tok-number">0x046A</span>;</span>
<span class="line" id="L703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_REBOOTSYSTEM = <span class="tok-number">0x046A</span>;</span>
<span class="line" id="L704"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETBUDDY = <span class="tok-number">0x046A</span>;</span>
<span class="line" id="L705"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMEOPTIONS = <span class="tok-number">0x046B</span>;</span>
<span class="line" id="L706"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_CANCELTOCLOSE = <span class="tok-number">0x046B</span>;</span>
<span class="line" id="L707"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETACCEL = <span class="tok-number">0x046B</span>;</span>
<span class="line" id="L708"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_CONVPOSITION = <span class="tok-number">0x046C</span>;</span>
<span class="line" id="L709"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_QUERYSIBLINGS = <span class="tok-number">0x046C</span>;</span>
<span class="line" id="L710"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETACCEL = <span class="tok-number">0x046C</span>;</span>
<span class="line" id="L711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETZOOM = <span class="tok-number">0x046D</span>;</span>
<span class="line" id="L712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_UNCHANGED = <span class="tok-number">0x046D</span>;</span>
<span class="line" id="L713"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETBASE = <span class="tok-number">0x046D</span>;</span>
<span class="line" id="L714"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_APPLY = <span class="tok-number">0x046E</span>;</span>
<span class="line" id="L715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETBASE = <span class="tok-number">0x046E</span>;</span>
<span class="line" id="L716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETTITLEA = <span class="tok-number">0x046F</span>;</span>
<span class="line" id="L717"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETRANGE32 = <span class="tok-number">0x046F</span>;</span>
<span class="line" id="L718"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETWIZBUTTONS = <span class="tok-number">0x0470</span>;</span>
<span class="line" id="L719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETRANGE32 = <span class="tok-number">0x0470</span>;</span>
<span class="line" id="L720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_DRIVER_GET_NAMEW = <span class="tok-number">0x0470</span>;</span>
<span class="line" id="L721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_PRESSBUTTON = <span class="tok-number">0x0471</span>;</span>
<span class="line" id="L722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_SETPOS32 = <span class="tok-number">0x0471</span>;</span>
<span class="line" id="L723"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_DRIVER_GET_VERSIONW = <span class="tok-number">0x0471</span>;</span>
<span class="line" id="L724"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETCURSELID = <span class="tok-number">0x0472</span>;</span>
<span class="line" id="L725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDM_GETPOS32 = <span class="tok-number">0x0472</span>;</span>
<span class="line" id="L726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETFINISHTEXTA = <span class="tok-number">0x0473</span>;</span>
<span class="line" id="L727"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_GETTABCONTROL = <span class="tok-number">0x0474</span>;</span>
<span class="line" id="L728"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_ISDIALOGMESSAGE = <span class="tok-number">0x0475</span>;</span>
<span class="line" id="L729"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_REALIZE = <span class="tok-number">0x0476</span>;</span>
<span class="line" id="L730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_GETCURRENTPAGEHWND = <span class="tok-number">0x0476</span>;</span>
<span class="line" id="L731"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_SETTIMEFORMATA = <span class="tok-number">0x0477</span>;</span>
<span class="line" id="L732"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_INSERTPAGE = <span class="tok-number">0x0477</span>;</span>
<span class="line" id="L733"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETLANGOPTIONS = <span class="tok-number">0x0478</span>;</span>
<span class="line" id="L734"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETTIMEFORMATA = <span class="tok-number">0x0478</span>;</span>
<span class="line" id="L735"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETTITLEW = <span class="tok-number">0x0478</span>;</span>
<span class="line" id="L736"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_FILE_SET_CAPTURE_FILEW = <span class="tok-number">0x0478</span>;</span>
<span class="line" id="L737"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETLANGOPTIONS = <span class="tok-number">0x0479</span>;</span>
<span class="line" id="L738"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_VALIDATEMEDIA = <span class="tok-number">0x0479</span>;</span>
<span class="line" id="L739"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETFINISHTEXTW = <span class="tok-number">0x0479</span>;</span>
<span class="line" id="L740"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_FILE_GET_CAPTURE_FILEW = <span class="tok-number">0x0479</span>;</span>
<span class="line" id="L741"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMECOMPMODE = <span class="tok-number">0x047A</span>;</span>
<span class="line" id="L742"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FINDTEXTW = <span class="tok-number">0x047B</span>;</span>
<span class="line" id="L743"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_PLAYTO = <span class="tok-number">0x047B</span>;</span>
<span class="line" id="L744"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_FILE_SAVEASW = <span class="tok-number">0x047B</span>;</span>
<span class="line" id="L745"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_FINDTEXTEXW = <span class="tok-number">0x047C</span>;</span>
<span class="line" id="L746"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETFILENAMEA = <span class="tok-number">0x047C</span>;</span>
<span class="line" id="L747"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_RECONVERSION = <span class="tok-number">0x047D</span>;</span>
<span class="line" id="L748"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETDEVICEA = <span class="tok-number">0x047D</span>;</span>
<span class="line" id="L749"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETHEADERTITLEA = <span class="tok-number">0x047D</span>;</span>
<span class="line" id="L750"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_FILE_SAVEDIBW = <span class="tok-number">0x047D</span>;</span>
<span class="line" id="L751"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETIMEMODEBIAS = <span class="tok-number">0x047E</span>;</span>
<span class="line" id="L752"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETPALETTE = <span class="tok-number">0x047E</span>;</span>
<span class="line" id="L753"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETHEADERTITLEW = <span class="tok-number">0x047E</span>;</span>
<span class="line" id="L754"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMEMODEBIAS = <span class="tok-number">0x047F</span>;</span>
<span class="line" id="L755"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_SETPALETTE = <span class="tok-number">0x047F</span>;</span>
<span class="line" id="L756"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETHEADERSUBTITLEA = <span class="tok-number">0x047F</span>;</span>
<span class="line" id="L757"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETERRORA = <span class="tok-number">0x0480</span>;</span>
<span class="line" id="L758"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_SETHEADERSUBTITLEW = <span class="tok-number">0x0480</span>;</span>
<span class="line" id="L759"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_HWNDTOINDEX = <span class="tok-number">0x0481</span>;</span>
<span class="line" id="L760"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_INDEXTOHWND = <span class="tok-number">0x0482</span>;</span>
<span class="line" id="L761"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_SETINACTIVETIMER = <span class="tok-number">0x0483</span>;</span>
<span class="line" id="L762"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_PAGETOINDEX = <span class="tok-number">0x0483</span>;</span>
<span class="line" id="L763"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_INDEXTOPAGE = <span class="tok-number">0x0484</span>;</span>
<span class="line" id="L764"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DL_BEGINDRAG = <span class="tok-number">0x0485</span>;</span>
<span class="line" id="L765"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETINACTIVETIMER = <span class="tok-number">0x0485</span>;</span>
<span class="line" id="L766"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_IDTOINDEX = <span class="tok-number">0x0485</span>;</span>
<span class="line" id="L767"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DL_DRAGGING = <span class="tok-number">0x0486</span>;</span>
<span class="line" id="L768"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_INDEXTOID = <span class="tok-number">0x0486</span>;</span>
<span class="line" id="L769"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DL_DROPPED = <span class="tok-number">0x0487</span>;</span>
<span class="line" id="L770"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_GETRESULT = <span class="tok-number">0x0487</span>;</span>
<span class="line" id="L771"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DL_CANCELDRAG = <span class="tok-number">0x0488</span>;</span>
<span class="line" id="L772"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSM_RECALCPAGESIZES = <span class="tok-number">0x0488</span>;</span>
<span class="line" id="L773"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GET_SOURCE = <span class="tok-number">0x048C</span>;</span>
<span class="line" id="L774"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_PUT_SOURCE = <span class="tok-number">0x048D</span>;</span>
<span class="line" id="L775"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GET_DEST = <span class="tok-number">0x048E</span>;</span>
<span class="line" id="L776"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_PUT_DEST = <span class="tok-number">0x048F</span>;</span>
<span class="line" id="L777"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_PLAY = <span class="tok-number">0x0490</span>;</span>
<span class="line" id="L778"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_WINDOW = <span class="tok-number">0x0491</span>;</span>
<span class="line" id="L779"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_RECORD = <span class="tok-number">0x0492</span>;</span>
<span class="line" id="L780"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_SAVE = <span class="tok-number">0x0493</span>;</span>
<span class="line" id="L781"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_EJECT = <span class="tok-number">0x0494</span>;</span>
<span class="line" id="L782"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_CAN_CONFIG = <span class="tok-number">0x0495</span>;</span>
<span class="line" id="L783"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETINK = <span class="tok-number">0x0496</span>;</span>
<span class="line" id="L784"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_PALETTEKICK = <span class="tok-number">0x0496</span>;</span>
<span class="line" id="L785"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETINK = <span class="tok-number">0x0497</span>;</span>
<span class="line" id="L786"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETPENTIP = <span class="tok-number">0x0498</span>;</span>
<span class="line" id="L787"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETPENTIP = <span class="tok-number">0x0499</span>;</span>
<span class="line" id="L788"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETERASERTIP = <span class="tok-number">0x049A</span>;</span>
<span class="line" id="L789"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETERASERTIP = <span class="tok-number">0x049B</span>;</span>
<span class="line" id="L790"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETBKGND = <span class="tok-number">0x049C</span>;</span>
<span class="line" id="L791"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETBKGND = <span class="tok-number">0x049D</span>;</span>
<span class="line" id="L792"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETGRIDORIGIN = <span class="tok-number">0x049E</span>;</span>
<span class="line" id="L793"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETGRIDORIGIN = <span class="tok-number">0x049F</span>;</span>
<span class="line" id="L794"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETGRIDPEN = <span class="tok-number">0x04A0</span>;</span>
<span class="line" id="L795"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETGRIDPEN = <span class="tok-number">0x04A1</span>;</span>
<span class="line" id="L796"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETGRIDSIZE = <span class="tok-number">0x04A2</span>;</span>
<span class="line" id="L797"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETGRIDSIZE = <span class="tok-number">0x04A3</span>;</span>
<span class="line" id="L798"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETMODE = <span class="tok-number">0x04A4</span>;</span>
<span class="line" id="L799"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETMODE = <span class="tok-number">0x04A5</span>;</span>
<span class="line" id="L800"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETINKRECT = <span class="tok-number">0x04A6</span>;</span>
<span class="line" id="L801"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_SET_MCI_DEVICEW = <span class="tok-number">0x04A6</span>;</span>
<span class="line" id="L802"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_GET_MCI_DEVICEW = <span class="tok-number">0x04A7</span>;</span>
<span class="line" id="L803"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_PAL_OPENW = <span class="tok-number">0x04B4</span>;</span>
<span class="line" id="L804"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CAP_PAL_SAVEW = <span class="tok-number">0x04B5</span>;</span>
<span class="line" id="L805"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETAPPDATA = <span class="tok-number">0x04B8</span>;</span>
<span class="line" id="L806"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETAPPDATA = <span class="tok-number">0x04B9</span>;</span>
<span class="line" id="L807"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETDRAWOPTS = <span class="tok-number">0x04BA</span>;</span>
<span class="line" id="L808"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETDRAWOPTS = <span class="tok-number">0x04BB</span>;</span>
<span class="line" id="L809"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETFORMAT = <span class="tok-number">0x04BC</span>;</span>
<span class="line" id="L810"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETFORMAT = <span class="tok-number">0x04BD</span>;</span>
<span class="line" id="L811"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETINKINPUT = <span class="tok-number">0x04BE</span>;</span>
<span class="line" id="L812"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETINKINPUT = <span class="tok-number">0x04BF</span>;</span>
<span class="line" id="L813"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETNOTIFY = <span class="tok-number">0x04C0</span>;</span>
<span class="line" id="L814"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETNOTIFY = <span class="tok-number">0x04C1</span>;</span>
<span class="line" id="L815"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETRECOG = <span class="tok-number">0x04C2</span>;</span>
<span class="line" id="L816"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETRECOG = <span class="tok-number">0x04C3</span>;</span>
<span class="line" id="L817"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETSECURITY = <span class="tok-number">0x04C4</span>;</span>
<span class="line" id="L818"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETSECURITY = <span class="tok-number">0x04C5</span>;</span>
<span class="line" id="L819"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETSEL = <span class="tok-number">0x04C6</span>;</span>
<span class="line" id="L820"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_SETSEL = <span class="tok-number">0x04C7</span>;</span>
<span class="line" id="L821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETBIDIOPTIONS = <span class="tok-number">0x04C8</span>;</span>
<span class="line" id="L822"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_DOCOMMAND = <span class="tok-number">0x04C8</span>;</span>
<span class="line" id="L823"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_NOTIFYMODE = <span class="tok-number">0x04C8</span>;</span>
<span class="line" id="L824"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETBIDIOPTIONS = <span class="tok-number">0x04C9</span>;</span>
<span class="line" id="L825"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETCOMMAND = <span class="tok-number">0x04C9</span>;</span>
<span class="line" id="L826"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETTYPOGRAPHYOPTIONS = <span class="tok-number">0x04CA</span>;</span>
<span class="line" id="L827"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETCOUNT = <span class="tok-number">0x04CA</span>;</span>
<span class="line" id="L828"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETTYPOGRAPHYOPTIONS = <span class="tok-number">0x04CB</span>;</span>
<span class="line" id="L829"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETGESTURE = <span class="tok-number">0x04CB</span>;</span>
<span class="line" id="L830"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_NOTIFYMEDIA = <span class="tok-number">0x04CB</span>;</span>
<span class="line" id="L831"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETEDITSTYLE = <span class="tok-number">0x04CC</span>;</span>
<span class="line" id="L832"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETMENU = <span class="tok-number">0x04CC</span>;</span>
<span class="line" id="L833"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETEDITSTYLE = <span class="tok-number">0x04CD</span>;</span>
<span class="line" id="L834"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETPAINTDC = <span class="tok-number">0x04CD</span>;</span>
<span class="line" id="L835"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_NOTIFYERROR = <span class="tok-number">0x04CD</span>;</span>
<span class="line" id="L836"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETPDEVENT = <span class="tok-number">0x04CE</span>;</span>
<span class="line" id="L837"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETSELCOUNT = <span class="tok-number">0x04CF</span>;</span>
<span class="line" id="L838"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETSELITEMS = <span class="tok-number">0x04D0</span>;</span>
<span class="line" id="L839"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IE_GETSTYLE = <span class="tok-number">0x04D1</span>;</span>
<span class="line" id="L840"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_SETTIMEFORMATW = <span class="tok-number">0x04DB</span>;</span>
<span class="line" id="L841"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_OUTLINE = <span class="tok-number">0x04DC</span>;</span>
<span class="line" id="L842"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETTIMEFORMATW = <span class="tok-number">0x04DC</span>;</span>
<span class="line" id="L843"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETSCROLLPOS = <span class="tok-number">0x04DD</span>;</span>
<span class="line" id="L844"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETSCROLLPOS = <span class="tok-number">0x04DE</span>;</span>
<span class="line" id="L845"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETFONTSIZE = <span class="tok-number">0x04DF</span>;</span>
<span class="line" id="L846"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETZOOM = <span class="tok-number">0x04E0</span>;</span>
<span class="line" id="L847"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETFILENAMEW = <span class="tok-number">0x04E0</span>;</span>
<span class="line" id="L848"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETZOOM = <span class="tok-number">0x04E1</span>;</span>
<span class="line" id="L849"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETDEVICEW = <span class="tok-number">0x04E1</span>;</span>
<span class="line" id="L850"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETVIEWKIND = <span class="tok-number">0x04E2</span>;</span>
<span class="line" id="L851"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETVIEWKIND = <span class="tok-number">0x04E3</span>;</span>
<span class="line" id="L852"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETPAGE = <span class="tok-number">0x04E4</span>;</span>
<span class="line" id="L853"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCIWNDM_GETERRORW = <span class="tok-number">0x04E4</span>;</span>
<span class="line" id="L854"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPAGE = <span class="tok-number">0x04E5</span>;</span>
<span class="line" id="L855"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETHYPHENATEINFO = <span class="tok-number">0x04E6</span>;</span>
<span class="line" id="L856"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETHYPHENATEINFO = <span class="tok-number">0x04E7</span>;</span>
<span class="line" id="L857"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETPAGEROTATE = <span class="tok-number">0x04EB</span>;</span>
<span class="line" id="L858"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETPAGEROTATE = <span class="tok-number">0x04EC</span>;</span>
<span class="line" id="L859"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETCTFMODEBIAS = <span class="tok-number">0x04ED</span>;</span>
<span class="line" id="L860"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETCTFMODEBIAS = <span class="tok-number">0x04EE</span>;</span>
<span class="line" id="L861"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETCTFOPENSTATUS = <span class="tok-number">0x04F0</span>;</span>
<span class="line" id="L862"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETCTFOPENSTATUS = <span class="tok-number">0x04F1</span>;</span>
<span class="line" id="L863"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMECOMPTEXT = <span class="tok-number">0x04F2</span>;</span>
<span class="line" id="L864"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_ISIME = <span class="tok-number">0x04F3</span>;</span>
<span class="line" id="L865"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETIMEPROPERTY = <span class="tok-number">0x04F4</span>;</span>
<span class="line" id="L866"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_GETQUERYRTFOBJ = <span class="tok-number">0x050D</span>;</span>
<span class="line" id="L867"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM_SETQUERYRTFOBJ = <span class="tok-number">0x050E</span>;</span>
<span class="line" id="L868"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETFOCUS = <span class="tok-number">0x0600</span>;</span>
<span class="line" id="L869"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETDRIVEINFOA = <span class="tok-number">0x0601</span>;</span>
<span class="line" id="L870"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETSELCOUNT = <span class="tok-number">0x0602</span>;</span>
<span class="line" id="L871"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETSELCOUNTLFN = <span class="tok-number">0x0603</span>;</span>
<span class="line" id="L872"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETFILESELA = <span class="tok-number">0x0604</span>;</span>
<span class="line" id="L873"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETFILESELLFNA = <span class="tok-number">0x0605</span>;</span>
<span class="line" id="L874"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_REFRESH_WINDOWS = <span class="tok-number">0x0606</span>;</span>
<span class="line" id="L875"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_RELOAD_EXTENSIONS = <span class="tok-number">0x0607</span>;</span>
<span class="line" id="L876"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETDRIVEINFOW = <span class="tok-number">0x0611</span>;</span>
<span class="line" id="L877"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETFILESELW = <span class="tok-number">0x0614</span>;</span>
<span class="line" id="L878"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FM_GETFILESELLFNW = <span class="tok-number">0x0615</span>;</span>
<span class="line" id="L879"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WLX_WM_SAS = <span class="tok-number">0x0659</span>;</span>
<span class="line" id="L880"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETSELCOUNT = <span class="tok-number">0x07E8</span>;</span>
<span class="line" id="L881"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETSELCOUNT = <span class="tok-number">0x07E8</span>;</span>
<span class="line" id="L882"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CPL_LAUNCH = <span class="tok-number">0x07E8</span>;</span>
<span class="line" id="L883"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETSERVERSELA = <span class="tok-number">0x07E9</span>;</span>
<span class="line" id="L884"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETUSERSELA = <span class="tok-number">0x07E9</span>;</span>
<span class="line" id="L885"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_CPL_LAUNCHED = <span class="tok-number">0x07E9</span>;</span>
<span class="line" id="L886"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETSERVERSELW = <span class="tok-number">0x07EA</span>;</span>
<span class="line" id="L887"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETUSERSELW = <span class="tok-number">0x07EA</span>;</span>
<span class="line" id="L888"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETCURFOCUSA = <span class="tok-number">0x07EB</span>;</span>
<span class="line" id="L889"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETGROUPSELA = <span class="tok-number">0x07EB</span>;</span>
<span class="line" id="L890"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETCURFOCUSW = <span class="tok-number">0x07EC</span>;</span>
<span class="line" id="L891"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETGROUPSELW = <span class="tok-number">0x07EC</span>;</span>
<span class="line" id="L892"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SM_GETOPTIONS = <span class="tok-number">0x07ED</span>;</span>
<span class="line" id="L893"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETCURFOCUSA = <span class="tok-number">0x07ED</span>;</span>
<span class="line" id="L894"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETCURFOCUSW = <span class="tok-number">0x07EE</span>;</span>
<span class="line" id="L895"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETOPTIONS = <span class="tok-number">0x07EF</span>;</span>
<span class="line" id="L896"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UM_GETOPTIONS2 = <span class="tok-number">0x07F0</span>;</span>
<span class="line" id="L897"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETBKCOLOR = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L898"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETBKCOLOR = <span class="tok-number">0x1001</span>;</span>
<span class="line" id="L899"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETIMAGELIST = <span class="tok-number">0x1002</span>;</span>
<span class="line" id="L900"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETIMAGELIST = <span class="tok-number">0x1003</span>;</span>
<span class="line" id="L901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMCOUNT = <span class="tok-number">0x1004</span>;</span>
<span class="line" id="L902"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMA = <span class="tok-number">0x1005</span>;</span>
<span class="line" id="L903"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMA = <span class="tok-number">0x1006</span>;</span>
<span class="line" id="L904"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTITEMA = <span class="tok-number">0x1007</span>;</span>
<span class="line" id="L905"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_DELETEITEM = <span class="tok-number">0x1008</span>;</span>
<span class="line" id="L906"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_DELETEALLITEMS = <span class="tok-number">0x1009</span>;</span>
<span class="line" id="L907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCALLBACKMASK = <span class="tok-number">0x100A</span>;</span>
<span class="line" id="L908"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETCALLBACKMASK = <span class="tok-number">0x100B</span>;</span>
<span class="line" id="L909"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETNEXTITEM = <span class="tok-number">0x100C</span>;</span>
<span class="line" id="L910"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_FINDITEMA = <span class="tok-number">0x100D</span>;</span>
<span class="line" id="L911"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMRECT = <span class="tok-number">0x100E</span>;</span>
<span class="line" id="L912"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMPOSITION = <span class="tok-number">0x100F</span>;</span>
<span class="line" id="L913"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMPOSITION = <span class="tok-number">0x1010</span>;</span>
<span class="line" id="L914"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSTRINGWIDTHA = <span class="tok-number">0x1011</span>;</span>
<span class="line" id="L915"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_HITTEST = <span class="tok-number">0x1012</span>;</span>
<span class="line" id="L916"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_ENSUREVISIBLE = <span class="tok-number">0x1013</span>;</span>
<span class="line" id="L917"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SCROLL = <span class="tok-number">0x1014</span>;</span>
<span class="line" id="L918"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_REDRAWITEMS = <span class="tok-number">0x1015</span>;</span>
<span class="line" id="L919"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_ARRANGE = <span class="tok-number">0x1016</span>;</span>
<span class="line" id="L920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_EDITLABELA = <span class="tok-number">0x1017</span>;</span>
<span class="line" id="L921"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETEDITCONTROL = <span class="tok-number">0x1018</span>;</span>
<span class="line" id="L922"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCOLUMNA = <span class="tok-number">0x1019</span>;</span>
<span class="line" id="L923"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETCOLUMNA = <span class="tok-number">0x101A</span>;</span>
<span class="line" id="L924"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTCOLUMNA = <span class="tok-number">0x101B</span>;</span>
<span class="line" id="L925"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_DELETECOLUMN = <span class="tok-number">0x101C</span>;</span>
<span class="line" id="L926"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCOLUMNWIDTH = <span class="tok-number">0x101D</span>;</span>
<span class="line" id="L927"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETCOLUMNWIDTH = <span class="tok-number">0x101E</span>;</span>
<span class="line" id="L928"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETHEADER = <span class="tok-number">0x101F</span>;</span>
<span class="line" id="L929"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_CREATEDRAGIMAGE = <span class="tok-number">0x1021</span>;</span>
<span class="line" id="L930"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETVIEWRECT = <span class="tok-number">0x1022</span>;</span>
<span class="line" id="L931"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTEXTCOLOR = <span class="tok-number">0x1023</span>;</span>
<span class="line" id="L932"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTEXTCOLOR = <span class="tok-number">0x1024</span>;</span>
<span class="line" id="L933"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTEXTBKCOLOR = <span class="tok-number">0x1025</span>;</span>
<span class="line" id="L934"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTEXTBKCOLOR = <span class="tok-number">0x1026</span>;</span>
<span class="line" id="L935"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTOPINDEX = <span class="tok-number">0x1027</span>;</span>
<span class="line" id="L936"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCOUNTPERPAGE = <span class="tok-number">0x1028</span>;</span>
<span class="line" id="L937"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETORIGIN = <span class="tok-number">0x1029</span>;</span>
<span class="line" id="L938"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_UPDATE = <span class="tok-number">0x102A</span>;</span>
<span class="line" id="L939"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMSTATE = <span class="tok-number">0x102B</span>;</span>
<span class="line" id="L940"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMSTATE = <span class="tok-number">0x102C</span>;</span>
<span class="line" id="L941"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMTEXTA = <span class="tok-number">0x102D</span>;</span>
<span class="line" id="L942"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMTEXTA = <span class="tok-number">0x102E</span>;</span>
<span class="line" id="L943"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMCOUNT = <span class="tok-number">0x102F</span>;</span>
<span class="line" id="L944"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SORTITEMS = <span class="tok-number">0x1030</span>;</span>
<span class="line" id="L945"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMPOSITION32 = <span class="tok-number">0x1031</span>;</span>
<span class="line" id="L946"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSELECTEDCOUNT = <span class="tok-number">0x1032</span>;</span>
<span class="line" id="L947"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMSPACING = <span class="tok-number">0x1033</span>;</span>
<span class="line" id="L948"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETISEARCHSTRINGA = <span class="tok-number">0x1034</span>;</span>
<span class="line" id="L949"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETICONSPACING = <span class="tok-number">0x1035</span>;</span>
<span class="line" id="L950"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETEXTENDEDLISTVIEWSTYLE = <span class="tok-number">0x1036</span>;</span>
<span class="line" id="L951"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETEXTENDEDLISTVIEWSTYLE = <span class="tok-number">0x1037</span>;</span>
<span class="line" id="L952"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSUBITEMRECT = <span class="tok-number">0x1038</span>;</span>
<span class="line" id="L953"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SUBITEMHITTEST = <span class="tok-number">0x1039</span>;</span>
<span class="line" id="L954"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETCOLUMNORDERARRAY = <span class="tok-number">0x103A</span>;</span>
<span class="line" id="L955"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCOLUMNORDERARRAY = <span class="tok-number">0x103B</span>;</span>
<span class="line" id="L956"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETHOTITEM = <span class="tok-number">0x103C</span>;</span>
<span class="line" id="L957"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETHOTITEM = <span class="tok-number">0x103D</span>;</span>
<span class="line" id="L958"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETHOTCURSOR = <span class="tok-number">0x103E</span>;</span>
<span class="line" id="L959"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETHOTCURSOR = <span class="tok-number">0x103F</span>;</span>
<span class="line" id="L960"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_APPROXIMATEVIEWRECT = <span class="tok-number">0x1040</span>;</span>
<span class="line" id="L961"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETWORKAREAS = <span class="tok-number">0x1041</span>;</span>
<span class="line" id="L962"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSELECTIONMARK = <span class="tok-number">0x1042</span>;</span>
<span class="line" id="L963"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETSELECTIONMARK = <span class="tok-number">0x1043</span>;</span>
<span class="line" id="L964"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETBKIMAGEA = <span class="tok-number">0x1044</span>;</span>
<span class="line" id="L965"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETBKIMAGEA = <span class="tok-number">0x1045</span>;</span>
<span class="line" id="L966"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETWORKAREAS = <span class="tok-number">0x1046</span>;</span>
<span class="line" id="L967"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETHOVERTIME = <span class="tok-number">0x1047</span>;</span>
<span class="line" id="L968"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETHOVERTIME = <span class="tok-number">0x1048</span>;</span>
<span class="line" id="L969"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETNUMBEROFWORKAREAS = <span class="tok-number">0x1049</span>;</span>
<span class="line" id="L970"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTOOLTIPS = <span class="tok-number">0x104A</span>;</span>
<span class="line" id="L971"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMW = <span class="tok-number">0x104B</span>;</span>
<span class="line" id="L972"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMW = <span class="tok-number">0x104C</span>;</span>
<span class="line" id="L973"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTITEMW = <span class="tok-number">0x104D</span>;</span>
<span class="line" id="L974"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTOOLTIPS = <span class="tok-number">0x104E</span>;</span>
<span class="line" id="L975"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_FINDITEMW = <span class="tok-number">0x1053</span>;</span>
<span class="line" id="L976"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSTRINGWIDTHW = <span class="tok-number">0x1057</span>;</span>
<span class="line" id="L977"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETCOLUMNW = <span class="tok-number">0x105F</span>;</span>
<span class="line" id="L978"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETCOLUMNW = <span class="tok-number">0x1060</span>;</span>
<span class="line" id="L979"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTCOLUMNW = <span class="tok-number">0x1061</span>;</span>
<span class="line" id="L980"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETITEMTEXTW = <span class="tok-number">0x1073</span>;</span>
<span class="line" id="L981"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETITEMTEXTW = <span class="tok-number">0x1074</span>;</span>
<span class="line" id="L982"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETISEARCHSTRINGW = <span class="tok-number">0x1075</span>;</span>
<span class="line" id="L983"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_EDITLABELW = <span class="tok-number">0x1076</span>;</span>
<span class="line" id="L984"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETBKIMAGEW = <span class="tok-number">0x108B</span>;</span>
<span class="line" id="L985"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETSELECTEDCOLUMN = <span class="tok-number">0x108C</span>;</span>
<span class="line" id="L986"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTILEWIDTH = <span class="tok-number">0x108D</span>;</span>
<span class="line" id="L987"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETVIEW = <span class="tok-number">0x108E</span>;</span>
<span class="line" id="L988"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETVIEW = <span class="tok-number">0x108F</span>;</span>
<span class="line" id="L989"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTGROUP = <span class="tok-number">0x1091</span>;</span>
<span class="line" id="L990"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETGROUPINFO = <span class="tok-number">0x1093</span>;</span>
<span class="line" id="L991"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETGROUPINFO = <span class="tok-number">0x1095</span>;</span>
<span class="line" id="L992"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_REMOVEGROUP = <span class="tok-number">0x1096</span>;</span>
<span class="line" id="L993"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_MOVEGROUP = <span class="tok-number">0x1097</span>;</span>
<span class="line" id="L994"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_MOVEITEMTOGROUP = <span class="tok-number">0x109A</span>;</span>
<span class="line" id="L995"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETGROUPMETRICS = <span class="tok-number">0x109B</span>;</span>
<span class="line" id="L996"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETGROUPMETRICS = <span class="tok-number">0x109C</span>;</span>
<span class="line" id="L997"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_ENABLEGROUPVIEW = <span class="tok-number">0x109D</span>;</span>
<span class="line" id="L998"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SORTGROUPS = <span class="tok-number">0x109E</span>;</span>
<span class="line" id="L999"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTGROUPSORTED = <span class="tok-number">0x109F</span>;</span>
<span class="line" id="L1000"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_REMOVEALLGROUPS = <span class="tok-number">0x10A0</span>;</span>
<span class="line" id="L1001"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_HASGROUP = <span class="tok-number">0x10A1</span>;</span>
<span class="line" id="L1002"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTILEVIEWINFO = <span class="tok-number">0x10A2</span>;</span>
<span class="line" id="L1003"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTILEVIEWINFO = <span class="tok-number">0x10A3</span>;</span>
<span class="line" id="L1004"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETTILEINFO = <span class="tok-number">0x10A4</span>;</span>
<span class="line" id="L1005"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETTILEINFO = <span class="tok-number">0x10A5</span>;</span>
<span class="line" id="L1006"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETINSERTMARK = <span class="tok-number">0x10A6</span>;</span>
<span class="line" id="L1007"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETINSERTMARK = <span class="tok-number">0x10A7</span>;</span>
<span class="line" id="L1008"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_INSERTMARKHITTEST = <span class="tok-number">0x10A8</span>;</span>
<span class="line" id="L1009"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETINSERTMARKRECT = <span class="tok-number">0x10A9</span>;</span>
<span class="line" id="L1010"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETINSERTMARKCOLOR = <span class="tok-number">0x10AA</span>;</span>
<span class="line" id="L1011"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETINSERTMARKCOLOR = <span class="tok-number">0x10AB</span>;</span>
<span class="line" id="L1012"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETINFOTIP = <span class="tok-number">0x10AD</span>;</span>
<span class="line" id="L1013"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETSELECTEDCOLUMN = <span class="tok-number">0x10AE</span>;</span>
<span class="line" id="L1014"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_ISGROUPVIEWENABLED = <span class="tok-number">0x10AF</span>;</span>
<span class="line" id="L1015"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETOUTLINECOLOR = <span class="tok-number">0x10B0</span>;</span>
<span class="line" id="L1016"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETOUTLINECOLOR = <span class="tok-number">0x10B1</span>;</span>
<span class="line" id="L1017"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_CANCELEDITLABEL = <span class="tok-number">0x10B3</span>;</span>
<span class="line" id="L1018"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_MAPINDEXTOID = <span class="tok-number">0x10B4</span>;</span>
<span class="line" id="L1019"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_MAPIDTOINDEX = <span class="tok-number">0x10B5</span>;</span>
<span class="line" id="L1020"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_ISITEMVISIBLE = <span class="tok-number">0x10B6</span>;</span>
<span class="line" id="L1021"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM__BASE = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L1022"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_SETUNICODEFORMAT = <span class="tok-number">0x2005</span>;</span>
<span class="line" id="L1023"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LVM_GETUNICODEFORMAT = <span class="tok-number">0x2006</span>;</span>
<span class="line" id="L1024"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLOR = <span class="tok-number">0x2019</span>;</span>
<span class="line" id="L1025"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_DRAWITEM = <span class="tok-number">0x202B</span>;</span>
<span class="line" id="L1026"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_MEASUREITEM = <span class="tok-number">0x202C</span>;</span>
<span class="line" id="L1027"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_DELETEITEM = <span class="tok-number">0x202D</span>;</span>
<span class="line" id="L1028"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_VKEYTOITEM = <span class="tok-number">0x202E</span>;</span>
<span class="line" id="L1029"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CHARTOITEM = <span class="tok-number">0x202F</span>;</span>
<span class="line" id="L1030"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_COMPAREITEM = <span class="tok-number">0x2039</span>;</span>
<span class="line" id="L1031"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_NOTIFY = <span class="tok-number">0x204E</span>;</span>
<span class="line" id="L1032"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_COMMAND = <span class="tok-number">0x2111</span>;</span>
<span class="line" id="L1033"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_HSCROLL = <span class="tok-number">0x2114</span>;</span>
<span class="line" id="L1034"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_VSCROLL = <span class="tok-number">0x2115</span>;</span>
<span class="line" id="L1035"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORMSGBOX = <span class="tok-number">0x2132</span>;</span>
<span class="line" id="L1036"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLOREDIT = <span class="tok-number">0x2133</span>;</span>
<span class="line" id="L1037"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORLISTBOX = <span class="tok-number">0x2134</span>;</span>
<span class="line" id="L1038"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORBTN = <span class="tok-number">0x2135</span>;</span>
<span class="line" id="L1039"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORDLG = <span class="tok-number">0x2136</span>;</span>
<span class="line" id="L1040"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORSCROLLBAR = <span class="tok-number">0x2137</span>;</span>
<span class="line" id="L1041"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_CTLCOLORSTATIC = <span class="tok-number">0x2138</span>;</span>
<span class="line" id="L1042"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCM_PARENTNOTIFY = <span class="tok-number">0x2210</span>;</span>
<span class="line" id="L1043"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_APP = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L1044"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WM_RASDIALEVENT = <span class="tok-number">0xCCCD</span>;</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetMessageA</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1047"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getMessageA</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: <span class="tok-type">u32</span>, wMsgFilterMax: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1048">    <span class="tok-kw">const</span> r = GetMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax);</span>
<span class="line" id="L1049">    <span class="tok-kw">if</span> (r == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Quit;</span>
<span class="line" id="L1050">    <span class="tok-kw">if</span> (r != -<span class="tok-number">1</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1051">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1052">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1053">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1054">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1055">    }</span>
<span class="line" id="L1056">}</span>
<span class="line" id="L1057"></span>
<span class="line" id="L1058"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetMessageW</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1059"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnGetMessageW: <span class="tok-builtin">@TypeOf</span>(GetMessageW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1060"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getMessageW</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: <span class="tok-type">u32</span>, wMsgFilterMax: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1061">    <span class="tok-kw">const</span> function = selectSymbol(GetMessageW, pfnGetMessageW, .win2k);</span>
<span class="line" id="L1062"></span>
<span class="line" id="L1063">    <span class="tok-kw">const</span> r = function(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax);</span>
<span class="line" id="L1064">    <span class="tok-kw">if</span> (r == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Quit;</span>
<span class="line" id="L1065">    <span class="tok-kw">if</span> (r != -<span class="tok-number">1</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1066">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1067">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1068">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1069">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1070">    }</span>
<span class="line" id="L1071">}</span>
<span class="line" id="L1072"></span>
<span class="line" id="L1073"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PM_NOREMOVE = <span class="tok-number">0x0000</span>;</span>
<span class="line" id="L1074"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PM_REMOVE = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L1075"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PM_NOYIELD = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">PeekMessageA</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1078"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekMessageA</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: <span class="tok-type">u32</span>, wMsgFilterMax: <span class="tok-type">u32</span>, wRemoveMsg: <span class="tok-type">u32</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L1079">    <span class="tok-kw">const</span> r = PeekMessageA(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg);</span>
<span class="line" id="L1080">    <span class="tok-kw">if</span> (r == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1081">    <span class="tok-kw">if</span> (r != -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1082">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1083">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1084">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1085">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1086">    }</span>
<span class="line" id="L1087">}</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">PeekMessageW</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1090"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnPeekMessageW: <span class="tok-builtin">@TypeOf</span>(PeekMessageW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1091"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">peekMessageW</span>(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: <span class="tok-type">u32</span>, wMsgFilterMax: <span class="tok-type">u32</span>, wRemoveMsg: <span class="tok-type">u32</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L1092">    <span class="tok-kw">const</span> function = selectSymbol(PeekMessageW, pfnPeekMessageW, .win2k);</span>
<span class="line" id="L1093"></span>
<span class="line" id="L1094">    <span class="tok-kw">const</span> r = function(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg);</span>
<span class="line" id="L1095">    <span class="tok-kw">if</span> (r == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1096">    <span class="tok-kw">if</span> (r != -<span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1097">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1098">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1099">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1100">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1101">    }</span>
<span class="line" id="L1102">}</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TranslateMessage</span>(lpMsg: *<span class="tok-kw">const</span> MSG) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1105"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">translateMessage</span>(lpMsg: *<span class="tok-kw">const</span> MSG) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1106">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (TranslateMessage(lpMsg) == <span class="tok-number">0</span>) <span class="tok-null">false</span> <span class="tok-kw">else</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L1107">}</span>
<span class="line" id="L1108"></span>
<span class="line" id="L1109"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DispatchMessageA</span>(lpMsg: *<span class="tok-kw">const</span> MSG) <span class="tok-kw">callconv</span>(WINAPI) LRESULT;</span>
<span class="line" id="L1110"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dispatchMessageA</span>(lpMsg: *<span class="tok-kw">const</span> MSG) LRESULT {</span>
<span class="line" id="L1111">    <span class="tok-kw">return</span> DispatchMessageA(lpMsg);</span>
<span class="line" id="L1112">}</span>
<span class="line" id="L1113"></span>
<span class="line" id="L1114"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DispatchMessageW</span>(lpMsg: *<span class="tok-kw">const</span> MSG) <span class="tok-kw">callconv</span>(WINAPI) LRESULT;</span>
<span class="line" id="L1115"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnDispatchMessageW: <span class="tok-builtin">@TypeOf</span>(DispatchMessageW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1116"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dispatchMessageW</span>(lpMsg: *<span class="tok-kw">const</span> MSG) LRESULT {</span>
<span class="line" id="L1117">    <span class="tok-kw">const</span> function = selectSymbol(DispatchMessageW, pfnDispatchMessageW, .win2k);</span>
<span class="line" id="L1118">    <span class="tok-kw">return</span> function(lpMsg);</span>
<span class="line" id="L1119">}</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">PostQuitMessage</span>(nExitCode: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L1122"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">postQuitMessage</span>(nExitCode: <span class="tok-type">i32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L1123">    PostQuitMessage(nExitCode);</span>
<span class="line" id="L1124">}</span>
<span class="line" id="L1125"></span>
<span class="line" id="L1126"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DefWindowProcA</span>(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) <span class="tok-kw">callconv</span>(WINAPI) LRESULT;</span>
<span class="line" id="L1127"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defWindowProcA</span>(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) LRESULT {</span>
<span class="line" id="L1128">    <span class="tok-kw">return</span> DefWindowProcA(hWnd, Msg, wParam, lParam);</span>
<span class="line" id="L1129">}</span>
<span class="line" id="L1130"></span>
<span class="line" id="L1131"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DefWindowProcW</span>(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) <span class="tok-kw">callconv</span>(WINAPI) LRESULT;</span>
<span class="line" id="L1132"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnDefWindowProcW: <span class="tok-builtin">@TypeOf</span>(DefWindowProcW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1133"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">defWindowProcW</span>(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) LRESULT {</span>
<span class="line" id="L1134">    <span class="tok-kw">const</span> function = selectSymbol(DefWindowProcW, pfnDefWindowProcW, .win2k);</span>
<span class="line" id="L1135">    <span class="tok-kw">return</span> function(hWnd, Msg, wParam, lParam);</span>
<span class="line" id="L1136">}</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138"><span class="tok-comment">// === Windows ===</span>
</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_VREDRAW = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L1141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_HREDRAW = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L1142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_DBLCLKS = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L1143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_OWNDC = <span class="tok-number">0x0020</span>;</span>
<span class="line" id="L1144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_CLASSDC = <span class="tok-number">0x0040</span>;</span>
<span class="line" id="L1145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_PARENTDC = <span class="tok-number">0x0080</span>;</span>
<span class="line" id="L1146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_NOCLOSE = <span class="tok-number">0x0200</span>;</span>
<span class="line" id="L1147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_SAVEBITS = <span class="tok-number">0x0800</span>;</span>
<span class="line" id="L1148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_BYTEALIGNCLIENT = <span class="tok-number">0x1000</span>;</span>
<span class="line" id="L1149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_BYTEALIGNWINDOW = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L1150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CS_GLOBALCLASS = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WNDCLASSEXA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1153">    cbSize: UINT = <span class="tok-builtin">@sizeOf</span>(WNDCLASSEXA),</span>
<span class="line" id="L1154">    style: UINT,</span>
<span class="line" id="L1155">    lpfnWndProc: WNDPROC,</span>
<span class="line" id="L1156">    cbClsExtra: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1157">    cbWndExtra: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1158">    hInstance: HINSTANCE,</span>
<span class="line" id="L1159">    hIcon: ?HICON,</span>
<span class="line" id="L1160">    hCursor: ?HCURSOR,</span>
<span class="line" id="L1161">    hbrBackground: ?HBRUSH,</span>
<span class="line" id="L1162">    lpszMenuName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1163">    lpszClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1164">    hIconSm: ?HICON,</span>
<span class="line" id="L1165">};</span>
<span class="line" id="L1166"></span>
<span class="line" id="L1167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WNDCLASSEXW = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1168">    cbSize: UINT = <span class="tok-builtin">@sizeOf</span>(WNDCLASSEXW),</span>
<span class="line" id="L1169">    style: UINT,</span>
<span class="line" id="L1170">    lpfnWndProc: WNDPROC,</span>
<span class="line" id="L1171">    cbClsExtra: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1172">    cbWndExtra: <span class="tok-type">i32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L1173">    hInstance: HINSTANCE,</span>
<span class="line" id="L1174">    hIcon: ?HICON,</span>
<span class="line" id="L1175">    hCursor: ?HCURSOR,</span>
<span class="line" id="L1176">    hbrBackground: ?HBRUSH,</span>
<span class="line" id="L1177">    lpszMenuName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1178">    lpszClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1179">    hIconSm: ?HICON,</span>
<span class="line" id="L1180">};</span>
<span class="line" id="L1181"></span>
<span class="line" id="L1182"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RegisterClassExA</span>(*<span class="tok-kw">const</span> WNDCLASSEXA) <span class="tok-kw">callconv</span>(WINAPI) ATOM;</span>
<span class="line" id="L1183"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">registerClassExA</span>(window_class: *<span class="tok-kw">const</span> WNDCLASSEXA) !ATOM {</span>
<span class="line" id="L1184">    <span class="tok-kw">const</span> atom = RegisterClassExA(window_class);</span>
<span class="line" id="L1185">    <span class="tok-kw">if</span> (atom != <span class="tok-number">0</span>) <span class="tok-kw">return</span> atom;</span>
<span class="line" id="L1186">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1187">        .CLASS_ALREADY_EXISTS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AlreadyExists,</span>
<span class="line" id="L1188">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1189">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1190">    }</span>
<span class="line" id="L1191">}</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RegisterClassExW</span>(*<span class="tok-kw">const</span> WNDCLASSEXW) <span class="tok-kw">callconv</span>(WINAPI) ATOM;</span>
<span class="line" id="L1194"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnRegisterClassExW: <span class="tok-builtin">@TypeOf</span>(RegisterClassExW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1195"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">registerClassExW</span>(window_class: *<span class="tok-kw">const</span> WNDCLASSEXW) !ATOM {</span>
<span class="line" id="L1196">    <span class="tok-kw">const</span> function = selectSymbol(RegisterClassExW, pfnRegisterClassExW, .win2k);</span>
<span class="line" id="L1197">    <span class="tok-kw">const</span> atom = function(window_class);</span>
<span class="line" id="L1198">    <span class="tok-kw">if</span> (atom != <span class="tok-number">0</span>) <span class="tok-kw">return</span> atom;</span>
<span class="line" id="L1199">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1200">        .CLASS_ALREADY_EXISTS =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AlreadyExists,</span>
<span class="line" id="L1201">        .CALL_NOT_IMPLEMENTED =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1202">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1203">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1204">    }</span>
<span class="line" id="L1205">}</span>
<span class="line" id="L1206"></span>
<span class="line" id="L1207"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">UnregisterClassA</span>(lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, hInstance: HINSTANCE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1208"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregisterClassA</span>(lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, hInstance: HINSTANCE) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1209">    <span class="tok-kw">if</span> (UnregisterClassA(lpClassName, hInstance) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1210">        <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1211">            .CLASS_DOES_NOT_EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ClassDoesNotExist,</span>
<span class="line" id="L1212">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1213">        }</span>
<span class="line" id="L1214">    }</span>
<span class="line" id="L1215">}</span>
<span class="line" id="L1216"></span>
<span class="line" id="L1217"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">UnregisterClassW</span>(lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, hInstance: HINSTANCE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1218"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnUnregisterClassW: <span class="tok-builtin">@TypeOf</span>(UnregisterClassW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1219"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregisterClassW</span>(lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, hInstance: HINSTANCE) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1220">    <span class="tok-kw">const</span> function = selectSymbol(UnregisterClassW, pfnUnregisterClassW, .win2k);</span>
<span class="line" id="L1221">    <span class="tok-kw">if</span> (function(lpClassName, hInstance) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1222">        <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1223">            .CLASS_DOES_NOT_EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ClassDoesNotExist,</span>
<span class="line" id="L1224">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1225">        }</span>
<span class="line" id="L1226">    }</span>
<span class="line" id="L1227">}</span>
<span class="line" id="L1228"></span>
<span class="line" id="L1229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_OVERLAPPED = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_POPUP = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_CHILD = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1232"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_MINIMIZE = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L1233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_VISIBLE = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1234"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_DISABLED = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L1235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_CLIPSIBLINGS = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_CLIPCHILDREN = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L1237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_MAXIMIZE = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L1238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_CAPTION = WS_BORDER | WS_DLGFRAME;</span>
<span class="line" id="L1239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_BORDER = <span class="tok-number">0x00800000</span>;</span>
<span class="line" id="L1240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_DLGFRAME = <span class="tok-number">0x00400000</span>;</span>
<span class="line" id="L1241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_VSCROLL = <span class="tok-number">0x00200000</span>;</span>
<span class="line" id="L1242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_HSCROLL = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L1243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_SYSMENU = <span class="tok-number">0x00080000</span>;</span>
<span class="line" id="L1244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_THICKFRAME = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L1245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_GROUP = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L1246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_TABSTOP = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L1247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_MINIMIZEBOX = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L1248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_MAXIMIZEBOX = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L1249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_TILED = WS_OVERLAPPED;</span>
<span class="line" id="L1250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_ICONIC = WS_MINIMIZE;</span>
<span class="line" id="L1251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_SIZEBOX = WS_THICKFRAME;</span>
<span class="line" id="L1252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;</span>
<span class="line" id="L1253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;</span>
<span class="line" id="L1254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_POPUPWINDOW = WS_POPUP | WS_BORDER | WS_SYSMENU;</span>
<span class="line" id="L1255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_CHILDWINDOW = WS_CHILD;</span>
<span class="line" id="L1256"></span>
<span class="line" id="L1257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_DLGMODALFRAME = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L1258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_NOPARENTNOTIFY = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L1259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_TOPMOST = <span class="tok-number">0x00000008</span>;</span>
<span class="line" id="L1260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_ACCEPTFILES = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L1261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_TRANSPARENT = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L1262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_MDICHILD = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L1263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_TOOLWINDOW = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L1264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_WINDOWEDGE = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L1265"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_CLIENTEDGE = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L1266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_CONTEXTHELP = <span class="tok-number">0x00000400</span>;</span>
<span class="line" id="L1267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_RIGHT = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L1268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_LEFT = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_RTLREADING = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L1270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_LTRREADING = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_LEFTSCROLLBAR = <span class="tok-number">0x00004000</span>;</span>
<span class="line" id="L1272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_RIGHTSCROLLBAR = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_CONTROLPARENT = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L1274"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_STATICEDGE = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L1275"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_APPWINDOW = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L1276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_LAYERED = <span class="tok-number">0x00080000</span>;</span>
<span class="line" id="L1277"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_OVERLAPPEDWINDOW = WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE;</span>
<span class="line" id="L1278"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WS_EX_PALETTEWINDOW = WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST;</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CW_USEDEFAULT = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x80000000</span>));</span>
<span class="line" id="L1281"></span>
<span class="line" id="L1282"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateWindowExA</span>(dwExStyle: DWORD, lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, lpWindowName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dwStyle: DWORD, X: <span class="tok-type">i32</span>, Y: <span class="tok-type">i32</span>, nWidth: <span class="tok-type">i32</span>, nHeight: <span class="tok-type">i32</span>, hWindParent: ?HWND, hMenu: ?HMENU, hInstance: HINSTANCE, lpParam: ?LPVOID) <span class="tok-kw">callconv</span>(WINAPI) ?HWND;</span>
<span class="line" id="L1283"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createWindowExA</span>(dwExStyle: <span class="tok-type">u32</span>, lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, lpWindowName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dwStyle: <span class="tok-type">u32</span>, X: <span class="tok-type">i32</span>, Y: <span class="tok-type">i32</span>, nWidth: <span class="tok-type">i32</span>, nHeight: <span class="tok-type">i32</span>, hWindParent: ?HWND, hMenu: ?HMENU, hInstance: HINSTANCE, lpParam: ?*<span class="tok-type">anyopaque</span>) !HWND {</span>
<span class="line" id="L1284">    <span class="tok-kw">const</span> window = CreateWindowExA(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWindParent, hMenu, hInstance, lpParam);</span>
<span class="line" id="L1285">    <span class="tok-kw">if</span> (window) |win| <span class="tok-kw">return</span> win;</span>
<span class="line" id="L1286"></span>
<span class="line" id="L1287">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1288">        .CLASS_DOES_NOT_EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ClassDoesNotExist,</span>
<span class="line" id="L1289">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1290">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1291">    }</span>
<span class="line" id="L1292">}</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">CreateWindowExW</span>(dwExStyle: DWORD, lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpWindowName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, dwStyle: DWORD, X: <span class="tok-type">i32</span>, Y: <span class="tok-type">i32</span>, nWidth: <span class="tok-type">i32</span>, nHeight: <span class="tok-type">i32</span>, hWindParent: ?HWND, hMenu: ?HMENU, hInstance: HINSTANCE, lpParam: ?LPVOID) <span class="tok-kw">callconv</span>(WINAPI) ?HWND;</span>
<span class="line" id="L1295"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnCreateWindowExW: <span class="tok-builtin">@TypeOf</span>(CreateWindowExW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1296"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createWindowExW</span>(dwExStyle: <span class="tok-type">u32</span>, lpClassName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpWindowName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, dwStyle: <span class="tok-type">u32</span>, X: <span class="tok-type">i32</span>, Y: <span class="tok-type">i32</span>, nWidth: <span class="tok-type">i32</span>, nHeight: <span class="tok-type">i32</span>, hWindParent: ?HWND, hMenu: ?HMENU, hInstance: HINSTANCE, lpParam: ?*<span class="tok-type">anyopaque</span>) !HWND {</span>
<span class="line" id="L1297">    <span class="tok-kw">const</span> function = selectSymbol(CreateWindowExW, pfnCreateWindowExW, .win2k);</span>
<span class="line" id="L1298">    <span class="tok-kw">const</span> window = function(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWindParent, hMenu, hInstance, lpParam);</span>
<span class="line" id="L1299">    <span class="tok-kw">if</span> (window) |win| <span class="tok-kw">return</span> win;</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1302">        .CLASS_DOES_NOT_EXIST =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ClassDoesNotExist,</span>
<span class="line" id="L1303">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1304">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1305">    }</span>
<span class="line" id="L1306">}</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">DestroyWindow</span>(hWnd: HWND) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1309"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroyWindow</span>(hWnd: HWND) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1310">    <span class="tok-kw">if</span> (DestroyWindow(hWnd) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1311">        <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1312">            .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1313">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1314">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1315">        }</span>
<span class="line" id="L1316">    }</span>
<span class="line" id="L1317">}</span>
<span class="line" id="L1318"></span>
<span class="line" id="L1319"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_HIDE = <span class="tok-number">0</span>;</span>
<span class="line" id="L1320"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWNORMAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L1321"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_NORMAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L1322"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWMINIMIZED = <span class="tok-number">2</span>;</span>
<span class="line" id="L1323"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWMAXIMIZED = <span class="tok-number">3</span>;</span>
<span class="line" id="L1324"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_MAXIMIZE = <span class="tok-number">3</span>;</span>
<span class="line" id="L1325"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWNOACTIVATE = <span class="tok-number">4</span>;</span>
<span class="line" id="L1326"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOW = <span class="tok-number">5</span>;</span>
<span class="line" id="L1327"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_MINIMIZE = <span class="tok-number">6</span>;</span>
<span class="line" id="L1328"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWMINNOACTIVE = <span class="tok-number">7</span>;</span>
<span class="line" id="L1329"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWNA = <span class="tok-number">8</span>;</span>
<span class="line" id="L1330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_RESTORE = <span class="tok-number">9</span>;</span>
<span class="line" id="L1331"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_SHOWDEFAULT = <span class="tok-number">10</span>;</span>
<span class="line" id="L1332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_FORCEMINIMIZE = <span class="tok-number">11</span>;</span>
<span class="line" id="L1333"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SW_MAX = <span class="tok-number">11</span>;</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ShowWindow</span>(hWnd: HWND, nCmdShow: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1336"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">showWindow</span>(hWnd: HWND, nCmdShow: <span class="tok-type">i32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1337">    <span class="tok-kw">return</span> (ShowWindow(hWnd, nCmdShow) == TRUE);</span>
<span class="line" id="L1338">}</span>
<span class="line" id="L1339"></span>
<span class="line" id="L1340"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">UpdateWindow</span>(hWnd: HWND) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1341"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateWindow</span>(hWnd: HWND) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1342">    <span class="tok-kw">if</span> (UpdateWindow(hWnd) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1343">        <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1344">            .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1345">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1346">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1347">        }</span>
<span class="line" id="L1348">    }</span>
<span class="line" id="L1349">}</span>
<span class="line" id="L1350"></span>
<span class="line" id="L1351"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">AdjustWindowRectEx</span>(lpRect: *RECT, dwStyle: DWORD, bMenu: BOOL, dwExStyle: DWORD) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1352"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">adjustWindowRectEx</span>(lpRect: *RECT, dwStyle: <span class="tok-type">u32</span>, bMenu: <span class="tok-type">bool</span>, dwExStyle: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1353">    assert(dwStyle &amp; WS_OVERLAPPED == <span class="tok-number">0</span>);</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355">    <span class="tok-kw">if</span> (AdjustWindowRectEx(lpRect, dwStyle, <span class="tok-builtin">@boolToInt</span>(bMenu), dwExStyle) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L1356">        <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1357">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1358">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1359">        }</span>
<span class="line" id="L1360">    }</span>
<span class="line" id="L1361">}</span>
<span class="line" id="L1362"></span>
<span class="line" id="L1363"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_WNDPROC = -<span class="tok-number">4</span>;</span>
<span class="line" id="L1364"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_HINSTANCE = -<span class="tok-number">6</span>;</span>
<span class="line" id="L1365"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_HWNDPARENT = -<span class="tok-number">8</span>;</span>
<span class="line" id="L1366"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_STYLE = -<span class="tok-number">16</span>;</span>
<span class="line" id="L1367"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_EXSTYLE = -<span class="tok-number">20</span>;</span>
<span class="line" id="L1368"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_USERDATA = -<span class="tok-number">21</span>;</span>
<span class="line" id="L1369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GWL_ID = -<span class="tok-number">12</span>;</span>
<span class="line" id="L1370"></span>
<span class="line" id="L1371"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetWindowLongA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) LONG;</span>
<span class="line" id="L1372"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getWindowLongA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1373">    <span class="tok-kw">const</span> value = GetWindowLongA(hWnd, nIndex);</span>
<span class="line" id="L1374">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1375"></span>
<span class="line" id="L1376">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1377">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1378">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1379">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1380">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1381">    }</span>
<span class="line" id="L1382">}</span>
<span class="line" id="L1383"></span>
<span class="line" id="L1384"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetWindowLongW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) LONG;</span>
<span class="line" id="L1385"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnGetWindowLongW: <span class="tok-builtin">@TypeOf</span>(GetWindowLongW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1386"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getWindowLongW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1387">    <span class="tok-kw">const</span> function = selectSymbol(GetWindowLongW, pfnGetWindowLongW, .win2k);</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389">    <span class="tok-kw">const</span> value = function(hWnd, nIndex);</span>
<span class="line" id="L1390">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1393">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1394">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1395">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1396">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1397">    }</span>
<span class="line" id="L1398">}</span>
<span class="line" id="L1399"></span>
<span class="line" id="L1400"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetWindowLongPtrA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) LONG_PTR;</span>
<span class="line" id="L1401"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getWindowLongPtrA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) !<span class="tok-type">isize</span> {</span>
<span class="line" id="L1402">    <span class="tok-comment">// &quot;When compiling for 32-bit Windows, GetWindowLongPtr is defined as a call to the GetWindowLong function.&quot;</span>
</span>
<span class="line" id="L1403">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongptrw</span>
</span>
<span class="line" id="L1404">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(LONG_PTR) == <span class="tok-number">4</span>) <span class="tok-kw">return</span> getWindowLongA(hWnd, nIndex);</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">    <span class="tok-kw">const</span> value = GetWindowLongPtrA(hWnd, nIndex);</span>
<span class="line" id="L1407">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1408"></span>
<span class="line" id="L1409">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1410">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1411">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1412">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1413">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1414">    }</span>
<span class="line" id="L1415">}</span>
<span class="line" id="L1416"></span>
<span class="line" id="L1417"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetWindowLongPtrW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) LONG_PTR;</span>
<span class="line" id="L1418"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnGetWindowLongPtrW: <span class="tok-builtin">@TypeOf</span>(GetWindowLongPtrW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1419"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getWindowLongPtrW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>) !<span class="tok-type">isize</span> {</span>
<span class="line" id="L1420">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(LONG_PTR) == <span class="tok-number">4</span>) <span class="tok-kw">return</span> getWindowLongW(hWnd, nIndex);</span>
<span class="line" id="L1421">    <span class="tok-kw">const</span> function = selectSymbol(GetWindowLongPtrW, pfnGetWindowLongPtrW, .win2k);</span>
<span class="line" id="L1422"></span>
<span class="line" id="L1423">    <span class="tok-kw">const</span> value = function(hWnd, nIndex);</span>
<span class="line" id="L1424">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1425"></span>
<span class="line" id="L1426">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1427">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1428">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1429">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1430">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1431">    }</span>
<span class="line" id="L1432">}</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetWindowLongA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: LONG) <span class="tok-kw">callconv</span>(WINAPI) LONG;</span>
<span class="line" id="L1435"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWindowLongA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: <span class="tok-type">i32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1436">    <span class="tok-comment">// [...] you should clear the last error information by calling SetLastError with 0 before calling SetWindowLong.</span>
</span>
<span class="line" id="L1437">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowlonga</span>
</span>
<span class="line" id="L1438">    SetLastError(.SUCCESS);</span>
<span class="line" id="L1439"></span>
<span class="line" id="L1440">    <span class="tok-kw">const</span> value = SetWindowLongA(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1441">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1442"></span>
<span class="line" id="L1443">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1444">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1445">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1446">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1447">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1448">    }</span>
<span class="line" id="L1449">}</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetWindowLongW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: LONG) <span class="tok-kw">callconv</span>(WINAPI) LONG;</span>
<span class="line" id="L1452"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnSetWindowLongW: <span class="tok-builtin">@TypeOf</span>(SetWindowLongW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1453"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWindowLongW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: <span class="tok-type">i32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1454">    <span class="tok-kw">const</span> function = selectSymbol(SetWindowLongW, pfnSetWindowLongW, .win2k);</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456">    SetLastError(.SUCCESS);</span>
<span class="line" id="L1457">    <span class="tok-kw">const</span> value = function(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1458">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1461">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1462">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1463">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1464">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1465">    }</span>
<span class="line" id="L1466">}</span>
<span class="line" id="L1467"></span>
<span class="line" id="L1468"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetWindowLongPtrA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: LONG_PTR) <span class="tok-kw">callconv</span>(WINAPI) LONG_PTR;</span>
<span class="line" id="L1469"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWindowLongPtrA</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: <span class="tok-type">isize</span>) !<span class="tok-type">isize</span> {</span>
<span class="line" id="L1470">    <span class="tok-comment">// &quot;When compiling for 32-bit Windows, GetWindowLongPtr is defined as a call to the GetWindowLong function.&quot;</span>
</span>
<span class="line" id="L1471">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongptrw</span>
</span>
<span class="line" id="L1472">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(LONG_PTR) == <span class="tok-number">4</span>) <span class="tok-kw">return</span> setWindowLongA(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1473"></span>
<span class="line" id="L1474">    SetLastError(.SUCCESS);</span>
<span class="line" id="L1475">    <span class="tok-kw">const</span> value = SetWindowLongPtrA(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1476">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1477"></span>
<span class="line" id="L1478">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1479">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1480">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1481">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1482">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1483">    }</span>
<span class="line" id="L1484">}</span>
<span class="line" id="L1485"></span>
<span class="line" id="L1486"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SetWindowLongPtrW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: LONG_PTR) <span class="tok-kw">callconv</span>(WINAPI) LONG_PTR;</span>
<span class="line" id="L1487"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnSetWindowLongPtrW: <span class="tok-builtin">@TypeOf</span>(SetWindowLongPtrW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1488"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setWindowLongPtrW</span>(hWnd: HWND, nIndex: <span class="tok-type">i32</span>, dwNewLong: <span class="tok-type">isize</span>) !<span class="tok-type">isize</span> {</span>
<span class="line" id="L1489">    <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(LONG_PTR) == <span class="tok-number">4</span>) <span class="tok-kw">return</span> setWindowLongW(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1490">    <span class="tok-kw">const</span> function = selectSymbol(SetWindowLongPtrW, pfnSetWindowLongPtrW, .win2k);</span>
<span class="line" id="L1491"></span>
<span class="line" id="L1492">    SetLastError(.SUCCESS);</span>
<span class="line" id="L1493">    <span class="tok-kw">const</span> value = function(hWnd, nIndex, dwNewLong);</span>
<span class="line" id="L1494">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1495"></span>
<span class="line" id="L1496">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1497">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L1498">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1499">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1500">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1501">    }</span>
<span class="line" id="L1502">}</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetDC</span>(hWnd: ?HWND) <span class="tok-kw">callconv</span>(WINAPI) ?HDC;</span>
<span class="line" id="L1505"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getDC</span>(hWnd: ?HWND) !HDC {</span>
<span class="line" id="L1506">    <span class="tok-kw">const</span> hdc = GetDC(hWnd);</span>
<span class="line" id="L1507">    <span class="tok-kw">if</span> (hdc) |h| <span class="tok-kw">return</span> h;</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1510">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1511">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1512">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1513">    }</span>
<span class="line" id="L1514">}</span>
<span class="line" id="L1515"></span>
<span class="line" id="L1516"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ReleaseDC</span>(hWnd: ?HWND, hDC: HDC) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1517"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">releaseDC</span>(hWnd: ?HWND, hDC: HDC) <span class="tok-type">bool</span> {</span>
<span class="line" id="L1518">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (ReleaseDC(hWnd, hDC) == <span class="tok-number">1</span>) <span class="tok-null">true</span> <span class="tok-kw">else</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L1519">}</span>
<span class="line" id="L1520"></span>
<span class="line" id="L1521"><span class="tok-comment">// === Modal dialogue boxes ===</span>
</span>
<span class="line" id="L1522"></span>
<span class="line" id="L1523"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_OK = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1524"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_OKCANCEL = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L1525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ABORTRETRYIGNORE = <span class="tok-number">0x00000002</span>;</span>
<span class="line" id="L1526"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_YESNOCANCEL = <span class="tok-number">0x00000003</span>;</span>
<span class="line" id="L1527"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_YESNO = <span class="tok-number">0x00000004</span>;</span>
<span class="line" id="L1528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_RETRYCANCEL = <span class="tok-number">0x00000005</span>;</span>
<span class="line" id="L1529"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_CANCELTRYCONTINUE = <span class="tok-number">0x00000006</span>;</span>
<span class="line" id="L1530"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONHAND = <span class="tok-number">0x00000010</span>;</span>
<span class="line" id="L1531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONQUESTION = <span class="tok-number">0x00000020</span>;</span>
<span class="line" id="L1532"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONEXCLAMATION = <span class="tok-number">0x00000030</span>;</span>
<span class="line" id="L1533"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONASTERISK = <span class="tok-number">0x00000040</span>;</span>
<span class="line" id="L1534"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_USERICON = <span class="tok-number">0x00000080</span>;</span>
<span class="line" id="L1535"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONWARNING = MB_ICONEXCLAMATION;</span>
<span class="line" id="L1536"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONERROR = MB_ICONHAND;</span>
<span class="line" id="L1537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONINFORMATION = MB_ICONASTERISK;</span>
<span class="line" id="L1538"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONSTOP = MB_ICONHAND;</span>
<span class="line" id="L1539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFBUTTON1 = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1540"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFBUTTON2 = <span class="tok-number">0x00000100</span>;</span>
<span class="line" id="L1541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFBUTTON3 = <span class="tok-number">0x00000200</span>;</span>
<span class="line" id="L1542"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFBUTTON4 = <span class="tok-number">0x00000300</span>;</span>
<span class="line" id="L1543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_APPLMODAL = <span class="tok-number">0x00000000</span>;</span>
<span class="line" id="L1544"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_SYSTEMMODAL = <span class="tok-number">0x00001000</span>;</span>
<span class="line" id="L1545"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_TASKMODAL = <span class="tok-number">0x00002000</span>;</span>
<span class="line" id="L1546"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_HELP = <span class="tok-number">0x00004000</span>;</span>
<span class="line" id="L1547"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_NOFOCUS = <span class="tok-number">0x00008000</span>;</span>
<span class="line" id="L1548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_SETFOREGROUND = <span class="tok-number">0x00010000</span>;</span>
<span class="line" id="L1549"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFAULT_DESKTOP_ONLY = <span class="tok-number">0x00020000</span>;</span>
<span class="line" id="L1550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_TOPMOST = <span class="tok-number">0x00040000</span>;</span>
<span class="line" id="L1551"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_RIGHT = <span class="tok-number">0x00080000</span>;</span>
<span class="line" id="L1552"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_RTLREADING = <span class="tok-number">0x00100000</span>;</span>
<span class="line" id="L1553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_TYPEMASK = <span class="tok-number">0x0000000F</span>;</span>
<span class="line" id="L1554"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_ICONMASK = <span class="tok-number">0x000000F0</span>;</span>
<span class="line" id="L1555"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_DEFMASK = <span class="tok-number">0x00000F00</span>;</span>
<span class="line" id="L1556"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_MODEMASK = <span class="tok-number">0x00003000</span>;</span>
<span class="line" id="L1557"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MB_MISCMASK = <span class="tok-number">0x0000C000</span>;</span>
<span class="line" id="L1558"></span>
<span class="line" id="L1559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDOK = <span class="tok-number">1</span>;</span>
<span class="line" id="L1560"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDCANCEL = <span class="tok-number">2</span>;</span>
<span class="line" id="L1561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDABORT = <span class="tok-number">3</span>;</span>
<span class="line" id="L1562"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDRETRY = <span class="tok-number">4</span>;</span>
<span class="line" id="L1563"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDIGNORE = <span class="tok-number">5</span>;</span>
<span class="line" id="L1564"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDYES = <span class="tok-number">6</span>;</span>
<span class="line" id="L1565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDNO = <span class="tok-number">7</span>;</span>
<span class="line" id="L1566"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDCLOSE = <span class="tok-number">8</span>;</span>
<span class="line" id="L1567"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDHELP = <span class="tok-number">9</span>;</span>
<span class="line" id="L1568"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDTRYAGAIN = <span class="tok-number">10</span>;</span>
<span class="line" id="L1569"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDCONTINUE = <span class="tok-number">11</span>;</span>
<span class="line" id="L1570"></span>
<span class="line" id="L1571"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">MessageBoxA</span>(hWnd: ?HWND, lpText: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, lpCaption: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, uType: UINT) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1572"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">messageBoxA</span>(hWnd: ?HWND, lpText: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, lpCaption: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, uType: <span class="tok-type">u32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1573">    <span class="tok-kw">const</span> value = MessageBoxA(hWnd, lpText, lpCaption, uType);</span>
<span class="line" id="L1574">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1575">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1576">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1577">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1578">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1579">    }</span>
<span class="line" id="L1580">}</span>
<span class="line" id="L1581"></span>
<span class="line" id="L1582"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;user32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">MessageBoxW</span>(hWnd: ?HWND, lpText: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpCaption: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, uType: UINT) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1583"><span class="tok-kw">pub</span> <span class="tok-kw">var</span> pfnMessageBoxW: <span class="tok-builtin">@TypeOf</span>(MessageBoxW) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1584"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">messageBoxW</span>(hWnd: ?HWND, lpText: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, lpCaption: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, uType: <span class="tok-type">u32</span>) !<span class="tok-type">i32</span> {</span>
<span class="line" id="L1585">    <span class="tok-kw">const</span> function = selectSymbol(MessageBoxW, pfnMessageBoxW, .win2k);</span>
<span class="line" id="L1586">    <span class="tok-kw">const</span> value = function(hWnd, lpText, lpCaption, uType);</span>
<span class="line" id="L1587">    <span class="tok-kw">if</span> (value != <span class="tok-number">0</span>) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L1588">    <span class="tok-kw">switch</span> (GetLastError()) {</span>
<span class="line" id="L1589">        .INVALID_WINDOW_HANDLE =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1590">        .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1591">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1592">    }</span>
<span class="line" id="L1593">}</span>
<span class="line" id="L1594"></span>
</code></pre></body>
</html>