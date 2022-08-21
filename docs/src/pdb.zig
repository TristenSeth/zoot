<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>pdb.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> coff = std.coff;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> ArrayList = std.ArrayList;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">// Note: most of this is based on information gathered from LLVM source code,</span>
</span>
<span class="line" id="L14"><span class="tok-comment">// documentation and/or contributors.</span>
</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">// https://llvm.org/docs/PDB/DbiStream.html#stream-header</span>
</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DbiStreamHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L18">    VersionSignature: <span class="tok-type">i32</span>,</span>
<span class="line" id="L19">    VersionHeader: <span class="tok-type">u32</span>,</span>
<span class="line" id="L20">    Age: <span class="tok-type">u32</span>,</span>
<span class="line" id="L21">    GlobalStreamIndex: <span class="tok-type">u16</span>,</span>
<span class="line" id="L22">    BuildNumber: <span class="tok-type">u16</span>,</span>
<span class="line" id="L23">    PublicStreamIndex: <span class="tok-type">u16</span>,</span>
<span class="line" id="L24">    PdbDllVersion: <span class="tok-type">u16</span>,</span>
<span class="line" id="L25">    SymRecordStream: <span class="tok-type">u16</span>,</span>
<span class="line" id="L26">    PdbDllRbld: <span class="tok-type">u16</span>,</span>
<span class="line" id="L27">    ModInfoSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L28">    SectionContributionSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L29">    SectionMapSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L30">    SourceInfoSize: <span class="tok-type">i32</span>,</span>
<span class="line" id="L31">    TypeServerSize: <span class="tok-type">i32</span>,</span>
<span class="line" id="L32">    MFCTypeServerIndex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L33">    OptionalDbgHeaderSize: <span class="tok-type">i32</span>,</span>
<span class="line" id="L34">    ECSubstreamSize: <span class="tok-type">i32</span>,</span>
<span class="line" id="L35">    Flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L36">    Machine: <span class="tok-type">u16</span>,</span>
<span class="line" id="L37">    Padding: <span class="tok-type">u32</span>,</span>
<span class="line" id="L38">};</span>
<span class="line" id="L39"></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SectionContribEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L41">    <span class="tok-comment">/// COFF Section index, 1-based</span></span>
<span class="line" id="L42">    Section: <span class="tok-type">u16</span>,</span>
<span class="line" id="L43">    Padding1: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L44">    Offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L45">    Size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L46">    Characteristics: <span class="tok-type">u32</span>,</span>
<span class="line" id="L47">    ModuleIndex: <span class="tok-type">u16</span>,</span>
<span class="line" id="L48">    Padding2: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L49">    DataCrc: <span class="tok-type">u32</span>,</span>
<span class="line" id="L50">    RelocCrc: <span class="tok-type">u32</span>,</span>
<span class="line" id="L51">};</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ModInfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L54">    Unused1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L55">    SectionContr: SectionContribEntry,</span>
<span class="line" id="L56">    Flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L57">    ModuleSymStream: <span class="tok-type">u16</span>,</span>
<span class="line" id="L58">    SymByteSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L59">    C11ByteSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L60">    C13ByteSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L61">    SourceFileCount: <span class="tok-type">u16</span>,</span>
<span class="line" id="L62">    Padding: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L63">    Unused2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L64">    SourceFileNameIndex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L65">    PdbFilePathNameIndex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L66">    <span class="tok-comment">// These fields are variable length</span>
</span>
<span class="line" id="L67">    <span class="tok-comment">//ModuleName: char[],</span>
</span>
<span class="line" id="L68">    <span class="tok-comment">//ObjFileName: char[],</span>
</span>
<span class="line" id="L69">};</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SectionMapHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    <span class="tok-comment">/// Number of segment descriptors</span></span>
<span class="line" id="L73">    Count: <span class="tok-type">u16</span>,</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-comment">/// Number of logical segment descriptors</span></span>
<span class="line" id="L76">    LogCount: <span class="tok-type">u16</span>,</span>
<span class="line" id="L77">};</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SectionMapEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L80">    <span class="tok-comment">/// See the SectionMapEntryFlags enum below.</span></span>
<span class="line" id="L81">    Flags: <span class="tok-type">u16</span>,</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-comment">/// Logical overlay number</span></span>
<span class="line" id="L84">    Ovl: <span class="tok-type">u16</span>,</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">    <span class="tok-comment">/// Group index into descriptor array.</span></span>
<span class="line" id="L87">    Group: <span class="tok-type">u16</span>,</span>
<span class="line" id="L88">    Frame: <span class="tok-type">u16</span>,</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">    <span class="tok-comment">/// Byte index of segment / group name in string table, or 0xFFFF.</span></span>
<span class="line" id="L91">    SectionName: <span class="tok-type">u16</span>,</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-comment">/// Byte index of class in string table, or 0xFFFF.</span></span>
<span class="line" id="L94">    ClassName: <span class="tok-type">u16</span>,</span>
<span class="line" id="L95"></span>
<span class="line" id="L96">    <span class="tok-comment">/// Byte offset of the logical segment within physical segment.  If group is set in flags, this is the offset of the group.</span></span>
<span class="line" id="L97">    Offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L98"></span>
<span class="line" id="L99">    <span class="tok-comment">/// Byte count of the segment or group.</span></span>
<span class="line" id="L100">    SectionLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L101">};</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StreamType = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L104">    Pdb = <span class="tok-number">1</span>,</span>
<span class="line" id="L105">    Tpi = <span class="tok-number">2</span>,</span>
<span class="line" id="L106">    Dbi = <span class="tok-number">3</span>,</span>
<span class="line" id="L107">    Ipi = <span class="tok-number">4</span>,</span>
<span class="line" id="L108">};</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-comment">/// Duplicate copy of SymbolRecordKind, but using the official CV names. Useful</span></span>
<span class="line" id="L111"><span class="tok-comment">/// for reference purposes and when dealing with unknown record types.</span></span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SymbolKind = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L113">    S_COMPILE = <span class="tok-number">1</span>,</span>
<span class="line" id="L114">    S_REGISTER_16t = <span class="tok-number">2</span>,</span>
<span class="line" id="L115">    S_CONSTANT_16t = <span class="tok-number">3</span>,</span>
<span class="line" id="L116">    S_UDT_16t = <span class="tok-number">4</span>,</span>
<span class="line" id="L117">    S_SSEARCH = <span class="tok-number">5</span>,</span>
<span class="line" id="L118">    S_SKIP = <span class="tok-number">7</span>,</span>
<span class="line" id="L119">    S_CVRESERVE = <span class="tok-number">8</span>,</span>
<span class="line" id="L120">    S_OBJNAME_ST = <span class="tok-number">9</span>,</span>
<span class="line" id="L121">    S_ENDARG = <span class="tok-number">10</span>,</span>
<span class="line" id="L122">    S_COBOLUDT_16t = <span class="tok-number">11</span>,</span>
<span class="line" id="L123">    S_MANYREG_16t = <span class="tok-number">12</span>,</span>
<span class="line" id="L124">    S_RETURN = <span class="tok-number">13</span>,</span>
<span class="line" id="L125">    S_ENTRYTHIS = <span class="tok-number">14</span>,</span>
<span class="line" id="L126">    S_BPREL16 = <span class="tok-number">256</span>,</span>
<span class="line" id="L127">    S_LDATA16 = <span class="tok-number">257</span>,</span>
<span class="line" id="L128">    S_GDATA16 = <span class="tok-number">258</span>,</span>
<span class="line" id="L129">    S_PUB16 = <span class="tok-number">259</span>,</span>
<span class="line" id="L130">    S_LPROC16 = <span class="tok-number">260</span>,</span>
<span class="line" id="L131">    S_GPROC16 = <span class="tok-number">261</span>,</span>
<span class="line" id="L132">    S_THUNK16 = <span class="tok-number">262</span>,</span>
<span class="line" id="L133">    S_BLOCK16 = <span class="tok-number">263</span>,</span>
<span class="line" id="L134">    S_WITH16 = <span class="tok-number">264</span>,</span>
<span class="line" id="L135">    S_LABEL16 = <span class="tok-number">265</span>,</span>
<span class="line" id="L136">    S_CEXMODEL16 = <span class="tok-number">266</span>,</span>
<span class="line" id="L137">    S_VFTABLE16 = <span class="tok-number">267</span>,</span>
<span class="line" id="L138">    S_REGREL16 = <span class="tok-number">268</span>,</span>
<span class="line" id="L139">    S_BPREL32_16t = <span class="tok-number">512</span>,</span>
<span class="line" id="L140">    S_LDATA32_16t = <span class="tok-number">513</span>,</span>
<span class="line" id="L141">    S_GDATA32_16t = <span class="tok-number">514</span>,</span>
<span class="line" id="L142">    S_PUB32_16t = <span class="tok-number">515</span>,</span>
<span class="line" id="L143">    S_LPROC32_16t = <span class="tok-number">516</span>,</span>
<span class="line" id="L144">    S_GPROC32_16t = <span class="tok-number">517</span>,</span>
<span class="line" id="L145">    S_THUNK32_ST = <span class="tok-number">518</span>,</span>
<span class="line" id="L146">    S_BLOCK32_ST = <span class="tok-number">519</span>,</span>
<span class="line" id="L147">    S_WITH32_ST = <span class="tok-number">520</span>,</span>
<span class="line" id="L148">    S_LABEL32_ST = <span class="tok-number">521</span>,</span>
<span class="line" id="L149">    S_CEXMODEL32 = <span class="tok-number">522</span>,</span>
<span class="line" id="L150">    S_VFTABLE32_16t = <span class="tok-number">523</span>,</span>
<span class="line" id="L151">    S_REGREL32_16t = <span class="tok-number">524</span>,</span>
<span class="line" id="L152">    S_LTHREAD32_16t = <span class="tok-number">525</span>,</span>
<span class="line" id="L153">    S_GTHREAD32_16t = <span class="tok-number">526</span>,</span>
<span class="line" id="L154">    S_SLINK32 = <span class="tok-number">527</span>,</span>
<span class="line" id="L155">    S_LPROCMIPS_16t = <span class="tok-number">768</span>,</span>
<span class="line" id="L156">    S_GPROCMIPS_16t = <span class="tok-number">769</span>,</span>
<span class="line" id="L157">    S_PROCREF_ST = <span class="tok-number">1024</span>,</span>
<span class="line" id="L158">    S_DATAREF_ST = <span class="tok-number">1025</span>,</span>
<span class="line" id="L159">    S_ALIGN = <span class="tok-number">1026</span>,</span>
<span class="line" id="L160">    S_LPROCREF_ST = <span class="tok-number">1027</span>,</span>
<span class="line" id="L161">    S_OEM = <span class="tok-number">1028</span>,</span>
<span class="line" id="L162">    S_TI16_MAX = <span class="tok-number">4096</span>,</span>
<span class="line" id="L163">    S_REGISTER_ST = <span class="tok-number">4097</span>,</span>
<span class="line" id="L164">    S_CONSTANT_ST = <span class="tok-number">4098</span>,</span>
<span class="line" id="L165">    S_UDT_ST = <span class="tok-number">4099</span>,</span>
<span class="line" id="L166">    S_COBOLUDT_ST = <span class="tok-number">4100</span>,</span>
<span class="line" id="L167">    S_MANYREG_ST = <span class="tok-number">4101</span>,</span>
<span class="line" id="L168">    S_BPREL32_ST = <span class="tok-number">4102</span>,</span>
<span class="line" id="L169">    S_LDATA32_ST = <span class="tok-number">4103</span>,</span>
<span class="line" id="L170">    S_GDATA32_ST = <span class="tok-number">4104</span>,</span>
<span class="line" id="L171">    S_PUB32_ST = <span class="tok-number">4105</span>,</span>
<span class="line" id="L172">    S_LPROC32_ST = <span class="tok-number">4106</span>,</span>
<span class="line" id="L173">    S_GPROC32_ST = <span class="tok-number">4107</span>,</span>
<span class="line" id="L174">    S_VFTABLE32 = <span class="tok-number">4108</span>,</span>
<span class="line" id="L175">    S_REGREL32_ST = <span class="tok-number">4109</span>,</span>
<span class="line" id="L176">    S_LTHREAD32_ST = <span class="tok-number">4110</span>,</span>
<span class="line" id="L177">    S_GTHREAD32_ST = <span class="tok-number">4111</span>,</span>
<span class="line" id="L178">    S_LPROCMIPS_ST = <span class="tok-number">4112</span>,</span>
<span class="line" id="L179">    S_GPROCMIPS_ST = <span class="tok-number">4113</span>,</span>
<span class="line" id="L180">    S_COMPILE2_ST = <span class="tok-number">4115</span>,</span>
<span class="line" id="L181">    S_MANYREG2_ST = <span class="tok-number">4116</span>,</span>
<span class="line" id="L182">    S_LPROCIA64_ST = <span class="tok-number">4117</span>,</span>
<span class="line" id="L183">    S_GPROCIA64_ST = <span class="tok-number">4118</span>,</span>
<span class="line" id="L184">    S_LOCALSLOT_ST = <span class="tok-number">4119</span>,</span>
<span class="line" id="L185">    S_PARAMSLOT_ST = <span class="tok-number">4120</span>,</span>
<span class="line" id="L186">    S_ANNOTATION = <span class="tok-number">4121</span>,</span>
<span class="line" id="L187">    S_GMANPROC_ST = <span class="tok-number">4122</span>,</span>
<span class="line" id="L188">    S_LMANPROC_ST = <span class="tok-number">4123</span>,</span>
<span class="line" id="L189">    S_RESERVED1 = <span class="tok-number">4124</span>,</span>
<span class="line" id="L190">    S_RESERVED2 = <span class="tok-number">4125</span>,</span>
<span class="line" id="L191">    S_RESERVED3 = <span class="tok-number">4126</span>,</span>
<span class="line" id="L192">    S_RESERVED4 = <span class="tok-number">4127</span>,</span>
<span class="line" id="L193">    S_LMANDATA_ST = <span class="tok-number">4128</span>,</span>
<span class="line" id="L194">    S_GMANDATA_ST = <span class="tok-number">4129</span>,</span>
<span class="line" id="L195">    S_MANFRAMEREL_ST = <span class="tok-number">4130</span>,</span>
<span class="line" id="L196">    S_MANREGISTER_ST = <span class="tok-number">4131</span>,</span>
<span class="line" id="L197">    S_MANSLOT_ST = <span class="tok-number">4132</span>,</span>
<span class="line" id="L198">    S_MANMANYREG_ST = <span class="tok-number">4133</span>,</span>
<span class="line" id="L199">    S_MANREGREL_ST = <span class="tok-number">4134</span>,</span>
<span class="line" id="L200">    S_MANMANYREG2_ST = <span class="tok-number">4135</span>,</span>
<span class="line" id="L201">    S_MANTYPREF = <span class="tok-number">4136</span>,</span>
<span class="line" id="L202">    S_UNAMESPACE_ST = <span class="tok-number">4137</span>,</span>
<span class="line" id="L203">    S_ST_MAX = <span class="tok-number">4352</span>,</span>
<span class="line" id="L204">    S_WITH32 = <span class="tok-number">4356</span>,</span>
<span class="line" id="L205">    S_MANYREG = <span class="tok-number">4362</span>,</span>
<span class="line" id="L206">    S_LPROCMIPS = <span class="tok-number">4372</span>,</span>
<span class="line" id="L207">    S_GPROCMIPS = <span class="tok-number">4373</span>,</span>
<span class="line" id="L208">    S_MANYREG2 = <span class="tok-number">4375</span>,</span>
<span class="line" id="L209">    S_LPROCIA64 = <span class="tok-number">4376</span>,</span>
<span class="line" id="L210">    S_GPROCIA64 = <span class="tok-number">4377</span>,</span>
<span class="line" id="L211">    S_LOCALSLOT = <span class="tok-number">4378</span>,</span>
<span class="line" id="L212">    S_PARAMSLOT = <span class="tok-number">4379</span>,</span>
<span class="line" id="L213">    S_MANFRAMEREL = <span class="tok-number">4382</span>,</span>
<span class="line" id="L214">    S_MANREGISTER = <span class="tok-number">4383</span>,</span>
<span class="line" id="L215">    S_MANSLOT = <span class="tok-number">4384</span>,</span>
<span class="line" id="L216">    S_MANMANYREG = <span class="tok-number">4385</span>,</span>
<span class="line" id="L217">    S_MANREGREL = <span class="tok-number">4386</span>,</span>
<span class="line" id="L218">    S_MANMANYREG2 = <span class="tok-number">4387</span>,</span>
<span class="line" id="L219">    S_UNAMESPACE = <span class="tok-number">4388</span>,</span>
<span class="line" id="L220">    S_DATAREF = <span class="tok-number">4390</span>,</span>
<span class="line" id="L221">    S_ANNOTATIONREF = <span class="tok-number">4392</span>,</span>
<span class="line" id="L222">    S_TOKENREF = <span class="tok-number">4393</span>,</span>
<span class="line" id="L223">    S_GMANPROC = <span class="tok-number">4394</span>,</span>
<span class="line" id="L224">    S_LMANPROC = <span class="tok-number">4395</span>,</span>
<span class="line" id="L225">    S_ATTR_FRAMEREL = <span class="tok-number">4398</span>,</span>
<span class="line" id="L226">    S_ATTR_REGISTER = <span class="tok-number">4399</span>,</span>
<span class="line" id="L227">    S_ATTR_REGREL = <span class="tok-number">4400</span>,</span>
<span class="line" id="L228">    S_ATTR_MANYREG = <span class="tok-number">4401</span>,</span>
<span class="line" id="L229">    S_SEPCODE = <span class="tok-number">4402</span>,</span>
<span class="line" id="L230">    S_LOCAL_2005 = <span class="tok-number">4403</span>,</span>
<span class="line" id="L231">    S_DEFRANGE_2005 = <span class="tok-number">4404</span>,</span>
<span class="line" id="L232">    S_DEFRANGE2_2005 = <span class="tok-number">4405</span>,</span>
<span class="line" id="L233">    S_DISCARDED = <span class="tok-number">4411</span>,</span>
<span class="line" id="L234">    S_LPROCMIPS_ID = <span class="tok-number">4424</span>,</span>
<span class="line" id="L235">    S_GPROCMIPS_ID = <span class="tok-number">4425</span>,</span>
<span class="line" id="L236">    S_LPROCIA64_ID = <span class="tok-number">4426</span>,</span>
<span class="line" id="L237">    S_GPROCIA64_ID = <span class="tok-number">4427</span>,</span>
<span class="line" id="L238">    S_DEFRANGE_HLSL = <span class="tok-number">4432</span>,</span>
<span class="line" id="L239">    S_GDATA_HLSL = <span class="tok-number">4433</span>,</span>
<span class="line" id="L240">    S_LDATA_HLSL = <span class="tok-number">4434</span>,</span>
<span class="line" id="L241">    S_LOCAL_DPC_GROUPSHARED = <span class="tok-number">4436</span>,</span>
<span class="line" id="L242">    S_DEFRANGE_DPC_PTR_TAG = <span class="tok-number">4439</span>,</span>
<span class="line" id="L243">    S_DPC_SYM_TAG_MAP = <span class="tok-number">4440</span>,</span>
<span class="line" id="L244">    S_ARMSWITCHTABLE = <span class="tok-number">4441</span>,</span>
<span class="line" id="L245">    S_POGODATA = <span class="tok-number">4444</span>,</span>
<span class="line" id="L246">    S_INLINESITE2 = <span class="tok-number">4445</span>,</span>
<span class="line" id="L247">    S_MOD_TYPEREF = <span class="tok-number">4447</span>,</span>
<span class="line" id="L248">    S_REF_MINIPDB = <span class="tok-number">4448</span>,</span>
<span class="line" id="L249">    S_PDBMAP = <span class="tok-number">4449</span>,</span>
<span class="line" id="L250">    S_GDATA_HLSL32 = <span class="tok-number">4450</span>,</span>
<span class="line" id="L251">    S_LDATA_HLSL32 = <span class="tok-number">4451</span>,</span>
<span class="line" id="L252">    S_GDATA_HLSL32_EX = <span class="tok-number">4452</span>,</span>
<span class="line" id="L253">    S_LDATA_HLSL32_EX = <span class="tok-number">4453</span>,</span>
<span class="line" id="L254">    S_FASTLINK = <span class="tok-number">4455</span>,</span>
<span class="line" id="L255">    S_INLINEES = <span class="tok-number">4456</span>,</span>
<span class="line" id="L256">    S_END = <span class="tok-number">6</span>,</span>
<span class="line" id="L257">    S_INLINESITE_END = <span class="tok-number">4430</span>,</span>
<span class="line" id="L258">    S_PROC_ID_END = <span class="tok-number">4431</span>,</span>
<span class="line" id="L259">    S_THUNK32 = <span class="tok-number">4354</span>,</span>
<span class="line" id="L260">    S_TRAMPOLINE = <span class="tok-number">4396</span>,</span>
<span class="line" id="L261">    S_SECTION = <span class="tok-number">4406</span>,</span>
<span class="line" id="L262">    S_COFFGROUP = <span class="tok-number">4407</span>,</span>
<span class="line" id="L263">    S_EXPORT = <span class="tok-number">4408</span>,</span>
<span class="line" id="L264">    S_LPROC32 = <span class="tok-number">4367</span>,</span>
<span class="line" id="L265">    S_GPROC32 = <span class="tok-number">4368</span>,</span>
<span class="line" id="L266">    S_LPROC32_ID = <span class="tok-number">4422</span>,</span>
<span class="line" id="L267">    S_GPROC32_ID = <span class="tok-number">4423</span>,</span>
<span class="line" id="L268">    S_LPROC32_DPC = <span class="tok-number">4437</span>,</span>
<span class="line" id="L269">    S_LPROC32_DPC_ID = <span class="tok-number">4438</span>,</span>
<span class="line" id="L270">    S_REGISTER = <span class="tok-number">4358</span>,</span>
<span class="line" id="L271">    S_PUB32 = <span class="tok-number">4366</span>,</span>
<span class="line" id="L272">    S_PROCREF = <span class="tok-number">4389</span>,</span>
<span class="line" id="L273">    S_LPROCREF = <span class="tok-number">4391</span>,</span>
<span class="line" id="L274">    S_ENVBLOCK = <span class="tok-number">4413</span>,</span>
<span class="line" id="L275">    S_INLINESITE = <span class="tok-number">4429</span>,</span>
<span class="line" id="L276">    S_LOCAL = <span class="tok-number">4414</span>,</span>
<span class="line" id="L277">    S_DEFRANGE = <span class="tok-number">4415</span>,</span>
<span class="line" id="L278">    S_DEFRANGE_SUBFIELD = <span class="tok-number">4416</span>,</span>
<span class="line" id="L279">    S_DEFRANGE_REGISTER = <span class="tok-number">4417</span>,</span>
<span class="line" id="L280">    S_DEFRANGE_FRAMEPOINTER_REL = <span class="tok-number">4418</span>,</span>
<span class="line" id="L281">    S_DEFRANGE_SUBFIELD_REGISTER = <span class="tok-number">4419</span>,</span>
<span class="line" id="L282">    S_DEFRANGE_FRAMEPOINTER_REL_FULL_SCOPE = <span class="tok-number">4420</span>,</span>
<span class="line" id="L283">    S_DEFRANGE_REGISTER_REL = <span class="tok-number">4421</span>,</span>
<span class="line" id="L284">    S_BLOCK32 = <span class="tok-number">4355</span>,</span>
<span class="line" id="L285">    S_LABEL32 = <span class="tok-number">4357</span>,</span>
<span class="line" id="L286">    S_OBJNAME = <span class="tok-number">4353</span>,</span>
<span class="line" id="L287">    S_COMPILE2 = <span class="tok-number">4374</span>,</span>
<span class="line" id="L288">    S_COMPILE3 = <span class="tok-number">4412</span>,</span>
<span class="line" id="L289">    S_FRAMEPROC = <span class="tok-number">4114</span>,</span>
<span class="line" id="L290">    S_CALLSITEINFO = <span class="tok-number">4409</span>,</span>
<span class="line" id="L291">    S_FILESTATIC = <span class="tok-number">4435</span>,</span>
<span class="line" id="L292">    S_HEAPALLOCSITE = <span class="tok-number">4446</span>,</span>
<span class="line" id="L293">    S_FRAMECOOKIE = <span class="tok-number">4410</span>,</span>
<span class="line" id="L294">    S_CALLEES = <span class="tok-number">4442</span>,</span>
<span class="line" id="L295">    S_CALLERS = <span class="tok-number">4443</span>,</span>
<span class="line" id="L296">    S_UDT = <span class="tok-number">4360</span>,</span>
<span class="line" id="L297">    S_COBOLUDT = <span class="tok-number">4361</span>,</span>
<span class="line" id="L298">    S_BUILDINFO = <span class="tok-number">4428</span>,</span>
<span class="line" id="L299">    S_BPREL32 = <span class="tok-number">4363</span>,</span>
<span class="line" id="L300">    S_REGREL32 = <span class="tok-number">4369</span>,</span>
<span class="line" id="L301">    S_CONSTANT = <span class="tok-number">4359</span>,</span>
<span class="line" id="L302">    S_MANCONSTANT = <span class="tok-number">4397</span>,</span>
<span class="line" id="L303">    S_LDATA32 = <span class="tok-number">4364</span>,</span>
<span class="line" id="L304">    S_GDATA32 = <span class="tok-number">4365</span>,</span>
<span class="line" id="L305">    S_LMANDATA = <span class="tok-number">4380</span>,</span>
<span class="line" id="L306">    S_GMANDATA = <span class="tok-number">4381</span>,</span>
<span class="line" id="L307">    S_LTHREAD32 = <span class="tok-number">4370</span>,</span>
<span class="line" id="L308">    S_GTHREAD32 = <span class="tok-number">4371</span>,</span>
<span class="line" id="L309">};</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TypeIndex = <span class="tok-type">u32</span>;</span>
<span class="line" id="L312"></span>
<span class="line" id="L313"><span class="tok-comment">// TODO According to this header:</span>
</span>
<span class="line" id="L314"><span class="tok-comment">// https://github.com/microsoft/microsoft-pdb/blob/082c5290e5aff028ae84e43affa8be717aa7af73/include/cvinfo.h#L3722</span>
</span>
<span class="line" id="L315"><span class="tok-comment">// we should define RecordPrefix as part of the ProcSym structure.</span>
</span>
<span class="line" id="L316"><span class="tok-comment">// This might be important when we start generating PDB in self-hosted with our own PE linker.</span>
</span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProcSym = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L318">    Parent: <span class="tok-type">u32</span>,</span>
<span class="line" id="L319">    End: <span class="tok-type">u32</span>,</span>
<span class="line" id="L320">    Next: <span class="tok-type">u32</span>,</span>
<span class="line" id="L321">    CodeSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L322">    DbgStart: <span class="tok-type">u32</span>,</span>
<span class="line" id="L323">    DbgEnd: <span class="tok-type">u32</span>,</span>
<span class="line" id="L324">    FunctionType: TypeIndex,</span>
<span class="line" id="L325">    CodeOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L326">    Segment: <span class="tok-type">u16</span>,</span>
<span class="line" id="L327">    Flags: ProcSymFlags,</span>
<span class="line" id="L328">    Name: [<span class="tok-number">1</span>]<span class="tok-type">u8</span>, <span class="tok-comment">// null-terminated</span>
</span>
<span class="line" id="L329">};</span>
<span class="line" id="L330"></span>
<span class="line" id="L331"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ProcSymFlags = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L332">    HasFP: <span class="tok-type">bool</span>,</span>
<span class="line" id="L333">    HasIRET: <span class="tok-type">bool</span>,</span>
<span class="line" id="L334">    HasFRET: <span class="tok-type">bool</span>,</span>
<span class="line" id="L335">    IsNoReturn: <span class="tok-type">bool</span>,</span>
<span class="line" id="L336">    IsUnreachable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L337">    HasCustomCallingConv: <span class="tok-type">bool</span>,</span>
<span class="line" id="L338">    IsNoInline: <span class="tok-type">bool</span>,</span>
<span class="line" id="L339">    HasOptimizedDebugInfo: <span class="tok-type">bool</span>,</span>
<span class="line" id="L340">};</span>
<span class="line" id="L341"></span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SectionContrSubstreamVersion = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L343">    Ver60 = <span class="tok-number">0xeffe0000</span> + <span class="tok-number">19970605</span>,</span>
<span class="line" id="L344">    V2 = <span class="tok-number">0xeffe0000</span> + <span class="tok-number">20140516</span>,</span>
<span class="line" id="L345">    _,</span>
<span class="line" id="L346">};</span>
<span class="line" id="L347"></span>
<span class="line" id="L348"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RecordPrefix = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L349">    <span class="tok-comment">/// Record length, starting from &amp;RecordKind.</span></span>
<span class="line" id="L350">    RecordLen: <span class="tok-type">u16</span>,</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">    <span class="tok-comment">/// Record kind enum (SymRecordKind or TypeRecordKind)</span></span>
<span class="line" id="L353">    RecordKind: SymbolKind,</span>
<span class="line" id="L354">};</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-comment">/// The following variable length array appears immediately after the header.</span></span>
<span class="line" id="L357"><span class="tok-comment">/// The structure definition follows.</span></span>
<span class="line" id="L358"><span class="tok-comment">/// LineBlockFragmentHeader Blocks[]</span></span>
<span class="line" id="L359"><span class="tok-comment">/// Each `LineBlockFragmentHeader` as specified below.</span></span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LineFragmentHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L361">    <span class="tok-comment">/// Code offset of line contribution.</span></span>
<span class="line" id="L362">    RelocOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">    <span class="tok-comment">/// Code segment of line contribution.</span></span>
<span class="line" id="L365">    RelocSegment: <span class="tok-type">u16</span>,</span>
<span class="line" id="L366">    Flags: LineFlags,</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-comment">/// Code size of this line contribution.</span></span>
<span class="line" id="L369">    CodeSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L370">};</span>
<span class="line" id="L371"></span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LineFlags = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L373">    <span class="tok-comment">/// CV_LINES_HAVE_COLUMNS</span></span>
<span class="line" id="L374">    LF_HaveColumns: <span class="tok-type">bool</span>,</span>
<span class="line" id="L375">    unused: <span class="tok-type">u15</span>,</span>
<span class="line" id="L376">};</span>
<span class="line" id="L377"></span>
<span class="line" id="L378"><span class="tok-comment">/// The following two variable length arrays appear immediately after the</span></span>
<span class="line" id="L379"><span class="tok-comment">/// header.  The structure definitions follow.</span></span>
<span class="line" id="L380"><span class="tok-comment">/// LineNumberEntry   Lines[NumLines];</span></span>
<span class="line" id="L381"><span class="tok-comment">/// ColumnNumberEntry Columns[NumLines];</span></span>
<span class="line" id="L382"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LineBlockFragmentHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L383">    <span class="tok-comment">/// Offset of FileChecksum entry in File</span></span>
<span class="line" id="L384">    <span class="tok-comment">/// checksums buffer.  The checksum entry then</span></span>
<span class="line" id="L385">    <span class="tok-comment">/// contains another offset into the string</span></span>
<span class="line" id="L386">    <span class="tok-comment">/// table of the actual name.</span></span>
<span class="line" id="L387">    NameIndex: <span class="tok-type">u32</span>,</span>
<span class="line" id="L388">    NumLines: <span class="tok-type">u32</span>,</span>
<span class="line" id="L389"></span>
<span class="line" id="L390">    <span class="tok-comment">/// code size of block, in bytes</span></span>
<span class="line" id="L391">    BlockSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L392">};</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LineNumberEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L395">    <span class="tok-comment">/// Offset to start of code bytes for line number</span></span>
<span class="line" id="L396">    Offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L397">    Flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    <span class="tok-comment">/// TODO runtime crash when I make the actual type of Flags this</span></span>
<span class="line" id="L400">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Flags = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L401">        <span class="tok-comment">/// Start line number</span></span>
<span class="line" id="L402">        Start: <span class="tok-type">u24</span>,</span>
<span class="line" id="L403">        <span class="tok-comment">/// Delta of lines to the end of the expression. Still unclear.</span></span>
<span class="line" id="L404">        <span class="tok-comment">// TODO figure out the point of this field.</span>
</span>
<span class="line" id="L405">        End: <span class="tok-type">u7</span>,</span>
<span class="line" id="L406">        IsStatement: <span class="tok-type">bool</span>,</span>
<span class="line" id="L407">    };</span>
<span class="line" id="L408">};</span>
<span class="line" id="L409"></span>
<span class="line" id="L410"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ColumnNumberEntry = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L411">    StartColumn: <span class="tok-type">u16</span>,</span>
<span class="line" id="L412">    EndColumn: <span class="tok-type">u16</span>,</span>
<span class="line" id="L413">};</span>
<span class="line" id="L414"></span>
<span class="line" id="L415"><span class="tok-comment">/// Checksum bytes follow.</span></span>
<span class="line" id="L416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FileChecksumEntryHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L417">    <span class="tok-comment">/// Byte offset of filename in global string table.</span></span>
<span class="line" id="L418">    FileNameOffset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">    <span class="tok-comment">/// Number of bytes of checksum.</span></span>
<span class="line" id="L421">    ChecksumSize: <span class="tok-type">u8</span>,</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">    <span class="tok-comment">/// FileChecksumKind</span></span>
<span class="line" id="L424">    ChecksumKind: <span class="tok-type">u8</span>,</span>
<span class="line" id="L425">};</span>
<span class="line" id="L426"></span>
<span class="line" id="L427"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DebugSubsectionKind = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L428">    None = <span class="tok-number">0</span>,</span>
<span class="line" id="L429">    Symbols = <span class="tok-number">0xf1</span>,</span>
<span class="line" id="L430">    Lines = <span class="tok-number">0xf2</span>,</span>
<span class="line" id="L431">    StringTable = <span class="tok-number">0xf3</span>,</span>
<span class="line" id="L432">    FileChecksums = <span class="tok-number">0xf4</span>,</span>
<span class="line" id="L433">    FrameData = <span class="tok-number">0xf5</span>,</span>
<span class="line" id="L434">    InlineeLines = <span class="tok-number">0xf6</span>,</span>
<span class="line" id="L435">    CrossScopeImports = <span class="tok-number">0xf7</span>,</span>
<span class="line" id="L436">    CrossScopeExports = <span class="tok-number">0xf8</span>,</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-comment">// These appear to relate to .Net assembly info.</span>
</span>
<span class="line" id="L439">    ILLines = <span class="tok-number">0xf9</span>,</span>
<span class="line" id="L440">    FuncMDTokenMap = <span class="tok-number">0xfa</span>,</span>
<span class="line" id="L441">    TypeMDTokenMap = <span class="tok-number">0xfb</span>,</span>
<span class="line" id="L442">    MergedAssemblyInput = <span class="tok-number">0xfc</span>,</span>
<span class="line" id="L443"></span>
<span class="line" id="L444">    CoffSymbolRVA = <span class="tok-number">0xfd</span>,</span>
<span class="line" id="L445">};</span>
<span class="line" id="L446"></span>
<span class="line" id="L447"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DebugSubsectionHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L448">    <span class="tok-comment">/// codeview::DebugSubsectionKind enum</span></span>
<span class="line" id="L449">    Kind: DebugSubsectionKind,</span>
<span class="line" id="L450"></span>
<span class="line" id="L451">    <span class="tok-comment">/// number of bytes occupied by this record.</span></span>
<span class="line" id="L452">    Length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L453">};</span>
<span class="line" id="L454"></span>
<span class="line" id="L455"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PDBStringTableHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L456">    <span class="tok-comment">/// PDBStringTableSignature</span></span>
<span class="line" id="L457">    Signature: <span class="tok-type">u32</span>,</span>
<span class="line" id="L458"></span>
<span class="line" id="L459">    <span class="tok-comment">/// 1 or 2</span></span>
<span class="line" id="L460">    HashVersion: <span class="tok-type">u32</span>,</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-comment">/// Number of bytes of names buffer.</span></span>
<span class="line" id="L463">    ByteSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L464">};</span>
<span class="line" id="L465"></span>
<span class="line" id="L466"><span class="tok-kw">fn</span> <span class="tok-fn">readSparseBitVector</span>(stream: <span class="tok-kw">anytype</span>, allocator: mem.Allocator) ![]<span class="tok-type">u32</span> {</span>
<span class="line" id="L467">    <span class="tok-kw">const</span> num_words = <span class="tok-kw">try</span> stream.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L468">    <span class="tok-kw">var</span> list = ArrayList(<span class="tok-type">u32</span>).init(allocator);</span>
<span class="line" id="L469">    <span class="tok-kw">errdefer</span> list.deinit();</span>
<span class="line" id="L470">    <span class="tok-kw">var</span> word_i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L471">    <span class="tok-kw">while</span> (word_i != num_words) : (word_i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L472">        <span class="tok-kw">const</span> word = <span class="tok-kw">try</span> stream.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L473">        <span class="tok-kw">var</span> bit_i: <span class="tok-type">u5</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L474">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (bit_i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L475">            <span class="tok-kw">if</span> (word &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">1</span>) &lt;&lt; bit_i) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L476">                <span class="tok-kw">try</span> list.append(word_i * <span class="tok-number">32</span> + bit_i);</span>
<span class="line" id="L477">            }</span>
<span class="line" id="L478">            <span class="tok-kw">if</span> (bit_i == std.math.maxInt(<span class="tok-type">u5</span>)) <span class="tok-kw">break</span>;</span>
<span class="line" id="L479">        }</span>
<span class="line" id="L480">    }</span>
<span class="line" id="L481">    <span class="tok-kw">return</span> list.toOwnedSlice();</span>
<span class="line" id="L482">}</span>
<span class="line" id="L483"></span>
<span class="line" id="L484"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Pdb = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L485">    in_file: File,</span>
<span class="line" id="L486">    msf: Msf,</span>
<span class="line" id="L487">    allocator: mem.Allocator,</span>
<span class="line" id="L488">    string_table: ?*MsfStream,</span>
<span class="line" id="L489">    dbi: ?*MsfStream,</span>
<span class="line" id="L490">    modules: []Module,</span>
<span class="line" id="L491">    sect_contribs: []SectionContribEntry,</span>
<span class="line" id="L492">    guid: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L493">    age: <span class="tok-type">u32</span>,</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Module = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L496">        mod_info: ModInfo,</span>
<span class="line" id="L497">        module_name: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L498">        obj_file_name: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L499">        <span class="tok-comment">// The fields below are filled on demand.</span>
</span>
<span class="line" id="L500">        populated: <span class="tok-type">bool</span>,</span>
<span class="line" id="L501">        symbols: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L502">        subsect_info: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L503">        checksum_offset: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Module, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L506">            allocator.free(self.module_name);</span>
<span class="line" id="L507">            allocator.free(self.obj_file_name);</span>
<span class="line" id="L508">            <span class="tok-kw">if</span> (self.populated) {</span>
<span class="line" id="L509">                allocator.free(self.symbols);</span>
<span class="line" id="L510">                allocator.free(self.subsect_info);</span>
<span class="line" id="L511">            }</span>
<span class="line" id="L512">        }</span>
<span class="line" id="L513">    };</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Pdb {</span>
<span class="line" id="L516">        <span class="tok-kw">const</span> file = <span class="tok-kw">try</span> fs.cwd().openFile(path, .{ .intended_io_mode = .blocking });</span>
<span class="line" id="L517">        <span class="tok-kw">errdefer</span> file.close();</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">        <span class="tok-kw">return</span> Pdb{</span>
<span class="line" id="L520">            .in_file = file,</span>
<span class="line" id="L521">            .allocator = allocator,</span>
<span class="line" id="L522">            .string_table = <span class="tok-null">null</span>,</span>
<span class="line" id="L523">            .dbi = <span class="tok-null">null</span>,</span>
<span class="line" id="L524">            .msf = <span class="tok-kw">try</span> Msf.init(allocator, file),</span>
<span class="line" id="L525">            .modules = &amp;[_]Module{},</span>
<span class="line" id="L526">            .sect_contribs = &amp;[_]SectionContribEntry{},</span>
<span class="line" id="L527">            .guid = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L528">            .age = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L529">        };</span>
<span class="line" id="L530">    }</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Pdb) <span class="tok-type">void</span> {</span>
<span class="line" id="L533">        self.in_file.close();</span>
<span class="line" id="L534">        self.msf.deinit(self.allocator);</span>
<span class="line" id="L535">        <span class="tok-kw">for</span> (self.modules) |*module| {</span>
<span class="line" id="L536">            module.deinit(self.allocator);</span>
<span class="line" id="L537">        }</span>
<span class="line" id="L538">        self.allocator.free(self.modules);</span>
<span class="line" id="L539">        self.allocator.free(self.sect_contribs);</span>
<span class="line" id="L540">    }</span>
<span class="line" id="L541"></span>
<span class="line" id="L542">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseDbiStream</span>(self: *Pdb) !<span class="tok-type">void</span> {</span>
<span class="line" id="L543">        <span class="tok-kw">var</span> stream = self.getStream(StreamType.Dbi) <span class="tok-kw">orelse</span></span>
<span class="line" id="L544">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L545">        <span class="tok-kw">const</span> reader = stream.reader();</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">        <span class="tok-kw">const</span> header = <span class="tok-kw">try</span> reader.readStruct(DbiStreamHeader);</span>
<span class="line" id="L548">        <span class="tok-kw">if</span> (header.VersionHeader != <span class="tok-number">19990903</span>) <span class="tok-comment">// V70, only value observed by LLVM team</span>
</span>
<span class="line" id="L549">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownPDBVersion;</span>
<span class="line" id="L550">        <span class="tok-comment">// if (header.Age != age)</span>
</span>
<span class="line" id="L551">        <span class="tok-comment">//     return error.UnmatchingPDB;</span>
</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">        <span class="tok-kw">const</span> mod_info_size = header.ModInfoSize;</span>
<span class="line" id="L554">        <span class="tok-kw">const</span> section_contrib_size = header.SectionContributionSize;</span>
<span class="line" id="L555"></span>
<span class="line" id="L556">        <span class="tok-kw">var</span> modules = ArrayList(Module).init(self.allocator);</span>
<span class="line" id="L557">        <span class="tok-kw">errdefer</span> modules.deinit();</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">        <span class="tok-comment">// Module Info Substream</span>
</span>
<span class="line" id="L560">        <span class="tok-kw">var</span> mod_info_offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L561">        <span class="tok-kw">while</span> (mod_info_offset != mod_info_size) {</span>
<span class="line" id="L562">            <span class="tok-kw">const</span> mod_info = <span class="tok-kw">try</span> reader.readStruct(ModInfo);</span>
<span class="line" id="L563">            <span class="tok-kw">var</span> this_record_len: <span class="tok-type">usize</span> = <span class="tok-builtin">@sizeOf</span>(ModInfo);</span>
<span class="line" id="L564"></span>
<span class="line" id="L565">            <span class="tok-kw">const</span> module_name = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(self.allocator, <span class="tok-number">0</span>, <span class="tok-number">1024</span>);</span>
<span class="line" id="L566">            <span class="tok-kw">errdefer</span> self.allocator.free(module_name);</span>
<span class="line" id="L567">            this_record_len += module_name.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L568"></span>
<span class="line" id="L569">            <span class="tok-kw">const</span> obj_file_name = <span class="tok-kw">try</span> reader.readUntilDelimiterAlloc(self.allocator, <span class="tok-number">0</span>, <span class="tok-number">1024</span>);</span>
<span class="line" id="L570">            <span class="tok-kw">errdefer</span> self.allocator.free(obj_file_name);</span>
<span class="line" id="L571">            this_record_len += obj_file_name.len + <span class="tok-number">1</span>;</span>
<span class="line" id="L572"></span>
<span class="line" id="L573">            <span class="tok-kw">if</span> (this_record_len % <span class="tok-number">4</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L574">                <span class="tok-kw">const</span> round_to_next_4 = (this_record_len | <span class="tok-number">0x3</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L575">                <span class="tok-kw">const</span> march_forward_bytes = round_to_next_4 - this_record_len;</span>
<span class="line" id="L576">                <span class="tok-kw">try</span> stream.seekBy(<span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, march_forward_bytes));</span>
<span class="line" id="L577">                this_record_len += march_forward_bytes;</span>
<span class="line" id="L578">            }</span>
<span class="line" id="L579"></span>
<span class="line" id="L580">            <span class="tok-kw">try</span> modules.append(Module{</span>
<span class="line" id="L581">                .mod_info = mod_info,</span>
<span class="line" id="L582">                .module_name = module_name,</span>
<span class="line" id="L583">                .obj_file_name = obj_file_name,</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">                .populated = <span class="tok-null">false</span>,</span>
<span class="line" id="L586">                .symbols = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L587">                .subsect_info = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L588">                .checksum_offset = <span class="tok-null">null</span>,</span>
<span class="line" id="L589">            });</span>
<span class="line" id="L590"></span>
<span class="line" id="L591">            mod_info_offset += this_record_len;</span>
<span class="line" id="L592">            <span class="tok-kw">if</span> (mod_info_offset &gt; mod_info_size)</span>
<span class="line" id="L593">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">        <span class="tok-comment">// Section Contribution Substream</span>
</span>
<span class="line" id="L597">        <span class="tok-kw">var</span> sect_contribs = ArrayList(SectionContribEntry).init(self.allocator);</span>
<span class="line" id="L598">        <span class="tok-kw">errdefer</span> sect_contribs.deinit();</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">        <span class="tok-kw">var</span> sect_cont_offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L601">        <span class="tok-kw">if</span> (section_contrib_size != <span class="tok-number">0</span>) {</span>
<span class="line" id="L602">            <span class="tok-kw">const</span> version = reader.readEnum(SectionContrSubstreamVersion, .Little) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L603">                <span class="tok-kw">error</span>.InvalidValue =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L604">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L605">            };</span>
<span class="line" id="L606">            _ = version;</span>
<span class="line" id="L607">            sect_cont_offset += <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>);</span>
<span class="line" id="L608">        }</span>
<span class="line" id="L609">        <span class="tok-kw">while</span> (sect_cont_offset != section_contrib_size) {</span>
<span class="line" id="L610">            <span class="tok-kw">const</span> entry = <span class="tok-kw">try</span> sect_contribs.addOne();</span>
<span class="line" id="L611">            entry.* = <span class="tok-kw">try</span> reader.readStruct(SectionContribEntry);</span>
<span class="line" id="L612">            sect_cont_offset += <span class="tok-builtin">@sizeOf</span>(SectionContribEntry);</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">            <span class="tok-kw">if</span> (sect_cont_offset &gt; section_contrib_size)</span>
<span class="line" id="L615">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L616">        }</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">        self.modules = modules.toOwnedSlice();</span>
<span class="line" id="L619">        self.sect_contribs = sect_contribs.toOwnedSlice();</span>
<span class="line" id="L620">    }</span>
<span class="line" id="L621"></span>
<span class="line" id="L622">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parseInfoStream</span>(self: *Pdb) !<span class="tok-type">void</span> {</span>
<span class="line" id="L623">        <span class="tok-kw">var</span> stream = self.getStream(StreamType.Pdb) <span class="tok-kw">orelse</span></span>
<span class="line" id="L624">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L625">        <span class="tok-kw">const</span> reader = stream.reader();</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">        <span class="tok-comment">// Parse the InfoStreamHeader.</span>
</span>
<span class="line" id="L628">        <span class="tok-kw">const</span> version = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L629">        <span class="tok-kw">const</span> signature = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L630">        _ = signature;</span>
<span class="line" id="L631">        <span class="tok-kw">const</span> age = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L632">        <span class="tok-kw">const</span> guid = <span class="tok-kw">try</span> reader.readBytesNoEof(<span class="tok-number">16</span>);</span>
<span class="line" id="L633"></span>
<span class="line" id="L634">        <span class="tok-kw">if</span> (version != <span class="tok-number">20000404</span>) <span class="tok-comment">// VC70, only value observed by LLVM team</span>
</span>
<span class="line" id="L635">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownPDBVersion;</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">        self.guid = guid;</span>
<span class="line" id="L638">        self.age = age;</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">        <span class="tok-comment">// Find the string table.</span>
</span>
<span class="line" id="L641">        <span class="tok-kw">const</span> string_table_index = str_tab_index: {</span>
<span class="line" id="L642">            <span class="tok-kw">const</span> name_bytes_len = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L643">            <span class="tok-kw">const</span> name_bytes = <span class="tok-kw">try</span> self.allocator.alloc(<span class="tok-type">u8</span>, name_bytes_len);</span>
<span class="line" id="L644">            <span class="tok-kw">defer</span> self.allocator.free(name_bytes);</span>
<span class="line" id="L645">            <span class="tok-kw">try</span> reader.readNoEof(name_bytes);</span>
<span class="line" id="L646"></span>
<span class="line" id="L647">            <span class="tok-kw">const</span> HashTableHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L648">                Size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L649">                Capacity: <span class="tok-type">u32</span>,</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">                <span class="tok-kw">fn</span> <span class="tok-fn">maxLoad</span>(cap: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L652">                    <span class="tok-kw">return</span> cap * <span class="tok-number">2</span> / <span class="tok-number">3</span> + <span class="tok-number">1</span>;</span>
<span class="line" id="L653">                }</span>
<span class="line" id="L654">            };</span>
<span class="line" id="L655">            <span class="tok-kw">const</span> hash_tbl_hdr = <span class="tok-kw">try</span> reader.readStruct(HashTableHeader);</span>
<span class="line" id="L656">            <span class="tok-kw">if</span> (hash_tbl_hdr.Capacity == <span class="tok-number">0</span>)</span>
<span class="line" id="L657">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">            <span class="tok-kw">if</span> (hash_tbl_hdr.Size &gt; HashTableHeader.maxLoad(hash_tbl_hdr.Capacity))</span>
<span class="line" id="L660">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">            <span class="tok-kw">const</span> present = <span class="tok-kw">try</span> readSparseBitVector(&amp;reader, self.allocator);</span>
<span class="line" id="L663">            <span class="tok-kw">defer</span> self.allocator.free(present);</span>
<span class="line" id="L664">            <span class="tok-kw">if</span> (present.len != hash_tbl_hdr.Size)</span>
<span class="line" id="L665">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L666">            <span class="tok-kw">const</span> deleted = <span class="tok-kw">try</span> readSparseBitVector(&amp;reader, self.allocator);</span>
<span class="line" id="L667">            <span class="tok-kw">defer</span> self.allocator.free(deleted);</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">            <span class="tok-kw">for</span> (present) |_| {</span>
<span class="line" id="L670">                <span class="tok-kw">const</span> name_offset = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L671">                <span class="tok-kw">const</span> name_index = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L672">                <span class="tok-kw">if</span> (name_offset &gt; name_bytes.len)</span>
<span class="line" id="L673">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L674">                <span class="tok-kw">const</span> name = mem.sliceTo(std.meta.assumeSentinel(name_bytes.ptr + name_offset, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L675">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;/names&quot;</span>)) {</span>
<span class="line" id="L676">                    <span class="tok-kw">break</span> :str_tab_index name_index;</span>
<span class="line" id="L677">                }</span>
<span class="line" id="L678">            }</span>
<span class="line" id="L679">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L680">        };</span>
<span class="line" id="L681"></span>
<span class="line" id="L682">        self.string_table = self.getStreamById(string_table_index) <span class="tok-kw">orelse</span></span>
<span class="line" id="L683">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L684">    }</span>
<span class="line" id="L685"></span>
<span class="line" id="L686">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSymbolName</span>(self: *Pdb, module: *Module, address: <span class="tok-type">u64</span>) ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L687">        _ = self;</span>
<span class="line" id="L688">        std.debug.assert(module.populated);</span>
<span class="line" id="L689"></span>
<span class="line" id="L690">        <span class="tok-kw">var</span> symbol_i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L691">        <span class="tok-kw">while</span> (symbol_i != module.symbols.len) {</span>
<span class="line" id="L692">            <span class="tok-kw">const</span> prefix = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) RecordPrefix, &amp;module.symbols[symbol_i]);</span>
<span class="line" id="L693">            <span class="tok-kw">if</span> (prefix.RecordLen &lt; <span class="tok-number">2</span>)</span>
<span class="line" id="L694">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L695">            <span class="tok-kw">switch</span> (prefix.RecordKind) {</span>
<span class="line" id="L696">                .S_LPROC32, .S_GPROC32 =&gt; {</span>
<span class="line" id="L697">                    <span class="tok-kw">const</span> proc_sym = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) ProcSym, &amp;module.symbols[symbol_i + <span class="tok-builtin">@sizeOf</span>(RecordPrefix)]);</span>
<span class="line" id="L698">                    <span class="tok-kw">if</span> (address &gt;= proc_sym.CodeOffset <span class="tok-kw">and</span> address &lt; proc_sym.CodeOffset + proc_sym.CodeSize) {</span>
<span class="line" id="L699">                        <span class="tok-kw">return</span> mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, &amp;proc_sym.Name[<span class="tok-number">0</span>]), <span class="tok-number">0</span>);</span>
<span class="line" id="L700">                    }</span>
<span class="line" id="L701">                },</span>
<span class="line" id="L702">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L703">            }</span>
<span class="line" id="L704">            symbol_i += prefix.RecordLen + <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u16</span>);</span>
<span class="line" id="L705">        }</span>
<span class="line" id="L706"></span>
<span class="line" id="L707">        <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L708">    }</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getLineNumberInfo</span>(self: *Pdb, module: *Module, address: <span class="tok-type">u64</span>) !debug.LineInfo {</span>
<span class="line" id="L711">        std.debug.assert(module.populated);</span>
<span class="line" id="L712">        <span class="tok-kw">const</span> subsect_info = module.subsect_info;</span>
<span class="line" id="L713"></span>
<span class="line" id="L714">        <span class="tok-kw">var</span> sect_offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L715">        <span class="tok-kw">var</span> skip_len: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L716">        <span class="tok-kw">const</span> checksum_offset = module.checksum_offset <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L717">        <span class="tok-kw">while</span> (sect_offset != subsect_info.len) : (sect_offset += skip_len) {</span>
<span class="line" id="L718">            <span class="tok-kw">const</span> subsect_hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) DebugSubsectionHeader, &amp;subsect_info[sect_offset]);</span>
<span class="line" id="L719">            skip_len = subsect_hdr.Length;</span>
<span class="line" id="L720">            sect_offset += <span class="tok-builtin">@sizeOf</span>(DebugSubsectionHeader);</span>
<span class="line" id="L721"></span>
<span class="line" id="L722">            <span class="tok-kw">switch</span> (subsect_hdr.Kind) {</span>
<span class="line" id="L723">                .Lines =&gt; {</span>
<span class="line" id="L724">                    <span class="tok-kw">var</span> line_index = sect_offset;</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">                    <span class="tok-kw">const</span> line_hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) LineFragmentHeader, &amp;subsect_info[line_index]);</span>
<span class="line" id="L727">                    <span class="tok-kw">if</span> (line_hdr.RelocSegment == <span class="tok-number">0</span>)</span>
<span class="line" id="L728">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L729">                    line_index += <span class="tok-builtin">@sizeOf</span>(LineFragmentHeader);</span>
<span class="line" id="L730">                    <span class="tok-kw">const</span> frag_vaddr_start = line_hdr.RelocOffset;</span>
<span class="line" id="L731">                    <span class="tok-kw">const</span> frag_vaddr_end = frag_vaddr_start + line_hdr.CodeSize;</span>
<span class="line" id="L732"></span>
<span class="line" id="L733">                    <span class="tok-kw">if</span> (address &gt;= frag_vaddr_start <span class="tok-kw">and</span> address &lt; frag_vaddr_end) {</span>
<span class="line" id="L734">                        <span class="tok-comment">// There is an unknown number of LineBlockFragmentHeaders (and their accompanying line and column records)</span>
</span>
<span class="line" id="L735">                        <span class="tok-comment">// from now on. We will iterate through them, and eventually find a LineInfo that we're interested in,</span>
</span>
<span class="line" id="L736">                        <span class="tok-comment">// breaking out to :subsections. If not, we will make sure to not read anything outside of this subsection.</span>
</span>
<span class="line" id="L737">                        <span class="tok-kw">const</span> subsection_end_index = sect_offset + subsect_hdr.Length;</span>
<span class="line" id="L738"></span>
<span class="line" id="L739">                        <span class="tok-kw">while</span> (line_index &lt; subsection_end_index) {</span>
<span class="line" id="L740">                            <span class="tok-kw">const</span> block_hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) LineBlockFragmentHeader, &amp;subsect_info[line_index]);</span>
<span class="line" id="L741">                            line_index += <span class="tok-builtin">@sizeOf</span>(LineBlockFragmentHeader);</span>
<span class="line" id="L742">                            <span class="tok-kw">const</span> start_line_index = line_index;</span>
<span class="line" id="L743"></span>
<span class="line" id="L744">                            <span class="tok-kw">const</span> has_column = line_hdr.Flags.LF_HaveColumns;</span>
<span class="line" id="L745"></span>
<span class="line" id="L746">                            <span class="tok-comment">// All line entries are stored inside their line block by ascending start address.</span>
</span>
<span class="line" id="L747">                            <span class="tok-comment">// Heuristic: we want to find the last line entry</span>
</span>
<span class="line" id="L748">                            <span class="tok-comment">// that has a vaddr_start &lt;= address.</span>
</span>
<span class="line" id="L749">                            <span class="tok-comment">// This is done with a simple linear search.</span>
</span>
<span class="line" id="L750">                            <span class="tok-kw">var</span> line_i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L751">                            <span class="tok-kw">while</span> (line_i &lt; block_hdr.NumLines) : (line_i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L752">                                <span class="tok-kw">const</span> line_num_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) LineNumberEntry, &amp;subsect_info[line_index]);</span>
<span class="line" id="L753">                                line_index += <span class="tok-builtin">@sizeOf</span>(LineNumberEntry);</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">                                <span class="tok-kw">const</span> vaddr_start = frag_vaddr_start + line_num_entry.Offset;</span>
<span class="line" id="L756">                                <span class="tok-kw">if</span> (address &lt; vaddr_start) {</span>
<span class="line" id="L757">                                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L758">                                }</span>
<span class="line" id="L759">                            }</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">                            <span class="tok-comment">// line_i == 0 would mean that no matching LineNumberEntry was found.</span>
</span>
<span class="line" id="L762">                            <span class="tok-kw">if</span> (line_i &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L763">                                <span class="tok-kw">const</span> subsect_index = checksum_offset + block_hdr.NameIndex;</span>
<span class="line" id="L764">                                <span class="tok-kw">const</span> chksum_hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) FileChecksumEntryHeader, &amp;module.subsect_info[subsect_index]);</span>
<span class="line" id="L765">                                <span class="tok-kw">const</span> strtab_offset = <span class="tok-builtin">@sizeOf</span>(PDBStringTableHeader) + chksum_hdr.FileNameOffset;</span>
<span class="line" id="L766">                                <span class="tok-kw">try</span> self.string_table.?.seekTo(strtab_offset);</span>
<span class="line" id="L767">                                <span class="tok-kw">const</span> source_file_name = <span class="tok-kw">try</span> self.string_table.?.reader().readUntilDelimiterAlloc(self.allocator, <span class="tok-number">0</span>, <span class="tok-number">1024</span>);</span>
<span class="line" id="L768"></span>
<span class="line" id="L769">                                <span class="tok-kw">const</span> line_entry_idx = line_i - <span class="tok-number">1</span>;</span>
<span class="line" id="L770"></span>
<span class="line" id="L771">                                <span class="tok-kw">const</span> column = <span class="tok-kw">if</span> (has_column) blk: {</span>
<span class="line" id="L772">                                    <span class="tok-kw">const</span> start_col_index = start_line_index + <span class="tok-builtin">@sizeOf</span>(LineNumberEntry) * block_hdr.NumLines;</span>
<span class="line" id="L773">                                    <span class="tok-kw">const</span> col_index = start_col_index + <span class="tok-builtin">@sizeOf</span>(ColumnNumberEntry) * line_entry_idx;</span>
<span class="line" id="L774">                                    <span class="tok-kw">const</span> col_num_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) ColumnNumberEntry, &amp;subsect_info[col_index]);</span>
<span class="line" id="L775">                                    <span class="tok-kw">break</span> :blk col_num_entry.StartColumn;</span>
<span class="line" id="L776">                                } <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L777"></span>
<span class="line" id="L778">                                <span class="tok-kw">const</span> found_line_index = start_line_index + line_entry_idx * <span class="tok-builtin">@sizeOf</span>(LineNumberEntry);</span>
<span class="line" id="L779">                                <span class="tok-kw">const</span> line_num_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) LineNumberEntry, &amp;subsect_info[found_line_index]);</span>
<span class="line" id="L780">                                <span class="tok-kw">const</span> flags = <span class="tok-builtin">@ptrCast</span>(*LineNumberEntry.Flags, &amp;line_num_entry.Flags);</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">                                <span class="tok-kw">return</span> debug.LineInfo{</span>
<span class="line" id="L783">                                    .file_name = source_file_name,</span>
<span class="line" id="L784">                                    .line = flags.Start,</span>
<span class="line" id="L785">                                    .column = column,</span>
<span class="line" id="L786">                                };</span>
<span class="line" id="L787">                            }</span>
<span class="line" id="L788">                        }</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">                        <span class="tok-comment">// Checking that we are not reading garbage after the (possibly) multiple block fragments.</span>
</span>
<span class="line" id="L791">                        <span class="tok-kw">if</span> (line_index != subsection_end_index) {</span>
<span class="line" id="L792">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L793">                        }</span>
<span class="line" id="L794">                    }</span>
<span class="line" id="L795">                },</span>
<span class="line" id="L796">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L797">            }</span>
<span class="line" id="L798"></span>
<span class="line" id="L799">            <span class="tok-kw">if</span> (sect_offset &gt; subsect_info.len)</span>
<span class="line" id="L800">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L801">        }</span>
<span class="line" id="L802"></span>
<span class="line" id="L803">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L804">    }</span>
<span class="line" id="L805"></span>
<span class="line" id="L806">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getModule</span>(self: *Pdb, index: <span class="tok-type">usize</span>) !?*Module {</span>
<span class="line" id="L807">        <span class="tok-kw">if</span> (index &gt;= self.modules.len)</span>
<span class="line" id="L808">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L809"></span>
<span class="line" id="L810">        <span class="tok-kw">const</span> mod = &amp;self.modules[index];</span>
<span class="line" id="L811">        <span class="tok-kw">if</span> (mod.populated)</span>
<span class="line" id="L812">            <span class="tok-kw">return</span> mod;</span>
<span class="line" id="L813"></span>
<span class="line" id="L814">        <span class="tok-comment">// At most one can be non-zero.</span>
</span>
<span class="line" id="L815">        <span class="tok-kw">if</span> (mod.mod_info.C11ByteSize != <span class="tok-number">0</span> <span class="tok-kw">and</span> mod.mod_info.C13ByteSize != <span class="tok-number">0</span>)</span>
<span class="line" id="L816">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L817">        <span class="tok-kw">if</span> (mod.mod_info.C13ByteSize == <span class="tok-number">0</span>)</span>
<span class="line" id="L818">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L819"></span>
<span class="line" id="L820">        <span class="tok-kw">const</span> stream = self.getStreamById(mod.mod_info.ModuleSymStream) <span class="tok-kw">orelse</span></span>
<span class="line" id="L821">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingDebugInfo;</span>
<span class="line" id="L822">        <span class="tok-kw">const</span> reader = stream.reader();</span>
<span class="line" id="L823"></span>
<span class="line" id="L824">        <span class="tok-kw">const</span> signature = <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L825">        <span class="tok-kw">if</span> (signature != <span class="tok-number">4</span>)</span>
<span class="line" id="L826">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">        mod.symbols = <span class="tok-kw">try</span> self.allocator.alloc(<span class="tok-type">u8</span>, mod.mod_info.SymByteSize - <span class="tok-number">4</span>);</span>
<span class="line" id="L829">        <span class="tok-kw">errdefer</span> self.allocator.free(mod.symbols);</span>
<span class="line" id="L830">        <span class="tok-kw">try</span> reader.readNoEof(mod.symbols);</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">        mod.subsect_info = <span class="tok-kw">try</span> self.allocator.alloc(<span class="tok-type">u8</span>, mod.mod_info.C13ByteSize);</span>
<span class="line" id="L833">        <span class="tok-kw">errdefer</span> self.allocator.free(mod.subsect_info);</span>
<span class="line" id="L834">        <span class="tok-kw">try</span> reader.readNoEof(mod.subsect_info);</span>
<span class="line" id="L835"></span>
<span class="line" id="L836">        <span class="tok-kw">var</span> sect_offset: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L837">        <span class="tok-kw">var</span> skip_len: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L838">        <span class="tok-kw">while</span> (sect_offset != mod.subsect_info.len) : (sect_offset += skip_len) {</span>
<span class="line" id="L839">            <span class="tok-kw">const</span> subsect_hdr = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) DebugSubsectionHeader, &amp;mod.subsect_info[sect_offset]);</span>
<span class="line" id="L840">            skip_len = subsect_hdr.Length;</span>
<span class="line" id="L841">            sect_offset += <span class="tok-builtin">@sizeOf</span>(DebugSubsectionHeader);</span>
<span class="line" id="L842"></span>
<span class="line" id="L843">            <span class="tok-kw">switch</span> (subsect_hdr.Kind) {</span>
<span class="line" id="L844">                .FileChecksums =&gt; {</span>
<span class="line" id="L845">                    mod.checksum_offset = sect_offset;</span>
<span class="line" id="L846">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L847">                },</span>
<span class="line" id="L848">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L849">            }</span>
<span class="line" id="L850"></span>
<span class="line" id="L851">            <span class="tok-kw">if</span> (sect_offset &gt; mod.subsect_info.len)</span>
<span class="line" id="L852">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L853">        }</span>
<span class="line" id="L854"></span>
<span class="line" id="L855">        mod.populated = <span class="tok-null">true</span>;</span>
<span class="line" id="L856">        <span class="tok-kw">return</span> mod;</span>
<span class="line" id="L857">    }</span>
<span class="line" id="L858"></span>
<span class="line" id="L859">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getStreamById</span>(self: *Pdb, id: <span class="tok-type">u32</span>) ?*MsfStream {</span>
<span class="line" id="L860">        <span class="tok-kw">if</span> (id &gt;= self.msf.streams.len)</span>
<span class="line" id="L861">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L862">        <span class="tok-kw">return</span> &amp;self.msf.streams[id];</span>
<span class="line" id="L863">    }</span>
<span class="line" id="L864"></span>
<span class="line" id="L865">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getStream</span>(self: *Pdb, stream: StreamType) ?*MsfStream {</span>
<span class="line" id="L866">        <span class="tok-kw">const</span> id = <span class="tok-builtin">@enumToInt</span>(stream);</span>
<span class="line" id="L867">        <span class="tok-kw">return</span> self.getStreamById(id);</span>
<span class="line" id="L868">    }</span>
<span class="line" id="L869">};</span>
<span class="line" id="L870"></span>
<span class="line" id="L871"><span class="tok-comment">// see https://llvm.org/docs/PDB/MsfFile.html</span>
</span>
<span class="line" id="L872"><span class="tok-kw">const</span> Msf = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L873">    directory: MsfStream,</span>
<span class="line" id="L874">    streams: []MsfStream,</span>
<span class="line" id="L875"></span>
<span class="line" id="L876">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(allocator: mem.Allocator, file: File) !Msf {</span>
<span class="line" id="L877">        <span class="tok-kw">const</span> in = file.reader();</span>
<span class="line" id="L878"></span>
<span class="line" id="L879">        <span class="tok-kw">const</span> superblock = <span class="tok-kw">try</span> in.readStruct(SuperBlock);</span>
<span class="line" id="L880"></span>
<span class="line" id="L881">        <span class="tok-comment">// Sanity checks</span>
</span>
<span class="line" id="L882">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;superblock.FileMagic, SuperBlock.file_magic))</span>
<span class="line" id="L883">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L884">        <span class="tok-kw">if</span> (superblock.FreeBlockMapBlock != <span class="tok-number">1</span> <span class="tok-kw">and</span> superblock.FreeBlockMapBlock != <span class="tok-number">2</span>)</span>
<span class="line" id="L885">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L886">        <span class="tok-kw">const</span> file_len = <span class="tok-kw">try</span> file.getEndPos();</span>
<span class="line" id="L887">        <span class="tok-kw">if</span> (superblock.NumBlocks * superblock.BlockSize != file_len)</span>
<span class="line" id="L888">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo;</span>
<span class="line" id="L889">        <span class="tok-kw">switch</span> (superblock.BlockSize) {</span>
<span class="line" id="L890">            <span class="tok-comment">// llvm only supports 4096 but we can handle any of these values</span>
</span>
<span class="line" id="L891">            <span class="tok-number">512</span>, <span class="tok-number">1024</span>, <span class="tok-number">2048</span>, <span class="tok-number">4096</span> =&gt; {},</span>
<span class="line" id="L892">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidDebugInfo,</span>
<span class="line" id="L893">        }</span>
<span class="line" id="L894"></span>
<span class="line" id="L895">        <span class="tok-kw">const</span> dir_block_count = blockCountFromSize(superblock.NumDirectoryBytes, superblock.BlockSize);</span>
<span class="line" id="L896">        <span class="tok-kw">if</span> (dir_block_count &gt; superblock.BlockSize / <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u32</span>))</span>
<span class="line" id="L897">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnhandledBigDirectoryStream; <span class="tok-comment">// cf. BlockMapAddr comment.</span>
</span>
<span class="line" id="L898"></span>
<span class="line" id="L899">        <span class="tok-kw">try</span> file.seekTo(superblock.BlockSize * superblock.BlockMapAddr);</span>
<span class="line" id="L900">        <span class="tok-kw">var</span> dir_blocks = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, dir_block_count);</span>
<span class="line" id="L901">        <span class="tok-kw">for</span> (dir_blocks) |*b| {</span>
<span class="line" id="L902">            b.* = <span class="tok-kw">try</span> in.readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L903">        }</span>
<span class="line" id="L904">        <span class="tok-kw">var</span> directory = MsfStream.init(</span>
<span class="line" id="L905">            superblock.BlockSize,</span>
<span class="line" id="L906">            file,</span>
<span class="line" id="L907">            dir_blocks,</span>
<span class="line" id="L908">        );</span>
<span class="line" id="L909"></span>
<span class="line" id="L910">        <span class="tok-kw">const</span> begin = directory.pos;</span>
<span class="line" id="L911">        <span class="tok-kw">const</span> stream_count = <span class="tok-kw">try</span> directory.reader().readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L912">        <span class="tok-kw">const</span> stream_sizes = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, stream_count);</span>
<span class="line" id="L913">        <span class="tok-kw">defer</span> allocator.free(stream_sizes);</span>
<span class="line" id="L914"></span>
<span class="line" id="L915">        <span class="tok-comment">// Microsoft's implementation uses @as(u32, -1) for inexistant streams.</span>
</span>
<span class="line" id="L916">        <span class="tok-comment">// These streams are not used, but still participate in the file</span>
</span>
<span class="line" id="L917">        <span class="tok-comment">// and must be taken into account when resolving stream indices.</span>
</span>
<span class="line" id="L918">        <span class="tok-kw">const</span> Nil = <span class="tok-number">0xFFFFFFFF</span>;</span>
<span class="line" id="L919">        <span class="tok-kw">for</span> (stream_sizes) |*s| {</span>
<span class="line" id="L920">            <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> directory.reader().readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L921">            s.* = <span class="tok-kw">if</span> (size == Nil) <span class="tok-number">0</span> <span class="tok-kw">else</span> blockCountFromSize(size, superblock.BlockSize);</span>
<span class="line" id="L922">        }</span>
<span class="line" id="L923"></span>
<span class="line" id="L924">        <span class="tok-kw">const</span> streams = <span class="tok-kw">try</span> allocator.alloc(MsfStream, stream_count);</span>
<span class="line" id="L925">        <span class="tok-kw">for</span> (streams) |*stream, i| {</span>
<span class="line" id="L926">            <span class="tok-kw">const</span> size = stream_sizes[i];</span>
<span class="line" id="L927">            <span class="tok-kw">if</span> (size == <span class="tok-number">0</span>) {</span>
<span class="line" id="L928">                stream.* = MsfStream{</span>
<span class="line" id="L929">                    .blocks = &amp;[_]<span class="tok-type">u32</span>{},</span>
<span class="line" id="L930">                };</span>
<span class="line" id="L931">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L932">                <span class="tok-kw">var</span> blocks = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u32</span>, size);</span>
<span class="line" id="L933">                <span class="tok-kw">var</span> j: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L934">                <span class="tok-kw">while</span> (j &lt; size) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L935">                    <span class="tok-kw">const</span> block_id = <span class="tok-kw">try</span> directory.reader().readIntLittle(<span class="tok-type">u32</span>);</span>
<span class="line" id="L936">                    <span class="tok-kw">const</span> n = (block_id % superblock.BlockSize);</span>
<span class="line" id="L937">                    <span class="tok-comment">// 0 is for SuperBlock, 1 and 2 for FPMs.</span>
</span>
<span class="line" id="L938">                    <span class="tok-kw">if</span> (block_id == <span class="tok-number">0</span> <span class="tok-kw">or</span> n == <span class="tok-number">1</span> <span class="tok-kw">or</span> n == <span class="tok-number">2</span> <span class="tok-kw">or</span> block_id * superblock.BlockSize &gt; file_len)</span>
<span class="line" id="L939">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidBlockIndex;</span>
<span class="line" id="L940">                    blocks[j] = block_id;</span>
<span class="line" id="L941">                }</span>
<span class="line" id="L942"></span>
<span class="line" id="L943">                stream.* = MsfStream.init(</span>
<span class="line" id="L944">                    superblock.BlockSize,</span>
<span class="line" id="L945">                    file,</span>
<span class="line" id="L946">                    blocks,</span>
<span class="line" id="L947">                );</span>
<span class="line" id="L948">            }</span>
<span class="line" id="L949">        }</span>
<span class="line" id="L950"></span>
<span class="line" id="L951">        <span class="tok-kw">const</span> end = directory.pos;</span>
<span class="line" id="L952">        <span class="tok-kw">if</span> (end - begin != superblock.NumDirectoryBytes)</span>
<span class="line" id="L953">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidStreamDirectory;</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">        <span class="tok-kw">return</span> Msf{</span>
<span class="line" id="L956">            .directory = directory,</span>
<span class="line" id="L957">            .streams = streams,</span>
<span class="line" id="L958">        };</span>
<span class="line" id="L959">    }</span>
<span class="line" id="L960"></span>
<span class="line" id="L961">    <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Msf, allocator: mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L962">        allocator.free(self.directory.blocks);</span>
<span class="line" id="L963">        <span class="tok-kw">for</span> (self.streams) |*stream| {</span>
<span class="line" id="L964">            allocator.free(stream.blocks);</span>
<span class="line" id="L965">        }</span>
<span class="line" id="L966">        allocator.free(self.streams);</span>
<span class="line" id="L967">    }</span>
<span class="line" id="L968">};</span>
<span class="line" id="L969"></span>
<span class="line" id="L970"><span class="tok-kw">fn</span> <span class="tok-fn">blockCountFromSize</span>(size: <span class="tok-type">u32</span>, block_size: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L971">    <span class="tok-kw">return</span> (size + block_size - <span class="tok-number">1</span>) / block_size;</span>
<span class="line" id="L972">}</span>
<span class="line" id="L973"></span>
<span class="line" id="L974"><span class="tok-comment">// https://llvm.org/docs/PDB/MsfFile.html#the-superblock</span>
</span>
<span class="line" id="L975"><span class="tok-kw">const</span> SuperBlock = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L976">    <span class="tok-comment">/// The LLVM docs list a space between C / C++ but empirically this is not the case.</span></span>
<span class="line" id="L977">    <span class="tok-kw">const</span> file_magic = <span class="tok-str">&quot;Microsoft C/C++ MSF 7.00\r\n\x1a\x44\x53\x00\x00\x00&quot;</span>;</span>
<span class="line" id="L978"></span>
<span class="line" id="L979">    FileMagic: [file_magic.len]<span class="tok-type">u8</span>,</span>
<span class="line" id="L980"></span>
<span class="line" id="L981">    <span class="tok-comment">/// The block size of the internal file system. Valid values are 512, 1024,</span></span>
<span class="line" id="L982">    <span class="tok-comment">/// 2048, and 4096 bytes. Certain aspects of the MSF file layout vary depending</span></span>
<span class="line" id="L983">    <span class="tok-comment">/// on the block sizes. For the purposes of LLVM, we handle only block sizes of</span></span>
<span class="line" id="L984">    <span class="tok-comment">/// 4KiB, and all further discussion assumes a block size of 4KiB.</span></span>
<span class="line" id="L985">    BlockSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L986"></span>
<span class="line" id="L987">    <span class="tok-comment">/// The index of a block within the file, at which begins a bitfield representing</span></span>
<span class="line" id="L988">    <span class="tok-comment">/// the set of all blocks within the file which are “free” (i.e. the data within</span></span>
<span class="line" id="L989">    <span class="tok-comment">/// that block is not used). See The Free Block Map for more information. Important:</span></span>
<span class="line" id="L990">    <span class="tok-comment">/// FreeBlockMapBlock can only be 1 or 2!</span></span>
<span class="line" id="L991">    FreeBlockMapBlock: <span class="tok-type">u32</span>,</span>
<span class="line" id="L992"></span>
<span class="line" id="L993">    <span class="tok-comment">/// The total number of blocks in the file. NumBlocks * BlockSize should equal the</span></span>
<span class="line" id="L994">    <span class="tok-comment">/// size of the file on disk.</span></span>
<span class="line" id="L995">    NumBlocks: <span class="tok-type">u32</span>,</span>
<span class="line" id="L996"></span>
<span class="line" id="L997">    <span class="tok-comment">/// The size of the stream directory, in bytes. The stream directory contains</span></span>
<span class="line" id="L998">    <span class="tok-comment">/// information about each stream’s size and the set of blocks that it occupies.</span></span>
<span class="line" id="L999">    <span class="tok-comment">/// It will be described in more detail later.</span></span>
<span class="line" id="L1000">    NumDirectoryBytes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1001"></span>
<span class="line" id="L1002">    Unknown: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1003">    <span class="tok-comment">/// The index of a block within the MSF file. At this block is an array of</span></span>
<span class="line" id="L1004">    <span class="tok-comment">/// ulittle32_t’s listing the blocks that the stream directory resides on.</span></span>
<span class="line" id="L1005">    <span class="tok-comment">/// For large MSF files, the stream directory (which describes the block</span></span>
<span class="line" id="L1006">    <span class="tok-comment">/// layout of each stream) may not fit entirely on a single block. As a</span></span>
<span class="line" id="L1007">    <span class="tok-comment">/// result, this extra layer of indirection is introduced, whereby this</span></span>
<span class="line" id="L1008">    <span class="tok-comment">/// block contains the list of blocks that the stream directory occupies,</span></span>
<span class="line" id="L1009">    <span class="tok-comment">/// and the stream directory itself can be stitched together accordingly.</span></span>
<span class="line" id="L1010">    <span class="tok-comment">/// The number of ulittle32_t’s in this array is given by</span></span>
<span class="line" id="L1011">    <span class="tok-comment">/// ceil(NumDirectoryBytes / BlockSize).</span></span>
<span class="line" id="L1012">    <span class="tok-comment">// Note: microsoft-pdb code actually suggests this is a variable-length</span>
</span>
<span class="line" id="L1013">    <span class="tok-comment">// array. If the indices of blocks occupied by the Stream Directory didn't</span>
</span>
<span class="line" id="L1014">    <span class="tok-comment">// fit in one page, there would be other u32 following it.</span>
</span>
<span class="line" id="L1015">    <span class="tok-comment">// This would mean the Stream Directory is bigger than BlockSize / sizeof(u32)</span>
</span>
<span class="line" id="L1016">    <span class="tok-comment">// blocks. We're not even close to this with a 1GB pdb file, and LLVM didn't</span>
</span>
<span class="line" id="L1017">    <span class="tok-comment">// implement it so we're kind of safe making this assumption for now.</span>
</span>
<span class="line" id="L1018">    BlockMapAddr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1019">};</span>
<span class="line" id="L1020"></span>
<span class="line" id="L1021"><span class="tok-kw">const</span> MsfStream = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1022">    in_file: File = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1023">    pos: <span class="tok-type">u64</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1024">    blocks: []<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1025">    block_size: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1026"></span>
<span class="line" id="L1027">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(read)).Fn.return_type.?).ErrorUnion.error_set;</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(block_size: <span class="tok-type">u32</span>, file: File, blocks: []<span class="tok-type">u32</span>) MsfStream {</span>
<span class="line" id="L1030">        <span class="tok-kw">const</span> stream = MsfStream{</span>
<span class="line" id="L1031">            .in_file = file,</span>
<span class="line" id="L1032">            .pos = <span class="tok-number">0</span>,</span>
<span class="line" id="L1033">            .blocks = blocks,</span>
<span class="line" id="L1034">            .block_size = block_size,</span>
<span class="line" id="L1035">        };</span>
<span class="line" id="L1036"></span>
<span class="line" id="L1037">        <span class="tok-kw">return</span> stream;</span>
<span class="line" id="L1038">    }</span>
<span class="line" id="L1039"></span>
<span class="line" id="L1040">    <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: *MsfStream, buffer: []<span class="tok-type">u8</span>) !<span class="tok-type">usize</span> {</span>
<span class="line" id="L1041">        <span class="tok-kw">var</span> block_id = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, self.pos / self.block_size);</span>
<span class="line" id="L1042">        <span class="tok-kw">if</span> (block_id &gt;= self.blocks.len) <span class="tok-kw">return</span> <span class="tok-number">0</span>; <span class="tok-comment">// End of Stream</span>
</span>
<span class="line" id="L1043">        <span class="tok-kw">var</span> block = self.blocks[block_id];</span>
<span class="line" id="L1044">        <span class="tok-kw">var</span> offset = self.pos % self.block_size;</span>
<span class="line" id="L1045"></span>
<span class="line" id="L1046">        <span class="tok-kw">try</span> self.in_file.seekTo(block * self.block_size + offset);</span>
<span class="line" id="L1047">        <span class="tok-kw">const</span> in = self.in_file.reader();</span>
<span class="line" id="L1048"></span>
<span class="line" id="L1049">        <span class="tok-kw">var</span> size: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1050">        <span class="tok-kw">var</span> rem_buffer = buffer;</span>
<span class="line" id="L1051">        <span class="tok-kw">while</span> (size &lt; buffer.len) {</span>
<span class="line" id="L1052">            <span class="tok-kw">const</span> size_to_read = math.min(self.block_size - offset, rem_buffer.len);</span>
<span class="line" id="L1053">            size += <span class="tok-kw">try</span> in.read(rem_buffer[<span class="tok-number">0</span>..size_to_read]);</span>
<span class="line" id="L1054">            rem_buffer = buffer[size..];</span>
<span class="line" id="L1055">            offset += size_to_read;</span>
<span class="line" id="L1056"></span>
<span class="line" id="L1057">            <span class="tok-comment">// If we're at the end of a block, go to the next one.</span>
</span>
<span class="line" id="L1058">            <span class="tok-kw">if</span> (offset == self.block_size) {</span>
<span class="line" id="L1059">                offset = <span class="tok-number">0</span>;</span>
<span class="line" id="L1060">                block_id += <span class="tok-number">1</span>;</span>
<span class="line" id="L1061">                <span class="tok-kw">if</span> (block_id &gt;= self.blocks.len) <span class="tok-kw">break</span>; <span class="tok-comment">// End of Stream</span>
</span>
<span class="line" id="L1062">                block = self.blocks[block_id];</span>
<span class="line" id="L1063">                <span class="tok-kw">try</span> self.in_file.seekTo(block * self.block_size);</span>
<span class="line" id="L1064">            }</span>
<span class="line" id="L1065">        }</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067">        self.pos += buffer.len;</span>
<span class="line" id="L1068">        <span class="tok-kw">return</span> buffer.len;</span>
<span class="line" id="L1069">    }</span>
<span class="line" id="L1070"></span>
<span class="line" id="L1071">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekBy</span>(self: *MsfStream, len: <span class="tok-type">i64</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1072">        self.pos = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">i64</span>, self.pos) + len);</span>
<span class="line" id="L1073">        <span class="tok-kw">if</span> (self.pos &gt;= self.blocks.len * self.block_size)</span>
<span class="line" id="L1074">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EOF;</span>
<span class="line" id="L1075">    }</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seekTo</span>(self: *MsfStream, len: <span class="tok-type">u64</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1078">        self.pos = len;</span>
<span class="line" id="L1079">        <span class="tok-kw">if</span> (self.pos &gt;= self.blocks.len * self.block_size)</span>
<span class="line" id="L1080">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EOF;</span>
<span class="line" id="L1081">    }</span>
<span class="line" id="L1082"></span>
<span class="line" id="L1083">    <span class="tok-kw">fn</span> <span class="tok-fn">getSize</span>(self: *<span class="tok-kw">const</span> MsfStream) <span class="tok-type">u64</span> {</span>
<span class="line" id="L1084">        <span class="tok-kw">return</span> self.blocks.len * self.block_size;</span>
<span class="line" id="L1085">    }</span>
<span class="line" id="L1086"></span>
<span class="line" id="L1087">    <span class="tok-kw">fn</span> <span class="tok-fn">getFilePos</span>(self: MsfStream) <span class="tok-type">u64</span> {</span>
<span class="line" id="L1088">        <span class="tok-kw">const</span> block_id = self.pos / self.block_size;</span>
<span class="line" id="L1089">        <span class="tok-kw">const</span> block = self.blocks[block_id];</span>
<span class="line" id="L1090">        <span class="tok-kw">const</span> offset = self.pos % self.block_size;</span>
<span class="line" id="L1091"></span>
<span class="line" id="L1092">        <span class="tok-kw">return</span> block * self.block_size + offset;</span>
<span class="line" id="L1093">    }</span>
<span class="line" id="L1094"></span>
<span class="line" id="L1095">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reader</span>(self: *MsfStream) std.io.Reader(*MsfStream, Error, read) {</span>
<span class="line" id="L1096">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L1097">    }</span>
<span class="line" id="L1098">};</span>
<span class="line" id="L1099"></span>
</code></pre></body>
</html>