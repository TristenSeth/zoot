<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/win32error.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">/// Codes are from https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/18d8fbe8-a967-4f1c-ae50-99ca8e491d2d</span></span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Win32Error = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L3">    <span class="tok-comment">/// The operation completed successfully.</span></span>
<span class="line" id="L4">    SUCCESS = <span class="tok-number">0</span>,</span>
<span class="line" id="L5">    <span class="tok-comment">/// Incorrect function.</span></span>
<span class="line" id="L6">    INVALID_FUNCTION = <span class="tok-number">1</span>,</span>
<span class="line" id="L7">    <span class="tok-comment">/// The system cannot find the file specified.</span></span>
<span class="line" id="L8">    FILE_NOT_FOUND = <span class="tok-number">2</span>,</span>
<span class="line" id="L9">    <span class="tok-comment">/// The system cannot find the path specified.</span></span>
<span class="line" id="L10">    PATH_NOT_FOUND = <span class="tok-number">3</span>,</span>
<span class="line" id="L11">    <span class="tok-comment">/// The system cannot open the file.</span></span>
<span class="line" id="L12">    TOO_MANY_OPEN_FILES = <span class="tok-number">4</span>,</span>
<span class="line" id="L13">    <span class="tok-comment">/// Access is denied.</span></span>
<span class="line" id="L14">    ACCESS_DENIED = <span class="tok-number">5</span>,</span>
<span class="line" id="L15">    <span class="tok-comment">/// The handle is invalid.</span></span>
<span class="line" id="L16">    INVALID_HANDLE = <span class="tok-number">6</span>,</span>
<span class="line" id="L17">    <span class="tok-comment">/// The storage control blocks were destroyed.</span></span>
<span class="line" id="L18">    ARENA_TRASHED = <span class="tok-number">7</span>,</span>
<span class="line" id="L19">    <span class="tok-comment">/// Not enough storage is available to process this command.</span></span>
<span class="line" id="L20">    NOT_ENOUGH_MEMORY = <span class="tok-number">8</span>,</span>
<span class="line" id="L21">    <span class="tok-comment">/// The storage control block address is invalid.</span></span>
<span class="line" id="L22">    INVALID_BLOCK = <span class="tok-number">9</span>,</span>
<span class="line" id="L23">    <span class="tok-comment">/// The environment is incorrect.</span></span>
<span class="line" id="L24">    BAD_ENVIRONMENT = <span class="tok-number">10</span>,</span>
<span class="line" id="L25">    <span class="tok-comment">/// An attempt was made to load a program with an incorrect format.</span></span>
<span class="line" id="L26">    BAD_FORMAT = <span class="tok-number">11</span>,</span>
<span class="line" id="L27">    <span class="tok-comment">/// The access code is invalid.</span></span>
<span class="line" id="L28">    INVALID_ACCESS = <span class="tok-number">12</span>,</span>
<span class="line" id="L29">    <span class="tok-comment">/// The data is invalid.</span></span>
<span class="line" id="L30">    INVALID_DATA = <span class="tok-number">13</span>,</span>
<span class="line" id="L31">    <span class="tok-comment">/// Not enough storage is available to complete this operation.</span></span>
<span class="line" id="L32">    OUTOFMEMORY = <span class="tok-number">14</span>,</span>
<span class="line" id="L33">    <span class="tok-comment">/// The system cannot find the drive specified.</span></span>
<span class="line" id="L34">    INVALID_DRIVE = <span class="tok-number">15</span>,</span>
<span class="line" id="L35">    <span class="tok-comment">/// The directory cannot be removed.</span></span>
<span class="line" id="L36">    CURRENT_DIRECTORY = <span class="tok-number">16</span>,</span>
<span class="line" id="L37">    <span class="tok-comment">/// The system cannot move the file to a different disk drive.</span></span>
<span class="line" id="L38">    NOT_SAME_DEVICE = <span class="tok-number">17</span>,</span>
<span class="line" id="L39">    <span class="tok-comment">/// There are no more files.</span></span>
<span class="line" id="L40">    NO_MORE_FILES = <span class="tok-number">18</span>,</span>
<span class="line" id="L41">    <span class="tok-comment">/// The media is write protected.</span></span>
<span class="line" id="L42">    WRITE_PROTECT = <span class="tok-number">19</span>,</span>
<span class="line" id="L43">    <span class="tok-comment">/// The system cannot find the device specified.</span></span>
<span class="line" id="L44">    BAD_UNIT = <span class="tok-number">20</span>,</span>
<span class="line" id="L45">    <span class="tok-comment">/// The device is not ready.</span></span>
<span class="line" id="L46">    NOT_READY = <span class="tok-number">21</span>,</span>
<span class="line" id="L47">    <span class="tok-comment">/// The device does not recognize the command.</span></span>
<span class="line" id="L48">    BAD_COMMAND = <span class="tok-number">22</span>,</span>
<span class="line" id="L49">    <span class="tok-comment">/// Data error (cyclic redundancy check).</span></span>
<span class="line" id="L50">    CRC = <span class="tok-number">23</span>,</span>
<span class="line" id="L51">    <span class="tok-comment">/// The program issued a command but the command length is incorrect.</span></span>
<span class="line" id="L52">    BAD_LENGTH = <span class="tok-number">24</span>,</span>
<span class="line" id="L53">    <span class="tok-comment">/// The drive cannot locate a specific area or track on the disk.</span></span>
<span class="line" id="L54">    SEEK = <span class="tok-number">25</span>,</span>
<span class="line" id="L55">    <span class="tok-comment">/// The specified disk or diskette cannot be accessed.</span></span>
<span class="line" id="L56">    NOT_DOS_DISK = <span class="tok-number">26</span>,</span>
<span class="line" id="L57">    <span class="tok-comment">/// The drive cannot find the sector requested.</span></span>
<span class="line" id="L58">    SECTOR_NOT_FOUND = <span class="tok-number">27</span>,</span>
<span class="line" id="L59">    <span class="tok-comment">/// The printer is out of paper.</span></span>
<span class="line" id="L60">    OUT_OF_PAPER = <span class="tok-number">28</span>,</span>
<span class="line" id="L61">    <span class="tok-comment">/// The system cannot write to the specified device.</span></span>
<span class="line" id="L62">    WRITE_FAULT = <span class="tok-number">29</span>,</span>
<span class="line" id="L63">    <span class="tok-comment">/// The system cannot read from the specified device.</span></span>
<span class="line" id="L64">    READ_FAULT = <span class="tok-number">30</span>,</span>
<span class="line" id="L65">    <span class="tok-comment">/// A device attached to the system is not functioning.</span></span>
<span class="line" id="L66">    GEN_FAILURE = <span class="tok-number">31</span>,</span>
<span class="line" id="L67">    <span class="tok-comment">/// The process cannot access the file because it is being used by another process.</span></span>
<span class="line" id="L68">    SHARING_VIOLATION = <span class="tok-number">32</span>,</span>
<span class="line" id="L69">    <span class="tok-comment">/// The process cannot access the file because another process has locked a portion of the file.</span></span>
<span class="line" id="L70">    LOCK_VIOLATION = <span class="tok-number">33</span>,</span>
<span class="line" id="L71">    <span class="tok-comment">/// The wrong diskette is in the drive.</span></span>
<span class="line" id="L72">    <span class="tok-comment">/// Insert %2 (Volume Serial Number: %3) into drive %1.</span></span>
<span class="line" id="L73">    WRONG_DISK = <span class="tok-number">34</span>,</span>
<span class="line" id="L74">    <span class="tok-comment">/// Too many files opened for sharing.</span></span>
<span class="line" id="L75">    SHARING_BUFFER_EXCEEDED = <span class="tok-number">36</span>,</span>
<span class="line" id="L76">    <span class="tok-comment">/// Reached the end of the file.</span></span>
<span class="line" id="L77">    HANDLE_EOF = <span class="tok-number">38</span>,</span>
<span class="line" id="L78">    <span class="tok-comment">/// The disk is full.</span></span>
<span class="line" id="L79">    HANDLE_DISK_FULL = <span class="tok-number">39</span>,</span>
<span class="line" id="L80">    <span class="tok-comment">/// The request is not supported.</span></span>
<span class="line" id="L81">    NOT_SUPPORTED = <span class="tok-number">50</span>,</span>
<span class="line" id="L82">    <span class="tok-comment">/// Windows cannot find the network path.</span></span>
<span class="line" id="L83">    <span class="tok-comment">/// Verify that the network path is correct and the destination computer is not busy or turned off.</span></span>
<span class="line" id="L84">    <span class="tok-comment">/// If Windows still cannot find the network path, contact your network administrator.</span></span>
<span class="line" id="L85">    REM_NOT_LIST = <span class="tok-number">51</span>,</span>
<span class="line" id="L86">    <span class="tok-comment">/// You were not connected because a duplicate name exists on the network.</span></span>
<span class="line" id="L87">    <span class="tok-comment">/// If joining a domain, go to System in Control Panel to change the computer name and try again.</span></span>
<span class="line" id="L88">    <span class="tok-comment">/// If joining a workgroup, choose another workgroup name.</span></span>
<span class="line" id="L89">    DUP_NAME = <span class="tok-number">52</span>,</span>
<span class="line" id="L90">    <span class="tok-comment">/// The network path was not found.</span></span>
<span class="line" id="L91">    BAD_NETPATH = <span class="tok-number">53</span>,</span>
<span class="line" id="L92">    <span class="tok-comment">/// The network is busy.</span></span>
<span class="line" id="L93">    NETWORK_BUSY = <span class="tok-number">54</span>,</span>
<span class="line" id="L94">    <span class="tok-comment">/// The specified network resource or device is no longer available.</span></span>
<span class="line" id="L95">    DEV_NOT_EXIST = <span class="tok-number">55</span>,</span>
<span class="line" id="L96">    <span class="tok-comment">/// The network BIOS command limit has been reached.</span></span>
<span class="line" id="L97">    TOO_MANY_CMDS = <span class="tok-number">56</span>,</span>
<span class="line" id="L98">    <span class="tok-comment">/// A network adapter hardware error occurred.</span></span>
<span class="line" id="L99">    ADAP_HDW_ERR = <span class="tok-number">57</span>,</span>
<span class="line" id="L100">    <span class="tok-comment">/// The specified server cannot perform the requested operation.</span></span>
<span class="line" id="L101">    BAD_NET_RESP = <span class="tok-number">58</span>,</span>
<span class="line" id="L102">    <span class="tok-comment">/// An unexpected network error occurred.</span></span>
<span class="line" id="L103">    UNEXP_NET_ERR = <span class="tok-number">59</span>,</span>
<span class="line" id="L104">    <span class="tok-comment">/// The remote adapter is not compatible.</span></span>
<span class="line" id="L105">    BAD_REM_ADAP = <span class="tok-number">60</span>,</span>
<span class="line" id="L106">    <span class="tok-comment">/// The printer queue is full.</span></span>
<span class="line" id="L107">    PRINTQ_FULL = <span class="tok-number">61</span>,</span>
<span class="line" id="L108">    <span class="tok-comment">/// Space to store the file waiting to be printed is not available on the server.</span></span>
<span class="line" id="L109">    NO_SPOOL_SPACE = <span class="tok-number">62</span>,</span>
<span class="line" id="L110">    <span class="tok-comment">/// Your file waiting to be printed was deleted.</span></span>
<span class="line" id="L111">    PRINT_CANCELLED = <span class="tok-number">63</span>,</span>
<span class="line" id="L112">    <span class="tok-comment">/// The specified network name is no longer available.</span></span>
<span class="line" id="L113">    NETNAME_DELETED = <span class="tok-number">64</span>,</span>
<span class="line" id="L114">    <span class="tok-comment">/// Network access is denied.</span></span>
<span class="line" id="L115">    NETWORK_ACCESS_DENIED = <span class="tok-number">65</span>,</span>
<span class="line" id="L116">    <span class="tok-comment">/// The network resource type is not correct.</span></span>
<span class="line" id="L117">    BAD_DEV_TYPE = <span class="tok-number">66</span>,</span>
<span class="line" id="L118">    <span class="tok-comment">/// The network name cannot be found.</span></span>
<span class="line" id="L119">    BAD_NET_NAME = <span class="tok-number">67</span>,</span>
<span class="line" id="L120">    <span class="tok-comment">/// The name limit for the local computer network adapter card was exceeded.</span></span>
<span class="line" id="L121">    TOO_MANY_NAMES = <span class="tok-number">68</span>,</span>
<span class="line" id="L122">    <span class="tok-comment">/// The network BIOS session limit was exceeded.</span></span>
<span class="line" id="L123">    TOO_MANY_SESS = <span class="tok-number">69</span>,</span>
<span class="line" id="L124">    <span class="tok-comment">/// The remote server has been paused or is in the process of being started.</span></span>
<span class="line" id="L125">    SHARING_PAUSED = <span class="tok-number">70</span>,</span>
<span class="line" id="L126">    <span class="tok-comment">/// No more connections can be made to this remote computer at this time because there are already as many connections as the computer can accept.</span></span>
<span class="line" id="L127">    REQ_NOT_ACCEP = <span class="tok-number">71</span>,</span>
<span class="line" id="L128">    <span class="tok-comment">/// The specified printer or disk device has been paused.</span></span>
<span class="line" id="L129">    REDIR_PAUSED = <span class="tok-number">72</span>,</span>
<span class="line" id="L130">    <span class="tok-comment">/// The file exists.</span></span>
<span class="line" id="L131">    FILE_EXISTS = <span class="tok-number">80</span>,</span>
<span class="line" id="L132">    <span class="tok-comment">/// The directory or file cannot be created.</span></span>
<span class="line" id="L133">    CANNOT_MAKE = <span class="tok-number">82</span>,</span>
<span class="line" id="L134">    <span class="tok-comment">/// Fail on INT 24.</span></span>
<span class="line" id="L135">    FAIL_I24 = <span class="tok-number">83</span>,</span>
<span class="line" id="L136">    <span class="tok-comment">/// Storage to process this request is not available.</span></span>
<span class="line" id="L137">    OUT_OF_STRUCTURES = <span class="tok-number">84</span>,</span>
<span class="line" id="L138">    <span class="tok-comment">/// The local device name is already in use.</span></span>
<span class="line" id="L139">    ALREADY_ASSIGNED = <span class="tok-number">85</span>,</span>
<span class="line" id="L140">    <span class="tok-comment">/// The specified network password is not correct.</span></span>
<span class="line" id="L141">    INVALID_PASSWORD = <span class="tok-number">86</span>,</span>
<span class="line" id="L142">    <span class="tok-comment">/// The parameter is incorrect.</span></span>
<span class="line" id="L143">    INVALID_PARAMETER = <span class="tok-number">87</span>,</span>
<span class="line" id="L144">    <span class="tok-comment">/// A write fault occurred on the network.</span></span>
<span class="line" id="L145">    NET_WRITE_FAULT = <span class="tok-number">88</span>,</span>
<span class="line" id="L146">    <span class="tok-comment">/// The system cannot start another process at this time.</span></span>
<span class="line" id="L147">    NO_PROC_SLOTS = <span class="tok-number">89</span>,</span>
<span class="line" id="L148">    <span class="tok-comment">/// Cannot create another system semaphore.</span></span>
<span class="line" id="L149">    TOO_MANY_SEMAPHORES = <span class="tok-number">100</span>,</span>
<span class="line" id="L150">    <span class="tok-comment">/// The exclusive semaphore is owned by another process.</span></span>
<span class="line" id="L151">    EXCL_SEM_ALREADY_OWNED = <span class="tok-number">101</span>,</span>
<span class="line" id="L152">    <span class="tok-comment">/// The semaphore is set and cannot be closed.</span></span>
<span class="line" id="L153">    SEM_IS_SET = <span class="tok-number">102</span>,</span>
<span class="line" id="L154">    <span class="tok-comment">/// The semaphore cannot be set again.</span></span>
<span class="line" id="L155">    TOO_MANY_SEM_REQUESTS = <span class="tok-number">103</span>,</span>
<span class="line" id="L156">    <span class="tok-comment">/// Cannot request exclusive semaphores at interrupt time.</span></span>
<span class="line" id="L157">    INVALID_AT_INTERRUPT_TIME = <span class="tok-number">104</span>,</span>
<span class="line" id="L158">    <span class="tok-comment">/// The previous ownership of this semaphore has ended.</span></span>
<span class="line" id="L159">    SEM_OWNER_DIED = <span class="tok-number">105</span>,</span>
<span class="line" id="L160">    <span class="tok-comment">/// Insert the diskette for drive %1.</span></span>
<span class="line" id="L161">    SEM_USER_LIMIT = <span class="tok-number">106</span>,</span>
<span class="line" id="L162">    <span class="tok-comment">/// The program stopped because an alternate diskette was not inserted.</span></span>
<span class="line" id="L163">    DISK_CHANGE = <span class="tok-number">107</span>,</span>
<span class="line" id="L164">    <span class="tok-comment">/// The disk is in use or locked by another process.</span></span>
<span class="line" id="L165">    DRIVE_LOCKED = <span class="tok-number">108</span>,</span>
<span class="line" id="L166">    <span class="tok-comment">/// The pipe has been ended.</span></span>
<span class="line" id="L167">    BROKEN_PIPE = <span class="tok-number">109</span>,</span>
<span class="line" id="L168">    <span class="tok-comment">/// The system cannot open the device or file specified.</span></span>
<span class="line" id="L169">    OPEN_FAILED = <span class="tok-number">110</span>,</span>
<span class="line" id="L170">    <span class="tok-comment">/// The file name is too long.</span></span>
<span class="line" id="L171">    BUFFER_OVERFLOW = <span class="tok-number">111</span>,</span>
<span class="line" id="L172">    <span class="tok-comment">/// There is not enough space on the disk.</span></span>
<span class="line" id="L173">    DISK_FULL = <span class="tok-number">112</span>,</span>
<span class="line" id="L174">    <span class="tok-comment">/// No more internal file identifiers available.</span></span>
<span class="line" id="L175">    NO_MORE_SEARCH_HANDLES = <span class="tok-number">113</span>,</span>
<span class="line" id="L176">    <span class="tok-comment">/// The target internal file identifier is incorrect.</span></span>
<span class="line" id="L177">    INVALID_TARGET_HANDLE = <span class="tok-number">114</span>,</span>
<span class="line" id="L178">    <span class="tok-comment">/// The IOCTL call made by the application program is not correct.</span></span>
<span class="line" id="L179">    INVALID_CATEGORY = <span class="tok-number">117</span>,</span>
<span class="line" id="L180">    <span class="tok-comment">/// The verify-on-write switch parameter value is not correct.</span></span>
<span class="line" id="L181">    INVALID_VERIFY_SWITCH = <span class="tok-number">118</span>,</span>
<span class="line" id="L182">    <span class="tok-comment">/// The system does not support the command requested.</span></span>
<span class="line" id="L183">    BAD_DRIVER_LEVEL = <span class="tok-number">119</span>,</span>
<span class="line" id="L184">    <span class="tok-comment">/// This function is not supported on this system.</span></span>
<span class="line" id="L185">    CALL_NOT_IMPLEMENTED = <span class="tok-number">120</span>,</span>
<span class="line" id="L186">    <span class="tok-comment">/// The semaphore timeout period has expired.</span></span>
<span class="line" id="L187">    SEM_TIMEOUT = <span class="tok-number">121</span>,</span>
<span class="line" id="L188">    <span class="tok-comment">/// The data area passed to a system call is too small.</span></span>
<span class="line" id="L189">    INSUFFICIENT_BUFFER = <span class="tok-number">122</span>,</span>
<span class="line" id="L190">    <span class="tok-comment">/// The filename, directory name, or volume label syntax is incorrect.</span></span>
<span class="line" id="L191">    INVALID_NAME = <span class="tok-number">123</span>,</span>
<span class="line" id="L192">    <span class="tok-comment">/// The system call level is not correct.</span></span>
<span class="line" id="L193">    INVALID_LEVEL = <span class="tok-number">124</span>,</span>
<span class="line" id="L194">    <span class="tok-comment">/// The disk has no volume label.</span></span>
<span class="line" id="L195">    NO_VOLUME_LABEL = <span class="tok-number">125</span>,</span>
<span class="line" id="L196">    <span class="tok-comment">/// The specified module could not be found.</span></span>
<span class="line" id="L197">    MOD_NOT_FOUND = <span class="tok-number">126</span>,</span>
<span class="line" id="L198">    <span class="tok-comment">/// The specified procedure could not be found.</span></span>
<span class="line" id="L199">    PROC_NOT_FOUND = <span class="tok-number">127</span>,</span>
<span class="line" id="L200">    <span class="tok-comment">/// There are no child processes to wait for.</span></span>
<span class="line" id="L201">    WAIT_NO_CHILDREN = <span class="tok-number">128</span>,</span>
<span class="line" id="L202">    <span class="tok-comment">/// The %1 application cannot be run in Win32 mode.</span></span>
<span class="line" id="L203">    CHILD_NOT_COMPLETE = <span class="tok-number">129</span>,</span>
<span class="line" id="L204">    <span class="tok-comment">/// Attempt to use a file handle to an open disk partition for an operation other than raw disk I/O.</span></span>
<span class="line" id="L205">    DIRECT_ACCESS_HANDLE = <span class="tok-number">130</span>,</span>
<span class="line" id="L206">    <span class="tok-comment">/// An attempt was made to move the file pointer before the beginning of the file.</span></span>
<span class="line" id="L207">    NEGATIVE_SEEK = <span class="tok-number">131</span>,</span>
<span class="line" id="L208">    <span class="tok-comment">/// The file pointer cannot be set on the specified device or file.</span></span>
<span class="line" id="L209">    SEEK_ON_DEVICE = <span class="tok-number">132</span>,</span>
<span class="line" id="L210">    <span class="tok-comment">/// A JOIN or SUBST command cannot be used for a drive that contains previously joined drives.</span></span>
<span class="line" id="L211">    IS_JOIN_TARGET = <span class="tok-number">133</span>,</span>
<span class="line" id="L212">    <span class="tok-comment">/// An attempt was made to use a JOIN or SUBST command on a drive that has already been joined.</span></span>
<span class="line" id="L213">    IS_JOINED = <span class="tok-number">134</span>,</span>
<span class="line" id="L214">    <span class="tok-comment">/// An attempt was made to use a JOIN or SUBST command on a drive that has already been substituted.</span></span>
<span class="line" id="L215">    IS_SUBSTED = <span class="tok-number">135</span>,</span>
<span class="line" id="L216">    <span class="tok-comment">/// The system tried to delete the JOIN of a drive that is not joined.</span></span>
<span class="line" id="L217">    NOT_JOINED = <span class="tok-number">136</span>,</span>
<span class="line" id="L218">    <span class="tok-comment">/// The system tried to delete the substitution of a drive that is not substituted.</span></span>
<span class="line" id="L219">    NOT_SUBSTED = <span class="tok-number">137</span>,</span>
<span class="line" id="L220">    <span class="tok-comment">/// The system tried to join a drive to a directory on a joined drive.</span></span>
<span class="line" id="L221">    JOIN_TO_JOIN = <span class="tok-number">138</span>,</span>
<span class="line" id="L222">    <span class="tok-comment">/// The system tried to substitute a drive to a directory on a substituted drive.</span></span>
<span class="line" id="L223">    SUBST_TO_SUBST = <span class="tok-number">139</span>,</span>
<span class="line" id="L224">    <span class="tok-comment">/// The system tried to join a drive to a directory on a substituted drive.</span></span>
<span class="line" id="L225">    JOIN_TO_SUBST = <span class="tok-number">140</span>,</span>
<span class="line" id="L226">    <span class="tok-comment">/// The system tried to SUBST a drive to a directory on a joined drive.</span></span>
<span class="line" id="L227">    SUBST_TO_JOIN = <span class="tok-number">141</span>,</span>
<span class="line" id="L228">    <span class="tok-comment">/// The system cannot perform a JOIN or SUBST at this time.</span></span>
<span class="line" id="L229">    BUSY_DRIVE = <span class="tok-number">142</span>,</span>
<span class="line" id="L230">    <span class="tok-comment">/// The system cannot join or substitute a drive to or for a directory on the same drive.</span></span>
<span class="line" id="L231">    SAME_DRIVE = <span class="tok-number">143</span>,</span>
<span class="line" id="L232">    <span class="tok-comment">/// The directory is not a subdirectory of the root directory.</span></span>
<span class="line" id="L233">    DIR_NOT_ROOT = <span class="tok-number">144</span>,</span>
<span class="line" id="L234">    <span class="tok-comment">/// The directory is not empty.</span></span>
<span class="line" id="L235">    DIR_NOT_EMPTY = <span class="tok-number">145</span>,</span>
<span class="line" id="L236">    <span class="tok-comment">/// The path specified is being used in a substitute.</span></span>
<span class="line" id="L237">    IS_SUBST_PATH = <span class="tok-number">146</span>,</span>
<span class="line" id="L238">    <span class="tok-comment">/// Not enough resources are available to process this command.</span></span>
<span class="line" id="L239">    IS_JOIN_PATH = <span class="tok-number">147</span>,</span>
<span class="line" id="L240">    <span class="tok-comment">/// The path specified cannot be used at this time.</span></span>
<span class="line" id="L241">    PATH_BUSY = <span class="tok-number">148</span>,</span>
<span class="line" id="L242">    <span class="tok-comment">/// An attempt was made to join or substitute a drive for which a directory on the drive is the target of a previous substitute.</span></span>
<span class="line" id="L243">    IS_SUBST_TARGET = <span class="tok-number">149</span>,</span>
<span class="line" id="L244">    <span class="tok-comment">/// System trace information was not specified in your CONFIG.SYS file, or tracing is disallowed.</span></span>
<span class="line" id="L245">    SYSTEM_TRACE = <span class="tok-number">150</span>,</span>
<span class="line" id="L246">    <span class="tok-comment">/// The number of specified semaphore events for DosMuxSemWait is not correct.</span></span>
<span class="line" id="L247">    INVALID_EVENT_COUNT = <span class="tok-number">151</span>,</span>
<span class="line" id="L248">    <span class="tok-comment">/// DosMuxSemWait did not execute; too many semaphores are already set.</span></span>
<span class="line" id="L249">    TOO_MANY_MUXWAITERS = <span class="tok-number">152</span>,</span>
<span class="line" id="L250">    <span class="tok-comment">/// The DosMuxSemWait list is not correct.</span></span>
<span class="line" id="L251">    INVALID_LIST_FORMAT = <span class="tok-number">153</span>,</span>
<span class="line" id="L252">    <span class="tok-comment">/// The volume label you entered exceeds the label character limit of the target file system.</span></span>
<span class="line" id="L253">    LABEL_TOO_LONG = <span class="tok-number">154</span>,</span>
<span class="line" id="L254">    <span class="tok-comment">/// Cannot create another thread.</span></span>
<span class="line" id="L255">    TOO_MANY_TCBS = <span class="tok-number">155</span>,</span>
<span class="line" id="L256">    <span class="tok-comment">/// The recipient process has refused the signal.</span></span>
<span class="line" id="L257">    SIGNAL_REFUSED = <span class="tok-number">156</span>,</span>
<span class="line" id="L258">    <span class="tok-comment">/// The segment is already discarded and cannot be locked.</span></span>
<span class="line" id="L259">    DISCARDED = <span class="tok-number">157</span>,</span>
<span class="line" id="L260">    <span class="tok-comment">/// The segment is already unlocked.</span></span>
<span class="line" id="L261">    NOT_LOCKED = <span class="tok-number">158</span>,</span>
<span class="line" id="L262">    <span class="tok-comment">/// The address for the thread ID is not correct.</span></span>
<span class="line" id="L263">    BAD_THREADID_ADDR = <span class="tok-number">159</span>,</span>
<span class="line" id="L264">    <span class="tok-comment">/// One or more arguments are not correct.</span></span>
<span class="line" id="L265">    BAD_ARGUMENTS = <span class="tok-number">160</span>,</span>
<span class="line" id="L266">    <span class="tok-comment">/// The specified path is invalid.</span></span>
<span class="line" id="L267">    BAD_PATHNAME = <span class="tok-number">161</span>,</span>
<span class="line" id="L268">    <span class="tok-comment">/// A signal is already pending.</span></span>
<span class="line" id="L269">    SIGNAL_PENDING = <span class="tok-number">162</span>,</span>
<span class="line" id="L270">    <span class="tok-comment">/// No more threads can be created in the system.</span></span>
<span class="line" id="L271">    MAX_THRDS_REACHED = <span class="tok-number">164</span>,</span>
<span class="line" id="L272">    <span class="tok-comment">/// Unable to lock a region of a file.</span></span>
<span class="line" id="L273">    LOCK_FAILED = <span class="tok-number">167</span>,</span>
<span class="line" id="L274">    <span class="tok-comment">/// The requested resource is in use.</span></span>
<span class="line" id="L275">    BUSY = <span class="tok-number">170</span>,</span>
<span class="line" id="L276">    <span class="tok-comment">/// Device's command support detection is in progress.</span></span>
<span class="line" id="L277">    DEVICE_SUPPORT_IN_PROGRESS = <span class="tok-number">171</span>,</span>
<span class="line" id="L278">    <span class="tok-comment">/// A lock request was not outstanding for the supplied cancel region.</span></span>
<span class="line" id="L279">    CANCEL_VIOLATION = <span class="tok-number">173</span>,</span>
<span class="line" id="L280">    <span class="tok-comment">/// The file system does not support atomic changes to the lock type.</span></span>
<span class="line" id="L281">    ATOMIC_LOCKS_NOT_SUPPORTED = <span class="tok-number">174</span>,</span>
<span class="line" id="L282">    <span class="tok-comment">/// The system detected a segment number that was not correct.</span></span>
<span class="line" id="L283">    INVALID_SEGMENT_NUMBER = <span class="tok-number">180</span>,</span>
<span class="line" id="L284">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L285">    INVALID_ORDINAL = <span class="tok-number">182</span>,</span>
<span class="line" id="L286">    <span class="tok-comment">/// Cannot create a file when that file already exists.</span></span>
<span class="line" id="L287">    ALREADY_EXISTS = <span class="tok-number">183</span>,</span>
<span class="line" id="L288">    <span class="tok-comment">/// The flag passed is not correct.</span></span>
<span class="line" id="L289">    INVALID_FLAG_NUMBER = <span class="tok-number">186</span>,</span>
<span class="line" id="L290">    <span class="tok-comment">/// The specified system semaphore name was not found.</span></span>
<span class="line" id="L291">    SEM_NOT_FOUND = <span class="tok-number">187</span>,</span>
<span class="line" id="L292">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L293">    INVALID_STARTING_CODESEG = <span class="tok-number">188</span>,</span>
<span class="line" id="L294">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L295">    INVALID_STACKSEG = <span class="tok-number">189</span>,</span>
<span class="line" id="L296">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L297">    INVALID_MODULETYPE = <span class="tok-number">190</span>,</span>
<span class="line" id="L298">    <span class="tok-comment">/// Cannot run %1 in Win32 mode.</span></span>
<span class="line" id="L299">    INVALID_EXE_SIGNATURE = <span class="tok-number">191</span>,</span>
<span class="line" id="L300">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L301">    EXE_MARKED_INVALID = <span class="tok-number">192</span>,</span>
<span class="line" id="L302">    <span class="tok-comment">/// %1 is not a valid Win32 application.</span></span>
<span class="line" id="L303">    BAD_EXE_FORMAT = <span class="tok-number">193</span>,</span>
<span class="line" id="L304">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L305">    ITERATED_DATA_EXCEEDS_64k = <span class="tok-number">194</span>,</span>
<span class="line" id="L306">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L307">    INVALID_MINALLOCSIZE = <span class="tok-number">195</span>,</span>
<span class="line" id="L308">    <span class="tok-comment">/// The operating system cannot run this application program.</span></span>
<span class="line" id="L309">    DYNLINK_FROM_INVALID_RING = <span class="tok-number">196</span>,</span>
<span class="line" id="L310">    <span class="tok-comment">/// The operating system is not presently configured to run this application.</span></span>
<span class="line" id="L311">    IOPL_NOT_ENABLED = <span class="tok-number">197</span>,</span>
<span class="line" id="L312">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L313">    INVALID_SEGDPL = <span class="tok-number">198</span>,</span>
<span class="line" id="L314">    <span class="tok-comment">/// The operating system cannot run this application program.</span></span>
<span class="line" id="L315">    AUTODATASEG_EXCEEDS_64k = <span class="tok-number">199</span>,</span>
<span class="line" id="L316">    <span class="tok-comment">/// The code segment cannot be greater than or equal to 64K.</span></span>
<span class="line" id="L317">    RING2SEG_MUST_BE_MOVABLE = <span class="tok-number">200</span>,</span>
<span class="line" id="L318">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L319">    RELOC_CHAIN_XEEDS_SEGLIM = <span class="tok-number">201</span>,</span>
<span class="line" id="L320">    <span class="tok-comment">/// The operating system cannot run %1.</span></span>
<span class="line" id="L321">    INFLOOP_IN_RELOC_CHAIN = <span class="tok-number">202</span>,</span>
<span class="line" id="L322">    <span class="tok-comment">/// The system could not find the environment option that was entered.</span></span>
<span class="line" id="L323">    ENVVAR_NOT_FOUND = <span class="tok-number">203</span>,</span>
<span class="line" id="L324">    <span class="tok-comment">/// No process in the command subtree has a signal handler.</span></span>
<span class="line" id="L325">    NO_SIGNAL_SENT = <span class="tok-number">205</span>,</span>
<span class="line" id="L326">    <span class="tok-comment">/// The filename or extension is too long.</span></span>
<span class="line" id="L327">    FILENAME_EXCED_RANGE = <span class="tok-number">206</span>,</span>
<span class="line" id="L328">    <span class="tok-comment">/// The ring 2 stack is in use.</span></span>
<span class="line" id="L329">    RING2_STACK_IN_USE = <span class="tok-number">207</span>,</span>
<span class="line" id="L330">    <span class="tok-comment">/// The global filename characters, * or ?, are entered incorrectly or too many global filename characters are specified.</span></span>
<span class="line" id="L331">    META_EXPANSION_TOO_LONG = <span class="tok-number">208</span>,</span>
<span class="line" id="L332">    <span class="tok-comment">/// The signal being posted is not correct.</span></span>
<span class="line" id="L333">    INVALID_SIGNAL_NUMBER = <span class="tok-number">209</span>,</span>
<span class="line" id="L334">    <span class="tok-comment">/// The signal handler cannot be set.</span></span>
<span class="line" id="L335">    THREAD_1_INACTIVE = <span class="tok-number">210</span>,</span>
<span class="line" id="L336">    <span class="tok-comment">/// The segment is locked and cannot be reallocated.</span></span>
<span class="line" id="L337">    LOCKED = <span class="tok-number">212</span>,</span>
<span class="line" id="L338">    <span class="tok-comment">/// Too many dynamic-link modules are attached to this program or dynamic-link module.</span></span>
<span class="line" id="L339">    TOO_MANY_MODULES = <span class="tok-number">214</span>,</span>
<span class="line" id="L340">    <span class="tok-comment">/// Cannot nest calls to LoadModule.</span></span>
<span class="line" id="L341">    NESTING_NOT_ALLOWED = <span class="tok-number">215</span>,</span>
<span class="line" id="L342">    <span class="tok-comment">/// This version of %1 is not compatible with the version of Windows you're running.</span></span>
<span class="line" id="L343">    <span class="tok-comment">/// Check your computer's system information and then contact the software publisher.</span></span>
<span class="line" id="L344">    EXE_MACHINE_TYPE_MISMATCH = <span class="tok-number">216</span>,</span>
<span class="line" id="L345">    <span class="tok-comment">/// The image file %1 is signed, unable to modify.</span></span>
<span class="line" id="L346">    EXE_CANNOT_MODIFY_SIGNED_BINARY = <span class="tok-number">217</span>,</span>
<span class="line" id="L347">    <span class="tok-comment">/// The image file %1 is strong signed, unable to modify.</span></span>
<span class="line" id="L348">    EXE_CANNOT_MODIFY_STRONG_SIGNED_BINARY = <span class="tok-number">218</span>,</span>
<span class="line" id="L349">    <span class="tok-comment">/// This file is checked out or locked for editing by another user.</span></span>
<span class="line" id="L350">    FILE_CHECKED_OUT = <span class="tok-number">220</span>,</span>
<span class="line" id="L351">    <span class="tok-comment">/// The file must be checked out before saving changes.</span></span>
<span class="line" id="L352">    CHECKOUT_REQUIRED = <span class="tok-number">221</span>,</span>
<span class="line" id="L353">    <span class="tok-comment">/// The file type being saved or retrieved has been blocked.</span></span>
<span class="line" id="L354">    BAD_FILE_TYPE = <span class="tok-number">222</span>,</span>
<span class="line" id="L355">    <span class="tok-comment">/// The file size exceeds the limit allowed and cannot be saved.</span></span>
<span class="line" id="L356">    FILE_TOO_LARGE = <span class="tok-number">223</span>,</span>
<span class="line" id="L357">    <span class="tok-comment">/// Access Denied. Before opening files in this location, you must first add the web site to your trusted sites list, browse to the web site, and select the option to login automatically.</span></span>
<span class="line" id="L358">    FORMS_AUTH_REQUIRED = <span class="tok-number">224</span>,</span>
<span class="line" id="L359">    <span class="tok-comment">/// Operation did not complete successfully because the file contains a virus or potentially unwanted software.</span></span>
<span class="line" id="L360">    VIRUS_INFECTED = <span class="tok-number">225</span>,</span>
<span class="line" id="L361">    <span class="tok-comment">/// This file contains a virus or potentially unwanted software and cannot be opened.</span></span>
<span class="line" id="L362">    <span class="tok-comment">/// Due to the nature of this virus or potentially unwanted software, the file has been removed from this location.</span></span>
<span class="line" id="L363">    VIRUS_DELETED = <span class="tok-number">226</span>,</span>
<span class="line" id="L364">    <span class="tok-comment">/// The pipe is local.</span></span>
<span class="line" id="L365">    PIPE_LOCAL = <span class="tok-number">229</span>,</span>
<span class="line" id="L366">    <span class="tok-comment">/// The pipe state is invalid.</span></span>
<span class="line" id="L367">    BAD_PIPE = <span class="tok-number">230</span>,</span>
<span class="line" id="L368">    <span class="tok-comment">/// All pipe instances are busy.</span></span>
<span class="line" id="L369">    PIPE_BUSY = <span class="tok-number">231</span>,</span>
<span class="line" id="L370">    <span class="tok-comment">/// The pipe is being closed.</span></span>
<span class="line" id="L371">    NO_DATA = <span class="tok-number">232</span>,</span>
<span class="line" id="L372">    <span class="tok-comment">/// No process is on the other end of the pipe.</span></span>
<span class="line" id="L373">    PIPE_NOT_CONNECTED = <span class="tok-number">233</span>,</span>
<span class="line" id="L374">    <span class="tok-comment">/// More data is available.</span></span>
<span class="line" id="L375">    MORE_DATA = <span class="tok-number">234</span>,</span>
<span class="line" id="L376">    <span class="tok-comment">/// The session was canceled.</span></span>
<span class="line" id="L377">    VC_DISCONNECTED = <span class="tok-number">240</span>,</span>
<span class="line" id="L378">    <span class="tok-comment">/// The specified extended attribute name was invalid.</span></span>
<span class="line" id="L379">    INVALID_EA_NAME = <span class="tok-number">254</span>,</span>
<span class="line" id="L380">    <span class="tok-comment">/// The extended attributes are inconsistent.</span></span>
<span class="line" id="L381">    EA_LIST_INCONSISTENT = <span class="tok-number">255</span>,</span>
<span class="line" id="L382">    <span class="tok-comment">/// The wait operation timed out.</span></span>
<span class="line" id="L383">    IMEOUT = <span class="tok-number">258</span>,</span>
<span class="line" id="L384">    <span class="tok-comment">/// No more data is available.</span></span>
<span class="line" id="L385">    NO_MORE_ITEMS = <span class="tok-number">259</span>,</span>
<span class="line" id="L386">    <span class="tok-comment">/// The copy functions cannot be used.</span></span>
<span class="line" id="L387">    CANNOT_COPY = <span class="tok-number">266</span>,</span>
<span class="line" id="L388">    <span class="tok-comment">/// The directory name is invalid.</span></span>
<span class="line" id="L389">    DIRECTORY = <span class="tok-number">267</span>,</span>
<span class="line" id="L390">    <span class="tok-comment">/// The extended attributes did not fit in the buffer.</span></span>
<span class="line" id="L391">    EAS_DIDNT_FIT = <span class="tok-number">275</span>,</span>
<span class="line" id="L392">    <span class="tok-comment">/// The extended attribute file on the mounted file system is corrupt.</span></span>
<span class="line" id="L393">    EA_FILE_CORRUPT = <span class="tok-number">276</span>,</span>
<span class="line" id="L394">    <span class="tok-comment">/// The extended attribute table file is full.</span></span>
<span class="line" id="L395">    EA_TABLE_FULL = <span class="tok-number">277</span>,</span>
<span class="line" id="L396">    <span class="tok-comment">/// The specified extended attribute handle is invalid.</span></span>
<span class="line" id="L397">    INVALID_EA_HANDLE = <span class="tok-number">278</span>,</span>
<span class="line" id="L398">    <span class="tok-comment">/// The mounted file system does not support extended attributes.</span></span>
<span class="line" id="L399">    EAS_NOT_SUPPORTED = <span class="tok-number">282</span>,</span>
<span class="line" id="L400">    <span class="tok-comment">/// Attempt to release mutex not owned by caller.</span></span>
<span class="line" id="L401">    NOT_OWNER = <span class="tok-number">288</span>,</span>
<span class="line" id="L402">    <span class="tok-comment">/// Too many posts were made to a semaphore.</span></span>
<span class="line" id="L403">    TOO_MANY_POSTS = <span class="tok-number">298</span>,</span>
<span class="line" id="L404">    <span class="tok-comment">/// Only part of a ReadProcessMemory or WriteProcessMemory request was completed.</span></span>
<span class="line" id="L405">    PARTIAL_COPY = <span class="tok-number">299</span>,</span>
<span class="line" id="L406">    <span class="tok-comment">/// The oplock request is denied.</span></span>
<span class="line" id="L407">    OPLOCK_NOT_GRANTED = <span class="tok-number">300</span>,</span>
<span class="line" id="L408">    <span class="tok-comment">/// An invalid oplock acknowledgment was received by the system.</span></span>
<span class="line" id="L409">    INVALID_OPLOCK_PROTOCOL = <span class="tok-number">301</span>,</span>
<span class="line" id="L410">    <span class="tok-comment">/// The volume is too fragmented to complete this operation.</span></span>
<span class="line" id="L411">    DISK_TOO_FRAGMENTED = <span class="tok-number">302</span>,</span>
<span class="line" id="L412">    <span class="tok-comment">/// The file cannot be opened because it is in the process of being deleted.</span></span>
<span class="line" id="L413">    DELETE_PENDING = <span class="tok-number">303</span>,</span>
<span class="line" id="L414">    <span class="tok-comment">/// Short name settings may not be changed on this volume due to the global registry setting.</span></span>
<span class="line" id="L415">    INCOMPATIBLE_WITH_GLOBAL_SHORT_NAME_REGISTRY_SETTING = <span class="tok-number">304</span>,</span>
<span class="line" id="L416">    <span class="tok-comment">/// Short names are not enabled on this volume.</span></span>
<span class="line" id="L417">    SHORT_NAMES_NOT_ENABLED_ON_VOLUME = <span class="tok-number">305</span>,</span>
<span class="line" id="L418">    <span class="tok-comment">/// The security stream for the given volume is in an inconsistent state. Please run CHKDSK on the volume.</span></span>
<span class="line" id="L419">    SECURITY_STREAM_IS_INCONSISTENT = <span class="tok-number">306</span>,</span>
<span class="line" id="L420">    <span class="tok-comment">/// A requested file lock operation cannot be processed due to an invalid byte range.</span></span>
<span class="line" id="L421">    INVALID_LOCK_RANGE = <span class="tok-number">307</span>,</span>
<span class="line" id="L422">    <span class="tok-comment">/// The subsystem needed to support the image type is not present.</span></span>
<span class="line" id="L423">    IMAGE_SUBSYSTEM_NOT_PRESENT = <span class="tok-number">308</span>,</span>
<span class="line" id="L424">    <span class="tok-comment">/// The specified file already has a notification GUID associated with it.</span></span>
<span class="line" id="L425">    NOTIFICATION_GUID_ALREADY_DEFINED = <span class="tok-number">309</span>,</span>
<span class="line" id="L426">    <span class="tok-comment">/// An invalid exception handler routine has been detected.</span></span>
<span class="line" id="L427">    INVALID_EXCEPTION_HANDLER = <span class="tok-number">310</span>,</span>
<span class="line" id="L428">    <span class="tok-comment">/// Duplicate privileges were specified for the token.</span></span>
<span class="line" id="L429">    DUPLICATE_PRIVILEGES = <span class="tok-number">311</span>,</span>
<span class="line" id="L430">    <span class="tok-comment">/// No ranges for the specified operation were able to be processed.</span></span>
<span class="line" id="L431">    NO_RANGES_PROCESSED = <span class="tok-number">312</span>,</span>
<span class="line" id="L432">    <span class="tok-comment">/// Operation is not allowed on a file system internal file.</span></span>
<span class="line" id="L433">    NOT_ALLOWED_ON_SYSTEM_FILE = <span class="tok-number">313</span>,</span>
<span class="line" id="L434">    <span class="tok-comment">/// The physical resources of this disk have been exhausted.</span></span>
<span class="line" id="L435">    DISK_RESOURCES_EXHAUSTED = <span class="tok-number">314</span>,</span>
<span class="line" id="L436">    <span class="tok-comment">/// The token representing the data is invalid.</span></span>
<span class="line" id="L437">    INVALID_TOKEN = <span class="tok-number">315</span>,</span>
<span class="line" id="L438">    <span class="tok-comment">/// The device does not support the command feature.</span></span>
<span class="line" id="L439">    DEVICE_FEATURE_NOT_SUPPORTED = <span class="tok-number">316</span>,</span>
<span class="line" id="L440">    <span class="tok-comment">/// The system cannot find message text for message number 0x%1 in the message file for %2.</span></span>
<span class="line" id="L441">    MR_MID_NOT_FOUND = <span class="tok-number">317</span>,</span>
<span class="line" id="L442">    <span class="tok-comment">/// The scope specified was not found.</span></span>
<span class="line" id="L443">    SCOPE_NOT_FOUND = <span class="tok-number">318</span>,</span>
<span class="line" id="L444">    <span class="tok-comment">/// The Central Access Policy specified is not defined on the target machine.</span></span>
<span class="line" id="L445">    UNDEFINED_SCOPE = <span class="tok-number">319</span>,</span>
<span class="line" id="L446">    <span class="tok-comment">/// The Central Access Policy obtained from Active Directory is invalid.</span></span>
<span class="line" id="L447">    INVALID_CAP = <span class="tok-number">320</span>,</span>
<span class="line" id="L448">    <span class="tok-comment">/// The device is unreachable.</span></span>
<span class="line" id="L449">    DEVICE_UNREACHABLE = <span class="tok-number">321</span>,</span>
<span class="line" id="L450">    <span class="tok-comment">/// The target device has insufficient resources to complete the operation.</span></span>
<span class="line" id="L451">    DEVICE_NO_RESOURCES = <span class="tok-number">322</span>,</span>
<span class="line" id="L452">    <span class="tok-comment">/// A data integrity checksum error occurred. Data in the file stream is corrupt.</span></span>
<span class="line" id="L453">    DATA_CHECKSUM_ERROR = <span class="tok-number">323</span>,</span>
<span class="line" id="L454">    <span class="tok-comment">/// An attempt was made to modify both a KERNEL and normal Extended Attribute (EA) in the same operation.</span></span>
<span class="line" id="L455">    INTERMIXED_KERNEL_EA_OPERATION = <span class="tok-number">324</span>,</span>
<span class="line" id="L456">    <span class="tok-comment">/// Device does not support file-level TRIM.</span></span>
<span class="line" id="L457">    FILE_LEVEL_TRIM_NOT_SUPPORTED = <span class="tok-number">326</span>,</span>
<span class="line" id="L458">    <span class="tok-comment">/// The command specified a data offset that does not align to the device's granularity/alignment.</span></span>
<span class="line" id="L459">    OFFSET_ALIGNMENT_VIOLATION = <span class="tok-number">327</span>,</span>
<span class="line" id="L460">    <span class="tok-comment">/// The command specified an invalid field in its parameter list.</span></span>
<span class="line" id="L461">    INVALID_FIELD_IN_PARAMETER_LIST = <span class="tok-number">328</span>,</span>
<span class="line" id="L462">    <span class="tok-comment">/// An operation is currently in progress with the device.</span></span>
<span class="line" id="L463">    OPERATION_IN_PROGRESS = <span class="tok-number">329</span>,</span>
<span class="line" id="L464">    <span class="tok-comment">/// An attempt was made to send down the command via an invalid path to the target device.</span></span>
<span class="line" id="L465">    BAD_DEVICE_PATH = <span class="tok-number">330</span>,</span>
<span class="line" id="L466">    <span class="tok-comment">/// The command specified a number of descriptors that exceeded the maximum supported by the device.</span></span>
<span class="line" id="L467">    TOO_MANY_DESCRIPTORS = <span class="tok-number">331</span>,</span>
<span class="line" id="L468">    <span class="tok-comment">/// Scrub is disabled on the specified file.</span></span>
<span class="line" id="L469">    SCRUB_DATA_DISABLED = <span class="tok-number">332</span>,</span>
<span class="line" id="L470">    <span class="tok-comment">/// The storage device does not provide redundancy.</span></span>
<span class="line" id="L471">    NOT_REDUNDANT_STORAGE = <span class="tok-number">333</span>,</span>
<span class="line" id="L472">    <span class="tok-comment">/// An operation is not supported on a resident file.</span></span>
<span class="line" id="L473">    RESIDENT_FILE_NOT_SUPPORTED = <span class="tok-number">334</span>,</span>
<span class="line" id="L474">    <span class="tok-comment">/// An operation is not supported on a compressed file.</span></span>
<span class="line" id="L475">    COMPRESSED_FILE_NOT_SUPPORTED = <span class="tok-number">335</span>,</span>
<span class="line" id="L476">    <span class="tok-comment">/// An operation is not supported on a directory.</span></span>
<span class="line" id="L477">    DIRECTORY_NOT_SUPPORTED = <span class="tok-number">336</span>,</span>
<span class="line" id="L478">    <span class="tok-comment">/// The specified copy of the requested data could not be read.</span></span>
<span class="line" id="L479">    NOT_READ_FROM_COPY = <span class="tok-number">337</span>,</span>
<span class="line" id="L480">    <span class="tok-comment">/// No action was taken as a system reboot is required.</span></span>
<span class="line" id="L481">    FAIL_NOACTION_REBOOT = <span class="tok-number">350</span>,</span>
<span class="line" id="L482">    <span class="tok-comment">/// The shutdown operation failed.</span></span>
<span class="line" id="L483">    FAIL_SHUTDOWN = <span class="tok-number">351</span>,</span>
<span class="line" id="L484">    <span class="tok-comment">/// The restart operation failed.</span></span>
<span class="line" id="L485">    FAIL_RESTART = <span class="tok-number">352</span>,</span>
<span class="line" id="L486">    <span class="tok-comment">/// The maximum number of sessions has been reached.</span></span>
<span class="line" id="L487">    MAX_SESSIONS_REACHED = <span class="tok-number">353</span>,</span>
<span class="line" id="L488">    <span class="tok-comment">/// The thread is already in background processing mode.</span></span>
<span class="line" id="L489">    THREAD_MODE_ALREADY_BACKGROUND = <span class="tok-number">400</span>,</span>
<span class="line" id="L490">    <span class="tok-comment">/// The thread is not in background processing mode.</span></span>
<span class="line" id="L491">    THREAD_MODE_NOT_BACKGROUND = <span class="tok-number">401</span>,</span>
<span class="line" id="L492">    <span class="tok-comment">/// The process is already in background processing mode.</span></span>
<span class="line" id="L493">    PROCESS_MODE_ALREADY_BACKGROUND = <span class="tok-number">402</span>,</span>
<span class="line" id="L494">    <span class="tok-comment">/// The process is not in background processing mode.</span></span>
<span class="line" id="L495">    PROCESS_MODE_NOT_BACKGROUND = <span class="tok-number">403</span>,</span>
<span class="line" id="L496">    <span class="tok-comment">/// Attempt to access invalid address.</span></span>
<span class="line" id="L497">    INVALID_ADDRESS = <span class="tok-number">487</span>,</span>
<span class="line" id="L498">    <span class="tok-comment">/// User profile cannot be loaded.</span></span>
<span class="line" id="L499">    USER_PROFILE_LOAD = <span class="tok-number">500</span>,</span>
<span class="line" id="L500">    <span class="tok-comment">/// Arithmetic result exceeded 32 bits.</span></span>
<span class="line" id="L501">    ARITHMETIC_OVERFLOW = <span class="tok-number">534</span>,</span>
<span class="line" id="L502">    <span class="tok-comment">/// There is a process on other end of the pipe.</span></span>
<span class="line" id="L503">    PIPE_CONNECTED = <span class="tok-number">535</span>,</span>
<span class="line" id="L504">    <span class="tok-comment">/// Waiting for a process to open the other end of the pipe.</span></span>
<span class="line" id="L505">    PIPE_LISTENING = <span class="tok-number">536</span>,</span>
<span class="line" id="L506">    <span class="tok-comment">/// Application verifier has found an error in the current process.</span></span>
<span class="line" id="L507">    VERIFIER_STOP = <span class="tok-number">537</span>,</span>
<span class="line" id="L508">    <span class="tok-comment">/// An error occurred in the ABIOS subsystem.</span></span>
<span class="line" id="L509">    ABIOS_ERROR = <span class="tok-number">538</span>,</span>
<span class="line" id="L510">    <span class="tok-comment">/// A warning occurred in the WX86 subsystem.</span></span>
<span class="line" id="L511">    WX86_WARNING = <span class="tok-number">539</span>,</span>
<span class="line" id="L512">    <span class="tok-comment">/// An error occurred in the WX86 subsystem.</span></span>
<span class="line" id="L513">    WX86_ERROR = <span class="tok-number">540</span>,</span>
<span class="line" id="L514">    <span class="tok-comment">/// An attempt was made to cancel or set a timer that has an associated APC and the subject thread is not the thread that originally set the timer with an associated APC routine.</span></span>
<span class="line" id="L515">    TIMER_NOT_CANCELED = <span class="tok-number">541</span>,</span>
<span class="line" id="L516">    <span class="tok-comment">/// Unwind exception code.</span></span>
<span class="line" id="L517">    UNWIND = <span class="tok-number">542</span>,</span>
<span class="line" id="L518">    <span class="tok-comment">/// An invalid or unaligned stack was encountered during an unwind operation.</span></span>
<span class="line" id="L519">    BAD_STACK = <span class="tok-number">543</span>,</span>
<span class="line" id="L520">    <span class="tok-comment">/// An invalid unwind target was encountered during an unwind operation.</span></span>
<span class="line" id="L521">    INVALID_UNWIND_TARGET = <span class="tok-number">544</span>,</span>
<span class="line" id="L522">    <span class="tok-comment">/// Invalid Object Attributes specified to NtCreatePort or invalid Port Attributes specified to NtConnectPort</span></span>
<span class="line" id="L523">    INVALID_PORT_ATTRIBUTES = <span class="tok-number">545</span>,</span>
<span class="line" id="L524">    <span class="tok-comment">/// Length of message passed to NtRequestPort or NtRequestWaitReplyPort was longer than the maximum message allowed by the port.</span></span>
<span class="line" id="L525">    PORT_MESSAGE_TOO_LONG = <span class="tok-number">546</span>,</span>
<span class="line" id="L526">    <span class="tok-comment">/// An attempt was made to lower a quota limit below the current usage.</span></span>
<span class="line" id="L527">    INVALID_QUOTA_LOWER = <span class="tok-number">547</span>,</span>
<span class="line" id="L528">    <span class="tok-comment">/// An attempt was made to attach to a device that was already attached to another device.</span></span>
<span class="line" id="L529">    DEVICE_ALREADY_ATTACHED = <span class="tok-number">548</span>,</span>
<span class="line" id="L530">    <span class="tok-comment">/// An attempt was made to execute an instruction at an unaligned address and the host system does not support unaligned instruction references.</span></span>
<span class="line" id="L531">    INSTRUCTION_MISALIGNMENT = <span class="tok-number">549</span>,</span>
<span class="line" id="L532">    <span class="tok-comment">/// Profiling not started.</span></span>
<span class="line" id="L533">    PROFILING_NOT_STARTED = <span class="tok-number">550</span>,</span>
<span class="line" id="L534">    <span class="tok-comment">/// Profiling not stopped.</span></span>
<span class="line" id="L535">    PROFILING_NOT_STOPPED = <span class="tok-number">551</span>,</span>
<span class="line" id="L536">    <span class="tok-comment">/// The passed ACL did not contain the minimum required information.</span></span>
<span class="line" id="L537">    COULD_NOT_INTERPRET = <span class="tok-number">552</span>,</span>
<span class="line" id="L538">    <span class="tok-comment">/// The number of active profiling objects is at the maximum and no more may be started.</span></span>
<span class="line" id="L539">    PROFILING_AT_LIMIT = <span class="tok-number">553</span>,</span>
<span class="line" id="L540">    <span class="tok-comment">/// Used to indicate that an operation cannot continue without blocking for I/O.</span></span>
<span class="line" id="L541">    CANT_WAIT = <span class="tok-number">554</span>,</span>
<span class="line" id="L542">    <span class="tok-comment">/// Indicates that a thread attempted to terminate itself by default (called NtTerminateThread with NULL) and it was the last thread in the current process.</span></span>
<span class="line" id="L543">    CANT_TERMINATE_SELF = <span class="tok-number">555</span>,</span>
<span class="line" id="L544">    <span class="tok-comment">/// If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.</span></span>
<span class="line" id="L545">    <span class="tok-comment">/// In this case information is lost, however, the filter correctly handles the exception.</span></span>
<span class="line" id="L546">    UNEXPECTED_MM_CREATE_ERR = <span class="tok-number">556</span>,</span>
<span class="line" id="L547">    <span class="tok-comment">/// If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.</span></span>
<span class="line" id="L548">    <span class="tok-comment">/// In this case information is lost, however, the filter correctly handles the exception.</span></span>
<span class="line" id="L549">    UNEXPECTED_MM_MAP_ERROR = <span class="tok-number">557</span>,</span>
<span class="line" id="L550">    <span class="tok-comment">/// If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.</span></span>
<span class="line" id="L551">    <span class="tok-comment">/// In this case information is lost, however, the filter correctly handles the exception.</span></span>
<span class="line" id="L552">    UNEXPECTED_MM_EXTEND_ERR = <span class="tok-number">558</span>,</span>
<span class="line" id="L553">    <span class="tok-comment">/// A malformed function table was encountered during an unwind operation.</span></span>
<span class="line" id="L554">    BAD_FUNCTION_TABLE = <span class="tok-number">559</span>,</span>
<span class="line" id="L555">    <span class="tok-comment">/// Indicates that an attempt was made to assign protection to a file system file or directory and one of the SIDs in the security descriptor could not be translated into a GUID that could be stored by the file system.</span></span>
<span class="line" id="L556">    <span class="tok-comment">/// This causes the protection attempt to fail, which may cause a file creation attempt to fail.</span></span>
<span class="line" id="L557">    NO_GUID_TRANSLATION = <span class="tok-number">560</span>,</span>
<span class="line" id="L558">    <span class="tok-comment">/// Indicates that an attempt was made to grow an LDT by setting its size, or that the size was not an even number of selectors.</span></span>
<span class="line" id="L559">    INVALID_LDT_SIZE = <span class="tok-number">561</span>,</span>
<span class="line" id="L560">    <span class="tok-comment">/// Indicates that the starting value for the LDT information was not an integral multiple of the selector size.</span></span>
<span class="line" id="L561">    INVALID_LDT_OFFSET = <span class="tok-number">563</span>,</span>
<span class="line" id="L562">    <span class="tok-comment">/// Indicates that the user supplied an invalid descriptor when trying to set up Ldt descriptors.</span></span>
<span class="line" id="L563">    INVALID_LDT_DESCRIPTOR = <span class="tok-number">564</span>,</span>
<span class="line" id="L564">    <span class="tok-comment">/// Indicates a process has too many threads to perform the requested action.</span></span>
<span class="line" id="L565">    <span class="tok-comment">/// For example, assignment of a primary token may only be performed when a process has zero or one threads.</span></span>
<span class="line" id="L566">    TOO_MANY_THREADS = <span class="tok-number">565</span>,</span>
<span class="line" id="L567">    <span class="tok-comment">/// An attempt was made to operate on a thread within a specific process, but the thread specified is not in the process specified.</span></span>
<span class="line" id="L568">    THREAD_NOT_IN_PROCESS = <span class="tok-number">566</span>,</span>
<span class="line" id="L569">    <span class="tok-comment">/// Page file quota was exceeded.</span></span>
<span class="line" id="L570">    PAGEFILE_QUOTA_EXCEEDED = <span class="tok-number">567</span>,</span>
<span class="line" id="L571">    <span class="tok-comment">/// The Netlogon service cannot start because another Netlogon service running in the domain conflicts with the specified role.</span></span>
<span class="line" id="L572">    LOGON_SERVER_CONFLICT = <span class="tok-number">568</span>,</span>
<span class="line" id="L573">    <span class="tok-comment">/// The SAM database on a Windows Server is significantly out of synchronization with the copy on the Domain Controller. A complete synchronization is required.</span></span>
<span class="line" id="L574">    SYNCHRONIZATION_REQUIRED = <span class="tok-number">569</span>,</span>
<span class="line" id="L575">    <span class="tok-comment">/// The NtCreateFile API failed. This error should never be returned to an application, it is a place holder for the Windows Lan Manager Redirector to use in its internal error mapping routines.</span></span>
<span class="line" id="L576">    NET_OPEN_FAILED = <span class="tok-number">570</span>,</span>
<span class="line" id="L577">    <span class="tok-comment">/// {Privilege Failed} The I/O permissions for the process could not be changed.</span></span>
<span class="line" id="L578">    IO_PRIVILEGE_FAILED = <span class="tok-number">571</span>,</span>
<span class="line" id="L579">    <span class="tok-comment">/// {Application Exit by CTRL+C} The application terminated as a result of a CTRL+C.</span></span>
<span class="line" id="L580">    CONTROL_C_EXIT = <span class="tok-number">572</span>,</span>
<span class="line" id="L581">    <span class="tok-comment">/// {Missing System File} The required system file %hs is bad or missing.</span></span>
<span class="line" id="L582">    MISSING_SYSTEMFILE = <span class="tok-number">573</span>,</span>
<span class="line" id="L583">    <span class="tok-comment">/// {Application Error} The exception %s (0x%08lx) occurred in the application at location 0x%08lx.</span></span>
<span class="line" id="L584">    UNHANDLED_EXCEPTION = <span class="tok-number">574</span>,</span>
<span class="line" id="L585">    <span class="tok-comment">/// {Application Error} The application was unable to start correctly (0x%lx). Click OK to close the application.</span></span>
<span class="line" id="L586">    APP_INIT_FAILURE = <span class="tok-number">575</span>,</span>
<span class="line" id="L587">    <span class="tok-comment">/// {Unable to Create Paging File} The creation of the paging file %hs failed (%lx). The requested size was %ld.</span></span>
<span class="line" id="L588">    PAGEFILE_CREATE_FAILED = <span class="tok-number">576</span>,</span>
<span class="line" id="L589">    <span class="tok-comment">/// Windows cannot verify the digital signature for this file.</span></span>
<span class="line" id="L590">    <span class="tok-comment">/// A recent hardware or software change might have installed a file that is signed incorrectly or damaged, or that might be malicious software from an unknown source.</span></span>
<span class="line" id="L591">    INVALID_IMAGE_HASH = <span class="tok-number">577</span>,</span>
<span class="line" id="L592">    <span class="tok-comment">/// {No Paging File Specified} No paging file was specified in the system configuration.</span></span>
<span class="line" id="L593">    NO_PAGEFILE = <span class="tok-number">578</span>,</span>
<span class="line" id="L594">    <span class="tok-comment">/// {EXCEPTION} A real-mode application issued a floating-point instruction and floating-point hardware is not present.</span></span>
<span class="line" id="L595">    ILLEGAL_FLOAT_CONTEXT = <span class="tok-number">579</span>,</span>
<span class="line" id="L596">    <span class="tok-comment">/// An event pair synchronization operation was performed using the thread specific client/server event pair object, but no event pair object was associated with the thread.</span></span>
<span class="line" id="L597">    NO_EVENT_PAIR = <span class="tok-number">580</span>,</span>
<span class="line" id="L598">    <span class="tok-comment">/// A Windows Server has an incorrect configuration.</span></span>
<span class="line" id="L599">    DOMAIN_CTRLR_CONFIG_ERROR = <span class="tok-number">581</span>,</span>
<span class="line" id="L600">    <span class="tok-comment">/// An illegal character was encountered.</span></span>
<span class="line" id="L601">    <span class="tok-comment">/// For a multi-byte character set this includes a lead byte without a succeeding trail byte.</span></span>
<span class="line" id="L602">    <span class="tok-comment">/// For the Unicode character set this includes the characters 0xFFFF and 0xFFFE.</span></span>
<span class="line" id="L603">    ILLEGAL_CHARACTER = <span class="tok-number">582</span>,</span>
<span class="line" id="L604">    <span class="tok-comment">/// The Unicode character is not defined in the Unicode character set installed on the system.</span></span>
<span class="line" id="L605">    UNDEFINED_CHARACTER = <span class="tok-number">583</span>,</span>
<span class="line" id="L606">    <span class="tok-comment">/// The paging file cannot be created on a floppy diskette.</span></span>
<span class="line" id="L607">    FLOPPY_VOLUME = <span class="tok-number">584</span>,</span>
<span class="line" id="L608">    <span class="tok-comment">/// The system BIOS failed to connect a system interrupt to the device or bus for which the device is connected.</span></span>
<span class="line" id="L609">    BIOS_FAILED_TO_CONNECT_INTERRUPT = <span class="tok-number">585</span>,</span>
<span class="line" id="L610">    <span class="tok-comment">/// This operation is only allowed for the Primary Domain Controller of the domain.</span></span>
<span class="line" id="L611">    BACKUP_CONTROLLER = <span class="tok-number">586</span>,</span>
<span class="line" id="L612">    <span class="tok-comment">/// An attempt was made to acquire a mutant such that its maximum count would have been exceeded.</span></span>
<span class="line" id="L613">    MUTANT_LIMIT_EXCEEDED = <span class="tok-number">587</span>,</span>
<span class="line" id="L614">    <span class="tok-comment">/// A volume has been accessed for which a file system driver is required that has not yet been loaded.</span></span>
<span class="line" id="L615">    FS_DRIVER_REQUIRED = <span class="tok-number">588</span>,</span>
<span class="line" id="L616">    <span class="tok-comment">/// {Registry File Failure} The registry cannot load the hive (file): %hs or its log or alternate. It is corrupt, absent, or not writable.</span></span>
<span class="line" id="L617">    CANNOT_LOAD_REGISTRY_FILE = <span class="tok-number">589</span>,</span>
<span class="line" id="L618">    <span class="tok-comment">/// {Unexpected Failure in DebugActiveProcess} An unexpected failure occurred while processing a DebugActiveProcess API request.</span></span>
<span class="line" id="L619">    <span class="tok-comment">/// You may choose OK to terminate the process, or Cancel to ignore the error.</span></span>
<span class="line" id="L620">    DEBUG_ATTACH_FAILED = <span class="tok-number">590</span>,</span>
<span class="line" id="L621">    <span class="tok-comment">/// {Fatal System Error} The %hs system process terminated unexpectedly with a status of 0x%08x (0x%08x 0x%08x). The system has been shut down.</span></span>
<span class="line" id="L622">    SYSTEM_PROCESS_TERMINATED = <span class="tok-number">591</span>,</span>
<span class="line" id="L623">    <span class="tok-comment">/// {Data Not Accepted} The TDI client could not handle the data received during an indication.</span></span>
<span class="line" id="L624">    DATA_NOT_ACCEPTED = <span class="tok-number">592</span>,</span>
<span class="line" id="L625">    <span class="tok-comment">/// NTVDM encountered a hard error.</span></span>
<span class="line" id="L626">    VDM_HARD_ERROR = <span class="tok-number">593</span>,</span>
<span class="line" id="L627">    <span class="tok-comment">/// {Cancel Timeout} The driver %hs failed to complete a cancelled I/O request in the allotted time.</span></span>
<span class="line" id="L628">    DRIVER_CANCEL_TIMEOUT = <span class="tok-number">594</span>,</span>
<span class="line" id="L629">    <span class="tok-comment">/// {Reply Message Mismatch} An attempt was made to reply to an LPC message, but the thread specified by the client ID in the message was not waiting on that message.</span></span>
<span class="line" id="L630">    REPLY_MESSAGE_MISMATCH = <span class="tok-number">595</span>,</span>
<span class="line" id="L631">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs. The data has been lost.</span></span>
<span class="line" id="L632">    <span class="tok-comment">/// This error may be caused by a failure of your computer hardware or network connection. Please try to save this file elsewhere.</span></span>
<span class="line" id="L633">    LOST_WRITEBEHIND_DATA = <span class="tok-number">596</span>,</span>
<span class="line" id="L634">    <span class="tok-comment">/// The parameter(s) passed to the server in the client/server shared memory window were invalid.</span></span>
<span class="line" id="L635">    <span class="tok-comment">/// Too much data may have been put in the shared memory window.</span></span>
<span class="line" id="L636">    CLIENT_SERVER_PARAMETERS_INVALID = <span class="tok-number">597</span>,</span>
<span class="line" id="L637">    <span class="tok-comment">/// The stream is not a tiny stream.</span></span>
<span class="line" id="L638">    NOT_TINY_STREAM = <span class="tok-number">598</span>,</span>
<span class="line" id="L639">    <span class="tok-comment">/// The request must be handled by the stack overflow code.</span></span>
<span class="line" id="L640">    STACK_OVERFLOW_READ = <span class="tok-number">599</span>,</span>
<span class="line" id="L641">    <span class="tok-comment">/// Internal OFS status codes indicating how an allocation operation is handled.</span></span>
<span class="line" id="L642">    <span class="tok-comment">/// Either it is retried after the containing onode is moved or the extent stream is converted to a large stream.</span></span>
<span class="line" id="L643">    CONVERT_TO_LARGE = <span class="tok-number">600</span>,</span>
<span class="line" id="L644">    <span class="tok-comment">/// The attempt to find the object found an object matching by ID on the volume but it is out of the scope of the handle used for the operation.</span></span>
<span class="line" id="L645">    FOUND_OUT_OF_SCOPE = <span class="tok-number">601</span>,</span>
<span class="line" id="L646">    <span class="tok-comment">/// The bucket array must be grown. Retry transaction after doing so.</span></span>
<span class="line" id="L647">    ALLOCATE_BUCKET = <span class="tok-number">602</span>,</span>
<span class="line" id="L648">    <span class="tok-comment">/// The user/kernel marshalling buffer has overflowed.</span></span>
<span class="line" id="L649">    MARSHALL_OVERFLOW = <span class="tok-number">603</span>,</span>
<span class="line" id="L650">    <span class="tok-comment">/// The supplied variant structure contains invalid data.</span></span>
<span class="line" id="L651">    INVALID_VARIANT = <span class="tok-number">604</span>,</span>
<span class="line" id="L652">    <span class="tok-comment">/// The specified buffer contains ill-formed data.</span></span>
<span class="line" id="L653">    BAD_COMPRESSION_BUFFER = <span class="tok-number">605</span>,</span>
<span class="line" id="L654">    <span class="tok-comment">/// {Audit Failed} An attempt to generate a security audit failed.</span></span>
<span class="line" id="L655">    AUDIT_FAILED = <span class="tok-number">606</span>,</span>
<span class="line" id="L656">    <span class="tok-comment">/// The timer resolution was not previously set by the current process.</span></span>
<span class="line" id="L657">    TIMER_RESOLUTION_NOT_SET = <span class="tok-number">607</span>,</span>
<span class="line" id="L658">    <span class="tok-comment">/// There is insufficient account information to log you on.</span></span>
<span class="line" id="L659">    INSUFFICIENT_LOGON_INFO = <span class="tok-number">608</span>,</span>
<span class="line" id="L660">    <span class="tok-comment">/// {Invalid DLL Entrypoint} The dynamic link library %hs is not written correctly.</span></span>
<span class="line" id="L661">    <span class="tok-comment">/// The stack pointer has been left in an inconsistent state.</span></span>
<span class="line" id="L662">    <span class="tok-comment">/// The entrypoint should be declared as WINAPI or STDCALL.</span></span>
<span class="line" id="L663">    <span class="tok-comment">/// Select YES to fail the DLL load. Select NO to continue execution.</span></span>
<span class="line" id="L664">    <span class="tok-comment">/// Selecting NO may cause the application to operate incorrectly.</span></span>
<span class="line" id="L665">    BAD_DLL_ENTRYPOINT = <span class="tok-number">609</span>,</span>
<span class="line" id="L666">    <span class="tok-comment">/// {Invalid Service Callback Entrypoint} The %hs service is not written correctly.</span></span>
<span class="line" id="L667">    <span class="tok-comment">/// The stack pointer has been left in an inconsistent state.</span></span>
<span class="line" id="L668">    <span class="tok-comment">/// The callback entrypoint should be declared as WINAPI or STDCALL.</span></span>
<span class="line" id="L669">    <span class="tok-comment">/// Selecting OK will cause the service to continue operation.</span></span>
<span class="line" id="L670">    <span class="tok-comment">/// However, the service process may operate incorrectly.</span></span>
<span class="line" id="L671">    BAD_SERVICE_ENTRYPOINT = <span class="tok-number">610</span>,</span>
<span class="line" id="L672">    <span class="tok-comment">/// There is an IP address conflict with another system on the network.</span></span>
<span class="line" id="L673">    IP_ADDRESS_CONFLICT1 = <span class="tok-number">611</span>,</span>
<span class="line" id="L674">    <span class="tok-comment">/// There is an IP address conflict with another system on the network.</span></span>
<span class="line" id="L675">    IP_ADDRESS_CONFLICT2 = <span class="tok-number">612</span>,</span>
<span class="line" id="L676">    <span class="tok-comment">/// {Low On Registry Space} The system has reached the maximum size allowed for the system part of the registry. Additional storage requests will be ignored.</span></span>
<span class="line" id="L677">    REGISTRY_QUOTA_LIMIT = <span class="tok-number">613</span>,</span>
<span class="line" id="L678">    <span class="tok-comment">/// A callback return system service cannot be executed when no callback is active.</span></span>
<span class="line" id="L679">    NO_CALLBACK_ACTIVE = <span class="tok-number">614</span>,</span>
<span class="line" id="L680">    <span class="tok-comment">/// The password provided is too short to meet the policy of your user account. Please choose a longer password.</span></span>
<span class="line" id="L681">    PWD_TOO_SHORT = <span class="tok-number">615</span>,</span>
<span class="line" id="L682">    <span class="tok-comment">/// The policy of your user account does not allow you to change passwords too frequently.</span></span>
<span class="line" id="L683">    <span class="tok-comment">/// This is done to prevent users from changing back to a familiar, but potentially discovered, password.</span></span>
<span class="line" id="L684">    <span class="tok-comment">/// If you feel your password has been compromised then please contact your administrator immediately to have a new one assigned.</span></span>
<span class="line" id="L685">    PWD_TOO_RECENT = <span class="tok-number">616</span>,</span>
<span class="line" id="L686">    <span class="tok-comment">/// You have attempted to change your password to one that you have used in the past.</span></span>
<span class="line" id="L687">    <span class="tok-comment">/// The policy of your user account does not allow this.</span></span>
<span class="line" id="L688">    <span class="tok-comment">/// Please select a password that you have not previously used.</span></span>
<span class="line" id="L689">    PWD_HISTORY_CONFLICT = <span class="tok-number">617</span>,</span>
<span class="line" id="L690">    <span class="tok-comment">/// The specified compression format is unsupported.</span></span>
<span class="line" id="L691">    UNSUPPORTED_COMPRESSION = <span class="tok-number">618</span>,</span>
<span class="line" id="L692">    <span class="tok-comment">/// The specified hardware profile configuration is invalid.</span></span>
<span class="line" id="L693">    INVALID_HW_PROFILE = <span class="tok-number">619</span>,</span>
<span class="line" id="L694">    <span class="tok-comment">/// The specified Plug and Play registry device path is invalid.</span></span>
<span class="line" id="L695">    INVALID_PLUGPLAY_DEVICE_PATH = <span class="tok-number">620</span>,</span>
<span class="line" id="L696">    <span class="tok-comment">/// The specified quota list is internally inconsistent with its descriptor.</span></span>
<span class="line" id="L697">    QUOTA_LIST_INCONSISTENT = <span class="tok-number">621</span>,</span>
<span class="line" id="L698">    <span class="tok-comment">/// {Windows Evaluation Notification} The evaluation period for this installation of Windows has expired. This system will shutdown in 1 hour.</span></span>
<span class="line" id="L699">    <span class="tok-comment">/// To restore access to this installation of Windows, please upgrade this installation using a licensed distribution of this product.</span></span>
<span class="line" id="L700">    EVALUATION_EXPIRATION = <span class="tok-number">622</span>,</span>
<span class="line" id="L701">    <span class="tok-comment">/// {Illegal System DLL Relocation} The system DLL %hs was relocated in memory. The application will not run properly.</span></span>
<span class="line" id="L702">    <span class="tok-comment">/// The relocation occurred because the DLL %hs occupied an address range reserved for Windows system DLLs.</span></span>
<span class="line" id="L703">    <span class="tok-comment">/// The vendor supplying the DLL should be contacted for a new DLL.</span></span>
<span class="line" id="L704">    ILLEGAL_DLL_RELOCATION = <span class="tok-number">623</span>,</span>
<span class="line" id="L705">    <span class="tok-comment">/// {DLL Initialization Failed} The application failed to initialize because the window station is shutting down.</span></span>
<span class="line" id="L706">    DLL_INIT_FAILED_LOGOFF = <span class="tok-number">624</span>,</span>
<span class="line" id="L707">    <span class="tok-comment">/// The validation process needs to continue on to the next step.</span></span>
<span class="line" id="L708">    VALIDATE_CONTINUE = <span class="tok-number">625</span>,</span>
<span class="line" id="L709">    <span class="tok-comment">/// There are no more matches for the current index enumeration.</span></span>
<span class="line" id="L710">    NO_MORE_MATCHES = <span class="tok-number">626</span>,</span>
<span class="line" id="L711">    <span class="tok-comment">/// The range could not be added to the range list because of a conflict.</span></span>
<span class="line" id="L712">    RANGE_LIST_CONFLICT = <span class="tok-number">627</span>,</span>
<span class="line" id="L713">    <span class="tok-comment">/// The server process is running under a SID different than that required by client.</span></span>
<span class="line" id="L714">    SERVER_SID_MISMATCH = <span class="tok-number">628</span>,</span>
<span class="line" id="L715">    <span class="tok-comment">/// A group marked use for deny only cannot be enabled.</span></span>
<span class="line" id="L716">    CANT_ENABLE_DENY_ONLY = <span class="tok-number">629</span>,</span>
<span class="line" id="L717">    <span class="tok-comment">/// {EXCEPTION} Multiple floating point faults.</span></span>
<span class="line" id="L718">    FLOAT_MULTIPLE_FAULTS = <span class="tok-number">630</span>,</span>
<span class="line" id="L719">    <span class="tok-comment">/// {EXCEPTION} Multiple floating point traps.</span></span>
<span class="line" id="L720">    FLOAT_MULTIPLE_TRAPS = <span class="tok-number">631</span>,</span>
<span class="line" id="L721">    <span class="tok-comment">/// The requested interface is not supported.</span></span>
<span class="line" id="L722">    NOINTERFACE = <span class="tok-number">632</span>,</span>
<span class="line" id="L723">    <span class="tok-comment">/// {System Standby Failed} The driver %hs does not support standby mode.</span></span>
<span class="line" id="L724">    <span class="tok-comment">/// Updating this driver may allow the system to go to standby mode.</span></span>
<span class="line" id="L725">    DRIVER_FAILED_SLEEP = <span class="tok-number">633</span>,</span>
<span class="line" id="L726">    <span class="tok-comment">/// The system file %1 has become corrupt and has been replaced.</span></span>
<span class="line" id="L727">    CORRUPT_SYSTEM_FILE = <span class="tok-number">634</span>,</span>
<span class="line" id="L728">    <span class="tok-comment">/// {Virtual Memory Minimum Too Low} Your system is low on virtual memory.</span></span>
<span class="line" id="L729">    <span class="tok-comment">/// Windows is increasing the size of your virtual memory paging file.</span></span>
<span class="line" id="L730">    <span class="tok-comment">/// During this process, memory requests for some applications may be denied. For more information, see Help.</span></span>
<span class="line" id="L731">    COMMITMENT_MINIMUM = <span class="tok-number">635</span>,</span>
<span class="line" id="L732">    <span class="tok-comment">/// A device was removed so enumeration must be restarted.</span></span>
<span class="line" id="L733">    PNP_RESTART_ENUMERATION = <span class="tok-number">636</span>,</span>
<span class="line" id="L734">    <span class="tok-comment">/// {Fatal System Error} The system image %s is not properly signed.</span></span>
<span class="line" id="L735">    <span class="tok-comment">/// The file has been replaced with the signed file. The system has been shut down.</span></span>
<span class="line" id="L736">    SYSTEM_IMAGE_BAD_SIGNATURE = <span class="tok-number">637</span>,</span>
<span class="line" id="L737">    <span class="tok-comment">/// Device will not start without a reboot.</span></span>
<span class="line" id="L738">    PNP_REBOOT_REQUIRED = <span class="tok-number">638</span>,</span>
<span class="line" id="L739">    <span class="tok-comment">/// There is not enough power to complete the requested operation.</span></span>
<span class="line" id="L740">    INSUFFICIENT_POWER = <span class="tok-number">639</span>,</span>
<span class="line" id="L741">    <span class="tok-comment">/// ERROR_MULTIPLE_FAULT_VIOLATION</span></span>
<span class="line" id="L742">    MULTIPLE_FAULT_VIOLATION = <span class="tok-number">640</span>,</span>
<span class="line" id="L743">    <span class="tok-comment">/// The system is in the process of shutting down.</span></span>
<span class="line" id="L744">    SYSTEM_SHUTDOWN = <span class="tok-number">641</span>,</span>
<span class="line" id="L745">    <span class="tok-comment">/// An attempt to remove a processes DebugPort was made, but a port was not already associated with the process.</span></span>
<span class="line" id="L746">    PORT_NOT_SET = <span class="tok-number">642</span>,</span>
<span class="line" id="L747">    <span class="tok-comment">/// This version of Windows is not compatible with the behavior version of directory forest, domain or domain controller.</span></span>
<span class="line" id="L748">    DS_VERSION_CHECK_FAILURE = <span class="tok-number">643</span>,</span>
<span class="line" id="L749">    <span class="tok-comment">/// The specified range could not be found in the range list.</span></span>
<span class="line" id="L750">    RANGE_NOT_FOUND = <span class="tok-number">644</span>,</span>
<span class="line" id="L751">    <span class="tok-comment">/// The driver was not loaded because the system is booting into safe mode.</span></span>
<span class="line" id="L752">    NOT_SAFE_MODE_DRIVER = <span class="tok-number">646</span>,</span>
<span class="line" id="L753">    <span class="tok-comment">/// The driver was not loaded because it failed its initialization call.</span></span>
<span class="line" id="L754">    FAILED_DRIVER_ENTRY = <span class="tok-number">647</span>,</span>
<span class="line" id="L755">    <span class="tok-comment">/// The &quot;%hs&quot; encountered an error while applying power or reading the device configuration.</span></span>
<span class="line" id="L756">    <span class="tok-comment">/// This may be caused by a failure of your hardware or by a poor connection.</span></span>
<span class="line" id="L757">    DEVICE_ENUMERATION_ERROR = <span class="tok-number">648</span>,</span>
<span class="line" id="L758">    <span class="tok-comment">/// The create operation failed because the name contained at least one mount point which resolves to a volume to which the specified device object is not attached.</span></span>
<span class="line" id="L759">    MOUNT_POINT_NOT_RESOLVED = <span class="tok-number">649</span>,</span>
<span class="line" id="L760">    <span class="tok-comment">/// The device object parameter is either not a valid device object or is not attached to the volume specified by the file name.</span></span>
<span class="line" id="L761">    INVALID_DEVICE_OBJECT_PARAMETER = <span class="tok-number">650</span>,</span>
<span class="line" id="L762">    <span class="tok-comment">/// A Machine Check Error has occurred.</span></span>
<span class="line" id="L763">    <span class="tok-comment">/// Please check the system eventlog for additional information.</span></span>
<span class="line" id="L764">    MCA_OCCURED = <span class="tok-number">651</span>,</span>
<span class="line" id="L765">    <span class="tok-comment">/// There was error [%2] processing the driver database.</span></span>
<span class="line" id="L766">    DRIVER_DATABASE_ERROR = <span class="tok-number">652</span>,</span>
<span class="line" id="L767">    <span class="tok-comment">/// System hive size has exceeded its limit.</span></span>
<span class="line" id="L768">    SYSTEM_HIVE_TOO_LARGE = <span class="tok-number">653</span>,</span>
<span class="line" id="L769">    <span class="tok-comment">/// The driver could not be loaded because a previous version of the driver is still in memory.</span></span>
<span class="line" id="L770">    DRIVER_FAILED_PRIOR_UNLOAD = <span class="tok-number">654</span>,</span>
<span class="line" id="L771">    <span class="tok-comment">/// {Volume Shadow Copy Service} Please wait while the Volume Shadow Copy Service prepares volume %hs for hibernation.</span></span>
<span class="line" id="L772">    VOLSNAP_PREPARE_HIBERNATE = <span class="tok-number">655</span>,</span>
<span class="line" id="L773">    <span class="tok-comment">/// The system has failed to hibernate (The error code is %hs).</span></span>
<span class="line" id="L774">    <span class="tok-comment">/// Hibernation will be disabled until the system is restarted.</span></span>
<span class="line" id="L775">    HIBERNATION_FAILURE = <span class="tok-number">656</span>,</span>
<span class="line" id="L776">    <span class="tok-comment">/// The password provided is too long to meet the policy of your user account. Please choose a shorter password.</span></span>
<span class="line" id="L777">    PWD_TOO_LONG = <span class="tok-number">657</span>,</span>
<span class="line" id="L778">    <span class="tok-comment">/// The requested operation could not be completed due to a file system limitation.</span></span>
<span class="line" id="L779">    FILE_SYSTEM_LIMITATION = <span class="tok-number">665</span>,</span>
<span class="line" id="L780">    <span class="tok-comment">/// An assertion failure has occurred.</span></span>
<span class="line" id="L781">    ASSERTION_FAILURE = <span class="tok-number">668</span>,</span>
<span class="line" id="L782">    <span class="tok-comment">/// An error occurred in the ACPI subsystem.</span></span>
<span class="line" id="L783">    ACPI_ERROR = <span class="tok-number">669</span>,</span>
<span class="line" id="L784">    <span class="tok-comment">/// WOW Assertion Error.</span></span>
<span class="line" id="L785">    WOW_ASSERTION = <span class="tok-number">670</span>,</span>
<span class="line" id="L786">    <span class="tok-comment">/// A device is missing in the system BIOS MPS table. This device will not be used.</span></span>
<span class="line" id="L787">    <span class="tok-comment">/// Please contact your system vendor for system BIOS update.</span></span>
<span class="line" id="L788">    PNP_BAD_MPS_TABLE = <span class="tok-number">671</span>,</span>
<span class="line" id="L789">    <span class="tok-comment">/// A translator failed to translate resources.</span></span>
<span class="line" id="L790">    PNP_TRANSLATION_FAILED = <span class="tok-number">672</span>,</span>
<span class="line" id="L791">    <span class="tok-comment">/// A IRQ translator failed to translate resources.</span></span>
<span class="line" id="L792">    PNP_IRQ_TRANSLATION_FAILED = <span class="tok-number">673</span>,</span>
<span class="line" id="L793">    <span class="tok-comment">/// Driver %2 returned invalid ID for a child device (%3).</span></span>
<span class="line" id="L794">    PNP_INVALID_ID = <span class="tok-number">674</span>,</span>
<span class="line" id="L795">    <span class="tok-comment">/// {Kernel Debugger Awakened} the system debugger was awakened by an interrupt.</span></span>
<span class="line" id="L796">    WAKE_SYSTEM_DEBUGGER = <span class="tok-number">675</span>,</span>
<span class="line" id="L797">    <span class="tok-comment">/// {Handles Closed} Handles to objects have been automatically closed as a result of the requested operation.</span></span>
<span class="line" id="L798">    HANDLES_CLOSED = <span class="tok-number">676</span>,</span>
<span class="line" id="L799">    <span class="tok-comment">/// {Too Much Information} The specified access control list (ACL) contained more information than was expected.</span></span>
<span class="line" id="L800">    EXTRANEOUS_INFORMATION = <span class="tok-number">677</span>,</span>
<span class="line" id="L801">    <span class="tok-comment">/// This warning level status indicates that the transaction state already exists for the registry sub-tree, but that a transaction commit was previously aborted.</span></span>
<span class="line" id="L802">    <span class="tok-comment">/// The commit has NOT been completed, but has not been rolled back either (so it may still be committed if desired).</span></span>
<span class="line" id="L803">    RXACT_COMMIT_NECESSARY = <span class="tok-number">678</span>,</span>
<span class="line" id="L804">    <span class="tok-comment">/// {Media Changed} The media may have changed.</span></span>
<span class="line" id="L805">    MEDIA_CHECK = <span class="tok-number">679</span>,</span>
<span class="line" id="L806">    <span class="tok-comment">/// {GUID Substitution} During the translation of a global identifier (GUID) to a Windows security ID (SID), no administratively-defined GUID prefix was found.</span></span>
<span class="line" id="L807">    <span class="tok-comment">/// A substitute prefix was used, which will not compromise system security.</span></span>
<span class="line" id="L808">    <span class="tok-comment">/// However, this may provide a more restrictive access than intended.</span></span>
<span class="line" id="L809">    GUID_SUBSTITUTION_MADE = <span class="tok-number">680</span>,</span>
<span class="line" id="L810">    <span class="tok-comment">/// The create operation stopped after reaching a symbolic link.</span></span>
<span class="line" id="L811">    STOPPED_ON_SYMLINK = <span class="tok-number">681</span>,</span>
<span class="line" id="L812">    <span class="tok-comment">/// A long jump has been executed.</span></span>
<span class="line" id="L813">    LONGJUMP = <span class="tok-number">682</span>,</span>
<span class="line" id="L814">    <span class="tok-comment">/// The Plug and Play query operation was not successful.</span></span>
<span class="line" id="L815">    PLUGPLAY_QUERY_VETOED = <span class="tok-number">683</span>,</span>
<span class="line" id="L816">    <span class="tok-comment">/// A frame consolidation has been executed.</span></span>
<span class="line" id="L817">    UNWIND_CONSOLIDATE = <span class="tok-number">684</span>,</span>
<span class="line" id="L818">    <span class="tok-comment">/// {Registry Hive Recovered} Registry hive (file): %hs was corrupted and it has been recovered. Some data might have been lost.</span></span>
<span class="line" id="L819">    REGISTRY_HIVE_RECOVERED = <span class="tok-number">685</span>,</span>
<span class="line" id="L820">    <span class="tok-comment">/// The application is attempting to run executable code from the module %hs. This may be insecure.</span></span>
<span class="line" id="L821">    <span class="tok-comment">/// An alternative, %hs, is available. Should the application use the secure module %hs?</span></span>
<span class="line" id="L822">    DLL_MIGHT_BE_INSECURE = <span class="tok-number">686</span>,</span>
<span class="line" id="L823">    <span class="tok-comment">/// The application is loading executable code from the module %hs.</span></span>
<span class="line" id="L824">    <span class="tok-comment">/// This is secure, but may be incompatible with previous releases of the operating system.</span></span>
<span class="line" id="L825">    <span class="tok-comment">/// An alternative, %hs, is available. Should the application use the secure module %hs?</span></span>
<span class="line" id="L826">    DLL_MIGHT_BE_INCOMPATIBLE = <span class="tok-number">687</span>,</span>
<span class="line" id="L827">    <span class="tok-comment">/// Debugger did not handle the exception.</span></span>
<span class="line" id="L828">    DBG_EXCEPTION_NOT_HANDLED = <span class="tok-number">688</span>,</span>
<span class="line" id="L829">    <span class="tok-comment">/// Debugger will reply later.</span></span>
<span class="line" id="L830">    DBG_REPLY_LATER = <span class="tok-number">689</span>,</span>
<span class="line" id="L831">    <span class="tok-comment">/// Debugger cannot provide handle.</span></span>
<span class="line" id="L832">    DBG_UNABLE_TO_PROVIDE_HANDLE = <span class="tok-number">690</span>,</span>
<span class="line" id="L833">    <span class="tok-comment">/// Debugger terminated thread.</span></span>
<span class="line" id="L834">    DBG_TERMINATE_THREAD = <span class="tok-number">691</span>,</span>
<span class="line" id="L835">    <span class="tok-comment">/// Debugger terminated process.</span></span>
<span class="line" id="L836">    DBG_TERMINATE_PROCESS = <span class="tok-number">692</span>,</span>
<span class="line" id="L837">    <span class="tok-comment">/// Debugger got control C.</span></span>
<span class="line" id="L838">    DBG_CONTROL_C = <span class="tok-number">693</span>,</span>
<span class="line" id="L839">    <span class="tok-comment">/// Debugger printed exception on control C.</span></span>
<span class="line" id="L840">    DBG_PRINTEXCEPTION_C = <span class="tok-number">694</span>,</span>
<span class="line" id="L841">    <span class="tok-comment">/// Debugger received RIP exception.</span></span>
<span class="line" id="L842">    DBG_RIPEXCEPTION = <span class="tok-number">695</span>,</span>
<span class="line" id="L843">    <span class="tok-comment">/// Debugger received control break.</span></span>
<span class="line" id="L844">    DBG_CONTROL_BREAK = <span class="tok-number">696</span>,</span>
<span class="line" id="L845">    <span class="tok-comment">/// Debugger command communication exception.</span></span>
<span class="line" id="L846">    DBG_COMMAND_EXCEPTION = <span class="tok-number">697</span>,</span>
<span class="line" id="L847">    <span class="tok-comment">/// {Object Exists} An attempt was made to create an object and the object name already existed.</span></span>
<span class="line" id="L848">    OBJECT_NAME_EXISTS = <span class="tok-number">698</span>,</span>
<span class="line" id="L849">    <span class="tok-comment">/// {Thread Suspended} A thread termination occurred while the thread was suspended.</span></span>
<span class="line" id="L850">    <span class="tok-comment">/// The thread was resumed, and termination proceeded.</span></span>
<span class="line" id="L851">    THREAD_WAS_SUSPENDED = <span class="tok-number">699</span>,</span>
<span class="line" id="L852">    <span class="tok-comment">/// {Image Relocated} An image file could not be mapped at the address specified in the image file. Local fixups must be performed on this image.</span></span>
<span class="line" id="L853">    IMAGE_NOT_AT_BASE = <span class="tok-number">700</span>,</span>
<span class="line" id="L854">    <span class="tok-comment">/// This informational level status indicates that a specified registry sub-tree transaction state did not yet exist and had to be created.</span></span>
<span class="line" id="L855">    RXACT_STATE_CREATED = <span class="tok-number">701</span>,</span>
<span class="line" id="L856">    <span class="tok-comment">/// {Segment Load} A virtual DOS machine (VDM) is loading, unloading, or moving an MS-DOS or Win16 program segment image.</span></span>
<span class="line" id="L857">    <span class="tok-comment">/// An exception is raised so a debugger can load, unload or track symbols and breakpoints within these 16-bit segments.</span></span>
<span class="line" id="L858">    SEGMENT_NOTIFICATION = <span class="tok-number">702</span>,</span>
<span class="line" id="L859">    <span class="tok-comment">/// {Invalid Current Directory} The process cannot switch to the startup current directory %hs.</span></span>
<span class="line" id="L860">    <span class="tok-comment">/// Select OK to set current directory to %hs, or select CANCEL to exit.</span></span>
<span class="line" id="L861">    BAD_CURRENT_DIRECTORY = <span class="tok-number">703</span>,</span>
<span class="line" id="L862">    <span class="tok-comment">/// {Redundant Read} To satisfy a read request, the NT fault-tolerant file system successfully read the requested data from a redundant copy.</span></span>
<span class="line" id="L863">    <span class="tok-comment">/// This was done because the file system encountered a failure on a member of the fault-tolerant volume, but was unable to reassign the failing area of the device.</span></span>
<span class="line" id="L864">    FT_READ_RECOVERY_FROM_BACKUP = <span class="tok-number">704</span>,</span>
<span class="line" id="L865">    <span class="tok-comment">/// {Redundant Write} To satisfy a write request, the NT fault-tolerant file system successfully wrote a redundant copy of the information.</span></span>
<span class="line" id="L866">    <span class="tok-comment">/// This was done because the file system encountered a failure on a member of the fault-tolerant volume, but was not able to reassign the failing area of the device.</span></span>
<span class="line" id="L867">    FT_WRITE_RECOVERY = <span class="tok-number">705</span>,</span>
<span class="line" id="L868">    <span class="tok-comment">/// {Machine Type Mismatch} The image file %hs is valid, but is for a machine type other than the current machine.</span></span>
<span class="line" id="L869">    <span class="tok-comment">/// Select OK to continue, or CANCEL to fail the DLL load.</span></span>
<span class="line" id="L870">    IMAGE_MACHINE_TYPE_MISMATCH = <span class="tok-number">706</span>,</span>
<span class="line" id="L871">    <span class="tok-comment">/// {Partial Data Received} The network transport returned partial data to its client. The remaining data will be sent later.</span></span>
<span class="line" id="L872">    RECEIVE_PARTIAL = <span class="tok-number">707</span>,</span>
<span class="line" id="L873">    <span class="tok-comment">/// {Expedited Data Received} The network transport returned data to its client that was marked as expedited by the remote system.</span></span>
<span class="line" id="L874">    RECEIVE_EXPEDITED = <span class="tok-number">708</span>,</span>
<span class="line" id="L875">    <span class="tok-comment">/// {Partial Expedited Data Received} The network transport returned partial data to its client and this data was marked as expedited by the remote system. The remaining data will be sent later.</span></span>
<span class="line" id="L876">    RECEIVE_PARTIAL_EXPEDITED = <span class="tok-number">709</span>,</span>
<span class="line" id="L877">    <span class="tok-comment">/// {TDI Event Done} The TDI indication has completed successfully.</span></span>
<span class="line" id="L878">    EVENT_DONE = <span class="tok-number">710</span>,</span>
<span class="line" id="L879">    <span class="tok-comment">/// {TDI Event Pending} The TDI indication has entered the pending state.</span></span>
<span class="line" id="L880">    EVENT_PENDING = <span class="tok-number">711</span>,</span>
<span class="line" id="L881">    <span class="tok-comment">/// Checking file system on %wZ.</span></span>
<span class="line" id="L882">    CHECKING_FILE_SYSTEM = <span class="tok-number">712</span>,</span>
<span class="line" id="L883">    <span class="tok-comment">/// {Fatal Application Exit} %hs.</span></span>
<span class="line" id="L884">    FATAL_APP_EXIT = <span class="tok-number">713</span>,</span>
<span class="line" id="L885">    <span class="tok-comment">/// The specified registry key is referenced by a predefined handle.</span></span>
<span class="line" id="L886">    PREDEFINED_HANDLE = <span class="tok-number">714</span>,</span>
<span class="line" id="L887">    <span class="tok-comment">/// {Page Unlocked} The page protection of a locked page was changed to 'No Access' and the page was unlocked from memory and from the process.</span></span>
<span class="line" id="L888">    WAS_UNLOCKED = <span class="tok-number">715</span>,</span>
<span class="line" id="L889">    <span class="tok-comment">/// %hs</span></span>
<span class="line" id="L890">    SERVICE_NOTIFICATION = <span class="tok-number">716</span>,</span>
<span class="line" id="L891">    <span class="tok-comment">/// {Page Locked} One of the pages to lock was already locked.</span></span>
<span class="line" id="L892">    WAS_LOCKED = <span class="tok-number">717</span>,</span>
<span class="line" id="L893">    <span class="tok-comment">/// Application popup: %1 : %2</span></span>
<span class="line" id="L894">    LOG_HARD_ERROR = <span class="tok-number">718</span>,</span>
<span class="line" id="L895">    <span class="tok-comment">/// ERROR_ALREADY_WIN32</span></span>
<span class="line" id="L896">    ALREADY_WIN32 = <span class="tok-number">719</span>,</span>
<span class="line" id="L897">    <span class="tok-comment">/// {Machine Type Mismatch} The image file %hs is valid, but is for a machine type other than the current machine.</span></span>
<span class="line" id="L898">    IMAGE_MACHINE_TYPE_MISMATCH_EXE = <span class="tok-number">720</span>,</span>
<span class="line" id="L899">    <span class="tok-comment">/// A yield execution was performed and no thread was available to run.</span></span>
<span class="line" id="L900">    NO_YIELD_PERFORMED = <span class="tok-number">721</span>,</span>
<span class="line" id="L901">    <span class="tok-comment">/// The resumable flag to a timer API was ignored.</span></span>
<span class="line" id="L902">    TIMER_RESUME_IGNORED = <span class="tok-number">722</span>,</span>
<span class="line" id="L903">    <span class="tok-comment">/// The arbiter has deferred arbitration of these resources to its parent.</span></span>
<span class="line" id="L904">    ARBITRATION_UNHANDLED = <span class="tok-number">723</span>,</span>
<span class="line" id="L905">    <span class="tok-comment">/// The inserted CardBus device cannot be started because of a configuration error on &quot;%hs&quot;.</span></span>
<span class="line" id="L906">    CARDBUS_NOT_SUPPORTED = <span class="tok-number">724</span>,</span>
<span class="line" id="L907">    <span class="tok-comment">/// The CPUs in this multiprocessor system are not all the same revision level.</span></span>
<span class="line" id="L908">    <span class="tok-comment">/// To use all processors the operating system restricts itself to the features of the least capable processor in the system.</span></span>
<span class="line" id="L909">    <span class="tok-comment">/// Should problems occur with this system, contact the CPU manufacturer to see if this mix of processors is supported.</span></span>
<span class="line" id="L910">    MP_PROCESSOR_MISMATCH = <span class="tok-number">725</span>,</span>
<span class="line" id="L911">    <span class="tok-comment">/// The system was put into hibernation.</span></span>
<span class="line" id="L912">    HIBERNATED = <span class="tok-number">726</span>,</span>
<span class="line" id="L913">    <span class="tok-comment">/// The system was resumed from hibernation.</span></span>
<span class="line" id="L914">    RESUME_HIBERNATION = <span class="tok-number">727</span>,</span>
<span class="line" id="L915">    <span class="tok-comment">/// Windows has detected that the system firmware (BIOS) was updated [previous firmware date = %2, current firmware date %3].</span></span>
<span class="line" id="L916">    FIRMWARE_UPDATED = <span class="tok-number">728</span>,</span>
<span class="line" id="L917">    <span class="tok-comment">/// A device driver is leaking locked I/O pages causing system degradation.</span></span>
<span class="line" id="L918">    <span class="tok-comment">/// The system has automatically enabled tracking code in order to try and catch the culprit.</span></span>
<span class="line" id="L919">    DRIVERS_LEAKING_LOCKED_PAGES = <span class="tok-number">729</span>,</span>
<span class="line" id="L920">    <span class="tok-comment">/// The system has awoken.</span></span>
<span class="line" id="L921">    WAKE_SYSTEM = <span class="tok-number">730</span>,</span>
<span class="line" id="L922">    <span class="tok-comment">/// ERROR_WAIT_1</span></span>
<span class="line" id="L923">    WAIT_1 = <span class="tok-number">731</span>,</span>
<span class="line" id="L924">    <span class="tok-comment">/// ERROR_WAIT_2</span></span>
<span class="line" id="L925">    WAIT_2 = <span class="tok-number">732</span>,</span>
<span class="line" id="L926">    <span class="tok-comment">/// ERROR_WAIT_3</span></span>
<span class="line" id="L927">    WAIT_3 = <span class="tok-number">733</span>,</span>
<span class="line" id="L928">    <span class="tok-comment">/// ERROR_WAIT_63</span></span>
<span class="line" id="L929">    WAIT_63 = <span class="tok-number">734</span>,</span>
<span class="line" id="L930">    <span class="tok-comment">/// ERROR_ABANDONED_WAIT_0</span></span>
<span class="line" id="L931">    ABANDONED_WAIT_0 = <span class="tok-number">735</span>,</span>
<span class="line" id="L932">    <span class="tok-comment">/// ERROR_ABANDONED_WAIT_63</span></span>
<span class="line" id="L933">    ABANDONED_WAIT_63 = <span class="tok-number">736</span>,</span>
<span class="line" id="L934">    <span class="tok-comment">/// ERROR_USER_APC</span></span>
<span class="line" id="L935">    USER_APC = <span class="tok-number">737</span>,</span>
<span class="line" id="L936">    <span class="tok-comment">/// ERROR_KERNEL_APC</span></span>
<span class="line" id="L937">    KERNEL_APC = <span class="tok-number">738</span>,</span>
<span class="line" id="L938">    <span class="tok-comment">/// ERROR_ALERTED</span></span>
<span class="line" id="L939">    ALERTED = <span class="tok-number">739</span>,</span>
<span class="line" id="L940">    <span class="tok-comment">/// The requested operation requires elevation.</span></span>
<span class="line" id="L941">    ELEVATION_REQUIRED = <span class="tok-number">740</span>,</span>
<span class="line" id="L942">    <span class="tok-comment">/// A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link.</span></span>
<span class="line" id="L943">    REPARSE = <span class="tok-number">741</span>,</span>
<span class="line" id="L944">    <span class="tok-comment">/// An open/create operation completed while an oplock break is underway.</span></span>
<span class="line" id="L945">    OPLOCK_BREAK_IN_PROGRESS = <span class="tok-number">742</span>,</span>
<span class="line" id="L946">    <span class="tok-comment">/// A new volume has been mounted by a file system.</span></span>
<span class="line" id="L947">    VOLUME_MOUNTED = <span class="tok-number">743</span>,</span>
<span class="line" id="L948">    <span class="tok-comment">/// This success level status indicates that the transaction state already exists for the registry sub-tree, but that a transaction commit was previously aborted. The commit has now been completed.</span></span>
<span class="line" id="L949">    RXACT_COMMITTED = <span class="tok-number">744</span>,</span>
<span class="line" id="L950">    <span class="tok-comment">/// This indicates that a notify change request has been completed due to closing the handle which made the notify change request.</span></span>
<span class="line" id="L951">    NOTIFY_CLEANUP = <span class="tok-number">745</span>,</span>
<span class="line" id="L952">    <span class="tok-comment">/// {Connect Failure on Primary Transport} An attempt was made to connect to the remote server %hs on the primary transport, but the connection failed.</span></span>
<span class="line" id="L953">    <span class="tok-comment">/// The computer WAS able to connect on a secondary transport.</span></span>
<span class="line" id="L954">    PRIMARY_TRANSPORT_CONNECT_FAILED = <span class="tok-number">746</span>,</span>
<span class="line" id="L955">    <span class="tok-comment">/// Page fault was a transition fault.</span></span>
<span class="line" id="L956">    PAGE_FAULT_TRANSITION = <span class="tok-number">747</span>,</span>
<span class="line" id="L957">    <span class="tok-comment">/// Page fault was a demand zero fault.</span></span>
<span class="line" id="L958">    PAGE_FAULT_DEMAND_ZERO = <span class="tok-number">748</span>,</span>
<span class="line" id="L959">    <span class="tok-comment">/// Page fault was a demand zero fault.</span></span>
<span class="line" id="L960">    PAGE_FAULT_COPY_ON_WRITE = <span class="tok-number">749</span>,</span>
<span class="line" id="L961">    <span class="tok-comment">/// Page fault was a demand zero fault.</span></span>
<span class="line" id="L962">    PAGE_FAULT_GUARD_PAGE = <span class="tok-number">750</span>,</span>
<span class="line" id="L963">    <span class="tok-comment">/// Page fault was satisfied by reading from a secondary storage device.</span></span>
<span class="line" id="L964">    PAGE_FAULT_PAGING_FILE = <span class="tok-number">751</span>,</span>
<span class="line" id="L965">    <span class="tok-comment">/// Cached page was locked during operation.</span></span>
<span class="line" id="L966">    CACHE_PAGE_LOCKED = <span class="tok-number">752</span>,</span>
<span class="line" id="L967">    <span class="tok-comment">/// Crash dump exists in paging file.</span></span>
<span class="line" id="L968">    CRASH_DUMP = <span class="tok-number">753</span>,</span>
<span class="line" id="L969">    <span class="tok-comment">/// Specified buffer contains all zeros.</span></span>
<span class="line" id="L970">    BUFFER_ALL_ZEROS = <span class="tok-number">754</span>,</span>
<span class="line" id="L971">    <span class="tok-comment">/// A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link.</span></span>
<span class="line" id="L972">    REPARSE_OBJECT = <span class="tok-number">755</span>,</span>
<span class="line" id="L973">    <span class="tok-comment">/// The device has succeeded a query-stop and its resource requirements have changed.</span></span>
<span class="line" id="L974">    RESOURCE_REQUIREMENTS_CHANGED = <span class="tok-number">756</span>,</span>
<span class="line" id="L975">    <span class="tok-comment">/// The translator has translated these resources into the global space and no further translations should be performed.</span></span>
<span class="line" id="L976">    TRANSLATION_COMPLETE = <span class="tok-number">757</span>,</span>
<span class="line" id="L977">    <span class="tok-comment">/// A process being terminated has no threads to terminate.</span></span>
<span class="line" id="L978">    NOTHING_TO_TERMINATE = <span class="tok-number">758</span>,</span>
<span class="line" id="L979">    <span class="tok-comment">/// The specified process is not part of a job.</span></span>
<span class="line" id="L980">    PROCESS_NOT_IN_JOB = <span class="tok-number">759</span>,</span>
<span class="line" id="L981">    <span class="tok-comment">/// The specified process is part of a job.</span></span>
<span class="line" id="L982">    PROCESS_IN_JOB = <span class="tok-number">760</span>,</span>
<span class="line" id="L983">    <span class="tok-comment">/// {Volume Shadow Copy Service} The system is now ready for hibernation.</span></span>
<span class="line" id="L984">    VOLSNAP_HIBERNATE_READY = <span class="tok-number">761</span>,</span>
<span class="line" id="L985">    <span class="tok-comment">/// A file system or file system filter driver has successfully completed an FsFilter operation.</span></span>
<span class="line" id="L986">    FSFILTER_OP_COMPLETED_SUCCESSFULLY = <span class="tok-number">762</span>,</span>
<span class="line" id="L987">    <span class="tok-comment">/// The specified interrupt vector was already connected.</span></span>
<span class="line" id="L988">    INTERRUPT_VECTOR_ALREADY_CONNECTED = <span class="tok-number">763</span>,</span>
<span class="line" id="L989">    <span class="tok-comment">/// The specified interrupt vector is still connected.</span></span>
<span class="line" id="L990">    INTERRUPT_STILL_CONNECTED = <span class="tok-number">764</span>,</span>
<span class="line" id="L991">    <span class="tok-comment">/// An operation is blocked waiting for an oplock.</span></span>
<span class="line" id="L992">    WAIT_FOR_OPLOCK = <span class="tok-number">765</span>,</span>
<span class="line" id="L993">    <span class="tok-comment">/// Debugger handled exception.</span></span>
<span class="line" id="L994">    DBG_EXCEPTION_HANDLED = <span class="tok-number">766</span>,</span>
<span class="line" id="L995">    <span class="tok-comment">/// Debugger continued.</span></span>
<span class="line" id="L996">    DBG_CONTINUE = <span class="tok-number">767</span>,</span>
<span class="line" id="L997">    <span class="tok-comment">/// An exception occurred in a user mode callback and the kernel callback frame should be removed.</span></span>
<span class="line" id="L998">    CALLBACK_POP_STACK = <span class="tok-number">768</span>,</span>
<span class="line" id="L999">    <span class="tok-comment">/// Compression is disabled for this volume.</span></span>
<span class="line" id="L1000">    COMPRESSION_DISABLED = <span class="tok-number">769</span>,</span>
<span class="line" id="L1001">    <span class="tok-comment">/// The data provider cannot fetch backwards through a result set.</span></span>
<span class="line" id="L1002">    CANTFETCHBACKWARDS = <span class="tok-number">770</span>,</span>
<span class="line" id="L1003">    <span class="tok-comment">/// The data provider cannot scroll backwards through a result set.</span></span>
<span class="line" id="L1004">    CANTSCROLLBACKWARDS = <span class="tok-number">771</span>,</span>
<span class="line" id="L1005">    <span class="tok-comment">/// The data provider requires that previously fetched data is released before asking for more data.</span></span>
<span class="line" id="L1006">    ROWSNOTRELEASED = <span class="tok-number">772</span>,</span>
<span class="line" id="L1007">    <span class="tok-comment">/// The data provider was not able to interpret the flags set for a column binding in an accessor.</span></span>
<span class="line" id="L1008">    BAD_ACCESSOR_FLAGS = <span class="tok-number">773</span>,</span>
<span class="line" id="L1009">    <span class="tok-comment">/// One or more errors occurred while processing the request.</span></span>
<span class="line" id="L1010">    ERRORS_ENCOUNTERED = <span class="tok-number">774</span>,</span>
<span class="line" id="L1011">    <span class="tok-comment">/// The implementation is not capable of performing the request.</span></span>
<span class="line" id="L1012">    NOT_CAPABLE = <span class="tok-number">775</span>,</span>
<span class="line" id="L1013">    <span class="tok-comment">/// The client of a component requested an operation which is not valid given the state of the component instance.</span></span>
<span class="line" id="L1014">    REQUEST_OUT_OF_SEQUENCE = <span class="tok-number">776</span>,</span>
<span class="line" id="L1015">    <span class="tok-comment">/// A version number could not be parsed.</span></span>
<span class="line" id="L1016">    VERSION_PARSE_ERROR = <span class="tok-number">777</span>,</span>
<span class="line" id="L1017">    <span class="tok-comment">/// The iterator's start position is invalid.</span></span>
<span class="line" id="L1018">    BADSTARTPOSITION = <span class="tok-number">778</span>,</span>
<span class="line" id="L1019">    <span class="tok-comment">/// The hardware has reported an uncorrectable memory error.</span></span>
<span class="line" id="L1020">    MEMORY_HARDWARE = <span class="tok-number">779</span>,</span>
<span class="line" id="L1021">    <span class="tok-comment">/// The attempted operation required self healing to be enabled.</span></span>
<span class="line" id="L1022">    DISK_REPAIR_DISABLED = <span class="tok-number">780</span>,</span>
<span class="line" id="L1023">    <span class="tok-comment">/// The Desktop heap encountered an error while allocating session memory.</span></span>
<span class="line" id="L1024">    <span class="tok-comment">/// There is more information in the system event log.</span></span>
<span class="line" id="L1025">    INSUFFICIENT_RESOURCE_FOR_SPECIFIED_SHARED_SECTION_SIZE = <span class="tok-number">781</span>,</span>
<span class="line" id="L1026">    <span class="tok-comment">/// The system power state is transitioning from %2 to %3.</span></span>
<span class="line" id="L1027">    SYSTEM_POWERSTATE_TRANSITION = <span class="tok-number">782</span>,</span>
<span class="line" id="L1028">    <span class="tok-comment">/// The system power state is transitioning from %2 to %3 but could enter %4.</span></span>
<span class="line" id="L1029">    SYSTEM_POWERSTATE_COMPLEX_TRANSITION = <span class="tok-number">783</span>,</span>
<span class="line" id="L1030">    <span class="tok-comment">/// A thread is getting dispatched with MCA EXCEPTION because of MCA.</span></span>
<span class="line" id="L1031">    MCA_EXCEPTION = <span class="tok-number">784</span>,</span>
<span class="line" id="L1032">    <span class="tok-comment">/// Access to %1 is monitored by policy rule %2.</span></span>
<span class="line" id="L1033">    ACCESS_AUDIT_BY_POLICY = <span class="tok-number">785</span>,</span>
<span class="line" id="L1034">    <span class="tok-comment">/// Access to %1 has been restricted by your Administrator by policy rule %2.</span></span>
<span class="line" id="L1035">    ACCESS_DISABLED_NO_SAFER_UI_BY_POLICY = <span class="tok-number">786</span>,</span>
<span class="line" id="L1036">    <span class="tok-comment">/// A valid hibernation file has been invalidated and should be abandoned.</span></span>
<span class="line" id="L1037">    ABANDON_HIBERFILE = <span class="tok-number">787</span>,</span>
<span class="line" id="L1038">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L1039">    <span class="tok-comment">/// This error may be caused by network connectivity issues. Please try to save this file elsewhere.</span></span>
<span class="line" id="L1040">    LOST_WRITEBEHIND_DATA_NETWORK_DISCONNECTED = <span class="tok-number">788</span>,</span>
<span class="line" id="L1041">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L1042">    <span class="tok-comment">/// This error was returned by the server on which the file exists. Please try to save this file elsewhere.</span></span>
<span class="line" id="L1043">    LOST_WRITEBEHIND_DATA_NETWORK_SERVER_ERROR = <span class="tok-number">789</span>,</span>
<span class="line" id="L1044">    <span class="tok-comment">/// {Delayed Write Failed} Windows was unable to save all the data for the file %hs; the data has been lost.</span></span>
<span class="line" id="L1045">    <span class="tok-comment">/// This error may be caused if the device has been removed or the media is write-protected.</span></span>
<span class="line" id="L1046">    LOST_WRITEBEHIND_DATA_LOCAL_DISK_ERROR = <span class="tok-number">790</span>,</span>
<span class="line" id="L1047">    <span class="tok-comment">/// The resources required for this device conflict with the MCFG table.</span></span>
<span class="line" id="L1048">    BAD_MCFG_TABLE = <span class="tok-number">791</span>,</span>
<span class="line" id="L1049">    <span class="tok-comment">/// The volume repair could not be performed while it is online.</span></span>
<span class="line" id="L1050">    <span class="tok-comment">/// Please schedule to take the volume offline so that it can be repaired.</span></span>
<span class="line" id="L1051">    DISK_REPAIR_REDIRECTED = <span class="tok-number">792</span>,</span>
<span class="line" id="L1052">    <span class="tok-comment">/// The volume repair was not successful.</span></span>
<span class="line" id="L1053">    DISK_REPAIR_UNSUCCESSFUL = <span class="tok-number">793</span>,</span>
<span class="line" id="L1054">    <span class="tok-comment">/// One of the volume corruption logs is full.</span></span>
<span class="line" id="L1055">    <span class="tok-comment">/// Further corruptions that may be detected won't be logged.</span></span>
<span class="line" id="L1056">    CORRUPT_LOG_OVERFULL = <span class="tok-number">794</span>,</span>
<span class="line" id="L1057">    <span class="tok-comment">/// One of the volume corruption logs is internally corrupted and needs to be recreated.</span></span>
<span class="line" id="L1058">    <span class="tok-comment">/// The volume may contain undetected corruptions and must be scanned.</span></span>
<span class="line" id="L1059">    CORRUPT_LOG_CORRUPTED = <span class="tok-number">795</span>,</span>
<span class="line" id="L1060">    <span class="tok-comment">/// One of the volume corruption logs is unavailable for being operated on.</span></span>
<span class="line" id="L1061">    CORRUPT_LOG_UNAVAILABLE = <span class="tok-number">796</span>,</span>
<span class="line" id="L1062">    <span class="tok-comment">/// One of the volume corruption logs was deleted while still having corruption records in them.</span></span>
<span class="line" id="L1063">    <span class="tok-comment">/// The volume contains detected corruptions and must be scanned.</span></span>
<span class="line" id="L1064">    CORRUPT_LOG_DELETED_FULL = <span class="tok-number">797</span>,</span>
<span class="line" id="L1065">    <span class="tok-comment">/// One of the volume corruption logs was cleared by chkdsk and no longer contains real corruptions.</span></span>
<span class="line" id="L1066">    CORRUPT_LOG_CLEARED = <span class="tok-number">798</span>,</span>
<span class="line" id="L1067">    <span class="tok-comment">/// Orphaned files exist on the volume but could not be recovered because no more new names could be created in the recovery directory. Files must be moved from the recovery directory.</span></span>
<span class="line" id="L1068">    ORPHAN_NAME_EXHAUSTED = <span class="tok-number">799</span>,</span>
<span class="line" id="L1069">    <span class="tok-comment">/// The oplock that was associated with this handle is now associated with a different handle.</span></span>
<span class="line" id="L1070">    OPLOCK_SWITCHED_TO_NEW_HANDLE = <span class="tok-number">800</span>,</span>
<span class="line" id="L1071">    <span class="tok-comment">/// An oplock of the requested level cannot be granted. An oplock of a lower level may be available.</span></span>
<span class="line" id="L1072">    CANNOT_GRANT_REQUESTED_OPLOCK = <span class="tok-number">801</span>,</span>
<span class="line" id="L1073">    <span class="tok-comment">/// The operation did not complete successfully because it would cause an oplock to be broken.</span></span>
<span class="line" id="L1074">    <span class="tok-comment">/// The caller has requested that existing oplocks not be broken.</span></span>
<span class="line" id="L1075">    CANNOT_BREAK_OPLOCK = <span class="tok-number">802</span>,</span>
<span class="line" id="L1076">    <span class="tok-comment">/// The handle with which this oplock was associated has been closed. The oplock is now broken.</span></span>
<span class="line" id="L1077">    OPLOCK_HANDLE_CLOSED = <span class="tok-number">803</span>,</span>
<span class="line" id="L1078">    <span class="tok-comment">/// The specified access control entry (ACE) does not contain a condition.</span></span>
<span class="line" id="L1079">    NO_ACE_CONDITION = <span class="tok-number">804</span>,</span>
<span class="line" id="L1080">    <span class="tok-comment">/// The specified access control entry (ACE) contains an invalid condition.</span></span>
<span class="line" id="L1081">    INVALID_ACE_CONDITION = <span class="tok-number">805</span>,</span>
<span class="line" id="L1082">    <span class="tok-comment">/// Access to the specified file handle has been revoked.</span></span>
<span class="line" id="L1083">    FILE_HANDLE_REVOKED = <span class="tok-number">806</span>,</span>
<span class="line" id="L1084">    <span class="tok-comment">/// An image file was mapped at a different address from the one specified in the image file but fixups will still be automatically performed on the image.</span></span>
<span class="line" id="L1085">    IMAGE_AT_DIFFERENT_BASE = <span class="tok-number">807</span>,</span>
<span class="line" id="L1086">    <span class="tok-comment">/// Access to the extended attribute was denied.</span></span>
<span class="line" id="L1087">    EA_ACCESS_DENIED = <span class="tok-number">994</span>,</span>
<span class="line" id="L1088">    <span class="tok-comment">/// The I/O operation has been aborted because of either a thread exit or an application request.</span></span>
<span class="line" id="L1089">    OPERATION_ABORTED = <span class="tok-number">995</span>,</span>
<span class="line" id="L1090">    <span class="tok-comment">/// Overlapped I/O event is not in a signaled state.</span></span>
<span class="line" id="L1091">    IO_INCOMPLETE = <span class="tok-number">996</span>,</span>
<span class="line" id="L1092">    <span class="tok-comment">/// Overlapped I/O operation is in progress.</span></span>
<span class="line" id="L1093">    IO_PENDING = <span class="tok-number">997</span>,</span>
<span class="line" id="L1094">    <span class="tok-comment">/// Invalid access to memory location.</span></span>
<span class="line" id="L1095">    NOACCESS = <span class="tok-number">998</span>,</span>
<span class="line" id="L1096">    <span class="tok-comment">/// Error performing inpage operation.</span></span>
<span class="line" id="L1097">    SWAPERROR = <span class="tok-number">999</span>,</span>
<span class="line" id="L1098">    <span class="tok-comment">/// Recursion too deep; the stack overflowed.</span></span>
<span class="line" id="L1099">    STACK_OVERFLOW = <span class="tok-number">1001</span>,</span>
<span class="line" id="L1100">    <span class="tok-comment">/// The window cannot act on the sent message.</span></span>
<span class="line" id="L1101">    INVALID_MESSAGE = <span class="tok-number">1002</span>,</span>
<span class="line" id="L1102">    <span class="tok-comment">/// Cannot complete this function.</span></span>
<span class="line" id="L1103">    CAN_NOT_COMPLETE = <span class="tok-number">1003</span>,</span>
<span class="line" id="L1104">    <span class="tok-comment">/// Invalid flags.</span></span>
<span class="line" id="L1105">    INVALID_FLAGS = <span class="tok-number">1004</span>,</span>
<span class="line" id="L1106">    <span class="tok-comment">/// The volume does not contain a recognized file system.</span></span>
<span class="line" id="L1107">    <span class="tok-comment">/// Please make sure that all required file system drivers are loaded and that the volume is not corrupted.</span></span>
<span class="line" id="L1108">    UNRECOGNIZED_VOLUME = <span class="tok-number">1005</span>,</span>
<span class="line" id="L1109">    <span class="tok-comment">/// The volume for a file has been externally altered so that the opened file is no longer valid.</span></span>
<span class="line" id="L1110">    FILE_INVALID = <span class="tok-number">1006</span>,</span>
<span class="line" id="L1111">    <span class="tok-comment">/// The requested operation cannot be performed in full-screen mode.</span></span>
<span class="line" id="L1112">    FULLSCREEN_MODE = <span class="tok-number">1007</span>,</span>
<span class="line" id="L1113">    <span class="tok-comment">/// An attempt was made to reference a token that does not exist.</span></span>
<span class="line" id="L1114">    NO_TOKEN = <span class="tok-number">1008</span>,</span>
<span class="line" id="L1115">    <span class="tok-comment">/// The configuration registry database is corrupt.</span></span>
<span class="line" id="L1116">    BADDB = <span class="tok-number">1009</span>,</span>
<span class="line" id="L1117">    <span class="tok-comment">/// The configuration registry key is invalid.</span></span>
<span class="line" id="L1118">    BADKEY = <span class="tok-number">1010</span>,</span>
<span class="line" id="L1119">    <span class="tok-comment">/// The configuration registry key could not be opened.</span></span>
<span class="line" id="L1120">    CANTOPEN = <span class="tok-number">1011</span>,</span>
<span class="line" id="L1121">    <span class="tok-comment">/// The configuration registry key could not be read.</span></span>
<span class="line" id="L1122">    CANTREAD = <span class="tok-number">1012</span>,</span>
<span class="line" id="L1123">    <span class="tok-comment">/// The configuration registry key could not be written.</span></span>
<span class="line" id="L1124">    CANTWRITE = <span class="tok-number">1013</span>,</span>
<span class="line" id="L1125">    <span class="tok-comment">/// One of the files in the registry database had to be recovered by use of a log or alternate copy. The recovery was successful.</span></span>
<span class="line" id="L1126">    REGISTRY_RECOVERED = <span class="tok-number">1014</span>,</span>
<span class="line" id="L1127">    <span class="tok-comment">/// The registry is corrupted. The structure of one of the files containing registry data is corrupted, or the system's memory image of the file is corrupted, or the file could not be recovered because the alternate copy or log was absent or corrupted.</span></span>
<span class="line" id="L1128">    REGISTRY_CORRUPT = <span class="tok-number">1015</span>,</span>
<span class="line" id="L1129">    <span class="tok-comment">/// An I/O operation initiated by the registry failed unrecoverably.</span></span>
<span class="line" id="L1130">    <span class="tok-comment">/// The registry could not read in, or write out, or flush, one of the files that contain the system's image of the registry.</span></span>
<span class="line" id="L1131">    REGISTRY_IO_FAILED = <span class="tok-number">1016</span>,</span>
<span class="line" id="L1132">    <span class="tok-comment">/// The system has attempted to load or restore a file into the registry, but the specified file is not in a registry file format.</span></span>
<span class="line" id="L1133">    NOT_REGISTRY_FILE = <span class="tok-number">1017</span>,</span>
<span class="line" id="L1134">    <span class="tok-comment">/// Illegal operation attempted on a registry key that has been marked for deletion.</span></span>
<span class="line" id="L1135">    KEY_DELETED = <span class="tok-number">1018</span>,</span>
<span class="line" id="L1136">    <span class="tok-comment">/// System could not allocate the required space in a registry log.</span></span>
<span class="line" id="L1137">    NO_LOG_SPACE = <span class="tok-number">1019</span>,</span>
<span class="line" id="L1138">    <span class="tok-comment">/// Cannot create a symbolic link in a registry key that already has subkeys or values.</span></span>
<span class="line" id="L1139">    KEY_HAS_CHILDREN = <span class="tok-number">1020</span>,</span>
<span class="line" id="L1140">    <span class="tok-comment">/// Cannot create a stable subkey under a volatile parent key.</span></span>
<span class="line" id="L1141">    CHILD_MUST_BE_VOLATILE = <span class="tok-number">1021</span>,</span>
<span class="line" id="L1142">    <span class="tok-comment">/// A notify change request is being completed and the information is not being returned in the caller's buffer.</span></span>
<span class="line" id="L1143">    <span class="tok-comment">/// The caller now needs to enumerate the files to find the changes.</span></span>
<span class="line" id="L1144">    NOTIFY_ENUM_DIR = <span class="tok-number">1022</span>,</span>
<span class="line" id="L1145">    <span class="tok-comment">/// A stop control has been sent to a service that other running services are dependent on.</span></span>
<span class="line" id="L1146">    DEPENDENT_SERVICES_RUNNING = <span class="tok-number">1051</span>,</span>
<span class="line" id="L1147">    <span class="tok-comment">/// The requested control is not valid for this service.</span></span>
<span class="line" id="L1148">    INVALID_SERVICE_CONTROL = <span class="tok-number">1052</span>,</span>
<span class="line" id="L1149">    <span class="tok-comment">/// The service did not respond to the start or control request in a timely fashion.</span></span>
<span class="line" id="L1150">    SERVICE_REQUEST_TIMEOUT = <span class="tok-number">1053</span>,</span>
<span class="line" id="L1151">    <span class="tok-comment">/// A thread could not be created for the service.</span></span>
<span class="line" id="L1152">    SERVICE_NO_THREAD = <span class="tok-number">1054</span>,</span>
<span class="line" id="L1153">    <span class="tok-comment">/// The service database is locked.</span></span>
<span class="line" id="L1154">    SERVICE_DATABASE_LOCKED = <span class="tok-number">1055</span>,</span>
<span class="line" id="L1155">    <span class="tok-comment">/// An instance of the service is already running.</span></span>
<span class="line" id="L1156">    SERVICE_ALREADY_RUNNING = <span class="tok-number">1056</span>,</span>
<span class="line" id="L1157">    <span class="tok-comment">/// The account name is invalid or does not exist, or the password is invalid for the account name specified.</span></span>
<span class="line" id="L1158">    INVALID_SERVICE_ACCOUNT = <span class="tok-number">1057</span>,</span>
<span class="line" id="L1159">    <span class="tok-comment">/// The service cannot be started, either because it is disabled or because it has no enabled devices associated with it.</span></span>
<span class="line" id="L1160">    SERVICE_DISABLED = <span class="tok-number">1058</span>,</span>
<span class="line" id="L1161">    <span class="tok-comment">/// Circular service dependency was specified.</span></span>
<span class="line" id="L1162">    CIRCULAR_DEPENDENCY = <span class="tok-number">1059</span>,</span>
<span class="line" id="L1163">    <span class="tok-comment">/// The specified service does not exist as an installed service.</span></span>
<span class="line" id="L1164">    SERVICE_DOES_NOT_EXIST = <span class="tok-number">1060</span>,</span>
<span class="line" id="L1165">    <span class="tok-comment">/// The service cannot accept control messages at this time.</span></span>
<span class="line" id="L1166">    SERVICE_CANNOT_ACCEPT_CTRL = <span class="tok-number">1061</span>,</span>
<span class="line" id="L1167">    <span class="tok-comment">/// The service has not been started.</span></span>
<span class="line" id="L1168">    SERVICE_NOT_ACTIVE = <span class="tok-number">1062</span>,</span>
<span class="line" id="L1169">    <span class="tok-comment">/// The service process could not connect to the service controller.</span></span>
<span class="line" id="L1170">    FAILED_SERVICE_CONTROLLER_CONNECT = <span class="tok-number">1063</span>,</span>
<span class="line" id="L1171">    <span class="tok-comment">/// An exception occurred in the service when handling the control request.</span></span>
<span class="line" id="L1172">    EXCEPTION_IN_SERVICE = <span class="tok-number">1064</span>,</span>
<span class="line" id="L1173">    <span class="tok-comment">/// The database specified does not exist.</span></span>
<span class="line" id="L1174">    DATABASE_DOES_NOT_EXIST = <span class="tok-number">1065</span>,</span>
<span class="line" id="L1175">    <span class="tok-comment">/// The service has returned a service-specific error code.</span></span>
<span class="line" id="L1176">    SERVICE_SPECIFIC_ERROR = <span class="tok-number">1066</span>,</span>
<span class="line" id="L1177">    <span class="tok-comment">/// The process terminated unexpectedly.</span></span>
<span class="line" id="L1178">    PROCESS_ABORTED = <span class="tok-number">1067</span>,</span>
<span class="line" id="L1179">    <span class="tok-comment">/// The dependency service or group failed to start.</span></span>
<span class="line" id="L1180">    SERVICE_DEPENDENCY_FAIL = <span class="tok-number">1068</span>,</span>
<span class="line" id="L1181">    <span class="tok-comment">/// The service did not start due to a logon failure.</span></span>
<span class="line" id="L1182">    SERVICE_LOGON_FAILED = <span class="tok-number">1069</span>,</span>
<span class="line" id="L1183">    <span class="tok-comment">/// After starting, the service hung in a start-pending state.</span></span>
<span class="line" id="L1184">    SERVICE_START_HANG = <span class="tok-number">1070</span>,</span>
<span class="line" id="L1185">    <span class="tok-comment">/// The specified service database lock is invalid.</span></span>
<span class="line" id="L1186">    INVALID_SERVICE_LOCK = <span class="tok-number">1071</span>,</span>
<span class="line" id="L1187">    <span class="tok-comment">/// The specified service has been marked for deletion.</span></span>
<span class="line" id="L1188">    SERVICE_MARKED_FOR_DELETE = <span class="tok-number">1072</span>,</span>
<span class="line" id="L1189">    <span class="tok-comment">/// The specified service already exists.</span></span>
<span class="line" id="L1190">    SERVICE_EXISTS = <span class="tok-number">1073</span>,</span>
<span class="line" id="L1191">    <span class="tok-comment">/// The system is currently running with the last-known-good configuration.</span></span>
<span class="line" id="L1192">    ALREADY_RUNNING_LKG = <span class="tok-number">1074</span>,</span>
<span class="line" id="L1193">    <span class="tok-comment">/// The dependency service does not exist or has been marked for deletion.</span></span>
<span class="line" id="L1194">    SERVICE_DEPENDENCY_DELETED = <span class="tok-number">1075</span>,</span>
<span class="line" id="L1195">    <span class="tok-comment">/// The current boot has already been accepted for use as the last-known-good control set.</span></span>
<span class="line" id="L1196">    BOOT_ALREADY_ACCEPTED = <span class="tok-number">1076</span>,</span>
<span class="line" id="L1197">    <span class="tok-comment">/// No attempts to start the service have been made since the last boot.</span></span>
<span class="line" id="L1198">    SERVICE_NEVER_STARTED = <span class="tok-number">1077</span>,</span>
<span class="line" id="L1199">    <span class="tok-comment">/// The name is already in use as either a service name or a service display name.</span></span>
<span class="line" id="L1200">    DUPLICATE_SERVICE_NAME = <span class="tok-number">1078</span>,</span>
<span class="line" id="L1201">    <span class="tok-comment">/// The account specified for this service is different from the account specified for other services running in the same process.</span></span>
<span class="line" id="L1202">    DIFFERENT_SERVICE_ACCOUNT = <span class="tok-number">1079</span>,</span>
<span class="line" id="L1203">    <span class="tok-comment">/// Failure actions can only be set for Win32 services, not for drivers.</span></span>
<span class="line" id="L1204">    CANNOT_DETECT_DRIVER_FAILURE = <span class="tok-number">1080</span>,</span>
<span class="line" id="L1205">    <span class="tok-comment">/// This service runs in the same process as the service control manager.</span></span>
<span class="line" id="L1206">    <span class="tok-comment">/// Therefore, the service control manager cannot take action if this service's process terminates unexpectedly.</span></span>
<span class="line" id="L1207">    CANNOT_DETECT_PROCESS_ABORT = <span class="tok-number">1081</span>,</span>
<span class="line" id="L1208">    <span class="tok-comment">/// No recovery program has been configured for this service.</span></span>
<span class="line" id="L1209">    NO_RECOVERY_PROGRAM = <span class="tok-number">1082</span>,</span>
<span class="line" id="L1210">    <span class="tok-comment">/// The executable program that this service is configured to run in does not implement the service.</span></span>
<span class="line" id="L1211">    SERVICE_NOT_IN_EXE = <span class="tok-number">1083</span>,</span>
<span class="line" id="L1212">    <span class="tok-comment">/// This service cannot be started in Safe Mode.</span></span>
<span class="line" id="L1213">    NOT_SAFEBOOT_SERVICE = <span class="tok-number">1084</span>,</span>
<span class="line" id="L1214">    <span class="tok-comment">/// The physical end of the tape has been reached.</span></span>
<span class="line" id="L1215">    END_OF_MEDIA = <span class="tok-number">1100</span>,</span>
<span class="line" id="L1216">    <span class="tok-comment">/// A tape access reached a filemark.</span></span>
<span class="line" id="L1217">    FILEMARK_DETECTED = <span class="tok-number">1101</span>,</span>
<span class="line" id="L1218">    <span class="tok-comment">/// The beginning of the tape or a partition was encountered.</span></span>
<span class="line" id="L1219">    BEGINNING_OF_MEDIA = <span class="tok-number">1102</span>,</span>
<span class="line" id="L1220">    <span class="tok-comment">/// A tape access reached the end of a set of files.</span></span>
<span class="line" id="L1221">    SETMARK_DETECTED = <span class="tok-number">1103</span>,</span>
<span class="line" id="L1222">    <span class="tok-comment">/// No more data is on the tape.</span></span>
<span class="line" id="L1223">    NO_DATA_DETECTED = <span class="tok-number">1104</span>,</span>
<span class="line" id="L1224">    <span class="tok-comment">/// Tape could not be partitioned.</span></span>
<span class="line" id="L1225">    PARTITION_FAILURE = <span class="tok-number">1105</span>,</span>
<span class="line" id="L1226">    <span class="tok-comment">/// When accessing a new tape of a multivolume partition, the current block size is incorrect.</span></span>
<span class="line" id="L1227">    INVALID_BLOCK_LENGTH = <span class="tok-number">1106</span>,</span>
<span class="line" id="L1228">    <span class="tok-comment">/// Tape partition information could not be found when loading a tape.</span></span>
<span class="line" id="L1229">    DEVICE_NOT_PARTITIONED = <span class="tok-number">1107</span>,</span>
<span class="line" id="L1230">    <span class="tok-comment">/// Unable to lock the media eject mechanism.</span></span>
<span class="line" id="L1231">    UNABLE_TO_LOCK_MEDIA = <span class="tok-number">1108</span>,</span>
<span class="line" id="L1232">    <span class="tok-comment">/// Unable to unload the media.</span></span>
<span class="line" id="L1233">    UNABLE_TO_UNLOAD_MEDIA = <span class="tok-number">1109</span>,</span>
<span class="line" id="L1234">    <span class="tok-comment">/// The media in the drive may have changed.</span></span>
<span class="line" id="L1235">    MEDIA_CHANGED = <span class="tok-number">1110</span>,</span>
<span class="line" id="L1236">    <span class="tok-comment">/// The I/O bus was reset.</span></span>
<span class="line" id="L1237">    BUS_RESET = <span class="tok-number">1111</span>,</span>
<span class="line" id="L1238">    <span class="tok-comment">/// No media in drive.</span></span>
<span class="line" id="L1239">    NO_MEDIA_IN_DRIVE = <span class="tok-number">1112</span>,</span>
<span class="line" id="L1240">    <span class="tok-comment">/// No mapping for the Unicode character exists in the target multi-byte code page.</span></span>
<span class="line" id="L1241">    NO_UNICODE_TRANSLATION = <span class="tok-number">1113</span>,</span>
<span class="line" id="L1242">    <span class="tok-comment">/// A dynamic link library (DLL) initialization routine failed.</span></span>
<span class="line" id="L1243">    DLL_INIT_FAILED = <span class="tok-number">1114</span>,</span>
<span class="line" id="L1244">    <span class="tok-comment">/// A system shutdown is in progress.</span></span>
<span class="line" id="L1245">    SHUTDOWN_IN_PROGRESS = <span class="tok-number">1115</span>,</span>
<span class="line" id="L1246">    <span class="tok-comment">/// Unable to abort the system shutdown because no shutdown was in progress.</span></span>
<span class="line" id="L1247">    NO_SHUTDOWN_IN_PROGRESS = <span class="tok-number">1116</span>,</span>
<span class="line" id="L1248">    <span class="tok-comment">/// The request could not be performed because of an I/O device error.</span></span>
<span class="line" id="L1249">    IO_DEVICE = <span class="tok-number">1117</span>,</span>
<span class="line" id="L1250">    <span class="tok-comment">/// No serial device was successfully initialized. The serial driver will unload.</span></span>
<span class="line" id="L1251">    SERIAL_NO_DEVICE = <span class="tok-number">1118</span>,</span>
<span class="line" id="L1252">    <span class="tok-comment">/// Unable to open a device that was sharing an interrupt request (IRQ) with other devices.</span></span>
<span class="line" id="L1253">    <span class="tok-comment">/// At least one other device that uses that IRQ was already opened.</span></span>
<span class="line" id="L1254">    IRQ_BUSY = <span class="tok-number">1119</span>,</span>
<span class="line" id="L1255">    <span class="tok-comment">/// A serial I/O operation was completed by another write to the serial port. The IOCTL_SERIAL_XOFF_COUNTER reached zero.)</span></span>
<span class="line" id="L1256">    MORE_WRITES = <span class="tok-number">1120</span>,</span>
<span class="line" id="L1257">    <span class="tok-comment">/// A serial I/O operation completed because the timeout period expired.</span></span>
<span class="line" id="L1258">    <span class="tok-comment">/// The IOCTL_SERIAL_XOFF_COUNTER did not reach zero.)</span></span>
<span class="line" id="L1259">    COUNTER_TIMEOUT = <span class="tok-number">1121</span>,</span>
<span class="line" id="L1260">    <span class="tok-comment">/// No ID address mark was found on the floppy disk.</span></span>
<span class="line" id="L1261">    FLOPPY_ID_MARK_NOT_FOUND = <span class="tok-number">1122</span>,</span>
<span class="line" id="L1262">    <span class="tok-comment">/// Mismatch between the floppy disk sector ID field and the floppy disk controller track address.</span></span>
<span class="line" id="L1263">    FLOPPY_WRONG_CYLINDER = <span class="tok-number">1123</span>,</span>
<span class="line" id="L1264">    <span class="tok-comment">/// The floppy disk controller reported an error that is not recognized by the floppy disk driver.</span></span>
<span class="line" id="L1265">    FLOPPY_UNKNOWN_ERROR = <span class="tok-number">1124</span>,</span>
<span class="line" id="L1266">    <span class="tok-comment">/// The floppy disk controller returned inconsistent results in its registers.</span></span>
<span class="line" id="L1267">    FLOPPY_BAD_REGISTERS = <span class="tok-number">1125</span>,</span>
<span class="line" id="L1268">    <span class="tok-comment">/// While accessing the hard disk, a recalibrate operation failed, even after retries.</span></span>
<span class="line" id="L1269">    DISK_RECALIBRATE_FAILED = <span class="tok-number">1126</span>,</span>
<span class="line" id="L1270">    <span class="tok-comment">/// While accessing the hard disk, a disk operation failed even after retries.</span></span>
<span class="line" id="L1271">    DISK_OPERATION_FAILED = <span class="tok-number">1127</span>,</span>
<span class="line" id="L1272">    <span class="tok-comment">/// While accessing the hard disk, a disk controller reset was needed, but even that failed.</span></span>
<span class="line" id="L1273">    DISK_RESET_FAILED = <span class="tok-number">1128</span>,</span>
<span class="line" id="L1274">    <span class="tok-comment">/// Physical end of tape encountered.</span></span>
<span class="line" id="L1275">    EOM_OVERFLOW = <span class="tok-number">1129</span>,</span>
<span class="line" id="L1276">    <span class="tok-comment">/// Not enough server storage is available to process this command.</span></span>
<span class="line" id="L1277">    NOT_ENOUGH_SERVER_MEMORY = <span class="tok-number">1130</span>,</span>
<span class="line" id="L1278">    <span class="tok-comment">/// A potential deadlock condition has been detected.</span></span>
<span class="line" id="L1279">    POSSIBLE_DEADLOCK = <span class="tok-number">1131</span>,</span>
<span class="line" id="L1280">    <span class="tok-comment">/// The base address or the file offset specified does not have the proper alignment.</span></span>
<span class="line" id="L1281">    MAPPED_ALIGNMENT = <span class="tok-number">1132</span>,</span>
<span class="line" id="L1282">    <span class="tok-comment">/// An attempt to change the system power state was vetoed by another application or driver.</span></span>
<span class="line" id="L1283">    SET_POWER_STATE_VETOED = <span class="tok-number">1140</span>,</span>
<span class="line" id="L1284">    <span class="tok-comment">/// The system BIOS failed an attempt to change the system power state.</span></span>
<span class="line" id="L1285">    SET_POWER_STATE_FAILED = <span class="tok-number">1141</span>,</span>
<span class="line" id="L1286">    <span class="tok-comment">/// An attempt was made to create more links on a file than the file system supports.</span></span>
<span class="line" id="L1287">    TOO_MANY_LINKS = <span class="tok-number">1142</span>,</span>
<span class="line" id="L1288">    <span class="tok-comment">/// The specified program requires a newer version of Windows.</span></span>
<span class="line" id="L1289">    OLD_WIN_VERSION = <span class="tok-number">1150</span>,</span>
<span class="line" id="L1290">    <span class="tok-comment">/// The specified program is not a Windows or MS-DOS program.</span></span>
<span class="line" id="L1291">    APP_WRONG_OS = <span class="tok-number">1151</span>,</span>
<span class="line" id="L1292">    <span class="tok-comment">/// Cannot start more than one instance of the specified program.</span></span>
<span class="line" id="L1293">    SINGLE_INSTANCE_APP = <span class="tok-number">1152</span>,</span>
<span class="line" id="L1294">    <span class="tok-comment">/// The specified program was written for an earlier version of Windows.</span></span>
<span class="line" id="L1295">    RMODE_APP = <span class="tok-number">1153</span>,</span>
<span class="line" id="L1296">    <span class="tok-comment">/// One of the library files needed to run this application is damaged.</span></span>
<span class="line" id="L1297">    INVALID_DLL = <span class="tok-number">1154</span>,</span>
<span class="line" id="L1298">    <span class="tok-comment">/// No application is associated with the specified file for this operation.</span></span>
<span class="line" id="L1299">    NO_ASSOCIATION = <span class="tok-number">1155</span>,</span>
<span class="line" id="L1300">    <span class="tok-comment">/// An error occurred in sending the command to the application.</span></span>
<span class="line" id="L1301">    DDE_FAIL = <span class="tok-number">1156</span>,</span>
<span class="line" id="L1302">    <span class="tok-comment">/// One of the library files needed to run this application cannot be found.</span></span>
<span class="line" id="L1303">    DLL_NOT_FOUND = <span class="tok-number">1157</span>,</span>
<span class="line" id="L1304">    <span class="tok-comment">/// The current process has used all of its system allowance of handles for Window Manager objects.</span></span>
<span class="line" id="L1305">    NO_MORE_USER_HANDLES = <span class="tok-number">1158</span>,</span>
<span class="line" id="L1306">    <span class="tok-comment">/// The message can be used only with synchronous operations.</span></span>
<span class="line" id="L1307">    MESSAGE_SYNC_ONLY = <span class="tok-number">1159</span>,</span>
<span class="line" id="L1308">    <span class="tok-comment">/// The indicated source element has no media.</span></span>
<span class="line" id="L1309">    SOURCE_ELEMENT_EMPTY = <span class="tok-number">1160</span>,</span>
<span class="line" id="L1310">    <span class="tok-comment">/// The indicated destination element already contains media.</span></span>
<span class="line" id="L1311">    DESTINATION_ELEMENT_FULL = <span class="tok-number">1161</span>,</span>
<span class="line" id="L1312">    <span class="tok-comment">/// The indicated element does not exist.</span></span>
<span class="line" id="L1313">    ILLEGAL_ELEMENT_ADDRESS = <span class="tok-number">1162</span>,</span>
<span class="line" id="L1314">    <span class="tok-comment">/// The indicated element is part of a magazine that is not present.</span></span>
<span class="line" id="L1315">    MAGAZINE_NOT_PRESENT = <span class="tok-number">1163</span>,</span>
<span class="line" id="L1316">    <span class="tok-comment">/// The indicated device requires reinitialization due to hardware errors.</span></span>
<span class="line" id="L1317">    DEVICE_REINITIALIZATION_NEEDED = <span class="tok-number">1164</span>,</span>
<span class="line" id="L1318">    <span class="tok-comment">/// The device has indicated that cleaning is required before further operations are attempted.</span></span>
<span class="line" id="L1319">    DEVICE_REQUIRES_CLEANING = <span class="tok-number">1165</span>,</span>
<span class="line" id="L1320">    <span class="tok-comment">/// The device has indicated that its door is open.</span></span>
<span class="line" id="L1321">    DEVICE_DOOR_OPEN = <span class="tok-number">1166</span>,</span>
<span class="line" id="L1322">    <span class="tok-comment">/// The device is not connected.</span></span>
<span class="line" id="L1323">    DEVICE_NOT_CONNECTED = <span class="tok-number">1167</span>,</span>
<span class="line" id="L1324">    <span class="tok-comment">/// Element not found.</span></span>
<span class="line" id="L1325">    NOT_FOUND = <span class="tok-number">1168</span>,</span>
<span class="line" id="L1326">    <span class="tok-comment">/// There was no match for the specified key in the index.</span></span>
<span class="line" id="L1327">    NO_MATCH = <span class="tok-number">1169</span>,</span>
<span class="line" id="L1328">    <span class="tok-comment">/// The property set specified does not exist on the object.</span></span>
<span class="line" id="L1329">    SET_NOT_FOUND = <span class="tok-number">1170</span>,</span>
<span class="line" id="L1330">    <span class="tok-comment">/// The point passed to GetMouseMovePoints is not in the buffer.</span></span>
<span class="line" id="L1331">    POINT_NOT_FOUND = <span class="tok-number">1171</span>,</span>
<span class="line" id="L1332">    <span class="tok-comment">/// The tracking (workstation) service is not running.</span></span>
<span class="line" id="L1333">    NO_TRACKING_SERVICE = <span class="tok-number">1172</span>,</span>
<span class="line" id="L1334">    <span class="tok-comment">/// The Volume ID could not be found.</span></span>
<span class="line" id="L1335">    NO_VOLUME_ID = <span class="tok-number">1173</span>,</span>
<span class="line" id="L1336">    <span class="tok-comment">/// Unable to remove the file to be replaced.</span></span>
<span class="line" id="L1337">    UNABLE_TO_REMOVE_REPLACED = <span class="tok-number">1175</span>,</span>
<span class="line" id="L1338">    <span class="tok-comment">/// Unable to move the replacement file to the file to be replaced.</span></span>
<span class="line" id="L1339">    <span class="tok-comment">/// The file to be replaced has retained its original name.</span></span>
<span class="line" id="L1340">    UNABLE_TO_MOVE_REPLACEMENT = <span class="tok-number">1176</span>,</span>
<span class="line" id="L1341">    <span class="tok-comment">/// Unable to move the replacement file to the file to be replaced.</span></span>
<span class="line" id="L1342">    <span class="tok-comment">/// The file to be replaced has been renamed using the backup name.</span></span>
<span class="line" id="L1343">    UNABLE_TO_MOVE_REPLACEMENT_2 = <span class="tok-number">1177</span>,</span>
<span class="line" id="L1344">    <span class="tok-comment">/// The volume change journal is being deleted.</span></span>
<span class="line" id="L1345">    JOURNAL_DELETE_IN_PROGRESS = <span class="tok-number">1178</span>,</span>
<span class="line" id="L1346">    <span class="tok-comment">/// The volume change journal is not active.</span></span>
<span class="line" id="L1347">    JOURNAL_NOT_ACTIVE = <span class="tok-number">1179</span>,</span>
<span class="line" id="L1348">    <span class="tok-comment">/// A file was found, but it may not be the correct file.</span></span>
<span class="line" id="L1349">    POTENTIAL_FILE_FOUND = <span class="tok-number">1180</span>,</span>
<span class="line" id="L1350">    <span class="tok-comment">/// The journal entry has been deleted from the journal.</span></span>
<span class="line" id="L1351">    JOURNAL_ENTRY_DELETED = <span class="tok-number">1181</span>,</span>
<span class="line" id="L1352">    <span class="tok-comment">/// A system shutdown has already been scheduled.</span></span>
<span class="line" id="L1353">    SHUTDOWN_IS_SCHEDULED = <span class="tok-number">1190</span>,</span>
<span class="line" id="L1354">    <span class="tok-comment">/// The system shutdown cannot be initiated because there are other users logged on to the computer.</span></span>
<span class="line" id="L1355">    SHUTDOWN_USERS_LOGGED_ON = <span class="tok-number">1191</span>,</span>
<span class="line" id="L1356">    <span class="tok-comment">/// The specified device name is invalid.</span></span>
<span class="line" id="L1357">    BAD_DEVICE = <span class="tok-number">1200</span>,</span>
<span class="line" id="L1358">    <span class="tok-comment">/// The device is not currently connected but it is a remembered connection.</span></span>
<span class="line" id="L1359">    CONNECTION_UNAVAIL = <span class="tok-number">1201</span>,</span>
<span class="line" id="L1360">    <span class="tok-comment">/// The local device name has a remembered connection to another network resource.</span></span>
<span class="line" id="L1361">    DEVICE_ALREADY_REMEMBERED = <span class="tok-number">1202</span>,</span>
<span class="line" id="L1362">    <span class="tok-comment">/// The network path was either typed incorrectly, does not exist, or the network provider is not currently available.</span></span>
<span class="line" id="L1363">    <span class="tok-comment">/// Please try retyping the path or contact your network administrator.</span></span>
<span class="line" id="L1364">    NO_NET_OR_BAD_PATH = <span class="tok-number">1203</span>,</span>
<span class="line" id="L1365">    <span class="tok-comment">/// The specified network provider name is invalid.</span></span>
<span class="line" id="L1366">    BAD_PROVIDER = <span class="tok-number">1204</span>,</span>
<span class="line" id="L1367">    <span class="tok-comment">/// Unable to open the network connection profile.</span></span>
<span class="line" id="L1368">    CANNOT_OPEN_PROFILE = <span class="tok-number">1205</span>,</span>
<span class="line" id="L1369">    <span class="tok-comment">/// The network connection profile is corrupted.</span></span>
<span class="line" id="L1370">    BAD_PROFILE = <span class="tok-number">1206</span>,</span>
<span class="line" id="L1371">    <span class="tok-comment">/// Cannot enumerate a noncontainer.</span></span>
<span class="line" id="L1372">    NOT_CONTAINER = <span class="tok-number">1207</span>,</span>
<span class="line" id="L1373">    <span class="tok-comment">/// An extended error has occurred.</span></span>
<span class="line" id="L1374">    EXTENDED_ERROR = <span class="tok-number">1208</span>,</span>
<span class="line" id="L1375">    <span class="tok-comment">/// The format of the specified group name is invalid.</span></span>
<span class="line" id="L1376">    INVALID_GROUPNAME = <span class="tok-number">1209</span>,</span>
<span class="line" id="L1377">    <span class="tok-comment">/// The format of the specified computer name is invalid.</span></span>
<span class="line" id="L1378">    INVALID_COMPUTERNAME = <span class="tok-number">1210</span>,</span>
<span class="line" id="L1379">    <span class="tok-comment">/// The format of the specified event name is invalid.</span></span>
<span class="line" id="L1380">    INVALID_EVENTNAME = <span class="tok-number">1211</span>,</span>
<span class="line" id="L1381">    <span class="tok-comment">/// The format of the specified domain name is invalid.</span></span>
<span class="line" id="L1382">    INVALID_DOMAINNAME = <span class="tok-number">1212</span>,</span>
<span class="line" id="L1383">    <span class="tok-comment">/// The format of the specified service name is invalid.</span></span>
<span class="line" id="L1384">    INVALID_SERVICENAME = <span class="tok-number">1213</span>,</span>
<span class="line" id="L1385">    <span class="tok-comment">/// The format of the specified network name is invalid.</span></span>
<span class="line" id="L1386">    INVALID_NETNAME = <span class="tok-number">1214</span>,</span>
<span class="line" id="L1387">    <span class="tok-comment">/// The format of the specified share name is invalid.</span></span>
<span class="line" id="L1388">    INVALID_SHARENAME = <span class="tok-number">1215</span>,</span>
<span class="line" id="L1389">    <span class="tok-comment">/// The format of the specified password is invalid.</span></span>
<span class="line" id="L1390">    INVALID_PASSWORDNAME = <span class="tok-number">1216</span>,</span>
<span class="line" id="L1391">    <span class="tok-comment">/// The format of the specified message name is invalid.</span></span>
<span class="line" id="L1392">    INVALID_MESSAGENAME = <span class="tok-number">1217</span>,</span>
<span class="line" id="L1393">    <span class="tok-comment">/// The format of the specified message destination is invalid.</span></span>
<span class="line" id="L1394">    INVALID_MESSAGEDEST = <span class="tok-number">1218</span>,</span>
<span class="line" id="L1395">    <span class="tok-comment">/// Multiple connections to a server or shared resource by the same user, using more than one user name, are not allowed.</span></span>
<span class="line" id="L1396">    <span class="tok-comment">/// Disconnect all previous connections to the server or shared resource and try again.</span></span>
<span class="line" id="L1397">    SESSION_CREDENTIAL_CONFLICT = <span class="tok-number">1219</span>,</span>
<span class="line" id="L1398">    <span class="tok-comment">/// An attempt was made to establish a session to a network server, but there are already too many sessions established to that server.</span></span>
<span class="line" id="L1399">    REMOTE_SESSION_LIMIT_EXCEEDED = <span class="tok-number">1220</span>,</span>
<span class="line" id="L1400">    <span class="tok-comment">/// The workgroup or domain name is already in use by another computer on the network.</span></span>
<span class="line" id="L1401">    DUP_DOMAINNAME = <span class="tok-number">1221</span>,</span>
<span class="line" id="L1402">    <span class="tok-comment">/// The network is not present or not started.</span></span>
<span class="line" id="L1403">    NO_NETWORK = <span class="tok-number">1222</span>,</span>
<span class="line" id="L1404">    <span class="tok-comment">/// The operation was canceled by the user.</span></span>
<span class="line" id="L1405">    CANCELLED = <span class="tok-number">1223</span>,</span>
<span class="line" id="L1406">    <span class="tok-comment">/// The requested operation cannot be performed on a file with a user-mapped section open.</span></span>
<span class="line" id="L1407">    USER_MAPPED_FILE = <span class="tok-number">1224</span>,</span>
<span class="line" id="L1408">    <span class="tok-comment">/// The remote computer refused the network connection.</span></span>
<span class="line" id="L1409">    CONNECTION_REFUSED = <span class="tok-number">1225</span>,</span>
<span class="line" id="L1410">    <span class="tok-comment">/// The network connection was gracefully closed.</span></span>
<span class="line" id="L1411">    GRACEFUL_DISCONNECT = <span class="tok-number">1226</span>,</span>
<span class="line" id="L1412">    <span class="tok-comment">/// The network transport endpoint already has an address associated with it.</span></span>
<span class="line" id="L1413">    ADDRESS_ALREADY_ASSOCIATED = <span class="tok-number">1227</span>,</span>
<span class="line" id="L1414">    <span class="tok-comment">/// An address has not yet been associated with the network endpoint.</span></span>
<span class="line" id="L1415">    ADDRESS_NOT_ASSOCIATED = <span class="tok-number">1228</span>,</span>
<span class="line" id="L1416">    <span class="tok-comment">/// An operation was attempted on a nonexistent network connection.</span></span>
<span class="line" id="L1417">    CONNECTION_INVALID = <span class="tok-number">1229</span>,</span>
<span class="line" id="L1418">    <span class="tok-comment">/// An invalid operation was attempted on an active network connection.</span></span>
<span class="line" id="L1419">    CONNECTION_ACTIVE = <span class="tok-number">1230</span>,</span>
<span class="line" id="L1420">    <span class="tok-comment">/// The network location cannot be reached.</span></span>
<span class="line" id="L1421">    <span class="tok-comment">/// For information about network troubleshooting, see Windows Help.</span></span>
<span class="line" id="L1422">    NETWORK_UNREACHABLE = <span class="tok-number">1231</span>,</span>
<span class="line" id="L1423">    <span class="tok-comment">/// The network location cannot be reached.</span></span>
<span class="line" id="L1424">    <span class="tok-comment">/// For information about network troubleshooting, see Windows Help.</span></span>
<span class="line" id="L1425">    HOST_UNREACHABLE = <span class="tok-number">1232</span>,</span>
<span class="line" id="L1426">    <span class="tok-comment">/// The network location cannot be reached.</span></span>
<span class="line" id="L1427">    <span class="tok-comment">/// For information about network troubleshooting, see Windows Help.</span></span>
<span class="line" id="L1428">    PROTOCOL_UNREACHABLE = <span class="tok-number">1233</span>,</span>
<span class="line" id="L1429">    <span class="tok-comment">/// No service is operating at the destination network endpoint on the remote system.</span></span>
<span class="line" id="L1430">    PORT_UNREACHABLE = <span class="tok-number">1234</span>,</span>
<span class="line" id="L1431">    <span class="tok-comment">/// The request was aborted.</span></span>
<span class="line" id="L1432">    REQUEST_ABORTED = <span class="tok-number">1235</span>,</span>
<span class="line" id="L1433">    <span class="tok-comment">/// The network connection was aborted by the local system.</span></span>
<span class="line" id="L1434">    CONNECTION_ABORTED = <span class="tok-number">1236</span>,</span>
<span class="line" id="L1435">    <span class="tok-comment">/// The operation could not be completed. A retry should be performed.</span></span>
<span class="line" id="L1436">    RETRY = <span class="tok-number">1237</span>,</span>
<span class="line" id="L1437">    <span class="tok-comment">/// A connection to the server could not be made because the limit on the number of concurrent connections for this account has been reached.</span></span>
<span class="line" id="L1438">    CONNECTION_COUNT_LIMIT = <span class="tok-number">1238</span>,</span>
<span class="line" id="L1439">    <span class="tok-comment">/// Attempting to log in during an unauthorized time of day for this account.</span></span>
<span class="line" id="L1440">    LOGIN_TIME_RESTRICTION = <span class="tok-number">1239</span>,</span>
<span class="line" id="L1441">    <span class="tok-comment">/// The account is not authorized to log in from this station.</span></span>
<span class="line" id="L1442">    LOGIN_WKSTA_RESTRICTION = <span class="tok-number">1240</span>,</span>
<span class="line" id="L1443">    <span class="tok-comment">/// The network address could not be used for the operation requested.</span></span>
<span class="line" id="L1444">    INCORRECT_ADDRESS = <span class="tok-number">1241</span>,</span>
<span class="line" id="L1445">    <span class="tok-comment">/// The service is already registered.</span></span>
<span class="line" id="L1446">    ALREADY_REGISTERED = <span class="tok-number">1242</span>,</span>
<span class="line" id="L1447">    <span class="tok-comment">/// The specified service does not exist.</span></span>
<span class="line" id="L1448">    SERVICE_NOT_FOUND = <span class="tok-number">1243</span>,</span>
<span class="line" id="L1449">    <span class="tok-comment">/// The operation being requested was not performed because the user has not been authenticated.</span></span>
<span class="line" id="L1450">    NOT_AUTHENTICATED = <span class="tok-number">1244</span>,</span>
<span class="line" id="L1451">    <span class="tok-comment">/// The operation being requested was not performed because the user has not logged on to the network. The specified service does not exist.</span></span>
<span class="line" id="L1452">    NOT_LOGGED_ON = <span class="tok-number">1245</span>,</span>
<span class="line" id="L1453">    <span class="tok-comment">/// Continue with work in progress.</span></span>
<span class="line" id="L1454">    CONTINUE = <span class="tok-number">1246</span>,</span>
<span class="line" id="L1455">    <span class="tok-comment">/// An attempt was made to perform an initialization operation when initialization has already been completed.</span></span>
<span class="line" id="L1456">    ALREADY_INITIALIZED = <span class="tok-number">1247</span>,</span>
<span class="line" id="L1457">    <span class="tok-comment">/// No more local devices.</span></span>
<span class="line" id="L1458">    NO_MORE_DEVICES = <span class="tok-number">1248</span>,</span>
<span class="line" id="L1459">    <span class="tok-comment">/// The specified site does not exist.</span></span>
<span class="line" id="L1460">    NO_SUCH_SITE = <span class="tok-number">1249</span>,</span>
<span class="line" id="L1461">    <span class="tok-comment">/// A domain controller with the specified name already exists.</span></span>
<span class="line" id="L1462">    DOMAIN_CONTROLLER_EXISTS = <span class="tok-number">1250</span>,</span>
<span class="line" id="L1463">    <span class="tok-comment">/// This operation is supported only when you are connected to the server.</span></span>
<span class="line" id="L1464">    ONLY_IF_CONNECTED = <span class="tok-number">1251</span>,</span>
<span class="line" id="L1465">    <span class="tok-comment">/// The group policy framework should call the extension even if there are no changes.</span></span>
<span class="line" id="L1466">    OVERRIDE_NOCHANGES = <span class="tok-number">1252</span>,</span>
<span class="line" id="L1467">    <span class="tok-comment">/// The specified user does not have a valid profile.</span></span>
<span class="line" id="L1468">    BAD_USER_PROFILE = <span class="tok-number">1253</span>,</span>
<span class="line" id="L1469">    <span class="tok-comment">/// This operation is not supported on a computer running Windows Server 2003 for Small Business Server.</span></span>
<span class="line" id="L1470">    NOT_SUPPORTED_ON_SBS = <span class="tok-number">1254</span>,</span>
<span class="line" id="L1471">    <span class="tok-comment">/// The server machine is shutting down.</span></span>
<span class="line" id="L1472">    SERVER_SHUTDOWN_IN_PROGRESS = <span class="tok-number">1255</span>,</span>
<span class="line" id="L1473">    <span class="tok-comment">/// The remote system is not available.</span></span>
<span class="line" id="L1474">    <span class="tok-comment">/// For information about network troubleshooting, see Windows Help.</span></span>
<span class="line" id="L1475">    HOST_DOWN = <span class="tok-number">1256</span>,</span>
<span class="line" id="L1476">    <span class="tok-comment">/// The security identifier provided is not from an account domain.</span></span>
<span class="line" id="L1477">    NON_ACCOUNT_SID = <span class="tok-number">1257</span>,</span>
<span class="line" id="L1478">    <span class="tok-comment">/// The security identifier provided does not have a domain component.</span></span>
<span class="line" id="L1479">    NON_DOMAIN_SID = <span class="tok-number">1258</span>,</span>
<span class="line" id="L1480">    <span class="tok-comment">/// AppHelp dialog canceled thus preventing the application from starting.</span></span>
<span class="line" id="L1481">    APPHELP_BLOCK = <span class="tok-number">1259</span>,</span>
<span class="line" id="L1482">    <span class="tok-comment">/// This program is blocked by group policy.</span></span>
<span class="line" id="L1483">    <span class="tok-comment">/// For more information, contact your system administrator.</span></span>
<span class="line" id="L1484">    ACCESS_DISABLED_BY_POLICY = <span class="tok-number">1260</span>,</span>
<span class="line" id="L1485">    <span class="tok-comment">/// A program attempt to use an invalid register value.</span></span>
<span class="line" id="L1486">    <span class="tok-comment">/// Normally caused by an uninitialized register. This error is Itanium specific.</span></span>
<span class="line" id="L1487">    REG_NAT_CONSUMPTION = <span class="tok-number">1261</span>,</span>
<span class="line" id="L1488">    <span class="tok-comment">/// The share is currently offline or does not exist.</span></span>
<span class="line" id="L1489">    CSCSHARE_OFFLINE = <span class="tok-number">1262</span>,</span>
<span class="line" id="L1490">    <span class="tok-comment">/// The Kerberos protocol encountered an error while validating the KDC certificate during smartcard logon.</span></span>
<span class="line" id="L1491">    <span class="tok-comment">/// There is more information in the system event log.</span></span>
<span class="line" id="L1492">    PKINIT_FAILURE = <span class="tok-number">1263</span>,</span>
<span class="line" id="L1493">    <span class="tok-comment">/// The Kerberos protocol encountered an error while attempting to utilize the smartcard subsystem.</span></span>
<span class="line" id="L1494">    SMARTCARD_SUBSYSTEM_FAILURE = <span class="tok-number">1264</span>,</span>
<span class="line" id="L1495">    <span class="tok-comment">/// The system cannot contact a domain controller to service the authentication request. Please try again later.</span></span>
<span class="line" id="L1496">    DOWNGRADE_DETECTED = <span class="tok-number">1265</span>,</span>
<span class="line" id="L1497">    <span class="tok-comment">/// The machine is locked and cannot be shut down without the force option.</span></span>
<span class="line" id="L1498">    MACHINE_LOCKED = <span class="tok-number">1271</span>,</span>
<span class="line" id="L1499">    <span class="tok-comment">/// An application-defined callback gave invalid data when called.</span></span>
<span class="line" id="L1500">    CALLBACK_SUPPLIED_INVALID_DATA = <span class="tok-number">1273</span>,</span>
<span class="line" id="L1501">    <span class="tok-comment">/// The group policy framework should call the extension in the synchronous foreground policy refresh.</span></span>
<span class="line" id="L1502">    SYNC_FOREGROUND_REFRESH_REQUIRED = <span class="tok-number">1274</span>,</span>
<span class="line" id="L1503">    <span class="tok-comment">/// This driver has been blocked from loading.</span></span>
<span class="line" id="L1504">    DRIVER_BLOCKED = <span class="tok-number">1275</span>,</span>
<span class="line" id="L1505">    <span class="tok-comment">/// A dynamic link library (DLL) referenced a module that was neither a DLL nor the process's executable image.</span></span>
<span class="line" id="L1506">    INVALID_IMPORT_OF_NON_DLL = <span class="tok-number">1276</span>,</span>
<span class="line" id="L1507">    <span class="tok-comment">/// Windows cannot open this program since it has been disabled.</span></span>
<span class="line" id="L1508">    ACCESS_DISABLED_WEBBLADE = <span class="tok-number">1277</span>,</span>
<span class="line" id="L1509">    <span class="tok-comment">/// Windows cannot open this program because the license enforcement system has been tampered with or become corrupted.</span></span>
<span class="line" id="L1510">    ACCESS_DISABLED_WEBBLADE_TAMPER = <span class="tok-number">1278</span>,</span>
<span class="line" id="L1511">    <span class="tok-comment">/// A transaction recover failed.</span></span>
<span class="line" id="L1512">    RECOVERY_FAILURE = <span class="tok-number">1279</span>,</span>
<span class="line" id="L1513">    <span class="tok-comment">/// The current thread has already been converted to a fiber.</span></span>
<span class="line" id="L1514">    ALREADY_FIBER = <span class="tok-number">1280</span>,</span>
<span class="line" id="L1515">    <span class="tok-comment">/// The current thread has already been converted from a fiber.</span></span>
<span class="line" id="L1516">    ALREADY_THREAD = <span class="tok-number">1281</span>,</span>
<span class="line" id="L1517">    <span class="tok-comment">/// The system detected an overrun of a stack-based buffer in this application.</span></span>
<span class="line" id="L1518">    <span class="tok-comment">/// This overrun could potentially allow a malicious user to gain control of this application.</span></span>
<span class="line" id="L1519">    STACK_BUFFER_OVERRUN = <span class="tok-number">1282</span>,</span>
<span class="line" id="L1520">    <span class="tok-comment">/// Data present in one of the parameters is more than the function can operate on.</span></span>
<span class="line" id="L1521">    PARAMETER_QUOTA_EXCEEDED = <span class="tok-number">1283</span>,</span>
<span class="line" id="L1522">    <span class="tok-comment">/// An attempt to do an operation on a debug object failed because the object is in the process of being deleted.</span></span>
<span class="line" id="L1523">    DEBUGGER_INACTIVE = <span class="tok-number">1284</span>,</span>
<span class="line" id="L1524">    <span class="tok-comment">/// An attempt to delay-load a .dll or get a function address in a delay-loaded .dll failed.</span></span>
<span class="line" id="L1525">    DELAY_LOAD_FAILED = <span class="tok-number">1285</span>,</span>
<span class="line" id="L1526">    <span class="tok-comment">/// %1 is a 16-bit application. You do not have permissions to execute 16-bit applications.</span></span>
<span class="line" id="L1527">    <span class="tok-comment">/// Check your permissions with your system administrator.</span></span>
<span class="line" id="L1528">    VDM_DISALLOWED = <span class="tok-number">1286</span>,</span>
<span class="line" id="L1529">    <span class="tok-comment">/// Insufficient information exists to identify the cause of failure.</span></span>
<span class="line" id="L1530">    UNIDENTIFIED_ERROR = <span class="tok-number">1287</span>,</span>
<span class="line" id="L1531">    <span class="tok-comment">/// The parameter passed to a C runtime function is incorrect.</span></span>
<span class="line" id="L1532">    INVALID_CRUNTIME_PARAMETER = <span class="tok-number">1288</span>,</span>
<span class="line" id="L1533">    <span class="tok-comment">/// The operation occurred beyond the valid data length of the file.</span></span>
<span class="line" id="L1534">    BEYOND_VDL = <span class="tok-number">1289</span>,</span>
<span class="line" id="L1535">    <span class="tok-comment">/// The service start failed since one or more services in the same process have an incompatible service SID type setting.</span></span>
<span class="line" id="L1536">    <span class="tok-comment">/// A service with restricted service SID type can only coexist in the same process with other services with a restricted SID type.</span></span>
<span class="line" id="L1537">    <span class="tok-comment">/// If the service SID type for this service was just configured, the hosting process must be restarted in order to start this service.</span></span>
<span class="line" id="L1538">    <span class="tok-comment">/// On Windows Server 2003 and Windows XP, an unrestricted service cannot coexist in the same process with other services.</span></span>
<span class="line" id="L1539">    <span class="tok-comment">/// The service with the unrestricted service SID type must be moved to an owned process in order to start this service.</span></span>
<span class="line" id="L1540">    INCOMPATIBLE_SERVICE_SID_TYPE = <span class="tok-number">1290</span>,</span>
<span class="line" id="L1541">    <span class="tok-comment">/// The process hosting the driver for this device has been terminated.</span></span>
<span class="line" id="L1542">    DRIVER_PROCESS_TERMINATED = <span class="tok-number">1291</span>,</span>
<span class="line" id="L1543">    <span class="tok-comment">/// An operation attempted to exceed an implementation-defined limit.</span></span>
<span class="line" id="L1544">    IMPLEMENTATION_LIMIT = <span class="tok-number">1292</span>,</span>
<span class="line" id="L1545">    <span class="tok-comment">/// Either the target process, or the target thread's containing process, is a protected process.</span></span>
<span class="line" id="L1546">    PROCESS_IS_PROTECTED = <span class="tok-number">1293</span>,</span>
<span class="line" id="L1547">    <span class="tok-comment">/// The service notification client is lagging too far behind the current state of services in the machine.</span></span>
<span class="line" id="L1548">    SERVICE_NOTIFY_CLIENT_LAGGING = <span class="tok-number">1294</span>,</span>
<span class="line" id="L1549">    <span class="tok-comment">/// The requested file operation failed because the storage quota was exceeded.</span></span>
<span class="line" id="L1550">    <span class="tok-comment">/// To free up disk space, move files to a different location or delete unnecessary files.</span></span>
<span class="line" id="L1551">    <span class="tok-comment">/// For more information, contact your system administrator.</span></span>
<span class="line" id="L1552">    DISK_QUOTA_EXCEEDED = <span class="tok-number">1295</span>,</span>
<span class="line" id="L1553">    <span class="tok-comment">/// The requested file operation failed because the storage policy blocks that type of file.</span></span>
<span class="line" id="L1554">    <span class="tok-comment">/// For more information, contact your system administrator.</span></span>
<span class="line" id="L1555">    CONTENT_BLOCKED = <span class="tok-number">1296</span>,</span>
<span class="line" id="L1556">    <span class="tok-comment">/// A privilege that the service requires to function properly does not exist in the service account configuration.</span></span>
<span class="line" id="L1557">    <span class="tok-comment">/// You may use the Services Microsoft Management Console (MMC) snap-in (services.msc) and the Local Security Settings MMC snap-in (secpol.msc) to view the service configuration and the account configuration.</span></span>
<span class="line" id="L1558">    INCOMPATIBLE_SERVICE_PRIVILEGE = <span class="tok-number">1297</span>,</span>
<span class="line" id="L1559">    <span class="tok-comment">/// A thread involved in this operation appears to be unresponsive.</span></span>
<span class="line" id="L1560">    APP_HANG = <span class="tok-number">1298</span>,</span>
<span class="line" id="L1561">    <span class="tok-comment">/// Indicates a particular Security ID may not be assigned as the label of an object.</span></span>
<span class="line" id="L1562">    INVALID_LABEL = <span class="tok-number">1299</span>,</span>
<span class="line" id="L1563">    <span class="tok-comment">/// Not all privileges or groups referenced are assigned to the caller.</span></span>
<span class="line" id="L1564">    NOT_ALL_ASSIGNED = <span class="tok-number">1300</span>,</span>
<span class="line" id="L1565">    <span class="tok-comment">/// Some mapping between account names and security IDs was not done.</span></span>
<span class="line" id="L1566">    SOME_NOT_MAPPED = <span class="tok-number">1301</span>,</span>
<span class="line" id="L1567">    <span class="tok-comment">/// No system quota limits are specifically set for this account.</span></span>
<span class="line" id="L1568">    NO_QUOTAS_FOR_ACCOUNT = <span class="tok-number">1302</span>,</span>
<span class="line" id="L1569">    <span class="tok-comment">/// No encryption key is available. A well-known encryption key was returned.</span></span>
<span class="line" id="L1570">    LOCAL_USER_SESSION_KEY = <span class="tok-number">1303</span>,</span>
<span class="line" id="L1571">    <span class="tok-comment">/// The password is too complex to be converted to a LAN Manager password.</span></span>
<span class="line" id="L1572">    <span class="tok-comment">/// The LAN Manager password returned is a NULL string.</span></span>
<span class="line" id="L1573">    NULL_LM_PASSWORD = <span class="tok-number">1304</span>,</span>
<span class="line" id="L1574">    <span class="tok-comment">/// The revision level is unknown.</span></span>
<span class="line" id="L1575">    UNKNOWN_REVISION = <span class="tok-number">1305</span>,</span>
<span class="line" id="L1576">    <span class="tok-comment">/// Indicates two revision levels are incompatible.</span></span>
<span class="line" id="L1577">    REVISION_MISMATCH = <span class="tok-number">1306</span>,</span>
<span class="line" id="L1578">    <span class="tok-comment">/// This security ID may not be assigned as the owner of this object.</span></span>
<span class="line" id="L1579">    INVALID_OWNER = <span class="tok-number">1307</span>,</span>
<span class="line" id="L1580">    <span class="tok-comment">/// This security ID may not be assigned as the primary group of an object.</span></span>
<span class="line" id="L1581">    INVALID_PRIMARY_GROUP = <span class="tok-number">1308</span>,</span>
<span class="line" id="L1582">    <span class="tok-comment">/// An attempt has been made to operate on an impersonation token by a thread that is not currently impersonating a client.</span></span>
<span class="line" id="L1583">    NO_IMPERSONATION_TOKEN = <span class="tok-number">1309</span>,</span>
<span class="line" id="L1584">    <span class="tok-comment">/// The group may not be disabled.</span></span>
<span class="line" id="L1585">    CANT_DISABLE_MANDATORY = <span class="tok-number">1310</span>,</span>
<span class="line" id="L1586">    <span class="tok-comment">/// There are currently no logon servers available to service the logon request.</span></span>
<span class="line" id="L1587">    NO_LOGON_SERVERS = <span class="tok-number">1311</span>,</span>
<span class="line" id="L1588">    <span class="tok-comment">/// A specified logon session does not exist. It may already have been terminated.</span></span>
<span class="line" id="L1589">    NO_SUCH_LOGON_SESSION = <span class="tok-number">1312</span>,</span>
<span class="line" id="L1590">    <span class="tok-comment">/// A specified privilege does not exist.</span></span>
<span class="line" id="L1591">    NO_SUCH_PRIVILEGE = <span class="tok-number">1313</span>,</span>
<span class="line" id="L1592">    <span class="tok-comment">/// A required privilege is not held by the client.</span></span>
<span class="line" id="L1593">    PRIVILEGE_NOT_HELD = <span class="tok-number">1314</span>,</span>
<span class="line" id="L1594">    <span class="tok-comment">/// The name provided is not a properly formed account name.</span></span>
<span class="line" id="L1595">    INVALID_ACCOUNT_NAME = <span class="tok-number">1315</span>,</span>
<span class="line" id="L1596">    <span class="tok-comment">/// The specified account already exists.</span></span>
<span class="line" id="L1597">    USER_EXISTS = <span class="tok-number">1316</span>,</span>
<span class="line" id="L1598">    <span class="tok-comment">/// The specified account does not exist.</span></span>
<span class="line" id="L1599">    NO_SUCH_USER = <span class="tok-number">1317</span>,</span>
<span class="line" id="L1600">    <span class="tok-comment">/// The specified group already exists.</span></span>
<span class="line" id="L1601">    GROUP_EXISTS = <span class="tok-number">1318</span>,</span>
<span class="line" id="L1602">    <span class="tok-comment">/// The specified group does not exist.</span></span>
<span class="line" id="L1603">    NO_SUCH_GROUP = <span class="tok-number">1319</span>,</span>
<span class="line" id="L1604">    <span class="tok-comment">/// Either the specified user account is already a member of the specified group, or the specified group cannot be deleted because it contains a member.</span></span>
<span class="line" id="L1605">    MEMBER_IN_GROUP = <span class="tok-number">1320</span>,</span>
<span class="line" id="L1606">    <span class="tok-comment">/// The specified user account is not a member of the specified group account.</span></span>
<span class="line" id="L1607">    MEMBER_NOT_IN_GROUP = <span class="tok-number">1321</span>,</span>
<span class="line" id="L1608">    <span class="tok-comment">/// This operation is disallowed as it could result in an administration account being disabled, deleted or unable to log on.</span></span>
<span class="line" id="L1609">    LAST_ADMIN = <span class="tok-number">1322</span>,</span>
<span class="line" id="L1610">    <span class="tok-comment">/// Unable to update the password. The value provided as the current password is incorrect.</span></span>
<span class="line" id="L1611">    WRONG_PASSWORD = <span class="tok-number">1323</span>,</span>
<span class="line" id="L1612">    <span class="tok-comment">/// Unable to update the password. The value provided for the new password contains values that are not allowed in passwords.</span></span>
<span class="line" id="L1613">    ILL_FORMED_PASSWORD = <span class="tok-number">1324</span>,</span>
<span class="line" id="L1614">    <span class="tok-comment">/// Unable to update the password. The value provided for the new password does not meet the length, complexity, or history requirements of the domain.</span></span>
<span class="line" id="L1615">    PASSWORD_RESTRICTION = <span class="tok-number">1325</span>,</span>
<span class="line" id="L1616">    <span class="tok-comment">/// The user name or password is incorrect.</span></span>
<span class="line" id="L1617">    LOGON_FAILURE = <span class="tok-number">1326</span>,</span>
<span class="line" id="L1618">    <span class="tok-comment">/// Account restrictions are preventing this user from signing in.</span></span>
<span class="line" id="L1619">    <span class="tok-comment">/// For example: blank passwords aren't allowed, sign-in times are limited, or a policy restriction has been enforced.</span></span>
<span class="line" id="L1620">    ACCOUNT_RESTRICTION = <span class="tok-number">1327</span>,</span>
<span class="line" id="L1621">    <span class="tok-comment">/// Your account has time restrictions that keep you from signing in right now.</span></span>
<span class="line" id="L1622">    INVALID_LOGON_HOURS = <span class="tok-number">1328</span>,</span>
<span class="line" id="L1623">    <span class="tok-comment">/// This user isn't allowed to sign in to this computer.</span></span>
<span class="line" id="L1624">    INVALID_WORKSTATION = <span class="tok-number">1329</span>,</span>
<span class="line" id="L1625">    <span class="tok-comment">/// The password for this account has expired.</span></span>
<span class="line" id="L1626">    PASSWORD_EXPIRED = <span class="tok-number">1330</span>,</span>
<span class="line" id="L1627">    <span class="tok-comment">/// This user can't sign in because this account is currently disabled.</span></span>
<span class="line" id="L1628">    ACCOUNT_DISABLED = <span class="tok-number">1331</span>,</span>
<span class="line" id="L1629">    <span class="tok-comment">/// No mapping between account names and security IDs was done.</span></span>
<span class="line" id="L1630">    NONE_MAPPED = <span class="tok-number">1332</span>,</span>
<span class="line" id="L1631">    <span class="tok-comment">/// Too many local user identifiers (LUIDs) were requested at one time.</span></span>
<span class="line" id="L1632">    TOO_MANY_LUIDS_REQUESTED = <span class="tok-number">1333</span>,</span>
<span class="line" id="L1633">    <span class="tok-comment">/// No more local user identifiers (LUIDs) are available.</span></span>
<span class="line" id="L1634">    LUIDS_EXHAUSTED = <span class="tok-number">1334</span>,</span>
<span class="line" id="L1635">    <span class="tok-comment">/// The subauthority part of a security ID is invalid for this particular use.</span></span>
<span class="line" id="L1636">    INVALID_SUB_AUTHORITY = <span class="tok-number">1335</span>,</span>
<span class="line" id="L1637">    <span class="tok-comment">/// The access control list (ACL) structure is invalid.</span></span>
<span class="line" id="L1638">    INVALID_ACL = <span class="tok-number">1336</span>,</span>
<span class="line" id="L1639">    <span class="tok-comment">/// The security ID structure is invalid.</span></span>
<span class="line" id="L1640">    INVALID_SID = <span class="tok-number">1337</span>,</span>
<span class="line" id="L1641">    <span class="tok-comment">/// The security descriptor structure is invalid.</span></span>
<span class="line" id="L1642">    INVALID_SECURITY_DESCR = <span class="tok-number">1338</span>,</span>
<span class="line" id="L1643">    <span class="tok-comment">/// The inherited access control list (ACL) or access control entry (ACE) could not be built.</span></span>
<span class="line" id="L1644">    BAD_INHERITANCE_ACL = <span class="tok-number">1340</span>,</span>
<span class="line" id="L1645">    <span class="tok-comment">/// The server is currently disabled.</span></span>
<span class="line" id="L1646">    SERVER_DISABLED = <span class="tok-number">1341</span>,</span>
<span class="line" id="L1647">    <span class="tok-comment">/// The server is currently enabled.</span></span>
<span class="line" id="L1648">    SERVER_NOT_DISABLED = <span class="tok-number">1342</span>,</span>
<span class="line" id="L1649">    <span class="tok-comment">/// The value provided was an invalid value for an identifier authority.</span></span>
<span class="line" id="L1650">    INVALID_ID_AUTHORITY = <span class="tok-number">1343</span>,</span>
<span class="line" id="L1651">    <span class="tok-comment">/// No more memory is available for security information updates.</span></span>
<span class="line" id="L1652">    ALLOTTED_SPACE_EXCEEDED = <span class="tok-number">1344</span>,</span>
<span class="line" id="L1653">    <span class="tok-comment">/// The specified attributes are invalid, or incompatible with the attributes for the group as a whole.</span></span>
<span class="line" id="L1654">    INVALID_GROUP_ATTRIBUTES = <span class="tok-number">1345</span>,</span>
<span class="line" id="L1655">    <span class="tok-comment">/// Either a required impersonation level was not provided, or the provided impersonation level is invalid.</span></span>
<span class="line" id="L1656">    BAD_IMPERSONATION_LEVEL = <span class="tok-number">1346</span>,</span>
<span class="line" id="L1657">    <span class="tok-comment">/// Cannot open an anonymous level security token.</span></span>
<span class="line" id="L1658">    CANT_OPEN_ANONYMOUS = <span class="tok-number">1347</span>,</span>
<span class="line" id="L1659">    <span class="tok-comment">/// The validation information class requested was invalid.</span></span>
<span class="line" id="L1660">    BAD_VALIDATION_CLASS = <span class="tok-number">1348</span>,</span>
<span class="line" id="L1661">    <span class="tok-comment">/// The type of the token is inappropriate for its attempted use.</span></span>
<span class="line" id="L1662">    BAD_TOKEN_TYPE = <span class="tok-number">1349</span>,</span>
<span class="line" id="L1663">    <span class="tok-comment">/// Unable to perform a security operation on an object that has no associated security.</span></span>
<span class="line" id="L1664">    NO_SECURITY_ON_OBJECT = <span class="tok-number">1350</span>,</span>
<span class="line" id="L1665">    <span class="tok-comment">/// Configuration information could not be read from the domain controller, either because the machine is unavailable, or access has been denied.</span></span>
<span class="line" id="L1666">    CANT_ACCESS_DOMAIN_INFO = <span class="tok-number">1351</span>,</span>
<span class="line" id="L1667">    <span class="tok-comment">/// The security account manager (SAM) or local security authority (LSA) server was in the wrong state to perform the security operation.</span></span>
<span class="line" id="L1668">    INVALID_SERVER_STATE = <span class="tok-number">1352</span>,</span>
<span class="line" id="L1669">    <span class="tok-comment">/// The domain was in the wrong state to perform the security operation.</span></span>
<span class="line" id="L1670">    INVALID_DOMAIN_STATE = <span class="tok-number">1353</span>,</span>
<span class="line" id="L1671">    <span class="tok-comment">/// This operation is only allowed for the Primary Domain Controller of the domain.</span></span>
<span class="line" id="L1672">    INVALID_DOMAIN_ROLE = <span class="tok-number">1354</span>,</span>
<span class="line" id="L1673">    <span class="tok-comment">/// The specified domain either does not exist or could not be contacted.</span></span>
<span class="line" id="L1674">    NO_SUCH_DOMAIN = <span class="tok-number">1355</span>,</span>
<span class="line" id="L1675">    <span class="tok-comment">/// The specified domain already exists.</span></span>
<span class="line" id="L1676">    DOMAIN_EXISTS = <span class="tok-number">1356</span>,</span>
<span class="line" id="L1677">    <span class="tok-comment">/// An attempt was made to exceed the limit on the number of domains per server.</span></span>
<span class="line" id="L1678">    DOMAIN_LIMIT_EXCEEDED = <span class="tok-number">1357</span>,</span>
<span class="line" id="L1679">    <span class="tok-comment">/// Unable to complete the requested operation because of either a catastrophic media failure or a data structure corruption on the disk.</span></span>
<span class="line" id="L1680">    INTERNAL_DB_CORRUPTION = <span class="tok-number">1358</span>,</span>
<span class="line" id="L1681">    <span class="tok-comment">/// An internal error occurred.</span></span>
<span class="line" id="L1682">    INTERNAL_ERROR = <span class="tok-number">1359</span>,</span>
<span class="line" id="L1683">    <span class="tok-comment">/// Generic access types were contained in an access mask which should already be mapped to nongeneric types.</span></span>
<span class="line" id="L1684">    GENERIC_NOT_MAPPED = <span class="tok-number">1360</span>,</span>
<span class="line" id="L1685">    <span class="tok-comment">/// A security descriptor is not in the right format (absolute or self-relative).</span></span>
<span class="line" id="L1686">    BAD_DESCRIPTOR_FORMAT = <span class="tok-number">1361</span>,</span>
<span class="line" id="L1687">    <span class="tok-comment">/// The requested action is restricted for use by logon processes only.</span></span>
<span class="line" id="L1688">    <span class="tok-comment">/// The calling process has not registered as a logon process.</span></span>
<span class="line" id="L1689">    NOT_LOGON_PROCESS = <span class="tok-number">1362</span>,</span>
<span class="line" id="L1690">    <span class="tok-comment">/// Cannot start a new logon session with an ID that is already in use.</span></span>
<span class="line" id="L1691">    LOGON_SESSION_EXISTS = <span class="tok-number">1363</span>,</span>
<span class="line" id="L1692">    <span class="tok-comment">/// A specified authentication package is unknown.</span></span>
<span class="line" id="L1693">    NO_SUCH_PACKAGE = <span class="tok-number">1364</span>,</span>
<span class="line" id="L1694">    <span class="tok-comment">/// The logon session is not in a state that is consistent with the requested operation.</span></span>
<span class="line" id="L1695">    BAD_LOGON_SESSION_STATE = <span class="tok-number">1365</span>,</span>
<span class="line" id="L1696">    <span class="tok-comment">/// The logon session ID is already in use.</span></span>
<span class="line" id="L1697">    LOGON_SESSION_COLLISION = <span class="tok-number">1366</span>,</span>
<span class="line" id="L1698">    <span class="tok-comment">/// A logon request contained an invalid logon type value.</span></span>
<span class="line" id="L1699">    INVALID_LOGON_TYPE = <span class="tok-number">1367</span>,</span>
<span class="line" id="L1700">    <span class="tok-comment">/// Unable to impersonate using a named pipe until data has been read from that pipe.</span></span>
<span class="line" id="L1701">    CANNOT_IMPERSONATE = <span class="tok-number">1368</span>,</span>
<span class="line" id="L1702">    <span class="tok-comment">/// The transaction state of a registry subtree is incompatible with the requested operation.</span></span>
<span class="line" id="L1703">    RXACT_INVALID_STATE = <span class="tok-number">1369</span>,</span>
<span class="line" id="L1704">    <span class="tok-comment">/// An internal security database corruption has been encountered.</span></span>
<span class="line" id="L1705">    RXACT_COMMIT_FAILURE = <span class="tok-number">1370</span>,</span>
<span class="line" id="L1706">    <span class="tok-comment">/// Cannot perform this operation on built-in accounts.</span></span>
<span class="line" id="L1707">    SPECIAL_ACCOUNT = <span class="tok-number">1371</span>,</span>
<span class="line" id="L1708">    <span class="tok-comment">/// Cannot perform this operation on this built-in special group.</span></span>
<span class="line" id="L1709">    SPECIAL_GROUP = <span class="tok-number">1372</span>,</span>
<span class="line" id="L1710">    <span class="tok-comment">/// Cannot perform this operation on this built-in special user.</span></span>
<span class="line" id="L1711">    SPECIAL_USER = <span class="tok-number">1373</span>,</span>
<span class="line" id="L1712">    <span class="tok-comment">/// The user cannot be removed from a group because the group is currently the user's primary group.</span></span>
<span class="line" id="L1713">    MEMBERS_PRIMARY_GROUP = <span class="tok-number">1374</span>,</span>
<span class="line" id="L1714">    <span class="tok-comment">/// The token is already in use as a primary token.</span></span>
<span class="line" id="L1715">    TOKEN_ALREADY_IN_USE = <span class="tok-number">1375</span>,</span>
<span class="line" id="L1716">    <span class="tok-comment">/// The specified local group does not exist.</span></span>
<span class="line" id="L1717">    NO_SUCH_ALIAS = <span class="tok-number">1376</span>,</span>
<span class="line" id="L1718">    <span class="tok-comment">/// The specified account name is not a member of the group.</span></span>
<span class="line" id="L1719">    MEMBER_NOT_IN_ALIAS = <span class="tok-number">1377</span>,</span>
<span class="line" id="L1720">    <span class="tok-comment">/// The specified account name is already a member of the group.</span></span>
<span class="line" id="L1721">    MEMBER_IN_ALIAS = <span class="tok-number">1378</span>,</span>
<span class="line" id="L1722">    <span class="tok-comment">/// The specified local group already exists.</span></span>
<span class="line" id="L1723">    ALIAS_EXISTS = <span class="tok-number">1379</span>,</span>
<span class="line" id="L1724">    <span class="tok-comment">/// Logon failure: the user has not been granted the requested logon type at this computer.</span></span>
<span class="line" id="L1725">    LOGON_NOT_GRANTED = <span class="tok-number">1380</span>,</span>
<span class="line" id="L1726">    <span class="tok-comment">/// The maximum number of secrets that may be stored in a single system has been exceeded.</span></span>
<span class="line" id="L1727">    TOO_MANY_SECRETS = <span class="tok-number">1381</span>,</span>
<span class="line" id="L1728">    <span class="tok-comment">/// The length of a secret exceeds the maximum length allowed.</span></span>
<span class="line" id="L1729">    SECRET_TOO_LONG = <span class="tok-number">1382</span>,</span>
<span class="line" id="L1730">    <span class="tok-comment">/// The local security authority database contains an internal inconsistency.</span></span>
<span class="line" id="L1731">    INTERNAL_DB_ERROR = <span class="tok-number">1383</span>,</span>
<span class="line" id="L1732">    <span class="tok-comment">/// During a logon attempt, the user's security context accumulated too many security IDs.</span></span>
<span class="line" id="L1733">    TOO_MANY_CONTEXT_IDS = <span class="tok-number">1384</span>,</span>
<span class="line" id="L1734">    <span class="tok-comment">/// Logon failure: the user has not been granted the requested logon type at this computer.</span></span>
<span class="line" id="L1735">    LOGON_TYPE_NOT_GRANTED = <span class="tok-number">1385</span>,</span>
<span class="line" id="L1736">    <span class="tok-comment">/// A cross-encrypted password is necessary to change a user password.</span></span>
<span class="line" id="L1737">    NT_CROSS_ENCRYPTION_REQUIRED = <span class="tok-number">1386</span>,</span>
<span class="line" id="L1738">    <span class="tok-comment">/// A member could not be added to or removed from the local group because the member does not exist.</span></span>
<span class="line" id="L1739">    NO_SUCH_MEMBER = <span class="tok-number">1387</span>,</span>
<span class="line" id="L1740">    <span class="tok-comment">/// A new member could not be added to a local group because the member has the wrong account type.</span></span>
<span class="line" id="L1741">    INVALID_MEMBER = <span class="tok-number">1388</span>,</span>
<span class="line" id="L1742">    <span class="tok-comment">/// Too many security IDs have been specified.</span></span>
<span class="line" id="L1743">    TOO_MANY_SIDS = <span class="tok-number">1389</span>,</span>
<span class="line" id="L1744">    <span class="tok-comment">/// A cross-encrypted password is necessary to change this user password.</span></span>
<span class="line" id="L1745">    LM_CROSS_ENCRYPTION_REQUIRED = <span class="tok-number">1390</span>,</span>
<span class="line" id="L1746">    <span class="tok-comment">/// Indicates an ACL contains no inheritable components.</span></span>
<span class="line" id="L1747">    NO_INHERITANCE = <span class="tok-number">1391</span>,</span>
<span class="line" id="L1748">    <span class="tok-comment">/// The file or directory is corrupted and unreadable.</span></span>
<span class="line" id="L1749">    FILE_CORRUPT = <span class="tok-number">1392</span>,</span>
<span class="line" id="L1750">    <span class="tok-comment">/// The disk structure is corrupted and unreadable.</span></span>
<span class="line" id="L1751">    DISK_CORRUPT = <span class="tok-number">1393</span>,</span>
<span class="line" id="L1752">    <span class="tok-comment">/// There is no user session key for the specified logon session.</span></span>
<span class="line" id="L1753">    NO_USER_SESSION_KEY = <span class="tok-number">1394</span>,</span>
<span class="line" id="L1754">    <span class="tok-comment">/// The service being accessed is licensed for a particular number of connections.</span></span>
<span class="line" id="L1755">    <span class="tok-comment">/// No more connections can be made to the service at this time because there are already as many connections as the service can accept.</span></span>
<span class="line" id="L1756">    LICENSE_QUOTA_EXCEEDED = <span class="tok-number">1395</span>,</span>
<span class="line" id="L1757">    <span class="tok-comment">/// The target account name is incorrect.</span></span>
<span class="line" id="L1758">    WRONG_TARGET_NAME = <span class="tok-number">1396</span>,</span>
<span class="line" id="L1759">    <span class="tok-comment">/// Mutual Authentication failed. The server's password is out of date at the domain controller.</span></span>
<span class="line" id="L1760">    MUTUAL_AUTH_FAILED = <span class="tok-number">1397</span>,</span>
<span class="line" id="L1761">    <span class="tok-comment">/// There is a time and/or date difference between the client and server.</span></span>
<span class="line" id="L1762">    TIME_SKEW = <span class="tok-number">1398</span>,</span>
<span class="line" id="L1763">    <span class="tok-comment">/// This operation cannot be performed on the current domain.</span></span>
<span class="line" id="L1764">    CURRENT_DOMAIN_NOT_ALLOWED = <span class="tok-number">1399</span>,</span>
<span class="line" id="L1765">    <span class="tok-comment">/// Invalid window handle.</span></span>
<span class="line" id="L1766">    INVALID_WINDOW_HANDLE = <span class="tok-number">1400</span>,</span>
<span class="line" id="L1767">    <span class="tok-comment">/// Invalid menu handle.</span></span>
<span class="line" id="L1768">    INVALID_MENU_HANDLE = <span class="tok-number">1401</span>,</span>
<span class="line" id="L1769">    <span class="tok-comment">/// Invalid cursor handle.</span></span>
<span class="line" id="L1770">    INVALID_CURSOR_HANDLE = <span class="tok-number">1402</span>,</span>
<span class="line" id="L1771">    <span class="tok-comment">/// Invalid accelerator table handle.</span></span>
<span class="line" id="L1772">    INVALID_ACCEL_HANDLE = <span class="tok-number">1403</span>,</span>
<span class="line" id="L1773">    <span class="tok-comment">/// Invalid hook handle.</span></span>
<span class="line" id="L1774">    INVALID_HOOK_HANDLE = <span class="tok-number">1404</span>,</span>
<span class="line" id="L1775">    <span class="tok-comment">/// Invalid handle to a multiple-window position structure.</span></span>
<span class="line" id="L1776">    INVALID_DWP_HANDLE = <span class="tok-number">1405</span>,</span>
<span class="line" id="L1777">    <span class="tok-comment">/// Cannot create a top-level child window.</span></span>
<span class="line" id="L1778">    TLW_WITH_WSCHILD = <span class="tok-number">1406</span>,</span>
<span class="line" id="L1779">    <span class="tok-comment">/// Cannot find window class.</span></span>
<span class="line" id="L1780">    CANNOT_FIND_WND_CLASS = <span class="tok-number">1407</span>,</span>
<span class="line" id="L1781">    <span class="tok-comment">/// Invalid window; it belongs to other thread.</span></span>
<span class="line" id="L1782">    WINDOW_OF_OTHER_THREAD = <span class="tok-number">1408</span>,</span>
<span class="line" id="L1783">    <span class="tok-comment">/// Hot key is already registered.</span></span>
<span class="line" id="L1784">    HOTKEY_ALREADY_REGISTERED = <span class="tok-number">1409</span>,</span>
<span class="line" id="L1785">    <span class="tok-comment">/// Class already exists.</span></span>
<span class="line" id="L1786">    CLASS_ALREADY_EXISTS = <span class="tok-number">1410</span>,</span>
<span class="line" id="L1787">    <span class="tok-comment">/// Class does not exist.</span></span>
<span class="line" id="L1788">    CLASS_DOES_NOT_EXIST = <span class="tok-number">1411</span>,</span>
<span class="line" id="L1789">    <span class="tok-comment">/// Class still has open windows.</span></span>
<span class="line" id="L1790">    CLASS_HAS_WINDOWS = <span class="tok-number">1412</span>,</span>
<span class="line" id="L1791">    <span class="tok-comment">/// Invalid index.</span></span>
<span class="line" id="L1792">    INVALID_INDEX = <span class="tok-number">1413</span>,</span>
<span class="line" id="L1793">    <span class="tok-comment">/// Invalid icon handle.</span></span>
<span class="line" id="L1794">    INVALID_ICON_HANDLE = <span class="tok-number">1414</span>,</span>
<span class="line" id="L1795">    <span class="tok-comment">/// Using private DIALOG window words.</span></span>
<span class="line" id="L1796">    PRIVATE_DIALOG_INDEX = <span class="tok-number">1415</span>,</span>
<span class="line" id="L1797">    <span class="tok-comment">/// The list box identifier was not found.</span></span>
<span class="line" id="L1798">    LISTBOX_ID_NOT_FOUND = <span class="tok-number">1416</span>,</span>
<span class="line" id="L1799">    <span class="tok-comment">/// No wildcards were found.</span></span>
<span class="line" id="L1800">    NO_WILDCARD_CHARACTERS = <span class="tok-number">1417</span>,</span>
<span class="line" id="L1801">    <span class="tok-comment">/// Thread does not have a clipboard open.</span></span>
<span class="line" id="L1802">    CLIPBOARD_NOT_OPEN = <span class="tok-number">1418</span>,</span>
<span class="line" id="L1803">    <span class="tok-comment">/// Hot key is not registered.</span></span>
<span class="line" id="L1804">    HOTKEY_NOT_REGISTERED = <span class="tok-number">1419</span>,</span>
<span class="line" id="L1805">    <span class="tok-comment">/// The window is not a valid dialog window.</span></span>
<span class="line" id="L1806">    WINDOW_NOT_DIALOG = <span class="tok-number">1420</span>,</span>
<span class="line" id="L1807">    <span class="tok-comment">/// Control ID not found.</span></span>
<span class="line" id="L1808">    CONTROL_ID_NOT_FOUND = <span class="tok-number">1421</span>,</span>
<span class="line" id="L1809">    <span class="tok-comment">/// Invalid message for a combo box because it does not have an edit control.</span></span>
<span class="line" id="L1810">    INVALID_COMBOBOX_MESSAGE = <span class="tok-number">1422</span>,</span>
<span class="line" id="L1811">    <span class="tok-comment">/// The window is not a combo box.</span></span>
<span class="line" id="L1812">    WINDOW_NOT_COMBOBOX = <span class="tok-number">1423</span>,</span>
<span class="line" id="L1813">    <span class="tok-comment">/// Height must be less than 256.</span></span>
<span class="line" id="L1814">    INVALID_EDIT_HEIGHT = <span class="tok-number">1424</span>,</span>
<span class="line" id="L1815">    <span class="tok-comment">/// Invalid device context (DC) handle.</span></span>
<span class="line" id="L1816">    DC_NOT_FOUND = <span class="tok-number">1425</span>,</span>
<span class="line" id="L1817">    <span class="tok-comment">/// Invalid hook procedure type.</span></span>
<span class="line" id="L1818">    INVALID_HOOK_FILTER = <span class="tok-number">1426</span>,</span>
<span class="line" id="L1819">    <span class="tok-comment">/// Invalid hook procedure.</span></span>
<span class="line" id="L1820">    INVALID_FILTER_PROC = <span class="tok-number">1427</span>,</span>
<span class="line" id="L1821">    <span class="tok-comment">/// Cannot set nonlocal hook without a module handle.</span></span>
<span class="line" id="L1822">    HOOK_NEEDS_HMOD = <span class="tok-number">1428</span>,</span>
<span class="line" id="L1823">    <span class="tok-comment">/// This hook procedure can only be set globally.</span></span>
<span class="line" id="L1824">    GLOBAL_ONLY_HOOK = <span class="tok-number">1429</span>,</span>
<span class="line" id="L1825">    <span class="tok-comment">/// The journal hook procedure is already installed.</span></span>
<span class="line" id="L1826">    JOURNAL_HOOK_SET = <span class="tok-number">1430</span>,</span>
<span class="line" id="L1827">    <span class="tok-comment">/// The hook procedure is not installed.</span></span>
<span class="line" id="L1828">    HOOK_NOT_INSTALLED = <span class="tok-number">1431</span>,</span>
<span class="line" id="L1829">    <span class="tok-comment">/// Invalid message for single-selection list box.</span></span>
<span class="line" id="L1830">    INVALID_LB_MESSAGE = <span class="tok-number">1432</span>,</span>
<span class="line" id="L1831">    <span class="tok-comment">/// LB_SETCOUNT sent to non-lazy list box.</span></span>
<span class="line" id="L1832">    SETCOUNT_ON_BAD_LB = <span class="tok-number">1433</span>,</span>
<span class="line" id="L1833">    <span class="tok-comment">/// This list box does not support tab stops.</span></span>
<span class="line" id="L1834">    LB_WITHOUT_TABSTOPS = <span class="tok-number">1434</span>,</span>
<span class="line" id="L1835">    <span class="tok-comment">/// Cannot destroy object created by another thread.</span></span>
<span class="line" id="L1836">    DESTROY_OBJECT_OF_OTHER_THREAD = <span class="tok-number">1435</span>,</span>
<span class="line" id="L1837">    <span class="tok-comment">/// Child windows cannot have menus.</span></span>
<span class="line" id="L1838">    CHILD_WINDOW_MENU = <span class="tok-number">1436</span>,</span>
<span class="line" id="L1839">    <span class="tok-comment">/// The window does not have a system menu.</span></span>
<span class="line" id="L1840">    NO_SYSTEM_MENU = <span class="tok-number">1437</span>,</span>
<span class="line" id="L1841">    <span class="tok-comment">/// Invalid message box style.</span></span>
<span class="line" id="L1842">    INVALID_MSGBOX_STYLE = <span class="tok-number">1438</span>,</span>
<span class="line" id="L1843">    <span class="tok-comment">/// Invalid system-wide (SPI_*) parameter.</span></span>
<span class="line" id="L1844">    INVALID_SPI_VALUE = <span class="tok-number">1439</span>,</span>
<span class="line" id="L1845">    <span class="tok-comment">/// Screen already locked.</span></span>
<span class="line" id="L1846">    SCREEN_ALREADY_LOCKED = <span class="tok-number">1440</span>,</span>
<span class="line" id="L1847">    <span class="tok-comment">/// All handles to windows in a multiple-window position structure must have the same parent.</span></span>
<span class="line" id="L1848">    HWNDS_HAVE_DIFF_PARENT = <span class="tok-number">1441</span>,</span>
<span class="line" id="L1849">    <span class="tok-comment">/// The window is not a child window.</span></span>
<span class="line" id="L1850">    NOT_CHILD_WINDOW = <span class="tok-number">1442</span>,</span>
<span class="line" id="L1851">    <span class="tok-comment">/// Invalid GW_* command.</span></span>
<span class="line" id="L1852">    INVALID_GW_COMMAND = <span class="tok-number">1443</span>,</span>
<span class="line" id="L1853">    <span class="tok-comment">/// Invalid thread identifier.</span></span>
<span class="line" id="L1854">    INVALID_THREAD_ID = <span class="tok-number">1444</span>,</span>
<span class="line" id="L1855">    <span class="tok-comment">/// Cannot process a message from a window that is not a multiple document interface (MDI) window.</span></span>
<span class="line" id="L1856">    NON_MDICHILD_WINDOW = <span class="tok-number">1445</span>,</span>
<span class="line" id="L1857">    <span class="tok-comment">/// Popup menu already active.</span></span>
<span class="line" id="L1858">    POPUP_ALREADY_ACTIVE = <span class="tok-number">1446</span>,</span>
<span class="line" id="L1859">    <span class="tok-comment">/// The window does not have scroll bars.</span></span>
<span class="line" id="L1860">    NO_SCROLLBARS = <span class="tok-number">1447</span>,</span>
<span class="line" id="L1861">    <span class="tok-comment">/// Scroll bar range cannot be greater than MAXLONG.</span></span>
<span class="line" id="L1862">    INVALID_SCROLLBAR_RANGE = <span class="tok-number">1448</span>,</span>
<span class="line" id="L1863">    <span class="tok-comment">/// Cannot show or remove the window in the way specified.</span></span>
<span class="line" id="L1864">    INVALID_SHOWWIN_COMMAND = <span class="tok-number">1449</span>,</span>
<span class="line" id="L1865">    <span class="tok-comment">/// Insufficient system resources exist to complete the requested service.</span></span>
<span class="line" id="L1866">    NO_SYSTEM_RESOURCES = <span class="tok-number">1450</span>,</span>
<span class="line" id="L1867">    <span class="tok-comment">/// Insufficient system resources exist to complete the requested service.</span></span>
<span class="line" id="L1868">    NONPAGED_SYSTEM_RESOURCES = <span class="tok-number">1451</span>,</span>
<span class="line" id="L1869">    <span class="tok-comment">/// Insufficient system resources exist to complete the requested service.</span></span>
<span class="line" id="L1870">    PAGED_SYSTEM_RESOURCES = <span class="tok-number">1452</span>,</span>
<span class="line" id="L1871">    <span class="tok-comment">/// Insufficient quota to complete the requested service.</span></span>
<span class="line" id="L1872">    WORKING_SET_QUOTA = <span class="tok-number">1453</span>,</span>
<span class="line" id="L1873">    <span class="tok-comment">/// Insufficient quota to complete the requested service.</span></span>
<span class="line" id="L1874">    PAGEFILE_QUOTA = <span class="tok-number">1454</span>,</span>
<span class="line" id="L1875">    <span class="tok-comment">/// The paging file is too small for this operation to complete.</span></span>
<span class="line" id="L1876">    COMMITMENT_LIMIT = <span class="tok-number">1455</span>,</span>
<span class="line" id="L1877">    <span class="tok-comment">/// A menu item was not found.</span></span>
<span class="line" id="L1878">    MENU_ITEM_NOT_FOUND = <span class="tok-number">1456</span>,</span>
<span class="line" id="L1879">    <span class="tok-comment">/// Invalid keyboard layout handle.</span></span>
<span class="line" id="L1880">    INVALID_KEYBOARD_HANDLE = <span class="tok-number">1457</span>,</span>
<span class="line" id="L1881">    <span class="tok-comment">/// Hook type not allowed.</span></span>
<span class="line" id="L1882">    HOOK_TYPE_NOT_ALLOWED = <span class="tok-number">1458</span>,</span>
<span class="line" id="L1883">    <span class="tok-comment">/// This operation requires an interactive window station.</span></span>
<span class="line" id="L1884">    REQUIRES_INTERACTIVE_WINDOWSTATION = <span class="tok-number">1459</span>,</span>
<span class="line" id="L1885">    <span class="tok-comment">/// This operation returned because the timeout period expired.</span></span>
<span class="line" id="L1886">    TIMEOUT = <span class="tok-number">1460</span>,</span>
<span class="line" id="L1887">    <span class="tok-comment">/// Invalid monitor handle.</span></span>
<span class="line" id="L1888">    INVALID_MONITOR_HANDLE = <span class="tok-number">1461</span>,</span>
<span class="line" id="L1889">    <span class="tok-comment">/// Incorrect size argument.</span></span>
<span class="line" id="L1890">    INCORRECT_SIZE = <span class="tok-number">1462</span>,</span>
<span class="line" id="L1891">    <span class="tok-comment">/// The symbolic link cannot be followed because its type is disabled.</span></span>
<span class="line" id="L1892">    SYMLINK_CLASS_DISABLED = <span class="tok-number">1463</span>,</span>
<span class="line" id="L1893">    <span class="tok-comment">/// This application does not support the current operation on symbolic links.</span></span>
<span class="line" id="L1894">    SYMLINK_NOT_SUPPORTED = <span class="tok-number">1464</span>,</span>
<span class="line" id="L1895">    <span class="tok-comment">/// Windows was unable to parse the requested XML data.</span></span>
<span class="line" id="L1896">    XML_PARSE_ERROR = <span class="tok-number">1465</span>,</span>
<span class="line" id="L1897">    <span class="tok-comment">/// An error was encountered while processing an XML digital signature.</span></span>
<span class="line" id="L1898">    XMLDSIG_ERROR = <span class="tok-number">1466</span>,</span>
<span class="line" id="L1899">    <span class="tok-comment">/// This application must be restarted.</span></span>
<span class="line" id="L1900">    RESTART_APPLICATION = <span class="tok-number">1467</span>,</span>
<span class="line" id="L1901">    <span class="tok-comment">/// The caller made the connection request in the wrong routing compartment.</span></span>
<span class="line" id="L1902">    WRONG_COMPARTMENT = <span class="tok-number">1468</span>,</span>
<span class="line" id="L1903">    <span class="tok-comment">/// There was an AuthIP failure when attempting to connect to the remote host.</span></span>
<span class="line" id="L1904">    AUTHIP_FAILURE = <span class="tok-number">1469</span>,</span>
<span class="line" id="L1905">    <span class="tok-comment">/// Insufficient NVRAM resources exist to complete the requested service. A reboot might be required.</span></span>
<span class="line" id="L1906">    NO_NVRAM_RESOURCES = <span class="tok-number">1470</span>,</span>
<span class="line" id="L1907">    <span class="tok-comment">/// Unable to finish the requested operation because the specified process is not a GUI process.</span></span>
<span class="line" id="L1908">    NOT_GUI_PROCESS = <span class="tok-number">1471</span>,</span>
<span class="line" id="L1909">    <span class="tok-comment">/// The event log file is corrupted.</span></span>
<span class="line" id="L1910">    EVENTLOG_FILE_CORRUPT = <span class="tok-number">1500</span>,</span>
<span class="line" id="L1911">    <span class="tok-comment">/// No event log file could be opened, so the event logging service did not start.</span></span>
<span class="line" id="L1912">    EVENTLOG_CANT_START = <span class="tok-number">1501</span>,</span>
<span class="line" id="L1913">    <span class="tok-comment">/// The event log file is full.</span></span>
<span class="line" id="L1914">    LOG_FILE_FULL = <span class="tok-number">1502</span>,</span>
<span class="line" id="L1915">    <span class="tok-comment">/// The event log file has changed between read operations.</span></span>
<span class="line" id="L1916">    EVENTLOG_FILE_CHANGED = <span class="tok-number">1503</span>,</span>
<span class="line" id="L1917">    <span class="tok-comment">/// The specified task name is invalid.</span></span>
<span class="line" id="L1918">    INVALID_TASK_NAME = <span class="tok-number">1550</span>,</span>
<span class="line" id="L1919">    <span class="tok-comment">/// The specified task index is invalid.</span></span>
<span class="line" id="L1920">    INVALID_TASK_INDEX = <span class="tok-number">1551</span>,</span>
<span class="line" id="L1921">    <span class="tok-comment">/// The specified thread is already joining a task.</span></span>
<span class="line" id="L1922">    THREAD_ALREADY_IN_TASK = <span class="tok-number">1552</span>,</span>
<span class="line" id="L1923">    <span class="tok-comment">/// The Windows Installer Service could not be accessed.</span></span>
<span class="line" id="L1924">    <span class="tok-comment">/// This can occur if the Windows Installer is not correctly installed. Contact your support personnel for assistance.</span></span>
<span class="line" id="L1925">    INSTALL_SERVICE_FAILURE = <span class="tok-number">1601</span>,</span>
<span class="line" id="L1926">    <span class="tok-comment">/// User cancelled installation.</span></span>
<span class="line" id="L1927">    INSTALL_USEREXIT = <span class="tok-number">1602</span>,</span>
<span class="line" id="L1928">    <span class="tok-comment">/// Fatal error during installation.</span></span>
<span class="line" id="L1929">    INSTALL_FAILURE = <span class="tok-number">1603</span>,</span>
<span class="line" id="L1930">    <span class="tok-comment">/// Installation suspended, incomplete.</span></span>
<span class="line" id="L1931">    INSTALL_SUSPEND = <span class="tok-number">1604</span>,</span>
<span class="line" id="L1932">    <span class="tok-comment">/// This action is only valid for products that are currently installed.</span></span>
<span class="line" id="L1933">    UNKNOWN_PRODUCT = <span class="tok-number">1605</span>,</span>
<span class="line" id="L1934">    <span class="tok-comment">/// Feature ID not registered.</span></span>
<span class="line" id="L1935">    UNKNOWN_FEATURE = <span class="tok-number">1606</span>,</span>
<span class="line" id="L1936">    <span class="tok-comment">/// Component ID not registered.</span></span>
<span class="line" id="L1937">    UNKNOWN_COMPONENT = <span class="tok-number">1607</span>,</span>
<span class="line" id="L1938">    <span class="tok-comment">/// Unknown property.</span></span>
<span class="line" id="L1939">    UNKNOWN_PROPERTY = <span class="tok-number">1608</span>,</span>
<span class="line" id="L1940">    <span class="tok-comment">/// Handle is in an invalid state.</span></span>
<span class="line" id="L1941">    INVALID_HANDLE_STATE = <span class="tok-number">1609</span>,</span>
<span class="line" id="L1942">    <span class="tok-comment">/// The configuration data for this product is corrupt. Contact your support personnel.</span></span>
<span class="line" id="L1943">    BAD_CONFIGURATION = <span class="tok-number">1610</span>,</span>
<span class="line" id="L1944">    <span class="tok-comment">/// Component qualifier not present.</span></span>
<span class="line" id="L1945">    INDEX_ABSENT = <span class="tok-number">1611</span>,</span>
<span class="line" id="L1946">    <span class="tok-comment">/// The installation source for this product is not available.</span></span>
<span class="line" id="L1947">    <span class="tok-comment">/// Verify that the source exists and that you can access it.</span></span>
<span class="line" id="L1948">    INSTALL_SOURCE_ABSENT = <span class="tok-number">1612</span>,</span>
<span class="line" id="L1949">    <span class="tok-comment">/// This installation package cannot be installed by the Windows Installer service.</span></span>
<span class="line" id="L1950">    <span class="tok-comment">/// You must install a Windows service pack that contains a newer version of the Windows Installer service.</span></span>
<span class="line" id="L1951">    INSTALL_PACKAGE_VERSION = <span class="tok-number">1613</span>,</span>
<span class="line" id="L1952">    <span class="tok-comment">/// Product is uninstalled.</span></span>
<span class="line" id="L1953">    PRODUCT_UNINSTALLED = <span class="tok-number">1614</span>,</span>
<span class="line" id="L1954">    <span class="tok-comment">/// SQL query syntax invalid or unsupported.</span></span>
<span class="line" id="L1955">    BAD_QUERY_SYNTAX = <span class="tok-number">1615</span>,</span>
<span class="line" id="L1956">    <span class="tok-comment">/// Record field does not exist.</span></span>
<span class="line" id="L1957">    INVALID_FIELD = <span class="tok-number">1616</span>,</span>
<span class="line" id="L1958">    <span class="tok-comment">/// The device has been removed.</span></span>
<span class="line" id="L1959">    DEVICE_REMOVED = <span class="tok-number">1617</span>,</span>
<span class="line" id="L1960">    <span class="tok-comment">/// Another installation is already in progress.</span></span>
<span class="line" id="L1961">    <span class="tok-comment">/// Complete that installation before proceeding with this install.</span></span>
<span class="line" id="L1962">    INSTALL_ALREADY_RUNNING = <span class="tok-number">1618</span>,</span>
<span class="line" id="L1963">    <span class="tok-comment">/// This installation package could not be opened.</span></span>
<span class="line" id="L1964">    <span class="tok-comment">/// Verify that the package exists and that you can access it, or contact the application vendor to verify that this is a valid Windows Installer package.</span></span>
<span class="line" id="L1965">    INSTALL_PACKAGE_OPEN_FAILED = <span class="tok-number">1619</span>,</span>
<span class="line" id="L1966">    <span class="tok-comment">/// This installation package could not be opened.</span></span>
<span class="line" id="L1967">    <span class="tok-comment">/// Contact the application vendor to verify that this is a valid Windows Installer package.</span></span>
<span class="line" id="L1968">    INSTALL_PACKAGE_INVALID = <span class="tok-number">1620</span>,</span>
<span class="line" id="L1969">    <span class="tok-comment">/// There was an error starting the Windows Installer service user interface. Contact your support personnel.</span></span>
<span class="line" id="L1970">    INSTALL_UI_FAILURE = <span class="tok-number">1621</span>,</span>
<span class="line" id="L1971">    <span class="tok-comment">/// Error opening installation log file.</span></span>
<span class="line" id="L1972">    <span class="tok-comment">/// Verify that the specified log file location exists and that you can write to it.</span></span>
<span class="line" id="L1973">    INSTALL_LOG_FAILURE = <span class="tok-number">1622</span>,</span>
<span class="line" id="L1974">    <span class="tok-comment">/// The language of this installation package is not supported by your system.</span></span>
<span class="line" id="L1975">    INSTALL_LANGUAGE_UNSUPPORTED = <span class="tok-number">1623</span>,</span>
<span class="line" id="L1976">    <span class="tok-comment">/// Error applying transforms. Verify that the specified transform paths are valid.</span></span>
<span class="line" id="L1977">    INSTALL_TRANSFORM_FAILURE = <span class="tok-number">1624</span>,</span>
<span class="line" id="L1978">    <span class="tok-comment">/// This installation is forbidden by system policy. Contact your system administrator.</span></span>
<span class="line" id="L1979">    INSTALL_PACKAGE_REJECTED = <span class="tok-number">1625</span>,</span>
<span class="line" id="L1980">    <span class="tok-comment">/// Function could not be executed.</span></span>
<span class="line" id="L1981">    FUNCTION_NOT_CALLED = <span class="tok-number">1626</span>,</span>
<span class="line" id="L1982">    <span class="tok-comment">/// Function failed during execution.</span></span>
<span class="line" id="L1983">    FUNCTION_FAILED = <span class="tok-number">1627</span>,</span>
<span class="line" id="L1984">    <span class="tok-comment">/// Invalid or unknown table specified.</span></span>
<span class="line" id="L1985">    INVALID_TABLE = <span class="tok-number">1628</span>,</span>
<span class="line" id="L1986">    <span class="tok-comment">/// Data supplied is of wrong type.</span></span>
<span class="line" id="L1987">    DATATYPE_MISMATCH = <span class="tok-number">1629</span>,</span>
<span class="line" id="L1988">    <span class="tok-comment">/// Data of this type is not supported.</span></span>
<span class="line" id="L1989">    UNSUPPORTED_TYPE = <span class="tok-number">1630</span>,</span>
<span class="line" id="L1990">    <span class="tok-comment">/// The Windows Installer service failed to start. Contact your support personnel.</span></span>
<span class="line" id="L1991">    CREATE_FAILED = <span class="tok-number">1631</span>,</span>
<span class="line" id="L1992">    <span class="tok-comment">/// The Temp folder is on a drive that is full or is inaccessible.</span></span>
<span class="line" id="L1993">    <span class="tok-comment">/// Free up space on the drive or verify that you have write permission on the Temp folder.</span></span>
<span class="line" id="L1994">    INSTALL_TEMP_UNWRITABLE = <span class="tok-number">1632</span>,</span>
<span class="line" id="L1995">    <span class="tok-comment">/// This installation package is not supported by this processor type. Contact your product vendor.</span></span>
<span class="line" id="L1996">    INSTALL_PLATFORM_UNSUPPORTED = <span class="tok-number">1633</span>,</span>
<span class="line" id="L1997">    <span class="tok-comment">/// Component not used on this computer.</span></span>
<span class="line" id="L1998">    INSTALL_NOTUSED = <span class="tok-number">1634</span>,</span>
<span class="line" id="L1999">    <span class="tok-comment">/// This update package could not be opened.</span></span>
<span class="line" id="L2000">    <span class="tok-comment">/// Verify that the update package exists and that you can access it, or contact the application vendor to verify that this is a valid Windows Installer update package.</span></span>
<span class="line" id="L2001">    PATCH_PACKAGE_OPEN_FAILED = <span class="tok-number">1635</span>,</span>
<span class="line" id="L2002">    <span class="tok-comment">/// This update package could not be opened.</span></span>
<span class="line" id="L2003">    <span class="tok-comment">/// Contact the application vendor to verify that this is a valid Windows Installer update package.</span></span>
<span class="line" id="L2004">    PATCH_PACKAGE_INVALID = <span class="tok-number">1636</span>,</span>
<span class="line" id="L2005">    <span class="tok-comment">/// This update package cannot be processed by the Windows Installer service.</span></span>
<span class="line" id="L2006">    <span class="tok-comment">/// You must install a Windows service pack that contains a newer version of the Windows Installer service.</span></span>
<span class="line" id="L2007">    PATCH_PACKAGE_UNSUPPORTED = <span class="tok-number">1637</span>,</span>
<span class="line" id="L2008">    <span class="tok-comment">/// Another version of this product is already installed. Installation of this version cannot continue.</span></span>
<span class="line" id="L2009">    <span class="tok-comment">/// To configure or remove the existing version of this product, use Add/Remove Programs on the Control Panel.</span></span>
<span class="line" id="L2010">    PRODUCT_VERSION = <span class="tok-number">1638</span>,</span>
<span class="line" id="L2011">    <span class="tok-comment">/// Invalid command line argument. Consult the Windows Installer SDK for detailed command line help.</span></span>
<span class="line" id="L2012">    INVALID_COMMAND_LINE = <span class="tok-number">1639</span>,</span>
<span class="line" id="L2013">    <span class="tok-comment">/// Only administrators have permission to add, remove, or configure server software during a Terminal services remote session.</span></span>
<span class="line" id="L2014">    <span class="tok-comment">/// If you want to install or configure software on the server, contact your network administrator.</span></span>
<span class="line" id="L2015">    INSTALL_REMOTE_DISALLOWED = <span class="tok-number">1640</span>,</span>
<span class="line" id="L2016">    <span class="tok-comment">/// The requested operation completed successfully.</span></span>
<span class="line" id="L2017">    <span class="tok-comment">/// The system will be restarted so the changes can take effect.</span></span>
<span class="line" id="L2018">    SUCCESS_REBOOT_INITIATED = <span class="tok-number">1641</span>,</span>
<span class="line" id="L2019">    <span class="tok-comment">/// The upgrade cannot be installed by the Windows Installer service because the program to be upgraded may be missing, or the upgrade may update a different version of the program.</span></span>
<span class="line" id="L2020">    <span class="tok-comment">/// Verify that the program to be upgraded exists on your computer and that you have the correct upgrade.</span></span>
<span class="line" id="L2021">    PATCH_TARGET_NOT_FOUND = <span class="tok-number">1642</span>,</span>
<span class="line" id="L2022">    <span class="tok-comment">/// The update package is not permitted by software restriction policy.</span></span>
<span class="line" id="L2023">    PATCH_PACKAGE_REJECTED = <span class="tok-number">1643</span>,</span>
<span class="line" id="L2024">    <span class="tok-comment">/// One or more customizations are not permitted by software restriction policy.</span></span>
<span class="line" id="L2025">    INSTALL_TRANSFORM_REJECTED = <span class="tok-number">1644</span>,</span>
<span class="line" id="L2026">    <span class="tok-comment">/// The Windows Installer does not permit installation from a Remote Desktop Connection.</span></span>
<span class="line" id="L2027">    INSTALL_REMOTE_PROHIBITED = <span class="tok-number">1645</span>,</span>
<span class="line" id="L2028">    <span class="tok-comment">/// Uninstallation of the update package is not supported.</span></span>
<span class="line" id="L2029">    PATCH_REMOVAL_UNSUPPORTED = <span class="tok-number">1646</span>,</span>
<span class="line" id="L2030">    <span class="tok-comment">/// The update is not applied to this product.</span></span>
<span class="line" id="L2031">    UNKNOWN_PATCH = <span class="tok-number">1647</span>,</span>
<span class="line" id="L2032">    <span class="tok-comment">/// No valid sequence could be found for the set of updates.</span></span>
<span class="line" id="L2033">    PATCH_NO_SEQUENCE = <span class="tok-number">1648</span>,</span>
<span class="line" id="L2034">    <span class="tok-comment">/// Update removal was disallowed by policy.</span></span>
<span class="line" id="L2035">    PATCH_REMOVAL_DISALLOWED = <span class="tok-number">1649</span>,</span>
<span class="line" id="L2036">    <span class="tok-comment">/// The XML update data is invalid.</span></span>
<span class="line" id="L2037">    INVALID_PATCH_XML = <span class="tok-number">1650</span>,</span>
<span class="line" id="L2038">    <span class="tok-comment">/// Windows Installer does not permit updating of managed advertised products.</span></span>
<span class="line" id="L2039">    <span class="tok-comment">/// At least one feature of the product must be installed before applying the update.</span></span>
<span class="line" id="L2040">    PATCH_MANAGED_ADVERTISED_PRODUCT = <span class="tok-number">1651</span>,</span>
<span class="line" id="L2041">    <span class="tok-comment">/// The Windows Installer service is not accessible in Safe Mode.</span></span>
<span class="line" id="L2042">    <span class="tok-comment">/// Please try again when your computer is not in Safe Mode or you can use System Restore to return your machine to a previous good state.</span></span>
<span class="line" id="L2043">    INSTALL_SERVICE_SAFEBOOT = <span class="tok-number">1652</span>,</span>
<span class="line" id="L2044">    <span class="tok-comment">/// A fail fast exception occurred.</span></span>
<span class="line" id="L2045">    <span class="tok-comment">/// Exception handlers will not be invoked and the process will be terminated immediately.</span></span>
<span class="line" id="L2046">    FAIL_FAST_EXCEPTION = <span class="tok-number">1653</span>,</span>
<span class="line" id="L2047">    <span class="tok-comment">/// The app that you are trying to run is not supported on this version of Windows.</span></span>
<span class="line" id="L2048">    INSTALL_REJECTED = <span class="tok-number">1654</span>,</span>
<span class="line" id="L2049">    <span class="tok-comment">/// The string binding is invalid.</span></span>
<span class="line" id="L2050">    RPC_S_INVALID_STRING_BINDING = <span class="tok-number">1700</span>,</span>
<span class="line" id="L2051">    <span class="tok-comment">/// The binding handle is not the correct type.</span></span>
<span class="line" id="L2052">    RPC_S_WRONG_KIND_OF_BINDING = <span class="tok-number">1701</span>,</span>
<span class="line" id="L2053">    <span class="tok-comment">/// The binding handle is invalid.</span></span>
<span class="line" id="L2054">    RPC_S_INVALID_BINDING = <span class="tok-number">1702</span>,</span>
<span class="line" id="L2055">    <span class="tok-comment">/// The RPC protocol sequence is not supported.</span></span>
<span class="line" id="L2056">    RPC_S_PROTSEQ_NOT_SUPPORTED = <span class="tok-number">1703</span>,</span>
<span class="line" id="L2057">    <span class="tok-comment">/// The RPC protocol sequence is invalid.</span></span>
<span class="line" id="L2058">    RPC_S_INVALID_RPC_PROTSEQ = <span class="tok-number">1704</span>,</span>
<span class="line" id="L2059">    <span class="tok-comment">/// The string universal unique identifier (UUID) is invalid.</span></span>
<span class="line" id="L2060">    RPC_S_INVALID_STRING_UUID = <span class="tok-number">1705</span>,</span>
<span class="line" id="L2061">    <span class="tok-comment">/// The endpoint format is invalid.</span></span>
<span class="line" id="L2062">    RPC_S_INVALID_ENDPOINT_FORMAT = <span class="tok-number">1706</span>,</span>
<span class="line" id="L2063">    <span class="tok-comment">/// The network address is invalid.</span></span>
<span class="line" id="L2064">    RPC_S_INVALID_NET_ADDR = <span class="tok-number">1707</span>,</span>
<span class="line" id="L2065">    <span class="tok-comment">/// No endpoint was found.</span></span>
<span class="line" id="L2066">    RPC_S_NO_ENDPOINT_FOUND = <span class="tok-number">1708</span>,</span>
<span class="line" id="L2067">    <span class="tok-comment">/// The timeout value is invalid.</span></span>
<span class="line" id="L2068">    RPC_S_INVALID_TIMEOUT = <span class="tok-number">1709</span>,</span>
<span class="line" id="L2069">    <span class="tok-comment">/// The object universal unique identifier (UUID) was not found.</span></span>
<span class="line" id="L2070">    RPC_S_OBJECT_NOT_FOUND = <span class="tok-number">1710</span>,</span>
<span class="line" id="L2071">    <span class="tok-comment">/// The object universal unique identifier (UUID) has already been registered.</span></span>
<span class="line" id="L2072">    RPC_S_ALREADY_REGISTERED = <span class="tok-number">1711</span>,</span>
<span class="line" id="L2073">    <span class="tok-comment">/// The type universal unique identifier (UUID) has already been registered.</span></span>
<span class="line" id="L2074">    RPC_S_TYPE_ALREADY_REGISTERED = <span class="tok-number">1712</span>,</span>
<span class="line" id="L2075">    <span class="tok-comment">/// The RPC server is already listening.</span></span>
<span class="line" id="L2076">    RPC_S_ALREADY_LISTENING = <span class="tok-number">1713</span>,</span>
<span class="line" id="L2077">    <span class="tok-comment">/// No protocol sequences have been registered.</span></span>
<span class="line" id="L2078">    RPC_S_NO_PROTSEQS_REGISTERED = <span class="tok-number">1714</span>,</span>
<span class="line" id="L2079">    <span class="tok-comment">/// The RPC server is not listening.</span></span>
<span class="line" id="L2080">    RPC_S_NOT_LISTENING = <span class="tok-number">1715</span>,</span>
<span class="line" id="L2081">    <span class="tok-comment">/// The manager type is unknown.</span></span>
<span class="line" id="L2082">    RPC_S_UNKNOWN_MGR_TYPE = <span class="tok-number">1716</span>,</span>
<span class="line" id="L2083">    <span class="tok-comment">/// The interface is unknown.</span></span>
<span class="line" id="L2084">    RPC_S_UNKNOWN_IF = <span class="tok-number">1717</span>,</span>
<span class="line" id="L2085">    <span class="tok-comment">/// There are no bindings.</span></span>
<span class="line" id="L2086">    RPC_S_NO_BINDINGS = <span class="tok-number">1718</span>,</span>
<span class="line" id="L2087">    <span class="tok-comment">/// There are no protocol sequences.</span></span>
<span class="line" id="L2088">    RPC_S_NO_PROTSEQS = <span class="tok-number">1719</span>,</span>
<span class="line" id="L2089">    <span class="tok-comment">/// The endpoint cannot be created.</span></span>
<span class="line" id="L2090">    RPC_S_CANT_CREATE_ENDPOINT = <span class="tok-number">1720</span>,</span>
<span class="line" id="L2091">    <span class="tok-comment">/// Not enough resources are available to complete this operation.</span></span>
<span class="line" id="L2092">    RPC_S_OUT_OF_RESOURCES = <span class="tok-number">1721</span>,</span>
<span class="line" id="L2093">    <span class="tok-comment">/// The RPC server is unavailable.</span></span>
<span class="line" id="L2094">    RPC_S_SERVER_UNAVAILABLE = <span class="tok-number">1722</span>,</span>
<span class="line" id="L2095">    <span class="tok-comment">/// The RPC server is too busy to complete this operation.</span></span>
<span class="line" id="L2096">    RPC_S_SERVER_TOO_BUSY = <span class="tok-number">1723</span>,</span>
<span class="line" id="L2097">    <span class="tok-comment">/// The network options are invalid.</span></span>
<span class="line" id="L2098">    RPC_S_INVALID_NETWORK_OPTIONS = <span class="tok-number">1724</span>,</span>
<span class="line" id="L2099">    <span class="tok-comment">/// There are no remote procedure calls active on this thread.</span></span>
<span class="line" id="L2100">    RPC_S_NO_CALL_ACTIVE = <span class="tok-number">1725</span>,</span>
<span class="line" id="L2101">    <span class="tok-comment">/// The remote procedure call failed.</span></span>
<span class="line" id="L2102">    RPC_S_CALL_FAILED = <span class="tok-number">1726</span>,</span>
<span class="line" id="L2103">    <span class="tok-comment">/// The remote procedure call failed and did not execute.</span></span>
<span class="line" id="L2104">    RPC_S_CALL_FAILED_DNE = <span class="tok-number">1727</span>,</span>
<span class="line" id="L2105">    <span class="tok-comment">/// A remote procedure call (RPC) protocol error occurred.</span></span>
<span class="line" id="L2106">    RPC_S_PROTOCOL_ERROR = <span class="tok-number">1728</span>,</span>
<span class="line" id="L2107">    <span class="tok-comment">/// Access to the HTTP proxy is denied.</span></span>
<span class="line" id="L2108">    RPC_S_PROXY_ACCESS_DENIED = <span class="tok-number">1729</span>,</span>
<span class="line" id="L2109">    <span class="tok-comment">/// The transfer syntax is not supported by the RPC server.</span></span>
<span class="line" id="L2110">    RPC_S_UNSUPPORTED_TRANS_SYN = <span class="tok-number">1730</span>,</span>
<span class="line" id="L2111">    <span class="tok-comment">/// The universal unique identifier (UUID) type is not supported.</span></span>
<span class="line" id="L2112">    RPC_S_UNSUPPORTED_TYPE = <span class="tok-number">1732</span>,</span>
<span class="line" id="L2113">    <span class="tok-comment">/// The tag is invalid.</span></span>
<span class="line" id="L2114">    RPC_S_INVALID_TAG = <span class="tok-number">1733</span>,</span>
<span class="line" id="L2115">    <span class="tok-comment">/// The array bounds are invalid.</span></span>
<span class="line" id="L2116">    RPC_S_INVALID_BOUND = <span class="tok-number">1734</span>,</span>
<span class="line" id="L2117">    <span class="tok-comment">/// The binding does not contain an entry name.</span></span>
<span class="line" id="L2118">    RPC_S_NO_ENTRY_NAME = <span class="tok-number">1735</span>,</span>
<span class="line" id="L2119">    <span class="tok-comment">/// The name syntax is invalid.</span></span>
<span class="line" id="L2120">    RPC_S_INVALID_NAME_SYNTAX = <span class="tok-number">1736</span>,</span>
<span class="line" id="L2121">    <span class="tok-comment">/// The name syntax is not supported.</span></span>
<span class="line" id="L2122">    RPC_S_UNSUPPORTED_NAME_SYNTAX = <span class="tok-number">1737</span>,</span>
<span class="line" id="L2123">    <span class="tok-comment">/// No network address is available to use to construct a universal unique identifier (UUID).</span></span>
<span class="line" id="L2124">    RPC_S_UUID_NO_ADDRESS = <span class="tok-number">1739</span>,</span>
<span class="line" id="L2125">    <span class="tok-comment">/// The endpoint is a duplicate.</span></span>
<span class="line" id="L2126">    RPC_S_DUPLICATE_ENDPOINT = <span class="tok-number">1740</span>,</span>
<span class="line" id="L2127">    <span class="tok-comment">/// The authentication type is unknown.</span></span>
<span class="line" id="L2128">    RPC_S_UNKNOWN_AUTHN_TYPE = <span class="tok-number">1741</span>,</span>
<span class="line" id="L2129">    <span class="tok-comment">/// The maximum number of calls is too small.</span></span>
<span class="line" id="L2130">    RPC_S_MAX_CALLS_TOO_SMALL = <span class="tok-number">1742</span>,</span>
<span class="line" id="L2131">    <span class="tok-comment">/// The string is too long.</span></span>
<span class="line" id="L2132">    RPC_S_STRING_TOO_LONG = <span class="tok-number">1743</span>,</span>
<span class="line" id="L2133">    <span class="tok-comment">/// The RPC protocol sequence was not found.</span></span>
<span class="line" id="L2134">    RPC_S_PROTSEQ_NOT_FOUND = <span class="tok-number">1744</span>,</span>
<span class="line" id="L2135">    <span class="tok-comment">/// The procedure number is out of range.</span></span>
<span class="line" id="L2136">    RPC_S_PROCNUM_OUT_OF_RANGE = <span class="tok-number">1745</span>,</span>
<span class="line" id="L2137">    <span class="tok-comment">/// The binding does not contain any authentication information.</span></span>
<span class="line" id="L2138">    RPC_S_BINDING_HAS_NO_AUTH = <span class="tok-number">1746</span>,</span>
<span class="line" id="L2139">    <span class="tok-comment">/// The authentication service is unknown.</span></span>
<span class="line" id="L2140">    RPC_S_UNKNOWN_AUTHN_SERVICE = <span class="tok-number">1747</span>,</span>
<span class="line" id="L2141">    <span class="tok-comment">/// The authentication level is unknown.</span></span>
<span class="line" id="L2142">    RPC_S_UNKNOWN_AUTHN_LEVEL = <span class="tok-number">1748</span>,</span>
<span class="line" id="L2143">    <span class="tok-comment">/// The security context is invalid.</span></span>
<span class="line" id="L2144">    RPC_S_INVALID_AUTH_IDENTITY = <span class="tok-number">1749</span>,</span>
<span class="line" id="L2145">    <span class="tok-comment">/// The authorization service is unknown.</span></span>
<span class="line" id="L2146">    RPC_S_UNKNOWN_AUTHZ_SERVICE = <span class="tok-number">1750</span>,</span>
<span class="line" id="L2147">    <span class="tok-comment">/// The entry is invalid.</span></span>
<span class="line" id="L2148">    EPT_S_INVALID_ENTRY = <span class="tok-number">1751</span>,</span>
<span class="line" id="L2149">    <span class="tok-comment">/// The server endpoint cannot perform the operation.</span></span>
<span class="line" id="L2150">    EPT_S_CANT_PERFORM_OP = <span class="tok-number">1752</span>,</span>
<span class="line" id="L2151">    <span class="tok-comment">/// There are no more endpoints available from the endpoint mapper.</span></span>
<span class="line" id="L2152">    EPT_S_NOT_REGISTERED = <span class="tok-number">1753</span>,</span>
<span class="line" id="L2153">    <span class="tok-comment">/// No interfaces have been exported.</span></span>
<span class="line" id="L2154">    RPC_S_NOTHING_TO_EXPORT = <span class="tok-number">1754</span>,</span>
<span class="line" id="L2155">    <span class="tok-comment">/// The entry name is incomplete.</span></span>
<span class="line" id="L2156">    RPC_S_INCOMPLETE_NAME = <span class="tok-number">1755</span>,</span>
<span class="line" id="L2157">    <span class="tok-comment">/// The version option is invalid.</span></span>
<span class="line" id="L2158">    RPC_S_INVALID_VERS_OPTION = <span class="tok-number">1756</span>,</span>
<span class="line" id="L2159">    <span class="tok-comment">/// There are no more members.</span></span>
<span class="line" id="L2160">    RPC_S_NO_MORE_MEMBERS = <span class="tok-number">1757</span>,</span>
<span class="line" id="L2161">    <span class="tok-comment">/// There is nothing to unexport.</span></span>
<span class="line" id="L2162">    RPC_S_NOT_ALL_OBJS_UNEXPORTED = <span class="tok-number">1758</span>,</span>
<span class="line" id="L2163">    <span class="tok-comment">/// The interface was not found.</span></span>
<span class="line" id="L2164">    RPC_S_INTERFACE_NOT_FOUND = <span class="tok-number">1759</span>,</span>
<span class="line" id="L2165">    <span class="tok-comment">/// The entry already exists.</span></span>
<span class="line" id="L2166">    RPC_S_ENTRY_ALREADY_EXISTS = <span class="tok-number">1760</span>,</span>
<span class="line" id="L2167">    <span class="tok-comment">/// The entry is not found.</span></span>
<span class="line" id="L2168">    RPC_S_ENTRY_NOT_FOUND = <span class="tok-number">1761</span>,</span>
<span class="line" id="L2169">    <span class="tok-comment">/// The name service is unavailable.</span></span>
<span class="line" id="L2170">    RPC_S_NAME_SERVICE_UNAVAILABLE = <span class="tok-number">1762</span>,</span>
<span class="line" id="L2171">    <span class="tok-comment">/// The network address family is invalid.</span></span>
<span class="line" id="L2172">    RPC_S_INVALID_NAF_ID = <span class="tok-number">1763</span>,</span>
<span class="line" id="L2173">    <span class="tok-comment">/// The requested operation is not supported.</span></span>
<span class="line" id="L2174">    RPC_S_CANNOT_SUPPORT = <span class="tok-number">1764</span>,</span>
<span class="line" id="L2175">    <span class="tok-comment">/// No security context is available to allow impersonation.</span></span>
<span class="line" id="L2176">    RPC_S_NO_CONTEXT_AVAILABLE = <span class="tok-number">1765</span>,</span>
<span class="line" id="L2177">    <span class="tok-comment">/// An internal error occurred in a remote procedure call (RPC).</span></span>
<span class="line" id="L2178">    RPC_S_INTERNAL_ERROR = <span class="tok-number">1766</span>,</span>
<span class="line" id="L2179">    <span class="tok-comment">/// The RPC server attempted an integer division by zero.</span></span>
<span class="line" id="L2180">    RPC_S_ZERO_DIVIDE = <span class="tok-number">1767</span>,</span>
<span class="line" id="L2181">    <span class="tok-comment">/// An addressing error occurred in the RPC server.</span></span>
<span class="line" id="L2182">    RPC_S_ADDRESS_ERROR = <span class="tok-number">1768</span>,</span>
<span class="line" id="L2183">    <span class="tok-comment">/// A floating-point operation at the RPC server caused a division by zero.</span></span>
<span class="line" id="L2184">    RPC_S_FP_DIV_ZERO = <span class="tok-number">1769</span>,</span>
<span class="line" id="L2185">    <span class="tok-comment">/// A floating-point underflow occurred at the RPC server.</span></span>
<span class="line" id="L2186">    RPC_S_FP_UNDERFLOW = <span class="tok-number">1770</span>,</span>
<span class="line" id="L2187">    <span class="tok-comment">/// A floating-point overflow occurred at the RPC server.</span></span>
<span class="line" id="L2188">    RPC_S_FP_OVERFLOW = <span class="tok-number">1771</span>,</span>
<span class="line" id="L2189">    <span class="tok-comment">/// The list of RPC servers available for the binding of auto handles has been exhausted.</span></span>
<span class="line" id="L2190">    RPC_X_NO_MORE_ENTRIES = <span class="tok-number">1772</span>,</span>
<span class="line" id="L2191">    <span class="tok-comment">/// Unable to open the character translation table file.</span></span>
<span class="line" id="L2192">    RPC_X_SS_CHAR_TRANS_OPEN_FAIL = <span class="tok-number">1773</span>,</span>
<span class="line" id="L2193">    <span class="tok-comment">/// The file containing the character translation table has fewer than 512 bytes.</span></span>
<span class="line" id="L2194">    RPC_X_SS_CHAR_TRANS_SHORT_FILE = <span class="tok-number">1774</span>,</span>
<span class="line" id="L2195">    <span class="tok-comment">/// A null context handle was passed from the client to the host during a remote procedure call.</span></span>
<span class="line" id="L2196">    RPC_X_SS_IN_NULL_CONTEXT = <span class="tok-number">1775</span>,</span>
<span class="line" id="L2197">    <span class="tok-comment">/// The context handle changed during a remote procedure call.</span></span>
<span class="line" id="L2198">    RPC_X_SS_CONTEXT_DAMAGED = <span class="tok-number">1777</span>,</span>
<span class="line" id="L2199">    <span class="tok-comment">/// The binding handles passed to a remote procedure call do not match.</span></span>
<span class="line" id="L2200">    RPC_X_SS_HANDLES_MISMATCH = <span class="tok-number">1778</span>,</span>
<span class="line" id="L2201">    <span class="tok-comment">/// The stub is unable to get the remote procedure call handle.</span></span>
<span class="line" id="L2202">    RPC_X_SS_CANNOT_GET_CALL_HANDLE = <span class="tok-number">1779</span>,</span>
<span class="line" id="L2203">    <span class="tok-comment">/// A null reference pointer was passed to the stub.</span></span>
<span class="line" id="L2204">    RPC_X_NULL_REF_POINTER = <span class="tok-number">1780</span>,</span>
<span class="line" id="L2205">    <span class="tok-comment">/// The enumeration value is out of range.</span></span>
<span class="line" id="L2206">    RPC_X_ENUM_VALUE_OUT_OF_RANGE = <span class="tok-number">1781</span>,</span>
<span class="line" id="L2207">    <span class="tok-comment">/// The byte count is too small.</span></span>
<span class="line" id="L2208">    RPC_X_BYTE_COUNT_TOO_SMALL = <span class="tok-number">1782</span>,</span>
<span class="line" id="L2209">    <span class="tok-comment">/// The stub received bad data.</span></span>
<span class="line" id="L2210">    RPC_X_BAD_STUB_DATA = <span class="tok-number">1783</span>,</span>
<span class="line" id="L2211">    <span class="tok-comment">/// The supplied user buffer is not valid for the requested operation.</span></span>
<span class="line" id="L2212">    INVALID_USER_BUFFER = <span class="tok-number">1784</span>,</span>
<span class="line" id="L2213">    <span class="tok-comment">/// The disk media is not recognized. It may not be formatted.</span></span>
<span class="line" id="L2214">    UNRECOGNIZED_MEDIA = <span class="tok-number">1785</span>,</span>
<span class="line" id="L2215">    <span class="tok-comment">/// The workstation does not have a trust secret.</span></span>
<span class="line" id="L2216">    NO_TRUST_LSA_SECRET = <span class="tok-number">1786</span>,</span>
<span class="line" id="L2217">    <span class="tok-comment">/// The security database on the server does not have a computer account for this workstation trust relationship.</span></span>
<span class="line" id="L2218">    NO_TRUST_SAM_ACCOUNT = <span class="tok-number">1787</span>,</span>
<span class="line" id="L2219">    <span class="tok-comment">/// The trust relationship between the primary domain and the trusted domain failed.</span></span>
<span class="line" id="L2220">    TRUSTED_DOMAIN_FAILURE = <span class="tok-number">1788</span>,</span>
<span class="line" id="L2221">    <span class="tok-comment">/// The trust relationship between this workstation and the primary domain failed.</span></span>
<span class="line" id="L2222">    TRUSTED_RELATIONSHIP_FAILURE = <span class="tok-number">1789</span>,</span>
<span class="line" id="L2223">    <span class="tok-comment">/// The network logon failed.</span></span>
<span class="line" id="L2224">    TRUST_FAILURE = <span class="tok-number">1790</span>,</span>
<span class="line" id="L2225">    <span class="tok-comment">/// A remote procedure call is already in progress for this thread.</span></span>
<span class="line" id="L2226">    RPC_S_CALL_IN_PROGRESS = <span class="tok-number">1791</span>,</span>
<span class="line" id="L2227">    <span class="tok-comment">/// An attempt was made to logon, but the network logon service was not started.</span></span>
<span class="line" id="L2228">    NETLOGON_NOT_STARTED = <span class="tok-number">1792</span>,</span>
<span class="line" id="L2229">    <span class="tok-comment">/// The user's account has expired.</span></span>
<span class="line" id="L2230">    ACCOUNT_EXPIRED = <span class="tok-number">1793</span>,</span>
<span class="line" id="L2231">    <span class="tok-comment">/// The redirector is in use and cannot be unloaded.</span></span>
<span class="line" id="L2232">    REDIRECTOR_HAS_OPEN_HANDLES = <span class="tok-number">1794</span>,</span>
<span class="line" id="L2233">    <span class="tok-comment">/// The specified printer driver is already installed.</span></span>
<span class="line" id="L2234">    PRINTER_DRIVER_ALREADY_INSTALLED = <span class="tok-number">1795</span>,</span>
<span class="line" id="L2235">    <span class="tok-comment">/// The specified port is unknown.</span></span>
<span class="line" id="L2236">    UNKNOWN_PORT = <span class="tok-number">1796</span>,</span>
<span class="line" id="L2237">    <span class="tok-comment">/// The printer driver is unknown.</span></span>
<span class="line" id="L2238">    UNKNOWN_PRINTER_DRIVER = <span class="tok-number">1797</span>,</span>
<span class="line" id="L2239">    <span class="tok-comment">/// The print processor is unknown.</span></span>
<span class="line" id="L2240">    UNKNOWN_PRINTPROCESSOR = <span class="tok-number">1798</span>,</span>
<span class="line" id="L2241">    <span class="tok-comment">/// The specified separator file is invalid.</span></span>
<span class="line" id="L2242">    INVALID_SEPARATOR_FILE = <span class="tok-number">1799</span>,</span>
<span class="line" id="L2243">    <span class="tok-comment">/// The specified priority is invalid.</span></span>
<span class="line" id="L2244">    INVALID_PRIORITY = <span class="tok-number">1800</span>,</span>
<span class="line" id="L2245">    <span class="tok-comment">/// The printer name is invalid.</span></span>
<span class="line" id="L2246">    INVALID_PRINTER_NAME = <span class="tok-number">1801</span>,</span>
<span class="line" id="L2247">    <span class="tok-comment">/// The printer already exists.</span></span>
<span class="line" id="L2248">    PRINTER_ALREADY_EXISTS = <span class="tok-number">1802</span>,</span>
<span class="line" id="L2249">    <span class="tok-comment">/// The printer command is invalid.</span></span>
<span class="line" id="L2250">    INVALID_PRINTER_COMMAND = <span class="tok-number">1803</span>,</span>
<span class="line" id="L2251">    <span class="tok-comment">/// The specified datatype is invalid.</span></span>
<span class="line" id="L2252">    INVALID_DATATYPE = <span class="tok-number">1804</span>,</span>
<span class="line" id="L2253">    <span class="tok-comment">/// The environment specified is invalid.</span></span>
<span class="line" id="L2254">    INVALID_ENVIRONMENT = <span class="tok-number">1805</span>,</span>
<span class="line" id="L2255">    <span class="tok-comment">/// There are no more bindings.</span></span>
<span class="line" id="L2256">    RPC_S_NO_MORE_BINDINGS = <span class="tok-number">1806</span>,</span>
<span class="line" id="L2257">    <span class="tok-comment">/// The account used is an interdomain trust account.</span></span>
<span class="line" id="L2258">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L2259">    NOLOGON_INTERDOMAIN_TRUST_ACCOUNT = <span class="tok-number">1807</span>,</span>
<span class="line" id="L2260">    <span class="tok-comment">/// The account used is a computer account.</span></span>
<span class="line" id="L2261">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L2262">    NOLOGON_WORKSTATION_TRUST_ACCOUNT = <span class="tok-number">1808</span>,</span>
<span class="line" id="L2263">    <span class="tok-comment">/// The account used is a server trust account.</span></span>
<span class="line" id="L2264">    <span class="tok-comment">/// Use your global user account or local user account to access this server.</span></span>
<span class="line" id="L2265">    NOLOGON_SERVER_TRUST_ACCOUNT = <span class="tok-number">1809</span>,</span>
<span class="line" id="L2266">    <span class="tok-comment">/// The name or security ID (SID) of the domain specified is inconsistent with the trust information for that domain.</span></span>
<span class="line" id="L2267">    DOMAIN_TRUST_INCONSISTENT = <span class="tok-number">1810</span>,</span>
<span class="line" id="L2268">    <span class="tok-comment">/// The server is in use and cannot be unloaded.</span></span>
<span class="line" id="L2269">    SERVER_HAS_OPEN_HANDLES = <span class="tok-number">1811</span>,</span>
<span class="line" id="L2270">    <span class="tok-comment">/// The specified image file did not contain a resource section.</span></span>
<span class="line" id="L2271">    RESOURCE_DATA_NOT_FOUND = <span class="tok-number">1812</span>,</span>
<span class="line" id="L2272">    <span class="tok-comment">/// The specified resource type cannot be found in the image file.</span></span>
<span class="line" id="L2273">    RESOURCE_TYPE_NOT_FOUND = <span class="tok-number">1813</span>,</span>
<span class="line" id="L2274">    <span class="tok-comment">/// The specified resource name cannot be found in the image file.</span></span>
<span class="line" id="L2275">    RESOURCE_NAME_NOT_FOUND = <span class="tok-number">1814</span>,</span>
<span class="line" id="L2276">    <span class="tok-comment">/// The specified resource language ID cannot be found in the image file.</span></span>
<span class="line" id="L2277">    RESOURCE_LANG_NOT_FOUND = <span class="tok-number">1815</span>,</span>
<span class="line" id="L2278">    <span class="tok-comment">/// Not enough quota is available to process this command.</span></span>
<span class="line" id="L2279">    NOT_ENOUGH_QUOTA = <span class="tok-number">1816</span>,</span>
<span class="line" id="L2280">    <span class="tok-comment">/// No interfaces have been registered.</span></span>
<span class="line" id="L2281">    RPC_S_NO_INTERFACES = <span class="tok-number">1817</span>,</span>
<span class="line" id="L2282">    <span class="tok-comment">/// The remote procedure call was cancelled.</span></span>
<span class="line" id="L2283">    RPC_S_CALL_CANCELLED = <span class="tok-number">1818</span>,</span>
<span class="line" id="L2284">    <span class="tok-comment">/// The binding handle does not contain all required information.</span></span>
<span class="line" id="L2285">    RPC_S_BINDING_INCOMPLETE = <span class="tok-number">1819</span>,</span>
<span class="line" id="L2286">    <span class="tok-comment">/// A communications failure occurred during a remote procedure call.</span></span>
<span class="line" id="L2287">    RPC_S_COMM_FAILURE = <span class="tok-number">1820</span>,</span>
<span class="line" id="L2288">    <span class="tok-comment">/// The requested authentication level is not supported.</span></span>
<span class="line" id="L2289">    RPC_S_UNSUPPORTED_AUTHN_LEVEL = <span class="tok-number">1821</span>,</span>
<span class="line" id="L2290">    <span class="tok-comment">/// No principal name registered.</span></span>
<span class="line" id="L2291">    RPC_S_NO_PRINC_NAME = <span class="tok-number">1822</span>,</span>
<span class="line" id="L2292">    <span class="tok-comment">/// The error specified is not a valid Windows RPC error code.</span></span>
<span class="line" id="L2293">    RPC_S_NOT_RPC_ERROR = <span class="tok-number">1823</span>,</span>
<span class="line" id="L2294">    <span class="tok-comment">/// A UUID that is valid only on this computer has been allocated.</span></span>
<span class="line" id="L2295">    RPC_S_UUID_LOCAL_ONLY = <span class="tok-number">1824</span>,</span>
<span class="line" id="L2296">    <span class="tok-comment">/// A security package specific error occurred.</span></span>
<span class="line" id="L2297">    RPC_S_SEC_PKG_ERROR = <span class="tok-number">1825</span>,</span>
<span class="line" id="L2298">    <span class="tok-comment">/// Thread is not canceled.</span></span>
<span class="line" id="L2299">    RPC_S_NOT_CANCELLED = <span class="tok-number">1826</span>,</span>
<span class="line" id="L2300">    <span class="tok-comment">/// Invalid operation on the encoding/decoding handle.</span></span>
<span class="line" id="L2301">    RPC_X_INVALID_ES_ACTION = <span class="tok-number">1827</span>,</span>
<span class="line" id="L2302">    <span class="tok-comment">/// Incompatible version of the serializing package.</span></span>
<span class="line" id="L2303">    RPC_X_WRONG_ES_VERSION = <span class="tok-number">1828</span>,</span>
<span class="line" id="L2304">    <span class="tok-comment">/// Incompatible version of the RPC stub.</span></span>
<span class="line" id="L2305">    RPC_X_WRONG_STUB_VERSION = <span class="tok-number">1829</span>,</span>
<span class="line" id="L2306">    <span class="tok-comment">/// The RPC pipe object is invalid or corrupted.</span></span>
<span class="line" id="L2307">    RPC_X_INVALID_PIPE_OBJECT = <span class="tok-number">1830</span>,</span>
<span class="line" id="L2308">    <span class="tok-comment">/// An invalid operation was attempted on an RPC pipe object.</span></span>
<span class="line" id="L2309">    RPC_X_WRONG_PIPE_ORDER = <span class="tok-number">1831</span>,</span>
<span class="line" id="L2310">    <span class="tok-comment">/// Unsupported RPC pipe version.</span></span>
<span class="line" id="L2311">    RPC_X_WRONG_PIPE_VERSION = <span class="tok-number">1832</span>,</span>
<span class="line" id="L2312">    <span class="tok-comment">/// HTTP proxy server rejected the connection because the cookie authentication failed.</span></span>
<span class="line" id="L2313">    RPC_S_COOKIE_AUTH_FAILED = <span class="tok-number">1833</span>,</span>
<span class="line" id="L2314">    <span class="tok-comment">/// The group member was not found.</span></span>
<span class="line" id="L2315">    RPC_S_GROUP_MEMBER_NOT_FOUND = <span class="tok-number">1898</span>,</span>
<span class="line" id="L2316">    <span class="tok-comment">/// The endpoint mapper database entry could not be created.</span></span>
<span class="line" id="L2317">    EPT_S_CANT_CREATE = <span class="tok-number">1899</span>,</span>
<span class="line" id="L2318">    <span class="tok-comment">/// The object universal unique identifier (UUID) is the nil UUID.</span></span>
<span class="line" id="L2319">    RPC_S_INVALID_OBJECT = <span class="tok-number">1900</span>,</span>
<span class="line" id="L2320">    <span class="tok-comment">/// The specified time is invalid.</span></span>
<span class="line" id="L2321">    INVALID_TIME = <span class="tok-number">1901</span>,</span>
<span class="line" id="L2322">    <span class="tok-comment">/// The specified form name is invalid.</span></span>
<span class="line" id="L2323">    INVALID_FORM_NAME = <span class="tok-number">1902</span>,</span>
<span class="line" id="L2324">    <span class="tok-comment">/// The specified form size is invalid.</span></span>
<span class="line" id="L2325">    INVALID_FORM_SIZE = <span class="tok-number">1903</span>,</span>
<span class="line" id="L2326">    <span class="tok-comment">/// The specified printer handle is already being waited on.</span></span>
<span class="line" id="L2327">    ALREADY_WAITING = <span class="tok-number">1904</span>,</span>
<span class="line" id="L2328">    <span class="tok-comment">/// The specified printer has been deleted.</span></span>
<span class="line" id="L2329">    PRINTER_DELETED = <span class="tok-number">1905</span>,</span>
<span class="line" id="L2330">    <span class="tok-comment">/// The state of the printer is invalid.</span></span>
<span class="line" id="L2331">    INVALID_PRINTER_STATE = <span class="tok-number">1906</span>,</span>
<span class="line" id="L2332">    <span class="tok-comment">/// The user's password must be changed before signing in.</span></span>
<span class="line" id="L2333">    PASSWORD_MUST_CHANGE = <span class="tok-number">1907</span>,</span>
<span class="line" id="L2334">    <span class="tok-comment">/// Could not find the domain controller for this domain.</span></span>
<span class="line" id="L2335">    DOMAIN_CONTROLLER_NOT_FOUND = <span class="tok-number">1908</span>,</span>
<span class="line" id="L2336">    <span class="tok-comment">/// The referenced account is currently locked out and may not be logged on to.</span></span>
<span class="line" id="L2337">    ACCOUNT_LOCKED_OUT = <span class="tok-number">1909</span>,</span>
<span class="line" id="L2338">    <span class="tok-comment">/// The object exporter specified was not found.</span></span>
<span class="line" id="L2339">    OR_INVALID_OXID = <span class="tok-number">1910</span>,</span>
<span class="line" id="L2340">    <span class="tok-comment">/// The object specified was not found.</span></span>
<span class="line" id="L2341">    OR_INVALID_OID = <span class="tok-number">1911</span>,</span>
<span class="line" id="L2342">    <span class="tok-comment">/// The object resolver set specified was not found.</span></span>
<span class="line" id="L2343">    OR_INVALID_SET = <span class="tok-number">1912</span>,</span>
<span class="line" id="L2344">    <span class="tok-comment">/// Some data remains to be sent in the request buffer.</span></span>
<span class="line" id="L2345">    RPC_S_SEND_INCOMPLETE = <span class="tok-number">1913</span>,</span>
<span class="line" id="L2346">    <span class="tok-comment">/// Invalid asynchronous remote procedure call handle.</span></span>
<span class="line" id="L2347">    RPC_S_INVALID_ASYNC_HANDLE = <span class="tok-number">1914</span>,</span>
<span class="line" id="L2348">    <span class="tok-comment">/// Invalid asynchronous RPC call handle for this operation.</span></span>
<span class="line" id="L2349">    RPC_S_INVALID_ASYNC_CALL = <span class="tok-number">1915</span>,</span>
<span class="line" id="L2350">    <span class="tok-comment">/// The RPC pipe object has already been closed.</span></span>
<span class="line" id="L2351">    RPC_X_PIPE_CLOSED = <span class="tok-number">1916</span>,</span>
<span class="line" id="L2352">    <span class="tok-comment">/// The RPC call completed before all pipes were processed.</span></span>
<span class="line" id="L2353">    RPC_X_PIPE_DISCIPLINE_ERROR = <span class="tok-number">1917</span>,</span>
<span class="line" id="L2354">    <span class="tok-comment">/// No more data is available from the RPC pipe.</span></span>
<span class="line" id="L2355">    RPC_X_PIPE_EMPTY = <span class="tok-number">1918</span>,</span>
<span class="line" id="L2356">    <span class="tok-comment">/// No site name is available for this machine.</span></span>
<span class="line" id="L2357">    NO_SITENAME = <span class="tok-number">1919</span>,</span>
<span class="line" id="L2358">    <span class="tok-comment">/// The file cannot be accessed by the system.</span></span>
<span class="line" id="L2359">    CANT_ACCESS_FILE = <span class="tok-number">1920</span>,</span>
<span class="line" id="L2360">    <span class="tok-comment">/// The name of the file cannot be resolved by the system.</span></span>
<span class="line" id="L2361">    CANT_RESOLVE_FILENAME = <span class="tok-number">1921</span>,</span>
<span class="line" id="L2362">    <span class="tok-comment">/// The entry is not of the expected type.</span></span>
<span class="line" id="L2363">    RPC_S_ENTRY_TYPE_MISMATCH = <span class="tok-number">1922</span>,</span>
<span class="line" id="L2364">    <span class="tok-comment">/// Not all object UUIDs could be exported to the specified entry.</span></span>
<span class="line" id="L2365">    RPC_S_NOT_ALL_OBJS_EXPORTED = <span class="tok-number">1923</span>,</span>
<span class="line" id="L2366">    <span class="tok-comment">/// Interface could not be exported to the specified entry.</span></span>
<span class="line" id="L2367">    RPC_S_INTERFACE_NOT_EXPORTED = <span class="tok-number">1924</span>,</span>
<span class="line" id="L2368">    <span class="tok-comment">/// The specified profile entry could not be added.</span></span>
<span class="line" id="L2369">    RPC_S_PROFILE_NOT_ADDED = <span class="tok-number">1925</span>,</span>
<span class="line" id="L2370">    <span class="tok-comment">/// The specified profile element could not be added.</span></span>
<span class="line" id="L2371">    RPC_S_PRF_ELT_NOT_ADDED = <span class="tok-number">1926</span>,</span>
<span class="line" id="L2372">    <span class="tok-comment">/// The specified profile element could not be removed.</span></span>
<span class="line" id="L2373">    RPC_S_PRF_ELT_NOT_REMOVED = <span class="tok-number">1927</span>,</span>
<span class="line" id="L2374">    <span class="tok-comment">/// The group element could not be added.</span></span>
<span class="line" id="L2375">    RPC_S_GRP_ELT_NOT_ADDED = <span class="tok-number">1928</span>,</span>
<span class="line" id="L2376">    <span class="tok-comment">/// The group element could not be removed.</span></span>
<span class="line" id="L2377">    RPC_S_GRP_ELT_NOT_REMOVED = <span class="tok-number">1929</span>,</span>
<span class="line" id="L2378">    <span class="tok-comment">/// The printer driver is not compatible with a policy enabled on your computer that blocks NT 4.0 drivers.</span></span>
<span class="line" id="L2379">    KM_DRIVER_BLOCKED = <span class="tok-number">1930</span>,</span>
<span class="line" id="L2380">    <span class="tok-comment">/// The context has expired and can no longer be used.</span></span>
<span class="line" id="L2381">    CONTEXT_EXPIRED = <span class="tok-number">1931</span>,</span>
<span class="line" id="L2382">    <span class="tok-comment">/// The current user's delegated trust creation quota has been exceeded.</span></span>
<span class="line" id="L2383">    PER_USER_TRUST_QUOTA_EXCEEDED = <span class="tok-number">1932</span>,</span>
<span class="line" id="L2384">    <span class="tok-comment">/// The total delegated trust creation quota has been exceeded.</span></span>
<span class="line" id="L2385">    ALL_USER_TRUST_QUOTA_EXCEEDED = <span class="tok-number">1933</span>,</span>
<span class="line" id="L2386">    <span class="tok-comment">/// The current user's delegated trust deletion quota has been exceeded.</span></span>
<span class="line" id="L2387">    USER_DELETE_TRUST_QUOTA_EXCEEDED = <span class="tok-number">1934</span>,</span>
<span class="line" id="L2388">    <span class="tok-comment">/// The computer you are signing into is protected by an authentication firewall.</span></span>
<span class="line" id="L2389">    <span class="tok-comment">/// The specified account is not allowed to authenticate to the computer.</span></span>
<span class="line" id="L2390">    AUTHENTICATION_FIREWALL_FAILED = <span class="tok-number">1935</span>,</span>
<span class="line" id="L2391">    <span class="tok-comment">/// Remote connections to the Print Spooler are blocked by a policy set on your machine.</span></span>
<span class="line" id="L2392">    REMOTE_PRINT_CONNECTIONS_BLOCKED = <span class="tok-number">1936</span>,</span>
<span class="line" id="L2393">    <span class="tok-comment">/// Authentication failed because NTLM authentication has been disabled.</span></span>
<span class="line" id="L2394">    NTLM_BLOCKED = <span class="tok-number">1937</span>,</span>
<span class="line" id="L2395">    <span class="tok-comment">/// Logon Failure: EAS policy requires that the user change their password before this operation can be performed.</span></span>
<span class="line" id="L2396">    PASSWORD_CHANGE_REQUIRED = <span class="tok-number">1938</span>,</span>
<span class="line" id="L2397">    <span class="tok-comment">/// The pixel format is invalid.</span></span>
<span class="line" id="L2398">    INVALID_PIXEL_FORMAT = <span class="tok-number">2000</span>,</span>
<span class="line" id="L2399">    <span class="tok-comment">/// The specified driver is invalid.</span></span>
<span class="line" id="L2400">    BAD_DRIVER = <span class="tok-number">2001</span>,</span>
<span class="line" id="L2401">    <span class="tok-comment">/// The window style or class attribute is invalid for this operation.</span></span>
<span class="line" id="L2402">    INVALID_WINDOW_STYLE = <span class="tok-number">2002</span>,</span>
<span class="line" id="L2403">    <span class="tok-comment">/// The requested metafile operation is not supported.</span></span>
<span class="line" id="L2404">    METAFILE_NOT_SUPPORTED = <span class="tok-number">2003</span>,</span>
<span class="line" id="L2405">    <span class="tok-comment">/// The requested transformation operation is not supported.</span></span>
<span class="line" id="L2406">    TRANSFORM_NOT_SUPPORTED = <span class="tok-number">2004</span>,</span>
<span class="line" id="L2407">    <span class="tok-comment">/// The requested clipping operation is not supported.</span></span>
<span class="line" id="L2408">    CLIPPING_NOT_SUPPORTED = <span class="tok-number">2005</span>,</span>
<span class="line" id="L2409">    <span class="tok-comment">/// The specified color management module is invalid.</span></span>
<span class="line" id="L2410">    INVALID_CMM = <span class="tok-number">2010</span>,</span>
<span class="line" id="L2411">    <span class="tok-comment">/// The specified color profile is invalid.</span></span>
<span class="line" id="L2412">    INVALID_PROFILE = <span class="tok-number">2011</span>,</span>
<span class="line" id="L2413">    <span class="tok-comment">/// The specified tag was not found.</span></span>
<span class="line" id="L2414">    TAG_NOT_FOUND = <span class="tok-number">2012</span>,</span>
<span class="line" id="L2415">    <span class="tok-comment">/// A required tag is not present.</span></span>
<span class="line" id="L2416">    TAG_NOT_PRESENT = <span class="tok-number">2013</span>,</span>
<span class="line" id="L2417">    <span class="tok-comment">/// The specified tag is already present.</span></span>
<span class="line" id="L2418">    DUPLICATE_TAG = <span class="tok-number">2014</span>,</span>
<span class="line" id="L2419">    <span class="tok-comment">/// The specified color profile is not associated with the specified device.</span></span>
<span class="line" id="L2420">    PROFILE_NOT_ASSOCIATED_WITH_DEVICE = <span class="tok-number">2015</span>,</span>
<span class="line" id="L2421">    <span class="tok-comment">/// The specified color profile was not found.</span></span>
<span class="line" id="L2422">    PROFILE_NOT_FOUND = <span class="tok-number">2016</span>,</span>
<span class="line" id="L2423">    <span class="tok-comment">/// The specified color space is invalid.</span></span>
<span class="line" id="L2424">    INVALID_COLORSPACE = <span class="tok-number">2017</span>,</span>
<span class="line" id="L2425">    <span class="tok-comment">/// Image Color Management is not enabled.</span></span>
<span class="line" id="L2426">    ICM_NOT_ENABLED = <span class="tok-number">2018</span>,</span>
<span class="line" id="L2427">    <span class="tok-comment">/// There was an error while deleting the color transform.</span></span>
<span class="line" id="L2428">    DELETING_ICM_XFORM = <span class="tok-number">2019</span>,</span>
<span class="line" id="L2429">    <span class="tok-comment">/// The specified color transform is invalid.</span></span>
<span class="line" id="L2430">    INVALID_TRANSFORM = <span class="tok-number">2020</span>,</span>
<span class="line" id="L2431">    <span class="tok-comment">/// The specified transform does not match the bitmap's color space.</span></span>
<span class="line" id="L2432">    COLORSPACE_MISMATCH = <span class="tok-number">2021</span>,</span>
<span class="line" id="L2433">    <span class="tok-comment">/// The specified named color index is not present in the profile.</span></span>
<span class="line" id="L2434">    INVALID_COLORINDEX = <span class="tok-number">2022</span>,</span>
<span class="line" id="L2435">    <span class="tok-comment">/// The specified profile is intended for a device of a different type than the specified device.</span></span>
<span class="line" id="L2436">    PROFILE_DOES_NOT_MATCH_DEVICE = <span class="tok-number">2023</span>,</span>
<span class="line" id="L2437">    <span class="tok-comment">/// The network connection was made successfully, but the user had to be prompted for a password other than the one originally specified.</span></span>
<span class="line" id="L2438">    CONNECTED_OTHER_PASSWORD = <span class="tok-number">2108</span>,</span>
<span class="line" id="L2439">    <span class="tok-comment">/// The network connection was made successfully using default credentials.</span></span>
<span class="line" id="L2440">    CONNECTED_OTHER_PASSWORD_DEFAULT = <span class="tok-number">2109</span>,</span>
<span class="line" id="L2441">    <span class="tok-comment">/// The specified username is invalid.</span></span>
<span class="line" id="L2442">    BAD_USERNAME = <span class="tok-number">2202</span>,</span>
<span class="line" id="L2443">    <span class="tok-comment">/// This network connection does not exist.</span></span>
<span class="line" id="L2444">    NOT_CONNECTED = <span class="tok-number">2250</span>,</span>
<span class="line" id="L2445">    <span class="tok-comment">/// This network connection has files open or requests pending.</span></span>
<span class="line" id="L2446">    OPEN_FILES = <span class="tok-number">2401</span>,</span>
<span class="line" id="L2447">    <span class="tok-comment">/// Active connections still exist.</span></span>
<span class="line" id="L2448">    ACTIVE_CONNECTIONS = <span class="tok-number">2402</span>,</span>
<span class="line" id="L2449">    <span class="tok-comment">/// The device is in use by an active process and cannot be disconnected.</span></span>
<span class="line" id="L2450">    DEVICE_IN_USE = <span class="tok-number">2404</span>,</span>
<span class="line" id="L2451">    <span class="tok-comment">/// The specified print monitor is unknown.</span></span>
<span class="line" id="L2452">    UNKNOWN_PRINT_MONITOR = <span class="tok-number">3000</span>,</span>
<span class="line" id="L2453">    <span class="tok-comment">/// The specified printer driver is currently in use.</span></span>
<span class="line" id="L2454">    PRINTER_DRIVER_IN_USE = <span class="tok-number">3001</span>,</span>
<span class="line" id="L2455">    <span class="tok-comment">/// The spool file was not found.</span></span>
<span class="line" id="L2456">    SPOOL_FILE_NOT_FOUND = <span class="tok-number">3002</span>,</span>
<span class="line" id="L2457">    <span class="tok-comment">/// A StartDocPrinter call was not issued.</span></span>
<span class="line" id="L2458">    SPL_NO_STARTDOC = <span class="tok-number">3003</span>,</span>
<span class="line" id="L2459">    <span class="tok-comment">/// An AddJob call was not issued.</span></span>
<span class="line" id="L2460">    SPL_NO_ADDJOB = <span class="tok-number">3004</span>,</span>
<span class="line" id="L2461">    <span class="tok-comment">/// The specified print processor has already been installed.</span></span>
<span class="line" id="L2462">    PRINT_PROCESSOR_ALREADY_INSTALLED = <span class="tok-number">3005</span>,</span>
<span class="line" id="L2463">    <span class="tok-comment">/// The specified print monitor has already been installed.</span></span>
<span class="line" id="L2464">    PRINT_MONITOR_ALREADY_INSTALLED = <span class="tok-number">3006</span>,</span>
<span class="line" id="L2465">    <span class="tok-comment">/// The specified print monitor does not have the required functions.</span></span>
<span class="line" id="L2466">    INVALID_PRINT_MONITOR = <span class="tok-number">3007</span>,</span>
<span class="line" id="L2467">    <span class="tok-comment">/// The specified print monitor is currently in use.</span></span>
<span class="line" id="L2468">    PRINT_MONITOR_IN_USE = <span class="tok-number">3008</span>,</span>
<span class="line" id="L2469">    <span class="tok-comment">/// The requested operation is not allowed when there are jobs queued to the printer.</span></span>
<span class="line" id="L2470">    PRINTER_HAS_JOBS_QUEUED = <span class="tok-number">3009</span>,</span>
<span class="line" id="L2471">    <span class="tok-comment">/// The requested operation is successful.</span></span>
<span class="line" id="L2472">    <span class="tok-comment">/// Changes will not be effective until the system is rebooted.</span></span>
<span class="line" id="L2473">    SUCCESS_REBOOT_REQUIRED = <span class="tok-number">3010</span>,</span>
<span class="line" id="L2474">    <span class="tok-comment">/// The requested operation is successful.</span></span>
<span class="line" id="L2475">    <span class="tok-comment">/// Changes will not be effective until the service is restarted.</span></span>
<span class="line" id="L2476">    SUCCESS_RESTART_REQUIRED = <span class="tok-number">3011</span>,</span>
<span class="line" id="L2477">    <span class="tok-comment">/// No printers were found.</span></span>
<span class="line" id="L2478">    PRINTER_NOT_FOUND = <span class="tok-number">3012</span>,</span>
<span class="line" id="L2479">    <span class="tok-comment">/// The printer driver is known to be unreliable.</span></span>
<span class="line" id="L2480">    PRINTER_DRIVER_WARNED = <span class="tok-number">3013</span>,</span>
<span class="line" id="L2481">    <span class="tok-comment">/// The printer driver is known to harm the system.</span></span>
<span class="line" id="L2482">    PRINTER_DRIVER_BLOCKED = <span class="tok-number">3014</span>,</span>
<span class="line" id="L2483">    <span class="tok-comment">/// The specified printer driver package is currently in use.</span></span>
<span class="line" id="L2484">    PRINTER_DRIVER_PACKAGE_IN_USE = <span class="tok-number">3015</span>,</span>
<span class="line" id="L2485">    <span class="tok-comment">/// Unable to find a core driver package that is required by the printer driver package.</span></span>
<span class="line" id="L2486">    CORE_DRIVER_PACKAGE_NOT_FOUND = <span class="tok-number">3016</span>,</span>
<span class="line" id="L2487">    <span class="tok-comment">/// The requested operation failed.</span></span>
<span class="line" id="L2488">    <span class="tok-comment">/// A system reboot is required to roll back changes made.</span></span>
<span class="line" id="L2489">    FAIL_REBOOT_REQUIRED = <span class="tok-number">3017</span>,</span>
<span class="line" id="L2490">    <span class="tok-comment">/// The requested operation failed.</span></span>
<span class="line" id="L2491">    <span class="tok-comment">/// A system reboot has been initiated to roll back changes made.</span></span>
<span class="line" id="L2492">    FAIL_REBOOT_INITIATED = <span class="tok-number">3018</span>,</span>
<span class="line" id="L2493">    <span class="tok-comment">/// The specified printer driver was not found on the system and needs to be downloaded.</span></span>
<span class="line" id="L2494">    PRINTER_DRIVER_DOWNLOAD_NEEDED = <span class="tok-number">3019</span>,</span>
<span class="line" id="L2495">    <span class="tok-comment">/// The requested print job has failed to print.</span></span>
<span class="line" id="L2496">    <span class="tok-comment">/// A print system update requires the job to be resubmitted.</span></span>
<span class="line" id="L2497">    PRINT_JOB_RESTART_REQUIRED = <span class="tok-number">3020</span>,</span>
<span class="line" id="L2498">    <span class="tok-comment">/// The printer driver does not contain a valid manifest, or contains too many manifests.</span></span>
<span class="line" id="L2499">    INVALID_PRINTER_DRIVER_MANIFEST = <span class="tok-number">3021</span>,</span>
<span class="line" id="L2500">    <span class="tok-comment">/// The specified printer cannot be shared.</span></span>
<span class="line" id="L2501">    PRINTER_NOT_SHAREABLE = <span class="tok-number">3022</span>,</span>
<span class="line" id="L2502">    <span class="tok-comment">/// The operation was paused.</span></span>
<span class="line" id="L2503">    REQUEST_PAUSED = <span class="tok-number">3050</span>,</span>
<span class="line" id="L2504">    <span class="tok-comment">/// Reissue the given operation as a cached IO operation.</span></span>
<span class="line" id="L2505">    IO_REISSUE_AS_CACHED = <span class="tok-number">3950</span>,</span>
<span class="line" id="L2506">    _,</span>
<span class="line" id="L2507">};</span>
<span class="line" id="L2508"></span>
</code></pre></body>
</html>