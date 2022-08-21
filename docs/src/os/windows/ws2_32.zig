<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/ws2_32.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> windows = std.os.windows;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> WINAPI = windows.WINAPI;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> OVERLAPPED = windows.OVERLAPPED;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> WORD = windows.WORD;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> DWORD = windows.DWORD;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> GUID = windows.GUID;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> USHORT = windows.USHORT;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> WCHAR = windows.WCHAR;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> BOOL = windows.BOOL;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> HANDLE = windows.HANDLE;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> timeval = windows.timeval;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> HWND = windows.HWND;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> INT = windows.INT;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> SHORT = windows.SHORT;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> CHAR = windows.CHAR;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> ULONG = windows.ULONG;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> LPARAM = windows.LPARAM;</span>
<span class="line" id="L20"><span class="tok-kw">const</span> FARPROC = windows.FARPROC;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET = *<span class="tok-kw">opaque</span> {};</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INVALID_SOCKET = <span class="tok-builtin">@intToPtr</span>(SOCKET, ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>));</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GROUP = <span class="tok-type">u32</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRESS_FAMILY = <span class="tok-type">u16</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAEVENT = HANDLE;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">// Microsoft use the signed c_int for this, but it should never be negative</span>
</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> socklen_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB_Extension = <span class="tok-number">128</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_PnP = <span class="tok-number">1</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_PDA_Palmtop = <span class="tok-number">2</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_Computer = <span class="tok-number">4</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_Printer = <span class="tok-number">8</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_Modem = <span class="tok-number">16</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_Fax = <span class="tok-number">32</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB1_LANAccess = <span class="tok-number">64</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB2_Telephony = <span class="tok-number">1</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_HB2_FileServer = <span class="tok-number">2</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPROTO_AALUSER = <span class="tok-number">0</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPROTO_AAL1 = <span class="tok-number">1</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPROTO_AAL2 = <span class="tok-number">2</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPROTO_AAL34 = <span class="tok-number">3</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMPROTO_AAL5 = <span class="tok-number">5</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAP_FIELD_ABSENT = <span class="tok-number">4294967294</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAP_FIELD_ANY = <span class="tok-number">4294967295</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAP_FIELD_ANY_AESA_SEL = <span class="tok-number">4294967290</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAP_FIELD_ANY_AESA_REST = <span class="tok-number">4294967291</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM_E164 = <span class="tok-number">1</span>;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM_NSAP = <span class="tok-number">2</span>;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM_AESA = <span class="tok-number">2</span>;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM_ADDR_SIZE = <span class="tok-number">20</span>;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_ISO_1745 = <span class="tok-number">1</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_Q921 = <span class="tok-number">2</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_X25L = <span class="tok-number">6</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_X25M = <span class="tok-number">7</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_ELAPB = <span class="tok-number">8</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_HDLC_ARM = <span class="tok-number">9</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_HDLC_NRM = <span class="tok-number">10</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_HDLC_ABM = <span class="tok-number">11</span>;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_LLC = <span class="tok-number">12</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_X75 = <span class="tok-number">13</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_Q922 = <span class="tok-number">14</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_USER_SPECIFIED = <span class="tok-number">16</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_ISO_7776 = <span class="tok-number">17</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_X25 = <span class="tok-number">6</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_ISO_8208 = <span class="tok-number">7</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_X223 = <span class="tok-number">8</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_SIO_8473 = <span class="tok-number">9</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_T70 = <span class="tok-number">10</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_ISO_TR9577 = <span class="tok-number">11</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_USER_SPECIFIED = <span class="tok-number">16</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_IPI_SNAP = <span class="tok-number">128</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_IPI_IP = <span class="tok-number">204</span>;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BHLI_ISO = <span class="tok-number">0</span>;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BHLI_UserSpecific = <span class="tok-number">1</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BHLI_HighLayerProfile = <span class="tok-number">2</span>;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BHLI_VendorSpecificAppId = <span class="tok-number">3</span>;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_MODE_MESSAGE = <span class="tok-number">1</span>;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_MODE_STREAMING = <span class="tok-number">2</span>;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_SSCS_NULL = <span class="tok-number">0</span>;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_SSCS_SSCOP_ASSURED = <span class="tok-number">1</span>;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_SSCS_SSCOP_NON_ASSURED = <span class="tok-number">2</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AAL5_SSCS_FRAME_RELAY = <span class="tok-number">4</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BCOB_A = <span class="tok-number">1</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BCOB_C = <span class="tok-number">3</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BCOB_X = <span class="tok-number">16</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TT_NOIND = <span class="tok-number">0</span>;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TT_CBR = <span class="tok-number">4</span>;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TT_VBR = <span class="tok-number">8</span>;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TR_NOIND = <span class="tok-number">0</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TR_END_TO_END = <span class="tok-number">1</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TR_NO_END_TO_END = <span class="tok-number">2</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLIP_NOT = <span class="tok-number">0</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLIP_SUS = <span class="tok-number">32</span>;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UP_P2P = <span class="tok-number">0</span>;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UP_P2MP = <span class="tok-number">1</span>;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_MODE_NORMAL = <span class="tok-number">64</span>;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L2_MODE_EXT = <span class="tok-number">128</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_MODE_NORMAL = <span class="tok-number">64</span>;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_MODE_EXT = <span class="tok-number">128</span>;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_16 = <span class="tok-number">4</span>;</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_32 = <span class="tok-number">5</span>;</span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_64 = <span class="tok-number">6</span>;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_128 = <span class="tok-number">7</span>;</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_256 = <span class="tok-number">8</span>;</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_512 = <span class="tok-number">9</span>;</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_1024 = <span class="tok-number">10</span>;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_2048 = <span class="tok-number">11</span>;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BLLI_L3_PACKET_4096 = <span class="tok-number">12</span>;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PI_ALLOWED = <span class="tok-number">0</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PI_RESTRICTED = <span class="tok-number">64</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PI_NUMBER_NOT_AVAILABLE = <span class="tok-number">128</span>;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SI_USER_NOT_SCREENED = <span class="tok-number">0</span>;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SI_USER_PASSED = <span class="tok-number">1</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SI_USER_FAILED = <span class="tok-number">2</span>;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SI_NETWORK = <span class="tok-number">3</span>;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_USER = <span class="tok-number">0</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_PRIVATE_LOCAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_PUBLIC_LOCAL = <span class="tok-number">2</span>;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_TRANSIT_NETWORK = <span class="tok-number">3</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_PUBLIC_REMOTE = <span class="tok-number">4</span>;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_PRIVATE_REMOTE = <span class="tok-number">5</span>;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_INTERNATIONAL_NETWORK = <span class="tok-number">7</span>;</span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_LOC_BEYOND_INTERWORKING = <span class="tok-number">10</span>;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_UNALLOCATED_NUMBER = <span class="tok-number">1</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NO_ROUTE_TO_TRANSIT_NETWORK = <span class="tok-number">2</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NO_ROUTE_TO_DESTINATION = <span class="tok-number">3</span>;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_VPI_VCI_UNACCEPTABLE = <span class="tok-number">10</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NORMAL_CALL_CLEARING = <span class="tok-number">16</span>;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_USER_BUSY = <span class="tok-number">17</span>;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NO_USER_RESPONDING = <span class="tok-number">18</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_CALL_REJECTED = <span class="tok-number">21</span>;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NUMBER_CHANGED = <span class="tok-number">22</span>;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_USER_REJECTS_CLIR = <span class="tok-number">23</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_DESTINATION_OUT_OF_ORDER = <span class="tok-number">27</span>;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_NUMBER_FORMAT = <span class="tok-number">28</span>;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_STATUS_ENQUIRY_RESPONSE = <span class="tok-number">30</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NORMAL_UNSPECIFIED = <span class="tok-number">31</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_VPI_VCI_UNAVAILABLE = <span class="tok-number">35</span>;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NETWORK_OUT_OF_ORDER = <span class="tok-number">38</span>;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_TEMPORARY_FAILURE = <span class="tok-number">41</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_ACCESS_INFORMAION_DISCARDED = <span class="tok-number">43</span>;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NO_VPI_VCI_AVAILABLE = <span class="tok-number">45</span>;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_RESOURCE_UNAVAILABLE = <span class="tok-number">47</span>;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_QOS_UNAVAILABLE = <span class="tok-number">49</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_USER_CELL_RATE_UNAVAILABLE = <span class="tok-number">51</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_BEARER_CAPABILITY_UNAUTHORIZED = <span class="tok-number">57</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_BEARER_CAPABILITY_UNAVAILABLE = <span class="tok-number">58</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_OPTION_UNAVAILABLE = <span class="tok-number">63</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_BEARER_CAPABILITY_UNIMPLEMENTED = <span class="tok-number">65</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_UNSUPPORTED_TRAFFIC_PARAMETERS = <span class="tok-number">73</span>;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_CALL_REFERENCE = <span class="tok-number">81</span>;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_CHANNEL_NONEXISTENT = <span class="tok-number">82</span>;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INCOMPATIBLE_DESTINATION = <span class="tok-number">88</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_ENDPOINT_REFERENCE = <span class="tok-number">89</span>;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_TRANSIT_NETWORK_SELECTION = <span class="tok-number">91</span>;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_TOO_MANY_PENDING_ADD_PARTY = <span class="tok-number">92</span>;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_AAL_PARAMETERS_UNSUPPORTED = <span class="tok-number">93</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_MANDATORY_IE_MISSING = <span class="tok-number">96</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_UNIMPLEMENTED_MESSAGE_TYPE = <span class="tok-number">97</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_UNIMPLEMENTED_IE = <span class="tok-number">99</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_IE_CONTENTS = <span class="tok-number">100</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INVALID_STATE_FOR_MESSAGE = <span class="tok-number">101</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_RECOVERY_ON_TIMEOUT = <span class="tok-number">102</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_INCORRECT_MESSAGE_LENGTH = <span class="tok-number">104</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_PROTOCOL_ERROR = <span class="tok-number">111</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_COND_UNKNOWN = <span class="tok-number">0</span>;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_COND_PERMANENT = <span class="tok-number">1</span>;</span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_COND_TRANSIENT = <span class="tok-number">2</span>;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_REASON_USER = <span class="tok-number">0</span>;</span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_REASON_IE_MISSING = <span class="tok-number">4</span>;</span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_REASON_IE_INSUFFICIENT = <span class="tok-number">8</span>;</span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_PU_PROVIDER = <span class="tok-number">0</span>;</span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_PU_USER = <span class="tok-number">8</span>;</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NA_NORMAL = <span class="tok-number">0</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CAUSE_NA_ABNORMAL = <span class="tok-number">4</span>;</span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS_CLASS0 = <span class="tok-number">0</span>;</span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS_CLASS1 = <span class="tok-number">1</span>;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS_CLASS2 = <span class="tok-number">2</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS_CLASS3 = <span class="tok-number">3</span>;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS_CLASS4 = <span class="tok-number">4</span>;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TNS_TYPE_NATIONAL = <span class="tok-number">64</span>;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TNS_PLAN_CARRIER_ID_CODE = <span class="tok-number">1</span>;</span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_GET_NUMBER_OF_ATM_DEVICES = <span class="tok-number">1343619073</span>;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_GET_ATM_ADDRESS = <span class="tok-number">3491102722</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_ASSOCIATE_PVC = <span class="tok-number">2417360899</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_GET_ATM_CONNECTION_ID = <span class="tok-number">1343619076</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_MSG_DONT_NOTIFY = <span class="tok-number">1</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_MSG_DEFER = <span class="tok-number">2</span>;</span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_MSG_WAITALL = <span class="tok-number">4</span>;</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_MSG_COMMIT_ONLY = <span class="tok-number">8</span>;</span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_MAX_CQ_SIZE = <span class="tok-number">134217728</span>;</span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIO_CORRUPT_CQ = <span class="tok-number">4294967295</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WINDOWS_AF_IRDA = <span class="tok-number">26</span>;</span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WCE_AF_IRDA = <span class="tok-number">22</span>;</span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRDA_PROTO_SOCK_STREAM = <span class="tok-number">1</span>;</span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_ENUMDEVICES = <span class="tok-number">16</span>;</span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_IAS_SET = <span class="tok-number">17</span>;</span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_IAS_QUERY = <span class="tok-number">18</span>;</span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_SEND_PDU_LEN = <span class="tok-number">19</span>;</span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_EXCLUSIVE_MODE = <span class="tok-number">20</span>;</span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_IRLPT_MODE = <span class="tok-number">21</span>;</span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_9WIRE_MODE = <span class="tok-number">22</span>;</span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_TINYTP_MODE = <span class="tok-number">23</span>;</span>
<span class="line" id="L208"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_PARAMETERS = <span class="tok-number">24</span>;</span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_DISCOVERY_MODE = <span class="tok-number">25</span>;</span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP_SHARP_MODE = <span class="tok-number">32</span>;</span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_ATTRIB_NO_CLASS = <span class="tok-number">16</span>;</span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_ATTRIB_NO_ATTRIB = <span class="tok-number">0</span>;</span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_ATTRIB_INT = <span class="tok-number">1</span>;</span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_ATTRIB_OCTETSEQ = <span class="tok-number">2</span>;</span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_ATTRIB_STR = <span class="tok-number">3</span>;</span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_MAX_USER_STRING = <span class="tok-number">256</span>;</span>
<span class="line" id="L217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_MAX_OCTET_STRING = <span class="tok-number">1024</span>;</span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_MAX_CLASSNAME = <span class="tok-number">64</span>;</span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IAS_MAX_ATTRIBNAME = <span class="tok-number">256</span>;</span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetASCII = <span class="tok-number">0</span>;</span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_1 = <span class="tok-number">1</span>;</span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_2 = <span class="tok-number">2</span>;</span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_3 = <span class="tok-number">3</span>;</span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_4 = <span class="tok-number">4</span>;</span>
<span class="line" id="L225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_5 = <span class="tok-number">5</span>;</span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_6 = <span class="tok-number">6</span>;</span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_7 = <span class="tok-number">7</span>;</span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_8 = <span class="tok-number">8</span>;</span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetISO_8859_9 = <span class="tok-number">9</span>;</span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LmCharSetUNICODE = <span class="tok-number">255</span>;</span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_1200 = <span class="tok-number">1200</span>;</span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_2400 = <span class="tok-number">2400</span>;</span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_9600 = <span class="tok-number">9600</span>;</span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_19200 = <span class="tok-number">19200</span>;</span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_38400 = <span class="tok-number">38400</span>;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_57600 = <span class="tok-number">57600</span>;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_115200 = <span class="tok-number">115200</span>;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_576K = <span class="tok-number">576000</span>;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_1152K = <span class="tok-number">1152000</span>;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_4M = <span class="tok-number">4000000</span>;</span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LM_BAUD_16M = <span class="tok-number">16000000</span>;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_PTYPE = <span class="tok-number">16384</span>;</span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_FILTERPTYPE = <span class="tok-number">16385</span>;</span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_STOPFILTERPTYPE = <span class="tok-number">16387</span>;</span>
<span class="line" id="L245"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_DSTYPE = <span class="tok-number">16386</span>;</span>
<span class="line" id="L246"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_EXTENDED_ADDRESS = <span class="tok-number">16388</span>;</span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_RECVHDR = <span class="tok-number">16389</span>;</span>
<span class="line" id="L248"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_MAXSIZE = <span class="tok-number">16390</span>;</span>
<span class="line" id="L249"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_ADDRESS = <span class="tok-number">16391</span>;</span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_GETNETINFO = <span class="tok-number">16392</span>;</span>
<span class="line" id="L251"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_GETNETINFO_NORIP = <span class="tok-number">16393</span>;</span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_SPXGETCONNECTIONSTATUS = <span class="tok-number">16395</span>;</span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_ADDRESS_NOTIFY = <span class="tok-number">16396</span>;</span>
<span class="line" id="L254"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_MAX_ADAPTER_NUM = <span class="tok-number">16397</span>;</span>
<span class="line" id="L255"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_RERIPNETNUMBER = <span class="tok-number">16398</span>;</span>
<span class="line" id="L256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_RECEIVE_BROADCAST = <span class="tok-number">16399</span>;</span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX_IMMEDIATESPXACK = <span class="tok-number">16400</span>;</span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_MCAST_TTL = <span class="tok-number">255</span>;</span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_OPTIONSBASE = <span class="tok-number">1000</span>;</span>
<span class="line" id="L260"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_RATE_WINDOW_SIZE = <span class="tok-number">1001</span>;</span>
<span class="line" id="L261"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SET_MESSAGE_BOUNDARY = <span class="tok-number">1002</span>;</span>
<span class="line" id="L262"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_FLUSHCACHE = <span class="tok-number">1003</span>;</span>
<span class="line" id="L263"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SENDER_WINDOW_ADVANCE_METHOD = <span class="tok-number">1004</span>;</span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SENDER_STATISTICS = <span class="tok-number">1005</span>;</span>
<span class="line" id="L265"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_LATEJOIN = <span class="tok-number">1006</span>;</span>
<span class="line" id="L266"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SET_SEND_IF = <span class="tok-number">1007</span>;</span>
<span class="line" id="L267"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_ADD_RECEIVE_IF = <span class="tok-number">1008</span>;</span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_DEL_RECEIVE_IF = <span class="tok-number">1009</span>;</span>
<span class="line" id="L269"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SEND_WINDOW_ADV_RATE = <span class="tok-number">1010</span>;</span>
<span class="line" id="L270"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_USE_FEC = <span class="tok-number">1011</span>;</span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_SET_MCAST_TTL = <span class="tok-number">1012</span>;</span>
<span class="line" id="L272"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_RECEIVER_STATISTICS = <span class="tok-number">1013</span>;</span>
<span class="line" id="L273"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM_HIGH_SPEED_INTRANET_OPT = <span class="tok-number">1014</span>;</span>
<span class="line" id="L274"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SENDER_DEFAULT_RATE_KBITS_PER_SEC = <span class="tok-number">56</span>;</span>
<span class="line" id="L275"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SENDER_DEFAULT_WINDOW_ADV_PERCENTAGE = <span class="tok-number">15</span>;</span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_WINDOW_INCREMENT_PERCENTAGE = <span class="tok-number">25</span>;</span>
<span class="line" id="L277"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SENDER_DEFAULT_LATE_JOINER_PERCENTAGE = <span class="tok-number">0</span>;</span>
<span class="line" id="L278"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SENDER_MAX_LATE_JOINER_PERCENTAGE = <span class="tok-number">75</span>;</span>
<span class="line" id="L279"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BITS_PER_BYTE = <span class="tok-number">8</span>;</span>
<span class="line" id="L280"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOG2_BITS_PER_BYTE = <span class="tok-number">3</span>;</span>
<span class="line" id="L281"></span>
<span class="line" id="L282"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_DEFAULT2_QM_POLICY = GUID.parse(<span class="tok-str">&quot;{aec2ef9c-3a4d-4d3e-8842-239942e39a47}&quot;</span>);</span>
<span class="line" id="L283"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REAL_TIME_NOTIFICATION_CAPABILITY = GUID.parse(<span class="tok-str">&quot;{6b59819a-5cae-492d-a901-2a3c2c50164f}&quot;</span>);</span>
<span class="line" id="L284"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> REAL_TIME_NOTIFICATION_CAPABILITY_EX = GUID.parse(<span class="tok-str">&quot;{6843da03-154a-4616-a508-44371295f96b}&quot;</span>);</span>
<span class="line" id="L285"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASSOCIATE_NAMERES_CONTEXT = GUID.parse(<span class="tok-str">&quot;{59a38b67-d4fe-46e1-ba3c-87ea74ca3049}&quot;</span>);</span>
<span class="line" id="L286"></span>
<span class="line" id="L287"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_CONNECTEX = GUID{</span>
<span class="line" id="L288">    .Data1 = <span class="tok-number">0x25a207b9</span>,</span>
<span class="line" id="L289">    .Data2 = <span class="tok-number">0xddf3</span>,</span>
<span class="line" id="L290">    .Data3 = <span class="tok-number">0x4660</span>,</span>
<span class="line" id="L291">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x8e</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x76</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x8c</span>, <span class="tok-number">0x74</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x3e</span> },</span>
<span class="line" id="L292">};</span>
<span class="line" id="L293"></span>
<span class="line" id="L294"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_ACCEPTEX = GUID{</span>
<span class="line" id="L295">    .Data1 = <span class="tok-number">0xb5367df1</span>,</span>
<span class="line" id="L296">    .Data2 = <span class="tok-number">0xcbac</span>,</span>
<span class="line" id="L297">    .Data3 = <span class="tok-number">0x11cf</span>,</span>
<span class="line" id="L298">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x95</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x92</span> },</span>
<span class="line" id="L299">};</span>
<span class="line" id="L300"></span>
<span class="line" id="L301"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_GETACCEPTEXSOCKADDRS = GUID{</span>
<span class="line" id="L302">    .Data1 = <span class="tok-number">0xb5367df2</span>,</span>
<span class="line" id="L303">    .Data2 = <span class="tok-number">0xcbac</span>,</span>
<span class="line" id="L304">    .Data3 = <span class="tok-number">0x11cf</span>,</span>
<span class="line" id="L305">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x95</span>, <span class="tok-number">0xca</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x5f</span>, <span class="tok-number">0x48</span>, <span class="tok-number">0xa1</span>, <span class="tok-number">0x92</span> },</span>
<span class="line" id="L306">};</span>
<span class="line" id="L307"></span>
<span class="line" id="L308"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_WSARECVMSG = GUID{</span>
<span class="line" id="L309">    .Data1 = <span class="tok-number">0xf689d7c8</span>,</span>
<span class="line" id="L310">    .Data2 = <span class="tok-number">0x6f1f</span>,</span>
<span class="line" id="L311">    .Data3 = <span class="tok-number">0x436b</span>,</span>
<span class="line" id="L312">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x8a</span>, <span class="tok-number">0x53</span>, <span class="tok-number">0xe5</span>, <span class="tok-number">0x4f</span>, <span class="tok-number">0xe3</span>, <span class="tok-number">0x51</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0x22</span> },</span>
<span class="line" id="L313">};</span>
<span class="line" id="L314"></span>
<span class="line" id="L315"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_WSAPOLL = GUID{</span>
<span class="line" id="L316">    .Data1 = <span class="tok-number">0x18C76F85</span>,</span>
<span class="line" id="L317">    .Data2 = <span class="tok-number">0xDC66</span>,</span>
<span class="line" id="L318">    .Data3 = <span class="tok-number">0x4964</span>,</span>
<span class="line" id="L319">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x97</span>, <span class="tok-number">0x2E</span>, <span class="tok-number">0x23</span>, <span class="tok-number">0xC2</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x2B</span> },</span>
<span class="line" id="L320">};</span>
<span class="line" id="L321"></span>
<span class="line" id="L322"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAID_WSASENDMSG = GUID{</span>
<span class="line" id="L323">    .Data1 = <span class="tok-number">0xa441e712</span>,</span>
<span class="line" id="L324">    .Data2 = <span class="tok-number">0x754f</span>,</span>
<span class="line" id="L325">    .Data3 = <span class="tok-number">0x43ca</span>,</span>
<span class="line" id="L326">    .Data4 = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x84</span>, <span class="tok-number">0xa7</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0xee</span>, <span class="tok-number">0x44</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0x6d</span> },</span>
<span class="line" id="L327">};</span>
<span class="line" id="L328"></span>
<span class="line" id="L329"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP_INITIAL_RTO_DEFAULT_RTT = <span class="tok-number">0</span>;</span>
<span class="line" id="L330"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP_INITIAL_RTO_DEFAULT_MAX_SYN_RETRANSMISSIONS = <span class="tok-number">0</span>;</span>
<span class="line" id="L331"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_GUARANTEE_ENCRYPTION = <span class="tok-number">1</span>;</span>
<span class="line" id="L332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_ALLOW_INSECURE = <span class="tok-number">2</span>;</span>
<span class="line" id="L333"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_IPSEC_SKIP_FILTER_INSTANTIATION = <span class="tok-number">1</span>;</span>
<span class="line" id="L334"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_IPSEC_OPTIONAL_PEER_NAME_VERIFICATION = <span class="tok-number">2</span>;</span>
<span class="line" id="L335"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_IPSEC_ALLOW_FIRST_INBOUND_PKT_UNENCRYPTED = <span class="tok-number">4</span>;</span>
<span class="line" id="L336"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_SETTINGS_IPSEC_PEER_NAME_IS_RAW_FORMAT = <span class="tok-number">8</span>;</span>
<span class="line" id="L337"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_QUERY_IPSEC2_ABORT_CONNECTION_ON_FIELD_CHANGE = <span class="tok-number">1</span>;</span>
<span class="line" id="L338"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_QUERY_IPSEC2_FIELD_MASK_MM_SA_ID = <span class="tok-number">1</span>;</span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_QUERY_IPSEC2_FIELD_MASK_QM_SA_ID = <span class="tok-number">2</span>;</span>
<span class="line" id="L340"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_INFO_CONNECTION_SECURED = <span class="tok-number">1</span>;</span>
<span class="line" id="L341"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_INFO_CONNECTION_ENCRYPTED = <span class="tok-number">2</span>;</span>
<span class="line" id="L342"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_INFO_CONNECTION_IMPERSONATED = <span class="tok-number">4</span>;</span>
<span class="line" id="L343"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN4ADDR_LOOPBACK = <span class="tok-number">16777343</span>;</span>
<span class="line" id="L344"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN4ADDR_LOOPBACKPREFIX_LENGTH = <span class="tok-number">8</span>;</span>
<span class="line" id="L345"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN4ADDR_LINKLOCALPREFIX_LENGTH = <span class="tok-number">16</span>;</span>
<span class="line" id="L346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN4ADDR_MULTICASTPREFIX_LENGTH = <span class="tok-number">4</span>;</span>
<span class="line" id="L347"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFF_UP = <span class="tok-number">1</span>;</span>
<span class="line" id="L348"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFF_BROADCAST = <span class="tok-number">2</span>;</span>
<span class="line" id="L349"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFF_LOOPBACK = <span class="tok-number">4</span>;</span>
<span class="line" id="L350"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFF_POINTTOPOINT = <span class="tok-number">8</span>;</span>
<span class="line" id="L351"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFF_MULTICAST = <span class="tok-number">16</span>;</span>
<span class="line" id="L352"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_OPTIONS = <span class="tok-number">1</span>;</span>
<span class="line" id="L353"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_HDRINCL = <span class="tok-number">2</span>;</span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_TOS = <span class="tok-number">3</span>;</span>
<span class="line" id="L355"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_TTL = <span class="tok-number">4</span>;</span>
<span class="line" id="L356"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MULTICAST_IF = <span class="tok-number">9</span>;</span>
<span class="line" id="L357"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MULTICAST_TTL = <span class="tok-number">10</span>;</span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MULTICAST_LOOP = <span class="tok-number">11</span>;</span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_ADD_MEMBERSHIP = <span class="tok-number">12</span>;</span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DROP_MEMBERSHIP = <span class="tok-number">13</span>;</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DONTFRAGMENT = <span class="tok-number">14</span>;</span>
<span class="line" id="L362"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_ADD_SOURCE_MEMBERSHIP = <span class="tok-number">15</span>;</span>
<span class="line" id="L363"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DROP_SOURCE_MEMBERSHIP = <span class="tok-number">16</span>;</span>
<span class="line" id="L364"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_BLOCK_SOURCE = <span class="tok-number">17</span>;</span>
<span class="line" id="L365"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_UNBLOCK_SOURCE = <span class="tok-number">18</span>;</span>
<span class="line" id="L366"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_PKTINFO = <span class="tok-number">19</span>;</span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_HOPLIMIT = <span class="tok-number">21</span>;</span>
<span class="line" id="L368"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVTTL = <span class="tok-number">21</span>;</span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECEIVE_BROADCAST = <span class="tok-number">22</span>;</span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVIF = <span class="tok-number">24</span>;</span>
<span class="line" id="L371"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVDSTADDR = <span class="tok-number">25</span>;</span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_IFLIST = <span class="tok-number">28</span>;</span>
<span class="line" id="L373"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_ADD_IFLIST = <span class="tok-number">29</span>;</span>
<span class="line" id="L374"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DEL_IFLIST = <span class="tok-number">30</span>;</span>
<span class="line" id="L375"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_UNICAST_IF = <span class="tok-number">31</span>;</span>
<span class="line" id="L376"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RTHDR = <span class="tok-number">32</span>;</span>
<span class="line" id="L377"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_GET_IFLIST = <span class="tok-number">33</span>;</span>
<span class="line" id="L378"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVRTHDR = <span class="tok-number">38</span>;</span>
<span class="line" id="L379"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_TCLASS = <span class="tok-number">39</span>;</span>
<span class="line" id="L380"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVTCLASS = <span class="tok-number">40</span>;</span>
<span class="line" id="L381"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVTOS = <span class="tok-number">40</span>;</span>
<span class="line" id="L382"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_ORIGINAL_ARRIVAL_IF = <span class="tok-number">47</span>;</span>
<span class="line" id="L383"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_ECN = <span class="tok-number">50</span>;</span>
<span class="line" id="L384"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_PKTINFO_EX = <span class="tok-number">51</span>;</span>
<span class="line" id="L385"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_WFP_REDIRECT_RECORDS = <span class="tok-number">60</span>;</span>
<span class="line" id="L386"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_WFP_REDIRECT_CONTEXT = <span class="tok-number">70</span>;</span>
<span class="line" id="L387"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MTU_DISCOVER = <span class="tok-number">71</span>;</span>
<span class="line" id="L388"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MTU = <span class="tok-number">73</span>;</span>
<span class="line" id="L389"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_NRT_INTERFACE = <span class="tok-number">74</span>;</span>
<span class="line" id="L390"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_RECVERR = <span class="tok-number">75</span>;</span>
<span class="line" id="L391"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_USER_MTU = <span class="tok-number">76</span>;</span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_UNSPECIFIED_TYPE_OF_SERVICE = -<span class="tok-number">1</span>;</span>
<span class="line" id="L393"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_LINKLOCALPREFIX_LENGTH = <span class="tok-number">64</span>;</span>
<span class="line" id="L394"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_MULTICASTPREFIX_LENGTH = <span class="tok-number">8</span>;</span>
<span class="line" id="L395"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_SOLICITEDNODEMULTICASTPREFIX_LENGTH = <span class="tok-number">104</span>;</span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_V4MAPPEDPREFIX_LENGTH = <span class="tok-number">96</span>;</span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_6TO4PREFIX_LENGTH = <span class="tok-number">16</span>;</span>
<span class="line" id="L398"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN6ADDR_TEREDOPREFIX_LENGTH = <span class="tok-number">32</span>;</span>
<span class="line" id="L399"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_JOIN_GROUP = <span class="tok-number">41</span>;</span>
<span class="line" id="L400"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_LEAVE_GROUP = <span class="tok-number">42</span>;</span>
<span class="line" id="L401"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_BLOCK_SOURCE = <span class="tok-number">43</span>;</span>
<span class="line" id="L402"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_UNBLOCK_SOURCE = <span class="tok-number">44</span>;</span>
<span class="line" id="L403"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_JOIN_SOURCE_GROUP = <span class="tok-number">45</span>;</span>
<span class="line" id="L404"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST_LEAVE_SOURCE_GROUP = <span class="tok-number">46</span>;</span>
<span class="line" id="L405"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_HOPOPTS = <span class="tok-number">1</span>;</span>
<span class="line" id="L406"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_HDRINCL = <span class="tok-number">2</span>;</span>
<span class="line" id="L407"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_UNICAST_HOPS = <span class="tok-number">4</span>;</span>
<span class="line" id="L408"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_MULTICAST_IF = <span class="tok-number">9</span>;</span>
<span class="line" id="L409"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_MULTICAST_HOPS = <span class="tok-number">10</span>;</span>
<span class="line" id="L410"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_MULTICAST_LOOP = <span class="tok-number">11</span>;</span>
<span class="line" id="L411"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_ADD_MEMBERSHIP = <span class="tok-number">12</span>;</span>
<span class="line" id="L412"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_DROP_MEMBERSHIP = <span class="tok-number">13</span>;</span>
<span class="line" id="L413"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_DONTFRAG = <span class="tok-number">14</span>;</span>
<span class="line" id="L414"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_PKTINFO = <span class="tok-number">19</span>;</span>
<span class="line" id="L415"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_HOPLIMIT = <span class="tok-number">21</span>;</span>
<span class="line" id="L416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_PROTECTION_LEVEL = <span class="tok-number">23</span>;</span>
<span class="line" id="L417"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RECVIF = <span class="tok-number">24</span>;</span>
<span class="line" id="L418"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RECVDSTADDR = <span class="tok-number">25</span>;</span>
<span class="line" id="L419"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_CHECKSUM = <span class="tok-number">26</span>;</span>
<span class="line" id="L420"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_V6ONLY = <span class="tok-number">27</span>;</span>
<span class="line" id="L421"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_IFLIST = <span class="tok-number">28</span>;</span>
<span class="line" id="L422"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_ADD_IFLIST = <span class="tok-number">29</span>;</span>
<span class="line" id="L423"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_DEL_IFLIST = <span class="tok-number">30</span>;</span>
<span class="line" id="L424"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_UNICAST_IF = <span class="tok-number">31</span>;</span>
<span class="line" id="L425"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RTHDR = <span class="tok-number">32</span>;</span>
<span class="line" id="L426"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_GET_IFLIST = <span class="tok-number">33</span>;</span>
<span class="line" id="L427"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RECVRTHDR = <span class="tok-number">38</span>;</span>
<span class="line" id="L428"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_TCLASS = <span class="tok-number">39</span>;</span>
<span class="line" id="L429"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RECVTCLASS = <span class="tok-number">40</span>;</span>
<span class="line" id="L430"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_ECN = <span class="tok-number">50</span>;</span>
<span class="line" id="L431"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_PKTINFO_EX = <span class="tok-number">51</span>;</span>
<span class="line" id="L432"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_WFP_REDIRECT_RECORDS = <span class="tok-number">60</span>;</span>
<span class="line" id="L433"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_WFP_REDIRECT_CONTEXT = <span class="tok-number">70</span>;</span>
<span class="line" id="L434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_MTU_DISCOVER = <span class="tok-number">71</span>;</span>
<span class="line" id="L435"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_MTU = <span class="tok-number">72</span>;</span>
<span class="line" id="L436"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_NRT_INTERFACE = <span class="tok-number">74</span>;</span>
<span class="line" id="L437"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_RECVERR = <span class="tok-number">75</span>;</span>
<span class="line" id="L438"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPV6_USER_MTU = <span class="tok-number">76</span>;</span>
<span class="line" id="L439"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_UNSPECIFIED_HOP_LIMIT = -<span class="tok-number">1</span>;</span>
<span class="line" id="L440"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTECTION_LEVEL_UNRESTRICTED = <span class="tok-number">10</span>;</span>
<span class="line" id="L441"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTECTION_LEVEL_EDGERESTRICTED = <span class="tok-number">20</span>;</span>
<span class="line" id="L442"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTECTION_LEVEL_RESTRICTED = <span class="tok-number">30</span>;</span>
<span class="line" id="L443"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET_ADDRSTRLEN = <span class="tok-number">22</span>;</span>
<span class="line" id="L444"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET6_ADDRSTRLEN = <span class="tok-number">65</span>;</span>
<span class="line" id="L445"></span>
<span class="line" id="L446"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L447">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NODELAY = <span class="tok-number">1</span>;</span>
<span class="line" id="L448">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXPEDITED_1122 = <span class="tok-number">2</span>;</span>
<span class="line" id="L449">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFFLOAD_NO_PREFERENCE = <span class="tok-number">0</span>;</span>
<span class="line" id="L450">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFFLOAD_NOT_PREFERRED = <span class="tok-number">1</span>;</span>
<span class="line" id="L451">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFFLOAD_PREFERRED = <span class="tok-number">2</span>;</span>
<span class="line" id="L452">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">3</span>;</span>
<span class="line" id="L453">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXSEG = <span class="tok-number">4</span>;</span>
<span class="line" id="L454">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXRT = <span class="tok-number">5</span>;</span>
<span class="line" id="L455">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDURG = <span class="tok-number">6</span>;</span>
<span class="line" id="L456">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOURG = <span class="tok-number">7</span>;</span>
<span class="line" id="L457">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATMARK = <span class="tok-number">8</span>;</span>
<span class="line" id="L458">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NOSYNRETRIES = <span class="tok-number">9</span>;</span>
<span class="line" id="L459">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIMESTAMPS = <span class="tok-number">10</span>;</span>
<span class="line" id="L460">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OFFLOAD_PREFERENCE = <span class="tok-number">11</span>;</span>
<span class="line" id="L461">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONGESTION_ALGORITHM = <span class="tok-number">12</span>;</span>
<span class="line" id="L462">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DELAY_FIN_ACK = <span class="tok-number">13</span>;</span>
<span class="line" id="L463">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXRTMS = <span class="tok-number">14</span>;</span>
<span class="line" id="L464">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FASTOPEN = <span class="tok-number">15</span>;</span>
<span class="line" id="L465">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPCNT = <span class="tok-number">16</span>;</span>
<span class="line" id="L466">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPINTVL = <span class="tok-number">17</span>;</span>
<span class="line" id="L467">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAIL_CONNECT_ON_ICMP_ERROR = <span class="tok-number">18</span>;</span>
<span class="line" id="L468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICMP_ERROR_INFO = <span class="tok-number">19</span>;</span>
<span class="line" id="L469">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSDURGENT = <span class="tok-number">28672</span>;</span>
<span class="line" id="L470">};</span>
<span class="line" id="L471"></span>
<span class="line" id="L472"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP_SEND_MSG_SIZE = <span class="tok-number">2</span>;</span>
<span class="line" id="L473"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP_RECV_MAX_COALESCED_SIZE = <span class="tok-number">3</span>;</span>
<span class="line" id="L474"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP_COALESCED_INFO = <span class="tok-number">3</span>;</span>
<span class="line" id="L475"></span>
<span class="line" id="L476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AF = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L477">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNSPEC = <span class="tok-number">0</span>;</span>
<span class="line" id="L478">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNIX = <span class="tok-number">1</span>;</span>
<span class="line" id="L479">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET = <span class="tok-number">2</span>;</span>
<span class="line" id="L480">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMPLINK = <span class="tok-number">3</span>;</span>
<span class="line" id="L481">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUP = <span class="tok-number">4</span>;</span>
<span class="line" id="L482">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHAOS = <span class="tok-number">5</span>;</span>
<span class="line" id="L483">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS = <span class="tok-number">6</span>;</span>
<span class="line" id="L484">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPX = <span class="tok-number">6</span>;</span>
<span class="line" id="L485">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ISO = <span class="tok-number">7</span>;</span>
<span class="line" id="L486">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ECMA = <span class="tok-number">8</span>;</span>
<span class="line" id="L487">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DATAKIT = <span class="tok-number">9</span>;</span>
<span class="line" id="L488">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CCITT = <span class="tok-number">10</span>;</span>
<span class="line" id="L489">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNA = <span class="tok-number">11</span>;</span>
<span class="line" id="L490">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DECnet = <span class="tok-number">12</span>;</span>
<span class="line" id="L491">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DLI = <span class="tok-number">13</span>;</span>
<span class="line" id="L492">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LAT = <span class="tok-number">14</span>;</span>
<span class="line" id="L493">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HYLINK = <span class="tok-number">15</span>;</span>
<span class="line" id="L494">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> APPLETALK = <span class="tok-number">16</span>;</span>
<span class="line" id="L495">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETBIOS = <span class="tok-number">17</span>;</span>
<span class="line" id="L496">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> VOICEVIEW = <span class="tok-number">18</span>;</span>
<span class="line" id="L497">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIREFOX = <span class="tok-number">19</span>;</span>
<span class="line" id="L498">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UNKNOWN1 = <span class="tok-number">20</span>;</span>
<span class="line" id="L499">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BAN = <span class="tok-number">21</span>;</span>
<span class="line" id="L500">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ATM = <span class="tok-number">22</span>;</span>
<span class="line" id="L501">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INET6 = <span class="tok-number">23</span>;</span>
<span class="line" id="L502">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLUSTER = <span class="tok-number">24</span>;</span>
<span class="line" id="L503">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;12844&quot; = <span class="tok-number">25</span>;</span>
<span class="line" id="L504">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRDA = <span class="tok-number">26</span>;</span>
<span class="line" id="L505">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NETDES = <span class="tok-number">28</span>;</span>
<span class="line" id="L506">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">29</span>;</span>
<span class="line" id="L507">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCNPROCESS = <span class="tok-number">29</span>;</span>
<span class="line" id="L508">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCNMESSAGE = <span class="tok-number">30</span>;</span>
<span class="line" id="L509">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICLFXBM = <span class="tok-number">31</span>;</span>
<span class="line" id="L510">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINK = <span class="tok-number">33</span>;</span>
<span class="line" id="L511">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HYPERV = <span class="tok-number">34</span>;</span>
<span class="line" id="L512">};</span>
<span class="line" id="L513"></span>
<span class="line" id="L514"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L515">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> STREAM = <span class="tok-number">1</span>;</span>
<span class="line" id="L516">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DGRAM = <span class="tok-number">2</span>;</span>
<span class="line" id="L517">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">3</span>;</span>
<span class="line" id="L518">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDM = <span class="tok-number">4</span>;</span>
<span class="line" id="L519">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SEQPACKET = <span class="tok-number">5</span>;</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-comment">/// WARNING: this flag is not supported by windows socket functions directly,</span></span>
<span class="line" id="L522">    <span class="tok-comment">///          it is only supported by std.os.socket. Be sure that this value does</span></span>
<span class="line" id="L523">    <span class="tok-comment">///          not share any bits with any of the `SOCK` values.</span></span>
<span class="line" id="L524">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOEXEC = <span class="tok-number">0x10000</span>;</span>
<span class="line" id="L525">    <span class="tok-comment">/// WARNING: this flag is not supported by windows socket functions directly,</span></span>
<span class="line" id="L526">    <span class="tok-comment">///          it is only supported by std.os.socket. Be sure that this value does</span></span>
<span class="line" id="L527">    <span class="tok-comment">///          not share any bits with any of the `SOCK` values.</span></span>
<span class="line" id="L528">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK = <span class="tok-number">0x20000</span>;</span>
<span class="line" id="L529">};</span>
<span class="line" id="L530"></span>
<span class="line" id="L531"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOL = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L532">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRLMP = <span class="tok-number">255</span>;</span>
<span class="line" id="L533">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET = <span class="tok-number">65535</span>;</span>
<span class="line" id="L534">};</span>
<span class="line" id="L535"></span>
<span class="line" id="L536"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SO = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L537">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEBUG = <span class="tok-number">1</span>;</span>
<span class="line" id="L538">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ACCEPTCONN = <span class="tok-number">2</span>;</span>
<span class="line" id="L539">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSEADDR = <span class="tok-number">4</span>;</span>
<span class="line" id="L540">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KEEPALIVE = <span class="tok-number">8</span>;</span>
<span class="line" id="L541">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DONTROUTE = <span class="tok-number">16</span>;</span>
<span class="line" id="L542">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BROADCAST = <span class="tok-number">32</span>;</span>
<span class="line" id="L543">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> USELOOPBACK = <span class="tok-number">64</span>;</span>
<span class="line" id="L544">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> LINGER = <span class="tok-number">128</span>;</span>
<span class="line" id="L545">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OOBINLINE = <span class="tok-number">256</span>;</span>
<span class="line" id="L546">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDBUF = <span class="tok-number">4097</span>;</span>
<span class="line" id="L547">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVBUF = <span class="tok-number">4098</span>;</span>
<span class="line" id="L548">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDLOWAT = <span class="tok-number">4099</span>;</span>
<span class="line" id="L549">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVLOWAT = <span class="tok-number">4100</span>;</span>
<span class="line" id="L550">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SNDTIMEO = <span class="tok-number">4101</span>;</span>
<span class="line" id="L551">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RCVTIMEO = <span class="tok-number">4102</span>;</span>
<span class="line" id="L552">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERROR = <span class="tok-number">4103</span>;</span>
<span class="line" id="L553">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TYPE = <span class="tok-number">4104</span>;</span>
<span class="line" id="L554">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BSP_STATE = <span class="tok-number">4105</span>;</span>
<span class="line" id="L555">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GROUP_ID = <span class="tok-number">8193</span>;</span>
<span class="line" id="L556">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GROUP_PRIORITY = <span class="tok-number">8194</span>;</span>
<span class="line" id="L557">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_MSG_SIZE = <span class="tok-number">8195</span>;</span>
<span class="line" id="L558">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONDITIONAL_ACCEPT = <span class="tok-number">12290</span>;</span>
<span class="line" id="L559">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PAUSE_ACCEPT = <span class="tok-number">12291</span>;</span>
<span class="line" id="L560">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> COMPARTMENT_ID = <span class="tok-number">12292</span>;</span>
<span class="line" id="L561">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RANDOMIZE_PORT = <span class="tok-number">12293</span>;</span>
<span class="line" id="L562">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PORT_SCALABILITY = <span class="tok-number">12294</span>;</span>
<span class="line" id="L563">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSE_UNICASTPORT = <span class="tok-number">12295</span>;</span>
<span class="line" id="L564">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REUSE_MULTICASTPORT = <span class="tok-number">12296</span>;</span>
<span class="line" id="L565">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ORIGINAL_DST = <span class="tok-number">12303</span>;</span>
<span class="line" id="L566">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL_INFOA = <span class="tok-number">8196</span>;</span>
<span class="line" id="L567">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROTOCOL_INFOW = <span class="tok-number">8197</span>;</span>
<span class="line" id="L568">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNDATA = <span class="tok-number">28672</span>;</span>
<span class="line" id="L569">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNOPT = <span class="tok-number">28673</span>;</span>
<span class="line" id="L570">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCDATA = <span class="tok-number">28674</span>;</span>
<span class="line" id="L571">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCOPT = <span class="tok-number">28675</span>;</span>
<span class="line" id="L572">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNDATALEN = <span class="tok-number">28676</span>;</span>
<span class="line" id="L573">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNOPTLEN = <span class="tok-number">28677</span>;</span>
<span class="line" id="L574">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCDATALEN = <span class="tok-number">28678</span>;</span>
<span class="line" id="L575">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISCOPTLEN = <span class="tok-number">28679</span>;</span>
<span class="line" id="L576">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OPENTYPE = <span class="tok-number">28680</span>;</span>
<span class="line" id="L577">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNCHRONOUS_ALERT = <span class="tok-number">16</span>;</span>
<span class="line" id="L578">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNCHRONOUS_NONALERT = <span class="tok-number">32</span>;</span>
<span class="line" id="L579">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXDG = <span class="tok-number">28681</span>;</span>
<span class="line" id="L580">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXPATHDG = <span class="tok-number">28682</span>;</span>
<span class="line" id="L581">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UPDATE_ACCEPT_CONTEXT = <span class="tok-number">28683</span>;</span>
<span class="line" id="L582">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CONNECT_TIME = <span class="tok-number">28684</span>;</span>
<span class="line" id="L583">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UPDATE_CONNECT_CONTEXT = <span class="tok-number">28688</span>;</span>
<span class="line" id="L584">};</span>
<span class="line" id="L585"></span>
<span class="line" id="L586"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSK_SO_BASE = <span class="tok-number">16384</span>;</span>
<span class="line" id="L587"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_UNIX = <span class="tok-number">0</span>;</span>
<span class="line" id="L588"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_WS2 = <span class="tok-number">134217728</span>;</span>
<span class="line" id="L589"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_PROTOCOL = <span class="tok-number">268435456</span>;</span>
<span class="line" id="L590"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_VENDOR = <span class="tok-number">402653184</span>;</span>
<span class="line" id="L591"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_GET_EXTENSION_FUNCTION_POINTER = IOC_OUT | IOC_IN | IOC_WS2 | <span class="tok-number">6</span>;</span>
<span class="line" id="L592"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_BSP_HANDLE = IOC_OUT | IOC_WS2 | <span class="tok-number">27</span>;</span>
<span class="line" id="L593"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_BSP_HANDLE_SELECT = IOC_OUT | IOC_WS2 | <span class="tok-number">28</span>;</span>
<span class="line" id="L594"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_BSP_HANDLE_POLL = IOC_OUT | IOC_WS2 | <span class="tok-number">29</span>;</span>
<span class="line" id="L595"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIO_BASE_HANDLE = IOC_OUT | IOC_WS2 | <span class="tok-number">34</span>;</span>
<span class="line" id="L596"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_TCPMUX = <span class="tok-number">1</span>;</span>
<span class="line" id="L597"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_ECHO = <span class="tok-number">7</span>;</span>
<span class="line" id="L598"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_DISCARD = <span class="tok-number">9</span>;</span>
<span class="line" id="L599"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_SYSTAT = <span class="tok-number">11</span>;</span>
<span class="line" id="L600"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_DAYTIME = <span class="tok-number">13</span>;</span>
<span class="line" id="L601"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NETSTAT = <span class="tok-number">15</span>;</span>
<span class="line" id="L602"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_QOTD = <span class="tok-number">17</span>;</span>
<span class="line" id="L603"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_MSP = <span class="tok-number">18</span>;</span>
<span class="line" id="L604"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_CHARGEN = <span class="tok-number">19</span>;</span>
<span class="line" id="L605"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_FTP_DATA = <span class="tok-number">20</span>;</span>
<span class="line" id="L606"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_FTP = <span class="tok-number">21</span>;</span>
<span class="line" id="L607"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_TELNET = <span class="tok-number">23</span>;</span>
<span class="line" id="L608"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_SMTP = <span class="tok-number">25</span>;</span>
<span class="line" id="L609"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_TIMESERVER = <span class="tok-number">37</span>;</span>
<span class="line" id="L610"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NAMESERVER = <span class="tok-number">42</span>;</span>
<span class="line" id="L611"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_WHOIS = <span class="tok-number">43</span>;</span>
<span class="line" id="L612"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_MTP = <span class="tok-number">57</span>;</span>
<span class="line" id="L613"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_TFTP = <span class="tok-number">69</span>;</span>
<span class="line" id="L614"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_RJE = <span class="tok-number">77</span>;</span>
<span class="line" id="L615"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_FINGER = <span class="tok-number">79</span>;</span>
<span class="line" id="L616"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_TTYLINK = <span class="tok-number">87</span>;</span>
<span class="line" id="L617"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_SUPDUP = <span class="tok-number">95</span>;</span>
<span class="line" id="L618"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_POP3 = <span class="tok-number">110</span>;</span>
<span class="line" id="L619"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NTP = <span class="tok-number">123</span>;</span>
<span class="line" id="L620"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_EPMAP = <span class="tok-number">135</span>;</span>
<span class="line" id="L621"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NETBIOS_NS = <span class="tok-number">137</span>;</span>
<span class="line" id="L622"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NETBIOS_DGM = <span class="tok-number">138</span>;</span>
<span class="line" id="L623"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_NETBIOS_SSN = <span class="tok-number">139</span>;</span>
<span class="line" id="L624"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_IMAP = <span class="tok-number">143</span>;</span>
<span class="line" id="L625"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_SNMP = <span class="tok-number">161</span>;</span>
<span class="line" id="L626"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_SNMP_TRAP = <span class="tok-number">162</span>;</span>
<span class="line" id="L627"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_IMAP3 = <span class="tok-number">220</span>;</span>
<span class="line" id="L628"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_LDAP = <span class="tok-number">389</span>;</span>
<span class="line" id="L629"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_HTTPS = <span class="tok-number">443</span>;</span>
<span class="line" id="L630"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_MICROSOFT_DS = <span class="tok-number">445</span>;</span>
<span class="line" id="L631"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_EXECSERVER = <span class="tok-number">512</span>;</span>
<span class="line" id="L632"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_LOGINSERVER = <span class="tok-number">513</span>;</span>
<span class="line" id="L633"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_CMDSERVER = <span class="tok-number">514</span>;</span>
<span class="line" id="L634"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_EFSSERVER = <span class="tok-number">520</span>;</span>
<span class="line" id="L635"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_BIFFUDP = <span class="tok-number">512</span>;</span>
<span class="line" id="L636"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_WHOSERVER = <span class="tok-number">513</span>;</span>
<span class="line" id="L637"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_ROUTESERVER = <span class="tok-number">520</span>;</span>
<span class="line" id="L638"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_RESERVED = <span class="tok-number">1024</span>;</span>
<span class="line" id="L639"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_REGISTERED_MAX = <span class="tok-number">49151</span>;</span>
<span class="line" id="L640"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_DYNAMIC_MIN = <span class="tok-number">49152</span>;</span>
<span class="line" id="L641"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPORT_DYNAMIC_MAX = <span class="tok-number">65535</span>;</span>
<span class="line" id="L642"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSA_NET = <span class="tok-number">4278190080</span>;</span>
<span class="line" id="L643"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSA_NSHIFT = <span class="tok-number">24</span>;</span>
<span class="line" id="L644"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSA_HOST = <span class="tok-number">16777215</span>;</span>
<span class="line" id="L645"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSA_MAX = <span class="tok-number">128</span>;</span>
<span class="line" id="L646"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSB_NET = <span class="tok-number">4294901760</span>;</span>
<span class="line" id="L647"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSB_NSHIFT = <span class="tok-number">16</span>;</span>
<span class="line" id="L648"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSB_HOST = <span class="tok-number">65535</span>;</span>
<span class="line" id="L649"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSB_MAX = <span class="tok-number">65536</span>;</span>
<span class="line" id="L650"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSC_NET = <span class="tok-number">4294967040</span>;</span>
<span class="line" id="L651"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSC_NSHIFT = <span class="tok-number">8</span>;</span>
<span class="line" id="L652"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSC_HOST = <span class="tok-number">255</span>;</span>
<span class="line" id="L653"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSD_NET = <span class="tok-number">4026531840</span>;</span>
<span class="line" id="L654"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSD_NSHIFT = <span class="tok-number">28</span>;</span>
<span class="line" id="L655"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IN_CLASSD_HOST = <span class="tok-number">268435455</span>;</span>
<span class="line" id="L656"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INADDR_LOOPBACK = <span class="tok-number">2130706433</span>;</span>
<span class="line" id="L657"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INADDR_NONE = <span class="tok-number">4294967295</span>;</span>
<span class="line" id="L658"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOCPARM_MASK = <span class="tok-number">127</span>;</span>
<span class="line" id="L659"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_VOID = <span class="tok-number">536870912</span>;</span>
<span class="line" id="L660"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_OUT = <span class="tok-number">1073741824</span>;</span>
<span class="line" id="L661"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOC_IN = <span class="tok-number">2147483648</span>;</span>
<span class="line" id="L662"></span>
<span class="line" id="L663"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MSG = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L664">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRUNC = <span class="tok-number">256</span>;</span>
<span class="line" id="L665">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CTRUNC = <span class="tok-number">512</span>;</span>
<span class="line" id="L666">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BCAST = <span class="tok-number">1024</span>;</span>
<span class="line" id="L667">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MCAST = <span class="tok-number">2048</span>;</span>
<span class="line" id="L668">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERRQUEUE = <span class="tok-number">4096</span>;</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PEEK = <span class="tok-number">2</span>;</span>
<span class="line" id="L671">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WAITALL = <span class="tok-number">8</span>;</span>
<span class="line" id="L672">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUSH_IMMEDIATE = <span class="tok-number">32</span>;</span>
<span class="line" id="L673">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PARTIAL = <span class="tok-number">32768</span>;</span>
<span class="line" id="L674">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> INTERRUPT = <span class="tok-number">16</span>;</span>
<span class="line" id="L675">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXIOVLEN = <span class="tok-number">16</span>;</span>
<span class="line" id="L676">};</span>
<span class="line" id="L677"></span>
<span class="line" id="L678"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AI = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L679">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASSIVE = <span class="tok-number">1</span>;</span>
<span class="line" id="L680">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CANONNAME = <span class="tok-number">2</span>;</span>
<span class="line" id="L681">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NUMERICHOST = <span class="tok-number">4</span>;</span>
<span class="line" id="L682">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NUMERICSERV = <span class="tok-number">8</span>;</span>
<span class="line" id="L683">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DNS_ONLY = <span class="tok-number">16</span>;</span>
<span class="line" id="L684">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALL = <span class="tok-number">256</span>;</span>
<span class="line" id="L685">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRCONFIG = <span class="tok-number">1024</span>;</span>
<span class="line" id="L686">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> V4MAPPED = <span class="tok-number">2048</span>;</span>
<span class="line" id="L687">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NON_AUTHORITATIVE = <span class="tok-number">16384</span>;</span>
<span class="line" id="L688">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURE = <span class="tok-number">32768</span>;</span>
<span class="line" id="L689">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RETURN_PREFERRED_NAMES = <span class="tok-number">65536</span>;</span>
<span class="line" id="L690">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FQDN = <span class="tok-number">131072</span>;</span>
<span class="line" id="L691">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILESERVER = <span class="tok-number">262144</span>;</span>
<span class="line" id="L692">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DISABLE_IDN_ENCODING = <span class="tok-number">524288</span>;</span>
<span class="line" id="L693">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXTENDED = <span class="tok-number">2147483648</span>;</span>
<span class="line" id="L694">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESOLUTION_HANDLE = <span class="tok-number">1073741824</span>;</span>
<span class="line" id="L695">};</span>
<span class="line" id="L696"></span>
<span class="line" id="L697"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FIONBIO = -<span class="tok-number">2147195266</span>;</span>
<span class="line" id="L698"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRINFOEX_VERSION_2 = <span class="tok-number">2</span>;</span>
<span class="line" id="L699"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRINFOEX_VERSION_3 = <span class="tok-number">3</span>;</span>
<span class="line" id="L700"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADDRINFOEX_VERSION_4 = <span class="tok-number">4</span>;</span>
<span class="line" id="L701"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_ALL = <span class="tok-number">0</span>;</span>
<span class="line" id="L702"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_SAP = <span class="tok-number">1</span>;</span>
<span class="line" id="L703"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NDS = <span class="tok-number">2</span>;</span>
<span class="line" id="L704"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_PEER_BROWSE = <span class="tok-number">3</span>;</span>
<span class="line" id="L705"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_SLP = <span class="tok-number">5</span>;</span>
<span class="line" id="L706"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_DHCP = <span class="tok-number">6</span>;</span>
<span class="line" id="L707"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_TCPIP_LOCAL = <span class="tok-number">10</span>;</span>
<span class="line" id="L708"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_TCPIP_HOSTS = <span class="tok-number">11</span>;</span>
<span class="line" id="L709"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_DNS = <span class="tok-number">12</span>;</span>
<span class="line" id="L710"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NETBT = <span class="tok-number">13</span>;</span>
<span class="line" id="L711"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_WINS = <span class="tok-number">14</span>;</span>
<span class="line" id="L712"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NLA = <span class="tok-number">15</span>;</span>
<span class="line" id="L713"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NBP = <span class="tok-number">20</span>;</span>
<span class="line" id="L714"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_MS = <span class="tok-number">30</span>;</span>
<span class="line" id="L715"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_STDA = <span class="tok-number">31</span>;</span>
<span class="line" id="L716"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NTDS = <span class="tok-number">32</span>;</span>
<span class="line" id="L717"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_EMAIL = <span class="tok-number">37</span>;</span>
<span class="line" id="L718"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_X500 = <span class="tok-number">40</span>;</span>
<span class="line" id="L719"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NIS = <span class="tok-number">41</span>;</span>
<span class="line" id="L720"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NISPLUS = <span class="tok-number">42</span>;</span>
<span class="line" id="L721"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_WRQ = <span class="tok-number">50</span>;</span>
<span class="line" id="L722"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_NETDES = <span class="tok-number">60</span>;</span>
<span class="line" id="L723"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_NOFQDN = <span class="tok-number">1</span>;</span>
<span class="line" id="L724"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_NUMERICHOST = <span class="tok-number">2</span>;</span>
<span class="line" id="L725"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_NAMEREQD = <span class="tok-number">4</span>;</span>
<span class="line" id="L726"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_NUMERICSERV = <span class="tok-number">8</span>;</span>
<span class="line" id="L727"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_DGRAM = <span class="tok-number">16</span>;</span>
<span class="line" id="L728"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_MAXHOST = <span class="tok-number">1025</span>;</span>
<span class="line" id="L729"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NI_MAXSERV = <span class="tok-number">32</span>;</span>
<span class="line" id="L730"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCL_WINSOCK_API_PROTOTYPES = <span class="tok-number">1</span>;</span>
<span class="line" id="L731"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INCL_WINSOCK_API_TYPEDEFS = <span class="tok-number">0</span>;</span>
<span class="line" id="L732"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_SETSIZE = <span class="tok-number">64</span>;</span>
<span class="line" id="L733"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMPLINK_IP = <span class="tok-number">155</span>;</span>
<span class="line" id="L734"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMPLINK_LOWEXPER = <span class="tok-number">156</span>;</span>
<span class="line" id="L735"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IMPLINK_HIGHEXPER = <span class="tok-number">158</span>;</span>
<span class="line" id="L736"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSADESCRIPTION_LEN = <span class="tok-number">256</span>;</span>
<span class="line" id="L737"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSASYS_STATUS_LEN = <span class="tok-number">128</span>;</span>
<span class="line" id="L738"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_ERROR = -<span class="tok-number">1</span>;</span>
<span class="line" id="L739"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FROM_PROTOCOL_INFO = -<span class="tok-number">1</span>;</span>
<span class="line" id="L740"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PVD_CONFIG = <span class="tok-number">12289</span>;</span>
<span class="line" id="L741"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOMAXCONN = <span class="tok-number">2147483647</span>;</span>
<span class="line" id="L742"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAXGETHOSTSTRUCT = <span class="tok-number">1024</span>;</span>
<span class="line" id="L743"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_READ_BIT = <span class="tok-number">0</span>;</span>
<span class="line" id="L744"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_WRITE_BIT = <span class="tok-number">1</span>;</span>
<span class="line" id="L745"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_OOB_BIT = <span class="tok-number">2</span>;</span>
<span class="line" id="L746"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ACCEPT_BIT = <span class="tok-number">3</span>;</span>
<span class="line" id="L747"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CONNECT_BIT = <span class="tok-number">4</span>;</span>
<span class="line" id="L748"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CLOSE_BIT = <span class="tok-number">5</span>;</span>
<span class="line" id="L749"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_QOS_BIT = <span class="tok-number">6</span>;</span>
<span class="line" id="L750"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_GROUP_QOS_BIT = <span class="tok-number">7</span>;</span>
<span class="line" id="L751"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ROUTING_INTERFACE_CHANGE_BIT = <span class="tok-number">8</span>;</span>
<span class="line" id="L752"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ADDRESS_LIST_CHANGE_BIT = <span class="tok-number">9</span>;</span>
<span class="line" id="L753"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_MAX_EVENTS = <span class="tok-number">10</span>;</span>
<span class="line" id="L754"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CF_ACCEPT = <span class="tok-number">0</span>;</span>
<span class="line" id="L755"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CF_REJECT = <span class="tok-number">1</span>;</span>
<span class="line" id="L756"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CF_DEFER = <span class="tok-number">2</span>;</span>
<span class="line" id="L757"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SD_RECEIVE = <span class="tok-number">0</span>;</span>
<span class="line" id="L758"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SD_SEND = <span class="tok-number">1</span>;</span>
<span class="line" id="L759"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SD_BOTH = <span class="tok-number">2</span>;</span>
<span class="line" id="L760"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SG_UNCONSTRAINED_GROUP = <span class="tok-number">1</span>;</span>
<span class="line" id="L761"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SG_CONSTRAINED_GROUP = <span class="tok-number">2</span>;</span>
<span class="line" id="L762"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PROTOCOL_CHAIN = <span class="tok-number">7</span>;</span>
<span class="line" id="L763"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BASE_PROTOCOL = <span class="tok-number">1</span>;</span>
<span class="line" id="L764"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LAYERED_PROTOCOL = <span class="tok-number">0</span>;</span>
<span class="line" id="L765"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAPROTOCOL_LEN = <span class="tok-number">255</span>;</span>
<span class="line" id="L766"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PFL_MULTIPLE_PROTO_ENTRIES = <span class="tok-number">1</span>;</span>
<span class="line" id="L767"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PFL_RECOMMENDED_PROTO_ENTRY = <span class="tok-number">2</span>;</span>
<span class="line" id="L768"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PFL_HIDDEN = <span class="tok-number">4</span>;</span>
<span class="line" id="L769"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PFL_MATCHES_PROTOCOL_ZERO = <span class="tok-number">8</span>;</span>
<span class="line" id="L770"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PFL_NETWORKDIRECT_PROVIDER = <span class="tok-number">16</span>;</span>
<span class="line" id="L771"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_CONNECTIONLESS = <span class="tok-number">1</span>;</span>
<span class="line" id="L772"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_GUARANTEED_DELIVERY = <span class="tok-number">2</span>;</span>
<span class="line" id="L773"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_GUARANTEED_ORDER = <span class="tok-number">4</span>;</span>
<span class="line" id="L774"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_MESSAGE_ORIENTED = <span class="tok-number">8</span>;</span>
<span class="line" id="L775"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_PSEUDO_STREAM = <span class="tok-number">16</span>;</span>
<span class="line" id="L776"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_GRACEFUL_CLOSE = <span class="tok-number">32</span>;</span>
<span class="line" id="L777"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_EXPEDITED_DATA = <span class="tok-number">64</span>;</span>
<span class="line" id="L778"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_CONNECT_DATA = <span class="tok-number">128</span>;</span>
<span class="line" id="L779"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_DISCONNECT_DATA = <span class="tok-number">256</span>;</span>
<span class="line" id="L780"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_SUPPORT_BROADCAST = <span class="tok-number">512</span>;</span>
<span class="line" id="L781"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_SUPPORT_MULTIPOINT = <span class="tok-number">1024</span>;</span>
<span class="line" id="L782"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_MULTIPOINT_CONTROL_PLANE = <span class="tok-number">2048</span>;</span>
<span class="line" id="L783"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_MULTIPOINT_DATA_PLANE = <span class="tok-number">4096</span>;</span>
<span class="line" id="L784"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_QOS_SUPPORTED = <span class="tok-number">8192</span>;</span>
<span class="line" id="L785"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_INTERRUPT = <span class="tok-number">16384</span>;</span>
<span class="line" id="L786"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_UNI_SEND = <span class="tok-number">32768</span>;</span>
<span class="line" id="L787"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_UNI_RECV = <span class="tok-number">65536</span>;</span>
<span class="line" id="L788"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_IFS_HANDLES = <span class="tok-number">131072</span>;</span>
<span class="line" id="L789"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_PARTIAL_MESSAGE = <span class="tok-number">262144</span>;</span>
<span class="line" id="L790"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP1_SAN_SUPPORT_SDP = <span class="tok-number">524288</span>;</span>
<span class="line" id="L791"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BIGENDIAN = <span class="tok-number">0</span>;</span>
<span class="line" id="L792"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LITTLEENDIAN = <span class="tok-number">1</span>;</span>
<span class="line" id="L793"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SECURITY_PROTOCOL_NONE = <span class="tok-number">0</span>;</span>
<span class="line" id="L794"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JL_SENDER_ONLY = <span class="tok-number">1</span>;</span>
<span class="line" id="L795"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JL_RECEIVER_ONLY = <span class="tok-number">2</span>;</span>
<span class="line" id="L796"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JL_BOTH = <span class="tok-number">4</span>;</span>
<span class="line" id="L797"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_OVERLAPPED = <span class="tok-number">1</span>;</span>
<span class="line" id="L798"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_MULTIPOINT_C_ROOT = <span class="tok-number">2</span>;</span>
<span class="line" id="L799"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_MULTIPOINT_C_LEAF = <span class="tok-number">4</span>;</span>
<span class="line" id="L800"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_MULTIPOINT_D_ROOT = <span class="tok-number">8</span>;</span>
<span class="line" id="L801"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_MULTIPOINT_D_LEAF = <span class="tok-number">16</span>;</span>
<span class="line" id="L802"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_ACCESS_SYSTEM_SECURITY = <span class="tok-number">64</span>;</span>
<span class="line" id="L803"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_NO_HANDLE_INHERIT = <span class="tok-number">128</span>;</span>
<span class="line" id="L804"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSA_FLAG_REGISTERED_IO = <span class="tok-number">256</span>;</span>
<span class="line" id="L805"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TH_NETDEV = <span class="tok-number">1</span>;</span>
<span class="line" id="L806"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TH_TAPI = <span class="tok-number">2</span>;</span>
<span class="line" id="L807"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_MULTIPLE = <span class="tok-number">1</span>;</span>
<span class="line" id="L808"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_LOCALNAME = <span class="tok-number">19</span>;</span>
<span class="line" id="L809"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RES_UNUSED_1 = <span class="tok-number">1</span>;</span>
<span class="line" id="L810"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RES_FLUSH_CACHE = <span class="tok-number">2</span>;</span>
<span class="line" id="L811"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RES_SERVICE = <span class="tok-number">4</span>;</span>
<span class="line" id="L812"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_DEEP = <span class="tok-number">1</span>;</span>
<span class="line" id="L813"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_CONTAINERS = <span class="tok-number">2</span>;</span>
<span class="line" id="L814"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_NOCONTAINERS = <span class="tok-number">4</span>;</span>
<span class="line" id="L815"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_NEAREST = <span class="tok-number">8</span>;</span>
<span class="line" id="L816"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_NAME = <span class="tok-number">16</span>;</span>
<span class="line" id="L817"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_TYPE = <span class="tok-number">32</span>;</span>
<span class="line" id="L818"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_VERSION = <span class="tok-number">64</span>;</span>
<span class="line" id="L819"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_COMMENT = <span class="tok-number">128</span>;</span>
<span class="line" id="L820"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_ADDR = <span class="tok-number">256</span>;</span>
<span class="line" id="L821"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_BLOB = <span class="tok-number">512</span>;</span>
<span class="line" id="L822"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_ALIASES = <span class="tok-number">1024</span>;</span>
<span class="line" id="L823"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_QUERY_STRING = <span class="tok-number">2048</span>;</span>
<span class="line" id="L824"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_ALL = <span class="tok-number">4080</span>;</span>
<span class="line" id="L825"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RES_SERVICE = <span class="tok-number">32768</span>;</span>
<span class="line" id="L826"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_FLUSHCACHE = <span class="tok-number">4096</span>;</span>
<span class="line" id="L827"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_FLUSHPREVIOUS = <span class="tok-number">8192</span>;</span>
<span class="line" id="L828"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_NON_AUTHORITATIVE = <span class="tok-number">16384</span>;</span>
<span class="line" id="L829"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_SECURE = <span class="tok-number">32768</span>;</span>
<span class="line" id="L830"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RETURN_PREFERRED_NAMES = <span class="tok-number">65536</span>;</span>
<span class="line" id="L831"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_DNS_ONLY = <span class="tok-number">131072</span>;</span>
<span class="line" id="L832"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_ADDRCONFIG = <span class="tok-number">1048576</span>;</span>
<span class="line" id="L833"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_DUAL_ADDR = <span class="tok-number">2097152</span>;</span>
<span class="line" id="L834"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_FILESERVER = <span class="tok-number">4194304</span>;</span>
<span class="line" id="L835"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_DISABLE_IDN_ENCODING = <span class="tok-number">8388608</span>;</span>
<span class="line" id="L836"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_API_ANSI = <span class="tok-number">16777216</span>;</span>
<span class="line" id="L837"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUP_RESOLUTION_HANDLE = <span class="tok-number">2147483648</span>;</span>
<span class="line" id="L838"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESULT_IS_ALIAS = <span class="tok-number">1</span>;</span>
<span class="line" id="L839"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESULT_IS_ADDED = <span class="tok-number">16</span>;</span>
<span class="line" id="L840"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESULT_IS_CHANGED = <span class="tok-number">32</span>;</span>
<span class="line" id="L841"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RESULT_IS_DELETED = <span class="tok-number">64</span>;</span>
<span class="line" id="L842"></span>
<span class="line" id="L843"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L844">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDNORM = <span class="tok-number">256</span>;</span>
<span class="line" id="L845">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RDBAND = <span class="tok-number">512</span>;</span>
<span class="line" id="L846">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PRI = <span class="tok-number">1024</span>;</span>
<span class="line" id="L847">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRNORM = <span class="tok-number">16</span>;</span>
<span class="line" id="L848">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WRBAND = <span class="tok-number">32</span>;</span>
<span class="line" id="L849">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ERR = <span class="tok-number">1</span>;</span>
<span class="line" id="L850">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUP = <span class="tok-number">2</span>;</span>
<span class="line" id="L851">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NVAL = <span class="tok-number">4</span>;</span>
<span class="line" id="L852">};</span>
<span class="line" id="L853"></span>
<span class="line" id="L854"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_DISCONNECT = <span class="tok-number">1</span>;</span>
<span class="line" id="L855"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_REUSE_SOCKET = <span class="tok-number">2</span>;</span>
<span class="line" id="L856"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_WRITE_BEHIND = <span class="tok-number">4</span>;</span>
<span class="line" id="L857"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_USE_DEFAULT_WORKER = <span class="tok-number">0</span>;</span>
<span class="line" id="L858"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_USE_SYSTEM_THREAD = <span class="tok-number">16</span>;</span>
<span class="line" id="L859"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TF_USE_KERNEL_APC = <span class="tok-number">32</span>;</span>
<span class="line" id="L860"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TP_ELEMENT_MEMORY = <span class="tok-number">1</span>;</span>
<span class="line" id="L861"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TP_ELEMENT_FILE = <span class="tok-number">2</span>;</span>
<span class="line" id="L862"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TP_ELEMENT_EOP = <span class="tok-number">4</span>;</span>
<span class="line" id="L863"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLA_ALLUSERS_NETWORK = <span class="tok-number">1</span>;</span>
<span class="line" id="L864"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NLA_FRIENDLY_NAME = <span class="tok-number">2</span>;</span>
<span class="line" id="L865"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSPDESCRIPTION_LEN = <span class="tok-number">255</span>;</span>
<span class="line" id="L866"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSS_OPERATION_IN_PROGRESS = <span class="tok-number">259</span>;</span>
<span class="line" id="L867"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_SYSTEM = <span class="tok-number">2147483648</span>;</span>
<span class="line" id="L868"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_INSPECTOR = <span class="tok-number">1</span>;</span>
<span class="line" id="L869"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_REDIRECTOR = <span class="tok-number">2</span>;</span>
<span class="line" id="L870"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_PROXY = <span class="tok-number">4</span>;</span>
<span class="line" id="L871"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_FIREWALL = <span class="tok-number">8</span>;</span>
<span class="line" id="L872"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_INBOUND_MODIFY = <span class="tok-number">16</span>;</span>
<span class="line" id="L873"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_OUTBOUND_MODIFY = <span class="tok-number">32</span>;</span>
<span class="line" id="L874"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_CRYPTO_COMPRESS = <span class="tok-number">64</span>;</span>
<span class="line" id="L875"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LSP_LOCAL_CACHE = <span class="tok-number">128</span>;</span>
<span class="line" id="L876"></span>
<span class="line" id="L877"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IPPROTO = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L878">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP = <span class="tok-number">0</span>;</span>
<span class="line" id="L879">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICMP = <span class="tok-number">1</span>;</span>
<span class="line" id="L880">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGMP = <span class="tok-number">2</span>;</span>
<span class="line" id="L881">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> GGP = <span class="tok-number">3</span>;</span>
<span class="line" id="L882">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TCP = <span class="tok-number">6</span>;</span>
<span class="line" id="L883">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUP = <span class="tok-number">12</span>;</span>
<span class="line" id="L884">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP = <span class="tok-number">17</span>;</span>
<span class="line" id="L885">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IDP = <span class="tok-number">22</span>;</span>
<span class="line" id="L886">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ND = <span class="tok-number">77</span>;</span>
<span class="line" id="L887">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RM = <span class="tok-number">113</span>;</span>
<span class="line" id="L888">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RAW = <span class="tok-number">255</span>;</span>
<span class="line" id="L889">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX = <span class="tok-number">256</span>;</span>
<span class="line" id="L890">};</span>
<span class="line" id="L891"></span>
<span class="line" id="L892"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DEFAULT_MULTICAST_TTL = <span class="tok-number">1</span>;</span>
<span class="line" id="L893"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_DEFAULT_MULTICAST_LOOP = <span class="tok-number">1</span>;</span>
<span class="line" id="L894"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IP_MAX_MEMBERSHIPS = <span class="tok-number">20</span>;</span>
<span class="line" id="L895"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_READ = <span class="tok-number">1</span>;</span>
<span class="line" id="L896"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_WRITE = <span class="tok-number">2</span>;</span>
<span class="line" id="L897"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_OOB = <span class="tok-number">4</span>;</span>
<span class="line" id="L898"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ACCEPT = <span class="tok-number">8</span>;</span>
<span class="line" id="L899"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CONNECT = <span class="tok-number">16</span>;</span>
<span class="line" id="L900"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_CLOSE = <span class="tok-number">32</span>;</span>
<span class="line" id="L901"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_RESOURCE = <span class="tok-number">1</span>;</span>
<span class="line" id="L902"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_SERVICE = <span class="tok-number">2</span>;</span>
<span class="line" id="L903"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_LOCAL = <span class="tok-number">4</span>;</span>
<span class="line" id="L904"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_FLAG_DEFER = <span class="tok-number">1</span>;</span>
<span class="line" id="L905"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_FLAG_HARD = <span class="tok-number">2</span>;</span>
<span class="line" id="L906"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_COMMENT = <span class="tok-number">1</span>;</span>
<span class="line" id="L907"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_LOCALE = <span class="tok-number">2</span>;</span>
<span class="line" id="L908"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_DISPLAY_HINT = <span class="tok-number">4</span>;</span>
<span class="line" id="L909"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_VERSION = <span class="tok-number">8</span>;</span>
<span class="line" id="L910"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_START_TIME = <span class="tok-number">16</span>;</span>
<span class="line" id="L911"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_MACHINE = <span class="tok-number">32</span>;</span>
<span class="line" id="L912"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_ADDRESSES = <span class="tok-number">256</span>;</span>
<span class="line" id="L913"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_SD = <span class="tok-number">512</span>;</span>
<span class="line" id="L914"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROP_ALL = <span class="tok-number">2147483648</span>;</span>
<span class="line" id="L915"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_ADDRESS_FLAG_RPC_CN = <span class="tok-number">1</span>;</span>
<span class="line" id="L916"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_ADDRESS_FLAG_RPC_DG = <span class="tok-number">2</span>;</span>
<span class="line" id="L917"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_ADDRESS_FLAG_RPC_NB = <span class="tok-number">4</span>;</span>
<span class="line" id="L918"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_DEFAULT = <span class="tok-number">0</span>;</span>
<span class="line" id="L919"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NS_VNS = <span class="tok-number">50</span>;</span>
<span class="line" id="L920"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NSTYPE_HIERARCHICAL = <span class="tok-number">1</span>;</span>
<span class="line" id="L921"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NSTYPE_DYNAMIC = <span class="tok-number">2</span>;</span>
<span class="line" id="L922"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NSTYPE_ENUMERABLE = <span class="tok-number">4</span>;</span>
<span class="line" id="L923"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NSTYPE_WORKGROUP = <span class="tok-number">8</span>;</span>
<span class="line" id="L924"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_CONNECTIONLESS = <span class="tok-number">1</span>;</span>
<span class="line" id="L925"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_GUARANTEED_DELIVERY = <span class="tok-number">2</span>;</span>
<span class="line" id="L926"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_GUARANTEED_ORDER = <span class="tok-number">4</span>;</span>
<span class="line" id="L927"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_MESSAGE_ORIENTED = <span class="tok-number">8</span>;</span>
<span class="line" id="L928"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_PSEUDO_STREAM = <span class="tok-number">16</span>;</span>
<span class="line" id="L929"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_GRACEFUL_CLOSE = <span class="tok-number">32</span>;</span>
<span class="line" id="L930"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_EXPEDITED_DATA = <span class="tok-number">64</span>;</span>
<span class="line" id="L931"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_CONNECT_DATA = <span class="tok-number">128</span>;</span>
<span class="line" id="L932"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_DISCONNECT_DATA = <span class="tok-number">256</span>;</span>
<span class="line" id="L933"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_SUPPORTS_BROADCAST = <span class="tok-number">512</span>;</span>
<span class="line" id="L934"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_SUPPORTS_MULTICAST = <span class="tok-number">1024</span>;</span>
<span class="line" id="L935"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_BANDWIDTH_ALLOCATION = <span class="tok-number">2048</span>;</span>
<span class="line" id="L936"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_FRAGMENTATION = <span class="tok-number">4096</span>;</span>
<span class="line" id="L937"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XP_ENCRYPTS = <span class="tok-number">8192</span>;</span>
<span class="line" id="L938"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RES_SOFT_SEARCH = <span class="tok-number">1</span>;</span>
<span class="line" id="L939"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RES_FIND_MULTIPLE = <span class="tok-number">2</span>;</span>
<span class="line" id="L940"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SET_SERVICE_PARTIAL_SUCCESS = <span class="tok-number">1</span>;</span>
<span class="line" id="L941"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP_NOCHECKSUM = <span class="tok-number">1</span>;</span>
<span class="line" id="L942"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UDP_CHECKSUM_COVERAGE = <span class="tok-number">20</span>;</span>
<span class="line" id="L943"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GAI_STRERROR_BUFFER_SIZE = <span class="tok-number">1024</span>;</span>
<span class="line" id="L944"></span>
<span class="line" id="L945"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPCONDITIONPROC = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L946">    lpCallerId: *WSABUF,</span>
<span class="line" id="L947">    lpCallerData: *WSABUF,</span>
<span class="line" id="L948">    lpSQOS: *QOS,</span>
<span class="line" id="L949">    lpGQOS: *QOS,</span>
<span class="line" id="L950">    lpCalleeId: *WSABUF,</span>
<span class="line" id="L951">    lpCalleeData: *WSABUF,</span>
<span class="line" id="L952">    g: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L953">    dwCallbackData: <span class="tok-type">usize</span>,</span>
<span class="line" id="L954">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L955"></span>
<span class="line" id="L956"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPWSAOVERLAPPED_COMPLETION_ROUTINE = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L957">    dwError: <span class="tok-type">u32</span>,</span>
<span class="line" id="L958">    cbTransferred: <span class="tok-type">u32</span>,</span>
<span class="line" id="L959">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L960">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L961">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L962"></span>
<span class="line" id="L963"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FLOWSPEC = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L964">    TokenRate: <span class="tok-type">u32</span>,</span>
<span class="line" id="L965">    TokenBucketSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L966">    PeakBandwidth: <span class="tok-type">u32</span>,</span>
<span class="line" id="L967">    Latency: <span class="tok-type">u32</span>,</span>
<span class="line" id="L968">    DelayVariation: <span class="tok-type">u32</span>,</span>
<span class="line" id="L969">    ServiceType: <span class="tok-type">u32</span>,</span>
<span class="line" id="L970">    MaxSduSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L971">    MinimumPolicedSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L972">};</span>
<span class="line" id="L973"></span>
<span class="line" id="L974"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QOS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L975">    SendingFlowspec: FLOWSPEC,</span>
<span class="line" id="L976">    ReceivingFlowspec: FLOWSPEC,</span>
<span class="line" id="L977">    ProviderSpecific: WSABUF,</span>
<span class="line" id="L978">};</span>
<span class="line" id="L979"></span>
<span class="line" id="L980"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_ADDRESS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L981">    lpSockaddr: *sockaddr,</span>
<span class="line" id="L982">    iSockaddrLength: <span class="tok-type">i32</span>,</span>
<span class="line" id="L983">};</span>
<span class="line" id="L984"></span>
<span class="line" id="L985"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCKET_ADDRESS_LIST = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L986">    iAddressCount: <span class="tok-type">i32</span>,</span>
<span class="line" id="L987">    Address: [<span class="tok-number">1</span>]SOCKET_ADDRESS,</span>
<span class="line" id="L988">};</span>
<span class="line" id="L989"></span>
<span class="line" id="L990"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSADATA = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(<span class="tok-type">usize</span>) == <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">u64</span>))</span>
<span class="line" id="L991">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L992">        wVersion: WORD,</span>
<span class="line" id="L993">        wHighVersion: WORD,</span>
<span class="line" id="L994">        iMaxSockets: <span class="tok-type">u16</span>,</span>
<span class="line" id="L995">        iMaxUdpDg: <span class="tok-type">u16</span>,</span>
<span class="line" id="L996">        lpVendorInfo: *<span class="tok-type">u8</span>,</span>
<span class="line" id="L997">        szDescription: [WSADESCRIPTION_LEN + <span class="tok-number">1</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L998">        szSystemStatus: [WSASYS_STATUS_LEN + <span class="tok-number">1</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L999">    }</span>
<span class="line" id="L1000"><span class="tok-kw">else</span></span>
<span class="line" id="L1001">    <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1002">        wVersion: WORD,</span>
<span class="line" id="L1003">        wHighVersion: WORD,</span>
<span class="line" id="L1004">        szDescription: [WSADESCRIPTION_LEN + <span class="tok-number">1</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1005">        szSystemStatus: [WSASYS_STATUS_LEN + <span class="tok-number">1</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1006">        iMaxSockets: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1007">        iMaxUdpDg: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1008">        lpVendorInfo: *<span class="tok-type">u8</span>,</span>
<span class="line" id="L1009">    };</span>
<span class="line" id="L1010"></span>
<span class="line" id="L1011"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAPROTOCOLCHAIN = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1012">    ChainLen: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1013">    ChainEntries: [MAX_PROTOCOL_CHAIN]DWORD,</span>
<span class="line" id="L1014">};</span>
<span class="line" id="L1015"></span>
<span class="line" id="L1016"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAPROTOCOL_INFOA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1017">    dwServiceFlags1: DWORD,</span>
<span class="line" id="L1018">    dwServiceFlags2: DWORD,</span>
<span class="line" id="L1019">    dwServiceFlags3: DWORD,</span>
<span class="line" id="L1020">    dwServiceFlags4: DWORD,</span>
<span class="line" id="L1021">    dwProviderFlags: DWORD,</span>
<span class="line" id="L1022">    ProviderId: GUID,</span>
<span class="line" id="L1023">    dwCatalogEntryId: DWORD,</span>
<span class="line" id="L1024">    ProtocolChain: WSAPROTOCOLCHAIN,</span>
<span class="line" id="L1025">    iVersion: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1026">    iAddressFamily: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1027">    iMaxSockAddr: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1028">    iMinSockAddr: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1029">    iSocketType: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1030">    iProtocol: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1031">    iProtocolMaxOffset: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1032">    iNetworkByteOrder: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1033">    iSecurityScheme: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1034">    dwMessageSize: DWORD,</span>
<span class="line" id="L1035">    dwProviderReserved: DWORD,</span>
<span class="line" id="L1036">    szProtocol: [WSAPROTOCOL_LEN + <span class="tok-number">1</span>]CHAR,</span>
<span class="line" id="L1037">};</span>
<span class="line" id="L1038"></span>
<span class="line" id="L1039"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAPROTOCOL_INFOW = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1040">    dwServiceFlags1: DWORD,</span>
<span class="line" id="L1041">    dwServiceFlags2: DWORD,</span>
<span class="line" id="L1042">    dwServiceFlags3: DWORD,</span>
<span class="line" id="L1043">    dwServiceFlags4: DWORD,</span>
<span class="line" id="L1044">    dwProviderFlags: DWORD,</span>
<span class="line" id="L1045">    ProviderId: GUID,</span>
<span class="line" id="L1046">    dwCatalogEntryId: DWORD,</span>
<span class="line" id="L1047">    ProtocolChain: WSAPROTOCOLCHAIN,</span>
<span class="line" id="L1048">    iVersion: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1049">    iAddressFamily: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1050">    iMaxSockAddr: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1051">    iMinSockAddr: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1052">    iSocketType: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1053">    iProtocol: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1054">    iProtocolMaxOffset: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1055">    iNetworkByteOrder: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1056">    iSecurityScheme: <span class="tok-type">c_int</span>,</span>
<span class="line" id="L1057">    dwMessageSize: DWORD,</span>
<span class="line" id="L1058">    dwProviderReserved: DWORD,</span>
<span class="line" id="L1059">    szProtocol: [WSAPROTOCOL_LEN + <span class="tok-number">1</span>]WCHAR,</span>
<span class="line" id="L1060">};</span>
<span class="line" id="L1061"></span>
<span class="line" id="L1062"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sockproto = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1063">    sp_family: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1064">    sp_protocol: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1065">};</span>
<span class="line" id="L1066"></span>
<span class="line" id="L1067"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> linger = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1068">    l_onoff: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1069">    l_linger: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1070">};</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSANETWORKEVENTS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1073">    lNetworkEvents: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1074">    iErrorCode: [<span class="tok-number">10</span>]<span class="tok-type">i32</span>,</span>
<span class="line" id="L1075">};</span>
<span class="line" id="L1076"></span>
<span class="line" id="L1077"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrinfo = addrinfoa;</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrinfoa = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1080">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1081">    family: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1082">    socktype: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1083">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1084">    addrlen: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1085">    canonname: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1086">    addr: ?*sockaddr,</span>
<span class="line" id="L1087">    next: ?*addrinfo,</span>
<span class="line" id="L1088">};</span>
<span class="line" id="L1089"></span>
<span class="line" id="L1090"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrinfoexA = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1091">    ai_flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1092">    ai_family: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1093">    ai_socktype: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1094">    ai_protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1095">    ai_addrlen: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1096">    ai_canonname: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1097">    ai_addr: *sockaddr,</span>
<span class="line" id="L1098">    ai_blob: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1099">    ai_bloblen: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1100">    ai_provider: *GUID,</span>
<span class="line" id="L1101">    ai_next: *addrinfoexA,</span>
<span class="line" id="L1102">};</span>
<span class="line" id="L1103"></span>
<span class="line" id="L1104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sockaddr = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1105">    family: ADDRESS_FAMILY,</span>
<span class="line" id="L1106">    data: [<span class="tok-number">14</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1107"></span>
<span class="line" id="L1108">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SS_MAXSIZE = <span class="tok-number">128</span>;</span>
<span class="line" id="L1109">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> storage = std.x.os.Socket.Address.Native.Storage;</span>
<span class="line" id="L1110"></span>
<span class="line" id="L1111">    <span class="tok-comment">/// IPv4 socket address</span></span>
<span class="line" id="L1112">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> in = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1113">        family: ADDRESS_FAMILY = AF.INET,</span>
<span class="line" id="L1114">        port: USHORT,</span>
<span class="line" id="L1115">        addr: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1116">        zero: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span> },</span>
<span class="line" id="L1117">    };</span>
<span class="line" id="L1118"></span>
<span class="line" id="L1119">    <span class="tok-comment">/// IPv6 socket address</span></span>
<span class="line" id="L1120">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> in6 = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1121">        family: ADDRESS_FAMILY = AF.INET6,</span>
<span class="line" id="L1122">        port: USHORT,</span>
<span class="line" id="L1123">        flowinfo: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1124">        addr: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1125">        scope_id: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1126">    };</span>
<span class="line" id="L1127"></span>
<span class="line" id="L1128">    <span class="tok-comment">/// UNIX domain socket address</span></span>
<span class="line" id="L1129">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> un = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1130">        family: ADDRESS_FAMILY = AF.UNIX,</span>
<span class="line" id="L1131">        path: [<span class="tok-number">108</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1132">    };</span>
<span class="line" id="L1133">};</span>
<span class="line" id="L1134"></span>
<span class="line" id="L1135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSABUF = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1136">    len: ULONG,</span>
<span class="line" id="L1137">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1138">};</span>
<span class="line" id="L1139"></span>
<span class="line" id="L1140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr = WSAMSG;</span>
<span class="line" id="L1141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> msghdr_const = WSAMSG_const;</span>
<span class="line" id="L1142"></span>
<span class="line" id="L1143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAMSG_const = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1144">    name: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L1145">    namelen: INT,</span>
<span class="line" id="L1146">    lpBuffers: [*]<span class="tok-kw">const</span> WSABUF,</span>
<span class="line" id="L1147">    dwBufferCount: DWORD,</span>
<span class="line" id="L1148">    Control: WSABUF,</span>
<span class="line" id="L1149">    dwFlags: DWORD,</span>
<span class="line" id="L1150">};</span>
<span class="line" id="L1151"></span>
<span class="line" id="L1152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAMSG = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1153">    name: *sockaddr,</span>
<span class="line" id="L1154">    namelen: INT,</span>
<span class="line" id="L1155">    lpBuffers: [*]WSABUF,</span>
<span class="line" id="L1156">    dwBufferCount: DWORD,</span>
<span class="line" id="L1157">    Control: WSABUF,</span>
<span class="line" id="L1158">    dwFlags: DWORD,</span>
<span class="line" id="L1159">};</span>
<span class="line" id="L1160"></span>
<span class="line" id="L1161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WSAPOLLFD = pollfd;</span>
<span class="line" id="L1162"></span>
<span class="line" id="L1163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pollfd = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1164">    fd: SOCKET,</span>
<span class="line" id="L1165">    events: SHORT,</span>
<span class="line" id="L1166">    revents: SHORT,</span>
<span class="line" id="L1167">};</span>
<span class="line" id="L1168"></span>
<span class="line" id="L1169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRANSMIT_FILE_BUFFERS = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1170">    Head: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1171">    HeadLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1172">    Tail: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1173">    TailLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1174">};</span>
<span class="line" id="L1175"></span>
<span class="line" id="L1176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPFN_TRANSMITFILE = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1177">    hSocket: SOCKET,</span>
<span class="line" id="L1178">    hFile: HANDLE,</span>
<span class="line" id="L1179">    nNumberOfBytesToWrite: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1180">    nNumberOfBytesPerSend: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1181">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L1182">    lpTransmitBuffers: ?*TRANSMIT_FILE_BUFFERS,</span>
<span class="line" id="L1183">    dwReserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1184">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1185"></span>
<span class="line" id="L1186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPFN_ACCEPTEX = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1187">    sListenSocket: SOCKET,</span>
<span class="line" id="L1188">    sAcceptSocket: SOCKET,</span>
<span class="line" id="L1189">    lpOutputBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1190">    dwReceiveDataLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1191">    dwLocalAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1192">    dwRemoteAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1193">    lpdwBytesReceived: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1194">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L1195">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1196"></span>
<span class="line" id="L1197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPFN_GETACCEPTEXSOCKADDRS = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1198">    lpOutputBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L1199">    dwReceiveDataLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1200">    dwLocalAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1201">    dwRemoteAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1202">    LocalSockaddr: **sockaddr,</span>
<span class="line" id="L1203">    LocalSockaddrLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L1204">    RemoteSockaddr: **sockaddr,</span>
<span class="line" id="L1205">    RemoteSockaddrLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L1206">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPFN_WSASENDMSG = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1209">    s: SOCKET,</span>
<span class="line" id="L1210">    lpMsg: *<span class="tok-kw">const</span> std.x.os.Socket.Message,</span>
<span class="line" id="L1211">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1212">    lpNumberOfBytesSent: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1213">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L1214">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L1215">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1216"></span>
<span class="line" id="L1217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPFN_WSARECVMSG = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1218">    s: SOCKET,</span>
<span class="line" id="L1219">    lpMsg: *std.x.os.Socket.Message,</span>
<span class="line" id="L1220">    lpdwNumberOfBytesRecv: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1221">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L1222">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L1223">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1224"></span>
<span class="line" id="L1225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPSERVICE_CALLBACK_PROC = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1226">    lParam: LPARAM,</span>
<span class="line" id="L1227">    hAsyncTaskHandle: HANDLE,</span>
<span class="line" id="L1228">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L1229"></span>
<span class="line" id="L1230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERVICE_ASYNC_INFO = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1231">    lpServiceCallbackProc: LPSERVICE_CALLBACK_PROC,</span>
<span class="line" id="L1232">    lParam: LPARAM,</span>
<span class="line" id="L1233">    hAsyncTaskHandle: HANDLE,</span>
<span class="line" id="L1234">};</span>
<span class="line" id="L1235"></span>
<span class="line" id="L1236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LPLOOKUPSERVICE_COMPLETION_ROUTINE = <span class="tok-kw">fn</span> (</span>
<span class="line" id="L1237">    dwError: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1238">    dwBytes: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1239">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L1240">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L1241"></span>
<span class="line" id="L1242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fd_set = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1243">    fd_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1244">    fd_array: [<span class="tok-number">64</span>]SOCKET,</span>
<span class="line" id="L1245">};</span>
<span class="line" id="L1246"></span>
<span class="line" id="L1247"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hostent = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1248">    h_name: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1249">    h_aliases: **<span class="tok-type">i8</span>,</span>
<span class="line" id="L1250">    h_addrtype: <span class="tok-type">i16</span>,</span>
<span class="line" id="L1251">    h_length: <span class="tok-type">i16</span>,</span>
<span class="line" id="L1252">    h_addr_list: **<span class="tok-type">i8</span>,</span>
<span class="line" id="L1253">};</span>
<span class="line" id="L1254"></span>
<span class="line" id="L1255"><span class="tok-comment">// https://docs.microsoft.com/en-au/windows/win32/winsock/windows-sockets-error-codes-2</span>
</span>
<span class="line" id="L1256"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WinsockError = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L1257">    <span class="tok-comment">/// Specified event object handle is invalid.</span></span>
<span class="line" id="L1258">    <span class="tok-comment">/// An application attempts to use an event object, but the specified handle is not valid.</span></span>
<span class="line" id="L1259">    WSA_INVALID_HANDLE = <span class="tok-number">6</span>,</span>
<span class="line" id="L1260"></span>
<span class="line" id="L1261">    <span class="tok-comment">/// Insufficient memory available.</span></span>
<span class="line" id="L1262">    <span class="tok-comment">/// An application used a Windows Sockets function that directly maps to a Windows function.</span></span>
<span class="line" id="L1263">    <span class="tok-comment">/// The Windows function is indicating a lack of required memory resources.</span></span>
<span class="line" id="L1264">    WSA_NOT_ENOUGH_MEMORY = <span class="tok-number">8</span>,</span>
<span class="line" id="L1265"></span>
<span class="line" id="L1266">    <span class="tok-comment">/// One or more parameters are invalid.</span></span>
<span class="line" id="L1267">    <span class="tok-comment">/// An application used a Windows Sockets function which directly maps to a Windows function.</span></span>
<span class="line" id="L1268">    <span class="tok-comment">/// The Windows function is indicating a problem with one or more parameters.</span></span>
<span class="line" id="L1269">    WSA_INVALID_PARAMETER = <span class="tok-number">87</span>,</span>
<span class="line" id="L1270"></span>
<span class="line" id="L1271">    <span class="tok-comment">/// Overlapped operation aborted.</span></span>
<span class="line" id="L1272">    <span class="tok-comment">/// An overlapped operation was canceled due to the closure of the socket, or the execution of the SIO_FLUSH command in WSAIoctl.</span></span>
<span class="line" id="L1273">    WSA_OPERATION_ABORTED = <span class="tok-number">995</span>,</span>
<span class="line" id="L1274"></span>
<span class="line" id="L1275">    <span class="tok-comment">/// Overlapped I/O event object not in signaled state.</span></span>
<span class="line" id="L1276">    <span class="tok-comment">/// The application has tried to determine the status of an overlapped operation which is not yet completed.</span></span>
<span class="line" id="L1277">    <span class="tok-comment">/// Applications that use WSAGetOverlappedResult (with the fWait flag set to FALSE) in a polling mode to determine when an overlapped operation has completed, get this error code until the operation is complete.</span></span>
<span class="line" id="L1278">    WSA_IO_INCOMPLETE = <span class="tok-number">996</span>,</span>
<span class="line" id="L1279"></span>
<span class="line" id="L1280">    <span class="tok-comment">/// The application has initiated an overlapped operation that cannot be completed immediately.</span></span>
<span class="line" id="L1281">    <span class="tok-comment">/// A completion indication will be given later when the operation has been completed.</span></span>
<span class="line" id="L1282">    WSA_IO_PENDING = <span class="tok-number">997</span>,</span>
<span class="line" id="L1283"></span>
<span class="line" id="L1284">    <span class="tok-comment">/// Interrupted function call.</span></span>
<span class="line" id="L1285">    <span class="tok-comment">/// A blocking operation was interrupted by a call to WSACancelBlockingCall.</span></span>
<span class="line" id="L1286">    WSAEINTR = <span class="tok-number">10004</span>,</span>
<span class="line" id="L1287"></span>
<span class="line" id="L1288">    <span class="tok-comment">/// File handle is not valid.</span></span>
<span class="line" id="L1289">    <span class="tok-comment">/// The file handle supplied is not valid.</span></span>
<span class="line" id="L1290">    WSAEBADF = <span class="tok-number">10009</span>,</span>
<span class="line" id="L1291"></span>
<span class="line" id="L1292">    <span class="tok-comment">/// Permission denied.</span></span>
<span class="line" id="L1293">    <span class="tok-comment">/// An attempt was made to access a socket in a way forbidden by its access permissions.</span></span>
<span class="line" id="L1294">    <span class="tok-comment">/// An example is using a broadcast address for sendto without broadcast permission being set using setsockopt(SO.BROADCAST).</span></span>
<span class="line" id="L1295">    <span class="tok-comment">/// Another possible reason for the WSAEACCES error is that when the bind function is called (on Windows NT 4.0 with SP4 and later), another application, service, or kernel mode driver is bound to the same address with exclusive access.</span></span>
<span class="line" id="L1296">    <span class="tok-comment">/// Such exclusive access is a new feature of Windows NT 4.0 with SP4 and later, and is implemented by using the SO.EXCLUSIVEADDRUSE option.</span></span>
<span class="line" id="L1297">    WSAEACCES = <span class="tok-number">10013</span>,</span>
<span class="line" id="L1298"></span>
<span class="line" id="L1299">    <span class="tok-comment">/// Bad address.</span></span>
<span class="line" id="L1300">    <span class="tok-comment">/// The system detected an invalid pointer address in attempting to use a pointer argument of a call.</span></span>
<span class="line" id="L1301">    <span class="tok-comment">/// This error occurs if an application passes an invalid pointer value, or if the length of the buffer is too small.</span></span>
<span class="line" id="L1302">    <span class="tok-comment">/// For instance, if the length of an argument, which is a sockaddr structure, is smaller than the sizeof(sockaddr).</span></span>
<span class="line" id="L1303">    WSAEFAULT = <span class="tok-number">10014</span>,</span>
<span class="line" id="L1304"></span>
<span class="line" id="L1305">    <span class="tok-comment">/// Invalid argument.</span></span>
<span class="line" id="L1306">    <span class="tok-comment">/// Some invalid argument was supplied (for example, specifying an invalid level to the setsockopt function).</span></span>
<span class="line" id="L1307">    <span class="tok-comment">/// In some instances, it also refers to the current state of the socket—for instance, calling accept on a socket that is not listening.</span></span>
<span class="line" id="L1308">    WSAEINVAL = <span class="tok-number">10022</span>,</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">    <span class="tok-comment">/// Too many open files.</span></span>
<span class="line" id="L1311">    <span class="tok-comment">/// Too many open sockets. Each implementation may have a maximum number of socket handles available, either globally, per process, or per thread.</span></span>
<span class="line" id="L1312">    WSAEMFILE = <span class="tok-number">10024</span>,</span>
<span class="line" id="L1313"></span>
<span class="line" id="L1314">    <span class="tok-comment">/// Resource temporarily unavailable.</span></span>
<span class="line" id="L1315">    <span class="tok-comment">/// This error is returned from operations on nonblocking sockets that cannot be completed immediately, for example recv when no data is queued to be read from the socket.</span></span>
<span class="line" id="L1316">    <span class="tok-comment">/// It is a nonfatal error, and the operation should be retried later.</span></span>
<span class="line" id="L1317">    <span class="tok-comment">/// It is normal for WSAEWOULDBLOCK to be reported as the result from calling connect on a nonblocking SOCK.STREAM socket, since some time must elapse for the connection to be established.</span></span>
<span class="line" id="L1318">    WSAEWOULDBLOCK = <span class="tok-number">10035</span>,</span>
<span class="line" id="L1319"></span>
<span class="line" id="L1320">    <span class="tok-comment">/// Operation now in progress.</span></span>
<span class="line" id="L1321">    <span class="tok-comment">/// A blocking operation is currently executing.</span></span>
<span class="line" id="L1322">    <span class="tok-comment">/// Windows Sockets only allows a single blocking operation—per- task or thread—to be outstanding, and if any other function call is made (whether or not it references that or any other socket) the function fails with the WSAEINPROGRESS error.</span></span>
<span class="line" id="L1323">    WSAEINPROGRESS = <span class="tok-number">10036</span>,</span>
<span class="line" id="L1324"></span>
<span class="line" id="L1325">    <span class="tok-comment">/// Operation already in progress.</span></span>
<span class="line" id="L1326">    <span class="tok-comment">/// An operation was attempted on a nonblocking socket with an operation already in progress—that is, calling connect a second time on a nonblocking socket that is already connecting, or canceling an asynchronous request (WSAAsyncGetXbyY) that has already been canceled or completed.</span></span>
<span class="line" id="L1327">    WSAEALREADY = <span class="tok-number">10037</span>,</span>
<span class="line" id="L1328"></span>
<span class="line" id="L1329">    <span class="tok-comment">/// Socket operation on nonsocket.</span></span>
<span class="line" id="L1330">    <span class="tok-comment">/// An operation was attempted on something that is not a socket.</span></span>
<span class="line" id="L1331">    <span class="tok-comment">/// Either the socket handle parameter did not reference a valid socket, or for select, a member of an fd_set was not valid.</span></span>
<span class="line" id="L1332">    WSAENOTSOCK = <span class="tok-number">10038</span>,</span>
<span class="line" id="L1333"></span>
<span class="line" id="L1334">    <span class="tok-comment">/// Destination address required.</span></span>
<span class="line" id="L1335">    <span class="tok-comment">/// A required address was omitted from an operation on a socket.</span></span>
<span class="line" id="L1336">    <span class="tok-comment">/// For example, this error is returned if sendto is called with the remote address of ADDR_ANY.</span></span>
<span class="line" id="L1337">    WSAEDESTADDRREQ = <span class="tok-number">10039</span>,</span>
<span class="line" id="L1338"></span>
<span class="line" id="L1339">    <span class="tok-comment">/// Message too long.</span></span>
<span class="line" id="L1340">    <span class="tok-comment">/// A message sent on a datagram socket was larger than the internal message buffer or some other network limit, or the buffer used to receive a datagram was smaller than the datagram itself.</span></span>
<span class="line" id="L1341">    WSAEMSGSIZE = <span class="tok-number">10040</span>,</span>
<span class="line" id="L1342"></span>
<span class="line" id="L1343">    <span class="tok-comment">/// Protocol wrong type for socket.</span></span>
<span class="line" id="L1344">    <span class="tok-comment">/// A protocol was specified in the socket function call that does not support the semantics of the socket type requested.</span></span>
<span class="line" id="L1345">    <span class="tok-comment">/// For example, the ARPA Internet UDP protocol cannot be specified with a socket type of SOCK.STREAM.</span></span>
<span class="line" id="L1346">    WSAEPROTOTYPE = <span class="tok-number">10041</span>,</span>
<span class="line" id="L1347"></span>
<span class="line" id="L1348">    <span class="tok-comment">/// Bad protocol option.</span></span>
<span class="line" id="L1349">    <span class="tok-comment">/// An unknown, invalid or unsupported option or level was specified in a getsockopt or setsockopt call.</span></span>
<span class="line" id="L1350">    WSAENOPROTOOPT = <span class="tok-number">10042</span>,</span>
<span class="line" id="L1351"></span>
<span class="line" id="L1352">    <span class="tok-comment">/// Protocol not supported.</span></span>
<span class="line" id="L1353">    <span class="tok-comment">/// The requested protocol has not been configured into the system, or no implementation for it exists.</span></span>
<span class="line" id="L1354">    <span class="tok-comment">/// For example, a socket call requests a SOCK.DGRAM socket, but specifies a stream protocol.</span></span>
<span class="line" id="L1355">    WSAEPROTONOSUPPORT = <span class="tok-number">10043</span>,</span>
<span class="line" id="L1356"></span>
<span class="line" id="L1357">    <span class="tok-comment">/// Socket type not supported.</span></span>
<span class="line" id="L1358">    <span class="tok-comment">/// The support for the specified socket type does not exist in this address family.</span></span>
<span class="line" id="L1359">    <span class="tok-comment">/// For example, the optional type SOCK.RAW might be selected in a socket call, and the implementation does not support SOCK.RAW sockets at all.</span></span>
<span class="line" id="L1360">    WSAESOCKTNOSUPPORT = <span class="tok-number">10044</span>,</span>
<span class="line" id="L1361"></span>
<span class="line" id="L1362">    <span class="tok-comment">/// Operation not supported.</span></span>
<span class="line" id="L1363">    <span class="tok-comment">/// The attempted operation is not supported for the type of object referenced.</span></span>
<span class="line" id="L1364">    <span class="tok-comment">/// Usually this occurs when a socket descriptor to a socket that cannot support this operation is trying to accept a connection on a datagram socket.</span></span>
<span class="line" id="L1365">    WSAEOPNOTSUPP = <span class="tok-number">10045</span>,</span>
<span class="line" id="L1366"></span>
<span class="line" id="L1367">    <span class="tok-comment">/// Protocol family not supported.</span></span>
<span class="line" id="L1368">    <span class="tok-comment">/// The protocol family has not been configured into the system or no implementation for it exists.</span></span>
<span class="line" id="L1369">    <span class="tok-comment">/// This message has a slightly different meaning from WSAEAFNOSUPPORT.</span></span>
<span class="line" id="L1370">    <span class="tok-comment">/// However, it is interchangeable in most cases, and all Windows Sockets functions that return one of these messages also specify WSAEAFNOSUPPORT.</span></span>
<span class="line" id="L1371">    WSAEPFNOSUPPORT = <span class="tok-number">10046</span>,</span>
<span class="line" id="L1372"></span>
<span class="line" id="L1373">    <span class="tok-comment">/// Address family not supported by protocol family.</span></span>
<span class="line" id="L1374">    <span class="tok-comment">/// An address incompatible with the requested protocol was used.</span></span>
<span class="line" id="L1375">    <span class="tok-comment">/// All sockets are created with an associated address family (that is, AF.INET for Internet Protocols) and a generic protocol type (that is, SOCK.STREAM).</span></span>
<span class="line" id="L1376">    <span class="tok-comment">/// This error is returned if an incorrect protocol is explicitly requested in the socket call, or if an address of the wrong family is used for a socket, for example, in sendto.</span></span>
<span class="line" id="L1377">    WSAEAFNOSUPPORT = <span class="tok-number">10047</span>,</span>
<span class="line" id="L1378"></span>
<span class="line" id="L1379">    <span class="tok-comment">/// Address already in use.</span></span>
<span class="line" id="L1380">    <span class="tok-comment">/// Typically, only one usage of each socket address (protocol/IP address/port) is permitted.</span></span>
<span class="line" id="L1381">    <span class="tok-comment">/// This error occurs if an application attempts to bind a socket to an IP address/port that has already been used for an existing socket, or a socket that was not closed properly, or one that is still in the process of closing.</span></span>
<span class="line" id="L1382">    <span class="tok-comment">/// For server applications that need to bind multiple sockets to the same port number, consider using setsockopt (SO.REUSEADDR).</span></span>
<span class="line" id="L1383">    <span class="tok-comment">/// Client applications usually need not call bind at all—connect chooses an unused port automatically.</span></span>
<span class="line" id="L1384">    <span class="tok-comment">/// When bind is called with a wildcard address (involving ADDR_ANY), a WSAEADDRINUSE error could be delayed until the specific address is committed.</span></span>
<span class="line" id="L1385">    <span class="tok-comment">/// This could happen with a call to another function later, including connect, listen, WSAConnect, or WSAJoinLeaf.</span></span>
<span class="line" id="L1386">    WSAEADDRINUSE = <span class="tok-number">10048</span>,</span>
<span class="line" id="L1387"></span>
<span class="line" id="L1388">    <span class="tok-comment">/// Cannot assign requested address.</span></span>
<span class="line" id="L1389">    <span class="tok-comment">/// The requested address is not valid in its context.</span></span>
<span class="line" id="L1390">    <span class="tok-comment">/// This normally results from an attempt to bind to an address that is not valid for the local computer.</span></span>
<span class="line" id="L1391">    <span class="tok-comment">/// This can also result from connect, sendto, WSAConnect, WSAJoinLeaf, or WSASendTo when the remote address or port is not valid for a remote computer (for example, address or port 0).</span></span>
<span class="line" id="L1392">    WSAEADDRNOTAVAIL = <span class="tok-number">10049</span>,</span>
<span class="line" id="L1393"></span>
<span class="line" id="L1394">    <span class="tok-comment">/// Network is down.</span></span>
<span class="line" id="L1395">    <span class="tok-comment">/// A socket operation encountered a dead network.</span></span>
<span class="line" id="L1396">    <span class="tok-comment">/// This could indicate a serious failure of the network system (that is, the protocol stack that the Windows Sockets DLL runs over), the network interface, or the local network itself.</span></span>
<span class="line" id="L1397">    WSAENETDOWN = <span class="tok-number">10050</span>,</span>
<span class="line" id="L1398"></span>
<span class="line" id="L1399">    <span class="tok-comment">/// Network is unreachable.</span></span>
<span class="line" id="L1400">    <span class="tok-comment">/// A socket operation was attempted to an unreachable network.</span></span>
<span class="line" id="L1401">    <span class="tok-comment">/// This usually means the local software knows no route to reach the remote host.</span></span>
<span class="line" id="L1402">    WSAENETUNREACH = <span class="tok-number">10051</span>,</span>
<span class="line" id="L1403"></span>
<span class="line" id="L1404">    <span class="tok-comment">/// Network dropped connection on reset.</span></span>
<span class="line" id="L1405">    <span class="tok-comment">/// The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.</span></span>
<span class="line" id="L1406">    <span class="tok-comment">/// It can also be returned by setsockopt if an attempt is made to set SO.KEEPALIVE on a connection that has already failed.</span></span>
<span class="line" id="L1407">    WSAENETRESET = <span class="tok-number">10052</span>,</span>
<span class="line" id="L1408"></span>
<span class="line" id="L1409">    <span class="tok-comment">/// Software caused connection abort.</span></span>
<span class="line" id="L1410">    <span class="tok-comment">/// An established connection was aborted by the software in your host computer, possibly due to a data transmission time-out or protocol error.</span></span>
<span class="line" id="L1411">    WSAECONNABORTED = <span class="tok-number">10053</span>,</span>
<span class="line" id="L1412"></span>
<span class="line" id="L1413">    <span class="tok-comment">/// Connection reset by peer.</span></span>
<span class="line" id="L1414">    <span class="tok-comment">/// An existing connection was forcibly closed by the remote host.</span></span>
<span class="line" id="L1415">    <span class="tok-comment">/// This normally results if the peer application on the remote host is suddenly stopped, the host is rebooted, the host or remote network interface is disabled, or the remote host uses a hard close (see setsockopt for more information on the SO.LINGER option on the remote socket).</span></span>
<span class="line" id="L1416">    <span class="tok-comment">/// This error may also result if a connection was broken due to keep-alive activity detecting a failure while one or more operations are in progress.</span></span>
<span class="line" id="L1417">    <span class="tok-comment">/// Operations that were in progress fail with WSAENETRESET. Subsequent operations fail with WSAECONNRESET.</span></span>
<span class="line" id="L1418">    WSAECONNRESET = <span class="tok-number">10054</span>,</span>
<span class="line" id="L1419"></span>
<span class="line" id="L1420">    <span class="tok-comment">/// No buffer space available.</span></span>
<span class="line" id="L1421">    <span class="tok-comment">/// An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.</span></span>
<span class="line" id="L1422">    WSAENOBUFS = <span class="tok-number">10055</span>,</span>
<span class="line" id="L1423"></span>
<span class="line" id="L1424">    <span class="tok-comment">/// Socket is already connected.</span></span>
<span class="line" id="L1425">    <span class="tok-comment">/// A connect request was made on an already-connected socket.</span></span>
<span class="line" id="L1426">    <span class="tok-comment">/// Some implementations also return this error if sendto is called on a connected SOCK.DGRAM socket (for SOCK.STREAM sockets, the to parameter in sendto is ignored) although other implementations treat this as a legal occurrence.</span></span>
<span class="line" id="L1427">    WSAEISCONN = <span class="tok-number">10056</span>,</span>
<span class="line" id="L1428"></span>
<span class="line" id="L1429">    <span class="tok-comment">/// Socket is not connected.</span></span>
<span class="line" id="L1430">    <span class="tok-comment">/// A request to send or receive data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto) no address was supplied.</span></span>
<span class="line" id="L1431">    <span class="tok-comment">/// Any other type of operation might also return this error—for example, setsockopt setting SO.KEEPALIVE if the connection has been reset.</span></span>
<span class="line" id="L1432">    WSAENOTCONN = <span class="tok-number">10057</span>,</span>
<span class="line" id="L1433"></span>
<span class="line" id="L1434">    <span class="tok-comment">/// Cannot send after socket shutdown.</span></span>
<span class="line" id="L1435">    <span class="tok-comment">/// A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call.</span></span>
<span class="line" id="L1436">    <span class="tok-comment">/// By calling shutdown a partial close of a socket is requested, which is a signal that sending or receiving, or both have been discontinued.</span></span>
<span class="line" id="L1437">    WSAESHUTDOWN = <span class="tok-number">10058</span>,</span>
<span class="line" id="L1438"></span>
<span class="line" id="L1439">    <span class="tok-comment">/// Too many references.</span></span>
<span class="line" id="L1440">    <span class="tok-comment">/// Too many references to some kernel object.</span></span>
<span class="line" id="L1441">    WSAETOOMANYREFS = <span class="tok-number">10059</span>,</span>
<span class="line" id="L1442"></span>
<span class="line" id="L1443">    <span class="tok-comment">/// Connection timed out.</span></span>
<span class="line" id="L1444">    <span class="tok-comment">/// A connection attempt failed because the connected party did not properly respond after a period of time, or the established connection failed because the connected host has failed to respond.</span></span>
<span class="line" id="L1445">    WSAETIMEDOUT = <span class="tok-number">10060</span>,</span>
<span class="line" id="L1446"></span>
<span class="line" id="L1447">    <span class="tok-comment">/// Connection refused.</span></span>
<span class="line" id="L1448">    <span class="tok-comment">/// No connection could be made because the target computer actively refused it.</span></span>
<span class="line" id="L1449">    <span class="tok-comment">/// This usually results from trying to connect to a service that is inactive on the foreign host—that is, one with no server application running.</span></span>
<span class="line" id="L1450">    WSAECONNREFUSED = <span class="tok-number">10061</span>,</span>
<span class="line" id="L1451"></span>
<span class="line" id="L1452">    <span class="tok-comment">/// Cannot translate name.</span></span>
<span class="line" id="L1453">    <span class="tok-comment">/// Cannot translate a name.</span></span>
<span class="line" id="L1454">    WSAELOOP = <span class="tok-number">10062</span>,</span>
<span class="line" id="L1455"></span>
<span class="line" id="L1456">    <span class="tok-comment">/// Name too long.</span></span>
<span class="line" id="L1457">    <span class="tok-comment">/// A name component or a name was too long.</span></span>
<span class="line" id="L1458">    WSAENAMETOOLONG = <span class="tok-number">10063</span>,</span>
<span class="line" id="L1459"></span>
<span class="line" id="L1460">    <span class="tok-comment">/// Host is down.</span></span>
<span class="line" id="L1461">    <span class="tok-comment">/// A socket operation failed because the destination host is down. A socket operation encountered a dead host.</span></span>
<span class="line" id="L1462">    <span class="tok-comment">/// Networking activity on the local host has not been initiated.</span></span>
<span class="line" id="L1463">    <span class="tok-comment">/// These conditions are more likely to be indicated by the error WSAETIMEDOUT.</span></span>
<span class="line" id="L1464">    WSAEHOSTDOWN = <span class="tok-number">10064</span>,</span>
<span class="line" id="L1465"></span>
<span class="line" id="L1466">    <span class="tok-comment">/// No route to host.</span></span>
<span class="line" id="L1467">    <span class="tok-comment">/// A socket operation was attempted to an unreachable host. See WSAENETUNREACH.</span></span>
<span class="line" id="L1468">    WSAEHOSTUNREACH = <span class="tok-number">10065</span>,</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">    <span class="tok-comment">/// Directory not empty.</span></span>
<span class="line" id="L1471">    <span class="tok-comment">/// Cannot remove a directory that is not empty.</span></span>
<span class="line" id="L1472">    WSAENOTEMPTY = <span class="tok-number">10066</span>,</span>
<span class="line" id="L1473"></span>
<span class="line" id="L1474">    <span class="tok-comment">/// Too many processes.</span></span>
<span class="line" id="L1475">    <span class="tok-comment">/// A Windows Sockets implementation may have a limit on the number of applications that can use it simultaneously.</span></span>
<span class="line" id="L1476">    <span class="tok-comment">/// WSAStartup may fail with this error if the limit has been reached.</span></span>
<span class="line" id="L1477">    WSAEPROCLIM = <span class="tok-number">10067</span>,</span>
<span class="line" id="L1478"></span>
<span class="line" id="L1479">    <span class="tok-comment">/// User quota exceeded.</span></span>
<span class="line" id="L1480">    <span class="tok-comment">/// Ran out of user quota.</span></span>
<span class="line" id="L1481">    WSAEUSERS = <span class="tok-number">10068</span>,</span>
<span class="line" id="L1482"></span>
<span class="line" id="L1483">    <span class="tok-comment">/// Disk quota exceeded.</span></span>
<span class="line" id="L1484">    <span class="tok-comment">/// Ran out of disk quota.</span></span>
<span class="line" id="L1485">    WSAEDQUOT = <span class="tok-number">10069</span>,</span>
<span class="line" id="L1486"></span>
<span class="line" id="L1487">    <span class="tok-comment">/// Stale file handle reference.</span></span>
<span class="line" id="L1488">    <span class="tok-comment">/// The file handle reference is no longer available.</span></span>
<span class="line" id="L1489">    WSAESTALE = <span class="tok-number">10070</span>,</span>
<span class="line" id="L1490"></span>
<span class="line" id="L1491">    <span class="tok-comment">/// Item is remote.</span></span>
<span class="line" id="L1492">    <span class="tok-comment">/// The item is not available locally.</span></span>
<span class="line" id="L1493">    WSAEREMOTE = <span class="tok-number">10071</span>,</span>
<span class="line" id="L1494"></span>
<span class="line" id="L1495">    <span class="tok-comment">/// Network subsystem is unavailable.</span></span>
<span class="line" id="L1496">    <span class="tok-comment">/// This error is returned by WSAStartup if the Windows Sockets implementation cannot function at this time because the underlying system it uses to provide network services is currently unavailable.</span></span>
<span class="line" id="L1497">    <span class="tok-comment">/// Users should check:</span></span>
<span class="line" id="L1498">    <span class="tok-comment">///   - That the appropriate Windows Sockets DLL file is in the current path.</span></span>
<span class="line" id="L1499">    <span class="tok-comment">///   - That they are not trying to use more than one Windows Sockets implementation simultaneously.</span></span>
<span class="line" id="L1500">    <span class="tok-comment">///   - If there is more than one Winsock DLL on your system, be sure the first one in the path is appropriate for the network subsystem currently loaded.</span></span>
<span class="line" id="L1501">    <span class="tok-comment">///   - The Windows Sockets implementation documentation to be sure all necessary components are currently installed and configured correctly.</span></span>
<span class="line" id="L1502">    WSASYSNOTREADY = <span class="tok-number">10091</span>,</span>
<span class="line" id="L1503"></span>
<span class="line" id="L1504">    <span class="tok-comment">/// Winsock.dll version out of range.</span></span>
<span class="line" id="L1505">    <span class="tok-comment">/// The current Windows Sockets implementation does not support the Windows Sockets specification version requested by the application.</span></span>
<span class="line" id="L1506">    <span class="tok-comment">/// Check that no old Windows Sockets DLL files are being accessed.</span></span>
<span class="line" id="L1507">    WSAVERNOTSUPPORTED = <span class="tok-number">10092</span>,</span>
<span class="line" id="L1508"></span>
<span class="line" id="L1509">    <span class="tok-comment">/// Successful WSAStartup not yet performed.</span></span>
<span class="line" id="L1510">    <span class="tok-comment">/// Either the application has not called WSAStartup or WSAStartup failed.</span></span>
<span class="line" id="L1511">    <span class="tok-comment">/// The application may be accessing a socket that the current active task does not own (that is, trying to share a socket between tasks), or WSACleanup has been called too many times.</span></span>
<span class="line" id="L1512">    WSANOTINITIALISED = <span class="tok-number">10093</span>,</span>
<span class="line" id="L1513"></span>
<span class="line" id="L1514">    <span class="tok-comment">/// Graceful shutdown in progress.</span></span>
<span class="line" id="L1515">    <span class="tok-comment">/// Returned by WSARecv and WSARecvFrom to indicate that the remote party has initiated a graceful shutdown sequence.</span></span>
<span class="line" id="L1516">    WSAEDISCON = <span class="tok-number">10101</span>,</span>
<span class="line" id="L1517"></span>
<span class="line" id="L1518">    <span class="tok-comment">/// No more results.</span></span>
<span class="line" id="L1519">    <span class="tok-comment">/// No more results can be returned by the WSALookupServiceNext function.</span></span>
<span class="line" id="L1520">    WSAENOMORE = <span class="tok-number">10102</span>,</span>
<span class="line" id="L1521"></span>
<span class="line" id="L1522">    <span class="tok-comment">/// Call has been canceled.</span></span>
<span class="line" id="L1523">    <span class="tok-comment">/// A call to the WSALookupServiceEnd function was made while this call was still processing. The call has been canceled.</span></span>
<span class="line" id="L1524">    WSAECANCELLED = <span class="tok-number">10103</span>,</span>
<span class="line" id="L1525"></span>
<span class="line" id="L1526">    <span class="tok-comment">/// Procedure call table is invalid.</span></span>
<span class="line" id="L1527">    <span class="tok-comment">/// The service provider procedure call table is invalid.</span></span>
<span class="line" id="L1528">    <span class="tok-comment">/// A service provider returned a bogus procedure table to Ws2_32.dll.</span></span>
<span class="line" id="L1529">    <span class="tok-comment">/// This is usually caused by one or more of the function pointers being NULL.</span></span>
<span class="line" id="L1530">    WSAEINVALIDPROCTABLE = <span class="tok-number">10104</span>,</span>
<span class="line" id="L1531"></span>
<span class="line" id="L1532">    <span class="tok-comment">/// Service provider is invalid.</span></span>
<span class="line" id="L1533">    <span class="tok-comment">/// The requested service provider is invalid.</span></span>
<span class="line" id="L1534">    <span class="tok-comment">/// This error is returned by the WSCGetProviderInfo and WSCGetProviderInfo32 functions if the protocol entry specified could not be found.</span></span>
<span class="line" id="L1535">    <span class="tok-comment">/// This error is also returned if the service provider returned a version number other than 2.0.</span></span>
<span class="line" id="L1536">    WSAEINVALIDPROVIDER = <span class="tok-number">10105</span>,</span>
<span class="line" id="L1537"></span>
<span class="line" id="L1538">    <span class="tok-comment">/// Service provider failed to initialize.</span></span>
<span class="line" id="L1539">    <span class="tok-comment">/// The requested service provider could not be loaded or initialized.</span></span>
<span class="line" id="L1540">    <span class="tok-comment">/// This error is returned if either a service provider's DLL could not be loaded (LoadLibrary failed) or the provider's WSPStartup or NSPStartup function failed.</span></span>
<span class="line" id="L1541">    WSAEPROVIDERFAILEDINIT = <span class="tok-number">10106</span>,</span>
<span class="line" id="L1542"></span>
<span class="line" id="L1543">    <span class="tok-comment">/// System call failure.</span></span>
<span class="line" id="L1544">    <span class="tok-comment">/// A system call that should never fail has failed.</span></span>
<span class="line" id="L1545">    <span class="tok-comment">/// This is a generic error code, returned under various conditions.</span></span>
<span class="line" id="L1546">    <span class="tok-comment">/// Returned when a system call that should never fail does fail.</span></span>
<span class="line" id="L1547">    <span class="tok-comment">/// For example, if a call to WaitForMultipleEvents fails or one of the registry functions fails trying to manipulate the protocol/namespace catalogs.</span></span>
<span class="line" id="L1548">    <span class="tok-comment">/// Returned when a provider does not return SUCCESS and does not provide an extended error code.</span></span>
<span class="line" id="L1549">    <span class="tok-comment">/// Can indicate a service provider implementation error.</span></span>
<span class="line" id="L1550">    WSASYSCALLFAILURE = <span class="tok-number">10107</span>,</span>
<span class="line" id="L1551"></span>
<span class="line" id="L1552">    <span class="tok-comment">/// Service not found.</span></span>
<span class="line" id="L1553">    <span class="tok-comment">/// No such service is known. The service cannot be found in the specified name space.</span></span>
<span class="line" id="L1554">    WSASERVICE_NOT_FOUND = <span class="tok-number">10108</span>,</span>
<span class="line" id="L1555"></span>
<span class="line" id="L1556">    <span class="tok-comment">/// Class type not found.</span></span>
<span class="line" id="L1557">    <span class="tok-comment">/// The specified class was not found.</span></span>
<span class="line" id="L1558">    WSATYPE_NOT_FOUND = <span class="tok-number">10109</span>,</span>
<span class="line" id="L1559"></span>
<span class="line" id="L1560">    <span class="tok-comment">/// No more results.</span></span>
<span class="line" id="L1561">    <span class="tok-comment">/// No more results can be returned by the WSALookupServiceNext function.</span></span>
<span class="line" id="L1562">    WSA_E_NO_MORE = <span class="tok-number">10110</span>,</span>
<span class="line" id="L1563"></span>
<span class="line" id="L1564">    <span class="tok-comment">/// Call was canceled.</span></span>
<span class="line" id="L1565">    <span class="tok-comment">/// A call to the WSALookupServiceEnd function was made while this call was still processing. The call has been canceled.</span></span>
<span class="line" id="L1566">    WSA_E_CANCELLED = <span class="tok-number">10111</span>,</span>
<span class="line" id="L1567"></span>
<span class="line" id="L1568">    <span class="tok-comment">/// Database query was refused.</span></span>
<span class="line" id="L1569">    <span class="tok-comment">/// A database query failed because it was actively refused.</span></span>
<span class="line" id="L1570">    WSAEREFUSED = <span class="tok-number">10112</span>,</span>
<span class="line" id="L1571"></span>
<span class="line" id="L1572">    <span class="tok-comment">/// Host not found.</span></span>
<span class="line" id="L1573">    <span class="tok-comment">/// No such host is known. The name is not an official host name or alias, or it cannot be found in the database(s) being queried.</span></span>
<span class="line" id="L1574">    <span class="tok-comment">/// This error may also be returned for protocol and service queries, and means that the specified name could not be found in the relevant database.</span></span>
<span class="line" id="L1575">    WSAHOST_NOT_FOUND = <span class="tok-number">11001</span>,</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577">    <span class="tok-comment">/// Nonauthoritative host not found.</span></span>
<span class="line" id="L1578">    <span class="tok-comment">/// This is usually a temporary error during host name resolution and means that the local server did not receive a response from an authoritative server. A retry at some time later may be successful.</span></span>
<span class="line" id="L1579">    WSATRY_AGAIN = <span class="tok-number">11002</span>,</span>
<span class="line" id="L1580"></span>
<span class="line" id="L1581">    <span class="tok-comment">/// This is a nonrecoverable error.</span></span>
<span class="line" id="L1582">    <span class="tok-comment">/// This indicates that some sort of nonrecoverable error occurred during a database lookup.</span></span>
<span class="line" id="L1583">    <span class="tok-comment">/// This may be because the database files (for example, BSD-compatible HOSTS, SERVICES, or PROTOCOLS files) could not be found, or a DNS request was returned by the server with a severe error.</span></span>
<span class="line" id="L1584">    WSANO_RECOVERY = <span class="tok-number">11003</span>,</span>
<span class="line" id="L1585"></span>
<span class="line" id="L1586">    <span class="tok-comment">/// Valid name, no data record of requested type.</span></span>
<span class="line" id="L1587">    <span class="tok-comment">/// The requested name is valid and was found in the database, but it does not have the correct associated data being resolved for.</span></span>
<span class="line" id="L1588">    <span class="tok-comment">/// The usual example for this is a host name-to-address translation attempt (using gethostbyname or WSAAsyncGetHostByName) which uses the DNS (Domain Name Server).</span></span>
<span class="line" id="L1589">    <span class="tok-comment">/// An MX record is returned but no A record—indicating the host itself exists, but is not directly reachable.</span></span>
<span class="line" id="L1590">    WSANO_DATA = <span class="tok-number">11004</span>,</span>
<span class="line" id="L1591"></span>
<span class="line" id="L1592">    <span class="tok-comment">/// QoS receivers.</span></span>
<span class="line" id="L1593">    <span class="tok-comment">/// At least one QoS reserve has arrived.</span></span>
<span class="line" id="L1594">    WSA_QOS_RECEIVERS = <span class="tok-number">11005</span>,</span>
<span class="line" id="L1595"></span>
<span class="line" id="L1596">    <span class="tok-comment">/// QoS senders.</span></span>
<span class="line" id="L1597">    <span class="tok-comment">/// At least one QoS send path has arrived.</span></span>
<span class="line" id="L1598">    WSA_QOS_SENDERS = <span class="tok-number">11006</span>,</span>
<span class="line" id="L1599"></span>
<span class="line" id="L1600">    <span class="tok-comment">/// No QoS senders.</span></span>
<span class="line" id="L1601">    <span class="tok-comment">/// There are no QoS senders.</span></span>
<span class="line" id="L1602">    WSA_QOS_NO_SENDERS = <span class="tok-number">11007</span>,</span>
<span class="line" id="L1603"></span>
<span class="line" id="L1604">    <span class="tok-comment">/// QoS no receivers.</span></span>
<span class="line" id="L1605">    <span class="tok-comment">/// There are no QoS receivers.</span></span>
<span class="line" id="L1606">    WSA_QOS_NO_RECEIVERS = <span class="tok-number">11008</span>,</span>
<span class="line" id="L1607"></span>
<span class="line" id="L1608">    <span class="tok-comment">/// QoS request confirmed.</span></span>
<span class="line" id="L1609">    <span class="tok-comment">/// The QoS reserve request has been confirmed.</span></span>
<span class="line" id="L1610">    WSA_QOS_REQUEST_CONFIRMED = <span class="tok-number">11009</span>,</span>
<span class="line" id="L1611"></span>
<span class="line" id="L1612">    <span class="tok-comment">/// QoS admission error.</span></span>
<span class="line" id="L1613">    <span class="tok-comment">/// A QoS error occurred due to lack of resources.</span></span>
<span class="line" id="L1614">    WSA_QOS_ADMISSION_FAILURE = <span class="tok-number">11010</span>,</span>
<span class="line" id="L1615"></span>
<span class="line" id="L1616">    <span class="tok-comment">/// QoS policy failure.</span></span>
<span class="line" id="L1617">    <span class="tok-comment">/// The QoS request was rejected because the policy system couldn't allocate the requested resource within the existing policy.</span></span>
<span class="line" id="L1618">    WSA_QOS_POLICY_FAILURE = <span class="tok-number">11011</span>,</span>
<span class="line" id="L1619"></span>
<span class="line" id="L1620">    <span class="tok-comment">/// QoS bad style.</span></span>
<span class="line" id="L1621">    <span class="tok-comment">/// An unknown or conflicting QoS style was encountered.</span></span>
<span class="line" id="L1622">    WSA_QOS_BAD_STYLE = <span class="tok-number">11012</span>,</span>
<span class="line" id="L1623"></span>
<span class="line" id="L1624">    <span class="tok-comment">/// QoS bad object.</span></span>
<span class="line" id="L1625">    <span class="tok-comment">/// A problem was encountered with some part of the filterspec or the provider-specific buffer in general.</span></span>
<span class="line" id="L1626">    WSA_QOS_BAD_OBJECT = <span class="tok-number">11013</span>,</span>
<span class="line" id="L1627"></span>
<span class="line" id="L1628">    <span class="tok-comment">/// QoS traffic control error.</span></span>
<span class="line" id="L1629">    <span class="tok-comment">/// An error with the underlying traffic control (TC) API as the generic QoS request was converted for local enforcement by the TC API.</span></span>
<span class="line" id="L1630">    <span class="tok-comment">/// This could be due to an out of memory error or to an internal QoS provider error.</span></span>
<span class="line" id="L1631">    WSA_QOS_TRAFFIC_CTRL_ERROR = <span class="tok-number">11014</span>,</span>
<span class="line" id="L1632"></span>
<span class="line" id="L1633">    <span class="tok-comment">/// QoS generic error.</span></span>
<span class="line" id="L1634">    <span class="tok-comment">/// A general QoS error.</span></span>
<span class="line" id="L1635">    WSA_QOS_GENERIC_ERROR = <span class="tok-number">11015</span>,</span>
<span class="line" id="L1636"></span>
<span class="line" id="L1637">    <span class="tok-comment">/// QoS service type error.</span></span>
<span class="line" id="L1638">    <span class="tok-comment">/// An invalid or unrecognized service type was found in the QoS flowspec.</span></span>
<span class="line" id="L1639">    WSA_QOS_ESERVICETYPE = <span class="tok-number">11016</span>,</span>
<span class="line" id="L1640"></span>
<span class="line" id="L1641">    <span class="tok-comment">/// QoS flowspec error.</span></span>
<span class="line" id="L1642">    <span class="tok-comment">/// An invalid or inconsistent flowspec was found in the QOS structure.</span></span>
<span class="line" id="L1643">    WSA_QOS_EFLOWSPEC = <span class="tok-number">11017</span>,</span>
<span class="line" id="L1644"></span>
<span class="line" id="L1645">    <span class="tok-comment">/// Invalid QoS provider buffer.</span></span>
<span class="line" id="L1646">    <span class="tok-comment">/// An invalid QoS provider-specific buffer.</span></span>
<span class="line" id="L1647">    WSA_QOS_EPROVSPECBUF = <span class="tok-number">11018</span>,</span>
<span class="line" id="L1648"></span>
<span class="line" id="L1649">    <span class="tok-comment">/// Invalid QoS filter style.</span></span>
<span class="line" id="L1650">    <span class="tok-comment">/// An invalid QoS filter style was used.</span></span>
<span class="line" id="L1651">    WSA_QOS_EFILTERSTYLE = <span class="tok-number">11019</span>,</span>
<span class="line" id="L1652"></span>
<span class="line" id="L1653">    <span class="tok-comment">/// Invalid QoS filter type.</span></span>
<span class="line" id="L1654">    <span class="tok-comment">/// An invalid QoS filter type was used.</span></span>
<span class="line" id="L1655">    WSA_QOS_EFILTERTYPE = <span class="tok-number">11020</span>,</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657">    <span class="tok-comment">/// Incorrect QoS filter count.</span></span>
<span class="line" id="L1658">    <span class="tok-comment">/// An incorrect number of QoS FILTERSPECs were specified in the FLOWDESCRIPTOR.</span></span>
<span class="line" id="L1659">    WSA_QOS_EFILTERCOUNT = <span class="tok-number">11021</span>,</span>
<span class="line" id="L1660"></span>
<span class="line" id="L1661">    <span class="tok-comment">/// Invalid QoS object length.</span></span>
<span class="line" id="L1662">    <span class="tok-comment">/// An object with an invalid ObjectLength field was specified in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1663">    WSA_QOS_EOBJLENGTH = <span class="tok-number">11022</span>,</span>
<span class="line" id="L1664"></span>
<span class="line" id="L1665">    <span class="tok-comment">/// Incorrect QoS flow count.</span></span>
<span class="line" id="L1666">    <span class="tok-comment">/// An incorrect number of flow descriptors was specified in the QoS structure.</span></span>
<span class="line" id="L1667">    WSA_QOS_EFLOWCOUNT = <span class="tok-number">11023</span>,</span>
<span class="line" id="L1668"></span>
<span class="line" id="L1669">    <span class="tok-comment">/// Unrecognized QoS object.</span></span>
<span class="line" id="L1670">    <span class="tok-comment">/// An unrecognized object was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1671">    WSA_QOS_EUNKOWNPSOBJ = <span class="tok-number">11024</span>,</span>
<span class="line" id="L1672"></span>
<span class="line" id="L1673">    <span class="tok-comment">/// Invalid QoS policy object.</span></span>
<span class="line" id="L1674">    <span class="tok-comment">/// An invalid policy object was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1675">    WSA_QOS_EPOLICYOBJ = <span class="tok-number">11025</span>,</span>
<span class="line" id="L1676"></span>
<span class="line" id="L1677">    <span class="tok-comment">/// Invalid QoS flow descriptor.</span></span>
<span class="line" id="L1678">    <span class="tok-comment">/// An invalid QoS flow descriptor was found in the flow descriptor list.</span></span>
<span class="line" id="L1679">    WSA_QOS_EFLOWDESC = <span class="tok-number">11026</span>,</span>
<span class="line" id="L1680"></span>
<span class="line" id="L1681">    <span class="tok-comment">/// Invalid QoS provider-specific flowspec.</span></span>
<span class="line" id="L1682">    <span class="tok-comment">/// An invalid or inconsistent flowspec was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1683">    WSA_QOS_EPSFLOWSPEC = <span class="tok-number">11027</span>,</span>
<span class="line" id="L1684"></span>
<span class="line" id="L1685">    <span class="tok-comment">/// Invalid QoS provider-specific filterspec.</span></span>
<span class="line" id="L1686">    <span class="tok-comment">/// An invalid FILTERSPEC was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1687">    WSA_QOS_EPSFILTERSPEC = <span class="tok-number">11028</span>,</span>
<span class="line" id="L1688"></span>
<span class="line" id="L1689">    <span class="tok-comment">/// Invalid QoS shape discard mode object.</span></span>
<span class="line" id="L1690">    <span class="tok-comment">/// An invalid shape discard mode object was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1691">    WSA_QOS_ESDMODEOBJ = <span class="tok-number">11029</span>,</span>
<span class="line" id="L1692"></span>
<span class="line" id="L1693">    <span class="tok-comment">/// Invalid QoS shaping rate object.</span></span>
<span class="line" id="L1694">    <span class="tok-comment">/// An invalid shaping rate object was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1695">    WSA_QOS_ESHAPERATEOBJ = <span class="tok-number">11030</span>,</span>
<span class="line" id="L1696"></span>
<span class="line" id="L1697">    <span class="tok-comment">/// Reserved policy QoS element type.</span></span>
<span class="line" id="L1698">    <span class="tok-comment">/// A reserved policy element was found in the QoS provider-specific buffer.</span></span>
<span class="line" id="L1699">    WSA_QOS_RESERVED_PETYPE = <span class="tok-number">11031</span>,</span>
<span class="line" id="L1700"></span>
<span class="line" id="L1701">    _,</span>
<span class="line" id="L1702">};</span>
<span class="line" id="L1703"></span>
<span class="line" id="L1704"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">accept</span>(</span>
<span class="line" id="L1705">    s: SOCKET,</span>
<span class="line" id="L1706">    addr: ?*sockaddr,</span>
<span class="line" id="L1707">    addrlen: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L1708">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L1709"></span>
<span class="line" id="L1710"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">bind</span>(</span>
<span class="line" id="L1711">    s: SOCKET,</span>
<span class="line" id="L1712">    name: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L1713">    namelen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1714">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1715"></span>
<span class="line" id="L1716"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">closesocket</span>(</span>
<span class="line" id="L1717">    s: SOCKET,</span>
<span class="line" id="L1718">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1719"></span>
<span class="line" id="L1720"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">connect</span>(</span>
<span class="line" id="L1721">    s: SOCKET,</span>
<span class="line" id="L1722">    name: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L1723">    namelen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1724">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1725"></span>
<span class="line" id="L1726"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ioctlsocket</span>(</span>
<span class="line" id="L1727">    s: SOCKET,</span>
<span class="line" id="L1728">    cmd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1729">    argp: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1730">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1731"></span>
<span class="line" id="L1732"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getpeername</span>(</span>
<span class="line" id="L1733">    s: SOCKET,</span>
<span class="line" id="L1734">    name: *sockaddr,</span>
<span class="line" id="L1735">    namelen: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L1736">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1737"></span>
<span class="line" id="L1738"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockname</span>(</span>
<span class="line" id="L1739">    s: SOCKET,</span>
<span class="line" id="L1740">    name: *sockaddr,</span>
<span class="line" id="L1741">    namelen: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L1742">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1743"></span>
<span class="line" id="L1744"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getsockopt</span>(</span>
<span class="line" id="L1745">    s: SOCKET,</span>
<span class="line" id="L1746">    level: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1747">    optname: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1748">    optval: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1749">    optlen: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L1750">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">htonl</span>(</span>
<span class="line" id="L1753">    hostlong: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1754">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L1755"></span>
<span class="line" id="L1756"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">htons</span>(</span>
<span class="line" id="L1757">    hostshort: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1758">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u16</span>;</span>
<span class="line" id="L1759"></span>
<span class="line" id="L1760"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">inet_addr</span>(</span>
<span class="line" id="L1761">    cp: ?[*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1762">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L1763"></span>
<span class="line" id="L1764"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">listen</span>(</span>
<span class="line" id="L1765">    s: SOCKET,</span>
<span class="line" id="L1766">    backlog: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1767">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1768"></span>
<span class="line" id="L1769"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ntohl</span>(</span>
<span class="line" id="L1770">    netlong: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1771">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L1772"></span>
<span class="line" id="L1773"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">ntohs</span>(</span>
<span class="line" id="L1774">    netshort: <span class="tok-type">u16</span>,</span>
<span class="line" id="L1775">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u16</span>;</span>
<span class="line" id="L1776"></span>
<span class="line" id="L1777"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">recv</span>(</span>
<span class="line" id="L1778">    s: SOCKET,</span>
<span class="line" id="L1779">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1780">    len: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1781">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1782">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1783"></span>
<span class="line" id="L1784"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">recvfrom</span>(</span>
<span class="line" id="L1785">    s: SOCKET,</span>
<span class="line" id="L1786">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1787">    len: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1788">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1789">    from: ?*sockaddr,</span>
<span class="line" id="L1790">    fromlen: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L1791">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1792"></span>
<span class="line" id="L1793"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">select</span>(</span>
<span class="line" id="L1794">    nfds: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1795">    readfds: ?*fd_set,</span>
<span class="line" id="L1796">    writefds: ?*fd_set,</span>
<span class="line" id="L1797">    exceptfds: ?*fd_set,</span>
<span class="line" id="L1798">    timeout: ?*<span class="tok-kw">const</span> timeval,</span>
<span class="line" id="L1799">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1800"></span>
<span class="line" id="L1801"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">send</span>(</span>
<span class="line" id="L1802">    s: SOCKET,</span>
<span class="line" id="L1803">    buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1804">    len: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1805">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1806">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1807"></span>
<span class="line" id="L1808"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sendto</span>(</span>
<span class="line" id="L1809">    s: SOCKET,</span>
<span class="line" id="L1810">    buf: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1811">    len: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1812">    flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1813">    to: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L1814">    tolen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1815">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1816"></span>
<span class="line" id="L1817"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">setsockopt</span>(</span>
<span class="line" id="L1818">    s: SOCKET,</span>
<span class="line" id="L1819">    level: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1820">    optname: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1821">    optval: ?[*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1822">    optlen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1823">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1824"></span>
<span class="line" id="L1825"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">shutdown</span>(</span>
<span class="line" id="L1826">    s: SOCKET,</span>
<span class="line" id="L1827">    how: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1828">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1829"></span>
<span class="line" id="L1830"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">socket</span>(</span>
<span class="line" id="L1831">    af: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1832">    @&quot;type&quot;: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1833">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1834">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L1835"></span>
<span class="line" id="L1836"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAStartup</span>(</span>
<span class="line" id="L1837">    wVersionRequired: WORD,</span>
<span class="line" id="L1838">    lpWSAData: *WSADATA,</span>
<span class="line" id="L1839">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1840"></span>
<span class="line" id="L1841"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACleanup</span>() <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1842"></span>
<span class="line" id="L1843"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASetLastError</span>(iError: <span class="tok-type">i32</span>) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L1844"></span>
<span class="line" id="L1845"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAGetLastError</span>() <span class="tok-kw">callconv</span>(WINAPI) WinsockError;</span>
<span class="line" id="L1846"></span>
<span class="line" id="L1847"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAIsBlocking</span>() <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1848"></span>
<span class="line" id="L1849"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAUnhookBlockingHook</span>() <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1850"></span>
<span class="line" id="L1851"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASetBlockingHook</span>(lpBlockFunc: FARPROC) <span class="tok-kw">callconv</span>(WINAPI) FARPROC;</span>
<span class="line" id="L1852"></span>
<span class="line" id="L1853"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACancelBlockingCall</span>() <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1854"></span>
<span class="line" id="L1855"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAsyncGetServByName</span>(</span>
<span class="line" id="L1856">    hWnd: HWND,</span>
<span class="line" id="L1857">    wMsg: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1858">    name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1859">    proto: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1860">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1861">    buflen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1862">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L1863"></span>
<span class="line" id="L1864"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAsyncGetServByPort</span>(</span>
<span class="line" id="L1865">    hWnd: HWND,</span>
<span class="line" id="L1866">    wMsg: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1867">    port: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1868">    proto: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1869">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1870">    buflen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1871">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L1872"></span>
<span class="line" id="L1873"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAsyncGetProtoByName</span>(</span>
<span class="line" id="L1874">    hWnd: HWND,</span>
<span class="line" id="L1875">    wMsg: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1876">    name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1877">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1878">    buflen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1879">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L1880"></span>
<span class="line" id="L1881"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAsyncGetProtoByNumber</span>(</span>
<span class="line" id="L1882">    hWnd: HWND,</span>
<span class="line" id="L1883">    wMsg: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1884">    number: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1885">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L1886">    buflen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1887">) <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L1888"></span>
<span class="line" id="L1889"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACancelAsyncRequest</span>(hAsyncTaskHandle: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAsyncSelect</span>(</span>
<span class="line" id="L1892">    s: SOCKET,</span>
<span class="line" id="L1893">    hWnd: HWND,</span>
<span class="line" id="L1894">    wMsg: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1895">    lEvent: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1896">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1897"></span>
<span class="line" id="L1898"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAccept</span>(</span>
<span class="line" id="L1899">    s: SOCKET,</span>
<span class="line" id="L1900">    addr: ?*sockaddr,</span>
<span class="line" id="L1901">    addrlen: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L1902">    lpfnCondition: ?LPCONDITIONPROC,</span>
<span class="line" id="L1903">    dwCallbackData: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1904">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L1905"></span>
<span class="line" id="L1906"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACloseEvent</span>(hEvent: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1907"></span>
<span class="line" id="L1908"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAConnect</span>(</span>
<span class="line" id="L1909">    s: SOCKET,</span>
<span class="line" id="L1910">    name: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L1911">    namelen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1912">    lpCallerData: ?*WSABUF,</span>
<span class="line" id="L1913">    lpCalleeData: ?*WSABUF,</span>
<span class="line" id="L1914">    lpSQOS: ?*QOS,</span>
<span class="line" id="L1915">    lpGQOS: ?*QOS,</span>
<span class="line" id="L1916">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1917"></span>
<span class="line" id="L1918"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAConnectByNameW</span>(</span>
<span class="line" id="L1919">    s: SOCKET,</span>
<span class="line" id="L1920">    nodename: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1921">    servicename: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1922">    LocalAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1923">    LocalAddress: ?*sockaddr,</span>
<span class="line" id="L1924">    RemoteAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1925">    RemoteAddress: ?*sockaddr,</span>
<span class="line" id="L1926">    timeout: ?*<span class="tok-kw">const</span> timeval,</span>
<span class="line" id="L1927">    Reserved: *OVERLAPPED,</span>
<span class="line" id="L1928">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1929"></span>
<span class="line" id="L1930"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAConnectByNameA</span>(</span>
<span class="line" id="L1931">    s: SOCKET,</span>
<span class="line" id="L1932">    nodename: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1933">    servicename: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1934">    LocalAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1935">    LocalAddress: ?*sockaddr,</span>
<span class="line" id="L1936">    RemoteAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1937">    RemoteAddress: ?*sockaddr,</span>
<span class="line" id="L1938">    timeout: ?*<span class="tok-kw">const</span> timeval,</span>
<span class="line" id="L1939">    Reserved: *OVERLAPPED,</span>
<span class="line" id="L1940">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1941"></span>
<span class="line" id="L1942"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAConnectByList</span>(</span>
<span class="line" id="L1943">    s: SOCKET,</span>
<span class="line" id="L1944">    SocketAddress: *SOCKET_ADDRESS_LIST,</span>
<span class="line" id="L1945">    LocalAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1946">    LocalAddress: ?*sockaddr,</span>
<span class="line" id="L1947">    RemoteAddressLength: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L1948">    RemoteAddress: ?*sockaddr,</span>
<span class="line" id="L1949">    timeout: ?*<span class="tok-kw">const</span> timeval,</span>
<span class="line" id="L1950">    Reserved: *OVERLAPPED,</span>
<span class="line" id="L1951">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1952"></span>
<span class="line" id="L1953"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSACreateEvent</span>() <span class="tok-kw">callconv</span>(WINAPI) HANDLE;</span>
<span class="line" id="L1954"></span>
<span class="line" id="L1955"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSADuplicateSocketA</span>(</span>
<span class="line" id="L1956">    s: SOCKET,</span>
<span class="line" id="L1957">    dwProcessId: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1958">    lpProtocolInfo: *WSAPROTOCOL_INFOA,</span>
<span class="line" id="L1959">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1960"></span>
<span class="line" id="L1961"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSADuplicateSocketW</span>(</span>
<span class="line" id="L1962">    s: SOCKET,</span>
<span class="line" id="L1963">    dwProcessId: <span class="tok-type">u32</span>,</span>
<span class="line" id="L1964">    lpProtocolInfo: *WSAPROTOCOL_INFOW,</span>
<span class="line" id="L1965">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1966"></span>
<span class="line" id="L1967"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAEnumNetworkEvents</span>(</span>
<span class="line" id="L1968">    s: SOCKET,</span>
<span class="line" id="L1969">    hEventObject: HANDLE,</span>
<span class="line" id="L1970">    lpNetworkEvents: *WSANETWORKEVENTS,</span>
<span class="line" id="L1971">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1972"></span>
<span class="line" id="L1973"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAEnumProtocolsA</span>(</span>
<span class="line" id="L1974">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L1975">    lpProtocolBuffer: ?*WSAPROTOCOL_INFOA,</span>
<span class="line" id="L1976">    lpdwBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1977">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1978"></span>
<span class="line" id="L1979"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAEnumProtocolsW</span>(</span>
<span class="line" id="L1980">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L1981">    lpProtocolBuffer: ?*WSAPROTOCOL_INFOW,</span>
<span class="line" id="L1982">    lpdwBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1983">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1984"></span>
<span class="line" id="L1985"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAEventSelect</span>(</span>
<span class="line" id="L1986">    s: SOCKET,</span>
<span class="line" id="L1987">    hEventObject: HANDLE,</span>
<span class="line" id="L1988">    lNetworkEvents: <span class="tok-type">i32</span>,</span>
<span class="line" id="L1989">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L1990"></span>
<span class="line" id="L1991"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAGetOverlappedResult</span>(</span>
<span class="line" id="L1992">    s: SOCKET,</span>
<span class="line" id="L1993">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L1994">    lpcbTransfer: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1995">    fWait: BOOL,</span>
<span class="line" id="L1996">    lpdwFlags: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L1997">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L1998"></span>
<span class="line" id="L1999"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAGetQOSByName</span>(</span>
<span class="line" id="L2000">    s: SOCKET,</span>
<span class="line" id="L2001">    lpQOSName: *WSABUF,</span>
<span class="line" id="L2002">    lpQOS: *QOS,</span>
<span class="line" id="L2003">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L2004"></span>
<span class="line" id="L2005"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAHtonl</span>(</span>
<span class="line" id="L2006">    s: SOCKET,</span>
<span class="line" id="L2007">    hostlong: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2008">    lpnetlong: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2009">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2010"></span>
<span class="line" id="L2011"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAHtons</span>(</span>
<span class="line" id="L2012">    s: SOCKET,</span>
<span class="line" id="L2013">    hostshort: <span class="tok-type">u16</span>,</span>
<span class="line" id="L2014">    lpnetshort: *<span class="tok-type">u16</span>,</span>
<span class="line" id="L2015">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2016"></span>
<span class="line" id="L2017"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAIoctl</span>(</span>
<span class="line" id="L2018">    s: SOCKET,</span>
<span class="line" id="L2019">    dwIoControlCode: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2020">    lpvInBuffer: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2021">    cbInBuffer: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2022">    lpvOutbuffer: ?*<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2023">    cbOutbuffer: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2024">    lpcbBytesReturned: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2025">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2026">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2027">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2028"></span>
<span class="line" id="L2029"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAJoinLeaf</span>(</span>
<span class="line" id="L2030">    s: SOCKET,</span>
<span class="line" id="L2031">    name: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L2032">    namelen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2033">    lpCallerdata: ?*WSABUF,</span>
<span class="line" id="L2034">    lpCalleeData: ?*WSABUF,</span>
<span class="line" id="L2035">    lpSQOS: ?*QOS,</span>
<span class="line" id="L2036">    lpGQOS: ?*QOS,</span>
<span class="line" id="L2037">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2038">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L2039"></span>
<span class="line" id="L2040"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSANtohl</span>(</span>
<span class="line" id="L2041">    s: SOCKET,</span>
<span class="line" id="L2042">    netlong: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2043">    lphostlong: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2044">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L2045"></span>
<span class="line" id="L2046"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSANtohs</span>(</span>
<span class="line" id="L2047">    s: SOCKET,</span>
<span class="line" id="L2048">    netshort: <span class="tok-type">u16</span>,</span>
<span class="line" id="L2049">    lphostshort: *<span class="tok-type">u16</span>,</span>
<span class="line" id="L2050">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2051"></span>
<span class="line" id="L2052"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSARecv</span>(</span>
<span class="line" id="L2053">    s: SOCKET,</span>
<span class="line" id="L2054">    lpBuffers: [*]WSABUF,</span>
<span class="line" id="L2055">    dwBufferCouynt: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2056">    lpNumberOfBytesRecv: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2057">    lpFlags: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2058">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2059">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2060">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2061"></span>
<span class="line" id="L2062"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSARecvDisconnect</span>(</span>
<span class="line" id="L2063">    s: SOCKET,</span>
<span class="line" id="L2064">    lpInboundDisconnectData: ?*WSABUF,</span>
<span class="line" id="L2065">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2066"></span>
<span class="line" id="L2067"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSARecvFrom</span>(</span>
<span class="line" id="L2068">    s: SOCKET,</span>
<span class="line" id="L2069">    lpBuffers: [*]WSABUF,</span>
<span class="line" id="L2070">    dwBuffercount: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2071">    lpNumberOfBytesRecvd: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2072">    lpFlags: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2073">    lpFrom: ?*sockaddr,</span>
<span class="line" id="L2074">    lpFromlen: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L2075">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2076">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2077">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2078"></span>
<span class="line" id="L2079"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAResetEvent</span>(hEvent: HANDLE) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2080"></span>
<span class="line" id="L2081"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASend</span>(</span>
<span class="line" id="L2082">    s: SOCKET,</span>
<span class="line" id="L2083">    lpBuffers: [*]WSABUF,</span>
<span class="line" id="L2084">    dwBufferCount: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2085">    lpNumberOfBytesSent: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2086">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2087">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2088">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2089">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2090"></span>
<span class="line" id="L2091"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASendMsg</span>(</span>
<span class="line" id="L2092">    s: SOCKET,</span>
<span class="line" id="L2093">    lpMsg: *<span class="tok-kw">const</span> std.x.os.Socket.Message,</span>
<span class="line" id="L2094">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2095">    lpNumberOfBytesSent: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2096">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2097">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2098">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2099"></span>
<span class="line" id="L2100"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSARecvMsg</span>(</span>
<span class="line" id="L2101">    s: SOCKET,</span>
<span class="line" id="L2102">    lpMsg: *std.x.os.Socket.Message,</span>
<span class="line" id="L2103">    lpdwNumberOfBytesRecv: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2104">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2105">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2106">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2107"></span>
<span class="line" id="L2108"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASendDisconnect</span>(</span>
<span class="line" id="L2109">    s: SOCKET,</span>
<span class="line" id="L2110">    lpOutboundDisconnectData: ?*WSABUF,</span>
<span class="line" id="L2111">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2112"></span>
<span class="line" id="L2113"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASendTo</span>(</span>
<span class="line" id="L2114">    s: SOCKET,</span>
<span class="line" id="L2115">    lpBuffers: [*]WSABUF,</span>
<span class="line" id="L2116">    dwBufferCount: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2117">    lpNumberOfBytesSent: ?*<span class="tok-type">u32</span>,</span>
<span class="line" id="L2118">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2119">    lpTo: ?*<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L2120">    iToLen: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2121">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2122">    lpCompletionRounte: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2123">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2124"></span>
<span class="line" id="L2125"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASetEvent</span>(</span>
<span class="line" id="L2126">    hEvent: HANDLE,</span>
<span class="line" id="L2127">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L2128"></span>
<span class="line" id="L2129"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASocketA</span>(</span>
<span class="line" id="L2130">    af: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2131">    @&quot;type&quot;: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2132">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2133">    lpProtocolInfo: ?*WSAPROTOCOL_INFOA,</span>
<span class="line" id="L2134">    g: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2135">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2136">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L2137"></span>
<span class="line" id="L2138"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSASocketW</span>(</span>
<span class="line" id="L2139">    af: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2140">    @&quot;type&quot;: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2141">    protocol: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2142">    lpProtocolInfo: ?*WSAPROTOCOL_INFOW,</span>
<span class="line" id="L2143">    g: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2144">    dwFlags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2145">) <span class="tok-kw">callconv</span>(WINAPI) SOCKET;</span>
<span class="line" id="L2146"></span>
<span class="line" id="L2147"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAWaitForMultipleEvents</span>(</span>
<span class="line" id="L2148">    cEvents: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2149">    lphEvents: [*]<span class="tok-kw">const</span> HANDLE,</span>
<span class="line" id="L2150">    fWaitAll: BOOL,</span>
<span class="line" id="L2151">    dwTimeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2152">    fAlertable: BOOL,</span>
<span class="line" id="L2153">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L2154"></span>
<span class="line" id="L2155"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAddressToStringA</span>(</span>
<span class="line" id="L2156">    lpsaAddress: *sockaddr,</span>
<span class="line" id="L2157">    dwAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2158">    lpProtocolInfo: ?*WSAPROTOCOL_INFOA,</span>
<span class="line" id="L2159">    lpszAddressString: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2160">    lpdwAddressStringLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2161">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2162"></span>
<span class="line" id="L2163"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAAddressToStringW</span>(</span>
<span class="line" id="L2164">    lpsaAddress: *sockaddr,</span>
<span class="line" id="L2165">    dwAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2166">    lpProtocolInfo: ?*WSAPROTOCOL_INFOW,</span>
<span class="line" id="L2167">    lpszAddressString: [*]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2168">    lpdwAddressStringLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2169">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2170"></span>
<span class="line" id="L2171"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAStringToAddressA</span>(</span>
<span class="line" id="L2172">    AddressString: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2173">    AddressFamily: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2174">    lpProtocolInfo: ?*WSAPROTOCOL_INFOA,</span>
<span class="line" id="L2175">    lpAddress: *sockaddr,</span>
<span class="line" id="L2176">    lpAddressLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L2177">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2178"></span>
<span class="line" id="L2179"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAStringToAddressW</span>(</span>
<span class="line" id="L2180">    AddressString: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L2181">    AddressFamily: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2182">    lpProtocolInfo: ?*WSAPROTOCOL_INFOW,</span>
<span class="line" id="L2183">    lpAddrses: *sockaddr,</span>
<span class="line" id="L2184">    lpAddressLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L2185">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2186"></span>
<span class="line" id="L2187"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAProviderConfigChange</span>(</span>
<span class="line" id="L2188">    lpNotificationHandle: *HANDLE,</span>
<span class="line" id="L2189">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2190">    lpCompletionRoutine: ?LPWSAOVERLAPPED_COMPLETION_ROUTINE,</span>
<span class="line" id="L2191">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2192"></span>
<span class="line" id="L2193"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAPoll</span>(</span>
<span class="line" id="L2194">    fdArray: [*]WSAPOLLFD,</span>
<span class="line" id="L2195">    fds: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2196">    timeout: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2197">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2198"></span>
<span class="line" id="L2199"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSARecvEx</span>(</span>
<span class="line" id="L2200">    s: SOCKET,</span>
<span class="line" id="L2201">    buf: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2202">    len: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2203">    flags: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L2204">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2205"></span>
<span class="line" id="L2206"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">TransmitFile</span>(</span>
<span class="line" id="L2207">    hSocket: SOCKET,</span>
<span class="line" id="L2208">    hFile: HANDLE,</span>
<span class="line" id="L2209">    nNumberOfBytesToWrite: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2210">    nNumberOfBytesPerSend: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2211">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2212">    lpTransmitBuffers: ?*TRANSMIT_FILE_BUFFERS,</span>
<span class="line" id="L2213">    dwReserved: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2214">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L2215"></span>
<span class="line" id="L2216"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">AcceptEx</span>(</span>
<span class="line" id="L2217">    sListenSocket: SOCKET,</span>
<span class="line" id="L2218">    sAcceptSocket: SOCKET,</span>
<span class="line" id="L2219">    lpOutputBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2220">    dwReceiveDataLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2221">    dwLocalAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2222">    dwRemoteAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2223">    lpdwBytesReceived: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2224">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L2225">) <span class="tok-kw">callconv</span>(WINAPI) BOOL;</span>
<span class="line" id="L2226"></span>
<span class="line" id="L2227"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAcceptExSockaddrs</span>(</span>
<span class="line" id="L2228">    lpOutputBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2229">    dwReceiveDataLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2230">    dwLocalAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2231">    dwRemoteAddressLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2232">    LocalSockaddr: **sockaddr,</span>
<span class="line" id="L2233">    LocalSockaddrLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L2234">    RemoteSockaddr: **sockaddr,</span>
<span class="line" id="L2235">    RemoteSockaddrLength: *<span class="tok-type">i32</span>,</span>
<span class="line" id="L2236">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L2237"></span>
<span class="line" id="L2238"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">WSAProviderCompleteAsyncCall</span>(</span>
<span class="line" id="L2239">    hAsyncCall: HANDLE,</span>
<span class="line" id="L2240">    iRetCode: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2241">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2242"></span>
<span class="line" id="L2243"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumProtocolsA</span>(</span>
<span class="line" id="L2244">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L2245">    lpProtocolBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2246">    lpdwBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2247">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2248"></span>
<span class="line" id="L2249"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumProtocolsW</span>(</span>
<span class="line" id="L2250">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L2251">    lpProtocolBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2252">    lpdwBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2253">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2254"></span>
<span class="line" id="L2255"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAddressByNameA</span>(</span>
<span class="line" id="L2256">    dwNameSpace: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2257">    lpServiceType: *GUID,</span>
<span class="line" id="L2258">    lpServiceName: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2259">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L2260">    dwResolution: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2261">    lpServiceAsyncInfo: ?*SERVICE_ASYNC_INFO,</span>
<span class="line" id="L2262">    lpCsaddrBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2263">    lpAliasBuffer: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2264">    lpdwAliasBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2265">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2266"></span>
<span class="line" id="L2267"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAddressByNameW</span>(</span>
<span class="line" id="L2268">    dwNameSpace: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2269">    lpServiceType: *GUID,</span>
<span class="line" id="L2270">    lpServiceName: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2271">    lpiProtocols: ?*<span class="tok-type">i32</span>,</span>
<span class="line" id="L2272">    dwResolution: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2273">    lpServiceAsyncInfo: ?*SERVICE_ASYNC_INFO,</span>
<span class="line" id="L2274">    lpCsaddrBuffer: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L2275">    ldwBufferLEngth: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2276">    lpAliasBuffer: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2277">    lpdwAliasBufferLength: *<span class="tok-type">u32</span>,</span>
<span class="line" id="L2278">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2279"></span>
<span class="line" id="L2280"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetTypeByNameA</span>(</span>
<span class="line" id="L2281">    lpServiceName: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2282">    lpServiceType: *GUID,</span>
<span class="line" id="L2283">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2284"></span>
<span class="line" id="L2285"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetTypeByNameW</span>(</span>
<span class="line" id="L2286">    lpServiceName: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2287">    lpServiceType: *GUID,</span>
<span class="line" id="L2288">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2289"></span>
<span class="line" id="L2290"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetNameByTypeA</span>(</span>
<span class="line" id="L2291">    lpServiceType: *GUID,</span>
<span class="line" id="L2292">    lpServiceName: [*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2293">    dwNameLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2294">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2295"></span>
<span class="line" id="L2296"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;mswsock&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetNameByTypeW</span>(</span>
<span class="line" id="L2297">    lpServiceType: *GUID,</span>
<span class="line" id="L2298">    lpServiceName: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>,</span>
<span class="line" id="L2299">    dwNameLength: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2300">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2301"></span>
<span class="line" id="L2302"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getaddrinfo</span>(</span>
<span class="line" id="L2303">    pNodeName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2304">    pServiceName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2305">    pHints: ?*<span class="tok-kw">const</span> addrinfoa,</span>
<span class="line" id="L2306">    ppResult: **addrinfoa,</span>
<span class="line" id="L2307">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2308"></span>
<span class="line" id="L2309"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAddrInfoExA</span>(</span>
<span class="line" id="L2310">    pName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2311">    pServiceName: ?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2312">    dwNameSapce: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2313">    lpNspId: ?*GUID,</span>
<span class="line" id="L2314">    hints: ?*<span class="tok-kw">const</span> addrinfoexA,</span>
<span class="line" id="L2315">    ppResult: **addrinfoexA,</span>
<span class="line" id="L2316">    timeout: ?*timeval,</span>
<span class="line" id="L2317">    lpOverlapped: ?*OVERLAPPED,</span>
<span class="line" id="L2318">    lpCompletionRoutine: ?LPLOOKUPSERVICE_COMPLETION_ROUTINE,</span>
<span class="line" id="L2319">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2320"></span>
<span class="line" id="L2321"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAddrInfoExCancel</span>(</span>
<span class="line" id="L2322">    lpHandle: *HANDLE,</span>
<span class="line" id="L2323">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2324"></span>
<span class="line" id="L2325"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">GetAddrInfoExOverlappedResult</span>(</span>
<span class="line" id="L2326">    lpOverlapped: *OVERLAPPED,</span>
<span class="line" id="L2327">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2328"></span>
<span class="line" id="L2329"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">freeaddrinfo</span>(</span>
<span class="line" id="L2330">    pAddrInfo: ?*addrinfoa,</span>
<span class="line" id="L2331">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L2332"></span>
<span class="line" id="L2333"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">FreeAddrInfoEx</span>(</span>
<span class="line" id="L2334">    pAddrInfoEx: ?*addrinfoexA,</span>
<span class="line" id="L2335">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">void</span>;</span>
<span class="line" id="L2336"></span>
<span class="line" id="L2337"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;ws2_32&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">getnameinfo</span>(</span>
<span class="line" id="L2338">    pSockaddr: *<span class="tok-kw">const</span> sockaddr,</span>
<span class="line" id="L2339">    SockaddrLength: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2340">    pNodeBuffer: ?[*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2341">    NodeBufferSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2342">    pServiceBuffer: ?[*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L2343">    ServiceBufferName: <span class="tok-type">u32</span>,</span>
<span class="line" id="L2344">    Flags: <span class="tok-type">i32</span>,</span>
<span class="line" id="L2345">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">i32</span>;</span>
<span class="line" id="L2346"></span>
<span class="line" id="L2347"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;IPHLPAPI&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">if_nametoindex</span>(</span>
<span class="line" id="L2348">    InterfaceName: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2349">) <span class="tok-kw">callconv</span>(WINAPI) <span class="tok-type">u32</span>;</span>
<span class="line" id="L2350"></span>
</code></pre></body>
</html>