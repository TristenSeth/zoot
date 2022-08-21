<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/siphash.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// SipHash is a moderately fast pseudorandom function, returning a 64-bit or 128-bit tag for an arbitrary long input.</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// Typical use cases include:</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// - protection against DoS attacks for hash tables and bloom filters</span>
</span>
<span class="line" id="L6"><span class="tok-comment">// - authentication of short-lived messages in online protocols</span>
</span>
<span class="line" id="L7"><span class="tok-comment">//</span>
</span>
<span class="line" id="L8"><span class="tok-comment">// https://www.aumasson.jp/siphash/siphash.pdf</span>
</span>
<span class="line" id="L9"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-comment">/// SipHash function with 64-bit output.</span></span>
<span class="line" id="L16"><span class="tok-comment">///</span></span>
<span class="line" id="L17"><span class="tok-comment">/// Recommended parameters are:</span></span>
<span class="line" id="L18"><span class="tok-comment">/// - (c_rounds=4, d_rounds=8) for conservative security; regular hash functions such as BLAKE2 or BLAKE3 are usually a better alternative.</span></span>
<span class="line" id="L19"><span class="tok-comment">/// - (c_rounds=2, d_rounds=4) standard parameters.</span></span>
<span class="line" id="L20"><span class="tok-comment">/// - (c_rounds=1, d_rounds=3) reduced-round function. Faster, no known implications on its practical security level.</span></span>
<span class="line" id="L21"><span class="tok-comment">/// - (c_rounds=1, d_rounds=2) fastest option, but the output may be distinguishable from random data with related keys or non-uniform input - not suitable as a PRF.</span></span>
<span class="line" id="L22"><span class="tok-comment">///</span></span>
<span class="line" id="L23"><span class="tok-comment">/// SipHash is not a traditional hash function. If the input includes untrusted content, a secret key is absolutely necessary.</span></span>
<span class="line" id="L24"><span class="tok-comment">/// And due to its small output size, collisions in SipHash64 can be found with an exhaustive search.</span></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SipHash64</span>(<span class="tok-kw">comptime</span> c_rounds: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> d_rounds: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L26">    <span class="tok-kw">return</span> SipHash(<span class="tok-type">u64</span>, c_rounds, d_rounds);</span>
<span class="line" id="L27">}</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// SipHash function with 128-bit output.</span></span>
<span class="line" id="L30"><span class="tok-comment">///</span></span>
<span class="line" id="L31"><span class="tok-comment">/// Recommended parameters are:</span></span>
<span class="line" id="L32"><span class="tok-comment">/// - (c_rounds=4, d_rounds=8) for conservative security; regular hash functions such as BLAKE2 or BLAKE3 are usually a better alternative.</span></span>
<span class="line" id="L33"><span class="tok-comment">/// - (c_rounds=2, d_rounds=4) standard parameters.</span></span>
<span class="line" id="L34"><span class="tok-comment">/// - (c_rounds=1, d_rounds=4) reduced-round function. Recommended to hash very short, similar strings, when a 128-bit PRF output is still required.</span></span>
<span class="line" id="L35"><span class="tok-comment">/// - (c_rounds=1, d_rounds=3) reduced-round function. Faster, no known implications on its practical security level.</span></span>
<span class="line" id="L36"><span class="tok-comment">/// - (c_rounds=1, d_rounds=2) fastest option, but the output may be distinguishable from random data with related keys or non-uniform input - not suitable as a PRF.</span></span>
<span class="line" id="L37"><span class="tok-comment">///</span></span>
<span class="line" id="L38"><span class="tok-comment">/// SipHash is not a traditional hash function. If the input includes untrusted content, a secret key is absolutely necessary.</span></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">SipHash128</span>(<span class="tok-kw">comptime</span> c_rounds: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> d_rounds: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L40">    <span class="tok-kw">return</span> SipHash(<span class="tok-type">u128</span>, c_rounds, d_rounds);</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-kw">fn</span> <span class="tok-fn">SipHashStateless</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> c_rounds: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> d_rounds: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L44">    assert(T == <span class="tok-type">u64</span> <span class="tok-kw">or</span> T == <span class="tok-type">u128</span>);</span>
<span class="line" id="L45">    assert(c_rounds &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> d_rounds &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L49">        <span class="tok-kw">const</span> block_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L50">        <span class="tok-kw">const</span> digest_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L51">        <span class="tok-kw">const</span> key_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        v0: <span class="tok-type">u64</span>,</span>
<span class="line" id="L54">        v1: <span class="tok-type">u64</span>,</span>
<span class="line" id="L55">        v2: <span class="tok-type">u64</span>,</span>
<span class="line" id="L56">        v3: <span class="tok-type">u64</span>,</span>
<span class="line" id="L57">        msg_len: <span class="tok-type">u8</span>,</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: *<span class="tok-kw">const</span> [key_length]<span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L60">            <span class="tok-kw">const</span> k0 = mem.readIntLittle(<span class="tok-type">u64</span>, key[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L61">            <span class="tok-kw">const</span> k1 = mem.readIntLittle(<span class="tok-type">u64</span>, key[<span class="tok-number">8</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">            <span class="tok-kw">var</span> d = Self{</span>
<span class="line" id="L64">                .v0 = k0 ^ <span class="tok-number">0x736f6d6570736575</span>,</span>
<span class="line" id="L65">                .v1 = k1 ^ <span class="tok-number">0x646f72616e646f6d</span>,</span>
<span class="line" id="L66">                .v2 = k0 ^ <span class="tok-number">0x6c7967656e657261</span>,</span>
<span class="line" id="L67">                .v3 = k1 ^ <span class="tok-number">0x7465646279746573</span>,</span>
<span class="line" id="L68">                .msg_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L69">            };</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">            <span class="tok-kw">if</span> (T == <span class="tok-type">u128</span>) {</span>
<span class="line" id="L72">                d.v1 ^= <span class="tok-number">0xee</span>;</span>
<span class="line" id="L73">            }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">            <span class="tok-kw">return</span> d;</span>
<span class="line" id="L76">        }</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L79">            std.debug.assert(b.len % <span class="tok-number">8</span> == <span class="tok-number">0</span>);</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">            <span class="tok-kw">const</span> inl = std.builtin.CallOptions{ .modifier = .always_inline };</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L84">            <span class="tok-kw">while</span> (off &lt; b.len) : (off += <span class="tok-number">8</span>) {</span>
<span class="line" id="L85">                <span class="tok-kw">const</span> blob = b[off..][<span class="tok-number">0</span>..<span class="tok-number">8</span>].*;</span>
<span class="line" id="L86">                <span class="tok-builtin">@call</span>(inl, round, .{ self, blob });</span>
<span class="line" id="L87">            }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">            self.msg_len +%= <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, b.len);</span>
<span class="line" id="L90">        }</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) T {</span>
<span class="line" id="L93">            std.debug.assert(b.len &lt; <span class="tok-number">8</span>);</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">            self.msg_len +%= <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, b.len);</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">            <span class="tok-kw">var</span> buf = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L98">            mem.copy(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..], b[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L99">            buf[<span class="tok-number">7</span>] = self.msg_len;</span>
<span class="line" id="L100">            self.round(buf);</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">            <span class="tok-kw">if</span> (T == <span class="tok-type">u128</span>) {</span>
<span class="line" id="L103">                self.v2 ^= <span class="tok-number">0xee</span>;</span>
<span class="line" id="L104">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L105">                self.v2 ^= <span class="tok-number">0xff</span>;</span>
<span class="line" id="L106">            }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">            <span class="tok-comment">// TODO this is a workaround, should be able to supply the value without a separate variable</span>
</span>
<span class="line" id="L109">            <span class="tok-kw">const</span> inl = std.builtin.CallOptions{ .modifier = .always_inline };</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L112">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; d_rounds) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L113">                <span class="tok-builtin">@call</span>(inl, sipRound, .{self});</span>
<span class="line" id="L114">            }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">            <span class="tok-kw">const</span> b1 = self.v0 ^ self.v1 ^ self.v2 ^ self.v3;</span>
<span class="line" id="L117">            <span class="tok-kw">if</span> (T == <span class="tok-type">u64</span>) {</span>
<span class="line" id="L118">                <span class="tok-kw">return</span> b1;</span>
<span class="line" id="L119">            }</span>
<span class="line" id="L120"></span>
<span class="line" id="L121">            self.v1 ^= <span class="tok-number">0xdd</span>;</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L124">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; d_rounds) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L125">                <span class="tok-builtin">@call</span>(inl, sipRound, .{self});</span>
<span class="line" id="L126">            }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">            <span class="tok-kw">const</span> b2 = self.v0 ^ self.v1 ^ self.v2 ^ self.v3;</span>
<span class="line" id="L129">            <span class="tok-kw">return</span> (<span class="tok-builtin">@as</span>(<span class="tok-type">u128</span>, b2) &lt;&lt; <span class="tok-number">64</span>) | b1;</span>
<span class="line" id="L130">        }</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(self: *Self, b: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L133">            <span class="tok-kw">const</span> m = mem.readIntLittle(<span class="tok-type">u64</span>, b[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L134">            self.v3 ^= m;</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">            <span class="tok-comment">// TODO this is a workaround, should be able to supply the value without a separate variable</span>
</span>
<span class="line" id="L137">            <span class="tok-kw">const</span> inl = std.builtin.CallOptions{ .modifier = .always_inline };</span>
<span class="line" id="L138">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L139">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; c_rounds) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L140">                <span class="tok-builtin">@call</span>(inl, sipRound, .{self});</span>
<span class="line" id="L141">            }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">            self.v0 ^= m;</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">        <span class="tok-kw">fn</span> <span class="tok-fn">sipRound</span>(d: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L147">            d.v0 +%= d.v1;</span>
<span class="line" id="L148">            d.v1 = math.rotl(<span class="tok-type">u64</span>, d.v1, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">13</span>));</span>
<span class="line" id="L149">            d.v1 ^= d.v0;</span>
<span class="line" id="L150">            d.v0 = math.rotl(<span class="tok-type">u64</span>, d.v0, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">32</span>));</span>
<span class="line" id="L151">            d.v2 +%= d.v3;</span>
<span class="line" id="L152">            d.v3 = math.rotl(<span class="tok-type">u64</span>, d.v3, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L153">            d.v3 ^= d.v2;</span>
<span class="line" id="L154">            d.v0 +%= d.v3;</span>
<span class="line" id="L155">            d.v3 = math.rotl(<span class="tok-type">u64</span>, d.v3, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">21</span>));</span>
<span class="line" id="L156">            d.v3 ^= d.v0;</span>
<span class="line" id="L157">            d.v2 +%= d.v1;</span>
<span class="line" id="L158">            d.v1 = math.rotl(<span class="tok-type">u64</span>, d.v1, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">17</span>));</span>
<span class="line" id="L159">            d.v1 ^= d.v2;</span>
<span class="line" id="L160">            d.v2 = math.rotl(<span class="tok-type">u64</span>, d.v2, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">32</span>));</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: *<span class="tok-kw">const</span> [key_length]<span class="tok-type">u8</span>) T {</span>
<span class="line" id="L164">            <span class="tok-kw">const</span> aligned_len = msg.len - (msg.len % <span class="tok-number">8</span>);</span>
<span class="line" id="L165">            <span class="tok-kw">var</span> c = Self.init(key);</span>
<span class="line" id="L166">            <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, c.update, .{msg[<span class="tok-number">0</span>..aligned_len]});</span>
<span class="line" id="L167">            <span class="tok-kw">return</span> <span class="tok-builtin">@call</span>(.{ .modifier = .always_inline }, c.final, .{msg[aligned_len..]});</span>
<span class="line" id="L168">        }</span>
<span class="line" id="L169">    };</span>
<span class="line" id="L170">}</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-kw">fn</span> <span class="tok-fn">SipHash</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> c_rounds: <span class="tok-type">usize</span>, <span class="tok-kw">comptime</span> d_rounds: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L173">    assert(T == <span class="tok-type">u64</span> <span class="tok-kw">or</span> T == <span class="tok-type">u128</span>);</span>
<span class="line" id="L174">    assert(c_rounds &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> d_rounds &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L177">        <span class="tok-kw">const</span> State = SipHashStateless(T, c_rounds, d_rounds);</span>
<span class="line" id="L178">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L179">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L180">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> mac_length = <span class="tok-builtin">@sizeOf</span>(T);</span>
<span class="line" id="L181">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">8</span>;</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">        state: State,</span>
<span class="line" id="L184">        buf: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L185">        buf_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">        <span class="tok-comment">/// Initialize a state for a SipHash function</span></span>
<span class="line" id="L188">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: *<span class="tok-kw">const</span> [key_length]<span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L189">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L190">                .state = State.init(key),</span>
<span class="line" id="L191">                .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L192">                .buf_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L193">            };</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">        <span class="tok-comment">/// Add data to the state</span></span>
<span class="line" id="L197">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L198">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">            <span class="tok-kw">if</span> (self.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> self.buf_len + b.len &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L201">                off += <span class="tok-number">8</span> - self.buf_len;</span>
<span class="line" id="L202">                mem.copy(<span class="tok-type">u8</span>, self.buf[self.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L203">                self.state.update(self.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L204">                self.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L205">            }</span>
<span class="line" id="L206"></span>
<span class="line" id="L207">            <span class="tok-kw">const</span> remain_len = b.len - off;</span>
<span class="line" id="L208">            <span class="tok-kw">const</span> aligned_len = remain_len - (remain_len % <span class="tok-number">8</span>);</span>
<span class="line" id="L209">            self.state.update(b[off .. off + aligned_len]);</span>
<span class="line" id="L210"></span>
<span class="line" id="L211">            mem.copy(<span class="tok-type">u8</span>, self.buf[self.buf_len..], b[off + aligned_len ..]);</span>
<span class="line" id="L212">            self.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off + aligned_len ..].len);</span>
<span class="line" id="L213">        }</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">        <span class="tok-comment">/// Return an authentication tag for the current state</span></span>
<span class="line" id="L216">        <span class="tok-comment">/// Assumes `out` is less than or equal to `mac_length`.</span></span>
<span class="line" id="L217">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Self, out: *[mac_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L218">            mem.writeIntLittle(T, out, self.state.final(self.buf[<span class="tok-number">0</span>..self.buf_len]));</span>
<span class="line" id="L219">        }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">        <span class="tok-comment">/// Return an authentication tag for a message and a key</span></span>
<span class="line" id="L222">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(out: *[mac_length]<span class="tok-type">u8</span>, msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: *<span class="tok-kw">const</span> [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L223">            <span class="tok-kw">var</span> ctx = Self.init(key);</span>
<span class="line" id="L224">            ctx.update(msg);</span>
<span class="line" id="L225">            ctx.final(out);</span>
<span class="line" id="L226">        }</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">        <span class="tok-comment">/// Return an authentication tag for the current state, as an integer</span></span>
<span class="line" id="L229">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">finalInt</span>(self: *Self) T {</span>
<span class="line" id="L230">            <span class="tok-kw">return</span> self.state.final(self.buf[<span class="tok-number">0</span>..self.buf_len]);</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">        <span class="tok-comment">/// Return an authentication tag for a message and a key, as an integer</span></span>
<span class="line" id="L234">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toInt</span>(msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: *<span class="tok-kw">const</span> [key_length]<span class="tok-type">u8</span>) T {</span>
<span class="line" id="L235">            <span class="tok-kw">return</span> State.hash(msg, key);</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L239">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L242">            self.update(bytes);</span>
<span class="line" id="L243">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L244">        }</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L247">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L248">        }</span>
<span class="line" id="L249">    };</span>
<span class="line" id="L250">}</span>
<span class="line" id="L251"></span>
<span class="line" id="L252"><span class="tok-comment">// Test vectors from reference implementation.</span>
</span>
<span class="line" id="L253"><span class="tok-comment">// https://github.com/veorq/SipHash/blob/master/vectors.h</span>
</span>
<span class="line" id="L254"><span class="tok-kw">const</span> test_key = <span class="tok-str">&quot;\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f&quot;</span>;</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-kw">test</span> <span class="tok-str">&quot;siphash64-2-4 sanity&quot;</span> {</span>
<span class="line" id="L257">    <span class="tok-kw">const</span> vectors = [_][<span class="tok-number">8</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L258">        <span class="tok-str">&quot;\x31\x0e\x0e\xdd\x47\xdb\x6f\x72&quot;</span>.*, <span class="tok-comment">// &quot;&quot;</span>
</span>
<span class="line" id="L259">        <span class="tok-str">&quot;\xfd\x67\xdc\x93\xc5\x39\xf8\x74&quot;</span>.*, <span class="tok-comment">// &quot;\x00&quot;</span>
</span>
<span class="line" id="L260">        <span class="tok-str">&quot;\x5a\x4f\xa9\xd9\x09\x80\x6c\x0d&quot;</span>.*, <span class="tok-comment">// &quot;\x00\x01&quot; ... etc</span>
</span>
<span class="line" id="L261">        <span class="tok-str">&quot;\x2d\x7e\xfb\xd7\x96\x66\x67\x85&quot;</span>.*,</span>
<span class="line" id="L262">        <span class="tok-str">&quot;\xb7\x87\x71\x27\xe0\x94\x27\xcf&quot;</span>.*,</span>
<span class="line" id="L263">        <span class="tok-str">&quot;\x8d\xa6\x99\xcd\x64\x55\x76\x18&quot;</span>.*,</span>
<span class="line" id="L264">        <span class="tok-str">&quot;\xce\xe3\xfe\x58\x6e\x46\xc9\xcb&quot;</span>.*,</span>
<span class="line" id="L265">        <span class="tok-str">&quot;\x37\xd1\x01\x8b\xf5\x00\x02\xab&quot;</span>.*,</span>
<span class="line" id="L266">        <span class="tok-str">&quot;\x62\x24\x93\x9a\x79\xf5\xf5\x93&quot;</span>.*,</span>
<span class="line" id="L267">        <span class="tok-str">&quot;\xb0\xe4\xa9\x0b\xdf\x82\x00\x9e&quot;</span>.*,</span>
<span class="line" id="L268">        <span class="tok-str">&quot;\xf3\xb9\xdd\x94\xc5\xbb\x5d\x7a&quot;</span>.*,</span>
<span class="line" id="L269">        <span class="tok-str">&quot;\xa7\xad\x6b\x22\x46\x2f\xb3\xf4&quot;</span>.*,</span>
<span class="line" id="L270">        <span class="tok-str">&quot;\xfb\xe5\x0e\x86\xbc\x8f\x1e\x75&quot;</span>.*,</span>
<span class="line" id="L271">        <span class="tok-str">&quot;\x90\x3d\x84\xc0\x27\x56\xea\x14&quot;</span>.*,</span>
<span class="line" id="L272">        <span class="tok-str">&quot;\xee\xf2\x7a\x8e\x90\xca\x23\xf7&quot;</span>.*,</span>
<span class="line" id="L273">        <span class="tok-str">&quot;\xe5\x45\xbe\x49\x61\xca\x29\xa1&quot;</span>.*,</span>
<span class="line" id="L274">        <span class="tok-str">&quot;\xdb\x9b\xc2\x57\x7f\xcc\x2a\x3f&quot;</span>.*,</span>
<span class="line" id="L275">        <span class="tok-str">&quot;\x94\x47\xbe\x2c\xf5\xe9\x9a\x69&quot;</span>.*,</span>
<span class="line" id="L276">        <span class="tok-str">&quot;\x9c\xd3\x8d\x96\xf0\xb3\xc1\x4b&quot;</span>.*,</span>
<span class="line" id="L277">        <span class="tok-str">&quot;\xbd\x61\x79\xa7\x1d\xc9\x6d\xbb&quot;</span>.*,</span>
<span class="line" id="L278">        <span class="tok-str">&quot;\x98\xee\xa2\x1a\xf2\x5c\xd6\xbe&quot;</span>.*,</span>
<span class="line" id="L279">        <span class="tok-str">&quot;\xc7\x67\x3b\x2e\xb0\xcb\xf2\xd0&quot;</span>.*,</span>
<span class="line" id="L280">        <span class="tok-str">&quot;\x88\x3e\xa3\xe3\x95\x67\x53\x93&quot;</span>.*,</span>
<span class="line" id="L281">        <span class="tok-str">&quot;\xc8\xce\x5c\xcd\x8c\x03\x0c\xa8&quot;</span>.*,</span>
<span class="line" id="L282">        <span class="tok-str">&quot;\x94\xaf\x49\xf6\xc6\x50\xad\xb8&quot;</span>.*,</span>
<span class="line" id="L283">        <span class="tok-str">&quot;\xea\xb8\x85\x8a\xde\x92\xe1\xbc&quot;</span>.*,</span>
<span class="line" id="L284">        <span class="tok-str">&quot;\xf3\x15\xbb\x5b\xb8\x35\xd8\x17&quot;</span>.*,</span>
<span class="line" id="L285">        <span class="tok-str">&quot;\xad\xcf\x6b\x07\x63\x61\x2e\x2f&quot;</span>.*,</span>
<span class="line" id="L286">        <span class="tok-str">&quot;\xa5\xc9\x1d\xa7\xac\xaa\x4d\xde&quot;</span>.*,</span>
<span class="line" id="L287">        <span class="tok-str">&quot;\x71\x65\x95\x87\x66\x50\xa2\xa6&quot;</span>.*,</span>
<span class="line" id="L288">        <span class="tok-str">&quot;\x28\xef\x49\x5c\x53\xa3\x87\xad&quot;</span>.*,</span>
<span class="line" id="L289">        <span class="tok-str">&quot;\x42\xc3\x41\xd8\xfa\x92\xd8\x32&quot;</span>.*,</span>
<span class="line" id="L290">        <span class="tok-str">&quot;\xce\x7c\xf2\x72\x2f\x51\x27\x71&quot;</span>.*,</span>
<span class="line" id="L291">        <span class="tok-str">&quot;\xe3\x78\x59\xf9\x46\x23\xf3\xa7&quot;</span>.*,</span>
<span class="line" id="L292">        <span class="tok-str">&quot;\x38\x12\x05\xbb\x1a\xb0\xe0\x12&quot;</span>.*,</span>
<span class="line" id="L293">        <span class="tok-str">&quot;\xae\x97\xa1\x0f\xd4\x34\xe0\x15&quot;</span>.*,</span>
<span class="line" id="L294">        <span class="tok-str">&quot;\xb4\xa3\x15\x08\xbe\xff\x4d\x31&quot;</span>.*,</span>
<span class="line" id="L295">        <span class="tok-str">&quot;\x81\x39\x62\x29\xf0\x90\x79\x02&quot;</span>.*,</span>
<span class="line" id="L296">        <span class="tok-str">&quot;\x4d\x0c\xf4\x9e\xe5\xd4\xdc\xca&quot;</span>.*,</span>
<span class="line" id="L297">        <span class="tok-str">&quot;\x5c\x73\x33\x6a\x76\xd8\xbf\x9a&quot;</span>.*,</span>
<span class="line" id="L298">        <span class="tok-str">&quot;\xd0\xa7\x04\x53\x6b\xa9\x3e\x0e&quot;</span>.*,</span>
<span class="line" id="L299">        <span class="tok-str">&quot;\x92\x59\x58\xfc\xd6\x42\x0c\xad&quot;</span>.*,</span>
<span class="line" id="L300">        <span class="tok-str">&quot;\xa9\x15\xc2\x9b\xc8\x06\x73\x18&quot;</span>.*,</span>
<span class="line" id="L301">        <span class="tok-str">&quot;\x95\x2b\x79\xf3\xbc\x0a\xa6\xd4&quot;</span>.*,</span>
<span class="line" id="L302">        <span class="tok-str">&quot;\xf2\x1d\xf2\xe4\x1d\x45\x35\xf9&quot;</span>.*,</span>
<span class="line" id="L303">        <span class="tok-str">&quot;\x87\x57\x75\x19\x04\x8f\x53\xa9&quot;</span>.*,</span>
<span class="line" id="L304">        <span class="tok-str">&quot;\x10\xa5\x6c\xf5\xdf\xcd\x9a\xdb&quot;</span>.*,</span>
<span class="line" id="L305">        <span class="tok-str">&quot;\xeb\x75\x09\x5c\xcd\x98\x6c\xd0&quot;</span>.*,</span>
<span class="line" id="L306">        <span class="tok-str">&quot;\x51\xa9\xcb\x9e\xcb\xa3\x12\xe6&quot;</span>.*,</span>
<span class="line" id="L307">        <span class="tok-str">&quot;\x96\xaf\xad\xfc\x2c\xe6\x66\xc7&quot;</span>.*,</span>
<span class="line" id="L308">        <span class="tok-str">&quot;\x72\xfe\x52\x97\x5a\x43\x64\xee&quot;</span>.*,</span>
<span class="line" id="L309">        <span class="tok-str">&quot;\x5a\x16\x45\xb2\x76\xd5\x92\xa1&quot;</span>.*,</span>
<span class="line" id="L310">        <span class="tok-str">&quot;\xb2\x74\xcb\x8e\xbf\x87\x87\x0a&quot;</span>.*,</span>
<span class="line" id="L311">        <span class="tok-str">&quot;\x6f\x9b\xb4\x20\x3d\xe7\xb3\x81&quot;</span>.*,</span>
<span class="line" id="L312">        <span class="tok-str">&quot;\xea\xec\xb2\xa3\x0b\x22\xa8\x7f&quot;</span>.*,</span>
<span class="line" id="L313">        <span class="tok-str">&quot;\x99\x24\xa4\x3c\xc1\x31\x57\x24&quot;</span>.*,</span>
<span class="line" id="L314">        <span class="tok-str">&quot;\xbd\x83\x8d\x3a\xaf\xbf\x8d\xb7&quot;</span>.*,</span>
<span class="line" id="L315">        <span class="tok-str">&quot;\x0b\x1a\x2a\x32\x65\xd5\x1a\xea&quot;</span>.*,</span>
<span class="line" id="L316">        <span class="tok-str">&quot;\x13\x50\x79\xa3\x23\x1c\xe6\x60&quot;</span>.*,</span>
<span class="line" id="L317">        <span class="tok-str">&quot;\x93\x2b\x28\x46\xe4\xd7\x06\x66&quot;</span>.*,</span>
<span class="line" id="L318">        <span class="tok-str">&quot;\xe1\x91\x5f\x5c\xb1\xec\xa4\x6c&quot;</span>.*,</span>
<span class="line" id="L319">        <span class="tok-str">&quot;\xf3\x25\x96\x5c\xa1\x6d\x62\x9f&quot;</span>.*,</span>
<span class="line" id="L320">        <span class="tok-str">&quot;\x57\x5f\xf2\x8e\x60\x38\x1b\xe5&quot;</span>.*,</span>
<span class="line" id="L321">        <span class="tok-str">&quot;\x72\x45\x06\xeb\x4c\x32\x8a\x95&quot;</span>.*,</span>
<span class="line" id="L322">    };</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">    <span class="tok-kw">const</span> siphash = SipHash64(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L327">    <span class="tok-kw">for</span> (vectors) |vector, i| {</span>
<span class="line" id="L328">        buffer[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">        <span class="tok-kw">var</span> out: [siphash.mac_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L331">        siphash.create(&amp;out, buffer[<span class="tok-number">0</span>..i], test_key);</span>
<span class="line" id="L332">        <span class="tok-kw">try</span> testing.expectEqual(out, vector);</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334">}</span>
<span class="line" id="L335"></span>
<span class="line" id="L336"><span class="tok-kw">test</span> <span class="tok-str">&quot;siphash128-2-4 sanity&quot;</span> {</span>
<span class="line" id="L337">    <span class="tok-kw">const</span> vectors = [_][<span class="tok-number">16</span>]<span class="tok-type">u8</span>{</span>
<span class="line" id="L338">        <span class="tok-str">&quot;\xa3\x81\x7f\x04\xba\x25\xa8\xe6\x6d\xf6\x72\x14\xc7\x55\x02\x93&quot;</span>.*,</span>
<span class="line" id="L339">        <span class="tok-str">&quot;\xda\x87\xc1\xd8\x6b\x99\xaf\x44\x34\x76\x59\x11\x9b\x22\xfc\x45&quot;</span>.*,</span>
<span class="line" id="L340">        <span class="tok-str">&quot;\x81\x77\x22\x8d\xa4\xa4\x5d\xc7\xfc\xa3\x8b\xde\xf6\x0a\xff\xe4&quot;</span>.*,</span>
<span class="line" id="L341">        <span class="tok-str">&quot;\x9c\x70\xb6\x0c\x52\x67\xa9\x4e\x5f\x33\xb6\xb0\x29\x85\xed\x51&quot;</span>.*,</span>
<span class="line" id="L342">        <span class="tok-str">&quot;\xf8\x81\x64\xc1\x2d\x9c\x8f\xaf\x7d\x0f\x6e\x7c\x7b\xcd\x55\x79&quot;</span>.*,</span>
<span class="line" id="L343">        <span class="tok-str">&quot;\x13\x68\x87\x59\x80\x77\x6f\x88\x54\x52\x7a\x07\x69\x0e\x96\x27&quot;</span>.*,</span>
<span class="line" id="L344">        <span class="tok-str">&quot;\x14\xee\xca\x33\x8b\x20\x86\x13\x48\x5e\xa0\x30\x8f\xd7\xa1\x5e&quot;</span>.*,</span>
<span class="line" id="L345">        <span class="tok-str">&quot;\xa1\xf1\xeb\xbe\xd8\xdb\xc1\x53\xc0\xb8\x4a\xa6\x1f\xf0\x82\x39&quot;</span>.*,</span>
<span class="line" id="L346">        <span class="tok-str">&quot;\x3b\x62\xa9\xba\x62\x58\xf5\x61\x0f\x83\xe2\x64\xf3\x14\x97\xb4&quot;</span>.*,</span>
<span class="line" id="L347">        <span class="tok-str">&quot;\x26\x44\x99\x06\x0a\xd9\xba\xab\xc4\x7f\x8b\x02\xbb\x6d\x71\xed&quot;</span>.*,</span>
<span class="line" id="L348">        <span class="tok-str">&quot;\x00\x11\x0d\xc3\x78\x14\x69\x56\xc9\x54\x47\xd3\xf3\xd0\xfb\xba&quot;</span>.*,</span>
<span class="line" id="L349">        <span class="tok-str">&quot;\x01\x51\xc5\x68\x38\x6b\x66\x77\xa2\xb4\xdc\x6f\x81\xe5\xdc\x18&quot;</span>.*,</span>
<span class="line" id="L350">        <span class="tok-str">&quot;\xd6\x26\xb2\x66\x90\x5e\xf3\x58\x82\x63\x4d\xf6\x85\x32\xc1\x25&quot;</span>.*,</span>
<span class="line" id="L351">        <span class="tok-str">&quot;\x98\x69\xe2\x47\xe9\xc0\x8b\x10\xd0\x29\x93\x4f\xc4\xb9\x52\xf7&quot;</span>.*,</span>
<span class="line" id="L352">        <span class="tok-str">&quot;\x31\xfc\xef\xac\x66\xd7\xde\x9c\x7e\xc7\x48\x5f\xe4\x49\x49\x02&quot;</span>.*,</span>
<span class="line" id="L353">        <span class="tok-str">&quot;\x54\x93\xe9\x99\x33\xb0\xa8\x11\x7e\x08\xec\x0f\x97\xcf\xc3\xd9&quot;</span>.*,</span>
<span class="line" id="L354">        <span class="tok-str">&quot;\x6e\xe2\xa4\xca\x67\xb0\x54\xbb\xfd\x33\x15\xbf\x85\x23\x05\x77&quot;</span>.*,</span>
<span class="line" id="L355">        <span class="tok-str">&quot;\x47\x3d\x06\xe8\x73\x8d\xb8\x98\x54\xc0\x66\xc4\x7a\xe4\x77\x40&quot;</span>.*,</span>
<span class="line" id="L356">        <span class="tok-str">&quot;\xa4\x26\xe5\xe4\x23\xbf\x48\x85\x29\x4d\xa4\x81\xfe\xae\xf7\x23&quot;</span>.*,</span>
<span class="line" id="L357">        <span class="tok-str">&quot;\x78\x01\x77\x31\xcf\x65\xfa\xb0\x74\xd5\x20\x89\x52\x51\x2e\xb1&quot;</span>.*,</span>
<span class="line" id="L358">        <span class="tok-str">&quot;\x9e\x25\xfc\x83\x3f\x22\x90\x73\x3e\x93\x44\xa5\xe8\x38\x39\xeb&quot;</span>.*,</span>
<span class="line" id="L359">        <span class="tok-str">&quot;\x56\x8e\x49\x5a\xbe\x52\x5a\x21\x8a\x22\x14\xcd\x3e\x07\x1d\x12&quot;</span>.*,</span>
<span class="line" id="L360">        <span class="tok-str">&quot;\x4a\x29\xb5\x45\x52\xd1\x6b\x9a\x46\x9c\x10\x52\x8e\xff\x0a\xae&quot;</span>.*,</span>
<span class="line" id="L361">        <span class="tok-str">&quot;\xc9\xd1\x84\xdd\xd5\xa9\xf5\xe0\xcf\x8c\xe2\x9a\x9a\xbf\x69\x1c&quot;</span>.*,</span>
<span class="line" id="L362">        <span class="tok-str">&quot;\x2d\xb4\x79\xae\x78\xbd\x50\xd8\x88\x2a\x8a\x17\x8a\x61\x32\xad&quot;</span>.*,</span>
<span class="line" id="L363">        <span class="tok-str">&quot;\x8e\xce\x5f\x04\x2d\x5e\x44\x7b\x50\x51\xb9\xea\xcb\x8d\x8f\x6f&quot;</span>.*,</span>
<span class="line" id="L364">        <span class="tok-str">&quot;\x9c\x0b\x53\xb4\xb3\xc3\x07\xe8\x7e\xae\xe0\x86\x78\x14\x1f\x66&quot;</span>.*,</span>
<span class="line" id="L365">        <span class="tok-str">&quot;\xab\xf2\x48\xaf\x69\xa6\xea\xe4\xbf\xd3\xeb\x2f\x12\x9e\xeb\x94&quot;</span>.*,</span>
<span class="line" id="L366">        <span class="tok-str">&quot;\x06\x64\xda\x16\x68\x57\x4b\x88\xb9\x35\xf3\x02\x73\x58\xae\xf4&quot;</span>.*,</span>
<span class="line" id="L367">        <span class="tok-str">&quot;\xaa\x4b\x9d\xc4\xbf\x33\x7d\xe9\x0c\xd4\xfd\x3c\x46\x7c\x6a\xb7&quot;</span>.*,</span>
<span class="line" id="L368">        <span class="tok-str">&quot;\xea\x5c\x7f\x47\x1f\xaf\x6b\xde\x2b\x1a\xd7\xd4\x68\x6d\x22\x87&quot;</span>.*,</span>
<span class="line" id="L369">        <span class="tok-str">&quot;\x29\x39\xb0\x18\x32\x23\xfa\xfc\x17\x23\xde\x4f\x52\xc4\x3d\x35&quot;</span>.*,</span>
<span class="line" id="L370">        <span class="tok-str">&quot;\x7c\x39\x56\xca\x5e\xea\xfc\x3e\x36\x3e\x9d\x55\x65\x46\xeb\x68&quot;</span>.*,</span>
<span class="line" id="L371">        <span class="tok-str">&quot;\x77\xc6\x07\x71\x46\xf0\x1c\x32\xb6\xb6\x9d\x5f\x4e\xa9\xff\xcf&quot;</span>.*,</span>
<span class="line" id="L372">        <span class="tok-str">&quot;\x37\xa6\x98\x6c\xb8\x84\x7e\xdf\x09\x25\xf0\xf1\x30\x9b\x54\xde&quot;</span>.*,</span>
<span class="line" id="L373">        <span class="tok-str">&quot;\xa7\x05\xf0\xe6\x9d\xa9\xa8\xf9\x07\x24\x1a\x2e\x92\x3c\x8c\xc8&quot;</span>.*,</span>
<span class="line" id="L374">        <span class="tok-str">&quot;\x3d\xc4\x7d\x1f\x29\xc4\x48\x46\x1e\x9e\x76\xed\x90\x4f\x67\x11&quot;</span>.*,</span>
<span class="line" id="L375">        <span class="tok-str">&quot;\x0d\x62\xbf\x01\xe6\xfc\x0e\x1a\x0d\x3c\x47\x51\xc5\xd3\x69\x2b&quot;</span>.*,</span>
<span class="line" id="L376">        <span class="tok-str">&quot;\x8c\x03\x46\x8b\xca\x7c\x66\x9e\xe4\xfd\x5e\x08\x4b\xbe\xe7\xb5&quot;</span>.*,</span>
<span class="line" id="L377">        <span class="tok-str">&quot;\x52\x8a\x5b\xb9\x3b\xaf\x2c\x9c\x44\x73\xcc\xe5\xd0\xd2\x2b\xd9&quot;</span>.*,</span>
<span class="line" id="L378">        <span class="tok-str">&quot;\xdf\x6a\x30\x1e\x95\xc9\x5d\xad\x97\xae\x0c\xc8\xc6\x91\x3b\xd8&quot;</span>.*,</span>
<span class="line" id="L379">        <span class="tok-str">&quot;\x80\x11\x89\x90\x2c\x85\x7f\x39\xe7\x35\x91\x28\x5e\x70\xb6\xdb&quot;</span>.*,</span>
<span class="line" id="L380">        <span class="tok-str">&quot;\xe6\x17\x34\x6a\xc9\xc2\x31\xbb\x36\x50\xae\x34\xcc\xca\x0c\x5b&quot;</span>.*,</span>
<span class="line" id="L381">        <span class="tok-str">&quot;\x27\xd9\x34\x37\xef\xb7\x21\xaa\x40\x18\x21\xdc\xec\x5a\xdf\x89&quot;</span>.*,</span>
<span class="line" id="L382">        <span class="tok-str">&quot;\x89\x23\x7d\x9d\xed\x9c\x5e\x78\xd8\xb1\xc9\xb1\x66\xcc\x73\x42&quot;</span>.*,</span>
<span class="line" id="L383">        <span class="tok-str">&quot;\x4a\x6d\x80\x91\xbf\x5e\x7d\x65\x11\x89\xfa\x94\xa2\x50\xb1\x4c&quot;</span>.*,</span>
<span class="line" id="L384">        <span class="tok-str">&quot;\x0e\x33\xf9\x60\x55\xe7\xae\x89\x3f\xfc\x0e\x3d\xcf\x49\x29\x02&quot;</span>.*,</span>
<span class="line" id="L385">        <span class="tok-str">&quot;\xe6\x1c\x43\x2b\x72\x0b\x19\xd1\x8e\xc8\xd8\x4b\xdc\x63\x15\x1b&quot;</span>.*,</span>
<span class="line" id="L386">        <span class="tok-str">&quot;\xf7\xe5\xae\xf5\x49\xf7\x82\xcf\x37\x90\x55\xa6\x08\x26\x9b\x16&quot;</span>.*,</span>
<span class="line" id="L387">        <span class="tok-str">&quot;\x43\x8d\x03\x0f\xd0\xb7\xa5\x4f\xa8\x37\xf2\xad\x20\x1a\x64\x03&quot;</span>.*,</span>
<span class="line" id="L388">        <span class="tok-str">&quot;\xa5\x90\xd3\xee\x4f\xbf\x04\xe3\x24\x7e\x0d\x27\xf2\x86\x42\x3f&quot;</span>.*,</span>
<span class="line" id="L389">        <span class="tok-str">&quot;\x5f\xe2\xc1\xa1\x72\xfe\x93\xc4\xb1\x5c\xd3\x7c\xae\xf9\xf5\x38&quot;</span>.*,</span>
<span class="line" id="L390">        <span class="tok-str">&quot;\x2c\x97\x32\x5c\xbd\x06\xb3\x6e\xb2\x13\x3d\xd0\x8b\x3a\x01\x7c&quot;</span>.*,</span>
<span class="line" id="L391">        <span class="tok-str">&quot;\x92\xc8\x14\x22\x7a\x6b\xca\x94\x9f\xf0\x65\x9f\x00\x2a\xd3\x9e&quot;</span>.*,</span>
<span class="line" id="L392">        <span class="tok-str">&quot;\xdc\xe8\x50\x11\x0b\xd8\x32\x8c\xfb\xd5\x08\x41\xd6\x91\x1d\x87&quot;</span>.*,</span>
<span class="line" id="L393">        <span class="tok-str">&quot;\x67\xf1\x49\x84\xc7\xda\x79\x12\x48\xe3\x2b\xb5\x92\x25\x83\xda&quot;</span>.*,</span>
<span class="line" id="L394">        <span class="tok-str">&quot;\x19\x38\xf2\xcf\x72\xd5\x4e\xe9\x7e\x94\x16\x6f\xa9\x1d\x2a\x36&quot;</span>.*,</span>
<span class="line" id="L395">        <span class="tok-str">&quot;\x74\x48\x1e\x96\x46\xed\x49\xfe\x0f\x62\x24\x30\x16\x04\x69\x8e&quot;</span>.*,</span>
<span class="line" id="L396">        <span class="tok-str">&quot;\x57\xfc\xa5\xde\x98\xa9\xd6\xd8\x00\x64\x38\xd0\x58\x3d\x8a\x1d&quot;</span>.*,</span>
<span class="line" id="L397">        <span class="tok-str">&quot;\x9f\xec\xde\x1c\xef\xdc\x1c\xbe\xd4\x76\x36\x74\xd9\x57\x53\x59&quot;</span>.*,</span>
<span class="line" id="L398">        <span class="tok-str">&quot;\xe3\x04\x0c\x00\xeb\x28\xf1\x53\x66\xca\x73\xcb\xd8\x72\xe7\x40&quot;</span>.*,</span>
<span class="line" id="L399">        <span class="tok-str">&quot;\x76\x97\x00\x9a\x6a\x83\x1d\xfe\xcc\xa9\x1c\x59\x93\x67\x0f\x7a&quot;</span>.*,</span>
<span class="line" id="L400">        <span class="tok-str">&quot;\x58\x53\x54\x23\x21\xf5\x67\xa0\x05\xd5\x47\xa4\xf0\x47\x59\xbd&quot;</span>.*,</span>
<span class="line" id="L401">        <span class="tok-str">&quot;\x51\x50\xd1\x77\x2f\x50\x83\x4a\x50\x3e\x06\x9a\x97\x3f\xbd\x7c&quot;</span>.*,</span>
<span class="line" id="L402">    };</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">    <span class="tok-kw">const</span> siphash = SipHash128(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L407">    <span class="tok-kw">for</span> (vectors) |vector, i| {</span>
<span class="line" id="L408">        buffer[i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">        <span class="tok-kw">var</span> out: [siphash.mac_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L411">        siphash.create(&amp;out, buffer[<span class="tok-number">0</span>..i], test_key[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L412">        <span class="tok-kw">try</span> testing.expectEqual(out, vector);</span>
<span class="line" id="L413">    }</span>
<span class="line" id="L414">}</span>
<span class="line" id="L415"></span>
<span class="line" id="L416"><span class="tok-kw">test</span> <span class="tok-str">&quot;iterative non-divisible update&quot;</span> {</span>
<span class="line" id="L417">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L418">    <span class="tok-kw">for</span> (buf) |*e, i| {</span>
<span class="line" id="L419">        e.* = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, i);</span>
<span class="line" id="L420">    }</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">    <span class="tok-kw">const</span> key = <span class="tok-str">&quot;0x128dad08f12307&quot;</span>;</span>
<span class="line" id="L423">    <span class="tok-kw">const</span> Siphash = SipHash64(<span class="tok-number">2</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">    <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = <span class="tok-number">9</span>;</span>
<span class="line" id="L426">    <span class="tok-kw">while</span> (end &lt; buf.len) : (end += <span class="tok-number">9</span>) {</span>
<span class="line" id="L427">        <span class="tok-kw">const</span> non_iterative_hash = Siphash.toInt(buf[<span class="tok-number">0</span>..end], key[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">        <span class="tok-kw">var</span> siphash = Siphash.init(key);</span>
<span class="line" id="L430">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L431">        <span class="tok-kw">while</span> (i &lt; end) : (i += <span class="tok-number">7</span>) {</span>
<span class="line" id="L432">            siphash.update(buf[i..std.math.min(i + <span class="tok-number">7</span>, end)]);</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434">        <span class="tok-kw">const</span> iterative_hash = siphash.finalInt();</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">        <span class="tok-kw">try</span> std.testing.expectEqual(iterative_hash, non_iterative_hash);</span>
<span class="line" id="L437">    }</span>
<span class="line" id="L438">}</span>
<span class="line" id="L439"></span>
</code></pre></body>
</html>