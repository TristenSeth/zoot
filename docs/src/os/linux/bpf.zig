<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux/bpf.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> errno = getErrno;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> unexpectedErrno = std.os.unexpectedErrno;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> expectEqual = std.testing.expectEqual;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> expectError = std.testing.expectError;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> linux = std.os.linux;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> fd_t = linux.fd_t;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> pid_t = linux.pid_t;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> getErrno = linux.getErrno;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> btf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bpf/btf.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> kern = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bpf/kern.zig&quot;</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">// instruction classes</span>
</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LD = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LDX = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ST = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STX = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALU = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JMP = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RET = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MISC = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// 32-bit</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L28"><span class="tok-comment">/// 16-bit</span></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> H = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L30"><span class="tok-comment">/// 8-bit</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L32"><span class="tok-comment">/// 64-bit</span></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DW = <span class="tok-number">0x18</span>;</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMM = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABS = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IND = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LEN = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSH = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L41"></span>
<span class="line" id="L42"><span class="tok-comment">// alu fields</span>
</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADD = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUB = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MUL = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIV = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OR = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AND = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSH = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RSH = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEG = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOD = <span class="tok-number">0x90</span>;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XOR = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-comment">// jmp fields</span>
</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JA = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JEQ = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JGT = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JGE = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSET = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-comment">//#define BPF_SRC(code)   ((code) &amp; 0x08)</span>
</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> K = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> X = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXINSNS = <span class="tok-number">4096</span>;</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-comment">// instruction classes</span>
</span>
<span class="line" id="L69"><span class="tok-comment">/// jmp mode in word width</span></span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JMP32 = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-comment">/// alu mode in double word width</span></span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALU64 = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-comment">// ld/ldx fields</span>
</span>
<span class="line" id="L76"><span class="tok-comment">/// exclusive add</span></span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XADD = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-comment">// alu/jmp fields</span>
</span>
<span class="line" id="L80"><span class="tok-comment">/// mov reg to reg</span></span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOV = <span class="tok-number">0xb0</span>;</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-comment">/// sign extending arithmetic shift right */</span></span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARSH = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-comment">// change endianness of a register</span>
</span>
<span class="line" id="L87"><span class="tok-comment">/// flags for endianness conversion:</span></span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> END = <span class="tok-number">0xd0</span>;</span>
<span class="line" id="L89"></span>
<span class="line" id="L90"><span class="tok-comment">/// convert to little-endian */</span></span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TO_LE = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-comment">/// convert to big-endian</span></span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TO_BE = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FROM_LE = TO_LE;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FROM_BE = TO_BE;</span>
<span class="line" id="L97"></span>
<span class="line" id="L98"><span class="tok-comment">// jmp encodings</span>
</span>
<span class="line" id="L99"><span class="tok-comment">/// jump != *</span></span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JNE = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L101"></span>
<span class="line" id="L102"><span class="tok-comment">/// LT is unsigned, '&lt;'</span></span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JLT = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-comment">/// LE is unsigned, '&lt;=' *</span></span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JLE = <span class="tok-number">0xb0</span>;</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-comment">/// SGT is signed '&gt;', GT in x86</span></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSGT = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L110"></span>
<span class="line" id="L111"><span class="tok-comment">/// SGE is signed '&gt;=', GE in x86</span></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSGE = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L113"></span>
<span class="line" id="L114"><span class="tok-comment">/// SLT is signed, '&lt;'</span></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSLT = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L116"></span>
<span class="line" id="L117"><span class="tok-comment">/// SLE is signed, '&lt;='</span></span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSLE = <span class="tok-number">0xd0</span>;</span>
<span class="line" id="L119"></span>
<span class="line" id="L120"><span class="tok-comment">/// function call</span></span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CALL = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-comment">/// function return</span></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXIT = <span class="tok-number">0x90</span>;</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-comment">/// Flag for prog_attach command. If a sub-cgroup installs some bpf program, the</span></span>
<span class="line" id="L127"><span class="tok-comment">/// program in this cgroup yields to sub-cgroup program.</span></span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_ALLOW_OVERRIDE = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L129"></span>
<span class="line" id="L130"><span class="tok-comment">/// Flag for prog_attach command. If a sub-cgroup installs some bpf program,</span></span>
<span class="line" id="L131"><span class="tok-comment">/// that cgroup program gets run in addition to the program in this cgroup.</span></span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_ALLOW_MULTI = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L133"></span>
<span class="line" id="L134"><span class="tok-comment">/// Flag for prog_attach command.</span></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_REPLACE = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137"><span class="tok-comment">/// If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the verifier</span></span>
<span class="line" id="L138"><span class="tok-comment">/// will perform strict alignment checking as if the kernel has been built with</span></span>
<span class="line" id="L139"><span class="tok-comment">/// CONFIG_EFFICIENT_UNALIGNED_ACCESS not set, and NET_IP_ALIGN defined to 2.</span></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_STRICT_ALIGNMENT = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142"><span class="tok-comment">/// If BPF_F_ANY_ALIGNMENT is used in BPF_PROF_LOAD command, the verifier will</span></span>
<span class="line" id="L143"><span class="tok-comment">/// allow any alignment whatsoever.  On platforms with strict alignment</span></span>
<span class="line" id="L144"><span class="tok-comment">/// requirements for loads ands stores (such as sparc and mips) the verifier</span></span>
<span class="line" id="L145"><span class="tok-comment">/// validates that all loads and stores provably follow this requirement.  This</span></span>
<span class="line" id="L146"><span class="tok-comment">/// flag turns that checking and enforcement off.</span></span>
<span class="line" id="L147"><span class="tok-comment">///</span></span>
<span class="line" id="L148"><span class="tok-comment">/// It is mostly used for testing when we want to validate the context and</span></span>
<span class="line" id="L149"><span class="tok-comment">/// memory access aspects of the verifier, but because of an unaligned access</span></span>
<span class="line" id="L150"><span class="tok-comment">/// the alignment check would trigger before the one we are interested in.</span></span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_ANY_ALIGNMENT = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-comment">/// BPF_F_TEST_RND_HI32 is used in BPF_PROG_LOAD command for testing purpose.</span></span>
<span class="line" id="L154"><span class="tok-comment">/// Verifier does sub-register def/use analysis and identifies instructions</span></span>
<span class="line" id="L155"><span class="tok-comment">/// whose def only matters for low 32-bit, high 32-bit is never referenced later</span></span>
<span class="line" id="L156"><span class="tok-comment">/// through implicit zero extension. Therefore verifier notifies JIT back-ends</span></span>
<span class="line" id="L157"><span class="tok-comment">/// that it is safe to ignore clearing high 32-bit for these instructions. This</span></span>
<span class="line" id="L158"><span class="tok-comment">/// saves some back-ends a lot of code-gen. However such optimization is not</span></span>
<span class="line" id="L159"><span class="tok-comment">/// necessary on some arches, for example x86_64, arm64 etc, whose JIT back-ends</span></span>
<span class="line" id="L160"><span class="tok-comment">/// hence hasn't used verifier's analysis result. But, we really want to have a</span></span>
<span class="line" id="L161"><span class="tok-comment">/// way to be able to verify the correctness of the described optimization on</span></span>
<span class="line" id="L162"><span class="tok-comment">/// x86_64 on which testsuites are frequently exercised.</span></span>
<span class="line" id="L163"><span class="tok-comment">///</span></span>
<span class="line" id="L164"><span class="tok-comment">/// So, this flag is introduced. Once it is set, verifier will randomize high</span></span>
<span class="line" id="L165"><span class="tok-comment">/// 32-bit for those instructions who has been identified as safe to ignore</span></span>
<span class="line" id="L166"><span class="tok-comment">/// them.  Then, if verifier is not doing correct analysis, such randomization</span></span>
<span class="line" id="L167"><span class="tok-comment">/// will regress tests to expose bugs.</span></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_TEST_RND_HI32 = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-comment">/// When BPF ldimm64's insn[0].src_reg != 0 then this can have two extensions:</span></span>
<span class="line" id="L171"><span class="tok-comment">/// insn[0].src_reg:  BPF_PSEUDO_MAP_FD   BPF_PSEUDO_MAP_VALUE</span></span>
<span class="line" id="L172"><span class="tok-comment">/// insn[0].imm:      map fd              map fd</span></span>
<span class="line" id="L173"><span class="tok-comment">/// insn[1].imm:      0                   offset into value</span></span>
<span class="line" id="L174"><span class="tok-comment">/// insn[0].off:      0                   0</span></span>
<span class="line" id="L175"><span class="tok-comment">/// insn[1].off:      0                   0</span></span>
<span class="line" id="L176"><span class="tok-comment">/// ldimm64 rewrite:  address of map      address of map[0]+offset</span></span>
<span class="line" id="L177"><span class="tok-comment">/// verifier type:    CONST_PTR_TO_MAP    PTR_TO_MAP_VALUE</span></span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSEUDO_MAP_FD = <span class="tok-number">1</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSEUDO_MAP_VALUE = <span class="tok-number">2</span>;</span>
<span class="line" id="L180"></span>
<span class="line" id="L181"><span class="tok-comment">/// when bpf_call-&gt;src_reg == BPF_PSEUDO_CALL, bpf_call-&gt;imm == pc-relative</span></span>
<span class="line" id="L182"><span class="tok-comment">/// offset to another bpf function</span></span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PSEUDO_CALL = <span class="tok-number">1</span>;</span>
<span class="line" id="L184"></span>
<span class="line" id="L185"><span class="tok-comment">/// flag for BPF_MAP_UPDATE_ELEM command. create new element or update existing</span></span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ANY = <span class="tok-number">0</span>;</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-comment">/// flag for BPF_MAP_UPDATE_ELEM command. create new element if it didn't exist</span></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOEXIST = <span class="tok-number">1</span>;</span>
<span class="line" id="L190"></span>
<span class="line" id="L191"><span class="tok-comment">/// flag for BPF_MAP_UPDATE_ELEM command. update existing element</span></span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXIST = <span class="tok-number">2</span>;</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-comment">/// flag for BPF_MAP_UPDATE_ELEM command. spin_lock-ed map_lookup/map_update</span></span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_LOCK = <span class="tok-number">4</span>;</span>
<span class="line" id="L196"></span>
<span class="line" id="L197"><span class="tok-comment">/// flag for BPF_MAP_CREATE command */</span></span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_NO_PREALLOC = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L199"></span>
<span class="line" id="L200"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Instead of having one common LRU list in</span></span>
<span class="line" id="L201"><span class="tok-comment">/// the BPF_MAP_TYPE_LRU_[PERCPU_]HASH map, use a percpu LRU list which can</span></span>
<span class="line" id="L202"><span class="tok-comment">/// scale and perform better.  Note, the LRU nodes (including free nodes) cannot</span></span>
<span class="line" id="L203"><span class="tok-comment">/// be moved across different LRU lists.</span></span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_NO_COMMON_LRU = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Specify numa node during map creation</span></span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_NUMA_NODE = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Flags for BPF object read access from</span></span>
<span class="line" id="L210"><span class="tok-comment">/// syscall side</span></span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_RDONLY = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L212"></span>
<span class="line" id="L213"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Flags for BPF object write access from</span></span>
<span class="line" id="L214"><span class="tok-comment">/// syscall side</span></span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_WRONLY = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L216"></span>
<span class="line" id="L217"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Flag for stack_map, store build_id+offset</span></span>
<span class="line" id="L218"><span class="tok-comment">/// instead of pointer</span></span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_STACK_BUILD_ID = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L220"></span>
<span class="line" id="L221"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Zero-initialize hash function seed. This</span></span>
<span class="line" id="L222"><span class="tok-comment">/// should only be used for testing.</span></span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_ZERO_SEED = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L224"></span>
<span class="line" id="L225"><span class="tok-comment">/// flag for BPF_MAP_CREATE command Flags for accessing BPF object from program</span></span>
<span class="line" id="L226"><span class="tok-comment">/// side.</span></span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_RDONLY_PROG = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L228"></span>
<span class="line" id="L229"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Flags for accessing BPF object from program</span></span>
<span class="line" id="L230"><span class="tok-comment">/// side.</span></span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_WRONLY_PROG = <span class="tok-number">0x100</span>;</span>
<span class="line" id="L232"></span>
<span class="line" id="L233"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Clone map from listener for newly accepted</span></span>
<span class="line" id="L234"><span class="tok-comment">/// socket</span></span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_CLONE = <span class="tok-number">0x200</span>;</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-comment">/// flag for BPF_MAP_CREATE command. Enable memory-mapping BPF map</span></span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BPF_F_MMAPABLE = <span class="tok-number">0x400</span>;</span>
<span class="line" id="L239"></span>
<span class="line" id="L240"><span class="tok-comment">/// These values correspond to &quot;syscalls&quot; within the BPF program's environment,</span></span>
<span class="line" id="L241"><span class="tok-comment">/// each one is documented in std.os.linux.BPF.kern</span></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Helper = <span class="tok-kw">enum</span>(<span class="tok-type">i32</span>) {</span>
<span class="line" id="L243">    unspec,</span>
<span class="line" id="L244">    map_lookup_elem,</span>
<span class="line" id="L245">    map_update_elem,</span>
<span class="line" id="L246">    map_delete_elem,</span>
<span class="line" id="L247">    probe_read,</span>
<span class="line" id="L248">    ktime_get_ns,</span>
<span class="line" id="L249">    trace_printk,</span>
<span class="line" id="L250">    get_prandom_u32,</span>
<span class="line" id="L251">    get_smp_processor_id,</span>
<span class="line" id="L252">    skb_store_bytes,</span>
<span class="line" id="L253">    l3_csum_replace,</span>
<span class="line" id="L254">    l4_csum_replace,</span>
<span class="line" id="L255">    tail_call,</span>
<span class="line" id="L256">    clone_redirect,</span>
<span class="line" id="L257">    get_current_pid_tgid,</span>
<span class="line" id="L258">    get_current_uid_gid,</span>
<span class="line" id="L259">    get_current_comm,</span>
<span class="line" id="L260">    get_cgroup_classid,</span>
<span class="line" id="L261">    skb_vlan_push,</span>
<span class="line" id="L262">    skb_vlan_pop,</span>
<span class="line" id="L263">    skb_get_tunnel_key,</span>
<span class="line" id="L264">    skb_set_tunnel_key,</span>
<span class="line" id="L265">    perf_event_read,</span>
<span class="line" id="L266">    redirect,</span>
<span class="line" id="L267">    get_route_realm,</span>
<span class="line" id="L268">    perf_event_output,</span>
<span class="line" id="L269">    skb_load_bytes,</span>
<span class="line" id="L270">    get_stackid,</span>
<span class="line" id="L271">    csum_diff,</span>
<span class="line" id="L272">    skb_get_tunnel_opt,</span>
<span class="line" id="L273">    skb_set_tunnel_opt,</span>
<span class="line" id="L274">    skb_change_proto,</span>
<span class="line" id="L275">    skb_change_type,</span>
<span class="line" id="L276">    skb_under_cgroup,</span>
<span class="line" id="L277">    get_hash_recalc,</span>
<span class="line" id="L278">    get_current_task,</span>
<span class="line" id="L279">    probe_write_user,</span>
<span class="line" id="L280">    current_task_under_cgroup,</span>
<span class="line" id="L281">    skb_change_tail,</span>
<span class="line" id="L282">    skb_pull_data,</span>
<span class="line" id="L283">    csum_update,</span>
<span class="line" id="L284">    set_hash_invalid,</span>
<span class="line" id="L285">    get_numa_node_id,</span>
<span class="line" id="L286">    skb_change_head,</span>
<span class="line" id="L287">    xdp_adjust_head,</span>
<span class="line" id="L288">    probe_read_str,</span>
<span class="line" id="L289">    get_socket_cookie,</span>
<span class="line" id="L290">    get_socket_uid,</span>
<span class="line" id="L291">    set_hash,</span>
<span class="line" id="L292">    setsockopt,</span>
<span class="line" id="L293">    skb_adjust_room,</span>
<span class="line" id="L294">    redirect_map,</span>
<span class="line" id="L295">    sk_redirect_map,</span>
<span class="line" id="L296">    sock_map_update,</span>
<span class="line" id="L297">    xdp_adjust_meta,</span>
<span class="line" id="L298">    perf_event_read_value,</span>
<span class="line" id="L299">    perf_prog_read_value,</span>
<span class="line" id="L300">    getsockopt,</span>
<span class="line" id="L301">    override_return,</span>
<span class="line" id="L302">    sock_ops_cb_flags_set,</span>
<span class="line" id="L303">    msg_redirect_map,</span>
<span class="line" id="L304">    msg_apply_bytes,</span>
<span class="line" id="L305">    msg_cork_bytes,</span>
<span class="line" id="L306">    msg_pull_data,</span>
<span class="line" id="L307">    bind,</span>
<span class="line" id="L308">    xdp_adjust_tail,</span>
<span class="line" id="L309">    skb_get_xfrm_state,</span>
<span class="line" id="L310">    get_stack,</span>
<span class="line" id="L311">    skb_load_bytes_relative,</span>
<span class="line" id="L312">    fib_lookup,</span>
<span class="line" id="L313">    sock_hash_update,</span>
<span class="line" id="L314">    msg_redirect_hash,</span>
<span class="line" id="L315">    sk_redirect_hash,</span>
<span class="line" id="L316">    lwt_push_encap,</span>
<span class="line" id="L317">    lwt_seg6_store_bytes,</span>
<span class="line" id="L318">    lwt_seg6_adjust_srh,</span>
<span class="line" id="L319">    lwt_seg6_action,</span>
<span class="line" id="L320">    rc_repeat,</span>
<span class="line" id="L321">    rc_keydown,</span>
<span class="line" id="L322">    skb_cgroup_id,</span>
<span class="line" id="L323">    get_current_cgroup_id,</span>
<span class="line" id="L324">    get_local_storage,</span>
<span class="line" id="L325">    sk_select_reuseport,</span>
<span class="line" id="L326">    skb_ancestor_cgroup_id,</span>
<span class="line" id="L327">    sk_lookup_tcp,</span>
<span class="line" id="L328">    sk_lookup_udp,</span>
<span class="line" id="L329">    sk_release,</span>
<span class="line" id="L330">    map_push_elem,</span>
<span class="line" id="L331">    map_pop_elem,</span>
<span class="line" id="L332">    map_peek_elem,</span>
<span class="line" id="L333">    msg_push_data,</span>
<span class="line" id="L334">    msg_pop_data,</span>
<span class="line" id="L335">    rc_pointer_rel,</span>
<span class="line" id="L336">    spin_lock,</span>
<span class="line" id="L337">    spin_unlock,</span>
<span class="line" id="L338">    sk_fullsock,</span>
<span class="line" id="L339">    tcp_sock,</span>
<span class="line" id="L340">    skb_ecn_set_ce,</span>
<span class="line" id="L341">    get_listener_sock,</span>
<span class="line" id="L342">    skc_lookup_tcp,</span>
<span class="line" id="L343">    tcp_check_syncookie,</span>
<span class="line" id="L344">    sysctl_get_name,</span>
<span class="line" id="L345">    sysctl_get_current_value,</span>
<span class="line" id="L346">    sysctl_get_new_value,</span>
<span class="line" id="L347">    sysctl_set_new_value,</span>
<span class="line" id="L348">    strtol,</span>
<span class="line" id="L349">    strtoul,</span>
<span class="line" id="L350">    sk_storage_get,</span>
<span class="line" id="L351">    sk_storage_delete,</span>
<span class="line" id="L352">    send_signal,</span>
<span class="line" id="L353">    tcp_gen_syncookie,</span>
<span class="line" id="L354">    skb_output,</span>
<span class="line" id="L355">    probe_read_user,</span>
<span class="line" id="L356">    probe_read_kernel,</span>
<span class="line" id="L357">    probe_read_user_str,</span>
<span class="line" id="L358">    probe_read_kernel_str,</span>
<span class="line" id="L359">    tcp_send_ack,</span>
<span class="line" id="L360">    send_signal_thread,</span>
<span class="line" id="L361">    jiffies64,</span>
<span class="line" id="L362">    read_branch_records,</span>
<span class="line" id="L363">    get_ns_current_pid_tgid,</span>
<span class="line" id="L364">    xdp_output,</span>
<span class="line" id="L365">    get_netns_cookie,</span>
<span class="line" id="L366">    get_current_ancestor_cgroup_id,</span>
<span class="line" id="L367">    sk_assign,</span>
<span class="line" id="L368">    ktime_get_boot_ns,</span>
<span class="line" id="L369">    seq_printf,</span>
<span class="line" id="L370">    seq_write,</span>
<span class="line" id="L371">    sk_cgroup_id,</span>
<span class="line" id="L372">    sk_ancestor_cgroup_id,</span>
<span class="line" id="L373">    ringbuf_output,</span>
<span class="line" id="L374">    ringbuf_reserve,</span>
<span class="line" id="L375">    ringbuf_submit,</span>
<span class="line" id="L376">    ringbuf_discard,</span>
<span class="line" id="L377">    ringbuf_query,</span>
<span class="line" id="L378">    csum_level,</span>
<span class="line" id="L379">    skc_to_tcp6_sock,</span>
<span class="line" id="L380">    skc_to_tcp_sock,</span>
<span class="line" id="L381">    skc_to_tcp_timewait_sock,</span>
<span class="line" id="L382">    skc_to_tcp_request_sock,</span>
<span class="line" id="L383">    skc_to_udp6_sock,</span>
<span class="line" id="L384">    get_task_stack,</span>
<span class="line" id="L385">    _,</span>
<span class="line" id="L386">};</span>
<span class="line" id="L387"></span>
<span class="line" id="L388"><span class="tok-comment">// TODO: determine that this is the expected bit layout for both little and big</span>
</span>
<span class="line" id="L389"><span class="tok-comment">// endian systems</span>
</span>
<span class="line" id="L390"><span class="tok-comment">/// a single BPF instruction</span></span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Insn = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L392">    code: <span class="tok-type">u8</span>,</span>
<span class="line" id="L393">    dst: <span class="tok-type">u4</span>,</span>
<span class="line" id="L394">    src: <span class="tok-type">u4</span>,</span>
<span class="line" id="L395">    off: <span class="tok-type">i16</span>,</span>
<span class="line" id="L396">    imm: <span class="tok-type">i32</span>,</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">    <span class="tok-comment">/// r0 - r9 are general purpose 64-bit registers, r10 points to the stack</span></span>
<span class="line" id="L399">    <span class="tok-comment">/// frame</span></span>
<span class="line" id="L400">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Reg = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) { r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10 };</span>
<span class="line" id="L401">    <span class="tok-kw">const</span> Source = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) { reg, imm };</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-kw">const</span> Mode = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L404">        imm = IMM,</span>
<span class="line" id="L405">        abs = ABS,</span>
<span class="line" id="L406">        ind = IND,</span>
<span class="line" id="L407">        mem = MEM,</span>
<span class="line" id="L408">        len = LEN,</span>
<span class="line" id="L409">        msh = MSH,</span>
<span class="line" id="L410">    };</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">const</span> AluOp = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L413">        add = ADD,</span>
<span class="line" id="L414">        sub = SUB,</span>
<span class="line" id="L415">        mul = MUL,</span>
<span class="line" id="L416">        div = DIV,</span>
<span class="line" id="L417">        alu_or = OR,</span>
<span class="line" id="L418">        alu_and = AND,</span>
<span class="line" id="L419">        lsh = LSH,</span>
<span class="line" id="L420">        rsh = RSH,</span>
<span class="line" id="L421">        neg = NEG,</span>
<span class="line" id="L422">        mod = MOD,</span>
<span class="line" id="L423">        xor = XOR,</span>
<span class="line" id="L424">        mov = MOV,</span>
<span class="line" id="L425">        arsh = ARSH,</span>
<span class="line" id="L426">    };</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Size = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L429">        byte = B,</span>
<span class="line" id="L430">        half_word = H,</span>
<span class="line" id="L431">        word = W,</span>
<span class="line" id="L432">        double_word = DW,</span>
<span class="line" id="L433">    };</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">    <span class="tok-kw">const</span> JmpOp = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L436">        ja = JA,</span>
<span class="line" id="L437">        jeq = JEQ,</span>
<span class="line" id="L438">        jgt = JGT,</span>
<span class="line" id="L439">        jge = JGE,</span>
<span class="line" id="L440">        jset = JSET,</span>
<span class="line" id="L441">        jlt = JLT,</span>
<span class="line" id="L442">        jle = JLE,</span>
<span class="line" id="L443">        jne = JNE,</span>
<span class="line" id="L444">        jsgt = JSGT,</span>
<span class="line" id="L445">        jsge = JSGE,</span>
<span class="line" id="L446">        jslt = JSLT,</span>
<span class="line" id="L447">        jsle = JSLE,</span>
<span class="line" id="L448">    };</span>
<span class="line" id="L449"></span>
<span class="line" id="L450">    <span class="tok-kw">const</span> ImmOrReg = <span class="tok-kw">union</span>(Source) {</span>
<span class="line" id="L451">        imm: <span class="tok-type">i32</span>,</span>
<span class="line" id="L452">        reg: Reg,</span>
<span class="line" id="L453">    };</span>
<span class="line" id="L454"></span>
<span class="line" id="L455">    <span class="tok-kw">fn</span> <span class="tok-fn">imm_reg</span>(code: <span class="tok-type">u8</span>, dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L456">        <span class="tok-kw">const</span> imm_or_reg = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(src)) == .EnumLiteral)</span>
<span class="line" id="L457">            ImmOrReg{ .reg = <span class="tok-builtin">@as</span>(Reg, src) }</span>
<span class="line" id="L458">        <span class="tok-kw">else</span></span>
<span class="line" id="L459">            ImmOrReg{ .imm = src };</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        <span class="tok-kw">const</span> src_type: <span class="tok-type">u8</span> = <span class="tok-kw">switch</span> (imm_or_reg) {</span>
<span class="line" id="L462">            .imm =&gt; K,</span>
<span class="line" id="L463">            .reg =&gt; X,</span>
<span class="line" id="L464">        };</span>
<span class="line" id="L465"></span>
<span class="line" id="L466">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L467">            .code = code | src_type,</span>
<span class="line" id="L468">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L469">            .src = <span class="tok-kw">switch</span> (imm_or_reg) {</span>
<span class="line" id="L470">                .imm =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L471">                .reg =&gt; |r| <span class="tok-builtin">@enumToInt</span>(r),</span>
<span class="line" id="L472">            },</span>
<span class="line" id="L473">            .off = off,</span>
<span class="line" id="L474">            .imm = <span class="tok-kw">switch</span> (imm_or_reg) {</span>
<span class="line" id="L475">                .imm =&gt; |i| i,</span>
<span class="line" id="L476">                .reg =&gt; <span class="tok-number">0</span>,</span>
<span class="line" id="L477">            },</span>
<span class="line" id="L478">        };</span>
<span class="line" id="L479">    }</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-kw">fn</span> <span class="tok-fn">alu</span>(<span class="tok-kw">comptime</span> width: <span class="tok-type">comptime_int</span>, op: AluOp, dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L482">        <span class="tok-kw">const</span> width_bitfield = <span class="tok-kw">switch</span> (width) {</span>
<span class="line" id="L483">            <span class="tok-number">32</span> =&gt; ALU,</span>
<span class="line" id="L484">            <span class="tok-number">64</span> =&gt; ALU64,</span>
<span class="line" id="L485">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;width must be 32 or 64&quot;</span>),</span>
<span class="line" id="L486">        };</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">        <span class="tok-kw">return</span> imm_reg(width_bitfield | <span class="tok-builtin">@enumToInt</span>(op), dst, src, <span class="tok-number">0</span>);</span>
<span class="line" id="L489">    }</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mov</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L492">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .mov, dst, src);</span>
<span class="line" id="L493">    }</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">add</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L496">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .add, dst, src);</span>
<span class="line" id="L497">    }</span>
<span class="line" id="L498"></span>
<span class="line" id="L499">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sub</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L500">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .sub, dst, src);</span>
<span class="line" id="L501">    }</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mul</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L504">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .mul, dst, src);</span>
<span class="line" id="L505">    }</span>
<span class="line" id="L506"></span>
<span class="line" id="L507">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">div</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L508">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .div, dst, src);</span>
<span class="line" id="L509">    }</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alu_or</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L512">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .alu_or, dst, src);</span>
<span class="line" id="L513">    }</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alu_and</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L516">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .alu_and, dst, src);</span>
<span class="line" id="L517">    }</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lsh</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L520">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .lsh, dst, src);</span>
<span class="line" id="L521">    }</span>
<span class="line" id="L522"></span>
<span class="line" id="L523">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rsh</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L524">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .rsh, dst, src);</span>
<span class="line" id="L525">    }</span>
<span class="line" id="L526"></span>
<span class="line" id="L527">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">neg</span>(dst: Reg) Insn {</span>
<span class="line" id="L528">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .neg, dst, <span class="tok-number">0</span>);</span>
<span class="line" id="L529">    }</span>
<span class="line" id="L530"></span>
<span class="line" id="L531">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mod</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L532">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .mod, dst, src);</span>
<span class="line" id="L533">    }</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L536">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .xor, dst, src);</span>
<span class="line" id="L537">    }</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">arsh</span>(dst: Reg, src: <span class="tok-kw">anytype</span>) Insn {</span>
<span class="line" id="L540">        <span class="tok-kw">return</span> alu(<span class="tok-number">64</span>, .arsh, dst, src);</span>
<span class="line" id="L541">    }</span>
<span class="line" id="L542"></span>
<span class="line" id="L543">    <span class="tok-kw">fn</span> <span class="tok-fn">jmp</span>(op: JmpOp, dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L544">        <span class="tok-kw">return</span> imm_reg(JMP | <span class="tok-builtin">@enumToInt</span>(op), dst, src, off);</span>
<span class="line" id="L545">    }</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ja</span>(off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L548">        <span class="tok-kw">return</span> jmp(.ja, .r0, <span class="tok-number">0</span>, off);</span>
<span class="line" id="L549">    }</span>
<span class="line" id="L550"></span>
<span class="line" id="L551">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jeq</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L552">        <span class="tok-kw">return</span> jmp(.jeq, dst, src, off);</span>
<span class="line" id="L553">    }</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jgt</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L556">        <span class="tok-kw">return</span> jmp(.jgt, dst, src, off);</span>
<span class="line" id="L557">    }</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jge</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L560">        <span class="tok-kw">return</span> jmp(.jge, dst, src, off);</span>
<span class="line" id="L561">    }</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jlt</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L564">        <span class="tok-kw">return</span> jmp(.jlt, dst, src, off);</span>
<span class="line" id="L565">    }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jle</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L568">        <span class="tok-kw">return</span> jmp(.jle, dst, src, off);</span>
<span class="line" id="L569">    }</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jset</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L572">        <span class="tok-kw">return</span> jmp(.jset, dst, src, off);</span>
<span class="line" id="L573">    }</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jne</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L576">        <span class="tok-kw">return</span> jmp(.jne, dst, src, off);</span>
<span class="line" id="L577">    }</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jsgt</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L580">        <span class="tok-kw">return</span> jmp(.jsgt, dst, src, off);</span>
<span class="line" id="L581">    }</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jsge</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L584">        <span class="tok-kw">return</span> jmp(.jsge, dst, src, off);</span>
<span class="line" id="L585">    }</span>
<span class="line" id="L586"></span>
<span class="line" id="L587">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jslt</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L588">        <span class="tok-kw">return</span> jmp(.jslt, dst, src, off);</span>
<span class="line" id="L589">    }</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jsle</span>(dst: Reg, src: <span class="tok-kw">anytype</span>, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L592">        <span class="tok-kw">return</span> jmp(.jsle, dst, src, off);</span>
<span class="line" id="L593">    }</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xadd</span>(dst: Reg, src: Reg) Insn {</span>
<span class="line" id="L596">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L597">            .code = STX | XADD | DW,</span>
<span class="line" id="L598">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L599">            .src = <span class="tok-builtin">@enumToInt</span>(src),</span>
<span class="line" id="L600">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L601">            .imm = <span class="tok-number">0</span>,</span>
<span class="line" id="L602">        };</span>
<span class="line" id="L603">    }</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">    <span class="tok-kw">fn</span> <span class="tok-fn">ld</span>(mode: Mode, size: Size, dst: Reg, src: Reg, imm: <span class="tok-type">i32</span>) Insn {</span>
<span class="line" id="L606">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L607">            .code = <span class="tok-builtin">@enumToInt</span>(mode) | <span class="tok-builtin">@enumToInt</span>(size) | LD,</span>
<span class="line" id="L608">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L609">            .src = <span class="tok-builtin">@enumToInt</span>(src),</span>
<span class="line" id="L610">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L611">            .imm = imm,</span>
<span class="line" id="L612">        };</span>
<span class="line" id="L613">    }</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_abs</span>(size: Size, dst: Reg, src: Reg, imm: <span class="tok-type">i32</span>) Insn {</span>
<span class="line" id="L616">        <span class="tok-kw">return</span> ld(.abs, size, dst, src, imm);</span>
<span class="line" id="L617">    }</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_ind</span>(size: Size, dst: Reg, src: Reg, imm: <span class="tok-type">i32</span>) Insn {</span>
<span class="line" id="L620">        <span class="tok-kw">return</span> ld(.ind, size, dst, src, imm);</span>
<span class="line" id="L621">    }</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldx</span>(size: Size, dst: Reg, src: Reg, off: <span class="tok-type">i16</span>) Insn {</span>
<span class="line" id="L624">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L625">            .code = MEM | <span class="tok-builtin">@enumToInt</span>(size) | LDX,</span>
<span class="line" id="L626">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L627">            .src = <span class="tok-builtin">@enumToInt</span>(src),</span>
<span class="line" id="L628">            .off = off,</span>
<span class="line" id="L629">            .imm = <span class="tok-number">0</span>,</span>
<span class="line" id="L630">        };</span>
<span class="line" id="L631">    }</span>
<span class="line" id="L632"></span>
<span class="line" id="L633">    <span class="tok-kw">fn</span> <span class="tok-fn">ld_imm_impl1</span>(dst: Reg, src: Reg, imm: <span class="tok-type">u64</span>) Insn {</span>
<span class="line" id="L634">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L635">            .code = LD | DW | IMM,</span>
<span class="line" id="L636">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L637">            .src = <span class="tok-builtin">@enumToInt</span>(src),</span>
<span class="line" id="L638">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L639">            .imm = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, imm)),</span>
<span class="line" id="L640">        };</span>
<span class="line" id="L641">    }</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-kw">fn</span> <span class="tok-fn">ld_imm_impl2</span>(imm: <span class="tok-type">u64</span>) Insn {</span>
<span class="line" id="L644">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L645">            .code = <span class="tok-number">0</span>,</span>
<span class="line" id="L646">            .dst = <span class="tok-number">0</span>,</span>
<span class="line" id="L647">            .src = <span class="tok-number">0</span>,</span>
<span class="line" id="L648">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L649">            .imm = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, imm &gt;&gt; <span class="tok-number">32</span>)),</span>
<span class="line" id="L650">        };</span>
<span class="line" id="L651">    }</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_dw1</span>(dst: Reg, imm: <span class="tok-type">u64</span>) Insn {</span>
<span class="line" id="L654">        <span class="tok-kw">return</span> ld_imm_impl1(dst, .r0, imm);</span>
<span class="line" id="L655">    }</span>
<span class="line" id="L656"></span>
<span class="line" id="L657">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_dw2</span>(imm: <span class="tok-type">u64</span>) Insn {</span>
<span class="line" id="L658">        <span class="tok-kw">return</span> ld_imm_impl2(imm);</span>
<span class="line" id="L659">    }</span>
<span class="line" id="L660"></span>
<span class="line" id="L661">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_map_fd1</span>(dst: Reg, map_fd: fd_t) Insn {</span>
<span class="line" id="L662">        <span class="tok-kw">return</span> ld_imm_impl1(dst, <span class="tok-builtin">@intToEnum</span>(Reg, PSEUDO_MAP_FD), <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, map_fd));</span>
<span class="line" id="L663">    }</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_map_fd2</span>(map_fd: fd_t) Insn {</span>
<span class="line" id="L666">        <span class="tok-kw">return</span> ld_imm_impl2(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, map_fd));</span>
<span class="line" id="L667">    }</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">st</span>(<span class="tok-kw">comptime</span> size: Size, dst: Reg, off: <span class="tok-type">i16</span>, imm: <span class="tok-type">i32</span>) Insn {</span>
<span class="line" id="L670">        <span class="tok-kw">if</span> (size == .double_word) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: need to determine how to correctly handle double words&quot;</span>);</span>
<span class="line" id="L671">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L672">            .code = MEM | <span class="tok-builtin">@enumToInt</span>(size) | ST,</span>
<span class="line" id="L673">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L674">            .src = <span class="tok-number">0</span>,</span>
<span class="line" id="L675">            .off = off,</span>
<span class="line" id="L676">            .imm = imm,</span>
<span class="line" id="L677">        };</span>
<span class="line" id="L678">    }</span>
<span class="line" id="L679"></span>
<span class="line" id="L680">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stx</span>(size: Size, dst: Reg, off: <span class="tok-type">i16</span>, src: Reg) Insn {</span>
<span class="line" id="L681">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L682">            .code = MEM | <span class="tok-builtin">@enumToInt</span>(size) | STX,</span>
<span class="line" id="L683">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L684">            .src = <span class="tok-builtin">@enumToInt</span>(src),</span>
<span class="line" id="L685">            .off = off,</span>
<span class="line" id="L686">            .imm = <span class="tok-number">0</span>,</span>
<span class="line" id="L687">        };</span>
<span class="line" id="L688">    }</span>
<span class="line" id="L689"></span>
<span class="line" id="L690">    <span class="tok-kw">fn</span> <span class="tok-fn">endian_swap</span>(endian: std.builtin.Endian, <span class="tok-kw">comptime</span> size: Size, dst: Reg) Insn {</span>
<span class="line" id="L691">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L692">            .code = <span class="tok-kw">switch</span> (endian) {</span>
<span class="line" id="L693">                .Big =&gt; <span class="tok-number">0xdc</span>,</span>
<span class="line" id="L694">                .Little =&gt; <span class="tok-number">0xd4</span>,</span>
<span class="line" id="L695">            },</span>
<span class="line" id="L696">            .dst = <span class="tok-builtin">@enumToInt</span>(dst),</span>
<span class="line" id="L697">            .src = <span class="tok-number">0</span>,</span>
<span class="line" id="L698">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L699">            .imm = <span class="tok-kw">switch</span> (size) {</span>
<span class="line" id="L700">                .byte =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;can't swap a single byte&quot;</span>),</span>
<span class="line" id="L701">                .half_word =&gt; <span class="tok-number">16</span>,</span>
<span class="line" id="L702">                .word =&gt; <span class="tok-number">32</span>,</span>
<span class="line" id="L703">                .double_word =&gt; <span class="tok-number">64</span>,</span>
<span class="line" id="L704">            },</span>
<span class="line" id="L705">        };</span>
<span class="line" id="L706">    }</span>
<span class="line" id="L707"></span>
<span class="line" id="L708">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">le</span>(<span class="tok-kw">comptime</span> size: Size, dst: Reg) Insn {</span>
<span class="line" id="L709">        <span class="tok-kw">return</span> endian_swap(.Little, size, dst);</span>
<span class="line" id="L710">    }</span>
<span class="line" id="L711"></span>
<span class="line" id="L712">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">be</span>(<span class="tok-kw">comptime</span> size: Size, dst: Reg) Insn {</span>
<span class="line" id="L713">        <span class="tok-kw">return</span> endian_swap(.Big, size, dst);</span>
<span class="line" id="L714">    }</span>
<span class="line" id="L715"></span>
<span class="line" id="L716">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">call</span>(helper: Helper) Insn {</span>
<span class="line" id="L717">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L718">            .code = JMP | CALL,</span>
<span class="line" id="L719">            .dst = <span class="tok-number">0</span>,</span>
<span class="line" id="L720">            .src = <span class="tok-number">0</span>,</span>
<span class="line" id="L721">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L722">            .imm = <span class="tok-builtin">@enumToInt</span>(helper),</span>
<span class="line" id="L723">        };</span>
<span class="line" id="L724">    }</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-comment">/// exit BPF program</span></span>
<span class="line" id="L727">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exit</span>() Insn {</span>
<span class="line" id="L728">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L729">            .code = JMP | EXIT,</span>
<span class="line" id="L730">            .dst = <span class="tok-number">0</span>,</span>
<span class="line" id="L731">            .src = <span class="tok-number">0</span>,</span>
<span class="line" id="L732">            .off = <span class="tok-number">0</span>,</span>
<span class="line" id="L733">            .imm = <span class="tok-number">0</span>,</span>
<span class="line" id="L734">        };</span>
<span class="line" id="L735">    }</span>
<span class="line" id="L736">};</span>
<span class="line" id="L737"></span>
<span class="line" id="L738"><span class="tok-kw">test</span> <span class="tok-str">&quot;insn bitsize&quot;</span> {</span>
<span class="line" id="L739">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@bitSizeOf</span>(Insn), <span class="tok-number">64</span>);</span>
<span class="line" id="L740">}</span>
<span class="line" id="L741"></span>
<span class="line" id="L742"><span class="tok-kw">fn</span> <span class="tok-fn">expect_opcode</span>(code: <span class="tok-type">u8</span>, insn: Insn) !<span class="tok-type">void</span> {</span>
<span class="line" id="L743">    <span class="tok-kw">try</span> expectEqual(code, insn.code);</span>
<span class="line" id="L744">}</span>
<span class="line" id="L745"></span>
<span class="line" id="L746"><span class="tok-comment">// The opcodes were grabbed from https://github.com/iovisor/bpf-docs/blob/master/eBPF.md</span>
</span>
<span class="line" id="L747"><span class="tok-kw">test</span> <span class="tok-str">&quot;opcodes&quot;</span> {</span>
<span class="line" id="L748">    <span class="tok-comment">// instructions that have a name that end with 1 or 2 are consecutive for</span>
</span>
<span class="line" id="L749">    <span class="tok-comment">// loading 64-bit immediates (imm is only 32 bits wide)</span>
</span>
<span class="line" id="L750"></span>
<span class="line" id="L751">    <span class="tok-comment">// alu instructions</span>
</span>
<span class="line" id="L752">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x07</span>, Insn.add(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L753">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x0f</span>, Insn.add(.r1, .r2));</span>
<span class="line" id="L754">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x17</span>, Insn.sub(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L755">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x1f</span>, Insn.sub(.r1, .r2));</span>
<span class="line" id="L756">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x27</span>, Insn.mul(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L757">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x2f</span>, Insn.mul(.r1, .r2));</span>
<span class="line" id="L758">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x37</span>, Insn.div(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L759">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x3f</span>, Insn.div(.r1, .r2));</span>
<span class="line" id="L760">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x47</span>, Insn.alu_or(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L761">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x4f</span>, Insn.alu_or(.r1, .r2));</span>
<span class="line" id="L762">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x57</span>, Insn.alu_and(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L763">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x5f</span>, Insn.alu_and(.r1, .r2));</span>
<span class="line" id="L764">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x67</span>, Insn.lsh(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L765">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x6f</span>, Insn.lsh(.r1, .r2));</span>
<span class="line" id="L766">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x77</span>, Insn.rsh(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L767">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x7f</span>, Insn.rsh(.r1, .r2));</span>
<span class="line" id="L768">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x87</span>, Insn.neg(.r1));</span>
<span class="line" id="L769">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x97</span>, Insn.mod(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L770">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x9f</span>, Insn.mod(.r1, .r2));</span>
<span class="line" id="L771">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xa7</span>, Insn.xor(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L772">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xaf</span>, Insn.xor(.r1, .r2));</span>
<span class="line" id="L773">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xb7</span>, Insn.mov(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L774">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xbf</span>, Insn.mov(.r1, .r2));</span>
<span class="line" id="L775">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xc7</span>, Insn.arsh(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L776">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xcf</span>, Insn.arsh(.r1, .r2));</span>
<span class="line" id="L777"></span>
<span class="line" id="L778">    <span class="tok-comment">// atomic instructions: might be more of these not documented in the wild</span>
</span>
<span class="line" id="L779">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xdb</span>, Insn.xadd(.r1, .r2));</span>
<span class="line" id="L780"></span>
<span class="line" id="L781">    <span class="tok-comment">// TODO: byteswap instructions</span>
</span>
<span class="line" id="L782">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xd4</span>, Insn.le(.half_word, .r1));</span>
<span class="line" id="L783">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">16</span>), Insn.le(.half_word, .r1).imm);</span>
<span class="line" id="L784">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xd4</span>, Insn.le(.word, .r1));</span>
<span class="line" id="L785">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">32</span>), Insn.le(.word, .r1).imm);</span>
<span class="line" id="L786">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xd4</span>, Insn.le(.double_word, .r1));</span>
<span class="line" id="L787">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">64</span>), Insn.le(.double_word, .r1).imm);</span>
<span class="line" id="L788">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xdc</span>, Insn.be(.half_word, .r1));</span>
<span class="line" id="L789">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">16</span>), Insn.be(.half_word, .r1).imm);</span>
<span class="line" id="L790">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xdc</span>, Insn.be(.word, .r1));</span>
<span class="line" id="L791">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">32</span>), Insn.be(.word, .r1).imm);</span>
<span class="line" id="L792">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xdc</span>, Insn.be(.double_word, .r1));</span>
<span class="line" id="L793">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, <span class="tok-number">64</span>), Insn.be(.double_word, .r1).imm);</span>
<span class="line" id="L794"></span>
<span class="line" id="L795">    <span class="tok-comment">// memory instructions</span>
</span>
<span class="line" id="L796">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x18</span>, Insn.ld_dw1(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L797">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x00</span>, Insn.ld_dw2(<span class="tok-number">0</span>));</span>
<span class="line" id="L798"></span>
<span class="line" id="L799">    <span class="tok-comment">//   loading a map fd</span>
</span>
<span class="line" id="L800">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x18</span>, Insn.ld_map_fd1(.r1, <span class="tok-number">0</span>));</span>
<span class="line" id="L801">    <span class="tok-kw">try</span> expectEqual(<span class="tok-builtin">@intCast</span>(<span class="tok-type">u4</span>, PSEUDO_MAP_FD), Insn.ld_map_fd1(.r1, <span class="tok-number">0</span>).src);</span>
<span class="line" id="L802">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x00</span>, Insn.ld_map_fd2(<span class="tok-number">0</span>));</span>
<span class="line" id="L803"></span>
<span class="line" id="L804">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x38</span>, Insn.ld_abs(.double_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L805">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x20</span>, Insn.ld_abs(.word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L806">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x28</span>, Insn.ld_abs(.half_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L807">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x30</span>, Insn.ld_abs(.byte, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x58</span>, Insn.ld_ind(.double_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x40</span>, Insn.ld_ind(.word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L811">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x48</span>, Insn.ld_ind(.half_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L812">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x50</span>, Insn.ld_ind(.byte, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L813"></span>
<span class="line" id="L814">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x79</span>, Insn.ldx(.double_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L815">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x61</span>, Insn.ldx(.word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L816">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x69</span>, Insn.ldx(.half_word, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L817">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x71</span>, Insn.ldx(.byte, .r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L818"></span>
<span class="line" id="L819">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x62</span>, Insn.st(.word, .r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L820">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x6a</span>, Insn.st(.half_word, .r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L821">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x72</span>, Insn.st(.byte, .r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L822"></span>
<span class="line" id="L823">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x63</span>, Insn.stx(.word, .r1, <span class="tok-number">0</span>, .r2));</span>
<span class="line" id="L824">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x6b</span>, Insn.stx(.half_word, .r1, <span class="tok-number">0</span>, .r2));</span>
<span class="line" id="L825">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x73</span>, Insn.stx(.byte, .r1, <span class="tok-number">0</span>, .r2));</span>
<span class="line" id="L826">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x7b</span>, Insn.stx(.double_word, .r1, <span class="tok-number">0</span>, .r2));</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    <span class="tok-comment">// branch instructions</span>
</span>
<span class="line" id="L829">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x05</span>, Insn.ja(<span class="tok-number">0</span>));</span>
<span class="line" id="L830">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x15</span>, Insn.jeq(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L831">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x1d</span>, Insn.jeq(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L832">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x25</span>, Insn.jgt(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L833">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x2d</span>, Insn.jgt(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L834">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x35</span>, Insn.jge(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L835">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x3d</span>, Insn.jge(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L836">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xa5</span>, Insn.jlt(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L837">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xad</span>, Insn.jlt(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L838">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xb5</span>, Insn.jle(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L839">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xbd</span>, Insn.jle(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L840">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x45</span>, Insn.jset(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L841">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x4d</span>, Insn.jset(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L842">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x55</span>, Insn.jne(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L843">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x5d</span>, Insn.jne(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L844">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x65</span>, Insn.jsgt(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L845">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x6d</span>, Insn.jsgt(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L846">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x75</span>, Insn.jsge(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L847">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x7d</span>, Insn.jsge(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L848">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xc5</span>, Insn.jslt(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L849">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xcd</span>, Insn.jslt(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L850">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xd5</span>, Insn.jsle(.r1, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L851">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0xdd</span>, Insn.jsle(.r1, .r2, <span class="tok-number">0</span>));</span>
<span class="line" id="L852">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x85</span>, Insn.call(.unspec));</span>
<span class="line" id="L853">    <span class="tok-kw">try</span> expect_opcode(<span class="tok-number">0x95</span>, Insn.exit());</span>
<span class="line" id="L854">}</span>
<span class="line" id="L855"></span>
<span class="line" id="L856"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Cmd = <span class="tok-kw">enum</span>(<span class="tok-type">usize</span>) {</span>
<span class="line" id="L857">    <span class="tok-comment">/// Create  a map and return a file descriptor that refers to the map.  The</span></span>
<span class="line" id="L858">    <span class="tok-comment">/// close-on-exec file descriptor flag is automatically enabled for the new</span></span>
<span class="line" id="L859">    <span class="tok-comment">/// file descriptor.</span></span>
<span class="line" id="L860">    <span class="tok-comment">///</span></span>
<span class="line" id="L861">    <span class="tok-comment">/// uses MapCreateAttr</span></span>
<span class="line" id="L862">    map_create,</span>
<span class="line" id="L863"></span>
<span class="line" id="L864">    <span class="tok-comment">/// Look up an element by key in a specified map and return its value.</span></span>
<span class="line" id="L865">    <span class="tok-comment">///</span></span>
<span class="line" id="L866">    <span class="tok-comment">/// uses MapElemAttr</span></span>
<span class="line" id="L867">    map_lookup_elem,</span>
<span class="line" id="L868"></span>
<span class="line" id="L869">    <span class="tok-comment">/// Create or update an element (key/value pair) in a specified map.</span></span>
<span class="line" id="L870">    <span class="tok-comment">///</span></span>
<span class="line" id="L871">    <span class="tok-comment">/// uses MapElemAttr</span></span>
<span class="line" id="L872">    map_update_elem,</span>
<span class="line" id="L873"></span>
<span class="line" id="L874">    <span class="tok-comment">/// Look up and delete an element by key in a specified map.</span></span>
<span class="line" id="L875">    <span class="tok-comment">///</span></span>
<span class="line" id="L876">    <span class="tok-comment">/// uses MapElemAttr</span></span>
<span class="line" id="L877">    map_delete_elem,</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">    <span class="tok-comment">/// Look up an element by key in a specified map and return the key of the</span></span>
<span class="line" id="L880">    <span class="tok-comment">/// next element.</span></span>
<span class="line" id="L881">    map_get_next_key,</span>
<span class="line" id="L882"></span>
<span class="line" id="L883">    <span class="tok-comment">/// Verify and load an eBPF program, returning a new file descriptor</span></span>
<span class="line" id="L884">    <span class="tok-comment">/// associated with  the  program.   The close-on-exec file descriptor flag</span></span>
<span class="line" id="L885">    <span class="tok-comment">/// is automatically enabled for the new file descriptor.</span></span>
<span class="line" id="L886">    <span class="tok-comment">///</span></span>
<span class="line" id="L887">    <span class="tok-comment">/// uses ProgLoadAttr</span></span>
<span class="line" id="L888">    prog_load,</span>
<span class="line" id="L889"></span>
<span class="line" id="L890">    <span class="tok-comment">/// Pin a map or eBPF program to a path within the minimal BPF filesystem</span></span>
<span class="line" id="L891">    <span class="tok-comment">///</span></span>
<span class="line" id="L892">    <span class="tok-comment">/// uses ObjAttr</span></span>
<span class="line" id="L893">    obj_pin,</span>
<span class="line" id="L894"></span>
<span class="line" id="L895">    <span class="tok-comment">/// Get the file descriptor of a BPF object pinned to a certain path</span></span>
<span class="line" id="L896">    <span class="tok-comment">///</span></span>
<span class="line" id="L897">    <span class="tok-comment">/// uses ObjAttr</span></span>
<span class="line" id="L898">    obj_get,</span>
<span class="line" id="L899"></span>
<span class="line" id="L900">    <span class="tok-comment">/// uses ProgAttachAttr</span></span>
<span class="line" id="L901">    prog_attach,</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">    <span class="tok-comment">/// uses ProgAttachAttr</span></span>
<span class="line" id="L904">    prog_detach,</span>
<span class="line" id="L905"></span>
<span class="line" id="L906">    <span class="tok-comment">/// uses TestRunAttr</span></span>
<span class="line" id="L907">    prog_test_run,</span>
<span class="line" id="L908"></span>
<span class="line" id="L909">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L910">    prog_get_next_id,</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L913">    map_get_next_id,</span>
<span class="line" id="L914"></span>
<span class="line" id="L915">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L916">    prog_get_fd_by_id,</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L919">    map_get_fd_by_id,</span>
<span class="line" id="L920"></span>
<span class="line" id="L921">    <span class="tok-comment">/// uses InfoAttr</span></span>
<span class="line" id="L922">    obj_get_info_by_fd,</span>
<span class="line" id="L923"></span>
<span class="line" id="L924">    <span class="tok-comment">/// uses QueryAttr</span></span>
<span class="line" id="L925">    prog_query,</span>
<span class="line" id="L926"></span>
<span class="line" id="L927">    <span class="tok-comment">/// uses RawTracepointAttr</span></span>
<span class="line" id="L928">    raw_tracepoint_open,</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">    <span class="tok-comment">/// uses BtfLoadAttr</span></span>
<span class="line" id="L931">    btf_load,</span>
<span class="line" id="L932"></span>
<span class="line" id="L933">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L934">    btf_get_fd_by_id,</span>
<span class="line" id="L935"></span>
<span class="line" id="L936">    <span class="tok-comment">/// uses TaskFdQueryAttr</span></span>
<span class="line" id="L937">    task_fd_query,</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">    <span class="tok-comment">/// uses MapElemAttr</span></span>
<span class="line" id="L940">    map_lookup_and_delete_elem,</span>
<span class="line" id="L941">    map_freeze,</span>
<span class="line" id="L942"></span>
<span class="line" id="L943">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L944">    btf_get_next_id,</span>
<span class="line" id="L945"></span>
<span class="line" id="L946">    <span class="tok-comment">/// uses MapBatchAttr</span></span>
<span class="line" id="L947">    map_lookup_batch,</span>
<span class="line" id="L948"></span>
<span class="line" id="L949">    <span class="tok-comment">/// uses MapBatchAttr</span></span>
<span class="line" id="L950">    map_lookup_and_delete_batch,</span>
<span class="line" id="L951"></span>
<span class="line" id="L952">    <span class="tok-comment">/// uses MapBatchAttr</span></span>
<span class="line" id="L953">    map_update_batch,</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">    <span class="tok-comment">/// uses MapBatchAttr</span></span>
<span class="line" id="L956">    map_delete_batch,</span>
<span class="line" id="L957"></span>
<span class="line" id="L958">    <span class="tok-comment">/// uses LinkCreateAttr</span></span>
<span class="line" id="L959">    link_create,</span>
<span class="line" id="L960"></span>
<span class="line" id="L961">    <span class="tok-comment">/// uses LinkUpdateAttr</span></span>
<span class="line" id="L962">    link_update,</span>
<span class="line" id="L963"></span>
<span class="line" id="L964">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L965">    link_get_fd_by_id,</span>
<span class="line" id="L966"></span>
<span class="line" id="L967">    <span class="tok-comment">/// uses GetIdAttr</span></span>
<span class="line" id="L968">    link_get_next_id,</span>
<span class="line" id="L969"></span>
<span class="line" id="L970">    <span class="tok-comment">/// uses EnableStatsAttr</span></span>
<span class="line" id="L971">    enable_stats,</span>
<span class="line" id="L972"></span>
<span class="line" id="L973">    <span class="tok-comment">/// uses IterCreateAttr</span></span>
<span class="line" id="L974">    iter_create,</span>
<span class="line" id="L975">    link_detach,</span>
<span class="line" id="L976">    _,</span>
<span class="line" id="L977">};</span>
<span class="line" id="L978"></span>
<span class="line" id="L979"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MapType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L980">    unspec,</span>
<span class="line" id="L981">    hash,</span>
<span class="line" id="L982">    array,</span>
<span class="line" id="L983">    prog_array,</span>
<span class="line" id="L984">    perf_event_array,</span>
<span class="line" id="L985">    percpu_hash,</span>
<span class="line" id="L986">    percpu_array,</span>
<span class="line" id="L987">    stack_trace,</span>
<span class="line" id="L988">    cgroup_array,</span>
<span class="line" id="L989">    lru_hash,</span>
<span class="line" id="L990">    lru_percpu_hash,</span>
<span class="line" id="L991">    lpm_trie,</span>
<span class="line" id="L992">    array_of_maps,</span>
<span class="line" id="L993">    hash_of_maps,</span>
<span class="line" id="L994">    devmap,</span>
<span class="line" id="L995">    sockmap,</span>
<span class="line" id="L996">    cpumap,</span>
<span class="line" id="L997">    xskmap,</span>
<span class="line" id="L998">    sockhash,</span>
<span class="line" id="L999">    cgroup_storage,</span>
<span class="line" id="L1000">    reuseport_sockarray,</span>
<span class="line" id="L1001">    percpu_cgroup_storage,</span>
<span class="line" id="L1002">    queue,</span>
<span class="line" id="L1003">    stack,</span>
<span class="line" id="L1004">    sk_storage,</span>
<span class="line" id="L1005">    devmap_hash,</span>
<span class="line" id="L1006">    struct_ops,</span>
<span class="line" id="L1007"></span>
<span class="line" id="L1008">    <span class="tok-comment">/// An ordered and shared CPU version of perf_event_array. They have</span></span>
<span class="line" id="L1009">    <span class="tok-comment">/// similar semantics:</span></span>
<span class="line" id="L1010">    <span class="tok-comment">///     - variable length records</span></span>
<span class="line" id="L1011">    <span class="tok-comment">///     - no blocking: when full, reservation fails</span></span>
<span class="line" id="L1012">    <span class="tok-comment">///     - memory mappable for ease and speed</span></span>
<span class="line" id="L1013">    <span class="tok-comment">///     - epoll notifications for new data, but can busy poll</span></span>
<span class="line" id="L1014">    <span class="tok-comment">///</span></span>
<span class="line" id="L1015">    <span class="tok-comment">/// Ringbufs give BPF programs two sets of APIs:</span></span>
<span class="line" id="L1016">    <span class="tok-comment">///     - ringbuf_output() allows copy data from one place to a ring</span></span>
<span class="line" id="L1017">    <span class="tok-comment">///     buffer, similar to bpf_perf_event_output()</span></span>
<span class="line" id="L1018">    <span class="tok-comment">///     - ringbuf_reserve()/ringbuf_commit()/ringbuf_discard() split the</span></span>
<span class="line" id="L1019">    <span class="tok-comment">///     process into two steps. First a fixed amount of space is reserved,</span></span>
<span class="line" id="L1020">    <span class="tok-comment">///     if that is successful then the program gets a pointer to a chunk of</span></span>
<span class="line" id="L1021">    <span class="tok-comment">///     memory and can be submitted with commit() or discarded with</span></span>
<span class="line" id="L1022">    <span class="tok-comment">///     discard()</span></span>
<span class="line" id="L1023">    <span class="tok-comment">///</span></span>
<span class="line" id="L1024">    <span class="tok-comment">/// ringbuf_output() will incurr an extra memory copy, but allows to submit</span></span>
<span class="line" id="L1025">    <span class="tok-comment">/// records of the length that's not known beforehand, and is an easy</span></span>
<span class="line" id="L1026">    <span class="tok-comment">/// replacement for perf_event_outptu().</span></span>
<span class="line" id="L1027">    <span class="tok-comment">///</span></span>
<span class="line" id="L1028">    <span class="tok-comment">/// ringbuf_reserve() avoids the extra memory copy but requires a known size</span></span>
<span class="line" id="L1029">    <span class="tok-comment">/// of memory beforehand.</span></span>
<span class="line" id="L1030">    <span class="tok-comment">///</span></span>
<span class="line" id="L1031">    <span class="tok-comment">/// ringbuf_query() allows to query properties of the map, 4 are currently</span></span>
<span class="line" id="L1032">    <span class="tok-comment">/// supported:</span></span>
<span class="line" id="L1033">    <span class="tok-comment">///     - BPF_RB_AVAIL_DATA: amount of unconsumed data in ringbuf</span></span>
<span class="line" id="L1034">    <span class="tok-comment">///     - BPF_RB_RING_SIZE: returns size of ringbuf</span></span>
<span class="line" id="L1035">    <span class="tok-comment">///     - BPF_RB_CONS_POS/BPF_RB_PROD_POS returns current logical position</span></span>
<span class="line" id="L1036">    <span class="tok-comment">///     of consumer and producer respectively</span></span>
<span class="line" id="L1037">    <span class="tok-comment">///</span></span>
<span class="line" id="L1038">    <span class="tok-comment">/// key size: 0</span></span>
<span class="line" id="L1039">    <span class="tok-comment">/// value size: 0</span></span>
<span class="line" id="L1040">    <span class="tok-comment">/// max entries: size of ringbuf, must be power of 2</span></span>
<span class="line" id="L1041">    ringbuf,</span>
<span class="line" id="L1042"></span>
<span class="line" id="L1043">    _,</span>
<span class="line" id="L1044">};</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProgType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L1047">    unspec,</span>
<span class="line" id="L1048"></span>
<span class="line" id="L1049">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1050">    socket_filter,</span>
<span class="line" id="L1051"></span>
<span class="line" id="L1052">    <span class="tok-comment">/// context type: bpf_user_pt_regs_t</span></span>
<span class="line" id="L1053">    kprobe,</span>
<span class="line" id="L1054"></span>
<span class="line" id="L1055">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1056">    sched_cls,</span>
<span class="line" id="L1057"></span>
<span class="line" id="L1058">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1059">    sched_act,</span>
<span class="line" id="L1060"></span>
<span class="line" id="L1061">    <span class="tok-comment">/// context type: u64</span></span>
<span class="line" id="L1062">    tracepoint,</span>
<span class="line" id="L1063"></span>
<span class="line" id="L1064">    <span class="tok-comment">/// context type: xdp_md</span></span>
<span class="line" id="L1065">    xdp,</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067">    <span class="tok-comment">/// context type: bpf_perf_event_data</span></span>
<span class="line" id="L1068">    perf_event,</span>
<span class="line" id="L1069"></span>
<span class="line" id="L1070">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1071">    cgroup_skb,</span>
<span class="line" id="L1072"></span>
<span class="line" id="L1073">    <span class="tok-comment">/// context type: bpf_sock</span></span>
<span class="line" id="L1074">    cgroup_sock,</span>
<span class="line" id="L1075"></span>
<span class="line" id="L1076">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1077">    lwt_in,</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1080">    lwt_out,</span>
<span class="line" id="L1081"></span>
<span class="line" id="L1082">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1083">    lwt_xmit,</span>
<span class="line" id="L1084"></span>
<span class="line" id="L1085">    <span class="tok-comment">/// context type: bpf_sock_ops</span></span>
<span class="line" id="L1086">    sock_ops,</span>
<span class="line" id="L1087"></span>
<span class="line" id="L1088">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1089">    sk_skb,</span>
<span class="line" id="L1090"></span>
<span class="line" id="L1091">    <span class="tok-comment">/// context type: bpf_cgroup_dev_ctx</span></span>
<span class="line" id="L1092">    cgroup_device,</span>
<span class="line" id="L1093"></span>
<span class="line" id="L1094">    <span class="tok-comment">/// context type: sk_msg_md</span></span>
<span class="line" id="L1095">    sk_msg,</span>
<span class="line" id="L1096"></span>
<span class="line" id="L1097">    <span class="tok-comment">/// context type: bpf_raw_tracepoint_args</span></span>
<span class="line" id="L1098">    raw_tracepoint,</span>
<span class="line" id="L1099"></span>
<span class="line" id="L1100">    <span class="tok-comment">/// context type: bpf_sock_addr</span></span>
<span class="line" id="L1101">    cgroup_sock_addr,</span>
<span class="line" id="L1102"></span>
<span class="line" id="L1103">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1104">    lwt_seg6local,</span>
<span class="line" id="L1105"></span>
<span class="line" id="L1106">    <span class="tok-comment">/// context type: u32</span></span>
<span class="line" id="L1107">    lirc_mode2,</span>
<span class="line" id="L1108"></span>
<span class="line" id="L1109">    <span class="tok-comment">/// context type: sk_reuseport_md</span></span>
<span class="line" id="L1110">    sk_reuseport,</span>
<span class="line" id="L1111"></span>
<span class="line" id="L1112">    <span class="tok-comment">/// context type: __sk_buff</span></span>
<span class="line" id="L1113">    flow_dissector,</span>
<span class="line" id="L1114"></span>
<span class="line" id="L1115">    <span class="tok-comment">/// context type: bpf_sysctl</span></span>
<span class="line" id="L1116">    cgroup_sysctl,</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">    <span class="tok-comment">/// context type: bpf_raw_tracepoint_args</span></span>
<span class="line" id="L1119">    raw_tracepoint_writable,</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121">    <span class="tok-comment">/// context type: bpf_sockopt</span></span>
<span class="line" id="L1122">    cgroup_sockopt,</span>
<span class="line" id="L1123"></span>
<span class="line" id="L1124">    <span class="tok-comment">/// context type: void *</span></span>
<span class="line" id="L1125">    tracing,</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127">    <span class="tok-comment">/// context type: void *</span></span>
<span class="line" id="L1128">    struct_ops,</span>
<span class="line" id="L1129"></span>
<span class="line" id="L1130">    <span class="tok-comment">/// context type: void *</span></span>
<span class="line" id="L1131">    ext,</span>
<span class="line" id="L1132"></span>
<span class="line" id="L1133">    <span class="tok-comment">/// context type: void *</span></span>
<span class="line" id="L1134">    lsm,</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136">    <span class="tok-comment">/// context type: bpf_sk_lookup</span></span>
<span class="line" id="L1137">    sk_lookup,</span>
<span class="line" id="L1138">    _,</span>
<span class="line" id="L1139">};</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AttachType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L1142">    cgroup_inet_ingress,</span>
<span class="line" id="L1143">    cgroup_inet_egress,</span>
<span class="line" id="L1144">    cgroup_inet_sock_create,</span>
<span class="line" id="L1145">    cgroup_sock_ops,</span>
<span class="line" id="L1146">    sk_skb_stream_parser,</span>
<span class="line" id="L1147">    sk_skb_stream_verdict,</span>
<span class="line" id="L1148">    cgroup_device,</span>
<span class="line" id="L1149">    sk_msg_verdict,</span>
<span class="line" id="L1150">    cgroup_inet4_bind,</span>
<span class="line" id="L1151">    cgroup_inet6_bind,</span>
<span class="line" id="L1152">    cgroup_inet4_connect,</span>
<span class="line" id="L1153">    cgroup_inet6_connect,</span>
<span class="line" id="L1154">    cgroup_inet4_post_bind,</span>
<span class="line" id="L1155">    cgroup_inet6_post_bind,</span>
<span class="line" id="L1156">    cgroup_udp4_sendmsg,</span>
<span class="line" id="L1157">    cgroup_udp6_sendmsg,</span>
<span class="line" id="L1158">    lirc_mode2,</span>
<span class="line" id="L1159">    flow_dissector,</span>
<span class="line" id="L1160">    cgroup_sysctl,</span>
<span class="line" id="L1161">    cgroup_udp4_recvmsg,</span>
<span class="line" id="L1162">    cgroup_udp6_recvmsg,</span>
<span class="line" id="L1163">    cgroup_getsockopt,</span>
<span class="line" id="L1164">    cgroup_setsockopt,</span>
<span class="line" id="L1165">    trace_raw_tp,</span>
<span class="line" id="L1166">    trace_fentry,</span>
<span class="line" id="L1167">    trace_fexit,</span>
<span class="line" id="L1168">    modify_return,</span>
<span class="line" id="L1169">    lsm_mac,</span>
<span class="line" id="L1170">    trace_iter,</span>
<span class="line" id="L1171">    cgroup_inet4_getpeername,</span>
<span class="line" id="L1172">    cgroup_inet6_getpeername,</span>
<span class="line" id="L1173">    cgroup_inet4_getsockname,</span>
<span class="line" id="L1174">    cgroup_inet6_getsockname,</span>
<span class="line" id="L1175">    xdp_devmap,</span>
<span class="line" id="L1176">    cgroup_inet_sock_release,</span>
<span class="line" id="L1177">    xdp_cpumap,</span>
<span class="line" id="L1178">    sk_lookup,</span>
<span class="line" id="L1179">    xdp,</span>
<span class="line" id="L1180">    _,</span>
<span class="line" id="L1181">};</span>
<span class="line" id="L1182"></span>
<span class="line" id="L1183"><span class="tok-kw">const</span> obj_name_len = <span class="tok-number">16</span>;</span>
<span class="line" id="L1184"><span class="tok-comment">/// struct used by Cmd.map_create command</span></span>
<span class="line" id="L1185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MapCreateAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1186">    <span class="tok-comment">/// one of MapType</span></span>
<span class="line" id="L1187">    map_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1188"></span>
<span class="line" id="L1189">    <span class="tok-comment">/// size of key in bytes</span></span>
<span class="line" id="L1190">    key_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1191"></span>
<span class="line" id="L1192">    <span class="tok-comment">/// size of value in bytes</span></span>
<span class="line" id="L1193">    value_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1194"></span>
<span class="line" id="L1195">    <span class="tok-comment">/// max number of entries in a map</span></span>
<span class="line" id="L1196">    max_entries: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1197"></span>
<span class="line" id="L1198">    <span class="tok-comment">/// .map_create related flags</span></span>
<span class="line" id="L1199">    map_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1200"></span>
<span class="line" id="L1201">    <span class="tok-comment">/// fd pointing to the inner map</span></span>
<span class="line" id="L1202">    inner_map_fd: fd_t,</span>
<span class="line" id="L1203"></span>
<span class="line" id="L1204">    <span class="tok-comment">/// numa node (effective only if MapCreateFlags.numa_node is set)</span></span>
<span class="line" id="L1205">    numa_node: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1206">    map_name: [obj_name_len]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208">    <span class="tok-comment">/// ifindex of netdev to create on</span></span>
<span class="line" id="L1209">    map_ifindex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1210"></span>
<span class="line" id="L1211">    <span class="tok-comment">/// fd pointing to a BTF type data</span></span>
<span class="line" id="L1212">    btf_fd: fd_t,</span>
<span class="line" id="L1213"></span>
<span class="line" id="L1214">    <span class="tok-comment">/// BTF type_id of the key</span></span>
<span class="line" id="L1215">    btf_key_type_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1216"></span>
<span class="line" id="L1217">    <span class="tok-comment">/// BTF type_id of the value</span></span>
<span class="line" id="L1218">    bpf_value_type_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1219"></span>
<span class="line" id="L1220">    <span class="tok-comment">/// BTF type_id of a kernel struct stored as the map value</span></span>
<span class="line" id="L1221">    btf_vmlinux_value_type_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1222">};</span>
<span class="line" id="L1223"></span>
<span class="line" id="L1224"><span class="tok-comment">/// struct used by Cmd.map_*_elem commands</span></span>
<span class="line" id="L1225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MapElemAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1226">    map_fd: fd_t,</span>
<span class="line" id="L1227">    key: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1228">    result: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L1229">        value: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1230">        next_key: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1231">    },</span>
<span class="line" id="L1232">    flags: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1233">};</span>
<span class="line" id="L1234"></span>
<span class="line" id="L1235"><span class="tok-comment">/// struct used by Cmd.map_*_batch commands</span></span>
<span class="line" id="L1236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MapBatchAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1237">    <span class="tok-comment">/// start batch, NULL to start from beginning</span></span>
<span class="line" id="L1238">    in_batch: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1239"></span>
<span class="line" id="L1240">    <span class="tok-comment">/// output: next start batch</span></span>
<span class="line" id="L1241">    out_batch: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1242">    keys: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1243">    values: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1244"></span>
<span class="line" id="L1245">    <span class="tok-comment">/// input/output:</span></span>
<span class="line" id="L1246">    <span class="tok-comment">/// input: # of key/value elements</span></span>
<span class="line" id="L1247">    <span class="tok-comment">/// output: # of filled elements</span></span>
<span class="line" id="L1248">    count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1249">    map_fd: fd_t,</span>
<span class="line" id="L1250">    elem_flags: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1251">    flags: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1252">};</span>
<span class="line" id="L1253"></span>
<span class="line" id="L1254"><span class="tok-comment">/// struct used by Cmd.prog_load command</span></span>
<span class="line" id="L1255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProgLoadAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1256">    <span class="tok-comment">/// one of ProgType</span></span>
<span class="line" id="L1257">    prog_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1258">    insn_cnt: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1259">    insns: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1260">    license: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1261"></span>
<span class="line" id="L1262">    <span class="tok-comment">/// verbosity level of verifier</span></span>
<span class="line" id="L1263">    log_level: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265">    <span class="tok-comment">/// size of user buffer</span></span>
<span class="line" id="L1266">    log_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1267"></span>
<span class="line" id="L1268">    <span class="tok-comment">/// user supplied buffer</span></span>
<span class="line" id="L1269">    log_buf: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">    <span class="tok-comment">/// not used</span></span>
<span class="line" id="L1272">    kern_version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1273">    prog_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1274">    prog_name: [obj_name_len]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1275"></span>
<span class="line" id="L1276">    <span class="tok-comment">/// ifindex of netdev to prep for.</span></span>
<span class="line" id="L1277">    prog_ifindex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1278"></span>
<span class="line" id="L1279">    <span class="tok-comment">/// For some prog types expected attach type must be known at load time to</span></span>
<span class="line" id="L1280">    <span class="tok-comment">/// verify attach type specific parts of prog (context accesses, allowed</span></span>
<span class="line" id="L1281">    <span class="tok-comment">/// helpers, etc).</span></span>
<span class="line" id="L1282">    expected_attach_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">    <span class="tok-comment">/// fd pointing to BTF type data</span></span>
<span class="line" id="L1285">    prog_btf_fd: fd_t,</span>
<span class="line" id="L1286"></span>
<span class="line" id="L1287">    <span class="tok-comment">/// userspace bpf_func_info size</span></span>
<span class="line" id="L1288">    func_info_rec_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1289">    func_info: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1290"></span>
<span class="line" id="L1291">    <span class="tok-comment">/// number of bpf_func_info records</span></span>
<span class="line" id="L1292">    func_info_cnt: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294">    <span class="tok-comment">/// userspace bpf_line_info size</span></span>
<span class="line" id="L1295">    line_info_rec_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1296">    line_info: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1297"></span>
<span class="line" id="L1298">    <span class="tok-comment">/// number of bpf_line_info records</span></span>
<span class="line" id="L1299">    line_info_cnt: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1300"></span>
<span class="line" id="L1301">    <span class="tok-comment">/// in-kernel BTF type id to attach to</span></span>
<span class="line" id="L1302">    attact_btf_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1303"></span>
<span class="line" id="L1304">    <span class="tok-comment">/// 0 to attach to vmlinux</span></span>
<span class="line" id="L1305">    attach_prog_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1306">};</span>
<span class="line" id="L1307"></span>
<span class="line" id="L1308"><span class="tok-comment">/// struct used by Cmd.obj_* commands</span></span>
<span class="line" id="L1309"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ObjAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1310">    pathname: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1311">    bpf_fd: fd_t,</span>
<span class="line" id="L1312">    file_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1313">};</span>
<span class="line" id="L1314"></span>
<span class="line" id="L1315"><span class="tok-comment">/// struct used by Cmd.prog_attach/detach commands</span></span>
<span class="line" id="L1316"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProgAttachAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1317">    <span class="tok-comment">/// container object to attach to</span></span>
<span class="line" id="L1318">    target_fd: fd_t,</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">    <span class="tok-comment">/// eBPF program to attach</span></span>
<span class="line" id="L1321">    attach_bpf_fd: fd_t,</span>
<span class="line" id="L1322"></span>
<span class="line" id="L1323">    attach_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1324">    attach_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1325"></span>
<span class="line" id="L1326">    <span class="tok-comment">// TODO: BPF_F_REPLACE flags</span>
</span>
<span class="line" id="L1327">    <span class="tok-comment">/// previously attached eBPF program to replace if .replace is used</span></span>
<span class="line" id="L1328">    replace_bpf_fd: fd_t,</span>
<span class="line" id="L1329">};</span>
<span class="line" id="L1330"></span>
<span class="line" id="L1331"><span class="tok-comment">/// struct used by Cmd.prog_test_run command</span></span>
<span class="line" id="L1332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TestRunAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1333">    prog_fd: fd_t,</span>
<span class="line" id="L1334">    retval: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1335"></span>
<span class="line" id="L1336">    <span class="tok-comment">/// input: len of data_in</span></span>
<span class="line" id="L1337">    data_size_in: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1338"></span>
<span class="line" id="L1339">    <span class="tok-comment">/// input/output: len of data_out. returns ENOSPC if data_out is too small.</span></span>
<span class="line" id="L1340">    data_size_out: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1341">    data_in: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1342">    data_out: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1343">    repeat: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1344">    duration: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1345"></span>
<span class="line" id="L1346">    <span class="tok-comment">/// input: len of ctx_in</span></span>
<span class="line" id="L1347">    ctx_size_in: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1348"></span>
<span class="line" id="L1349">    <span class="tok-comment">/// input/output: len of ctx_out. returns ENOSPC if ctx_out is too small.</span></span>
<span class="line" id="L1350">    ctx_size_out: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1351">    ctx_in: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1352">    ctx_out: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1353">};</span>
<span class="line" id="L1354"></span>
<span class="line" id="L1355"><span class="tok-comment">/// struct used by Cmd.*_get_*_id commands</span></span>
<span class="line" id="L1356"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetIdAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1357">    id: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L1358">        start_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1359">        prog_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1360">        map_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1361">        btf_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1362">        link_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1363">    },</span>
<span class="line" id="L1364">    next_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1365">    open_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1366">};</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368"><span class="tok-comment">/// struct used by Cmd.obj_get_info_by_fd command</span></span>
<span class="line" id="L1369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InfoAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1370">    bpf_fd: fd_t,</span>
<span class="line" id="L1371">    info_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1372">    info: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1373">};</span>
<span class="line" id="L1374"></span>
<span class="line" id="L1375"><span class="tok-comment">/// struct used by Cmd.prog_query command</span></span>
<span class="line" id="L1376"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QueryAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1377">    <span class="tok-comment">/// container object to query</span></span>
<span class="line" id="L1378">    target_fd: fd_t,</span>
<span class="line" id="L1379">    attach_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1380">    query_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1381">    attach_flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1382">    prog_ids: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1383">    prog_cnt: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1384">};</span>
<span class="line" id="L1385"></span>
<span class="line" id="L1386"><span class="tok-comment">/// struct used by Cmd.raw_tracepoint_open command</span></span>
<span class="line" id="L1387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RawTracepointAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1388">    name: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1389">    prog_fd: fd_t,</span>
<span class="line" id="L1390">};</span>
<span class="line" id="L1391"></span>
<span class="line" id="L1392"><span class="tok-comment">/// struct used by Cmd.btf_load command</span></span>
<span class="line" id="L1393"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BtfLoadAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1394">    btf: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1395">    btf_log_buf: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1396">    btf_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1397">    btf_log_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1398">    btf_log_level: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1399">};</span>
<span class="line" id="L1400"></span>
<span class="line" id="L1401"><span class="tok-comment">/// struct used by Cmd.task_fd_query</span></span>
<span class="line" id="L1402"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TaskFdQueryAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1403">    <span class="tok-comment">/// input: pid</span></span>
<span class="line" id="L1404">    pid: pid_t,</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">    <span class="tok-comment">/// input: fd</span></span>
<span class="line" id="L1407">    fd: fd_t,</span>
<span class="line" id="L1408"></span>
<span class="line" id="L1409">    <span class="tok-comment">/// input: flags</span></span>
<span class="line" id="L1410">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1411"></span>
<span class="line" id="L1412">    <span class="tok-comment">/// input/output: buf len</span></span>
<span class="line" id="L1413">    buf_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1414"></span>
<span class="line" id="L1415">    <span class="tok-comment">/// input/output:</span></span>
<span class="line" id="L1416">    <span class="tok-comment">///     tp_name for tracepoint</span></span>
<span class="line" id="L1417">    <span class="tok-comment">///     symbol for kprobe</span></span>
<span class="line" id="L1418">    <span class="tok-comment">///     filename for uprobe</span></span>
<span class="line" id="L1419">    buf: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1420"></span>
<span class="line" id="L1421">    <span class="tok-comment">/// output: prod_id</span></span>
<span class="line" id="L1422">    prog_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1423"></span>
<span class="line" id="L1424">    <span class="tok-comment">/// output: BPF_FD_TYPE</span></span>
<span class="line" id="L1425">    fd_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1426"></span>
<span class="line" id="L1427">    <span class="tok-comment">/// output: probe_offset</span></span>
<span class="line" id="L1428">    probe_offset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1429"></span>
<span class="line" id="L1430">    <span class="tok-comment">/// output: probe_addr</span></span>
<span class="line" id="L1431">    probe_addr: <span class="tok-type">u64</span>,</span>
<span class="line" id="L1432">};</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434"><span class="tok-comment">/// struct used by Cmd.link_create command</span></span>
<span class="line" id="L1435"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkCreateAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1436">    <span class="tok-comment">/// eBPF program to attach</span></span>
<span class="line" id="L1437">    prog_fd: fd_t,</span>
<span class="line" id="L1438"></span>
<span class="line" id="L1439">    <span class="tok-comment">/// object to attach to</span></span>
<span class="line" id="L1440">    target_fd: fd_t,</span>
<span class="line" id="L1441">    attach_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1442"></span>
<span class="line" id="L1443">    <span class="tok-comment">/// extra flags</span></span>
<span class="line" id="L1444">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1445">};</span>
<span class="line" id="L1446"></span>
<span class="line" id="L1447"><span class="tok-comment">/// struct used by Cmd.link_update command</span></span>
<span class="line" id="L1448"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkUpdateAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1449">    link_fd: fd_t,</span>
<span class="line" id="L1450"></span>
<span class="line" id="L1451">    <span class="tok-comment">/// new program to update link with</span></span>
<span class="line" id="L1452">    new_prog_fd: fd_t,</span>
<span class="line" id="L1453"></span>
<span class="line" id="L1454">    <span class="tok-comment">/// extra flags</span></span>
<span class="line" id="L1455">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1456"></span>
<span class="line" id="L1457">    <span class="tok-comment">/// expected link's program fd, it is specified only if BPF_F_REPLACE is</span></span>
<span class="line" id="L1458">    <span class="tok-comment">/// set in flags</span></span>
<span class="line" id="L1459">    old_prog_fd: fd_t,</span>
<span class="line" id="L1460">};</span>
<span class="line" id="L1461"></span>
<span class="line" id="L1462"><span class="tok-comment">/// struct used by Cmd.enable_stats command</span></span>
<span class="line" id="L1463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnableStatsAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1464">    <span class="tok-type">type</span>: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1465">};</span>
<span class="line" id="L1466"></span>
<span class="line" id="L1467"><span class="tok-comment">/// struct used by Cmd.iter_create command</span></span>
<span class="line" id="L1468"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IterCreateAttr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1469">    link_fd: fd_t,</span>
<span class="line" id="L1470">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1471">};</span>
<span class="line" id="L1472"></span>
<span class="line" id="L1473"><span class="tok-comment">/// Mega struct that is passed to the bpf() syscall</span></span>
<span class="line" id="L1474"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Attr = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L1475">    map_create: MapCreateAttr,</span>
<span class="line" id="L1476">    map_elem: MapElemAttr,</span>
<span class="line" id="L1477">    map_batch: MapBatchAttr,</span>
<span class="line" id="L1478">    prog_load: ProgLoadAttr,</span>
<span class="line" id="L1479">    obj: ObjAttr,</span>
<span class="line" id="L1480">    prog_attach: ProgAttachAttr,</span>
<span class="line" id="L1481">    test_run: TestRunAttr,</span>
<span class="line" id="L1482">    get_id: GetIdAttr,</span>
<span class="line" id="L1483">    info: InfoAttr,</span>
<span class="line" id="L1484">    query: QueryAttr,</span>
<span class="line" id="L1485">    raw_tracepoint: RawTracepointAttr,</span>
<span class="line" id="L1486">    btf_load: BtfLoadAttr,</span>
<span class="line" id="L1487">    task_fd_query: TaskFdQueryAttr,</span>
<span class="line" id="L1488">    link_create: LinkCreateAttr,</span>
<span class="line" id="L1489">    link_update: LinkUpdateAttr,</span>
<span class="line" id="L1490">    enable_stats: EnableStatsAttr,</span>
<span class="line" id="L1491">    iter_create: IterCreateAttr,</span>
<span class="line" id="L1492">};</span>
<span class="line" id="L1493"></span>
<span class="line" id="L1494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Log = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1495">    level: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1496">    buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L1497">};</span>
<span class="line" id="L1498"></span>
<span class="line" id="L1499"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">map_create</span>(map_type: MapType, key_size: <span class="tok-type">u32</span>, value_size: <span class="tok-type">u32</span>, max_entries: <span class="tok-type">u32</span>) !fd_t {</span>
<span class="line" id="L1500">    <span class="tok-kw">var</span> attr = Attr{</span>
<span class="line" id="L1501">        .map_create = std.mem.zeroes(MapCreateAttr),</span>
<span class="line" id="L1502">    };</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">    attr.map_create.map_type = <span class="tok-builtin">@enumToInt</span>(map_type);</span>
<span class="line" id="L1505">    attr.map_create.key_size = key_size;</span>
<span class="line" id="L1506">    attr.map_create.value_size = value_size;</span>
<span class="line" id="L1507">    attr.map_create.max_entries = max_entries;</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">    <span class="tok-kw">const</span> rc = linux.bpf(.map_create, &amp;attr, <span class="tok-builtin">@sizeOf</span>(MapCreateAttr));</span>
<span class="line" id="L1510">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1511">        .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L1512">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MapTypeOrAttrInvalid,</span>
<span class="line" id="L1513">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1514">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1515">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1516">    }</span>
<span class="line" id="L1517">}</span>
<span class="line" id="L1518"></span>
<span class="line" id="L1519"><span class="tok-kw">test</span> <span class="tok-str">&quot;map_create&quot;</span> {</span>
<span class="line" id="L1520">    <span class="tok-kw">const</span> map = <span class="tok-kw">try</span> map_create(.hash, <span class="tok-number">4</span>, <span class="tok-number">4</span>, <span class="tok-number">32</span>);</span>
<span class="line" id="L1521">    <span class="tok-kw">defer</span> std.os.close(map);</span>
<span class="line" id="L1522">}</span>
<span class="line" id="L1523"></span>
<span class="line" id="L1524"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">map_lookup_elem</span>(fd: fd_t, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1525">    <span class="tok-kw">var</span> attr = Attr{</span>
<span class="line" id="L1526">        .map_elem = std.mem.zeroes(MapElemAttr),</span>
<span class="line" id="L1527">    };</span>
<span class="line" id="L1528"></span>
<span class="line" id="L1529">    attr.map_elem.map_fd = fd;</span>
<span class="line" id="L1530">    attr.map_elem.key = <span class="tok-builtin">@ptrToInt</span>(key.ptr);</span>
<span class="line" id="L1531">    attr.map_elem.result.value = <span class="tok-builtin">@ptrToInt</span>(value.ptr);</span>
<span class="line" id="L1532"></span>
<span class="line" id="L1533">    <span class="tok-kw">const</span> rc = linux.bpf(.map_lookup_elem, &amp;attr, <span class="tok-builtin">@sizeOf</span>(MapElemAttr));</span>
<span class="line" id="L1534">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1535">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1536">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadFd,</span>
<span class="line" id="L1537">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1538">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FieldInAttrNeedsZeroing,</span>
<span class="line" id="L1539">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotFound,</span>
<span class="line" id="L1540">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1541">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1542">    }</span>
<span class="line" id="L1543">}</span>
<span class="line" id="L1544"></span>
<span class="line" id="L1545"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">map_update_elem</span>(fd: fd_t, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u64</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1546">    <span class="tok-kw">var</span> attr = Attr{</span>
<span class="line" id="L1547">        .map_elem = std.mem.zeroes(MapElemAttr),</span>
<span class="line" id="L1548">    };</span>
<span class="line" id="L1549"></span>
<span class="line" id="L1550">    attr.map_elem.map_fd = fd;</span>
<span class="line" id="L1551">    attr.map_elem.key = <span class="tok-builtin">@ptrToInt</span>(key.ptr);</span>
<span class="line" id="L1552">    attr.map_elem.result = .{ .value = <span class="tok-builtin">@ptrToInt</span>(value.ptr) };</span>
<span class="line" id="L1553">    attr.map_elem.flags = flags;</span>
<span class="line" id="L1554"></span>
<span class="line" id="L1555">    <span class="tok-kw">const</span> rc = linux.bpf(.map_update_elem, &amp;attr, <span class="tok-builtin">@sizeOf</span>(MapElemAttr));</span>
<span class="line" id="L1556">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1557">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1558">        .@&quot;2BIG&quot; =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ReachedMaxEntries,</span>
<span class="line" id="L1559">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadFd,</span>
<span class="line" id="L1560">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1561">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FieldInAttrNeedsZeroing,</span>
<span class="line" id="L1562">        .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L1563">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1564">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1565">    }</span>
<span class="line" id="L1566">}</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">map_delete_elem</span>(fd: fd_t, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1569">    <span class="tok-kw">var</span> attr = Attr{</span>
<span class="line" id="L1570">        .map_elem = std.mem.zeroes(MapElemAttr),</span>
<span class="line" id="L1571">    };</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573">    attr.map_elem.map_fd = fd;</span>
<span class="line" id="L1574">    attr.map_elem.key = <span class="tok-builtin">@ptrToInt</span>(key.ptr);</span>
<span class="line" id="L1575"></span>
<span class="line" id="L1576">    <span class="tok-kw">const</span> rc = linux.bpf(.map_delete_elem, &amp;attr, <span class="tok-builtin">@sizeOf</span>(MapElemAttr));</span>
<span class="line" id="L1577">    <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1578">        .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L1579">        .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BadFd,</span>
<span class="line" id="L1580">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1581">        .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FieldInAttrNeedsZeroing,</span>
<span class="line" id="L1582">        .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotFound,</span>
<span class="line" id="L1583">        .PERM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1584">        <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L1585">    }</span>
<span class="line" id="L1586">}</span>
<span class="line" id="L1587"></span>
<span class="line" id="L1588"><span class="tok-kw">test</span> <span class="tok-str">&quot;map lookup, update, and delete&quot;</span> {</span>
<span class="line" id="L1589">    <span class="tok-kw">const</span> key_size = <span class="tok-number">4</span>;</span>
<span class="line" id="L1590">    <span class="tok-kw">const</span> value_size = <span class="tok-number">4</span>;</span>
<span class="line" id="L1591">    <span class="tok-kw">const</span> map = <span class="tok-kw">try</span> map_create(.hash, key_size, value_size, <span class="tok-number">1</span>);</span>
<span class="line" id="L1592">    <span class="tok-kw">defer</span> std.os.close(map);</span>
<span class="line" id="L1593"></span>
<span class="line" id="L1594">    <span class="tok-kw">const</span> key = std.mem.zeroes([key_size]<span class="tok-type">u8</span>);</span>
<span class="line" id="L1595">    <span class="tok-kw">var</span> value = std.mem.zeroes([value_size]<span class="tok-type">u8</span>);</span>
<span class="line" id="L1596"></span>
<span class="line" id="L1597">    <span class="tok-comment">// fails looking up value that doesn't exist</span>
</span>
<span class="line" id="L1598">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.NotFound, map_lookup_elem(map, &amp;key, &amp;value));</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600">    <span class="tok-comment">// succeed at updating and looking up element</span>
</span>
<span class="line" id="L1601">    <span class="tok-kw">try</span> map_update_elem(map, &amp;key, &amp;value, <span class="tok-number">0</span>);</span>
<span class="line" id="L1602">    <span class="tok-kw">try</span> map_lookup_elem(map, &amp;key, &amp;value);</span>
<span class="line" id="L1603"></span>
<span class="line" id="L1604">    <span class="tok-comment">// fails inserting more than max entries</span>
</span>
<span class="line" id="L1605">    <span class="tok-kw">const</span> second_key = [key_size]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L1606">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.ReachedMaxEntries, map_update_elem(map, &amp;second_key, &amp;value, <span class="tok-number">0</span>));</span>
<span class="line" id="L1607"></span>
<span class="line" id="L1608">    <span class="tok-comment">// succeed at deleting an existing elem</span>
</span>
<span class="line" id="L1609">    <span class="tok-kw">try</span> map_delete_elem(map, &amp;key);</span>
<span class="line" id="L1610">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.NotFound, map_lookup_elem(map, &amp;key, &amp;value));</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612">    <span class="tok-comment">// fail at deleting a non-existing elem</span>
</span>
<span class="line" id="L1613">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.NotFound, map_delete_elem(map, &amp;key));</span>
<span class="line" id="L1614">}</span>
<span class="line" id="L1615"></span>
<span class="line" id="L1616"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">prog_load</span>(</span>
<span class="line" id="L1617">    prog_type: ProgType,</span>
<span class="line" id="L1618">    insns: []<span class="tok-kw">const</span> Insn,</span>
<span class="line" id="L1619">    log: ?*Log,</span>
<span class="line" id="L1620">    license: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1621">    kern_version: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1622">) !fd_t {</span>
<span class="line" id="L1623">    <span class="tok-kw">var</span> attr = Attr{</span>
<span class="line" id="L1624">        .prog_load = std.mem.zeroes(ProgLoadAttr),</span>
<span class="line" id="L1625">    };</span>
<span class="line" id="L1626"></span>
<span class="line" id="L1627">    attr.prog_load.prog_type = <span class="tok-builtin">@enumToInt</span>(prog_type);</span>
<span class="line" id="L1628">    attr.prog_load.insns = <span class="tok-builtin">@ptrToInt</span>(insns.ptr);</span>
<span class="line" id="L1629">    attr.prog_load.insn_cnt = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, insns.len);</span>
<span class="line" id="L1630">    attr.prog_load.license = <span class="tok-builtin">@ptrToInt</span>(license.ptr);</span>
<span class="line" id="L1631">    attr.prog_load.kern_version = kern_version;</span>
<span class="line" id="L1632"></span>
<span class="line" id="L1633">    <span class="tok-kw">if</span> (log) |l| {</span>
<span class="line" id="L1634">        attr.prog_load.log_buf = <span class="tok-builtin">@ptrToInt</span>(l.buf.ptr);</span>
<span class="line" id="L1635">        attr.prog_load.log_size = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, l.buf.len);</span>
<span class="line" id="L1636">        attr.prog_load.log_level = l.level;</span>
<span class="line" id="L1637">    }</span>
<span class="line" id="L1638"></span>
<span class="line" id="L1639">    <span class="tok-kw">const</span> rc = linux.bpf(.prog_load, &amp;attr, <span class="tok-builtin">@sizeOf</span>(ProgLoadAttr));</span>
<span class="line" id="L1640">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L1641">        .SUCCESS =&gt; <span class="tok-builtin">@intCast</span>(fd_t, rc),</span>
<span class="line" id="L1642">        .ACCES =&gt; <span class="tok-kw">error</span>.UnsafeProgram,</span>
<span class="line" id="L1643">        .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1644">        .INVAL =&gt; <span class="tok-kw">error</span>.InvalidProgram,</span>
<span class="line" id="L1645">        .PERM =&gt; <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L1646">        <span class="tok-kw">else</span> =&gt; |err| unexpectedErrno(err),</span>
<span class="line" id="L1647">    };</span>
<span class="line" id="L1648">}</span>
<span class="line" id="L1649"></span>
<span class="line" id="L1650"><span class="tok-kw">test</span> <span class="tok-str">&quot;prog_load&quot;</span> {</span>
<span class="line" id="L1651">    <span class="tok-comment">// this should fail because it does not set r0 before exiting</span>
</span>
<span class="line" id="L1652">    <span class="tok-kw">const</span> bad_prog = [_]Insn{</span>
<span class="line" id="L1653">        Insn.exit(),</span>
<span class="line" id="L1654">    };</span>
<span class="line" id="L1655"></span>
<span class="line" id="L1656">    <span class="tok-kw">const</span> good_prog = [_]Insn{</span>
<span class="line" id="L1657">        Insn.mov(.r0, <span class="tok-number">0</span>),</span>
<span class="line" id="L1658">        Insn.exit(),</span>
<span class="line" id="L1659">    };</span>
<span class="line" id="L1660"></span>
<span class="line" id="L1661">    <span class="tok-kw">const</span> prog = <span class="tok-kw">try</span> prog_load(.socket_filter, &amp;good_prog, <span class="tok-null">null</span>, <span class="tok-str">&quot;MIT&quot;</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1662">    <span class="tok-kw">defer</span> std.os.close(prog);</span>
<span class="line" id="L1663"></span>
<span class="line" id="L1664">    <span class="tok-kw">try</span> expectError(<span class="tok-kw">error</span>.UnsafeProgram, prog_load(.socket_filter, &amp;bad_prog, <span class="tok-null">null</span>, <span class="tok-str">&quot;MIT&quot;</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L1665">}</span>
<span class="line" id="L1666"></span>
</code></pre></body>
</html>