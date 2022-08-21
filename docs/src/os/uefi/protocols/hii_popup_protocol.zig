<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/hii_popup_protocol.zig - source view</title>
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
<span class="line" id="L4"><span class="tok-kw">const</span> hii = uefi.protocols.hii;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Display a popup window</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPopupProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    revision: <span class="tok-type">u64</span>,</span>
<span class="line" id="L9">    _create_popup: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> HIIPopupProtocol, HIIPopupStyle, HIIPopupType, hii.HIIHandle, <span class="tok-type">u16</span>, ?*HIIPopupSelection) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-comment">/// Displays a popup window.</span></span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createPopup</span>(self: *<span class="tok-kw">const</span> HIIPopupProtocol, style: HIIPopupStyle, popup_type: HIIPopupType, handle: hii.HIIHandle, msg: <span class="tok-type">u16</span>, user_selection: ?*HIIPopupSelection) Status {</span>
<span class="line" id="L13">        <span class="tok-kw">return</span> self._create_popup(self, style, popup_type, handle, msg, user_selection);</span>
<span class="line" id="L14">    }</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L17">        .time_low = <span class="tok-number">0x4311edc0</span>,</span>
<span class="line" id="L18">        .time_mid = <span class="tok-number">0x6054</span>,</span>
<span class="line" id="L19">        .time_high_and_version = <span class="tok-number">0x46d4</span>,</span>
<span class="line" id="L20">        .clock_seq_high_and_reserved = <span class="tok-number">0x9e</span>,</span>
<span class="line" id="L21">        .clock_seq_low = <span class="tok-number">0x40</span>,</span>
<span class="line" id="L22">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x89</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0xcc</span> },</span>
<span class="line" id="L23">    };</span>
<span class="line" id="L24">};</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPopupStyle = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L27">    Info,</span>
<span class="line" id="L28">    Warning,</span>
<span class="line" id="L29">    Error,</span>
<span class="line" id="L30">};</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPopupType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L33">    Ok,</span>
<span class="line" id="L34">    Cancel,</span>
<span class="line" id="L35">    YesNo,</span>
<span class="line" id="L36">    YesNoCancel,</span>
<span class="line" id="L37">};</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPopupSelection = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L40">    Ok,</span>
<span class="line" id="L41">    Cancel,</span>
<span class="line" id="L42">    Yes,</span>
<span class="line" id="L43">    No,</span>
<span class="line" id="L44">};</span>
<span class="line" id="L45"></span>
</code></pre></body>
</html>