<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/windows/sublang.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEUTRAL = <span class="tok-number">0x00</span>;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DEFAULT = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYS_DEFAULT = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CUSTOM_DEFAULT = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CUSTOM_UNSPECIFIED = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UI_CUSTOM_DEFAULT = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AFRIKAANS_SOUTH_AFRICA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALBANIAN_ALBANIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALSATIAN_FRANCE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AMHARIC_ETHIOPIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_SAUDI_ARABIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_IRAQ = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_EGYPT = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_LIBYA = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_ALGERIA = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_MOROCCO = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_TUNISIA = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_OMAN = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_YEMEN = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_SYRIA = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_JORDAN = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_LEBANON = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_KUWAIT = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_UAE = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_BAHRAIN = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARABIC_QATAR = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ARMENIAN_ARMENIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ASSAMESE_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AZERI_LATIN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AZERI_CYRILLIC = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AZERBAIJANI_AZERBAIJAN_LATIN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AZERBAIJANI_AZERBAIJAN_CYRILLIC = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BANGLA_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BANGLA_BANGLADESH = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BASHKIR_RUSSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BASQUE_BASQUE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BELARUSIAN_BELARUS = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BENGALI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BENGALI_BANGLADESH = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOSNIAN_BOSNIA_HERZEGOVINA_LATIN = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BOSNIAN_BOSNIA_HERZEGOVINA_CYRILLIC = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BRETON_FRANCE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BULGARIAN_BULGARIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CATALAN_CATALAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CENTRAL_KURDISH_IRAQ = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHEROKEE_CHEROKEE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHINESE_TRADITIONAL = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHINESE_SIMPLIFIED = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHINESE_HONGKONG = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHINESE_SINGAPORE = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CHINESE_MACAU = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CORSICAN_FRANCE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CZECH_CZECH_REPUBLIC = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CROATIAN_CROATIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CROATIAN_BOSNIA_HERZEGOVINA_LATIN = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DANISH_DENMARK = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DARI_AFGHANISTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIVEHI_MALDIVES = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DUTCH = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DUTCH_BELGIAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_US = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_UK = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_AUS = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_CAN = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_NZ = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_EIRE = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_SOUTH_AFRICA = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_JAMAICA = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_CARIBBEAN = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_BELIZE = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_TRINIDAD = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_ZIMBABWE = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_PHILIPPINES = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_INDIA = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_MALAYSIA = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ENGLISH_SINGAPORE = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ESTONIAN_ESTONIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FAEROESE_FAROE_ISLANDS = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILIPINO_PHILIPPINES = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FINNISH_FINLAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH_BELGIAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH_CANADIAN = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH_SWISS = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH_LUXEMBOURG = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRENCH_MONACO = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FRISIAN_NETHERLANDS = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FULAH_SENEGAL = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GALICIAN_GALICIAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GEORGIAN_GEORGIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GERMAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GERMAN_SWISS = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GERMAN_AUSTRIAN = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GERMAN_LUXEMBOURG = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GERMAN_LIECHTENSTEIN = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GREEK_GREECE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L97"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GREENLANDIC_GREENLAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GUJARATI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L99"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HAUSA_NIGERIA_LATIN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HAWAIIAN_US = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HEBREW_ISRAEL = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HINDI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HUNGARIAN_HUNGARY = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ICELANDIC_ICELAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L105"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IGBO_NIGERIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L106"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INDONESIAN_INDONESIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L107"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INUKTITUT_CANADA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> INUKTITUT_CANADA_LATIN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IRISH_IRELAND = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ITALIAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L111"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ITALIAN_SWISS = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L112"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> JAPANESE_JAPAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KANNADA_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L114"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KASHMIRI_SASIA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KASHMIRI_INDIA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L116"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KAZAK_KAZAKHSTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KHMER_CAMBODIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L118"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KICHE_GUATEMALA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L119"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KINYARWANDA_RWANDA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L120"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KONKANI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KOREAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> KYRGYZ_KYRGYZSTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L123"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LAO_LAO = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LATVIAN_LATVIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LITHUANIAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L126"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOWER_SORBIAN_GERMANY = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L127"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LUXEMBOURGISH_LUXEMBOURG = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L128"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MACEDONIAN_MACEDONIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MALAY_MALAYSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MALAY_BRUNEI_DARUSSALAM = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MALAYALAM_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MALTESE_MALTA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAORI_NEW_ZEALAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L134"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAPUDUNGUN_CHILE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MARATHI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MOHAWK_MOHAWK = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L137"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONGOLIAN_CYRILLIC_MONGOLIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L138"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONGOLIAN_PRC = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L139"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEPALI_INDIA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NEPALI_NEPAL = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORWEGIAN_BOKMAL = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NORWEGIAN_NYNORSK = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OCCITAN_FRANCE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L144"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ODIA_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ORIYA_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L146"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PASHTO_AFGHANISTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L147"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PERSIAN_IRAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L148"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLISH_POLAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PORTUGUESE = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L150"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PORTUGUESE_BRAZILIAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L151"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PULAR_SENEGAL = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L152"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUNJABI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L153"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PUNJABI_PAKISTAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUECHUA_BOLIVIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUECHUA_ECUADOR = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L156"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> QUECHUA_PERU = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROMANIAN_ROMANIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ROMANSH_SWITZERLAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L159"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RUSSIAN_RUSSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L160"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAKHA_RUSSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L161"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_NORTHERN_NORWAY = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L162"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_NORTHERN_SWEDEN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_NORTHERN_FINLAND = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_LULE_NORWAY = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_LULE_SWEDEN = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_SOUTHERN_NORWAY = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_SOUTHERN_SWEDEN = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_SKOLT_FINLAND = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SAMI_INARI_FINLAND = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SANSKRIT_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L171"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SCOTTISH_GAELIC = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_BOSNIA_HERZEGOVINA_LATIN = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_BOSNIA_HERZEGOVINA_CYRILLIC = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L174"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_MONTENEGRO_LATIN = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L175"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_MONTENEGRO_CYRILLIC = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L176"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_SERBIA_LATIN = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L177"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_SERBIA_CYRILLIC = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_CROATIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_LATIN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SERBIAN_CYRILLIC = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L181"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SINDHI_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SINDHI_PAKISTAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SINDHI_AFGHANISTAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SINHALESE_SRI_LANKA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOTHO_NORTHERN_SOUTH_AFRICA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SLOVAK_SLOVAKIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SLOVENIAN_SLOVENIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_MEXICAN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L190"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_MODERN = <span class="tok-number">0x03</span>;</span>
<span class="line" id="L191"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_GUATEMALA = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L192"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_COSTA_RICA = <span class="tok-number">0x05</span>;</span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_PANAMA = <span class="tok-number">0x06</span>;</span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_DOMINICAN_REPUBLIC = <span class="tok-number">0x07</span>;</span>
<span class="line" id="L195"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_VENEZUELA = <span class="tok-number">0x08</span>;</span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_COLOMBIA = <span class="tok-number">0x09</span>;</span>
<span class="line" id="L197"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_PERU = <span class="tok-number">0x0a</span>;</span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_ARGENTINA = <span class="tok-number">0x0b</span>;</span>
<span class="line" id="L199"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_ECUADOR = <span class="tok-number">0x0c</span>;</span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_CHILE = <span class="tok-number">0x0d</span>;</span>
<span class="line" id="L201"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_URUGUAY = <span class="tok-number">0x0e</span>;</span>
<span class="line" id="L202"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_PARAGUAY = <span class="tok-number">0x0f</span>;</span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_BOLIVIA = <span class="tok-number">0x10</span>;</span>
<span class="line" id="L204"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_EL_SALVADOR = <span class="tok-number">0x11</span>;</span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_HONDURAS = <span class="tok-number">0x12</span>;</span>
<span class="line" id="L206"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_NICARAGUA = <span class="tok-number">0x13</span>;</span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_PUERTO_RICO = <span class="tok-number">0x14</span>;</span>
<span class="line" id="L208"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SPANISH_US = <span class="tok-number">0x15</span>;</span>
<span class="line" id="L209"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWAHILI_KENYA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWEDISH = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L211"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SWEDISH_FINLAND = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYRIAC_SYRIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L213"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAJIK_TAJIKISTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAMAZIGHT_ALGERIA_LATIN = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L215"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAMAZIGHT_MOROCCO_TIFINAGH = <span class="tok-number">0x04</span>;</span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAMIL_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L217"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TAMIL_SRI_LANKA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L218"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TATAR_RUSSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L219"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TELUGU_INDIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> THAI_THAILAND = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L221"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIBETAN_PRC = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L222"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIGRIGNA_ERITREA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L223"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIGRINYA_ERITREA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L224"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TIGRINYA_ETHIOPIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L225"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSWANA_BOTSWANA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TSWANA_SOUTH_AFRICA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TURKISH_TURKEY = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L228"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TURKMEN_TURKMENISTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L229"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UIGHUR_PRC = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L230"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UKRAINIAN_UKRAINE = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L231"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UPPER_SORBIAN_GERMANY = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> URDU_PAKISTAN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> URDU_INDIA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L234"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UZBEK_LATIN = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L235"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UZBEK_CYRILLIC = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L236"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VALENCIAN_VALENCIA = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L237"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VIETNAMESE_VIETNAM = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WELSH_UNITED_KINGDOM = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WOLOF_SENEGAL = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L240"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XHOSA_SOUTH_AFRICA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> YAKUT_RUSSIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L242"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> YI_PRC = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L243"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> YORUBA_NIGERIA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ZULU_SOUTH_AFRICA = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L245"></span>
</code></pre></body>
</html>