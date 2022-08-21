<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/plan9.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> syscall_bits = <span class="tok-kw">switch</span> (builtin.cpu.arch) {</span>
<span class="line" id="L5">    .x86_64 =&gt; <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;plan9/x86_64.zig&quot;</span>),</span>
<span class="line" id="L6">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;more plan9 syscall implementations (needs more inline asm in stage2&quot;</span>),</span>
<span class="line" id="L7">};</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS = <span class="tok-kw">enum</span>(<span class="tok-type">usize</span>) {</span>
<span class="line" id="L9">    SYSR1 = <span class="tok-number">0</span>,</span>
<span class="line" id="L10">    _ERRSTR = <span class="tok-number">1</span>,</span>
<span class="line" id="L11">    BIND = <span class="tok-number">2</span>,</span>
<span class="line" id="L12">    CHDIR = <span class="tok-number">3</span>,</span>
<span class="line" id="L13">    CLOSE = <span class="tok-number">4</span>,</span>
<span class="line" id="L14">    DUP = <span class="tok-number">5</span>,</span>
<span class="line" id="L15">    ALARM = <span class="tok-number">6</span>,</span>
<span class="line" id="L16">    EXEC = <span class="tok-number">7</span>,</span>
<span class="line" id="L17">    EXITS = <span class="tok-number">8</span>,</span>
<span class="line" id="L18">    _FSESSION = <span class="tok-number">9</span>,</span>
<span class="line" id="L19">    FAUTH = <span class="tok-number">10</span>,</span>
<span class="line" id="L20">    _FSTAT = <span class="tok-number">11</span>,</span>
<span class="line" id="L21">    SEGBRK = <span class="tok-number">12</span>,</span>
<span class="line" id="L22">    _MOUNT = <span class="tok-number">13</span>,</span>
<span class="line" id="L23">    OPEN = <span class="tok-number">14</span>,</span>
<span class="line" id="L24">    _READ = <span class="tok-number">15</span>,</span>
<span class="line" id="L25">    OSEEK = <span class="tok-number">16</span>,</span>
<span class="line" id="L26">    SLEEP = <span class="tok-number">17</span>,</span>
<span class="line" id="L27">    _STAT = <span class="tok-number">18</span>,</span>
<span class="line" id="L28">    RFORK = <span class="tok-number">19</span>,</span>
<span class="line" id="L29">    _WRITE = <span class="tok-number">20</span>,</span>
<span class="line" id="L30">    PIPE = <span class="tok-number">21</span>,</span>
<span class="line" id="L31">    CREATE = <span class="tok-number">22</span>,</span>
<span class="line" id="L32">    FD2PATH = <span class="tok-number">23</span>,</span>
<span class="line" id="L33">    BRK_ = <span class="tok-number">24</span>,</span>
<span class="line" id="L34">    REMOVE = <span class="tok-number">25</span>,</span>
<span class="line" id="L35">    _WSTAT = <span class="tok-number">26</span>,</span>
<span class="line" id="L36">    _FWSTAT = <span class="tok-number">27</span>,</span>
<span class="line" id="L37">    NOTIFY = <span class="tok-number">28</span>,</span>
<span class="line" id="L38">    NOTED = <span class="tok-number">29</span>,</span>
<span class="line" id="L39">    SEGATTACH = <span class="tok-number">30</span>,</span>
<span class="line" id="L40">    SEGDETACH = <span class="tok-number">31</span>,</span>
<span class="line" id="L41">    SEGFREE = <span class="tok-number">32</span>,</span>
<span class="line" id="L42">    SEGFLUSH = <span class="tok-number">33</span>,</span>
<span class="line" id="L43">    RENDEZVOUS = <span class="tok-number">34</span>,</span>
<span class="line" id="L44">    UNMOUNT = <span class="tok-number">35</span>,</span>
<span class="line" id="L45">    _WAIT = <span class="tok-number">36</span>,</span>
<span class="line" id="L46">    SEMACQUIRE = <span class="tok-number">37</span>,</span>
<span class="line" id="L47">    SEMRELEASE = <span class="tok-number">38</span>,</span>
<span class="line" id="L48">    SEEK = <span class="tok-number">39</span>,</span>
<span class="line" id="L49">    FVERSION = <span class="tok-number">40</span>,</span>
<span class="line" id="L50">    ERRSTR = <span class="tok-number">41</span>,</span>
<span class="line" id="L51">    STAT = <span class="tok-number">42</span>,</span>
<span class="line" id="L52">    FSTAT = <span class="tok-number">43</span>,</span>
<span class="line" id="L53">    WSTAT = <span class="tok-number">44</span>,</span>
<span class="line" id="L54">    FWSTAT = <span class="tok-number">45</span>,</span>
<span class="line" id="L55">    MOUNT = <span class="tok-number">46</span>,</span>
<span class="line" id="L56">    AWAIT = <span class="tok-number">47</span>,</span>
<span class="line" id="L57">    PREAD = <span class="tok-number">50</span>,</span>
<span class="line" id="L58">    PWRITE = <span class="tok-number">51</span>,</span>
<span class="line" id="L59">    TSEMACQUIRE = <span class="tok-number">52</span>,</span>
<span class="line" id="L60">    _NSEC = <span class="tok-number">53</span>,</span>
<span class="line" id="L61">};</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pwrite</span>(fd: <span class="tok-type">usize</span>, buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, count: <span class="tok-type">usize</span>, offset: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L64">    <span class="tok-kw">return</span> syscall_bits.syscall4(.PWRITE, fd, <span class="tok-builtin">@ptrToInt</span>(buf), count, offset);</span>
<span class="line" id="L65">}</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, omode: OpenMode) <span class="tok-type">usize</span> {</span>
<span class="line" id="L68">    <span class="tok-kw">return</span> syscall_bits.syscall2(.OPEN, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@enumToInt</span>(omode));</span>
<span class="line" id="L69">}</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, omode: OpenMode, perms: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L72">    <span class="tok-kw">return</span> syscall_bits.syscall3(.CREATE, <span class="tok-builtin">@ptrToInt</span>(path), <span class="tok-builtin">@enumToInt</span>(omode), perms);</span>
<span class="line" id="L73">}</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exits</span>(status: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L76">    _ = syscall_bits.syscall1(.EXITS, <span class="tok-kw">if</span> (status) |s| <span class="tok-builtin">@ptrToInt</span>(s) <span class="tok-kw">else</span> <span class="tok-number">0</span>);</span>
<span class="line" id="L77">}</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(fd: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L80">    <span class="tok-kw">return</span> syscall_bits.syscall1(.CLOSE, fd);</span>
<span class="line" id="L81">}</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenMode = <span class="tok-kw">enum</span>(<span class="tok-type">usize</span>) {</span>
<span class="line" id="L83">    OREAD = <span class="tok-number">0</span>, <span class="tok-comment">//* open for read</span>
</span>
<span class="line" id="L84">    OWRITE = <span class="tok-number">1</span>, <span class="tok-comment">//* write</span>
</span>
<span class="line" id="L85">    ORDWR = <span class="tok-number">2</span>, <span class="tok-comment">//* read and write</span>
</span>
<span class="line" id="L86">    OEXEC = <span class="tok-number">3</span>, <span class="tok-comment">//* execute, == read but check execute permission</span>
</span>
<span class="line" id="L87">    OTRUNC = <span class="tok-number">16</span>, <span class="tok-comment">//* or'ed in (except for exec), truncate file first</span>
</span>
<span class="line" id="L88">    OCEXEC = <span class="tok-number">32</span>, <span class="tok-comment">//* or'ed in (per file descriptor), close on exec</span>
</span>
<span class="line" id="L89">    ORCLOSE = <span class="tok-number">64</span>, <span class="tok-comment">//* or'ed in, remove on close</span>
</span>
<span class="line" id="L90">    OEXCL = <span class="tok-number">0x1000</span>, <span class="tok-comment">//* or'ed in, exclusive create</span>
</span>
<span class="line" id="L91">};</span>
<span class="line" id="L92"></span>
</code></pre></body>
</html>