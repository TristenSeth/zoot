<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/chacha20.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Based on public domain Supercop by Daniel J. Bernstein</span>
</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> maxInt = math.maxInt;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Poly1305 = std.crypto.onetimeauth.Poly1305;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> AuthenticationError = std.crypto.errors.AuthenticationError;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-comment">/// IETF-variant of the ChaCha20 stream cipher, as designed for TLS.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha20IETF = ChaChaIETF(<span class="tok-number">20</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// IETF-variant of the ChaCha20 stream cipher, reduced to 12 rounds.</span></span>
<span class="line" id="L17"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L18"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha12IETF = ChaChaIETF(<span class="tok-number">12</span>);</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">/// IETF-variant of the ChaCha20 stream cipher, reduced to 8 rounds.</span></span>
<span class="line" id="L22"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L23"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha8IETF = ChaChaIETF(<span class="tok-number">8</span>);</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// Original ChaCha20 stream cipher.</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha20With64BitNonce = ChaChaWith64BitNonce(<span class="tok-number">20</span>);</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// Original ChaCha20 stream cipher, reduced to 12 rounds.</span></span>
<span class="line" id="L30"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L31"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha12With64BitNonce = ChaChaWith64BitNonce(<span class="tok-number">12</span>);</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// Original ChaCha20 stream cipher, reduced to 8 rounds.</span></span>
<span class="line" id="L35"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L36"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha8With64BitNonce = ChaChaWith64BitNonce(<span class="tok-number">8</span>);</span>
<span class="line" id="L38"></span>
<span class="line" id="L39"><span class="tok-comment">/// XChaCha20 (nonce-extended version of the IETF ChaCha20 variant) stream cipher</span></span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha20IETF = XChaChaIETF(<span class="tok-number">20</span>);</span>
<span class="line" id="L41"></span>
<span class="line" id="L42"><span class="tok-comment">/// XChaCha20 (nonce-extended version of the IETF ChaCha20 variant) stream cipher, reduced to 12 rounds</span></span>
<span class="line" id="L43"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L44"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha12IETF = XChaChaIETF(<span class="tok-number">12</span>);</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-comment">/// XChaCha20 (nonce-extended version of the IETF ChaCha20 variant) stream cipher, reduced to 8 rounds</span></span>
<span class="line" id="L48"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L49"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha8IETF = XChaChaIETF(<span class="tok-number">8</span>);</span>
<span class="line" id="L51"></span>
<span class="line" id="L52"><span class="tok-comment">/// ChaCha20-Poly1305 authenticated cipher, as designed for TLS</span></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha20Poly1305 = ChaChaPoly1305(<span class="tok-number">20</span>);</span>
<span class="line" id="L54"></span>
<span class="line" id="L55"><span class="tok-comment">/// ChaCha20-Poly1305 authenticated cipher, reduced to 12 rounds</span></span>
<span class="line" id="L56"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L57"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha12Poly1305 = ChaChaPoly1305(<span class="tok-number">12</span>);</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-comment">/// ChaCha20-Poly1305 authenticated cipher, reduced to 8 rounds</span></span>
<span class="line" id="L61"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L62"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChaCha8Poly1305 = ChaChaPoly1305(<span class="tok-number">8</span>);</span>
<span class="line" id="L64"></span>
<span class="line" id="L65"><span class="tok-comment">/// XChaCha20-Poly1305 authenticated cipher</span></span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha20Poly1305 = XChaChaPoly1305(<span class="tok-number">20</span>);</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-comment">/// XChaCha20-Poly1305 authenticated cipher</span></span>
<span class="line" id="L69"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L70"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha12Poly1305 = XChaChaPoly1305(<span class="tok-number">12</span>);</span>
<span class="line" id="L72"></span>
<span class="line" id="L73"><span class="tok-comment">/// XChaCha20-Poly1305 authenticated cipher</span></span>
<span class="line" id="L74"><span class="tok-comment">/// Reduced-rounds versions are faster than the full-round version, but have a lower security margin.</span></span>
<span class="line" id="L75"><span class="tok-comment">/// However, ChaCha is still believed to have a comfortable security even with only with 8 rounds.</span></span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XChaCha8Poly1305 = XChaChaPoly1305(<span class="tok-number">8</span>);</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-comment">// Vectorized implementation of the core function</span>
</span>
<span class="line" id="L79"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaVecImpl</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L80">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> Lane = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> BlockVec = [<span class="tok-number">4</span>]Lane;</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) BlockVec {</span>
<span class="line" id="L85">            <span class="tok-kw">const</span> c = <span class="tok-str">&quot;expand 32-byte k&quot;</span>;</span>
<span class="line" id="L86">            <span class="tok-kw">const</span> constant_le = <span class="tok-kw">comptime</span> Lane{</span>
<span class="line" id="L87">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">0</span>..<span class="tok-number">4</span>]),</span>
<span class="line" id="L88">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">4</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L89">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">8</span>..<span class="tok-number">12</span>]),</span>
<span class="line" id="L90">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">12</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L91">            };</span>
<span class="line" id="L92">            <span class="tok-kw">return</span> BlockVec{</span>
<span class="line" id="L93">                constant_le,</span>
<span class="line" id="L94">                Lane{ key[<span class="tok-number">0</span>], key[<span class="tok-number">1</span>], key[<span class="tok-number">2</span>], key[<span class="tok-number">3</span>] },</span>
<span class="line" id="L95">                Lane{ key[<span class="tok-number">4</span>], key[<span class="tok-number">5</span>], key[<span class="tok-number">6</span>], key[<span class="tok-number">7</span>] },</span>
<span class="line" id="L96">                Lane{ d[<span class="tok-number">0</span>], d[<span class="tok-number">1</span>], d[<span class="tok-number">2</span>], d[<span class="tok-number">3</span>] },</span>
<span class="line" id="L97">            };</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">chacha20Core</span>(x: *BlockVec, input: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L101">            x.* = input;</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">            <span class="tok-kw">var</span> r: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L104">            <span class="tok-kw">while</span> (r &lt; rounds_nb) : (r += <span class="tok-number">2</span>) {</span>
<span class="line" id="L105">                x[<span class="tok-number">0</span>] +%= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L106">                x[<span class="tok-number">3</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L107">                x[<span class="tok-number">3</span>] = math.rotl(Lane, x[<span class="tok-number">3</span>], <span class="tok-number">16</span>);</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">                x[<span class="tok-number">2</span>] +%= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L110">                x[<span class="tok-number">1</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L111">                x[<span class="tok-number">1</span>] = math.rotl(Lane, x[<span class="tok-number">1</span>], <span class="tok-number">12</span>);</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">                x[<span class="tok-number">0</span>] +%= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L114">                x[<span class="tok-number">3</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L115">                x[<span class="tok-number">0</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">0</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L116">                x[<span class="tok-number">3</span>] = math.rotl(Lane, x[<span class="tok-number">3</span>], <span class="tok-number">8</span>);</span>
<span class="line" id="L117"></span>
<span class="line" id="L118">                x[<span class="tok-number">2</span>] +%= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L119">                x[<span class="tok-number">3</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">3</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L120">                x[<span class="tok-number">1</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L121">                x[<span class="tok-number">2</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">2</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L122">                x[<span class="tok-number">1</span>] = math.rotl(Lane, x[<span class="tok-number">1</span>], <span class="tok-number">7</span>);</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">                x[<span class="tok-number">0</span>] +%= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L125">                x[<span class="tok-number">3</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L126">                x[<span class="tok-number">3</span>] = math.rotl(Lane, x[<span class="tok-number">3</span>], <span class="tok-number">16</span>);</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">                x[<span class="tok-number">2</span>] +%= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L129">                x[<span class="tok-number">1</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L130">                x[<span class="tok-number">1</span>] = math.rotl(Lane, x[<span class="tok-number">1</span>], <span class="tok-number">12</span>);</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">                x[<span class="tok-number">0</span>] +%= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L133">                x[<span class="tok-number">3</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L134">                x[<span class="tok-number">0</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">0</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L135">                x[<span class="tok-number">3</span>] = math.rotl(Lane, x[<span class="tok-number">3</span>], <span class="tok-number">8</span>);</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">                x[<span class="tok-number">2</span>] +%= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L138">                x[<span class="tok-number">3</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">3</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L139">                x[<span class="tok-number">1</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L140">                x[<span class="tok-number">2</span>] = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, x[<span class="tok-number">2</span>], <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L141">                x[<span class="tok-number">1</span>] = math.rotl(Lane, x[<span class="tok-number">1</span>], <span class="tok-number">7</span>);</span>
<span class="line" id="L142">            }</span>
<span class="line" id="L143">        }</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashToBytes</span>(out: *[<span class="tok-number">64</span>]<span class="tok-type">u8</span>, x: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L146">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L147">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L148">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">0</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">0</span>]);</span>
<span class="line" id="L149">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">1</span>]);</span>
<span class="line" id="L150">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">2</span>]);</span>
<span class="line" id="L151">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">12</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">3</span>]);</span>
<span class="line" id="L152">            }</span>
<span class="line" id="L153">        }</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">contextFeedback</span>(x: *BlockVec, ctx: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L156">            x[<span class="tok-number">0</span>] +%= ctx[<span class="tok-number">0</span>];</span>
<span class="line" id="L157">            x[<span class="tok-number">1</span>] +%= ctx[<span class="tok-number">1</span>];</span>
<span class="line" id="L158">            x[<span class="tok-number">2</span>] +%= ctx[<span class="tok-number">2</span>];</span>
<span class="line" id="L159">            x[<span class="tok-number">3</span>] +%= ctx[<span class="tok-number">3</span>];</span>
<span class="line" id="L160">        }</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        <span class="tok-kw">fn</span> <span class="tok-fn">chacha20Xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, counter: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L163">            <span class="tok-kw">var</span> ctx = initContext(key, counter);</span>
<span class="line" id="L164">            <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L165">            <span class="tok-kw">var</span> buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L166">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L167">            <span class="tok-kw">while</span> (i + <span class="tok-number">64</span> &lt;= in.len) : (i += <span class="tok-number">64</span>) {</span>
<span class="line" id="L168">                chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L169">                contextFeedback(&amp;x, ctx);</span>
<span class="line" id="L170">                hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">                <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L173">                <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L174">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L175">                <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L176">                    xout[j] = xin[j];</span>
<span class="line" id="L177">                }</span>
<span class="line" id="L178">                j = <span class="tok-number">0</span>;</span>
<span class="line" id="L179">                <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L180">                    xout[j] ^= buf[j];</span>
<span class="line" id="L181">                }</span>
<span class="line" id="L182">                ctx[<span class="tok-number">3</span>][<span class="tok-number">0</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L183">            }</span>
<span class="line" id="L184">            <span class="tok-kw">if</span> (i &lt; in.len) {</span>
<span class="line" id="L185">                chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L186">                contextFeedback(&amp;x, ctx);</span>
<span class="line" id="L187">                hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">                <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L190">                <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L191">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L192">                <span class="tok-kw">while</span> (j &lt; in.len % <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L193">                    xout[j] = xin[j] ^ buf[j];</span>
<span class="line" id="L194">                }</span>
<span class="line" id="L195">            }</span>
<span class="line" id="L196">        }</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">        <span class="tok-kw">fn</span> <span class="tok-fn">hchacha20</span>(input: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L199">            <span class="tok-kw">var</span> c: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L200">            <span class="tok-kw">for</span> (c) |_, i| {</span>
<span class="line" id="L201">                c[i] = mem.readIntLittle(<span class="tok-type">u32</span>, input[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L202">            }</span>
<span class="line" id="L203">            <span class="tok-kw">const</span> ctx = initContext(keyToWords(key), c);</span>
<span class="line" id="L204">            <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L205">            chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L206">            <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L207">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[<span class="tok-number">0</span>][<span class="tok-number">0</span>]);</span>
<span class="line" id="L208">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span>..<span class="tok-number">8</span>], x[<span class="tok-number">0</span>][<span class="tok-number">1</span>]);</span>
<span class="line" id="L209">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">8</span>..<span class="tok-number">12</span>], x[<span class="tok-number">0</span>][<span class="tok-number">2</span>]);</span>
<span class="line" id="L210">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">12</span>..<span class="tok-number">16</span>], x[<span class="tok-number">0</span>][<span class="tok-number">3</span>]);</span>
<span class="line" id="L211">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span>..<span class="tok-number">20</span>], x[<span class="tok-number">3</span>][<span class="tok-number">0</span>]);</span>
<span class="line" id="L212">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">20</span>..<span class="tok-number">24</span>], x[<span class="tok-number">3</span>][<span class="tok-number">1</span>]);</span>
<span class="line" id="L213">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">24</span>..<span class="tok-number">28</span>], x[<span class="tok-number">3</span>][<span class="tok-number">2</span>]);</span>
<span class="line" id="L214">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">28</span>..<span class="tok-number">32</span>], x[<span class="tok-number">3</span>][<span class="tok-number">3</span>]);</span>
<span class="line" id="L215">            <span class="tok-kw">return</span> out;</span>
<span class="line" id="L216">        }</span>
<span class="line" id="L217">    };</span>
<span class="line" id="L218">}</span>
<span class="line" id="L219"></span>
<span class="line" id="L220"><span class="tok-comment">// Non-vectorized implementation of the core function</span>
</span>
<span class="line" id="L221"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaNonVecImpl</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L222">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L223">        <span class="tok-kw">const</span> BlockVec = [<span class="tok-number">16</span>]<span class="tok-type">u32</span>;</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">        <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) BlockVec {</span>
<span class="line" id="L226">            <span class="tok-kw">const</span> c = <span class="tok-str">&quot;expand 32-byte k&quot;</span>;</span>
<span class="line" id="L227">            <span class="tok-kw">const</span> constant_le = <span class="tok-kw">comptime</span> [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L228">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">0</span>..<span class="tok-number">4</span>]),</span>
<span class="line" id="L229">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">4</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L230">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">8</span>..<span class="tok-number">12</span>]),</span>
<span class="line" id="L231">                mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">12</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L232">            };</span>
<span class="line" id="L233">            <span class="tok-kw">return</span> BlockVec{</span>
<span class="line" id="L234">                constant_le[<span class="tok-number">0</span>], constant_le[<span class="tok-number">1</span>], constant_le[<span class="tok-number">2</span>], constant_le[<span class="tok-number">3</span>],</span>
<span class="line" id="L235">                key[<span class="tok-number">0</span>],         key[<span class="tok-number">1</span>],         key[<span class="tok-number">2</span>],         key[<span class="tok-number">3</span>],</span>
<span class="line" id="L236">                key[<span class="tok-number">4</span>],         key[<span class="tok-number">5</span>],         key[<span class="tok-number">6</span>],         key[<span class="tok-number">7</span>],</span>
<span class="line" id="L237">                d[<span class="tok-number">0</span>],           d[<span class="tok-number">1</span>],           d[<span class="tok-number">2</span>],           d[<span class="tok-number">3</span>],</span>
<span class="line" id="L238">            };</span>
<span class="line" id="L239">        }</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">        <span class="tok-kw">const</span> QuarterRound = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L242">            a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L243">            b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L244">            c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L245">            d: <span class="tok-type">usize</span>,</span>
<span class="line" id="L246">        };</span>
<span class="line" id="L247"></span>
<span class="line" id="L248">        <span class="tok-kw">fn</span> <span class="tok-fn">Rp</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>) QuarterRound {</span>
<span class="line" id="L249">            <span class="tok-kw">return</span> QuarterRound{</span>
<span class="line" id="L250">                .a = a,</span>
<span class="line" id="L251">                .b = b,</span>
<span class="line" id="L252">                .c = c,</span>
<span class="line" id="L253">                .d = d,</span>
<span class="line" id="L254">            };</span>
<span class="line" id="L255">        }</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">chacha20Core</span>(x: *BlockVec, input: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L258">            x.* = input;</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">            <span class="tok-kw">const</span> rounds = <span class="tok-kw">comptime</span> [_]QuarterRound{</span>
<span class="line" id="L261">                Rp(<span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>),</span>
<span class="line" id="L262">                Rp(<span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L263">                Rp(<span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L264">                Rp(<span class="tok-number">3</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L265">                Rp(<span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L266">                Rp(<span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>),</span>
<span class="line" id="L267">                Rp(<span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L268">                Rp(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L269">            };</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L272">            <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (j &lt; rounds_nb) : (j += <span class="tok-number">2</span>) {</span>
<span class="line" id="L273">                <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rounds) |r| {</span>
<span class="line" id="L274">                    x[r.a] +%= x[r.b];</span>
<span class="line" id="L275">                    x[r.d] = math.rotl(<span class="tok-type">u32</span>, x[r.d] ^ x[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L276">                    x[r.c] +%= x[r.d];</span>
<span class="line" id="L277">                    x[r.b] = math.rotl(<span class="tok-type">u32</span>, x[r.b] ^ x[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">12</span>));</span>
<span class="line" id="L278">                    x[r.a] +%= x[r.b];</span>
<span class="line" id="L279">                    x[r.d] = math.rotl(<span class="tok-type">u32</span>, x[r.d] ^ x[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">8</span>));</span>
<span class="line" id="L280">                    x[r.c] +%= x[r.d];</span>
<span class="line" id="L281">                    x[r.b] = math.rotl(<span class="tok-type">u32</span>, x[r.b] ^ x[r.c], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>));</span>
<span class="line" id="L282">                }</span>
<span class="line" id="L283">            }</span>
<span class="line" id="L284">        }</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashToBytes</span>(out: *[<span class="tok-number">64</span>]<span class="tok-type">u8</span>, x: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L287">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L288">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L289">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">0</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i * <span class="tok-number">4</span> + <span class="tok-number">0</span>]);</span>
<span class="line" id="L290">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i * <span class="tok-number">4</span> + <span class="tok-number">1</span>]);</span>
<span class="line" id="L291">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i * <span class="tok-number">4</span> + <span class="tok-number">2</span>]);</span>
<span class="line" id="L292">                mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">12</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i * <span class="tok-number">4</span> + <span class="tok-number">3</span>]);</span>
<span class="line" id="L293">            }</span>
<span class="line" id="L294">        }</span>
<span class="line" id="L295"></span>
<span class="line" id="L296">        <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">contextFeedback</span>(x: *BlockVec, ctx: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L297">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L298">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L299">                x[i] +%= ctx[i];</span>
<span class="line" id="L300">            }</span>
<span class="line" id="L301">        }</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">        <span class="tok-kw">fn</span> <span class="tok-fn">chacha20Xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, counter: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L304">            <span class="tok-kw">var</span> ctx = initContext(key, counter);</span>
<span class="line" id="L305">            <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L306">            <span class="tok-kw">var</span> buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L307">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L308">            <span class="tok-kw">while</span> (i + <span class="tok-number">64</span> &lt;= in.len) : (i += <span class="tok-number">64</span>) {</span>
<span class="line" id="L309">                chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L310">                contextFeedback(&amp;x, ctx);</span>
<span class="line" id="L311">                hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">                <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L314">                <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L315">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L316">                <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L317">                    xout[j] = xin[j];</span>
<span class="line" id="L318">                }</span>
<span class="line" id="L319">                j = <span class="tok-number">0</span>;</span>
<span class="line" id="L320">                <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L321">                    xout[j] ^= buf[j];</span>
<span class="line" id="L322">                }</span>
<span class="line" id="L323">                ctx[<span class="tok-number">12</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L324">            }</span>
<span class="line" id="L325">            <span class="tok-kw">if</span> (i &lt; in.len) {</span>
<span class="line" id="L326">                chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L327">                contextFeedback(&amp;x, ctx);</span>
<span class="line" id="L328">                hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">                <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L331">                <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L332">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L333">                <span class="tok-kw">while</span> (j &lt; in.len % <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L334">                    xout[j] = xin[j] ^ buf[j];</span>
<span class="line" id="L335">                }</span>
<span class="line" id="L336">            }</span>
<span class="line" id="L337">        }</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">        <span class="tok-kw">fn</span> <span class="tok-fn">hchacha20</span>(input: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L340">            <span class="tok-kw">var</span> c: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L341">            <span class="tok-kw">for</span> (c) |_, i| {</span>
<span class="line" id="L342">                c[i] = mem.readIntLittle(<span class="tok-type">u32</span>, input[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L343">            }</span>
<span class="line" id="L344">            <span class="tok-kw">const</span> ctx = initContext(keyToWords(key), c);</span>
<span class="line" id="L345">            <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L346">            chacha20Core(x[<span class="tok-number">0</span>..], ctx);</span>
<span class="line" id="L347">            <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L348">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[<span class="tok-number">0</span>]);</span>
<span class="line" id="L349">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span>..<span class="tok-number">8</span>], x[<span class="tok-number">1</span>]);</span>
<span class="line" id="L350">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">8</span>..<span class="tok-number">12</span>], x[<span class="tok-number">2</span>]);</span>
<span class="line" id="L351">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">12</span>..<span class="tok-number">16</span>], x[<span class="tok-number">3</span>]);</span>
<span class="line" id="L352">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span>..<span class="tok-number">20</span>], x[<span class="tok-number">12</span>]);</span>
<span class="line" id="L353">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">20</span>..<span class="tok-number">24</span>], x[<span class="tok-number">13</span>]);</span>
<span class="line" id="L354">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">24</span>..<span class="tok-number">28</span>], x[<span class="tok-number">14</span>]);</span>
<span class="line" id="L355">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">28</span>..<span class="tok-number">32</span>], x[<span class="tok-number">15</span>]);</span>
<span class="line" id="L356">            <span class="tok-kw">return</span> out;</span>
<span class="line" id="L357">        }</span>
<span class="line" id="L358">    };</span>
<span class="line" id="L359">}</span>
<span class="line" id="L360"></span>
<span class="line" id="L361"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaImpl</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L362">    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (builtin.cpu.arch == .x86_64) ChaChaVecImpl(rounds_nb) <span class="tok-kw">else</span> ChaChaNonVecImpl(rounds_nb);</span>
<span class="line" id="L363">}</span>
<span class="line" id="L364"></span>
<span class="line" id="L365"><span class="tok-kw">fn</span> <span class="tok-fn">keyToWords</span>(key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L366">    <span class="tok-kw">var</span> k: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L367">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L368">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L369">        k[i] = mem.readIntLittle(<span class="tok-type">u32</span>, key[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L370">    }</span>
<span class="line" id="L371">    <span class="tok-kw">return</span> k;</span>
<span class="line" id="L372">}</span>
<span class="line" id="L373"></span>
<span class="line" id="L374"><span class="tok-kw">fn</span> <span class="tok-fn">extend</span>(key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">24</span>]<span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-kw">struct</span> { key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">12</span>]<span class="tok-type">u8</span> } {</span>
<span class="line" id="L375">    <span class="tok-kw">var</span> subnonce: [<span class="tok-number">12</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L376">    mem.set(<span class="tok-type">u8</span>, subnonce[<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L377">    mem.copy(<span class="tok-type">u8</span>, subnonce[<span class="tok-number">4</span>..], nonce[<span class="tok-number">16</span>..<span class="tok-number">24</span>]);</span>
<span class="line" id="L378">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L379">        .key = ChaChaImpl(rounds_nb).hchacha20(nonce[<span class="tok-number">0</span>..<span class="tok-number">16</span>].*, key),</span>
<span class="line" id="L380">        .nonce = subnonce,</span>
<span class="line" id="L381">    };</span>
<span class="line" id="L382">}</span>
<span class="line" id="L383"></span>
<span class="line" id="L384"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaIETF</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L385">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L386">        <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L387">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">12</span>;</span>
<span class="line" id="L388">        <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L389">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">        <span class="tok-comment">/// Add the output of the ChaCha20 stream cipher to `in` and stores the result into `out`.</span></span>
<span class="line" id="L392">        <span class="tok-comment">/// WARNING: This function doesn't provide authenticated encryption.</span></span>
<span class="line" id="L393">        <span class="tok-comment">/// Using the AEAD or one of the `box` versions is usually preferred.</span></span>
<span class="line" id="L394">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, counter: <span class="tok-type">u32</span>, key: [key_length]<span class="tok-type">u8</span>, nonce: [nonce_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L395">            assert(in.len == out.len);</span>
<span class="line" id="L396">            assert(in.len / <span class="tok-number">64</span> &lt;= (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">32</span> - <span class="tok-number">1</span>) - counter);</span>
<span class="line" id="L397"></span>
<span class="line" id="L398">            <span class="tok-kw">var</span> d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L399">            d[<span class="tok-number">0</span>] = counter;</span>
<span class="line" id="L400">            d[<span class="tok-number">1</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L401">            d[<span class="tok-number">2</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L402">            d[<span class="tok-number">3</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">8</span>..<span class="tok-number">12</span>]);</span>
<span class="line" id="L403">            ChaChaImpl(rounds_nb).chacha20Xor(out, in, keyToWords(key), d);</span>
<span class="line" id="L404">        }</span>
<span class="line" id="L405">    };</span>
<span class="line" id="L406">}</span>
<span class="line" id="L407"></span>
<span class="line" id="L408"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaWith64BitNonce</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L409">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L410">        <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L411">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">8</span>;</span>
<span class="line" id="L412">        <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L413">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L414"></span>
<span class="line" id="L415">        <span class="tok-comment">/// Add the output of the ChaCha20 stream cipher to `in` and stores the result into `out`.</span></span>
<span class="line" id="L416">        <span class="tok-comment">/// WARNING: This function doesn't provide authenticated encryption.</span></span>
<span class="line" id="L417">        <span class="tok-comment">/// Using the AEAD or one of the `box` versions is usually preferred.</span></span>
<span class="line" id="L418">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, counter: <span class="tok-type">u64</span>, key: [key_length]<span class="tok-type">u8</span>, nonce: [nonce_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L419">            assert(in.len == out.len);</span>
<span class="line" id="L420">            assert(in.len / <span class="tok-number">64</span> &lt;= (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">64</span> - <span class="tok-number">1</span>) - counter);</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">            <span class="tok-kw">var</span> cursor: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L423">            <span class="tok-kw">const</span> k = keyToWords(key);</span>
<span class="line" id="L424">            <span class="tok-kw">var</span> c: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L425">            c[<span class="tok-number">0</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter);</span>
<span class="line" id="L426">            c[<span class="tok-number">1</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L427">            c[<span class="tok-number">2</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L428">            c[<span class="tok-number">3</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">            <span class="tok-kw">const</span> block_length = (<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">6</span>);</span>
<span class="line" id="L431">            <span class="tok-comment">// The full block size is greater than the address space on a 32bit machine</span>
</span>
<span class="line" id="L432">            <span class="tok-kw">const</span> big_block = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) &gt; <span class="tok-number">4</span>) (block_length &lt;&lt; <span class="tok-number">32</span>) <span class="tok-kw">else</span> maxInt(<span class="tok-type">usize</span>);</span>
<span class="line" id="L433"></span>
<span class="line" id="L434">            <span class="tok-comment">// first partial big block</span>
</span>
<span class="line" id="L435">            <span class="tok-kw">if</span> (((<span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, maxInt(<span class="tok-type">u32</span>) - <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter)) + <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">6</span>) &lt; in.len) {</span>
<span class="line" id="L436">                ChaChaImpl(rounds_nb).chacha20Xor(out[cursor..big_block], in[cursor..big_block], k, c);</span>
<span class="line" id="L437">                cursor = big_block - cursor;</span>
<span class="line" id="L438">                c[<span class="tok-number">1</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L439">                <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) &gt; <span class="tok-number">4</span>) {</span>
<span class="line" id="L440">                    <span class="tok-comment">// A big block is giant: 256 GiB, but we can avoid this limitation</span>
</span>
<span class="line" id="L441">                    <span class="tok-kw">var</span> remaining_blocks: <span class="tok-type">u32</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, (in.len / big_block));</span>
<span class="line" id="L442">                    <span class="tok-kw">while</span> (remaining_blocks &gt; <span class="tok-number">0</span>) : (remaining_blocks -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L443">                        ChaChaImpl(rounds_nb).chacha20Xor(out[cursor .. cursor + big_block], in[cursor .. cursor + big_block], k, c);</span>
<span class="line" id="L444">                        c[<span class="tok-number">1</span>] += <span class="tok-number">1</span>; <span class="tok-comment">// upper 32-bit of counter, generic chacha20Xor() doesn't know about this.</span>
</span>
<span class="line" id="L445">                        cursor += big_block;</span>
<span class="line" id="L446">                    }</span>
<span class="line" id="L447">                }</span>
<span class="line" id="L448">            }</span>
<span class="line" id="L449">            ChaChaImpl(rounds_nb).chacha20Xor(out[cursor..], in[cursor..], k, c);</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451">    };</span>
<span class="line" id="L452">}</span>
<span class="line" id="L453"></span>
<span class="line" id="L454"><span class="tok-kw">fn</span> <span class="tok-fn">XChaChaIETF</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L455">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L456">        <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L457">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">24</span>;</span>
<span class="line" id="L458">        <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L459">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        <span class="tok-comment">/// Add the output of the XChaCha20 stream cipher to `in` and stores the result into `out`.</span></span>
<span class="line" id="L462">        <span class="tok-comment">/// WARNING: This function doesn't provide authenticated encryption.</span></span>
<span class="line" id="L463">        <span class="tok-comment">/// Using the AEAD or one of the `box` versions is usually preferred.</span></span>
<span class="line" id="L464">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, counter: <span class="tok-type">u32</span>, key: [key_length]<span class="tok-type">u8</span>, nonce: [nonce_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L465">            <span class="tok-kw">const</span> extended = extend(key, nonce, rounds_nb);</span>
<span class="line" id="L466">            ChaChaIETF(rounds_nb).xor(out, in, counter, extended.key, extended.nonce);</span>
<span class="line" id="L467">        }</span>
<span class="line" id="L468">    };</span>
<span class="line" id="L469">}</span>
<span class="line" id="L470"></span>
<span class="line" id="L471"><span class="tok-kw">fn</span> <span class="tok-fn">ChaChaPoly1305</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L473">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L474">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">12</span>;</span>
<span class="line" id="L475">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L476"></span>
<span class="line" id="L477">        <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L478">        <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L479">        <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L480">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L481">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L482">        <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L483">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L484">            assert(c.len == m.len);</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">            <span class="tok-kw">var</span> polyKey = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L487">            ChaChaIETF(rounds_nb).xor(polyKey[<span class="tok-number">0</span>..], polyKey[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, k, npub);</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">            ChaChaIETF(rounds_nb).xor(c[<span class="tok-number">0</span>..m.len], m, <span class="tok-number">1</span>, k, npub);</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">            <span class="tok-kw">var</span> mac = Poly1305.init(polyKey[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L492">            mac.update(ad);</span>
<span class="line" id="L493">            <span class="tok-kw">if</span> (ad.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L494">                <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L495">                <span class="tok-kw">const</span> padding = <span class="tok-number">16</span> - (ad.len % <span class="tok-number">16</span>);</span>
<span class="line" id="L496">                mac.update(zeros[<span class="tok-number">0</span>..padding]);</span>
<span class="line" id="L497">            }</span>
<span class="line" id="L498">            mac.update(c[<span class="tok-number">0</span>..m.len]);</span>
<span class="line" id="L499">            <span class="tok-kw">if</span> (m.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L500">                <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L501">                <span class="tok-kw">const</span> padding = <span class="tok-number">16</span> - (m.len % <span class="tok-number">16</span>);</span>
<span class="line" id="L502">                mac.update(zeros[<span class="tok-number">0</span>..padding]);</span>
<span class="line" id="L503">            }</span>
<span class="line" id="L504">            <span class="tok-kw">var</span> lens: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L505">            mem.writeIntLittle(<span class="tok-type">u64</span>, lens[<span class="tok-number">0</span>..<span class="tok-number">8</span>], ad.len);</span>
<span class="line" id="L506">            mem.writeIntLittle(<span class="tok-type">u64</span>, lens[<span class="tok-number">8</span>..<span class="tok-number">16</span>], m.len);</span>
<span class="line" id="L507">            mac.update(lens[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L508">            mac.final(tag);</span>
<span class="line" id="L509">        }</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">        <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L512">        <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L513">        <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L514">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L515">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L516">        <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L517">        <span class="tok-comment">/// NOTE: the check of the authentication tag is currently not done in constant time</span></span>
<span class="line" id="L518">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L519">            assert(c.len == m.len);</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">            <span class="tok-kw">var</span> polyKey = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L522">            ChaChaIETF(rounds_nb).xor(polyKey[<span class="tok-number">0</span>..], polyKey[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, k, npub);</span>
<span class="line" id="L523"></span>
<span class="line" id="L524">            <span class="tok-kw">var</span> mac = Poly1305.init(polyKey[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">            mac.update(ad);</span>
<span class="line" id="L527">            <span class="tok-kw">if</span> (ad.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L528">                <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L529">                <span class="tok-kw">const</span> padding = <span class="tok-number">16</span> - (ad.len % <span class="tok-number">16</span>);</span>
<span class="line" id="L530">                mac.update(zeros[<span class="tok-number">0</span>..padding]);</span>
<span class="line" id="L531">            }</span>
<span class="line" id="L532">            mac.update(c);</span>
<span class="line" id="L533">            <span class="tok-kw">if</span> (c.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L534">                <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L535">                <span class="tok-kw">const</span> padding = <span class="tok-number">16</span> - (c.len % <span class="tok-number">16</span>);</span>
<span class="line" id="L536">                mac.update(zeros[<span class="tok-number">0</span>..padding]);</span>
<span class="line" id="L537">            }</span>
<span class="line" id="L538">            <span class="tok-kw">var</span> lens: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L539">            mem.writeIntLittle(<span class="tok-type">u64</span>, lens[<span class="tok-number">0</span>..<span class="tok-number">8</span>], ad.len);</span>
<span class="line" id="L540">            mem.writeIntLittle(<span class="tok-type">u64</span>, lens[<span class="tok-number">8</span>..<span class="tok-number">16</span>], c.len);</span>
<span class="line" id="L541">            mac.update(lens[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L542">            <span class="tok-kw">var</span> computedTag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L543">            mac.final(computedTag[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L544"></span>
<span class="line" id="L545">            <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L546">            <span class="tok-kw">for</span> (computedTag) |_, i| {</span>
<span class="line" id="L547">                acc |= computedTag[i] ^ tag[i];</span>
<span class="line" id="L548">            }</span>
<span class="line" id="L549">            <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L550">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L551">            }</span>
<span class="line" id="L552">            ChaChaIETF(rounds_nb).xor(m[<span class="tok-number">0</span>..c.len], c, <span class="tok-number">1</span>, k, npub);</span>
<span class="line" id="L553">        }</span>
<span class="line" id="L554">    };</span>
<span class="line" id="L555">}</span>
<span class="line" id="L556"></span>
<span class="line" id="L557"><span class="tok-kw">fn</span> <span class="tok-fn">XChaChaPoly1305</span>(<span class="tok-kw">comptime</span> rounds_nb: <span class="tok-type">usize</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L558">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L559">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L560">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">24</span>;</span>
<span class="line" id="L561">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L562"></span>
<span class="line" id="L563">        <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L564">        <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L565">        <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L566">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L567">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L568">        <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L569">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L570">            <span class="tok-kw">const</span> extended = extend(k, npub, rounds_nb);</span>
<span class="line" id="L571">            <span class="tok-kw">return</span> ChaChaPoly1305(rounds_nb).encrypt(c, tag, m, ad, extended.nonce, extended.key);</span>
<span class="line" id="L572">        }</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">        <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L575">        <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L576">        <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L577">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L578">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L579">        <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L580">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L581">            <span class="tok-kw">const</span> extended = extend(k, npub, rounds_nb);</span>
<span class="line" id="L582">            <span class="tok-kw">return</span> ChaChaPoly1305(rounds_nb).decrypt(m, c, tag, ad, extended.nonce, extended.key);</span>
<span class="line" id="L583">        }</span>
<span class="line" id="L584">    };</span>
<span class="line" id="L585">}</span>
<span class="line" id="L586"></span>
<span class="line" id="L587"><span class="tok-kw">test</span> <span class="tok-str">&quot;chacha20 AEAD API&quot;</span> {</span>
<span class="line" id="L588">    <span class="tok-kw">const</span> aeads = [_]<span class="tok-type">type</span>{ ChaCha20Poly1305, XChaCha20Poly1305 };</span>
<span class="line" id="L589">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.&quot;</span>;</span>
<span class="line" id="L590">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;Additional data&quot;</span>;</span>
<span class="line" id="L591"></span>
<span class="line" id="L592">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (aeads) |aead| {</span>
<span class="line" id="L593">        <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{<span class="tok-number">69</span>} ** aead.key_length;</span>
<span class="line" id="L594">        <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** aead.nonce_length;</span>
<span class="line" id="L595">        <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L596">        <span class="tok-kw">var</span> tag: [aead.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L597">        <span class="tok-kw">var</span> out: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">        aead.encrypt(c[<span class="tok-number">0</span>..], tag[<span class="tok-number">0</span>..], m, ad, nonce, key);</span>
<span class="line" id="L600">        <span class="tok-kw">try</span> aead.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..], tag, ad[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L601">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..], m);</span>
<span class="line" id="L602">        c[<span class="tok-number">0</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L603">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, aead.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..], tag, ad[<span class="tok-number">0</span>..], nonce, key));</span>
<span class="line" id="L604">    }</span>
<span class="line" id="L605">}</span>
<span class="line" id="L606"></span>
<span class="line" id="L607"><span class="tok-comment">// https://tools.ietf.org/html/rfc7539#section-2.4.2</span>
</span>
<span class="line" id="L608"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector sunscreen&quot;</span> {</span>
<span class="line" id="L609">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L610">        <span class="tok-number">0x6e</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0x80</span>,</span>
<span class="line" id="L611">        <span class="tok-number">0x41</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x07</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x81</span>,</span>
<span class="line" id="L612">        <span class="tok-number">0xe9</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0xec</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xc2</span>,</span>
<span class="line" id="L613">        <span class="tok-number">0x0a</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x0b</span>,</span>
<span class="line" id="L614">        <span class="tok-number">0xf9</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0xab</span>,</span>
<span class="line" id="L615">        <span class="tok-number">0x8f</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0x57</span>,</span>
<span class="line" id="L616">        <span class="tok-number">0x16</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0xab</span>,</span>
<span class="line" id="L617">        <span class="tok-number">0x8f</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0xd8</span>,</span>
<span class="line" id="L618">        <span class="tok-number">0x07</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x61</span>,</span>
<span class="line" id="L619">        <span class="tok-number">0x56</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x5e</span>,</span>
<span class="line" id="L620">        <span class="tok-number">0x52</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x06</span>,</span>
<span class="line" id="L621">        <span class="tok-number">0x81</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L622">        <span class="tok-number">0x5a</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x5b</span>, <span class="tok-number">0xe6</span>,</span>
<span class="line" id="L623">        <span class="tok-number">0xb4</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0x42</span>,</span>
<span class="line" id="L624">        <span class="tok-number">0x87</span>, <span class="tok-number">0x4d</span>,</span>
<span class="line" id="L625">    };</span>
<span class="line" id="L626">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.&quot;</span>;</span>
<span class="line" id="L627">    <span class="tok-kw">var</span> result: [<span class="tok-number">114</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L628">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L629">        <span class="tok-number">0</span>,  <span class="tok-number">1</span>,  <span class="tok-number">2</span>,  <span class="tok-number">3</span>,  <span class="tok-number">4</span>,  <span class="tok-number">5</span>,  <span class="tok-number">6</span>,  <span class="tok-number">7</span>,</span>
<span class="line" id="L630">        <span class="tok-number">8</span>,  <span class="tok-number">9</span>,  <span class="tok-number">10</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>, <span class="tok-number">14</span>, <span class="tok-number">15</span>,</span>
<span class="line" id="L631">        <span class="tok-number">16</span>, <span class="tok-number">17</span>, <span class="tok-number">18</span>, <span class="tok-number">19</span>, <span class="tok-number">20</span>, <span class="tok-number">21</span>, <span class="tok-number">22</span>, <span class="tok-number">23</span>,</span>
<span class="line" id="L632">        <span class="tok-number">24</span>, <span class="tok-number">25</span>, <span class="tok-number">26</span>, <span class="tok-number">27</span>, <span class="tok-number">28</span>, <span class="tok-number">29</span>, <span class="tok-number">30</span>, <span class="tok-number">31</span>,</span>
<span class="line" id="L633">    };</span>
<span class="line" id="L634">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L635">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L636">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0x4a</span>,</span>
<span class="line" id="L637">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L638">    };</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">    ChaCha20IETF.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">1</span>, key, nonce);</span>
<span class="line" id="L641">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L642"></span>
<span class="line" id="L643">    <span class="tok-kw">var</span> m2: [<span class="tok-number">114</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L644">    ChaCha20IETF.xor(m2[<span class="tok-number">0</span>..], result[<span class="tok-number">0</span>..], <span class="tok-number">1</span>, key, nonce);</span>
<span class="line" id="L645">    <span class="tok-kw">try</span> testing.expect(mem.order(<span class="tok-type">u8</span>, m, &amp;m2) == .eq);</span>
<span class="line" id="L646">}</span>
<span class="line" id="L647"></span>
<span class="line" id="L648"><span class="tok-comment">// https://tools.ietf.org/html/draft-agl-tls-chacha20poly1305-04#section-7</span>
</span>
<span class="line" id="L649"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector 1&quot;</span> {</span>
<span class="line" id="L650">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L651">        <span class="tok-number">0x76</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x90</span>,</span>
<span class="line" id="L652">        <span class="tok-number">0x40</span>, <span class="tok-number">0x5d</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x28</span>,</span>
<span class="line" id="L653">        <span class="tok-number">0xbd</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x1a</span>,</span>
<span class="line" id="L654">        <span class="tok-number">0xa8</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0xcc</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0xc7</span>,</span>
<span class="line" id="L655">        <span class="tok-number">0xda</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x8d</span>,</span>
<span class="line" id="L656">        <span class="tok-number">0x77</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0xd8</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0x37</span>,</span>
<span class="line" id="L657">        <span class="tok-number">0x6a</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0xb8</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x1c</span>,</span>
<span class="line" id="L658">        <span class="tok-number">0xc3</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x86</span>,</span>
<span class="line" id="L659">    };</span>
<span class="line" id="L660">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L661">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L662">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L663">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L664">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L665">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L666">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L667">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L668">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L669">    };</span>
<span class="line" id="L670">    <span class="tok-kw">var</span> result: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L671">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L672">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L673">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L674">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L675">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L676">    };</span>
<span class="line" id="L677">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L678"></span>
<span class="line" id="L679">    ChaCha20With64BitNonce.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L680">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L681">}</span>
<span class="line" id="L682"></span>
<span class="line" id="L683"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector 2&quot;</span> {</span>
<span class="line" id="L684">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L685">        <span class="tok-number">0x45</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0x9f</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0x96</span>,</span>
<span class="line" id="L686">        <span class="tok-number">0xd7</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x96</span>,</span>
<span class="line" id="L687">        <span class="tok-number">0xeb</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x60</span>,</span>
<span class="line" id="L688">        <span class="tok-number">0x4f</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x41</span>,</span>
<span class="line" id="L689">        <span class="tok-number">0xbb</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0xea</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0xd2</span>,</span>
<span class="line" id="L690">        <span class="tok-number">0xa5</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x2c</span>,</span>
<span class="line" id="L691">        <span class="tok-number">0x53</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xea</span>, <span class="tok-number">0x81</span>,</span>
<span class="line" id="L692">        <span class="tok-number">0x7e</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0xae</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x63</span>,</span>
<span class="line" id="L693">    };</span>
<span class="line" id="L694">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L695">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L696">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L697">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L698">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L699">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L700">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L701">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L702">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L703">    };</span>
<span class="line" id="L704">    <span class="tok-kw">var</span> result: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L705">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L706">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L707">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L708">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L709">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>,</span>
<span class="line" id="L710">    };</span>
<span class="line" id="L711">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">    ChaCha20With64BitNonce.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L714">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L715">}</span>
<span class="line" id="L716"></span>
<span class="line" id="L717"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector 3&quot;</span> {</span>
<span class="line" id="L718">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L719">        <span class="tok-number">0xde</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0xba</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0xf5</span>,</span>
<span class="line" id="L720">        <span class="tok-number">0xe7</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x3a</span>,</span>
<span class="line" id="L721">        <span class="tok-number">0x0b</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0x13</span>,</span>
<span class="line" id="L722">        <span class="tok-number">0x4f</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x31</span>,</span>
<span class="line" id="L723">        <span class="tok-number">0xe8</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0xa7</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x45</span>,</span>
<span class="line" id="L724">        <span class="tok-number">0x27</span>, <span class="tok-number">0x21</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0x5b</span>,</span>
<span class="line" id="L725">        <span class="tok-number">0x52</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x3e</span>,</span>
<span class="line" id="L726">        <span class="tok-number">0x44</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0xe3</span>,</span>
<span class="line" id="L727">    };</span>
<span class="line" id="L728">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L729">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L730">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L731">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L732">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L733">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L734">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L735">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L736">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L737">    };</span>
<span class="line" id="L738">    <span class="tok-kw">var</span> result: [<span class="tok-number">60</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L739">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L740">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L741">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L742">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L743">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L744">    };</span>
<span class="line" id="L745">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> };</span>
<span class="line" id="L746"></span>
<span class="line" id="L747">    ChaCha20With64BitNonce.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L748">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L749">}</span>
<span class="line" id="L750"></span>
<span class="line" id="L751"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector 4&quot;</span> {</span>
<span class="line" id="L752">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L753">        <span class="tok-number">0xef</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0xfb</span>,</span>
<span class="line" id="L754">        <span class="tok-number">0xf5</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x80</span>,</span>
<span class="line" id="L755">        <span class="tok-number">0x09</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0xac</span>,</span>
<span class="line" id="L756">        <span class="tok-number">0x33</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x32</span>,</span>
<span class="line" id="L757">        <span class="tok-number">0x11</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x4c</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x3c</span>,</span>
<span class="line" id="L758">        <span class="tok-number">0xa8</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x54</span>,</span>
<span class="line" id="L759">        <span class="tok-number">0x5d</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x7d</span>,</span>
<span class="line" id="L760">        <span class="tok-number">0x6b</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0xb0</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0x58</span>, <span class="tok-number">0x6b</span>,</span>
<span class="line" id="L761">    };</span>
<span class="line" id="L762">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L763">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L764">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L765">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L766">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L767">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L768">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L769">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L770">        <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>,</span>
<span class="line" id="L771">    };</span>
<span class="line" id="L772">    <span class="tok-kw">var</span> result: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L773">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L774">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L775">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L776">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L777">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L778">    };</span>
<span class="line" id="L779">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> };</span>
<span class="line" id="L780"></span>
<span class="line" id="L781">    ChaCha20With64BitNonce.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L782">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L783">}</span>
<span class="line" id="L784"></span>
<span class="line" id="L785"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.chacha20 test vector 5&quot;</span> {</span>
<span class="line" id="L786">    <span class="tok-kw">const</span> expected_result = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L787">        <span class="tok-number">0xf7</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L788">        <span class="tok-number">0x82</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0x75</span>,</span>
<span class="line" id="L789">        <span class="tok-number">0x7f</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0x93</span>,</span>
<span class="line" id="L790">        <span class="tok-number">0xec</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0xac</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xc1</span>,</span>
<span class="line" id="L791">        <span class="tok-number">0x34</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x41</span>,</span>
<span class="line" id="L792">        <span class="tok-number">0x30</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L793">        <span class="tok-number">0x05</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0xea</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xf1</span>,</span>
<span class="line" id="L794">        <span class="tok-number">0x59</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x5c</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x1a</span>,</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">        <span class="tok-number">0x38</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0x94</span>,</span>
<span class="line" id="L797">        <span class="tok-number">0x1e</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x7c</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x66</span>,</span>
<span class="line" id="L798">        <span class="tok-number">0x89</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0x58</span>,</span>
<span class="line" id="L799">        <span class="tok-number">0x89</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xbd</span>,</span>
<span class="line" id="L800">        <span class="tok-number">0x9a</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x56</span>,</span>
<span class="line" id="L801">        <span class="tok-number">0x3e</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L802">        <span class="tok-number">0x09</span>, <span class="tok-number">0xa7</span>, <span class="tok-number">0xe7</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L803">        <span class="tok-number">0xf7</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x0e</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0xc7</span>,</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">        <span class="tok-number">0x9d</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x15</span>,</span>
<span class="line" id="L806">        <span class="tok-number">0x1b</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x50</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc3</span>,</span>
<span class="line" id="L807">        <span class="tok-number">0x85</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0x5a</span>,</span>
<span class="line" id="L808">        <span class="tok-number">0x97</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x25</span>,</span>
<span class="line" id="L809">        <span class="tok-number">0xd3</span>, <span class="tok-number">0xce</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0x56</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0xc5</span>,</span>
<span class="line" id="L810">        <span class="tok-number">0x07</span>, <span class="tok-number">0xb1</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L811">        <span class="tok-number">0x59</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0xc4</span>,</span>
<span class="line" id="L812">        <span class="tok-number">0xa6</span>, <span class="tok-number">0xea</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0xd7</span>,</span>
<span class="line" id="L813"></span>
<span class="line" id="L814">        <span class="tok-number">0x0e</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x79</span>,</span>
<span class="line" id="L815">        <span class="tok-number">0xe5</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x6a</span>,</span>
<span class="line" id="L816">        <span class="tok-number">0x1c</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x4c</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x6a</span>,</span>
<span class="line" id="L817">        <span class="tok-number">0x94</span>, <span class="tok-number">0xdf</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0xf2</span>,</span>
<span class="line" id="L818">        <span class="tok-number">0xcc</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0x7d</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0xaa</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0x7a</span>,</span>
<span class="line" id="L819">        <span class="tok-number">0xd0</span>, <span class="tok-number">0xf9</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x54</span>, <span class="tok-number">0x09</span>,</span>
<span class="line" id="L820">        <span class="tok-number">0x87</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x7a</span>,</span>
<span class="line" id="L821">        <span class="tok-number">0x6d</span>, <span class="tok-number">0xeb</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0xb7</span>, <span class="tok-number">0x8f</span>, <span class="tok-number">0xab</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0xc9</span>,</span>
<span class="line" id="L822">    };</span>
<span class="line" id="L823">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L824">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L825">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L826">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L827">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L828">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L829">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L830">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L831">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L832"></span>
<span class="line" id="L833">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L834">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L835">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L836">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L837">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L838">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L839">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L840">        <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>,</span>
<span class="line" id="L841">    };</span>
<span class="line" id="L842">    <span class="tok-kw">var</span> result: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L843">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L844">        <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span>,</span>
<span class="line" id="L845">        <span class="tok-number">0x08</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x0e</span>, <span class="tok-number">0x0f</span>,</span>
<span class="line" id="L846">        <span class="tok-number">0x10</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x17</span>,</span>
<span class="line" id="L847">        <span class="tok-number">0x18</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x1f</span>,</span>
<span class="line" id="L848">    };</span>
<span class="line" id="L849">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L850">        <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span>,</span>
<span class="line" id="L851">    };</span>
<span class="line" id="L852"></span>
<span class="line" id="L853">    ChaCha20With64BitNonce.xor(result[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L854">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;expected_result, &amp;result);</span>
<span class="line" id="L855">}</span>
<span class="line" id="L856"></span>
<span class="line" id="L857"><span class="tok-kw">test</span> <span class="tok-str">&quot;seal&quot;</span> {</span>
<span class="line" id="L858">    {</span>
<span class="line" id="L859">        <span class="tok-kw">const</span> m = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L860">        <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L861">        <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L862">            <span class="tok-number">0x80</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x8f</span>,</span>
<span class="line" id="L863">            <span class="tok-number">0x90</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x9f</span>,</span>
<span class="line" id="L864">        };</span>
<span class="line" id="L865">        <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x47</span> };</span>
<span class="line" id="L866">        <span class="tok-kw">const</span> exp_out = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xa0</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x4</span> };</span>
<span class="line" id="L867"></span>
<span class="line" id="L868">        <span class="tok-kw">var</span> out: [exp_out.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L869">        ChaCha20Poly1305.encrypt(out[<span class="tok-number">0</span>..m.len], out[m.len..], m, ad, nonce, key);</span>
<span class="line" id="L870">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, exp_out[<span class="tok-number">0</span>..], out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L871">    }</span>
<span class="line" id="L872">    {</span>
<span class="line" id="L873">        <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L874">            <span class="tok-number">0x4c</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L875">            <span class="tok-number">0x65</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x73</span>,</span>
<span class="line" id="L876">            <span class="tok-number">0x73</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x63</span>,</span>
<span class="line" id="L877">            <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>,</span>
<span class="line" id="L878">            <span class="tok-number">0x6e</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x20</span>,</span>
<span class="line" id="L879">            <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x73</span>,</span>
<span class="line" id="L880">            <span class="tok-number">0x63</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L881">            <span class="tok-number">0x74</span>, <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L882">        };</span>
<span class="line" id="L883">        <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x50</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xc7</span> };</span>
<span class="line" id="L884">        <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L885">            <span class="tok-number">0x80</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x8f</span>,</span>
<span class="line" id="L886">            <span class="tok-number">0x90</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x9f</span>,</span>
<span class="line" id="L887">        };</span>
<span class="line" id="L888">        <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x47</span> };</span>
<span class="line" id="L889">        <span class="tok-kw">const</span> exp_out = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L890">            <span class="tok-number">0xd3</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xc2</span>,</span>
<span class="line" id="L891">            <span class="tok-number">0xa4</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xfe</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0xa7</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0xd6</span>,</span>
<span class="line" id="L892">            <span class="tok-number">0x3d</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x8b</span>,</span>
<span class="line" id="L893">            <span class="tok-number">0x1a</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x9e</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0xb</span>,  <span class="tok-number">0x29</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0xd6</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L894">            <span class="tok-number">0x92</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xae</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0x1b</span>, <span class="tok-number">0x58</span>,</span>
<span class="line" id="L895">            <span class="tok-number">0xfa</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0xbc</span>,</span>
<span class="line" id="L896">            <span class="tok-number">0x3f</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xce</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x4b</span>,</span>
<span class="line" id="L897">            <span class="tok-number">0x61</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0xb</span>,  <span class="tok-number">0x59</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0xe2</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0xd0</span>, <span class="tok-number">0x60</span>,</span>
<span class="line" id="L898">            <span class="tok-number">0x6</span>,  <span class="tok-number">0x91</span>,</span>
<span class="line" id="L899">        };</span>
<span class="line" id="L900"></span>
<span class="line" id="L901">        <span class="tok-kw">var</span> out: [exp_out.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L902">        ChaCha20Poly1305.encrypt(out[<span class="tok-number">0</span>..m.len], out[m.len..], m[<span class="tok-number">0</span>..], ad[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L903">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, exp_out[<span class="tok-number">0</span>..], out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L904">    }</span>
<span class="line" id="L905">}</span>
<span class="line" id="L906"></span>
<span class="line" id="L907"><span class="tok-kw">test</span> <span class="tok-str">&quot;open&quot;</span> {</span>
<span class="line" id="L908">    {</span>
<span class="line" id="L909">        <span class="tok-kw">const</span> c = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xa0</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xfe</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0x4e</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0x4</span> };</span>
<span class="line" id="L910">        <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L911">        <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L912">            <span class="tok-number">0x80</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x8f</span>,</span>
<span class="line" id="L913">            <span class="tok-number">0x90</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x9f</span>,</span>
<span class="line" id="L914">        };</span>
<span class="line" id="L915">        <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x47</span> };</span>
<span class="line" id="L916">        <span class="tok-kw">const</span> exp_out = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">        <span class="tok-kw">var</span> out: [exp_out.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L919">        <span class="tok-kw">try</span> ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..exp_out.len], c[exp_out.len..].*, ad[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L920">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, exp_out[<span class="tok-number">0</span>..], out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L921">    }</span>
<span class="line" id="L922">    {</span>
<span class="line" id="L923">        <span class="tok-kw">const</span> c = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L924">            <span class="tok-number">0xd3</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x34</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x7b</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xaf</span>, <span class="tok-number">0xbc</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xef</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xc2</span>,</span>
<span class="line" id="L925">            <span class="tok-number">0xa4</span>, <span class="tok-number">0xad</span>, <span class="tok-number">0xed</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x8</span>,  <span class="tok-number">0xfe</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0xa7</span>, <span class="tok-number">0x36</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0xd6</span>,</span>
<span class="line" id="L926">            <span class="tok-number">0x3d</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0x5e</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xfb</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0xda</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x8b</span>,</span>
<span class="line" id="L927">            <span class="tok-number">0x1a</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xa</span>,  <span class="tok-number">0x9e</span>, <span class="tok-number">0x6</span>,  <span class="tok-number">0xb</span>,  <span class="tok-number">0x29</span>, <span class="tok-number">0x5</span>,  <span class="tok-number">0xd6</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0x3b</span>, <span class="tok-number">0x36</span>,</span>
<span class="line" id="L928">            <span class="tok-number">0x92</span>, <span class="tok-number">0xdd</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x3</span>,  <span class="tok-number">0xae</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0x1b</span>, <span class="tok-number">0x58</span>,</span>
<span class="line" id="L929">            <span class="tok-number">0xfa</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xd6</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0xbc</span>,</span>
<span class="line" id="L930">            <span class="tok-number">0x3f</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x4b</span>, <span class="tok-number">0x7a</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xce</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0x4b</span>,</span>
<span class="line" id="L931">            <span class="tok-number">0x61</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0xb</span>,  <span class="tok-number">0x59</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x9</span>,  <span class="tok-number">0xe2</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x7e</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x2e</span>, <span class="tok-number">0xcb</span>, <span class="tok-number">0xd0</span>, <span class="tok-number">0x60</span>,</span>
<span class="line" id="L932">            <span class="tok-number">0x6</span>,  <span class="tok-number">0x91</span>,</span>
<span class="line" id="L933">        };</span>
<span class="line" id="L934">        <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x50</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0xc5</span>, <span class="tok-number">0xc6</span>, <span class="tok-number">0xc7</span> };</span>
<span class="line" id="L935">        <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L936">            <span class="tok-number">0x80</span>, <span class="tok-number">0x81</span>, <span class="tok-number">0x82</span>, <span class="tok-number">0x83</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x8e</span>, <span class="tok-number">0x8f</span>,</span>
<span class="line" id="L937">            <span class="tok-number">0x90</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x92</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x95</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x97</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x9b</span>, <span class="tok-number">0x9c</span>, <span class="tok-number">0x9d</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x9f</span>,</span>
<span class="line" id="L938">        };</span>
<span class="line" id="L939">        <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x41</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x46</span>, <span class="tok-number">0x47</span> };</span>
<span class="line" id="L940">        <span class="tok-kw">const</span> exp_out = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L941">            <span class="tok-number">0x4c</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x47</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L942">            <span class="tok-number">0x65</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x73</span>,</span>
<span class="line" id="L943">            <span class="tok-number">0x73</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x63</span>,</span>
<span class="line" id="L944">            <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>,</span>
<span class="line" id="L945">            <span class="tok-number">0x6e</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x70</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x20</span>,</span>
<span class="line" id="L946">            <span class="tok-number">0x74</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x66</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x2c</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x73</span>,</span>
<span class="line" id="L947">            <span class="tok-number">0x63</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x65</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x69</span>,</span>
<span class="line" id="L948">            <span class="tok-number">0x74</span>, <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L949">        };</span>
<span class="line" id="L950"></span>
<span class="line" id="L951">        <span class="tok-kw">var</span> out: [exp_out.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L952">        <span class="tok-kw">try</span> ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..exp_out.len], c[exp_out.len..].*, ad[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L953">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, exp_out[<span class="tok-number">0</span>..], out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L954"></span>
<span class="line" id="L955">        <span class="tok-comment">// corrupting the ciphertext, data, key, or nonce should cause a failure</span>
</span>
<span class="line" id="L956">        <span class="tok-kw">var</span> bad_c = c;</span>
<span class="line" id="L957">        bad_c[<span class="tok-number">0</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L958">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], bad_c[<span class="tok-number">0</span>..out.len], bad_c[out.len..].*, ad[<span class="tok-number">0</span>..], nonce, key));</span>
<span class="line" id="L959">        <span class="tok-kw">var</span> bad_ad = ad;</span>
<span class="line" id="L960">        bad_ad[<span class="tok-number">0</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L961">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..out.len], c[out.len..].*, bad_ad[<span class="tok-number">0</span>..], nonce, key));</span>
<span class="line" id="L962">        <span class="tok-kw">var</span> bad_key = key;</span>
<span class="line" id="L963">        bad_key[<span class="tok-number">0</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L964">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..out.len], c[out.len..].*, ad[<span class="tok-number">0</span>..], nonce, bad_key));</span>
<span class="line" id="L965">        <span class="tok-kw">var</span> bad_nonce = nonce;</span>
<span class="line" id="L966">        bad_nonce[<span class="tok-number">0</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L967">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, ChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..out.len], c[out.len..].*, ad[<span class="tok-number">0</span>..], bad_nonce, key));</span>
<span class="line" id="L968">    }</span>
<span class="line" id="L969">}</span>
<span class="line" id="L970"></span>
<span class="line" id="L971"><span class="tok-kw">test</span> <span class="tok-str">&quot;crypto.xchacha20&quot;</span> {</span>
<span class="line" id="L972">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{<span class="tok-number">69</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L973">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{<span class="tok-number">42</span>} ** <span class="tok-number">24</span>;</span>
<span class="line" id="L974">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.&quot;</span>;</span>
<span class="line" id="L975">    {</span>
<span class="line" id="L976">        <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L977">        XChaCha20IETF.xor(c[<span class="tok-number">0</span>..], m[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L978">        <span class="tok-kw">var</span> buf: [<span class="tok-number">2</span> * c.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L979">        <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;c)}), <span class="tok-str">&quot;E0A1BCF939654AFDBDC1746EC49832647C19D891F0D1A81FC0C1703B4514BDEA584B512F6908C2C5E9DD18D5CBC1805DE5803FE3B9CA5F193FB8359E91FAB0C3BB40309A292EB1CF49685C65C4A3ADF4F11DB0CD2B6B67FBC174BC2E860E8F769FD3565BBFAD1C845E05A0FED9BE167C240D&quot;</span>);</span>
<span class="line" id="L980">    }</span>
<span class="line" id="L981">    {</span>
<span class="line" id="L982">        <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;Additional data&quot;</span>;</span>
<span class="line" id="L983">        <span class="tok-kw">var</span> c: [m.len + XChaCha20Poly1305.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L984">        XChaCha20Poly1305.encrypt(c[<span class="tok-number">0</span>..m.len], c[m.len..], m, ad, nonce, key);</span>
<span class="line" id="L985">        <span class="tok-kw">var</span> out: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L986">        <span class="tok-kw">try</span> XChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..m.len], c[m.len..].*, ad, nonce, key);</span>
<span class="line" id="L987">        <span class="tok-kw">var</span> buf: [<span class="tok-number">2</span> * c.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L988">        <span class="tok-kw">try</span> testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;c)}), <span class="tok-str">&quot;994D2DD32333F48E53650C02C7A2ABB8E018B0836D7175AEC779F52E961780768F815C58F1AA52D211498DB89B9216763F569C9433A6BBFCEFB4D4A49387A4C5207FBB3B5A92B5941294DF30588C6740D39DC16FA1F0E634F7246CF7CDCB978E44347D89381B7A74EB7084F754B90BDE9AAF5A94B8F2A85EFD0B50692AE2D425E234&quot;</span>);</span>
<span class="line" id="L989">        <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, out[<span class="tok-number">0</span>..], m);</span>
<span class="line" id="L990">        c[<span class="tok-number">0</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L991">        <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, XChaCha20Poly1305.decrypt(out[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..m.len], c[m.len..].*, ad, nonce, key));</span>
<span class="line" id="L992">    }</span>
<span class="line" id="L993">}</span>
<span class="line" id="L994"></span>
</code></pre></body>
</html>