<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/simple_text_output_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.uefi;</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Character output devices</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleTextOutputProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    _reset: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L8">    _output_string: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _test_string: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    _query_mode: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">usize</span>, *<span class="tok-type">usize</span>, *<span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _set_mode: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _set_attribute: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _clear_screen: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _set_cursor_position: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _enable_cursor: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextOutputProtocol, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    mode: *SimpleTextOutputMode,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-comment">/// Resets the text output device hardware.</span></span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, verify: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L20">        <span class="tok-kw">return</span> self._reset(self, verify);</span>
<span class="line" id="L21">    }</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// Writes a string to the output device.</span></span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">outputString</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, msg: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) Status {</span>
<span class="line" id="L25">        <span class="tok-kw">return</span> self._output_string(self, msg);</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-comment">/// Verifies that all characters in a string can be output to the target device.</span></span>
<span class="line" id="L29">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testString</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, msg: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) Status {</span>
<span class="line" id="L30">        <span class="tok-kw">return</span> self._test_string(self, msg);</span>
<span class="line" id="L31">    }</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-comment">/// Returns information for an available text mode that the output device(s) supports.</span></span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">queryMode</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, mode_number: <span class="tok-type">usize</span>, columns: *<span class="tok-type">usize</span>, rows: *<span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> self._query_mode(self, mode_number, columns, rows);</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-comment">/// Sets the output device(s) to a specified mode.</span></span>
<span class="line" id="L39">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMode</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, mode_number: <span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L40">        <span class="tok-kw">return</span> self._set_mode(self, mode_number);</span>
<span class="line" id="L41">    }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-comment">/// Sets the background and foreground colors for the outputString() and clearScreen() functions.</span></span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setAttribute</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, attribute: <span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> self._set_attribute(self, attribute);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-comment">/// Clears the output device(s) display to the currently selected background color.</span></span>
<span class="line" id="L49">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">clearScreen</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol) Status {</span>
<span class="line" id="L50">        <span class="tok-kw">return</span> self._clear_screen(self);</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Sets the current coordinates of the cursor position.</span></span>
<span class="line" id="L54">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setCursorPosition</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, column: <span class="tok-type">usize</span>, row: <span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L55">        <span class="tok-kw">return</span> self._set_cursor_position(self, column, row);</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-comment">/// Makes the cursor visible or invisible.</span></span>
<span class="line" id="L59">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">enableCursor</span>(self: *<span class="tok-kw">const</span> SimpleTextOutputProtocol, visible: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L60">        <span class="tok-kw">return</span> self._enable_cursor(self, visible);</span>
<span class="line" id="L61">    }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L64">        .time_low = <span class="tok-number">0x387477c2</span>,</span>
<span class="line" id="L65">        .time_mid = <span class="tok-number">0x69c7</span>,</span>
<span class="line" id="L66">        .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L67">        .clock_seq_high_and_reserved = <span class="tok-number">0x8e</span>,</span>
<span class="line" id="L68">        .clock_seq_low = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L69">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3b</span> },</span>
<span class="line" id="L70">    };</span>
<span class="line" id="L71">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2500</span>;</span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical: <span class="tok-type">u16</span> = <span class="tok-number">0x2502</span>;</span>
<span class="line" id="L73">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_right: <span class="tok-type">u16</span> = <span class="tok-number">0x250c</span>;</span>
<span class="line" id="L74">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2510</span>;</span>
<span class="line" id="L75">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_right: <span class="tok-type">u16</span> = <span class="tok-number">0x2514</span>;</span>
<span class="line" id="L76">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2518</span>;</span>
<span class="line" id="L77">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_right: <span class="tok-type">u16</span> = <span class="tok-number">0x251c</span>;</span>
<span class="line" id="L78">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2524</span>;</span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x252c</span>;</span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2534</span>;</span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x253c</span>;</span>
<span class="line" id="L82">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2550</span>;</span>
<span class="line" id="L83">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_vertical: <span class="tok-type">u16</span> = <span class="tok-number">0x2551</span>;</span>
<span class="line" id="L84">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_right_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2552</span>;</span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_double_right: <span class="tok-type">u16</span> = <span class="tok-number">0x2553</span>;</span>
<span class="line" id="L86">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_down_right: <span class="tok-type">u16</span> = <span class="tok-number">0x2554</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_left_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2555</span>;</span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_double_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2556</span>;</span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_down_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2557</span>;</span>
<span class="line" id="L90">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_right_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2558</span>;</span>
<span class="line" id="L91">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_double_right: <span class="tok-type">u16</span> = <span class="tok-number">0x2559</span>;</span>
<span class="line" id="L92">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_up_right: <span class="tok-type">u16</span> = <span class="tok-number">0x255a</span>;</span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_left_double: <span class="tok-type">u16</span> = <span class="tok-number">0x255b</span>;</span>
<span class="line" id="L94">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_double_left: <span class="tok-type">u16</span> = <span class="tok-number">0x255c</span>;</span>
<span class="line" id="L95">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_up_left: <span class="tok-type">u16</span> = <span class="tok-number">0x255d</span>;</span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_right_double: <span class="tok-type">u16</span> = <span class="tok-number">0x255e</span>;</span>
<span class="line" id="L97">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_double_right: <span class="tok-type">u16</span> = <span class="tok-number">0x255f</span>;</span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_vertical_right: <span class="tok-type">u16</span> = <span class="tok-number">0x2560</span>;</span>
<span class="line" id="L99">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_left_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2561</span>;</span>
<span class="line" id="L100">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_double_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2562</span>;</span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_vertical_left: <span class="tok-type">u16</span> = <span class="tok-number">0x2563</span>;</span>
<span class="line" id="L102">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_horizontal_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2564</span>;</span>
<span class="line" id="L103">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_down_double_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2565</span>;</span>
<span class="line" id="L104">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_down_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2566</span>;</span>
<span class="line" id="L105">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_horizontal_double: <span class="tok-type">u16</span> = <span class="tok-number">0x2567</span>;</span>
<span class="line" id="L106">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_up_double_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2568</span>;</span>
<span class="line" id="L107">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_up_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x2569</span>;</span>
<span class="line" id="L108">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_horizontal_double: <span class="tok-type">u16</span> = <span class="tok-number">0x256a</span>;</span>
<span class="line" id="L109">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_vertical_double_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x256b</span>;</span>
<span class="line" id="L110">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> boxdraw_double_vertical_horizontal: <span class="tok-type">u16</span> = <span class="tok-number">0x256c</span>;</span>
<span class="line" id="L111">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> blockelement_full_block: <span class="tok-type">u16</span> = <span class="tok-number">0x2588</span>;</span>
<span class="line" id="L112">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> blockelement_light_shade: <span class="tok-type">u16</span> = <span class="tok-number">0x2591</span>;</span>
<span class="line" id="L113">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> geometricshape_up_triangle: <span class="tok-type">u16</span> = <span class="tok-number">0x25b2</span>;</span>
<span class="line" id="L114">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> geometricshape_right_triangle: <span class="tok-type">u16</span> = <span class="tok-number">0x25ba</span>;</span>
<span class="line" id="L115">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> geometricshape_down_triangle: <span class="tok-type">u16</span> = <span class="tok-number">0x25bc</span>;</span>
<span class="line" id="L116">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> geometricshape_left_triangle: <span class="tok-type">u16</span> = <span class="tok-number">0x25c4</span>;</span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> arrow_up: <span class="tok-type">u16</span> = <span class="tok-number">0x2591</span>;</span>
<span class="line" id="L118">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> arrow_down: <span class="tok-type">u16</span> = <span class="tok-number">0x2593</span>;</span>
<span class="line" id="L119">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> black: <span class="tok-type">u8</span> = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L120">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> blue: <span class="tok-type">u8</span> = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> green: <span class="tok-type">u8</span> = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L122">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> cyan: <span class="tok-type">u8</span> = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L123">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> red: <span class="tok-type">u8</span> = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L124">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> magenta: <span class="tok-type">u8</span> = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L125">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> brown: <span class="tok-type">u8</span> = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightgray: <span class="tok-type">u8</span> = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L127">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> bright: <span class="tok-type">u8</span> = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L128">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> darkgray: <span class="tok-type">u8</span> = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L129">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightblue: <span class="tok-type">u8</span> = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightgreen: <span class="tok-type">u8</span> = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L131">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightcyan: <span class="tok-type">u8</span> = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L132">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightred: <span class="tok-type">u8</span> = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L133">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> lightmagenta: <span class="tok-type">u8</span> = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> yellow: <span class="tok-type">u8</span> = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> white: <span class="tok-type">u8</span> = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L136">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_black: <span class="tok-type">u8</span> = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L137">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_blue: <span class="tok-type">u8</span> = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_green: <span class="tok-type">u8</span> = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L139">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_cyan: <span class="tok-type">u8</span> = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L140">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_red: <span class="tok-type">u8</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L141">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_magenta: <span class="tok-type">u8</span> = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L142">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_brown: <span class="tok-type">u8</span> = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> background_lightgray: <span class="tok-type">u8</span> = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L144">};</span>
<span class="line" id="L145"></span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleTextOutputMode = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L147">    max_mode: <span class="tok-type">u32</span>, <span class="tok-comment">// specified as signed</span>
</span>
<span class="line" id="L148">    mode: <span class="tok-type">u32</span>, <span class="tok-comment">// specified as signed</span>
</span>
<span class="line" id="L149">    attribute: <span class="tok-type">i32</span>,</span>
<span class="line" id="L150">    cursor_column: <span class="tok-type">i32</span>,</span>
<span class="line" id="L151">    cursor_row: <span class="tok-type">i32</span>,</span>
<span class="line" id="L152">    cursor_visible: <span class="tok-type">bool</span>,</span>
<span class="line" id="L153">};</span>
<span class="line" id="L154"></span>
</code></pre></body>
</html>