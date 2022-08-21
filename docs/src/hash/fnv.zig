<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>hash/fnv.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// FNV1a - Fowler-Noll-Vo hash function</span>
</span>
<span class="line" id="L2"><span class="tok-comment">//</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// FNV1a is a fast, non-cryptographic hash function with fairly good distribution properties.</span>
</span>
<span class="line" id="L4"><span class="tok-comment">//</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://tools.ietf.org/html/draft-eastlake-fnv-14</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fnv1a_32 = Fnv1a(<span class="tok-type">u32</span>, <span class="tok-number">0x01000193</span>, <span class="tok-number">0x811c9dc5</span>);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fnv1a_64 = Fnv1a(<span class="tok-type">u64</span>, <span class="tok-number">0x100000001b3</span>, <span class="tok-number">0xcbf29ce484222325</span>);</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fnv1a_128 = Fnv1a(<span class="tok-type">u128</span>, <span class="tok-number">0x1000000000000000000013b</span>, <span class="tok-number">0x6c62272e07bb014262b821756295c58d</span>);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">fn</span> <span class="tok-fn">Fnv1a</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> prime: T, <span class="tok-kw">comptime</span> offset: T) <span class="tok-type">type</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        value: T,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Self {</span>
<span class="line" id="L21">            <span class="tok-kw">return</span> Self{ .value = offset };</span>
<span class="line" id="L22">        }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L25">            <span class="tok-kw">for</span> (input) |b| {</span>
<span class="line" id="L26">                self.value ^= b;</span>
<span class="line" id="L27">                self.value *%= prime;</span>
<span class="line" id="L28">            }</span>
<span class="line" id="L29">        }</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Self) T {</span>
<span class="line" id="L32">            <span class="tok-kw">return</span> self.value;</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) T {</span>
<span class="line" id="L36">            <span class="tok-kw">var</span> c = Self.init();</span>
<span class="line" id="L37">            c.update(input);</span>
<span class="line" id="L38">            <span class="tok-kw">return</span> c.final();</span>
<span class="line" id="L39">        }</span>
<span class="line" id="L40">    };</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-kw">test</span> <span class="tok-str">&quot;fnv1a-32&quot;</span> {</span>
<span class="line" id="L44">    <span class="tok-kw">try</span> testing.expect(Fnv1a_32.hash(<span class="tok-str">&quot;&quot;</span>) == <span class="tok-number">0x811c9dc5</span>);</span>
<span class="line" id="L45">    <span class="tok-kw">try</span> testing.expect(Fnv1a_32.hash(<span class="tok-str">&quot;a&quot;</span>) == <span class="tok-number">0xe40c292c</span>);</span>
<span class="line" id="L46">    <span class="tok-kw">try</span> testing.expect(Fnv1a_32.hash(<span class="tok-str">&quot;foobar&quot;</span>) == <span class="tok-number">0xbf9cf968</span>);</span>
<span class="line" id="L47">}</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">test</span> <span class="tok-str">&quot;fnv1a-64&quot;</span> {</span>
<span class="line" id="L50">    <span class="tok-kw">try</span> testing.expect(Fnv1a_64.hash(<span class="tok-str">&quot;&quot;</span>) == <span class="tok-number">0xcbf29ce484222325</span>);</span>
<span class="line" id="L51">    <span class="tok-kw">try</span> testing.expect(Fnv1a_64.hash(<span class="tok-str">&quot;a&quot;</span>) == <span class="tok-number">0xaf63dc4c8601ec8c</span>);</span>
<span class="line" id="L52">    <span class="tok-kw">try</span> testing.expect(Fnv1a_64.hash(<span class="tok-str">&quot;foobar&quot;</span>) == <span class="tok-number">0x85944171f73967e8</span>);</span>
<span class="line" id="L53">}</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-kw">test</span> <span class="tok-str">&quot;fnv1a-128&quot;</span> {</span>
<span class="line" id="L56">    <span class="tok-kw">try</span> testing.expect(Fnv1a_128.hash(<span class="tok-str">&quot;&quot;</span>) == <span class="tok-number">0x6c62272e07bb014262b821756295c58d</span>);</span>
<span class="line" id="L57">    <span class="tok-kw">try</span> testing.expect(Fnv1a_128.hash(<span class="tok-str">&quot;a&quot;</span>) == <span class="tok-number">0xd228cb696f1a8caf78912b704e4a8964</span>);</span>
<span class="line" id="L58">}</span>
<span class="line" id="L59"></span>
</code></pre></body>
</html>