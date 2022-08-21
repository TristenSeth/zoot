<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dwarf/TAG.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> padding = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> array_type = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> class_type = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> entry_point = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> enumeration_type = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> formal_parameter = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> imported_declaration = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> label = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lexical_block = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> member = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pointer_type = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reference_type = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> compile_unit = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> string_type = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> structure_type = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subroutine = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subroutine_type = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> typedef = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> union_type = <span class="tok-number">0x17</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified_parameters = <span class="tok-number">0x18</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> variant = <span class="tok-number">0x19</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> common_block = <span class="tok-number">0x1a</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> common_inclusion = <span class="tok-number">0x1b</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inheritance = <span class="tok-number">0x1c</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inlined_subroutine = <span class="tok-number">0x1d</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> module = <span class="tok-number">0x1e</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ptr_to_member_type = <span class="tok-number">0x1f</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> set_type = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subrange_type = <span class="tok-number">0x21</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> with_stmt = <span class="tok-number">0x22</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> access_declaration = <span class="tok-number">0x23</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_type = <span class="tok-number">0x24</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> catch_block = <span class="tok-number">0x25</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const_type = <span class="tok-number">0x26</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> constant = <span class="tok-number">0x27</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> enumerator = <span class="tok-number">0x28</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> file_type = <span class="tok-number">0x29</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> friend = <span class="tok-number">0x2a</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> namelist = <span class="tok-number">0x2b</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> namelist_item = <span class="tok-number">0x2c</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> packed_type = <span class="tok-number">0x2d</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subprogram = <span class="tok-number">0x2e</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> template_type_param = <span class="tok-number">0x2f</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> template_value_param = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> thrown_type = <span class="tok-number">0x31</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> try_block = <span class="tok-number">0x32</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> variant_part = <span class="tok-number">0x33</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> variable = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> volatile_type = <span class="tok-number">0x35</span>;</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">// DWARF 3</span>
</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dwarf_procedure = <span class="tok-number">0x36</span>;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> restrict_type = <span class="tok-number">0x37</span>;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> interface_type = <span class="tok-number">0x38</span>;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> namespace = <span class="tok-number">0x39</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> imported_module = <span class="tok-number">0x3a</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unspecified_type = <span class="tok-number">0x3b</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> partial_unit = <span class="tok-number">0x3c</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> imported_unit = <span class="tok-number">0x3d</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> condition = <span class="tok-number">0x3f</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> shared_type = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63"><span class="tok-comment">// DWARF 4</span>
</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> type_unit = <span class="tok-number">0x41</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rvalue_reference_type = <span class="tok-number">0x42</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> template_alias = <span class="tok-number">0x43</span>;</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-comment">// DWARF 5</span>
</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> coarray_type = <span class="tok-number">0x44</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> generic_subrange = <span class="tok-number">0x45</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dynamic_type = <span class="tok-number">0x46</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> atomic_type = <span class="tok-number">0x47</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call_site = <span class="tok-number">0x48</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call_site_parameter = <span class="tok-number">0x49</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> skeleton_unit = <span class="tok-number">0x4a</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> immutable_type = <span class="tok-number">0x4b</span>;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x4080</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-comment">// SGI/MIPS Extensions.</span>
</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MIPS_loop = <span class="tok-number">0x4081</span>;</span>
<span class="line" id="L83"></span>
<span class="line" id="L84"><span class="tok-comment">// HP extensions.  See: ftp://ftp.hp.com/pub/lang/tools/WDB/wdb-4.0.tar.gz .</span>
</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_array_descriptor = <span class="tok-number">0x4090</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_Bliss_field = <span class="tok-number">0x4091</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_Bliss_field_set = <span class="tok-number">0x4092</span>;</span>
<span class="line" id="L88"></span>
<span class="line" id="L89"><span class="tok-comment">// GNU extensions.</span>
</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> format_label = <span class="tok-number">0x4101</span>; <span class="tok-comment">// For FORTRAN 77 and Fortran 90.</span>
</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> function_template = <span class="tok-number">0x4102</span>; <span class="tok-comment">// For C++.</span>
</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> class_template = <span class="tok-number">0x4103</span>; <span class="tok-comment">//For C++.</span>
</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_BINCL = <span class="tok-number">0x4104</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_EINCL = <span class="tok-number">0x4105</span>;</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-comment">// Template template parameter.</span>
</span>
<span class="line" id="L97"><span class="tok-comment">// See http://gcc.gnu.org/wiki/TemplateParmsDwarf .</span>
</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_template_template_param = <span class="tok-number">0x4106</span>;</span>
<span class="line" id="L99"></span>
<span class="line" id="L100"><span class="tok-comment">// Template parameter pack extension = specified at</span>
</span>
<span class="line" id="L101"><span class="tok-comment">// http://wiki.dwarfstd.org/index.php?title=C%2B%2B0x:_Variadic_templates</span>
</span>
<span class="line" id="L102"><span class="tok-comment">// The values of these two TAGS are in the DW_TAG_GNU_* space until the tags</span>
</span>
<span class="line" id="L103"><span class="tok-comment">// are properly part of DWARF 5.</span>
</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_template_parameter_pack = <span class="tok-number">0x4107</span>;</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_formal_parameter_pack = <span class="tok-number">0x4108</span>;</span>
<span class="line" id="L106"><span class="tok-comment">// The GNU call site extension = specified at</span>
</span>
<span class="line" id="L107"><span class="tok-comment">// http://www.dwarfstd.org/ShowIssue.php?issue=100909.2&amp;type=open .</span>
</span>
<span class="line" id="L108"><span class="tok-comment">// The values of these two TAGS are in the DW_TAG_GNU_* space until the tags</span>
</span>
<span class="line" id="L109"><span class="tok-comment">// are properly part of DWARF 5.</span>
</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_call_site = <span class="tok-number">0x4109</span>;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_call_site_parameter = <span class="tok-number">0x410a</span>;</span>
<span class="line" id="L112"><span class="tok-comment">// Extensions for UPC.  See: http://dwarfstd.org/doc/DWARF4.pdf.</span>
</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> upc_shared_type = <span class="tok-number">0x8765</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> upc_strict_type = <span class="tok-number">0x8766</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> upc_relaxed_type = <span class="tok-number">0x8767</span>;</span>
<span class="line" id="L116"><span class="tok-comment">// PGI (STMicroelectronics; extensions.  No documentation available.</span>
</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PGI_kanji_type = <span class="tok-number">0xA000</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PGI_interface_block = <span class="tok-number">0xA020</span>;</span>
<span class="line" id="L119"></span>
</code></pre></body>
</html>