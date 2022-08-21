<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/blake3.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Translated from BLAKE3 reference implementation.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// Source: https://github.com/BLAKE3-team/BLAKE3</span>
</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> ChunkIterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">    slice: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L13">    chunk_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(slice: []<span class="tok-type">u8</span>, chunk_len: <span class="tok-type">usize</span>) ChunkIterator {</span>
<span class="line" id="L16">        <span class="tok-kw">return</span> ChunkIterator{</span>
<span class="line" id="L17">            .slice = slice,</span>
<span class="line" id="L18">            .chunk_len = chunk_len,</span>
<span class="line" id="L19">        };</span>
<span class="line" id="L20">    }</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *ChunkIterator) ?[]<span class="tok-type">u8</span> {</span>
<span class="line" id="L23">        <span class="tok-kw">const</span> next_chunk = self.slice[<span class="tok-number">0</span>..math.min(self.chunk_len, self.slice.len)];</span>
<span class="line" id="L24">        self.slice = self.slice[next_chunk.len..];</span>
<span class="line" id="L25">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (next_chunk.len &gt; <span class="tok-number">0</span>) next_chunk <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">const</span> OUT_LEN: <span class="tok-type">usize</span> = <span class="tok-number">32</span>;</span>
<span class="line" id="L30"><span class="tok-kw">const</span> KEY_LEN: <span class="tok-type">usize</span> = <span class="tok-number">32</span>;</span>
<span class="line" id="L31"><span class="tok-kw">const</span> BLOCK_LEN: <span class="tok-type">usize</span> = <span class="tok-number">64</span>;</span>
<span class="line" id="L32"><span class="tok-kw">const</span> CHUNK_LEN: <span class="tok-type">usize</span> = <span class="tok-number">1024</span>;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-kw">const</span> IV = [<span class="tok-number">8</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L35">    <span class="tok-number">0x6A09E667</span>, <span class="tok-number">0xBB67AE85</span>, <span class="tok-number">0x3C6EF372</span>, <span class="tok-number">0xA54FF53A</span>, <span class="tok-number">0x510E527F</span>, <span class="tok-number">0x9B05688C</span>, <span class="tok-number">0x1F83D9AB</span>, <span class="tok-number">0x5BE0CD19</span>,</span>
<span class="line" id="L36">};</span>
<span class="line" id="L37"></span>
<span class="line" id="L38"><span class="tok-kw">const</span> MSG_SCHEDULE = [<span class="tok-number">7</span>][<span class="tok-number">16</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L39">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">9</span>, <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span> },</span>
<span class="line" id="L40">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">3</span>, <span class="tok-number">10</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">13</span>, <span class="tok-number">1</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span> },</span>
<span class="line" id="L41">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">10</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">14</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span> },</span>
<span class="line" id="L42">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">10</span>, <span class="tok-number">7</span>, <span class="tok-number">12</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>, <span class="tok-number">15</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">11</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">8</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span> },</span>
<span class="line" id="L43">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">9</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, <span class="tok-number">8</span>, <span class="tok-number">7</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">4</span> },</span>
<span class="line" id="L44">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">9</span>, <span class="tok-number">14</span>, <span class="tok-number">11</span>, <span class="tok-number">5</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, <span class="tok-number">15</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">10</span>, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span> },</span>
<span class="line" id="L45">    [_]<span class="tok-type">u8</span>{ <span class="tok-number">11</span>, <span class="tok-number">15</span>, <span class="tok-number">5</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">9</span>, <span class="tok-number">8</span>, <span class="tok-number">6</span>, <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">2</span>, <span class="tok-number">12</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">13</span> },</span>
<span class="line" id="L46">};</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-comment">// These are the internal flags that we use to domain separate root/non-root,</span>
</span>
<span class="line" id="L49"><span class="tok-comment">// chunk/parent, and chunk beginning/middle/end. These get set at the high end</span>
</span>
<span class="line" id="L50"><span class="tok-comment">// of the block flags word in the compression function, so their values start</span>
</span>
<span class="line" id="L51"><span class="tok-comment">// high and go down.</span>
</span>
<span class="line" id="L52"><span class="tok-kw">const</span> CHUNK_START: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L53"><span class="tok-kw">const</span> CHUNK_END: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L54"><span class="tok-kw">const</span> PARENT: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L55"><span class="tok-kw">const</span> ROOT: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L56"><span class="tok-kw">const</span> KEYED_HASH: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L57"><span class="tok-kw">const</span> DERIVE_KEY_CONTEXT: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">5</span>;</span>
<span class="line" id="L58"><span class="tok-kw">const</span> DERIVE_KEY_MATERIAL: <span class="tok-type">u8</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">const</span> CompressVectorized = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L61">    <span class="tok-kw">const</span> Lane = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L62">    <span class="tok-kw">const</span> Rows = [<span class="tok-number">4</span>]Lane;</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">g</span>(<span class="tok-kw">comptime</span> even: <span class="tok-type">bool</span>, rows: *Rows, m: Lane) <span class="tok-type">void</span> {</span>
<span class="line" id="L65">        rows[<span class="tok-number">0</span>] +%= rows[<span class="tok-number">1</span>] +% m;</span>
<span class="line" id="L66">        rows[<span class="tok-number">3</span>] ^= rows[<span class="tok-number">0</span>];</span>
<span class="line" id="L67">        rows[<span class="tok-number">3</span>] = math.rotr(Lane, rows[<span class="tok-number">3</span>], <span class="tok-kw">if</span> (even) <span class="tok-number">8</span> <span class="tok-kw">else</span> <span class="tok-number">16</span>);</span>
<span class="line" id="L68">        rows[<span class="tok-number">2</span>] +%= rows[<span class="tok-number">3</span>];</span>
<span class="line" id="L69">        rows[<span class="tok-number">1</span>] ^= rows[<span class="tok-number">2</span>];</span>
<span class="line" id="L70">        rows[<span class="tok-number">1</span>] = math.rotr(Lane, rows[<span class="tok-number">1</span>], <span class="tok-kw">if</span> (even) <span class="tok-number">7</span> <span class="tok-kw">else</span> <span class="tok-number">12</span>);</span>
<span class="line" id="L71">    }</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">diagonalize</span>(rows: *Rows) <span class="tok-type">void</span> {</span>
<span class="line" id="L74">        rows[<span class="tok-number">0</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">0</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L75">        rows[<span class="tok-number">3</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">3</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L76">        rows[<span class="tok-number">2</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">2</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">undiagonalize</span>(rows: *Rows) <span class="tok-type">void</span> {</span>
<span class="line" id="L80">        rows[<span class="tok-number">0</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">0</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L81">        rows[<span class="tok-number">3</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">3</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L82">        rows[<span class="tok-number">2</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, rows[<span class="tok-number">2</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L83">    }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">    <span class="tok-kw">fn</span> <span class="tok-fn">compress</span>(</span>
<span class="line" id="L86">        chaining_value: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L87">        block_words: [<span class="tok-number">16</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L88">        block_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L89">        counter: <span class="tok-type">u64</span>,</span>
<span class="line" id="L90">        flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L91">    ) [<span class="tok-number">16</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L92">        <span class="tok-kw">const</span> md = Lane{ <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter), <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter &gt;&gt; <span class="tok-number">32</span>), block_len, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, flags) };</span>
<span class="line" id="L93">        <span class="tok-kw">var</span> rows = Rows{ chaining_value[<span class="tok-number">0</span>..<span class="tok-number">4</span>].*, chaining_value[<span class="tok-number">4</span>..<span class="tok-number">8</span>].*, IV[<span class="tok-number">0</span>..<span class="tok-number">4</span>].*, md };</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-kw">var</span> m = Rows{ block_words[<span class="tok-number">0</span>..<span class="tok-number">4</span>].*, block_words[<span class="tok-number">4</span>..<span class="tok-number">8</span>].*, block_words[<span class="tok-number">8</span>..<span class="tok-number">12</span>].*, block_words[<span class="tok-number">12</span>..<span class="tok-number">16</span>].* };</span>
<span class="line" id="L96">        <span class="tok-kw">var</span> t0 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">0</span>], m[<span class="tok-number">1</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">0</span>), (-<span class="tok-number">1</span> - <span class="tok-number">2</span>) });</span>
<span class="line" id="L97">        g(<span class="tok-null">false</span>, &amp;rows, t0);</span>
<span class="line" id="L98">        <span class="tok-kw">var</span> t1 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">0</span>], m[<span class="tok-number">1</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">3</span>, (-<span class="tok-number">1</span> - <span class="tok-number">1</span>), (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L99">        g(<span class="tok-null">true</span>, &amp;rows, t1);</span>
<span class="line" id="L100">        diagonalize(&amp;rows);</span>
<span class="line" id="L101">        <span class="tok-kw">var</span> t2 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">2</span>], m[<span class="tok-number">3</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">0</span>), (-<span class="tok-number">1</span> - <span class="tok-number">2</span>) });</span>
<span class="line" id="L102">        t2 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, t2, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L103">        g(<span class="tok-null">false</span>, &amp;rows, t2);</span>
<span class="line" id="L104">        <span class="tok-kw">var</span> t3 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">2</span>], m[<span class="tok-number">3</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">3</span>, (-<span class="tok-number">1</span> - <span class="tok-number">1</span>), (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L105">        t3 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, t3, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L106">        g(<span class="tok-null">true</span>, &amp;rows, t3);</span>
<span class="line" id="L107">        undiagonalize(&amp;rows);</span>
<span class="line" id="L108">        m = Rows{ t0, t1, t2, t3 };</span>
<span class="line" id="L109"></span>
<span class="line" id="L110">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L111">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">6</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L112">            t0 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">0</span>], m[<span class="tok-number">1</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">1</span>, (-<span class="tok-number">1</span> - <span class="tok-number">1</span>), (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L113">            t0 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, t0, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L114">            g(<span class="tok-null">false</span>, &amp;rows, t0);</span>
<span class="line" id="L115">            t1 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">2</span>], m[<span class="tok-number">3</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">3</span>), (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L116">            <span class="tok-kw">var</span> tt = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">0</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L117">            t1 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, tt, t1, [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, (-<span class="tok-number">1</span> - <span class="tok-number">1</span>), <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L118">            g(<span class="tok-null">true</span>, &amp;rows, t1);</span>
<span class="line" id="L119">            diagonalize(&amp;rows);</span>
<span class="line" id="L120">            t2 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">3</span>], m[<span class="tok-number">1</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, (-<span class="tok-number">1</span> - <span class="tok-number">0</span>), (-<span class="tok-number">1</span> - <span class="tok-number">1</span>) });</span>
<span class="line" id="L121">            tt = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, t2, m[<span class="tok-number">2</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L122">            t2 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, tt, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L123">            g(<span class="tok-null">false</span>, &amp;rows, t2);</span>
<span class="line" id="L124">            t3 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">1</span>], m[<span class="tok-number">3</span>], [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, (-<span class="tok-number">1</span> - <span class="tok-number">2</span>), <span class="tok-number">3</span>, (-<span class="tok-number">1</span> - <span class="tok-number">3</span>) });</span>
<span class="line" id="L125">            tt = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, m[<span class="tok-number">2</span>], t3, [_]<span class="tok-type">i32</span>{ <span class="tok-number">0</span>, (-<span class="tok-number">1</span> - <span class="tok-number">0</span>), <span class="tok-number">1</span>, (-<span class="tok-number">1</span> - <span class="tok-number">1</span>) });</span>
<span class="line" id="L126">            t3 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, tt, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L127">            g(<span class="tok-null">true</span>, &amp;rows, t3);</span>
<span class="line" id="L128">            undiagonalize(&amp;rows);</span>
<span class="line" id="L129">            m = Rows{ t0, t1, t2, t3 };</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        rows[<span class="tok-number">0</span>] ^= rows[<span class="tok-number">2</span>];</span>
<span class="line" id="L133">        rows[<span class="tok-number">1</span>] ^= rows[<span class="tok-number">3</span>];</span>
<span class="line" id="L134">        rows[<span class="tok-number">2</span>] ^= <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>){ chaining_value[<span class="tok-number">0</span>], chaining_value[<span class="tok-number">1</span>], chaining_value[<span class="tok-number">2</span>], chaining_value[<span class="tok-number">3</span>] };</span>
<span class="line" id="L135">        rows[<span class="tok-number">3</span>] ^= <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>){ chaining_value[<span class="tok-number">4</span>], chaining_value[<span class="tok-number">5</span>], chaining_value[<span class="tok-number">6</span>], chaining_value[<span class="tok-number">7</span>] };</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>([<span class="tok-number">16</span>]<span class="tok-type">u32</span>, rows);</span>
<span class="line" id="L138">    }</span>
<span class="line" id="L139">};</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">const</span> CompressGeneric = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L142">    <span class="tok-kw">fn</span> <span class="tok-fn">g</span>(state: *[<span class="tok-number">16</span>]<span class="tok-type">u32</span>, <span class="tok-kw">comptime</span> a: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> b: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> c: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> d: <span class="tok-type">usize</span>, mx: <span class="tok-type">u32</span>, my: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L143">        state[a] +%= state[b] +% mx;</span>
<span class="line" id="L144">        state[d] = math.rotr(<span class="tok-type">u32</span>, state[d] ^ state[a], <span class="tok-number">16</span>);</span>
<span class="line" id="L145">        state[c] +%= state[d];</span>
<span class="line" id="L146">        state[b] = math.rotr(<span class="tok-type">u32</span>, state[b] ^ state[c], <span class="tok-number">12</span>);</span>
<span class="line" id="L147">        state[a] +%= state[b] +% my;</span>
<span class="line" id="L148">        state[d] = math.rotr(<span class="tok-type">u32</span>, state[d] ^ state[a], <span class="tok-number">8</span>);</span>
<span class="line" id="L149">        state[c] +%= state[d];</span>
<span class="line" id="L150">        state[b] = math.rotr(<span class="tok-type">u32</span>, state[b] ^ state[c], <span class="tok-number">7</span>);</span>
<span class="line" id="L151">    }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(state: *[<span class="tok-number">16</span>]<span class="tok-type">u32</span>, msg: [<span class="tok-number">16</span>]<span class="tok-type">u32</span>, schedule: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L154">        <span class="tok-comment">// Mix the columns.</span>
</span>
<span class="line" id="L155">        g(state, <span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>, msg[schedule[<span class="tok-number">0</span>]], msg[schedule[<span class="tok-number">1</span>]]);</span>
<span class="line" id="L156">        g(state, <span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>, msg[schedule[<span class="tok-number">2</span>]], msg[schedule[<span class="tok-number">3</span>]]);</span>
<span class="line" id="L157">        g(state, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>, msg[schedule[<span class="tok-number">4</span>]], msg[schedule[<span class="tok-number">5</span>]]);</span>
<span class="line" id="L158">        g(state, <span class="tok-number">3</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>, msg[schedule[<span class="tok-number">6</span>]], msg[schedule[<span class="tok-number">7</span>]]);</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">        <span class="tok-comment">// Mix the diagonals.</span>
</span>
<span class="line" id="L161">        g(state, <span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>, msg[schedule[<span class="tok-number">8</span>]], msg[schedule[<span class="tok-number">9</span>]]);</span>
<span class="line" id="L162">        g(state, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, msg[schedule[<span class="tok-number">10</span>]], msg[schedule[<span class="tok-number">11</span>]]);</span>
<span class="line" id="L163">        g(state, <span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">13</span>, msg[schedule[<span class="tok-number">12</span>]], msg[schedule[<span class="tok-number">13</span>]]);</span>
<span class="line" id="L164">        g(state, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>, msg[schedule[<span class="tok-number">14</span>]], msg[schedule[<span class="tok-number">15</span>]]);</span>
<span class="line" id="L165">    }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-kw">fn</span> <span class="tok-fn">compress</span>(</span>
<span class="line" id="L168">        chaining_value: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L169">        block_words: [<span class="tok-number">16</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L170">        block_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L171">        counter: <span class="tok-type">u64</span>,</span>
<span class="line" id="L172">        flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L173">    ) [<span class="tok-number">16</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L174">        <span class="tok-kw">var</span> state = [<span class="tok-number">16</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L175">            chaining_value[<span class="tok-number">0</span>],</span>
<span class="line" id="L176">            chaining_value[<span class="tok-number">1</span>],</span>
<span class="line" id="L177">            chaining_value[<span class="tok-number">2</span>],</span>
<span class="line" id="L178">            chaining_value[<span class="tok-number">3</span>],</span>
<span class="line" id="L179">            chaining_value[<span class="tok-number">4</span>],</span>
<span class="line" id="L180">            chaining_value[<span class="tok-number">5</span>],</span>
<span class="line" id="L181">            chaining_value[<span class="tok-number">6</span>],</span>
<span class="line" id="L182">            chaining_value[<span class="tok-number">7</span>],</span>
<span class="line" id="L183">            IV[<span class="tok-number">0</span>],</span>
<span class="line" id="L184">            IV[<span class="tok-number">1</span>],</span>
<span class="line" id="L185">            IV[<span class="tok-number">2</span>],</span>
<span class="line" id="L186">            IV[<span class="tok-number">3</span>],</span>
<span class="line" id="L187">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter),</span>
<span class="line" id="L188">            <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter &gt;&gt; <span class="tok-number">32</span>),</span>
<span class="line" id="L189">            block_len,</span>
<span class="line" id="L190">            flags,</span>
<span class="line" id="L191">        };</span>
<span class="line" id="L192">        <span class="tok-kw">for</span> (MSG_SCHEDULE) |schedule| {</span>
<span class="line" id="L193">            round(&amp;state, block_words, schedule);</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195">        <span class="tok-kw">for</span> (chaining_value) |_, i| {</span>
<span class="line" id="L196">            state[i] ^= state[i + <span class="tok-number">8</span>];</span>
<span class="line" id="L197">            state[i + <span class="tok-number">8</span>] ^= chaining_value[i];</span>
<span class="line" id="L198">        }</span>
<span class="line" id="L199">        <span class="tok-kw">return</span> state;</span>
<span class="line" id="L200">    }</span>
<span class="line" id="L201">};</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">const</span> compress = <span class="tok-kw">if</span> (builtin.cpu.arch == .x86_64) CompressVectorized.compress <span class="tok-kw">else</span> CompressGeneric.compress;</span>
<span class="line" id="L204"></span>
<span class="line" id="L205"><span class="tok-kw">fn</span> <span class="tok-fn">first8Words</span>(words: [<span class="tok-number">16</span>]<span class="tok-type">u32</span>) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L206">    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, &amp;words).*;</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">fn</span> <span class="tok-fn">wordsFromLittleEndianBytes</span>(<span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>, bytes: [count * <span class="tok-number">4</span>]<span class="tok-type">u8</span>) [count]<span class="tok-type">u32</span> {</span>
<span class="line" id="L210">    <span class="tok-kw">var</span> words: [count]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L211">    <span class="tok-kw">for</span> (words) |*word, i| {</span>
<span class="line" id="L212">        word.* = mem.readIntSliceLittle(<span class="tok-type">u32</span>, bytes[<span class="tok-number">4</span> * i ..]);</span>
<span class="line" id="L213">    }</span>
<span class="line" id="L214">    <span class="tok-kw">return</span> words;</span>
<span class="line" id="L215">}</span>
<span class="line" id="L216"></span>
<span class="line" id="L217"><span class="tok-comment">// Each chunk or parent node can produce either an 8-word chaining value or, by</span>
</span>
<span class="line" id="L218"><span class="tok-comment">// setting the ROOT flag, any number of final output bytes. The Output struct</span>
</span>
<span class="line" id="L219"><span class="tok-comment">// captures the state just prior to choosing between those two possibilities.</span>
</span>
<span class="line" id="L220"><span class="tok-kw">const</span> Output = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L221">    input_chaining_value: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L222">    block_words: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L223">    block_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L224">    counter: <span class="tok-type">u64</span>,</span>
<span class="line" id="L225">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">fn</span> <span class="tok-fn">chainingValue</span>(self: *<span class="tok-kw">const</span> Output) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L228">        <span class="tok-kw">return</span> first8Words(compress(</span>
<span class="line" id="L229">            self.input_chaining_value,</span>
<span class="line" id="L230">            self.block_words,</span>
<span class="line" id="L231">            self.block_len,</span>
<span class="line" id="L232">            self.counter,</span>
<span class="line" id="L233">            self.flags,</span>
<span class="line" id="L234">        ));</span>
<span class="line" id="L235">    }</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">    <span class="tok-kw">fn</span> <span class="tok-fn">rootOutputBytes</span>(self: *<span class="tok-kw">const</span> Output, output: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L238">        <span class="tok-kw">var</span> out_block_it = ChunkIterator.init(output, <span class="tok-number">2</span> * OUT_LEN);</span>
<span class="line" id="L239">        <span class="tok-kw">var</span> output_block_counter: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L240">        <span class="tok-kw">while</span> (out_block_it.next()) |out_block| {</span>
<span class="line" id="L241">            <span class="tok-kw">var</span> words = compress(</span>
<span class="line" id="L242">                self.input_chaining_value,</span>
<span class="line" id="L243">                self.block_words,</span>
<span class="line" id="L244">                self.block_len,</span>
<span class="line" id="L245">                output_block_counter,</span>
<span class="line" id="L246">                self.flags | ROOT,</span>
<span class="line" id="L247">            );</span>
<span class="line" id="L248">            <span class="tok-kw">var</span> out_word_it = ChunkIterator.init(out_block, <span class="tok-number">4</span>);</span>
<span class="line" id="L249">            <span class="tok-kw">var</span> word_counter: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L250">            <span class="tok-kw">while</span> (out_word_it.next()) |out_word| {</span>
<span class="line" id="L251">                <span class="tok-kw">var</span> word_bytes: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L252">                mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;word_bytes, words[word_counter]);</span>
<span class="line" id="L253">                mem.copy(<span class="tok-type">u8</span>, out_word, word_bytes[<span class="tok-number">0</span>..out_word.len]);</span>
<span class="line" id="L254">                word_counter += <span class="tok-number">1</span>;</span>
<span class="line" id="L255">            }</span>
<span class="line" id="L256">            output_block_counter += <span class="tok-number">1</span>;</span>
<span class="line" id="L257">        }</span>
<span class="line" id="L258">    }</span>
<span class="line" id="L259">};</span>
<span class="line" id="L260"></span>
<span class="line" id="L261"><span class="tok-kw">const</span> ChunkState = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L262">    chaining_value: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L263">    chunk_counter: <span class="tok-type">u64</span>,</span>
<span class="line" id="L264">    block: [BLOCK_LEN]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** BLOCK_LEN,</span>
<span class="line" id="L265">    block_len: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L266">    blocks_compressed: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L267">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, chunk_counter: <span class="tok-type">u64</span>, flags: <span class="tok-type">u8</span>) ChunkState {</span>
<span class="line" id="L270">        <span class="tok-kw">return</span> ChunkState{</span>
<span class="line" id="L271">            .chaining_value = key,</span>
<span class="line" id="L272">            .chunk_counter = chunk_counter,</span>
<span class="line" id="L273">            .flags = flags,</span>
<span class="line" id="L274">        };</span>
<span class="line" id="L275">    }</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">    <span class="tok-kw">fn</span> <span class="tok-fn">len</span>(self: *<span class="tok-kw">const</span> ChunkState) <span class="tok-type">usize</span> {</span>
<span class="line" id="L278">        <span class="tok-kw">return</span> BLOCK_LEN * <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, self.blocks_compressed) + <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, self.block_len);</span>
<span class="line" id="L279">    }</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">    <span class="tok-kw">fn</span> <span class="tok-fn">fillBlockBuf</span>(self: *ChunkState, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L282">        <span class="tok-kw">const</span> want = BLOCK_LEN - self.block_len;</span>
<span class="line" id="L283">        <span class="tok-kw">const</span> take = math.min(want, input.len);</span>
<span class="line" id="L284">        mem.copy(<span class="tok-type">u8</span>, self.block[self.block_len..][<span class="tok-number">0</span>..take], input[<span class="tok-number">0</span>..take]);</span>
<span class="line" id="L285">        self.block_len += <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, take);</span>
<span class="line" id="L286">        <span class="tok-kw">return</span> input[take..];</span>
<span class="line" id="L287">    }</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">    <span class="tok-kw">fn</span> <span class="tok-fn">startFlag</span>(self: *<span class="tok-kw">const</span> ChunkState) <span class="tok-type">u8</span> {</span>
<span class="line" id="L290">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.blocks_compressed == <span class="tok-number">0</span>) CHUNK_START <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L291">    }</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *ChunkState, input_slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L294">        <span class="tok-kw">var</span> input = input_slice;</span>
<span class="line" id="L295">        <span class="tok-kw">while</span> (input.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L296">            <span class="tok-comment">// If the block buffer is full, compress it and clear it. More</span>
</span>
<span class="line" id="L297">            <span class="tok-comment">// input is coming, so this compression is not CHUNK_END.</span>
</span>
<span class="line" id="L298">            <span class="tok-kw">if</span> (self.block_len == BLOCK_LEN) {</span>
<span class="line" id="L299">                <span class="tok-kw">const</span> block_words = wordsFromLittleEndianBytes(<span class="tok-number">16</span>, self.block);</span>
<span class="line" id="L300">                self.chaining_value = first8Words(compress(</span>
<span class="line" id="L301">                    self.chaining_value,</span>
<span class="line" id="L302">                    block_words,</span>
<span class="line" id="L303">                    BLOCK_LEN,</span>
<span class="line" id="L304">                    self.chunk_counter,</span>
<span class="line" id="L305">                    self.flags | self.startFlag(),</span>
<span class="line" id="L306">                ));</span>
<span class="line" id="L307">                self.blocks_compressed += <span class="tok-number">1</span>;</span>
<span class="line" id="L308">                self.block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** BLOCK_LEN;</span>
<span class="line" id="L309">                self.block_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L310">            }</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">            <span class="tok-comment">// Copy input bytes into the block buffer.</span>
</span>
<span class="line" id="L313">            input = self.fillBlockBuf(input);</span>
<span class="line" id="L314">        }</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-kw">fn</span> <span class="tok-fn">output</span>(self: *<span class="tok-kw">const</span> ChunkState) Output {</span>
<span class="line" id="L318">        <span class="tok-kw">const</span> block_words = wordsFromLittleEndianBytes(<span class="tok-number">16</span>, self.block);</span>
<span class="line" id="L319">        <span class="tok-kw">return</span> Output{</span>
<span class="line" id="L320">            .input_chaining_value = self.chaining_value,</span>
<span class="line" id="L321">            .block_words = block_words,</span>
<span class="line" id="L322">            .block_len = self.block_len,</span>
<span class="line" id="L323">            .counter = self.chunk_counter,</span>
<span class="line" id="L324">            .flags = self.flags | self.startFlag() | CHUNK_END,</span>
<span class="line" id="L325">        };</span>
<span class="line" id="L326">    }</span>
<span class="line" id="L327">};</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-kw">fn</span> <span class="tok-fn">parentOutput</span>(</span>
<span class="line" id="L330">    left_child_cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L331">    right_child_cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L332">    key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L333">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L334">) Output {</span>
<span class="line" id="L335">    <span class="tok-kw">var</span> block_words: [<span class="tok-number">16</span>]<span class="tok-type">u32</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L336">    mem.copy(<span class="tok-type">u32</span>, block_words[<span class="tok-number">0</span>..<span class="tok-number">8</span>], left_child_cv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L337">    mem.copy(<span class="tok-type">u32</span>, block_words[<span class="tok-number">8</span>..], right_child_cv[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L338">    <span class="tok-kw">return</span> Output{</span>
<span class="line" id="L339">        .input_chaining_value = key,</span>
<span class="line" id="L340">        .block_words = block_words,</span>
<span class="line" id="L341">        .block_len = BLOCK_LEN, <span class="tok-comment">// Always BLOCK_LEN (64) for parent nodes.</span>
</span>
<span class="line" id="L342">        .counter = <span class="tok-number">0</span>, <span class="tok-comment">// Always 0 for parent nodes.</span>
</span>
<span class="line" id="L343">        .flags = PARENT | flags,</span>
<span class="line" id="L344">    };</span>
<span class="line" id="L345">}</span>
<span class="line" id="L346"></span>
<span class="line" id="L347"><span class="tok-kw">fn</span> <span class="tok-fn">parentCv</span>(</span>
<span class="line" id="L348">    left_child_cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L349">    right_child_cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L350">    key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L351">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L352">) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L353">    <span class="tok-kw">return</span> parentOutput(left_child_cv, right_child_cv, key, flags).chainingValue();</span>
<span class="line" id="L354">}</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-comment">/// An incremental hasher that can accept any number of writes.</span></span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Blake3 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L358">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> { key: ?[digest_length]<span class="tok-type">u8</span> = <span class="tok-null">null</span> };</span>
<span class="line" id="L359">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KdfOptions = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    chunk_state: ChunkState,</span>
<span class="line" id="L362">    key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L363">    cv_stack: [<span class="tok-number">54</span>][<span class="tok-number">8</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>, <span class="tok-comment">// Space for 54 subtree chaining values:</span>
</span>
<span class="line" id="L364">    cv_stack_len: <span class="tok-type">u8</span> = <span class="tok-number">0</span>, <span class="tok-comment">// 2^54 * CHUNK_LEN = 2^64</span>
</span>
<span class="line" id="L365">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L366"></span>
<span class="line" id="L367">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = BLOCK_LEN;</span>
<span class="line" id="L368">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = OUT_LEN;</span>
<span class="line" id="L369">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = KEY_LEN;</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">    <span class="tok-kw">fn</span> <span class="tok-fn">init_internal</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, flags: <span class="tok-type">u8</span>) Blake3 {</span>
<span class="line" id="L372">        <span class="tok-kw">return</span> Blake3{</span>
<span class="line" id="L373">            .chunk_state = ChunkState.init(key, <span class="tok-number">0</span>, flags),</span>
<span class="line" id="L374">            .key = key,</span>
<span class="line" id="L375">            .flags = flags,</span>
<span class="line" id="L376">        };</span>
<span class="line" id="L377">    }</span>
<span class="line" id="L378"></span>
<span class="line" id="L379">    <span class="tok-comment">/// Construct a new `Blake3` for the hash function, with an optional key</span></span>
<span class="line" id="L380">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Blake3 {</span>
<span class="line" id="L381">        <span class="tok-kw">if</span> (options.key) |key| {</span>
<span class="line" id="L382">            <span class="tok-kw">const</span> key_words = wordsFromLittleEndianBytes(<span class="tok-number">8</span>, key);</span>
<span class="line" id="L383">            <span class="tok-kw">return</span> Blake3.init_internal(key_words, KEYED_HASH);</span>
<span class="line" id="L384">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L385">            <span class="tok-kw">return</span> Blake3.init_internal(IV, <span class="tok-number">0</span>);</span>
<span class="line" id="L386">        }</span>
<span class="line" id="L387">    }</span>
<span class="line" id="L388"></span>
<span class="line" id="L389">    <span class="tok-comment">/// Construct a new `Blake3` for the key derivation function. The context</span></span>
<span class="line" id="L390">    <span class="tok-comment">/// string should be hardcoded, globally unique, and application-specific.</span></span>
<span class="line" id="L391">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initKdf</span>(context: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: KdfOptions) Blake3 {</span>
<span class="line" id="L392">        _ = options;</span>
<span class="line" id="L393">        <span class="tok-kw">var</span> context_hasher = Blake3.init_internal(IV, DERIVE_KEY_CONTEXT);</span>
<span class="line" id="L394">        context_hasher.update(context);</span>
<span class="line" id="L395">        <span class="tok-kw">var</span> context_key: [KEY_LEN]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L396">        context_hasher.final(context_key[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L397">        <span class="tok-kw">const</span> context_key_words = wordsFromLittleEndianBytes(<span class="tok-number">8</span>, context_key);</span>
<span class="line" id="L398">        <span class="tok-kw">return</span> Blake3.init_internal(context_key_words, DERIVE_KEY_MATERIAL);</span>
<span class="line" id="L399">    }</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: []<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L402">        <span class="tok-kw">var</span> d = Blake3.init(options);</span>
<span class="line" id="L403">        d.update(b);</span>
<span class="line" id="L404">        d.final(out);</span>
<span class="line" id="L405">    }</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">fn</span> <span class="tok-fn">pushCv</span>(self: *Blake3, cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L408">        self.cv_stack[self.cv_stack_len] = cv;</span>
<span class="line" id="L409">        self.cv_stack_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">fn</span> <span class="tok-fn">popCv</span>(self: *Blake3) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L413">        self.cv_stack_len -= <span class="tok-number">1</span>;</span>
<span class="line" id="L414">        <span class="tok-kw">return</span> self.cv_stack[self.cv_stack_len];</span>
<span class="line" id="L415">    }</span>
<span class="line" id="L416"></span>
<span class="line" id="L417">    <span class="tok-comment">// Section 5.1.2 of the BLAKE3 spec explains this algorithm in more detail.</span>
</span>
<span class="line" id="L418">    <span class="tok-kw">fn</span> <span class="tok-fn">addChunkChainingValue</span>(self: *Blake3, first_cv: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, total_chunks: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L419">        <span class="tok-comment">// This chunk might complete some subtrees. For each completed subtree,</span>
</span>
<span class="line" id="L420">        <span class="tok-comment">// its left child will be the current top entry in the CV stack, and</span>
</span>
<span class="line" id="L421">        <span class="tok-comment">// its right child will be the current value of `new_cv`. Pop each left</span>
</span>
<span class="line" id="L422">        <span class="tok-comment">// child off the stack, merge it with `new_cv`, and overwrite `new_cv`</span>
</span>
<span class="line" id="L423">        <span class="tok-comment">// with the result. After all these merges, push the final value of</span>
</span>
<span class="line" id="L424">        <span class="tok-comment">// `new_cv` onto the stack. The number of completed subtrees is given</span>
</span>
<span class="line" id="L425">        <span class="tok-comment">// by the number of trailing 0-bits in the new total number of chunks.</span>
</span>
<span class="line" id="L426">        <span class="tok-kw">var</span> new_cv = first_cv;</span>
<span class="line" id="L427">        <span class="tok-kw">var</span> chunk_counter = total_chunks;</span>
<span class="line" id="L428">        <span class="tok-kw">while</span> (chunk_counter &amp; <span class="tok-number">1</span> == <span class="tok-number">0</span>) {</span>
<span class="line" id="L429">            new_cv = parentCv(self.popCv(), new_cv, self.key, self.flags);</span>
<span class="line" id="L430">            chunk_counter &gt;&gt;= <span class="tok-number">1</span>;</span>
<span class="line" id="L431">        }</span>
<span class="line" id="L432">        self.pushCv(new_cv);</span>
<span class="line" id="L433">    }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">    <span class="tok-comment">/// Add input to the hash state. This can be called any number of times.</span></span>
<span class="line" id="L436">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Blake3, input_slice: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L437">        <span class="tok-kw">var</span> input = input_slice;</span>
<span class="line" id="L438">        <span class="tok-kw">while</span> (input.len &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L439">            <span class="tok-comment">// If the current chunk is complete, finalize it and reset the</span>
</span>
<span class="line" id="L440">            <span class="tok-comment">// chunk state. More input is coming, so this chunk is not ROOT.</span>
</span>
<span class="line" id="L441">            <span class="tok-kw">if</span> (self.chunk_state.len() == CHUNK_LEN) {</span>
<span class="line" id="L442">                <span class="tok-kw">const</span> chunk_cv = self.chunk_state.output().chainingValue();</span>
<span class="line" id="L443">                <span class="tok-kw">const</span> total_chunks = self.chunk_state.chunk_counter + <span class="tok-number">1</span>;</span>
<span class="line" id="L444">                self.addChunkChainingValue(chunk_cv, total_chunks);</span>
<span class="line" id="L445">                self.chunk_state = ChunkState.init(self.key, total_chunks, self.flags);</span>
<span class="line" id="L446">            }</span>
<span class="line" id="L447"></span>
<span class="line" id="L448">            <span class="tok-comment">// Compress input bytes into the current chunk state.</span>
</span>
<span class="line" id="L449">            <span class="tok-kw">const</span> want = CHUNK_LEN - self.chunk_state.len();</span>
<span class="line" id="L450">            <span class="tok-kw">const</span> take = math.min(want, input.len);</span>
<span class="line" id="L451">            self.chunk_state.update(input[<span class="tok-number">0</span>..take]);</span>
<span class="line" id="L452">            input = input[take..];</span>
<span class="line" id="L453">        }</span>
<span class="line" id="L454">    }</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-comment">/// Finalize the hash and write any number of output bytes.</span></span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *<span class="tok-kw">const</span> Blake3, out_slice: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L458">        <span class="tok-comment">// Starting with the Output from the current chunk, compute all the</span>
</span>
<span class="line" id="L459">        <span class="tok-comment">// parent chaining values along the right edge of the tree, until we</span>
</span>
<span class="line" id="L460">        <span class="tok-comment">// have the root Output.</span>
</span>
<span class="line" id="L461">        <span class="tok-kw">var</span> output = self.chunk_state.output();</span>
<span class="line" id="L462">        <span class="tok-kw">var</span> parent_nodes_remaining: <span class="tok-type">usize</span> = self.cv_stack_len;</span>
<span class="line" id="L463">        <span class="tok-kw">while</span> (parent_nodes_remaining &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L464">            parent_nodes_remaining -= <span class="tok-number">1</span>;</span>
<span class="line" id="L465">            output = parentOutput(</span>
<span class="line" id="L466">                self.cv_stack[parent_nodes_remaining],</span>
<span class="line" id="L467">                output.chainingValue(),</span>
<span class="line" id="L468">                self.key,</span>
<span class="line" id="L469">                self.flags,</span>
<span class="line" id="L470">            );</span>
<span class="line" id="L471">        }</span>
<span class="line" id="L472">        output.rootOutputBytes(out_slice);</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L476">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Blake3, Error, write);</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">    <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Blake3, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L479">        self.update(bytes);</span>
<span class="line" id="L480">        <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L481">    }</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Blake3) Writer {</span>
<span class="line" id="L484">        <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L485">    }</span>
<span class="line" id="L486">};</span>
<span class="line" id="L487"></span>
<span class="line" id="L488"><span class="tok-comment">// Use named type declarations to workaround crash with anonymous structs (issue #4373).</span>
</span>
<span class="line" id="L489"><span class="tok-kw">const</span> ReferenceTest = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L490">    key: *<span class="tok-kw">const</span> [KEY_LEN]<span class="tok-type">u8</span>,</span>
<span class="line" id="L491">    context_string: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L492">    cases: []<span class="tok-kw">const</span> ReferenceTestCase,</span>
<span class="line" id="L493">};</span>
<span class="line" id="L494"></span>
<span class="line" id="L495"><span class="tok-kw">const</span> ReferenceTestCase = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L496">    input_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L497">    hash: *<span class="tok-kw">const</span> [<span class="tok-number">262</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L498">    keyed_hash: *<span class="tok-kw">const</span> [<span class="tok-number">262</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L499">    derive_key: *<span class="tok-kw">const</span> [<span class="tok-number">262</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L500">};</span>
<span class="line" id="L501"></span>
<span class="line" id="L502"><span class="tok-comment">// Each test is an input length and three outputs, one for each of the `hash`, `keyed_hash`, and</span>
</span>
<span class="line" id="L503"><span class="tok-comment">// `derive_key` modes. The input in each case is filled with a 251-byte-long repeating pattern:</span>
</span>
<span class="line" id="L504"><span class="tok-comment">// 0, 1, 2, ..., 249, 250, 0, 1, ... The key used with `keyed_hash` is the 32-byte ASCII string</span>
</span>
<span class="line" id="L505"><span class="tok-comment">// given in the `key` field below. For `derive_key`, the test input is used as the input key, and</span>
</span>
<span class="line" id="L506"><span class="tok-comment">// the context string is 'BLAKE3 2019-12-27 16:29:52 test vectors context'. (As good practice for</span>
</span>
<span class="line" id="L507"><span class="tok-comment">// following the security requirements of `derive_key`, test runners should make that context</span>
</span>
<span class="line" id="L508"><span class="tok-comment">// string a hardcoded constant, and we do not provided it in machine-readable form.) Outputs are</span>
</span>
<span class="line" id="L509"><span class="tok-comment">// encoded as hexadecimal. Each case is an extended output, and implementations should also check</span>
</span>
<span class="line" id="L510"><span class="tok-comment">// that the first 32 bytes match their default-length output.</span>
</span>
<span class="line" id="L511"><span class="tok-comment">//</span>
</span>
<span class="line" id="L512"><span class="tok-comment">// Source: https://github.com/BLAKE3-team/BLAKE3/blob/92d421dea1a89e2f079f4dbd93b0dab41234b279/test_vectors/test_vectors.json</span>
</span>
<span class="line" id="L513"><span class="tok-kw">const</span> reference_test = ReferenceTest{</span>
<span class="line" id="L514">    .key = <span class="tok-str">&quot;whats the Elvish word for friend&quot;</span>,</span>
<span class="line" id="L515">    .context_string = <span class="tok-str">&quot;BLAKE3 2019-12-27 16:29:52 test vectors context&quot;</span>,</span>
<span class="line" id="L516">    .cases = &amp;[_]ReferenceTestCase{</span>
<span class="line" id="L517">        .{</span>
<span class="line" id="L518">            .input_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L519">            .hash = <span class="tok-str">&quot;af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262e00f03e7b69af26b7faaf09fcd333050338ddfe085b8cc869ca98b206c08243a26f5487789e8f660afe6c99ef9e0c52b92e7393024a80459cf91f476f9ffdbda7001c22e159b402631f277ca96f2defdf1078282314e763699a31c5363165421cce14d&quot;</span>,</span>
<span class="line" id="L520">            .keyed_hash = <span class="tok-str">&quot;92b2b75604ed3c761f9d6f62392c8a9227ad0ea3f09573e783f1498a4ed60d26b18171a2f22a4b94822c701f107153dba24918c4bae4d2945c20ece13387627d3b73cbf97b797d5e59948c7ef788f54372df45e45e4293c7dc18c1d41144a9758be58960856be1eabbe22c2653190de560ca3b2ac4aa692a9210694254c371e851bc8f&quot;</span>,</span>
<span class="line" id="L521">            .derive_key = <span class="tok-str">&quot;2cc39783c223154fea8dfb7c1b1660f2ac2dcbd1c1de8277b0b0dd39b7e50d7d905630c8be290dfcf3e6842f13bddd573c098c3f17361f1f206b8cad9d088aa4a3f746752c6b0ce6a83b0da81d59649257cdf8eb3e9f7d4998e41021fac119deefb896224ac99f860011f73609e6e0e4540f93b273e56547dfd3aa1a035ba6689d89a0&quot;</span>,</span>
<span class="line" id="L522">        },</span>
<span class="line" id="L523">        .{</span>
<span class="line" id="L524">            .input_len = <span class="tok-number">1</span>,</span>
<span class="line" id="L525">            .hash = <span class="tok-str">&quot;2d3adedff11b61f14c886e35afa036736dcd87a74d27b5c1510225d0f592e213c3a6cb8bf623e20cdb535f8d1a5ffb86342d9c0b64aca3bce1d31f60adfa137b358ad4d79f97b47c3d5e79f179df87a3b9776ef8325f8329886ba42f07fb138bb502f4081cbcec3195c5871e6c23e2cc97d3c69a613eba131e5f1351f3f1da786545e5&quot;</span>,</span>
<span class="line" id="L526">            .keyed_hash = <span class="tok-str">&quot;6d7878dfff2f485635d39013278ae14f1454b8c0a3a2d34bc1ab38228a80c95b6568c0490609413006fbd428eb3fd14e7756d90f73a4725fad147f7bf70fd61c4e0cf7074885e92b0e3f125978b4154986d4fb202a3f331a3fb6cf349a3a70e49990f98fe4289761c8602c4e6ab1138d31d3b62218078b2f3ba9a88e1d08d0dd4cea11&quot;</span>,</span>
<span class="line" id="L527">            .derive_key = <span class="tok-str">&quot;b3e2e340a117a499c6cf2398a19ee0d29cca2bb7404c73063382693bf66cb06c5827b91bf889b6b97c5477f535361caefca0b5d8c4746441c57617111933158950670f9aa8a05d791daae10ac683cbef8faf897c84e6114a59d2173c3f417023a35d6983f2c7dfa57e7fc559ad751dbfb9ffab39c2ef8c4aafebc9ae973a64f0c76551&quot;</span>,</span>
<span class="line" id="L528">        },</span>
<span class="line" id="L529">        .{</span>
<span class="line" id="L530">            .input_len = <span class="tok-number">1023</span>,</span>
<span class="line" id="L531">            .hash = <span class="tok-str">&quot;10108970eeda3eb932baac1428c7a2163b0e924c9a9e25b35bba72b28f70bd11a182d27a591b05592b15607500e1e8dd56bc6c7fc063715b7a1d737df5bad3339c56778957d870eb9717b57ea3d9fb68d1b55127bba6a906a4a24bbd5acb2d123a37b28f9e9a81bbaae360d58f85e5fc9d75f7c370a0cc09b6522d9c8d822f2f28f485&quot;</span>,</span>
<span class="line" id="L532">            .keyed_hash = <span class="tok-str">&quot;c951ecdf03288d0fcc96ee3413563d8a6d3589547f2c2fb36d9786470f1b9d6e890316d2e6d8b8c25b0a5b2180f94fb1a158ef508c3cde45e2966bd796a696d3e13efd86259d756387d9becf5c8bf1ce2192b87025152907b6d8cc33d17826d8b7b9bc97e38c3c85108ef09f013e01c229c20a83d9e8efac5b37470da28575fd755a10&quot;</span>,</span>
<span class="line" id="L533">            .derive_key = <span class="tok-str">&quot;74a16c1c3d44368a86e1ca6df64be6a2f64cce8f09220787450722d85725dea59c413264404661e9e4d955409dfe4ad3aa487871bcd454ed12abfe2c2b1eb7757588cf6cb18d2eccad49e018c0d0fec323bec82bf1644c6325717d13ea712e6840d3e6e730d35553f59eff5377a9c350bcc1556694b924b858f329c44ee64b884ef00d&quot;</span>,</span>
<span class="line" id="L534">        },</span>
<span class="line" id="L535">        .{</span>
<span class="line" id="L536">            .input_len = <span class="tok-number">1024</span>,</span>
<span class="line" id="L537">            .hash = <span class="tok-str">&quot;42214739f095a406f3fc83deb889744ac00df831c10daa55189b5d121c855af71cf8107265ecdaf8505b95d8fcec83a98a6a96ea5109d2c179c47a387ffbb404756f6eeae7883b446b70ebb144527c2075ab8ab204c0086bb22b7c93d465efc57f8d917f0b385c6df265e77003b85102967486ed57db5c5ca170ba441427ed9afa684e&quot;</span>,</span>
<span class="line" id="L538">            .keyed_hash = <span class="tok-str">&quot;75c46f6f3d9eb4f55ecaaee480db732e6c2105546f1e675003687c31719c7ba4a78bc838c72852d4f49c864acb7adafe2478e824afe51c8919d06168414c265f298a8094b1ad813a9b8614acabac321f24ce61c5a5346eb519520d38ecc43e89b5000236df0597243e4d2493fd626730e2ba17ac4d8824d09d1a4a8f57b8227778e2de&quot;</span>,</span>
<span class="line" id="L539">            .derive_key = <span class="tok-str">&quot;7356cd7720d5b66b6d0697eb3177d9f8d73a4a5c5e968896eb6a6896843027066c23b601d3ddfb391e90d5c8eccdef4ae2a264bce9e612ba15e2bc9d654af1481b2e75dbabe615974f1070bba84d56853265a34330b4766f8e75edd1f4a1650476c10802f22b64bd3919d246ba20a17558bc51c199efdec67e80a227251808d8ce5bad&quot;</span>,</span>
<span class="line" id="L540">        },</span>
<span class="line" id="L541">        .{</span>
<span class="line" id="L542">            .input_len = <span class="tok-number">1025</span>,</span>
<span class="line" id="L543">            .hash = <span class="tok-str">&quot;d00278ae47eb27b34faecf67b4fe263f82d5412916c1ffd97c8cb7fb814b8444f4c4a22b4b399155358a994e52bf255de60035742ec71bd08ac275a1b51cc6bfe332b0ef84b409108cda080e6269ed4b3e2c3f7d722aa4cdc98d16deb554e5627be8f955c98e1d5f9565a9194cad0c4285f93700062d9595adb992ae68ff12800ab67a&quot;</span>,</span>
<span class="line" id="L544">            .keyed_hash = <span class="tok-str">&quot;357dc55de0c7e382c900fd6e320acc04146be01db6a8ce7210b7189bd664ea69362396b77fdc0d2634a552970843722066c3c15902ae5097e00ff53f1e116f1cd5352720113a837ab2452cafbde4d54085d9cf5d21ca613071551b25d52e69d6c81123872b6f19cd3bc1333edf0c52b94de23ba772cf82636cff4542540a7738d5b930&quot;</span>,</span>
<span class="line" id="L545">            .derive_key = <span class="tok-str">&quot;effaa245f065fbf82ac186839a249707c3bddf6d3fdda22d1b95a3c970379bcb5d31013a167509e9066273ab6e2123bc835b408b067d88f96addb550d96b6852dad38e320b9d940f86db74d398c770f462118b35d2724efa13da97194491d96dd37c3c09cbef665953f2ee85ec83d88b88d11547a6f911c8217cca46defa2751e7f3ad&quot;</span>,</span>
<span class="line" id="L546">        },</span>
<span class="line" id="L547">        .{</span>
<span class="line" id="L548">            .input_len = <span class="tok-number">2048</span>,</span>
<span class="line" id="L549">            .hash = <span class="tok-str">&quot;e776b6028c7cd22a4d0ba182a8bf62205d2ef576467e838ed6f2529b85fba24a9a60bf80001410ec9eea6698cd537939fad4749edd484cb541aced55cd9bf54764d063f23f6f1e32e12958ba5cfeb1bf618ad094266d4fc3c968c2088f677454c288c67ba0dba337b9d91c7e1ba586dc9a5bc2d5e90c14f53a8863ac75655461cea8f9&quot;</span>,</span>
<span class="line" id="L550">            .keyed_hash = <span class="tok-str">&quot;879cf1fa2ea0e79126cb1063617a05b6ad9d0b696d0d757cf053439f60a99dd10173b961cd574288194b23ece278c330fbb8585485e74967f31352a8183aa782b2b22f26cdcadb61eed1a5bc144b8198fbb0c13abbf8e3192c145d0a5c21633b0ef86054f42809df823389ee40811a5910dcbd1018af31c3b43aa55201ed4edaac74fe&quot;</span>,</span>
<span class="line" id="L551">            .derive_key = <span class="tok-str">&quot;7b2945cb4fef70885cc5d78a87bf6f6207dd901ff239201351ffac04e1088a23e2c11a1ebffcea4d80447867b61badb1383d842d4e79645d48dd82ccba290769caa7af8eaa1bd78a2a5e6e94fbdab78d9c7b74e894879f6a515257ccf6f95056f4e25390f24f6b35ffbb74b766202569b1d797f2d4bd9d17524c720107f985f4ddc583&quot;</span>,</span>
<span class="line" id="L552">        },</span>
<span class="line" id="L553">        .{</span>
<span class="line" id="L554">            .input_len = <span class="tok-number">2049</span>,</span>
<span class="line" id="L555">            .hash = <span class="tok-str">&quot;5f4d72f40d7a5f82b15ca2b2e44b1de3c2ef86c426c95c1af0b687952256303096de31d71d74103403822a2e0bc1eb193e7aecc9643a76b7bbc0c9f9c52e8783aae98764ca468962b5c2ec92f0c74eb5448d519713e09413719431c802f948dd5d90425a4ecdadece9eb178d80f26efccae630734dff63340285adec2aed3b51073ad3&quot;</span>,</span>
<span class="line" id="L556">            .keyed_hash = <span class="tok-str">&quot;9f29700902f7c86e514ddc4df1e3049f258b2472b6dd5267f61bf13983b78dd5f9a88abfefdfa1e00b418971f2b39c64ca621e8eb37fceac57fd0c8fc8e117d43b81447be22d5d8186f8f5919ba6bcc6846bd7d50726c06d245672c2ad4f61702c646499ee1173daa061ffe15bf45a631e2946d616a4c345822f1151284712f76b2b0e&quot;</span>,</span>
<span class="line" id="L557">            .derive_key = <span class="tok-str">&quot;2ea477c5515cc3dd606512ee72bb3e0e758cfae7232826f35fb98ca1bcbdf27316d8e9e79081a80b046b60f6a263616f33ca464bd78d79fa18200d06c7fc9bffd808cc4755277a7d5e09da0f29ed150f6537ea9bed946227ff184cc66a72a5f8c1e4bd8b04e81cf40fe6dc4427ad5678311a61f4ffc39d195589bdbc670f63ae70f4b6&quot;</span>,</span>
<span class="line" id="L558">        },</span>
<span class="line" id="L559">        .{</span>
<span class="line" id="L560">            .input_len = <span class="tok-number">3072</span>,</span>
<span class="line" id="L561">            .hash = <span class="tok-str">&quot;b98cb0ff3623be03326b373de6b9095218513e64f1ee2edd2525c7ad1e5cffd29a3f6b0b978d6608335c09dc94ccf682f9951cdfc501bfe47b9c9189a6fc7b404d120258506341a6d802857322fbd20d3e5dae05b95c88793fa83db1cb08e7d8008d1599b6209d78336e24839724c191b2a52a80448306e0daa84a3fdb566661a37e11&quot;</span>,</span>
<span class="line" id="L562">            .keyed_hash = <span class="tok-str">&quot;044a0e7b172a312dc02a4c9a818c036ffa2776368d7f528268d2e6b5df19177022f302d0529e4174cc507c463671217975e81dab02b8fdeb0d7ccc7568dd22574c783a76be215441b32e91b9a904be8ea81f7a0afd14bad8ee7c8efc305ace5d3dd61b996febe8da4f56ca0919359a7533216e2999fc87ff7d8f176fbecb3d6f34278b&quot;</span>,</span>
<span class="line" id="L563">            .derive_key = <span class="tok-str">&quot;050df97f8c2ead654d9bb3ab8c9178edcd902a32f8495949feadcc1e0480c46b3604131bbd6e3ba573b6dd682fa0a63e5b165d39fc43a625d00207607a2bfeb65ff1d29292152e26b298868e3b87be95d6458f6f2ce6118437b632415abe6ad522874bcd79e4030a5e7bad2efa90a7a7c67e93f0a18fb28369d0a9329ab5c24134ccb0&quot;</span>,</span>
<span class="line" id="L564">        },</span>
<span class="line" id="L565">        .{</span>
<span class="line" id="L566">            .input_len = <span class="tok-number">3073</span>,</span>
<span class="line" id="L567">            .hash = <span class="tok-str">&quot;7124b49501012f81cc7f11ca069ec9226cecb8a2c850cfe644e327d22d3e1cd39a27ae3b79d68d89da9bf25bc27139ae65a324918a5f9b7828181e52cf373c84f35b639b7fccbb985b6f2fa56aea0c18f531203497b8bbd3a07ceb5926f1cab74d14bd66486d9a91eba99059a98bd1cd25876b2af5a76c3e9eed554ed72ea952b603bf&quot;</span>,</span>
<span class="line" id="L568">            .keyed_hash = <span class="tok-str">&quot;68dede9bef00ba89e43f31a6825f4cf433389fedae75c04ee9f0cf16a427c95a96d6da3fe985054d3478865be9a092250839a697bbda74e279e8a9e69f0025e4cfddd6cfb434b1cd9543aaf97c635d1b451a4386041e4bb100f5e45407cbbc24fa53ea2de3536ccb329e4eb9466ec37093a42cf62b82903c696a93a50b702c80f3c3c5&quot;</span>,</span>
<span class="line" id="L569">            .derive_key = <span class="tok-str">&quot;72613c9ec9ff7e40f8f5c173784c532ad852e827dba2bf85b2ab4b76f7079081576288e552647a9d86481c2cae75c2dd4e7c5195fb9ada1ef50e9c5098c249d743929191441301c69e1f48505a4305ec1778450ee48b8e69dc23a25960fe33070ea549119599760a8a2d28aeca06b8c5e9ba58bc19e11fe57b6ee98aa44b2a8e6b14a5&quot;</span>,</span>
<span class="line" id="L570">        },</span>
<span class="line" id="L571">        .{</span>
<span class="line" id="L572">            .input_len = <span class="tok-number">4096</span>,</span>
<span class="line" id="L573">            .hash = <span class="tok-str">&quot;015094013f57a5277b59d8475c0501042c0b642e531b0a1c8f58d2163229e9690289e9409ddb1b99768eafe1623da896faf7e1114bebeadc1be30829b6f8af707d85c298f4f0ff4d9438aef948335612ae921e76d411c3a9111df62d27eaf871959ae0062b5492a0feb98ef3ed4af277f5395172dbe5c311918ea0074ce0036454f620&quot;</span>,</span>
<span class="line" id="L574">            .keyed_hash = <span class="tok-str">&quot;befc660aea2f1718884cd8deb9902811d332f4fc4a38cf7c7300d597a081bfc0bbb64a36edb564e01e4b4aaf3b060092a6b838bea44afebd2deb8298fa562b7b597c757b9df4c911c3ca462e2ac89e9a787357aaf74c3b56d5c07bc93ce899568a3eb17d9250c20f6c5f6c1e792ec9a2dcb715398d5a6ec6d5c54f586a00403a1af1de&quot;</span>,</span>
<span class="line" id="L575">            .derive_key = <span class="tok-str">&quot;1e0d7f3db8c414c97c6307cbda6cd27ac3b030949da8e23be1a1a924ad2f25b9d78038f7b198596c6cc4a9ccf93223c08722d684f240ff6569075ed81591fd93f9fff1110b3a75bc67e426012e5588959cc5a4c192173a03c00731cf84544f65a2fb9378989f72e9694a6a394a8a30997c2e67f95a504e631cd2c5f55246024761b245&quot;</span>,</span>
<span class="line" id="L576">        },</span>
<span class="line" id="L577">        .{</span>
<span class="line" id="L578">            .input_len = <span class="tok-number">4097</span>,</span>
<span class="line" id="L579">            .hash = <span class="tok-str">&quot;9b4052b38f1c5fc8b1f9ff7ac7b27cd242487b3d890d15c96a1c25b8aa0fb99505f91b0b5600a11251652eacfa9497b31cd3c409ce2e45cfe6c0a016967316c426bd26f619eab5d70af9a418b845c608840390f361630bd497b1ab44019316357c61dbe091ce72fc16dc340ac3d6e009e050b3adac4b5b2c92e722cffdc46501531956&quot;</span>,</span>
<span class="line" id="L580">            .keyed_hash = <span class="tok-str">&quot;00df940cd36bb9fa7cbbc3556744e0dbc8191401afe70520ba292ee3ca80abbc606db4976cfdd266ae0abf667d9481831ff12e0caa268e7d3e57260c0824115a54ce595ccc897786d9dcbf495599cfd90157186a46ec800a6763f1c59e36197e9939e900809f7077c102f888caaf864b253bc41eea812656d46742e4ea42769f89b83f&quot;</span>,</span>
<span class="line" id="L581">            .derive_key = <span class="tok-str">&quot;aca51029626b55fda7117b42a7c211f8c6e9ba4fe5b7a8ca922f34299500ead8a897f66a400fed9198fd61dd2d58d382458e64e100128075fc54b860934e8de2e84170734b06e1d212a117100820dbc48292d148afa50567b8b84b1ec336ae10d40c8c975a624996e12de31abbe135d9d159375739c333798a80c64ae895e51e22f3ad&quot;</span>,</span>
<span class="line" id="L582">        },</span>
<span class="line" id="L583">        .{</span>
<span class="line" id="L584">            .input_len = <span class="tok-number">5120</span>,</span>
<span class="line" id="L585">            .hash = <span class="tok-str">&quot;9cadc15fed8b5d854562b26a9536d9707cadeda9b143978f319ab34230535833acc61c8fdc114a2010ce8038c853e121e1544985133fccdd0a2d507e8e615e611e9a0ba4f47915f49e53d721816a9198e8b30f12d20ec3689989175f1bf7a300eee0d9321fad8da232ece6efb8e9fd81b42ad161f6b9550a069e66b11b40487a5f5059&quot;</span>,</span>
<span class="line" id="L586">            .keyed_hash = <span class="tok-str">&quot;2c493e48e9b9bf31e0553a22b23503c0a3388f035cece68eb438d22fa1943e209b4dc9209cd80ce7c1f7c9a744658e7e288465717ae6e56d5463d4f80cdb2ef56495f6a4f5487f69749af0c34c2cdfa857f3056bf8d807336a14d7b89bf62bef2fb54f9af6a546f818dc1e98b9e07f8a5834da50fa28fb5874af91bf06020d1bf0120e&quot;</span>,</span>
<span class="line" id="L587">            .derive_key = <span class="tok-str">&quot;7a7acac8a02adcf3038d74cdd1d34527de8a0fcc0ee3399d1262397ce5817f6055d0cefd84d9d57fe792d65a278fd20384ac6c30fdb340092f1a74a92ace99c482b28f0fc0ef3b923e56ade20c6dba47e49227166251337d80a037e987ad3a7f728b5ab6dfafd6e2ab1bd583a95d9c895ba9c2422c24ea0f62961f0dca45cad47bfa0d&quot;</span>,</span>
<span class="line" id="L588">        },</span>
<span class="line" id="L589">        .{</span>
<span class="line" id="L590">            .input_len = <span class="tok-number">5121</span>,</span>
<span class="line" id="L591">            .hash = <span class="tok-str">&quot;628bd2cb2004694adaab7bbd778a25df25c47b9d4155a55f8fbd79f2fe154cff96adaab0613a6146cdaabe498c3a94e529d3fc1da2bd08edf54ed64d40dcd6777647eac51d8277d70219a9694334a68bc8f0f23e20b0ff70ada6f844542dfa32cd4204ca1846ef76d811cdb296f65e260227f477aa7aa008bac878f72257484f2b6c95&quot;</span>,</span>
<span class="line" id="L592">            .keyed_hash = <span class="tok-str">&quot;6ccf1c34753e7a044db80798ecd0782a8f76f33563accaddbfbb2e0ea4b2d0240d07e63f13667a8d1490e5e04f13eb617aea16a8c8a5aaed1ef6fbde1b0515e3c81050b361af6ead126032998290b563e3caddeaebfab592e155f2e161fb7cba939092133f23f9e65245e58ec23457b78a2e8a125588aad6e07d7f11a85b88d375b72d&quot;</span>,</span>
<span class="line" id="L593">            .derive_key = <span class="tok-str">&quot;b07f01e518e702f7ccb44a267e9e112d403a7b3f4883a47ffbed4b48339b3c341a0add0ac032ab5aaea1e4e5b004707ec5681ae0fcbe3796974c0b1cf31a194740c14519273eedaabec832e8a784b6e7cfc2c5952677e6c3f2c3914454082d7eb1ce1766ac7d75a4d3001fc89544dd46b5147382240d689bbbaefc359fb6ae30263165&quot;</span>,</span>
<span class="line" id="L594">        },</span>
<span class="line" id="L595">        .{</span>
<span class="line" id="L596">            .input_len = <span class="tok-number">6144</span>,</span>
<span class="line" id="L597">            .hash = <span class="tok-str">&quot;3e2e5b74e048f3add6d21faab3f83aa44d3b2278afb83b80b3c35164ebeca2054d742022da6fdda444ebc384b04a54c3ac5839b49da7d39f6d8a9db03deab32aade156c1c0311e9b3435cde0ddba0dce7b26a376cad121294b689193508dd63151603c6ddb866ad16c2ee41585d1633a2cea093bea714f4c5d6b903522045b20395c83&quot;</span>,</span>
<span class="line" id="L598">            .keyed_hash = <span class="tok-str">&quot;3d6b6d21281d0ade5b2b016ae4034c5dec10ca7e475f90f76eac7138e9bc8f1dc35754060091dc5caf3efabe0603c60f45e415bb3407db67e6beb3d11cf8e4f7907561f05dace0c15807f4b5f389c841eb114d81a82c02a00b57206b1d11fa6e803486b048a5ce87105a686dee041207e095323dfe172df73deb8c9532066d88f9da7e&quot;</span>,</span>
<span class="line" id="L599">            .derive_key = <span class="tok-str">&quot;2a95beae63ddce523762355cf4b9c1d8f131465780a391286a5d01abb5683a1597099e3c6488aab6c48f3c15dbe1942d21dbcdc12115d19a8b8465fb54e9053323a9178e4275647f1a9927f6439e52b7031a0b465c861a3fc531527f7758b2b888cf2f20582e9e2c593709c0a44f9c6e0f8b963994882ea4168827823eef1f64169fef&quot;</span>,</span>
<span class="line" id="L600">        },</span>
<span class="line" id="L601">        .{</span>
<span class="line" id="L602">            .input_len = <span class="tok-number">6145</span>,</span>
<span class="line" id="L603">            .hash = <span class="tok-str">&quot;f1323a8631446cc50536a9f705ee5cb619424d46887f3c376c695b70e0f0507f18a2cfdd73c6e39dd75ce7c1c6e3ef238fd54465f053b25d21044ccb2093beb015015532b108313b5829c3621ce324b8e14229091b7c93f32db2e4e63126a377d2a63a3597997d4f1cba59309cb4af240ba70cebff9a23d5e3ff0cdae2cfd54e070022&quot;</span>,</span>
<span class="line" id="L604">            .keyed_hash = <span class="tok-str">&quot;9ac301e9e39e45e3250a7e3b3df701aa0fb6889fbd80eeecf28dbc6300fbc539f3c184ca2f59780e27a576c1d1fb9772e99fd17881d02ac7dfd39675aca918453283ed8c3169085ef4a466b91c1649cc341dfdee60e32231fc34c9c4e0b9a2ba87ca8f372589c744c15fd6f985eec15e98136f25beeb4b13c4e43dc84abcc79cd4646c&quot;</span>,</span>
<span class="line" id="L605">            .derive_key = <span class="tok-str">&quot;379bcc61d0051dd489f686c13de00d5b14c505245103dc040d9e4dd1facab8e5114493d029bdbd295aaa744a59e31f35c7f52dba9c3642f773dd0b4262a9980a2aef811697e1305d37ba9d8b6d850ef07fe41108993180cf779aeece363704c76483458603bbeeb693cffbbe5588d1f3535dcad888893e53d977424bb707201569a8d2&quot;</span>,</span>
<span class="line" id="L606">        },</span>
<span class="line" id="L607">        .{</span>
<span class="line" id="L608">            .input_len = <span class="tok-number">7168</span>,</span>
<span class="line" id="L609">            .hash = <span class="tok-str">&quot;61da957ec2499a95d6b8023e2b0e604ec7f6b50e80a9678b89d2628e99ada77a5707c321c83361793b9af62a40f43b523df1c8633cecb4cd14d00bdc79c78fca5165b863893f6d38b02ff7236c5a9a8ad2dba87d24c547cab046c29fc5bc1ed142e1de4763613bb162a5a538e6ef05ed05199d751f9eb58d332791b8d73fb74e4fce95&quot;</span>,</span>
<span class="line" id="L610">            .keyed_hash = <span class="tok-str">&quot;b42835e40e9d4a7f42ad8cc04f85a963a76e18198377ed84adddeaecacc6f3fca2f01d5277d69bb681c70fa8d36094f73ec06e452c80d2ff2257ed82e7ba348400989a65ee8daa7094ae0933e3d2210ac6395c4af24f91c2b590ef87d7788d7066ea3eaebca4c08a4f14b9a27644f99084c3543711b64a070b94f2c9d1d8a90d035d52&quot;</span>,</span>
<span class="line" id="L611">            .derive_key = <span class="tok-str">&quot;11c37a112765370c94a51415d0d651190c288566e295d505defdad895dae223730d5a5175a38841693020669c7638f40b9bc1f9f39cf98bda7a5b54ae24218a800a2116b34665aa95d846d97ea988bfcb53dd9c055d588fa21ba78996776ea6c40bc428b53c62b5f3ccf200f647a5aae8067f0ea1976391fcc72af1945100e2a6dcb88&quot;</span>,</span>
<span class="line" id="L612">        },</span>
<span class="line" id="L613">        .{</span>
<span class="line" id="L614">            .input_len = <span class="tok-number">7169</span>,</span>
<span class="line" id="L615">            .hash = <span class="tok-str">&quot;a003fc7a51754a9b3c7fae0367ab3d782dccf28855a03d435f8cfe74605e781798a8b20534be1ca9eb2ae2df3fae2ea60e48c6fb0b850b1385b5de0fe460dbe9d9f9b0d8db4435da75c601156df9d047f4ede008732eb17adc05d96180f8a73548522840779e6062d643b79478a6e8dbce68927f36ebf676ffa7d72d5f68f050b119c8&quot;</span>,</span>
<span class="line" id="L616">            .keyed_hash = <span class="tok-str">&quot;ed9b1a922c046fdb3d423ae34e143b05ca1bf28b710432857bf738bcedbfa5113c9e28d72fcbfc020814ce3f5d4fc867f01c8f5b6caf305b3ea8a8ba2da3ab69fabcb438f19ff11f5378ad4484d75c478de425fb8e6ee809b54eec9bdb184315dc856617c09f5340451bf42fd3270a7b0b6566169f242e533777604c118a6358250f54&quot;</span>,</span>
<span class="line" id="L617">            .derive_key = <span class="tok-str">&quot;554b0a5efea9ef183f2f9b931b7497995d9eb26f5c5c6dad2b97d62fc5ac31d99b20652c016d88ba2a611bbd761668d5eda3e568e940faae24b0d9991c3bd25a65f770b89fdcadabcb3d1a9c1cb63e69721cacf1ae69fefdcef1e3ef41bc5312ccc17222199e47a26552c6adc460cf47a72319cb5039369d0060eaea59d6c65130f1dd&quot;</span>,</span>
<span class="line" id="L618">        },</span>
<span class="line" id="L619">        .{</span>
<span class="line" id="L620">            .input_len = <span class="tok-number">8192</span>,</span>
<span class="line" id="L621">            .hash = <span class="tok-str">&quot;aae792484c8efe4f19e2ca7d371d8c467ffb10748d8a5a1ae579948f718a2a635fe51a27db045a567c1ad51be5aa34c01c6651c4d9b5b5ac5d0fd58cf18dd61a47778566b797a8c67df7b1d60b97b19288d2d877bb2df417ace009dcb0241ca1257d62712b6a4043b4ff33f690d849da91ea3bf711ed583cb7b7a7da2839ba71309bbf&quot;</span>,</span>
<span class="line" id="L622">            .keyed_hash = <span class="tok-str">&quot;dc9637c8845a770b4cbf76b8daec0eebf7dc2eac11498517f08d44c8fc00d58a4834464159dcbc12a0ba0c6d6eb41bac0ed6585cabfe0aca36a375e6c5480c22afdc40785c170f5a6b8a1107dbee282318d00d915ac9ed1143ad40765ec120042ee121cd2baa36250c618adaf9e27260fda2f94dea8fb6f08c04f8f10c78292aa46102&quot;</span>,</span>
<span class="line" id="L623">            .derive_key = <span class="tok-str">&quot;ad01d7ae4ad059b0d33baa3c01319dcf8088094d0359e5fd45d6aeaa8b2d0c3d4c9e58958553513b67f84f8eac653aeeb02ae1d5672dcecf91cd9985a0e67f4501910ecba25555395427ccc7241d70dc21c190e2aadee875e5aae6bf1912837e53411dabf7a56cbf8e4fb780432b0d7fe6cec45024a0788cf5874616407757e9e6bef7&quot;</span>,</span>
<span class="line" id="L624">        },</span>
<span class="line" id="L625">        .{</span>
<span class="line" id="L626">            .input_len = <span class="tok-number">8193</span>,</span>
<span class="line" id="L627">            .hash = <span class="tok-str">&quot;bab6c09cb8ce8cf459261398d2e7aef35700bf488116ceb94a36d0f5f1b7bc3bb2282aa69be089359ea1154b9a9286c4a56af4de975a9aa4a5c497654914d279bea60bb6d2cf7225a2fa0ff5ef56bbe4b149f3ed15860f78b4e2ad04e158e375c1e0c0b551cd7dfc82f1b155c11b6b3ed51ec9edb30d133653bb5709d1dbd55f4e1ff6&quot;</span>,</span>
<span class="line" id="L628">            .keyed_hash = <span class="tok-str">&quot;954a2a75420c8d6547e3ba5b98d963e6fa6491addc8c023189cc519821b4a1f5f03228648fd983aef045c2fa8290934b0866b615f585149587dda2299039965328835a2b18f1d63b7e300fc76ff260b571839fe44876a4eae66cbac8c67694411ed7e09df51068a22c6e67d6d3dd2cca8ff12e3275384006c80f4db68023f24eebba57&quot;</span>,</span>
<span class="line" id="L629">            .derive_key = <span class="tok-str">&quot;af1e0346e389b17c23200270a64aa4e1ead98c61695d917de7d5b00491c9b0f12f20a01d6d622edf3de026a4db4e4526225debb93c1237934d71c7340bb5916158cbdafe9ac3225476b6ab57a12357db3abbad7a26c6e66290e44034fb08a20a8d0ec264f309994d2810c49cfba6989d7abb095897459f5425adb48aba07c5fb3c83c0&quot;</span>,</span>
<span class="line" id="L630">        },</span>
<span class="line" id="L631">        .{</span>
<span class="line" id="L632">            .input_len = <span class="tok-number">16384</span>,</span>
<span class="line" id="L633">            .hash = <span class="tok-str">&quot;f875d6646de28985646f34ee13be9a576fd515f76b5b0a26bb324735041ddde49d764c270176e53e97bdffa58d549073f2c660be0e81293767ed4e4929f9ad34bbb39a529334c57c4a381ffd2a6d4bfdbf1482651b172aa883cc13408fa67758a3e47503f93f87720a3177325f7823251b85275f64636a8f1d599c2e49722f42e93893&quot;</span>,</span>
<span class="line" id="L634">            .keyed_hash = <span class="tok-str">&quot;9e9fc4eb7cf081ea7c47d1807790ed211bfec56aa25bb7037784c13c4b707b0df9e601b101e4cf63a404dfe50f2e1865bb12edc8fca166579ce0c70dba5a5c0fc960ad6f3772183416a00bd29d4c6e651ea7620bb100c9449858bf14e1ddc9ecd35725581ca5b9160de04060045993d972571c3e8f71e9d0496bfa744656861b169d65&quot;</span>,</span>
<span class="line" id="L635">            .derive_key = <span class="tok-str">&quot;160e18b5878cd0df1c3af85eb25a0db5344d43a6fbd7a8ef4ed98d0714c3f7e160dc0b1f09caa35f2f417b9ef309dfe5ebd67f4c9507995a531374d099cf8ae317542e885ec6f589378864d3ea98716b3bbb65ef4ab5e0ab5bb298a501f19a41ec19af84a5e6b428ecd813b1a47ed91c9657c3fba11c406bc316768b58f6802c9e9b57&quot;</span>,</span>
<span class="line" id="L636">        },</span>
<span class="line" id="L637">        .{</span>
<span class="line" id="L638">            .input_len = <span class="tok-number">31744</span>,</span>
<span class="line" id="L639">            .hash = <span class="tok-str">&quot;62b6960e1a44bcc1eb1a611a8d6235b6b4b78f32e7abc4fb4c6cdcce94895c47860cc51f2b0c28a7b77304bd55fe73af663c02d3f52ea053ba43431ca5bab7bfea2f5e9d7121770d88f70ae9649ea713087d1914f7f312147e247f87eb2d4ffef0ac978bf7b6579d57d533355aa20b8b77b13fd09748728a5cc327a8ec470f4013226f&quot;</span>,</span>
<span class="line" id="L640">            .keyed_hash = <span class="tok-str">&quot;efa53b389ab67c593dba624d898d0f7353ab99e4ac9d42302ee64cbf9939a4193a7258db2d9cd32a7a3ecfce46144114b15c2fcb68a618a976bd74515d47be08b628be420b5e830fade7c080e351a076fbc38641ad80c736c8a18fe3c66ce12f95c61c2462a9770d60d0f77115bbcd3782b593016a4e728d4c06cee4505cb0c08a42ec&quot;</span>,</span>
<span class="line" id="L641">            .derive_key = <span class="tok-str">&quot;39772aef80e0ebe60596361e45b061e8f417429d529171b6764468c22928e28e9759adeb797a3fbf771b1bcea30150a020e317982bf0d6e7d14dd9f064bc11025c25f31e81bd78a921db0174f03dd481d30e93fd8e90f8b2fee209f849f2d2a52f31719a490fb0ba7aea1e09814ee912eba111a9fde9d5c274185f7bae8ba85d300a2b&quot;</span>,</span>
<span class="line" id="L642">        },</span>
<span class="line" id="L643">        .{</span>
<span class="line" id="L644">            .input_len = <span class="tok-number">102400</span>,</span>
<span class="line" id="L645">            .hash = <span class="tok-str">&quot;bc3e3d41a1146b069abffad3c0d44860cf664390afce4d9661f7902e7943e085e01c59dab908c04c3342b816941a26d69c2605ebee5ec5291cc55e15b76146e6745f0601156c3596cb75065a9c57f35585a52e1ac70f69131c23d611ce11ee4ab1ec2c009012d236648e77be9295dd0426f29b764d65de58eb7d01dd42248204f45f8e&quot;</span>,</span>
<span class="line" id="L646">            .keyed_hash = <span class="tok-str">&quot;1c35d1a5811083fd7119f5d5d1ba027b4d01c0c6c49fb6ff2cf75393ea5db4a7f9dbdd3e1d81dcbca3ba241bb18760f207710b751846faaeb9dff8262710999a59b2aa1aca298a032d94eacfadf1aa192418eb54808db23b56e34213266aa08499a16b354f018fc4967d05f8b9d2ad87a7278337be9693fc638a3bfdbe314574ee6fc4&quot;</span>,</span>
<span class="line" id="L647">            .derive_key = <span class="tok-str">&quot;4652cff7a3f385a6103b5c260fc1593e13c778dbe608efb092fe7ee69df6e9c6d83a3e041bc3a48df2879f4a0a3ed40e7c961c73eff740f3117a0504c2dff4786d44fb17f1549eb0ba585e40ec29bf7732f0b7e286ff8acddc4cb1e23b87ff5d824a986458dcc6a04ac83969b80637562953df51ed1a7e90a7926924d2763778be8560&quot;</span>,</span>
<span class="line" id="L648">        },</span>
<span class="line" id="L649">    },</span>
<span class="line" id="L650">};</span>
<span class="line" id="L651"></span>
<span class="line" id="L652"><span class="tok-kw">fn</span> <span class="tok-fn">testBlake3</span>(hasher: *Blake3, input_len: <span class="tok-type">usize</span>, expected_hex: [<span class="tok-number">262</span>]<span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L653">    <span class="tok-comment">// Save initial state</span>
</span>
<span class="line" id="L654">    <span class="tok-kw">const</span> initial_state = hasher.*;</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-comment">// Setup input pattern</span>
</span>
<span class="line" id="L657">    <span class="tok-kw">var</span> input_pattern: [<span class="tok-number">251</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L658">    <span class="tok-kw">for</span> (input_pattern) |*e, i| e.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L659"></span>
<span class="line" id="L660">    <span class="tok-comment">// Write repeating input pattern to hasher</span>
</span>
<span class="line" id="L661">    <span class="tok-kw">var</span> input_counter = input_len;</span>
<span class="line" id="L662">    <span class="tok-kw">while</span> (input_counter &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L663">        <span class="tok-kw">const</span> update_len = math.min(input_counter, input_pattern.len);</span>
<span class="line" id="L664">        hasher.update(input_pattern[<span class="tok-number">0</span>..update_len]);</span>
<span class="line" id="L665">        input_counter -= update_len;</span>
<span class="line" id="L666">    }</span>
<span class="line" id="L667"></span>
<span class="line" id="L668">    <span class="tok-comment">// Read final hash value</span>
</span>
<span class="line" id="L669">    <span class="tok-kw">var</span> actual_bytes: [expected_hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L670">    hasher.final(actual_bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L671"></span>
<span class="line" id="L672">    <span class="tok-comment">// Compare to expected value</span>
</span>
<span class="line" id="L673">    <span class="tok-kw">var</span> expected_bytes: [expected_hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L674">    _ = fmt.hexToBytes(expected_bytes[<span class="tok-number">0</span>..], expected_hex[<span class="tok-number">0</span>..]) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L675">    <span class="tok-kw">try</span> testing.expectEqual(actual_bytes, expected_bytes);</span>
<span class="line" id="L676"></span>
<span class="line" id="L677">    <span class="tok-comment">// Restore initial state</span>
</span>
<span class="line" id="L678">    hasher.* = initial_state;</span>
<span class="line" id="L679">}</span>
<span class="line" id="L680"></span>
<span class="line" id="L681"><span class="tok-kw">test</span> <span class="tok-str">&quot;BLAKE3 reference test cases&quot;</span> {</span>
<span class="line" id="L682">    <span class="tok-kw">var</span> hash_state = Blake3.init(.{});</span>
<span class="line" id="L683">    <span class="tok-kw">const</span> hash = &amp;hash_state;</span>
<span class="line" id="L684">    <span class="tok-kw">var</span> keyed_hash_state = Blake3.init(.{ .key = reference_test.key.* });</span>
<span class="line" id="L685">    <span class="tok-kw">const</span> keyed_hash = &amp;keyed_hash_state;</span>
<span class="line" id="L686">    <span class="tok-kw">var</span> derive_key_state = Blake3.initKdf(reference_test.context_string, .{});</span>
<span class="line" id="L687">    <span class="tok-kw">const</span> derive_key = &amp;derive_key_state;</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-kw">for</span> (reference_test.cases) |t| {</span>
<span class="line" id="L690">        <span class="tok-kw">try</span> testBlake3(hash, t.input_len, t.hash.*);</span>
<span class="line" id="L691">        <span class="tok-kw">try</span> testBlake3(keyed_hash, t.input_len, t.keyed_hash.*);</span>
<span class="line" id="L692">        <span class="tok-kw">try</span> testBlake3(derive_key, t.input_len, t.derive_key.*);</span>
<span class="line" id="L693">    }</span>
<span class="line" id="L694">}</span>
<span class="line" id="L695"></span>
</code></pre></body>
</html>