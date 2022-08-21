<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/hii_database_protocol.zig - source view</title>
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
<span class="line" id="L6"><span class="tok-comment">/// Database manager for HII-related data structures.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIDatabaseProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    _new_package_list: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L9">    _remove_package_list: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> HIIDatabaseProtocol, hii.HIIHandle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    _update_package_list: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> HIIDatabaseProtocol, hii.HIIHandle, *<span class="tok-kw">const</span> hii.HIIPackageList) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _list_package_lists: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> HIIDatabaseProtocol, <span class="tok-type">u8</span>, ?*<span class="tok-kw">const</span> Guid, *<span class="tok-type">usize</span>, [*]hii.HIIHandle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _export_package_lists: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> HIIDatabaseProtocol, ?hii.HIIHandle, *<span class="tok-type">usize</span>, *hii.HIIPackageList) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _register_package_notify: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L14">    _unregister_package_notify: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L15">    _find_keyboard_layouts: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L16">    _get_keyboard_layout: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L17">    _set_keyboard_layout: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L18">    _get_package_list_handle: Status, <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-comment">/// Removes a package list from the HII database.</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">removePackageList</span>(self: *<span class="tok-kw">const</span> HIIDatabaseProtocol, handle: hii.HIIHandle) Status {</span>
<span class="line" id="L22">        <span class="tok-kw">return</span> self._remove_package_list(self, handle);</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">/// Update a package list in the HII database.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updatePackageList</span>(self: *<span class="tok-kw">const</span> HIIDatabaseProtocol, handle: hii.HIIHandle, buffer: *<span class="tok-kw">const</span> hii.HIIPackageList) Status {</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> self._update_package_list(self, handle, buffer);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Determines the handles that are currently active in the database.</span></span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">listPackageLists</span>(self: *<span class="tok-kw">const</span> HIIDatabaseProtocol, package_type: <span class="tok-type">u8</span>, package_guid: ?*<span class="tok-kw">const</span> Guid, buffer_length: *<span class="tok-type">usize</span>, handles: [*]hii.HIIHandle) Status {</span>
<span class="line" id="L32">        <span class="tok-kw">return</span> self._list_package_lists(self, package_type, package_guid, buffer_length, handles);</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Exports the contents of one or all package lists in the HII database into a buffer.</span></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exportPackageLists</span>(self: *<span class="tok-kw">const</span> HIIDatabaseProtocol, handle: ?hii.HIIHandle, buffer_size: *<span class="tok-type">usize</span>, buffer: *hii.HIIPackageList) Status {</span>
<span class="line" id="L37">        <span class="tok-kw">return</span> self._export_package_lists(self, handle, buffer_size, buffer);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L41">        .time_low = <span class="tok-number">0xef9fc172</span>,</span>
<span class="line" id="L42">        .time_mid = <span class="tok-number">0xa1b2</span>,</span>
<span class="line" id="L43">        .time_high_and_version = <span class="tok-number">0x4693</span>,</span>
<span class="line" id="L44">        .clock_seq_high_and_reserved = <span class="tok-number">0xb3</span>,</span>
<span class="line" id="L45">        .clock_seq_low = <span class="tok-number">0x27</span>,</span>
<span class="line" id="L46">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x6d</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0x42</span> },</span>
<span class="line" id="L47">    };</span>
<span class="line" id="L48">};</span>
<span class="line" id="L49"></span>
</code></pre></body>
</html>