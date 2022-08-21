<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fmt/errol/lookup.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HP = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2">    val: <span class="tok-type">f64</span>,</span>
<span class="line" id="L3">    off: <span class="tok-type">f64</span>,</span>
<span class="line" id="L4">};</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lookup_table = [_]HP{</span>
<span class="line" id="L6">    HP{ .val = <span class="tok-number">1.000000e+308</span>, .off = -<span class="tok-number">1.097906362944045488e+291</span> },</span>
<span class="line" id="L7">    HP{ .val = <span class="tok-number">1.000000e+307</span>, .off = <span class="tok-number">1.396894023974354241e+290</span> },</span>
<span class="line" id="L8">    HP{ .val = <span class="tok-number">1.000000e+306</span>, .off = -<span class="tok-number">1.721606459673645508e+289</span> },</span>
<span class="line" id="L9">    HP{ .val = <span class="tok-number">1.000000e+305</span>, .off = <span class="tok-number">6.074644749446353973e+288</span> },</span>
<span class="line" id="L10">    HP{ .val = <span class="tok-number">1.000000e+304</span>, .off = <span class="tok-number">6.074644749446353567e+287</span> },</span>
<span class="line" id="L11">    HP{ .val = <span class="tok-number">1.000000e+303</span>, .off = -<span class="tok-number">1.617650767864564452e+284</span> },</span>
<span class="line" id="L12">    HP{ .val = <span class="tok-number">1.000000e+302</span>, .off = -<span class="tok-number">7.629703079084895055e+285</span> },</span>
<span class="line" id="L13">    HP{ .val = <span class="tok-number">1.000000e+301</span>, .off = -<span class="tok-number">5.250476025520442286e+284</span> },</span>
<span class="line" id="L14">    HP{ .val = <span class="tok-number">1.000000e+300</span>, .off = -<span class="tok-number">5.250476025520441956e+283</span> },</span>
<span class="line" id="L15">    HP{ .val = <span class="tok-number">1.000000e+299</span>, .off = -<span class="tok-number">5.250476025520441750e+282</span> },</span>
<span class="line" id="L16">    HP{ .val = <span class="tok-number">1.000000e+298</span>, .off = <span class="tok-number">4.043379652465702264e+281</span> },</span>
<span class="line" id="L17">    HP{ .val = <span class="tok-number">1.000000e+297</span>, .off = -<span class="tok-number">1.765280146275637946e+280</span> },</span>
<span class="line" id="L18">    HP{ .val = <span class="tok-number">1.000000e+296</span>, .off = <span class="tok-number">1.865132227937699609e+279</span> },</span>
<span class="line" id="L19">    HP{ .val = <span class="tok-number">1.000000e+295</span>, .off = <span class="tok-number">1.865132227937699609e+278</span> },</span>
<span class="line" id="L20">    HP{ .val = <span class="tok-number">1.000000e+294</span>, .off = -<span class="tok-number">6.643646774124810287e+277</span> },</span>
<span class="line" id="L21">    HP{ .val = <span class="tok-number">1.000000e+293</span>, .off = <span class="tok-number">7.537651562646039934e+276</span> },</span>
<span class="line" id="L22">    HP{ .val = <span class="tok-number">1.000000e+292</span>, .off = -<span class="tok-number">1.325659897835741608e+275</span> },</span>
<span class="line" id="L23">    HP{ .val = <span class="tok-number">1.000000e+291</span>, .off = <span class="tok-number">4.213909764965371606e+274</span> },</span>
<span class="line" id="L24">    HP{ .val = <span class="tok-number">1.000000e+290</span>, .off = -<span class="tok-number">6.172783352786715670e+273</span> },</span>
<span class="line" id="L25">    HP{ .val = <span class="tok-number">1.000000e+289</span>, .off = -<span class="tok-number">6.172783352786715670e+272</span> },</span>
<span class="line" id="L26">    HP{ .val = <span class="tok-number">1.000000e+288</span>, .off = -<span class="tok-number">7.630473539575035471e+270</span> },</span>
<span class="line" id="L27">    HP{ .val = <span class="tok-number">1.000000e+287</span>, .off = -<span class="tok-number">7.525217352494018700e+270</span> },</span>
<span class="line" id="L28">    HP{ .val = <span class="tok-number">1.000000e+286</span>, .off = -<span class="tok-number">3.298861103408696612e+269</span> },</span>
<span class="line" id="L29">    HP{ .val = <span class="tok-number">1.000000e+285</span>, .off = <span class="tok-number">1.984084207947955778e+268</span> },</span>
<span class="line" id="L30">    HP{ .val = <span class="tok-number">1.000000e+284</span>, .off = -<span class="tok-number">7.921438250845767591e+267</span> },</span>
<span class="line" id="L31">    HP{ .val = <span class="tok-number">1.000000e+283</span>, .off = <span class="tok-number">4.460464822646386735e+266</span> },</span>
<span class="line" id="L32">    HP{ .val = <span class="tok-number">1.000000e+282</span>, .off = -<span class="tok-number">3.278224598286209647e+265</span> },</span>
<span class="line" id="L33">    HP{ .val = <span class="tok-number">1.000000e+281</span>, .off = -<span class="tok-number">3.278224598286209737e+264</span> },</span>
<span class="line" id="L34">    HP{ .val = <span class="tok-number">1.000000e+280</span>, .off = -<span class="tok-number">3.278224598286209961e+263</span> },</span>
<span class="line" id="L35">    HP{ .val = <span class="tok-number">1.000000e+279</span>, .off = -<span class="tok-number">5.797329227496039232e+262</span> },</span>
<span class="line" id="L36">    HP{ .val = <span class="tok-number">1.000000e+278</span>, .off = <span class="tok-number">3.649313132040821498e+261</span> },</span>
<span class="line" id="L37">    HP{ .val = <span class="tok-number">1.000000e+277</span>, .off = -<span class="tok-number">2.867878510995372374e+259</span> },</span>
<span class="line" id="L38">    HP{ .val = <span class="tok-number">1.000000e+276</span>, .off = -<span class="tok-number">5.206914080024985409e+259</span> },</span>
<span class="line" id="L39">    HP{ .val = <span class="tok-number">1.000000e+275</span>, .off = <span class="tok-number">4.018322599210230404e+258</span> },</span>
<span class="line" id="L40">    HP{ .val = <span class="tok-number">1.000000e+274</span>, .off = <span class="tok-number">7.862171215558236495e+257</span> },</span>
<span class="line" id="L41">    HP{ .val = <span class="tok-number">1.000000e+273</span>, .off = <span class="tok-number">5.459765830340732821e+256</span> },</span>
<span class="line" id="L42">    HP{ .val = <span class="tok-number">1.000000e+272</span>, .off = -<span class="tok-number">6.552261095746788047e+255</span> },</span>
<span class="line" id="L43">    HP{ .val = <span class="tok-number">1.000000e+271</span>, .off = <span class="tok-number">4.709014147460262298e+254</span> },</span>
<span class="line" id="L44">    HP{ .val = <span class="tok-number">1.000000e+270</span>, .off = -<span class="tok-number">4.675381888545612729e+253</span> },</span>
<span class="line" id="L45">    HP{ .val = <span class="tok-number">1.000000e+269</span>, .off = -<span class="tok-number">4.675381888545612892e+252</span> },</span>
<span class="line" id="L46">    HP{ .val = <span class="tok-number">1.000000e+268</span>, .off = <span class="tok-number">2.656177514583977380e+251</span> },</span>
<span class="line" id="L47">    HP{ .val = <span class="tok-number">1.000000e+267</span>, .off = <span class="tok-number">2.656177514583977190e+250</span> },</span>
<span class="line" id="L48">    HP{ .val = <span class="tok-number">1.000000e+266</span>, .off = -<span class="tok-number">3.071603269111014892e+249</span> },</span>
<span class="line" id="L49">    HP{ .val = <span class="tok-number">1.000000e+265</span>, .off = -<span class="tok-number">6.651466258920385440e+248</span> },</span>
<span class="line" id="L50">    HP{ .val = <span class="tok-number">1.000000e+264</span>, .off = -<span class="tok-number">4.414051890289528972e+247</span> },</span>
<span class="line" id="L51">    HP{ .val = <span class="tok-number">1.000000e+263</span>, .off = -<span class="tok-number">1.617283929500958387e+246</span> },</span>
<span class="line" id="L52">    HP{ .val = <span class="tok-number">1.000000e+262</span>, .off = -<span class="tok-number">1.617283929500958241e+245</span> },</span>
<span class="line" id="L53">    HP{ .val = <span class="tok-number">1.000000e+261</span>, .off = <span class="tok-number">7.122615947963323868e+244</span> },</span>
<span class="line" id="L54">    HP{ .val = <span class="tok-number">1.000000e+260</span>, .off = -<span class="tok-number">6.533477610574617382e+243</span> },</span>
<span class="line" id="L55">    HP{ .val = <span class="tok-number">1.000000e+259</span>, .off = <span class="tok-number">7.122615947963323982e+242</span> },</span>
<span class="line" id="L56">    HP{ .val = <span class="tok-number">1.000000e+258</span>, .off = -<span class="tok-number">5.679971763165996225e+241</span> },</span>
<span class="line" id="L57">    HP{ .val = <span class="tok-number">1.000000e+257</span>, .off = -<span class="tok-number">3.012765990014054219e+240</span> },</span>
<span class="line" id="L58">    HP{ .val = <span class="tok-number">1.000000e+256</span>, .off = -<span class="tok-number">3.012765990014054219e+239</span> },</span>
<span class="line" id="L59">    HP{ .val = <span class="tok-number">1.000000e+255</span>, .off = <span class="tok-number">1.154743030535854616e+238</span> },</span>
<span class="line" id="L60">    HP{ .val = <span class="tok-number">1.000000e+254</span>, .off = <span class="tok-number">6.364129306223240767e+237</span> },</span>
<span class="line" id="L61">    HP{ .val = <span class="tok-number">1.000000e+253</span>, .off = <span class="tok-number">6.364129306223241129e+236</span> },</span>
<span class="line" id="L62">    HP{ .val = <span class="tok-number">1.000000e+252</span>, .off = -<span class="tok-number">9.915202805299840595e+235</span> },</span>
<span class="line" id="L63">    HP{ .val = <span class="tok-number">1.000000e+251</span>, .off = -<span class="tok-number">4.827911520448877980e+234</span> },</span>
<span class="line" id="L64">    HP{ .val = <span class="tok-number">1.000000e+250</span>, .off = <span class="tok-number">7.890316691678530146e+233</span> },</span>
<span class="line" id="L65">    HP{ .val = <span class="tok-number">1.000000e+249</span>, .off = <span class="tok-number">7.890316691678529484e+232</span> },</span>
<span class="line" id="L66">    HP{ .val = <span class="tok-number">1.000000e+248</span>, .off = -<span class="tok-number">4.529828046727141859e+231</span> },</span>
<span class="line" id="L67">    HP{ .val = <span class="tok-number">1.000000e+247</span>, .off = <span class="tok-number">4.785280507077111924e+230</span> },</span>
<span class="line" id="L68">    HP{ .val = <span class="tok-number">1.000000e+246</span>, .off = -<span class="tok-number">6.858605185178205305e+229</span> },</span>
<span class="line" id="L69">    HP{ .val = <span class="tok-number">1.000000e+245</span>, .off = -<span class="tok-number">4.432795665958347728e+228</span> },</span>
<span class="line" id="L70">    HP{ .val = <span class="tok-number">1.000000e+244</span>, .off = -<span class="tok-number">7.465057564983169531e+227</span> },</span>
<span class="line" id="L71">    HP{ .val = <span class="tok-number">1.000000e+243</span>, .off = -<span class="tok-number">7.465057564983169741e+226</span> },</span>
<span class="line" id="L72">    HP{ .val = <span class="tok-number">1.000000e+242</span>, .off = -<span class="tok-number">5.096102956370027445e+225</span> },</span>
<span class="line" id="L73">    HP{ .val = <span class="tok-number">1.000000e+241</span>, .off = -<span class="tok-number">5.096102956370026952e+224</span> },</span>
<span class="line" id="L74">    HP{ .val = <span class="tok-number">1.000000e+240</span>, .off = -<span class="tok-number">1.394611380411992474e+223</span> },</span>
<span class="line" id="L75">    HP{ .val = <span class="tok-number">1.000000e+239</span>, .off = <span class="tok-number">9.188208545617793960e+221</span> },</span>
<span class="line" id="L76">    HP{ .val = <span class="tok-number">1.000000e+238</span>, .off = -<span class="tok-number">4.864759732872650359e+221</span> },</span>
<span class="line" id="L77">    HP{ .val = <span class="tok-number">1.000000e+237</span>, .off = <span class="tok-number">5.979453868566904629e+220</span> },</span>
<span class="line" id="L78">    HP{ .val = <span class="tok-number">1.000000e+236</span>, .off = -<span class="tok-number">5.316601966265964857e+219</span> },</span>
<span class="line" id="L79">    HP{ .val = <span class="tok-number">1.000000e+235</span>, .off = -<span class="tok-number">5.316601966265964701e+218</span> },</span>
<span class="line" id="L80">    HP{ .val = <span class="tok-number">1.000000e+234</span>, .off = -<span class="tok-number">1.786584517880693123e+217</span> },</span>
<span class="line" id="L81">    HP{ .val = <span class="tok-number">1.000000e+233</span>, .off = <span class="tok-number">2.625937292600896716e+216</span> },</span>
<span class="line" id="L82">    HP{ .val = <span class="tok-number">1.000000e+232</span>, .off = -<span class="tok-number">5.647541102052084079e+215</span> },</span>
<span class="line" id="L83">    HP{ .val = <span class="tok-number">1.000000e+231</span>, .off = -<span class="tok-number">5.647541102052083888e+214</span> },</span>
<span class="line" id="L84">    HP{ .val = <span class="tok-number">1.000000e+230</span>, .off = -<span class="tok-number">9.956644432600511943e+213</span> },</span>
<span class="line" id="L85">    HP{ .val = <span class="tok-number">1.000000e+229</span>, .off = <span class="tok-number">8.161138937705571862e+211</span> },</span>
<span class="line" id="L86">    HP{ .val = <span class="tok-number">1.000000e+228</span>, .off = <span class="tok-number">7.549087847752475275e+211</span> },</span>
<span class="line" id="L87">    HP{ .val = <span class="tok-number">1.000000e+227</span>, .off = -<span class="tok-number">9.283347037202319948e+210</span> },</span>
<span class="line" id="L88">    HP{ .val = <span class="tok-number">1.000000e+226</span>, .off = <span class="tok-number">3.866992716668613820e+209</span> },</span>
<span class="line" id="L89">    HP{ .val = <span class="tok-number">1.000000e+225</span>, .off = <span class="tok-number">7.154577655136347262e+208</span> },</span>
<span class="line" id="L90">    HP{ .val = <span class="tok-number">1.000000e+224</span>, .off = <span class="tok-number">3.045096482051680688e+207</span> },</span>
<span class="line" id="L91">    HP{ .val = <span class="tok-number">1.000000e+223</span>, .off = -<span class="tok-number">4.660180717482069567e+206</span> },</span>
<span class="line" id="L92">    HP{ .val = <span class="tok-number">1.000000e+222</span>, .off = -<span class="tok-number">4.660180717482070101e+205</span> },</span>
<span class="line" id="L93">    HP{ .val = <span class="tok-number">1.000000e+221</span>, .off = -<span class="tok-number">4.660180717482069544e+204</span> },</span>
<span class="line" id="L94">    HP{ .val = <span class="tok-number">1.000000e+220</span>, .off = <span class="tok-number">3.562757926310489022e+202</span> },</span>
<span class="line" id="L95">    HP{ .val = <span class="tok-number">1.000000e+219</span>, .off = <span class="tok-number">3.491561111451748149e+202</span> },</span>
<span class="line" id="L96">    HP{ .val = <span class="tok-number">1.000000e+218</span>, .off = -<span class="tok-number">8.265758834125874135e+201</span> },</span>
<span class="line" id="L97">    HP{ .val = <span class="tok-number">1.000000e+217</span>, .off = <span class="tok-number">3.981449442517482365e+200</span> },</span>
<span class="line" id="L98">    HP{ .val = <span class="tok-number">1.000000e+216</span>, .off = -<span class="tok-number">2.142154695804195936e+199</span> },</span>
<span class="line" id="L99">    HP{ .val = <span class="tok-number">1.000000e+215</span>, .off = <span class="tok-number">9.339603063548950188e+198</span> },</span>
<span class="line" id="L100">    HP{ .val = <span class="tok-number">1.000000e+214</span>, .off = <span class="tok-number">4.555537330485139746e+197</span> },</span>
<span class="line" id="L101">    HP{ .val = <span class="tok-number">1.000000e+213</span>, .off = <span class="tok-number">1.565496247320257804e+196</span> },</span>
<span class="line" id="L102">    HP{ .val = <span class="tok-number">1.000000e+212</span>, .off = <span class="tok-number">9.040598955232462036e+195</span> },</span>
<span class="line" id="L103">    HP{ .val = <span class="tok-number">1.000000e+211</span>, .off = <span class="tok-number">4.368659762787334780e+194</span> },</span>
<span class="line" id="L104">    HP{ .val = <span class="tok-number">1.000000e+210</span>, .off = <span class="tok-number">7.288621758065539072e+193</span> },</span>
<span class="line" id="L105">    HP{ .val = <span class="tok-number">1.000000e+209</span>, .off = -<span class="tok-number">7.311188218325485628e+192</span> },</span>
<span class="line" id="L106">    HP{ .val = <span class="tok-number">1.000000e+208</span>, .off = <span class="tok-number">1.813693016918905189e+191</span> },</span>
<span class="line" id="L107">    HP{ .val = <span class="tok-number">1.000000e+207</span>, .off = -<span class="tok-number">3.889357755108838992e+190</span> },</span>
<span class="line" id="L108">    HP{ .val = <span class="tok-number">1.000000e+206</span>, .off = -<span class="tok-number">3.889357755108838992e+189</span> },</span>
<span class="line" id="L109">    HP{ .val = <span class="tok-number">1.000000e+205</span>, .off = -<span class="tok-number">1.661603547285501360e+188</span> },</span>
<span class="line" id="L110">    HP{ .val = <span class="tok-number">1.000000e+204</span>, .off = <span class="tok-number">1.123089212493670643e+187</span> },</span>
<span class="line" id="L111">    HP{ .val = <span class="tok-number">1.000000e+203</span>, .off = <span class="tok-number">1.123089212493670643e+186</span> },</span>
<span class="line" id="L112">    HP{ .val = <span class="tok-number">1.000000e+202</span>, .off = <span class="tok-number">9.825254086803583029e+185</span> },</span>
<span class="line" id="L113">    HP{ .val = <span class="tok-number">1.000000e+201</span>, .off = -<span class="tok-number">3.771878529305654999e+184</span> },</span>
<span class="line" id="L114">    HP{ .val = <span class="tok-number">1.000000e+200</span>, .off = <span class="tok-number">3.026687778748963675e+183</span> },</span>
<span class="line" id="L115">    HP{ .val = <span class="tok-number">1.000000e+199</span>, .off = -<span class="tok-number">9.720624048853446693e+182</span> },</span>
<span class="line" id="L116">    HP{ .val = <span class="tok-number">1.000000e+198</span>, .off = -<span class="tok-number">1.753554156601940139e+181</span> },</span>
<span class="line" id="L117">    HP{ .val = <span class="tok-number">1.000000e+197</span>, .off = <span class="tok-number">4.885670753607648963e+180</span> },</span>
<span class="line" id="L118">    HP{ .val = <span class="tok-number">1.000000e+196</span>, .off = <span class="tok-number">4.885670753607648963e+179</span> },</span>
<span class="line" id="L119">    HP{ .val = <span class="tok-number">1.000000e+195</span>, .off = <span class="tok-number">2.292223523057028076e+178</span> },</span>
<span class="line" id="L120">    HP{ .val = <span class="tok-number">1.000000e+194</span>, .off = <span class="tok-number">5.534032561245303825e+177</span> },</span>
<span class="line" id="L121">    HP{ .val = <span class="tok-number">1.000000e+193</span>, .off = -<span class="tok-number">6.622751331960730683e+176</span> },</span>
<span class="line" id="L122">    HP{ .val = <span class="tok-number">1.000000e+192</span>, .off = -<span class="tok-number">4.090088020876139692e+175</span> },</span>
<span class="line" id="L123">    HP{ .val = <span class="tok-number">1.000000e+191</span>, .off = -<span class="tok-number">7.255917159731877552e+174</span> },</span>
<span class="line" id="L124">    HP{ .val = <span class="tok-number">1.000000e+190</span>, .off = -<span class="tok-number">7.255917159731877992e+173</span> },</span>
<span class="line" id="L125">    HP{ .val = <span class="tok-number">1.000000e+189</span>, .off = -<span class="tok-number">2.309309130269787104e+172</span> },</span>
<span class="line" id="L126">    HP{ .val = <span class="tok-number">1.000000e+188</span>, .off = -<span class="tok-number">2.309309130269787019e+171</span> },</span>
<span class="line" id="L127">    HP{ .val = <span class="tok-number">1.000000e+187</span>, .off = <span class="tok-number">9.284303438781988230e+170</span> },</span>
<span class="line" id="L128">    HP{ .val = <span class="tok-number">1.000000e+186</span>, .off = <span class="tok-number">2.038295583124628364e+169</span> },</span>
<span class="line" id="L129">    HP{ .val = <span class="tok-number">1.000000e+185</span>, .off = <span class="tok-number">2.038295583124628532e+168</span> },</span>
<span class="line" id="L130">    HP{ .val = <span class="tok-number">1.000000e+184</span>, .off = -<span class="tok-number">1.735666841696912925e+167</span> },</span>
<span class="line" id="L131">    HP{ .val = <span class="tok-number">1.000000e+183</span>, .off = <span class="tok-number">5.340512704843477241e+166</span> },</span>
<span class="line" id="L132">    HP{ .val = <span class="tok-number">1.000000e+182</span>, .off = -<span class="tok-number">6.453119872723839321e+165</span> },</span>
<span class="line" id="L133">    HP{ .val = <span class="tok-number">1.000000e+181</span>, .off = <span class="tok-number">8.288920849235306587e+164</span> },</span>
<span class="line" id="L134">    HP{ .val = <span class="tok-number">1.000000e+180</span>, .off = -<span class="tok-number">9.248546019891598293e+162</span> },</span>
<span class="line" id="L135">    HP{ .val = <span class="tok-number">1.000000e+179</span>, .off = <span class="tok-number">1.954450226518486016e+162</span> },</span>
<span class="line" id="L136">    HP{ .val = <span class="tok-number">1.000000e+178</span>, .off = -<span class="tok-number">5.243811844750628197e+161</span> },</span>
<span class="line" id="L137">    HP{ .val = <span class="tok-number">1.000000e+177</span>, .off = -<span class="tok-number">7.448980502074320639e+159</span> },</span>
<span class="line" id="L138">    HP{ .val = <span class="tok-number">1.000000e+176</span>, .off = -<span class="tok-number">7.448980502074319858e+158</span> },</span>
<span class="line" id="L139">    HP{ .val = <span class="tok-number">1.000000e+175</span>, .off = <span class="tok-number">6.284654753766312753e+158</span> },</span>
<span class="line" id="L140">    HP{ .val = <span class="tok-number">1.000000e+174</span>, .off = -<span class="tok-number">6.895756753684458388e+157</span> },</span>
<span class="line" id="L141">    HP{ .val = <span class="tok-number">1.000000e+173</span>, .off = -<span class="tok-number">1.403918625579970616e+156</span> },</span>
<span class="line" id="L142">    HP{ .val = <span class="tok-number">1.000000e+172</span>, .off = -<span class="tok-number">8.268716285710580522e+155</span> },</span>
<span class="line" id="L143">    HP{ .val = <span class="tok-number">1.000000e+171</span>, .off = <span class="tok-number">4.602779327034313170e+154</span> },</span>
<span class="line" id="L144">    HP{ .val = <span class="tok-number">1.000000e+170</span>, .off = -<span class="tok-number">3.441905430931244940e+153</span> },</span>
<span class="line" id="L145">    HP{ .val = <span class="tok-number">1.000000e+169</span>, .off = <span class="tok-number">6.613950516525702884e+152</span> },</span>
<span class="line" id="L146">    HP{ .val = <span class="tok-number">1.000000e+168</span>, .off = <span class="tok-number">6.613950516525702652e+151</span> },</span>
<span class="line" id="L147">    HP{ .val = <span class="tok-number">1.000000e+167</span>, .off = -<span class="tok-number">3.860899428741951187e+150</span> },</span>
<span class="line" id="L148">    HP{ .val = <span class="tok-number">1.000000e+166</span>, .off = <span class="tok-number">5.959272394946474605e+149</span> },</span>
<span class="line" id="L149">    HP{ .val = <span class="tok-number">1.000000e+165</span>, .off = <span class="tok-number">1.005101065481665103e+149</span> },</span>
<span class="line" id="L150">    HP{ .val = <span class="tok-number">1.000000e+164</span>, .off = -<span class="tok-number">1.783349948587918355e+146</span> },</span>
<span class="line" id="L151">    HP{ .val = <span class="tok-number">1.000000e+163</span>, .off = <span class="tok-number">6.215006036188360099e+146</span> },</span>
<span class="line" id="L152">    HP{ .val = <span class="tok-number">1.000000e+162</span>, .off = <span class="tok-number">6.215006036188360099e+145</span> },</span>
<span class="line" id="L153">    HP{ .val = <span class="tok-number">1.000000e+161</span>, .off = -<span class="tok-number">3.774589324822814903e+144</span> },</span>
<span class="line" id="L154">    HP{ .val = <span class="tok-number">1.000000e+160</span>, .off = -<span class="tok-number">6.528407745068226929e+142</span> },</span>
<span class="line" id="L155">    HP{ .val = <span class="tok-number">1.000000e+159</span>, .off = <span class="tok-number">7.151530601283157561e+142</span> },</span>
<span class="line" id="L156">    HP{ .val = <span class="tok-number">1.000000e+158</span>, .off = <span class="tok-number">4.712664546348788765e+141</span> },</span>
<span class="line" id="L157">    HP{ .val = <span class="tok-number">1.000000e+157</span>, .off = <span class="tok-number">1.664081977680827856e+140</span> },</span>
<span class="line" id="L158">    HP{ .val = <span class="tok-number">1.000000e+156</span>, .off = <span class="tok-number">1.664081977680827750e+139</span> },</span>
<span class="line" id="L159">    HP{ .val = <span class="tok-number">1.000000e+155</span>, .off = -<span class="tok-number">7.176231540910168265e+137</span> },</span>
<span class="line" id="L160">    HP{ .val = <span class="tok-number">1.000000e+154</span>, .off = -<span class="tok-number">3.694754568805822650e+137</span> },</span>
<span class="line" id="L161">    HP{ .val = <span class="tok-number">1.000000e+153</span>, .off = <span class="tok-number">2.665969958768462622e+134</span> },</span>
<span class="line" id="L162">    HP{ .val = <span class="tok-number">1.000000e+152</span>, .off = -<span class="tok-number">4.625108135904199522e+135</span> },</span>
<span class="line" id="L163">    HP{ .val = <span class="tok-number">1.000000e+151</span>, .off = -<span class="tok-number">1.717753238721771919e+134</span> },</span>
<span class="line" id="L164">    HP{ .val = <span class="tok-number">1.000000e+150</span>, .off = <span class="tok-number">1.916440382756262433e+133</span> },</span>
<span class="line" id="L165">    HP{ .val = <span class="tok-number">1.000000e+149</span>, .off = -<span class="tok-number">4.897672657515052040e+132</span> },</span>
<span class="line" id="L166">    HP{ .val = <span class="tok-number">1.000000e+148</span>, .off = -<span class="tok-number">4.897672657515052198e+131</span> },</span>
<span class="line" id="L167">    HP{ .val = <span class="tok-number">1.000000e+147</span>, .off = <span class="tok-number">2.200361759434233991e+130</span> },</span>
<span class="line" id="L168">    HP{ .val = <span class="tok-number">1.000000e+146</span>, .off = <span class="tok-number">6.636633270027537273e+129</span> },</span>
<span class="line" id="L169">    HP{ .val = <span class="tok-number">1.000000e+145</span>, .off = <span class="tok-number">1.091293881785907977e+128</span> },</span>
<span class="line" id="L170">    HP{ .val = <span class="tok-number">1.000000e+144</span>, .off = -<span class="tok-number">2.374543235865110597e+127</span> },</span>
<span class="line" id="L171">    HP{ .val = <span class="tok-number">1.000000e+143</span>, .off = -<span class="tok-number">2.374543235865110537e+126</span> },</span>
<span class="line" id="L172">    HP{ .val = <span class="tok-number">1.000000e+142</span>, .off = -<span class="tok-number">5.082228484029969099e+125</span> },</span>
<span class="line" id="L173">    HP{ .val = <span class="tok-number">1.000000e+141</span>, .off = -<span class="tok-number">1.697621923823895943e+124</span> },</span>
<span class="line" id="L174">    HP{ .val = <span class="tok-number">1.000000e+140</span>, .off = -<span class="tok-number">5.928380124081487212e+123</span> },</span>
<span class="line" id="L175">    HP{ .val = <span class="tok-number">1.000000e+139</span>, .off = -<span class="tok-number">3.284156248920492522e+122</span> },</span>
<span class="line" id="L176">    HP{ .val = <span class="tok-number">1.000000e+138</span>, .off = -<span class="tok-number">3.284156248920492706e+121</span> },</span>
<span class="line" id="L177">    HP{ .val = <span class="tok-number">1.000000e+137</span>, .off = -<span class="tok-number">3.284156248920492476e+120</span> },</span>
<span class="line" id="L178">    HP{ .val = <span class="tok-number">1.000000e+136</span>, .off = -<span class="tok-number">5.866406127007401066e+119</span> },</span>
<span class="line" id="L179">    HP{ .val = <span class="tok-number">1.000000e+135</span>, .off = <span class="tok-number">3.817030915818506056e+118</span> },</span>
<span class="line" id="L180">    HP{ .val = <span class="tok-number">1.000000e+134</span>, .off = <span class="tok-number">7.851796350329300951e+117</span> },</span>
<span class="line" id="L181">    HP{ .val = <span class="tok-number">1.000000e+133</span>, .off = -<span class="tok-number">2.235117235947686077e+116</span> },</span>
<span class="line" id="L182">    HP{ .val = <span class="tok-number">1.000000e+132</span>, .off = <span class="tok-number">9.170432597638723691e+114</span> },</span>
<span class="line" id="L183">    HP{ .val = <span class="tok-number">1.000000e+131</span>, .off = <span class="tok-number">8.797444499042767883e+114</span> },</span>
<span class="line" id="L184">    HP{ .val = <span class="tok-number">1.000000e+130</span>, .off = -<span class="tok-number">5.978307824605161274e+113</span> },</span>
<span class="line" id="L185">    HP{ .val = <span class="tok-number">1.000000e+129</span>, .off = <span class="tok-number">1.782556435814758516e+111</span> },</span>
<span class="line" id="L186">    HP{ .val = <span class="tok-number">1.000000e+128</span>, .off = -<span class="tok-number">7.517448691651820362e+111</span> },</span>
<span class="line" id="L187">    HP{ .val = <span class="tok-number">1.000000e+127</span>, .off = <span class="tok-number">4.507089332150205498e+110</span> },</span>
<span class="line" id="L188">    HP{ .val = <span class="tok-number">1.000000e+126</span>, .off = <span class="tok-number">7.513223838100711695e+109</span> },</span>
<span class="line" id="L189">    HP{ .val = <span class="tok-number">1.000000e+125</span>, .off = <span class="tok-number">7.513223838100712113e+108</span> },</span>
<span class="line" id="L190">    HP{ .val = <span class="tok-number">1.000000e+124</span>, .off = <span class="tok-number">5.164681255326878494e+107</span> },</span>
<span class="line" id="L191">    HP{ .val = <span class="tok-number">1.000000e+123</span>, .off = <span class="tok-number">2.229003026859587122e+106</span> },</span>
<span class="line" id="L192">    HP{ .val = <span class="tok-number">1.000000e+122</span>, .off = -<span class="tok-number">1.440594758724527399e+105</span> },</span>
<span class="line" id="L193">    HP{ .val = <span class="tok-number">1.000000e+121</span>, .off = -<span class="tok-number">3.734093374714598783e+104</span> },</span>
<span class="line" id="L194">    HP{ .val = <span class="tok-number">1.000000e+120</span>, .off = <span class="tok-number">1.999653165260579757e+103</span> },</span>
<span class="line" id="L195">    HP{ .val = <span class="tok-number">1.000000e+119</span>, .off = <span class="tok-number">5.583244752745066693e+102</span> },</span>
<span class="line" id="L196">    HP{ .val = <span class="tok-number">1.000000e+118</span>, .off = <span class="tok-number">3.343500010567262234e+101</span> },</span>
<span class="line" id="L197">    HP{ .val = <span class="tok-number">1.000000e+117</span>, .off = -<span class="tok-number">5.055542772599503556e+100</span> },</span>
<span class="line" id="L198">    HP{ .val = <span class="tok-number">1.000000e+116</span>, .off = -<span class="tok-number">1.555941612946684331e+99</span> },</span>
<span class="line" id="L199">    HP{ .val = <span class="tok-number">1.000000e+115</span>, .off = -<span class="tok-number">1.555941612946684331e+98</span> },</span>
<span class="line" id="L200">    HP{ .val = <span class="tok-number">1.000000e+114</span>, .off = -<span class="tok-number">1.555941612946684293e+97</span> },</span>
<span class="line" id="L201">    HP{ .val = <span class="tok-number">1.000000e+113</span>, .off = -<span class="tok-number">1.555941612946684246e+96</span> },</span>
<span class="line" id="L202">    HP{ .val = <span class="tok-number">1.000000e+112</span>, .off = <span class="tok-number">6.988006530736955847e+95</span> },</span>
<span class="line" id="L203">    HP{ .val = <span class="tok-number">1.000000e+111</span>, .off = <span class="tok-number">4.318022735835818244e+94</span> },</span>
<span class="line" id="L204">    HP{ .val = <span class="tok-number">1.000000e+110</span>, .off = -<span class="tok-number">2.356936751417025578e+93</span> },</span>
<span class="line" id="L205">    HP{ .val = <span class="tok-number">1.000000e+109</span>, .off = <span class="tok-number">1.814912928116001926e+92</span> },</span>
<span class="line" id="L206">    HP{ .val = <span class="tok-number">1.000000e+108</span>, .off = -<span class="tok-number">3.399899171300282744e+91</span> },</span>
<span class="line" id="L207">    HP{ .val = <span class="tok-number">1.000000e+107</span>, .off = <span class="tok-number">3.118615952970072913e+90</span> },</span>
<span class="line" id="L208">    HP{ .val = <span class="tok-number">1.000000e+106</span>, .off = -<span class="tok-number">9.103599905036843605e+89</span> },</span>
<span class="line" id="L209">    HP{ .val = <span class="tok-number">1.000000e+105</span>, .off = <span class="tok-number">6.174169917471802325e+88</span> },</span>
<span class="line" id="L210">    HP{ .val = <span class="tok-number">1.000000e+104</span>, .off = -<span class="tok-number">1.915675085734668657e+86</span> },</span>
<span class="line" id="L211">    HP{ .val = <span class="tok-number">1.000000e+103</span>, .off = -<span class="tok-number">1.915675085734668864e+85</span> },</span>
<span class="line" id="L212">    HP{ .val = <span class="tok-number">1.000000e+102</span>, .off = <span class="tok-number">2.295048673475466221e+85</span> },</span>
<span class="line" id="L213">    HP{ .val = <span class="tok-number">1.000000e+101</span>, .off = <span class="tok-number">2.295048673475466135e+84</span> },</span>
<span class="line" id="L214">    HP{ .val = <span class="tok-number">1.000000e+100</span>, .off = -<span class="tok-number">1.590289110975991792e+83</span> },</span>
<span class="line" id="L215">    HP{ .val = <span class="tok-number">1.000000e+99</span>, .off = <span class="tok-number">3.266383119588331155e+82</span> },</span>
<span class="line" id="L216">    HP{ .val = <span class="tok-number">1.000000e+98</span>, .off = <span class="tok-number">2.309629754856292029e+80</span> },</span>
<span class="line" id="L217">    HP{ .val = <span class="tok-number">1.000000e+97</span>, .off = -<span class="tok-number">7.357587384771124533e+80</span> },</span>
<span class="line" id="L218">    HP{ .val = <span class="tok-number">1.000000e+96</span>, .off = -<span class="tok-number">4.986165397190889509e+79</span> },</span>
<span class="line" id="L219">    HP{ .val = <span class="tok-number">1.000000e+95</span>, .off = -<span class="tok-number">2.021887912715594741e+78</span> },</span>
<span class="line" id="L220">    HP{ .val = <span class="tok-number">1.000000e+94</span>, .off = -<span class="tok-number">2.021887912715594638e+77</span> },</span>
<span class="line" id="L221">    HP{ .val = <span class="tok-number">1.000000e+93</span>, .off = -<span class="tok-number">4.337729697461918675e+76</span> },</span>
<span class="line" id="L222">    HP{ .val = <span class="tok-number">1.000000e+92</span>, .off = -<span class="tok-number">4.337729697461918997e+75</span> },</span>
<span class="line" id="L223">    HP{ .val = <span class="tok-number">1.000000e+91</span>, .off = -<span class="tok-number">7.956232486128049702e+74</span> },</span>
<span class="line" id="L224">    HP{ .val = <span class="tok-number">1.000000e+90</span>, .off = <span class="tok-number">3.351588728453609882e+73</span> },</span>
<span class="line" id="L225">    HP{ .val = <span class="tok-number">1.000000e+89</span>, .off = <span class="tok-number">5.246334248081951113e+71</span> },</span>
<span class="line" id="L226">    HP{ .val = <span class="tok-number">1.000000e+88</span>, .off = <span class="tok-number">4.058327554364963672e+71</span> },</span>
<span class="line" id="L227">    HP{ .val = <span class="tok-number">1.000000e+87</span>, .off = <span class="tok-number">4.058327554364963918e+70</span> },</span>
<span class="line" id="L228">    HP{ .val = <span class="tok-number">1.000000e+86</span>, .off = -<span class="tok-number">1.463069523067487266e+69</span> },</span>
<span class="line" id="L229">    HP{ .val = <span class="tok-number">1.000000e+85</span>, .off = -<span class="tok-number">1.463069523067487314e+68</span> },</span>
<span class="line" id="L230">    HP{ .val = <span class="tok-number">1.000000e+84</span>, .off = -<span class="tok-number">5.776660989811589441e+67</span> },</span>
<span class="line" id="L231">    HP{ .val = <span class="tok-number">1.000000e+83</span>, .off = -<span class="tok-number">3.080666323096525761e+66</span> },</span>
<span class="line" id="L232">    HP{ .val = <span class="tok-number">1.000000e+82</span>, .off = <span class="tok-number">3.659320343691134468e+65</span> },</span>
<span class="line" id="L233">    HP{ .val = <span class="tok-number">1.000000e+81</span>, .off = <span class="tok-number">7.871812010433421235e+64</span> },</span>
<span class="line" id="L234">    HP{ .val = <span class="tok-number">1.000000e+80</span>, .off = -<span class="tok-number">2.660986470836727449e+61</span> },</span>
<span class="line" id="L235">    HP{ .val = <span class="tok-number">1.000000e+79</span>, .off = <span class="tok-number">3.264399249934044627e+62</span> },</span>
<span class="line" id="L236">    HP{ .val = <span class="tok-number">1.000000e+78</span>, .off = -<span class="tok-number">8.493621433689703070e+60</span> },</span>
<span class="line" id="L237">    HP{ .val = <span class="tok-number">1.000000e+77</span>, .off = <span class="tok-number">1.721738727445414063e+60</span> },</span>
<span class="line" id="L238">    HP{ .val = <span class="tok-number">1.000000e+76</span>, .off = -<span class="tok-number">4.706013449590547218e+59</span> },</span>
<span class="line" id="L239">    HP{ .val = <span class="tok-number">1.000000e+75</span>, .off = <span class="tok-number">7.346021882351880518e+58</span> },</span>
<span class="line" id="L240">    HP{ .val = <span class="tok-number">1.000000e+74</span>, .off = <span class="tok-number">4.835181188197207515e+57</span> },</span>
<span class="line" id="L241">    HP{ .val = <span class="tok-number">1.000000e+73</span>, .off = <span class="tok-number">1.696630320503867482e+56</span> },</span>
<span class="line" id="L242">    HP{ .val = <span class="tok-number">1.000000e+72</span>, .off = <span class="tok-number">5.619818905120542959e+55</span> },</span>
<span class="line" id="L243">    HP{ .val = <span class="tok-number">1.000000e+71</span>, .off = -<span class="tok-number">4.188152556421145598e+54</span> },</span>
<span class="line" id="L244">    HP{ .val = <span class="tok-number">1.000000e+70</span>, .off = -<span class="tok-number">7.253143638152923145e+53</span> },</span>
<span class="line" id="L245">    HP{ .val = <span class="tok-number">1.000000e+69</span>, .off = -<span class="tok-number">7.253143638152923145e+52</span> },</span>
<span class="line" id="L246">    HP{ .val = <span class="tok-number">1.000000e+68</span>, .off = <span class="tok-number">4.719477774861832896e+51</span> },</span>
<span class="line" id="L247">    HP{ .val = <span class="tok-number">1.000000e+67</span>, .off = <span class="tok-number">1.726322421608144052e+50</span> },</span>
<span class="line" id="L248">    HP{ .val = <span class="tok-number">1.000000e+66</span>, .off = <span class="tok-number">5.467766613175255107e+49</span> },</span>
<span class="line" id="L249">    HP{ .val = <span class="tok-number">1.000000e+65</span>, .off = <span class="tok-number">7.909613737163661911e+47</span> },</span>
<span class="line" id="L250">    HP{ .val = <span class="tok-number">1.000000e+64</span>, .off = -<span class="tok-number">2.132041900945439564e+47</span> },</span>
<span class="line" id="L251">    HP{ .val = <span class="tok-number">1.000000e+63</span>, .off = -<span class="tok-number">5.785795994272697265e+46</span> },</span>
<span class="line" id="L252">    HP{ .val = <span class="tok-number">1.000000e+62</span>, .off = -<span class="tok-number">3.502199685943161329e+45</span> },</span>
<span class="line" id="L253">    HP{ .val = <span class="tok-number">1.000000e+61</span>, .off = <span class="tok-number">5.061286470292598274e+44</span> },</span>
<span class="line" id="L254">    HP{ .val = <span class="tok-number">1.000000e+60</span>, .off = <span class="tok-number">5.061286470292598472e+43</span> },</span>
<span class="line" id="L255">    HP{ .val = <span class="tok-number">1.000000e+59</span>, .off = <span class="tok-number">2.831211950439536034e+42</span> },</span>
<span class="line" id="L256">    HP{ .val = <span class="tok-number">1.000000e+58</span>, .off = <span class="tok-number">5.618805100255863927e+41</span> },</span>
<span class="line" id="L257">    HP{ .val = <span class="tok-number">1.000000e+57</span>, .off = -<span class="tok-number">4.834669211555366251e+40</span> },</span>
<span class="line" id="L258">    HP{ .val = <span class="tok-number">1.000000e+56</span>, .off = -<span class="tok-number">9.190283508143378583e+39</span> },</span>
<span class="line" id="L259">    HP{ .val = <span class="tok-number">1.000000e+55</span>, .off = -<span class="tok-number">1.023506702040855158e+38</span> },</span>
<span class="line" id="L260">    HP{ .val = <span class="tok-number">1.000000e+54</span>, .off = -<span class="tok-number">7.829154040459624616e+37</span> },</span>
<span class="line" id="L261">    HP{ .val = <span class="tok-number">1.000000e+53</span>, .off = <span class="tok-number">6.779051325638372659e+35</span> },</span>
<span class="line" id="L262">    HP{ .val = <span class="tok-number">1.000000e+52</span>, .off = <span class="tok-number">6.779051325638372290e+34</span> },</span>
<span class="line" id="L263">    HP{ .val = <span class="tok-number">1.000000e+51</span>, .off = <span class="tok-number">6.779051325638371598e+33</span> },</span>
<span class="line" id="L264">    HP{ .val = <span class="tok-number">1.000000e+50</span>, .off = -<span class="tok-number">7.629769841091887392e+33</span> },</span>
<span class="line" id="L265">    HP{ .val = <span class="tok-number">1.000000e+49</span>, .off = <span class="tok-number">5.350972305245182400e+32</span> },</span>
<span class="line" id="L266">    HP{ .val = <span class="tok-number">1.000000e+48</span>, .off = -<span class="tok-number">4.384584304507619764e+31</span> },</span>
<span class="line" id="L267">    HP{ .val = <span class="tok-number">1.000000e+47</span>, .off = -<span class="tok-number">4.384584304507619876e+30</span> },</span>
<span class="line" id="L268">    HP{ .val = <span class="tok-number">1.000000e+46</span>, .off = <span class="tok-number">6.860180964052978705e+28</span> },</span>
<span class="line" id="L269">    HP{ .val = <span class="tok-number">1.000000e+45</span>, .off = <span class="tok-number">7.024271097546444878e+28</span> },</span>
<span class="line" id="L270">    HP{ .val = <span class="tok-number">1.000000e+44</span>, .off = -<span class="tok-number">8.821361405306422641e+27</span> },</span>
<span class="line" id="L271">    HP{ .val = <span class="tok-number">1.000000e+43</span>, .off = -<span class="tok-number">1.393721169594140991e+26</span> },</span>
<span class="line" id="L272">    HP{ .val = <span class="tok-number">1.000000e+42</span>, .off = -<span class="tok-number">4.488571267807591679e+25</span> },</span>
<span class="line" id="L273">    HP{ .val = <span class="tok-number">1.000000e+41</span>, .off = -<span class="tok-number">6.200086450407783195e+23</span> },</span>
<span class="line" id="L274">    HP{ .val = <span class="tok-number">1.000000e+40</span>, .off = -<span class="tok-number">3.037860284270036669e+23</span> },</span>
<span class="line" id="L275">    HP{ .val = <span class="tok-number">1.000000e+39</span>, .off = <span class="tok-number">6.029083362839682141e+22</span> },</span>
<span class="line" id="L276">    HP{ .val = <span class="tok-number">1.000000e+38</span>, .off = <span class="tok-number">2.251190176543965970e+21</span> },</span>
<span class="line" id="L277">    HP{ .val = <span class="tok-number">1.000000e+37</span>, .off = <span class="tok-number">4.612373417978788577e+20</span> },</span>
<span class="line" id="L278">    HP{ .val = <span class="tok-number">1.000000e+36</span>, .off = -<span class="tok-number">4.242063737401796198e+19</span> },</span>
<span class="line" id="L279">    HP{ .val = <span class="tok-number">1.000000e+35</span>, .off = <span class="tok-number">3.136633892082024448e+18</span> },</span>
<span class="line" id="L280">    HP{ .val = <span class="tok-number">1.000000e+34</span>, .off = <span class="tok-number">5.442476901295718400e+17</span> },</span>
<span class="line" id="L281">    HP{ .val = <span class="tok-number">1.000000e+33</span>, .off = <span class="tok-number">5.442476901295718400e+16</span> },</span>
<span class="line" id="L282">    HP{ .val = <span class="tok-number">1.000000e+32</span>, .off = -<span class="tok-number">5.366162204393472000e+15</span> },</span>
<span class="line" id="L283">    HP{ .val = <span class="tok-number">1.000000e+31</span>, .off = <span class="tok-number">3.641037050347520000e+14</span> },</span>
<span class="line" id="L284">    HP{ .val = <span class="tok-number">1.000000e+30</span>, .off = -<span class="tok-number">1.988462483865600000e+13</span> },</span>
<span class="line" id="L285">    HP{ .val = <span class="tok-number">1.000000e+29</span>, .off = <span class="tok-number">8.566849142784000000e+12</span> },</span>
<span class="line" id="L286">    HP{ .val = <span class="tok-number">1.000000e+28</span>, .off = <span class="tok-number">4.168802631680000000e+11</span> },</span>
<span class="line" id="L287">    HP{ .val = <span class="tok-number">1.000000e+27</span>, .off = -<span class="tok-number">1.328755507200000000e+10</span> },</span>
<span class="line" id="L288">    HP{ .val = <span class="tok-number">1.000000e+26</span>, .off = -<span class="tok-number">4.764729344000000000e+09</span> },</span>
<span class="line" id="L289">    HP{ .val = <span class="tok-number">1.000000e+25</span>, .off = -<span class="tok-number">9.059696640000000000e+08</span> },</span>
<span class="line" id="L290">    HP{ .val = <span class="tok-number">1.000000e+24</span>, .off = <span class="tok-number">1.677721600000000000e+07</span> },</span>
<span class="line" id="L291">    HP{ .val = <span class="tok-number">1.000000e+23</span>, .off = <span class="tok-number">8.388608000000000000e+06</span> },</span>
<span class="line" id="L292">    HP{ .val = <span class="tok-number">1.000000e+22</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L293">    HP{ .val = <span class="tok-number">1.000000e+21</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L294">    HP{ .val = <span class="tok-number">1.000000e+20</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L295">    HP{ .val = <span class="tok-number">1.000000e+19</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L296">    HP{ .val = <span class="tok-number">1.000000e+18</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L297">    HP{ .val = <span class="tok-number">1.000000e+17</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L298">    HP{ .val = <span class="tok-number">1.000000e+16</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L299">    HP{ .val = <span class="tok-number">1.000000e+15</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L300">    HP{ .val = <span class="tok-number">1.000000e+14</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L301">    HP{ .val = <span class="tok-number">1.000000e+13</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L302">    HP{ .val = <span class="tok-number">1.000000e+12</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L303">    HP{ .val = <span class="tok-number">1.000000e+11</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L304">    HP{ .val = <span class="tok-number">1.000000e+10</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L305">    HP{ .val = <span class="tok-number">1.000000e+09</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L306">    HP{ .val = <span class="tok-number">1.000000e+08</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L307">    HP{ .val = <span class="tok-number">1.000000e+07</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L308">    HP{ .val = <span class="tok-number">1.000000e+06</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L309">    HP{ .val = <span class="tok-number">1.000000e+05</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L310">    HP{ .val = <span class="tok-number">1.000000e+04</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L311">    HP{ .val = <span class="tok-number">1.000000e+03</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L312">    HP{ .val = <span class="tok-number">1.000000e+02</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L313">    HP{ .val = <span class="tok-number">1.000000e+01</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L314">    HP{ .val = <span class="tok-number">1.000000e+00</span>, .off = <span class="tok-number">0.000000000000000000e+00</span> },</span>
<span class="line" id="L315">    HP{ .val = <span class="tok-number">1.000000e-01</span>, .off = -<span class="tok-number">5.551115123125783010e-18</span> },</span>
<span class="line" id="L316">    HP{ .val = <span class="tok-number">1.000000e-02</span>, .off = -<span class="tok-number">2.081668171172168436e-19</span> },</span>
<span class="line" id="L317">    HP{ .val = <span class="tok-number">1.000000e-03</span>, .off = -<span class="tok-number">2.081668171172168557e-20</span> },</span>
<span class="line" id="L318">    HP{ .val = <span class="tok-number">1.000000e-04</span>, .off = -<span class="tok-number">4.792173602385929943e-21</span> },</span>
<span class="line" id="L319">    HP{ .val = <span class="tok-number">1.000000e-05</span>, .off = -<span class="tok-number">8.180305391403130547e-22</span> },</span>
<span class="line" id="L320">    HP{ .val = <span class="tok-number">1.000000e-06</span>, .off = <span class="tok-number">4.525188817411374069e-23</span> },</span>
<span class="line" id="L321">    HP{ .val = <span class="tok-number">1.000000e-07</span>, .off = <span class="tok-number">4.525188817411373922e-24</span> },</span>
<span class="line" id="L322">    HP{ .val = <span class="tok-number">1.000000e-08</span>, .off = -<span class="tok-number">2.092256083012847109e-25</span> },</span>
<span class="line" id="L323">    HP{ .val = <span class="tok-number">1.000000e-09</span>, .off = -<span class="tok-number">6.228159145777985254e-26</span> },</span>
<span class="line" id="L324">    HP{ .val = <span class="tok-number">1.000000e-10</span>, .off = -<span class="tok-number">3.643219731549774344e-27</span> },</span>
<span class="line" id="L325">    HP{ .val = <span class="tok-number">1.000000e-11</span>, .off = <span class="tok-number">6.050303071806019080e-28</span> },</span>
<span class="line" id="L326">    HP{ .val = <span class="tok-number">1.000000e-12</span>, .off = <span class="tok-number">2.011335237074438524e-29</span> },</span>
<span class="line" id="L327">    HP{ .val = <span class="tok-number">1.000000e-13</span>, .off = -<span class="tok-number">3.037374556340037101e-30</span> },</span>
<span class="line" id="L328">    HP{ .val = <span class="tok-number">1.000000e-14</span>, .off = <span class="tok-number">1.180690645440101289e-32</span> },</span>
<span class="line" id="L329">    HP{ .val = <span class="tok-number">1.000000e-15</span>, .off = -<span class="tok-number">7.770539987666107583e-32</span> },</span>
<span class="line" id="L330">    HP{ .val = <span class="tok-number">1.000000e-16</span>, .off = <span class="tok-number">2.090221327596539779e-33</span> },</span>
<span class="line" id="L331">    HP{ .val = <span class="tok-number">1.000000e-17</span>, .off = -<span class="tok-number">7.154242405462192144e-34</span> },</span>
<span class="line" id="L332">    HP{ .val = <span class="tok-number">1.000000e-18</span>, .off = -<span class="tok-number">7.154242405462192572e-35</span> },</span>
<span class="line" id="L333">    HP{ .val = <span class="tok-number">1.000000e-19</span>, .off = <span class="tok-number">2.475407316473986894e-36</span> },</span>
<span class="line" id="L334">    HP{ .val = <span class="tok-number">1.000000e-20</span>, .off = <span class="tok-number">5.484672854579042914e-37</span> },</span>
<span class="line" id="L335">    HP{ .val = <span class="tok-number">1.000000e-21</span>, .off = <span class="tok-number">9.246254777210362522e-38</span> },</span>
<span class="line" id="L336">    HP{ .val = <span class="tok-number">1.000000e-22</span>, .off = -<span class="tok-number">4.859677432657087182e-39</span> },</span>
<span class="line" id="L337">    HP{ .val = <span class="tok-number">1.000000e-23</span>, .off = <span class="tok-number">3.956530198510069291e-40</span> },</span>
<span class="line" id="L338">    HP{ .val = <span class="tok-number">1.000000e-24</span>, .off = <span class="tok-number">7.629950044829717753e-41</span> },</span>
<span class="line" id="L339">    HP{ .val = <span class="tok-number">1.000000e-25</span>, .off = -<span class="tok-number">3.849486974919183692e-42</span> },</span>
<span class="line" id="L340">    HP{ .val = <span class="tok-number">1.000000e-26</span>, .off = -<span class="tok-number">3.849486974919184170e-43</span> },</span>
<span class="line" id="L341">    HP{ .val = <span class="tok-number">1.000000e-27</span>, .off = -<span class="tok-number">3.849486974919184070e-44</span> },</span>
<span class="line" id="L342">    HP{ .val = <span class="tok-number">1.000000e-28</span>, .off = <span class="tok-number">2.876745653839937870e-45</span> },</span>
<span class="line" id="L343">    HP{ .val = <span class="tok-number">1.000000e-29</span>, .off = <span class="tok-number">5.679342582489572168e-46</span> },</span>
<span class="line" id="L344">    HP{ .val = <span class="tok-number">1.000000e-30</span>, .off = -<span class="tok-number">8.333642060758598930e-47</span> },</span>
<span class="line" id="L345">    HP{ .val = <span class="tok-number">1.000000e-31</span>, .off = -<span class="tok-number">8.333642060758597958e-48</span> },</span>
<span class="line" id="L346">    HP{ .val = <span class="tok-number">1.000000e-32</span>, .off = -<span class="tok-number">5.596730997624190224e-49</span> },</span>
<span class="line" id="L347">    HP{ .val = <span class="tok-number">1.000000e-33</span>, .off = -<span class="tok-number">5.596730997624190604e-50</span> },</span>
<span class="line" id="L348">    HP{ .val = <span class="tok-number">1.000000e-34</span>, .off = <span class="tok-number">7.232539610818348498e-51</span> },</span>
<span class="line" id="L349">    HP{ .val = <span class="tok-number">1.000000e-35</span>, .off = -<span class="tok-number">7.857545194582380514e-53</span> },</span>
<span class="line" id="L350">    HP{ .val = <span class="tok-number">1.000000e-36</span>, .off = <span class="tok-number">5.896157255772251528e-53</span> },</span>
<span class="line" id="L351">    HP{ .val = <span class="tok-number">1.000000e-37</span>, .off = -<span class="tok-number">6.632427322784915796e-54</span> },</span>
<span class="line" id="L352">    HP{ .val = <span class="tok-number">1.000000e-38</span>, .off = <span class="tok-number">3.808059826012723592e-55</span> },</span>
<span class="line" id="L353">    HP{ .val = <span class="tok-number">1.000000e-39</span>, .off = <span class="tok-number">7.070712060011985131e-56</span> },</span>
<span class="line" id="L354">    HP{ .val = <span class="tok-number">1.000000e-40</span>, .off = <span class="tok-number">7.070712060011985584e-57</span> },</span>
<span class="line" id="L355">    HP{ .val = <span class="tok-number">1.000000e-41</span>, .off = -<span class="tok-number">5.761291134237854167e-59</span> },</span>
<span class="line" id="L356">    HP{ .val = <span class="tok-number">1.000000e-42</span>, .off = -<span class="tok-number">3.762312935688689794e-59</span> },</span>
<span class="line" id="L357">    HP{ .val = <span class="tok-number">1.000000e-43</span>, .off = -<span class="tok-number">7.745042713519821150e-60</span> },</span>
<span class="line" id="L358">    HP{ .val = <span class="tok-number">1.000000e-44</span>, .off = <span class="tok-number">4.700987842202462817e-61</span> },</span>
<span class="line" id="L359">    HP{ .val = <span class="tok-number">1.000000e-45</span>, .off = <span class="tok-number">1.589480203271891964e-62</span> },</span>
<span class="line" id="L360">    HP{ .val = <span class="tok-number">1.000000e-46</span>, .off = -<span class="tok-number">2.299904345391321765e-63</span> },</span>
<span class="line" id="L361">    HP{ .val = <span class="tok-number">1.000000e-47</span>, .off = <span class="tok-number">2.561826340437695261e-64</span> },</span>
<span class="line" id="L362">    HP{ .val = <span class="tok-number">1.000000e-48</span>, .off = <span class="tok-number">2.561826340437695345e-65</span> },</span>
<span class="line" id="L363">    HP{ .val = <span class="tok-number">1.000000e-49</span>, .off = <span class="tok-number">6.360053438741614633e-66</span> },</span>
<span class="line" id="L364">    HP{ .val = <span class="tok-number">1.000000e-50</span>, .off = -<span class="tok-number">7.616223705782342295e-68</span> },</span>
<span class="line" id="L365">    HP{ .val = <span class="tok-number">1.000000e-51</span>, .off = -<span class="tok-number">7.616223705782343324e-69</span> },</span>
<span class="line" id="L366">    HP{ .val = <span class="tok-number">1.000000e-52</span>, .off = -<span class="tok-number">7.616223705782342295e-70</span> },</span>
<span class="line" id="L367">    HP{ .val = <span class="tok-number">1.000000e-53</span>, .off = -<span class="tok-number">3.079876214757872338e-70</span> },</span>
<span class="line" id="L368">    HP{ .val = <span class="tok-number">1.000000e-54</span>, .off = -<span class="tok-number">3.079876214757872821e-71</span> },</span>
<span class="line" id="L369">    HP{ .val = <span class="tok-number">1.000000e-55</span>, .off = <span class="tok-number">5.423954167728123147e-73</span> },</span>
<span class="line" id="L370">    HP{ .val = <span class="tok-number">1.000000e-56</span>, .off = -<span class="tok-number">3.985444122640543680e-73</span> },</span>
<span class="line" id="L371">    HP{ .val = <span class="tok-number">1.000000e-57</span>, .off = <span class="tok-number">4.504255013759498850e-74</span> },</span>
<span class="line" id="L372">    HP{ .val = <span class="tok-number">1.000000e-58</span>, .off = -<span class="tok-number">2.570494266573869991e-75</span> },</span>
<span class="line" id="L373">    HP{ .val = <span class="tok-number">1.000000e-59</span>, .off = -<span class="tok-number">2.570494266573869930e-76</span> },</span>
<span class="line" id="L374">    HP{ .val = <span class="tok-number">1.000000e-60</span>, .off = <span class="tok-number">2.956653608686574324e-77</span> },</span>
<span class="line" id="L375">    HP{ .val = <span class="tok-number">1.000000e-61</span>, .off = -<span class="tok-number">3.952281235388981376e-78</span> },</span>
<span class="line" id="L376">    HP{ .val = <span class="tok-number">1.000000e-62</span>, .off = -<span class="tok-number">3.952281235388981376e-79</span> },</span>
<span class="line" id="L377">    HP{ .val = <span class="tok-number">1.000000e-63</span>, .off = -<span class="tok-number">6.651083908855995172e-80</span> },</span>
<span class="line" id="L378">    HP{ .val = <span class="tok-number">1.000000e-64</span>, .off = <span class="tok-number">3.469426116645307030e-81</span> },</span>
<span class="line" id="L379">    HP{ .val = <span class="tok-number">1.000000e-65</span>, .off = <span class="tok-number">7.686305293937516319e-82</span> },</span>
<span class="line" id="L380">    HP{ .val = <span class="tok-number">1.000000e-66</span>, .off = <span class="tok-number">2.415206322322254927e-83</span> },</span>
<span class="line" id="L381">    HP{ .val = <span class="tok-number">1.000000e-67</span>, .off = <span class="tok-number">5.709643179581793251e-84</span> },</span>
<span class="line" id="L382">    HP{ .val = <span class="tok-number">1.000000e-68</span>, .off = -<span class="tok-number">6.644495035141475923e-85</span> },</span>
<span class="line" id="L383">    HP{ .val = <span class="tok-number">1.000000e-69</span>, .off = <span class="tok-number">3.650620143794581913e-86</span> },</span>
<span class="line" id="L384">    HP{ .val = <span class="tok-number">1.000000e-70</span>, .off = <span class="tok-number">4.333966503770636492e-88</span> },</span>
<span class="line" id="L385">    HP{ .val = <span class="tok-number">1.000000e-71</span>, .off = <span class="tok-number">8.476455383920859113e-88</span> },</span>
<span class="line" id="L386">    HP{ .val = <span class="tok-number">1.000000e-72</span>, .off = <span class="tok-number">3.449543675455986564e-89</span> },</span>
<span class="line" id="L387">    HP{ .val = <span class="tok-number">1.000000e-73</span>, .off = <span class="tok-number">3.077238576654418974e-91</span> },</span>
<span class="line" id="L388">    HP{ .val = <span class="tok-number">1.000000e-74</span>, .off = <span class="tok-number">4.234998629903623140e-91</span> },</span>
<span class="line" id="L389">    HP{ .val = <span class="tok-number">1.000000e-75</span>, .off = <span class="tok-number">4.234998629903623412e-92</span> },</span>
<span class="line" id="L390">    HP{ .val = <span class="tok-number">1.000000e-76</span>, .off = <span class="tok-number">7.303182045714702338e-93</span> },</span>
<span class="line" id="L391">    HP{ .val = <span class="tok-number">1.000000e-77</span>, .off = <span class="tok-number">7.303182045714701699e-94</span> },</span>
<span class="line" id="L392">    HP{ .val = <span class="tok-number">1.000000e-78</span>, .off = <span class="tok-number">1.121271649074855759e-96</span> },</span>
<span class="line" id="L393">    HP{ .val = <span class="tok-number">1.000000e-79</span>, .off = <span class="tok-number">1.121271649074855863e-97</span> },</span>
<span class="line" id="L394">    HP{ .val = <span class="tok-number">1.000000e-80</span>, .off = <span class="tok-number">3.857468248661243988e-97</span> },</span>
<span class="line" id="L395">    HP{ .val = <span class="tok-number">1.000000e-81</span>, .off = <span class="tok-number">3.857468248661244248e-98</span> },</span>
<span class="line" id="L396">    HP{ .val = <span class="tok-number">1.000000e-82</span>, .off = <span class="tok-number">3.857468248661244410e-99</span> },</span>
<span class="line" id="L397">    HP{ .val = <span class="tok-number">1.000000e-83</span>, .off = -<span class="tok-number">3.457651055545315679e-100</span> },</span>
<span class="line" id="L398">    HP{ .val = <span class="tok-number">1.000000e-84</span>, .off = -<span class="tok-number">3.457651055545315933e-101</span> },</span>
<span class="line" id="L399">    HP{ .val = <span class="tok-number">1.000000e-85</span>, .off = <span class="tok-number">2.257285900866059216e-102</span> },</span>
<span class="line" id="L400">    HP{ .val = <span class="tok-number">1.000000e-86</span>, .off = -<span class="tok-number">8.458220892405268345e-103</span> },</span>
<span class="line" id="L401">    HP{ .val = <span class="tok-number">1.000000e-87</span>, .off = -<span class="tok-number">1.761029146610688867e-104</span> },</span>
<span class="line" id="L402">    HP{ .val = <span class="tok-number">1.000000e-88</span>, .off = <span class="tok-number">6.610460535632536565e-105</span> },</span>
<span class="line" id="L403">    HP{ .val = <span class="tok-number">1.000000e-89</span>, .off = -<span class="tok-number">3.853901567171494935e-106</span> },</span>
<span class="line" id="L404">    HP{ .val = <span class="tok-number">1.000000e-90</span>, .off = <span class="tok-number">5.062493089968513723e-108</span> },</span>
<span class="line" id="L405">    HP{ .val = <span class="tok-number">1.000000e-91</span>, .off = -<span class="tok-number">2.218844988608365240e-108</span> },</span>
<span class="line" id="L406">    HP{ .val = <span class="tok-number">1.000000e-92</span>, .off = <span class="tok-number">1.187522883398155383e-109</span> },</span>
<span class="line" id="L407">    HP{ .val = <span class="tok-number">1.000000e-93</span>, .off = <span class="tok-number">9.703442563414457296e-110</span> },</span>
<span class="line" id="L408">    HP{ .val = <span class="tok-number">1.000000e-94</span>, .off = <span class="tok-number">4.380992763404268896e-111</span> },</span>
<span class="line" id="L409">    HP{ .val = <span class="tok-number">1.000000e-95</span>, .off = <span class="tok-number">1.054461638397900823e-112</span> },</span>
<span class="line" id="L410">    HP{ .val = <span class="tok-number">1.000000e-96</span>, .off = <span class="tok-number">9.370789450913819736e-113</span> },</span>
<span class="line" id="L411">    HP{ .val = <span class="tok-number">1.000000e-97</span>, .off = -<span class="tok-number">3.623472756142303998e-114</span> },</span>
<span class="line" id="L412">    HP{ .val = <span class="tok-number">1.000000e-98</span>, .off = <span class="tok-number">6.122223899149788839e-115</span> },</span>
<span class="line" id="L413">    HP{ .val = <span class="tok-number">1.000000e-99</span>, .off = -<span class="tok-number">1.999189980260288281e-116</span> },</span>
<span class="line" id="L414">    HP{ .val = <span class="tok-number">1.000000e-100</span>, .off = -<span class="tok-number">1.999189980260288281e-117</span> },</span>
<span class="line" id="L415">    HP{ .val = <span class="tok-number">1.000000e-101</span>, .off = -<span class="tok-number">5.171617276904849634e-118</span> },</span>
<span class="line" id="L416">    HP{ .val = <span class="tok-number">1.000000e-102</span>, .off = <span class="tok-number">6.724985085512256320e-119</span> },</span>
<span class="line" id="L417">    HP{ .val = <span class="tok-number">1.000000e-103</span>, .off = <span class="tok-number">4.246526260008692213e-120</span> },</span>
<span class="line" id="L418">    HP{ .val = <span class="tok-number">1.000000e-104</span>, .off = <span class="tok-number">7.344599791888147003e-121</span> },</span>
<span class="line" id="L419">    HP{ .val = <span class="tok-number">1.000000e-105</span>, .off = <span class="tok-number">3.472007877038828407e-122</span> },</span>
<span class="line" id="L420">    HP{ .val = <span class="tok-number">1.000000e-106</span>, .off = <span class="tok-number">5.892377823819652194e-123</span> },</span>
<span class="line" id="L421">    HP{ .val = <span class="tok-number">1.000000e-107</span>, .off = -<span class="tok-number">1.585470431324073925e-125</span> },</span>
<span class="line" id="L422">    HP{ .val = <span class="tok-number">1.000000e-108</span>, .off = -<span class="tok-number">3.940375084977444795e-125</span> },</span>
<span class="line" id="L423">    HP{ .val = <span class="tok-number">1.000000e-109</span>, .off = <span class="tok-number">7.869099673288519908e-127</span> },</span>
<span class="line" id="L424">    HP{ .val = <span class="tok-number">1.000000e-110</span>, .off = -<span class="tok-number">5.122196348054018581e-127</span> },</span>
<span class="line" id="L425">    HP{ .val = <span class="tok-number">1.000000e-111</span>, .off = -<span class="tok-number">8.815387795168313713e-128</span> },</span>
<span class="line" id="L426">    HP{ .val = <span class="tok-number">1.000000e-112</span>, .off = <span class="tok-number">5.034080131510290214e-129</span> },</span>
<span class="line" id="L427">    HP{ .val = <span class="tok-number">1.000000e-113</span>, .off = <span class="tok-number">2.148774313452247863e-130</span> },</span>
<span class="line" id="L428">    HP{ .val = <span class="tok-number">1.000000e-114</span>, .off = -<span class="tok-number">5.064490231692858416e-131</span> },</span>
<span class="line" id="L429">    HP{ .val = <span class="tok-number">1.000000e-115</span>, .off = -<span class="tok-number">5.064490231692858166e-132</span> },</span>
<span class="line" id="L430">    HP{ .val = <span class="tok-number">1.000000e-116</span>, .off = <span class="tok-number">5.708726942017560559e-134</span> },</span>
<span class="line" id="L431">    HP{ .val = <span class="tok-number">1.000000e-117</span>, .off = -<span class="tok-number">2.951229134482377772e-134</span> },</span>
<span class="line" id="L432">    HP{ .val = <span class="tok-number">1.000000e-118</span>, .off = <span class="tok-number">1.451398151372789513e-135</span> },</span>
<span class="line" id="L433">    HP{ .val = <span class="tok-number">1.000000e-119</span>, .off = -<span class="tok-number">1.300243902286690040e-136</span> },</span>
<span class="line" id="L434">    HP{ .val = <span class="tok-number">1.000000e-120</span>, .off = <span class="tok-number">2.139308664787659449e-137</span> },</span>
<span class="line" id="L435">    HP{ .val = <span class="tok-number">1.000000e-121</span>, .off = <span class="tok-number">2.139308664787659329e-138</span> },</span>
<span class="line" id="L436">    HP{ .val = <span class="tok-number">1.000000e-122</span>, .off = -<span class="tok-number">5.922142664292847471e-139</span> },</span>
<span class="line" id="L437">    HP{ .val = <span class="tok-number">1.000000e-123</span>, .off = -<span class="tok-number">5.922142664292846912e-140</span> },</span>
<span class="line" id="L438">    HP{ .val = <span class="tok-number">1.000000e-124</span>, .off = <span class="tok-number">6.673875037395443799e-141</span> },</span>
<span class="line" id="L439">    HP{ .val = <span class="tok-number">1.000000e-125</span>, .off = -<span class="tok-number">1.198636026159737932e-142</span> },</span>
<span class="line" id="L440">    HP{ .val = <span class="tok-number">1.000000e-126</span>, .off = <span class="tok-number">5.361789860136246995e-143</span> },</span>
<span class="line" id="L441">    HP{ .val = <span class="tok-number">1.000000e-127</span>, .off = -<span class="tok-number">2.838742497733733936e-144</span> },</span>
<span class="line" id="L442">    HP{ .val = <span class="tok-number">1.000000e-128</span>, .off = -<span class="tok-number">5.401408859568103261e-145</span> },</span>
<span class="line" id="L443">    HP{ .val = <span class="tok-number">1.000000e-129</span>, .off = <span class="tok-number">7.411922949603743011e-146</span> },</span>
<span class="line" id="L444">    HP{ .val = <span class="tok-number">1.000000e-130</span>, .off = -<span class="tok-number">8.604741811861064385e-147</span> },</span>
<span class="line" id="L445">    HP{ .val = <span class="tok-number">1.000000e-131</span>, .off = <span class="tok-number">1.405673664054439890e-148</span> },</span>
<span class="line" id="L446">    HP{ .val = <span class="tok-number">1.000000e-132</span>, .off = <span class="tok-number">1.405673664054439933e-149</span> },</span>
<span class="line" id="L447">    HP{ .val = <span class="tok-number">1.000000e-133</span>, .off = -<span class="tok-number">6.414963426504548053e-150</span> },</span>
<span class="line" id="L448">    HP{ .val = <span class="tok-number">1.000000e-134</span>, .off = -<span class="tok-number">3.971014335704864578e-151</span> },</span>
<span class="line" id="L449">    HP{ .val = <span class="tok-number">1.000000e-135</span>, .off = -<span class="tok-number">3.971014335704864748e-152</span> },</span>
<span class="line" id="L450">    HP{ .val = <span class="tok-number">1.000000e-136</span>, .off = -<span class="tok-number">1.523438813303585576e-154</span> },</span>
<span class="line" id="L451">    HP{ .val = <span class="tok-number">1.000000e-137</span>, .off = <span class="tok-number">2.234325152653707766e-154</span> },</span>
<span class="line" id="L452">    HP{ .val = <span class="tok-number">1.000000e-138</span>, .off = -<span class="tok-number">6.715683724786540160e-155</span> },</span>
<span class="line" id="L453">    HP{ .val = <span class="tok-number">1.000000e-139</span>, .off = -<span class="tok-number">2.986513359186437306e-156</span> },</span>
<span class="line" id="L454">    HP{ .val = <span class="tok-number">1.000000e-140</span>, .off = <span class="tok-number">1.674949597813692102e-157</span> },</span>
<span class="line" id="L455">    HP{ .val = <span class="tok-number">1.000000e-141</span>, .off = -<span class="tok-number">4.151879098436469092e-158</span> },</span>
<span class="line" id="L456">    HP{ .val = <span class="tok-number">1.000000e-142</span>, .off = -<span class="tok-number">4.151879098436469295e-159</span> },</span>
<span class="line" id="L457">    HP{ .val = <span class="tok-number">1.000000e-143</span>, .off = <span class="tok-number">4.952540739454407825e-160</span> },</span>
<span class="line" id="L458">    HP{ .val = <span class="tok-number">1.000000e-144</span>, .off = <span class="tok-number">4.952540739454407667e-161</span> },</span>
<span class="line" id="L459">    HP{ .val = <span class="tok-number">1.000000e-145</span>, .off = <span class="tok-number">8.508954738630531443e-162</span> },</span>
<span class="line" id="L460">    HP{ .val = <span class="tok-number">1.000000e-146</span>, .off = -<span class="tok-number">2.604839008794855481e-163</span> },</span>
<span class="line" id="L461">    HP{ .val = <span class="tok-number">1.000000e-147</span>, .off = <span class="tok-number">2.952057864917838382e-164</span> },</span>
<span class="line" id="L462">    HP{ .val = <span class="tok-number">1.000000e-148</span>, .off = <span class="tok-number">6.425118410988271757e-165</span> },</span>
<span class="line" id="L463">    HP{ .val = <span class="tok-number">1.000000e-149</span>, .off = <span class="tok-number">2.083792728400229858e-166</span> },</span>
<span class="line" id="L464">    HP{ .val = <span class="tok-number">1.000000e-150</span>, .off = -<span class="tok-number">6.295358232172964237e-168</span> },</span>
<span class="line" id="L465">    HP{ .val = <span class="tok-number">1.000000e-151</span>, .off = <span class="tok-number">6.153785555826519421e-168</span> },</span>
<span class="line" id="L466">    HP{ .val = <span class="tok-number">1.000000e-152</span>, .off = -<span class="tok-number">6.564942029880634994e-169</span> },</span>
<span class="line" id="L467">    HP{ .val = <span class="tok-number">1.000000e-153</span>, .off = -<span class="tok-number">3.915207116191644540e-170</span> },</span>
<span class="line" id="L468">    HP{ .val = <span class="tok-number">1.000000e-154</span>, .off = <span class="tok-number">2.709130168030831503e-171</span> },</span>
<span class="line" id="L469">    HP{ .val = <span class="tok-number">1.000000e-155</span>, .off = -<span class="tok-number">1.431080634608215966e-172</span> },</span>
<span class="line" id="L470">    HP{ .val = <span class="tok-number">1.000000e-156</span>, .off = -<span class="tok-number">4.018712386257620994e-173</span> },</span>
<span class="line" id="L471">    HP{ .val = <span class="tok-number">1.000000e-157</span>, .off = <span class="tok-number">5.684906682427646782e-174</span> },</span>
<span class="line" id="L472">    HP{ .val = <span class="tok-number">1.000000e-158</span>, .off = -<span class="tok-number">6.444617153428937489e-175</span> },</span>
<span class="line" id="L473">    HP{ .val = <span class="tok-number">1.000000e-159</span>, .off = <span class="tok-number">1.136335243981427681e-176</span> },</span>
<span class="line" id="L474">    HP{ .val = <span class="tok-number">1.000000e-160</span>, .off = <span class="tok-number">1.136335243981427725e-177</span> },</span>
<span class="line" id="L475">    HP{ .val = <span class="tok-number">1.000000e-161</span>, .off = -<span class="tok-number">2.812077463003137395e-178</span> },</span>
<span class="line" id="L476">    HP{ .val = <span class="tok-number">1.000000e-162</span>, .off = <span class="tok-number">4.591196362592922204e-179</span> },</span>
<span class="line" id="L477">    HP{ .val = <span class="tok-number">1.000000e-163</span>, .off = <span class="tok-number">7.675893789924613703e-180</span> },</span>
<span class="line" id="L478">    HP{ .val = <span class="tok-number">1.000000e-164</span>, .off = <span class="tok-number">3.820022005759999543e-181</span> },</span>
<span class="line" id="L479">    HP{ .val = <span class="tok-number">1.000000e-165</span>, .off = -<span class="tok-number">9.998177244457686588e-183</span> },</span>
<span class="line" id="L480">    HP{ .val = <span class="tok-number">1.000000e-166</span>, .off = -<span class="tok-number">4.012217555824373639e-183</span> },</span>
<span class="line" id="L481">    HP{ .val = <span class="tok-number">1.000000e-167</span>, .off = -<span class="tok-number">2.467177666011174334e-185</span> },</span>
<span class="line" id="L482">    HP{ .val = <span class="tok-number">1.000000e-168</span>, .off = -<span class="tok-number">4.953592503130188139e-185</span> },</span>
<span class="line" id="L483">    HP{ .val = <span class="tok-number">1.000000e-169</span>, .off = -<span class="tok-number">2.011795792799518887e-186</span> },</span>
<span class="line" id="L484">    HP{ .val = <span class="tok-number">1.000000e-170</span>, .off = <span class="tok-number">1.665450095113817423e-187</span> },</span>
<span class="line" id="L485">    HP{ .val = <span class="tok-number">1.000000e-171</span>, .off = <span class="tok-number">1.665450095113817487e-188</span> },</span>
<span class="line" id="L486">    HP{ .val = <span class="tok-number">1.000000e-172</span>, .off = -<span class="tok-number">4.080246604750770577e-189</span> },</span>
<span class="line" id="L487">    HP{ .val = <span class="tok-number">1.000000e-173</span>, .off = -<span class="tok-number">4.080246604750770677e-190</span> },</span>
<span class="line" id="L488">    HP{ .val = <span class="tok-number">1.000000e-174</span>, .off = <span class="tok-number">4.085789420184387951e-192</span> },</span>
<span class="line" id="L489">    HP{ .val = <span class="tok-number">1.000000e-175</span>, .off = <span class="tok-number">4.085789420184388146e-193</span> },</span>
<span class="line" id="L490">    HP{ .val = <span class="tok-number">1.000000e-176</span>, .off = <span class="tok-number">4.085789420184388146e-194</span> },</span>
<span class="line" id="L491">    HP{ .val = <span class="tok-number">1.000000e-177</span>, .off = <span class="tok-number">4.792197640035244894e-194</span> },</span>
<span class="line" id="L492">    HP{ .val = <span class="tok-number">1.000000e-178</span>, .off = <span class="tok-number">4.792197640035244742e-195</span> },</span>
<span class="line" id="L493">    HP{ .val = <span class="tok-number">1.000000e-179</span>, .off = -<span class="tok-number">2.057206575616014662e-196</span> },</span>
<span class="line" id="L494">    HP{ .val = <span class="tok-number">1.000000e-180</span>, .off = -<span class="tok-number">2.057206575616014662e-197</span> },</span>
<span class="line" id="L495">    HP{ .val = <span class="tok-number">1.000000e-181</span>, .off = -<span class="tok-number">4.732755097354788053e-198</span> },</span>
<span class="line" id="L496">    HP{ .val = <span class="tok-number">1.000000e-182</span>, .off = -<span class="tok-number">4.732755097354787867e-199</span> },</span>
<span class="line" id="L497">    HP{ .val = <span class="tok-number">1.000000e-183</span>, .off = -<span class="tok-number">5.522105321379546765e-201</span> },</span>
<span class="line" id="L498">    HP{ .val = <span class="tok-number">1.000000e-184</span>, .off = -<span class="tok-number">5.777891238658996019e-201</span> },</span>
<span class="line" id="L499">    HP{ .val = <span class="tok-number">1.000000e-185</span>, .off = <span class="tok-number">7.542096444923057046e-203</span> },</span>
<span class="line" id="L500">    HP{ .val = <span class="tok-number">1.000000e-186</span>, .off = <span class="tok-number">8.919335748431433483e-203</span> },</span>
<span class="line" id="L501">    HP{ .val = <span class="tok-number">1.000000e-187</span>, .off = -<span class="tok-number">1.287071881492476028e-204</span> },</span>
<span class="line" id="L502">    HP{ .val = <span class="tok-number">1.000000e-188</span>, .off = <span class="tok-number">5.091932887209967018e-205</span> },</span>
<span class="line" id="L503">    HP{ .val = <span class="tok-number">1.000000e-189</span>, .off = -<span class="tok-number">6.868701054107114024e-206</span> },</span>
<span class="line" id="L504">    HP{ .val = <span class="tok-number">1.000000e-190</span>, .off = -<span class="tok-number">1.885103578558330118e-207</span> },</span>
<span class="line" id="L505">    HP{ .val = <span class="tok-number">1.000000e-191</span>, .off = -<span class="tok-number">1.885103578558330205e-208</span> },</span>
<span class="line" id="L506">    HP{ .val = <span class="tok-number">1.000000e-192</span>, .off = -<span class="tok-number">9.671974634103305058e-209</span> },</span>
<span class="line" id="L507">    HP{ .val = <span class="tok-number">1.000000e-193</span>, .off = -<span class="tok-number">4.805180224387695640e-210</span> },</span>
<span class="line" id="L508">    HP{ .val = <span class="tok-number">1.000000e-194</span>, .off = -<span class="tok-number">1.763433718315439838e-211</span> },</span>
<span class="line" id="L509">    HP{ .val = <span class="tok-number">1.000000e-195</span>, .off = -<span class="tok-number">9.367799983496079132e-212</span> },</span>
<span class="line" id="L510">    HP{ .val = <span class="tok-number">1.000000e-196</span>, .off = -<span class="tok-number">4.615071067758179837e-213</span> },</span>
<span class="line" id="L511">    HP{ .val = <span class="tok-number">1.000000e-197</span>, .off = <span class="tok-number">1.325840076914194777e-214</span> },</span>
<span class="line" id="L512">    HP{ .val = <span class="tok-number">1.000000e-198</span>, .off = <span class="tok-number">8.751979007754662425e-215</span> },</span>
<span class="line" id="L513">    HP{ .val = <span class="tok-number">1.000000e-199</span>, .off = <span class="tok-number">1.789973760091724198e-216</span> },</span>
<span class="line" id="L514">    HP{ .val = <span class="tok-number">1.000000e-200</span>, .off = <span class="tok-number">1.789973760091724077e-217</span> },</span>
<span class="line" id="L515">    HP{ .val = <span class="tok-number">1.000000e-201</span>, .off = <span class="tok-number">5.416018159916171171e-218</span> },</span>
<span class="line" id="L516">    HP{ .val = <span class="tok-number">1.000000e-202</span>, .off = -<span class="tok-number">3.649092839644947067e-219</span> },</span>
<span class="line" id="L517">    HP{ .val = <span class="tok-number">1.000000e-203</span>, .off = -<span class="tok-number">3.649092839644947067e-220</span> },</span>
<span class="line" id="L518">    HP{ .val = <span class="tok-number">1.000000e-204</span>, .off = -<span class="tok-number">1.080338554413850956e-222</span> },</span>
<span class="line" id="L519">    HP{ .val = <span class="tok-number">1.000000e-205</span>, .off = -<span class="tok-number">1.080338554413850841e-223</span> },</span>
<span class="line" id="L520">    HP{ .val = <span class="tok-number">1.000000e-206</span>, .off = -<span class="tok-number">2.874486186850417807e-223</span> },</span>
<span class="line" id="L521">    HP{ .val = <span class="tok-number">1.000000e-207</span>, .off = <span class="tok-number">7.499710055933455072e-224</span> },</span>
<span class="line" id="L522">    HP{ .val = <span class="tok-number">1.000000e-208</span>, .off = -<span class="tok-number">9.790617015372999087e-225</span> },</span>
<span class="line" id="L523">    HP{ .val = <span class="tok-number">1.000000e-209</span>, .off = -<span class="tok-number">4.387389805589732612e-226</span> },</span>
<span class="line" id="L524">    HP{ .val = <span class="tok-number">1.000000e-210</span>, .off = -<span class="tok-number">4.387389805589732612e-227</span> },</span>
<span class="line" id="L525">    HP{ .val = <span class="tok-number">1.000000e-211</span>, .off = -<span class="tok-number">8.608661063232909897e-228</span> },</span>
<span class="line" id="L526">    HP{ .val = <span class="tok-number">1.000000e-212</span>, .off = <span class="tok-number">4.582811616902018972e-229</span> },</span>
<span class="line" id="L527">    HP{ .val = <span class="tok-number">1.000000e-213</span>, .off = <span class="tok-number">4.582811616902019155e-230</span> },</span>
<span class="line" id="L528">    HP{ .val = <span class="tok-number">1.000000e-214</span>, .off = <span class="tok-number">8.705146829444184930e-231</span> },</span>
<span class="line" id="L529">    HP{ .val = <span class="tok-number">1.000000e-215</span>, .off = -<span class="tok-number">4.177150709750081830e-232</span> },</span>
<span class="line" id="L530">    HP{ .val = <span class="tok-number">1.000000e-216</span>, .off = -<span class="tok-number">4.177150709750082366e-233</span> },</span>
<span class="line" id="L531">    HP{ .val = <span class="tok-number">1.000000e-217</span>, .off = -<span class="tok-number">8.202868690748290237e-234</span> },</span>
<span class="line" id="L532">    HP{ .val = <span class="tok-number">1.000000e-218</span>, .off = -<span class="tok-number">3.170721214500530119e-235</span> },</span>
<span class="line" id="L533">    HP{ .val = <span class="tok-number">1.000000e-219</span>, .off = -<span class="tok-number">3.170721214500529857e-236</span> },</span>
<span class="line" id="L534">    HP{ .val = <span class="tok-number">1.000000e-220</span>, .off = <span class="tok-number">7.606440013180328441e-238</span> },</span>
<span class="line" id="L535">    HP{ .val = <span class="tok-number">1.000000e-221</span>, .off = -<span class="tok-number">1.696459258568569049e-238</span> },</span>
<span class="line" id="L536">    HP{ .val = <span class="tok-number">1.000000e-222</span>, .off = -<span class="tok-number">4.767838333426821244e-239</span> },</span>
<span class="line" id="L537">    HP{ .val = <span class="tok-number">1.000000e-223</span>, .off = <span class="tok-number">2.910609353718809138e-240</span> },</span>
<span class="line" id="L538">    HP{ .val = <span class="tok-number">1.000000e-224</span>, .off = -<span class="tok-number">1.888420450747209784e-241</span> },</span>
<span class="line" id="L539">    HP{ .val = <span class="tok-number">1.000000e-225</span>, .off = <span class="tok-number">4.110366804835314035e-242</span> },</span>
<span class="line" id="L540">    HP{ .val = <span class="tok-number">1.000000e-226</span>, .off = <span class="tok-number">7.859608839574391006e-243</span> },</span>
<span class="line" id="L541">    HP{ .val = <span class="tok-number">1.000000e-227</span>, .off = <span class="tok-number">5.516332567862468419e-244</span> },</span>
<span class="line" id="L542">    HP{ .val = <span class="tok-number">1.000000e-228</span>, .off = -<span class="tok-number">3.270953451057244613e-245</span> },</span>
<span class="line" id="L543">    HP{ .val = <span class="tok-number">1.000000e-229</span>, .off = -<span class="tok-number">6.932322625607124670e-246</span> },</span>
<span class="line" id="L544">    HP{ .val = <span class="tok-number">1.000000e-230</span>, .off = -<span class="tok-number">4.643966891513449762e-247</span> },</span>
<span class="line" id="L545">    HP{ .val = <span class="tok-number">1.000000e-231</span>, .off = <span class="tok-number">1.076922443720738305e-248</span> },</span>
<span class="line" id="L546">    HP{ .val = <span class="tok-number">1.000000e-232</span>, .off = -<span class="tok-number">2.498633390800628939e-249</span> },</span>
<span class="line" id="L547">    HP{ .val = <span class="tok-number">1.000000e-233</span>, .off = <span class="tok-number">4.205533798926934891e-250</span> },</span>
<span class="line" id="L548">    HP{ .val = <span class="tok-number">1.000000e-234</span>, .off = <span class="tok-number">4.205533798926934891e-251</span> },</span>
<span class="line" id="L549">    HP{ .val = <span class="tok-number">1.000000e-235</span>, .off = <span class="tok-number">4.205533798926934697e-252</span> },</span>
<span class="line" id="L550">    HP{ .val = <span class="tok-number">1.000000e-236</span>, .off = -<span class="tok-number">4.523850562697497656e-253</span> },</span>
<span class="line" id="L551">    HP{ .val = <span class="tok-number">1.000000e-237</span>, .off = <span class="tok-number">9.320146633177728298e-255</span> },</span>
<span class="line" id="L552">    HP{ .val = <span class="tok-number">1.000000e-238</span>, .off = <span class="tok-number">9.320146633177728062e-256</span> },</span>
<span class="line" id="L553">    HP{ .val = <span class="tok-number">1.000000e-239</span>, .off = -<span class="tok-number">7.592774752331086440e-256</span> },</span>
<span class="line" id="L554">    HP{ .val = <span class="tok-number">1.000000e-240</span>, .off = <span class="tok-number">3.063212017229987840e-257</span> },</span>
<span class="line" id="L555">    HP{ .val = <span class="tok-number">1.000000e-241</span>, .off = <span class="tok-number">3.063212017229987562e-258</span> },</span>
<span class="line" id="L556">    HP{ .val = <span class="tok-number">1.000000e-242</span>, .off = <span class="tok-number">3.063212017229987562e-259</span> },</span>
<span class="line" id="L557">    HP{ .val = <span class="tok-number">1.000000e-243</span>, .off = <span class="tok-number">4.616527473176159842e-261</span> },</span>
<span class="line" id="L558">    HP{ .val = <span class="tok-number">1.000000e-244</span>, .off = <span class="tok-number">6.965550922098544975e-261</span> },</span>
<span class="line" id="L559">    HP{ .val = <span class="tok-number">1.000000e-245</span>, .off = <span class="tok-number">6.965550922098544749e-262</span> },</span>
<span class="line" id="L560">    HP{ .val = <span class="tok-number">1.000000e-246</span>, .off = <span class="tok-number">4.424965697574744679e-263</span> },</span>
<span class="line" id="L561">    HP{ .val = <span class="tok-number">1.000000e-247</span>, .off = -<span class="tok-number">1.926497363734756420e-264</span> },</span>
<span class="line" id="L562">    HP{ .val = <span class="tok-number">1.000000e-248</span>, .off = <span class="tok-number">2.043167049583681740e-265</span> },</span>
<span class="line" id="L563">    HP{ .val = <span class="tok-number">1.000000e-249</span>, .off = -<span class="tok-number">5.399953725388390154e-266</span> },</span>
<span class="line" id="L564">    HP{ .val = <span class="tok-number">1.000000e-250</span>, .off = -<span class="tok-number">5.399953725388389982e-267</span> },</span>
<span class="line" id="L565">    HP{ .val = <span class="tok-number">1.000000e-251</span>, .off = -<span class="tok-number">1.523328321757102663e-268</span> },</span>
<span class="line" id="L566">    HP{ .val = <span class="tok-number">1.000000e-252</span>, .off = <span class="tok-number">5.745344310051561161e-269</span> },</span>
<span class="line" id="L567">    HP{ .val = <span class="tok-number">1.000000e-253</span>, .off = -<span class="tok-number">6.369110076296211879e-270</span> },</span>
<span class="line" id="L568">    HP{ .val = <span class="tok-number">1.000000e-254</span>, .off = <span class="tok-number">8.773957906638504842e-271</span> },</span>
<span class="line" id="L569">    HP{ .val = <span class="tok-number">1.000000e-255</span>, .off = -<span class="tok-number">6.904595826956931908e-273</span> },</span>
<span class="line" id="L570">    HP{ .val = <span class="tok-number">1.000000e-256</span>, .off = <span class="tok-number">2.267170882721243669e-273</span> },</span>
<span class="line" id="L571">    HP{ .val = <span class="tok-number">1.000000e-257</span>, .off = <span class="tok-number">2.267170882721243669e-274</span> },</span>
<span class="line" id="L572">    HP{ .val = <span class="tok-number">1.000000e-258</span>, .off = <span class="tok-number">4.577819683828225398e-275</span> },</span>
<span class="line" id="L573">    HP{ .val = <span class="tok-number">1.000000e-259</span>, .off = -<span class="tok-number">6.975424321706684210e-276</span> },</span>
<span class="line" id="L574">    HP{ .val = <span class="tok-number">1.000000e-260</span>, .off = <span class="tok-number">3.855741933482293648e-277</span> },</span>
<span class="line" id="L575">    HP{ .val = <span class="tok-number">1.000000e-261</span>, .off = <span class="tok-number">1.599248963651256552e-278</span> },</span>
<span class="line" id="L576">    HP{ .val = <span class="tok-number">1.000000e-262</span>, .off = -<span class="tok-number">1.221367248637539543e-279</span> },</span>
<span class="line" id="L577">    HP{ .val = <span class="tok-number">1.000000e-263</span>, .off = -<span class="tok-number">1.221367248637539494e-280</span> },</span>
<span class="line" id="L578">    HP{ .val = <span class="tok-number">1.000000e-264</span>, .off = -<span class="tok-number">1.221367248637539647e-281</span> },</span>
<span class="line" id="L579">    HP{ .val = <span class="tok-number">1.000000e-265</span>, .off = <span class="tok-number">1.533140771175737943e-282</span> },</span>
<span class="line" id="L580">    HP{ .val = <span class="tok-number">1.000000e-266</span>, .off = <span class="tok-number">1.533140771175737895e-283</span> },</span>
<span class="line" id="L581">    HP{ .val = <span class="tok-number">1.000000e-267</span>, .off = <span class="tok-number">1.533140771175738074e-284</span> },</span>
<span class="line" id="L582">    HP{ .val = <span class="tok-number">1.000000e-268</span>, .off = <span class="tok-number">4.223090009274641634e-285</span> },</span>
<span class="line" id="L583">    HP{ .val = <span class="tok-number">1.000000e-269</span>, .off = <span class="tok-number">4.223090009274641634e-286</span> },</span>
<span class="line" id="L584">    HP{ .val = <span class="tok-number">1.000000e-270</span>, .off = -<span class="tok-number">4.183001359784432924e-287</span> },</span>
<span class="line" id="L585">    HP{ .val = <span class="tok-number">1.000000e-271</span>, .off = <span class="tok-number">3.697709298708449474e-288</span> },</span>
<span class="line" id="L586">    HP{ .val = <span class="tok-number">1.000000e-272</span>, .off = <span class="tok-number">6.981338739747150474e-289</span> },</span>
<span class="line" id="L587">    HP{ .val = <span class="tok-number">1.000000e-273</span>, .off = -<span class="tok-number">9.436808465446354751e-290</span> },</span>
<span class="line" id="L588">    HP{ .val = <span class="tok-number">1.000000e-274</span>, .off = <span class="tok-number">3.389869038611071740e-291</span> },</span>
<span class="line" id="L589">    HP{ .val = <span class="tok-number">1.000000e-275</span>, .off = <span class="tok-number">6.596538414625427829e-292</span> },</span>
<span class="line" id="L590">    HP{ .val = <span class="tok-number">1.000000e-276</span>, .off = -<span class="tok-number">9.436808465446354618e-293</span> },</span>
<span class="line" id="L591">    HP{ .val = <span class="tok-number">1.000000e-277</span>, .off = <span class="tok-number">3.089243784609725523e-294</span> },</span>
<span class="line" id="L592">    HP{ .val = <span class="tok-number">1.000000e-278</span>, .off = <span class="tok-number">6.220756847123745836e-295</span> },</span>
<span class="line" id="L593">    HP{ .val = <span class="tok-number">1.000000e-279</span>, .off = -<span class="tok-number">5.522417137303829470e-296</span> },</span>
<span class="line" id="L594">    HP{ .val = <span class="tok-number">1.000000e-280</span>, .off = <span class="tok-number">4.263561183052483059e-297</span> },</span>
<span class="line" id="L595">    HP{ .val = <span class="tok-number">1.000000e-281</span>, .off = -<span class="tok-number">1.852675267170212272e-298</span> },</span>
<span class="line" id="L596">    HP{ .val = <span class="tok-number">1.000000e-282</span>, .off = -<span class="tok-number">1.852675267170212378e-299</span> },</span>
<span class="line" id="L597">    HP{ .val = <span class="tok-number">1.000000e-283</span>, .off = <span class="tok-number">5.314789322934508480e-300</span> },</span>
<span class="line" id="L598">    HP{ .val = <span class="tok-number">1.000000e-284</span>, .off = -<span class="tok-number">3.644541414696392675e-301</span> },</span>
<span class="line" id="L599">    HP{ .val = <span class="tok-number">1.000000e-285</span>, .off = -<span class="tok-number">7.377595888709267777e-302</span> },</span>
<span class="line" id="L600">    HP{ .val = <span class="tok-number">1.000000e-286</span>, .off = -<span class="tok-number">5.044436842451220838e-303</span> },</span>
<span class="line" id="L601">    HP{ .val = <span class="tok-number">1.000000e-287</span>, .off = -<span class="tok-number">2.127988034628661760e-304</span> },</span>
<span class="line" id="L602">    HP{ .val = <span class="tok-number">1.000000e-288</span>, .off = -<span class="tok-number">5.773549044406860911e-305</span> },</span>
<span class="line" id="L603">    HP{ .val = <span class="tok-number">1.000000e-289</span>, .off = -<span class="tok-number">1.216597782184112068e-306</span> },</span>
<span class="line" id="L604">    HP{ .val = <span class="tok-number">1.000000e-290</span>, .off = -<span class="tok-number">6.912786859962547924e-307</span> },</span>
<span class="line" id="L605">    HP{ .val = <span class="tok-number">1.000000e-291</span>, .off = <span class="tok-number">3.767567660872018813e-308</span> },</span>
<span class="line" id="L606">};</span>
<span class="line" id="L607"></span>
</code></pre></body>
</html>