<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash/adler.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Adler32 checksum.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">//</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// https://tools.ietf.org/html/rfc1950#section-9</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://github.com/madler/zlib/blob/master/adler32.c</span>
</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Adler32 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    <span class="tok-kw">const</span> base = <span class="tok-number">65521</span>;</span>
<span class="line" id="L11">    <span class="tok-kw">const</span> nmax = <span class="tok-number">5552</span>;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    adler: <span class="tok-type">u32</span>,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Adler32 {</span>
<span class="line" id="L16">        <span class="tok-kw">return</span> Adler32{ .adler = <span class="tok-number">1</span> };</span>
<span class="line" id="L17">    }</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">    <span class="tok-comment">// This fast variant is taken from zlib. It reduces the required modulos and unrolls longer</span>
</span>
<span class="line" id="L20">    <span class="tok-comment">// buffer inputs and should be much quicker.</span>
</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Adler32, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L22">        <span class="tok-kw">var</span> s1 = self.adler &amp; <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L23">        <span class="tok-kw">var</span> s2 = (self.adler &gt;&gt; <span class="tok-number">16</span>) &amp; <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        <span class="tok-kw">if</span> (input.len == <span class="tok-number">1</span>) {</span>
<span class="line" id="L26">            s1 +%= input[<span class="tok-number">0</span>];</span>
<span class="line" id="L27">            <span class="tok-kw">if</span> (s1 &gt;= base) {</span>
<span class="line" id="L28">                s1 -= base;</span>
<span class="line" id="L29">            }</span>
<span class="line" id="L30">            s2 +%= s1;</span>
<span class="line" id="L31">            <span class="tok-kw">if</span> (s2 &gt;= base) {</span>
<span class="line" id="L32">                s2 -= base;</span>
<span class="line" id="L33">            }</span>
<span class="line" id="L34">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (input.len &lt; <span class="tok-number">16</span>) {</span>
<span class="line" id="L35">            <span class="tok-kw">for</span> (input) |b| {</span>
<span class="line" id="L36">                s1 +%= b;</span>
<span class="line" id="L37">                s2 +%= s1;</span>
<span class="line" id="L38">            }</span>
<span class="line" id="L39">            <span class="tok-kw">if</span> (s1 &gt;= base) {</span>
<span class="line" id="L40">                s1 -= base;</span>
<span class="line" id="L41">            }</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">            s2 %= base;</span>
<span class="line" id="L44">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L45">            <span class="tok-kw">const</span> n = nmax / <span class="tok-number">16</span>; <span class="tok-comment">// note: 16 | nmax</span>
</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">            <span class="tok-kw">while</span> (i + nmax &lt;= input.len) {</span>
<span class="line" id="L50">                <span class="tok-kw">var</span> rounds: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L51">                <span class="tok-kw">while</span> (rounds &lt; n) : (rounds += <span class="tok-number">1</span>) {</span>
<span class="line" id="L52">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L53">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">16</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L54">                        s1 +%= input[i + j];</span>
<span class="line" id="L55">                        s2 +%= s1;</span>
<span class="line" id="L56">                    }</span>
<span class="line" id="L57">                    i += <span class="tok-number">16</span>;</span>
<span class="line" id="L58">                }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">                s1 %= base;</span>
<span class="line" id="L61">                s2 %= base;</span>
<span class="line" id="L62">            }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">            <span class="tok-kw">if</span> (i &lt; input.len) {</span>
<span class="line" id="L65">                <span class="tok-kw">while</span> (i + <span class="tok-number">16</span> &lt;= input.len) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L66">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L67">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">16</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L68">                        s1 +%= input[i + j];</span>
<span class="line" id="L69">                        s2 +%= s1;</span>
<span class="line" id="L70">                    }</span>
<span class="line" id="L71">                }</span>
<span class="line" id="L72">                <span class="tok-kw">while</span> (i &lt; input.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L73">                    s1 +%= input[i];</span>
<span class="line" id="L74">                    s2 +%= s1;</span>
<span class="line" id="L75">                }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">                s1 %= base;</span>
<span class="line" id="L78">                s2 %= base;</span>
<span class="line" id="L79">            }</span>
<span class="line" id="L80">        }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">        self.adler = s1 | (s2 &lt;&lt; <span class="tok-number">16</span>);</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Adler32) <span class="tok-type">u32</span> {</span>
<span class="line" id="L86">        <span class="tok-kw">return</span> self.adler;</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L90">        <span class="tok-kw">var</span> c = Adler32.init();</span>
<span class="line" id="L91">        c.update(input);</span>
<span class="line" id="L92">        <span class="tok-kw">return</span> c.final();</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94">};</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">test</span> <span class="tok-str">&quot;adler32 sanity&quot;</span> {</span>
<span class="line" id="L97">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x620062</span>), Adler32.hash(<span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L98">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0xbc002ed</span>), Adler32.hash(<span class="tok-str">&quot;example&quot;</span>));</span>
<span class="line" id="L99">}</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">test</span> <span class="tok-str">&quot;adler32 long&quot;</span> {</span>
<span class="line" id="L102">    <span class="tok-kw">const</span> long1 = [_]<span class="tok-type">u8</span>{<span class="tok-number">1</span>} ** <span class="tok-number">1024</span>;</span>
<span class="line" id="L103">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x06780401</span>), Adler32.hash(long1[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">const</span> long2 = [_]<span class="tok-type">u8</span>{<span class="tok-number">1</span>} ** <span class="tok-number">1025</span>;</span>
<span class="line" id="L106">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x0a7a0402</span>), Adler32.hash(long2[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L107">}</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-kw">test</span> <span class="tok-str">&quot;adler32 very long&quot;</span> {</span>
<span class="line" id="L110">    <span class="tok-kw">const</span> long = [_]<span class="tok-type">u8</span>{<span class="tok-number">1</span>} ** <span class="tok-number">5553</span>;</span>
<span class="line" id="L111">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x707f15b2</span>), Adler32.hash(long[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L112">}</span>
<span class="line" id="L113"></span>
<span class="line" id="L114"><span class="tok-kw">test</span> <span class="tok-str">&quot;adler32 very long with variation&quot;</span> {</span>
<span class="line" id="L115">    <span class="tok-kw">const</span> long = <span class="tok-kw">comptime</span> blk: {</span>
<span class="line" id="L116">        <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">7000</span>);</span>
<span class="line" id="L117">        <span class="tok-kw">var</span> result: [<span class="tok-number">6000</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L120">        <span class="tok-kw">while</span> (i &lt; result.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L121">            result[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L122">        }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">        <span class="tok-kw">break</span> :blk result;</span>
<span class="line" id="L125">    };</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x5af38d6e</span>), std.hash.Adler32.hash(long[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L128">}</span>
<span class="line" id="L129"></span>
</code></pre></body>
</html>