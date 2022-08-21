<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>elf.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> native_endian = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).target.cpu.arch.endian();</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_NULL = <span class="tok-number">0</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_IGNORE = <span class="tok-number">1</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_EXECFD = <span class="tok-number">2</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_PHDR = <span class="tok-number">3</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_PHENT = <span class="tok-number">4</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_PHNUM = <span class="tok-number">5</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_PAGESZ = <span class="tok-number">6</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_BASE = <span class="tok-number">7</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_FLAGS = <span class="tok-number">8</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_ENTRY = <span class="tok-number">9</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_NOTELF = <span class="tok-number">10</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_UID = <span class="tok-number">11</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_EUID = <span class="tok-number">12</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_GID = <span class="tok-number">13</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_EGID = <span class="tok-number">14</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_CLKTCK = <span class="tok-number">17</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_PLATFORM = <span class="tok-number">15</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_HWCAP = <span class="tok-number">16</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_FPUCW = <span class="tok-number">18</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_DCACHEBSIZE = <span class="tok-number">19</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_ICACHEBSIZE = <span class="tok-number">20</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_UCACHEBSIZE = <span class="tok-number">21</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_IGNOREPPC = <span class="tok-number">22</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_SECURE = <span class="tok-number">23</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_BASE_PLATFORM = <span class="tok-number">24</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_RANDOM = <span class="tok-number">25</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_HWCAP2 = <span class="tok-number">26</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_EXECFN = <span class="tok-number">31</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_SYSINFO = <span class="tok-number">32</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_SYSINFO_EHDR = <span class="tok-number">33</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1I_CACHESHAPE = <span class="tok-number">34</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1D_CACHESHAPE = <span class="tok-number">35</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L2_CACHESHAPE = <span class="tok-number">36</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L3_CACHESHAPE = <span class="tok-number">37</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1I_CACHESIZE = <span class="tok-number">40</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1I_CACHEGEOMETRY = <span class="tok-number">41</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1D_CACHESIZE = <span class="tok-number">42</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L1D_CACHEGEOMETRY = <span class="tok-number">43</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L2_CACHESIZE = <span class="tok-number">44</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L2_CACHEGEOMETRY = <span class="tok-number">45</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L3_CACHESIZE = <span class="tok-number">46</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT_L3_CACHEGEOMETRY = <span class="tok-number">47</span>;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_NULL = <span class="tok-number">0</span>;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_NEEDED = <span class="tok-number">1</span>;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PLTRELSZ = <span class="tok-number">2</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PLTGOT = <span class="tok-number">3</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_HASH = <span class="tok-number">4</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_STRTAB = <span class="tok-number">5</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMTAB = <span class="tok-number">6</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELA = <span class="tok-number">7</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELASZ = <span class="tok-number">8</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELAENT = <span class="tok-number">9</span>;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_STRSZ = <span class="tok-number">10</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMENT = <span class="tok-number">11</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_INIT = <span class="tok-number">12</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FINI = <span class="tok-number">13</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SONAME = <span class="tok-number">14</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RPATH = <span class="tok-number">15</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMBOLIC = <span class="tok-number">16</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_REL = <span class="tok-number">17</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELSZ = <span class="tok-number">18</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELENT = <span class="tok-number">19</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PLTREL = <span class="tok-number">20</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_DEBUG = <span class="tok-number">21</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_TEXTREL = <span class="tok-number">22</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_JMPREL = <span class="tok-number">23</span>;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_BIND_NOW = <span class="tok-number">24</span>;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_INIT_ARRAY = <span class="tok-number">25</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FINI_ARRAY = <span class="tok-number">26</span>;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_INIT_ARRAYSZ = <span class="tok-number">27</span>;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FINI_ARRAYSZ = <span class="tok-number">28</span>;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RUNPATH = <span class="tok-number">29</span>;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FLAGS = <span class="tok-number">30</span>;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ENCODING = <span class="tok-number">32</span>;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PREINIT_ARRAY = <span class="tok-number">32</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PREINIT_ARRAYSZ = <span class="tok-number">33</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMTAB_SHNDX = <span class="tok-number">34</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_NUM = <span class="tok-number">35</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_LOOS = <span class="tok-number">0x6000000d</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_HIOS = <span class="tok-number">0x6ffff000</span>;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_LOPROC = <span class="tok-number">0x70000000</span>;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_HIPROC = <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PROCNUM = DT_MIPS_NUM;</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VALRNGLO = <span class="tok-number">0x6ffffd00</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_PRELINKED = <span class="tok-number">0x6ffffdf5</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_CONFLICTSZ = <span class="tok-number">0x6ffffdf6</span>;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_LIBLISTSZ = <span class="tok-number">0x6ffffdf7</span>;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_CHECKSUM = <span class="tok-number">0x6ffffdf8</span>;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PLTPADSZ = <span class="tok-number">0x6ffffdf9</span>;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MOVEENT = <span class="tok-number">0x6ffffdfa</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MOVESZ = <span class="tok-number">0x6ffffdfb</span>;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FEATURE_1 = <span class="tok-number">0x6ffffdfc</span>;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_POSFLAG_1 = <span class="tok-number">0x6ffffdfd</span>;</span>
<span class="line" id="L105"></span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMINSZ = <span class="tok-number">0x6ffffdfe</span>;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMINENT = <span class="tok-number">0x6ffffdff</span>;</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VALRNGHI = <span class="tok-number">0x6ffffdff</span>;</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VALNUM = <span class="tok-number">12</span>;</span>
<span class="line" id="L110"></span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ADDRRNGLO = <span class="tok-number">0x6ffffe00</span>;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_HASH = <span class="tok-number">0x6ffffef5</span>;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_TLSDESC_PLT = <span class="tok-number">0x6ffffef6</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_TLSDESC_GOT = <span class="tok-number">0x6ffffef7</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_CONFLICT = <span class="tok-number">0x6ffffef8</span>;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_GNU_LIBLIST = <span class="tok-number">0x6ffffef9</span>;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_CONFIG = <span class="tok-number">0x6ffffefa</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_DEPAUDIT = <span class="tok-number">0x6ffffefb</span>;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_AUDIT = <span class="tok-number">0x6ffffefc</span>;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PLTPAD = <span class="tok-number">0x6ffffefd</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MOVETAB = <span class="tok-number">0x6ffffefe</span>;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SYMINFO = <span class="tok-number">0x6ffffeff</span>;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ADDRRNGHI = <span class="tok-number">0x6ffffeff</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ADDRNUM = <span class="tok-number">11</span>;</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERSYM = <span class="tok-number">0x6ffffff0</span>;</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELACOUNT = <span class="tok-number">0x6ffffff9</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_RELCOUNT = <span class="tok-number">0x6ffffffa</span>;</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FLAGS_1 = <span class="tok-number">0x6ffffffb</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERDEF = <span class="tok-number">0x6ffffffc</span>;</span>
<span class="line" id="L133"></span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERDEFNUM = <span class="tok-number">0x6ffffffd</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERNEED = <span class="tok-number">0x6ffffffe</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERNEEDNUM = <span class="tok-number">0x6fffffff</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_VERSIONTAGNUM = <span class="tok-number">16</span>;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_AUXILIARY = <span class="tok-number">0x7ffffffd</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_FILTER = <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_EXTRANUM = <span class="tok-number">3</span>;</span>
<span class="line" id="L143"></span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SPARC_REGISTER = <span class="tok-number">0x70000001</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_SPARC_NUM = <span class="tok-number">2</span>;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_RLD_VERSION = <span class="tok-number">0x70000001</span>;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_TIME_STAMP = <span class="tok-number">0x70000002</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_ICHECKSUM = <span class="tok-number">0x70000003</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_IVERSION = <span class="tok-number">0x70000004</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_FLAGS = <span class="tok-number">0x70000005</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_BASE_ADDRESS = <span class="tok-number">0x70000006</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_MSYM = <span class="tok-number">0x70000007</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_CONFLICT = <span class="tok-number">0x70000008</span>;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_LIBLIST = <span class="tok-number">0x70000009</span>;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_LOCAL_GOTNO = <span class="tok-number">0x7000000a</span>;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_CONFLICTNO = <span class="tok-number">0x7000000b</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_LIBLISTNO = <span class="tok-number">0x70000010</span>;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_SYMTABNO = <span class="tok-number">0x70000011</span>;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_UNREFEXTNO = <span class="tok-number">0x70000012</span>;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_GOTSYM = <span class="tok-number">0x70000013</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_HIPAGENO = <span class="tok-number">0x70000014</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_RLD_MAP = <span class="tok-number">0x70000016</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_CLASS = <span class="tok-number">0x70000017</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_CLASS_NO = <span class="tok-number">0x70000018</span>;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_INSTANCE = <span class="tok-number">0x70000019</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_INSTANCE_NO = <span class="tok-number">0x7000001a</span>;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_RELOC = <span class="tok-number">0x7000001b</span>;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_RELOC_NO = <span class="tok-number">0x7000001c</span>;</span>
<span class="line" id="L172"></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_SYM = <span class="tok-number">0x7000001d</span>;</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_SYM_NO = <span class="tok-number">0x7000001e</span>;</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_CLASSSYM = <span class="tok-number">0x70000020</span>;</span>
<span class="line" id="L178"></span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DELTA_CLASSSYM_NO = <span class="tok-number">0x70000021</span>;</span>
<span class="line" id="L180"></span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_CXX_FLAGS = <span class="tok-number">0x70000022</span>;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_PIXIE_INIT = <span class="tok-number">0x70000023</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_SYMBOL_LIB = <span class="tok-number">0x70000024</span>;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_LOCALPAGE_GOTIDX = <span class="tok-number">0x70000025</span>;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_LOCAL_GOTIDX = <span class="tok-number">0x70000026</span>;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_HIDDEN_GOTIDX = <span class="tok-number">0x70000027</span>;</span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_PROTECTED_GOTIDX = <span class="tok-number">0x70000028</span>;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_OPTIONS = <span class="tok-number">0x70000029</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_INTERFACE = <span class="tok-number">0x7000002a</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_DYNSTR_ALIGN = <span class="tok-number">0x7000002b</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_INTERFACE_SIZE = <span class="tok-number">0x7000002c</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_RLD_TEXT_RESOLVE_ADDR = <span class="tok-number">0x7000002d</span>;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_PERF_SUFFIX = <span class="tok-number">0x7000002e</span>;</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_COMPACT_SIZE = <span class="tok-number">0x7000002f</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_GP_VALUE = <span class="tok-number">0x70000030</span>;</span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_AUX_DYNAMIC = <span class="tok-number">0x70000031</span>;</span>
<span class="line" id="L199"></span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_PLTGOT = <span class="tok-number">0x70000032</span>;</span>
<span class="line" id="L201"></span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_RWPLT = <span class="tok-number">0x70000034</span>;</span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_RLD_MAP_REL = <span class="tok-number">0x70000035</span>;</span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_MIPS_NUM = <span class="tok-number">0x36</span>;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ALPHA_PLTRO = (DT_LOPROC + <span class="tok-number">0</span>);</span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_ALPHA_NUM = <span class="tok-number">1</span>;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC_GOT = (DT_LOPROC + <span class="tok-number">0</span>);</span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC_OPT = (DT_LOPROC + <span class="tok-number">1</span>);</span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC_NUM = <span class="tok-number">2</span>;</span>
<span class="line" id="L212"></span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC64_GLINK = (DT_LOPROC + <span class="tok-number">0</span>);</span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC64_OPD = (DT_LOPROC + <span class="tok-number">1</span>);</span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC64_OPDSZ = (DT_LOPROC + <span class="tok-number">2</span>);</span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC64_OPT = (DT_LOPROC + <span class="tok-number">3</span>);</span>
<span class="line" id="L217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_PPC64_NUM = <span class="tok-number">4</span>;</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_IA_64_PLT_RESERVE = (DT_LOPROC + <span class="tok-number">0</span>);</span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_IA_64_NUM = <span class="tok-number">1</span>;</span>
<span class="line" id="L221"></span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DT_NIOS2_GP = <span class="tok-number">0x70000002</span>;</span>
<span class="line" id="L223"></span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_NULL = <span class="tok-number">0</span>;</span>
<span class="line" id="L225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_LOAD = <span class="tok-number">1</span>;</span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_DYNAMIC = <span class="tok-number">2</span>;</span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_INTERP = <span class="tok-number">3</span>;</span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_NOTE = <span class="tok-number">4</span>;</span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_SHLIB = <span class="tok-number">5</span>;</span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_PHDR = <span class="tok-number">6</span>;</span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_TLS = <span class="tok-number">7</span>;</span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_NUM = <span class="tok-number">8</span>;</span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_LOOS = <span class="tok-number">0x60000000</span>;</span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_GNU_EH_FRAME = <span class="tok-number">0x6474e550</span>;</span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_GNU_STACK = <span class="tok-number">0x6474e551</span>;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_GNU_RELRO = <span class="tok-number">0x6474e552</span>;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_LOSUNW = <span class="tok-number">0x6ffffffa</span>;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_SUNWBSS = <span class="tok-number">0x6ffffffa</span>;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_SUNWSTACK = <span class="tok-number">0x6ffffffb</span>;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_HISUNW = <span class="tok-number">0x6fffffff</span>;</span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_HIOS = <span class="tok-number">0x6fffffff</span>;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_LOPROC = <span class="tok-number">0x70000000</span>;</span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PT_HIPROC = <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L244"></span>
<span class="line" id="L245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_NULL = <span class="tok-number">0</span>;</span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_PROGBITS = <span class="tok-number">1</span>;</span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_SYMTAB = <span class="tok-number">2</span>;</span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_STRTAB = <span class="tok-number">3</span>;</span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_RELA = <span class="tok-number">4</span>;</span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_HASH = <span class="tok-number">5</span>;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_DYNAMIC = <span class="tok-number">6</span>;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_NOTE = <span class="tok-number">7</span>;</span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_NOBITS = <span class="tok-number">8</span>;</span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_REL = <span class="tok-number">9</span>;</span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_SHLIB = <span class="tok-number">10</span>;</span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_DYNSYM = <span class="tok-number">11</span>;</span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_INIT_ARRAY = <span class="tok-number">14</span>;</span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_FINI_ARRAY = <span class="tok-number">15</span>;</span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_PREINIT_ARRAY = <span class="tok-number">16</span>;</span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_GROUP = <span class="tok-number">17</span>;</span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_SYMTAB_SHNDX = <span class="tok-number">18</span>;</span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_LOOS = <span class="tok-number">0x60000000</span>;</span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_HIOS = <span class="tok-number">0x6fffffff</span>;</span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_LOPROC = <span class="tok-number">0x70000000</span>;</span>
<span class="line" id="L265"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_HIPROC = <span class="tok-number">0x7fffffff</span>;</span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_LOUSER = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHT_HIUSER = <span class="tok-number">0xffffffff</span>;</span>
<span class="line" id="L268"></span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_LOCAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_GLOBAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_WEAK = <span class="tok-number">2</span>;</span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_NUM = <span class="tok-number">3</span>;</span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_LOOS = <span class="tok-number">10</span>;</span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_GNU_UNIQUE = <span class="tok-number">10</span>;</span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_HIOS = <span class="tok-number">12</span>;</span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_LOPROC = <span class="tok-number">13</span>;</span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_HIPROC = <span class="tok-number">15</span>;</span>
<span class="line" id="L278"></span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STB_MIPS_SPLIT_COMMON = <span class="tok-number">13</span>;</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_NOTYPE = <span class="tok-number">0</span>;</span>
<span class="line" id="L282"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_OBJECT = <span class="tok-number">1</span>;</span>
<span class="line" id="L283"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_FUNC = <span class="tok-number">2</span>;</span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_SECTION = <span class="tok-number">3</span>;</span>
<span class="line" id="L285"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_FILE = <span class="tok-number">4</span>;</span>
<span class="line" id="L286"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_COMMON = <span class="tok-number">5</span>;</span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_TLS = <span class="tok-number">6</span>;</span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_NUM = <span class="tok-number">7</span>;</span>
<span class="line" id="L289"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_LOOS = <span class="tok-number">10</span>;</span>
<span class="line" id="L290"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_GNU_IFUNC = <span class="tok-number">10</span>;</span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_HIOS = <span class="tok-number">12</span>;</span>
<span class="line" id="L292"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_LOPROC = <span class="tok-number">13</span>;</span>
<span class="line" id="L293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_HIPROC = <span class="tok-number">15</span>;</span>
<span class="line" id="L294"></span>
<span class="line" id="L295"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_SPARC_REGISTER = <span class="tok-number">13</span>;</span>
<span class="line" id="L296"></span>
<span class="line" id="L297"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_PARISC_MILLICODE = <span class="tok-number">13</span>;</span>
<span class="line" id="L298"></span>
<span class="line" id="L299"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_HP_OPAQUE = (STT_LOOS + <span class="tok-number">0x1</span>);</span>
<span class="line" id="L300"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_HP_STUB = (STT_LOOS + <span class="tok-number">0x2</span>);</span>
<span class="line" id="L301"></span>
<span class="line" id="L302"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_ARM_TFUNC = STT_LOPROC;</span>
<span class="line" id="L303"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STT_ARM_16BIT = STT_HIPROC;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VER_FLG_BASE = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L306"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VER_FLG_WEAK = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L307"></span>
<span class="line" id="L308"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAGIC = <span class="tok-str">&quot;\x7fELF&quot;</span>;</span>
<span class="line" id="L309"></span>
<span class="line" id="L310"><span class="tok-comment">/// File types</span></span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ET = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L312">    <span class="tok-comment">/// No file type</span></span>
<span class="line" id="L313">    NONE = <span class="tok-number">0</span>,</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-comment">/// Relocatable file</span></span>
<span class="line" id="L316">    REL = <span class="tok-number">1</span>,</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-comment">/// Executable file</span></span>
<span class="line" id="L319">    EXEC = <span class="tok-number">2</span>,</span>
<span class="line" id="L320"></span>
<span class="line" id="L321">    <span class="tok-comment">/// Shared object file</span></span>
<span class="line" id="L322">    DYN = <span class="tok-number">3</span>,</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    <span class="tok-comment">/// Core file</span></span>
<span class="line" id="L325">    CORE = <span class="tok-number">4</span>,</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-comment">/// Beginning of processor-specific codes</span></span>
<span class="line" id="L328">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOPROC = <span class="tok-number">0xff00</span>;</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-comment">/// Processor-specific</span></span>
<span class="line" id="L331">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIPROC = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L332">};</span>
<span class="line" id="L333"></span>
<span class="line" id="L334"><span class="tok-comment">/// All integers are native endian.</span></span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Header = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L336">    endian: std.builtin.Endian,</span>
<span class="line" id="L337">    machine: EM,</span>
<span class="line" id="L338">    is_64: <span class="tok-type">bool</span>,</span>
<span class="line" id="L339">    entry: <span class="tok-type">u64</span>,</span>
<span class="line" id="L340">    phoff: <span class="tok-type">u64</span>,</span>
<span class="line" id="L341">    shoff: <span class="tok-type">u64</span>,</span>
<span class="line" id="L342">    phentsize: <span class="tok-type">u16</span>,</span>
<span class="line" id="L343">    phnum: <span class="tok-type">u16</span>,</span>
<span class="line" id="L344">    shentsize: <span class="tok-type">u16</span>,</span>
<span class="line" id="L345">    shnum: <span class="tok-type">u16</span>,</span>
<span class="line" id="L346">    shstrndx: <span class="tok-type">u16</span>,</span>
<span class="line" id="L347"></span>
<span class="line" id="L348">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">program_header_iterator</span>(self: Header, parse_source: <span class="tok-kw">anytype</span>) ProgramHeaderIterator(<span class="tok-builtin">@TypeOf</span>(parse_source)) {</span>
<span class="line" id="L349">        <span class="tok-kw">return</span> ProgramHeaderIterator(<span class="tok-builtin">@TypeOf</span>(parse_source)){</span>
<span class="line" id="L350">            .elf_header = self,</span>
<span class="line" id="L351">            .parse_source = parse_source,</span>
<span class="line" id="L352">        };</span>
<span class="line" id="L353">    }</span>
<span class="line" id="L354"></span>
<span class="line" id="L355">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">section_header_iterator</span>(self: Header, parse_source: <span class="tok-kw">anytype</span>) SectionHeaderIterator(<span class="tok-builtin">@TypeOf</span>(parse_source)) {</span>
<span class="line" id="L356">        <span class="tok-kw">return</span> SectionHeaderIterator(<span class="tok-builtin">@TypeOf</span>(parse_source)){</span>
<span class="line" id="L357">            .elf_header = self,</span>
<span class="line" id="L358">            .parse_source = parse_source,</span>
<span class="line" id="L359">        };</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(parse_source: <span class="tok-kw">anytype</span>) !Header {</span>
<span class="line" id="L363">        <span class="tok-kw">var</span> hdr_buf: [<span class="tok-builtin">@sizeOf</span>(Elf64_Ehdr)]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Elf64_Ehdr)) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L364">        <span class="tok-kw">try</span> parse_source.seekableStream().seekTo(<span class="tok-number">0</span>);</span>
<span class="line" id="L365">        <span class="tok-kw">try</span> parse_source.reader().readNoEof(&amp;hdr_buf);</span>
<span class="line" id="L366">        <span class="tok-kw">return</span> Header.parse(&amp;hdr_buf);</span>
<span class="line" id="L367">    }</span>
<span class="line" id="L368"></span>
<span class="line" id="L369">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(hdr_buf: *<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Elf64_Ehdr)) <span class="tok-kw">const</span> [<span class="tok-builtin">@sizeOf</span>(Elf64_Ehdr)]<span class="tok-type">u8</span>) !Header {</span>
<span class="line" id="L370">        <span class="tok-kw">const</span> hdr32 = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> Elf32_Ehdr, hdr_buf);</span>
<span class="line" id="L371">        <span class="tok-kw">const</span> hdr64 = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> Elf64_Ehdr, hdr_buf);</span>
<span class="line" id="L372">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hdr32.e_ident[<span class="tok-number">0</span>..<span class="tok-number">4</span>], MAGIC)) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfMagic;</span>
<span class="line" id="L373">        <span class="tok-kw">if</span> (hdr32.e_ident[EI_VERSION] != <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfVersion;</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">        <span class="tok-kw">const</span> endian: std.builtin.Endian = <span class="tok-kw">switch</span> (hdr32.e_ident[EI_DATA]) {</span>
<span class="line" id="L376">            ELFDATA2LSB =&gt; .Little,</span>
<span class="line" id="L377">            ELFDATA2MSB =&gt; .Big,</span>
<span class="line" id="L378">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfEndian,</span>
<span class="line" id="L379">        };</span>
<span class="line" id="L380">        <span class="tok-kw">const</span> need_bswap = endian != native_endian;</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-kw">const</span> is_64 = <span class="tok-kw">switch</span> (hdr32.e_ident[EI_CLASS]) {</span>
<span class="line" id="L383">            ELFCLASS32 =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L384">            ELFCLASS64 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L385">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidElfClass,</span>
<span class="line" id="L386">        };</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">        <span class="tok-kw">const</span> machine = <span class="tok-kw">if</span> (need_bswap) blk: {</span>
<span class="line" id="L389">            <span class="tok-kw">const</span> value = <span class="tok-builtin">@enumToInt</span>(hdr32.e_machine);</span>
<span class="line" id="L390">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@intToEnum</span>(EM, <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(value), value));</span>
<span class="line" id="L391">        } <span class="tok-kw">else</span> hdr32.e_machine;</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(Header, .{</span>
<span class="line" id="L394">            .endian = endian,</span>
<span class="line" id="L395">            .machine = machine,</span>
<span class="line" id="L396">            .is_64 = is_64,</span>
<span class="line" id="L397">            .entry = int(is_64, need_bswap, hdr32.e_entry, hdr64.e_entry),</span>
<span class="line" id="L398">            .phoff = int(is_64, need_bswap, hdr32.e_phoff, hdr64.e_phoff),</span>
<span class="line" id="L399">            .shoff = int(is_64, need_bswap, hdr32.e_shoff, hdr64.e_shoff),</span>
<span class="line" id="L400">            .phentsize = int(is_64, need_bswap, hdr32.e_phentsize, hdr64.e_phentsize),</span>
<span class="line" id="L401">            .phnum = int(is_64, need_bswap, hdr32.e_phnum, hdr64.e_phnum),</span>
<span class="line" id="L402">            .shentsize = int(is_64, need_bswap, hdr32.e_shentsize, hdr64.e_shentsize),</span>
<span class="line" id="L403">            .shnum = int(is_64, need_bswap, hdr32.e_shnum, hdr64.e_shnum),</span>
<span class="line" id="L404">            .shstrndx = int(is_64, need_bswap, hdr32.e_shstrndx, hdr64.e_shstrndx),</span>
<span class="line" id="L405">        });</span>
<span class="line" id="L406">    }</span>
<span class="line" id="L407">};</span>
<span class="line" id="L408"></span>
<span class="line" id="L409"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ProgramHeaderIterator</span>(ParseSource: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L410">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L411">        elf_header: Header,</span>
<span class="line" id="L412">        parse_source: ParseSource,</span>
<span class="line" id="L413">        index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *<span class="tok-builtin">@This</span>()) !?Elf64_Phdr {</span>
<span class="line" id="L416">            <span class="tok-kw">if</span> (self.index &gt;= self.elf_header.phnum) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L417">            <span class="tok-kw">defer</span> self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">            <span class="tok-kw">if</span> (self.elf_header.is_64) {</span>
<span class="line" id="L420">                <span class="tok-kw">var</span> phdr: Elf64_Phdr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L421">                <span class="tok-kw">const</span> offset = self.elf_header.phoff + <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(phdr)) * self.index;</span>
<span class="line" id="L422">                <span class="tok-kw">try</span> self.parse_source.seekableStream().seekTo(offset);</span>
<span class="line" id="L423">                <span class="tok-kw">try</span> self.parse_source.reader().readNoEof(mem.asBytes(&amp;phdr));</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">                <span class="tok-comment">// ELF endianness matches native endianness.</span>
</span>
<span class="line" id="L426">                <span class="tok-kw">if</span> (self.elf_header.endian == native_endian) <span class="tok-kw">return</span> phdr;</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">                <span class="tok-comment">// Convert fields to native endianness.</span>
</span>
<span class="line" id="L429">                mem.byteSwapAllFields(Elf64_Phdr, &amp;phdr);</span>
<span class="line" id="L430">                <span class="tok-kw">return</span> phdr;</span>
<span class="line" id="L431">            }</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">            <span class="tok-kw">var</span> phdr: Elf32_Phdr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L434">            <span class="tok-kw">const</span> offset = self.elf_header.phoff + <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(phdr)) * self.index;</span>
<span class="line" id="L435">            <span class="tok-kw">try</span> self.parse_source.seekableStream().seekTo(offset);</span>
<span class="line" id="L436">            <span class="tok-kw">try</span> self.parse_source.reader().readNoEof(mem.asBytes(&amp;phdr));</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">            <span class="tok-comment">// ELF endianness does NOT match native endianness.</span>
</span>
<span class="line" id="L439">            <span class="tok-kw">if</span> (self.elf_header.endian != native_endian) {</span>
<span class="line" id="L440">                <span class="tok-comment">// Convert fields to native endianness.</span>
</span>
<span class="line" id="L441">                mem.byteSwapAllFields(Elf32_Phdr, &amp;phdr);</span>
<span class="line" id="L442">            }</span>
<span class="line" id="L443"></span>
<span class="line" id="L444">            <span class="tok-comment">// Convert 32-bit header to 64-bit.</span>
</span>
<span class="line" id="L445">            <span class="tok-kw">return</span> Elf64_Phdr{</span>
<span class="line" id="L446">                .p_type = phdr.p_type,</span>
<span class="line" id="L447">                .p_offset = phdr.p_offset,</span>
<span class="line" id="L448">                .p_vaddr = phdr.p_vaddr,</span>
<span class="line" id="L449">                .p_paddr = phdr.p_paddr,</span>
<span class="line" id="L450">                .p_filesz = phdr.p_filesz,</span>
<span class="line" id="L451">                .p_memsz = phdr.p_memsz,</span>
<span class="line" id="L452">                .p_flags = phdr.p_flags,</span>
<span class="line" id="L453">                .p_align = phdr.p_align,</span>
<span class="line" id="L454">            };</span>
<span class="line" id="L455">        }</span>
<span class="line" id="L456">    };</span>
<span class="line" id="L457">}</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SectionHeaderIterator</span>(ParseSource: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L460">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L461">        elf_header: Header,</span>
<span class="line" id="L462">        parse_source: ParseSource,</span>
<span class="line" id="L463">        index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *<span class="tok-builtin">@This</span>()) !?Elf64_Shdr {</span>
<span class="line" id="L466">            <span class="tok-kw">if</span> (self.index &gt;= self.elf_header.shnum) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L467">            <span class="tok-kw">defer</span> self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L468"></span>
<span class="line" id="L469">            <span class="tok-kw">if</span> (self.elf_header.is_64) {</span>
<span class="line" id="L470">                <span class="tok-kw">var</span> shdr: Elf64_Shdr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L471">                <span class="tok-kw">const</span> offset = self.elf_header.shoff + <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(shdr)) * self.index;</span>
<span class="line" id="L472">                <span class="tok-kw">try</span> self.parse_source.seekableStream().seekTo(offset);</span>
<span class="line" id="L473">                <span class="tok-kw">try</span> self.parse_source.reader().readNoEof(mem.asBytes(&amp;shdr));</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">                <span class="tok-comment">// ELF endianness matches native endianness.</span>
</span>
<span class="line" id="L476">                <span class="tok-kw">if</span> (self.elf_header.endian == native_endian) <span class="tok-kw">return</span> shdr;</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">                <span class="tok-comment">// Convert fields to native endianness.</span>
</span>
<span class="line" id="L479">                mem.byteSwapAllFields(Elf64_Shdr, &amp;shdr);</span>
<span class="line" id="L480">                <span class="tok-kw">return</span> shdr;</span>
<span class="line" id="L481">            }</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">            <span class="tok-kw">var</span> shdr: Elf32_Shdr = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L484">            <span class="tok-kw">const</span> offset = self.elf_header.shoff + <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(shdr)) * self.index;</span>
<span class="line" id="L485">            <span class="tok-kw">try</span> self.parse_source.seekableStream().seekTo(offset);</span>
<span class="line" id="L486">            <span class="tok-kw">try</span> self.parse_source.reader().readNoEof(mem.asBytes(&amp;shdr));</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">            <span class="tok-comment">// ELF endianness does NOT match native endianness.</span>
</span>
<span class="line" id="L489">            <span class="tok-kw">if</span> (self.elf_header.endian != native_endian) {</span>
<span class="line" id="L490">                <span class="tok-comment">// Convert fields to native endianness.</span>
</span>
<span class="line" id="L491">                mem.byteSwapAllFields(Elf32_Shdr, &amp;shdr);</span>
<span class="line" id="L492">            }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">            <span class="tok-comment">// Convert 32-bit header to 64-bit.</span>
</span>
<span class="line" id="L495">            <span class="tok-kw">return</span> Elf64_Shdr{</span>
<span class="line" id="L496">                .sh_name = shdr.sh_name,</span>
<span class="line" id="L497">                .sh_type = shdr.sh_type,</span>
<span class="line" id="L498">                .sh_flags = shdr.sh_flags,</span>
<span class="line" id="L499">                .sh_addr = shdr.sh_addr,</span>
<span class="line" id="L500">                .sh_offset = shdr.sh_offset,</span>
<span class="line" id="L501">                .sh_size = shdr.sh_size,</span>
<span class="line" id="L502">                .sh_link = shdr.sh_link,</span>
<span class="line" id="L503">                .sh_info = shdr.sh_info,</span>
<span class="line" id="L504">                .sh_addralign = shdr.sh_addralign,</span>
<span class="line" id="L505">                .sh_entsize = shdr.sh_entsize,</span>
<span class="line" id="L506">            };</span>
<span class="line" id="L507">        }</span>
<span class="line" id="L508">    };</span>
<span class="line" id="L509">}</span>
<span class="line" id="L510"></span>
<span class="line" id="L511"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">int</span>(is_64: <span class="tok-type">bool</span>, need_bswap: <span class="tok-type">bool</span>, int_32: <span class="tok-kw">anytype</span>, int_64: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(int_64) {</span>
<span class="line" id="L512">    <span class="tok-kw">if</span> (is_64) {</span>
<span class="line" id="L513">        <span class="tok-kw">if</span> (need_bswap) {</span>
<span class="line" id="L514">            <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(int_64), int_64);</span>
<span class="line" id="L515">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L516">            <span class="tok-kw">return</span> int_64;</span>
<span class="line" id="L517">        }</span>
<span class="line" id="L518">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L519">        <span class="tok-kw">return</span> int32(need_bswap, int_32, <span class="tok-builtin">@TypeOf</span>(int_64));</span>
<span class="line" id="L520">    }</span>
<span class="line" id="L521">}</span>
<span class="line" id="L522"></span>
<span class="line" id="L523"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">int32</span>(need_bswap: <span class="tok-type">bool</span>, int_32: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> Int64: <span class="tok-kw">anytype</span>) Int64 {</span>
<span class="line" id="L524">    <span class="tok-kw">if</span> (need_bswap) {</span>
<span class="line" id="L525">        <span class="tok-kw">return</span> <span class="tok-builtin">@byteSwap</span>(<span class="tok-builtin">@TypeOf</span>(int_32), int_32);</span>
<span class="line" id="L526">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L527">        <span class="tok-kw">return</span> int_32;</span>
<span class="line" id="L528">    }</span>
<span class="line" id="L529">}</span>
<span class="line" id="L530"></span>
<span class="line" id="L531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EI_NIDENT = <span class="tok-number">16</span>;</span>
<span class="line" id="L532"></span>
<span class="line" id="L533"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EI_CLASS = <span class="tok-number">4</span>;</span>
<span class="line" id="L534"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFCLASSNONE = <span class="tok-number">0</span>;</span>
<span class="line" id="L535"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFCLASS32 = <span class="tok-number">1</span>;</span>
<span class="line" id="L536"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFCLASS64 = <span class="tok-number">2</span>;</span>
<span class="line" id="L537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFCLASSNUM = <span class="tok-number">3</span>;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EI_DATA = <span class="tok-number">5</span>;</span>
<span class="line" id="L540"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFDATANONE = <span class="tok-number">0</span>;</span>
<span class="line" id="L541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFDATA2LSB = <span class="tok-number">1</span>;</span>
<span class="line" id="L542"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFDATA2MSB = <span class="tok-number">2</span>;</span>
<span class="line" id="L543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ELFDATANUM = <span class="tok-number">3</span>;</span>
<span class="line" id="L544"></span>
<span class="line" id="L545"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EI_VERSION = <span class="tok-number">6</span>;</span>
<span class="line" id="L546"></span>
<span class="line" id="L547"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Half = <span class="tok-type">u16</span>;</span>
<span class="line" id="L548"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Half = <span class="tok-type">u16</span>;</span>
<span class="line" id="L549"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Word = <span class="tok-type">u32</span>;</span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Sword = <span class="tok-type">i32</span>;</span>
<span class="line" id="L551"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Word = <span class="tok-type">u32</span>;</span>
<span class="line" id="L552"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Sword = <span class="tok-type">i32</span>;</span>
<span class="line" id="L553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Xword = <span class="tok-type">u64</span>;</span>
<span class="line" id="L554"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Sxword = <span class="tok-type">i64</span>;</span>
<span class="line" id="L555"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Xword = <span class="tok-type">u64</span>;</span>
<span class="line" id="L556"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Sxword = <span class="tok-type">i64</span>;</span>
<span class="line" id="L557"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Addr = <span class="tok-type">u32</span>;</span>
<span class="line" id="L558"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Addr = <span class="tok-type">u64</span>;</span>
<span class="line" id="L559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Off = <span class="tok-type">u32</span>;</span>
<span class="line" id="L560"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Off = <span class="tok-type">u64</span>;</span>
<span class="line" id="L561"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Section = <span class="tok-type">u16</span>;</span>
<span class="line" id="L562"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Section = <span class="tok-type">u16</span>;</span>
<span class="line" id="L563"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Versym = Elf32_Half;</span>
<span class="line" id="L564"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Versym = Elf64_Half;</span>
<span class="line" id="L565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Ehdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L566">    e_ident: [EI_NIDENT]<span class="tok-type">u8</span>,</span>
<span class="line" id="L567">    e_type: ET,</span>
<span class="line" id="L568">    e_machine: EM,</span>
<span class="line" id="L569">    e_version: Elf32_Word,</span>
<span class="line" id="L570">    e_entry: Elf32_Addr,</span>
<span class="line" id="L571">    e_phoff: Elf32_Off,</span>
<span class="line" id="L572">    e_shoff: Elf32_Off,</span>
<span class="line" id="L573">    e_flags: Elf32_Word,</span>
<span class="line" id="L574">    e_ehsize: Elf32_Half,</span>
<span class="line" id="L575">    e_phentsize: Elf32_Half,</span>
<span class="line" id="L576">    e_phnum: Elf32_Half,</span>
<span class="line" id="L577">    e_shentsize: Elf32_Half,</span>
<span class="line" id="L578">    e_shnum: Elf32_Half,</span>
<span class="line" id="L579">    e_shstrndx: Elf32_Half,</span>
<span class="line" id="L580">};</span>
<span class="line" id="L581"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Ehdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L582">    e_ident: [EI_NIDENT]<span class="tok-type">u8</span>,</span>
<span class="line" id="L583">    e_type: ET,</span>
<span class="line" id="L584">    e_machine: EM,</span>
<span class="line" id="L585">    e_version: Elf64_Word,</span>
<span class="line" id="L586">    e_entry: Elf64_Addr,</span>
<span class="line" id="L587">    e_phoff: Elf64_Off,</span>
<span class="line" id="L588">    e_shoff: Elf64_Off,</span>
<span class="line" id="L589">    e_flags: Elf64_Word,</span>
<span class="line" id="L590">    e_ehsize: Elf64_Half,</span>
<span class="line" id="L591">    e_phentsize: Elf64_Half,</span>
<span class="line" id="L592">    e_phnum: Elf64_Half,</span>
<span class="line" id="L593">    e_shentsize: Elf64_Half,</span>
<span class="line" id="L594">    e_shnum: Elf64_Half,</span>
<span class="line" id="L595">    e_shstrndx: Elf64_Half,</span>
<span class="line" id="L596">};</span>
<span class="line" id="L597"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Phdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L598">    p_type: Elf32_Word,</span>
<span class="line" id="L599">    p_offset: Elf32_Off,</span>
<span class="line" id="L600">    p_vaddr: Elf32_Addr,</span>
<span class="line" id="L601">    p_paddr: Elf32_Addr,</span>
<span class="line" id="L602">    p_filesz: Elf32_Word,</span>
<span class="line" id="L603">    p_memsz: Elf32_Word,</span>
<span class="line" id="L604">    p_flags: Elf32_Word,</span>
<span class="line" id="L605">    p_align: Elf32_Word,</span>
<span class="line" id="L606">};</span>
<span class="line" id="L607"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Phdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L608">    p_type: Elf64_Word,</span>
<span class="line" id="L609">    p_flags: Elf64_Word,</span>
<span class="line" id="L610">    p_offset: Elf64_Off,</span>
<span class="line" id="L611">    p_vaddr: Elf64_Addr,</span>
<span class="line" id="L612">    p_paddr: Elf64_Addr,</span>
<span class="line" id="L613">    p_filesz: Elf64_Xword,</span>
<span class="line" id="L614">    p_memsz: Elf64_Xword,</span>
<span class="line" id="L615">    p_align: Elf64_Xword,</span>
<span class="line" id="L616">};</span>
<span class="line" id="L617"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Shdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L618">    sh_name: Elf32_Word,</span>
<span class="line" id="L619">    sh_type: Elf32_Word,</span>
<span class="line" id="L620">    sh_flags: Elf32_Word,</span>
<span class="line" id="L621">    sh_addr: Elf32_Addr,</span>
<span class="line" id="L622">    sh_offset: Elf32_Off,</span>
<span class="line" id="L623">    sh_size: Elf32_Word,</span>
<span class="line" id="L624">    sh_link: Elf32_Word,</span>
<span class="line" id="L625">    sh_info: Elf32_Word,</span>
<span class="line" id="L626">    sh_addralign: Elf32_Word,</span>
<span class="line" id="L627">    sh_entsize: Elf32_Word,</span>
<span class="line" id="L628">};</span>
<span class="line" id="L629"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Shdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L630">    sh_name: Elf64_Word,</span>
<span class="line" id="L631">    sh_type: Elf64_Word,</span>
<span class="line" id="L632">    sh_flags: Elf64_Xword,</span>
<span class="line" id="L633">    sh_addr: Elf64_Addr,</span>
<span class="line" id="L634">    sh_offset: Elf64_Off,</span>
<span class="line" id="L635">    sh_size: Elf64_Xword,</span>
<span class="line" id="L636">    sh_link: Elf64_Word,</span>
<span class="line" id="L637">    sh_info: Elf64_Word,</span>
<span class="line" id="L638">    sh_addralign: Elf64_Xword,</span>
<span class="line" id="L639">    sh_entsize: Elf64_Xword,</span>
<span class="line" id="L640">};</span>
<span class="line" id="L641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Chdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L642">    ch_type: Elf32_Word,</span>
<span class="line" id="L643">    ch_size: Elf32_Word,</span>
<span class="line" id="L644">    ch_addralign: Elf32_Word,</span>
<span class="line" id="L645">};</span>
<span class="line" id="L646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Chdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L647">    ch_type: Elf64_Word,</span>
<span class="line" id="L648">    ch_reserved: Elf64_Word,</span>
<span class="line" id="L649">    ch_size: Elf64_Xword,</span>
<span class="line" id="L650">    ch_addralign: Elf64_Xword,</span>
<span class="line" id="L651">};</span>
<span class="line" id="L652"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Sym = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L653">    st_name: Elf32_Word,</span>
<span class="line" id="L654">    st_value: Elf32_Addr,</span>
<span class="line" id="L655">    st_size: Elf32_Word,</span>
<span class="line" id="L656">    st_info: <span class="tok-type">u8</span>,</span>
<span class="line" id="L657">    st_other: <span class="tok-type">u8</span>,</span>
<span class="line" id="L658">    st_shndx: Elf32_Section,</span>
<span class="line" id="L659">};</span>
<span class="line" id="L660"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Sym = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L661">    st_name: Elf64_Word,</span>
<span class="line" id="L662">    st_info: <span class="tok-type">u8</span>,</span>
<span class="line" id="L663">    st_other: <span class="tok-type">u8</span>,</span>
<span class="line" id="L664">    st_shndx: Elf64_Section,</span>
<span class="line" id="L665">    st_value: Elf64_Addr,</span>
<span class="line" id="L666">    st_size: Elf64_Xword,</span>
<span class="line" id="L667">};</span>
<span class="line" id="L668"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Syminfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L669">    si_boundto: Elf32_Half,</span>
<span class="line" id="L670">    si_flags: Elf32_Half,</span>
<span class="line" id="L671">};</span>
<span class="line" id="L672"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Syminfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L673">    si_boundto: Elf64_Half,</span>
<span class="line" id="L674">    si_flags: Elf64_Half,</span>
<span class="line" id="L675">};</span>
<span class="line" id="L676"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Rel = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L677">    r_offset: Elf32_Addr,</span>
<span class="line" id="L678">    r_info: Elf32_Word,</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_sym</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u24</span> {</span>
<span class="line" id="L681">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u24</span>, self.r_info &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L682">    }</span>
<span class="line" id="L683">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_type</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u8</span> {</span>
<span class="line" id="L684">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, self.r_info &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L685">    }</span>
<span class="line" id="L686">};</span>
<span class="line" id="L687"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Rel = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L688">    r_offset: Elf64_Addr,</span>
<span class="line" id="L689">    r_info: Elf64_Xword,</span>
<span class="line" id="L690"></span>
<span class="line" id="L691">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_sym</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u32</span> {</span>
<span class="line" id="L692">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, self.r_info &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L693">    }</span>
<span class="line" id="L694">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_type</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u32</span> {</span>
<span class="line" id="L695">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, self.r_info &amp; <span class="tok-number">0xffffffff</span>);</span>
<span class="line" id="L696">    }</span>
<span class="line" id="L697">};</span>
<span class="line" id="L698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Rela = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L699">    r_offset: Elf32_Addr,</span>
<span class="line" id="L700">    r_info: Elf32_Word,</span>
<span class="line" id="L701">    r_addend: Elf32_Sword,</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_sym</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u24</span> {</span>
<span class="line" id="L704">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u24</span>, self.r_info &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L705">    }</span>
<span class="line" id="L706">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_type</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u8</span> {</span>
<span class="line" id="L707">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, self.r_info &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L708">    }</span>
<span class="line" id="L709">};</span>
<span class="line" id="L710"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Rela = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L711">    r_offset: Elf64_Addr,</span>
<span class="line" id="L712">    r_info: Elf64_Xword,</span>
<span class="line" id="L713">    r_addend: Elf64_Sxword,</span>
<span class="line" id="L714"></span>
<span class="line" id="L715">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_sym</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u32</span> {</span>
<span class="line" id="L716">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, self.r_info &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L717">    }</span>
<span class="line" id="L718">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">r_type</span>(self: <span class="tok-builtin">@This</span>()) <span class="tok-type">u32</span> {</span>
<span class="line" id="L719">        <span class="tok-kw">return</span> <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, self.r_info &amp; <span class="tok-number">0xffffffff</span>);</span>
<span class="line" id="L720">    }</span>
<span class="line" id="L721">};</span>
<span class="line" id="L722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Dyn = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L723">    d_tag: Elf32_Sword,</span>
<span class="line" id="L724">    d_val: Elf32_Addr,</span>
<span class="line" id="L725">};</span>
<span class="line" id="L726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Dyn = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L727">    d_tag: Elf64_Sxword,</span>
<span class="line" id="L728">    d_val: Elf64_Addr,</span>
<span class="line" id="L729">};</span>
<span class="line" id="L730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Verdef = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L731">    vd_version: Elf32_Half,</span>
<span class="line" id="L732">    vd_flags: Elf32_Half,</span>
<span class="line" id="L733">    vd_ndx: Elf32_Half,</span>
<span class="line" id="L734">    vd_cnt: Elf32_Half,</span>
<span class="line" id="L735">    vd_hash: Elf32_Word,</span>
<span class="line" id="L736">    vd_aux: Elf32_Word,</span>
<span class="line" id="L737">    vd_next: Elf32_Word,</span>
<span class="line" id="L738">};</span>
<span class="line" id="L739"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Verdef = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L740">    vd_version: Elf64_Half,</span>
<span class="line" id="L741">    vd_flags: Elf64_Half,</span>
<span class="line" id="L742">    vd_ndx: Elf64_Half,</span>
<span class="line" id="L743">    vd_cnt: Elf64_Half,</span>
<span class="line" id="L744">    vd_hash: Elf64_Word,</span>
<span class="line" id="L745">    vd_aux: Elf64_Word,</span>
<span class="line" id="L746">    vd_next: Elf64_Word,</span>
<span class="line" id="L747">};</span>
<span class="line" id="L748"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Verdaux = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L749">    vda_name: Elf32_Word,</span>
<span class="line" id="L750">    vda_next: Elf32_Word,</span>
<span class="line" id="L751">};</span>
<span class="line" id="L752"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Verdaux = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L753">    vda_name: Elf64_Word,</span>
<span class="line" id="L754">    vda_next: Elf64_Word,</span>
<span class="line" id="L755">};</span>
<span class="line" id="L756"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Verneed = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L757">    vn_version: Elf32_Half,</span>
<span class="line" id="L758">    vn_cnt: Elf32_Half,</span>
<span class="line" id="L759">    vn_file: Elf32_Word,</span>
<span class="line" id="L760">    vn_aux: Elf32_Word,</span>
<span class="line" id="L761">    vn_next: Elf32_Word,</span>
<span class="line" id="L762">};</span>
<span class="line" id="L763"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Verneed = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L764">    vn_version: Elf64_Half,</span>
<span class="line" id="L765">    vn_cnt: Elf64_Half,</span>
<span class="line" id="L766">    vn_file: Elf64_Word,</span>
<span class="line" id="L767">    vn_aux: Elf64_Word,</span>
<span class="line" id="L768">    vn_next: Elf64_Word,</span>
<span class="line" id="L769">};</span>
<span class="line" id="L770"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Vernaux = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L771">    vna_hash: Elf32_Word,</span>
<span class="line" id="L772">    vna_flags: Elf32_Half,</span>
<span class="line" id="L773">    vna_other: Elf32_Half,</span>
<span class="line" id="L774">    vna_name: Elf32_Word,</span>
<span class="line" id="L775">    vna_next: Elf32_Word,</span>
<span class="line" id="L776">};</span>
<span class="line" id="L777"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Vernaux = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L778">    vna_hash: Elf64_Word,</span>
<span class="line" id="L779">    vna_flags: Elf64_Half,</span>
<span class="line" id="L780">    vna_other: Elf64_Half,</span>
<span class="line" id="L781">    vna_name: Elf64_Word,</span>
<span class="line" id="L782">    vna_next: Elf64_Word,</span>
<span class="line" id="L783">};</span>
<span class="line" id="L784"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_auxv_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L785">    a_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L786">    a_un: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L787">        a_val: <span class="tok-type">u32</span>,</span>
<span class="line" id="L788">    },</span>
<span class="line" id="L789">};</span>
<span class="line" id="L790"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_auxv_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L791">    a_type: <span class="tok-type">u64</span>,</span>
<span class="line" id="L792">    a_un: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L793">        a_val: <span class="tok-type">u64</span>,</span>
<span class="line" id="L794">    },</span>
<span class="line" id="L795">};</span>
<span class="line" id="L796"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Nhdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L797">    n_namesz: Elf32_Word,</span>
<span class="line" id="L798">    n_descsz: Elf32_Word,</span>
<span class="line" id="L799">    n_type: Elf32_Word,</span>
<span class="line" id="L800">};</span>
<span class="line" id="L801"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Nhdr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L802">    n_namesz: Elf64_Word,</span>
<span class="line" id="L803">    n_descsz: Elf64_Word,</span>
<span class="line" id="L804">    n_type: Elf64_Word,</span>
<span class="line" id="L805">};</span>
<span class="line" id="L806"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Move = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L807">    m_value: Elf32_Xword,</span>
<span class="line" id="L808">    m_info: Elf32_Word,</span>
<span class="line" id="L809">    m_poffset: Elf32_Word,</span>
<span class="line" id="L810">    m_repeat: Elf32_Half,</span>
<span class="line" id="L811">    m_stride: Elf32_Half,</span>
<span class="line" id="L812">};</span>
<span class="line" id="L813"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Move = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L814">    m_value: Elf64_Xword,</span>
<span class="line" id="L815">    m_info: Elf64_Xword,</span>
<span class="line" id="L816">    m_poffset: Elf64_Xword,</span>
<span class="line" id="L817">    m_repeat: Elf64_Half,</span>
<span class="line" id="L818">    m_stride: Elf64_Half,</span>
<span class="line" id="L819">};</span>
<span class="line" id="L820"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_gptab = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L821">    gt_header: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L822">        gt_current_g_value: Elf32_Word,</span>
<span class="line" id="L823">        gt_unused: Elf32_Word,</span>
<span class="line" id="L824">    },</span>
<span class="line" id="L825">    gt_entry: <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L826">        gt_g_value: Elf32_Word,</span>
<span class="line" id="L827">        gt_bytes: Elf32_Word,</span>
<span class="line" id="L828">    },</span>
<span class="line" id="L829">};</span>
<span class="line" id="L830"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_RegInfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L831">    ri_gprmask: Elf32_Word,</span>
<span class="line" id="L832">    ri_cprmask: [<span class="tok-number">4</span>]Elf32_Word,</span>
<span class="line" id="L833">    ri_gp_value: Elf32_Sword,</span>
<span class="line" id="L834">};</span>
<span class="line" id="L835"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf_Options = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L836">    kind: <span class="tok-type">u8</span>,</span>
<span class="line" id="L837">    size: <span class="tok-type">u8</span>,</span>
<span class="line" id="L838">    @&quot;section&quot;: Elf32_Section,</span>
<span class="line" id="L839">    info: Elf32_Word,</span>
<span class="line" id="L840">};</span>
<span class="line" id="L841"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf_Options_Hw = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L842">    hwp_flags1: Elf32_Word,</span>
<span class="line" id="L843">    hwp_flags2: Elf32_Word,</span>
<span class="line" id="L844">};</span>
<span class="line" id="L845"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Lib = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L846">    l_name: Elf32_Word,</span>
<span class="line" id="L847">    l_time_stamp: Elf32_Word,</span>
<span class="line" id="L848">    l_checksum: Elf32_Word,</span>
<span class="line" id="L849">    l_version: Elf32_Word,</span>
<span class="line" id="L850">    l_flags: Elf32_Word,</span>
<span class="line" id="L851">};</span>
<span class="line" id="L852"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf64_Lib = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L853">    l_name: Elf64_Word,</span>
<span class="line" id="L854">    l_time_stamp: Elf64_Word,</span>
<span class="line" id="L855">    l_checksum: Elf64_Word,</span>
<span class="line" id="L856">    l_version: Elf64_Word,</span>
<span class="line" id="L857">    l_flags: Elf64_Word,</span>
<span class="line" id="L858">};</span>
<span class="line" id="L859"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf32_Conflict = Elf32_Addr;</span>
<span class="line" id="L860"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Elf_MIPS_ABIFlags_v0 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L861">    version: Elf32_Half,</span>
<span class="line" id="L862">    isa_level: <span class="tok-type">u8</span>,</span>
<span class="line" id="L863">    isa_rev: <span class="tok-type">u8</span>,</span>
<span class="line" id="L864">    gpr_size: <span class="tok-type">u8</span>,</span>
<span class="line" id="L865">    cpr1_size: <span class="tok-type">u8</span>,</span>
<span class="line" id="L866">    cpr2_size: <span class="tok-type">u8</span>,</span>
<span class="line" id="L867">    fp_abi: <span class="tok-type">u8</span>,</span>
<span class="line" id="L868">    isa_ext: Elf32_Word,</span>
<span class="line" id="L869">    ases: Elf32_Word,</span>
<span class="line" id="L870">    flags1: Elf32_Word,</span>
<span class="line" id="L871">    flags2: Elf32_Word,</span>
<span class="line" id="L872">};</span>
<span class="line" id="L873"></span>
<span class="line" id="L874"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L875">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf32_Ehdr) == <span class="tok-number">52</span>);</span>
<span class="line" id="L876">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf64_Ehdr) == <span class="tok-number">64</span>);</span>
<span class="line" id="L877"></span>
<span class="line" id="L878">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf32_Phdr) == <span class="tok-number">32</span>);</span>
<span class="line" id="L879">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf64_Phdr) == <span class="tok-number">56</span>);</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf32_Shdr) == <span class="tok-number">40</span>);</span>
<span class="line" id="L882">    debug.assert(<span class="tok-builtin">@sizeOf</span>(Elf64_Shdr) == <span class="tok-number">64</span>);</span>
<span class="line" id="L883">}</span>
<span class="line" id="L884"></span>
<span class="line" id="L885"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Auxv = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L886">    <span class="tok-number">4</span> =&gt; Elf32_auxv_t,</span>
<span class="line" id="L887">    <span class="tok-number">8</span> =&gt; Elf64_auxv_t,</span>
<span class="line" id="L888">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L889">};</span>
<span class="line" id="L890"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ehdr = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L891">    <span class="tok-number">4</span> =&gt; Elf32_Ehdr,</span>
<span class="line" id="L892">    <span class="tok-number">8</span> =&gt; Elf64_Ehdr,</span>
<span class="line" id="L893">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L894">};</span>
<span class="line" id="L895"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Phdr = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L896">    <span class="tok-number">4</span> =&gt; Elf32_Phdr,</span>
<span class="line" id="L897">    <span class="tok-number">8</span> =&gt; Elf64_Phdr,</span>
<span class="line" id="L898">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L899">};</span>
<span class="line" id="L900"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Dyn = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L901">    <span class="tok-number">4</span> =&gt; Elf32_Dyn,</span>
<span class="line" id="L902">    <span class="tok-number">8</span> =&gt; Elf64_Dyn,</span>
<span class="line" id="L903">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L904">};</span>
<span class="line" id="L905"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Rel = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L906">    <span class="tok-number">4</span> =&gt; Elf32_Rel,</span>
<span class="line" id="L907">    <span class="tok-number">8</span> =&gt; Elf64_Rel,</span>
<span class="line" id="L908">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L909">};</span>
<span class="line" id="L910"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Rela = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L911">    <span class="tok-number">4</span> =&gt; Elf32_Rela,</span>
<span class="line" id="L912">    <span class="tok-number">8</span> =&gt; Elf64_Rela,</span>
<span class="line" id="L913">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L914">};</span>
<span class="line" id="L915"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Shdr = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L916">    <span class="tok-number">4</span> =&gt; Elf32_Shdr,</span>
<span class="line" id="L917">    <span class="tok-number">8</span> =&gt; Elf64_Shdr,</span>
<span class="line" id="L918">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L919">};</span>
<span class="line" id="L920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sym = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L921">    <span class="tok-number">4</span> =&gt; Elf32_Sym,</span>
<span class="line" id="L922">    <span class="tok-number">8</span> =&gt; Elf64_Sym,</span>
<span class="line" id="L923">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L924">};</span>
<span class="line" id="L925"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Verdef = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L926">    <span class="tok-number">4</span> =&gt; Elf32_Verdef,</span>
<span class="line" id="L927">    <span class="tok-number">8</span> =&gt; Elf64_Verdef,</span>
<span class="line" id="L928">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L929">};</span>
<span class="line" id="L930"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Verdaux = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L931">    <span class="tok-number">4</span> =&gt; Elf32_Verdaux,</span>
<span class="line" id="L932">    <span class="tok-number">8</span> =&gt; Elf64_Verdaux,</span>
<span class="line" id="L933">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L934">};</span>
<span class="line" id="L935"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Addr = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L936">    <span class="tok-number">4</span> =&gt; Elf32_Addr,</span>
<span class="line" id="L937">    <span class="tok-number">8</span> =&gt; Elf64_Addr,</span>
<span class="line" id="L938">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L939">};</span>
<span class="line" id="L940"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Half = <span class="tok-kw">switch</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>)) {</span>
<span class="line" id="L941">    <span class="tok-number">4</span> =&gt; Elf32_Half,</span>
<span class="line" id="L942">    <span class="tok-number">8</span> =&gt; Elf64_Half,</span>
<span class="line" id="L943">    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;expected pointer size of 32 or 64&quot;</span>),</span>
<span class="line" id="L944">};</span>
<span class="line" id="L945"></span>
<span class="line" id="L946"><span class="tok-comment">/// Machine architectures.</span></span>
<span class="line" id="L947"><span class="tok-comment">///</span></span>
<span class="line" id="L948"><span class="tok-comment">/// See current registered ELF machine architectures at:</span></span>
<span class="line" id="L949"><span class="tok-comment">/// http://www.sco.com/developers/gabi/latest/ch4.eheader.html</span></span>
<span class="line" id="L950"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L951">    <span class="tok-comment">/// No machine</span></span>
<span class="line" id="L952">    NONE = <span class="tok-number">0</span>,</span>
<span class="line" id="L953"></span>
<span class="line" id="L954">    <span class="tok-comment">/// AT&amp;T WE 32100</span></span>
<span class="line" id="L955">    M32 = <span class="tok-number">1</span>,</span>
<span class="line" id="L956"></span>
<span class="line" id="L957">    <span class="tok-comment">/// SPARC</span></span>
<span class="line" id="L958">    SPARC = <span class="tok-number">2</span>,</span>
<span class="line" id="L959"></span>
<span class="line" id="L960">    <span class="tok-comment">/// Intel 386</span></span>
<span class="line" id="L961">    @&quot;386&quot; = <span class="tok-number">3</span>,</span>
<span class="line" id="L962"></span>
<span class="line" id="L963">    <span class="tok-comment">/// Motorola 68000</span></span>
<span class="line" id="L964">    @&quot;68K&quot; = <span class="tok-number">4</span>,</span>
<span class="line" id="L965"></span>
<span class="line" id="L966">    <span class="tok-comment">/// Motorola 88000</span></span>
<span class="line" id="L967">    @&quot;88K&quot; = <span class="tok-number">5</span>,</span>
<span class="line" id="L968"></span>
<span class="line" id="L969">    <span class="tok-comment">/// Intel MCU</span></span>
<span class="line" id="L970">    IAMCU = <span class="tok-number">6</span>,</span>
<span class="line" id="L971"></span>
<span class="line" id="L972">    <span class="tok-comment">/// Intel 80860</span></span>
<span class="line" id="L973">    @&quot;860&quot; = <span class="tok-number">7</span>,</span>
<span class="line" id="L974"></span>
<span class="line" id="L975">    <span class="tok-comment">/// MIPS R3000</span></span>
<span class="line" id="L976">    MIPS = <span class="tok-number">8</span>,</span>
<span class="line" id="L977"></span>
<span class="line" id="L978">    <span class="tok-comment">/// IBM System/370</span></span>
<span class="line" id="L979">    S370 = <span class="tok-number">9</span>,</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">    <span class="tok-comment">/// MIPS RS3000 Little-endian</span></span>
<span class="line" id="L982">    MIPS_RS3_LE = <span class="tok-number">10</span>,</span>
<span class="line" id="L983"></span>
<span class="line" id="L984">    <span class="tok-comment">/// SPU Mark II</span></span>
<span class="line" id="L985">    SPU_2 = <span class="tok-number">13</span>,</span>
<span class="line" id="L986"></span>
<span class="line" id="L987">    <span class="tok-comment">/// Hewlett-Packard PA-RISC</span></span>
<span class="line" id="L988">    PARISC = <span class="tok-number">15</span>,</span>
<span class="line" id="L989"></span>
<span class="line" id="L990">    <span class="tok-comment">/// Fujitsu VPP500</span></span>
<span class="line" id="L991">    VPP500 = <span class="tok-number">17</span>,</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">    <span class="tok-comment">/// Enhanced instruction set SPARC</span></span>
<span class="line" id="L994">    SPARC32PLUS = <span class="tok-number">18</span>,</span>
<span class="line" id="L995"></span>
<span class="line" id="L996">    <span class="tok-comment">/// Intel 80960</span></span>
<span class="line" id="L997">    @&quot;960&quot; = <span class="tok-number">19</span>,</span>
<span class="line" id="L998"></span>
<span class="line" id="L999">    <span class="tok-comment">/// PowerPC</span></span>
<span class="line" id="L1000">    PPC = <span class="tok-number">20</span>,</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002">    <span class="tok-comment">/// PowerPC64</span></span>
<span class="line" id="L1003">    PPC64 = <span class="tok-number">21</span>,</span>
<span class="line" id="L1004"></span>
<span class="line" id="L1005">    <span class="tok-comment">/// IBM System/390</span></span>
<span class="line" id="L1006">    S390 = <span class="tok-number">22</span>,</span>
<span class="line" id="L1007"></span>
<span class="line" id="L1008">    <span class="tok-comment">/// IBM SPU/SPC</span></span>
<span class="line" id="L1009">    SPU = <span class="tok-number">23</span>,</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011">    <span class="tok-comment">/// NEC V800</span></span>
<span class="line" id="L1012">    V800 = <span class="tok-number">36</span>,</span>
<span class="line" id="L1013"></span>
<span class="line" id="L1014">    <span class="tok-comment">/// Fujitsu FR20</span></span>
<span class="line" id="L1015">    FR20 = <span class="tok-number">37</span>,</span>
<span class="line" id="L1016"></span>
<span class="line" id="L1017">    <span class="tok-comment">/// TRW RH-32</span></span>
<span class="line" id="L1018">    RH32 = <span class="tok-number">38</span>,</span>
<span class="line" id="L1019"></span>
<span class="line" id="L1020">    <span class="tok-comment">/// Motorola RCE</span></span>
<span class="line" id="L1021">    RCE = <span class="tok-number">39</span>,</span>
<span class="line" id="L1022"></span>
<span class="line" id="L1023">    <span class="tok-comment">/// ARM</span></span>
<span class="line" id="L1024">    ARM = <span class="tok-number">40</span>,</span>
<span class="line" id="L1025"></span>
<span class="line" id="L1026">    <span class="tok-comment">/// DEC Alpha</span></span>
<span class="line" id="L1027">    ALPHA = <span class="tok-number">41</span>,</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-comment">/// Hitachi SH</span></span>
<span class="line" id="L1030">    SH = <span class="tok-number">42</span>,</span>
<span class="line" id="L1031"></span>
<span class="line" id="L1032">    <span class="tok-comment">/// SPARC V9</span></span>
<span class="line" id="L1033">    SPARCV9 = <span class="tok-number">43</span>,</span>
<span class="line" id="L1034"></span>
<span class="line" id="L1035">    <span class="tok-comment">/// Siemens TriCore</span></span>
<span class="line" id="L1036">    TRICORE = <span class="tok-number">44</span>,</span>
<span class="line" id="L1037"></span>
<span class="line" id="L1038">    <span class="tok-comment">/// Argonaut RISC Core</span></span>
<span class="line" id="L1039">    ARC = <span class="tok-number">45</span>,</span>
<span class="line" id="L1040"></span>
<span class="line" id="L1041">    <span class="tok-comment">/// Hitachi H8/300</span></span>
<span class="line" id="L1042">    H8_300 = <span class="tok-number">46</span>,</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-comment">/// Hitachi H8/300H</span></span>
<span class="line" id="L1045">    H8_300H = <span class="tok-number">47</span>,</span>
<span class="line" id="L1046"></span>
<span class="line" id="L1047">    <span class="tok-comment">/// Hitachi H8S</span></span>
<span class="line" id="L1048">    H8S = <span class="tok-number">48</span>,</span>
<span class="line" id="L1049"></span>
<span class="line" id="L1050">    <span class="tok-comment">/// Hitachi H8/500</span></span>
<span class="line" id="L1051">    H8_500 = <span class="tok-number">49</span>,</span>
<span class="line" id="L1052"></span>
<span class="line" id="L1053">    <span class="tok-comment">/// Intel IA-64 processor architecture</span></span>
<span class="line" id="L1054">    IA_64 = <span class="tok-number">50</span>,</span>
<span class="line" id="L1055"></span>
<span class="line" id="L1056">    <span class="tok-comment">/// Stanford MIPS-X</span></span>
<span class="line" id="L1057">    MIPS_X = <span class="tok-number">51</span>,</span>
<span class="line" id="L1058"></span>
<span class="line" id="L1059">    <span class="tok-comment">/// Motorola ColdFire</span></span>
<span class="line" id="L1060">    COLDFIRE = <span class="tok-number">52</span>,</span>
<span class="line" id="L1061"></span>
<span class="line" id="L1062">    <span class="tok-comment">/// Motorola M68HC12</span></span>
<span class="line" id="L1063">    @&quot;68HC12&quot; = <span class="tok-number">53</span>,</span>
<span class="line" id="L1064"></span>
<span class="line" id="L1065">    <span class="tok-comment">/// Fujitsu MMA Multimedia Accelerator</span></span>
<span class="line" id="L1066">    MMA = <span class="tok-number">54</span>,</span>
<span class="line" id="L1067"></span>
<span class="line" id="L1068">    <span class="tok-comment">/// Siemens PCP</span></span>
<span class="line" id="L1069">    PCP = <span class="tok-number">55</span>,</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071">    <span class="tok-comment">/// Sony nCPU embedded RISC processor</span></span>
<span class="line" id="L1072">    NCPU = <span class="tok-number">56</span>,</span>
<span class="line" id="L1073"></span>
<span class="line" id="L1074">    <span class="tok-comment">/// Denso NDR1 microprocessor</span></span>
<span class="line" id="L1075">    NDR1 = <span class="tok-number">57</span>,</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077">    <span class="tok-comment">/// Motorola Star*Core processor</span></span>
<span class="line" id="L1078">    STARCORE = <span class="tok-number">58</span>,</span>
<span class="line" id="L1079"></span>
<span class="line" id="L1080">    <span class="tok-comment">/// Toyota ME16 processor</span></span>
<span class="line" id="L1081">    ME16 = <span class="tok-number">59</span>,</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083">    <span class="tok-comment">/// STMicroelectronics ST100 processor</span></span>
<span class="line" id="L1084">    ST100 = <span class="tok-number">60</span>,</span>
<span class="line" id="L1085"></span>
<span class="line" id="L1086">    <span class="tok-comment">/// Advanced Logic Corp. TinyJ embedded processor family</span></span>
<span class="line" id="L1087">    TINYJ = <span class="tok-number">61</span>,</span>
<span class="line" id="L1088"></span>
<span class="line" id="L1089">    <span class="tok-comment">/// AMD x86-64 architecture</span></span>
<span class="line" id="L1090">    X86_64 = <span class="tok-number">62</span>,</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">    <span class="tok-comment">/// Sony DSP Processor</span></span>
<span class="line" id="L1093">    PDSP = <span class="tok-number">63</span>,</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095">    <span class="tok-comment">/// Digital Equipment Corp. PDP-10</span></span>
<span class="line" id="L1096">    PDP10 = <span class="tok-number">64</span>,</span>
<span class="line" id="L1097"></span>
<span class="line" id="L1098">    <span class="tok-comment">/// Digital Equipment Corp. PDP-11</span></span>
<span class="line" id="L1099">    PDP11 = <span class="tok-number">65</span>,</span>
<span class="line" id="L1100"></span>
<span class="line" id="L1101">    <span class="tok-comment">/// Siemens FX66 microcontroller</span></span>
<span class="line" id="L1102">    FX66 = <span class="tok-number">66</span>,</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104">    <span class="tok-comment">/// STMicroelectronics ST9+ 8/16 bit microcontroller</span></span>
<span class="line" id="L1105">    ST9PLUS = <span class="tok-number">67</span>,</span>
<span class="line" id="L1106"></span>
<span class="line" id="L1107">    <span class="tok-comment">/// STMicroelectronics ST7 8-bit microcontroller</span></span>
<span class="line" id="L1108">    ST7 = <span class="tok-number">68</span>,</span>
<span class="line" id="L1109"></span>
<span class="line" id="L1110">    <span class="tok-comment">/// Motorola MC68HC16 Microcontroller</span></span>
<span class="line" id="L1111">    @&quot;68HC16&quot; = <span class="tok-number">69</span>,</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113">    <span class="tok-comment">/// Motorola MC68HC11 Microcontroller</span></span>
<span class="line" id="L1114">    @&quot;68HC11&quot; = <span class="tok-number">70</span>,</span>
<span class="line" id="L1115"></span>
<span class="line" id="L1116">    <span class="tok-comment">/// Motorola MC68HC08 Microcontroller</span></span>
<span class="line" id="L1117">    @&quot;68HC08&quot; = <span class="tok-number">71</span>,</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    <span class="tok-comment">/// Motorola MC68HC05 Microcontroller</span></span>
<span class="line" id="L1120">    @&quot;68HC05&quot; = <span class="tok-number">72</span>,</span>
<span class="line" id="L1121"></span>
<span class="line" id="L1122">    <span class="tok-comment">/// Silicon Graphics SVx</span></span>
<span class="line" id="L1123">    SVX = <span class="tok-number">73</span>,</span>
<span class="line" id="L1124"></span>
<span class="line" id="L1125">    <span class="tok-comment">/// STMicroelectronics ST19 8-bit microcontroller</span></span>
<span class="line" id="L1126">    ST19 = <span class="tok-number">74</span>,</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128">    <span class="tok-comment">/// Digital VAX</span></span>
<span class="line" id="L1129">    VAX = <span class="tok-number">75</span>,</span>
<span class="line" id="L1130"></span>
<span class="line" id="L1131">    <span class="tok-comment">/// Axis Communications 32-bit embedded processor</span></span>
<span class="line" id="L1132">    CRIS = <span class="tok-number">76</span>,</span>
<span class="line" id="L1133"></span>
<span class="line" id="L1134">    <span class="tok-comment">/// Infineon Technologies 32-bit embedded processor</span></span>
<span class="line" id="L1135">    JAVELIN = <span class="tok-number">77</span>,</span>
<span class="line" id="L1136"></span>
<span class="line" id="L1137">    <span class="tok-comment">/// Element 14 64-bit DSP Processor</span></span>
<span class="line" id="L1138">    FIREPATH = <span class="tok-number">78</span>,</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140">    <span class="tok-comment">/// LSI Logic 16-bit DSP Processor</span></span>
<span class="line" id="L1141">    ZSP = <span class="tok-number">79</span>,</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143">    <span class="tok-comment">/// Donald Knuth's educational 64-bit processor</span></span>
<span class="line" id="L1144">    MMIX = <span class="tok-number">80</span>,</span>
<span class="line" id="L1145"></span>
<span class="line" id="L1146">    <span class="tok-comment">/// Harvard University machine-independent object files</span></span>
<span class="line" id="L1147">    HUANY = <span class="tok-number">81</span>,</span>
<span class="line" id="L1148"></span>
<span class="line" id="L1149">    <span class="tok-comment">/// SiTera Prism</span></span>
<span class="line" id="L1150">    PRISM = <span class="tok-number">82</span>,</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152">    <span class="tok-comment">/// Atmel AVR 8-bit microcontroller</span></span>
<span class="line" id="L1153">    AVR = <span class="tok-number">83</span>,</span>
<span class="line" id="L1154"></span>
<span class="line" id="L1155">    <span class="tok-comment">/// Fujitsu FR30</span></span>
<span class="line" id="L1156">    FR30 = <span class="tok-number">84</span>,</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158">    <span class="tok-comment">/// Mitsubishi D10V</span></span>
<span class="line" id="L1159">    D10V = <span class="tok-number">85</span>,</span>
<span class="line" id="L1160"></span>
<span class="line" id="L1161">    <span class="tok-comment">/// Mitsubishi D30V</span></span>
<span class="line" id="L1162">    D30V = <span class="tok-number">86</span>,</span>
<span class="line" id="L1163"></span>
<span class="line" id="L1164">    <span class="tok-comment">/// NEC v850</span></span>
<span class="line" id="L1165">    V850 = <span class="tok-number">87</span>,</span>
<span class="line" id="L1166"></span>
<span class="line" id="L1167">    <span class="tok-comment">/// Mitsubishi M32R</span></span>
<span class="line" id="L1168">    M32R = <span class="tok-number">88</span>,</span>
<span class="line" id="L1169"></span>
<span class="line" id="L1170">    <span class="tok-comment">/// Matsushita MN10300</span></span>
<span class="line" id="L1171">    MN10300 = <span class="tok-number">89</span>,</span>
<span class="line" id="L1172"></span>
<span class="line" id="L1173">    <span class="tok-comment">/// Matsushita MN10200</span></span>
<span class="line" id="L1174">    MN10200 = <span class="tok-number">90</span>,</span>
<span class="line" id="L1175"></span>
<span class="line" id="L1176">    <span class="tok-comment">/// picoJava</span></span>
<span class="line" id="L1177">    PJ = <span class="tok-number">91</span>,</span>
<span class="line" id="L1178"></span>
<span class="line" id="L1179">    <span class="tok-comment">/// OpenRISC 32-bit embedded processor</span></span>
<span class="line" id="L1180">    OPENRISC = <span class="tok-number">92</span>,</span>
<span class="line" id="L1181"></span>
<span class="line" id="L1182">    <span class="tok-comment">/// ARC International ARCompact processor (old spelling/synonym: EM_ARC_A5)</span></span>
<span class="line" id="L1183">    ARC_COMPACT = <span class="tok-number">93</span>,</span>
<span class="line" id="L1184"></span>
<span class="line" id="L1185">    <span class="tok-comment">/// Tensilica Xtensa Architecture</span></span>
<span class="line" id="L1186">    XTENSA = <span class="tok-number">94</span>,</span>
<span class="line" id="L1187"></span>
<span class="line" id="L1188">    <span class="tok-comment">/// Alphamosaic VideoCore processor</span></span>
<span class="line" id="L1189">    VIDEOCORE = <span class="tok-number">95</span>,</span>
<span class="line" id="L1190"></span>
<span class="line" id="L1191">    <span class="tok-comment">/// Thompson Multimedia General Purpose Processor</span></span>
<span class="line" id="L1192">    TMM_GPP = <span class="tok-number">96</span>,</span>
<span class="line" id="L1193"></span>
<span class="line" id="L1194">    <span class="tok-comment">/// National Semiconductor 32000 series</span></span>
<span class="line" id="L1195">    NS32K = <span class="tok-number">97</span>,</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197">    <span class="tok-comment">/// Tenor Network TPC processor</span></span>
<span class="line" id="L1198">    TPC = <span class="tok-number">98</span>,</span>
<span class="line" id="L1199"></span>
<span class="line" id="L1200">    <span class="tok-comment">/// Trebia SNP 1000 processor</span></span>
<span class="line" id="L1201">    SNP1K = <span class="tok-number">99</span>,</span>
<span class="line" id="L1202"></span>
<span class="line" id="L1203">    <span class="tok-comment">/// STMicroelectronics (www.st.com) ST200</span></span>
<span class="line" id="L1204">    ST200 = <span class="tok-number">100</span>,</span>
<span class="line" id="L1205"></span>
<span class="line" id="L1206">    <span class="tok-comment">/// Ubicom IP2xxx microcontroller family</span></span>
<span class="line" id="L1207">    IP2K = <span class="tok-number">101</span>,</span>
<span class="line" id="L1208"></span>
<span class="line" id="L1209">    <span class="tok-comment">/// MAX Processor</span></span>
<span class="line" id="L1210">    MAX = <span class="tok-number">102</span>,</span>
<span class="line" id="L1211"></span>
<span class="line" id="L1212">    <span class="tok-comment">/// National Semiconductor CompactRISC microprocessor</span></span>
<span class="line" id="L1213">    CR = <span class="tok-number">103</span>,</span>
<span class="line" id="L1214"></span>
<span class="line" id="L1215">    <span class="tok-comment">/// Fujitsu F2MC16</span></span>
<span class="line" id="L1216">    F2MC16 = <span class="tok-number">104</span>,</span>
<span class="line" id="L1217"></span>
<span class="line" id="L1218">    <span class="tok-comment">/// Texas Instruments embedded microcontroller msp430</span></span>
<span class="line" id="L1219">    MSP430 = <span class="tok-number">105</span>,</span>
<span class="line" id="L1220"></span>
<span class="line" id="L1221">    <span class="tok-comment">/// Analog Devices Blackfin (DSP) processor</span></span>
<span class="line" id="L1222">    BLACKFIN = <span class="tok-number">106</span>,</span>
<span class="line" id="L1223"></span>
<span class="line" id="L1224">    <span class="tok-comment">/// S1C33 Family of Seiko Epson processors</span></span>
<span class="line" id="L1225">    SE_C33 = <span class="tok-number">107</span>,</span>
<span class="line" id="L1226"></span>
<span class="line" id="L1227">    <span class="tok-comment">/// Sharp embedded microprocessor</span></span>
<span class="line" id="L1228">    SEP = <span class="tok-number">108</span>,</span>
<span class="line" id="L1229"></span>
<span class="line" id="L1230">    <span class="tok-comment">/// Arca RISC Microprocessor</span></span>
<span class="line" id="L1231">    ARCA = <span class="tok-number">109</span>,</span>
<span class="line" id="L1232"></span>
<span class="line" id="L1233">    <span class="tok-comment">/// Microprocessor series from PKU-Unity Ltd. and MPRC of Peking University</span></span>
<span class="line" id="L1234">    UNICORE = <span class="tok-number">110</span>,</span>
<span class="line" id="L1235"></span>
<span class="line" id="L1236">    <span class="tok-comment">/// eXcess: 16/32/64-bit configurable embedded CPU</span></span>
<span class="line" id="L1237">    EXCESS = <span class="tok-number">111</span>,</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239">    <span class="tok-comment">/// Icera Semiconductor Inc. Deep Execution Processor</span></span>
<span class="line" id="L1240">    DXP = <span class="tok-number">112</span>,</span>
<span class="line" id="L1241"></span>
<span class="line" id="L1242">    <span class="tok-comment">/// Altera Nios II soft-core processor</span></span>
<span class="line" id="L1243">    ALTERA_NIOS2 = <span class="tok-number">113</span>,</span>
<span class="line" id="L1244"></span>
<span class="line" id="L1245">    <span class="tok-comment">/// National Semiconductor CompactRISC CRX</span></span>
<span class="line" id="L1246">    CRX = <span class="tok-number">114</span>,</span>
<span class="line" id="L1247"></span>
<span class="line" id="L1248">    <span class="tok-comment">/// Motorola XGATE embedded processor</span></span>
<span class="line" id="L1249">    XGATE = <span class="tok-number">115</span>,</span>
<span class="line" id="L1250"></span>
<span class="line" id="L1251">    <span class="tok-comment">/// Infineon C16x/XC16x processor</span></span>
<span class="line" id="L1252">    C166 = <span class="tok-number">116</span>,</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254">    <span class="tok-comment">/// Renesas M16C series microprocessors</span></span>
<span class="line" id="L1255">    M16C = <span class="tok-number">117</span>,</span>
<span class="line" id="L1256"></span>
<span class="line" id="L1257">    <span class="tok-comment">/// Microchip Technology dsPIC30F Digital Signal Controller</span></span>
<span class="line" id="L1258">    DSPIC30F = <span class="tok-number">118</span>,</span>
<span class="line" id="L1259"></span>
<span class="line" id="L1260">    <span class="tok-comment">/// Freescale Communication Engine RISC core</span></span>
<span class="line" id="L1261">    CE = <span class="tok-number">119</span>,</span>
<span class="line" id="L1262"></span>
<span class="line" id="L1263">    <span class="tok-comment">/// Renesas M32C series microprocessors</span></span>
<span class="line" id="L1264">    M32C = <span class="tok-number">120</span>,</span>
<span class="line" id="L1265"></span>
<span class="line" id="L1266">    <span class="tok-comment">/// Altium TSK3000 core</span></span>
<span class="line" id="L1267">    TSK3000 = <span class="tok-number">131</span>,</span>
<span class="line" id="L1268"></span>
<span class="line" id="L1269">    <span class="tok-comment">/// Freescale RS08 embedded processor</span></span>
<span class="line" id="L1270">    RS08 = <span class="tok-number">132</span>,</span>
<span class="line" id="L1271"></span>
<span class="line" id="L1272">    <span class="tok-comment">/// Analog Devices SHARC family of 32-bit DSP processors</span></span>
<span class="line" id="L1273">    SHARC = <span class="tok-number">133</span>,</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275">    <span class="tok-comment">/// Cyan Technology eCOG2 microprocessor</span></span>
<span class="line" id="L1276">    ECOG2 = <span class="tok-number">134</span>,</span>
<span class="line" id="L1277"></span>
<span class="line" id="L1278">    <span class="tok-comment">/// Sunplus S+core7 RISC processor</span></span>
<span class="line" id="L1279">    SCORE7 = <span class="tok-number">135</span>,</span>
<span class="line" id="L1280"></span>
<span class="line" id="L1281">    <span class="tok-comment">/// New Japan Radio (NJR) 24-bit DSP Processor</span></span>
<span class="line" id="L1282">    DSP24 = <span class="tok-number">136</span>,</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">    <span class="tok-comment">/// Broadcom VideoCore III processor</span></span>
<span class="line" id="L1285">    VIDEOCORE3 = <span class="tok-number">137</span>,</span>
<span class="line" id="L1286"></span>
<span class="line" id="L1287">    <span class="tok-comment">/// RISC processor for Lattice FPGA architecture</span></span>
<span class="line" id="L1288">    LATTICEMICO32 = <span class="tok-number">138</span>,</span>
<span class="line" id="L1289"></span>
<span class="line" id="L1290">    <span class="tok-comment">/// Seiko Epson C17 family</span></span>
<span class="line" id="L1291">    SE_C17 = <span class="tok-number">139</span>,</span>
<span class="line" id="L1292"></span>
<span class="line" id="L1293">    <span class="tok-comment">/// The Texas Instruments TMS320C6000 DSP family</span></span>
<span class="line" id="L1294">    TI_C6000 = <span class="tok-number">140</span>,</span>
<span class="line" id="L1295"></span>
<span class="line" id="L1296">    <span class="tok-comment">/// The Texas Instruments TMS320C2000 DSP family</span></span>
<span class="line" id="L1297">    TI_C2000 = <span class="tok-number">141</span>,</span>
<span class="line" id="L1298"></span>
<span class="line" id="L1299">    <span class="tok-comment">/// The Texas Instruments TMS320C55x DSP family</span></span>
<span class="line" id="L1300">    TI_C5500 = <span class="tok-number">142</span>,</span>
<span class="line" id="L1301"></span>
<span class="line" id="L1302">    <span class="tok-comment">/// STMicroelectronics 64bit VLIW Data Signal Processor</span></span>
<span class="line" id="L1303">    MMDSP_PLUS = <span class="tok-number">160</span>,</span>
<span class="line" id="L1304"></span>
<span class="line" id="L1305">    <span class="tok-comment">/// Cypress M8C microprocessor</span></span>
<span class="line" id="L1306">    CYPRESS_M8C = <span class="tok-number">161</span>,</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308">    <span class="tok-comment">/// Renesas R32C series microprocessors</span></span>
<span class="line" id="L1309">    R32C = <span class="tok-number">162</span>,</span>
<span class="line" id="L1310"></span>
<span class="line" id="L1311">    <span class="tok-comment">/// NXP Semiconductors TriMedia architecture family</span></span>
<span class="line" id="L1312">    TRIMEDIA = <span class="tok-number">163</span>,</span>
<span class="line" id="L1313"></span>
<span class="line" id="L1314">    <span class="tok-comment">/// Qualcomm Hexagon processor</span></span>
<span class="line" id="L1315">    HEXAGON = <span class="tok-number">164</span>,</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">    <span class="tok-comment">/// Intel 8051 and variants</span></span>
<span class="line" id="L1318">    @&quot;8051&quot; = <span class="tok-number">165</span>,</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">    <span class="tok-comment">/// STMicroelectronics STxP7x family of configurable and extensible RISC processors</span></span>
<span class="line" id="L1321">    STXP7X = <span class="tok-number">166</span>,</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323">    <span class="tok-comment">/// Andes Technology compact code size embedded RISC processor family</span></span>
<span class="line" id="L1324">    NDS32 = <span class="tok-number">167</span>,</span>
<span class="line" id="L1325"></span>
<span class="line" id="L1326">    <span class="tok-comment">/// Cyan Technology eCOG1X family</span></span>
<span class="line" id="L1327">    ECOG1X = <span class="tok-number">168</span>,</span>
<span class="line" id="L1328"></span>
<span class="line" id="L1329">    <span class="tok-comment">/// Dallas Semiconductor MAXQ30 Core Micro-controllers</span></span>
<span class="line" id="L1330">    MAXQ30 = <span class="tok-number">169</span>,</span>
<span class="line" id="L1331"></span>
<span class="line" id="L1332">    <span class="tok-comment">/// New Japan Radio (NJR) 16-bit DSP Processor</span></span>
<span class="line" id="L1333">    XIMO16 = <span class="tok-number">170</span>,</span>
<span class="line" id="L1334"></span>
<span class="line" id="L1335">    <span class="tok-comment">/// M2000 Reconfigurable RISC Microprocessor</span></span>
<span class="line" id="L1336">    MANIK = <span class="tok-number">171</span>,</span>
<span class="line" id="L1337"></span>
<span class="line" id="L1338">    <span class="tok-comment">/// Cray Inc. NV2 vector architecture</span></span>
<span class="line" id="L1339">    CRAYNV2 = <span class="tok-number">172</span>,</span>
<span class="line" id="L1340"></span>
<span class="line" id="L1341">    <span class="tok-comment">/// Renesas RX family</span></span>
<span class="line" id="L1342">    RX = <span class="tok-number">173</span>,</span>
<span class="line" id="L1343"></span>
<span class="line" id="L1344">    <span class="tok-comment">/// Imagination Technologies META processor architecture</span></span>
<span class="line" id="L1345">    METAG = <span class="tok-number">174</span>,</span>
<span class="line" id="L1346"></span>
<span class="line" id="L1347">    <span class="tok-comment">/// MCST Elbrus general purpose hardware architecture</span></span>
<span class="line" id="L1348">    MCST_ELBRUS = <span class="tok-number">175</span>,</span>
<span class="line" id="L1349"></span>
<span class="line" id="L1350">    <span class="tok-comment">/// Cyan Technology eCOG16 family</span></span>
<span class="line" id="L1351">    ECOG16 = <span class="tok-number">176</span>,</span>
<span class="line" id="L1352"></span>
<span class="line" id="L1353">    <span class="tok-comment">/// National Semiconductor CompactRISC CR16 16-bit microprocessor</span></span>
<span class="line" id="L1354">    CR16 = <span class="tok-number">177</span>,</span>
<span class="line" id="L1355"></span>
<span class="line" id="L1356">    <span class="tok-comment">/// Freescale Extended Time Processing Unit</span></span>
<span class="line" id="L1357">    ETPU = <span class="tok-number">178</span>,</span>
<span class="line" id="L1358"></span>
<span class="line" id="L1359">    <span class="tok-comment">/// Infineon Technologies SLE9X core</span></span>
<span class="line" id="L1360">    SLE9X = <span class="tok-number">179</span>,</span>
<span class="line" id="L1361"></span>
<span class="line" id="L1362">    <span class="tok-comment">/// Intel L10M</span></span>
<span class="line" id="L1363">    L10M = <span class="tok-number">180</span>,</span>
<span class="line" id="L1364"></span>
<span class="line" id="L1365">    <span class="tok-comment">/// Intel K10M</span></span>
<span class="line" id="L1366">    K10M = <span class="tok-number">181</span>,</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">    <span class="tok-comment">/// ARM AArch64</span></span>
<span class="line" id="L1369">    AARCH64 = <span class="tok-number">183</span>,</span>
<span class="line" id="L1370"></span>
<span class="line" id="L1371">    <span class="tok-comment">/// Atmel Corporation 32-bit microprocessor family</span></span>
<span class="line" id="L1372">    AVR32 = <span class="tok-number">185</span>,</span>
<span class="line" id="L1373"></span>
<span class="line" id="L1374">    <span class="tok-comment">/// STMicroeletronics STM8 8-bit microcontroller</span></span>
<span class="line" id="L1375">    STM8 = <span class="tok-number">186</span>,</span>
<span class="line" id="L1376"></span>
<span class="line" id="L1377">    <span class="tok-comment">/// Tilera TILE64 multicore architecture family</span></span>
<span class="line" id="L1378">    TILE64 = <span class="tok-number">187</span>,</span>
<span class="line" id="L1379"></span>
<span class="line" id="L1380">    <span class="tok-comment">/// Tilera TILEPro multicore architecture family</span></span>
<span class="line" id="L1381">    TILEPRO = <span class="tok-number">188</span>,</span>
<span class="line" id="L1382"></span>
<span class="line" id="L1383">    <span class="tok-comment">/// NVIDIA CUDA architecture</span></span>
<span class="line" id="L1384">    CUDA = <span class="tok-number">190</span>,</span>
<span class="line" id="L1385"></span>
<span class="line" id="L1386">    <span class="tok-comment">/// Tilera TILE-Gx multicore architecture family</span></span>
<span class="line" id="L1387">    TILEGX = <span class="tok-number">191</span>,</span>
<span class="line" id="L1388"></span>
<span class="line" id="L1389">    <span class="tok-comment">/// CloudShield architecture family</span></span>
<span class="line" id="L1390">    CLOUDSHIELD = <span class="tok-number">192</span>,</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392">    <span class="tok-comment">/// KIPO-KAIST Core-A 1st generation processor family</span></span>
<span class="line" id="L1393">    COREA_1ST = <span class="tok-number">193</span>,</span>
<span class="line" id="L1394"></span>
<span class="line" id="L1395">    <span class="tok-comment">/// KIPO-KAIST Core-A 2nd generation processor family</span></span>
<span class="line" id="L1396">    COREA_2ND = <span class="tok-number">194</span>,</span>
<span class="line" id="L1397"></span>
<span class="line" id="L1398">    <span class="tok-comment">/// Synopsys ARCompact V2</span></span>
<span class="line" id="L1399">    ARC_COMPACT2 = <span class="tok-number">195</span>,</span>
<span class="line" id="L1400"></span>
<span class="line" id="L1401">    <span class="tok-comment">/// Open8 8-bit RISC soft processor core</span></span>
<span class="line" id="L1402">    OPEN8 = <span class="tok-number">196</span>,</span>
<span class="line" id="L1403"></span>
<span class="line" id="L1404">    <span class="tok-comment">/// Renesas RL78 family</span></span>
<span class="line" id="L1405">    RL78 = <span class="tok-number">197</span>,</span>
<span class="line" id="L1406"></span>
<span class="line" id="L1407">    <span class="tok-comment">/// Broadcom VideoCore V processor</span></span>
<span class="line" id="L1408">    VIDEOCORE5 = <span class="tok-number">198</span>,</span>
<span class="line" id="L1409"></span>
<span class="line" id="L1410">    <span class="tok-comment">/// Renesas 78KOR family</span></span>
<span class="line" id="L1411">    @&quot;78KOR&quot; = <span class="tok-number">199</span>,</span>
<span class="line" id="L1412"></span>
<span class="line" id="L1413">    <span class="tok-comment">/// Freescale 56800EX Digital Signal Controller (DSC)</span></span>
<span class="line" id="L1414">    @&quot;56800EX&quot; = <span class="tok-number">200</span>,</span>
<span class="line" id="L1415"></span>
<span class="line" id="L1416">    <span class="tok-comment">/// Beyond BA1 CPU architecture</span></span>
<span class="line" id="L1417">    BA1 = <span class="tok-number">201</span>,</span>
<span class="line" id="L1418"></span>
<span class="line" id="L1419">    <span class="tok-comment">/// Beyond BA2 CPU architecture</span></span>
<span class="line" id="L1420">    BA2 = <span class="tok-number">202</span>,</span>
<span class="line" id="L1421"></span>
<span class="line" id="L1422">    <span class="tok-comment">/// XMOS xCORE processor family</span></span>
<span class="line" id="L1423">    XCORE = <span class="tok-number">203</span>,</span>
<span class="line" id="L1424"></span>
<span class="line" id="L1425">    <span class="tok-comment">/// Microchip 8-bit PIC(r) family</span></span>
<span class="line" id="L1426">    MCHP_PIC = <span class="tok-number">204</span>,</span>
<span class="line" id="L1427"></span>
<span class="line" id="L1428">    <span class="tok-comment">/// Reserved by Intel</span></span>
<span class="line" id="L1429">    INTEL205 = <span class="tok-number">205</span>,</span>
<span class="line" id="L1430"></span>
<span class="line" id="L1431">    <span class="tok-comment">/// Reserved by Intel</span></span>
<span class="line" id="L1432">    INTEL206 = <span class="tok-number">206</span>,</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434">    <span class="tok-comment">/// Reserved by Intel</span></span>
<span class="line" id="L1435">    INTEL207 = <span class="tok-number">207</span>,</span>
<span class="line" id="L1436"></span>
<span class="line" id="L1437">    <span class="tok-comment">/// Reserved by Intel</span></span>
<span class="line" id="L1438">    INTEL208 = <span class="tok-number">208</span>,</span>
<span class="line" id="L1439"></span>
<span class="line" id="L1440">    <span class="tok-comment">/// Reserved by Intel</span></span>
<span class="line" id="L1441">    INTEL209 = <span class="tok-number">209</span>,</span>
<span class="line" id="L1442"></span>
<span class="line" id="L1443">    <span class="tok-comment">/// KM211 KM32 32-bit processor</span></span>
<span class="line" id="L1444">    KM32 = <span class="tok-number">210</span>,</span>
<span class="line" id="L1445"></span>
<span class="line" id="L1446">    <span class="tok-comment">/// KM211 KMX32 32-bit processor</span></span>
<span class="line" id="L1447">    KMX32 = <span class="tok-number">211</span>,</span>
<span class="line" id="L1448"></span>
<span class="line" id="L1449">    <span class="tok-comment">/// KM211 KMX16 16-bit processor</span></span>
<span class="line" id="L1450">    KMX16 = <span class="tok-number">212</span>,</span>
<span class="line" id="L1451"></span>
<span class="line" id="L1452">    <span class="tok-comment">/// KM211 KMX8 8-bit processor</span></span>
<span class="line" id="L1453">    KMX8 = <span class="tok-number">213</span>,</span>
<span class="line" id="L1454"></span>
<span class="line" id="L1455">    <span class="tok-comment">/// KM211 KVARC processor</span></span>
<span class="line" id="L1456">    KVARC = <span class="tok-number">214</span>,</span>
<span class="line" id="L1457"></span>
<span class="line" id="L1458">    <span class="tok-comment">/// Paneve CDP architecture family</span></span>
<span class="line" id="L1459">    CDP = <span class="tok-number">215</span>,</span>
<span class="line" id="L1460"></span>
<span class="line" id="L1461">    <span class="tok-comment">/// Cognitive Smart Memory Processor</span></span>
<span class="line" id="L1462">    COGE = <span class="tok-number">216</span>,</span>
<span class="line" id="L1463"></span>
<span class="line" id="L1464">    <span class="tok-comment">/// iCelero CoolEngine</span></span>
<span class="line" id="L1465">    COOL = <span class="tok-number">217</span>,</span>
<span class="line" id="L1466"></span>
<span class="line" id="L1467">    <span class="tok-comment">/// Nanoradio Optimized RISC</span></span>
<span class="line" id="L1468">    NORC = <span class="tok-number">218</span>,</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">    <span class="tok-comment">/// CSR Kalimba architecture family</span></span>
<span class="line" id="L1471">    CSR_KALIMBA = <span class="tok-number">219</span>,</span>
<span class="line" id="L1472"></span>
<span class="line" id="L1473">    <span class="tok-comment">/// AMD GPU architecture</span></span>
<span class="line" id="L1474">    AMDGPU = <span class="tok-number">224</span>,</span>
<span class="line" id="L1475"></span>
<span class="line" id="L1476">    <span class="tok-comment">/// RISC-V</span></span>
<span class="line" id="L1477">    RISCV = <span class="tok-number">243</span>,</span>
<span class="line" id="L1478"></span>
<span class="line" id="L1479">    <span class="tok-comment">/// Lanai 32-bit processor</span></span>
<span class="line" id="L1480">    LANAI = <span class="tok-number">244</span>,</span>
<span class="line" id="L1481"></span>
<span class="line" id="L1482">    <span class="tok-comment">/// Linux kernel bpf virtual machine</span></span>
<span class="line" id="L1483">    BPF = <span class="tok-number">247</span>,</span>
<span class="line" id="L1484"></span>
<span class="line" id="L1485">    <span class="tok-comment">/// C-SKY</span></span>
<span class="line" id="L1486">    CSKY = <span class="tok-number">252</span>,</span>
<span class="line" id="L1487"></span>
<span class="line" id="L1488">    <span class="tok-comment">/// Fujitsu FR-V</span></span>
<span class="line" id="L1489">    FRV = <span class="tok-number">0x5441</span>,</span>
<span class="line" id="L1490"></span>
<span class="line" id="L1491">    _,</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toTargetCpuArch</span>(em: EM) ?std.Target.Cpu.Arch {</span>
<span class="line" id="L1494">        <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (em) {</span>
<span class="line" id="L1495">            .AVR =&gt; .avr,</span>
<span class="line" id="L1496">            .MSP430 =&gt; .msp430,</span>
<span class="line" id="L1497">            .ARC =&gt; .arc,</span>
<span class="line" id="L1498">            .ARM =&gt; .arm,</span>
<span class="line" id="L1499">            .HEXAGON =&gt; .hexagon,</span>
<span class="line" id="L1500">            .@&quot;68K&quot; =&gt; .m68k,</span>
<span class="line" id="L1501">            .MIPS =&gt; .mips,</span>
<span class="line" id="L1502">            .MIPS_RS3_LE =&gt; .mipsel,</span>
<span class="line" id="L1503">            .PPC =&gt; .powerpc,</span>
<span class="line" id="L1504">            .SPARC =&gt; .sparc,</span>
<span class="line" id="L1505">            .@&quot;386&quot; =&gt; .<span class="tok-type">i386</span>,</span>
<span class="line" id="L1506">            .XCORE =&gt; .xcore,</span>
<span class="line" id="L1507">            .CSR_KALIMBA =&gt; .kalimba,</span>
<span class="line" id="L1508">            .LANAI =&gt; .lanai,</span>
<span class="line" id="L1509">            .AARCH64 =&gt; .aarch64,</span>
<span class="line" id="L1510">            .PPC64 =&gt; .powerpc64,</span>
<span class="line" id="L1511">            .RISCV =&gt; .riscv64,</span>
<span class="line" id="L1512">            .X86_64 =&gt; .x86_64,</span>
<span class="line" id="L1513">            .BPF =&gt; .bpfel,</span>
<span class="line" id="L1514">            .SPARCV9 =&gt; .sparc64,</span>
<span class="line" id="L1515">            .S390 =&gt; .s390x,</span>
<span class="line" id="L1516">            .SPU_2 =&gt; .spu_2,</span>
<span class="line" id="L1517">            <span class="tok-comment">// there's many cases we don't (yet) handle, or will never have a</span>
</span>
<span class="line" id="L1518">            <span class="tok-comment">// zig target cpu arch equivalent (such as null).</span>
</span>
<span class="line" id="L1519">            <span class="tok-kw">else</span> =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L1520">        };</span>
<span class="line" id="L1521">    }</span>
<span class="line" id="L1522">};</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524"><span class="tok-comment">/// Section data should be writable during execution.</span></span>
<span class="line" id="L1525"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_WRITE = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L1526"></span>
<span class="line" id="L1527"><span class="tok-comment">/// Section occupies memory during program execution.</span></span>
<span class="line" id="L1528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_ALLOC = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L1529"></span>
<span class="line" id="L1530"><span class="tok-comment">/// Section contains executable machine instructions.</span></span>
<span class="line" id="L1531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_EXECINSTR = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533"><span class="tok-comment">/// The data in this section may be merged.</span></span>
<span class="line" id="L1534"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MERGE = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L1535"></span>
<span class="line" id="L1536"><span class="tok-comment">/// The data in this section is null-terminated strings.</span></span>
<span class="line" id="L1537"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_STRINGS = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L1538"></span>
<span class="line" id="L1539"><span class="tok-comment">/// A field in this section holds a section header table index.</span></span>
<span class="line" id="L1540"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_INFO_LINK = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L1541"></span>
<span class="line" id="L1542"><span class="tok-comment">/// Adds special ordering requirements for link editors.</span></span>
<span class="line" id="L1543"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_LINK_ORDER = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545"><span class="tok-comment">/// This section requires special OS-specific processing to avoid incorrect</span></span>
<span class="line" id="L1546"><span class="tok-comment">/// behavior.</span></span>
<span class="line" id="L1547"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_OS_NONCONFORMING = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L1548"></span>
<span class="line" id="L1549"><span class="tok-comment">/// This section is a member of a section group.</span></span>
<span class="line" id="L1550"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_GROUP = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L1551"></span>
<span class="line" id="L1552"><span class="tok-comment">/// This section holds Thread-Local Storage.</span></span>
<span class="line" id="L1553"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_TLS = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L1554"></span>
<span class="line" id="L1555"><span class="tok-comment">/// Identifies a section containing compressed data.</span></span>
<span class="line" id="L1556"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_COMPRESSED = <span class="tok-number">0x800</span>;</span>
<span class="line" id="L1557"></span>
<span class="line" id="L1558"><span class="tok-comment">/// This section is excluded from the final executable or shared library.</span></span>
<span class="line" id="L1559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_EXCLUDE = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1560"></span>
<span class="line" id="L1561"><span class="tok-comment">/// Start of target-specific flags.</span></span>
<span class="line" id="L1562"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MASKOS = <span class="tok-number">0x0ff00000</span>;</span>
<span class="line" id="L1563"></span>
<span class="line" id="L1564"><span class="tok-comment">/// Bits indicating processor-specific flags.</span></span>
<span class="line" id="L1565"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MASKPROC = <span class="tok-number">0xf0000000</span>;</span>
<span class="line" id="L1566"></span>
<span class="line" id="L1567"><span class="tok-comment">/// All sections with the &quot;d&quot; flag are grouped together by the linker to form</span></span>
<span class="line" id="L1568"><span class="tok-comment">/// the data section and the dp register is set to the start of the section by</span></span>
<span class="line" id="L1569"><span class="tok-comment">/// the boot code.</span></span>
<span class="line" id="L1570"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XCORE_SHF_DP_SECTION = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1571"></span>
<span class="line" id="L1572"><span class="tok-comment">/// All sections with the &quot;c&quot; flag are grouped together by the linker to form</span></span>
<span class="line" id="L1573"><span class="tok-comment">/// the constant pool and the cp register is set to the start of the constant</span></span>
<span class="line" id="L1574"><span class="tok-comment">/// pool by the boot code.</span></span>
<span class="line" id="L1575"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XCORE_SHF_CP_SECTION = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577"><span class="tok-comment">/// If an object file section does not have this flag set, then it may not hold</span></span>
<span class="line" id="L1578"><span class="tok-comment">/// more than 2GB and can be freely referred to in objects using smaller code</span></span>
<span class="line" id="L1579"><span class="tok-comment">/// models. Otherwise, only objects using larger code models can refer to them.</span></span>
<span class="line" id="L1580"><span class="tok-comment">/// For example, a medium code model object can refer to data in a section that</span></span>
<span class="line" id="L1581"><span class="tok-comment">/// sets this flag besides being able to refer to data in a section that does</span></span>
<span class="line" id="L1582"><span class="tok-comment">/// not set it; likewise, a small code model object can refer only to code in a</span></span>
<span class="line" id="L1583"><span class="tok-comment">/// section that does not set this flag.</span></span>
<span class="line" id="L1584"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_X86_64_LARGE = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1585"></span>
<span class="line" id="L1586"><span class="tok-comment">/// All sections with the GPREL flag are grouped into a global data area</span></span>
<span class="line" id="L1587"><span class="tok-comment">/// for faster accesses</span></span>
<span class="line" id="L1588"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_HEX_GPREL = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1589"></span>
<span class="line" id="L1590"><span class="tok-comment">/// Section contains text/data which may be replicated in other sections.</span></span>
<span class="line" id="L1591"><span class="tok-comment">/// Linker must retain only one copy.</span></span>
<span class="line" id="L1592"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_NODUPES = <span class="tok-number">0x01000000</span>;</span>
<span class="line" id="L1593"></span>
<span class="line" id="L1594"><span class="tok-comment">/// Linker must generate implicit hidden weak names.</span></span>
<span class="line" id="L1595"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_NAMES = <span class="tok-number">0x02000000</span>;</span>
<span class="line" id="L1596"></span>
<span class="line" id="L1597"><span class="tok-comment">/// Section data local to process.</span></span>
<span class="line" id="L1598"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_LOCAL = <span class="tok-number">0x04000000</span>;</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600"><span class="tok-comment">/// Do not strip this section.</span></span>
<span class="line" id="L1601"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_NOSTRIP = <span class="tok-number">0x08000000</span>;</span>
<span class="line" id="L1602"></span>
<span class="line" id="L1603"><span class="tok-comment">/// Section must be part of global data area.</span></span>
<span class="line" id="L1604"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_GPREL = <span class="tok-number">0x10000000</span>;</span>
<span class="line" id="L1605"></span>
<span class="line" id="L1606"><span class="tok-comment">/// This section should be merged.</span></span>
<span class="line" id="L1607"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_MERGE = <span class="tok-number">0x20000000</span>;</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609"><span class="tok-comment">/// Address size to be inferred from section entry size.</span></span>
<span class="line" id="L1610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_ADDR = <span class="tok-number">0x40000000</span>;</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612"><span class="tok-comment">/// Section data is string data by default.</span></span>
<span class="line" id="L1613"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_MIPS_STRING = <span class="tok-number">0x80000000</span>;</span>
<span class="line" id="L1614"></span>
<span class="line" id="L1615"><span class="tok-comment">/// Make code section unreadable when in execute-only mode</span></span>
<span class="line" id="L1616"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHF_ARM_PURECODE = <span class="tok-number">0x2000000</span>;</span>
<span class="line" id="L1617"></span>
<span class="line" id="L1618"><span class="tok-comment">/// Execute</span></span>
<span class="line" id="L1619"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF_X = <span class="tok-number">1</span>;</span>
<span class="line" id="L1620"></span>
<span class="line" id="L1621"><span class="tok-comment">/// Write</span></span>
<span class="line" id="L1622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF_W = <span class="tok-number">2</span>;</span>
<span class="line" id="L1623"></span>
<span class="line" id="L1624"><span class="tok-comment">/// Read</span></span>
<span class="line" id="L1625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF_R = <span class="tok-number">4</span>;</span>
<span class="line" id="L1626"></span>
<span class="line" id="L1627"><span class="tok-comment">/// Bits for operating system-specific semantics.</span></span>
<span class="line" id="L1628"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF_MASKOS = <span class="tok-number">0x0ff00000</span>;</span>
<span class="line" id="L1629"></span>
<span class="line" id="L1630"><span class="tok-comment">/// Bits for processor-specific semantics.</span></span>
<span class="line" id="L1631"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PF_MASKPROC = <span class="tok-number">0xf0000000</span>;</span>
<span class="line" id="L1632"></span>
<span class="line" id="L1633"><span class="tok-comment">// Special section indexes used in Elf{32,64}_Sym.</span>
</span>
<span class="line" id="L1634"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_UNDEF = <span class="tok-number">0</span>;</span>
<span class="line" id="L1635"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_LORESERVE = <span class="tok-number">0xff00</span>;</span>
<span class="line" id="L1636"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_LOPROC = <span class="tok-number">0xff00</span>;</span>
<span class="line" id="L1637"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_HIPROC = <span class="tok-number">0xff1f</span>;</span>
<span class="line" id="L1638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_LIVEPATCH = <span class="tok-number">0xff20</span>;</span>
<span class="line" id="L1639"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_ABS = <span class="tok-number">0xfff1</span>;</span>
<span class="line" id="L1640"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_COMMON = <span class="tok-number">0xfff2</span>;</span>
<span class="line" id="L1641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHN_HIRESERVE = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L1642"></span>
<span class="line" id="L1643"><span class="tok-comment">/// AMD x86-64 relocations.</span></span>
<span class="line" id="L1644"><span class="tok-comment">/// No reloc</span></span>
<span class="line" id="L1645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_NONE = <span class="tok-number">0</span>;</span>
<span class="line" id="L1646"><span class="tok-comment">/// Direct 64 bit</span></span>
<span class="line" id="L1647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_64 = <span class="tok-number">1</span>;</span>
<span class="line" id="L1648"><span class="tok-comment">/// PC relative 32 bit signed</span></span>
<span class="line" id="L1649"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PC32 = <span class="tok-number">2</span>;</span>
<span class="line" id="L1650"><span class="tok-comment">/// 32 bit GOT entry</span></span>
<span class="line" id="L1651"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOT32 = <span class="tok-number">3</span>;</span>
<span class="line" id="L1652"><span class="tok-comment">/// 32 bit PLT address</span></span>
<span class="line" id="L1653"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PLT32 = <span class="tok-number">4</span>;</span>
<span class="line" id="L1654"><span class="tok-comment">/// Copy symbol at runtime</span></span>
<span class="line" id="L1655"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_COPY = <span class="tok-number">5</span>;</span>
<span class="line" id="L1656"><span class="tok-comment">/// Create GOT entry</span></span>
<span class="line" id="L1657"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GLOB_DAT = <span class="tok-number">6</span>;</span>
<span class="line" id="L1658"><span class="tok-comment">/// Create PLT entry</span></span>
<span class="line" id="L1659"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_JUMP_SLOT = <span class="tok-number">7</span>;</span>
<span class="line" id="L1660"><span class="tok-comment">/// Adjust by program base</span></span>
<span class="line" id="L1661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_RELATIVE = <span class="tok-number">8</span>;</span>
<span class="line" id="L1662"><span class="tok-comment">/// 32 bit signed PC relative offset to GOT</span></span>
<span class="line" id="L1663"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPCREL = <span class="tok-number">9</span>;</span>
<span class="line" id="L1664"><span class="tok-comment">/// Direct 32 bit zero extended</span></span>
<span class="line" id="L1665"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_32 = <span class="tok-number">10</span>;</span>
<span class="line" id="L1666"><span class="tok-comment">/// Direct 32 bit sign extended</span></span>
<span class="line" id="L1667"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_32S = <span class="tok-number">11</span>;</span>
<span class="line" id="L1668"><span class="tok-comment">/// Direct 16 bit zero extended</span></span>
<span class="line" id="L1669"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_16 = <span class="tok-number">12</span>;</span>
<span class="line" id="L1670"><span class="tok-comment">/// 16 bit sign extended pc relative</span></span>
<span class="line" id="L1671"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PC16 = <span class="tok-number">13</span>;</span>
<span class="line" id="L1672"><span class="tok-comment">/// Direct 8 bit sign extended</span></span>
<span class="line" id="L1673"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_8 = <span class="tok-number">14</span>;</span>
<span class="line" id="L1674"><span class="tok-comment">/// 8 bit sign extended pc relative</span></span>
<span class="line" id="L1675"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PC8 = <span class="tok-number">15</span>;</span>
<span class="line" id="L1676"><span class="tok-comment">/// ID of module containing symbol</span></span>
<span class="line" id="L1677"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_DTPMOD64 = <span class="tok-number">16</span>;</span>
<span class="line" id="L1678"><span class="tok-comment">/// Offset in module's TLS block</span></span>
<span class="line" id="L1679"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_DTPOFF64 = <span class="tok-number">17</span>;</span>
<span class="line" id="L1680"><span class="tok-comment">/// Offset in initial TLS block</span></span>
<span class="line" id="L1681"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TPOFF64 = <span class="tok-number">18</span>;</span>
<span class="line" id="L1682"><span class="tok-comment">/// 32 bit signed PC relative offset to two GOT entries for GD symbol</span></span>
<span class="line" id="L1683"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TLSGD = <span class="tok-number">19</span>;</span>
<span class="line" id="L1684"><span class="tok-comment">/// 32 bit signed PC relative offset to two GOT entries for LD symbol</span></span>
<span class="line" id="L1685"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TLSLD = <span class="tok-number">20</span>;</span>
<span class="line" id="L1686"><span class="tok-comment">/// Offset in TLS block</span></span>
<span class="line" id="L1687"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_DTPOFF32 = <span class="tok-number">21</span>;</span>
<span class="line" id="L1688"><span class="tok-comment">/// 32 bit signed PC relative offset to GOT entry for IE symbol</span></span>
<span class="line" id="L1689"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTTPOFF = <span class="tok-number">22</span>;</span>
<span class="line" id="L1690"><span class="tok-comment">/// Offset in initial TLS block</span></span>
<span class="line" id="L1691"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TPOFF32 = <span class="tok-number">23</span>;</span>
<span class="line" id="L1692"><span class="tok-comment">/// PC relative 64 bit</span></span>
<span class="line" id="L1693"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PC64 = <span class="tok-number">24</span>;</span>
<span class="line" id="L1694"><span class="tok-comment">/// 64 bit offset to GOT</span></span>
<span class="line" id="L1695"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTOFF64 = <span class="tok-number">25</span>;</span>
<span class="line" id="L1696"><span class="tok-comment">/// 32 bit signed pc relative offset to GOT</span></span>
<span class="line" id="L1697"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPC32 = <span class="tok-number">26</span>;</span>
<span class="line" id="L1698"><span class="tok-comment">/// 64 bit GOT entry offset</span></span>
<span class="line" id="L1699"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOT64 = <span class="tok-number">27</span>;</span>
<span class="line" id="L1700"><span class="tok-comment">/// 64 bit PC relative offset to GOT entry</span></span>
<span class="line" id="L1701"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPCREL64 = <span class="tok-number">28</span>;</span>
<span class="line" id="L1702"><span class="tok-comment">/// 64 bit PC relative offset to GOT</span></span>
<span class="line" id="L1703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPC64 = <span class="tok-number">29</span>;</span>
<span class="line" id="L1704"><span class="tok-comment">/// Like GOT64, says PLT entry needed</span></span>
<span class="line" id="L1705"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPLT64 = <span class="tok-number">30</span>;</span>
<span class="line" id="L1706"><span class="tok-comment">/// 64-bit GOT relative offset to PLT entry</span></span>
<span class="line" id="L1707"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_PLTOFF64 = <span class="tok-number">31</span>;</span>
<span class="line" id="L1708"><span class="tok-comment">/// Size of symbol plus 32-bit addend</span></span>
<span class="line" id="L1709"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_SIZE32 = <span class="tok-number">32</span>;</span>
<span class="line" id="L1710"><span class="tok-comment">/// Size of symbol plus 64-bit addend</span></span>
<span class="line" id="L1711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_SIZE64 = <span class="tok-number">33</span>;</span>
<span class="line" id="L1712"><span class="tok-comment">/// GOT offset for TLS descriptor</span></span>
<span class="line" id="L1713"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPC32_TLSDESC = <span class="tok-number">34</span>;</span>
<span class="line" id="L1714"><span class="tok-comment">/// Marker for call through TLS descriptor</span></span>
<span class="line" id="L1715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TLSDESC_CALL = <span class="tok-number">35</span>;</span>
<span class="line" id="L1716"><span class="tok-comment">/// TLS descriptor</span></span>
<span class="line" id="L1717"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_TLSDESC = <span class="tok-number">36</span>;</span>
<span class="line" id="L1718"><span class="tok-comment">/// Adjust indirectly by program base</span></span>
<span class="line" id="L1719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_IRELATIVE = <span class="tok-number">37</span>;</span>
<span class="line" id="L1720"><span class="tok-comment">/// 64-bit adjust by program base</span></span>
<span class="line" id="L1721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_RELATIVE64 = <span class="tok-number">38</span>;</span>
<span class="line" id="L1722"><span class="tok-comment">/// 39 Reserved was R_X86_64_PC32_BND</span></span>
<span class="line" id="L1723"><span class="tok-comment">/// 40 Reserved was R_X86_64_PLT32_BND</span></span>
<span class="line" id="L1724"><span class="tok-comment">/// Load from 32 bit signed pc relative offset to GOT entry without REX prefix, relaxable</span></span>
<span class="line" id="L1725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_GOTPCRELX = <span class="tok-number">41</span>;</span>
<span class="line" id="L1726"><span class="tok-comment">/// Load from 32 bit signed PC relative offset to GOT entry with REX prefix, relaxable</span></span>
<span class="line" id="L1727"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_REX_GOTPCRELX = <span class="tok-number">42</span>;</span>
<span class="line" id="L1728"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_X86_64_NUM = <span class="tok-number">43</span>;</span>
<span class="line" id="L1729"></span>
<span class="line" id="L1730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STV = <span class="tok-kw">enum</span>(<span class="tok-type">u2</span>) {</span>
<span class="line" id="L1731">    DEFAULT = <span class="tok-number">0</span>,</span>
<span class="line" id="L1732">    INTERNAL = <span class="tok-number">1</span>,</span>
<span class="line" id="L1733">    HIDDEN = <span class="tok-number">2</span>,</span>
<span class="line" id="L1734">    PROTECTED = <span class="tok-number">3</span>,</span>
<span class="line" id="L1735">};</span>
<span class="line" id="L1736"></span>
</code></pre></body>
</html>