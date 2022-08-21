<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>dwarf/OP.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addr = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> deref = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const1u = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const1s = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const2u = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const2s = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const4u = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const4s = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const8u = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const8s = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> constu = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> consts = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dup = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> drop = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> over = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pick = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> swap = <span class="tok-number">0x16</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rot = <span class="tok-number">0x17</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xderef = <span class="tok-number">0x18</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> abs = <span class="tok-number">0x19</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;and&quot; = <span class="tok-number">0x1a</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> div = <span class="tok-number">0x1b</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> minus = <span class="tok-number">0x1c</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mod = <span class="tok-number">0x1d</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mul = <span class="tok-number">0x1e</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> neg = <span class="tok-number">0x1f</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> not = <span class="tok-number">0x20</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> @&quot;or&quot; = <span class="tok-number">0x21</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> plus = <span class="tok-number">0x22</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> plus_uconst = <span class="tok-number">0x23</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> shl = <span class="tok-number">0x24</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> shr = <span class="tok-number">0x25</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> shra = <span class="tok-number">0x26</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xor = <span class="tok-number">0x27</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> bra = <span class="tok-number">0x28</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> eq = <span class="tok-number">0x29</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ge = <span class="tok-number">0x2a</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> gt = <span class="tok-number">0x2b</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> le = <span class="tok-number">0x2c</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lt = <span class="tok-number">0x2d</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ne = <span class="tok-number">0x2e</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> skip = <span class="tok-number">0x2f</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit0 = <span class="tok-number">0x30</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit1 = <span class="tok-number">0x31</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit2 = <span class="tok-number">0x32</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit3 = <span class="tok-number">0x33</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit4 = <span class="tok-number">0x34</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit5 = <span class="tok-number">0x35</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit6 = <span class="tok-number">0x36</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit7 = <span class="tok-number">0x37</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit8 = <span class="tok-number">0x38</span>;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit9 = <span class="tok-number">0x39</span>;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit10 = <span class="tok-number">0x3a</span>;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit11 = <span class="tok-number">0x3b</span>;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit12 = <span class="tok-number">0x3c</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit13 = <span class="tok-number">0x3d</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit14 = <span class="tok-number">0x3e</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit15 = <span class="tok-number">0x3f</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit16 = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit17 = <span class="tok-number">0x41</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit18 = <span class="tok-number">0x42</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit19 = <span class="tok-number">0x43</span>;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit20 = <span class="tok-number">0x44</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit21 = <span class="tok-number">0x45</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit22 = <span class="tok-number">0x46</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit23 = <span class="tok-number">0x47</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit24 = <span class="tok-number">0x48</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit25 = <span class="tok-number">0x49</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit26 = <span class="tok-number">0x4a</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit27 = <span class="tok-number">0x4b</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit28 = <span class="tok-number">0x4c</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit29 = <span class="tok-number">0x4d</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit30 = <span class="tok-number">0x4e</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lit31 = <span class="tok-number">0x4f</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg0 = <span class="tok-number">0x50</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg1 = <span class="tok-number">0x51</span>;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg2 = <span class="tok-number">0x52</span>;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg3 = <span class="tok-number">0x53</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg4 = <span class="tok-number">0x54</span>;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg5 = <span class="tok-number">0x55</span>;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg6 = <span class="tok-number">0x56</span>;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg7 = <span class="tok-number">0x57</span>;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg8 = <span class="tok-number">0x58</span>;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg9 = <span class="tok-number">0x59</span>;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg10 = <span class="tok-number">0x5a</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg11 = <span class="tok-number">0x5b</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg12 = <span class="tok-number">0x5c</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg13 = <span class="tok-number">0x5d</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg14 = <span class="tok-number">0x5e</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg15 = <span class="tok-number">0x5f</span>;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg16 = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg17 = <span class="tok-number">0x61</span>;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg18 = <span class="tok-number">0x62</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg19 = <span class="tok-number">0x63</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg20 = <span class="tok-number">0x64</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg21 = <span class="tok-number">0x65</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg22 = <span class="tok-number">0x66</span>;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg23 = <span class="tok-number">0x67</span>;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg24 = <span class="tok-number">0x68</span>;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg25 = <span class="tok-number">0x69</span>;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg26 = <span class="tok-number">0x6a</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg27 = <span class="tok-number">0x6b</span>;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg28 = <span class="tok-number">0x6c</span>;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg29 = <span class="tok-number">0x6d</span>;</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg30 = <span class="tok-number">0x6e</span>;</span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reg31 = <span class="tok-number">0x6f</span>;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg0 = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg1 = <span class="tok-number">0x71</span>;</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg2 = <span class="tok-number">0x72</span>;</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg3 = <span class="tok-number">0x73</span>;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg4 = <span class="tok-number">0x74</span>;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg5 = <span class="tok-number">0x75</span>;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg6 = <span class="tok-number">0x76</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg7 = <span class="tok-number">0x77</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg8 = <span class="tok-number">0x78</span>;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg9 = <span class="tok-number">0x79</span>;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg10 = <span class="tok-number">0x7a</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg11 = <span class="tok-number">0x7b</span>;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg12 = <span class="tok-number">0x7c</span>;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg13 = <span class="tok-number">0x7d</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg14 = <span class="tok-number">0x7e</span>;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg15 = <span class="tok-number">0x7f</span>;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg16 = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg17 = <span class="tok-number">0x81</span>;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg18 = <span class="tok-number">0x82</span>;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg19 = <span class="tok-number">0x83</span>;</span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg20 = <span class="tok-number">0x84</span>;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg21 = <span class="tok-number">0x85</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg22 = <span class="tok-number">0x86</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg23 = <span class="tok-number">0x87</span>;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg24 = <span class="tok-number">0x88</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg25 = <span class="tok-number">0x89</span>;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg26 = <span class="tok-number">0x8a</span>;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg27 = <span class="tok-number">0x8b</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg28 = <span class="tok-number">0x8c</span>;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg29 = <span class="tok-number">0x8d</span>;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg30 = <span class="tok-number">0x8e</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> breg31 = <span class="tok-number">0x8f</span>;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> regx = <span class="tok-number">0x90</span>;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fbreg = <span class="tok-number">0x91</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> bregx = <span class="tok-number">0x92</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> piece = <span class="tok-number">0x93</span>;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> deref_size = <span class="tok-number">0x94</span>;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xderef_size = <span class="tok-number">0x95</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> nop = <span class="tok-number">0x96</span>;</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-comment">// DWARF 3 extensions.</span>
</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> push_object_address = <span class="tok-number">0x97</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call2 = <span class="tok-number">0x98</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call4 = <span class="tok-number">0x99</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call_ref = <span class="tok-number">0x9a</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> form_tls_address = <span class="tok-number">0x9b</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> call_frame_cfa = <span class="tok-number">0x9c</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> bit_piece = <span class="tok-number">0x9d</span>;</span>
<span class="line" id="L155"></span>
<span class="line" id="L156"><span class="tok-comment">// DWARF 4 extensions.</span>
</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> implicit_value = <span class="tok-number">0x9e</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> stack_value = <span class="tok-number">0x9f</span>;</span>
<span class="line" id="L159"></span>
<span class="line" id="L160"><span class="tok-comment">// DWARF 5 extensions.</span>
</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> implicit_pointer = <span class="tok-number">0xa0</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> addrx = <span class="tok-number">0xa1</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> constx = <span class="tok-number">0xa2</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> entry_value = <span class="tok-number">0xa3</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> const_type = <span class="tok-number">0xa4</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> regval_type = <span class="tok-number">0xa5</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> deref_type = <span class="tok-number">0xa6</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> xderef_type = <span class="tok-number">0xa7</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> convert = <span class="tok-number">0xa8</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> reinterpret = <span class="tok-number">0xa9</span>;</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lo_user = <span class="tok-number">0xe0</span>; <span class="tok-comment">// Implementation-defined range start.</span>
</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hi_user = <span class="tok-number">0xff</span>; <span class="tok-comment">// Implementation-defined range end.</span>
</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-comment">// GNU extensions.</span>
</span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_push_tls_address = <span class="tok-number">0xe0</span>;</span>
<span class="line" id="L177"><span class="tok-comment">// The following is for marking variables that are uninitialized.</span>
</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_uninit = <span class="tok-number">0xf0</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_encoded_addr = <span class="tok-number">0xf1</span>;</span>
<span class="line" id="L180"><span class="tok-comment">// The GNU implicit pointer extension.</span>
</span>
<span class="line" id="L181"><span class="tok-comment">// See http://www.dwarfstd.org/ShowIssue.php?issue=100831.1&amp;type=open .</span>
</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_implicit_pointer = <span class="tok-number">0xf2</span>;</span>
<span class="line" id="L183"><span class="tok-comment">// The GNU entry value extension.</span>
</span>
<span class="line" id="L184"><span class="tok-comment">// See http://www.dwarfstd.org/ShowIssue.php?issue=100909.1&amp;type=open .</span>
</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_entry_value = <span class="tok-number">0xf3</span>;</span>
<span class="line" id="L186"><span class="tok-comment">// The GNU typed stack extension.</span>
</span>
<span class="line" id="L187"><span class="tok-comment">// See http://www.dwarfstd.org/doc/040408.1.html .</span>
</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_const_type = <span class="tok-number">0xf4</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_regval_type = <span class="tok-number">0xf5</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_deref_type = <span class="tok-number">0xf6</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_convert = <span class="tok-number">0xf7</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_reinterpret = <span class="tok-number">0xf9</span>;</span>
<span class="line" id="L193"><span class="tok-comment">// The GNU parameter ref extension.</span>
</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_parameter_ref = <span class="tok-number">0xfa</span>;</span>
<span class="line" id="L195"><span class="tok-comment">// Extension for Fission.  See http://gcc.gnu.org/wiki/DebugFission.</span>
</span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_addr_index = <span class="tok-number">0xfb</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GNU_const_index = <span class="tok-number">0xfc</span>;</span>
<span class="line" id="L198"><span class="tok-comment">// HP extensions.</span>
</span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_unknown = <span class="tok-number">0xe0</span>; <span class="tok-comment">// Ouch, the same as GNU_push_tls_address.</span>
</span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_is_value = <span class="tok-number">0xe1</span>;</span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_fltconst4 = <span class="tok-number">0xe2</span>;</span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_fltconst8 = <span class="tok-number">0xe3</span>;</span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_mod_range = <span class="tok-number">0xe4</span>;</span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_unmod_range = <span class="tok-number">0xe5</span>;</span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP_tls = <span class="tok-number">0xe6</span>;</span>
<span class="line" id="L206"><span class="tok-comment">// PGI (STMicroelectronics) extensions.</span>
</span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PGI_omp_thread_num = <span class="tok-number">0xf8</span>;</span>
<span class="line" id="L208"><span class="tok-comment">// Wasm extensions.</span>
</span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WASM_location = <span class="tok-number">0xed</span>;</span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WASM_local = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WASM_global = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WASM_global_u32 = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WASM_operand_stack = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L214"></span>
</code></pre></body>
</html>