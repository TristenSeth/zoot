<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/simple_text_input_ex_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Character input devices, e.g. Keyboard</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SimpleTextInputExProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    _reset: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextInputExProtocol, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _read_key_stroke_ex: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextInputExProtocol, *KeyData) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    wait_for_key_ex: Event,</span>
<span class="line" id="L11">    _set_state: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextInputExProtocol, *<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _register_key_notify: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextInputExProtocol, *<span class="tok-kw">const</span> KeyData, <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> KeyData) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span>, **<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _unregister_key_notify: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> SimpleTextInputExProtocol, *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-comment">/// Resets the input device hardware.</span></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *<span class="tok-kw">const</span> SimpleTextInputExProtocol, verify: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L17">        <span class="tok-kw">return</span> self._reset(self, verify);</span>
<span class="line" id="L18">    }</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-comment">/// Reads the next keystroke from the input device.</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readKeyStrokeEx</span>(self: *<span class="tok-kw">const</span> SimpleTextInputExProtocol, key_data: *KeyData) Status {</span>
<span class="line" id="L22">        <span class="tok-kw">return</span> self._read_key_stroke_ex(self, key_data);</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">/// Set certain state for the input device.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setState</span>(self: *<span class="tok-kw">const</span> SimpleTextInputExProtocol, state: *<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> self._set_state(self, state);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Register a notification function for a particular keystroke for the input device.</span></span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">registerKeyNotify</span>(self: *<span class="tok-kw">const</span> SimpleTextInputExProtocol, key_data: *<span class="tok-kw">const</span> KeyData, notify: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> KeyData) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">usize</span>, handle: **<span class="tok-type">anyopaque</span>) Status {</span>
<span class="line" id="L32">        <span class="tok-kw">return</span> self._register_key_notify(self, key_data, notify, handle);</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Remove the notification that was previously registered.</span></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unregisterKeyNotify</span>(self: *<span class="tok-kw">const</span> SimpleTextInputExProtocol, handle: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) Status {</span>
<span class="line" id="L37">        <span class="tok-kw">return</span> self._unregister_key_notify(self, handle);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L41">        .time_low = <span class="tok-number">0xdd9e7534</span>,</span>
<span class="line" id="L42">        .time_mid = <span class="tok-number">0x7762</span>,</span>
<span class="line" id="L43">        .time_high_and_version = <span class="tok-number">0x4698</span>,</span>
<span class="line" id="L44">        .clock_seq_high_and_reserved = <span class="tok-number">0x8c</span>,</span>
<span class="line" id="L45">        .clock_seq_low = <span class="tok-number">0x14</span>,</span>
<span class="line" id="L46">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xf5</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0xa6</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0xaa</span> },</span>
<span class="line" id="L47">    };</span>
<span class="line" id="L48">};</span>
<span class="line" id="L49"></span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L51">    key: InputKey = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L52">    key_state: KeyState = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L53">};</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyState = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L56">    key_shift_state: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L57">        right_shift_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L58">        left_shift_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L59">        right_control_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L60">        left_control_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L61">        right_alt_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L62">        left_alt_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L63">        right_logo_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L64">        left_logo_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L65">        menu_key_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L66">        sys_req_pressed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L67">        _pad: <span class="tok-type">u21</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L68">        shift_state_valid: <span class="tok-type">bool</span>,</span>
<span class="line" id="L69">    },</span>
<span class="line" id="L70">    key_toggle_state: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L71">        scroll_lock_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L72">        num_lock_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L73">        caps_lock_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L74">        _pad: <span class="tok-type">u3</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L75">        key_state_exposed: <span class="tok-type">bool</span>,</span>
<span class="line" id="L76">        toggle_state_valid: <span class="tok-type">bool</span>,</span>
<span class="line" id="L77">    },</span>
<span class="line" id="L78">};</span>
<span class="line" id="L79"></span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InputKey = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">    scan_code: <span class="tok-type">u16</span>,</span>
<span class="line" id="L82">    unicode_char: <span class="tok-type">u16</span>,</span>
<span class="line" id="L83">};</span>
<span class="line" id="L84"></span>
</code></pre></body>
</html>