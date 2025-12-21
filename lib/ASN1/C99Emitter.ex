defmodule ASN1.C99Emitter do
  @behaviour ASN1.Emitter

  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, save: 4, lookup: 1, outputDir: 0]

  @common_block """
  #ifndef ASN1C_COMMON_TYPES
  #define ASN1C_COMMON_TYPES

  #include <stddef.h>
  #include <stdint.h>
  #include <stdbool.h>
  #include <string.h>
  #include <asn1/asn1.h>
  #include <asn1/asn1_types.h>

  typedef struct {
      size_t count;
      uint32_t components[32];
  } ASN1C_OID;

  typedef struct {
      size_t byte_count;
      uint8_t bytes[256];
      uint8_t unused_bits;
  } ASN1C_BitString;

  typedef struct {
      size_t length;
      uint8_t bytes[256];
  } ASN1C_OctetString;

  typedef struct {
      size_t length;
      uint8_t bytes[512];
  } ASN1C_Node;

  #define ASN1C_MAX_SEQUENCE_ELEMENTS 32U

  /* Encode/decode helpers for common types */
  static inline asn1_error_t ASN1C_OID_encode(const ASN1C_OID *self, asn1_serializer_t *s) {
      asn1_oid_t oid = {.count = self->count};
      for (size_t i = 0; i < self->count; i++) oid.components[i] = self->components[i];
      return asn1_serialize_oid(s, &oid);
  }
  static inline asn1_error_t ASN1C_OID_decode(ASN1C_OID *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
      (void)result;
      asn1_oid_t oid;
      asn1_error_t err = asn1_parse_oid(node, &oid);
      if (!asn1_is_ok(err)) return err;
      self->count = oid.count;
      for (size_t i = 0; i < oid.count; i++) self->components[i] = oid.components[i];
      return asn1_ok();
  }
  static inline asn1_error_t ASN1C_BitString_encode(const ASN1C_BitString *self, asn1_serializer_t *s) {
      asn1_bit_string_t bs = {.bytes = self->bytes, .byte_count = self->byte_count, .unused_bits = self->unused_bits};
      return asn1_serialize_bit_string(s, &bs);
  }
  static inline asn1_error_t ASN1C_BitString_decode(ASN1C_BitString *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
      (void)result;
      asn1_bit_string_t bs;
      asn1_error_t err = asn1_parse_bit_string(node, &bs);
      if (!asn1_is_ok(err)) return err;
      size_t bc = bs.byte_count > sizeof(self->bytes) ? sizeof(self->bytes) : bs.byte_count;
      memcpy(self->bytes, bs.bytes, bc);
      self->byte_count = bc;
      self->unused_bits = bs.unused_bits;
      return asn1_ok();
  }
  static inline asn1_error_t ASN1C_OctetString_encode(const ASN1C_OctetString *self, asn1_serializer_t *s) {
      return asn1_serialize_octet_string(s, self->bytes, self->length);
  }
  static inline asn1_error_t ASN1C_OctetString_decode(ASN1C_OctetString *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
      (void)result;
      const uint8_t *data; size_t len;
      asn1_error_t err = asn1_parse_octet_string(node, &data, &len);
      if (!asn1_is_ok(err)) return err;
      if (len > sizeof(self->bytes)) len = sizeof(self->bytes);
      memcpy(self->bytes, data, len);
      self->length = len;
      return asn1_ok();
  }
  static inline asn1_error_t ASN1C_Node_encode(const ASN1C_Node *self, asn1_serializer_t *s) {
      return asn1_serialize_raw(s, self->bytes, self->length);
  }
  static inline asn1_error_t ASN1C_Node_decode(ASN1C_Node *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
      (void)result;
      if (node->encoded_length > sizeof(self->bytes)) return asn1_error(ASN1_ERROR_INVALID_OBJECT, \"too large\", 0);
      memcpy(self->bytes, node->encoded_bytes, node->encoded_length);
      self->length = node->encoded_length;
      return asn1_ok();
  }

  #endif /* ASN1C_COMMON_TYPES */
  """

  @builtin_map %{
    :"OBJECT IDENTIFIER" => "ASN1C_OID",
    :"BIT STRING" => "ASN1C_BitString",
    :"OCTET STRING" => "ASN1C_OctetString",
    :BOOLEAN => "bool",
    :INTEGER => "int64_t",
    :ENUMERATED => "int64_t",
    :NULL => "uint8_t",
    :UTF8String => "char[256]",
    :PrintableString => "char[128]",
    :IA5String => "char[256]",
    :GeneralizedTime => "char[32]",
    :UTCTime => "char[32]",
    :ANY => "ASN1C_Node",
    :TeletexString => "char[256]",
    :BMPString => "char[256]",
    :UniversalString => "char[256]",
    :NumericString => "char[64]"
  }

  @primitive_types MapSet.new([
    "int64_t",
    "uint64_t",
    "uint32_t",
    "uint16_t",
    "uint8_t",
    "size_t",
    "bool",
    "ASN1C_OID",
    "ASN1C_BitString",
    "ASN1C_OctetString",
    "ASN1C_Node"
  ])

  @impl true
  def fileExtension, do: ".h"

  @impl true
  def name(raw_name, modname), do: sanitize_type_name("#{modname}_#{raw_name}")

  @impl true
  @reserved_identifiers ~w(auto break case char const continue default do double else enum extern float for goto if inline int long register restrict return short signed sizeof static struct switch typedef union unsigned void volatile while _Alignas _Alignof _Atomic _Bool _Complex _Generic _Imaginary _Noreturn _Static_assert _Thread_local)

  def fieldName(name) do
    name
    |> bin()
    |> normalizeName()
    |> Macro.underscore()
    |> String.replace(~r/[^a-z0-9_]/i, "_")
    |> String.downcase()
    |> String.trim("_")
    |> ensure_not_reserved()
    |> case do
      "" -> "field_#{:erlang.unique_integer([:positive])}"
      other -> other
    end
  end

  defp record_header(name) do
    dir = current_output_dir()
    headers = Process.get(:c99_headers, %{})
    set = Map.get(headers, dir, MapSet.new())
    Process.put(:c99_headers, Map.put(headers, dir, MapSet.put(set, name)))

    locations = Process.get(:c99_header_locations, %{})
    Process.put(:c99_header_locations, Map.put(locations, name, dir))
  end

  defp current_output_dir do
    outputDir()
    |> ensure_trailing_slash()
    |> Path.expand()
  end

  defp ensure_trailing_slash(dir) do
    if String.ends_with?(dir, "/"), do: dir, else: dir <> "/"
  end

  defp umbrella_guard(dir) do
    dir
    |> String.replace(~r/[^A-Za-z0-9]/, "_")
    |> String.upcase()
    |> Kernel.<>("_UMBRELLA_H")
  end

  defp start_header(c_name) do
    stack = Process.get(:c99_header_stack, [])
    Process.put(:c99_header_stack, [c_name | stack])
    Process.put({:c99_deps, c_name}, MapSet.new())
  end

  defp finish_header(c_name) do
    [current | rest] = Process.get(:c99_header_stack, [])
    true = current == c_name
    Process.put(:c99_header_stack, rest)
    deps = Process.get({:c99_deps, c_name}, MapSet.new())
    Process.delete({:c99_deps, c_name})
    deps
  end

  defp current_header do
    case Process.get(:c99_header_stack, []) do
      [head | _] -> head
      _ -> nil
    end
  end

  defp track_if_type(type_name) do
    maybe_track_dependency(type_name)
    type_name
  end

  defp track_and_sanitize(type_name, struct_name) do
    sanitized = sanitize_type_name(type_name, struct_name)
    maybe_track_dependency(sanitized)
    sanitized
  end

  defp maybe_track_dependency(nil), do: :ok

  defp maybe_track_dependency(type_name) do
    cond do
      not is_binary(type_name) ->
        :ok

      builtin_type?(type_name) ->
        :ok

      current_header() == sanitize_type_name(type_name) ->
        :ok

      true ->
        header = current_header()

        if header do
          deps = Process.get({:c99_deps, header}, MapSet.new())
          Process.put({:c99_deps, header}, MapSet.put(deps, sanitize_type_name(type_name)))
        end
    end
  end

  defp builtin_type?(type_name) when is_binary(type_name) do
    lower = String.downcase(type_name)
    String.starts_with?(type_name, "char[") or
      MapSet.member?(@primitive_types, type_name) or
      MapSet.member?(@primitive_types, lower) or
      String.starts_with?(type_name, "ASN1C_") or
      lower in ["int64_t", "uint64_t", "int32_t", "uint32_t", "int16_t", "uint16_t",
                "int8_t", "uint8_t", "size_t", "bool", "void"]
  end

  defp builtin_type?(_), do: true

  defp ensure_not_reserved(""), do: ""

  defp ensure_not_reserved(identifier) do
    if identifier in @reserved_identifiers do
      identifier <> "_field"
    else
      identifier
    end
  end

  @impl true
  def fieldType(struct_name, field, {:type, _, inner, _, _, _}), do: fieldType(struct_name, field, inner)

  def fieldType(struct_name, field, {:tag, _, _, _, inner}), do: fieldType(struct_name, field, inner)

  @impl true
  def fieldType(_struct_name, _field, {:ObjectClassFieldType, _, _, _, _}), do: "ASN1C_Node"

  @impl true
  def fieldType(struct_name, field, {:"SEQUENCE OF", inner}), do: sequenceOf(struct_name, field, inner)

  def fieldType(struct_name, field, {:"Sequence Of", inner}), do: sequenceOf(struct_name, field, inner)
  def fieldType(struct_name, field, {:"SET OF", inner}), do: sequenceOf(struct_name, field, inner)
  def fieldType(struct_name, field, {:"Set Of", inner}), do: sequenceOf(struct_name, field, inner)

  @impl true
  def fieldType(_struct_name, _field, {:"CHOICE", _cases}), do: "ASN1C_Node"

  def fieldType(_struct_name, _field, {:"SEQUENCE", _, _, _, _}), do: "ASN1C_Node"
  def fieldType(_struct_name, _field, {:"SET", _, _, _, _}), do: "ASN1C_Node"
  def fieldType(_struct_name, _field, {:"ENUMERATED", _}), do: "int64_t"
  def fieldType(_struct_name, _field, {:"INTEGER", _}), do: "int64_t"
  def fieldType(_struct_name, _field, {:"BIT STRING", _}), do: "ASN1C_BitString"
  def fieldType(_struct_name, _field, {:"OCTET STRING", _}), do: "ASN1C_OctetString"

  @impl true
  def fieldType(struct_name, _field, {:Externaltypereference, _, mod, ref}) do
    lookup(bin(ref))
    |> substituteType()
    |> track_and_sanitize({mod, struct_name})
  end

  def fieldType(_struct_name, _field, value) when is_atom(value) do
    value |> substituteType() |> track_if_type()
  end

  def fieldType(_struct_name, _field, value) when is_binary(value) do
    value |> substituteType() |> track_if_type()
  end

  def fieldType(_struct_name, _field, _other), do: "ASN1C_Node"

  @impl true
  def array(name, type, tag, _level \\ "") do
    mod = current_module()
    c_name =
      if mod == "" do
        sanitize_type_name(name)
      else
        qualified_name(name, mod)
      end

    setEnv(name, c_name)
    start_header(c_name)
    track_if_type(type)

    tag_label =
      case tag do
        :set -> "SET"
        :sequence -> "SEQUENCE"
        _ -> "COLLECTION"
      end

    # Determine the tag for the constructed type
    asn1_id = case tag do
      :set -> "ASN1_ID_SET"
      _ -> "ASN1_ID_SEQUENCE"
    end

    typedef = """
    typedef struct {
        size_t length;
        #{type} elements[ASN1C_MAX_SEQUENCE_ELEMENTS];
    } #{c_name};

    /* NASA-style note: #{c_name} models #{tag_label} OF #{type}. */
    """

    # Generate encoder that iterates over elements
    encode_decode = emit_array_encode_decode(c_name, type, asn1_id)

    deps = finish_header(c_name)
    record_header(c_name)
    save(true, mod, c_name, emit_unit(mod, c_name, typedef <> encode_decode, deps))
    c_name
  end

  @impl true
  def sequence(name, fields, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    setEnv(:current_struct, c_name)
    start_header(c_name)

    spec =
      fields
      |> Enum.filter(&match?({:ComponentType, _, _, _, _, _, _}, &1))
      |> Enum.map(&emit_sequence_field(c_name, &1))
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")

    body = """
    typedef struct {
    #{spec}
    } #{c_name};
    """

    deps = finish_header(c_name)
    record_header(c_name)
    encoder = emit_sequence_encoder(c_name, fields)
    decoder = emit_sequence_decoder(c_name, fields)
    full_body = body <> "\n" <> encoder <> "\n" <> decoder
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, full_body, deps))
  end

  @impl true
  def set(name, fields, modname, saveFlag), do: sequence(name, fields, modname, saveFlag)

  @impl true
  def choice(name, cases, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    start_header(c_name)

    variants =
      cases
      |> Enum.filter(&match?({:ComponentType, _, _, _, _, _, _}, &1))
      |> Enum.map(&choice_variant(c_name, &1))
      |> Enum.reject(&(&1 == nil))

    selector =
      variants
      |> Enum.map(fn {variant, _field, _type} -> "    #{selector_name(c_name, variant)}," end)
      |> Enum.join("\n")

    union_body =
      variants
      |> Enum.map(fn {variant, field, type} ->
        # Handle C array types like "char[32]" -> "char field[32]"
        field_decl = case Regex.run(~r/^(\w+)\[(\d+)\]$/, type) do
          [_, base_type, size] -> "#{base_type} #{field}[#{size}]"
          _ -> "#{type} #{field}"
        end
        "        #{field_decl}; /* #{variant} */"
      end)
      |> Enum.join("\n")

    body = """
    typedef enum {
    #{selector}
    } #{c_name}_Selector;

    typedef struct {
        #{c_name}_Selector selector;
        union {
    #{union_body}
        } data;
    } #{c_name};
    """

    # Generate CHOICE encoder - encode based on selector
    encoder = emit_choice_encoder(c_name, variants)
    # Generate CHOICE decoder - just a placeholder for now (needs tag-based dispatch)
    decoder = emit_choice_decoder(c_name, variants)

    deps = finish_header(c_name)
    full_body = body <> "\n" <> encoder <> "\n" <> decoder
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, full_body, deps))
  end

  @impl true
  def enumeration(name, cases, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    start_header(c_name)

    entries =
      cases
      |> Enum.reject(&(&1 == :EXTENSIONMARK))
      |> Enum.map(&enum_case(c_name, &1))
      |> Enum.join("\n")

    typedef = """
    typedef enum {
    #{entries}
    } #{c_name};
    """

    # Generate simple integer encode/decode for enumeration
    encode_decode = """
    static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
        return asn1_serialize_int64(s, (int64_t)*self);
    }
    static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
        (void)result;
        int64_t val;
        asn1_error_t err = asn1_parse_int64(node, &val);
        if (!asn1_is_ok(err)) return err;
        *self = (#{c_name})val;
        return asn1_ok();
    }
    """

    deps = finish_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, typedef <> encode_decode, deps))
  end

  @impl true
  def integerEnum(name, cases, modname, saveFlag), do: enumeration(name, cases, modname, saveFlag)

  @impl true
  def substituteType(type) when is_atom(type) do
    Map.get(@builtin_map, type, default_type_name(type))
  end

  def substituteType(type) when is_binary(type) do
    Map.get(@builtin_map, type, default_type_name(type))
  end

  def substituteType({mod, type_name}), do: {mod, type_name}

  def substituteType(_), do: "ASN1C_Node"

  @impl true
  def tagClass(_tag), do: ""

  @impl true
  def typealias(name, target, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    target_name = substituteType(target)
    start_header(c_name)
    track_if_type(target_name)

    # Generate encode/decode wrappers that delegate to the target type
    encode_decode =
      if builtin_type?(target_name) do
        # Map common C types to their ASN1C_ encoder/decoder names
        encoder_target = case target_name do
          "ASN1C_OID" -> "ASN1C_OID"
          "ASN1C_BitString" -> "ASN1C_BitString"
          "ASN1C_OctetString" -> "ASN1C_OctetString"
          "ASN1C_Node" -> "ASN1C_Node"
          "int64_t" -> :int64
          "bool" -> :bool
          _ -> nil
        end

        case encoder_target do
          :int64 ->
            """

            static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
                return asn1_serialize_int64(s, (int64_t)*self);
            }
            static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
                (void)result;
                int64_t val;
                asn1_error_t err = asn1_parse_int64(node, &val);
                if (!asn1_is_ok(err)) return err;
                *self = (#{c_name})val;
                return asn1_ok();
            }
            """
          :bool ->
            """

            static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
                return asn1_serialize_boolean(s, *self);
            }
            static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
                (void)result;
                return asn1_parse_boolean(node, self, ASN1_ENCODING_DER);
            }
            """
          nil -> ""
          helper_name ->
            """

            static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
                return #{helper_name}_encode(self, s);
            }
            static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
                return #{helper_name}_decode(self, node, result);
            }
            """
        end
      else
        # For non-builtin types, delegate to the target type's encode/decode
        """

        static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
            return #{target_name}_encode(self, s);
        }
        static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
            return #{target_name}_decode(self, node, result);
        }
        """
      end

    body = """
    typedef #{target_name} #{c_name};
    #{encode_decode}
    """

    deps = finish_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, body, deps))
  end

  @impl true
  def value(name, {:type, _, :"OBJECT IDENTIFIER", _, _, _}, val, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    start_header(c_name)
    components = flatten_oid(val)
    count = length(components)
    values = Enum.join(components, ", ")

    body = """
    static const ASN1C_OID #{c_name} = {
        .count = #{count},
        .components = { #{values} }
    };
    """

    deps = finish_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, body, deps))
  end

  @impl true
  def value(name, _type, val, modname, saveFlag) do
    c_name = name(name, modname)
    setEnv(name, c_name)
    start_header(c_name)

    literal =
      cond do
        is_integer(val) -> Integer.to_string(val)
        is_binary(val) -> ~s("#{val}")
        true -> inspect(val)
      end

    body = """
    static const int64_t #{c_name} = #{literal};
    """

    deps = finish_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, body, deps))
  end

  @impl true
  def builtinType(type) when is_atom(type), do: Map.get(@builtin_map, type, default_type_name(type))

  @impl true
  def builtinType(type) when is_binary(type), do: Map.get(@builtin_map, type, default_type_name(type))

  @impl true
  def sequenceOf(name, field, type) do
    element_type = fieldType(name, field, type)
    alias_name = "#{name}_#{bin(field)}_SequenceOf"
    result = array(alias_name, element_type, :sequence, "field")
    track_if_type(result)
    result
  end

  @impl true
  def algorithmIdentifierClass(className, modname, saveFlag) do
    c_name = name(className, modname)
    start_header(c_name)

    body = """
    typedef struct {
        ASN1C_OID algorithm;
        ASN1C_Node parameters;
    } #{c_name};
    """

    deps = finish_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, body, deps))
  end

  @impl true
  def integerValue(name, val, modname, saveFlag) do
    c_name = name(name, modname)
    literal = literal(val)
    start_header(c_name)

    body = """
    #define #{c_name} #{literal}
    """

    deps = finish_header(c_name)
    record_header(c_name)
    save(saveFlag, modname, c_name, emit_unit(modname, c_name, body, deps))
  end

  @impl true
  def finalize do
    headers_by_dir = Process.get(:c99_headers, %{})

    Enum.each(headers_by_dir, fn {dir, headers} ->
      if MapSet.size(headers) > 0 do
        guard = umbrella_guard(dir)

        includes =
          headers
          |> Enum.sort()
          |> Enum.map(&~s(#include "#{&1}.h"))
          |> Enum.join("\n")

        content = """
        /*
         * Umbrella include for #{dir}
         * Generated by ASN1.C99Emitter finalize/0.
         */
        #ifndef #{guard}
        #define #{guard}

        #{includes}

        #endif /* #{guard} */
        """

        File.mkdir_p!(dir)
        File.write!(Path.join(dir, "umbrella.h"), content)
      end
    end)

    Process.delete(:c99_headers)
    Process.delete(:c99_header_locations)
    :ok
  end

  # ============================================================================
  # Encoder/Decoder Generation
  # ============================================================================

  defp emit_sequence_encoder(c_name, fields) do
    field_encoders =
      fields
      |> Enum.filter(&match?({:ComponentType, _, _, _, _, _, _}, &1))
      |> Enum.map(&emit_field_encoder(c_name, &1))
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")

    """
    static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
        asn1_error_t err;
        size_t seq_marker;
        err = asn1_serialize_constructed_begin(s, ASN1_ID_SEQUENCE, &seq_marker);
        if (!asn1_is_ok(err)) return err;
    #{field_encoders}
        return asn1_serialize_constructed_end(s, seq_marker);
    }
    """
  end

  defp emit_sequence_decoder(c_name, fields) do
    field_decoders =
      fields
      |> Enum.filter(&match?({:ComponentType, _, _, _, _, _, _}, &1))
      |> Enum.with_index()
      |> Enum.map(fn {field, idx} -> emit_field_decoder(c_name, field, idx) end)
      |> Enum.reject(&(&1 == ""))
      |> Enum.join("\n")

    """
    static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
        asn1_error_t err; (void)err;
        if (node->content_type != ASN1_CONTENT_CONSTRUCTED) {
            return asn1_error(ASN1_ERROR_INVALID_OBJECT, "expected constructed", 0);
        }
        size_t node_idx = asn1_node_index(result, node);
        asn1_node_iterator_t iter = asn1_children(result, node_idx);
        asn1_node_t *child; (void)child;
    #{field_decoders}
        return asn1_ok();
    }
    """
  end

  defp emit_choice_encoder(c_name, variants) do
    cases =
      variants
      |> Enum.map(fn {variant_name, field, type} ->
        selector = selector_name(c_name, variant_name)
        encoder_call = primitive_encoder_for_choice(type, "self->data.#{field}")
        "        case #{selector}: #{encoder_call} break;"
      end)
      |> Enum.join("\n")

    """
    static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
        asn1_error_t err;
        switch (self->selector) {
    #{cases}
            default: return asn1_error(ASN1_ERROR_INVALID_OBJECT, "unknown selector", 0);
        }
        return asn1_ok();
    }
    """
  end

  defp emit_choice_decoder(c_name, _variants) do
    """
    static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
        (void)self; (void)node; (void)result;
        /* TODO: CHOICE decoding requires tag-based dispatch */
        return asn1_error(ASN1_ERROR_INVALID_OBJECT, "CHOICE decode not implemented", 0);
    }
    """
  end

  defp primitive_encoder_for_choice(type, var) do
    case Regex.run(~r/^(\w+)\[(\d+)\]$/, type) do
      [_, _, _] ->
        "err = asn1_serialize_string(s, ASN1_ID_UTF8_STRING, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      _ ->
        case type do
          "ASN1C_OID" -> "err = ASN1C_OID_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
          "ASN1C_BitString" -> "err = ASN1C_BitString_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
          "ASN1C_OctetString" -> "err = ASN1C_OctetString_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
          "ASN1C_Node" -> "err = ASN1C_Node_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
          "int64_t" -> "err = asn1_serialize_int64(s, #{var}); if (!asn1_is_ok(err)) return err;"
          "bool" -> "err = asn1_serialize_boolean(s, #{var}); if (!asn1_is_ok(err)) return err;"
          other -> "err = #{other}_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
        end
    end
  end

  defp emit_array_encode_decode(c_name, element_type, asn1_id) do
    # Determine the encoder call for element type
    element_encoder = case element_type do
      "ASN1C_OID" -> "err = ASN1C_OID_encode(&self->elements[i], s); if (!asn1_is_ok(err)) return err;"
      "ASN1C_BitString" -> "err = ASN1C_BitString_encode(&self->elements[i], s); if (!asn1_is_ok(err)) return err;"
      "ASN1C_OctetString" -> "err = ASN1C_OctetString_encode(&self->elements[i], s); if (!asn1_is_ok(err)) return err;"
      "ASN1C_Node" -> "err = ASN1C_Node_encode(&self->elements[i], s); if (!asn1_is_ok(err)) return err;"
      "int64_t" -> "err = asn1_serialize_int64(s, self->elements[i]); if (!asn1_is_ok(err)) return err;"
      "bool" -> "err = asn1_serialize_boolean(s, self->elements[i]); if (!asn1_is_ok(err)) return err;"
      other -> "err = #{other}_encode(&self->elements[i], s); if (!asn1_is_ok(err)) return err;"
    end

    element_decoder = case element_type do
      "ASN1C_OID" -> "{err = ASN1C_OID_decode(&self->elements[self->length], child, result); if (!asn1_is_ok(err)) return err;}"
      "ASN1C_BitString" -> "{err = ASN1C_BitString_decode(&self->elements[self->length], child, result); if (!asn1_is_ok(err)) return err;}"
      "ASN1C_OctetString" -> "{err = ASN1C_OctetString_decode(&self->elements[self->length], child, result); if (!asn1_is_ok(err)) return err;}"
      "ASN1C_Node" -> "{err = ASN1C_Node_decode(&self->elements[self->length], child, result); if (!asn1_is_ok(err)) return err;}"
      "int64_t" -> "{int64_t val; err = asn1_parse_int64(child, &val); if (!asn1_is_ok(err)) return err; self->elements[self->length] = val;}"
      "bool" -> "{bool val; err = asn1_parse_boolean(child, &val, ASN1_ENCODING_DER); if (!asn1_is_ok(err)) return err; self->elements[self->length] = val;}"
      other -> "{err = #{other}_decode(&self->elements[self->length], child, result); if (!asn1_is_ok(err)) return err;}"
    end

    """
    static inline asn1_error_t #{c_name}_encode(const #{c_name} *self, asn1_serializer_t *s) {
        asn1_error_t err;
        size_t seq_marker;
        err = asn1_serialize_constructed_begin(s, #{asn1_id}, &seq_marker);
        if (!asn1_is_ok(err)) return err;
        for (size_t i = 0; i < self->length; i++) {
            #{element_encoder}
        }
        return asn1_serialize_constructed_end(s, seq_marker);
    }
    static inline asn1_error_t #{c_name}_decode(#{c_name} *self, const asn1_node_t *node, const asn1_parse_result_t *result) {
        asn1_error_t err;
        if (node->content_type != ASN1_CONTENT_CONSTRUCTED) {
            return asn1_error(ASN1_ERROR_INVALID_OBJECT, "expected constructed", 0);
        }
        size_t node_idx = asn1_node_index(result, node);
        asn1_node_iterator_t iter = asn1_children(result, node_idx);
        self->length = 0;
        asn1_node_t *child;
        while ((child = asn1_next_child(&iter)) != NULL && self->length < ASN1C_MAX_SEQUENCE_ELEMENTS) {
            #{element_decoder}
            self->length++;
        }
        return asn1_ok();
    }
    """
  end

  defp emit_field_encoder(_struct_name, {:ComponentType, _, field_name, {:type, _, type_ast, _, _, _}, optional, _, _}) do
    field = fieldName(field_name)
    is_optional = optional?(optional)

    encoder_call = primitive_encoder(type_ast, "self->#{field}")

    if is_optional do
      "    if (self->has_" <> field <> ") {\n" <>
      "        " <> encoder_call <> "\n" <>
      "    }"
    else
      "    " <> encoder_call
    end
  end

  defp emit_field_encoder(_, _), do: ""

  defp emit_field_decoder(_struct_name, {:ComponentType, _, field_name, {:type, _, type_ast, _, _, _}, optional, _, _}, _idx) do
    field = fieldName(field_name)
    is_optional = optional?(optional)

    decoder_call = primitive_decoder(type_ast, "self->#{field}")

    if is_optional do
      "    child = asn1_next_child(&iter);\n" <>
      "    if (child != NULL) {\n" <>
      "        " <> decoder_call <> "\n" <>
      "        self->has_" <> field <> " = true;\n" <>
      "    } else {\n" <>
      "        self->has_" <> field <> " = false;\n" <>
      "    }"
    else
      "    child = asn1_next_child(&iter);\n" <>
      "    if (child == NULL) return asn1_error(ASN1_ERROR_TRUNCATED_FIELD, \"missing field\", 0);\n" <>
      "    " <> decoder_call
    end
  end

  defp emit_field_decoder(_, _, _), do: ""

  defp primitive_encoder(type_ast, var) do
    case type_ast do
      :INTEGER -> "err = asn1_serialize_int64(s, #{var}); if (!asn1_is_ok(err)) return err;"
      :BOOLEAN -> "err = asn1_serialize_boolean(s, #{var}); if (!asn1_is_ok(err)) return err;"
      :NULL -> "err = asn1_serialize_null(s); if (!asn1_is_ok(err)) return err;"
      :"OBJECT IDENTIFIER" ->
        "{ asn1_oid_t oid = {.count = #{var}.count}; for(size_t i=0; i<#{var}.count; i++) oid.components[i] = #{var}.components[i]; err = asn1_serialize_oid(s, &oid); if (!asn1_is_ok(err)) return err; }"
      :"OCTET STRING" ->
        "err = asn1_serialize_octet_string(s, #{var}.bytes, #{var}.length); if (!asn1_is_ok(err)) return err;"
      :"BIT STRING" ->
        "{ asn1_bit_string_t bs = {.bytes = #{var}.bytes, .byte_count = #{var}.byte_count, .unused_bits = #{var}.unused_bits}; err = asn1_serialize_bit_string(s, &bs); if (!asn1_is_ok(err)) return err; }"
      {:"BIT STRING", _} ->
        "{ asn1_bit_string_t bs = {.bytes = #{var}.bytes, .byte_count = #{var}.byte_count, .unused_bits = #{var}.unused_bits}; err = asn1_serialize_bit_string(s, &bs); if (!asn1_is_ok(err)) return err; }"
      {:"OCTET STRING", _} ->
        "err = asn1_serialize_octet_string(s, #{var}.bytes, #{var}.length); if (!asn1_is_ok(err)) return err;"
      {:ENUMERATED, _} -> "err = asn1_serialize_int64(s, (int64_t)#{var}); if (!asn1_is_ok(err)) return err;"
      {:INTEGER, _} -> "err = asn1_serialize_int64(s, #{var}); if (!asn1_is_ok(err)) return err;"
      :UTF8String -> "err = asn1_serialize_string(s, ASN1_ID_UTF8_STRING, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      :PrintableString -> "err = asn1_serialize_string(s, ASN1_ID_PRINTABLE_STRING, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      :IA5String -> "err = asn1_serialize_string(s, ASN1_ID_IA5_STRING, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      :GeneralizedTime -> "err = asn1_serialize_string(s, ASN1_ID_GENERALIZED_TIME, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      :UTCTime -> "err = asn1_serialize_string(s, ASN1_ID_UTC_TIME, #{var}, strlen(#{var})); if (!asn1_is_ok(err)) return err;"
      :ANY -> "err = asn1_serialize_raw(s, #{var}.bytes, #{var}.length); if (!asn1_is_ok(err)) return err;"
      {:Externaltypereference, _, mod, ref_type} ->
        c_ref_name = sanitize_type_name("#{mod}_#{ref_type}")
        "err = #{c_ref_name}_encode(&#{var}, s); if (!asn1_is_ok(err)) return err;"
      _ -> "/* TODO: encode #{inspect(type_ast)} */ (void)#{var};"
    end
  end

  defp primitive_decoder(type_ast, var) do
    case type_ast do
      :INTEGER -> "{ int64_t val; err = asn1_parse_int64(child, &val); if (!asn1_is_ok(err)) return err; #{var} = val; }"
      :BOOLEAN -> "{ bool val; err = asn1_parse_boolean(child, &val, ASN1_ENCODING_DER); if (!asn1_is_ok(err)) return err; #{var} = val; }"
      :NULL -> "err = asn1_parse_null(child); if (!asn1_is_ok(err)) return err;"
      :"OBJECT IDENTIFIER" ->
        "{ asn1_oid_t oid; err = asn1_parse_oid(child, &oid); if (!asn1_is_ok(err)) return err; #{var}.count = oid.count; for(size_t i=0; i<oid.count; i++) #{var}.components[i] = oid.components[i]; }"
      :"OCTET STRING" ->
        "{ const uint8_t *data; size_t len; err = asn1_parse_octet_string(child, &data, &len); if (!asn1_is_ok(err)) return err; if(len > sizeof(#{var}.bytes)) len = sizeof(#{var}.bytes); memcpy(#{var}.bytes, data, len); #{var}.length = len; }"
      :"BIT STRING" ->
        "{ asn1_bit_string_t bs; err = asn1_parse_bit_string(child, &bs); if (!asn1_is_ok(err)) return err; if(bs.byte_count > sizeof(#{var}.bytes)) bs.byte_count = sizeof(#{var}.bytes); memcpy(#{var}.bytes, bs.bytes, bs.byte_count); #{var}.byte_count = bs.byte_count; #{var}.unused_bits = bs.unused_bits; }"
      {:"BIT STRING", _} ->
        "{ asn1_bit_string_t bs; err = asn1_parse_bit_string(child, &bs); if (!asn1_is_ok(err)) return err; if(bs.byte_count > sizeof(#{var}.bytes)) bs.byte_count = sizeof(#{var}.bytes); memcpy(#{var}.bytes, bs.bytes, bs.byte_count); #{var}.byte_count = bs.byte_count; #{var}.unused_bits = bs.unused_bits; }"
      {:"OCTET STRING", _} ->
        "{ const uint8_t *data; size_t len; err = asn1_parse_octet_string(child, &data, &len); if (!asn1_is_ok(err)) return err; if(len > sizeof(#{var}.bytes)) len = sizeof(#{var}.bytes); memcpy(#{var}.bytes, data, len); #{var}.length = len; }"
      {:ENUMERATED, _} -> "{ int64_t val; err = asn1_parse_int64(child, &val); if (!asn1_is_ok(err)) return err; #{var} = (int64_t)val; }"
      {:INTEGER, _} -> "{ int64_t val; err = asn1_parse_int64(child, &val); if (!asn1_is_ok(err)) return err; #{var} = val; }"
      :ANY -> "{ if(child->data_length > sizeof(#{var}.bytes)) return asn1_error(ASN1_ERROR_INVALID_OBJECT, \"data too large\", 0); memcpy(#{var}.bytes, child->data_bytes, child->data_length); #{var}.length = child->data_length; }"
      {:Externaltypereference, _, mod, ref_type} ->
        c_ref_name = sanitize_type_name("#{mod}_#{ref_type}")
        "err = #{c_ref_name}_decode(&#{var}, child, result); if (!asn1_is_ok(err)) return err;"
      _ -> "/* TODO: decode #{inspect(type_ast)} */"
    end
  end

  defp current_module, do: getEnv(:current_module, "")

  defp emit_sequence_field(struct_name, {:ComponentType, _, field_name, {:type, _, type_ast, _, _, _}, optional, _, _}) do
    field = fieldName(field_name)
    c_type = fieldType(struct_name, field_name, type_ast)

    presence =
      if optional?(optional) do
        "    bool has_#{field};\n"
      else
        ""
      end

    # Handle C array types like "char[256]" -> "char field[256]"
    field_decl = case Regex.run(~r/^(\w+)\[(\d+)\]$/, c_type) do
      [_, base_type, size] -> "#{base_type} #{field}[#{size}]"
      _ -> "#{c_type} #{field}"
    end

    presence <> "    #{field_decl};"
  end

  defp emit_sequence_field(_struct_name, _other), do: ""

  defp optional?(opt) when opt == :OPTIONAL, do: true

  defp optional?(opt) when is_list(opt) do
    Enum.any?(opt, &(&1 == :OPTIONAL))
  end

  defp optional?(_), do: false

  defp choice_variant(struct_name, {:ComponentType, _, field_name, {:type, _, type_ast, _, _, _}, _optional, _, _}) do
    field = fieldName(field_name)
    type = fieldType(struct_name, field_name, type_ast)
    {field_name, field, type}
  end

  defp choice_variant(_struct_name, _other), do: nil

  defp selector_name(choice_name, variant) do
    variant_label =
      variant
      |> bin()
      |> normalizeName()
      |> String.upcase()

    "#{choice_name}_SELECTOR_#{variant_label}"
  end

  defp enum_case(enum_name, {:NamedNumber, label, value}) do
    label_str =
      label
      |> bin()
      |> normalizeName()
      |> String.upcase()

    "    #{enum_name}_#{label_str} = #{literal(value)},"
  end

  defp enum_case(enum_name, {label, value}) when is_atom(label) do
    enum_case(enum_name, {:NamedNumber, label, value})
  end

  defp enum_case(enum_name, other) do
    value = literal(other)
    "    #{enum_name}_VALUE_#{value} = #{value},"
  end

  defp literal({:Externalvaluereference, _, mod, name}), do: sanitize_type_name("#{mod}_#{name}")
  defp literal(val) when is_integer(val), do: Integer.to_string(val)
  defp literal(val) when is_binary(val), do: ~s("#{val}")
  defp literal(val), do: inspect(val)

  defp flatten_oid(val) when is_list(val) do
    Enum.flat_map(val, &flatten_oid/1)
  end

  defp flatten_oid({:NamedNumber, _, inner}), do: flatten_oid(inner)
  defp flatten_oid({:seqtag, _, _, _}), do: []
  defp flatten_oid({:Externalvaluereference, _, _, name}), do: flatten_oid(name)
  defp flatten_oid(atom) when is_atom(atom) do
    value = Atom.to_string(atom)

    case Integer.parse(value) do
      {number, ""} -> [Integer.to_string(number)]
      _ -> []
    end
  end

  defp flatten_oid(int) when is_integer(int), do: [Integer.to_string(int)]
  defp flatten_oid(other), do: [inspect(other)]

  defp emit_unit(modname, type_name, body, deps \\ MapSet.new()) do
    guard = guard_name(modname, type_name)
    current_dir = current_output_dir()

    includes =
      deps
      |> MapSet.to_list()
      |> Enum.sort()
      |> Enum.map(&~s(#include "#{header_include_path(&1, current_dir)}"))
      |> Enum.join("\n")

    include_block =
      case includes do
        "" -> ""
        other -> other <> "\n\n"
      end

    """
    #{file_banner(type_name)}
    #ifndef #{guard}
    #define #{guard}

    #{@common_block}

    #{include_block}#{String.trim(body)}

    #endif /* #{guard} */
    """
  end

  defp file_banner(type_name) do
    """
    /*
     * Generated by ASN1.ERP.UNO Compiler
     * Target: C99 NASA style emitter
     * Type: #{type_name}
     * Guideline: NASA-STD-8739.8 compliant layout (4 spaces, explicit types).
     */
    """
  end

  defp guard_name(modname, type_name) do
    [modname, type_name, "H"]
    |> Enum.map(&bin/1)
    |> Enum.map(&normalizeName/1)
    |> Enum.join("_")
    |> String.upcase()
  end

  defp default_type_name(value) do
    str = bin(value) |> normalizeName()
    lower = String.downcase(str)
    # Don't uppercase if it's already a valid C primitive type
    if lower in ["int64_t", "uint64_t", "int32_t", "uint32_t", "int16_t", "uint16_t",
                 "int8_t", "uint8_t", "size_t", "bool", "void"] do
      lower
    else if String.starts_with?(str, "ASN1C_") do
      str
    else
      String.upcase(str)
    end end
  end

  defp sanitize_type_name(value, fallback \\ nil) do
    raw =
      value
      |> bin()
      |> normalizeName()
      |> String.replace(~r/[^A-Za-z0-9_]/, "_")
      |> String.upcase()
      |> String.trim("_")

    cond do
      raw == "" and fallback -> fallback
      raw == "" -> "ASN1C_NODE"
      String.match?(raw, ~r/^[0-9]/) -> "T_" <> raw
      true -> raw
    end
  end

  defp current_module do
    getEnv(:current_module, "")
  end

  defp header_include_path(dep, current_dir) do
    locations = Process.get(:c99_header_locations, %{})

    case Map.get(locations, dep) do
      nil ->
        "#{dep}.h"

      dep_dir ->
        dep_file = Path.join(dep_dir, "#{dep}.h")
        relative_path(dep_file, current_dir)
    end
  end

  defp relative_path(target, base_dir) do
    target_expanded = Path.expand(target)
    base_expanded = Path.expand(base_dir)

    target_segments = Path.split(target_expanded)
    base_segments = Path.split(base_expanded)

    common_length = common_prefix_length(target_segments, base_segments)

    target_rest = Enum.drop(target_segments, common_length)
    base_rest = Enum.drop(base_segments, common_length)

    ups = Enum.map(base_rest, fn _ -> ".." end)
    path_segments = ups ++ target_rest

    path = Path.join(path_segments)

    if path == "" do
      "."
    else
      path
    end
  end

  defp common_prefix_length([head | rest1], [head | rest2]) do
    1 + common_prefix_length(rest1, rest2)
  end

  defp common_prefix_length(_, _), do: 0

  defp qualified_name(name, mod) do
    mod_part =
      mod
      |> bin()
      |> normalizeName()

    sanitize_type_name("#{mod_part}_#{name}")
  end
end
