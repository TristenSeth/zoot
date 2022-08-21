<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/advapi32.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> BOOL = windows.BOOL;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> HKEY = windows.HKEY;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> BYTE = windows.BYTE;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> LPCWSTR = windows.LPCWSTR;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> LSTATUS = windows.LSTATUS;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> REGSAM = windows.REGSAM;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> ULONG = windows.ULONG;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;advapi32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RegOpenKeyExW</span>(</span>
<span class="line" id="L14">    hKey: HKEY,</span>
<span class="line" id="L15">    lpSubKey: LPCWSTR,</span>
<span class="line" id="L16">    ulOptions: DWORD,</span>
<span class="line" id="L17">    samDesired: REGSAM,</span>
<span class="line" id="L18">    phkResult: *HKEY,</span>
<span class="line" id="L19">) <span class="tok-kw">callconv</span>(WINAPI) LSTATUS;</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;advapi32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">RegQueryValueExW</span>(</span>
<span class="line" id="L22">    hKey: HKEY,</span>
<span class="line" id="L23">    lpValueName: LPCWSTR,</span>
<span class="line" id="L24">    lpReserved: *DWORD,</span>
<span class="line" id="L25">    lpType: *DWORD,</span>
<span class="line" id="L26">    lpData: *BYTE,</span>
<span class="line" id="L27">    lpcbData: *DWORD,</span>
<span class="line" id="L28">) <span class="tok-kw">callconv</span>(WINAPI) LSTATUS;</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-comment">// RtlGenRandom is known as SystemFunction036 under advapi32</span>
</span>
<span class="line" id="L31"><span class="tok-comment">// http://msdn.microsoft.com/en-us/library/windows/desktop/aa387694.aspx */</span>
</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;advapi32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">SystemFunction036</span>(output: [*]<span class="tok-type">u8</span>, length: ULONG) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RtlGenRandom = SystemFunction036;</span>
<span class="line" id="L34"></span>
</code></pre></body>
</html>