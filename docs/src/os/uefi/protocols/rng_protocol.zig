<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/rng_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.uefi;</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Random Number Generator protocol</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RNGProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L7">    _get_info: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> RNGProtocol, *<span class="tok-type">usize</span>, [*]<span class="tok-kw">align</span>(<span class="tok-number">8</span>) Guid) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L8">    _get_rng: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> RNGProtocol, ?*<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, <span class="tok-type">usize</span>, [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">    <span class="tok-comment">/// Returns information about the random number generation implementation.</span></span>
<span class="line" id="L11">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getInfo</span>(self: *<span class="tok-kw">const</span> RNGProtocol, list_size: *<span class="tok-type">usize</span>, list: [*]<span class="tok-kw">align</span>(<span class="tok-number">8</span>) Guid) Status {</span>
<span class="line" id="L12">        <span class="tok-kw">return</span> self._get_info(self, list_size, list);</span>
<span class="line" id="L13">    }</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-comment">/// Produces and returns an RNG value using either the default or specified RNG algorithm.</span></span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getRNG</span>(self: *<span class="tok-kw">const</span> RNGProtocol, algo: ?*<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, value_length: <span class="tok-type">usize</span>, value: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L17">        <span class="tok-kw">return</span> self._get_rng(self, algo, value_length, value);</span>
<span class="line" id="L18">    }</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L21">        .time_low = <span class="tok-number">0x3152bca5</span>,</span>
<span class="line" id="L22">        .time_mid = <span class="tok-number">0xeade</span>,</span>
<span class="line" id="L23">        .time_high_and_version = <span class="tok-number">0x433d</span>,</span>
<span class="line" id="L24">        .clock_seq_high_and_reserved = <span class="tok-number">0x86</span>,</span>
<span class="line" id="L25">        .clock_seq_low = <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L26">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xc0</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0xdc</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x44</span> },</span>
<span class="line" id="L27">    };</span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_sp800_90_hash_256 <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L29">        .time_low = <span class="tok-number">0xa7af67cb</span>,</span>
<span class="line" id="L30">        .time_mid = <span class="tok-number">0x603b</span>,</span>
<span class="line" id="L31">        .time_high_and_version = <span class="tok-number">0x4d42</span>,</span>
<span class="line" id="L32">        .clock_seq_high_and_reserved = <span class="tok-number">0xba</span>,</span>
<span class="line" id="L33">        .clock_seq_low = <span class="tok-number">0x21</span>,</span>
<span class="line" id="L34">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x70</span>, <span class="tok-number">0xbf</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x29</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0x96</span> },</span>
<span class="line" id="L35">    };</span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_sp800_90_hmac_256 <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L37">        .time_low = <span class="tok-number">0xc5149b43</span>,</span>
<span class="line" id="L38">        .time_mid = <span class="tok-number">0xae85</span>,</span>
<span class="line" id="L39">        .time_high_and_version = <span class="tok-number">0x4f53</span>,</span>
<span class="line" id="L40">        .clock_seq_high_and_reserved = <span class="tok-number">0x99</span>,</span>
<span class="line" id="L41">        .clock_seq_low = <span class="tok-number">0x82</span>,</span>
<span class="line" id="L42">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xb9</span>, <span class="tok-number">0x43</span>, <span class="tok-number">0x35</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0xa9</span>, <span class="tok-number">0xe7</span> },</span>
<span class="line" id="L43">    };</span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_sp800_90_ctr_256 <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L45">        .time_low = <span class="tok-number">0x44f0de6e</span>,</span>
<span class="line" id="L46">        .time_mid = <span class="tok-number">0x4d8c</span>,</span>
<span class="line" id="L47">        .time_high_and_version = <span class="tok-number">0x4045</span>,</span>
<span class="line" id="L48">        .clock_seq_high_and_reserved = <span class="tok-number">0xa8</span>,</span>
<span class="line" id="L49">        .clock_seq_low = <span class="tok-number">0xc7</span>,</span>
<span class="line" id="L50">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x4d</span>, <span class="tok-number">0xd1</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x6b</span>, <span class="tok-number">0x9e</span> },</span>
<span class="line" id="L51">    };</span>
<span class="line" id="L52">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_x9_31_3des <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L53">        .time_low = <span class="tok-number">0x63c4785a</span>,</span>
<span class="line" id="L54">        .time_mid = <span class="tok-number">0xca34</span>,</span>
<span class="line" id="L55">        .time_high_and_version = <span class="tok-number">0x4012</span>,</span>
<span class="line" id="L56">        .clock_seq_high_and_reserved = <span class="tok-number">0xa3</span>,</span>
<span class="line" id="L57">        .clock_seq_low = <span class="tok-number">0xc8</span>,</span>
<span class="line" id="L58">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x0b</span>, <span class="tok-number">0x6a</span>, <span class="tok-number">0x32</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x46</span> },</span>
<span class="line" id="L59">    };</span>
<span class="line" id="L60">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_x9_31_aes <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L61">        .time_low = <span class="tok-number">0xacd03321</span>,</span>
<span class="line" id="L62">        .time_mid = <span class="tok-number">0x777e</span>,</span>
<span class="line" id="L63">        .time_high_and_version = <span class="tok-number">0x4d3d</span>,</span>
<span class="line" id="L64">        .clock_seq_high_and_reserved = <span class="tok-number">0xb1</span>,</span>
<span class="line" id="L65">        .clock_seq_low = <span class="tok-number">0xc8</span>,</span>
<span class="line" id="L66">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x20</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0xd8</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xc9</span> },</span>
<span class="line" id="L67">    };</span>
<span class="line" id="L68">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> algorithm_raw <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L69">        .time_low = <span class="tok-number">0xe43176d7</span>,</span>
<span class="line" id="L70">        .time_mid = <span class="tok-number">0xb6e8</span>,</span>
<span class="line" id="L71">        .time_high_and_version = <span class="tok-number">0x4827</span>,</span>
<span class="line" id="L72">        .clock_seq_high_and_reserved = <span class="tok-number">0xb7</span>,</span>
<span class="line" id="L73">        .clock_seq_low = <span class="tok-number">0x84</span>,</span>
<span class="line" id="L74">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x7f</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0xb6</span>, <span class="tok-number">0x85</span>, <span class="tok-number">0x61</span> },</span>
<span class="line" id="L75">    };</span>
<span class="line" id="L76">};</span>
<span class="line" id="L77"></span>
</code></pre></body>
</html>