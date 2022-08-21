<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dwarf/ATE.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;void&quot; = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> address = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> boolean = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> complex_float = <span class="tok-number">0x3</span>;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> float = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signed = <span class="tok-number">0x5</span>;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signed_char = <span class="tok-number">0x6</span>;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unsigned = <span class="tok-number">0x7</span>;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unsigned_char = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-comment">// DWARF 3.</span>
</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> imaginary_float = <span class="tok-number">0x9</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> packed_decimal = <span class="tok-number">0xa</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> numeric_string = <span class="tok-number">0xb</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> edited = <span class="tok-number">0xc</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signed_fixed = <span class="tok-number">0xd</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unsigned_fixed = <span class="tok-number">0xe</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> decimal_float = <span class="tok-number">0xf</span>;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">// DWARF 4.</span>
</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UTF = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-comment">// DWARF 5.</span>
</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UCS = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASCII = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-comment">// HP extensions.</span>
</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_float80 = <span class="tok-number">0x80</span>; <span class="tok-comment">// Floating-point (80 bit).</span>
</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_complex_float80 = <span class="tok-number">0x81</span>; <span class="tok-comment">// Complex floating-point (80 bit).</span>
</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_float128 = <span class="tok-number">0x82</span>; <span class="tok-comment">// Floating-point (128 bit).</span>
</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_complex_float128 = <span class="tok-number">0x83</span>; <span class="tok-comment">// Complex fp (128 bit).</span>
</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_floathpintel = <span class="tok-number">0x84</span>; <span class="tok-comment">// Floating-point (82 bit IA64).</span>
</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_imaginary_float80 = <span class="tok-number">0x85</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_imaginary_float128 = <span class="tok-number">0x86</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_VAX_float = <span class="tok-number">0x88</span>; <span class="tok-comment">// F or G floating.</span>
</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_VAX_float_d = <span class="tok-number">0x89</span>; <span class="tok-comment">// D floating.</span>
</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_packed_decimal = <span class="tok-number">0x8a</span>; <span class="tok-comment">// Cobol.</span>
</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_zoned_decimal = <span class="tok-number">0x8b</span>; <span class="tok-comment">// Cobol.</span>
</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_edited = <span class="tok-number">0x8c</span>; <span class="tok-comment">// Cobol.</span>
</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_signed_fixed = <span class="tok-number">0x8d</span>; <span class="tok-comment">// Cobol.</span>
</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_unsigned_fixed = <span class="tok-number">0x8e</span>; <span class="tok-comment">// Cobol.</span>
</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_VAX_complex_float = <span class="tok-number">0x8f</span>; <span class="tok-comment">// F or G floating complex.</span>
</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_VAX_complex_float_d = <span class="tok-number">0x90</span>; <span class="tok-comment">// D floating complex.</span>
</span>
<span class="line" id="L47"></span>
</code></pre></body>
</html>