<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/aes_ocb.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> aes = crypto.core.aes;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> AuthenticationError = crypto.errors.AuthenticationError;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aes128Ocb = AesOcb(aes.Aes128);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aes256Ocb = AesOcb(aes.Aes256);</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> Block = [<span class="tok-number">16</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-comment">/// AES-OCB (RFC 7253 - https://competitions.cr.yp.to/round3/ocbv11.pdf)</span></span>
<span class="line" id="L16"><span class="tok-kw">fn</span> <span class="tok-fn">AesOcb</span>(<span class="tok-kw">comptime</span> Aes: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L17">    <span class="tok-kw">const</span> EncryptCtx = aes.AesEncryptCtx(Aes);</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> DecryptCtx = aes.AesDecryptCtx(Aes);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L21">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = Aes.key_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L22">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length: <span class="tok-type">usize</span> = <span class="tok-number">12</span>;</span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length: <span class="tok-type">usize</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">        <span class="tok-kw">const</span> Lx = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L26">            star: Block <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L27">            dol: Block <span class="tok-kw">align</span>(<span class="tok-number">16</span>),</span>
<span class="line" id="L28">            table: [<span class="tok-number">56</span>]Block <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L29">            upto: <span class="tok-type">usize</span>,</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">            <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">double</span>(l: Block) Block {</span>
<span class="line" id="L32">                <span class="tok-kw">const</span> l_ = mem.readIntBig(<span class="tok-type">u128</span>, &amp;l);</span>
<span class="line" id="L33">                <span class="tok-kw">const</span> l_2 = (l_ &lt;&lt; <span class="tok-number">1</span>) ^ (<span class="tok-number">0x87</span> &amp; -%(l_ &gt;&gt; <span class="tok-number">127</span>));</span>
<span class="line" id="L34">                <span class="tok-kw">var</span> l2: Block = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L35">                mem.writeIntBig(<span class="tok-type">u128</span>, &amp;l2, l_2);</span>
<span class="line" id="L36">                <span class="tok-kw">return</span> l2;</span>
<span class="line" id="L37">            }</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">            <span class="tok-kw">fn</span> <span class="tok-fn">precomp</span>(lx: *Lx, upto: <span class="tok-type">usize</span>) []<span class="tok-kw">const</span> Block {</span>
<span class="line" id="L40">                <span class="tok-kw">const</span> table = &amp;lx.table;</span>
<span class="line" id="L41">                assert(upto &lt; table.len);</span>
<span class="line" id="L42">                <span class="tok-kw">var</span> i = lx.upto;</span>
<span class="line" id="L43">                <span class="tok-kw">while</span> (i + <span class="tok-number">1</span> &lt;= upto) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L44">                    table[i + <span class="tok-number">1</span>] = double(table[i]);</span>
<span class="line" id="L45">                }</span>
<span class="line" id="L46">                lx.upto = upto;</span>
<span class="line" id="L47">                <span class="tok-kw">return</span> lx.table[<span class="tok-number">0</span> .. upto + <span class="tok-number">1</span>];</span>
<span class="line" id="L48">            }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">            <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(aes_enc_ctx: EncryptCtx) Lx {</span>
<span class="line" id="L51">                <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L52">                <span class="tok-kw">var</span> star: Block = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L53">                aes_enc_ctx.encrypt(&amp;star, &amp;zeros);</span>
<span class="line" id="L54">                <span class="tok-kw">const</span> dol = double(star);</span>
<span class="line" id="L55">                <span class="tok-kw">var</span> lx = Lx{ .star = star, .dol = dol, .upto = <span class="tok-number">0</span> };</span>
<span class="line" id="L56">                lx.table[<span class="tok-number">0</span>] = double(dol);</span>
<span class="line" id="L57">                <span class="tok-kw">return</span> lx;</span>
<span class="line" id="L58">            }</span>
<span class="line" id="L59">        };</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(aes_enc_ctx: EncryptCtx, lx: *Lx, a: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Block {</span>
<span class="line" id="L62">            <span class="tok-kw">const</span> full_blocks: <span class="tok-type">usize</span> = a.len / <span class="tok-number">16</span>;</span>
<span class="line" id="L63">            <span class="tok-kw">const</span> x_max = <span class="tok-kw">if</span> (full_blocks &gt; <span class="tok-number">0</span>) math.log2_int(<span class="tok-type">usize</span>, full_blocks) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L64">            <span class="tok-kw">const</span> lt = lx.precomp(x_max);</span>
<span class="line" id="L65">            <span class="tok-kw">var</span> sum = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L66">            <span class="tok-kw">var</span> offset = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L67">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L68">            <span class="tok-kw">while</span> (i &lt; full_blocks) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L69">                xorWith(&amp;offset, lt[<span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">1</span>)]);</span>
<span class="line" id="L70">                <span class="tok-kw">var</span> e = xorBlocks(offset, a[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*);</span>
<span class="line" id="L71">                aes_enc_ctx.encrypt(&amp;e, &amp;e);</span>
<span class="line" id="L72">                xorWith(&amp;sum, e);</span>
<span class="line" id="L73">            }</span>
<span class="line" id="L74">            <span class="tok-kw">const</span> leftover = a.len % <span class="tok-number">16</span>;</span>
<span class="line" id="L75">            <span class="tok-kw">if</span> (leftover &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L76">                xorWith(&amp;offset, lx.star);</span>
<span class="line" id="L77">                <span class="tok-kw">var</span> padded = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L78">                mem.copy(<span class="tok-type">u8</span>, padded[<span class="tok-number">0</span>..leftover], a[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..leftover]);</span>
<span class="line" id="L79">                padded[leftover] = <span class="tok-number">1</span>;</span>
<span class="line" id="L80">                <span class="tok-kw">var</span> e = xorBlocks(offset, padded);</span>
<span class="line" id="L81">                aes_enc_ctx.encrypt(&amp;e, &amp;e);</span>
<span class="line" id="L82">                xorWith(&amp;sum, e);</span>
<span class="line" id="L83">            }</span>
<span class="line" id="L84">            <span class="tok-kw">return</span> sum;</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-kw">fn</span> <span class="tok-fn">getOffset</span>(aes_enc_ctx: EncryptCtx, npub: [nonce_length]<span class="tok-type">u8</span>) Block {</span>
<span class="line" id="L88">            <span class="tok-kw">var</span> nx = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L89">            nx[<span class="tok-number">0</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u7</span>, tag_length * <span class="tok-number">8</span>) &lt;&lt; <span class="tok-number">1</span>);</span>
<span class="line" id="L90">            nx[<span class="tok-number">16</span> - nonce_length - <span class="tok-number">1</span>] = <span class="tok-number">1</span>;</span>
<span class="line" id="L91">            mem.copy(<span class="tok-type">u8</span>, nx[<span class="tok-number">16</span> - nonce_length ..], &amp;npub);</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">            <span class="tok-kw">const</span> bottom = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u6</span>, nx[<span class="tok-number">15</span>]);</span>
<span class="line" id="L94">            nx[<span class="tok-number">15</span>] &amp;= <span class="tok-number">0xc0</span>;</span>
<span class="line" id="L95">            <span class="tok-kw">var</span> ktop_: Block = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L96">            aes_enc_ctx.encrypt(&amp;ktop_, &amp;nx);</span>
<span class="line" id="L97">            <span class="tok-kw">const</span> ktop = mem.readIntBig(<span class="tok-type">u128</span>, &amp;ktop_);</span>
<span class="line" id="L98">            <span class="tok-kw">var</span> stretch = (<span class="tok-builtin">@as</span>(<span class="tok-type">u192</span>, ktop) &lt;&lt; <span class="tok-number">64</span>) | <span class="tok-builtin">@as</span>(<span class="tok-type">u192</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, ktop &gt;&gt; <span class="tok-number">64</span>) ^ <span class="tok-builtin">@truncate</span>(<span class="tok-type">u64</span>, ktop &gt;&gt; <span class="tok-number">56</span>));</span>
<span class="line" id="L99">            <span class="tok-kw">var</span> offset: Block = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L100">            mem.writeIntBig(<span class="tok-type">u128</span>, &amp;offset, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u128</span>, stretch &gt;&gt; (<span class="tok-number">64</span> - <span class="tok-builtin">@as</span>(<span class="tok-type">u7</span>, bottom))));</span>
<span class="line" id="L101">            <span class="tok-kw">return</span> offset;</span>
<span class="line" id="L102">        }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">        <span class="tok-kw">const</span> has_aesni = std.Target.x86.featureSetHas(builtin.cpu.features, .aes);</span>
<span class="line" id="L105">        <span class="tok-kw">const</span> has_armaes = std.Target.aarch64.featureSetHas(builtin.cpu.features, .aes);</span>
<span class="line" id="L106">        <span class="tok-kw">const</span> wb: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> ((builtin.cpu.arch == .x86_64 <span class="tok-kw">and</span> has_aesni) <span class="tok-kw">or</span> (builtin.cpu.arch == .aarch64 <span class="tok-kw">and</span> has_armaes)) <span class="tok-number">4</span> <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L109">        <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L110">        <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L111">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L112">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L113">        <span class="tok-comment">/// k: secret key</span></span>
<span class="line" id="L114">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L115">            assert(c.len == m.len);</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">            <span class="tok-kw">const</span> aes_enc_ctx = Aes.initEnc(key);</span>
<span class="line" id="L118">            <span class="tok-kw">const</span> full_blocks: <span class="tok-type">usize</span> = m.len / <span class="tok-number">16</span>;</span>
<span class="line" id="L119">            <span class="tok-kw">const</span> x_max = <span class="tok-kw">if</span> (full_blocks &gt; <span class="tok-number">0</span>) math.log2_int(<span class="tok-type">usize</span>, full_blocks) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L120">            <span class="tok-kw">var</span> lx = Lx.init(aes_enc_ctx);</span>
<span class="line" id="L121">            <span class="tok-kw">const</span> lt = lx.precomp(x_max);</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">            <span class="tok-kw">var</span> offset = getOffset(aes_enc_ctx, npub);</span>
<span class="line" id="L124">            <span class="tok-kw">var</span> sum = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L125">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">            <span class="tok-kw">while</span> (wb &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> i + wb &lt;= full_blocks) : (i += wb) {</span>
<span class="line" id="L128">                <span class="tok-kw">var</span> offsets: [wb]Block <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L129">                <span class="tok-kw">var</span> es: [<span class="tok-number">16</span> * wb]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L130">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L131">                <span class="tok-kw">while</span> (j &lt; wb) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L132">                    xorWith(&amp;offset, lt[<span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">1</span> + j)]);</span>
<span class="line" id="L133">                    offsets[j] = offset;</span>
<span class="line" id="L134">                    <span class="tok-kw">const</span> p = m[(i + j) * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*;</span>
<span class="line" id="L135">                    mem.copy(<span class="tok-type">u8</span>, es[j * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;xorBlocks(p, offsets[j]));</span>
<span class="line" id="L136">                    xorWith(&amp;sum, p);</span>
<span class="line" id="L137">                }</span>
<span class="line" id="L138">                aes_enc_ctx.encryptWide(wb, &amp;es, &amp;es);</span>
<span class="line" id="L139">                j = <span class="tok-number">0</span>;</span>
<span class="line" id="L140">                <span class="tok-kw">while</span> (j &lt; wb) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L141">                    <span class="tok-kw">const</span> e = es[j * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*;</span>
<span class="line" id="L142">                    mem.copy(<span class="tok-type">u8</span>, c[(i + j) * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;xorBlocks(e, offsets[j]));</span>
<span class="line" id="L143">                }</span>
<span class="line" id="L144">            }</span>
<span class="line" id="L145">            <span class="tok-kw">while</span> (i &lt; full_blocks) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L146">                xorWith(&amp;offset, lt[<span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">1</span>)]);</span>
<span class="line" id="L147">                <span class="tok-kw">const</span> p = m[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*;</span>
<span class="line" id="L148">                <span class="tok-kw">var</span> e = xorBlocks(p, offset);</span>
<span class="line" id="L149">                aes_enc_ctx.encrypt(&amp;e, &amp;e);</span>
<span class="line" id="L150">                mem.copy(<span class="tok-type">u8</span>, c[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;xorBlocks(e, offset));</span>
<span class="line" id="L151">                xorWith(&amp;sum, p);</span>
<span class="line" id="L152">            }</span>
<span class="line" id="L153">            <span class="tok-kw">const</span> leftover = m.len % <span class="tok-number">16</span>;</span>
<span class="line" id="L154">            <span class="tok-kw">if</span> (leftover &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L155">                xorWith(&amp;offset, lx.star);</span>
<span class="line" id="L156">                <span class="tok-kw">var</span> pad = offset;</span>
<span class="line" id="L157">                aes_enc_ctx.encrypt(&amp;pad, &amp;pad);</span>
<span class="line" id="L158">                <span class="tok-kw">for</span> (m[i * <span class="tok-number">16</span> ..]) |x, j| {</span>
<span class="line" id="L159">                    c[i * <span class="tok-number">16</span> + j] = pad[j] ^ x;</span>
<span class="line" id="L160">                }</span>
<span class="line" id="L161">                <span class="tok-kw">var</span> e = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L162">                mem.copy(<span class="tok-type">u8</span>, e[<span class="tok-number">0</span>..leftover], m[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..leftover]);</span>
<span class="line" id="L163">                e[leftover] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L164">                xorWith(&amp;sum, e);</span>
<span class="line" id="L165">            }</span>
<span class="line" id="L166">            <span class="tok-kw">var</span> e = xorBlocks(xorBlocks(sum, offset), lx.dol);</span>
<span class="line" id="L167">            aes_enc_ctx.encrypt(&amp;e, &amp;e);</span>
<span class="line" id="L168">            tag.* = xorBlocks(e, hash(aes_enc_ctx, &amp;lx, ad));</span>
<span class="line" id="L169">        }</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">        <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L172">        <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L173">        <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L174">        <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L175">        <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L176">        <span class="tok-comment">/// k: secret key</span></span>
<span class="line" id="L177">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L178">            assert(c.len == m.len);</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">            <span class="tok-kw">const</span> aes_enc_ctx = Aes.initEnc(key);</span>
<span class="line" id="L181">            <span class="tok-kw">const</span> aes_dec_ctx = DecryptCtx.initFromEnc(aes_enc_ctx);</span>
<span class="line" id="L182">            <span class="tok-kw">const</span> full_blocks: <span class="tok-type">usize</span> = m.len / <span class="tok-number">16</span>;</span>
<span class="line" id="L183">            <span class="tok-kw">const</span> x_max = <span class="tok-kw">if</span> (full_blocks &gt; <span class="tok-number">0</span>) math.log2_int(<span class="tok-type">usize</span>, full_blocks) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L184">            <span class="tok-kw">var</span> lx = Lx.init(aes_enc_ctx);</span>
<span class="line" id="L185">            <span class="tok-kw">const</span> lt = lx.precomp(x_max);</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">            <span class="tok-kw">var</span> offset = getOffset(aes_enc_ctx, npub);</span>
<span class="line" id="L188">            <span class="tok-kw">var</span> sum = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L189">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">            <span class="tok-kw">while</span> (wb &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> i + wb &lt;= full_blocks) : (i += wb) {</span>
<span class="line" id="L192">                <span class="tok-kw">var</span> offsets: [wb]Block <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L193">                <span class="tok-kw">var</span> es: [<span class="tok-number">16</span> * wb]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L194">                <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L195">                <span class="tok-kw">while</span> (j &lt; wb) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L196">                    xorWith(&amp;offset, lt[<span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">1</span> + j)]);</span>
<span class="line" id="L197">                    offsets[j] = offset;</span>
<span class="line" id="L198">                    <span class="tok-kw">const</span> q = c[(i + j) * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*;</span>
<span class="line" id="L199">                    mem.copy(<span class="tok-type">u8</span>, es[j * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;xorBlocks(q, offsets[j]));</span>
<span class="line" id="L200">                }</span>
<span class="line" id="L201">                aes_dec_ctx.decryptWide(wb, &amp;es, &amp;es);</span>
<span class="line" id="L202">                j = <span class="tok-number">0</span>;</span>
<span class="line" id="L203">                <span class="tok-kw">while</span> (j &lt; wb) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L204">                    <span class="tok-kw">const</span> p = xorBlocks(es[j * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*, offsets[j]);</span>
<span class="line" id="L205">                    mem.copy(<span class="tok-type">u8</span>, m[(i + j) * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;p);</span>
<span class="line" id="L206">                    xorWith(&amp;sum, p);</span>
<span class="line" id="L207">                }</span>
<span class="line" id="L208">            }</span>
<span class="line" id="L209">            <span class="tok-kw">while</span> (i &lt; full_blocks) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L210">                xorWith(&amp;offset, lt[<span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, i + <span class="tok-number">1</span>)]);</span>
<span class="line" id="L211">                <span class="tok-kw">const</span> q = c[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>].*;</span>
<span class="line" id="L212">                <span class="tok-kw">var</span> e = xorBlocks(q, offset);</span>
<span class="line" id="L213">                aes_dec_ctx.decrypt(&amp;e, &amp;e);</span>
<span class="line" id="L214">                <span class="tok-kw">const</span> p = xorBlocks(e, offset);</span>
<span class="line" id="L215">                mem.copy(<span class="tok-type">u8</span>, m[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], &amp;p);</span>
<span class="line" id="L216">                xorWith(&amp;sum, p);</span>
<span class="line" id="L217">            }</span>
<span class="line" id="L218">            <span class="tok-kw">const</span> leftover = m.len % <span class="tok-number">16</span>;</span>
<span class="line" id="L219">            <span class="tok-kw">if</span> (leftover &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L220">                xorWith(&amp;offset, lx.star);</span>
<span class="line" id="L221">                <span class="tok-kw">var</span> pad = offset;</span>
<span class="line" id="L222">                aes_enc_ctx.encrypt(&amp;pad, &amp;pad);</span>
<span class="line" id="L223">                <span class="tok-kw">for</span> (c[i * <span class="tok-number">16</span> ..]) |x, j| {</span>
<span class="line" id="L224">                    m[i * <span class="tok-number">16</span> + j] = pad[j] ^ x;</span>
<span class="line" id="L225">                }</span>
<span class="line" id="L226">                <span class="tok-kw">var</span> e = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L227">                mem.copy(<span class="tok-type">u8</span>, e[<span class="tok-number">0</span>..leftover], m[i * <span class="tok-number">16</span> ..][<span class="tok-number">0</span>..leftover]);</span>
<span class="line" id="L228">                e[leftover] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L229">                xorWith(&amp;sum, e);</span>
<span class="line" id="L230">            }</span>
<span class="line" id="L231">            <span class="tok-kw">var</span> e = xorBlocks(xorBlocks(sum, offset), lx.dol);</span>
<span class="line" id="L232">            aes_enc_ctx.encrypt(&amp;e, &amp;e);</span>
<span class="line" id="L233">            <span class="tok-kw">var</span> computed_tag = xorBlocks(e, hash(aes_enc_ctx, &amp;lx, ad));</span>
<span class="line" id="L234">            <span class="tok-kw">const</span> verify = crypto.utils.timingSafeEql([tag_length]<span class="tok-type">u8</span>, computed_tag, tag);</span>
<span class="line" id="L235">            crypto.utils.secureZero(<span class="tok-type">u8</span>, &amp;computed_tag);</span>
<span class="line" id="L236">            <span class="tok-kw">if</span> (!verify) {</span>
<span class="line" id="L237">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L238">            }</span>
<span class="line" id="L239">        }</span>
<span class="line" id="L240">    };</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">xorBlocks</span>(x: Block, y: Block) Block {</span>
<span class="line" id="L244">    <span class="tok-kw">var</span> z: Block = x;</span>
<span class="line" id="L245">    <span class="tok-kw">for</span> (z) |*v, i| {</span>
<span class="line" id="L246">        v.* = x[i] ^ y[i];</span>
<span class="line" id="L247">    }</span>
<span class="line" id="L248">    <span class="tok-kw">return</span> z;</span>
<span class="line" id="L249">}</span>
<span class="line" id="L250"></span>
<span class="line" id="L251"><span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">xorWith</span>(x: *Block, y: Block) <span class="tok-type">void</span> {</span>
<span class="line" id="L252">    <span class="tok-kw">for</span> (x) |*v, i| {</span>
<span class="line" id="L253">        v.* ^= y[i];</span>
<span class="line" id="L254">    }</span>
<span class="line" id="L255">}</span>
<span class="line" id="L256"></span>
<span class="line" id="L257"><span class="tok-kw">const</span> hexToBytes = std.fmt.hexToBytes;</span>
<span class="line" id="L258"></span>
<span class="line" id="L259"><span class="tok-kw">test</span> <span class="tok-str">&quot;AesOcb test vector 1&quot;</span> {</span>
<span class="line" id="L260">    <span class="tok-kw">var</span> k: [Aes128Ocb.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L261">    <span class="tok-kw">var</span> nonce: [Aes128Ocb.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L262">    <span class="tok-kw">var</span> tag: [Aes128Ocb.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L263">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;k, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L264">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;nonce, <span class="tok-str">&quot;BBAA99887766554433221100&quot;</span>);</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">    <span class="tok-kw">var</span> c: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L267">    Aes128Ocb.encrypt(&amp;c, &amp;tag, <span class="tok-str">&quot;&quot;</span>, <span class="tok-str">&quot;&quot;</span>, nonce, k);</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-kw">var</span> expected_tag: [tag.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L270">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_tag, <span class="tok-str">&quot;785407BFFFC8AD9EDCC5520AC9111EE6&quot;</span>);</span>
<span class="line" id="L271"></span>
<span class="line" id="L272">    <span class="tok-kw">var</span> m: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L273">    <span class="tok-kw">try</span> Aes128Ocb.decrypt(&amp;m, <span class="tok-str">&quot;&quot;</span>, tag, <span class="tok-str">&quot;&quot;</span>, nonce, k);</span>
<span class="line" id="L274">}</span>
<span class="line" id="L275"></span>
<span class="line" id="L276"><span class="tok-kw">test</span> <span class="tok-str">&quot;AesOcb test vector 2&quot;</span> {</span>
<span class="line" id="L277">    <span class="tok-kw">var</span> k: [Aes128Ocb.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L278">    <span class="tok-kw">var</span> nonce: [Aes128Ocb.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L279">    <span class="tok-kw">var</span> tag: [Aes128Ocb.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L280">    <span class="tok-kw">var</span> ad: [<span class="tok-number">40</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L281">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;k, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L282">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;ad, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F2021222324252627&quot;</span>);</span>
<span class="line" id="L283">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;nonce, <span class="tok-str">&quot;BBAA9988776655443322110E&quot;</span>);</span>
<span class="line" id="L284"></span>
<span class="line" id="L285">    <span class="tok-kw">var</span> c: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L286">    Aes128Ocb.encrypt(&amp;c, &amp;tag, <span class="tok-str">&quot;&quot;</span>, &amp;ad, nonce, k);</span>
<span class="line" id="L287"></span>
<span class="line" id="L288">    <span class="tok-kw">var</span> expected_tag: [tag.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L289">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_tag, <span class="tok-str">&quot;C5CD9D1850C141E358649994EE701B68&quot;</span>);</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-kw">var</span> m: [<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L292">    <span class="tok-kw">try</span> Aes128Ocb.decrypt(&amp;m, &amp;c, tag, &amp;ad, nonce, k);</span>
<span class="line" id="L293">}</span>
<span class="line" id="L294"></span>
<span class="line" id="L295"><span class="tok-kw">test</span> <span class="tok-str">&quot;AesOcb test vector 3&quot;</span> {</span>
<span class="line" id="L296">    <span class="tok-kw">var</span> k: [Aes128Ocb.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L297">    <span class="tok-kw">var</span> nonce: [Aes128Ocb.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L298">    <span class="tok-kw">var</span> tag: [Aes128Ocb.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L299">    <span class="tok-kw">var</span> m: [<span class="tok-number">40</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L300">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L301">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;k, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L302">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;m, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F2021222324252627&quot;</span>);</span>
<span class="line" id="L303">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;nonce, <span class="tok-str">&quot;BBAA9988776655443322110F&quot;</span>);</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    Aes128Ocb.encrypt(&amp;c, &amp;tag, &amp;m, <span class="tok-str">&quot;&quot;</span>, nonce, k);</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">var</span> expected_c: [c.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L308">    <span class="tok-kw">var</span> expected_tag: [tag.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L309">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_tag, <span class="tok-str">&quot;479AD363AC366B95A98CA5F3000B1479&quot;</span>);</span>
<span class="line" id="L310">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_c, <span class="tok-str">&quot;4412923493C57D5DE0D700F753CCE0D1D2D95060122E9F15A5DDBFC5787E50B5CC55EE507BCB084E&quot;</span>);</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L313">    <span class="tok-kw">try</span> Aes128Ocb.decrypt(&amp;m2, &amp;c, tag, <span class="tok-str">&quot;&quot;</span>, nonce, k);</span>
<span class="line" id="L314">    assert(mem.eql(<span class="tok-type">u8</span>, &amp;m, &amp;m2));</span>
<span class="line" id="L315">}</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-kw">test</span> <span class="tok-str">&quot;AesOcb test vector 4&quot;</span> {</span>
<span class="line" id="L318">    <span class="tok-kw">var</span> k: [Aes128Ocb.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L319">    <span class="tok-kw">var</span> nonce: [Aes128Ocb.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L320">    <span class="tok-kw">var</span> tag: [Aes128Ocb.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L321">    <span class="tok-kw">var</span> m: [<span class="tok-number">40</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L322">    <span class="tok-kw">var</span> ad = m;</span>
<span class="line" id="L323">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L324">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;k, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F&quot;</span>);</span>
<span class="line" id="L325">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;m, <span class="tok-str">&quot;000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F2021222324252627&quot;</span>);</span>
<span class="line" id="L326">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;nonce, <span class="tok-str">&quot;BBAA99887766554433221104&quot;</span>);</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    Aes128Ocb.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, k);</span>
<span class="line" id="L329"></span>
<span class="line" id="L330">    <span class="tok-kw">var</span> expected_c: [c.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L331">    <span class="tok-kw">var</span> expected_tag: [tag.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L332">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_tag, <span class="tok-str">&quot;3AD7A4FF3835B8C5701C1CCEC8FC3358&quot;</span>);</span>
<span class="line" id="L333">    _ = <span class="tok-kw">try</span> hexToBytes(&amp;expected_c, <span class="tok-str">&quot;571D535B60B277188BE5147170A9A22C&quot;</span>);</span>
<span class="line" id="L334"></span>
<span class="line" id="L335">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L336">    <span class="tok-kw">try</span> Aes128Ocb.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, k);</span>
<span class="line" id="L337">    assert(mem.eql(<span class="tok-type">u8</span>, &amp;m, &amp;m2));</span>
<span class="line" id="L338">}</span>
<span class="line" id="L339"></span>
</code></pre></body>
</html>