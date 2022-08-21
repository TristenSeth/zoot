<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/file_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> uefi = std.os.uefi;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Time = uefi.Time;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">    revision: <span class="tok-type">u64</span>,</span>
<span class="line" id="L10">    _open: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, **<span class="tok-kw">const</span> FileProtocol, [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, <span class="tok-type">u64</span>, <span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _close: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _delete: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _read: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, *<span class="tok-type">usize</span>, [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _write: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, *<span class="tok-type">usize</span>, [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _get_position: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, *<span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    _set_position: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, <span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L17">    _get_info: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, *<span class="tok-kw">const</span> <span class="tok-type">usize</span>, [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L18">    _set_info: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol, *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, <span class="tok-type">usize</span>, [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L19">    _flush: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> FileProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeekError = <span class="tok-kw">error</span>{SeekError};</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetSeekPosError = <span class="tok-kw">error</span>{GetSeekPosError};</span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReadError = <span class="tok-kw">error</span>{ReadError};</span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WriteError = <span class="tok-kw">error</span>{WriteError};</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeekableStream = io.SeekableStream(*<span class="tok-kw">const</span> FileProtocol, SeekError, GetSeekPosError, seekTo, seekBy, getPos, getEndPos);</span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reader = io.Reader(*<span class="tok-kw">const</span> FileProtocol, ReadError, readFn);</span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = io.Writer(*<span class="tok-kw">const</span> FileProtocol, WriteError, writeFn);</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekableStream</span>(self: *FileProtocol) SeekableStream {</span>
<span class="line" id="L31">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L32">    }</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *FileProtocol) Reader {</span>
<span class="line" id="L35">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *FileProtocol) Writer {</span>
<span class="line" id="L39">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L40">    }</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(self: *<span class="tok-kw">const</span> FileProtocol, new_handle: **<span class="tok-kw">const</span> FileProtocol, file_name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, open_mode: <span class="tok-type">u64</span>, attributes: <span class="tok-type">u64</span>) Status {</span>
<span class="line" id="L43">        <span class="tok-kw">return</span> self._open(self, new_handle, file_name, open_mode, attributes);</span>
<span class="line" id="L44">    }</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *<span class="tok-kw">const</span> FileProtocol) Status {</span>
<span class="line" id="L47">        <span class="tok-kw">return</span> self._close(self);</span>
<span class="line" id="L48">    }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">delete</span>(self: *<span class="tok-kw">const</span> FileProtocol) Status {</span>
<span class="line" id="L51">        <span class="tok-kw">return</span> self._delete(self);</span>
<span class="line" id="L52">    }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *<span class="tok-kw">const</span> FileProtocol, buffer_size: *<span class="tok-type">usize</span>, buffer: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L55">        <span class="tok-kw">return</span> self._read(self, buffer_size, buffer);</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-kw">fn</span> <span class="tok-fn">readFn</span>(self: *<span class="tok-kw">const</span> FileProtocol, buffer: []<span class="tok-type">u8</span>) ReadError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L59">        <span class="tok-kw">var</span> size: <span class="tok-type">usize</span> = buffer.len;</span>
<span class="line" id="L60">        <span class="tok-kw">if</span> (.Success != self.read(&amp;size, buffer.ptr)) <span class="tok-kw">return</span> ReadError.ReadError;</span>
<span class="line" id="L61">        <span class="tok-kw">return</span> size;</span>
<span class="line" id="L62">    }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *<span class="tok-kw">const</span> FileProtocol, buffer_size: *<span class="tok-type">usize</span>, buffer: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L65">        <span class="tok-kw">return</span> self._write(self, buffer_size, buffer);</span>
<span class="line" id="L66">    }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">    <span class="tok-kw">fn</span> <span class="tok-fn">writeFn</span>(self: *<span class="tok-kw">const</span> FileProtocol, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) WriteError!<span class="tok-type">usize</span> {</span>
<span class="line" id="L69">        <span class="tok-kw">var</span> size: <span class="tok-type">usize</span> = bytes.len;</span>
<span class="line" id="L70">        <span class="tok-kw">if</span> (.Success != self.write(&amp;size, bytes.ptr)) <span class="tok-kw">return</span> WriteError.WriteError;</span>
<span class="line" id="L71">        <span class="tok-kw">return</span> size;</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPosition</span>(self: *<span class="tok-kw">const</span> FileProtocol, position: *<span class="tok-type">u64</span>) Status {</span>
<span class="line" id="L75">        <span class="tok-kw">return</span> self._get_position(self, position);</span>
<span class="line" id="L76">    }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">    <span class="tok-kw">fn</span> <span class="tok-fn">getPos</span>(self: *<span class="tok-kw">const</span> FileProtocol) GetSeekPosError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L79">        <span class="tok-kw">var</span> pos: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L80">        <span class="tok-kw">if</span> (.Success != self.getPosition(&amp;pos)) <span class="tok-kw">return</span> GetSeekPosError.GetSeekPosError;</span>
<span class="line" id="L81">        <span class="tok-kw">return</span> pos;</span>
<span class="line" id="L82">    }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">    <span class="tok-kw">fn</span> <span class="tok-fn">getEndPos</span>(self: *<span class="tok-kw">const</span> FileProtocol) GetSeekPosError!<span class="tok-type">u64</span> {</span>
<span class="line" id="L85">        <span class="tok-comment">// preserve the old file position</span>
</span>
<span class="line" id="L86">        <span class="tok-kw">var</span> pos: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L87">        <span class="tok-kw">if</span> (.Success != self.getPosition(&amp;pos)) <span class="tok-kw">return</span> GetSeekPosError.GetSeekPosError;</span>
<span class="line" id="L88">        <span class="tok-comment">// seek to end of file to get position = file size</span>
</span>
<span class="line" id="L89">        <span class="tok-kw">if</span> (.Success != self.setPosition(efi_file_position_end_of_file)) <span class="tok-kw">return</span> GetSeekPosError.GetSeekPosError;</span>
<span class="line" id="L90">        <span class="tok-comment">// restore the old position</span>
</span>
<span class="line" id="L91">        <span class="tok-kw">if</span> (.Success != self.setPosition(pos)) <span class="tok-kw">return</span> GetSeekPosError.GetSeekPosError;</span>
<span class="line" id="L92">        <span class="tok-comment">// return the file size = position</span>
</span>
<span class="line" id="L93">        <span class="tok-kw">return</span> pos;</span>
<span class="line" id="L94">    }</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPosition</span>(self: *<span class="tok-kw">const</span> FileProtocol, position: <span class="tok-type">u64</span>) Status {</span>
<span class="line" id="L97">        <span class="tok-kw">return</span> self._set_position(self, position);</span>
<span class="line" id="L98">    }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-kw">fn</span> <span class="tok-fn">seekTo</span>(self: *<span class="tok-kw">const</span> FileProtocol, pos: <span class="tok-type">u64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L101">        <span class="tok-kw">if</span> (.Success != self.setPosition(pos)) <span class="tok-kw">return</span> SeekError.SeekError;</span>
<span class="line" id="L102">    }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">    <span class="tok-kw">fn</span> <span class="tok-fn">seekBy</span>(self: *<span class="tok-kw">const</span> FileProtocol, offset: <span class="tok-type">i64</span>) SeekError!<span class="tok-type">void</span> {</span>
<span class="line" id="L105">        <span class="tok-comment">// save the old position and calculate the delta</span>
</span>
<span class="line" id="L106">        <span class="tok-kw">var</span> pos: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L107">        <span class="tok-kw">if</span> (.Success != self.getPosition(&amp;pos)) <span class="tok-kw">return</span> SeekError.SeekError;</span>
<span class="line" id="L108">        <span class="tok-kw">const</span> seek_back = offset &lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L109">        <span class="tok-kw">const</span> amt = std.math.absCast(offset);</span>
<span class="line" id="L110">        <span class="tok-kw">if</span> (seek_back) {</span>
<span class="line" id="L111">            pos += amt;</span>
<span class="line" id="L112">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L113">            pos -= amt;</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115">        <span class="tok-kw">if</span> (.Success != self.setPosition(pos)) <span class="tok-kw">return</span> SeekError.SeekError;</span>
<span class="line" id="L116">    }</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getInfo</span>(self: *<span class="tok-kw">const</span> FileProtocol, information_type: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, buffer_size: *<span class="tok-type">usize</span>, buffer: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L119">        <span class="tok-kw">return</span> self._get_info(self, information_type, buffer_size, buffer);</span>
<span class="line" id="L120">    }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setInfo</span>(self: *<span class="tok-kw">const</span> FileProtocol, information_type: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, buffer_size: <span class="tok-type">usize</span>, buffer: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L123">        <span class="tok-kw">return</span> self._set_info(self, information_type, buffer_size, buffer);</span>
<span class="line" id="L124">    }</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flush</span>(self: *<span class="tok-kw">const</span> FileProtocol) Status {</span>
<span class="line" id="L127">        <span class="tok-kw">return</span> self._flush(self);</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_mode_read: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000001</span>;</span>
<span class="line" id="L131">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_mode_write: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000002</span>;</span>
<span class="line" id="L132">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_mode_create: <span class="tok-type">u64</span> = <span class="tok-number">0x8000000000000000</span>;</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_read_only: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000001</span>;</span>
<span class="line" id="L135">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_hidden: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000002</span>;</span>
<span class="line" id="L136">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_system: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000004</span>;</span>
<span class="line" id="L137">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_reserved: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000008</span>;</span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_directory: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000010</span>;</span>
<span class="line" id="L139">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_archive: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000020</span>;</span>
<span class="line" id="L140">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_valid_attr: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000037</span>;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_position_end_of_file: <span class="tok-type">u64</span> = <span class="tok-number">0xffffffffffffffff</span>;</span>
<span class="line" id="L143">};</span>
<span class="line" id="L144"></span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileInfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L146">    size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L147">    file_size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L148">    physical_size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L149">    create_time: Time,</span>
<span class="line" id="L150">    last_access_time: Time,</span>
<span class="line" id="L151">    modification_time: Time,</span>
<span class="line" id="L152">    attribute: <span class="tok-type">u64</span>,</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFileName</span>(self: *<span class="tok-kw">const</span> FileInfo) [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L155">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(FileInfo));</span>
<span class="line" id="L156">    }</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_read_only: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000001</span>;</span>
<span class="line" id="L159">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_hidden: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000002</span>;</span>
<span class="line" id="L160">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_system: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000004</span>;</span>
<span class="line" id="L161">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_reserved: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000008</span>;</span>
<span class="line" id="L162">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_directory: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000010</span>;</span>
<span class="line" id="L163">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_archive: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000020</span>;</span>
<span class="line" id="L164">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> efi_file_valid_attr: <span class="tok-type">u64</span> = <span class="tok-number">0x0000000000000037</span>;</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L167">        .time_low = <span class="tok-number">0x09576e92</span>,</span>
<span class="line" id="L168">        .time_mid = <span class="tok-number">0x6d3f</span>,</span>
<span class="line" id="L169">        .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L170">        .clock_seq_high_and_reserved = <span class="tok-number">0x8e</span>,</span>
<span class="line" id="L171">        .clock_seq_low = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L172">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3b</span> },</span>
<span class="line" id="L173">    };</span>
<span class="line" id="L174">};</span>
<span class="line" id="L175"></span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileSystemInfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L177">    size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L178">    read_only: <span class="tok-type">bool</span>,</span>
<span class="line" id="L179">    volume_size: <span class="tok-type">u64</span>,</span>
<span class="line" id="L180">    free_space: <span class="tok-type">u64</span>,</span>
<span class="line" id="L181">    block_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L182">    _volume_label: <span class="tok-type">u16</span>,</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getVolumeLabel</span>(self: *<span class="tok-kw">const</span> FileSystemInfo) [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L185">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, &amp;self._volume_label);</span>
<span class="line" id="L186">    }</span>
<span class="line" id="L187"></span>
<span class="line" id="L188">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L189">        .time_low = <span class="tok-number">0x09576e93</span>,</span>
<span class="line" id="L190">        .time_mid = <span class="tok-number">0x6d3f</span>,</span>
<span class="line" id="L191">        .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L192">        .clock_seq_high_and_reserved = <span class="tok-number">0x8e</span>,</span>
<span class="line" id="L193">        .clock_seq_low = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L194">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3b</span> },</span>
<span class="line" id="L195">    };</span>
<span class="line" id="L196">};</span>
<span class="line" id="L197"></span>
</code></pre></body>
</html>