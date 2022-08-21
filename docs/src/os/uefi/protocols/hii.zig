<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/hii.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIHandle = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// The header found at the start of each package.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPackageHeader = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    length: <span class="tok-type">u24</span>,</span>
<span class="line" id="L9">    <span class="tok-type">type</span>: <span class="tok-type">u8</span>,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> type_all: <span class="tok-type">u8</span> = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L12">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> type_guid: <span class="tok-type">u8</span> = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L13">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> forms: <span class="tok-type">u8</span> = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> strings: <span class="tok-type">u8</span> = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> fonts: <span class="tok-type">u8</span> = <span class="tok-number">0x5</span>;</span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> images: <span class="tok-type">u8</span> = <span class="tok-number">0x6</span>;</span>
<span class="line" id="L17">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> simple_fonsts: <span class="tok-type">u8</span> = <span class="tok-number">0x7</span>;</span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> device_path: <span class="tok-type">u8</span> = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> keyboard_layout: <span class="tok-type">u8</span> = <span class="tok-number">0x9</span>;</span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> animations: <span class="tok-type">u8</span> = <span class="tok-number">0xa</span>;</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> end: <span class="tok-type">u8</span> = <span class="tok-number">0xdf</span>;</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> type_system_begin: <span class="tok-type">u8</span> = <span class="tok-number">0xe0</span>;</span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> type_system_end: <span class="tok-type">u8</span> = <span class="tok-number">0xff</span>;</span>
<span class="line" id="L24">};</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// The header found at the start of each package list.</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIPackageList = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L28">    package_list_guid: Guid,</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// The size of the package list (in bytes), including the header.</span></span>
<span class="line" id="L31">    package_list_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-comment">// TODO implement iterator</span>
</span>
<span class="line" id="L34">};</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIISimplifiedFontPackage = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L37">    header: HIIPackageHeader,</span>
<span class="line" id="L38">    number_of_narrow_glyphs: <span class="tok-type">u16</span>,</span>
<span class="line" id="L39">    number_of_wide_glyphs: <span class="tok-type">u16</span>,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getNarrowGlyphs</span>(self: *HIISimplifiedFontPackage) []NarrowGlyph {</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]NarrowGlyph, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(HIISimplifiedFontPackage))[<span class="tok-number">0</span>..self.number_of_narrow_glyphs];</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44">};</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NarrowGlyph = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L47">    unicode_weight: <span class="tok-type">u16</span>,</span>
<span class="line" id="L48">    attributes: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L49">        non_spacing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L50">        wide: <span class="tok-type">bool</span>,</span>
<span class="line" id="L51">        _pad: <span class="tok-type">u6</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L52">    },</span>
<span class="line" id="L53">    glyph_col_1: [<span class="tok-number">19</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L54">};</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WideGlyph = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L57">    unicode_weight: <span class="tok-type">u16</span>,</span>
<span class="line" id="L58">    attributes: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L59">        non_spacing: <span class="tok-type">bool</span>,</span>
<span class="line" id="L60">        wide: <span class="tok-type">bool</span>,</span>
<span class="line" id="L61">        _pad: <span class="tok-type">u6</span>,</span>
<span class="line" id="L62">    },</span>
<span class="line" id="L63">    glyph_col_1: [<span class="tok-number">19</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L64">    glyph_col_2: [<span class="tok-number">19</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L65">    _pad: [<span class="tok-number">3</span>]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">3</span>,</span>
<span class="line" id="L66">};</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HIIStringPackage = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L69">    header: HIIPackageHeader,</span>
<span class="line" id="L70">    hdr_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L71">    string_info_offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L72">    language_window: [<span class="tok-number">16</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L73">    language_name: <span class="tok-type">u16</span>,</span>
<span class="line" id="L74">    language: [<span class="tok-number">3</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L75">};</span>
<span class="line" id="L76"></span>
</code></pre></body>
</html>