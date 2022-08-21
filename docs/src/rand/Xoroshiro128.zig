<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>rand/Xoroshiro128.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! Xoroshiro128+ - http://xoroshiro.di.unimi.it/</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! PRNG</span></span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Random = std.rand.Random;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> Xoroshiro128 = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">s: [<span class="tok-number">2</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_s: <span class="tok-type">u64</span>) Xoroshiro128 {</span>
<span class="line" id="L13">    <span class="tok-kw">var</span> x = Xoroshiro128{ .s = <span class="tok-null">undefined</span> };</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    x.seed(init_s);</span>
<span class="line" id="L16">    <span class="tok-kw">return</span> x;</span>
<span class="line" id="L17">}</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>(self: *Xoroshiro128) Random {</span>
<span class="line" id="L20">    <span class="tok-kw">return</span> Random.init(self, fill);</span>
<span class="line" id="L21">}</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Xoroshiro128) <span class="tok-type">u64</span> {</span>
<span class="line" id="L24">    <span class="tok-kw">const</span> s0 = self.s[<span class="tok-number">0</span>];</span>
<span class="line" id="L25">    <span class="tok-kw">var</span> s1 = self.s[<span class="tok-number">1</span>];</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> r = s0 +% s1;</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    s1 ^= s0;</span>
<span class="line" id="L29">    self.s[<span class="tok-number">0</span>] = math.rotl(<span class="tok-type">u64</span>, s0, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">55</span>)) ^ s1 ^ (s1 &lt;&lt; <span class="tok-number">14</span>);</span>
<span class="line" id="L30">    self.s[<span class="tok-number">1</span>] = math.rotl(<span class="tok-type">u64</span>, s1, <span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">36</span>));</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L33">}</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-comment">// Skip 2^64 places ahead in the sequence</span>
</span>
<span class="line" id="L36"><span class="tok-kw">fn</span> <span class="tok-fn">jump</span>(self: *Xoroshiro128) <span class="tok-type">void</span> {</span>
<span class="line" id="L37">    <span class="tok-kw">var</span> s0: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L38">    <span class="tok-kw">var</span> s1: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">const</span> table = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L41">        <span class="tok-number">0xbeac0467eba5facb</span>,</span>
<span class="line" id="L42">        <span class="tok-number">0xd86b048b86aa9922</span>,</span>
<span class="line" id="L43">    };</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (table) |entry| {</span>
<span class="line" id="L46">        <span class="tok-kw">var</span> b: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L47">        <span class="tok-kw">while</span> (b &lt; <span class="tok-number">64</span>) : (b += <span class="tok-number">1</span>) {</span>
<span class="line" id="L48">            <span class="tok-kw">if</span> ((entry &amp; (<span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>) &lt;&lt; <span class="tok-builtin">@intCast</span>(<span class="tok-type">u6</span>, b))) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L49">                s0 ^= self.s[<span class="tok-number">0</span>];</span>
<span class="line" id="L50">                s1 ^= self.s[<span class="tok-number">1</span>];</span>
<span class="line" id="L51">            }</span>
<span class="line" id="L52">            _ = self.next();</span>
<span class="line" id="L53">        }</span>
<span class="line" id="L54">    }</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">    self.s[<span class="tok-number">0</span>] = s0;</span>
<span class="line" id="L57">    self.s[<span class="tok-number">1</span>] = s1;</span>
<span class="line" id="L58">}</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seed</span>(self: *Xoroshiro128, init_s: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L61">    <span class="tok-comment">// Xoroshiro requires 128-bits of seed.</span>
</span>
<span class="line" id="L62">    <span class="tok-kw">var</span> gen = std.rand.SplitMix64.init(init_s);</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    self.s[<span class="tok-number">0</span>] = gen.next();</span>
<span class="line" id="L65">    self.s[<span class="tok-number">1</span>] = gen.next();</span>
<span class="line" id="L66">}</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(self: *Xoroshiro128, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L69">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L70">    <span class="tok-kw">const</span> aligned_len = buf.len - (buf.len &amp; <span class="tok-number">7</span>);</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-comment">// Complete 8 byte segments.</span>
</span>
<span class="line" id="L73">    <span class="tok-kw">while</span> (i &lt; aligned_len) : (i += <span class="tok-number">8</span>) {</span>
<span class="line" id="L74">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L75">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L76">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">8</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L77">            buf[i + j] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L78">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-comment">// Remaining. (cuts the stream)</span>
</span>
<span class="line" id="L83">    <span class="tok-kw">if</span> (i != buf.len) {</span>
<span class="line" id="L84">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L85">        <span class="tok-kw">while</span> (i &lt; buf.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L86">            buf[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L87">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89">    }</span>
<span class="line" id="L90">}</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-kw">test</span> <span class="tok-str">&quot;xoroshiro sequence&quot;</span> {</span>
<span class="line" id="L93">    <span class="tok-kw">var</span> r = Xoroshiro128.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L94">    r.s[<span class="tok-number">0</span>] = <span class="tok-number">0xaeecf86f7878dd75</span>;</span>
<span class="line" id="L95">    r.s[<span class="tok-number">1</span>] = <span class="tok-number">0x01cd153642e72622</span>;</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">const</span> seq1 = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L98">        <span class="tok-number">0xb0ba0da5bb600397</span>,</span>
<span class="line" id="L99">        <span class="tok-number">0x18a08afde614dccc</span>,</span>
<span class="line" id="L100">        <span class="tok-number">0xa2635b956a31b929</span>,</span>
<span class="line" id="L101">        <span class="tok-number">0xabe633c971efa045</span>,</span>
<span class="line" id="L102">        <span class="tok-number">0x9ac19f9706ca3cac</span>,</span>
<span class="line" id="L103">        <span class="tok-number">0xf62b426578c1e3fb</span>,</span>
<span class="line" id="L104">    };</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">    <span class="tok-kw">for</span> (seq1) |s| {</span>
<span class="line" id="L107">        <span class="tok-kw">try</span> std.testing.expect(s == r.next());</span>
<span class="line" id="L108">    }</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">    r.jump();</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">const</span> seq2 = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L113">        <span class="tok-number">0x95344a13556d3e22</span>,</span>
<span class="line" id="L114">        <span class="tok-number">0xb4fb32dafa4d00df</span>,</span>
<span class="line" id="L115">        <span class="tok-number">0xb2011d9ccdcfe2dd</span>,</span>
<span class="line" id="L116">        <span class="tok-number">0x05679a9b2119b908</span>,</span>
<span class="line" id="L117">        <span class="tok-number">0xa860a1da7c9cd8a0</span>,</span>
<span class="line" id="L118">        <span class="tok-number">0x658a96efe3f86550</span>,</span>
<span class="line" id="L119">    };</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">    <span class="tok-kw">for</span> (seq2) |s| {</span>
<span class="line" id="L122">        <span class="tok-kw">try</span> std.testing.expect(s == r.next());</span>
<span class="line" id="L123">    }</span>
<span class="line" id="L124">}</span>
<span class="line" id="L125"></span>
<span class="line" id="L126"><span class="tok-kw">test</span> <span class="tok-str">&quot;xoroshiro fill&quot;</span> {</span>
<span class="line" id="L127">    <span class="tok-kw">var</span> r = Xoroshiro128.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L128">    r.s[<span class="tok-number">0</span>] = <span class="tok-number">0xaeecf86f7878dd75</span>;</span>
<span class="line" id="L129">    r.s[<span class="tok-number">1</span>] = <span class="tok-number">0x01cd153642e72622</span>;</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">    <span class="tok-kw">const</span> seq = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L132">        <span class="tok-number">0xb0ba0da5bb600397</span>,</span>
<span class="line" id="L133">        <span class="tok-number">0x18a08afde614dccc</span>,</span>
<span class="line" id="L134">        <span class="tok-number">0xa2635b956a31b929</span>,</span>
<span class="line" id="L135">        <span class="tok-number">0xabe633c971efa045</span>,</span>
<span class="line" id="L136">        <span class="tok-number">0x9ac19f9706ca3cac</span>,</span>
<span class="line" id="L137">        <span class="tok-number">0xf62b426578c1e3fb</span>,</span>
<span class="line" id="L138">    };</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">for</span> (seq) |s| {</span>
<span class="line" id="L141">        <span class="tok-kw">var</span> buf0: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L142">        <span class="tok-kw">var</span> buf1: [<span class="tok-number">7</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L143">        std.mem.writeIntLittle(<span class="tok-type">u64</span>, &amp;buf0, s);</span>
<span class="line" id="L144">        r.fill(&amp;buf1);</span>
<span class="line" id="L145">        <span class="tok-kw">try</span> std.testing.expect(std.mem.eql(<span class="tok-type">u8</span>, buf0[<span class="tok-number">0</span>..<span class="tok-number">7</span>], buf1[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L146">    }</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
</code></pre></body>
</html>