<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>ascii.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Does NOT look at the locale the way C89's toupper(3), isspace() et cetera does.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// I could have taken only a u7 to make this clear, but it would be slower</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// It is my opinion that encodings other than UTF-8 should not be supported.</span>
</span>
<span class="line" id="L4"><span class="tok-comment">//</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// (and 128 bytes is not much to pay).</span>
</span>
<span class="line" id="L6"><span class="tok-comment">// Also does not handle Unicode character classes.</span>
</span>
<span class="line" id="L7"><span class="tok-comment">//</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/USASCII_code_chart.png/1200px-USASCII_code_chart.png</span>
</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Contains constants for the C0 control codes of the ASCII encoding.</span></span>
<span class="line" id="L13"><span class="tok-comment">/// https://en.wikipedia.org/wiki/C0_and_C1_control_codes</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> control_code = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NUL = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOH = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L17">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STX = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L18">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ETX = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EOT = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENQ = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACK = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BEL = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BS = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAB = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LF = <span class="tok-number">0x0A</span>;</span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VT = <span class="tok-number">0x0B</span>;</span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FF = <span class="tok-number">0x0C</span>;</span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CR = <span class="tok-number">0x0D</span>;</span>
<span class="line" id="L29">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SO = <span class="tok-number">0x0E</span>;</span>
<span class="line" id="L30">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SI = <span class="tok-number">0x0F</span>;</span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DLE = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DC1 = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L33">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DC2 = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L34">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DC3 = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DC4 = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NAK = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L37">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYN = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ETB = <span class="tok-number">0x17</span>;</span>
<span class="line" id="L39">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAN = <span class="tok-number">0x18</span>;</span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EM = <span class="tok-number">0x19</span>;</span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUB = <span class="tok-number">0x1A</span>;</span>
<span class="line" id="L42">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ESC = <span class="tok-number">0x1B</span>;</span>
<span class="line" id="L43">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FS = <span class="tok-number">0x1C</span>;</span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GS = <span class="tok-number">0x1D</span>;</span>
<span class="line" id="L45">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RS = <span class="tok-number">0x1E</span>;</span>
<span class="line" id="L46">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> US = <span class="tok-number">0x1F</span>;</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEL = <span class="tok-number">0x7F</span>;</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XON = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> XOFF = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L52">};</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-kw">const</span> tIndex = <span class="tok-kw">enum</span>(<span class="tok-type">u3</span>) {</span>
<span class="line" id="L55">    Alpha,</span>
<span class="line" id="L56">    Hex,</span>
<span class="line" id="L57">    Space,</span>
<span class="line" id="L58">    Digit,</span>
<span class="line" id="L59">    Lower,</span>
<span class="line" id="L60">    Upper,</span>
<span class="line" id="L61">    <span class="tok-comment">// Ctrl, &lt; 0x20 || == DEL</span>
</span>
<span class="line" id="L62">    <span class="tok-comment">// Print, = Graph || == ' '. NOT '\t' et cetera</span>
</span>
<span class="line" id="L63">    Punct,</span>
<span class="line" id="L64">    Graph,</span>
<span class="line" id="L65">    <span class="tok-comment">//ASCII, | ~0b01111111</span>
</span>
<span class="line" id="L66">    <span class="tok-comment">//isBlank, == ' ' || == '\x09'</span>
</span>
<span class="line" id="L67">};</span>
<span class="line" id="L68"></span>
<span class="line" id="L69"><span class="tok-kw">const</span> combinedTable = init: {</span>
<span class="line" id="L70">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> table: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    <span class="tok-kw">const</span> alpha = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L75">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L76">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L77">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L78">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L79">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L82">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L83">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L84">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L85">    };</span>
<span class="line" id="L86">    <span class="tok-kw">const</span> lower = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L87">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L88">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L89">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L90">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L91">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L94">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L95">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L96">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L97">    };</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> upper = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L99">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L100">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L101">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L102">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L103">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L106">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L107">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L108">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L109">    };</span>
<span class="line" id="L110">    <span class="tok-kw">const</span> digit = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L111">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L112">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L113">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L114">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L115">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L118">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L119">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L120">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L121">    };</span>
<span class="line" id="L122">    <span class="tok-kw">const</span> hex = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L123">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L124">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L125">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L126">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L127">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L130">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L131">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L132">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L133">    };</span>
<span class="line" id="L134">    <span class="tok-kw">const</span> space = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L135">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L136">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L137">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L138">        <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L139">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L142">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L143">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L144">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L145">    };</span>
<span class="line" id="L146">    <span class="tok-kw">const</span> punct = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L147">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L148">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L149">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L150">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L151">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">        <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L154">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L155">        <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L156">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L157">    };</span>
<span class="line" id="L158">    <span class="tok-kw">const</span> graph = [_]<span class="tok-type">u1</span>{</span>
<span class="line" id="L159">        <span class="tok-comment">//  0, 1, 2, 3, 4, 5, 6, 7 ,8, 9,10,11,12,13,14,15</span>
</span>
<span class="line" id="L160">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L161">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L162">        <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L163">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L166">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L167">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L168">        <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L169">    };</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i = <span class="tok-number">0</span>;</span>
<span class="line" id="L172">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; <span class="tok-number">128</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L173">        table[i] =</span>
<span class="line" id="L174">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, alpha[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Alpha) |</span>
<span class="line" id="L175">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, hex[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Hex) |</span>
<span class="line" id="L176">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, space[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Space) |</span>
<span class="line" id="L177">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, digit[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Digit) |</span>
<span class="line" id="L178">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, lower[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Lower) |</span>
<span class="line" id="L179">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, upper[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Upper) |</span>
<span class="line" id="L180">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, punct[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Punct) |</span>
<span class="line" id="L181">            <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, graph[i]) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Graph);</span>
<span class="line" id="L182">    }</span>
<span class="line" id="L183">    mem.set(<span class="tok-type">u8</span>, table[<span class="tok-number">128</span>..<span class="tok-number">256</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L184">    <span class="tok-kw">break</span> :init table;</span>
<span class="line" id="L185">};</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">fn</span> <span class="tok-fn">inTable</span>(c: <span class="tok-type">u8</span>, t: tIndex) <span class="tok-type">bool</span> {</span>
<span class="line" id="L188">    <span class="tok-kw">return</span> (combinedTable[c] &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(t))) != <span class="tok-number">0</span>;</span>
<span class="line" id="L189">}</span>
<span class="line" id="L190"></span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAlNum</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L192">    <span class="tok-kw">return</span> (combinedTable[c] &amp; ((<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Alpha)) |</span>
<span class="line" id="L193">        <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@enumToInt</span>(tIndex.Digit))) != <span class="tok-number">0</span>;</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAlpha</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">return</span> inTable(c, tIndex.Alpha);</span>
<span class="line" id="L198">}</span>
<span class="line" id="L199"></span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isCntrl</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L201">    <span class="tok-kw">return</span> c &lt; <span class="tok-number">0x20</span> <span class="tok-kw">or</span> c == <span class="tok-number">127</span>; <span class="tok-comment">//DEL</span>
</span>
<span class="line" id="L202">}</span>
<span class="line" id="L203"></span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isDigit</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L205">    <span class="tok-kw">return</span> inTable(c, tIndex.Digit);</span>
<span class="line" id="L206">}</span>
<span class="line" id="L207"></span>
<span class="line" id="L208"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isGraph</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L209">    <span class="tok-kw">return</span> inTable(c, tIndex.Graph);</span>
<span class="line" id="L210">}</span>
<span class="line" id="L211"></span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isLower</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L213">    <span class="tok-kw">return</span> inTable(c, tIndex.Lower);</span>
<span class="line" id="L214">}</span>
<span class="line" id="L215"></span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPrint</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L217">    <span class="tok-kw">return</span> inTable(c, tIndex.Graph) <span class="tok-kw">or</span> c == <span class="tok-str">' '</span>;</span>
<span class="line" id="L218">}</span>
<span class="line" id="L219"></span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isPunct</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L221">    <span class="tok-kw">return</span> inTable(c, tIndex.Punct);</span>
<span class="line" id="L222">}</span>
<span class="line" id="L223"></span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isSpace</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L225">    <span class="tok-kw">return</span> inTable(c, tIndex.Space);</span>
<span class="line" id="L226">}</span>
<span class="line" id="L227"></span>
<span class="line" id="L228"><span class="tok-comment">/// All the values for which isSpace() returns true. This may be used with</span></span>
<span class="line" id="L229"><span class="tok-comment">/// e.g. std.mem.trim() to trim whiteSpace.</span></span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> spaces = [_]<span class="tok-type">u8</span>{ <span class="tok-str">' '</span>, <span class="tok-str">'\t'</span>, <span class="tok-str">'\n'</span>, <span class="tok-str">'\r'</span>, control_code.VT, control_code.FF };</span>
<span class="line" id="L231"></span>
<span class="line" id="L232"><span class="tok-kw">test</span> <span class="tok-str">&quot;spaces&quot;</span> {</span>
<span class="line" id="L233">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L234">    <span class="tok-kw">for</span> (spaces) |space| <span class="tok-kw">try</span> testing.expect(isSpace(space));</span>
<span class="line" id="L235"></span>
<span class="line" id="L236">    <span class="tok-kw">var</span> i: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L237">    <span class="tok-kw">while</span> (isASCII(i)) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L238">        <span class="tok-kw">if</span> (isSpace(i)) <span class="tok-kw">try</span> testing.expect(std.mem.indexOfScalar(<span class="tok-type">u8</span>, &amp;spaces, i) != <span class="tok-null">null</span>);</span>
<span class="line" id="L239">    }</span>
<span class="line" id="L240">}</span>
<span class="line" id="L241"></span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isUpper</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L243">    <span class="tok-kw">return</span> inTable(c, tIndex.Upper);</span>
<span class="line" id="L244">}</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isXDigit</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L247">    <span class="tok-kw">return</span> inTable(c, tIndex.Hex);</span>
<span class="line" id="L248">}</span>
<span class="line" id="L249"></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isASCII</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L251">    <span class="tok-kw">return</span> c &lt; <span class="tok-number">128</span>;</span>
<span class="line" id="L252">}</span>
<span class="line" id="L253"></span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isBlank</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L255">    <span class="tok-kw">return</span> (c == <span class="tok-str">' '</span>) <span class="tok-kw">or</span> (c == <span class="tok-str">'\x09'</span>);</span>
<span class="line" id="L256">}</span>
<span class="line" id="L257"></span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toUpper</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L259">    <span class="tok-kw">if</span> (isLower(c)) {</span>
<span class="line" id="L260">        <span class="tok-kw">return</span> c &amp; <span class="tok-number">0b11011111</span>;</span>
<span class="line" id="L261">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L262">        <span class="tok-kw">return</span> c;</span>
<span class="line" id="L263">    }</span>
<span class="line" id="L264">}</span>
<span class="line" id="L265"></span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toLower</span>(c: <span class="tok-type">u8</span>) <span class="tok-type">u8</span> {</span>
<span class="line" id="L267">    <span class="tok-kw">if</span> (isUpper(c)) {</span>
<span class="line" id="L268">        <span class="tok-kw">return</span> c | <span class="tok-number">0b00100000</span>;</span>
<span class="line" id="L269">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L270">        <span class="tok-kw">return</span> c;</span>
<span class="line" id="L271">    }</span>
<span class="line" id="L272">}</span>
<span class="line" id="L273"></span>
<span class="line" id="L274"><span class="tok-kw">test</span> <span class="tok-str">&quot;ascii character classes&quot;</span> {</span>
<span class="line" id="L275">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-kw">try</span> testing.expect(<span class="tok-str">'C'</span> == toUpper(<span class="tok-str">'c'</span>));</span>
<span class="line" id="L278">    <span class="tok-kw">try</span> testing.expect(<span class="tok-str">':'</span> == toUpper(<span class="tok-str">':'</span>));</span>
<span class="line" id="L279">    <span class="tok-kw">try</span> testing.expect(<span class="tok-str">'\xab'</span> == toUpper(<span class="tok-str">'\xab'</span>));</span>
<span class="line" id="L280">    <span class="tok-kw">try</span> testing.expect(<span class="tok-str">'c'</span> == toLower(<span class="tok-str">'C'</span>));</span>
<span class="line" id="L281">    <span class="tok-kw">try</span> testing.expect(isAlpha(<span class="tok-str">'c'</span>));</span>
<span class="line" id="L282">    <span class="tok-kw">try</span> testing.expect(!isAlpha(<span class="tok-str">'5'</span>));</span>
<span class="line" id="L283">    <span class="tok-kw">try</span> testing.expect(isSpace(<span class="tok-str">' '</span>));</span>
<span class="line" id="L284">}</span>
<span class="line" id="L285"></span>
<span class="line" id="L286"><span class="tok-comment">/// Writes a lower case copy of `ascii_string` to `output`.</span></span>
<span class="line" id="L287"><span class="tok-comment">/// Asserts `output.len &gt;= ascii_string.len`.</span></span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lowerString</span>(output: []<span class="tok-type">u8</span>, ascii_string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L289">    std.debug.assert(output.len &gt;= ascii_string.len);</span>
<span class="line" id="L290">    <span class="tok-kw">for</span> (ascii_string) |c, i| {</span>
<span class="line" id="L291">        output[i] = toLower(c);</span>
<span class="line" id="L292">    }</span>
<span class="line" id="L293">    <span class="tok-kw">return</span> output[<span class="tok-number">0</span>..ascii_string.len];</span>
<span class="line" id="L294">}</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-kw">test</span> <span class="tok-str">&quot;lowerString&quot;</span> {</span>
<span class="line" id="L297">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L298">    <span class="tok-kw">const</span> result = lowerString(&amp;buf, <span class="tok-str">&quot;aBcDeFgHiJkLmNOPqrst0234+💩!&quot;</span>);</span>
<span class="line" id="L299">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;abcdefghijklmnopqrst0234+💩!&quot;</span>, result);</span>
<span class="line" id="L300">}</span>
<span class="line" id="L301"></span>
<span class="line" id="L302"><span class="tok-comment">/// Allocates a lower case copy of `ascii_string`.</span></span>
<span class="line" id="L303"><span class="tok-comment">/// Caller owns returned string and must free with `allocator`.</span></span>
<span class="line" id="L304"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocLowerString</span>(allocator: std.mem.Allocator, ascii_string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L305">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, ascii_string.len);</span>
<span class="line" id="L306">    <span class="tok-kw">return</span> lowerString(result, ascii_string);</span>
<span class="line" id="L307">}</span>
<span class="line" id="L308"></span>
<span class="line" id="L309"><span class="tok-kw">test</span> <span class="tok-str">&quot;allocLowerString&quot;</span> {</span>
<span class="line" id="L310">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocLowerString(std.testing.allocator, <span class="tok-str">&quot;aBcDeFgHiJkLmNOPqrst0234+💩!&quot;</span>);</span>
<span class="line" id="L311">    <span class="tok-kw">defer</span> std.testing.allocator.free(result);</span>
<span class="line" id="L312">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;abcdefghijklmnopqrst0234+💩!&quot;</span>, result);</span>
<span class="line" id="L313">}</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-comment">/// Writes an upper case copy of `ascii_string` to `output`.</span></span>
<span class="line" id="L316"><span class="tok-comment">/// Asserts `output.len &gt;= ascii_string.len`.</span></span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">upperString</span>(output: []<span class="tok-type">u8</span>, ascii_string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-type">u8</span> {</span>
<span class="line" id="L318">    std.debug.assert(output.len &gt;= ascii_string.len);</span>
<span class="line" id="L319">    <span class="tok-kw">for</span> (ascii_string) |c, i| {</span>
<span class="line" id="L320">        output[i] = toUpper(c);</span>
<span class="line" id="L321">    }</span>
<span class="line" id="L322">    <span class="tok-kw">return</span> output[<span class="tok-number">0</span>..ascii_string.len];</span>
<span class="line" id="L323">}</span>
<span class="line" id="L324"></span>
<span class="line" id="L325"><span class="tok-kw">test</span> <span class="tok-str">&quot;upperString&quot;</span> {</span>
<span class="line" id="L326">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L327">    <span class="tok-kw">const</span> result = upperString(&amp;buf, <span class="tok-str">&quot;aBcDeFgHiJkLmNOPqrst0234+💩!&quot;</span>);</span>
<span class="line" id="L328">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRST0234+💩!&quot;</span>, result);</span>
<span class="line" id="L329">}</span>
<span class="line" id="L330"></span>
<span class="line" id="L331"><span class="tok-comment">/// Allocates an upper case copy of `ascii_string`.</span></span>
<span class="line" id="L332"><span class="tok-comment">/// Caller owns returned string and must free with `allocator`.</span></span>
<span class="line" id="L333"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocUpperString</span>(allocator: std.mem.Allocator, ascii_string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L334">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, ascii_string.len);</span>
<span class="line" id="L335">    <span class="tok-kw">return</span> upperString(result, ascii_string);</span>
<span class="line" id="L336">}</span>
<span class="line" id="L337"></span>
<span class="line" id="L338"><span class="tok-kw">test</span> <span class="tok-str">&quot;allocUpperString&quot;</span> {</span>
<span class="line" id="L339">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocUpperString(std.testing.allocator, <span class="tok-str">&quot;aBcDeFgHiJkLmNOPqrst0234+💩!&quot;</span>);</span>
<span class="line" id="L340">    <span class="tok-kw">defer</span> std.testing.allocator.free(result);</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRST0234+💩!&quot;</span>, result);</span>
<span class="line" id="L342">}</span>
<span class="line" id="L343"></span>
<span class="line" id="L344"><span class="tok-comment">/// Compares strings `a` and `b` case insensitively and returns whether they are equal.</span></span>
<span class="line" id="L345"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eqlIgnoreCase</span>(a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L346">    <span class="tok-kw">if</span> (a.len != b.len) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L347">    <span class="tok-kw">for</span> (a) |a_c, i| {</span>
<span class="line" id="L348">        <span class="tok-kw">if</span> (toLower(a_c) != toLower(b[i])) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L349">    }</span>
<span class="line" id="L350">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L351">}</span>
<span class="line" id="L352"></span>
<span class="line" id="L353"><span class="tok-kw">test</span> <span class="tok-str">&quot;eqlIgnoreCase&quot;</span> {</span>
<span class="line" id="L354">    <span class="tok-kw">try</span> std.testing.expect(eqlIgnoreCase(<span class="tok-str">&quot;HEl💩Lo!&quot;</span>, <span class="tok-str">&quot;hel💩lo!&quot;</span>));</span>
<span class="line" id="L355">    <span class="tok-kw">try</span> std.testing.expect(!eqlIgnoreCase(<span class="tok-str">&quot;hElLo!&quot;</span>, <span class="tok-str">&quot;hello! &quot;</span>));</span>
<span class="line" id="L356">    <span class="tok-kw">try</span> std.testing.expect(!eqlIgnoreCase(<span class="tok-str">&quot;hElLo!&quot;</span>, <span class="tok-str">&quot;helro!&quot;</span>));</span>
<span class="line" id="L357">}</span>
<span class="line" id="L358"></span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">startsWithIgnoreCase</span>(haystack: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, needle: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L360">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-null">false</span> <span class="tok-kw">else</span> eqlIgnoreCase(haystack[<span class="tok-number">0</span>..needle.len], needle);</span>
<span class="line" id="L361">}</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-kw">test</span> <span class="tok-str">&quot;ascii.startsWithIgnoreCase&quot;</span> {</span>
<span class="line" id="L364">    <span class="tok-kw">try</span> std.testing.expect(startsWithIgnoreCase(<span class="tok-str">&quot;boB&quot;</span>, <span class="tok-str">&quot;Bo&quot;</span>));</span>
<span class="line" id="L365">    <span class="tok-kw">try</span> std.testing.expect(!startsWithIgnoreCase(<span class="tok-str">&quot;Needle in hAyStAcK&quot;</span>, <span class="tok-str">&quot;haystack&quot;</span>));</span>
<span class="line" id="L366">}</span>
<span class="line" id="L367"></span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">endsWithIgnoreCase</span>(haystack: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, needle: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L369">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (needle.len &gt; haystack.len) <span class="tok-null">false</span> <span class="tok-kw">else</span> eqlIgnoreCase(haystack[haystack.len - needle.len ..], needle);</span>
<span class="line" id="L370">}</span>
<span class="line" id="L371"></span>
<span class="line" id="L372"><span class="tok-kw">test</span> <span class="tok-str">&quot;ascii.endsWithIgnoreCase&quot;</span> {</span>
<span class="line" id="L373">    <span class="tok-kw">try</span> std.testing.expect(endsWithIgnoreCase(<span class="tok-str">&quot;Needle in HaYsTaCk&quot;</span>, <span class="tok-str">&quot;haystack&quot;</span>));</span>
<span class="line" id="L374">    <span class="tok-kw">try</span> std.testing.expect(!endsWithIgnoreCase(<span class="tok-str">&quot;BoB&quot;</span>, <span class="tok-str">&quot;Bo&quot;</span>));</span>
<span class="line" id="L375">}</span>
<span class="line" id="L376"></span>
<span class="line" id="L377"><span class="tok-comment">/// Finds `substr` in `container`, ignoring case, starting at `start_index`.</span></span>
<span class="line" id="L378"><span class="tok-comment">/// TODO boyer-moore algorithm</span></span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfIgnoreCasePos</span>(container: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, start_index: <span class="tok-type">usize</span>, substr: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L380">    <span class="tok-kw">if</span> (substr.len &gt; container.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = start_index;</span>
<span class="line" id="L383">    <span class="tok-kw">const</span> end = container.len - substr.len;</span>
<span class="line" id="L384">    <span class="tok-kw">while</span> (i &lt;= end) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L385">        <span class="tok-kw">if</span> (eqlIgnoreCase(container[i .. i + substr.len], substr)) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L386">    }</span>
<span class="line" id="L387">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L388">}</span>
<span class="line" id="L389"></span>
<span class="line" id="L390"><span class="tok-comment">/// Finds `substr` in `container`, ignoring case, starting at index 0.</span></span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOfIgnoreCase</span>(container: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, substr: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L392">    <span class="tok-kw">return</span> indexOfIgnoreCasePos(container, <span class="tok-number">0</span>, substr);</span>
<span class="line" id="L393">}</span>
<span class="line" id="L394"></span>
<span class="line" id="L395"><span class="tok-kw">test</span> <span class="tok-str">&quot;indexOfIgnoreCase&quot;</span> {</span>
<span class="line" id="L396">    <span class="tok-kw">try</span> std.testing.expect(indexOfIgnoreCase(<span class="tok-str">&quot;one Two Three Four&quot;</span>, <span class="tok-str">&quot;foUr&quot;</span>).? == <span class="tok-number">14</span>);</span>
<span class="line" id="L397">    <span class="tok-kw">try</span> std.testing.expect(indexOfIgnoreCase(<span class="tok-str">&quot;one two three FouR&quot;</span>, <span class="tok-str">&quot;gOur&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L398">    <span class="tok-kw">try</span> std.testing.expect(indexOfIgnoreCase(<span class="tok-str">&quot;foO&quot;</span>, <span class="tok-str">&quot;Foo&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L399">    <span class="tok-kw">try</span> std.testing.expect(indexOfIgnoreCase(<span class="tok-str">&quot;foo&quot;</span>, <span class="tok-str">&quot;fool&quot;</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">try</span> std.testing.expect(indexOfIgnoreCase(<span class="tok-str">&quot;FOO foo&quot;</span>, <span class="tok-str">&quot;fOo&quot;</span>).? == <span class="tok-number">0</span>);</span>
<span class="line" id="L402">}</span>
<span class="line" id="L403"></span>
<span class="line" id="L404"><span class="tok-comment">/// Compares two slices of numbers lexicographically. O(n).</span></span>
<span class="line" id="L405"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">orderIgnoreCase</span>(lhs: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, rhs: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) std.math.Order {</span>
<span class="line" id="L406">    <span class="tok-kw">const</span> n = std.math.min(lhs.len, rhs.len);</span>
<span class="line" id="L407">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L408">    <span class="tok-kw">while</span> (i &lt; n) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L409">        <span class="tok-kw">switch</span> (std.math.order(toLower(lhs[i]), toLower(rhs[i]))) {</span>
<span class="line" id="L410">            .eq =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L411">            .lt =&gt; <span class="tok-kw">return</span> .lt,</span>
<span class="line" id="L412">            .gt =&gt; <span class="tok-kw">return</span> .gt,</span>
<span class="line" id="L413">        }</span>
<span class="line" id="L414">    }</span>
<span class="line" id="L415">    <span class="tok-kw">return</span> std.math.order(lhs.len, rhs.len);</span>
<span class="line" id="L416">}</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-comment">/// Returns true if lhs &lt; rhs, false otherwise</span></span>
<span class="line" id="L419"><span class="tok-comment">/// TODO rename &quot;IgnoreCase&quot; to &quot;Insensitive&quot; in this entire file.</span></span>
<span class="line" id="L420"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lessThanIgnoreCase</span>(lhs: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, rhs: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L421">    <span class="tok-kw">return</span> orderIgnoreCase(lhs, rhs) == .lt;</span>
<span class="line" id="L422">}</span>
<span class="line" id="L423"></span>
</code></pre></body>
</html>