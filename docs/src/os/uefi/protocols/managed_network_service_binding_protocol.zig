<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/managed_network_service_binding_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Handle = uefi.Handle;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ManagedNetworkServiceBindingProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    _create_child: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkServiceBindingProtocol, *?Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L8">    _destroy_child: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> ManagedNetworkServiceBindingProtocol, Handle) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createChild</span>(self: *<span class="tok-kw">const</span> ManagedNetworkServiceBindingProtocol, handle: *?Handle) Status {</span>
<span class="line" id="L11">        <span class="tok-kw">return</span> self._create_child(self, handle);</span>
<span class="line" id="L12">    }</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroyChild</span>(self: *<span class="tok-kw">const</span> ManagedNetworkServiceBindingProtocol, handle: Handle) Status {</span>
<span class="line" id="L15">        <span class="tok-kw">return</span> self._destroy_child(self, handle);</span>
<span class="line" id="L16">    }</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L19">        .time_low = <span class="tok-number">0xf36ff770</span>,</span>
<span class="line" id="L20">        .time_mid = <span class="tok-number">0xa7e1</span>,</span>
<span class="line" id="L21">        .time_high_and_version = <span class="tok-number">0x42cf</span>,</span>
<span class="line" id="L22">        .clock_seq_high_and_reserved = <span class="tok-number">0x9e</span>,</span>
<span class="line" id="L23">        .clock_seq_low = <span class="tok-number">0xd2</span>,</span>
<span class="line" id="L24">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x56</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x4c</span> },</span>
<span class="line" id="L25">    };</span>
<span class="line" id="L26">};</span>
<span class="line" id="L27"></span>
</code></pre></body>
</html>