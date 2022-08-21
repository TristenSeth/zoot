<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dwarf/FORM.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addr = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> block2 = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> block4 = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data2 = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data4 = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data8 = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> string = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> block = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> block1 = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data1 = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> flag = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sdata = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strp = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> udata = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref_addr = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref1 = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref2 = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref4 = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref8 = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref_udata = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> indirect = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sec_offset = <span class="tok-number">0x17</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> exprloc = <span class="tok-number">0x18</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> flag_present = <span class="tok-number">0x19</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strx = <span class="tok-number">0x1a</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx = <span class="tok-number">0x1b</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref_sup4 = <span class="tok-number">0x1c</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strp_sup = <span class="tok-number">0x1d</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> data16 = <span class="tok-number">0x1e</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> line_strp = <span class="tok-number">0x1f</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref_sig8 = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> implicit_const = <span class="tok-number">0x21</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> loclistx = <span class="tok-number">0x22</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rnglistx = <span class="tok-number">0x23</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ref_sup8 = <span class="tok-number">0x24</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strx1 = <span class="tok-number">0x25</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strx2 = <span class="tok-number">0x26</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strx3 = <span class="tok-number">0x27</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> strx4 = <span class="tok-number">0x28</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx1 = <span class="tok-number">0x29</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx2 = <span class="tok-number">0x2a</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx3 = <span class="tok-number">0x2b</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx4 = <span class="tok-number">0x2c</span>;</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-comment">// Extensions for Fission.  See http://gcc.gnu.org/wiki/DebugFission.</span>
</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_addr_index = <span class="tok-number">0x1f01</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_str_index = <span class="tok-number">0x1f02</span>;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-comment">// Extensions for DWZ multifile.</span>
</span>
<span class="line" id="L50"><span class="tok-comment">// See http://www.dwarfstd.org/ShowIssue.php?issue=120604.1&amp;type=open .</span>
</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_ref_alt = <span class="tok-number">0x1f20</span>;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_strp_alt = <span class="tok-number">0x1f21</span>;</span>
<span class="line" id="L53"></span>
</code></pre></body>
</html>