<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/graphics_output_protocol.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-comment">/// Graphics output</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsOutputProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    _query_mode: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> GraphicsOutputProtocol, <span class="tok-type">u32</span>, *<span class="tok-type">usize</span>, **GraphicsOutputModeInformation) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L8">    _set_mode: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> GraphicsOutputProtocol, <span class="tok-type">u32</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _blt: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> GraphicsOutputProtocol, ?[*]GraphicsOutputBltPixel, GraphicsOutputBltOperation, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    mode: *GraphicsOutputProtocolMode,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-comment">/// Returns information for an available graphics mode that the graphics device and the set of active video output devices supports.</span></span>
<span class="line" id="L13">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">queryMode</span>(self: *<span class="tok-kw">const</span> GraphicsOutputProtocol, mode: <span class="tok-type">u32</span>, size_of_info: *<span class="tok-type">usize</span>, info: **GraphicsOutputModeInformation) Status {</span>
<span class="line" id="L14">        <span class="tok-kw">return</span> self._query_mode(self, mode, size_of_info, info);</span>
<span class="line" id="L15">    }</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-comment">/// Set the video device into the specified mode and clears the visible portions of the output display to black.</span></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMode</span>(self: *<span class="tok-kw">const</span> GraphicsOutputProtocol, mode: <span class="tok-type">u32</span>) Status {</span>
<span class="line" id="L19">        <span class="tok-kw">return</span> self._set_mode(self, mode);</span>
<span class="line" id="L20">    }</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    <span class="tok-comment">/// Blt a rectangle of pixels on the graphics screen. Blt stands for BLock Transfer.</span></span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">blt</span>(self: *<span class="tok-kw">const</span> GraphicsOutputProtocol, blt_buffer: ?[*]GraphicsOutputBltPixel, blt_operation: GraphicsOutputBltOperation, source_x: <span class="tok-type">usize</span>, source_y: <span class="tok-type">usize</span>, destination_x: <span class="tok-type">usize</span>, destination_y: <span class="tok-type">usize</span>, width: <span class="tok-type">usize</span>, height: <span class="tok-type">usize</span>, delta: <span class="tok-type">usize</span>) Status {</span>
<span class="line" id="L24">        <span class="tok-kw">return</span> self._blt(self, blt_buffer, blt_operation, source_x, source_y, destination_x, destination_y, width, height, delta);</span>
<span class="line" id="L25">    }</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L28">        .time_low = <span class="tok-number">0x9042a9de</span>,</span>
<span class="line" id="L29">        .time_mid = <span class="tok-number">0x23dc</span>,</span>
<span class="line" id="L30">        .time_high_and_version = <span class="tok-number">0x4a38</span>,</span>
<span class="line" id="L31">        .clock_seq_high_and_reserved = <span class="tok-number">0x96</span>,</span>
<span class="line" id="L32">        .clock_seq_low = <span class="tok-number">0xfb</span>,</span>
<span class="line" id="L33">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7a</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xd0</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x6a</span> },</span>
<span class="line" id="L34">    };</span>
<span class="line" id="L35">};</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsOutputProtocolMode = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L38">    max_mode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L39">    mode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L40">    info: *GraphicsOutputModeInformation,</span>
<span class="line" id="L41">    size_of_info: <span class="tok-type">usize</span>,</span>
<span class="line" id="L42">    frame_buffer_base: <span class="tok-type">u64</span>,</span>
<span class="line" id="L43">    frame_buffer_size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L44">};</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsOutputModeInformation = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L47">    version: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L48">    horizontal_resolution: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L49">    vertical_resolution: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L50">    pixel_format: GraphicsPixelFormat = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L51">    pixel_information: PixelBitmask = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L52">    pixels_per_scan_line: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L53">};</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsPixelFormat = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L56">    PixelRedGreenBlueReserved8BitPerColor,</span>
<span class="line" id="L57">    PixelBlueGreenRedReserved8BitPerColor,</span>
<span class="line" id="L58">    PixelBitMask,</span>
<span class="line" id="L59">    PixelBltOnly,</span>
<span class="line" id="L60">    PixelFormatMax,</span>
<span class="line" id="L61">};</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PixelBitmask = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L64">    red_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L65">    green_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L66">    blue_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L67">    reserved_mask: <span class="tok-type">u32</span>,</span>
<span class="line" id="L68">};</span>
<span class="line" id="L69"></span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsOutputBltPixel = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L71">    blue: <span class="tok-type">u8</span>,</span>
<span class="line" id="L72">    green: <span class="tok-type">u8</span>,</span>
<span class="line" id="L73">    red: <span class="tok-type">u8</span>,</span>
<span class="line" id="L74">    reserved: <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L75">};</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GraphicsOutputBltOperation = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L78">    BltVideoFill,</span>
<span class="line" id="L79">    BltVideoToBltBuffer,</span>
<span class="line" id="L80">    BltBufferToVideo,</span>
<span class="line" id="L81">    BltVideoToVideo,</span>
<span class="line" id="L82">    GraphicsOutputBltOperationMax,</span>
<span class="line" id="L83">};</span>
<span class="line" id="L84"></span>
</code></pre></body>
</html>