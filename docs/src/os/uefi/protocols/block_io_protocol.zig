<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/block_io_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> uefi = std.os.uefi;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">const</span> EfiBlockMedia = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L6">    <span class="tok-comment">/// The current media ID. If the media changes, this value is changed.</span></span>
<span class="line" id="L7">    media_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L8"></span>
<span class="line" id="L9">    <span class="tok-comment">/// `true` if the media is removable; otherwise, `false`.</span></span>
<span class="line" id="L10">    removable_media: <span class="tok-type">bool</span>,</span>
<span class="line" id="L11">    <span class="tok-comment">/// `true` if there is a media currently present in the device</span></span>
<span class="line" id="L12">    media_present: <span class="tok-type">bool</span>,</span>
<span class="line" id="L13">    <span class="tok-comment">/// `true` if the `BlockIoProtocol` was produced to abstract</span></span>
<span class="line" id="L14">    <span class="tok-comment">/// partition structures on the disk. `false` if the `BlockIoProtocol` was</span></span>
<span class="line" id="L15">    <span class="tok-comment">/// produced to abstract the logical blocks on a hardware device.</span></span>
<span class="line" id="L16">    logical_partition: <span class="tok-type">bool</span>,</span>
<span class="line" id="L17">    <span class="tok-comment">/// `true` if the media is marked read-only otherwise, `false`. This field</span></span>
<span class="line" id="L18">    <span class="tok-comment">/// shows the read-only status as of the most recent `WriteBlocks()`</span></span>
<span class="line" id="L19">    read_only: <span class="tok-type">bool</span>,</span>
<span class="line" id="L20">    <span class="tok-comment">/// `true` if the WriteBlocks() function caches write data.</span></span>
<span class="line" id="L21">    write_caching: <span class="tok-type">bool</span>,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// The intrinsic block size of the device. If the media changes, then this</span></span>
<span class="line" id="L24">    <span class="tok-comment">// field is updated. Returns the number of bytes per logical block.</span>
</span>
<span class="line" id="L25">    block_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L26">    <span class="tok-comment">/// Supplies the alignment requirement for any buffer used in a data</span></span>
<span class="line" id="L27">    <span class="tok-comment">/// transfer. IoAlign values of 0 and 1 mean that the buffer can be</span></span>
<span class="line" id="L28">    <span class="tok-comment">/// placed anywhere in memory. Otherwise, IoAlign must be a power of</span></span>
<span class="line" id="L29">    <span class="tok-comment">/// 2, and the requirement is that the start address of a buffer must be</span></span>
<span class="line" id="L30">    <span class="tok-comment">/// evenly divisible by IoAlign with no remainder.</span></span>
<span class="line" id="L31">    io_align: <span class="tok-type">u32</span>,</span>
<span class="line" id="L32">    <span class="tok-comment">/// The last LBA on the device. If the media changes, then this field is updated.</span></span>
<span class="line" id="L33">    last_block: <span class="tok-type">u64</span>,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">// Revision 2</span>
</span>
<span class="line" id="L36">    lowest_aligned_lba: <span class="tok-type">u64</span>,</span>
<span class="line" id="L37">    logical_blocks_per_physical_block: <span class="tok-type">u32</span>,</span>
<span class="line" id="L38">    optimal_transfer_length_granularity: <span class="tok-type">u32</span>,</span>
<span class="line" id="L39">};</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-kw">const</span> BlockIoProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L42">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    revision: <span class="tok-type">u64</span>,</span>
<span class="line" id="L45">    media: *EfiBlockMedia,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    _reset: <span class="tok-kw">fn</span> (*BlockIoProtocol, extended_verification: <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L48">    _read_blocks: <span class="tok-kw">fn</span> (*BlockIoProtocol, media_id: <span class="tok-type">u32</span>, lba: <span class="tok-type">u64</span>, buffer_size: <span class="tok-type">usize</span>, buf: [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L49">    _write_blocks: <span class="tok-kw">fn</span> (*BlockIoProtocol, media_id: <span class="tok-type">u32</span>, lba: <span class="tok-type">u64</span>, buffer_size: <span class="tok-type">usize</span>, buf: [*]<span class="tok-type">u8</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L50">    _flush_blocks: <span class="tok-kw">fn</span> (*BlockIoProtocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">    <span class="tok-comment">/// Resets the block device hardware.</span></span>
<span class="line" id="L53">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *Self, extended_verification: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L54">        <span class="tok-kw">return</span> self._reset(self, extended_verification);</span>
<span class="line" id="L55">    }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-comment">/// Reads the number of requested blocks from the device.</span></span>
<span class="line" id="L58">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readBlocks</span>(self: *Self, media_id: <span class="tok-type">u32</span>, lba: <span class="tok-type">u64</span>, buffer_size: <span class="tok-type">usize</span>, buf: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L59">        <span class="tok-kw">return</span> self._read_blocks(self, media_id, lba, buffer_size, buf);</span>
<span class="line" id="L60">    }</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-comment">/// Writes a specified number of blocks to the device.</span></span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeBlocks</span>(self: *Self, media_id: <span class="tok-type">u32</span>, lba: <span class="tok-type">u64</span>, buffer_size: <span class="tok-type">usize</span>, buf: [*]<span class="tok-type">u8</span>) Status {</span>
<span class="line" id="L64">        <span class="tok-kw">return</span> self._write_blocks(self, media_id, lba, buffer_size, buf);</span>
<span class="line" id="L65">    }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">    <span class="tok-comment">/// Flushes all modified data to a physical block device.</span></span>
<span class="line" id="L68">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">flushBlocks</span>(self: *Self) Status {</span>
<span class="line" id="L69">        <span class="tok-kw">return</span> self._flush_blocks(self);</span>
<span class="line" id="L70">    }</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = uefi.Guid{</span>
<span class="line" id="L73">        .time_low = <span class="tok-number">0x964e5b21</span>,</span>
<span class="line" id="L74">        .time_mid = <span class="tok-number">0x6459</span>,</span>
<span class="line" id="L75">        .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L76">        .clock_seq_high_and_reserved = <span class="tok-number">0x8e</span>,</span>
<span class="line" id="L77">        .clock_seq_low = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L78">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xa0</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3b</span> },</span>
<span class="line" id="L79">    };</span>
<span class="line" id="L80">};</span>
<span class="line" id="L81"></span>
</code></pre></body>
</html>