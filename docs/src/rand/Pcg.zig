<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>rand/Pcg.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! PCG32 - http://www.pcg-random.org/</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! PRNG</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Random = std.rand.Random;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Pcg = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> default_multiplier = <span class="tok-number">6364136223846793005</span>;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">s: <span class="tok-type">u64</span>,</span>
<span class="line" id="L12">i: <span class="tok-type">u64</span>,</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_s: <span class="tok-type">u64</span>) Pcg {</span>
<span class="line" id="L15">    <span class="tok-kw">var</span> pcg = Pcg{</span>
<span class="line" id="L16">        .s = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L17">        .i = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L18">    };</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    pcg.seed(init_s);</span>
<span class="line" id="L21">    <span class="tok-kw">return</span> pcg;</span>
<span class="line" id="L22">}</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>(self: *Pcg) Random {</span>
<span class="line" id="L25">    <span class="tok-kw">return</span> Random.init(self, fill);</span>
<span class="line" id="L26">}</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Pcg) <span class="tok-type">u32</span> {</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> l = self.s;</span>
<span class="line" id="L30">    self.s = l *% default_multiplier +% (self.i | <span class="tok-number">1</span>);</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">const</span> xor_s = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, ((l &gt;&gt; <span class="tok-number">18</span>) ^ l) &gt;&gt; <span class="tok-number">27</span>);</span>
<span class="line" id="L33">    <span class="tok-kw">const</span> rot = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, l &gt;&gt; <span class="tok-number">59</span>);</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">return</span> (xor_s &gt;&gt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, rot)) | (xor_s &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u5</span>, (<span class="tok-number">0</span> -% rot) &amp; <span class="tok-number">31</span>));</span>
<span class="line" id="L36">}</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-kw">fn</span> <span class="tok-fn">seed</span>(self: *Pcg, init_s: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L39">    <span class="tok-comment">// Pcg requires 128-bits of seed.</span>
</span>
<span class="line" id="L40">    <span class="tok-kw">var</span> gen = std.rand.SplitMix64.init(init_s);</span>
<span class="line" id="L41">    self.seedTwo(gen.next(), gen.next());</span>
<span class="line" id="L42">}</span>
<span class="line" id="L43"></span>
<span class="line" id="L44"><span class="tok-kw">fn</span> <span class="tok-fn">seedTwo</span>(self: *Pcg, init_s: <span class="tok-type">u64</span>, init_i: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L45">    self.s = <span class="tok-number">0</span>;</span>
<span class="line" id="L46">    self.i = (init_s &lt;&lt; <span class="tok-number">1</span>) | <span class="tok-number">1</span>;</span>
<span class="line" id="L47">    self.s = self.s *% default_multiplier +% self.i;</span>
<span class="line" id="L48">    self.s +%= init_i;</span>
<span class="line" id="L49">    self.s = self.s *% default_multiplier +% self.i;</span>
<span class="line" id="L50">}</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(self: *Pcg, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L53">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L54">    <span class="tok-kw">const</span> aligned_len = buf.len - (buf.len &amp; <span class="tok-number">7</span>);</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">    <span class="tok-comment">// Complete 4 byte segments.</span>
</span>
<span class="line" id="L57">    <span class="tok-kw">while</span> (i &lt; aligned_len) : (i += <span class="tok-number">4</span>) {</span>
<span class="line" id="L58">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L59">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L60">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">4</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L61">            buf[i + j] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L62">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L63">        }</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-comment">// Remaining. (cuts the stream)</span>
</span>
<span class="line" id="L67">    <span class="tok-kw">if</span> (i != buf.len) {</span>
<span class="line" id="L68">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L69">        <span class="tok-kw">while</span> (i &lt; buf.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L70">            buf[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L71">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L72">        }</span>
<span class="line" id="L73">    }</span>
<span class="line" id="L74">}</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-kw">test</span> <span class="tok-str">&quot;pcg sequence&quot;</span> {</span>
<span class="line" id="L77">    <span class="tok-kw">var</span> r = Pcg.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L78">    <span class="tok-kw">const</span> s0: <span class="tok-type">u64</span> = <span class="tok-number">0x9394bf54ce5d79de</span>;</span>
<span class="line" id="L79">    <span class="tok-kw">const</span> s1: <span class="tok-type">u64</span> = <span class="tok-number">0x84e9c579ef59bbf7</span>;</span>
<span class="line" id="L80">    r.seedTwo(s0, s1);</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-kw">const</span> seq = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L83">        <span class="tok-number">2881561918</span>,</span>
<span class="line" id="L84">        <span class="tok-number">3063928540</span>,</span>
<span class="line" id="L85">        <span class="tok-number">1199791034</span>,</span>
<span class="line" id="L86">        <span class="tok-number">2487695858</span>,</span>
<span class="line" id="L87">        <span class="tok-number">1479648952</span>,</span>
<span class="line" id="L88">        <span class="tok-number">3247963454</span>,</span>
<span class="line" id="L89">    };</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">    <span class="tok-kw">for</span> (seq) |s| {</span>
<span class="line" id="L92">        <span class="tok-kw">try</span> std.testing.expect(s == r.next());</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94">}</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">test</span> <span class="tok-str">&quot;pcg fill&quot;</span> {</span>
<span class="line" id="L97">    <span class="tok-kw">var</span> r = Pcg.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L98">    <span class="tok-kw">const</span> s0: <span class="tok-type">u64</span> = <span class="tok-number">0x9394bf54ce5d79de</span>;</span>
<span class="line" id="L99">    <span class="tok-kw">const</span> s1: <span class="tok-type">u64</span> = <span class="tok-number">0x84e9c579ef59bbf7</span>;</span>
<span class="line" id="L100">    r.seedTwo(s0, s1);</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">    <span class="tok-kw">const</span> seq = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L103">        <span class="tok-number">2881561918</span>,</span>
<span class="line" id="L104">        <span class="tok-number">3063928540</span>,</span>
<span class="line" id="L105">        <span class="tok-number">1199791034</span>,</span>
<span class="line" id="L106">        <span class="tok-number">2487695858</span>,</span>
<span class="line" id="L107">        <span class="tok-number">1479648952</span>,</span>
<span class="line" id="L108">        <span class="tok-number">3247963454</span>,</span>
<span class="line" id="L109">    };</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">    <span class="tok-kw">for</span> (seq) |s| {</span>
<span class="line" id="L112">        <span class="tok-kw">var</span> buf0: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L113">        <span class="tok-kw">var</span> buf1: [<span class="tok-number">3</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L114">        std.mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;buf0, s);</span>
<span class="line" id="L115">        r.fill(&amp;buf1);</span>
<span class="line" id="L116">        <span class="tok-kw">try</span> std.testing.expect(std.mem.eql(<span class="tok-type">u8</span>, buf0[<span class="tok-number">0</span>..<span class="tok-number">3</span>], buf1[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118">}</span>
<span class="line" id="L119"></span>
</code></pre></body>
</html>