<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux/bpf/kern.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> in_bpf_program = <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L5">    .bpfel, .bpfeb =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L6">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L7">};</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> helpers = <span class="tok-kw">if</span> (in_bpf_program) <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;helpers.zig&quot;</span>) <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BpfSock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BpfSockAddr = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FibLookup = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MapDef = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PerfEventData = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PerfEventValue = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PidNsInfo = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SeqFile = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SkBuff = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SkMsgMd = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SkReusePortMd = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SockAddr = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SockOps = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SockTuple = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SpinLock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SysCtl = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tcp6Sock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TcpRequestSock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TcpSock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TcpTimewaitSock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TunnelKey = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6Sock = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XdpMd = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XfrmState = <span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L36"></span>
</code></pre></body>
</html>