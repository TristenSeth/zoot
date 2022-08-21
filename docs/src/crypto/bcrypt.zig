<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/bcrypt.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> pwhash = crypto.pwhash;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> Sha512 = crypto.hash.sha2.Sha512;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> utils = crypto.utils;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">const</span> phc_format = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;phc_encoding.zig&quot;</span>);</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> KdfError = pwhash.KdfError;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> HasherError = pwhash.HasherError;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> EncodingError = phc_format.Error;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> Error = pwhash.Error;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19"><span class="tok-kw">const</span> salt_length: <span class="tok-type">usize</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> salt_str_length: <span class="tok-type">usize</span> = <span class="tok-number">22</span>;</span>
<span class="line" id="L21"><span class="tok-kw">const</span> ct_str_length: <span class="tok-type">usize</span> = <span class="tok-number">31</span>;</span>
<span class="line" id="L22"><span class="tok-kw">const</span> ct_length: <span class="tok-type">usize</span> = <span class="tok-number">24</span>;</span>
<span class="line" id="L23"><span class="tok-kw">const</span> dk_length: <span class="tok-type">usize</span> = ct_length - <span class="tok-number">1</span>;</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-comment">/// Length (in bytes) of a password hash in crypt encoding</span></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hash_length: <span class="tok-type">usize</span> = <span class="tok-number">60</span>;</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> State = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L29">    sboxes: [<span class="tok-number">4</span>][<span class="tok-number">256</span>]<span class="tok-type">u32</span> = [<span class="tok-number">4</span>][<span class="tok-number">256</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L30">        .{</span>
<span class="line" id="L31">            <span class="tok-number">0xd1310ba6</span>, <span class="tok-number">0x98dfb5ac</span>, <span class="tok-number">0x2ffd72db</span>, <span class="tok-number">0xd01adfb7</span>,</span>
<span class="line" id="L32">            <span class="tok-number">0xb8e1afed</span>, <span class="tok-number">0x6a267e96</span>, <span class="tok-number">0xba7c9045</span>, <span class="tok-number">0xf12c7f99</span>,</span>
<span class="line" id="L33">            <span class="tok-number">0x24a19947</span>, <span class="tok-number">0xb3916cf7</span>, <span class="tok-number">0x0801f2e2</span>, <span class="tok-number">0x858efc16</span>,</span>
<span class="line" id="L34">            <span class="tok-number">0x636920d8</span>, <span class="tok-number">0x71574e69</span>, <span class="tok-number">0xa458fea3</span>, <span class="tok-number">0xf4933d7e</span>,</span>
<span class="line" id="L35">            <span class="tok-number">0x0d95748f</span>, <span class="tok-number">0x728eb658</span>, <span class="tok-number">0x718bcd58</span>, <span class="tok-number">0x82154aee</span>,</span>
<span class="line" id="L36">            <span class="tok-number">0x7b54a41d</span>, <span class="tok-number">0xc25a59b5</span>, <span class="tok-number">0x9c30d539</span>, <span class="tok-number">0x2af26013</span>,</span>
<span class="line" id="L37">            <span class="tok-number">0xc5d1b023</span>, <span class="tok-number">0x286085f0</span>, <span class="tok-number">0xca417918</span>, <span class="tok-number">0xb8db38ef</span>,</span>
<span class="line" id="L38">            <span class="tok-number">0x8e79dcb0</span>, <span class="tok-number">0x603a180e</span>, <span class="tok-number">0x6c9e0e8b</span>, <span class="tok-number">0xb01e8a3e</span>,</span>
<span class="line" id="L39">            <span class="tok-number">0xd71577c1</span>, <span class="tok-number">0xbd314b27</span>, <span class="tok-number">0x78af2fda</span>, <span class="tok-number">0x55605c60</span>,</span>
<span class="line" id="L40">            <span class="tok-number">0xe65525f3</span>, <span class="tok-number">0xaa55ab94</span>, <span class="tok-number">0x57489862</span>, <span class="tok-number">0x63e81440</span>,</span>
<span class="line" id="L41">            <span class="tok-number">0x55ca396a</span>, <span class="tok-number">0x2aab10b6</span>, <span class="tok-number">0xb4cc5c34</span>, <span class="tok-number">0x1141e8ce</span>,</span>
<span class="line" id="L42">            <span class="tok-number">0xa15486af</span>, <span class="tok-number">0x7c72e993</span>, <span class="tok-number">0xb3ee1411</span>, <span class="tok-number">0x636fbc2a</span>,</span>
<span class="line" id="L43">            <span class="tok-number">0x2ba9c55d</span>, <span class="tok-number">0x741831f6</span>, <span class="tok-number">0xce5c3e16</span>, <span class="tok-number">0x9b87931e</span>,</span>
<span class="line" id="L44">            <span class="tok-number">0xafd6ba33</span>, <span class="tok-number">0x6c24cf5c</span>, <span class="tok-number">0x7a325381</span>, <span class="tok-number">0x28958677</span>,</span>
<span class="line" id="L45">            <span class="tok-number">0x3b8f4898</span>, <span class="tok-number">0x6b4bb9af</span>, <span class="tok-number">0xc4bfe81b</span>, <span class="tok-number">0x66282193</span>,</span>
<span class="line" id="L46">            <span class="tok-number">0x61d809cc</span>, <span class="tok-number">0xfb21a991</span>, <span class="tok-number">0x487cac60</span>, <span class="tok-number">0x5dec8032</span>,</span>
<span class="line" id="L47">            <span class="tok-number">0xef845d5d</span>, <span class="tok-number">0xe98575b1</span>, <span class="tok-number">0xdc262302</span>, <span class="tok-number">0xeb651b88</span>,</span>
<span class="line" id="L48">            <span class="tok-number">0x23893e81</span>, <span class="tok-number">0xd396acc5</span>, <span class="tok-number">0x0f6d6ff3</span>, <span class="tok-number">0x83f44239</span>,</span>
<span class="line" id="L49">            <span class="tok-number">0x2e0b4482</span>, <span class="tok-number">0xa4842004</span>, <span class="tok-number">0x69c8f04a</span>, <span class="tok-number">0x9e1f9b5e</span>,</span>
<span class="line" id="L50">            <span class="tok-number">0x21c66842</span>, <span class="tok-number">0xf6e96c9a</span>, <span class="tok-number">0x670c9c61</span>, <span class="tok-number">0xabd388f0</span>,</span>
<span class="line" id="L51">            <span class="tok-number">0x6a51a0d2</span>, <span class="tok-number">0xd8542f68</span>, <span class="tok-number">0x960fa728</span>, <span class="tok-number">0xab5133a3</span>,</span>
<span class="line" id="L52">            <span class="tok-number">0x6eef0b6c</span>, <span class="tok-number">0x137a3be4</span>, <span class="tok-number">0xba3bf050</span>, <span class="tok-number">0x7efb2a98</span>,</span>
<span class="line" id="L53">            <span class="tok-number">0xa1f1651d</span>, <span class="tok-number">0x39af0176</span>, <span class="tok-number">0x66ca593e</span>, <span class="tok-number">0x82430e88</span>,</span>
<span class="line" id="L54">            <span class="tok-number">0x8cee8619</span>, <span class="tok-number">0x456f9fb4</span>, <span class="tok-number">0x7d84a5c3</span>, <span class="tok-number">0x3b8b5ebe</span>,</span>
<span class="line" id="L55">            <span class="tok-number">0xe06f75d8</span>, <span class="tok-number">0x85c12073</span>, <span class="tok-number">0x401a449f</span>, <span class="tok-number">0x56c16aa6</span>,</span>
<span class="line" id="L56">            <span class="tok-number">0x4ed3aa62</span>, <span class="tok-number">0x363f7706</span>, <span class="tok-number">0x1bfedf72</span>, <span class="tok-number">0x429b023d</span>,</span>
<span class="line" id="L57">            <span class="tok-number">0x37d0d724</span>, <span class="tok-number">0xd00a1248</span>, <span class="tok-number">0xdb0fead3</span>, <span class="tok-number">0x49f1c09b</span>,</span>
<span class="line" id="L58">            <span class="tok-number">0x075372c9</span>, <span class="tok-number">0x80991b7b</span>, <span class="tok-number">0x25d479d8</span>, <span class="tok-number">0xf6e8def7</span>,</span>
<span class="line" id="L59">            <span class="tok-number">0xe3fe501a</span>, <span class="tok-number">0xb6794c3b</span>, <span class="tok-number">0x976ce0bd</span>, <span class="tok-number">0x04c006ba</span>,</span>
<span class="line" id="L60">            <span class="tok-number">0xc1a94fb6</span>, <span class="tok-number">0x409f60c4</span>, <span class="tok-number">0x5e5c9ec2</span>, <span class="tok-number">0x196a2463</span>,</span>
<span class="line" id="L61">            <span class="tok-number">0x68fb6faf</span>, <span class="tok-number">0x3e6c53b5</span>, <span class="tok-number">0x1339b2eb</span>, <span class="tok-number">0x3b52ec6f</span>,</span>
<span class="line" id="L62">            <span class="tok-number">0x6dfc511f</span>, <span class="tok-number">0x9b30952c</span>, <span class="tok-number">0xcc814544</span>, <span class="tok-number">0xaf5ebd09</span>,</span>
<span class="line" id="L63">            <span class="tok-number">0xbee3d004</span>, <span class="tok-number">0xde334afd</span>, <span class="tok-number">0x660f2807</span>, <span class="tok-number">0x192e4bb3</span>,</span>
<span class="line" id="L64">            <span class="tok-number">0xc0cba857</span>, <span class="tok-number">0x45c8740f</span>, <span class="tok-number">0xd20b5f39</span>, <span class="tok-number">0xb9d3fbdb</span>,</span>
<span class="line" id="L65">            <span class="tok-number">0x5579c0bd</span>, <span class="tok-number">0x1a60320a</span>, <span class="tok-number">0xd6a100c6</span>, <span class="tok-number">0x402c7279</span>,</span>
<span class="line" id="L66">            <span class="tok-number">0x679f25fe</span>, <span class="tok-number">0xfb1fa3cc</span>, <span class="tok-number">0x8ea5e9f8</span>, <span class="tok-number">0xdb3222f8</span>,</span>
<span class="line" id="L67">            <span class="tok-number">0x3c7516df</span>, <span class="tok-number">0xfd616b15</span>, <span class="tok-number">0x2f501ec8</span>, <span class="tok-number">0xad0552ab</span>,</span>
<span class="line" id="L68">            <span class="tok-number">0x323db5fa</span>, <span class="tok-number">0xfd238760</span>, <span class="tok-number">0x53317b48</span>, <span class="tok-number">0x3e00df82</span>,</span>
<span class="line" id="L69">            <span class="tok-number">0x9e5c57bb</span>, <span class="tok-number">0xca6f8ca0</span>, <span class="tok-number">0x1a87562e</span>, <span class="tok-number">0xdf1769db</span>,</span>
<span class="line" id="L70">            <span class="tok-number">0xd542a8f6</span>, <span class="tok-number">0x287effc3</span>, <span class="tok-number">0xac6732c6</span>, <span class="tok-number">0x8c4f5573</span>,</span>
<span class="line" id="L71">            <span class="tok-number">0x695b27b0</span>, <span class="tok-number">0xbbca58c8</span>, <span class="tok-number">0xe1ffa35d</span>, <span class="tok-number">0xb8f011a0</span>,</span>
<span class="line" id="L72">            <span class="tok-number">0x10fa3d98</span>, <span class="tok-number">0xfd2183b8</span>, <span class="tok-number">0x4afcb56c</span>, <span class="tok-number">0x2dd1d35b</span>,</span>
<span class="line" id="L73">            <span class="tok-number">0x9a53e479</span>, <span class="tok-number">0xb6f84565</span>, <span class="tok-number">0xd28e49bc</span>, <span class="tok-number">0x4bfb9790</span>,</span>
<span class="line" id="L74">            <span class="tok-number">0xe1ddf2da</span>, <span class="tok-number">0xa4cb7e33</span>, <span class="tok-number">0x62fb1341</span>, <span class="tok-number">0xcee4c6e8</span>,</span>
<span class="line" id="L75">            <span class="tok-number">0xef20cada</span>, <span class="tok-number">0x36774c01</span>, <span class="tok-number">0xd07e9efe</span>, <span class="tok-number">0x2bf11fb4</span>,</span>
<span class="line" id="L76">            <span class="tok-number">0x95dbda4d</span>, <span class="tok-number">0xae909198</span>, <span class="tok-number">0xeaad8e71</span>, <span class="tok-number">0x6b93d5a0</span>,</span>
<span class="line" id="L77">            <span class="tok-number">0xd08ed1d0</span>, <span class="tok-number">0xafc725e0</span>, <span class="tok-number">0x8e3c5b2f</span>, <span class="tok-number">0x8e7594b7</span>,</span>
<span class="line" id="L78">            <span class="tok-number">0x8ff6e2fb</span>, <span class="tok-number">0xf2122b64</span>, <span class="tok-number">0x8888b812</span>, <span class="tok-number">0x900df01c</span>,</span>
<span class="line" id="L79">            <span class="tok-number">0x4fad5ea0</span>, <span class="tok-number">0x688fc31c</span>, <span class="tok-number">0xd1cff191</span>, <span class="tok-number">0xb3a8c1ad</span>,</span>
<span class="line" id="L80">            <span class="tok-number">0x2f2f2218</span>, <span class="tok-number">0xbe0e1777</span>, <span class="tok-number">0xea752dfe</span>, <span class="tok-number">0x8b021fa1</span>,</span>
<span class="line" id="L81">            <span class="tok-number">0xe5a0cc0f</span>, <span class="tok-number">0xb56f74e8</span>, <span class="tok-number">0x18acf3d6</span>, <span class="tok-number">0xce89e299</span>,</span>
<span class="line" id="L82">            <span class="tok-number">0xb4a84fe0</span>, <span class="tok-number">0xfd13e0b7</span>, <span class="tok-number">0x7cc43b81</span>, <span class="tok-number">0xd2ada8d9</span>,</span>
<span class="line" id="L83">            <span class="tok-number">0x165fa266</span>, <span class="tok-number">0x80957705</span>, <span class="tok-number">0x93cc7314</span>, <span class="tok-number">0x211a1477</span>,</span>
<span class="line" id="L84">            <span class="tok-number">0xe6ad2065</span>, <span class="tok-number">0x77b5fa86</span>, <span class="tok-number">0xc75442f5</span>, <span class="tok-number">0xfb9d35cf</span>,</span>
<span class="line" id="L85">            <span class="tok-number">0xebcdaf0c</span>, <span class="tok-number">0x7b3e89a0</span>, <span class="tok-number">0xd6411bd3</span>, <span class="tok-number">0xae1e7e49</span>,</span>
<span class="line" id="L86">            <span class="tok-number">0x00250e2d</span>, <span class="tok-number">0x2071b35e</span>, <span class="tok-number">0x226800bb</span>, <span class="tok-number">0x57b8e0af</span>,</span>
<span class="line" id="L87">            <span class="tok-number">0x2464369b</span>, <span class="tok-number">0xf009b91e</span>, <span class="tok-number">0x5563911d</span>, <span class="tok-number">0x59dfa6aa</span>,</span>
<span class="line" id="L88">            <span class="tok-number">0x78c14389</span>, <span class="tok-number">0xd95a537f</span>, <span class="tok-number">0x207d5ba2</span>, <span class="tok-number">0x02e5b9c5</span>,</span>
<span class="line" id="L89">            <span class="tok-number">0x83260376</span>, <span class="tok-number">0x6295cfa9</span>, <span class="tok-number">0x11c81968</span>, <span class="tok-number">0x4e734a41</span>,</span>
<span class="line" id="L90">            <span class="tok-number">0xb3472dca</span>, <span class="tok-number">0x7b14a94a</span>, <span class="tok-number">0x1b510052</span>, <span class="tok-number">0x9a532915</span>,</span>
<span class="line" id="L91">            <span class="tok-number">0xd60f573f</span>, <span class="tok-number">0xbc9bc6e4</span>, <span class="tok-number">0x2b60a476</span>, <span class="tok-number">0x81e67400</span>,</span>
<span class="line" id="L92">            <span class="tok-number">0x08ba6fb5</span>, <span class="tok-number">0x571be91f</span>, <span class="tok-number">0xf296ec6b</span>, <span class="tok-number">0x2a0dd915</span>,</span>
<span class="line" id="L93">            <span class="tok-number">0xb6636521</span>, <span class="tok-number">0xe7b9f9b6</span>, <span class="tok-number">0xff34052e</span>, <span class="tok-number">0xc5855664</span>,</span>
<span class="line" id="L94">            <span class="tok-number">0x53b02d5d</span>, <span class="tok-number">0xa99f8fa1</span>, <span class="tok-number">0x08ba4799</span>, <span class="tok-number">0x6e85076a</span>,</span>
<span class="line" id="L95">        },</span>
<span class="line" id="L96">        .{</span>
<span class="line" id="L97">            <span class="tok-number">0x4b7a70e9</span>, <span class="tok-number">0xb5b32944</span>, <span class="tok-number">0xdb75092e</span>, <span class="tok-number">0xc4192623</span>,</span>
<span class="line" id="L98">            <span class="tok-number">0xad6ea6b0</span>, <span class="tok-number">0x49a7df7d</span>, <span class="tok-number">0x9cee60b8</span>, <span class="tok-number">0x8fedb266</span>,</span>
<span class="line" id="L99">            <span class="tok-number">0xecaa8c71</span>, <span class="tok-number">0x699a17ff</span>, <span class="tok-number">0x5664526c</span>, <span class="tok-number">0xc2b19ee1</span>,</span>
<span class="line" id="L100">            <span class="tok-number">0x193602a5</span>, <span class="tok-number">0x75094c29</span>, <span class="tok-number">0xa0591340</span>, <span class="tok-number">0xe4183a3e</span>,</span>
<span class="line" id="L101">            <span class="tok-number">0x3f54989a</span>, <span class="tok-number">0x5b429d65</span>, <span class="tok-number">0x6b8fe4d6</span>, <span class="tok-number">0x99f73fd6</span>,</span>
<span class="line" id="L102">            <span class="tok-number">0xa1d29c07</span>, <span class="tok-number">0xefe830f5</span>, <span class="tok-number">0x4d2d38e6</span>, <span class="tok-number">0xf0255dc1</span>,</span>
<span class="line" id="L103">            <span class="tok-number">0x4cdd2086</span>, <span class="tok-number">0x8470eb26</span>, <span class="tok-number">0x6382e9c6</span>, <span class="tok-number">0x021ecc5e</span>,</span>
<span class="line" id="L104">            <span class="tok-number">0x09686b3f</span>, <span class="tok-number">0x3ebaefc9</span>, <span class="tok-number">0x3c971814</span>, <span class="tok-number">0x6b6a70a1</span>,</span>
<span class="line" id="L105">            <span class="tok-number">0x687f3584</span>, <span class="tok-number">0x52a0e286</span>, <span class="tok-number">0xb79c5305</span>, <span class="tok-number">0xaa500737</span>,</span>
<span class="line" id="L106">            <span class="tok-number">0x3e07841c</span>, <span class="tok-number">0x7fdeae5c</span>, <span class="tok-number">0x8e7d44ec</span>, <span class="tok-number">0x5716f2b8</span>,</span>
<span class="line" id="L107">            <span class="tok-number">0xb03ada37</span>, <span class="tok-number">0xf0500c0d</span>, <span class="tok-number">0xf01c1f04</span>, <span class="tok-number">0x0200b3ff</span>,</span>
<span class="line" id="L108">            <span class="tok-number">0xae0cf51a</span>, <span class="tok-number">0x3cb574b2</span>, <span class="tok-number">0x25837a58</span>, <span class="tok-number">0xdc0921bd</span>,</span>
<span class="line" id="L109">            <span class="tok-number">0xd19113f9</span>, <span class="tok-number">0x7ca92ff6</span>, <span class="tok-number">0x94324773</span>, <span class="tok-number">0x22f54701</span>,</span>
<span class="line" id="L110">            <span class="tok-number">0x3ae5e581</span>, <span class="tok-number">0x37c2dadc</span>, <span class="tok-number">0xc8b57634</span>, <span class="tok-number">0x9af3dda7</span>,</span>
<span class="line" id="L111">            <span class="tok-number">0xa9446146</span>, <span class="tok-number">0x0fd0030e</span>, <span class="tok-number">0xecc8c73e</span>, <span class="tok-number">0xa4751e41</span>,</span>
<span class="line" id="L112">            <span class="tok-number">0xe238cd99</span>, <span class="tok-number">0x3bea0e2f</span>, <span class="tok-number">0x3280bba1</span>, <span class="tok-number">0x183eb331</span>,</span>
<span class="line" id="L113">            <span class="tok-number">0x4e548b38</span>, <span class="tok-number">0x4f6db908</span>, <span class="tok-number">0x6f420d03</span>, <span class="tok-number">0xf60a04bf</span>,</span>
<span class="line" id="L114">            <span class="tok-number">0x2cb81290</span>, <span class="tok-number">0x24977c79</span>, <span class="tok-number">0x5679b072</span>, <span class="tok-number">0xbcaf89af</span>,</span>
<span class="line" id="L115">            <span class="tok-number">0xde9a771f</span>, <span class="tok-number">0xd9930810</span>, <span class="tok-number">0xb38bae12</span>, <span class="tok-number">0xdccf3f2e</span>,</span>
<span class="line" id="L116">            <span class="tok-number">0x5512721f</span>, <span class="tok-number">0x2e6b7124</span>, <span class="tok-number">0x501adde6</span>, <span class="tok-number">0x9f84cd87</span>,</span>
<span class="line" id="L117">            <span class="tok-number">0x7a584718</span>, <span class="tok-number">0x7408da17</span>, <span class="tok-number">0xbc9f9abc</span>, <span class="tok-number">0xe94b7d8c</span>,</span>
<span class="line" id="L118">            <span class="tok-number">0xec7aec3a</span>, <span class="tok-number">0xdb851dfa</span>, <span class="tok-number">0x63094366</span>, <span class="tok-number">0xc464c3d2</span>,</span>
<span class="line" id="L119">            <span class="tok-number">0xef1c1847</span>, <span class="tok-number">0x3215d908</span>, <span class="tok-number">0xdd433b37</span>, <span class="tok-number">0x24c2ba16</span>,</span>
<span class="line" id="L120">            <span class="tok-number">0x12a14d43</span>, <span class="tok-number">0x2a65c451</span>, <span class="tok-number">0x50940002</span>, <span class="tok-number">0x133ae4dd</span>,</span>
<span class="line" id="L121">            <span class="tok-number">0x71dff89e</span>, <span class="tok-number">0x10314e55</span>, <span class="tok-number">0x81ac77d6</span>, <span class="tok-number">0x5f11199b</span>,</span>
<span class="line" id="L122">            <span class="tok-number">0x043556f1</span>, <span class="tok-number">0xd7a3c76b</span>, <span class="tok-number">0x3c11183b</span>, <span class="tok-number">0x5924a509</span>,</span>
<span class="line" id="L123">            <span class="tok-number">0xf28fe6ed</span>, <span class="tok-number">0x97f1fbfa</span>, <span class="tok-number">0x9ebabf2c</span>, <span class="tok-number">0x1e153c6e</span>,</span>
<span class="line" id="L124">            <span class="tok-number">0x86e34570</span>, <span class="tok-number">0xeae96fb1</span>, <span class="tok-number">0x860e5e0a</span>, <span class="tok-number">0x5a3e2ab3</span>,</span>
<span class="line" id="L125">            <span class="tok-number">0x771fe71c</span>, <span class="tok-number">0x4e3d06fa</span>, <span class="tok-number">0x2965dcb9</span>, <span class="tok-number">0x99e71d0f</span>,</span>
<span class="line" id="L126">            <span class="tok-number">0x803e89d6</span>, <span class="tok-number">0x5266c825</span>, <span class="tok-number">0x2e4cc978</span>, <span class="tok-number">0x9c10b36a</span>,</span>
<span class="line" id="L127">            <span class="tok-number">0xc6150eba</span>, <span class="tok-number">0x94e2ea78</span>, <span class="tok-number">0xa5fc3c53</span>, <span class="tok-number">0x1e0a2df4</span>,</span>
<span class="line" id="L128">            <span class="tok-number">0xf2f74ea7</span>, <span class="tok-number">0x361d2b3d</span>, <span class="tok-number">0x1939260f</span>, <span class="tok-number">0x19c27960</span>,</span>
<span class="line" id="L129">            <span class="tok-number">0x5223a708</span>, <span class="tok-number">0xf71312b6</span>, <span class="tok-number">0xebadfe6e</span>, <span class="tok-number">0xeac31f66</span>,</span>
<span class="line" id="L130">            <span class="tok-number">0xe3bc4595</span>, <span class="tok-number">0xa67bc883</span>, <span class="tok-number">0xb17f37d1</span>, <span class="tok-number">0x018cff28</span>,</span>
<span class="line" id="L131">            <span class="tok-number">0xc332ddef</span>, <span class="tok-number">0xbe6c5aa5</span>, <span class="tok-number">0x65582185</span>, <span class="tok-number">0x68ab9802</span>,</span>
<span class="line" id="L132">            <span class="tok-number">0xeecea50f</span>, <span class="tok-number">0xdb2f953b</span>, <span class="tok-number">0x2aef7dad</span>, <span class="tok-number">0x5b6e2f84</span>,</span>
<span class="line" id="L133">            <span class="tok-number">0x1521b628</span>, <span class="tok-number">0x29076170</span>, <span class="tok-number">0xecdd4775</span>, <span class="tok-number">0x619f1510</span>,</span>
<span class="line" id="L134">            <span class="tok-number">0x13cca830</span>, <span class="tok-number">0xeb61bd96</span>, <span class="tok-number">0x0334fe1e</span>, <span class="tok-number">0xaa0363cf</span>,</span>
<span class="line" id="L135">            <span class="tok-number">0xb5735c90</span>, <span class="tok-number">0x4c70a239</span>, <span class="tok-number">0xd59e9e0b</span>, <span class="tok-number">0xcbaade14</span>,</span>
<span class="line" id="L136">            <span class="tok-number">0xeecc86bc</span>, <span class="tok-number">0x60622ca7</span>, <span class="tok-number">0x9cab5cab</span>, <span class="tok-number">0xb2f3846e</span>,</span>
<span class="line" id="L137">            <span class="tok-number">0x648b1eaf</span>, <span class="tok-number">0x19bdf0ca</span>, <span class="tok-number">0xa02369b9</span>, <span class="tok-number">0x655abb50</span>,</span>
<span class="line" id="L138">            <span class="tok-number">0x40685a32</span>, <span class="tok-number">0x3c2ab4b3</span>, <span class="tok-number">0x319ee9d5</span>, <span class="tok-number">0xc021b8f7</span>,</span>
<span class="line" id="L139">            <span class="tok-number">0x9b540b19</span>, <span class="tok-number">0x875fa099</span>, <span class="tok-number">0x95f7997e</span>, <span class="tok-number">0x623d7da8</span>,</span>
<span class="line" id="L140">            <span class="tok-number">0xf837889a</span>, <span class="tok-number">0x97e32d77</span>, <span class="tok-number">0x11ed935f</span>, <span class="tok-number">0x16681281</span>,</span>
<span class="line" id="L141">            <span class="tok-number">0x0e358829</span>, <span class="tok-number">0xc7e61fd6</span>, <span class="tok-number">0x96dedfa1</span>, <span class="tok-number">0x7858ba99</span>,</span>
<span class="line" id="L142">            <span class="tok-number">0x57f584a5</span>, <span class="tok-number">0x1b227263</span>, <span class="tok-number">0x9b83c3ff</span>, <span class="tok-number">0x1ac24696</span>,</span>
<span class="line" id="L143">            <span class="tok-number">0xcdb30aeb</span>, <span class="tok-number">0x532e3054</span>, <span class="tok-number">0x8fd948e4</span>, <span class="tok-number">0x6dbc3128</span>,</span>
<span class="line" id="L144">            <span class="tok-number">0x58ebf2ef</span>, <span class="tok-number">0x34c6ffea</span>, <span class="tok-number">0xfe28ed61</span>, <span class="tok-number">0xee7c3c73</span>,</span>
<span class="line" id="L145">            <span class="tok-number">0x5d4a14d9</span>, <span class="tok-number">0xe864b7e3</span>, <span class="tok-number">0x42105d14</span>, <span class="tok-number">0x203e13e0</span>,</span>
<span class="line" id="L146">            <span class="tok-number">0x45eee2b6</span>, <span class="tok-number">0xa3aaabea</span>, <span class="tok-number">0xdb6c4f15</span>, <span class="tok-number">0xfacb4fd0</span>,</span>
<span class="line" id="L147">            <span class="tok-number">0xc742f442</span>, <span class="tok-number">0xef6abbb5</span>, <span class="tok-number">0x654f3b1d</span>, <span class="tok-number">0x41cd2105</span>,</span>
<span class="line" id="L148">            <span class="tok-number">0xd81e799e</span>, <span class="tok-number">0x86854dc7</span>, <span class="tok-number">0xe44b476a</span>, <span class="tok-number">0x3d816250</span>,</span>
<span class="line" id="L149">            <span class="tok-number">0xcf62a1f2</span>, <span class="tok-number">0x5b8d2646</span>, <span class="tok-number">0xfc8883a0</span>, <span class="tok-number">0xc1c7b6a3</span>,</span>
<span class="line" id="L150">            <span class="tok-number">0x7f1524c3</span>, <span class="tok-number">0x69cb7492</span>, <span class="tok-number">0x47848a0b</span>, <span class="tok-number">0x5692b285</span>,</span>
<span class="line" id="L151">            <span class="tok-number">0x095bbf00</span>, <span class="tok-number">0xad19489d</span>, <span class="tok-number">0x1462b174</span>, <span class="tok-number">0x23820e00</span>,</span>
<span class="line" id="L152">            <span class="tok-number">0x58428d2a</span>, <span class="tok-number">0x0c55f5ea</span>, <span class="tok-number">0x1dadf43e</span>, <span class="tok-number">0x233f7061</span>,</span>
<span class="line" id="L153">            <span class="tok-number">0x3372f092</span>, <span class="tok-number">0x8d937e41</span>, <span class="tok-number">0xd65fecf1</span>, <span class="tok-number">0x6c223bdb</span>,</span>
<span class="line" id="L154">            <span class="tok-number">0x7cde3759</span>, <span class="tok-number">0xcbee7460</span>, <span class="tok-number">0x4085f2a7</span>, <span class="tok-number">0xce77326e</span>,</span>
<span class="line" id="L155">            <span class="tok-number">0xa6078084</span>, <span class="tok-number">0x19f8509e</span>, <span class="tok-number">0xe8efd855</span>, <span class="tok-number">0x61d99735</span>,</span>
<span class="line" id="L156">            <span class="tok-number">0xa969a7aa</span>, <span class="tok-number">0xc50c06c2</span>, <span class="tok-number">0x5a04abfc</span>, <span class="tok-number">0x800bcadc</span>,</span>
<span class="line" id="L157">            <span class="tok-number">0x9e447a2e</span>, <span class="tok-number">0xc3453484</span>, <span class="tok-number">0xfdd56705</span>, <span class="tok-number">0x0e1e9ec9</span>,</span>
<span class="line" id="L158">            <span class="tok-number">0xdb73dbd3</span>, <span class="tok-number">0x105588cd</span>, <span class="tok-number">0x675fda79</span>, <span class="tok-number">0xe3674340</span>,</span>
<span class="line" id="L159">            <span class="tok-number">0xc5c43465</span>, <span class="tok-number">0x713e38d8</span>, <span class="tok-number">0x3d28f89e</span>, <span class="tok-number">0xf16dff20</span>,</span>
<span class="line" id="L160">            <span class="tok-number">0x153e21e7</span>, <span class="tok-number">0x8fb03d4a</span>, <span class="tok-number">0xe6e39f2b</span>, <span class="tok-number">0xdb83adf7</span>,</span>
<span class="line" id="L161">        },</span>
<span class="line" id="L162">        .{</span>
<span class="line" id="L163">            <span class="tok-number">0xe93d5a68</span>, <span class="tok-number">0x948140f7</span>, <span class="tok-number">0xf64c261c</span>, <span class="tok-number">0x94692934</span>,</span>
<span class="line" id="L164">            <span class="tok-number">0x411520f7</span>, <span class="tok-number">0x7602d4f7</span>, <span class="tok-number">0xbcf46b2e</span>, <span class="tok-number">0xd4a20068</span>,</span>
<span class="line" id="L165">            <span class="tok-number">0xd4082471</span>, <span class="tok-number">0x3320f46a</span>, <span class="tok-number">0x43b7d4b7</span>, <span class="tok-number">0x500061af</span>,</span>
<span class="line" id="L166">            <span class="tok-number">0x1e39f62e</span>, <span class="tok-number">0x97244546</span>, <span class="tok-number">0x14214f74</span>, <span class="tok-number">0xbf8b8840</span>,</span>
<span class="line" id="L167">            <span class="tok-number">0x4d95fc1d</span>, <span class="tok-number">0x96b591af</span>, <span class="tok-number">0x70f4ddd3</span>, <span class="tok-number">0x66a02f45</span>,</span>
<span class="line" id="L168">            <span class="tok-number">0xbfbc09ec</span>, <span class="tok-number">0x03bd9785</span>, <span class="tok-number">0x7fac6dd0</span>, <span class="tok-number">0x31cb8504</span>,</span>
<span class="line" id="L169">            <span class="tok-number">0x96eb27b3</span>, <span class="tok-number">0x55fd3941</span>, <span class="tok-number">0xda2547e6</span>, <span class="tok-number">0xabca0a9a</span>,</span>
<span class="line" id="L170">            <span class="tok-number">0x28507825</span>, <span class="tok-number">0x530429f4</span>, <span class="tok-number">0x0a2c86da</span>, <span class="tok-number">0xe9b66dfb</span>,</span>
<span class="line" id="L171">            <span class="tok-number">0x68dc1462</span>, <span class="tok-number">0xd7486900</span>, <span class="tok-number">0x680ec0a4</span>, <span class="tok-number">0x27a18dee</span>,</span>
<span class="line" id="L172">            <span class="tok-number">0x4f3ffea2</span>, <span class="tok-number">0xe887ad8c</span>, <span class="tok-number">0xb58ce006</span>, <span class="tok-number">0x7af4d6b6</span>,</span>
<span class="line" id="L173">            <span class="tok-number">0xaace1e7c</span>, <span class="tok-number">0xd3375fec</span>, <span class="tok-number">0xce78a399</span>, <span class="tok-number">0x406b2a42</span>,</span>
<span class="line" id="L174">            <span class="tok-number">0x20fe9e35</span>, <span class="tok-number">0xd9f385b9</span>, <span class="tok-number">0xee39d7ab</span>, <span class="tok-number">0x3b124e8b</span>,</span>
<span class="line" id="L175">            <span class="tok-number">0x1dc9faf7</span>, <span class="tok-number">0x4b6d1856</span>, <span class="tok-number">0x26a36631</span>, <span class="tok-number">0xeae397b2</span>,</span>
<span class="line" id="L176">            <span class="tok-number">0x3a6efa74</span>, <span class="tok-number">0xdd5b4332</span>, <span class="tok-number">0x6841e7f7</span>, <span class="tok-number">0xca7820fb</span>,</span>
<span class="line" id="L177">            <span class="tok-number">0xfb0af54e</span>, <span class="tok-number">0xd8feb397</span>, <span class="tok-number">0x454056ac</span>, <span class="tok-number">0xba489527</span>,</span>
<span class="line" id="L178">            <span class="tok-number">0x55533a3a</span>, <span class="tok-number">0x20838d87</span>, <span class="tok-number">0xfe6ba9b7</span>, <span class="tok-number">0xd096954b</span>,</span>
<span class="line" id="L179">            <span class="tok-number">0x55a867bc</span>, <span class="tok-number">0xa1159a58</span>, <span class="tok-number">0xcca92963</span>, <span class="tok-number">0x99e1db33</span>,</span>
<span class="line" id="L180">            <span class="tok-number">0xa62a4a56</span>, <span class="tok-number">0x3f3125f9</span>, <span class="tok-number">0x5ef47e1c</span>, <span class="tok-number">0x9029317c</span>,</span>
<span class="line" id="L181">            <span class="tok-number">0xfdf8e802</span>, <span class="tok-number">0x04272f70</span>, <span class="tok-number">0x80bb155c</span>, <span class="tok-number">0x05282ce3</span>,</span>
<span class="line" id="L182">            <span class="tok-number">0x95c11548</span>, <span class="tok-number">0xe4c66d22</span>, <span class="tok-number">0x48c1133f</span>, <span class="tok-number">0xc70f86dc</span>,</span>
<span class="line" id="L183">            <span class="tok-number">0x07f9c9ee</span>, <span class="tok-number">0x41041f0f</span>, <span class="tok-number">0x404779a4</span>, <span class="tok-number">0x5d886e17</span>,</span>
<span class="line" id="L184">            <span class="tok-number">0x325f51eb</span>, <span class="tok-number">0xd59bc0d1</span>, <span class="tok-number">0xf2bcc18f</span>, <span class="tok-number">0x41113564</span>,</span>
<span class="line" id="L185">            <span class="tok-number">0x257b7834</span>, <span class="tok-number">0x602a9c60</span>, <span class="tok-number">0xdff8e8a3</span>, <span class="tok-number">0x1f636c1b</span>,</span>
<span class="line" id="L186">            <span class="tok-number">0x0e12b4c2</span>, <span class="tok-number">0x02e1329e</span>, <span class="tok-number">0xaf664fd1</span>, <span class="tok-number">0xcad18115</span>,</span>
<span class="line" id="L187">            <span class="tok-number">0x6b2395e0</span>, <span class="tok-number">0x333e92e1</span>, <span class="tok-number">0x3b240b62</span>, <span class="tok-number">0xeebeb922</span>,</span>
<span class="line" id="L188">            <span class="tok-number">0x85b2a20e</span>, <span class="tok-number">0xe6ba0d99</span>, <span class="tok-number">0xde720c8c</span>, <span class="tok-number">0x2da2f728</span>,</span>
<span class="line" id="L189">            <span class="tok-number">0xd0127845</span>, <span class="tok-number">0x95b794fd</span>, <span class="tok-number">0x647d0862</span>, <span class="tok-number">0xe7ccf5f0</span>,</span>
<span class="line" id="L190">            <span class="tok-number">0x5449a36f</span>, <span class="tok-number">0x877d48fa</span>, <span class="tok-number">0xc39dfd27</span>, <span class="tok-number">0xf33e8d1e</span>,</span>
<span class="line" id="L191">            <span class="tok-number">0x0a476341</span>, <span class="tok-number">0x992eff74</span>, <span class="tok-number">0x3a6f6eab</span>, <span class="tok-number">0xf4f8fd37</span>,</span>
<span class="line" id="L192">            <span class="tok-number">0xa812dc60</span>, <span class="tok-number">0xa1ebddf8</span>, <span class="tok-number">0x991be14c</span>, <span class="tok-number">0xdb6e6b0d</span>,</span>
<span class="line" id="L193">            <span class="tok-number">0xc67b5510</span>, <span class="tok-number">0x6d672c37</span>, <span class="tok-number">0x2765d43b</span>, <span class="tok-number">0xdcd0e804</span>,</span>
<span class="line" id="L194">            <span class="tok-number">0xf1290dc7</span>, <span class="tok-number">0xcc00ffa3</span>, <span class="tok-number">0xb5390f92</span>, <span class="tok-number">0x690fed0b</span>,</span>
<span class="line" id="L195">            <span class="tok-number">0x667b9ffb</span>, <span class="tok-number">0xcedb7d9c</span>, <span class="tok-number">0xa091cf0b</span>, <span class="tok-number">0xd9155ea3</span>,</span>
<span class="line" id="L196">            <span class="tok-number">0xbb132f88</span>, <span class="tok-number">0x515bad24</span>, <span class="tok-number">0x7b9479bf</span>, <span class="tok-number">0x763bd6eb</span>,</span>
<span class="line" id="L197">            <span class="tok-number">0x37392eb3</span>, <span class="tok-number">0xcc115979</span>, <span class="tok-number">0x8026e297</span>, <span class="tok-number">0xf42e312d</span>,</span>
<span class="line" id="L198">            <span class="tok-number">0x6842ada7</span>, <span class="tok-number">0xc66a2b3b</span>, <span class="tok-number">0x12754ccc</span>, <span class="tok-number">0x782ef11c</span>,</span>
<span class="line" id="L199">            <span class="tok-number">0x6a124237</span>, <span class="tok-number">0xb79251e7</span>, <span class="tok-number">0x06a1bbe6</span>, <span class="tok-number">0x4bfb6350</span>,</span>
<span class="line" id="L200">            <span class="tok-number">0x1a6b1018</span>, <span class="tok-number">0x11caedfa</span>, <span class="tok-number">0x3d25bdd8</span>, <span class="tok-number">0xe2e1c3c9</span>,</span>
<span class="line" id="L201">            <span class="tok-number">0x44421659</span>, <span class="tok-number">0x0a121386</span>, <span class="tok-number">0xd90cec6e</span>, <span class="tok-number">0xd5abea2a</span>,</span>
<span class="line" id="L202">            <span class="tok-number">0x64af674e</span>, <span class="tok-number">0xda86a85f</span>, <span class="tok-number">0xbebfe988</span>, <span class="tok-number">0x64e4c3fe</span>,</span>
<span class="line" id="L203">            <span class="tok-number">0x9dbc8057</span>, <span class="tok-number">0xf0f7c086</span>, <span class="tok-number">0x60787bf8</span>, <span class="tok-number">0x6003604d</span>,</span>
<span class="line" id="L204">            <span class="tok-number">0xd1fd8346</span>, <span class="tok-number">0xf6381fb0</span>, <span class="tok-number">0x7745ae04</span>, <span class="tok-number">0xd736fccc</span>,</span>
<span class="line" id="L205">            <span class="tok-number">0x83426b33</span>, <span class="tok-number">0xf01eab71</span>, <span class="tok-number">0xb0804187</span>, <span class="tok-number">0x3c005e5f</span>,</span>
<span class="line" id="L206">            <span class="tok-number">0x77a057be</span>, <span class="tok-number">0xbde8ae24</span>, <span class="tok-number">0x55464299</span>, <span class="tok-number">0xbf582e61</span>,</span>
<span class="line" id="L207">            <span class="tok-number">0x4e58f48f</span>, <span class="tok-number">0xf2ddfda2</span>, <span class="tok-number">0xf474ef38</span>, <span class="tok-number">0x8789bdc2</span>,</span>
<span class="line" id="L208">            <span class="tok-number">0x5366f9c3</span>, <span class="tok-number">0xc8b38e74</span>, <span class="tok-number">0xb475f255</span>, <span class="tok-number">0x46fcd9b9</span>,</span>
<span class="line" id="L209">            <span class="tok-number">0x7aeb2661</span>, <span class="tok-number">0x8b1ddf84</span>, <span class="tok-number">0x846a0e79</span>, <span class="tok-number">0x915f95e2</span>,</span>
<span class="line" id="L210">            <span class="tok-number">0x466e598e</span>, <span class="tok-number">0x20b45770</span>, <span class="tok-number">0x8cd55591</span>, <span class="tok-number">0xc902de4c</span>,</span>
<span class="line" id="L211">            <span class="tok-number">0xb90bace1</span>, <span class="tok-number">0xbb8205d0</span>, <span class="tok-number">0x11a86248</span>, <span class="tok-number">0x7574a99e</span>,</span>
<span class="line" id="L212">            <span class="tok-number">0xb77f19b6</span>, <span class="tok-number">0xe0a9dc09</span>, <span class="tok-number">0x662d09a1</span>, <span class="tok-number">0xc4324633</span>,</span>
<span class="line" id="L213">            <span class="tok-number">0xe85a1f02</span>, <span class="tok-number">0x09f0be8c</span>, <span class="tok-number">0x4a99a025</span>, <span class="tok-number">0x1d6efe10</span>,</span>
<span class="line" id="L214">            <span class="tok-number">0x1ab93d1d</span>, <span class="tok-number">0x0ba5a4df</span>, <span class="tok-number">0xa186f20f</span>, <span class="tok-number">0x2868f169</span>,</span>
<span class="line" id="L215">            <span class="tok-number">0xdcb7da83</span>, <span class="tok-number">0x573906fe</span>, <span class="tok-number">0xa1e2ce9b</span>, <span class="tok-number">0x4fcd7f52</span>,</span>
<span class="line" id="L216">            <span class="tok-number">0x50115e01</span>, <span class="tok-number">0xa70683fa</span>, <span class="tok-number">0xa002b5c4</span>, <span class="tok-number">0x0de6d027</span>,</span>
<span class="line" id="L217">            <span class="tok-number">0x9af88c27</span>, <span class="tok-number">0x773f8641</span>, <span class="tok-number">0xc3604c06</span>, <span class="tok-number">0x61a806b5</span>,</span>
<span class="line" id="L218">            <span class="tok-number">0xf0177a28</span>, <span class="tok-number">0xc0f586e0</span>, <span class="tok-number">0x006058aa</span>, <span class="tok-number">0x30dc7d62</span>,</span>
<span class="line" id="L219">            <span class="tok-number">0x11e69ed7</span>, <span class="tok-number">0x2338ea63</span>, <span class="tok-number">0x53c2dd94</span>, <span class="tok-number">0xc2c21634</span>,</span>
<span class="line" id="L220">            <span class="tok-number">0xbbcbee56</span>, <span class="tok-number">0x90bcb6de</span>, <span class="tok-number">0xebfc7da1</span>, <span class="tok-number">0xce591d76</span>,</span>
<span class="line" id="L221">            <span class="tok-number">0x6f05e409</span>, <span class="tok-number">0x4b7c0188</span>, <span class="tok-number">0x39720a3d</span>, <span class="tok-number">0x7c927c24</span>,</span>
<span class="line" id="L222">            <span class="tok-number">0x86e3725f</span>, <span class="tok-number">0x724d9db9</span>, <span class="tok-number">0x1ac15bb4</span>, <span class="tok-number">0xd39eb8fc</span>,</span>
<span class="line" id="L223">            <span class="tok-number">0xed545578</span>, <span class="tok-number">0x08fca5b5</span>, <span class="tok-number">0xd83d7cd3</span>, <span class="tok-number">0x4dad0fc4</span>,</span>
<span class="line" id="L224">            <span class="tok-number">0x1e50ef5e</span>, <span class="tok-number">0xb161e6f8</span>, <span class="tok-number">0xa28514d9</span>, <span class="tok-number">0x6c51133c</span>,</span>
<span class="line" id="L225">            <span class="tok-number">0x6fd5c7e7</span>, <span class="tok-number">0x56e14ec4</span>, <span class="tok-number">0x362abfce</span>, <span class="tok-number">0xddc6c837</span>,</span>
<span class="line" id="L226">            <span class="tok-number">0xd79a3234</span>, <span class="tok-number">0x92638212</span>, <span class="tok-number">0x670efa8e</span>, <span class="tok-number">0x406000e0</span>,</span>
<span class="line" id="L227">        },</span>
<span class="line" id="L228">        .{</span>
<span class="line" id="L229">            <span class="tok-number">0x3a39ce37</span>, <span class="tok-number">0xd3faf5cf</span>, <span class="tok-number">0xabc27737</span>, <span class="tok-number">0x5ac52d1b</span>,</span>
<span class="line" id="L230">            <span class="tok-number">0x5cb0679e</span>, <span class="tok-number">0x4fa33742</span>, <span class="tok-number">0xd3822740</span>, <span class="tok-number">0x99bc9bbe</span>,</span>
<span class="line" id="L231">            <span class="tok-number">0xd5118e9d</span>, <span class="tok-number">0xbf0f7315</span>, <span class="tok-number">0xd62d1c7e</span>, <span class="tok-number">0xc700c47b</span>,</span>
<span class="line" id="L232">            <span class="tok-number">0xb78c1b6b</span>, <span class="tok-number">0x21a19045</span>, <span class="tok-number">0xb26eb1be</span>, <span class="tok-number">0x6a366eb4</span>,</span>
<span class="line" id="L233">            <span class="tok-number">0x5748ab2f</span>, <span class="tok-number">0xbc946e79</span>, <span class="tok-number">0xc6a376d2</span>, <span class="tok-number">0x6549c2c8</span>,</span>
<span class="line" id="L234">            <span class="tok-number">0x530ff8ee</span>, <span class="tok-number">0x468dde7d</span>, <span class="tok-number">0xd5730a1d</span>, <span class="tok-number">0x4cd04dc6</span>,</span>
<span class="line" id="L235">            <span class="tok-number">0x2939bbdb</span>, <span class="tok-number">0xa9ba4650</span>, <span class="tok-number">0xac9526e8</span>, <span class="tok-number">0xbe5ee304</span>,</span>
<span class="line" id="L236">            <span class="tok-number">0xa1fad5f0</span>, <span class="tok-number">0x6a2d519a</span>, <span class="tok-number">0x63ef8ce2</span>, <span class="tok-number">0x9a86ee22</span>,</span>
<span class="line" id="L237">            <span class="tok-number">0xc089c2b8</span>, <span class="tok-number">0x43242ef6</span>, <span class="tok-number">0xa51e03aa</span>, <span class="tok-number">0x9cf2d0a4</span>,</span>
<span class="line" id="L238">            <span class="tok-number">0x83c061ba</span>, <span class="tok-number">0x9be96a4d</span>, <span class="tok-number">0x8fe51550</span>, <span class="tok-number">0xba645bd6</span>,</span>
<span class="line" id="L239">            <span class="tok-number">0x2826a2f9</span>, <span class="tok-number">0xa73a3ae1</span>, <span class="tok-number">0x4ba99586</span>, <span class="tok-number">0xef5562e9</span>,</span>
<span class="line" id="L240">            <span class="tok-number">0xc72fefd3</span>, <span class="tok-number">0xf752f7da</span>, <span class="tok-number">0x3f046f69</span>, <span class="tok-number">0x77fa0a59</span>,</span>
<span class="line" id="L241">            <span class="tok-number">0x80e4a915</span>, <span class="tok-number">0x87b08601</span>, <span class="tok-number">0x9b09e6ad</span>, <span class="tok-number">0x3b3ee593</span>,</span>
<span class="line" id="L242">            <span class="tok-number">0xe990fd5a</span>, <span class="tok-number">0x9e34d797</span>, <span class="tok-number">0x2cf0b7d9</span>, <span class="tok-number">0x022b8b51</span>,</span>
<span class="line" id="L243">            <span class="tok-number">0x96d5ac3a</span>, <span class="tok-number">0x017da67d</span>, <span class="tok-number">0xd1cf3ed6</span>, <span class="tok-number">0x7c7d2d28</span>,</span>
<span class="line" id="L244">            <span class="tok-number">0x1f9f25cf</span>, <span class="tok-number">0xadf2b89b</span>, <span class="tok-number">0x5ad6b472</span>, <span class="tok-number">0x5a88f54c</span>,</span>
<span class="line" id="L245">            <span class="tok-number">0xe029ac71</span>, <span class="tok-number">0xe019a5e6</span>, <span class="tok-number">0x47b0acfd</span>, <span class="tok-number">0xed93fa9b</span>,</span>
<span class="line" id="L246">            <span class="tok-number">0xe8d3c48d</span>, <span class="tok-number">0x283b57cc</span>, <span class="tok-number">0xf8d56629</span>, <span class="tok-number">0x79132e28</span>,</span>
<span class="line" id="L247">            <span class="tok-number">0x785f0191</span>, <span class="tok-number">0xed756055</span>, <span class="tok-number">0xf7960e44</span>, <span class="tok-number">0xe3d35e8c</span>,</span>
<span class="line" id="L248">            <span class="tok-number">0x15056dd4</span>, <span class="tok-number">0x88f46dba</span>, <span class="tok-number">0x03a16125</span>, <span class="tok-number">0x0564f0bd</span>,</span>
<span class="line" id="L249">            <span class="tok-number">0xc3eb9e15</span>, <span class="tok-number">0x3c9057a2</span>, <span class="tok-number">0x97271aec</span>, <span class="tok-number">0xa93a072a</span>,</span>
<span class="line" id="L250">            <span class="tok-number">0x1b3f6d9b</span>, <span class="tok-number">0x1e6321f5</span>, <span class="tok-number">0xf59c66fb</span>, <span class="tok-number">0x26dcf319</span>,</span>
<span class="line" id="L251">            <span class="tok-number">0x7533d928</span>, <span class="tok-number">0xb155fdf5</span>, <span class="tok-number">0x03563482</span>, <span class="tok-number">0x8aba3cbb</span>,</span>
<span class="line" id="L252">            <span class="tok-number">0x28517711</span>, <span class="tok-number">0xc20ad9f8</span>, <span class="tok-number">0xabcc5167</span>, <span class="tok-number">0xccad925f</span>,</span>
<span class="line" id="L253">            <span class="tok-number">0x4de81751</span>, <span class="tok-number">0x3830dc8e</span>, <span class="tok-number">0x379d5862</span>, <span class="tok-number">0x9320f991</span>,</span>
<span class="line" id="L254">            <span class="tok-number">0xea7a90c2</span>, <span class="tok-number">0xfb3e7bce</span>, <span class="tok-number">0x5121ce64</span>, <span class="tok-number">0x774fbe32</span>,</span>
<span class="line" id="L255">            <span class="tok-number">0xa8b6e37e</span>, <span class="tok-number">0xc3293d46</span>, <span class="tok-number">0x48de5369</span>, <span class="tok-number">0x6413e680</span>,</span>
<span class="line" id="L256">            <span class="tok-number">0xa2ae0810</span>, <span class="tok-number">0xdd6db224</span>, <span class="tok-number">0x69852dfd</span>, <span class="tok-number">0x09072166</span>,</span>
<span class="line" id="L257">            <span class="tok-number">0xb39a460a</span>, <span class="tok-number">0x6445c0dd</span>, <span class="tok-number">0x586cdecf</span>, <span class="tok-number">0x1c20c8ae</span>,</span>
<span class="line" id="L258">            <span class="tok-number">0x5bbef7dd</span>, <span class="tok-number">0x1b588d40</span>, <span class="tok-number">0xccd2017f</span>, <span class="tok-number">0x6bb4e3bb</span>,</span>
<span class="line" id="L259">            <span class="tok-number">0xdda26a7e</span>, <span class="tok-number">0x3a59ff45</span>, <span class="tok-number">0x3e350a44</span>, <span class="tok-number">0xbcb4cdd5</span>,</span>
<span class="line" id="L260">            <span class="tok-number">0x72eacea8</span>, <span class="tok-number">0xfa6484bb</span>, <span class="tok-number">0x8d6612ae</span>, <span class="tok-number">0xbf3c6f47</span>,</span>
<span class="line" id="L261">            <span class="tok-number">0xd29be463</span>, <span class="tok-number">0x542f5d9e</span>, <span class="tok-number">0xaec2771b</span>, <span class="tok-number">0xf64e6370</span>,</span>
<span class="line" id="L262">            <span class="tok-number">0x740e0d8d</span>, <span class="tok-number">0xe75b1357</span>, <span class="tok-number">0xf8721671</span>, <span class="tok-number">0xaf537d5d</span>,</span>
<span class="line" id="L263">            <span class="tok-number">0x4040cb08</span>, <span class="tok-number">0x4eb4e2cc</span>, <span class="tok-number">0x34d2466a</span>, <span class="tok-number">0x0115af84</span>,</span>
<span class="line" id="L264">            <span class="tok-number">0xe1b00428</span>, <span class="tok-number">0x95983a1d</span>, <span class="tok-number">0x06b89fb4</span>, <span class="tok-number">0xce6ea048</span>,</span>
<span class="line" id="L265">            <span class="tok-number">0x6f3f3b82</span>, <span class="tok-number">0x3520ab82</span>, <span class="tok-number">0x011a1d4b</span>, <span class="tok-number">0x277227f8</span>,</span>
<span class="line" id="L266">            <span class="tok-number">0x611560b1</span>, <span class="tok-number">0xe7933fdc</span>, <span class="tok-number">0xbb3a792b</span>, <span class="tok-number">0x344525bd</span>,</span>
<span class="line" id="L267">            <span class="tok-number">0xa08839e1</span>, <span class="tok-number">0x51ce794b</span>, <span class="tok-number">0x2f32c9b7</span>, <span class="tok-number">0xa01fbac9</span>,</span>
<span class="line" id="L268">            <span class="tok-number">0xe01cc87e</span>, <span class="tok-number">0xbcc7d1f6</span>, <span class="tok-number">0xcf0111c3</span>, <span class="tok-number">0xa1e8aac7</span>,</span>
<span class="line" id="L269">            <span class="tok-number">0x1a908749</span>, <span class="tok-number">0xd44fbd9a</span>, <span class="tok-number">0xd0dadecb</span>, <span class="tok-number">0xd50ada38</span>,</span>
<span class="line" id="L270">            <span class="tok-number">0x0339c32a</span>, <span class="tok-number">0xc6913667</span>, <span class="tok-number">0x8df9317c</span>, <span class="tok-number">0xe0b12b4f</span>,</span>
<span class="line" id="L271">            <span class="tok-number">0xf79e59b7</span>, <span class="tok-number">0x43f5bb3a</span>, <span class="tok-number">0xf2d519ff</span>, <span class="tok-number">0x27d9459c</span>,</span>
<span class="line" id="L272">            <span class="tok-number">0xbf97222c</span>, <span class="tok-number">0x15e6fc2a</span>, <span class="tok-number">0x0f91fc71</span>, <span class="tok-number">0x9b941525</span>,</span>
<span class="line" id="L273">            <span class="tok-number">0xfae59361</span>, <span class="tok-number">0xceb69ceb</span>, <span class="tok-number">0xc2a86459</span>, <span class="tok-number">0x12baa8d1</span>,</span>
<span class="line" id="L274">            <span class="tok-number">0xb6c1075e</span>, <span class="tok-number">0xe3056a0c</span>, <span class="tok-number">0x10d25065</span>, <span class="tok-number">0xcb03a442</span>,</span>
<span class="line" id="L275">            <span class="tok-number">0xe0ec6e0e</span>, <span class="tok-number">0x1698db3b</span>, <span class="tok-number">0x4c98a0be</span>, <span class="tok-number">0x3278e964</span>,</span>
<span class="line" id="L276">            <span class="tok-number">0x9f1f9532</span>, <span class="tok-number">0xe0d392df</span>, <span class="tok-number">0xd3a0342b</span>, <span class="tok-number">0x8971f21e</span>,</span>
<span class="line" id="L277">            <span class="tok-number">0x1b0a7441</span>, <span class="tok-number">0x4ba3348c</span>, <span class="tok-number">0xc5be7120</span>, <span class="tok-number">0xc37632d8</span>,</span>
<span class="line" id="L278">            <span class="tok-number">0xdf359f8d</span>, <span class="tok-number">0x9b992f2e</span>, <span class="tok-number">0xe60b6f47</span>, <span class="tok-number">0x0fe3f11d</span>,</span>
<span class="line" id="L279">            <span class="tok-number">0xe54cda54</span>, <span class="tok-number">0x1edad891</span>, <span class="tok-number">0xce6279cf</span>, <span class="tok-number">0xcd3e7e6f</span>,</span>
<span class="line" id="L280">            <span class="tok-number">0x1618b166</span>, <span class="tok-number">0xfd2c1d05</span>, <span class="tok-number">0x848fd2c5</span>, <span class="tok-number">0xf6fb2299</span>,</span>
<span class="line" id="L281">            <span class="tok-number">0xf523f357</span>, <span class="tok-number">0xa6327623</span>, <span class="tok-number">0x93a83531</span>, <span class="tok-number">0x56cccd02</span>,</span>
<span class="line" id="L282">            <span class="tok-number">0xacf08162</span>, <span class="tok-number">0x5a75ebb5</span>, <span class="tok-number">0x6e163697</span>, <span class="tok-number">0x88d273cc</span>,</span>
<span class="line" id="L283">            <span class="tok-number">0xde966292</span>, <span class="tok-number">0x81b949d0</span>, <span class="tok-number">0x4c50901b</span>, <span class="tok-number">0x71c65614</span>,</span>
<span class="line" id="L284">            <span class="tok-number">0xe6c6c7bd</span>, <span class="tok-number">0x327a140a</span>, <span class="tok-number">0x45e1d006</span>, <span class="tok-number">0xc3f27b9a</span>,</span>
<span class="line" id="L285">            <span class="tok-number">0xc9aa53fd</span>, <span class="tok-number">0x62a80f00</span>, <span class="tok-number">0xbb25bfe2</span>, <span class="tok-number">0x35bdd2f6</span>,</span>
<span class="line" id="L286">            <span class="tok-number">0x71126905</span>, <span class="tok-number">0xb2040222</span>, <span class="tok-number">0xb6cbcf7c</span>, <span class="tok-number">0xcd769c2b</span>,</span>
<span class="line" id="L287">            <span class="tok-number">0x53113ec0</span>, <span class="tok-number">0x1640e3d3</span>, <span class="tok-number">0x38abbd60</span>, <span class="tok-number">0x2547adf0</span>,</span>
<span class="line" id="L288">            <span class="tok-number">0xba38209c</span>, <span class="tok-number">0xf746ce76</span>, <span class="tok-number">0x77afa1c5</span>, <span class="tok-number">0x20756060</span>,</span>
<span class="line" id="L289">            <span class="tok-number">0x85cbfe4e</span>, <span class="tok-number">0x8ae88dd8</span>, <span class="tok-number">0x7aaaf9b0</span>, <span class="tok-number">0x4cf9aa7e</span>,</span>
<span class="line" id="L290">            <span class="tok-number">0x1948c25c</span>, <span class="tok-number">0x02fb8a8c</span>, <span class="tok-number">0x01c36ae4</span>, <span class="tok-number">0xd6ebe1f9</span>,</span>
<span class="line" id="L291">            <span class="tok-number">0x90d4f869</span>, <span class="tok-number">0xa65cdea0</span>, <span class="tok-number">0x3f09252d</span>, <span class="tok-number">0xc208e69f</span>,</span>
<span class="line" id="L292">            <span class="tok-number">0xb74e6132</span>, <span class="tok-number">0xce77e25b</span>, <span class="tok-number">0x578fdfe3</span>, <span class="tok-number">0x3ac372e6</span>,</span>
<span class="line" id="L293">        },</span>
<span class="line" id="L294">    },</span>
<span class="line" id="L295">    subkeys: [<span class="tok-number">18</span>]<span class="tok-type">u32</span> = [<span class="tok-number">18</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L296">        <span class="tok-number">0x243f6a88</span>, <span class="tok-number">0x85a308d3</span>, <span class="tok-number">0x13198a2e</span>,</span>
<span class="line" id="L297">        <span class="tok-number">0x03707344</span>, <span class="tok-number">0xa4093822</span>, <span class="tok-number">0x299f31d0</span>,</span>
<span class="line" id="L298">        <span class="tok-number">0x082efa98</span>, <span class="tok-number">0xec4e6c89</span>, <span class="tok-number">0x452821e6</span>,</span>
<span class="line" id="L299">        <span class="tok-number">0x38d01377</span>, <span class="tok-number">0xbe5466cf</span>, <span class="tok-number">0x34e90c6c</span>,</span>
<span class="line" id="L300">        <span class="tok-number">0xc0ac29b7</span>, <span class="tok-number">0xc97c50dd</span>, <span class="tok-number">0x3f84d5b5</span>,</span>
<span class="line" id="L301">        <span class="tok-number">0xb5470917</span>, <span class="tok-number">0x9216d5d9</span>, <span class="tok-number">0x8979fb1b</span>,</span>
<span class="line" id="L302">    },</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    <span class="tok-kw">fn</span> <span class="tok-fn">toWord</span>(data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, current: *<span class="tok-type">usize</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L305">        <span class="tok-kw">var</span> t: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L306">        <span class="tok-kw">var</span> j = current.*;</span>
<span class="line" id="L307">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L308">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L309">            <span class="tok-kw">if</span> (j &gt;= data.len) j = <span class="tok-number">0</span>;</span>
<span class="line" id="L310">            t = (t &lt;&lt; <span class="tok-number">8</span>) | data[j];</span>
<span class="line" id="L311">            j += <span class="tok-number">1</span>;</span>
<span class="line" id="L312">        }</span>
<span class="line" id="L313">        current.* = j;</span>
<span class="line" id="L314">        <span class="tok-kw">return</span> t;</span>
<span class="line" id="L315">    }</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-kw">fn</span> <span class="tok-fn">expand0</span>(state: *State, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L318">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L319">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L320">        <span class="tok-kw">while</span> (i &lt; state.subkeys.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L321">            state.subkeys[i] ^= toWord(key, &amp;j);</span>
<span class="line" id="L322">        }</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">        <span class="tok-kw">var</span> halves = Halves{ .l = <span class="tok-number">0</span>, .r = <span class="tok-number">0</span> };</span>
<span class="line" id="L325">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L326">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">18</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L327">            state.encipher(&amp;halves);</span>
<span class="line" id="L328">            state.subkeys[i] = halves.l;</span>
<span class="line" id="L329">            state.subkeys[i + <span class="tok-number">1</span>] = halves.r;</span>
<span class="line" id="L330">        }</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L333">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L334">            <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L335">            <span class="tok-kw">while</span> (k &lt; <span class="tok-number">256</span>) : (k += <span class="tok-number">2</span>) {</span>
<span class="line" id="L336">                state.encipher(&amp;halves);</span>
<span class="line" id="L337">                state.sboxes[i][k] = halves.l;</span>
<span class="line" id="L338">                state.sboxes[i][k + <span class="tok-number">1</span>] = halves.r;</span>
<span class="line" id="L339">            }</span>
<span class="line" id="L340">        }</span>
<span class="line" id="L341">    }</span>
<span class="line" id="L342"></span>
<span class="line" id="L343">    <span class="tok-kw">fn</span> <span class="tok-fn">expand</span>(state: *State, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L344">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L345">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L346">        <span class="tok-kw">while</span> (i &lt; state.subkeys.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L347">            state.subkeys[i] ^= toWord(key, &amp;j);</span>
<span class="line" id="L348">        }</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">        <span class="tok-kw">var</span> halves = Halves{ .l = <span class="tok-number">0</span>, .r = <span class="tok-number">0</span> };</span>
<span class="line" id="L351">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L352">        j = <span class="tok-number">0</span>;</span>
<span class="line" id="L353">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">18</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L354">            halves.l ^= toWord(data, &amp;j);</span>
<span class="line" id="L355">            halves.r ^= toWord(data, &amp;j);</span>
<span class="line" id="L356">            state.encipher(&amp;halves);</span>
<span class="line" id="L357">            state.subkeys[i] = halves.l;</span>
<span class="line" id="L358">            state.subkeys[i + <span class="tok-number">1</span>] = halves.r;</span>
<span class="line" id="L359">        }</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L362">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L363">            <span class="tok-kw">var</span> k: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L364">            <span class="tok-kw">while</span> (k &lt; <span class="tok-number">256</span>) : (k += <span class="tok-number">2</span>) {</span>
<span class="line" id="L365">                halves.l ^= toWord(data, &amp;j);</span>
<span class="line" id="L366">                halves.r ^= toWord(data, &amp;j);</span>
<span class="line" id="L367">                state.encipher(&amp;halves);</span>
<span class="line" id="L368">                state.sboxes[i][k] = halves.l;</span>
<span class="line" id="L369">                state.sboxes[i][k + <span class="tok-number">1</span>] = halves.r;</span>
<span class="line" id="L370">            }</span>
<span class="line" id="L371">        }</span>
<span class="line" id="L372">    }</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">    <span class="tok-kw">const</span> Halves = <span class="tok-kw">struct</span> { l: <span class="tok-type">u32</span>, r: <span class="tok-type">u32</span> };</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">    <span class="tok-kw">fn</span> <span class="tok-fn">feistelF</span>(state: State, x: <span class="tok-type">u32</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L377">        <span class="tok-kw">var</span> r = state.sboxes[<span class="tok-number">0</span>][<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">24</span>)];</span>
<span class="line" id="L378">        r +%= state.sboxes[<span class="tok-number">1</span>][<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">16</span>)];</span>
<span class="line" id="L379">        r ^= state.sboxes[<span class="tok-number">2</span>][<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x &gt;&gt; <span class="tok-number">8</span>)];</span>
<span class="line" id="L380">        r +%= state.sboxes[<span class="tok-number">3</span>][<span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, x)];</span>
<span class="line" id="L381">        <span class="tok-kw">return</span> r;</span>
<span class="line" id="L382">    }</span>
<span class="line" id="L383"></span>
<span class="line" id="L384">    <span class="tok-kw">fn</span> <span class="tok-fn">halfRound</span>(state: State, i: <span class="tok-type">u32</span>, j: <span class="tok-type">u32</span>, n: <span class="tok-type">usize</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L385">        <span class="tok-kw">return</span> i ^ state.feistelF(j) ^ state.subkeys[n];</span>
<span class="line" id="L386">    }</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">    <span class="tok-kw">fn</span> <span class="tok-fn">encipher</span>(state: State, halves: *Halves) <span class="tok-type">void</span> {</span>
<span class="line" id="L389">        halves.l ^= state.subkeys[<span class="tok-number">0</span>];</span>
<span class="line" id="L390">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L391">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L392">            halves.r = state.halfRound(halves.r, halves.l, i);</span>
<span class="line" id="L393">            halves.l = state.halfRound(halves.l, halves.r, i + <span class="tok-number">1</span>);</span>
<span class="line" id="L394">        }</span>
<span class="line" id="L395">        <span class="tok-kw">const</span> halves_last = Halves{ .l = halves.r ^ state.subkeys[i], .r = halves.l };</span>
<span class="line" id="L396">        halves.* = halves_last;</span>
<span class="line" id="L397">    }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">    <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(state: State, data: []<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L400">        debug.assert(data.len % <span class="tok-number">2</span> == <span class="tok-number">0</span>);</span>
<span class="line" id="L401">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L402">        <span class="tok-kw">while</span> (i &lt; data.len) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L403">            <span class="tok-kw">var</span> halves = Halves{ .l = data[i], .r = data[i + <span class="tok-number">1</span>] };</span>
<span class="line" id="L404">            state.encipher(&amp;halves);</span>
<span class="line" id="L405">            data[i] = halves.l;</span>
<span class="line" id="L406">            data[i + <span class="tok-number">1</span>] = halves.r;</span>
<span class="line" id="L407">        }</span>
<span class="line" id="L408">    }</span>
<span class="line" id="L409">};</span>
<span class="line" id="L410"></span>
<span class="line" id="L411"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Params = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L412">    rounds_log: <span class="tok-type">u6</span>,</span>
<span class="line" id="L413">};</span>
<span class="line" id="L414"></span>
<span class="line" id="L415"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bcrypt</span>(</span>
<span class="line" id="L416">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L417">    salt: [salt_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L418">    params: Params,</span>
<span class="line" id="L419">) [dk_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L420">    <span class="tok-kw">var</span> state = State{};</span>
<span class="line" id="L421">    <span class="tok-kw">var</span> password_buf: [<span class="tok-number">73</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L422">    <span class="tok-kw">const</span> trimmed_len = math.min(password.len, password_buf.len - <span class="tok-number">1</span>);</span>
<span class="line" id="L423">    mem.copy(<span class="tok-type">u8</span>, password_buf[<span class="tok-number">0</span>..], password[<span class="tok-number">0</span>..trimmed_len]);</span>
<span class="line" id="L424">    password_buf[trimmed_len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L425">    <span class="tok-kw">var</span> passwordZ = password_buf[<span class="tok-number">0</span> .. trimmed_len + <span class="tok-number">1</span>];</span>
<span class="line" id="L426">    state.expand(salt[<span class="tok-number">0</span>..], passwordZ);</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-kw">const</span> rounds: <span class="tok-type">u64</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>) &lt;&lt; params.rounds_log;</span>
<span class="line" id="L429">    <span class="tok-kw">var</span> k: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L430">    <span class="tok-kw">while</span> (k &lt; rounds) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L431">        state.expand0(passwordZ);</span>
<span class="line" id="L432">        state.expand0(salt[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L433">    }</span>
<span class="line" id="L434">    utils.secureZero(<span class="tok-type">u8</span>, &amp;password_buf);</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">    <span class="tok-kw">var</span> cdata = [<span class="tok-number">6</span>]<span class="tok-type">u32</span>{ <span class="tok-number">0x4f727068</span>, <span class="tok-number">0x65616e42</span>, <span class="tok-number">0x65686f6c</span>, <span class="tok-number">0x64657253</span>, <span class="tok-number">0x63727944</span>, <span class="tok-number">0x6f756274</span> }; <span class="tok-comment">// &quot;OrpheanBeholderScryDoubt&quot;</span>
</span>
<span class="line" id="L437">    k = <span class="tok-number">0</span>;</span>
<span class="line" id="L438">    <span class="tok-kw">while</span> (k &lt; <span class="tok-number">64</span>) : (k += <span class="tok-number">1</span>) {</span>
<span class="line" id="L439">        state.encrypt(&amp;cdata);</span>
<span class="line" id="L440">    }</span>
<span class="line" id="L441"></span>
<span class="line" id="L442">    <span class="tok-kw">var</span> ct: [ct_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L443">    <span class="tok-kw">for</span> (cdata) |c, i| {</span>
<span class="line" id="L444">        mem.writeIntBig(<span class="tok-type">u32</span>, ct[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], c);</span>
<span class="line" id="L445">    }</span>
<span class="line" id="L446">    <span class="tok-kw">return</span> ct[<span class="tok-number">0</span>..dk_length].*;</span>
<span class="line" id="L447">}</span>
<span class="line" id="L448"></span>
<span class="line" id="L449"><span class="tok-kw">const</span> pbkdf_prf = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L450">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L451">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> mac_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L452"></span>
<span class="line" id="L453">    hasher: Sha512,</span>
<span class="line" id="L454">    sha2pass: [Sha512.digest_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(out: *[mac_length]<span class="tok-type">u8</span>, msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L457">        <span class="tok-kw">var</span> ctx = Self.init(key);</span>
<span class="line" id="L458">        ctx.update(msg);</span>
<span class="line" id="L459">        ctx.final(out);</span>
<span class="line" id="L460">    }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Self {</span>
<span class="line" id="L463">        <span class="tok-kw">var</span> self: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L464">        self.hasher = Sha512.init(.{});</span>
<span class="line" id="L465">        Sha512.hash(key, &amp;self.sha2pass, .{});</span>
<span class="line" id="L466">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L467">    }</span>
<span class="line" id="L468"></span>
<span class="line" id="L469">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(self: *Self, msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L470">        self.hasher.update(msg);</span>
<span class="line" id="L471">    }</span>
<span class="line" id="L472"></span>
<span class="line" id="L473">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(self: *Self, out: *[mac_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L474">        <span class="tok-kw">var</span> sha2salt: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L475">        self.hasher.final(&amp;sha2salt);</span>
<span class="line" id="L476">        out.* = hash(self.sha2pass, sha2salt);</span>
<span class="line" id="L477">    }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">    <span class="tok-comment">/// Matches OpenBSD function</span></span>
<span class="line" id="L480">    <span class="tok-comment">/// https://github.com/openbsd/src/blob/6df1256b7792691e66c2ed9d86a8c103069f9e34/lib/libutil/bcrypt_pbkdf.c#L98</span></span>
<span class="line" id="L481">    <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(sha2pass: [Sha512.digest_length]<span class="tok-type">u8</span>, sha2salt: [Sha512.digest_length]<span class="tok-type">u8</span>) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L482">        <span class="tok-kw">var</span> cdata: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L483">        {</span>
<span class="line" id="L484">            <span class="tok-kw">const</span> ciphertext = <span class="tok-str">&quot;OxychromaticBlowfishSwatDynamite&quot;</span>;</span>
<span class="line" id="L485">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L486">            <span class="tok-kw">for</span> (cdata) |*v| {</span>
<span class="line" id="L487">                v.* = State.toWord(ciphertext, &amp;j);</span>
<span class="line" id="L488">            }</span>
<span class="line" id="L489">        }</span>
<span class="line" id="L490"></span>
<span class="line" id="L491">        <span class="tok-kw">var</span> state = State{};</span>
<span class="line" id="L492"></span>
<span class="line" id="L493">        { <span class="tok-comment">// key expansion</span>
</span>
<span class="line" id="L494">            state.expand(&amp;sha2salt, &amp;sha2pass);</span>
<span class="line" id="L495">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L496">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">64</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L497">                state.expand0(&amp;sha2salt);</span>
<span class="line" id="L498">                state.expand0(&amp;sha2pass);</span>
<span class="line" id="L499">            }</span>
<span class="line" id="L500">        }</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">        { <span class="tok-comment">// encryption</span>
</span>
<span class="line" id="L503">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L504">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">64</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L505">                state.encrypt(&amp;cdata);</span>
<span class="line" id="L506">            }</span>
<span class="line" id="L507">        }</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">        <span class="tok-comment">// copy out</span>
</span>
<span class="line" id="L510">        <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L511">        <span class="tok-kw">for</span> (cdata) |v, i| {</span>
<span class="line" id="L512">            std.mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], v);</span>
<span class="line" id="L513">        }</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">        <span class="tok-comment">// zap</span>
</span>
<span class="line" id="L516">        crypto.utils.secureZero(<span class="tok-type">u32</span>, &amp;cdata);</span>
<span class="line" id="L517">        crypto.utils.secureZero(State, <span class="tok-builtin">@as</span>(*[<span class="tok-number">1</span>]State, &amp;state));</span>
<span class="line" id="L518"></span>
<span class="line" id="L519">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L520">    }</span>
<span class="line" id="L521">};</span>
<span class="line" id="L522"></span>
<span class="line" id="L523"><span class="tok-comment">/// bcrypt PBKDF2 implementation with variations to match OpenBSD</span></span>
<span class="line" id="L524"><span class="tok-comment">/// https://github.com/openbsd/src/blob/6df1256b7792691e66c2ed9d86a8c103069f9e34/lib/libutil/bcrypt_pbkdf.c#L98</span></span>
<span class="line" id="L525"><span class="tok-comment">///</span></span>
<span class="line" id="L526"><span class="tok-comment">/// This particular variant is used in e.g. SSH</span></span>
<span class="line" id="L527"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">pbkdf</span>(pass: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: []<span class="tok-type">u8</span>, rounds: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L528">    <span class="tok-kw">try</span> crypto.pwhash.pbkdf2(key, pass, salt, rounds, pbkdf_prf);</span>
<span class="line" id="L529">}</span>
<span class="line" id="L530"></span>
<span class="line" id="L531"><span class="tok-kw">const</span> crypt_format = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L532">    <span class="tok-comment">/// String prefix for bcrypt</span></span>
<span class="line" id="L533">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> prefix = <span class="tok-str">&quot;$2&quot;</span>;</span>
<span class="line" id="L534"></span>
<span class="line" id="L535">    <span class="tok-comment">// bcrypt has its own variant of base64, with its own alphabet and no padding</span>
</span>
<span class="line" id="L536">    <span class="tok-kw">const</span> Codec = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L537">        <span class="tok-kw">const</span> alphabet = <span class="tok-str">&quot;./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789&quot;</span>;</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-kw">fn</span> <span class="tok-fn">encode</span>(b64: []<span class="tok-type">u8</span>, bin: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L540">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L541">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L542">            <span class="tok-kw">while</span> (i &lt; bin.len) {</span>
<span class="line" id="L543">                <span class="tok-kw">var</span> c1 = bin[i];</span>
<span class="line" id="L544">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L545">                b64[j] = alphabet[c1 &gt;&gt; <span class="tok-number">2</span>];</span>
<span class="line" id="L546">                j += <span class="tok-number">1</span>;</span>
<span class="line" id="L547">                c1 = (c1 &amp; <span class="tok-number">3</span>) &lt;&lt; <span class="tok-number">4</span>;</span>
<span class="line" id="L548">                <span class="tok-kw">if</span> (i &gt;= bin.len) {</span>
<span class="line" id="L549">                    b64[j] = alphabet[c1];</span>
<span class="line" id="L550">                    j += <span class="tok-number">1</span>;</span>
<span class="line" id="L551">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L552">                }</span>
<span class="line" id="L553">                <span class="tok-kw">var</span> c2 = bin[i];</span>
<span class="line" id="L554">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L555">                c1 |= (c2 &gt;&gt; <span class="tok-number">4</span>) &amp; <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L556">                b64[j] = alphabet[c1];</span>
<span class="line" id="L557">                j += <span class="tok-number">1</span>;</span>
<span class="line" id="L558">                c1 = (c2 &amp; <span class="tok-number">0x0f</span>) &lt;&lt; <span class="tok-number">2</span>;</span>
<span class="line" id="L559">                <span class="tok-kw">if</span> (i &gt;= bin.len) {</span>
<span class="line" id="L560">                    b64[j] = alphabet[c1];</span>
<span class="line" id="L561">                    j += <span class="tok-number">1</span>;</span>
<span class="line" id="L562">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L563">                }</span>
<span class="line" id="L564">                c2 = bin[i];</span>
<span class="line" id="L565">                i += <span class="tok-number">1</span>;</span>
<span class="line" id="L566">                c1 |= (c2 &gt;&gt; <span class="tok-number">6</span>) &amp; <span class="tok-number">3</span>;</span>
<span class="line" id="L567">                b64[j] = alphabet[c1];</span>
<span class="line" id="L568">                b64[j + <span class="tok-number">1</span>] = alphabet[c2 &amp; <span class="tok-number">0x3f</span>];</span>
<span class="line" id="L569">                j += <span class="tok-number">2</span>;</span>
<span class="line" id="L570">            }</span>
<span class="line" id="L571">            debug.assert(j == b64.len);</span>
<span class="line" id="L572">        }</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">        <span class="tok-kw">fn</span> <span class="tok-fn">decode</span>(bin: []<span class="tok-type">u8</span>, b64: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) EncodingError!<span class="tok-type">void</span> {</span>
<span class="line" id="L575">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L576">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L577">            <span class="tok-kw">while</span> (j &lt; bin.len) {</span>
<span class="line" id="L578">                <span class="tok-kw">const</span> c1 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, mem.indexOfScalar(<span class="tok-type">u8</span>, alphabet, b64[i]) <span class="tok-kw">orelse</span></span>
<span class="line" id="L579">                    <span class="tok-kw">return</span> EncodingError.InvalidEncoding);</span>
<span class="line" id="L580">                <span class="tok-kw">const</span> c2 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, mem.indexOfScalar(<span class="tok-type">u8</span>, alphabet, b64[i + <span class="tok-number">1</span>]) <span class="tok-kw">orelse</span></span>
<span class="line" id="L581">                    <span class="tok-kw">return</span> EncodingError.InvalidEncoding);</span>
<span class="line" id="L582">                bin[j] = (c1 &lt;&lt; <span class="tok-number">2</span>) | ((c2 &amp; <span class="tok-number">0x30</span>) &gt;&gt; <span class="tok-number">4</span>);</span>
<span class="line" id="L583">                j += <span class="tok-number">1</span>;</span>
<span class="line" id="L584">                <span class="tok-kw">if</span> (j &gt;= bin.len) {</span>
<span class="line" id="L585">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L586">                }</span>
<span class="line" id="L587">                <span class="tok-kw">const</span> c3 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, mem.indexOfScalar(<span class="tok-type">u8</span>, alphabet, b64[i + <span class="tok-number">2</span>]) <span class="tok-kw">orelse</span></span>
<span class="line" id="L588">                    <span class="tok-kw">return</span> EncodingError.InvalidEncoding);</span>
<span class="line" id="L589">                bin[j] = ((c2 &amp; <span class="tok-number">0x0f</span>) &lt;&lt; <span class="tok-number">4</span>) | ((c3 &amp; <span class="tok-number">0x3c</span>) &gt;&gt; <span class="tok-number">2</span>);</span>
<span class="line" id="L590">                j += <span class="tok-number">1</span>;</span>
<span class="line" id="L591">                <span class="tok-kw">if</span> (j &gt;= bin.len) {</span>
<span class="line" id="L592">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L593">                }</span>
<span class="line" id="L594">                <span class="tok-kw">const</span> c4 = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, mem.indexOfScalar(<span class="tok-type">u8</span>, alphabet, b64[i + <span class="tok-number">3</span>]) <span class="tok-kw">orelse</span></span>
<span class="line" id="L595">                    <span class="tok-kw">return</span> EncodingError.InvalidEncoding);</span>
<span class="line" id="L596">                bin[j] = ((c3 &amp; <span class="tok-number">0x03</span>) &lt;&lt; <span class="tok-number">6</span>) | c4;</span>
<span class="line" id="L597">                j += <span class="tok-number">1</span>;</span>
<span class="line" id="L598">                i += <span class="tok-number">4</span>;</span>
<span class="line" id="L599">            }</span>
<span class="line" id="L600">        }</span>
<span class="line" id="L601">    };</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">    <span class="tok-kw">fn</span> <span class="tok-fn">strHashInternal</span>(</span>
<span class="line" id="L604">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L605">        salt: [salt_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L606">        params: Params,</span>
<span class="line" id="L607">    ) [hash_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L608">        <span class="tok-kw">var</span> dk = bcrypt(password, salt, params);</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">        <span class="tok-kw">var</span> salt_str: [salt_str_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L611">        Codec.encode(salt_str[<span class="tok-number">0</span>..], salt[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L612"></span>
<span class="line" id="L613">        <span class="tok-kw">var</span> ct_str: [ct_str_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L614">        Codec.encode(ct_str[<span class="tok-number">0</span>..], dk[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">        <span class="tok-kw">var</span> s_buf: [hash_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L617">        <span class="tok-kw">const</span> s = fmt.bufPrint(</span>
<span class="line" id="L618">            s_buf[<span class="tok-number">0</span>..],</span>
<span class="line" id="L619">            <span class="tok-str">&quot;{s}b${d}{d}${s}{s}&quot;</span>,</span>
<span class="line" id="L620">            .{ prefix, params.rounds_log / <span class="tok-number">10</span>, params.rounds_log % <span class="tok-number">10</span>, salt_str, ct_str },</span>
<span class="line" id="L621">        ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L622">        debug.assert(s.len == s_buf.len);</span>
<span class="line" id="L623">        <span class="tok-kw">return</span> s_buf;</span>
<span class="line" id="L624">    }</span>
<span class="line" id="L625">};</span>
<span class="line" id="L626"></span>
<span class="line" id="L627"><span class="tok-comment">/// Hash and verify passwords using the PHC format.</span></span>
<span class="line" id="L628"><span class="tok-kw">const</span> PhcFormatHasher = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L629">    <span class="tok-kw">const</span> alg_id = <span class="tok-str">&quot;bcrypt&quot;</span>;</span>
<span class="line" id="L630">    <span class="tok-kw">const</span> BinValue = phc_format.BinValue;</span>
<span class="line" id="L631"></span>
<span class="line" id="L632">    <span class="tok-kw">const</span> HashResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L633">        alg_id: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L634">        r: <span class="tok-type">u6</span>,</span>
<span class="line" id="L635">        salt: BinValue(salt_length),</span>
<span class="line" id="L636">        hash: BinValue(dk_length),</span>
<span class="line" id="L637">    };</span>
<span class="line" id="L638"></span>
<span class="line" id="L639">    <span class="tok-comment">/// Return a non-deterministic hash of the password encoded as a PHC-format string</span></span>
<span class="line" id="L640">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L641">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L642">        params: Params,</span>
<span class="line" id="L643">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L644">    ) HasherError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L645">        <span class="tok-kw">var</span> salt: [salt_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L646">        crypto.random.bytes(&amp;salt);</span>
<span class="line" id="L647"></span>
<span class="line" id="L648">        <span class="tok-kw">const</span> hash = bcrypt(password, salt, params);</span>
<span class="line" id="L649"></span>
<span class="line" id="L650">        <span class="tok-kw">return</span> phc_format.serialize(HashResult{</span>
<span class="line" id="L651">            .alg_id = alg_id,</span>
<span class="line" id="L652">            .r = params.rounds_log,</span>
<span class="line" id="L653">            .salt = <span class="tok-kw">try</span> BinValue(salt_length).fromSlice(&amp;salt),</span>
<span class="line" id="L654">            .hash = <span class="tok-kw">try</span> BinValue(dk_length).fromSlice(&amp;hash),</span>
<span class="line" id="L655">        }, buf);</span>
<span class="line" id="L656">    }</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">    <span class="tok-comment">/// Verify a password against a PHC-format encoded string</span></span>
<span class="line" id="L659">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(</span>
<span class="line" id="L660">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L661">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L662">    ) HasherError!<span class="tok-type">void</span> {</span>
<span class="line" id="L663">        <span class="tok-kw">const</span> hash_result = <span class="tok-kw">try</span> phc_format.deserialize(HashResult, str);</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hash_result.alg_id, alg_id)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L666">        <span class="tok-kw">if</span> (hash_result.salt.len != salt_length <span class="tok-kw">or</span> hash_result.hash.len != dk_length)</span>
<span class="line" id="L667">            <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">        <span class="tok-kw">const</span> hash = bcrypt(password, hash_result.salt.buf, .{ .rounds_log = hash_result.r });</span>
<span class="line" id="L670">        <span class="tok-kw">const</span> expected_hash = hash_result.hash.constSlice();</span>
<span class="line" id="L671"></span>
<span class="line" id="L672">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, &amp;hash, expected_hash)) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L673">    }</span>
<span class="line" id="L674">};</span>
<span class="line" id="L675"></span>
<span class="line" id="L676"><span class="tok-comment">/// Hash and verify passwords using the modular crypt format.</span></span>
<span class="line" id="L677"><span class="tok-kw">const</span> CryptFormatHasher = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L678">    <span class="tok-comment">/// Length of a string returned by the create() function</span></span>
<span class="line" id="L679">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> pwhash_str_length: <span class="tok-type">usize</span> = hash_length;</span>
<span class="line" id="L680"></span>
<span class="line" id="L681">    <span class="tok-comment">/// Return a non-deterministic hash of the password encoded into the modular crypt format</span></span>
<span class="line" id="L682">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(</span>
<span class="line" id="L683">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L684">        params: Params,</span>
<span class="line" id="L685">        buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L686">    ) HasherError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L687">        <span class="tok-kw">if</span> (buf.len &lt; pwhash_str_length) <span class="tok-kw">return</span> HasherError.NoSpaceLeft;</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">        <span class="tok-kw">var</span> salt: [salt_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L690">        crypto.random.bytes(&amp;salt);</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">        <span class="tok-kw">const</span> hash = crypt_format.strHashInternal(password, salt, params);</span>
<span class="line" id="L693">        mem.copy(<span class="tok-type">u8</span>, buf, &amp;hash);</span>
<span class="line" id="L694"></span>
<span class="line" id="L695">        <span class="tok-kw">return</span> buf[<span class="tok-number">0</span>..pwhash_str_length];</span>
<span class="line" id="L696">    }</span>
<span class="line" id="L697"></span>
<span class="line" id="L698">    <span class="tok-comment">/// Verify a password against a string in modular crypt format</span></span>
<span class="line" id="L699">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(</span>
<span class="line" id="L700">        str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L701">        password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L702">    ) HasherError!<span class="tok-type">void</span> {</span>
<span class="line" id="L703">        <span class="tok-kw">if</span> (str.len != pwhash_str_length <span class="tok-kw">or</span> str[<span class="tok-number">3</span>] != <span class="tok-str">'$'</span> <span class="tok-kw">or</span> str[<span class="tok-number">6</span>] != <span class="tok-str">'$'</span>)</span>
<span class="line" id="L704">            <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">        <span class="tok-kw">const</span> rounds_log_str = str[<span class="tok-number">4</span>..][<span class="tok-number">0</span>..<span class="tok-number">2</span>];</span>
<span class="line" id="L707">        <span class="tok-kw">const</span> rounds_log = fmt.parseInt(<span class="tok-type">u6</span>, rounds_log_str[<span class="tok-number">0</span>..], <span class="tok-number">10</span>) <span class="tok-kw">catch</span></span>
<span class="line" id="L708">            <span class="tok-kw">return</span> HasherError.InvalidEncoding;</span>
<span class="line" id="L709"></span>
<span class="line" id="L710">        <span class="tok-kw">const</span> salt_str = str[<span class="tok-number">7</span>..][<span class="tok-number">0</span>..salt_str_length];</span>
<span class="line" id="L711">        <span class="tok-kw">var</span> salt: [salt_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L712">        <span class="tok-kw">try</span> crypt_format.Codec.decode(salt[<span class="tok-number">0</span>..], salt_str[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L713"></span>
<span class="line" id="L714">        <span class="tok-kw">const</span> wanted_s = crypt_format.strHashInternal(password, salt, .{ .rounds_log = rounds_log });</span>
<span class="line" id="L715">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, wanted_s[<span class="tok-number">0</span>..], str[<span class="tok-number">0</span>..])) <span class="tok-kw">return</span> HasherError.PasswordVerificationFailed;</span>
<span class="line" id="L716">    }</span>
<span class="line" id="L717">};</span>
<span class="line" id="L718"></span>
<span class="line" id="L719"><span class="tok-comment">/// Options for hashing a password.</span></span>
<span class="line" id="L720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L721">    allocator: ?mem.Allocator = <span class="tok-null">null</span>,</span>
<span class="line" id="L722">    params: Params,</span>
<span class="line" id="L723">    encoding: pwhash.Encoding,</span>
<span class="line" id="L724">};</span>
<span class="line" id="L725"></span>
<span class="line" id="L726"><span class="tok-comment">/// Compute a hash of a password using 2^rounds_log rounds of the bcrypt key stretching function.</span></span>
<span class="line" id="L727"><span class="tok-comment">/// bcrypt is a computationally expensive and cache-hard function, explicitly designed to slow down exhaustive searches.</span></span>
<span class="line" id="L728"><span class="tok-comment">///</span></span>
<span class="line" id="L729"><span class="tok-comment">/// The function returns a string that includes all the parameters required for verification.</span></span>
<span class="line" id="L730"><span class="tok-comment">///</span></span>
<span class="line" id="L731"><span class="tok-comment">/// IMPORTANT: by design, bcrypt silently truncates passwords to 72 bytes.</span></span>
<span class="line" id="L732"><span class="tok-comment">/// If this is an issue for your application, hash the password first using a function such as SHA-512,</span></span>
<span class="line" id="L733"><span class="tok-comment">/// and then use the resulting hash as the password parameter for bcrypt.</span></span>
<span class="line" id="L734"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strHash</span>(</span>
<span class="line" id="L735">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L736">    options: HashOptions,</span>
<span class="line" id="L737">    out: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L738">) Error![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L739">    <span class="tok-kw">switch</span> (options.encoding) {</span>
<span class="line" id="L740">        .phc =&gt; <span class="tok-kw">return</span> PhcFormatHasher.create(password, options.params, out),</span>
<span class="line" id="L741">        .crypt =&gt; <span class="tok-kw">return</span> CryptFormatHasher.create(password, options.params, out),</span>
<span class="line" id="L742">    }</span>
<span class="line" id="L743">}</span>
<span class="line" id="L744"></span>
<span class="line" id="L745"><span class="tok-comment">/// Options for hash verification.</span></span>
<span class="line" id="L746"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VerifyOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L747">    allocator: ?mem.Allocator = <span class="tok-null">null</span>,</span>
<span class="line" id="L748">};</span>
<span class="line" id="L749"></span>
<span class="line" id="L750"><span class="tok-comment">/// Verify that a previously computed hash is valid for a given password.</span></span>
<span class="line" id="L751"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">strVerify</span>(</span>
<span class="line" id="L752">    str: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L753">    password: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L754">    _: VerifyOptions,</span>
<span class="line" id="L755">) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L756">    <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, str, crypt_format.prefix)) {</span>
<span class="line" id="L757">        <span class="tok-kw">return</span> CryptFormatHasher.verify(str, password);</span>
<span class="line" id="L758">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L759">        <span class="tok-kw">return</span> PhcFormatHasher.verify(str, password);</span>
<span class="line" id="L760">    }</span>
<span class="line" id="L761">}</span>
<span class="line" id="L762"></span>
<span class="line" id="L763"><span class="tok-kw">test</span> <span class="tok-str">&quot;bcrypt codec&quot;</span> {</span>
<span class="line" id="L764">    <span class="tok-kw">var</span> salt: [salt_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L765">    crypto.random.bytes(&amp;salt);</span>
<span class="line" id="L766">    <span class="tok-kw">var</span> salt_str: [salt_str_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L767">    crypt_format.Codec.encode(salt_str[<span class="tok-number">0</span>..], salt[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L768">    <span class="tok-kw">var</span> salt2: [salt_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L769">    <span class="tok-kw">try</span> crypt_format.Codec.decode(salt2[<span class="tok-number">0</span>..], salt_str[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L770">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, salt[<span class="tok-number">0</span>..], salt2[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L771">}</span>
<span class="line" id="L772"></span>
<span class="line" id="L773"><span class="tok-kw">test</span> <span class="tok-str">&quot;bcrypt crypt format&quot;</span> {</span>
<span class="line" id="L774">    <span class="tok-kw">const</span> hash_options = HashOptions{</span>
<span class="line" id="L775">        .params = .{ .rounds_log = <span class="tok-number">5</span> },</span>
<span class="line" id="L776">        .encoding = .crypt,</span>
<span class="line" id="L777">    };</span>
<span class="line" id="L778">    <span class="tok-kw">const</span> verify_options = VerifyOptions{};</span>
<span class="line" id="L779"></span>
<span class="line" id="L780">    <span class="tok-kw">var</span> buf: [hash_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L781">    <span class="tok-kw">const</span> s = <span class="tok-kw">try</span> strHash(<span class="tok-str">&quot;password&quot;</span>, hash_options, &amp;buf);</span>
<span class="line" id="L782"></span>
<span class="line" id="L783">    <span class="tok-kw">try</span> testing.expect(mem.startsWith(<span class="tok-type">u8</span>, s, crypt_format.prefix));</span>
<span class="line" id="L784">    <span class="tok-kw">try</span> strVerify(s, <span class="tok-str">&quot;password&quot;</span>, verify_options);</span>
<span class="line" id="L785">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L786">        <span class="tok-kw">error</span>.PasswordVerificationFailed,</span>
<span class="line" id="L787">        strVerify(s, <span class="tok-str">&quot;invalid password&quot;</span>, verify_options),</span>
<span class="line" id="L788">    );</span>
<span class="line" id="L789"></span>
<span class="line" id="L790">    <span class="tok-kw">var</span> long_buf: [hash_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L791">    <span class="tok-kw">const</span> long_s = <span class="tok-kw">try</span> strHash(<span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">100</span>, hash_options, &amp;long_buf);</span>
<span class="line" id="L792"></span>
<span class="line" id="L793">    <span class="tok-kw">try</span> testing.expect(mem.startsWith(<span class="tok-type">u8</span>, long_s, crypt_format.prefix));</span>
<span class="line" id="L794">    <span class="tok-kw">try</span> strVerify(long_s, <span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">100</span>, verify_options);</span>
<span class="line" id="L795">    <span class="tok-kw">try</span> strVerify(long_s, <span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">101</span>, verify_options);</span>
<span class="line" id="L796"></span>
<span class="line" id="L797">    <span class="tok-kw">try</span> strVerify(</span>
<span class="line" id="L798">        <span class="tok-str">&quot;$2b$08$WUQKyBCaKpziCwUXHiMVvu40dYVjkTxtWJlftl0PpjY2BxWSvFIEe&quot;</span>,</span>
<span class="line" id="L799">        <span class="tok-str">&quot;The devil himself&quot;</span>,</span>
<span class="line" id="L800">        verify_options,</span>
<span class="line" id="L801">    );</span>
<span class="line" id="L802">}</span>
<span class="line" id="L803"></span>
<span class="line" id="L804"><span class="tok-kw">test</span> <span class="tok-str">&quot;bcrypt phc format&quot;</span> {</span>
<span class="line" id="L805">    <span class="tok-kw">const</span> hash_options = HashOptions{</span>
<span class="line" id="L806">        .params = .{ .rounds_log = <span class="tok-number">5</span> },</span>
<span class="line" id="L807">        .encoding = .phc,</span>
<span class="line" id="L808">    };</span>
<span class="line" id="L809">    <span class="tok-kw">const</span> verify_options = VerifyOptions{};</span>
<span class="line" id="L810">    <span class="tok-kw">const</span> prefix = <span class="tok-str">&quot;$bcrypt$&quot;</span>;</span>
<span class="line" id="L811"></span>
<span class="line" id="L812">    <span class="tok-kw">var</span> buf: [hash_length * <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L813">    <span class="tok-kw">const</span> s = <span class="tok-kw">try</span> strHash(<span class="tok-str">&quot;password&quot;</span>, hash_options, &amp;buf);</span>
<span class="line" id="L814"></span>
<span class="line" id="L815">    <span class="tok-kw">try</span> testing.expect(mem.startsWith(<span class="tok-type">u8</span>, s, prefix));</span>
<span class="line" id="L816">    <span class="tok-kw">try</span> strVerify(s, <span class="tok-str">&quot;password&quot;</span>, verify_options);</span>
<span class="line" id="L817">    <span class="tok-kw">try</span> testing.expectError(</span>
<span class="line" id="L818">        <span class="tok-kw">error</span>.PasswordVerificationFailed,</span>
<span class="line" id="L819">        strVerify(s, <span class="tok-str">&quot;invalid password&quot;</span>, verify_options),</span>
<span class="line" id="L820">    );</span>
<span class="line" id="L821"></span>
<span class="line" id="L822">    <span class="tok-kw">var</span> long_buf: [hash_length * <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L823">    <span class="tok-kw">const</span> long_s = <span class="tok-kw">try</span> strHash(<span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">100</span>, hash_options, &amp;long_buf);</span>
<span class="line" id="L824"></span>
<span class="line" id="L825">    <span class="tok-kw">try</span> testing.expect(mem.startsWith(<span class="tok-type">u8</span>, long_s, prefix));</span>
<span class="line" id="L826">    <span class="tok-kw">try</span> strVerify(long_s, <span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">100</span>, verify_options);</span>
<span class="line" id="L827">    <span class="tok-kw">try</span> strVerify(long_s, <span class="tok-str">&quot;password&quot;</span> ** <span class="tok-number">101</span>, verify_options);</span>
<span class="line" id="L828"></span>
<span class="line" id="L829">    <span class="tok-kw">try</span> strVerify(</span>
<span class="line" id="L830">        <span class="tok-str">&quot;$bcrypt$r=5$2NopntlgE2lX3cTwr4qz8A$r3T7iKYQNnY4hAhGjk9RmuyvgrYJZwc&quot;</span>,</span>
<span class="line" id="L831">        <span class="tok-str">&quot;The devil himself&quot;</span>,</span>
<span class="line" id="L832">        verify_options,</span>
<span class="line" id="L833">    );</span>
<span class="line" id="L834">}</span>
<span class="line" id="L835"></span>
</code></pre></body>
</html>