<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>x/net/bpf.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This package provides instrumentation for creating Berkeley Packet Filter[1]</span></span>
<span class="line" id="L2"><span class="tok-comment">//! (BPF) programs, along with a simulator for running them.</span></span>
<span class="line" id="L3"><span class="tok-comment">//!</span></span>
<span class="line" id="L4"><span class="tok-comment">//! BPF is a mechanism for cheap, in-kernel packet filtering. Programs are</span></span>
<span class="line" id="L5"><span class="tok-comment">//! attached to a network device and executed for every packet that flows</span></span>
<span class="line" id="L6"><span class="tok-comment">//! through it. The program must then return a verdict: the amount of packet</span></span>
<span class="line" id="L7"><span class="tok-comment">//! bytes that the kernel should copy into userspace. Execution speed is</span></span>
<span class="line" id="L8"><span class="tok-comment">//! achieved by having programs run in a limited virtual machine, which has the</span></span>
<span class="line" id="L9"><span class="tok-comment">//! added benefit of graceful failure in the face of buggy programs.</span></span>
<span class="line" id="L10"><span class="tok-comment">//!</span></span>
<span class="line" id="L11"><span class="tok-comment">//! The BPF virtual machine has a 32-bit word length and a small number of</span></span>
<span class="line" id="L12"><span class="tok-comment">//! word-sized registers:</span></span>
<span class="line" id="L13"><span class="tok-comment">//!</span></span>
<span class="line" id="L14"><span class="tok-comment">//! - The accumulator, `a`: The source/destination of arithmetic and logic</span></span>
<span class="line" id="L15"><span class="tok-comment">//!   operations.</span></span>
<span class="line" id="L16"><span class="tok-comment">//! - The index register, `x`: Used as an offset for indirect memory access and</span></span>
<span class="line" id="L17"><span class="tok-comment">//!   as a comparison value for conditional jumps.</span></span>
<span class="line" id="L18"><span class="tok-comment">//! - The scratch memory store, `M[0]..M[15]`: Used for saving the value of a/x</span></span>
<span class="line" id="L19"><span class="tok-comment">//!   for later use.</span></span>
<span class="line" id="L20"><span class="tok-comment">//!</span></span>
<span class="line" id="L21"><span class="tok-comment">//! The packet being examined is an array of bytes, and is addressed using plain</span></span>
<span class="line" id="L22"><span class="tok-comment">//! array subscript notation, e.g. [10] for the byte at offset 10. An implicit</span></span>
<span class="line" id="L23"><span class="tok-comment">//! program counter, `pc`, is intialized to zero and incremented for each instruction.</span></span>
<span class="line" id="L24"><span class="tok-comment">//!</span></span>
<span class="line" id="L25"><span class="tok-comment">//! The machine has a fixed instruction set with the following form, where the</span></span>
<span class="line" id="L26"><span class="tok-comment">//! numbers represent bit length:</span></span>
<span class="line" id="L27"><span class="tok-comment">//!</span></span>
<span class="line" id="L28"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L29"><span class="tok-comment">//! ┌───────────┬──────┬──────┐</span></span>
<span class="line" id="L30"><span class="tok-comment">//! │ opcode:16 │ jt:8 │ jt:8 │</span></span>
<span class="line" id="L31"><span class="tok-comment">//! ├───────────┴──────┴──────┤</span></span>
<span class="line" id="L32"><span class="tok-comment">//! │           k:32          │</span></span>
<span class="line" id="L33"><span class="tok-comment">//! └─────────────────────────┘</span></span>
<span class="line" id="L34"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L35"><span class="tok-comment">//!</span></span>
<span class="line" id="L36"><span class="tok-comment">//! The `opcode` indicates the instruction class and its addressing mode.</span></span>
<span class="line" id="L37"><span class="tok-comment">//! Opcodes are generated by performing binary addition on the 8-bit class and</span></span>
<span class="line" id="L38"><span class="tok-comment">//! mode constants. For example, the opcode for loading a byte from the packet</span></span>
<span class="line" id="L39"><span class="tok-comment">//! at X + 2, (`ldb [x + 2]`), is:</span></span>
<span class="line" id="L40"><span class="tok-comment">//!</span></span>
<span class="line" id="L41"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L42"><span class="tok-comment">//! LD | IND | B = 0x00 | 0x40 | 0x20</span></span>
<span class="line" id="L43"><span class="tok-comment">//!              = 0x60</span></span>
<span class="line" id="L44"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L45"><span class="tok-comment">//!</span></span>
<span class="line" id="L46"><span class="tok-comment">//! `jt` is an offset used for conditional jumps, and increments the program</span></span>
<span class="line" id="L47"><span class="tok-comment">//! counter by its amount if the comparison was true. Conversely, `jf`</span></span>
<span class="line" id="L48"><span class="tok-comment">//! increments the counter if it was false. These fields are ignored in all</span></span>
<span class="line" id="L49"><span class="tok-comment">//! other cases. `k` is a generic variable used for various purposes, most</span></span>
<span class="line" id="L50"><span class="tok-comment">//! commonly as some sort of constant.</span></span>
<span class="line" id="L51"><span class="tok-comment">//!</span></span>
<span class="line" id="L52"><span class="tok-comment">//! This package contains opcode extensions used by different implementations,</span></span>
<span class="line" id="L53"><span class="tok-comment">//! where &quot;extension&quot; is anything outside of the original that was imported into</span></span>
<span class="line" id="L54"><span class="tok-comment">//! 4.4BSD[2]. These are marked with &quot;EXTENSION&quot;, along with a list of</span></span>
<span class="line" id="L55"><span class="tok-comment">//! implementations that use them.</span></span>
<span class="line" id="L56"><span class="tok-comment">//!</span></span>
<span class="line" id="L57"><span class="tok-comment">//! Most of the doc-comments use the BPF assembly syntax as described in the</span></span>
<span class="line" id="L58"><span class="tok-comment">//! original paper[1]. For the sake of completeness, here is the complete</span></span>
<span class="line" id="L59"><span class="tok-comment">//! instruction set, along with the extensions:</span></span>
<span class="line" id="L60"><span class="tok-comment">//!</span></span>
<span class="line" id="L61"><span class="tok-comment">//!```</span></span>
<span class="line" id="L62"><span class="tok-comment">//! opcode  addressing modes</span></span>
<span class="line" id="L63"><span class="tok-comment">//! ld      #k  #len    M[k]    [k]     [x + k]</span></span>
<span class="line" id="L64"><span class="tok-comment">//! ldh     [k] [x + k]</span></span>
<span class="line" id="L65"><span class="tok-comment">//! ldb     [k] [x + k]</span></span>
<span class="line" id="L66"><span class="tok-comment">//! ldx     #k  #len    M[k]    4 * ([k] &amp; 0xf) arc4random()</span></span>
<span class="line" id="L67"><span class="tok-comment">//! st      M[k]</span></span>
<span class="line" id="L68"><span class="tok-comment">//! stx     M[k]</span></span>
<span class="line" id="L69"><span class="tok-comment">//! jmp     L</span></span>
<span class="line" id="L70"><span class="tok-comment">//! jeq     #k, Lt, Lf</span></span>
<span class="line" id="L71"><span class="tok-comment">//! jgt     #k, Lt, Lf</span></span>
<span class="line" id="L72"><span class="tok-comment">//! jge     #k, Lt, Lf</span></span>
<span class="line" id="L73"><span class="tok-comment">//! jset    #k, Lt, Lf</span></span>
<span class="line" id="L74"><span class="tok-comment">//! add     #k  x</span></span>
<span class="line" id="L75"><span class="tok-comment">//! sub     #k  x</span></span>
<span class="line" id="L76"><span class="tok-comment">//! mul     #k  x</span></span>
<span class="line" id="L77"><span class="tok-comment">//! div     #k  x</span></span>
<span class="line" id="L78"><span class="tok-comment">//! or      #k  x</span></span>
<span class="line" id="L79"><span class="tok-comment">//! and     #k  x</span></span>
<span class="line" id="L80"><span class="tok-comment">//! lsh     #k  x</span></span>
<span class="line" id="L81"><span class="tok-comment">//! rsh     #k  x</span></span>
<span class="line" id="L82"><span class="tok-comment">//! neg     #k  x</span></span>
<span class="line" id="L83"><span class="tok-comment">//! mod     #k  x</span></span>
<span class="line" id="L84"><span class="tok-comment">//! xor     #k  x</span></span>
<span class="line" id="L85"><span class="tok-comment">//! ret     #k  a</span></span>
<span class="line" id="L86"><span class="tok-comment">//! tax</span></span>
<span class="line" id="L87"><span class="tok-comment">//! txa</span></span>
<span class="line" id="L88"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L89"><span class="tok-comment">//!</span></span>
<span class="line" id="L90"><span class="tok-comment">//! Finally, a note on program design. The lack of backwards jumps leads to a</span></span>
<span class="line" id="L91"><span class="tok-comment">//! &quot;return early, return often&quot; control flow. Take for example the program</span></span>
<span class="line" id="L92"><span class="tok-comment">//! generated from the tcpdump filter `ip`:</span></span>
<span class="line" id="L93"><span class="tok-comment">//!</span></span>
<span class="line" id="L94"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L95"><span class="tok-comment">//! (000) ldh   [12]            ; Ethernet Packet Type</span></span>
<span class="line" id="L96"><span class="tok-comment">//! (001) jeq   #0x86dd, 2, 7   ; ETHERTYPE_IPV6</span></span>
<span class="line" id="L97"><span class="tok-comment">//! (002) ldb   [20]            ; IPv6 Next Header</span></span>
<span class="line" id="L98"><span class="tok-comment">//! (003) jeq   #0x6, 10, 4     ; TCP</span></span>
<span class="line" id="L99"><span class="tok-comment">//! (004) jeq   #0x2c, 5, 11    ; IPv6 Fragment Header</span></span>
<span class="line" id="L100"><span class="tok-comment">//! (005) ldb   [54]            ; TCP Source Port</span></span>
<span class="line" id="L101"><span class="tok-comment">//! (006) jeq   #0x6, 10, 11    ; IPPROTO_TCP</span></span>
<span class="line" id="L102"><span class="tok-comment">//! (007) jeq   #0x800, 8, 11   ; ETHERTYPE_IP</span></span>
<span class="line" id="L103"><span class="tok-comment">//! (008) ldb   [23]            ; IPv4 Protocol</span></span>
<span class="line" id="L104"><span class="tok-comment">//! (009) jeq   #0x6, 10, 11    ; IPPROTO_TCP</span></span>
<span class="line" id="L105"><span class="tok-comment">//! (010) ret   #262144         ; copy 0x40000</span></span>
<span class="line" id="L106"><span class="tok-comment">//! (011) ret   #0              ; skip packet</span></span>
<span class="line" id="L107"><span class="tok-comment">//! ```</span></span>
<span class="line" id="L108"><span class="tok-comment">//!</span></span>
<span class="line" id="L109"><span class="tok-comment">//! Here we can make a few observations:</span></span>
<span class="line" id="L110"><span class="tok-comment">//!</span></span>
<span class="line" id="L111"><span class="tok-comment">//! - The problem &quot;filter only tcp packets&quot; has essentially been transformed</span></span>
<span class="line" id="L112"><span class="tok-comment">//!   into a series of layer checks.</span></span>
<span class="line" id="L113"><span class="tok-comment">//! - There are two distinct branches in the code, one for validating IPv4</span></span>
<span class="line" id="L114"><span class="tok-comment">//!   headers and one for IPv6 headers.</span></span>
<span class="line" id="L115"><span class="tok-comment">//! - Most conditional jumps in these branches lead directly to the last two</span></span>
<span class="line" id="L116"><span class="tok-comment">//!   instructions, a pass or fail. Thus the goal of a program is to find the</span></span>
<span class="line" id="L117"><span class="tok-comment">//!   fastest route to a pass/fail comparison.</span></span>
<span class="line" id="L118"><span class="tok-comment">//!</span></span>
<span class="line" id="L119"><span class="tok-comment">//! [1]: S. McCanne and V. Jacobson, &quot;The BSD Packet Filter: A New Architecture</span></span>
<span class="line" id="L120"><span class="tok-comment">//!      for User-level Packet Capture&quot;, Proceedings of the 1993 Winter USENIX.</span></span>
<span class="line" id="L121"><span class="tok-comment">//! [2]: https://minnie.tuhs.org/cgi-bin/utree.pl?file=4.4BSD/usr/src/sys/net/bpf.h</span></span>
<span class="line" id="L122"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L123"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L124"><span class="tok-kw">const</span> native_endian = builtin.target.cpu.arch.endian();</span>
<span class="line" id="L125"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L126"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L127"><span class="tok-kw">const</span> random = std.crypto.random;</span>
<span class="line" id="L128"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L129"><span class="tok-kw">const</span> expectEqual = std.testing.expectEqual;</span>
<span class="line" id="L130"><span class="tok-kw">const</span> expectError = std.testing.expectError;</span>
<span class="line" id="L131"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L132"></span>
<span class="line" id="L133"><span class="tok-comment">// instruction classes</span>
</span>
<span class="line" id="L134"><span class="tok-comment">/// ld, ldh, ldb: Load data into a.</span></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LD = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L136"><span class="tok-comment">/// ldx: Load data into x.</span></span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LDX = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L138"><span class="tok-comment">/// st:  Store into scratch memory the value of a.</span></span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ST = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L140"><span class="tok-comment">/// st:  Store into scratch memory the value of x.</span></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STX = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L142"><span class="tok-comment">/// alu: Wrapping arithmetic/bitwise operations on a using the value of k/x.</span></span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALU = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L144"><span class="tok-comment">/// jmp, jeq, jgt, je, jset: Increment the program counter based on a comparison</span></span>
<span class="line" id="L145"><span class="tok-comment">/// between k/x and the accumulator.</span></span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JMP = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L147"><span class="tok-comment">/// ret: Return a verdict using the value of k/the accumulator.</span></span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RET = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L149"><span class="tok-comment">/// tax, txa: Register value copying between X and a.</span></span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MISC = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-comment">// Size of data to be loaded from the packet.</span>
</span>
<span class="line" id="L153"><span class="tok-comment">/// ld: 32-bit full word.</span></span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L155"><span class="tok-comment">/// ldh: 16-bit half word.</span></span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> H = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L157"><span class="tok-comment">/// ldb: Single byte.</span></span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> B = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L159"></span>
<span class="line" id="L160"><span class="tok-comment">// Addressing modes used for loads to a/x.</span>
</span>
<span class="line" id="L161"><span class="tok-comment">/// #k: The immediate value stored in k.</span></span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMM = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L163"><span class="tok-comment">/// [k]: The value at offset k in the packet.</span></span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ABS = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L165"><span class="tok-comment">/// [x + k]: The value at offset x + k in the packet.</span></span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IND = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L167"><span class="tok-comment">/// M[k]: The value of the k'th scratch memory register.</span></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEM = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L169"><span class="tok-comment">/// #len: The size of the packet.</span></span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LEN = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L171"><span class="tok-comment">/// 4 * ([k] &amp; 0xf): Four times the low four bits of the byte at offset k in the</span></span>
<span class="line" id="L172"><span class="tok-comment">/// packet. This is used for efficiently loading the header length of an IP</span></span>
<span class="line" id="L173"><span class="tok-comment">/// packet.</span></span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSH = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L175"><span class="tok-comment">/// arc4random: 32-bit integer generated from a CPRNG (see arc4random(3)) loaded into a.</span></span>
<span class="line" id="L176"><span class="tok-comment">/// EXTENSION. Defined for:</span></span>
<span class="line" id="L177"><span class="tok-comment">/// - OpenBSD.</span></span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RND = <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-comment">// Modifiers for different instruction classes.</span>
</span>
<span class="line" id="L181"><span class="tok-comment">/// Use the value of k for alu operations (add #k).</span></span>
<span class="line" id="L182"><span class="tok-comment">/// Compare against the value of k for jumps (jeq #k, Lt, Lf).</span></span>
<span class="line" id="L183"><span class="tok-comment">/// Return the value of k for returns (ret #k).</span></span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> K = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L185"><span class="tok-comment">/// Use the value of x for alu operations (add x).</span></span>
<span class="line" id="L186"><span class="tok-comment">/// Compare against the value of X for jumps (jeq x, Lt, Lf).</span></span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> X = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L188"><span class="tok-comment">/// Return the value of a for returns (ret a).</span></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> A = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L190"></span>
<span class="line" id="L191"><span class="tok-comment">// ALU Operations on a using the value of k/x.</span>
</span>
<span class="line" id="L192"><span class="tok-comment">// All arithmetic operations are defined to overflow the value of a.</span>
</span>
<span class="line" id="L193"><span class="tok-comment">/// add: a = a + k</span></span>
<span class="line" id="L194"><span class="tok-comment">///      a = a + x.</span></span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADD = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L196"><span class="tok-comment">/// sub: a = a - k</span></span>
<span class="line" id="L197"><span class="tok-comment">///      a = a - x.</span></span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUB = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L199"><span class="tok-comment">/// mul: a = a * k</span></span>
<span class="line" id="L200"><span class="tok-comment">///      a = a * x.</span></span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MUL = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L202"><span class="tok-comment">/// div: a = a / k</span></span>
<span class="line" id="L203"><span class="tok-comment">///      a = a / x.</span></span>
<span class="line" id="L204"><span class="tok-comment">/// Truncated division.</span></span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIV = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L206"><span class="tok-comment">/// or:  a = a | k</span></span>
<span class="line" id="L207"><span class="tok-comment">///      a = a | x.</span></span>
<span class="line" id="L208"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OR = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L209"><span class="tok-comment">/// and: a = a &amp; k</span></span>
<span class="line" id="L210"><span class="tok-comment">///      a = a &amp; x.</span></span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AND = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L212"><span class="tok-comment">/// lsh: a = a &lt;&lt; k</span></span>
<span class="line" id="L213"><span class="tok-comment">///      a = a &lt;&lt; x.</span></span>
<span class="line" id="L214"><span class="tok-comment">/// a = a &lt;&lt; k, a = a &lt;&lt; x.</span></span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSH = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L216"><span class="tok-comment">/// rsh: a = a &gt;&gt; k</span></span>
<span class="line" id="L217"><span class="tok-comment">///      a = a &gt;&gt; x.</span></span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RSH = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L219"><span class="tok-comment">/// neg: a = -a.</span></span>
<span class="line" id="L220"><span class="tok-comment">/// Note that this isn't a binary negation, rather the value of `~a + 1`.</span></span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEG = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L222"><span class="tok-comment">/// mod: a = a % k</span></span>
<span class="line" id="L223"><span class="tok-comment">///      a = a % x.</span></span>
<span class="line" id="L224"><span class="tok-comment">/// EXTENSION. Defined for:</span></span>
<span class="line" id="L225"><span class="tok-comment">///  - Linux.</span></span>
<span class="line" id="L226"><span class="tok-comment">///  - NetBSD + Minix 3.</span></span>
<span class="line" id="L227"><span class="tok-comment">///  - FreeBSD and derivitives.</span></span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOD = <span class="tok-number">0x90</span>;</span>
<span class="line" id="L229"><span class="tok-comment">/// xor: a = a ^ k</span></span>
<span class="line" id="L230"><span class="tok-comment">///      a = a ^ x.</span></span>
<span class="line" id="L231"><span class="tok-comment">/// EXTENSION. Defined for:</span></span>
<span class="line" id="L232"><span class="tok-comment">///  - Linux.</span></span>
<span class="line" id="L233"><span class="tok-comment">///  - NetBSD + Minix 3.</span></span>
<span class="line" id="L234"><span class="tok-comment">///  - FreeBSD and derivitives.</span></span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XOR = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-comment">// Jump operations using a comparison between a and x/k.</span>
</span>
<span class="line" id="L238"><span class="tok-comment">/// jmp L: pc += k.</span></span>
<span class="line" id="L239"><span class="tok-comment">/// No comparison done here.</span></span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JA = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L241"><span class="tok-comment">/// jeq    #k, Lt, Lf: pc += (a == k)    ? jt : jf.</span></span>
<span class="line" id="L242"><span class="tok-comment">/// jeq     x, Lt, Lf: pc += (a == x)    ? jt : jf.</span></span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JEQ = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L244"><span class="tok-comment">/// jgt    #k, Lt, Lf: pc += (a &gt;  k)    ? jt : jf.</span></span>
<span class="line" id="L245"><span class="tok-comment">/// jgt     x, Lt, Lf: pc += (a &gt;  x)    ? jt : jf.</span></span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JGT = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L247"><span class="tok-comment">/// jge    #k, Lt, Lf: pc += (a &gt;= k)    ? jt : jf.</span></span>
<span class="line" id="L248"><span class="tok-comment">/// jge     x, Lt, Lf: pc += (a &gt;= x)    ? jt : jf.</span></span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JGE = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L250"><span class="tok-comment">/// jset   #k, Lt, Lf: pc += (a &amp; k &gt; 0) ? jt : jf.</span></span>
<span class="line" id="L251"><span class="tok-comment">/// jset    x, Lt, Lf: pc += (a &amp; x &gt; 0) ? jt : jf.</span></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JSET = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L253"></span>
<span class="line" id="L254"><span class="tok-comment">// Miscellaneous operations/register copy.</span>
</span>
<span class="line" id="L255"><span class="tok-comment">/// tax: x = a.</span></span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAX = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L257"><span class="tok-comment">/// txa: a = x.</span></span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TXA = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L259"></span>
<span class="line" id="L260"><span class="tok-comment">/// The 16 registers in the scratch memory store as named enums.</span></span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Scratch = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) { m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15 };</span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MEMWORDS = <span class="tok-number">16</span>;</span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXINSNS = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L264">    .linux =&gt; <span class="tok-number">4096</span>,</span>
<span class="line" id="L265">    <span class="tok-kw">else</span> =&gt; <span class="tok-number">512</span>,</span>
<span class="line" id="L266">};</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MINBUFSIZE = <span class="tok-number">32</span>;</span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXBUFSIZE = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">21</span>;</span>
<span class="line" id="L269"></span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Insn = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L271">    opcode: <span class="tok-type">u16</span>,</span>
<span class="line" id="L272">    jt: <span class="tok-type">u8</span>,</span>
<span class="line" id="L273">    jf: <span class="tok-type">u8</span>,</span>
<span class="line" id="L274">    k: <span class="tok-type">u32</span>,</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">    <span class="tok-comment">/// Implements the `std.fmt.format` API.</span></span>
<span class="line" id="L277">    <span class="tok-comment">/// The formatting is similar to the output of tcpdump -dd.</span></span>
<span class="line" id="L278">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L279">        self: Insn,</span>
<span class="line" id="L280">        <span class="tok-kw">comptime</span> layout: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L281">        opts: std.fmt.FormatOptions,</span>
<span class="line" id="L282">        writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L283">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L284">        _ = opts;</span>
<span class="line" id="L285">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> layout.len != <span class="tok-number">0</span> <span class="tok-kw">and</span> layout[<span class="tok-number">0</span>] != <span class="tok-str">'s'</span>)</span>
<span class="line" id="L286">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unsupported format specifier for BPF Insn type '&quot;</span> ++ layout ++ <span class="tok-str">&quot;'.&quot;</span>);</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">        <span class="tok-kw">try</span> std.fmt.format(</span>
<span class="line" id="L289">            writer,</span>
<span class="line" id="L290">            <span class="tok-str">&quot;Insn{{ 0x{X:0&lt;2}, {d}, {d}, 0x{X:0&lt;8} }}&quot;</span>,</span>
<span class="line" id="L291">            .{ self.opcode, self.jt, self.jf, self.k },</span>
<span class="line" id="L292">        );</span>
<span class="line" id="L293">    }</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">const</span> Size = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L296">        word = W,</span>
<span class="line" id="L297">        half_word = H,</span>
<span class="line" id="L298">        byte = B,</span>
<span class="line" id="L299">    };</span>
<span class="line" id="L300"></span>
<span class="line" id="L301">    <span class="tok-kw">fn</span> <span class="tok-fn">stmt</span>(opcode: <span class="tok-type">u16</span>, k: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L302">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L303">            .opcode = opcode,</span>
<span class="line" id="L304">            .jt = <span class="tok-number">0</span>,</span>
<span class="line" id="L305">            .jf = <span class="tok-number">0</span>,</span>
<span class="line" id="L306">            .k = k,</span>
<span class="line" id="L307">        };</span>
<span class="line" id="L308">    }</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_imm</span>(value: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L311">        <span class="tok-kw">return</span> stmt(LD | IMM, value);</span>
<span class="line" id="L312">    }</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_abs</span>(size: Size, offset: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L315">        <span class="tok-kw">return</span> stmt(LD | ABS | <span class="tok-builtin">@enumToInt</span>(size), offset);</span>
<span class="line" id="L316">    }</span>
<span class="line" id="L317"></span>
<span class="line" id="L318">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_ind</span>(size: Size, offset: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L319">        <span class="tok-kw">return</span> stmt(LD | IND | <span class="tok-builtin">@enumToInt</span>(size), offset);</span>
<span class="line" id="L320">    }</span>
<span class="line" id="L321"></span>
<span class="line" id="L322">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_mem</span>(reg: Scratch) Insn {</span>
<span class="line" id="L323">        <span class="tok-kw">return</span> stmt(LD | MEM, <span class="tok-builtin">@enumToInt</span>(reg));</span>
<span class="line" id="L324">    }</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_len</span>() Insn {</span>
<span class="line" id="L327">        <span class="tok-kw">return</span> stmt(LD | LEN | W, <span class="tok-number">0</span>);</span>
<span class="line" id="L328">    }</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ld_rnd</span>() Insn {</span>
<span class="line" id="L331">        <span class="tok-kw">return</span> stmt(LD | RND | W, <span class="tok-number">0</span>);</span>
<span class="line" id="L332">    }</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldx_imm</span>(value: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L335">        <span class="tok-kw">return</span> stmt(LDX | IMM, value);</span>
<span class="line" id="L336">    }</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldx_mem</span>(reg: Scratch) Insn {</span>
<span class="line" id="L339">        <span class="tok-kw">return</span> stmt(LDX | MEM, <span class="tok-builtin">@enumToInt</span>(reg));</span>
<span class="line" id="L340">    }</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldx_len</span>() Insn {</span>
<span class="line" id="L343">        <span class="tok-kw">return</span> stmt(LDX | LEN | W, <span class="tok-number">0</span>);</span>
<span class="line" id="L344">    }</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldx_msh</span>(offset: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L347">        <span class="tok-kw">return</span> stmt(LDX | MSH | B, offset);</span>
<span class="line" id="L348">    }</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">st</span>(reg: Scratch) Insn {</span>
<span class="line" id="L351">        <span class="tok-kw">return</span> stmt(ST, <span class="tok-builtin">@enumToInt</span>(reg));</span>
<span class="line" id="L352">    }</span>
<span class="line" id="L353">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stx</span>(reg: Scratch) Insn {</span>
<span class="line" id="L354">        <span class="tok-kw">return</span> stmt(STX, <span class="tok-builtin">@enumToInt</span>(reg));</span>
<span class="line" id="L355">    }</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-kw">const</span> AluOp = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L358">        add = ADD,</span>
<span class="line" id="L359">        sub = SUB,</span>
<span class="line" id="L360">        mul = MUL,</span>
<span class="line" id="L361">        div = DIV,</span>
<span class="line" id="L362">        @&quot;or&quot; = OR,</span>
<span class="line" id="L363">        @&quot;and&quot; = AND,</span>
<span class="line" id="L364">        lsh = LSH,</span>
<span class="line" id="L365">        rsh = RSH,</span>
<span class="line" id="L366">        mod = MOD,</span>
<span class="line" id="L367">        xor = XOR,</span>
<span class="line" id="L368">    };</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    <span class="tok-kw">const</span> Source = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L371">        k = K,</span>
<span class="line" id="L372">        x = X,</span>
<span class="line" id="L373">    };</span>
<span class="line" id="L374">    <span class="tok-kw">const</span> KOrX = <span class="tok-kw">union</span>(Source) {</span>
<span class="line" id="L375">        k: <span class="tok-type">u32</span>,</span>
<span class="line" id="L376">        x: <span class="tok-type">void</span>,</span>
<span class="line" id="L377">    };</span>
<span class="line" id="L378"></span>
<span class="line" id="L379">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alu_neg</span>() Insn {</span>
<span class="line" id="L380">        <span class="tok-kw">return</span> stmt(ALU | NEG, <span class="tok-number">0</span>);</span>
<span class="line" id="L381">    }</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">alu</span>(op: AluOp, source: KOrX) Insn {</span>
<span class="line" id="L384">        <span class="tok-kw">return</span> stmt(</span>
<span class="line" id="L385">            ALU | <span class="tok-builtin">@enumToInt</span>(op) | <span class="tok-builtin">@enumToInt</span>(source),</span>
<span class="line" id="L386">            <span class="tok-kw">if</span> (source == .k) source.k <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L387">        );</span>
<span class="line" id="L388">    }</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-kw">const</span> JmpOp = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L391">        jeq = JEQ,</span>
<span class="line" id="L392">        jgt = JGT,</span>
<span class="line" id="L393">        jge = JGE,</span>
<span class="line" id="L394">        jset = JSET,</span>
<span class="line" id="L395">    };</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jmp_ja</span>(location: <span class="tok-type">u32</span>) Insn {</span>
<span class="line" id="L398">        <span class="tok-kw">return</span> stmt(JMP | JA, location);</span>
<span class="line" id="L399">    }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">jmp</span>(op: JmpOp, source: KOrX, jt: <span class="tok-type">u8</span>, jf: <span class="tok-type">u8</span>) Insn {</span>
<span class="line" id="L402">        <span class="tok-kw">return</span> Insn{</span>
<span class="line" id="L403">            .opcode = JMP | <span class="tok-builtin">@enumToInt</span>(op) | <span class="tok-builtin">@enumToInt</span>(source),</span>
<span class="line" id="L404">            .jt = jt,</span>
<span class="line" id="L405">            .jf = jf,</span>
<span class="line" id="L406">            .k = <span class="tok-kw">if</span> (source == .k) source.k <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L407">        };</span>
<span class="line" id="L408">    }</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-kw">const</span> Verdict = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L411">        k = K,</span>
<span class="line" id="L412">        a = A,</span>
<span class="line" id="L413">    };</span>
<span class="line" id="L414">    <span class="tok-kw">const</span> KOrA = <span class="tok-kw">union</span>(Verdict) {</span>
<span class="line" id="L415">        k: <span class="tok-type">u32</span>,</span>
<span class="line" id="L416">        a: <span class="tok-type">void</span>,</span>
<span class="line" id="L417">    };</span>
<span class="line" id="L418"></span>
<span class="line" id="L419">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ret</span>(verdict: KOrA) Insn {</span>
<span class="line" id="L420">        <span class="tok-kw">return</span> stmt(</span>
<span class="line" id="L421">            RET | <span class="tok-builtin">@enumToInt</span>(verdict),</span>
<span class="line" id="L422">            <span class="tok-kw">if</span> (verdict == .k) verdict.k <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L423">        );</span>
<span class="line" id="L424">    }</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tax</span>() Insn {</span>
<span class="line" id="L427">        <span class="tok-kw">return</span> stmt(MISC | TAX, <span class="tok-number">0</span>);</span>
<span class="line" id="L428">    }</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">txa</span>() Insn {</span>
<span class="line" id="L431">        <span class="tok-kw">return</span> stmt(MISC | TXA, <span class="tok-number">0</span>);</span>
<span class="line" id="L432">    }</span>
<span class="line" id="L433">};</span>
<span class="line" id="L434"></span>
<span class="line" id="L435"><span class="tok-kw">fn</span> <span class="tok-fn">opcodeEqual</span>(opcode: <span class="tok-type">u16</span>, insn: Insn) !<span class="tok-type">void</span> {</span>
<span class="line" id="L436">    <span class="tok-kw">try</span> expectEqual(opcode, insn.opcode);</span>
<span class="line" id="L437">}</span>
<span class="line" id="L438"></span>
<span class="line" id="L439"><span class="tok-kw">test</span> <span class="tok-str">&quot;opcodes&quot;</span> {</span>
<span class="line" id="L440">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x00</span>, Insn.ld_imm(<span class="tok-number">0</span>));</span>
<span class="line" id="L441">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x20</span>, Insn.ld_abs(.word, <span class="tok-number">0</span>));</span>
<span class="line" id="L442">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x28</span>, Insn.ld_abs(.half_word, <span class="tok-number">0</span>));</span>
<span class="line" id="L443">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x30</span>, Insn.ld_abs(.byte, <span class="tok-number">0</span>));</span>
<span class="line" id="L444">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x40</span>, Insn.ld_ind(.word, <span class="tok-number">0</span>));</span>
<span class="line" id="L445">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x48</span>, Insn.ld_ind(.half_word, <span class="tok-number">0</span>));</span>
<span class="line" id="L446">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x50</span>, Insn.ld_ind(.byte, <span class="tok-number">0</span>));</span>
<span class="line" id="L447">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x60</span>, Insn.ld_mem(.m0));</span>
<span class="line" id="L448">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x80</span>, Insn.ld_len());</span>
<span class="line" id="L449">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0xc0</span>, Insn.ld_rnd());</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x01</span>, Insn.ldx_imm(<span class="tok-number">0</span>));</span>
<span class="line" id="L452">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x61</span>, Insn.ldx_mem(.m0));</span>
<span class="line" id="L453">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x81</span>, Insn.ldx_len());</span>
<span class="line" id="L454">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0xb1</span>, Insn.ldx_msh(<span class="tok-number">0</span>));</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x02</span>, Insn.st(.m0));</span>
<span class="line" id="L457">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x03</span>, Insn.stx(.m0));</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x04</span>, Insn.alu(.add, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L460">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x14</span>, Insn.alu(.sub, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L461">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x24</span>, Insn.alu(.mul, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L462">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x34</span>, Insn.alu(.div, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L463">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x44</span>, Insn.alu(.@&quot;or&quot;, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L464">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x54</span>, Insn.alu(.@&quot;and&quot;, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L465">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x64</span>, Insn.alu(.lsh, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L466">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x74</span>, Insn.alu(.rsh, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L467">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x94</span>, Insn.alu(.mod, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L468">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0xa4</span>, Insn.alu(.xor, .{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L469">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x84</span>, Insn.alu_neg());</span>
<span class="line" id="L470">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x0c</span>, Insn.alu(.add, .x));</span>
<span class="line" id="L471">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x1c</span>, Insn.alu(.sub, .x));</span>
<span class="line" id="L472">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x2c</span>, Insn.alu(.mul, .x));</span>
<span class="line" id="L473">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x3c</span>, Insn.alu(.div, .x));</span>
<span class="line" id="L474">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x4c</span>, Insn.alu(.@&quot;or&quot;, .x));</span>
<span class="line" id="L475">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x5c</span>, Insn.alu(.@&quot;and&quot;, .x));</span>
<span class="line" id="L476">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x6c</span>, Insn.alu(.lsh, .x));</span>
<span class="line" id="L477">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x7c</span>, Insn.alu(.rsh, .x));</span>
<span class="line" id="L478">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x9c</span>, Insn.alu(.mod, .x));</span>
<span class="line" id="L479">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0xac</span>, Insn.alu(.xor, .x));</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x05</span>, Insn.jmp_ja(<span class="tok-number">0</span>));</span>
<span class="line" id="L482">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x15</span>, Insn.jmp(.jeq, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L483">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x25</span>, Insn.jmp(.jgt, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L484">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x35</span>, Insn.jmp(.jge, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L485">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x45</span>, Insn.jmp(.jset, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L486">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x1d</span>, Insn.jmp(.jeq, .x, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L487">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x2d</span>, Insn.jmp(.jgt, .x, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L488">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x3d</span>, Insn.jmp(.jge, .x, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L489">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x4d</span>, Insn.jmp(.jset, .x, <span class="tok-number">0</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x06</span>, Insn.ret(.{ .k = <span class="tok-number">0</span> }));</span>
<span class="line" id="L492">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x16</span>, Insn.ret(.a));</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x07</span>, Insn.tax());</span>
<span class="line" id="L495">    <span class="tok-kw">try</span> opcodeEqual(<span class="tok-number">0x87</span>, Insn.txa());</span>
<span class="line" id="L496">}</span>
<span class="line" id="L497"></span>
<span class="line" id="L498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L499">    InvalidOpcode,</span>
<span class="line" id="L500">    InvalidOffset,</span>
<span class="line" id="L501">    InvalidLocation,</span>
<span class="line" id="L502">    DivisionByZero,</span>
<span class="line" id="L503">    NoReturn,</span>
<span class="line" id="L504">};</span>
<span class="line" id="L505"></span>
<span class="line" id="L506"><span class="tok-comment">/// A simple implementation of the BPF virtual-machine.</span></span>
<span class="line" id="L507"><span class="tok-comment">/// Use this to run/debug programs.</span></span>
<span class="line" id="L508"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">simulate</span>(</span>
<span class="line" id="L509">    packet: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L510">    filter: []<span class="tok-kw">const</span> Insn,</span>
<span class="line" id="L511">    byte_order: std.builtin.Endian,</span>
<span class="line" id="L512">) Error!<span class="tok-type">u32</span> {</span>
<span class="line" id="L513">    assert(filter.len &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> filter.len &lt; MAXINSNS);</span>
<span class="line" id="L514">    assert(packet.len &lt; MAXBUFSIZE);</span>
<span class="line" id="L515">    <span class="tok-kw">const</span> len = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, packet.len);</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    <span class="tok-kw">var</span> a: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L518">    <span class="tok-kw">var</span> x: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L519">    <span class="tok-kw">var</span> m = mem.zeroes([MEMWORDS]<span class="tok-type">u32</span>);</span>
<span class="line" id="L520">    <span class="tok-kw">var</span> pc: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">    <span class="tok-kw">while</span> (pc &lt; filter.len) : (pc += <span class="tok-number">1</span>) {</span>
<span class="line" id="L523">        <span class="tok-kw">const</span> i = filter[pc];</span>
<span class="line" id="L524">        <span class="tok-comment">// Cast to a wider type to protect against overflow.</span>
</span>
<span class="line" id="L525">        <span class="tok-kw">const</span> k = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, i.k);</span>
<span class="line" id="L526">        <span class="tok-kw">const</span> remaining = filter.len - (pc + <span class="tok-number">1</span>);</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-comment">// Do validation/error checking here to compress the second switch.</span>
</span>
<span class="line" id="L529">        <span class="tok-kw">switch</span> (i.opcode) {</span>
<span class="line" id="L530">            LD | ABS | W =&gt; <span class="tok-kw">if</span> (k + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>) - <span class="tok-number">1</span> &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L531">            LD | ABS | H =&gt; <span class="tok-kw">if</span> (k + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>) - <span class="tok-number">1</span> &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L532">            LD | ABS | B =&gt; <span class="tok-kw">if</span> (k &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L533">            LD | IND | W =&gt; <span class="tok-kw">if</span> (k + x + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>) - <span class="tok-number">1</span> &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L534">            LD | IND | H =&gt; <span class="tok-kw">if</span> (k + x + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>) - <span class="tok-number">1</span> &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L535">            LD | IND | B =&gt; <span class="tok-kw">if</span> (k + x &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">            LDX | MSH | B =&gt; <span class="tok-kw">if</span> (k &gt;= packet.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L538">            ST, STX, LD | MEM, LDX | MEM =&gt; <span class="tok-kw">if</span> (i.k &gt;= MEMWORDS) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">            JMP | JA =&gt; <span class="tok-kw">if</span> (remaining &lt;= i.k) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOffset,</span>
<span class="line" id="L541">            JMP | JEQ | K,</span>
<span class="line" id="L542">            JMP | JGT | K,</span>
<span class="line" id="L543">            JMP | JGE | K,</span>
<span class="line" id="L544">            JMP | JSET | K,</span>
<span class="line" id="L545">            JMP | JEQ | X,</span>
<span class="line" id="L546">            JMP | JGT | X,</span>
<span class="line" id="L547">            JMP | JGE | X,</span>
<span class="line" id="L548">            JMP | JSET | X,</span>
<span class="line" id="L549">            =&gt; <span class="tok-kw">if</span> (remaining &lt;= i.jt <span class="tok-kw">or</span> remaining &lt;= i.jf) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidLocation,</span>
<span class="line" id="L550">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L551">        }</span>
<span class="line" id="L552">        <span class="tok-kw">switch</span> (i.opcode) {</span>
<span class="line" id="L553">            LD | IMM =&gt; a = i.k,</span>
<span class="line" id="L554">            LD | MEM =&gt; a = m[i.k],</span>
<span class="line" id="L555">            LD | LEN | W =&gt; a = len,</span>
<span class="line" id="L556">            LD | RND | W =&gt; a = random.int(<span class="tok-type">u32</span>),</span>
<span class="line" id="L557">            LD | ABS | W =&gt; a = mem.readInt(<span class="tok-type">u32</span>, packet[i.k..][<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>)], byte_order),</span>
<span class="line" id="L558">            LD | ABS | H =&gt; a = mem.readInt(<span class="tok-type">u16</span>, packet[i.k..][<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>)], byte_order),</span>
<span class="line" id="L559">            LD | ABS | B =&gt; a = packet[i.k],</span>
<span class="line" id="L560">            LD | IND | W =&gt; a = mem.readInt(<span class="tok-type">u32</span>, packet[i.k + x ..][<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>)], byte_order),</span>
<span class="line" id="L561">            LD | IND | H =&gt; a = mem.readInt(<span class="tok-type">u16</span>, packet[i.k + x ..][<span class="tok-number">0</span>..<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>)], byte_order),</span>
<span class="line" id="L562">            LD | IND | B =&gt; a = packet[i.k + x],</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">            LDX | IMM =&gt; x = i.k,</span>
<span class="line" id="L565">            LDX | MEM =&gt; x = m[i.k],</span>
<span class="line" id="L566">            LDX | LEN | W =&gt; x = len,</span>
<span class="line" id="L567">            LDX | MSH | B =&gt; x = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u4</span>, packet[i.k])) &lt;&lt; <span class="tok-number">2</span>,</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">            ST =&gt; m[i.k] = a,</span>
<span class="line" id="L570">            STX =&gt; m[i.k] = x,</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">            ALU | ADD | K =&gt; a +%= i.k,</span>
<span class="line" id="L573">            ALU | SUB | K =&gt; a -%= i.k,</span>
<span class="line" id="L574">            ALU | MUL | K =&gt; a *%= i.k,</span>
<span class="line" id="L575">            ALU | DIV | K =&gt; a = <span class="tok-kw">try</span> math.divTrunc(<span class="tok-type">u32</span>, a, i.k),</span>
<span class="line" id="L576">            ALU | OR | K =&gt; a |= i.k,</span>
<span class="line" id="L577">            ALU | AND | K =&gt; a &amp;= i.k,</span>
<span class="line" id="L578">            ALU | LSH | K =&gt; a = math.shl(<span class="tok-type">u32</span>, a, i.k),</span>
<span class="line" id="L579">            ALU | RSH | K =&gt; a = math.shr(<span class="tok-type">u32</span>, a, i.k),</span>
<span class="line" id="L580">            ALU | MOD | K =&gt; a = <span class="tok-kw">try</span> math.mod(<span class="tok-type">u32</span>, a, i.k),</span>
<span class="line" id="L581">            ALU | XOR | K =&gt; a ^= i.k,</span>
<span class="line" id="L582">            ALU | ADD | X =&gt; a +%= x,</span>
<span class="line" id="L583">            ALU | SUB | X =&gt; a -%= x,</span>
<span class="line" id="L584">            ALU | MUL | X =&gt; a *%= x,</span>
<span class="line" id="L585">            ALU | DIV | X =&gt; a = <span class="tok-kw">try</span> math.divTrunc(<span class="tok-type">u32</span>, a, x),</span>
<span class="line" id="L586">            ALU | OR | X =&gt; a |= x,</span>
<span class="line" id="L587">            ALU | AND | X =&gt; a &amp;= x,</span>
<span class="line" id="L588">            ALU | LSH | X =&gt; a = math.shl(<span class="tok-type">u32</span>, a, x),</span>
<span class="line" id="L589">            ALU | RSH | X =&gt; a = math.shr(<span class="tok-type">u32</span>, a, x),</span>
<span class="line" id="L590">            ALU | MOD | X =&gt; a = <span class="tok-kw">try</span> math.mod(<span class="tok-type">u32</span>, a, x),</span>
<span class="line" id="L591">            ALU | XOR | X =&gt; a ^= x,</span>
<span class="line" id="L592">            ALU | NEG =&gt; a = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, -%<span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, a)),</span>
<span class="line" id="L593"></span>
<span class="line" id="L594">            JMP | JA =&gt; pc += i.k,</span>
<span class="line" id="L595">            JMP | JEQ | K =&gt; pc += <span class="tok-kw">if</span> (a == i.k) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L596">            JMP | JGT | K =&gt; pc += <span class="tok-kw">if</span> (a &gt; i.k) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L597">            JMP | JGE | K =&gt; pc += <span class="tok-kw">if</span> (a &gt;= i.k) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L598">            JMP | JSET | K =&gt; pc += <span class="tok-kw">if</span> (a &amp; i.k &gt; <span class="tok-number">0</span>) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L599">            JMP | JEQ | X =&gt; pc += <span class="tok-kw">if</span> (a == x) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L600">            JMP | JGT | X =&gt; pc += <span class="tok-kw">if</span> (a &gt; x) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L601">            JMP | JGE | X =&gt; pc += <span class="tok-kw">if</span> (a &gt;= x) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L602">            JMP | JSET | X =&gt; pc += <span class="tok-kw">if</span> (a &amp; x &gt; <span class="tok-number">0</span>) i.jt <span class="tok-kw">else</span> i.jf,</span>
<span class="line" id="L603"></span>
<span class="line" id="L604">            RET | K =&gt; <span class="tok-kw">return</span> i.k,</span>
<span class="line" id="L605">            RET | A =&gt; <span class="tok-kw">return</span> a,</span>
<span class="line" id="L606"></span>
<span class="line" id="L607">            MISC | TAX =&gt; x = a,</span>
<span class="line" id="L608">            MISC | TXA =&gt; a = x,</span>
<span class="line" id="L609">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidOpcode,</span>
<span class="line" id="L610">        }</span>
<span class="line" id="L611">    }</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NoReturn;</span>
<span class="line" id="L614">}</span>
<span class="line" id="L615"></span>
<span class="line" id="L616"><span class="tok-comment">// This program is the BPF form of the tcpdump filter:</span>
</span>
<span class="line" id="L617"><span class="tok-comment">//</span>
</span>
<span class="line" id="L618"><span class="tok-comment">//     tcpdump -dd 'ip host mirror.internode.on.net and tcp port ftp-data'</span>
</span>
<span class="line" id="L619"><span class="tok-comment">//</span>
</span>
<span class="line" id="L620"><span class="tok-comment">// As of January 2022, mirror.internode.on.net resolves to 150.101.135.3</span>
</span>
<span class="line" id="L621"><span class="tok-comment">//</span>
</span>
<span class="line" id="L622"><span class="tok-comment">// For reference, here's what it looks like in BPF assembler.</span>
</span>
<span class="line" id="L623"><span class="tok-comment">// Note that the jumps are used for TCP/IP layer checks.</span>
</span>
<span class="line" id="L624"><span class="tok-comment">//</span>
</span>
<span class="line" id="L625"><span class="tok-comment">// ```</span>
</span>
<span class="line" id="L626"><span class="tok-comment">//       ldh [12] (#proto)</span>
</span>
<span class="line" id="L627"><span class="tok-comment">//       jeq #0x0800 (ETHERTYPE_IP), L1, fail</span>
</span>
<span class="line" id="L628"><span class="tok-comment">// L1:   ld [26]</span>
</span>
<span class="line" id="L629"><span class="tok-comment">//       jeq #150.101.135.3, L2, dest</span>
</span>
<span class="line" id="L630"><span class="tok-comment">// dest: ld [30]</span>
</span>
<span class="line" id="L631"><span class="tok-comment">//       jeq #150.101.135.3, L2, fail</span>
</span>
<span class="line" id="L632"><span class="tok-comment">// L2:   ldb [23]</span>
</span>
<span class="line" id="L633"><span class="tok-comment">//       jeq #0x6 (IPPROTO_TCP), L3, fail</span>
</span>
<span class="line" id="L634"><span class="tok-comment">// L3:   ldh [20]</span>
</span>
<span class="line" id="L635"><span class="tok-comment">//       jset #0x1fff, fail, plen</span>
</span>
<span class="line" id="L636"><span class="tok-comment">// plen: ldx 4 * ([14] &amp; 0xf)</span>
</span>
<span class="line" id="L637"><span class="tok-comment">//       ldh [x + 14]</span>
</span>
<span class="line" id="L638"><span class="tok-comment">//       jeq  #0x14 (FTP), pass, dstp</span>
</span>
<span class="line" id="L639"><span class="tok-comment">// dstp: ldh [x + 16]</span>
</span>
<span class="line" id="L640"><span class="tok-comment">//       jeq  #0x14 (FTP), pass, fail</span>
</span>
<span class="line" id="L641"><span class="tok-comment">// pass: ret #0x40000</span>
</span>
<span class="line" id="L642"><span class="tok-comment">// fail: ret #0</span>
</span>
<span class="line" id="L643"><span class="tok-comment">// ```</span>
</span>
<span class="line" id="L644"><span class="tok-kw">const</span> tcpdump_filter = [_]Insn{</span>
<span class="line" id="L645">    Insn.ld_abs(.half_word, <span class="tok-number">12</span>),</span>
<span class="line" id="L646">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x800</span> }, <span class="tok-number">0</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L647">    Insn.ld_abs(.word, <span class="tok-number">26</span>),</span>
<span class="line" id="L648">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x96658703</span> }, <span class="tok-number">2</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L649">    Insn.ld_abs(.word, <span class="tok-number">30</span>),</span>
<span class="line" id="L650">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x96658703</span> }, <span class="tok-number">0</span>, <span class="tok-number">10</span>),</span>
<span class="line" id="L651">    Insn.ld_abs(.byte, <span class="tok-number">23</span>),</span>
<span class="line" id="L652">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x6</span> }, <span class="tok-number">0</span>, <span class="tok-number">8</span>),</span>
<span class="line" id="L653">    Insn.ld_abs(.half_word, <span class="tok-number">20</span>),</span>
<span class="line" id="L654">    Insn.jmp(.jset, .{ .k = <span class="tok-number">0x1fff</span> }, <span class="tok-number">6</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L655">    Insn.ldx_msh(<span class="tok-number">14</span>),</span>
<span class="line" id="L656">    Insn.ld_ind(.half_word, <span class="tok-number">14</span>),</span>
<span class="line" id="L657">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x14</span> }, <span class="tok-number">2</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L658">    Insn.ld_ind(.half_word, <span class="tok-number">16</span>),</span>
<span class="line" id="L659">    Insn.jmp(.jeq, .{ .k = <span class="tok-number">0x14</span> }, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L660">    Insn.ret(.{ .k = <span class="tok-number">0x40000</span> }),</span>
<span class="line" id="L661">    Insn.ret(.{ .k = <span class="tok-number">0</span> }),</span>
<span class="line" id="L662">};</span>
<span class="line" id="L663"></span>
<span class="line" id="L664"><span class="tok-comment">// This packet is the output of `ls` on mirror.internode.on.net:/, captured</span>
</span>
<span class="line" id="L665"><span class="tok-comment">// using the filter above.</span>
</span>
<span class="line" id="L666"><span class="tok-comment">//</span>
</span>
<span class="line" id="L667"><span class="tok-comment">// zig fmt: off</span>
</span>
<span class="line" id="L668"><span class="tok-kw">const</span> ftp_data = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L669">    <span class="tok-comment">// ethernet - 14 bytes: IPv4(0x0800) from a4:71:74:ad:4b:f0 -&gt; de:ad:be:ef:f0:0f</span>
</span>
<span class="line" id="L670">    <span class="tok-number">0xde</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L671">    <span class="tok-comment">// IPv4 - 20 bytes: TCP data from 150.101.135.3 -&gt; 192.168.1.3</span>
</span>
<span class="line" id="L672">    <span class="tok-number">0x45</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0xb6</span>,</span>
<span class="line" id="L673">    <span class="tok-number">0x96</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x03</span>,</span>
<span class="line" id="L674">    <span class="tok-comment">// TCP - 32 bytes: Source port: 20 (FTP). Payload = 446 bytes</span>
</span>
<span class="line" id="L675">    <span class="tok-number">0x00</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L676">    <span class="tok-number">0x88</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0xa0</span></span>
<span class="line" id="L677">} ++</span>
<span class="line" id="L678">    <span class="tok-comment">// Raw line-based FTP data - 446 bytes</span>
</span>
<span class="line" id="L679">    <span class="tok-str">&quot;lrwxrwxrwx   1 root     root           12 Feb 14  2012 debian -&gt; .pub2/debian\r\n&quot;</span> ++</span>
<span class="line" id="L680">    <span class="tok-str">&quot;lrwxrwxrwx   1 root     root           15 Feb 14  2012 debian-cd -&gt; .pub2/debian-cd\r\n&quot;</span> ++</span>
<span class="line" id="L681">    <span class="tok-str">&quot;lrwxrwxrwx   1 root     root            9 Mar  9  2018 linux -&gt; pub/linux\r\n&quot;</span> ++</span>
<span class="line" id="L682">    <span class="tok-str">&quot;drwxr-xr-X   3 mirror   mirror       4096 Sep 20 08:10 pub\r\n&quot;</span> ++</span>
<span class="line" id="L683">    <span class="tok-str">&quot;lrwxrwxrwx   1 root     root           12 Feb 14  2012 ubuntu -&gt; .pub2/ubuntu\r\n&quot;</span> ++</span>
<span class="line" id="L684">    <span class="tok-str">&quot;-rw-r--r--   1 root     root         1044 Jan 20  2015 welcome.msg\r\n&quot;</span>;</span>
<span class="line" id="L685"><span class="tok-comment">// zig fmt: on</span>
</span>
<span class="line" id="L686"></span>
<span class="line" id="L687"><span class="tok-kw">test</span> <span class="tok-str">&quot;tcpdump filter&quot;</span> {</span>
<span class="line" id="L688">    <span class="tok-kw">try</span> expectEqual(</span>
<span class="line" id="L689">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x40000</span>),</span>
<span class="line" id="L690">        <span class="tok-kw">try</span> simulate(ftp_data, &amp;tcpdump_filter, .Big),</span>
<span class="line" id="L691">    );</span>
<span class="line" id="L692">}</span>
<span class="line" id="L693"></span>
<span class="line" id="L694"><span class="tok-kw">fn</span> <span class="tok-fn">expectPass</span>(data: <span class="tok-kw">anytype</span>, filter: []Insn) !<span class="tok-type">void</span> {</span>
<span class="line" id="L695">    <span class="tok-kw">try</span> expectEqual(</span>
<span class="line" id="L696">        <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L697">        <span class="tok-kw">try</span> simulate(mem.asBytes(data), filter, .Big),</span>
<span class="line" id="L698">    );</span>
<span class="line" id="L699">}</span>
<span class="line" id="L700"></span>
<span class="line" id="L701"><span class="tok-kw">fn</span> <span class="tok-fn">expectFail</span>(expected_error: <span class="tok-type">anyerror</span>, data: <span class="tok-kw">anytype</span>, filter: []Insn) !<span class="tok-type">void</span> {</span>
<span class="line" id="L702">    <span class="tok-kw">try</span> expectError(</span>
<span class="line" id="L703">        expected_error,</span>
<span class="line" id="L704">        simulate(mem.asBytes(data), filter, native_endian),</span>
<span class="line" id="L705">    );</span>
<span class="line" id="L706">}</span>
<span class="line" id="L707"></span>
<span class="line" id="L708"><span class="tok-kw">test</span> <span class="tok-str">&quot;simulator coverage&quot;</span> {</span>
<span class="line" id="L709">    <span class="tok-kw">const</span> some_data = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L710">        <span class="tok-number">0xaa</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0x7f</span>,</span>
<span class="line" id="L711">    };</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    <span class="tok-kw">try</span> expectPass(&amp;some_data, &amp;.{</span>
<span class="line" id="L714">        <span class="tok-comment">// ld  #10</span>
</span>
<span class="line" id="L715">        <span class="tok-comment">// ldx #1</span>
</span>
<span class="line" id="L716">        <span class="tok-comment">// st M[0]</span>
</span>
<span class="line" id="L717">        <span class="tok-comment">// stx M[1]</span>
</span>
<span class="line" id="L718">        <span class="tok-comment">// fail if A != 10</span>
</span>
<span class="line" id="L719">        Insn.ld_imm(<span class="tok-number">10</span>),</span>
<span class="line" id="L720">        Insn.ldx_imm(<span class="tok-number">1</span>),</span>
<span class="line" id="L721">        Insn.st(.m0),</span>
<span class="line" id="L722">        Insn.stx(.m1),</span>
<span class="line" id="L723">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">10</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L724">        Insn.ret(.{ .k = <span class="tok-number">1</span> }),</span>
<span class="line" id="L725">        <span class="tok-comment">// ld [0]</span>
</span>
<span class="line" id="L726">        <span class="tok-comment">// fail if A != 0xaabbccdd</span>
</span>
<span class="line" id="L727">        Insn.ld_abs(.word, <span class="tok-number">0</span>),</span>
<span class="line" id="L728">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xaabbccdd</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L729">        Insn.ret(.{ .k = <span class="tok-number">2</span> }),</span>
<span class="line" id="L730">        <span class="tok-comment">// ldh [0]</span>
</span>
<span class="line" id="L731">        <span class="tok-comment">// fail if A != 0xaabb</span>
</span>
<span class="line" id="L732">        Insn.ld_abs(.half_word, <span class="tok-number">0</span>),</span>
<span class="line" id="L733">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xaabb</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L734">        Insn.ret(.{ .k = <span class="tok-number">3</span> }),</span>
<span class="line" id="L735">        <span class="tok-comment">// ldb [0]</span>
</span>
<span class="line" id="L736">        <span class="tok-comment">// fail if A != 0xaa</span>
</span>
<span class="line" id="L737">        Insn.ld_abs(.byte, <span class="tok-number">0</span>),</span>
<span class="line" id="L738">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xaa</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L739">        Insn.ret(.{ .k = <span class="tok-number">4</span> }),</span>
<span class="line" id="L740">        <span class="tok-comment">// ld [x + 0]</span>
</span>
<span class="line" id="L741">        <span class="tok-comment">// fail if A != 0xbbccdd7f</span>
</span>
<span class="line" id="L742">        Insn.ld_ind(.word, <span class="tok-number">0</span>),</span>
<span class="line" id="L743">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xbbccdd7f</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L744">        Insn.ret(.{ .k = <span class="tok-number">5</span> }),</span>
<span class="line" id="L745">        <span class="tok-comment">// ldh [x + 0]</span>
</span>
<span class="line" id="L746">        <span class="tok-comment">// fail if A != 0xbbcc</span>
</span>
<span class="line" id="L747">        Insn.ld_ind(.half_word, <span class="tok-number">0</span>),</span>
<span class="line" id="L748">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xbbcc</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L749">        Insn.ret(.{ .k = <span class="tok-number">6</span> }),</span>
<span class="line" id="L750">        <span class="tok-comment">// ldb [x + 0]</span>
</span>
<span class="line" id="L751">        <span class="tok-comment">// fail if A != 0xbb</span>
</span>
<span class="line" id="L752">        Insn.ld_ind(.byte, <span class="tok-number">0</span>),</span>
<span class="line" id="L753">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xbb</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L754">        Insn.ret(.{ .k = <span class="tok-number">7</span> }),</span>
<span class="line" id="L755">        <span class="tok-comment">// ld M[0]</span>
</span>
<span class="line" id="L756">        <span class="tok-comment">// fail if A != 10</span>
</span>
<span class="line" id="L757">        Insn.ld_mem(.m0),</span>
<span class="line" id="L758">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">10</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L759">        Insn.ret(.{ .k = <span class="tok-number">8</span> }),</span>
<span class="line" id="L760">        <span class="tok-comment">// ld #len</span>
</span>
<span class="line" id="L761">        <span class="tok-comment">// fail if A != 5</span>
</span>
<span class="line" id="L762">        Insn.ld_len(),</span>
<span class="line" id="L763">        Insn.jmp(.jeq, .{ .k = some_data.len }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L764">        Insn.ret(.{ .k = <span class="tok-number">9</span> }),</span>
<span class="line" id="L765">        <span class="tok-comment">// ld #0</span>
</span>
<span class="line" id="L766">        <span class="tok-comment">// ld arc4random()</span>
</span>
<span class="line" id="L767">        <span class="tok-comment">// fail if A == 0</span>
</span>
<span class="line" id="L768">        Insn.ld_imm(<span class="tok-number">0</span>),</span>
<span class="line" id="L769">        Insn.ld_rnd(),</span>
<span class="line" id="L770">        Insn.jmp(.jgt, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L771">        Insn.ret(.{ .k = <span class="tok-number">10</span> }),</span>
<span class="line" id="L772">        <span class="tok-comment">// ld  #3</span>
</span>
<span class="line" id="L773">        <span class="tok-comment">// ldx #10</span>
</span>
<span class="line" id="L774">        <span class="tok-comment">// st M[2]</span>
</span>
<span class="line" id="L775">        <span class="tok-comment">// txa</span>
</span>
<span class="line" id="L776">        <span class="tok-comment">// fail if a != x</span>
</span>
<span class="line" id="L777">        Insn.ld_imm(<span class="tok-number">3</span>),</span>
<span class="line" id="L778">        Insn.ldx_imm(<span class="tok-number">10</span>),</span>
<span class="line" id="L779">        Insn.st(.m2),</span>
<span class="line" id="L780">        Insn.txa(),</span>
<span class="line" id="L781">        Insn.jmp(.jeq, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L782">        Insn.ret(.{ .k = <span class="tok-number">11</span> }),</span>
<span class="line" id="L783">        <span class="tok-comment">// ldx M[2]</span>
</span>
<span class="line" id="L784">        <span class="tok-comment">// fail if A &lt;= X</span>
</span>
<span class="line" id="L785">        Insn.ldx_mem(.m2),</span>
<span class="line" id="L786">        Insn.jmp(.jgt, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L787">        Insn.ret(.{ .k = <span class="tok-number">12</span> }),</span>
<span class="line" id="L788">        <span class="tok-comment">// ldx #len</span>
</span>
<span class="line" id="L789">        <span class="tok-comment">// fail if a &lt;= x</span>
</span>
<span class="line" id="L790">        Insn.ldx_len(),</span>
<span class="line" id="L791">        Insn.jmp(.jgt, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L792">        Insn.ret(.{ .k = <span class="tok-number">13</span> }),</span>
<span class="line" id="L793">        <span class="tok-comment">// a = 4 * (0x7f &amp; 0xf)</span>
</span>
<span class="line" id="L794">        <span class="tok-comment">// x = 4 * ([4]  &amp; 0xf)</span>
</span>
<span class="line" id="L795">        <span class="tok-comment">// fail if a != x</span>
</span>
<span class="line" id="L796">        Insn.ld_imm(<span class="tok-number">4</span> * (<span class="tok-number">0x7f</span> &amp; <span class="tok-number">0xf</span>)),</span>
<span class="line" id="L797">        Insn.ldx_msh(<span class="tok-number">4</span>),</span>
<span class="line" id="L798">        Insn.jmp(.jeq, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L799">        Insn.ret(.{ .k = <span class="tok-number">14</span> }),</span>
<span class="line" id="L800">        <span class="tok-comment">// ld  #(u32)-1</span>
</span>
<span class="line" id="L801">        <span class="tok-comment">// ldx #2</span>
</span>
<span class="line" id="L802">        <span class="tok-comment">// add #1</span>
</span>
<span class="line" id="L803">        <span class="tok-comment">// fail if a != 0</span>
</span>
<span class="line" id="L804">        Insn.ld_imm(<span class="tok-number">0xffffffff</span>),</span>
<span class="line" id="L805">        Insn.ldx_imm(<span class="tok-number">2</span>),</span>
<span class="line" id="L806">        Insn.alu(.add, .{ .k = <span class="tok-number">1</span> }),</span>
<span class="line" id="L807">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L808">        Insn.ret(.{ .k = <span class="tok-number">15</span> }),</span>
<span class="line" id="L809">        <span class="tok-comment">// sub #1</span>
</span>
<span class="line" id="L810">        <span class="tok-comment">// fail if a != (u32)-1</span>
</span>
<span class="line" id="L811">        Insn.alu(.sub, .{ .k = <span class="tok-number">1</span> }),</span>
<span class="line" id="L812">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xffffffff</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L813">        Insn.ret(.{ .k = <span class="tok-number">16</span> }),</span>
<span class="line" id="L814">        <span class="tok-comment">// add x</span>
</span>
<span class="line" id="L815">        <span class="tok-comment">// fail if a != 1</span>
</span>
<span class="line" id="L816">        Insn.alu(.add, .x),</span>
<span class="line" id="L817">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">1</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L818">        Insn.ret(.{ .k = <span class="tok-number">17</span> }),</span>
<span class="line" id="L819">        <span class="tok-comment">// sub x</span>
</span>
<span class="line" id="L820">        <span class="tok-comment">// fail if a != (u32)-1</span>
</span>
<span class="line" id="L821">        Insn.alu(.sub, .x),</span>
<span class="line" id="L822">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0xffffffff</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L823">        Insn.ret(.{ .k = <span class="tok-number">18</span> }),</span>
<span class="line" id="L824">        <span class="tok-comment">// ld #16</span>
</span>
<span class="line" id="L825">        <span class="tok-comment">// mul #2</span>
</span>
<span class="line" id="L826">        <span class="tok-comment">// fail if a != 32</span>
</span>
<span class="line" id="L827">        Insn.ld_imm(<span class="tok-number">16</span>),</span>
<span class="line" id="L828">        Insn.alu(.mul, .{ .k = <span class="tok-number">2</span> }),</span>
<span class="line" id="L829">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">32</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L830">        Insn.ret(.{ .k = <span class="tok-number">19</span> }),</span>
<span class="line" id="L831">        <span class="tok-comment">// mul x</span>
</span>
<span class="line" id="L832">        <span class="tok-comment">// fail if a != 64</span>
</span>
<span class="line" id="L833">        Insn.alu(.mul, .x),</span>
<span class="line" id="L834">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">64</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L835">        Insn.ret(.{ .k = <span class="tok-number">20</span> }),</span>
<span class="line" id="L836">        <span class="tok-comment">// div #2</span>
</span>
<span class="line" id="L837">        <span class="tok-comment">// fail if a != 32</span>
</span>
<span class="line" id="L838">        Insn.alu(.div, .{ .k = <span class="tok-number">2</span> }),</span>
<span class="line" id="L839">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">32</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L840">        Insn.ret(.{ .k = <span class="tok-number">21</span> }),</span>
<span class="line" id="L841">        <span class="tok-comment">// div x</span>
</span>
<span class="line" id="L842">        <span class="tok-comment">// fail if a != 16</span>
</span>
<span class="line" id="L843">        Insn.alu(.div, .x),</span>
<span class="line" id="L844">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">16</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L845">        Insn.ret(.{ .k = <span class="tok-number">22</span> }),</span>
<span class="line" id="L846">        <span class="tok-comment">// or #4</span>
</span>
<span class="line" id="L847">        <span class="tok-comment">// fail if a != 20</span>
</span>
<span class="line" id="L848">        Insn.alu(.@&quot;or&quot;, .{ .k = <span class="tok-number">4</span> }),</span>
<span class="line" id="L849">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">20</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L850">        Insn.ret(.{ .k = <span class="tok-number">23</span> }),</span>
<span class="line" id="L851">        <span class="tok-comment">// or x</span>
</span>
<span class="line" id="L852">        <span class="tok-comment">// fail if a != 22</span>
</span>
<span class="line" id="L853">        Insn.alu(.@&quot;or&quot;, .x),</span>
<span class="line" id="L854">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">22</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L855">        Insn.ret(.{ .k = <span class="tok-number">24</span> }),</span>
<span class="line" id="L856">        <span class="tok-comment">// and #6</span>
</span>
<span class="line" id="L857">        <span class="tok-comment">// fail if a != 6</span>
</span>
<span class="line" id="L858">        Insn.alu(.@&quot;and&quot;, .{ .k = <span class="tok-number">0b110</span> }),</span>
<span class="line" id="L859">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">6</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L860">        Insn.ret(.{ .k = <span class="tok-number">25</span> }),</span>
<span class="line" id="L861">        <span class="tok-comment">// and x</span>
</span>
<span class="line" id="L862">        <span class="tok-comment">// fail if a != 2</span>
</span>
<span class="line" id="L863">        Insn.alu(.@&quot;and&quot;, .x),</span>
<span class="line" id="L864">        Insn.jmp(.jeq, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L865">        Insn.ret(.{ .k = <span class="tok-number">26</span> }),</span>
<span class="line" id="L866">        <span class="tok-comment">// xor #15</span>
</span>
<span class="line" id="L867">        <span class="tok-comment">// fail if a != 13</span>
</span>
<span class="line" id="L868">        Insn.alu(.xor, .{ .k = <span class="tok-number">0b1111</span> }),</span>
<span class="line" id="L869">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b1101</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L870">        Insn.ret(.{ .k = <span class="tok-number">27</span> }),</span>
<span class="line" id="L871">        <span class="tok-comment">// xor x</span>
</span>
<span class="line" id="L872">        <span class="tok-comment">// fail if a != 15</span>
</span>
<span class="line" id="L873">        Insn.alu(.xor, .x),</span>
<span class="line" id="L874">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b1111</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L875">        Insn.ret(.{ .k = <span class="tok-number">28</span> }),</span>
<span class="line" id="L876">        <span class="tok-comment">// rsh #1</span>
</span>
<span class="line" id="L877">        <span class="tok-comment">// fail if a != 7</span>
</span>
<span class="line" id="L878">        Insn.alu(.rsh, .{ .k = <span class="tok-number">1</span> }),</span>
<span class="line" id="L879">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b0111</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L880">        Insn.ret(.{ .k = <span class="tok-number">29</span> }),</span>
<span class="line" id="L881">        <span class="tok-comment">// rsh x</span>
</span>
<span class="line" id="L882">        <span class="tok-comment">// fail if a != 1</span>
</span>
<span class="line" id="L883">        Insn.alu(.rsh, .x),</span>
<span class="line" id="L884">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b0001</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L885">        Insn.ret(.{ .k = <span class="tok-number">30</span> }),</span>
<span class="line" id="L886">        <span class="tok-comment">// lsh #1</span>
</span>
<span class="line" id="L887">        <span class="tok-comment">// fail if a != 2</span>
</span>
<span class="line" id="L888">        Insn.alu(.lsh, .{ .k = <span class="tok-number">1</span> }),</span>
<span class="line" id="L889">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b0010</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L890">        Insn.ret(.{ .k = <span class="tok-number">31</span> }),</span>
<span class="line" id="L891">        <span class="tok-comment">// lsh x</span>
</span>
<span class="line" id="L892">        <span class="tok-comment">// fail if a != 8</span>
</span>
<span class="line" id="L893">        Insn.alu(.lsh, .x),</span>
<span class="line" id="L894">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0b1000</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L895">        Insn.ret(.{ .k = <span class="tok-number">32</span> }),</span>
<span class="line" id="L896">        <span class="tok-comment">// mod 6</span>
</span>
<span class="line" id="L897">        <span class="tok-comment">// fail if a != 2</span>
</span>
<span class="line" id="L898">        Insn.alu(.mod, .{ .k = <span class="tok-number">6</span> }),</span>
<span class="line" id="L899">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">2</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L900">        Insn.ret(.{ .k = <span class="tok-number">33</span> }),</span>
<span class="line" id="L901">        <span class="tok-comment">// mod x</span>
</span>
<span class="line" id="L902">        <span class="tok-comment">// fail if a != 0</span>
</span>
<span class="line" id="L903">        Insn.alu(.mod, .x),</span>
<span class="line" id="L904">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L905">        Insn.ret(.{ .k = <span class="tok-number">34</span> }),</span>
<span class="line" id="L906">        <span class="tok-comment">// tax</span>
</span>
<span class="line" id="L907">        <span class="tok-comment">// neg</span>
</span>
<span class="line" id="L908">        <span class="tok-comment">// fail if a != (u32)-2</span>
</span>
<span class="line" id="L909">        Insn.txa(),</span>
<span class="line" id="L910">        Insn.alu_neg(),</span>
<span class="line" id="L911">        Insn.jmp(.jeq, .{ .k = ~<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>) + <span class="tok-number">1</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L912">        Insn.ret(.{ .k = <span class="tok-number">35</span> }),</span>
<span class="line" id="L913">        <span class="tok-comment">// ja #1 (skip the next instruction)</span>
</span>
<span class="line" id="L914">        Insn.jmp_ja(<span class="tok-number">1</span>),</span>
<span class="line" id="L915">        Insn.ret(.{ .k = <span class="tok-number">36</span> }),</span>
<span class="line" id="L916">        <span class="tok-comment">// ld #20</span>
</span>
<span class="line" id="L917">        <span class="tok-comment">// tax</span>
</span>
<span class="line" id="L918">        <span class="tok-comment">// fail if a != 20</span>
</span>
<span class="line" id="L919">        <span class="tok-comment">// fail if a != x</span>
</span>
<span class="line" id="L920">        Insn.ld_imm(<span class="tok-number">20</span>),</span>
<span class="line" id="L921">        Insn.tax(),</span>
<span class="line" id="L922">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">20</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L923">        Insn.ret(.{ .k = <span class="tok-number">37</span> }),</span>
<span class="line" id="L924">        Insn.jmp(.jeq, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L925">        Insn.ret(.{ .k = <span class="tok-number">38</span> }),</span>
<span class="line" id="L926">        <span class="tok-comment">// ld #19</span>
</span>
<span class="line" id="L927">        <span class="tok-comment">// fail if a == 20</span>
</span>
<span class="line" id="L928">        <span class="tok-comment">// fail if a == x</span>
</span>
<span class="line" id="L929">        <span class="tok-comment">// fail if a &gt;= 20</span>
</span>
<span class="line" id="L930">        <span class="tok-comment">// fail if a &gt;= X</span>
</span>
<span class="line" id="L931">        Insn.ld_imm(<span class="tok-number">19</span>),</span>
<span class="line" id="L932">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">20</span> }, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L933">        Insn.ret(.{ .k = <span class="tok-number">39</span> }),</span>
<span class="line" id="L934">        Insn.jmp(.jeq, .x, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L935">        Insn.ret(.{ .k = <span class="tok-number">40</span> }),</span>
<span class="line" id="L936">        Insn.jmp(.jgt, .{ .k = <span class="tok-number">20</span> }, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L937">        Insn.ret(.{ .k = <span class="tok-number">41</span> }),</span>
<span class="line" id="L938">        Insn.jmp(.jgt, .x, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L939">        Insn.ret(.{ .k = <span class="tok-number">42</span> }),</span>
<span class="line" id="L940">        <span class="tok-comment">// ld #21</span>
</span>
<span class="line" id="L941">        <span class="tok-comment">// fail if a &lt; 20</span>
</span>
<span class="line" id="L942">        <span class="tok-comment">// fail if a &lt; x</span>
</span>
<span class="line" id="L943">        Insn.ld_imm(<span class="tok-number">21</span>),</span>
<span class="line" id="L944">        Insn.jmp(.jgt, .{ .k = <span class="tok-number">20</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L945">        Insn.ret(.{ .k = <span class="tok-number">43</span> }),</span>
<span class="line" id="L946">        Insn.jmp(.jgt, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L947">        Insn.ret(.{ .k = <span class="tok-number">44</span> }),</span>
<span class="line" id="L948">        <span class="tok-comment">// ldx #22</span>
</span>
<span class="line" id="L949">        <span class="tok-comment">// fail if a &lt; 22</span>
</span>
<span class="line" id="L950">        <span class="tok-comment">// fail if a &lt; x</span>
</span>
<span class="line" id="L951">        Insn.ldx_imm(<span class="tok-number">22</span>),</span>
<span class="line" id="L952">        Insn.jmp(.jge, .{ .k = <span class="tok-number">22</span> }, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L953">        Insn.ret(.{ .k = <span class="tok-number">45</span> }),</span>
<span class="line" id="L954">        Insn.jmp(.jge, .x, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L955">        Insn.ret(.{ .k = <span class="tok-number">46</span> }),</span>
<span class="line" id="L956">        <span class="tok-comment">// ld #23</span>
</span>
<span class="line" id="L957">        <span class="tok-comment">// fail if a &gt;= 22</span>
</span>
<span class="line" id="L958">        <span class="tok-comment">// fail if a &gt;= x</span>
</span>
<span class="line" id="L959">        Insn.ld_imm(<span class="tok-number">23</span>),</span>
<span class="line" id="L960">        Insn.jmp(.jge, .{ .k = <span class="tok-number">22</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L961">        Insn.ret(.{ .k = <span class="tok-number">47</span> }),</span>
<span class="line" id="L962">        Insn.jmp(.jge, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L963">        Insn.ret(.{ .k = <span class="tok-number">48</span> }),</span>
<span class="line" id="L964">        <span class="tok-comment">// ldx #0b10100</span>
</span>
<span class="line" id="L965">        <span class="tok-comment">// fail if a &amp; 0b10100 == 0</span>
</span>
<span class="line" id="L966">        <span class="tok-comment">// fail if a &amp; x       == 0</span>
</span>
<span class="line" id="L967">        Insn.ldx_imm(<span class="tok-number">0b10100</span>),</span>
<span class="line" id="L968">        Insn.jmp(.jset, .{ .k = <span class="tok-number">0b10100</span> }, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L969">        Insn.ret(.{ .k = <span class="tok-number">47</span> }),</span>
<span class="line" id="L970">        Insn.jmp(.jset, .x, <span class="tok-number">1</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L971">        Insn.ret(.{ .k = <span class="tok-number">48</span> }),</span>
<span class="line" id="L972">        <span class="tok-comment">// ldx #0</span>
</span>
<span class="line" id="L973">        <span class="tok-comment">// fail if a &amp; 0 &gt; 0</span>
</span>
<span class="line" id="L974">        <span class="tok-comment">// fail if a &amp; x &gt; 0</span>
</span>
<span class="line" id="L975">        Insn.ldx_imm(<span class="tok-number">0</span>),</span>
<span class="line" id="L976">        Insn.jmp(.jset, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L977">        Insn.ret(.{ .k = <span class="tok-number">49</span> }),</span>
<span class="line" id="L978">        Insn.jmp(.jset, .x, <span class="tok-number">0</span>, <span class="tok-number">1</span>),</span>
<span class="line" id="L979">        Insn.ret(.{ .k = <span class="tok-number">50</span> }),</span>
<span class="line" id="L980">        Insn.ret(.{ .k = <span class="tok-number">0</span> }),</span>
<span class="line" id="L981">    });</span>
<span class="line" id="L982">    <span class="tok-kw">try</span> expectPass(&amp;some_data, &amp;.{</span>
<span class="line" id="L983">        Insn.ld_imm(<span class="tok-number">35</span>),</span>
<span class="line" id="L984">        Insn.ld_imm(<span class="tok-number">0</span>),</span>
<span class="line" id="L985">        Insn.ret(.a),</span>
<span class="line" id="L986">    });</span>
<span class="line" id="L987"></span>
<span class="line" id="L988">    <span class="tok-comment">// Errors</span>
</span>
<span class="line" id="L989">    <span class="tok-kw">try</span> expectFail(<span class="tok-kw">error</span>.NoReturn, &amp;some_data, &amp;.{</span>
<span class="line" id="L990">        Insn.ld_imm(<span class="tok-number">10</span>),</span>
<span class="line" id="L991">    });</span>
<span class="line" id="L992">    <span class="tok-kw">try</span> expectFail(<span class="tok-kw">error</span>.InvalidOpcode, &amp;some_data, &amp;.{</span>
<span class="line" id="L993">        Insn.stmt(<span class="tok-number">0x7f</span>, <span class="tok-number">0xdeadbeef</span>),</span>
<span class="line" id="L994">    });</span>
<span class="line" id="L995">    <span class="tok-kw">try</span> expectFail(<span class="tok-kw">error</span>.InvalidOffset, &amp;some_data, &amp;.{</span>
<span class="line" id="L996">        Insn.stmt(LD | ABS | W, <span class="tok-number">10</span>),</span>
<span class="line" id="L997">    });</span>
<span class="line" id="L998">    <span class="tok-kw">try</span> expectFail(<span class="tok-kw">error</span>.InvalidLocation, &amp;some_data, &amp;.{</span>
<span class="line" id="L999">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">10</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1000">    });</span>
<span class="line" id="L1001">    <span class="tok-kw">try</span> expectFail(<span class="tok-kw">error</span>.InvalidLocation, &amp;some_data, &amp;.{</span>
<span class="line" id="L1002">        Insn.jmp(.jeq, .{ .k = <span class="tok-number">0</span> }, <span class="tok-number">0</span>, <span class="tok-number">10</span>),</span>
<span class="line" id="L1003">    });</span>
<span class="line" id="L1004">}</span>
<span class="line" id="L1005"></span>
</code></pre></body>
</html>