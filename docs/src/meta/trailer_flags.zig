<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>meta/trailer_flags.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> meta = std.meta;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Type = std.builtin.Type;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// This is useful for saving memory when allocating an object that has many</span></span>
<span class="line" id="L9"><span class="tok-comment">/// optional components. The optional objects are allocated sequentially in</span></span>
<span class="line" id="L10"><span class="tok-comment">/// memory, and a single integer is used to represent each optional object</span></span>
<span class="line" id="L11"><span class="tok-comment">/// and whether it is present based on each corresponding bit.</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">TrailerFlags</span>(<span class="tok-kw">comptime</span> Fields: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L14">        bits: Int,</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Int = meta.Int(.unsigned, bit_count);</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> bit_count = <span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields.len;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FieldEnum = std.meta.FieldEnum(Fields);</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ActiveFields = std.enums.EnumFieldStruct(FieldEnum, <span class="tok-type">bool</span>, <span class="tok-null">false</span>);</span>
<span class="line" id="L22">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FieldValues = blk: {</span>
<span class="line" id="L23">            <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> fields: [bit_count]Type.StructField = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L24">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields) |struct_field, i| {</span>
<span class="line" id="L25">                fields[i] = Type.StructField{</span>
<span class="line" id="L26">                    .name = struct_field.name,</span>
<span class="line" id="L27">                    .field_type = ?struct_field.field_type,</span>
<span class="line" id="L28">                    .default_value = &amp;<span class="tok-builtin">@as</span>(?struct_field.field_type, <span class="tok-null">null</span>),</span>
<span class="line" id="L29">                    .is_comptime = <span class="tok-null">false</span>,</span>
<span class="line" id="L30">                    .alignment = <span class="tok-builtin">@alignOf</span>(?struct_field.field_type),</span>
<span class="line" id="L31">                };</span>
<span class="line" id="L32">            }</span>
<span class="line" id="L33">            <span class="tok-kw">break</span> :blk <span class="tok-builtin">@Type</span>(.{</span>
<span class="line" id="L34">                .Struct = .{</span>
<span class="line" id="L35">                    .layout = .Auto,</span>
<span class="line" id="L36">                    .fields = &amp;fields,</span>
<span class="line" id="L37">                    .decls = &amp;.{},</span>
<span class="line" id="L38">                    .is_tuple = <span class="tok-null">false</span>,</span>
<span class="line" id="L39">                },</span>
<span class="line" id="L40">            });</span>
<span class="line" id="L41">        };</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">has</span>(self: Self, <span class="tok-kw">comptime</span> field: FieldEnum) <span class="tok-type">bool</span> {</span>
<span class="line" id="L46">            <span class="tok-kw">const</span> field_index = <span class="tok-builtin">@enumToInt</span>(field);</span>
<span class="line" id="L47">            <span class="tok-kw">return</span> (self.bits &amp; (<span class="tok-number">1</span> &lt;&lt; field_index)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L48">        }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, p: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Fields)) <span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> field: FieldEnum) ?Field(field) {</span>
<span class="line" id="L51">            <span class="tok-kw">if</span> (!self.has(field))</span>
<span class="line" id="L52">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L53">            <span class="tok-kw">return</span> self.ptrConst(p, field).*;</span>
<span class="line" id="L54">        }</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setFlag</span>(self: *Self, <span class="tok-kw">comptime</span> field: FieldEnum) <span class="tok-type">void</span> {</span>
<span class="line" id="L57">            <span class="tok-kw">const</span> field_index = <span class="tok-builtin">@enumToInt</span>(field);</span>
<span class="line" id="L58">            self.bits |= <span class="tok-number">1</span> &lt;&lt; field_index;</span>
<span class="line" id="L59">        }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-comment">/// `fields` is a boolean struct where each active field is set to `true`</span></span>
<span class="line" id="L62">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(fields: ActiveFields) Self {</span>
<span class="line" id="L63">            <span class="tok-kw">var</span> self: Self = .{ .bits = <span class="tok-number">0</span> };</span>
<span class="line" id="L64">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields) |field, i| {</span>
<span class="line" id="L65">                <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(fields, field.name))</span>
<span class="line" id="L66">                    self.bits |= <span class="tok-number">1</span> &lt;&lt; i;</span>
<span class="line" id="L67">            }</span>
<span class="line" id="L68">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-comment">/// `fields` is a struct with each field set to an optional value</span></span>
<span class="line" id="L72">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setMany</span>(self: Self, p: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Fields)) <span class="tok-type">u8</span>, fields: FieldValues) <span class="tok-type">void</span> {</span>
<span class="line" id="L73">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields) |field, i| {</span>
<span class="line" id="L74">                <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(fields, field.name)) |value|</span>
<span class="line" id="L75">                    self.set(p, <span class="tok-builtin">@intToEnum</span>(FieldEnum, i), value);</span>
<span class="line" id="L76">            }</span>
<span class="line" id="L77">        }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(</span>
<span class="line" id="L80">            self: Self,</span>
<span class="line" id="L81">            p: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Fields)) <span class="tok-type">u8</span>,</span>
<span class="line" id="L82">            <span class="tok-kw">comptime</span> field: FieldEnum,</span>
<span class="line" id="L83">            value: Field(field),</span>
<span class="line" id="L84">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L85">            self.ptr(p, field).* = value;</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptr</span>(self: Self, p: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Fields)) <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> field: FieldEnum) *Field(field) {</span>
<span class="line" id="L89">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Field(field)) == <span class="tok-number">0</span>)</span>
<span class="line" id="L90">                <span class="tok-kw">return</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L91">            <span class="tok-kw">const</span> off = self.offset(field);</span>
<span class="line" id="L92">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*Field(field), <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Field(field)), p + off));</span>
<span class="line" id="L93">        }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ptrConst</span>(self: Self, p: [*]<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(Fields)) <span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> field: FieldEnum) *<span class="tok-kw">const</span> Field(field) {</span>
<span class="line" id="L96">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Field(field)) == <span class="tok-number">0</span>)</span>
<span class="line" id="L97">                <span class="tok-kw">return</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L98">            <span class="tok-kw">const</span> off = self.offset(field);</span>
<span class="line" id="L99">            <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> Field(field), <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(Field(field)), p + off));</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">offset</span>(self: Self, <span class="tok-kw">comptime</span> field: FieldEnum) <span class="tok-type">usize</span> {</span>
<span class="line" id="L103">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L104">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields) |field_info, i| {</span>
<span class="line" id="L105">                <span class="tok-kw">const</span> active = (self.bits &amp; (<span class="tok-number">1</span> &lt;&lt; i)) != <span class="tok-number">0</span>;</span>
<span class="line" id="L106">                <span class="tok-kw">if</span> (i == <span class="tok-builtin">@enumToInt</span>(field)) {</span>
<span class="line" id="L107">                    assert(active);</span>
<span class="line" id="L108">                    <span class="tok-kw">return</span> mem.alignForwardGeneric(<span class="tok-type">usize</span>, off, <span class="tok-builtin">@alignOf</span>(field_info.field_type));</span>
<span class="line" id="L109">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (active) {</span>
<span class="line" id="L110">                    off = mem.alignForwardGeneric(<span class="tok-type">usize</span>, off, <span class="tok-builtin">@alignOf</span>(field_info.field_type));</span>
<span class="line" id="L111">                    off += <span class="tok-builtin">@sizeOf</span>(field_info.field_type);</span>
<span class="line" id="L112">                }</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Field</span>(<span class="tok-kw">comptime</span> field: FieldEnum) <span class="tok-type">type</span> {</span>
<span class="line" id="L117">            <span class="tok-kw">return</span> <span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields[<span class="tok-builtin">@enumToInt</span>(field)].field_type;</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sizeInBytes</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L121">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L122">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(Fields).Struct.fields) |field, i| {</span>
<span class="line" id="L123">                <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(field.field_type) == <span class="tok-number">0</span>)</span>
<span class="line" id="L124">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L125">                <span class="tok-kw">if</span> ((self.bits &amp; (<span class="tok-number">1</span> &lt;&lt; i)) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L126">                    off = mem.alignForwardGeneric(<span class="tok-type">usize</span>, off, <span class="tok-builtin">@alignOf</span>(field.field_type));</span>
<span class="line" id="L127">                    off += <span class="tok-builtin">@sizeOf</span>(field.field_type);</span>
<span class="line" id="L128">                }</span>
<span class="line" id="L129">            }</span>
<span class="line" id="L130">            <span class="tok-kw">return</span> off;</span>
<span class="line" id="L131">        }</span>
<span class="line" id="L132">    };</span>
<span class="line" id="L133">}</span>
<span class="line" id="L134"></span>
<span class="line" id="L135"><span class="tok-kw">test</span> <span class="tok-str">&quot;TrailerFlags&quot;</span> {</span>
<span class="line" id="L136">    <span class="tok-kw">const</span> Flags = TrailerFlags(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L137">        a: <span class="tok-type">i32</span>,</span>
<span class="line" id="L138">        b: <span class="tok-type">bool</span>,</span>
<span class="line" id="L139">        c: <span class="tok-type">u64</span>,</span>
<span class="line" id="L140">    });</span>
<span class="line" id="L141">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">u2</span>, meta.Tag(Flags.FieldEnum));</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-kw">var</span> flags = Flags.init(.{</span>
<span class="line" id="L144">        .b = <span class="tok-null">true</span>,</span>
<span class="line" id="L145">        .c = <span class="tok-null">true</span>,</span>
<span class="line" id="L146">    });</span>
<span class="line" id="L147">    <span class="tok-kw">const</span> slice = <span class="tok-kw">try</span> testing.allocator.allocAdvanced(<span class="tok-type">u8</span>, <span class="tok-number">8</span>, flags.sizeInBytes(), .exact);</span>
<span class="line" id="L148">    <span class="tok-kw">defer</span> testing.allocator.free(slice);</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    flags.set(slice.ptr, .b, <span class="tok-null">false</span>);</span>
<span class="line" id="L151">    flags.set(slice.ptr, .c, <span class="tok-number">12345678</span>);</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-kw">try</span> testing.expect(flags.get(slice.ptr, .a) == <span class="tok-null">null</span>);</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> testing.expect(!flags.get(slice.ptr, .b).?);</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> testing.expect(flags.get(slice.ptr, .c).? == <span class="tok-number">12345678</span>);</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    flags.setMany(slice.ptr, .{</span>
<span class="line" id="L158">        .b = <span class="tok-null">true</span>,</span>
<span class="line" id="L159">        .c = <span class="tok-number">5678</span>,</span>
<span class="line" id="L160">    });</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">    <span class="tok-kw">try</span> testing.expect(flags.get(slice.ptr, .a) == <span class="tok-null">null</span>);</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> testing.expect(flags.get(slice.ptr, .b).?);</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> testing.expect(flags.get(slice.ptr, .c).? == <span class="tok-number">5678</span>);</span>
<span class="line" id="L165">}</span>
<span class="line" id="L166"></span>
</code></pre></body>
</html>