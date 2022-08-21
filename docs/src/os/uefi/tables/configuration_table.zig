<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/tables/configuration_table.zig - source view</title>
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
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ConfigurationTable = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L5">    vendor_guid: Guid,</span>
<span class="line" id="L6">    vendor_table: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L7"></span>
<span class="line" id="L8">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> acpi_20_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L9">        .time_low = <span class="tok-number">0x8868e871</span>,</span>
<span class="line" id="L10">        .time_mid = <span class="tok-number">0xe4f1</span>,</span>
<span class="line" id="L11">        .time_high_and_version = <span class="tok-number">0x11d3</span>,</span>
<span class="line" id="L12">        .clock_seq_high_and_reserved = <span class="tok-number">0xbc</span>,</span>
<span class="line" id="L13">        .clock_seq_low = <span class="tok-number">0x22</span>,</span>
<span class="line" id="L14">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x3c</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x81</span> },</span>
<span class="line" id="L15">    };</span>
<span class="line" id="L16">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> acpi_10_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L17">        .time_low = <span class="tok-number">0xeb9d2d30</span>,</span>
<span class="line" id="L18">        .time_mid = <span class="tok-number">0x2d88</span>,</span>
<span class="line" id="L19">        .time_high_and_version = <span class="tok-number">0x11d3</span>,</span>
<span class="line" id="L20">        .clock_seq_high_and_reserved = <span class="tok-number">0x9a</span>,</span>
<span class="line" id="L21">        .clock_seq_low = <span class="tok-number">0x16</span>,</span>
<span class="line" id="L22">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x4d</span> },</span>
<span class="line" id="L23">    };</span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> sal_system_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L25">        .time_low = <span class="tok-number">0xeb9d2d32</span>,</span>
<span class="line" id="L26">        .time_mid = <span class="tok-number">0x2d88</span>,</span>
<span class="line" id="L27">        .time_high_and_version = <span class="tok-number">0x113d</span>,</span>
<span class="line" id="L28">        .clock_seq_high_and_reserved = <span class="tok-number">0x9a</span>,</span>
<span class="line" id="L29">        .clock_seq_low = <span class="tok-number">0x16</span>,</span>
<span class="line" id="L30">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x4d</span> },</span>
<span class="line" id="L31">    };</span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> smbios_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L33">        .time_low = <span class="tok-number">0xeb9d2d31</span>,</span>
<span class="line" id="L34">        .time_mid = <span class="tok-number">0x2d88</span>,</span>
<span class="line" id="L35">        .time_high_and_version = <span class="tok-number">0x11d3</span>,</span>
<span class="line" id="L36">        .clock_seq_high_and_reserved = <span class="tok-number">0x9a</span>,</span>
<span class="line" id="L37">        .clock_seq_low = <span class="tok-number">0x16</span>,</span>
<span class="line" id="L38">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x4d</span> },</span>
<span class="line" id="L39">    };</span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> smbios3_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L41">        .time_low = <span class="tok-number">0xf2fd1544</span>,</span>
<span class="line" id="L42">        .time_mid = <span class="tok-number">0x9794</span>,</span>
<span class="line" id="L43">        .time_high_and_version = <span class="tok-number">0x4a2c</span>,</span>
<span class="line" id="L44">        .clock_seq_high_and_reserved = <span class="tok-number">0x99</span>,</span>
<span class="line" id="L45">        .clock_seq_low = <span class="tok-number">0x2e</span>,</span>
<span class="line" id="L46">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xe5</span>, <span class="tok-number">0xbb</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0x94</span> },</span>
<span class="line" id="L47">    };</span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> mps_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L49">        .time_low = <span class="tok-number">0xeb9d2d2f</span>,</span>
<span class="line" id="L50">        .time_mid = <span class="tok-number">0x2d88</span>,</span>
<span class="line" id="L51">        .time_high_and_version = <span class="tok-number">0x11d3</span>,</span>
<span class="line" id="L52">        .clock_seq_high_and_reserved = <span class="tok-number">0x9a</span>,</span>
<span class="line" id="L53">        .clock_seq_low = <span class="tok-number">0x16</span>,</span>
<span class="line" id="L54">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x27</span>, <span class="tok-number">0x3f</span>, <span class="tok-number">0xc1</span>, <span class="tok-number">0x4d</span> },</span>
<span class="line" id="L55">    };</span>
<span class="line" id="L56">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> json_config_data_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L57">        .time_low = <span class="tok-number">0x87367f87</span>,</span>
<span class="line" id="L58">        .time_mid = <span class="tok-number">0x1119</span>,</span>
<span class="line" id="L59">        .time_high_and_version = <span class="tok-number">0x41ce</span>,</span>
<span class="line" id="L60">        .clock_seq_high_and_reserved = <span class="tok-number">0xaa</span>,</span>
<span class="line" id="L61">        .clock_seq_low = <span class="tok-number">0xec</span>,</span>
<span class="line" id="L62">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x8b</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x8a</span> },</span>
<span class="line" id="L63">    };</span>
<span class="line" id="L64">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> json_capsule_data_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L65">        .time_low = <span class="tok-number">0x35e7a725</span>,</span>
<span class="line" id="L66">        .time_mid = <span class="tok-number">0x8dd2</span>,</span>
<span class="line" id="L67">        .time_high_and_version = <span class="tok-number">0x4cac</span>,</span>
<span class="line" id="L68">        .clock_seq_high_and_reserved = <span class="tok-number">0x80</span>,</span>
<span class="line" id="L69">        .clock_seq_low = <span class="tok-number">0x11</span>,</span>
<span class="line" id="L70">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x33</span>, <span class="tok-number">0xcd</span>, <span class="tok-number">0xa8</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0x56</span> },</span>
<span class="line" id="L71">    };</span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> json_capsule_result_table_guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L73">        .time_low = <span class="tok-number">0xdbc461c3</span>,</span>
<span class="line" id="L74">        .time_mid = <span class="tok-number">0xb3de</span>,</span>
<span class="line" id="L75">        .time_high_and_version = <span class="tok-number">0x422a</span>,</span>
<span class="line" id="L76">        .clock_seq_high_and_reserved = <span class="tok-number">0xb9</span>,</span>
<span class="line" id="L77">        .clock_seq_low = <span class="tok-number">0xb4</span>,</span>
<span class="line" id="L78">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x98</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0xfd</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0xe5</span> },</span>
<span class="line" id="L79">    };</span>
<span class="line" id="L80">};</span>
<span class="line" id="L81"></span>
</code></pre></body>
</html>