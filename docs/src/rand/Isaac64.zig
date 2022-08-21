<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>rand/Isaac64.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! ISAAC64 - http://www.burtleburtle.net/bob/rand/isaacafa.html</span></span>
<span class="line" id="L2"><span class="tok-comment">//!</span></span>
<span class="line" id="L3"><span class="tok-comment">//! Follows the general idea of the implementation from here with a few shortcuts.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! https://doc.rust-lang.org/rand/src/rand/prng/isaac64.rs.html</span></span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Random = std.rand.Random;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> Isaac64 = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">r: [<span class="tok-number">256</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L12">m: [<span class="tok-number">256</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L13">a: <span class="tok-type">u64</span>,</span>
<span class="line" id="L14">b: <span class="tok-type">u64</span>,</span>
<span class="line" id="L15">c: <span class="tok-type">u64</span>,</span>
<span class="line" id="L16">i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_s: <span class="tok-type">u64</span>) Isaac64 {</span>
<span class="line" id="L19">    <span class="tok-kw">var</span> isaac = Isaac64{</span>
<span class="line" id="L20">        .r = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L21">        .m = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L22">        .a = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L23">        .b = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L24">        .c = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L25">        .i = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L26">    };</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-comment">// seed == 0 =&gt; same result as the unseeded reference implementation</span>
</span>
<span class="line" id="L29">    isaac.seed(init_s, <span class="tok-number">1</span>);</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> isaac;</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">random</span>(self: *Isaac64) Random {</span>
<span class="line" id="L34">    <span class="tok-kw">return</span> Random.init(self, fill);</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">fn</span> <span class="tok-fn">step</span>(self: *Isaac64, mix: <span class="tok-type">u64</span>, base: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> m1: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> m2: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L38">    <span class="tok-kw">const</span> x = self.m[base + m1];</span>
<span class="line" id="L39">    self.a = mix +% self.m[base + m2];</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-kw">const</span> y = self.a +% self.b +% self.m[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, (x &gt;&gt; <span class="tok-number">3</span>) % self.m.len)];</span>
<span class="line" id="L42">    self.m[base + m1] = y;</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    self.b = x +% self.m[<span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, (y &gt;&gt; <span class="tok-number">11</span>) % self.m.len)];</span>
<span class="line" id="L45">    self.r[self.r.len - <span class="tok-number">1</span> - base - m1] = self.b;</span>
<span class="line" id="L46">}</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-kw">fn</span> <span class="tok-fn">refill</span>(self: *Isaac64) <span class="tok-type">void</span> {</span>
<span class="line" id="L49">    <span class="tok-kw">const</span> midpoint = self.r.len / <span class="tok-number">2</span>;</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    self.c +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L52">    self.b +%= self.c;</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">    {</span>
<span class="line" id="L55">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L56">        <span class="tok-kw">while</span> (i &lt; midpoint) : (i += <span class="tok-number">4</span>) {</span>
<span class="line" id="L57">            self.step(~(self.a ^ (self.a &lt;&lt; <span class="tok-number">21</span>)), i + <span class="tok-number">0</span>, <span class="tok-number">0</span>, midpoint);</span>
<span class="line" id="L58">            self.step(self.a ^ (self.a &gt;&gt; <span class="tok-number">5</span>), i + <span class="tok-number">1</span>, <span class="tok-number">0</span>, midpoint);</span>
<span class="line" id="L59">            self.step(self.a ^ (self.a &lt;&lt; <span class="tok-number">12</span>), i + <span class="tok-number">2</span>, <span class="tok-number">0</span>, midpoint);</span>
<span class="line" id="L60">            self.step(self.a ^ (self.a &gt;&gt; <span class="tok-number">33</span>), i + <span class="tok-number">3</span>, <span class="tok-number">0</span>, midpoint);</span>
<span class="line" id="L61">        }</span>
<span class="line" id="L62">    }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    {</span>
<span class="line" id="L65">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L66">        <span class="tok-kw">while</span> (i &lt; midpoint) : (i += <span class="tok-number">4</span>) {</span>
<span class="line" id="L67">            self.step(~(self.a ^ (self.a &lt;&lt; <span class="tok-number">21</span>)), i + <span class="tok-number">0</span>, midpoint, <span class="tok-number">0</span>);</span>
<span class="line" id="L68">            self.step(self.a ^ (self.a &gt;&gt; <span class="tok-number">5</span>), i + <span class="tok-number">1</span>, midpoint, <span class="tok-number">0</span>);</span>
<span class="line" id="L69">            self.step(self.a ^ (self.a &lt;&lt; <span class="tok-number">12</span>), i + <span class="tok-number">2</span>, midpoint, <span class="tok-number">0</span>);</span>
<span class="line" id="L70">            self.step(self.a ^ (self.a &gt;&gt; <span class="tok-number">33</span>), i + <span class="tok-number">3</span>, midpoint, <span class="tok-number">0</span>);</span>
<span class="line" id="L71">        }</span>
<span class="line" id="L72">    }</span>
<span class="line" id="L73"></span>
<span class="line" id="L74">    self.i = <span class="tok-number">0</span>;</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Isaac64) <span class="tok-type">u64</span> {</span>
<span class="line" id="L78">    <span class="tok-kw">if</span> (self.i &gt;= self.r.len) {</span>
<span class="line" id="L79">        self.refill();</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-kw">const</span> value = self.r[self.i];</span>
<span class="line" id="L83">    self.i += <span class="tok-number">1</span>;</span>
<span class="line" id="L84">    <span class="tok-kw">return</span> value;</span>
<span class="line" id="L85">}</span>
<span class="line" id="L86"></span>
<span class="line" id="L87"><span class="tok-kw">fn</span> <span class="tok-fn">seed</span>(self: *Isaac64, init_s: <span class="tok-type">u64</span>, <span class="tok-kw">comptime</span> rounds: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L88">    <span class="tok-comment">// We ignore the multi-pass requirement since we don't currently expose full access to</span>
</span>
<span class="line" id="L89">    <span class="tok-comment">// seeding the self.m array completely.</span>
</span>
<span class="line" id="L90">    mem.set(<span class="tok-type">u64</span>, self.m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L91">    self.m[<span class="tok-number">0</span>] = init_s;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-comment">// prescrambled golden ratio constants</span>
</span>
<span class="line" id="L94">    <span class="tok-kw">var</span> a = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L95">        <span class="tok-number">0x647c4677a2884b7c</span>,</span>
<span class="line" id="L96">        <span class="tok-number">0xb9f8b322c73ac862</span>,</span>
<span class="line" id="L97">        <span class="tok-number">0x8c0ea5053d4712a0</span>,</span>
<span class="line" id="L98">        <span class="tok-number">0xb29b2e824a595524</span>,</span>
<span class="line" id="L99">        <span class="tok-number">0x82f053db8355e0ce</span>,</span>
<span class="line" id="L100">        <span class="tok-number">0x48fe4a0fa5a09315</span>,</span>
<span class="line" id="L101">        <span class="tok-number">0xae985bf2cbfc89ed</span>,</span>
<span class="line" id="L102">        <span class="tok-number">0x98f5704f6c44c0ab</span>,</span>
<span class="line" id="L103">    };</span>
<span class="line" id="L104"></span>
<span class="line" id="L105">    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L106">    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; rounds) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L107">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L108">        <span class="tok-kw">while</span> (j &lt; self.m.len) : (j += <span class="tok-number">8</span>) {</span>
<span class="line" id="L109">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> x1: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L110">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x1 &lt; <span class="tok-number">8</span>) : (x1 += <span class="tok-number">1</span>) {</span>
<span class="line" id="L111">                a[x1] +%= self.m[j + x1];</span>
<span class="line" id="L112">            }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">            a[<span class="tok-number">0</span>] -%= a[<span class="tok-number">4</span>];</span>
<span class="line" id="L115">            a[<span class="tok-number">5</span>] ^= a[<span class="tok-number">7</span>] &gt;&gt; <span class="tok-number">9</span>;</span>
<span class="line" id="L116">            a[<span class="tok-number">7</span>] +%= a[<span class="tok-number">0</span>];</span>
<span class="line" id="L117">            a[<span class="tok-number">1</span>] -%= a[<span class="tok-number">5</span>];</span>
<span class="line" id="L118">            a[<span class="tok-number">6</span>] ^= a[<span class="tok-number">0</span>] &lt;&lt; <span class="tok-number">9</span>;</span>
<span class="line" id="L119">            a[<span class="tok-number">0</span>] +%= a[<span class="tok-number">1</span>];</span>
<span class="line" id="L120">            a[<span class="tok-number">2</span>] -%= a[<span class="tok-number">6</span>];</span>
<span class="line" id="L121">            a[<span class="tok-number">7</span>] ^= a[<span class="tok-number">1</span>] &gt;&gt; <span class="tok-number">23</span>;</span>
<span class="line" id="L122">            a[<span class="tok-number">1</span>] +%= a[<span class="tok-number">2</span>];</span>
<span class="line" id="L123">            a[<span class="tok-number">3</span>] -%= a[<span class="tok-number">7</span>];</span>
<span class="line" id="L124">            a[<span class="tok-number">0</span>] ^= a[<span class="tok-number">2</span>] &lt;&lt; <span class="tok-number">15</span>;</span>
<span class="line" id="L125">            a[<span class="tok-number">2</span>] +%= a[<span class="tok-number">3</span>];</span>
<span class="line" id="L126">            a[<span class="tok-number">4</span>] -%= a[<span class="tok-number">0</span>];</span>
<span class="line" id="L127">            a[<span class="tok-number">1</span>] ^= a[<span class="tok-number">3</span>] &gt;&gt; <span class="tok-number">14</span>;</span>
<span class="line" id="L128">            a[<span class="tok-number">3</span>] +%= a[<span class="tok-number">4</span>];</span>
<span class="line" id="L129">            a[<span class="tok-number">5</span>] -%= a[<span class="tok-number">1</span>];</span>
<span class="line" id="L130">            a[<span class="tok-number">2</span>] ^= a[<span class="tok-number">4</span>] &lt;&lt; <span class="tok-number">20</span>;</span>
<span class="line" id="L131">            a[<span class="tok-number">4</span>] +%= a[<span class="tok-number">5</span>];</span>
<span class="line" id="L132">            a[<span class="tok-number">6</span>] -%= a[<span class="tok-number">2</span>];</span>
<span class="line" id="L133">            a[<span class="tok-number">3</span>] ^= a[<span class="tok-number">5</span>] &gt;&gt; <span class="tok-number">17</span>;</span>
<span class="line" id="L134">            a[<span class="tok-number">5</span>] +%= a[<span class="tok-number">6</span>];</span>
<span class="line" id="L135">            a[<span class="tok-number">7</span>] -%= a[<span class="tok-number">3</span>];</span>
<span class="line" id="L136">            a[<span class="tok-number">4</span>] ^= a[<span class="tok-number">6</span>] &lt;&lt; <span class="tok-number">14</span>;</span>
<span class="line" id="L137">            a[<span class="tok-number">6</span>] +%= a[<span class="tok-number">7</span>];</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> x2: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L140">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (x2 &lt; <span class="tok-number">8</span>) : (x2 += <span class="tok-number">1</span>) {</span>
<span class="line" id="L141">                self.m[j + x2] = a[x2];</span>
<span class="line" id="L142">            }</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144">    }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    mem.set(<span class="tok-type">u64</span>, self.r[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L147">    self.a = <span class="tok-number">0</span>;</span>
<span class="line" id="L148">    self.b = <span class="tok-number">0</span>;</span>
<span class="line" id="L149">    self.c = <span class="tok-number">0</span>;</span>
<span class="line" id="L150">    self.i = self.r.len; <span class="tok-comment">// trigger refill on first value</span>
</span>
<span class="line" id="L151">}</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(self: *Isaac64, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L154">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L155">    <span class="tok-kw">const</span> aligned_len = buf.len - (buf.len &amp; <span class="tok-number">7</span>);</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    <span class="tok-comment">// Fill complete 64-byte segments</span>
</span>
<span class="line" id="L158">    <span class="tok-kw">while</span> (i &lt; aligned_len) : (i += <span class="tok-number">8</span>) {</span>
<span class="line" id="L159">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L160">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L161">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; <span class="tok-number">8</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L162">            buf[i + j] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L163">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L164">        }</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-comment">// Fill trailing, ignoring excess (cut the stream).</span>
</span>
<span class="line" id="L168">    <span class="tok-kw">if</span> (i != buf.len) {</span>
<span class="line" id="L169">        <span class="tok-kw">var</span> n = self.next();</span>
<span class="line" id="L170">        <span class="tok-kw">while</span> (i &lt; buf.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L171">            buf[i] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, n);</span>
<span class="line" id="L172">            n &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L173">        }</span>
<span class="line" id="L174">    }</span>
<span class="line" id="L175">}</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">test</span> <span class="tok-str">&quot;isaac64 sequence&quot;</span> {</span>
<span class="line" id="L178">    <span class="tok-kw">var</span> r = Isaac64.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">    <span class="tok-comment">// from reference implementation</span>
</span>
<span class="line" id="L181">    <span class="tok-kw">const</span> seq = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L182">        <span class="tok-number">0xf67dfba498e4937c</span>,</span>
<span class="line" id="L183">        <span class="tok-number">0x84a5066a9204f380</span>,</span>
<span class="line" id="L184">        <span class="tok-number">0xfee34bd5f5514dbb</span>,</span>
<span class="line" id="L185">        <span class="tok-number">0x4d1664739b8f80d6</span>,</span>
<span class="line" id="L186">        <span class="tok-number">0x8607459ab52a14aa</span>,</span>
<span class="line" id="L187">        <span class="tok-number">0x0e78bc5a98529e49</span>,</span>
<span class="line" id="L188">        <span class="tok-number">0xfe5332822ad13777</span>,</span>
<span class="line" id="L189">        <span class="tok-number">0x556c27525e33d01a</span>,</span>
<span class="line" id="L190">        <span class="tok-number">0x08643ca615f3149f</span>,</span>
<span class="line" id="L191">        <span class="tok-number">0xd0771faf3cb04714</span>,</span>
<span class="line" id="L192">        <span class="tok-number">0x30e86f68a37b008d</span>,</span>
<span class="line" id="L193">        <span class="tok-number">0x3074ebc0488a3adf</span>,</span>
<span class="line" id="L194">        <span class="tok-number">0x270645ea7a2790bc</span>,</span>
<span class="line" id="L195">        <span class="tok-number">0x5601a0a8d3763c6a</span>,</span>
<span class="line" id="L196">        <span class="tok-number">0x2f83071f53f325dd</span>,</span>
<span class="line" id="L197">        <span class="tok-number">0xb9090f3d42d2d2ea</span>,</span>
<span class="line" id="L198">    };</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">    <span class="tok-kw">for</span> (seq) |s| {</span>
<span class="line" id="L201">        <span class="tok-kw">try</span> std.testing.expect(s == r.next());</span>
<span class="line" id="L202">    }</span>
<span class="line" id="L203">}</span>
<span class="line" id="L204"></span>
<span class="line" id="L205"><span class="tok-kw">test</span> <span class="tok-str">&quot;isaac64 fill&quot;</span> {</span>
<span class="line" id="L206">    <span class="tok-kw">var</span> r = Isaac64.init(<span class="tok-number">0</span>);</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">    <span class="tok-comment">// from reference implementation</span>
</span>
<span class="line" id="L209">    <span class="tok-kw">const</span> seq = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L210">        <span class="tok-number">0xf67dfba498e4937c</span>,</span>
<span class="line" id="L211">        <span class="tok-number">0x84a5066a9204f380</span>,</span>
<span class="line" id="L212">        <span class="tok-number">0xfee34bd5f5514dbb</span>,</span>
<span class="line" id="L213">        <span class="tok-number">0x4d1664739b8f80d6</span>,</span>
<span class="line" id="L214">        <span class="tok-number">0x8607459ab52a14aa</span>,</span>
<span class="line" id="L215">        <span class="tok-number">0x0e78bc5a98529e49</span>,</span>
<span class="line" id="L216">        <span class="tok-number">0xfe5332822ad13777</span>,</span>
<span class="line" id="L217">        <span class="tok-number">0x556c27525e33d01a</span>,</span>
<span class="line" id="L218">        <span class="tok-number">0x08643ca615f3149f</span>,</span>
<span class="line" id="L219">        <span class="tok-number">0xd0771faf3cb04714</span>,</span>
<span class="line" id="L220">        <span class="tok-number">0x30e86f68a37b008d</span>,</span>
<span class="line" id="L221">        <span class="tok-number">0x3074ebc0488a3adf</span>,</span>
<span class="line" id="L222">        <span class="tok-number">0x270645ea7a2790bc</span>,</span>
<span class="line" id="L223">        <span class="tok-number">0x5601a0a8d3763c6a</span>,</span>
<span class="line" id="L224">        <span class="tok-number">0x2f83071f53f325dd</span>,</span>
<span class="line" id="L225">        <span class="tok-number">0xb9090f3d42d2d2ea</span>,</span>
<span class="line" id="L226">    };</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    <span class="tok-kw">for</span> (seq) |s| {</span>
<span class="line" id="L229">        <span class="tok-kw">var</span> buf0: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L230">        <span class="tok-kw">var</span> buf1: [<span class="tok-number">7</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L231">        std.mem.writeIntLittle(<span class="tok-type">u64</span>, &amp;buf0, s);</span>
<span class="line" id="L232">        r.fill(&amp;buf1);</span>
<span class="line" id="L233">        <span class="tok-kw">try</span> std.testing.expect(std.mem.eql(<span class="tok-type">u8</span>, buf0[<span class="tok-number">0</span>..<span class="tok-number">7</span>], buf1[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L234">    }</span>
<span class="line" id="L235">}</span>
<span class="line" id="L236"></span>
</code></pre></body>
</html>