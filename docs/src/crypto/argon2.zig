<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/argon2.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// https://datatracker.ietf.org/doc/rfc9106</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://github.com/golang/crypto/tree/master/argon2</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// https://github.com/P-H-C/phc-winner-argon2</span>
</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L6"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> blake2 = crypto.hash.blake2;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> phc_format = pwhash.phc_format;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> pwhash = crypto.pwhash;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">const</span> Thread = std.Thread;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> Blake2b512 = blake2.Blake2b512;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> Blocks = std.ArrayListAligned([block_length]<span class="tok-type">u64</span>, <span class="tok-number">16</span>);</span>
<span class="line" id="L18"><span class="tok-kw">const</span> H0 = [Blake2b512.digest_length + <span class="tok-number">8</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">const</span> EncodingError = crypto.errors.EncodingError;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> KdfError = pwhash.KdfError;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> HasherError = pwhash.HasherError;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> Error = pwhash.Error;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">const</span> version = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L26"><span class="tok-kw">const</span> block_length = <span class="tok-number">128</span>;</span>
<span class="line" id="L27"><span class="tok-kw">const</span> sync_points = <span class="tok-number">4</span>;</span>
<span class="line" id="L28"><span class="tok-kw">const</span> max_int = <span class="tok-number">0xffff_ffff</span>;</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-kw">const</span> default_salt_len = <span class="tok-number">32</span>;</span>
<span class="line" id="L31"><span class="tok-kw">const</span> default_hash_len = <span class="tok-number">32</span>;</span>
<span class="line" id="L32"><span class="tok-kw">const</span> max_salt_len = <span class="tok-number">64</span>;</span>
<span class="line" id="L33"><span class="tok-kw">const</span> max_hash_len = <span class="tok-number">64</span>;</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-comment">/// Argon2 type</span></span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Mode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L37">    <span class="tok-comment">/// Argon2d is faster and uses data-depending memory access, which makes it highly resistant</span></span>
<span class="line" id="L38">    <span class="tok-comment">/// against GPU cracking attacks and suitable for applications with no threats from side-channel</span></span>
<span class="line" id="L39">    <span class="tok-comment">/// timing attacks (eg. cryptocurrencies).</span></span>
<span class="line" id="L40">    argon2d,</span>
<span class="line" id="L41"></span>
<span class="line" id="L42">    <span class="tok-comment">/// Argon2i instead uses data-independent memory access, which is preferred for password</span></span>
<span class="line" id="L43">    <span class="tok-comment">/// hashing and password-based key derivation, but it is slower as it makes more passes over</span></span>
<span class="line" id="L44">    <span class="tok-comment">/// the memory to protect from tradeoff attacks.</span></span>
<span class="line" id="L45">    argon2i,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">/// Argon2id is a hybrid of Argon2i and Argon2d, using a combination of data-depending and</span></span>
<span class="line" id="L48">    <span class="tok-comment">/// data-independent memory accesses, which gives some of Argon2i's resistance to side-channel</span></span>
<span class="line" id="L49">    <span class="tok-comment">/// cache timing attacks and much of Argon2d's resistance to GPU cracking attacks.</span></span>
<span class="line" id="L50">    argon2id,</span>
<span class="line" id="L51">};</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-comment">/// Argon2 parameters</span></span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Params = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L55">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-comment">/// A [t]ime cost, which defines the amount of computation realized and therefore the execution</span></span>
<span class="line" id="L58">    <span class="tok-comment">/// time, given in number of iterations.</span></span>
<span class="line" id="L59">    t: <span class="tok-type">u32</span>,</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-comment">/// A [m]emory cost, which defines the memory usage, given in kibibytes.</span></span>
<span class="line" id="L62">    m: <span class="tok-type">u32</span>,</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">    <span class="tok-comment">/// A [p]arallelism degree, which defines the number of parallel threads.</span></span>
<span class="line" id="L65">    p: <span class="tok-type">u24</span>,</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-comment">/// The [secret] parameter, which is used for keyed hashing. This allows a secret key to be input</span></span>
<span class="line" id="L68">    <span class="tok-comment">/// at hashing time (from some external location) and be folded into the value of the hash. This</span></span>
<span class="line" id="L69">    <span class="tok-comment">/// means that even if your salts and hashes are compromised, an attacker cannot brute-force to</span></span>
<span class="line" id="L70">    <span class="tok-comment">/// find the password without the key.</span></span>
<span class="line" id="L71">    secret: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">    <span class="tok-comment">/// The [ad] parameter, which is used to fold any additional data into the hash value. Functionally,</span></span>
<span class="line" id="L74">    <span class="tok-comment">/// this behaves almost exactly like the secret or salt parameters; the ad parameter is folding</span></span>
<span class="line" id="L75">    <span class="tok-comment">/// into the value of the hash. However, this parameter is used for different data. The salt</span></span>
<span class="line" id="L76">    <span class="tok-comment">/// should be a random string stored alongside your password. The secret should be a random key</span></span>
<span class="line" id="L77">    <span class="tok-comment">/// only usable at hashing time. The ad is for any other data.</span></span>
<span class="line" id="L78">    ad: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-comment">/// Baseline parameters for interactive logins using argon2i type</span></span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> interactive_2i = Self.fromLimits(<span class="tok-number">4</span>, <span class="tok-number">33554432</span>);</span>
<span class="line" id="L82">    <span class="tok-comment">/// Baseline parameters for normal usage using argon2i type</span></span>
<span class="line" id="L83">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> moderate_2i = Self.fromLimits(<span class="tok-number">6</span>, <span class="tok-number">134217728</span>);</span>
<span class="line" id="L84">    <span class="tok-comment">/// Baseline parameters for offline usage using argon2i type</span></span>
<span class="line" id="L85">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sensitive_2i = Self.fromLimits(<span class="tok-number">8</span>, <span class="tok-number">536870912</span>);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-comment">/// Baseline parameters for interactive logins using argon2id type</span></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> interactive_2id = Self.fromLimits(<span class="tok-number">2</span>, <span class="tok-number">67108864</span>);</span>
<span class="line" id="L89">    <span class="tok-comment">/// Baseline parameters for normal usage using argon2id type</span></span>
<span class="line" id="L90">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> moderate_2id = Self.fromLimits(<span class="tok-number">3</span>, <span class="tok-number">268435456</span>);</span>
<span class="line" id="L91">    <span class="tok-comment">/// Baseline parameters for offline usage using argon2id type</span></span>
<span class="line" id="L92">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sensitive_2id = Self.fromLimits(<span class="tok-number">4</span>, <span class="tok-number">1073741824</span>);</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">    <span class="tok-comment">/// Create parameters from ops and mem limits, where mem_limit given in bytes</span></span>
<span class="line" id="L95">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromLimits</span>(ops_limit: <span class="tok-type">u32</span>, mem_limit: <span class="tok-type">usize</span>) Self {</span>
<span class="line" id="L96">        <span class="tok-kw">const</span> m = mem_limit / <span class="tok-number">1024</span>;</span>
<span class="line" id="L97">        std.debug.assert(m &lt;= max_int);</span>
<span class="line" id="L98">        <span class="tok-kw">return</span> .{ .t = ops_limit, .m = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, m), .p = <span class="tok-number">1</span> };</span>
<span class="line" id="L99">    }</span>
<span class="line" id="L100">};</span>
<span class="line" id="L101"></span>
<span class="line" id="L102"><span class="tok-kw">fn</span> <span class="tok-fn">initHash</span>(</span>
<span class="line" id="L103">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L104">    salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L105">    params: Params,</span>
<span class="line" id="L106">    dk_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L107">    mode: Mode,</span>
<span class="line" id="L108">) H0 {</span>
<span class="line" id="L109">    <span class="tok-kw">var</span> h0: H0 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L110">    <span class="tok-kw">var</span> parameters: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L111">    <span class="tok-kw">var</span> tmp: [<span class="tok-number">4</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L112">    <span class="tok-kw">var</span> b2 = Blake2b512.init(.{});</span>
<span class="line" id="L113">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">0</span>..<span class="tok-number">4</span>], params.p);</span>
<span class="line" id="L114">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">4</span>..<span class="tok-number">8</span>], <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, dk_len));</span>
<span class="line" id="L115">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">8</span>..<span class="tok-number">12</span>], params.m);</span>
<span class="line" id="L116">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">12</span>..<span class="tok-number">16</span>], params.t);</span>
<span class="line" id="L117">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">16</span>..<span class="tok-number">20</span>], version);</span>
<span class="line" id="L118">    mem.writeIntLittle(<span class="tok-type">u32</span>, parameters[<span class="tok-number">20</span>..<span class="tok-number">24</span>], <span class="tok-builtin">@enumToInt</span>(mode));</span>
<span class="line" id="L119">    b2.update(&amp;parameters);</span>
<span class="line" id="L120">    mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;tmp, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, password.len));</span>
<span class="line" id="L121">    b2.update(&amp;tmp);</span>
<span class="line" id="L122">    b2.update(password);</span>
<span class="line" id="L123">    mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;tmp, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, salt.len));</span>
<span class="line" id="L124">    b2.update(&amp;tmp);</span>
<span class="line" id="L125">    b2.update(salt);</span>
<span class="line" id="L126">    <span class="tok-kw">const</span> secret = params.secret <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L127">    std.debug.assert(secret.len &lt;= max_int);</span>
<span class="line" id="L128">    mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;tmp, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, secret.len));</span>
<span class="line" id="L129">    b2.update(&amp;tmp);</span>
<span class="line" id="L130">    b2.update(secret);</span>
<span class="line" id="L131">    <span class="tok-kw">const</span> ad = params.ad <span class="tok-kw">orelse</span> <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L132">    std.debug.assert(ad.len &lt;= max_int);</span>
<span class="line" id="L133">    mem.writeIntLittle(<span class="tok-type">u32</span>, &amp;tmp, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ad.len));</span>
<span class="line" id="L134">    b2.update(&amp;tmp);</span>
<span class="line" id="L135">    b2.update(ad);</span>
<span class="line" id="L136">    b2.final(h0[<span class="tok-number">0</span>..Blake2b512.digest_length]);</span>
<span class="line" id="L137">    <span class="tok-kw">return</span> h0;</span>
<span class="line" id="L138">}</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">fn</span> <span class="tok-fn">blake2bLong</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L141">    <span class="tok-kw">var</span> b2 = Blake2b512.init(.{ .expected_out_bits = math.min(<span class="tok-number">512</span>, out.len * <span class="tok-number">8</span>) });</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-kw">var</span> buffer: [Blake2b512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L144">    mem.writeIntLittle(<span class="tok-type">u32</span>, buffer[<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, out.len));</span>
<span class="line" id="L145">    b2.update(buffer[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L146">    b2.update(in);</span>
<span class="line" id="L147">    b2.final(&amp;buffer);</span>
<span class="line" id="L148"></span>
<span class="line" id="L149">    <span class="tok-kw">if</span> (out.len &lt;= Blake2b512.digest_length) {</span>
<span class="line" id="L150">        mem.copy(<span class="tok-type">u8</span>, out, buffer[<span class="tok-number">0</span>..out.len]);</span>
<span class="line" id="L151">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L152">    }</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    b2 = Blake2b512.init(.{});</span>
<span class="line" id="L155">    mem.copy(<span class="tok-type">u8</span>, out, buffer[<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L156">    <span class="tok-kw">var</span> out_slice = out[<span class="tok-number">32</span>..];</span>
<span class="line" id="L157">    <span class="tok-kw">while</span> (out_slice.len &gt; Blake2b512.digest_length) : ({</span>
<span class="line" id="L158">        out_slice = out_slice[<span class="tok-number">32</span>..];</span>
<span class="line" id="L159">        b2 = Blake2b512.init(.{});</span>
<span class="line" id="L160">    }) {</span>
<span class="line" id="L161">        b2.update(&amp;buffer);</span>
<span class="line" id="L162">        b2.final(&amp;buffer);</span>
<span class="line" id="L163">        mem.copy(<span class="tok-type">u8</span>, out_slice, buffer[<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L164">    }</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">    <span class="tok-kw">var</span> r = Blake2b512.digest_length;</span>
<span class="line" id="L167">    <span class="tok-kw">if</span> (out.len % Blake2b512.digest_length &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L168">        r = ((out.len + <span class="tok-number">31</span>) / <span class="tok-number">32</span>) - <span class="tok-number">2</span>;</span>
<span class="line" id="L169">        b2 = Blake2b512.init(.{ .expected_out_bits = r * <span class="tok-number">8</span> });</span>
<span class="line" id="L170">    }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    b2.update(&amp;buffer);</span>
<span class="line" id="L173">    b2.final(&amp;buffer);</span>
<span class="line" id="L174">    mem.copy(<span class="tok-type">u8</span>, out_slice, buffer[<span class="tok-number">0</span>..r]);</span>
<span class="line" id="L175">}</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">fn</span> <span class="tok-fn">initBlocks</span>(</span>
<span class="line" id="L178">    blocks: *Blocks,</span>
<span class="line" id="L179">    h0: *H0,</span>
<span class="line" id="L180">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L181">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L182">) <span class="tok-type">void</span> {</span>
<span class="line" id="L183">    <span class="tok-kw">var</span> block0: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L184">    <span class="tok-kw">var</span> lane: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L185">    <span class="tok-kw">while</span> (lane &lt; threads) : (lane += <span class="tok-number">1</span>) {</span>
<span class="line" id="L186">        <span class="tok-kw">const</span> j = lane * (memory / threads);</span>
<span class="line" id="L187">        mem.writeIntLittle(<span class="tok-type">u32</span>, h0[Blake2b512.digest_length + <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], lane);</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">        mem.writeIntLittle(<span class="tok-type">u32</span>, h0[Blake2b512.digest_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L190">        blake2bLong(&amp;block0, h0);</span>
<span class="line" id="L191">        <span class="tok-kw">for</span> (blocks.items[j + <span class="tok-number">0</span>]) |*v, i| {</span>
<span class="line" id="L192">            v.* = mem.readIntLittle(<span class="tok-type">u64</span>, block0[i * <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L193">        }</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">        mem.writeIntLittle(<span class="tok-type">u32</span>, h0[Blake2b512.digest_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">1</span>);</span>
<span class="line" id="L196">        blake2bLong(&amp;block0, h0);</span>
<span class="line" id="L197">        <span class="tok-kw">for</span> (blocks.items[j + <span class="tok-number">1</span>]) |*v, i| {</span>
<span class="line" id="L198">            v.* = mem.readIntLittle(<span class="tok-type">u64</span>, block0[i * <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L199">        }</span>
<span class="line" id="L200">    }</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">fn</span> <span class="tok-fn">processBlocks</span>(</span>
<span class="line" id="L204">    allocator: mem.Allocator,</span>
<span class="line" id="L205">    blocks: *Blocks,</span>
<span class="line" id="L206">    time: <span class="tok-type">u32</span>,</span>
<span class="line" id="L207">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L208">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L209">    mode: Mode,</span>
<span class="line" id="L210">) KdfError!<span class="tok-type">void</span> {</span>
<span class="line" id="L211">    <span class="tok-kw">const</span> lanes = memory / threads;</span>
<span class="line" id="L212">    <span class="tok-kw">const</span> segments = lanes / sync_points;</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-kw">if</span> (builtin.single_threaded <span class="tok-kw">or</span> threads == <span class="tok-number">1</span>) {</span>
<span class="line" id="L215">        processBlocksSt(blocks, time, memory, threads, mode, lanes, segments);</span>
<span class="line" id="L216">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L217">        <span class="tok-kw">try</span> processBlocksMt(allocator, blocks, time, memory, threads, mode, lanes, segments);</span>
<span class="line" id="L218">    }</span>
<span class="line" id="L219">}</span>
<span class="line" id="L220"></span>
<span class="line" id="L221"><span class="tok-kw">fn</span> <span class="tok-fn">processBlocksSt</span>(</span>
<span class="line" id="L222">    blocks: *Blocks,</span>
<span class="line" id="L223">    time: <span class="tok-type">u32</span>,</span>
<span class="line" id="L224">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L225">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L226">    mode: Mode,</span>
<span class="line" id="L227">    lanes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L228">    segments: <span class="tok-type">u32</span>,</span>
<span class="line" id="L229">) <span class="tok-type">void</span> {</span>
<span class="line" id="L230">    <span class="tok-kw">var</span> n: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L231">    <span class="tok-kw">while</span> (n &lt; time) : (n += <span class="tok-number">1</span>) {</span>
<span class="line" id="L232">        <span class="tok-kw">var</span> slice: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L233">        <span class="tok-kw">while</span> (slice &lt; sync_points) : (slice += <span class="tok-number">1</span>) {</span>
<span class="line" id="L234">            <span class="tok-kw">var</span> lane: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L235">            <span class="tok-kw">while</span> (lane &lt; threads) : (lane += <span class="tok-number">1</span>) {</span>
<span class="line" id="L236">                processSegment(blocks, time, memory, threads, mode, lanes, segments, n, slice, lane);</span>
<span class="line" id="L237">            }</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239">    }</span>
<span class="line" id="L240">}</span>
<span class="line" id="L241"></span>
<span class="line" id="L242"><span class="tok-kw">fn</span> <span class="tok-fn">processBlocksMt</span>(</span>
<span class="line" id="L243">    allocator: mem.Allocator,</span>
<span class="line" id="L244">    blocks: *Blocks,</span>
<span class="line" id="L245">    time: <span class="tok-type">u32</span>,</span>
<span class="line" id="L246">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L247">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L248">    mode: Mode,</span>
<span class="line" id="L249">    lanes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L250">    segments: <span class="tok-type">u32</span>,</span>
<span class="line" id="L251">) KdfError!<span class="tok-type">void</span> {</span>
<span class="line" id="L252">    <span class="tok-kw">var</span> threads_list = <span class="tok-kw">try</span> std.ArrayList(Thread).initCapacity(allocator, threads);</span>
<span class="line" id="L253">    <span class="tok-kw">defer</span> threads_list.deinit();</span>
<span class="line" id="L254"></span>
<span class="line" id="L255">    <span class="tok-kw">var</span> n: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L256">    <span class="tok-kw">while</span> (n &lt; time) : (n += <span class="tok-number">1</span>) {</span>
<span class="line" id="L257">        <span class="tok-kw">var</span> slice: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L258">        <span class="tok-kw">while</span> (slice &lt; sync_points) : (slice += <span class="tok-number">1</span>) {</span>
<span class="line" id="L259">            <span class="tok-kw">var</span> lane: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L260">            <span class="tok-kw">while</span> (lane &lt; threads) : (lane += <span class="tok-number">1</span>) {</span>
<span class="line" id="L261">                <span class="tok-kw">const</span> thread = <span class="tok-kw">try</span> Thread.spawn(.{}, processSegment, .{</span>
<span class="line" id="L262">                    blocks, time, memory, threads, mode, lanes, segments, n, slice, lane,</span>
<span class="line" id="L263">                });</span>
<span class="line" id="L264">                threads_list.appendAssumeCapacity(thread);</span>
<span class="line" id="L265">            }</span>
<span class="line" id="L266">            lane = <span class="tok-number">0</span>;</span>
<span class="line" id="L267">            <span class="tok-kw">while</span> (lane &lt; threads) : (lane += <span class="tok-number">1</span>) {</span>
<span class="line" id="L268">                threads_list.items[lane].join();</span>
<span class="line" id="L269">            }</span>
<span class="line" id="L270">            threads_list.clearRetainingCapacity();</span>
<span class="line" id="L271">        }</span>
<span class="line" id="L272">    }</span>
<span class="line" id="L273">}</span>
<span class="line" id="L274"></span>
<span class="line" id="L275"><span class="tok-kw">fn</span> <span class="tok-fn">processSegment</span>(</span>
<span class="line" id="L276">    blocks: *Blocks,</span>
<span class="line" id="L277">    passes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L278">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L279">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L280">    mode: Mode,</span>
<span class="line" id="L281">    lanes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L282">    segments: <span class="tok-type">u32</span>,</span>
<span class="line" id="L283">    n: <span class="tok-type">u32</span>,</span>
<span class="line" id="L284">    slice: <span class="tok-type">u32</span>,</span>
<span class="line" id="L285">    lane: <span class="tok-type">u24</span>,</span>
<span class="line" id="L286">) <span class="tok-type">void</span> {</span>
<span class="line" id="L287">    <span class="tok-kw">var</span> addresses <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** block_length;</span>
<span class="line" id="L288">    <span class="tok-kw">var</span> in <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** block_length;</span>
<span class="line" id="L289">    <span class="tok-kw">const</span> zero <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = [_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** block_length;</span>
<span class="line" id="L290">    <span class="tok-kw">if</span> (mode == .argon2i <span class="tok-kw">or</span> (mode == .argon2id <span class="tok-kw">and</span> n == <span class="tok-number">0</span> <span class="tok-kw">and</span> slice &lt; sync_points / <span class="tok-number">2</span>)) {</span>
<span class="line" id="L291">        in[<span class="tok-number">0</span>] = n;</span>
<span class="line" id="L292">        in[<span class="tok-number">1</span>] = lane;</span>
<span class="line" id="L293">        in[<span class="tok-number">2</span>] = slice;</span>
<span class="line" id="L294">        in[<span class="tok-number">3</span>] = memory;</span>
<span class="line" id="L295">        in[<span class="tok-number">4</span>] = passes;</span>
<span class="line" id="L296">        in[<span class="tok-number">5</span>] = <span class="tok-builtin">@enumToInt</span>(mode);</span>
<span class="line" id="L297">    }</span>
<span class="line" id="L298">    <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L299">    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span> <span class="tok-kw">and</span> slice == <span class="tok-number">0</span>) {</span>
<span class="line" id="L300">        index = <span class="tok-number">2</span>;</span>
<span class="line" id="L301">        <span class="tok-kw">if</span> (mode == .argon2i <span class="tok-kw">or</span> mode == .argon2id) {</span>
<span class="line" id="L302">            in[<span class="tok-number">6</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L303">            processBlock(&amp;addresses, &amp;in, &amp;zero);</span>
<span class="line" id="L304">            processBlock(&amp;addresses, &amp;addresses, &amp;zero);</span>
<span class="line" id="L305">        }</span>
<span class="line" id="L306">    }</span>
<span class="line" id="L307">    <span class="tok-kw">var</span> offset = lane * lanes + slice * segments + index;</span>
<span class="line" id="L308">    <span class="tok-kw">var</span> random: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L309">    <span class="tok-kw">while</span> (index &lt; segments) : ({</span>
<span class="line" id="L310">        index += <span class="tok-number">1</span>;</span>
<span class="line" id="L311">        offset += <span class="tok-number">1</span>;</span>
<span class="line" id="L312">    }) {</span>
<span class="line" id="L313">        <span class="tok-kw">var</span> prev = offset -% <span class="tok-number">1</span>;</span>
<span class="line" id="L314">        <span class="tok-kw">if</span> (index == <span class="tok-number">0</span> <span class="tok-kw">and</span> slice == <span class="tok-number">0</span>) {</span>
<span class="line" id="L315">            prev +%= lanes;</span>
<span class="line" id="L316">        }</span>
<span class="line" id="L317">        <span class="tok-kw">if</span> (mode == .argon2i <span class="tok-kw">or</span> (mode == .argon2id <span class="tok-kw">and</span> n == <span class="tok-number">0</span> <span class="tok-kw">and</span> slice &lt; sync_points / <span class="tok-number">2</span>)) {</span>
<span class="line" id="L318">            <span class="tok-kw">if</span> (index % block_length == <span class="tok-number">0</span>) {</span>
<span class="line" id="L319">                in[<span class="tok-number">6</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L320">                processBlock(&amp;addresses, &amp;in, &amp;zero);</span>
<span class="line" id="L321">                processBlock(&amp;addresses, &amp;addresses, &amp;zero);</span>
<span class="line" id="L322">            }</span>
<span class="line" id="L323">            random = addresses[index % block_length];</span>
<span class="line" id="L324">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L325">            random = blocks.items[prev][<span class="tok-number">0</span>];</span>
<span class="line" id="L326">        }</span>
<span class="line" id="L327">        <span class="tok-kw">const</span> new_offset = indexAlpha(random, lanes, segments, threads, n, slice, lane, index);</span>
<span class="line" id="L328">        processBlockXor(&amp;blocks.items[offset], &amp;blocks.items[prev], &amp;blocks.items[new_offset]);</span>
<span class="line" id="L329">    }</span>
<span class="line" id="L330">}</span>
<span class="line" id="L331"></span>
<span class="line" id="L332"><span class="tok-kw">fn</span> <span class="tok-fn">processBlock</span>(</span>
<span class="line" id="L333">    out: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L334">    in1: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L335">    in2: *<span class="tok-kw">align</span>(<span class="tok-number">16</span>) <span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L336">) <span class="tok-type">void</span> {</span>
<span class="line" id="L337">    processBlockGeneric(out, in1, in2, <span class="tok-null">false</span>);</span>
<span class="line" id="L338">}</span>
<span class="line" id="L339"></span>
<span class="line" id="L340"><span class="tok-kw">fn</span> <span class="tok-fn">processBlockXor</span>(</span>
<span class="line" id="L341">    out: *[block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L342">    in1: *<span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L343">    in2: *<span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L344">) <span class="tok-type">void</span> {</span>
<span class="line" id="L345">    processBlockGeneric(out, in1, in2, <span class="tok-null">true</span>);</span>
<span class="line" id="L346">}</span>
<span class="line" id="L347"></span>
<span class="line" id="L348"><span class="tok-kw">fn</span> <span class="tok-fn">processBlockGeneric</span>(</span>
<span class="line" id="L349">    out: *[block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L350">    in1: *<span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L351">    in2: *<span class="tok-kw">const</span> [block_length]<span class="tok-type">u64</span>,</span>
<span class="line" id="L352">    <span class="tok-kw">comptime</span> xor: <span class="tok-type">bool</span>,</span>
<span class="line" id="L353">) <span class="tok-type">void</span> {</span>
<span class="line" id="L354">    <span class="tok-kw">var</span> t: [block_length]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L355">    <span class="tok-kw">for</span> (t) |*v, i| {</span>
<span class="line" id="L356">        v.* = in1[i] ^ in2[i];</span>
<span class="line" id="L357">    }</span>
<span class="line" id="L358">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L359">    <span class="tok-kw">while</span> (i &lt; block_length) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L360">        blamkaGeneric(t[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L361">    }</span>
<span class="line" id="L362">    i = <span class="tok-number">0</span>;</span>
<span class="line" id="L363">    <span class="tok-kw">var</span> buffer: [<span class="tok-number">16</span>]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L364">    <span class="tok-kw">while</span> (i &lt; block_length / <span class="tok-number">8</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L365">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L366">        <span class="tok-kw">while</span> (j &lt; block_length / <span class="tok-number">8</span>) : (j += <span class="tok-number">2</span>) {</span>
<span class="line" id="L367">            buffer[j] = t[j * <span class="tok-number">8</span> + i];</span>
<span class="line" id="L368">            buffer[j + <span class="tok-number">1</span>] = t[j * <span class="tok-number">8</span> + i + <span class="tok-number">1</span>];</span>
<span class="line" id="L369">        }</span>
<span class="line" id="L370">        blamkaGeneric(&amp;buffer);</span>
<span class="line" id="L371">        j = <span class="tok-number">0</span>;</span>
<span class="line" id="L372">        <span class="tok-kw">while</span> (j &lt; block_length / <span class="tok-number">8</span>) : (j += <span class="tok-number">2</span>) {</span>
<span class="line" id="L373">            t[j * <span class="tok-number">8</span> + i] = buffer[j];</span>
<span class="line" id="L374">            t[j * <span class="tok-number">8</span> + i + <span class="tok-number">1</span>] = buffer[j + <span class="tok-number">1</span>];</span>
<span class="line" id="L375">        }</span>
<span class="line" id="L376">    }</span>
<span class="line" id="L377">    <span class="tok-kw">if</span> (xor) {</span>
<span class="line" id="L378">        <span class="tok-kw">for</span> (t) |v, j| {</span>
<span class="line" id="L379">            out[j] ^= in1[j] ^ in2[j] ^ v;</span>
<span class="line" id="L380">        }</span>
<span class="line" id="L381">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L382">        <span class="tok-kw">for</span> (t) |v, j| {</span>
<span class="line" id="L383">            out[j] = in1[j] ^ in2[j] ^ v;</span>
<span class="line" id="L384">        }</span>
<span class="line" id="L385">    }</span>
<span class="line" id="L386">}</span>
<span class="line" id="L387"></span>
<span class="line" id="L388"><span class="tok-kw">const</span> QuarterRound = <span class="tok-kw">struct</span> { a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span> };</span>
<span class="line" id="L389"></span>
<span class="line" id="L390"><span class="tok-kw">fn</span> <span class="tok-fn">Rp</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>) QuarterRound {</span>
<span class="line" id="L391">    <span class="tok-kw">return</span> .{ .a = a, .b = b, .c = c, .d = d };</span>
<span class="line" id="L392">}</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">fn</span> <span class="tok-fn">fBlaMka</span>(x: <span class="tok-type">u64</span>, y: <span class="tok-type">u64</span>) <span class="tok-type">u64</span> {</span>
<span class="line" id="L395">    <span class="tok-kw">const</span> xy = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, x)) * <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, y));</span>
<span class="line" id="L396">    <span class="tok-kw">return</span> x +% y +% <span class="tok-number">2</span> *% xy;</span>
<span class="line" id="L397">}</span>
<span class="line" id="L398"></span>
<span class="line" id="L399"><span class="tok-kw">fn</span> <span class="tok-fn">blamkaGeneric</span>(x: *[<span class="tok-number">16</span>]<span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L400">    <span class="tok-kw">const</span> rounds = <span class="tok-kw">comptime</span> [_]QuarterRound{</span>
<span class="line" id="L401">        Rp(<span class="tok-number">0</span>, <span class="tok-number">4</span>, <span class="tok-number">8</span>, <span class="tok-number">12</span>),</span>
<span class="line" id="L402">        Rp(<span class="tok-number">1</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L403">        Rp(<span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">10</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L404">        Rp(<span class="tok-number">3</span>, <span class="tok-number">7</span>, <span class="tok-number">11</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L405">        Rp(<span class="tok-number">0</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">15</span>),</span>
<span class="line" id="L406">        Rp(<span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">11</span>, <span class="tok-number">12</span>),</span>
<span class="line" id="L407">        Rp(<span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">13</span>),</span>
<span class="line" id="L408">        Rp(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">9</span>, <span class="tok-number">14</span>),</span>
<span class="line" id="L409">    };</span>
<span class="line" id="L410">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rounds) |r| {</span>
<span class="line" id="L411">        x[r.a] = fBlaMka(x[r.a], x[r.b]);</span>
<span class="line" id="L412">        x[r.d] = math.rotr(<span class="tok-type">u64</span>, x[r.d] ^ x[r.a], <span class="tok-number">32</span>);</span>
<span class="line" id="L413">        x[r.c] = fBlaMka(x[r.c], x[r.d]);</span>
<span class="line" id="L414">        x[r.b] = math.rotr(<span class="tok-type">u64</span>, x[r.b] ^ x[r.c], <span class="tok-number">24</span>);</span>
<span class="line" id="L415">        x[r.a] = fBlaMka(x[r.a], x[r.b]);</span>
<span class="line" id="L416">        x[r.d] = math.rotr(<span class="tok-type">u64</span>, x[r.d] ^ x[r.a], <span class="tok-number">16</span>);</span>
<span class="line" id="L417">        x[r.c] = fBlaMka(x[r.c], x[r.d]);</span>
<span class="line" id="L418">        x[r.b] = math.rotr(<span class="tok-type">u64</span>, x[r.b] ^ x[r.c], <span class="tok-number">63</span>);</span>
<span class="line" id="L419">    }</span>
<span class="line" id="L420">}</span>
<span class="line" id="L421"></span>
<span class="line" id="L422"><span class="tok-kw">fn</span> <span class="tok-fn">finalize</span>(</span>
<span class="line" id="L423">    blocks: *Blocks,</span>
<span class="line" id="L424">    memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L425">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L426">    out: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L427">) <span class="tok-type">void</span> {</span>
<span class="line" id="L428">    <span class="tok-kw">const</span> lanes = memory / threads;</span>
<span class="line" id="L429">    <span class="tok-kw">var</span> lane: <span class="tok-type">u24</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L430">    <span class="tok-kw">while</span> (lane &lt; threads - <span class="tok-number">1</span>) : (lane += <span class="tok-number">1</span>) {</span>
<span class="line" id="L431">        <span class="tok-kw">for</span> (blocks.items[(lane * lanes) + lanes - <span class="tok-number">1</span>]) |v, i| {</span>
<span class="line" id="L432">            blocks.items[memory - <span class="tok-number">1</span>][i] ^= v;</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434">    }</span>
<span class="line" id="L435">    <span class="tok-kw">var</span> block: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L436">    <span class="tok-kw">for</span> (blocks.items[memory - <span class="tok-number">1</span>]) |v, i| {</span>
<span class="line" id="L437">        mem.writeIntLittle(<span class="tok-type">u64</span>, block[i * <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], v);</span>
<span class="line" id="L438">    }</span>
<span class="line" id="L439">    blake2bLong(out, &amp;block);</span>
<span class="line" id="L440">}</span>
<span class="line" id="L441"></span>
<span class="line" id="L442"><span class="tok-kw">fn</span> <span class="tok-fn">indexAlpha</span>(</span>
<span class="line" id="L443">    rand: <span class="tok-type">u64</span>,</span>
<span class="line" id="L444">    lanes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L445">    segments: <span class="tok-type">u32</span>,</span>
<span class="line" id="L446">    threads: <span class="tok-type">u24</span>,</span>
<span class="line" id="L447">    n: <span class="tok-type">u32</span>,</span>
<span class="line" id="L448">    slice: <span class="tok-type">u32</span>,</span>
<span class="line" id="L449">    lane: <span class="tok-type">u24</span>,</span>
<span class="line" id="L450">    index: <span class="tok-type">u32</span>,</span>
<span class="line" id="L451">) <span class="tok-type">u32</span> {</span>
<span class="line" id="L452">    <span class="tok-kw">var</span> ref_lane = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, rand &gt;&gt; <span class="tok-number">32</span>) % threads;</span>
<span class="line" id="L453">    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span> <span class="tok-kw">and</span> slice == <span class="tok-number">0</span>) {</span>
<span class="line" id="L454">        ref_lane = lane;</span>
<span class="line" id="L455">    }</span>
<span class="line" id="L456">    <span class="tok-kw">var</span> m = <span class="tok-number">3</span> * segments;</span>
<span class="line" id="L457">    <span class="tok-kw">var</span> s = ((slice + <span class="tok-number">1</span>) % sync_points) * segments;</span>
<span class="line" id="L458">    <span class="tok-kw">if</span> (lane == ref_lane) {</span>
<span class="line" id="L459">        m += index;</span>
<span class="line" id="L460">    }</span>
<span class="line" id="L461">    <span class="tok-kw">if</span> (n == <span class="tok-number">0</span>) {</span>
<span class="line" id="L462">        m = slice * segments;</span>
<span class="line" id="L463">        s = <span class="tok-number">0</span>;</span>
<span class="line" id="L464">        <span class="tok-kw">if</span> (slice == <span class="tok-number">0</span> <span class="tok-kw">or</span> lane == ref_lane) {</span>
<span class="line" id="L465">            m += index;</span>
<span class="line" id="L466">        }</span>
<span class="line" id="L467">    }</span>
<span class="line" id="L468">    <span class="tok-kw">if</span> (index == <span class="tok-number">0</span> <span class="tok-kw">or</span> lane == ref_lane) {</span>
<span class="line" id="L469">        m -= <span class="tok-number">1</span>;</span>
<span class="line" id="L470">    }</span>
<span class="line" id="L471">    <span class="tok-kw">var</span> p = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, rand));</span>
<span class="line" id="L472">    p = (p * p) &gt;&gt; <span class="tok-number">32</span>;</span>
<span class="line" id="L473">    p = (p * m) &gt;&gt; <span class="tok-number">32</span>;</span>
<span class="line" id="L474">    <span class="tok-kw">return</span> ref_lane * lanes + <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, ((s + m - (p + <span class="tok-number">1</span>)) % lanes));</span>
<span class="line" id="L475">}</span>
<span class="line" id="L476"></span>
<span class="line" id="L477"><span class="tok-comment">/// Derives a key from the password, salt, and argon2 parameters.</span></span>
<span class="line" id="L478"><span class="tok-comment">///</span></span>
<span class="line" id="L479"><span class="tok-comment">/// Derived key has to be at least 4 bytes length.</span></span>
<span class="line" id="L480"><span class="tok-comment">///</span></span>
<span class="line" id="L481"><span class="tok-comment">/// Salt has to be at least 8 bytes length.</span></span>
<span class="line" id="L482"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kdf</span>(</span>
<span class="line" id="L483">    allocator: mem.Allocator,</span>
<span class="line" id="L484">    derived_key: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L485">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L486">    salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L487">    params: Params,</span>
<span class="line" id="L488">    mode: Mode,</span>
<span class="line" id="L489">) KdfError!<span class="tok-type">void</span> {</span>
<span class="line" id="L490">    <span class="tok-kw">if</span> (derived_key.len &lt; <span class="tok-number">4</span>) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L491">    <span class="tok-kw">if</span> (derived_key.len &gt; max_int) <span class="tok-kw">return</span> KdfError.OutputTooLong;</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">    <span class="tok-kw">if</span> (password.len &gt; max_int) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L494">    <span class="tok-kw">if</span> (salt.len &lt; <span class="tok-number">8</span> <span class="tok-kw">or</span> salt.len &gt; max_int) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L495">    <span class="tok-kw">if</span> (params.t &lt; <span class="tok-number">1</span> <span class="tok-kw">or</span> params.p &lt; <span class="tok-number">1</span>) <span class="tok-kw">return</span> KdfError.WeakParameters;</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">    <span class="tok-kw">var</span> h0 = initHash(password, salt, params, derived_key.len, mode);</span>
<span class="line" id="L498">    <span class="tok-kw">const</span> memory = math.max(</span>
<span class="line" id="L499">        params.m / (sync_points * params.p) * (sync_points * params.p),</span>
<span class="line" id="L500">        <span class="tok-number">2</span> * sync_points * params.p,</span>
<span class="line" id="L501">    );</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">    <span class="tok-kw">var</span> blocks = <span class="tok-kw">try</span> Blocks.initCapacity(allocator, memory);</span>
<span class="line" id="L504">    <span class="tok-kw">defer</span> blocks.deinit();</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">    blocks.appendNTimesAssumeCapacity([_]<span class="tok-type">u64</span>{<span class="tok-number">0</span>} ** block_length, memory);</span>
<span class="line" id="L507"></span>
<span class="line" id="L508">    initBlocks(&amp;blocks, &amp;h0, memory, params.p);</span>
<span class="line" id="L509">    <span class="tok-kw">try</span> processBlocks(allocator, &amp;blocks, params.t, memory, params.p, mode);</span>
<span class="line" id="L510">    finalize(&amp;blocks, memory, params.p, derived_key);</span>
<span class="line" id="L511">}</span>
<span class="line" id="L512"></span>
<span class="line" id="L513"><span class="tok-kw">const</span> PhcFormatHasher = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L514">    <span class="tok-kw">const</span> BinValue = phc_format.BinValue;</span>
<span class="line" id="L515"></span>
<span class="line" id="L516">    <span class="tok-kw">const</span> HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L517">        alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L518">        alg_version: ?<span class="tok-type">u32</span>,</span>
<span class="line" id="L519">        m: <span class="tok-type">u32</span>,</span>
<span class="line" id="L520">        t: <span class="tok-type">u32</span>,</span>
<span class="line" id="L521">        p: <span class="tok-type">u24</span>,</span>
<span class="line" id="L522">        salt: BinValue(max_salt_len),</span>
<span class="line" id="L523">        hash: BinValue(max_hash_len),</span>
<span class="line" id="L524">    };</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L527">        allocator: mem.Allocator,</span>
<span class="line" id="L528">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L529">        params: Params,</span>
<span class="line" id="L530">        mode: Mode,</span>
<span class="line" id="L531">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L532">    ) HasherError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L533">        <span class="tok-kw">if</span> (params.secret != <span class="tok-null">null</span> <span class="tok-kw">or</span> params.ad != <span class="tok-null">null</span>) <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">        <span class="tok-kw">var</span> salt: [default_salt_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L536">        crypto.random.bytes(&amp;salt);</span>
<span class="line" id="L537"></span>
<span class="line" id="L538">        <span class="tok-kw">var</span> hash: [default_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L539">        <span class="tok-kw">try</span> kdf(allocator, &amp;hash, password, &amp;salt, params, mode);</span>
<span class="line" id="L540"></span>
<span class="line" id="L541">        <span class="tok-kw">return</span> phc_format.serialize(HashResult{</span>
<span class="line" id="L542">            .alg_id = <span class="tok-builtin">@tagName</span>(mode),</span>
<span class="line" id="L543">            .alg_version = version,</span>
<span class="line" id="L544">            .m = params.m,</span>
<span class="line" id="L545">            .t = params.t,</span>
<span class="line" id="L546">            .p = params.p,</span>
<span class="line" id="L547">            .salt = <span class="tok-kw">try</span> BinValue(max_salt_len).fromSlice(&amp;salt),</span>
<span class="line" id="L548">            .hash = <span class="tok-kw">try</span> BinValue(max_hash_len).fromSlice(&amp;hash),</span>
<span class="line" id="L549">        }, buf);</span>
<span class="line" id="L550">    }</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(</span>
<span class="line" id="L553">        allocator: mem.Allocator,</span>
<span class="line" id="L554">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L555">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L556">    ) HasherError!<span class="tok-type">void</span> {</span>
<span class="line" id="L557">        <span class="tok-kw">const</span> hash_result = <span class="tok-kw">try</span> phc_format.deserialize(HashResult, str);</span>
<span class="line" id="L558"></span>
<span class="line" id="L559">        <span class="tok-kw">const</span> mode = std.meta.stringToEnum(Mode, hash_result.alg_id) <span class="tok-kw">orelse</span></span>
<span class="line" id="L560">            <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L561">        <span class="tok-kw">if</span> (hash_result.alg_version) |v| {</span>
<span class="line" id="L562">            <span class="tok-kw">if</span> (v != version) <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L563">        }</span>
<span class="line" id="L564">        <span class="tok-kw">const</span> params = Params{ .t = hash_result.t, .m = hash_result.m, .p = hash_result.p };</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">        <span class="tok-kw">const</span> expected_hash = hash_result.hash.constSlice();</span>
<span class="line" id="L567">        <span class="tok-kw">var</span> hash_buf: [max_hash_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L568">        <span class="tok-kw">if</span> (expected_hash.len &gt; hash_buf.len) <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L569">        <span class="tok-kw">var</span> hash = hash_buf[<span class="tok-number">0</span>..expected_hash.len];</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">        <span class="tok-kw">try</span> kdf(allocator, hash, password, hash_result.salt.constSlice(), params, mode);</span>
<span class="line" id="L572">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hash, expected_hash)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L573">    }</span>
<span class="line" id="L574">};</span>
<span class="line" id="L575"></span>
<span class="line" id="L576"><span class="tok-comment">/// Options for hashing a password.</span></span>
<span class="line" id="L577"><span class="tok-comment">///</span></span>
<span class="line" id="L578"><span class="tok-comment">/// Allocator is required for argon2.</span></span>
<span class="line" id="L579"><span class="tok-comment">///</span></span>
<span class="line" id="L580"><span class="tok-comment">/// Only phc encoding is supported.</span></span>
<span class="line" id="L581"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L582">    allocator: ?mem.Allocator,</span>
<span class="line" id="L583">    params: Params,</span>
<span class="line" id="L584">    mode: Mode = .argon2id,</span>
<span class="line" id="L585">    encoding: pwhash.Encoding = .phc,</span>
<span class="line" id="L586">};</span>
<span class="line" id="L587"></span>
<span class="line" id="L588"><span class="tok-comment">/// Compute a hash of a password using the argon2 key derivation function.</span></span>
<span class="line" id="L589"><span class="tok-comment">/// The function returns a string that includes all the parameters required for verification.</span></span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strHash</span>(</span>
<span class="line" id="L591">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L592">    options: HashOptions,</span>
<span class="line" id="L593">    out: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L594">) Error![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L595">    <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.AllocatorRequired;</span>
<span class="line" id="L596">    <span class="tok-kw">switch</span> (options.encoding) {</span>
<span class="line" id="L597">        .phc =&gt; <span class="tok-kw">return</span> PhcFormatHasher.create(</span>
<span class="line" id="L598">            allocator,</span>
<span class="line" id="L599">            password,</span>
<span class="line" id="L600">            options.params,</span>
<span class="line" id="L601">            options.mode,</span>
<span class="line" id="L602">            out,</span>
<span class="line" id="L603">        ),</span>
<span class="line" id="L604">        .crypt =&gt; <span class="tok-kw">return</span> Error.InvalidEncoding,</span>
<span class="line" id="L605">    }</span>
<span class="line" id="L606">}</span>
<span class="line" id="L607"></span>
<span class="line" id="L608"><span class="tok-comment">/// Options for hash verification.</span></span>
<span class="line" id="L609"><span class="tok-comment">///</span></span>
<span class="line" id="L610"><span class="tok-comment">/// Allocator is required for argon2.</span></span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VerifyOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L612">    allocator: ?mem.Allocator,</span>
<span class="line" id="L613">};</span>
<span class="line" id="L614"></span>
<span class="line" id="L615"><span class="tok-comment">/// Verify that a previously computed hash is valid for a given password.</span></span>
<span class="line" id="L616"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strVerify</span>(</span>
<span class="line" id="L617">    str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L618">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L619">    options: VerifyOptions,</span>
<span class="line" id="L620">) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L621">    <span class="tok-kw">const</span> allocator = options.allocator <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> Error.AllocatorRequired;</span>
<span class="line" id="L622">    <span class="tok-kw">return</span> PhcFormatHasher.verify(allocator, str, password);</span>
<span class="line" id="L623">}</span>
<span class="line" id="L624"></span>
<span class="line" id="L625"><span class="tok-kw">test</span> <span class="tok-str">&quot;argon2d&quot;</span> {</span>
<span class="line" id="L626">    <span class="tok-kw">const</span> password = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x01</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L627">    <span class="tok-kw">const</span> salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x02</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L628">    <span class="tok-kw">const</span> secret = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x03</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L629">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x04</span>} ** <span class="tok-number">12</span>;</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">    <span class="tok-kw">var</span> dk: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L632">    <span class="tok-kw">try</span> kdf(</span>
<span class="line" id="L633">        std.testing.allocator,</span>
<span class="line" id="L634">        &amp;dk,</span>
<span class="line" id="L635">        &amp;password,</span>
<span class="line" id="L636">        &amp;salt,</span>
<span class="line" id="L637">        .{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span>, .secret = &amp;secret, .ad = &amp;ad },</span>
<span class="line" id="L638">        .argon2d,</span>
<span class="line" id="L639">    );</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">    <span class="tok-kw">const</span> want = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L642">        <span class="tok-number">0x51</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x6f</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x62</span>, <span class="tok-number">0x97</span>,</span>
<span class="line" id="L643">        <span class="tok-number">0x53</span>, <span class="tok-number">0x71</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x94</span>,</span>
<span class="line" id="L644">        <span class="tok-number">0xf8</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x39</span>, <span class="tok-number">0x84</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xc1</span>,</span>
<span class="line" id="L645">        <span class="tok-number">0xa1</span>, <span class="tok-number">0x3a</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0xb9</span>, <span class="tok-number">0xfa</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0xcb</span>,</span>
<span class="line" id="L646">    };</span>
<span class="line" id="L647">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;dk, &amp;want);</span>
<span class="line" id="L648">}</span>
<span class="line" id="L649"></span>
<span class="line" id="L650"><span class="tok-kw">test</span> <span class="tok-str">&quot;argon2i&quot;</span> {</span>
<span class="line" id="L651">    <span class="tok-kw">const</span> password = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x01</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L652">    <span class="tok-kw">const</span> salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x02</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L653">    <span class="tok-kw">const</span> secret = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x03</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L654">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x04</span>} ** <span class="tok-number">12</span>;</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">var</span> dk: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L657">    <span class="tok-kw">try</span> kdf(</span>
<span class="line" id="L658">        std.testing.allocator,</span>
<span class="line" id="L659">        &amp;dk,</span>
<span class="line" id="L660">        &amp;password,</span>
<span class="line" id="L661">        &amp;salt,</span>
<span class="line" id="L662">        .{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span>, .secret = &amp;secret, .ad = &amp;ad },</span>
<span class="line" id="L663">        .argon2i,</span>
<span class="line" id="L664">    );</span>
<span class="line" id="L665"></span>
<span class="line" id="L666">    <span class="tok-kw">const</span> want = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L667">        <span class="tok-number">0xc8</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0xd9</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0xaa</span>,</span>
<span class="line" id="L668">        <span class="tok-number">0x13</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0xd7</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0x24</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0xbd</span>, <span class="tok-number">0xa1</span>,</span>
<span class="line" id="L669">        <span class="tok-number">0xc8</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0xd2</span>,</span>
<span class="line" id="L670">        <span class="tok-number">0x99</span>, <span class="tok-number">0x52</span>, <span class="tok-number">0xa4</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0xe8</span>,</span>
<span class="line" id="L671">    };</span>
<span class="line" id="L672">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;dk, &amp;want);</span>
<span class="line" id="L673">}</span>
<span class="line" id="L674"></span>
<span class="line" id="L675"><span class="tok-kw">test</span> <span class="tok-str">&quot;argon2id&quot;</span> {</span>
<span class="line" id="L676">    <span class="tok-kw">const</span> password = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x01</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L677">    <span class="tok-kw">const</span> salt = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x02</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L678">    <span class="tok-kw">const</span> secret = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x03</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L679">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x04</span>} ** <span class="tok-number">12</span>;</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">    <span class="tok-kw">var</span> dk: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L682">    <span class="tok-kw">try</span> kdf(</span>
<span class="line" id="L683">        std.testing.allocator,</span>
<span class="line" id="L684">        &amp;dk,</span>
<span class="line" id="L685">        &amp;password,</span>
<span class="line" id="L686">        &amp;salt,</span>
<span class="line" id="L687">        .{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span>, .secret = &amp;secret, .ad = &amp;ad },</span>
<span class="line" id="L688">        .argon2id,</span>
<span class="line" id="L689">    );</span>
<span class="line" id="L690"></span>
<span class="line" id="L691">    <span class="tok-kw">const</span> want = [_]<span class="tok-type">u8</span>{</span>
<span class="line" id="L692">        <span class="tok-number">0x0d</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0x8d</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0x6c</span>,</span>
<span class="line" id="L693">        <span class="tok-number">0x08</span>, <span class="tok-number">0xc0</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0xa3</span>, <span class="tok-number">0x4a</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xc9</span>,</span>
<span class="line" id="L694">        <span class="tok-number">0xd0</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0xf0</span>, <span class="tok-number">0x45</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x5e</span>,</span>
<span class="line" id="L695">        <span class="tok-number">0xb5</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x59</span>,</span>
<span class="line" id="L696">    };</span>
<span class="line" id="L697">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;dk, &amp;want);</span>
<span class="line" id="L698">}</span>
<span class="line" id="L699"></span>
<span class="line" id="L700"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf&quot;</span> {</span>
<span class="line" id="L701">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;password&quot;</span>;</span>
<span class="line" id="L702">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;somesalt&quot;</span>;</span>
<span class="line" id="L703"></span>
<span class="line" id="L704">    <span class="tok-kw">const</span> TestVector = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L705">        mode: Mode,</span>
<span class="line" id="L706">        time: <span class="tok-type">u32</span>,</span>
<span class="line" id="L707">        memory: <span class="tok-type">u32</span>,</span>
<span class="line" id="L708">        threads: <span class="tok-type">u8</span>,</span>
<span class="line" id="L709">        hash: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L710">    };</span>
<span class="line" id="L711">    <span class="tok-kw">const</span> test_vectors = [_]TestVector{</span>
<span class="line" id="L712">        .{</span>
<span class="line" id="L713">            .mode = .argon2i,</span>
<span class="line" id="L714">            .time = <span class="tok-number">1</span>,</span>
<span class="line" id="L715">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L716">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L717">            .hash = <span class="tok-str">&quot;b9c401d1844a67d50eae3967dc28870b22e508092e861a37&quot;</span>,</span>
<span class="line" id="L718">        },</span>
<span class="line" id="L719">        .{</span>
<span class="line" id="L720">            .mode = .argon2d,</span>
<span class="line" id="L721">            .time = <span class="tok-number">1</span>,</span>
<span class="line" id="L722">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L723">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L724">            .hash = <span class="tok-str">&quot;8727405fd07c32c78d64f547f24150d3f2e703a89f981a19&quot;</span>,</span>
<span class="line" id="L725">        },</span>
<span class="line" id="L726">        .{</span>
<span class="line" id="L727">            .mode = .argon2id,</span>
<span class="line" id="L728">            .time = <span class="tok-number">1</span>,</span>
<span class="line" id="L729">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L730">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L731">            .hash = <span class="tok-str">&quot;655ad15eac652dc59f7170a7332bf49b8469be1fdb9c28bb&quot;</span>,</span>
<span class="line" id="L732">        },</span>
<span class="line" id="L733">        .{</span>
<span class="line" id="L734">            .mode = .argon2i,</span>
<span class="line" id="L735">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L736">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L737">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L738">            .hash = <span class="tok-str">&quot;8cf3d8f76a6617afe35fac48eb0b7433a9a670ca4a07ed64&quot;</span>,</span>
<span class="line" id="L739">        },</span>
<span class="line" id="L740">        .{</span>
<span class="line" id="L741">            .mode = .argon2d,</span>
<span class="line" id="L742">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L743">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L744">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L745">            .hash = <span class="tok-str">&quot;3be9ec79a69b75d3752acb59a1fbb8b295a46529c48fbb75&quot;</span>,</span>
<span class="line" id="L746">        },</span>
<span class="line" id="L747">        .{</span>
<span class="line" id="L748">            .mode = .argon2id,</span>
<span class="line" id="L749">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L750">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L751">            .threads = <span class="tok-number">1</span>,</span>
<span class="line" id="L752">            .hash = <span class="tok-str">&quot;068d62b26455936aa6ebe60060b0a65870dbfa3ddf8d41f7&quot;</span>,</span>
<span class="line" id="L753">        },</span>
<span class="line" id="L754">        .{</span>
<span class="line" id="L755">            .mode = .argon2i,</span>
<span class="line" id="L756">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L757">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L758">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L759">            .hash = <span class="tok-str">&quot;2089f3e78a799720f80af806553128f29b132cafe40d059f&quot;</span>,</span>
<span class="line" id="L760">        },</span>
<span class="line" id="L761">        .{</span>
<span class="line" id="L762">            .mode = .argon2d,</span>
<span class="line" id="L763">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L764">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L765">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L766">            .hash = <span class="tok-str">&quot;68e2462c98b8bc6bb60ec68db418ae2c9ed24fc6748a40e9&quot;</span>,</span>
<span class="line" id="L767">        },</span>
<span class="line" id="L768">        .{</span>
<span class="line" id="L769">            .mode = .argon2id,</span>
<span class="line" id="L770">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L771">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L772">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L773">            .hash = <span class="tok-str">&quot;350ac37222f436ccb5c0972f1ebd3bf6b958bf2071841362&quot;</span>,</span>
<span class="line" id="L774">        },</span>
<span class="line" id="L775">        .{</span>
<span class="line" id="L776">            .mode = .argon2i,</span>
<span class="line" id="L777">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L778">            .memory = <span class="tok-number">256</span>,</span>
<span class="line" id="L779">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L780">            .hash = <span class="tok-str">&quot;f5bbf5d4c3836af13193053155b73ec7476a6a2eb93fd5e6&quot;</span>,</span>
<span class="line" id="L781">        },</span>
<span class="line" id="L782">        .{</span>
<span class="line" id="L783">            .mode = .argon2d,</span>
<span class="line" id="L784">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L785">            .memory = <span class="tok-number">256</span>,</span>
<span class="line" id="L786">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L787">            .hash = <span class="tok-str">&quot;f4f0669218eaf3641f39cc97efb915721102f4b128211ef2&quot;</span>,</span>
<span class="line" id="L788">        },</span>
<span class="line" id="L789">        .{</span>
<span class="line" id="L790">            .mode = .argon2id,</span>
<span class="line" id="L791">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L792">            .memory = <span class="tok-number">256</span>,</span>
<span class="line" id="L793">            .threads = <span class="tok-number">2</span>,</span>
<span class="line" id="L794">            .hash = <span class="tok-str">&quot;4668d30ac4187e6878eedeacf0fd83c5a0a30db2cc16ef0b&quot;</span>,</span>
<span class="line" id="L795">        },</span>
<span class="line" id="L796">        .{</span>
<span class="line" id="L797">            .mode = .argon2i,</span>
<span class="line" id="L798">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L799">            .memory = <span class="tok-number">4096</span>,</span>
<span class="line" id="L800">            .threads = <span class="tok-number">4</span>,</span>
<span class="line" id="L801">            .hash = <span class="tok-str">&quot;a11f7b7f3f93f02ad4bddb59ab62d121e278369288a0d0e7&quot;</span>,</span>
<span class="line" id="L802">        },</span>
<span class="line" id="L803">        .{</span>
<span class="line" id="L804">            .mode = .argon2d,</span>
<span class="line" id="L805">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L806">            .memory = <span class="tok-number">4096</span>,</span>
<span class="line" id="L807">            .threads = <span class="tok-number">4</span>,</span>
<span class="line" id="L808">            .hash = <span class="tok-str">&quot;935598181aa8dc2b720914aa6435ac8d3e3a4210c5b0fb2d&quot;</span>,</span>
<span class="line" id="L809">        },</span>
<span class="line" id="L810">        .{</span>
<span class="line" id="L811">            .mode = .argon2id,</span>
<span class="line" id="L812">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L813">            .memory = <span class="tok-number">4096</span>,</span>
<span class="line" id="L814">            .threads = <span class="tok-number">4</span>,</span>
<span class="line" id="L815">            .hash = <span class="tok-str">&quot;145db9733a9f4ee43edf33c509be96b934d505a4efb33c5a&quot;</span>,</span>
<span class="line" id="L816">        },</span>
<span class="line" id="L817">        .{</span>
<span class="line" id="L818">            .mode = .argon2i,</span>
<span class="line" id="L819">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L820">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L821">            .threads = <span class="tok-number">8</span>,</span>
<span class="line" id="L822">            .hash = <span class="tok-str">&quot;0cdd3956aa35e6b475a7b0c63488822f774f15b43f6e6e17&quot;</span>,</span>
<span class="line" id="L823">        },</span>
<span class="line" id="L824">        .{</span>
<span class="line" id="L825">            .mode = .argon2d,</span>
<span class="line" id="L826">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L827">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L828">            .threads = <span class="tok-number">8</span>,</span>
<span class="line" id="L829">            .hash = <span class="tok-str">&quot;83604fc2ad0589b9d055578f4d3cc55bc616df3578a896e9&quot;</span>,</span>
<span class="line" id="L830">        },</span>
<span class="line" id="L831">        .{</span>
<span class="line" id="L832">            .mode = .argon2id,</span>
<span class="line" id="L833">            .time = <span class="tok-number">4</span>,</span>
<span class="line" id="L834">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L835">            .threads = <span class="tok-number">8</span>,</span>
<span class="line" id="L836">            .hash = <span class="tok-str">&quot;8dafa8e004f8ea96bf7c0f93eecf67a6047476143d15577f&quot;</span>,</span>
<span class="line" id="L837">        },</span>
<span class="line" id="L838">        .{</span>
<span class="line" id="L839">            .mode = .argon2i,</span>
<span class="line" id="L840">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L841">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L842">            .threads = <span class="tok-number">3</span>,</span>
<span class="line" id="L843">            .hash = <span class="tok-str">&quot;5cab452fe6b8479c8661def8cd703b611a3905a6d5477fe6&quot;</span>,</span>
<span class="line" id="L844">        },</span>
<span class="line" id="L845">        .{</span>
<span class="line" id="L846">            .mode = .argon2d,</span>
<span class="line" id="L847">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L848">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L849">            .threads = <span class="tok-number">3</span>,</span>
<span class="line" id="L850">            .hash = <span class="tok-str">&quot;22474a423bda2ccd36ec9afd5119e5c8949798cadf659f51&quot;</span>,</span>
<span class="line" id="L851">        },</span>
<span class="line" id="L852">        .{</span>
<span class="line" id="L853">            .mode = .argon2id,</span>
<span class="line" id="L854">            .time = <span class="tok-number">2</span>,</span>
<span class="line" id="L855">            .memory = <span class="tok-number">64</span>,</span>
<span class="line" id="L856">            .threads = <span class="tok-number">3</span>,</span>
<span class="line" id="L857">            .hash = <span class="tok-str">&quot;4a15b31aec7c2590b87d1f520be7d96f56658172deaa3079&quot;</span>,</span>
<span class="line" id="L858">        },</span>
<span class="line" id="L859">        .{</span>
<span class="line" id="L860">            .mode = .argon2i,</span>
<span class="line" id="L861">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L862">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L863">            .threads = <span class="tok-number">6</span>,</span>
<span class="line" id="L864">            .hash = <span class="tok-str">&quot;d236b29c2b2a09babee842b0dec6aa1e83ccbdea8023dced&quot;</span>,</span>
<span class="line" id="L865">        },</span>
<span class="line" id="L866">        .{</span>
<span class="line" id="L867">            .mode = .argon2d,</span>
<span class="line" id="L868">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L869">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L870">            .threads = <span class="tok-number">6</span>,</span>
<span class="line" id="L871">            .hash = <span class="tok-str">&quot;a3351b0319a53229152023d9206902f4ef59661cdca89481&quot;</span>,</span>
<span class="line" id="L872">        },</span>
<span class="line" id="L873">        .{</span>
<span class="line" id="L874">            .mode = .argon2id,</span>
<span class="line" id="L875">            .time = <span class="tok-number">3</span>,</span>
<span class="line" id="L876">            .memory = <span class="tok-number">1024</span>,</span>
<span class="line" id="L877">            .threads = <span class="tok-number">6</span>,</span>
<span class="line" id="L878">            .hash = <span class="tok-str">&quot;1640b932f4b60e272f5d2207b9a9c626ffa1bd88d2349016&quot;</span>,</span>
<span class="line" id="L879">        },</span>
<span class="line" id="L880">    };</span>
<span class="line" id="L881">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (test_vectors) |v| {</span>
<span class="line" id="L882">        <span class="tok-kw">var</span> want: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L883">        _ = <span class="tok-kw">try</span> std.fmt.hexToBytes(&amp;want, v.hash);</span>
<span class="line" id="L884"></span>
<span class="line" id="L885">        <span class="tok-kw">var</span> dk: [<span class="tok-number">24</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L886">        <span class="tok-kw">try</span> kdf(</span>
<span class="line" id="L887">            std.testing.allocator,</span>
<span class="line" id="L888">            &amp;dk,</span>
<span class="line" id="L889">            password,</span>
<span class="line" id="L890">            salt,</span>
<span class="line" id="L891">            .{ .t = v.time, .m = v.memory, .p = v.threads },</span>
<span class="line" id="L892">            v.mode,</span>
<span class="line" id="L893">        );</span>
<span class="line" id="L894"></span>
<span class="line" id="L895">        <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;dk, &amp;want);</span>
<span class="line" id="L896">    }</span>
<span class="line" id="L897">}</span>
<span class="line" id="L898"></span>
<span class="line" id="L899"><span class="tok-kw">test</span> <span class="tok-str">&quot;phc format hasher&quot;</span> {</span>
<span class="line" id="L900">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L901">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;testpass&quot;</span>;</span>
<span class="line" id="L902"></span>
<span class="line" id="L903">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L904">    <span class="tok-kw">const</span> hash = <span class="tok-kw">try</span> PhcFormatHasher.create(</span>
<span class="line" id="L905">        allocator,</span>
<span class="line" id="L906">        password,</span>
<span class="line" id="L907">        .{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span> },</span>
<span class="line" id="L908">        .argon2id,</span>
<span class="line" id="L909">        &amp;buf,</span>
<span class="line" id="L910">    );</span>
<span class="line" id="L911">    <span class="tok-kw">try</span> PhcFormatHasher.verify(allocator, hash, password);</span>
<span class="line" id="L912">}</span>
<span class="line" id="L913"></span>
<span class="line" id="L914"><span class="tok-kw">test</span> <span class="tok-str">&quot;password hash and password verify&quot;</span> {</span>
<span class="line" id="L915">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L916">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;testpass&quot;</span>;</span>
<span class="line" id="L917"></span>
<span class="line" id="L918">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L919">    <span class="tok-kw">const</span> hash = <span class="tok-kw">try</span> strHash(</span>
<span class="line" id="L920">        password,</span>
<span class="line" id="L921">        .{ .allocator = allocator, .params = .{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span> } },</span>
<span class="line" id="L922">        &amp;buf,</span>
<span class="line" id="L923">    );</span>
<span class="line" id="L924">    <span class="tok-kw">try</span> strVerify(hash, password, .{ .allocator = allocator });</span>
<span class="line" id="L925">}</span>
<span class="line" id="L926"></span>
<span class="line" id="L927"><span class="tok-kw">test</span> <span class="tok-str">&quot;kdf derived key length&quot;</span> {</span>
<span class="line" id="L928">    <span class="tok-kw">const</span> allocator = std.testing.allocator;</span>
<span class="line" id="L929"></span>
<span class="line" id="L930">    <span class="tok-kw">const</span> password = <span class="tok-str">&quot;testpass&quot;</span>;</span>
<span class="line" id="L931">    <span class="tok-kw">const</span> salt = <span class="tok-str">&quot;saltsalt&quot;</span>;</span>
<span class="line" id="L932">    <span class="tok-kw">const</span> params = Params{ .t = <span class="tok-number">3</span>, .m = <span class="tok-number">32</span>, .p = <span class="tok-number">4</span> };</span>
<span class="line" id="L933">    <span class="tok-kw">const</span> mode = Mode.argon2id;</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">    <span class="tok-kw">var</span> dk1: [<span class="tok-number">11</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L936">    <span class="tok-kw">try</span> kdf(allocator, &amp;dk1, password, salt, params, mode);</span>
<span class="line" id="L937"></span>
<span class="line" id="L938">    <span class="tok-kw">var</span> dk2: [<span class="tok-number">77</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L939">    <span class="tok-kw">try</span> kdf(allocator, &amp;dk2, password, salt, params, mode);</span>
<span class="line" id="L940"></span>
<span class="line" id="L941">    <span class="tok-kw">var</span> dk3: [<span class="tok-number">111</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L942">    <span class="tok-kw">try</span> kdf(allocator, &amp;dk3, password, salt, params, mode);</span>
<span class="line" id="L943">}</span>
<span class="line" id="L944"></span>
</code></pre></body>
</html>