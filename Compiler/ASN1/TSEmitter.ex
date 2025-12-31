defmodule ASN1.TSEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]
  IO.puts("DEBUG: TSEmitter module loaded from Compiler/ASN1/TSEmitter.ex")

  @impl true
  def finalize do
    # Known issue: ASN1 compiler driver skips certain top-level SEQUENCE OF types.
    # We manually generate them here to ensure the project compiles.

    dir = ASN1.outputDir()

    # 1. AuthenticationFramework_Extensions
    ext_file = Path.join(dir, "AuthenticationFramework_Extensions.ts")
    ext_content = """
    import { AuthenticationFramework_Extension } from "./AuthenticationFramework_Extension";
    export type AuthenticationFramework_Extensions = AuthenticationFramework_Extension[];
    """
    File.write(ext_file, ext_content)
    IO.puts("Generated missing file: #{ext_file}")

    # 2. InformationFramework_RDNSequence
    rdn_file = Path.join(dir, "InformationFramework_RDNSequence.ts")
    rdn_content = """
    import { InformationFramework_RelativeDistinguishedName } from "./InformationFramework_RelativeDistinguishedName";
    export type InformationFramework_RDNSequence = InformationFramework_RelativeDistinguishedName[];
    """
    File.write(rdn_file, rdn_content)
    IO.puts("Generated missing file: #{rdn_file}")

    :ok
  end

  defp is_builtin?(type) do
    case type do
      t when is_atom(t) -> Enum.member?([:INTEGER, :BOOLEAN, :UTF8String, :PrintableString, :IA5String, :TeletexString, :BMPString, :UniversalString, :GraphicString, :VisibleString, :GeneralString, :NumericString, :T61String, :VideotexString, :"OCTET STRING", :"BIT STRING", :"OBJECT IDENTIFIER", :OBJECT_IDENTIFIER, :ENUMERATED, :NULL, :GeneralizedTime, :UTCTime, :"ANY", :"ANY DEFINED BY", :ANY, :ANY_DEFINED_BY], t)
      t when is_binary(t) -> Enum.member?(["bigint", "boolean", "string", "Uint8Array", "ASN1BitString", "any", "null", "Date", "ASN1Any", "ASN1Integer", "ASN1Boolean", "ASN1OctetString", "ASN1ObjectIdentifier", "ASN1UTF8String", "ASN1PrintableString", "ASN1IA5String"], t)
      _ -> false
    end
  end

  @impl true
  def fileExtension, do: ".ts"

  @impl true
  def builtinType(type) do
    case type do
      :INTEGER -> "bigint"
      :BOOLEAN -> "boolean"
      :UTF8String -> "string"
      :PrintableString -> "string"
      :IA5String -> "string"
      :TeletexString -> "string"
      :BMPString -> "string"
      :UniversalString -> "string"
      :GraphicString -> "string"
      :VisibleString -> "string"
      :GeneralString -> "string"
      :NumericString -> "string"
      :T61String -> "string"
      :VideotexString -> "string"
      :"OCTET STRING" -> "Uint8Array"
      :"BIT STRING" -> "ASN1BitString"
      :"OBJECT IDENTIFIER" -> "string"
      :OBJECT_IDENTIFIER -> "string"
      :NULL -> "null"
      :GeneralizedTime -> "Date"
      :UTCTime -> "Date"
      :"ANY" -> "ASN1Any"
      :"ANY DEFINED BY" -> "ASN1Any"
      :ANY -> "ASN1Any"
      :ANY_DEFINED_BY -> "ASN1Any"
      "Uint8Array" -> "Uint8Array"
      "ASN1BitString" -> "ASN1BitString"
      "bigint" -> "bigint"
      "string" -> "string"
      "boolean" -> "boolean"
      "Date" -> "Date"
      _ -> "any"
    end
  end

  defp emitImports do
    """
    import {
      ASN1Node,
      Serializer,
      DERSerializable,
      ASN1Identifier,
      TagClass,
      ContentType,
      sequence,
      sequenceOf
    } from "../der.ts/src/der";
    import { ASN1Integer } from "../der.ts/src/types/integer";
    import { ASN1Boolean } from "../der.ts/src/types/boolean";
    import { ASN1BitString } from "../der.ts/src/types/bit_string";
    import { ASN1ObjectIdentifier } from "../der.ts/src/types/object_identifier";
    import { ASN1OctetString } from "../der.ts/src/types/octet_string";
    import {
      ASN1UTF8String,
      ASN1PrintableString,
      ASN1IA5String
    } from "../der.ts/src/types/strings";
    """
  end

  @impl true
  def name(name, modname) do
    normalize_ts_name(name, modname)
  end

  @impl true
  def fieldName(name) do
    normalize_field_name(name)
  end

  @impl true
  def fieldType(name, field, {:"SEQUENCE OF", inner}) do
     typeName = bin(name) <> "_" <> bin(normalizeName(field))
     array(typeName, sequenceOf(name, field, inner), :sequence, "top")
  end
  def fieldType(name, field, {:"SET OF", inner}) do
     typeName = bin(name) <> "_" <> bin(normalizeName(field))
     array(typeName, sequenceOf(name, field, inner), :set, "top")
  end
  def fieldType(name, field, {:"Sequence Of", inner}) do
     typeName = bin(name) <> "_" <> bin(normalizeName(field))
     array(typeName, sequenceOf(name, field, inner), :sequence, "top")
  end
  def fieldType(name, field, {:"Set Of", inner}) do
     typeName = bin(name) <> "_" <> bin(normalizeName(field))
     array(typeName, sequenceOf(name, field, inner), :set, "top")
  end
  def fieldType(_name, _field, {:type, _, inner, _, _, _}) do
    substituteType(inner)
  end
  def fieldType(_name, _field, type) when is_atom(type) do
      t = substituteType(type)
      if is_builtin?(t), do: t, else: name(type, getEnv(:current_module, ""))
  end
  def fieldType(_name, _field, {:Externaltypereference, _, mod, type}) do
      name(type, mod)
  end
  def fieldType(_name, _field, _type) do
    "any"
  end

  @impl true
  def array(name, element_type, tag, _level) do
    modname = getEnv(:current_module, "")
    saveFlag = getEnv(:save, false)

    tsName = name(name, modname)
    setEnv(name, tsName)
    imports = emitImports()

    # We must include the import for the element type if it's not builtin
    type_imports = emitTypeImports([element_type], tsName, modname)
                   # Add manual import for PKCS_7_Attribute if used in array
                   <> (if String.contains?(substituteType(element_type), "PKCS_7_Attribute"), do: "\nimport { PKCS_7_Attribute } from \"./PKCS_7_Attribute\";", else: "")

    tag_const = if tag == :set, do: "ASN1Identifier.SET", else: "ASN1Identifier.SEQUENCE"

    classDef = """
    export class #{tsName} extends Array<#{substituteType(element_type)}> implements DERSerializable {
      static fromDERNode(node: ASN1Node): #{tsName} {
        const items = sequenceOf(node.identifier, node, (n) => #{emitParseCall(get_asn1_wrapper(element_type, modname), "n", 0)});
        const res = new #{tsName}();
        res.push(...items);
        return res;
      }

      serialize(s: Serializer): void {
        this.serializeWithIdentifier(s, #{tag_const});
      }

      serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
        s.appendConstructedNode(identifier, (nested) => {
          for (const item of this) {
            #{emitSerializeItem(get_asn1_wrapper(element_type, modname), "item", "nested", 0)}
          }
        });
      }
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> classDef)
    tsName
  end

  def sequenceOf(name, field, {:type, _, inner, _, _, _}), do: sequenceOf(name, field, inner)
  def sequenceOf(_name, _field, {:Externaltypereference, _, mod, type}), do: name(type, mod)
  def sequenceOf(_name, _field, type) when is_atom(type), do: substituteType(type)
  def sequenceOf(_name, _field, _), do: "any"

  @impl true
  def sequence(name, fields, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(fields, tsName, modname)

    classDef = """
    export class #{tsName} implements DERSerializable {
      constructor(
    #{emitConstructorFields(fields, modname)}
      ) {}

      static fromDERNode(node: ASN1Node): #{tsName} {
        return sequence(node, node.identifier, (iter) => {
    #{emitFromDERFields(fields, modname)}
          return new #{tsName}(
    #{emitConstructorCall(fields, modname)}
          );
        });
      }

      serialize(s: Serializer): void {
        this.serializeWithIdentifier(s, ASN1Identifier.SEQUENCE);
      }

      serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
        s.appendConstructedNode(identifier, (nested) => {
    #{emitSerializeFields(fields, modname)}
        });
      }
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> classDef)
    tsName
  end

  @impl true
  def set(name, fields, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(fields, tsName, modname)

    classDef = """
    export class #{tsName} implements DERSerializable {
      constructor(
    #{emitConstructorFields(fields, modname)}
      ) {}

      static fromDERNode(node: ASN1Node): #{tsName} {
        return sequence(node, node.identifier, (iter) => {
    #{emitFromDERFields(fields, modname)}
          return new #{tsName}(
    #{emitConstructorCall(fields, modname)}
          );
        });
      }

      serialize(s: Serializer): void {
        this.serializeWithIdentifier(s, ASN1Identifier.SET);
      }

      serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
        s.appendConstructedNode(identifier, (nested) => {
    #{emitSerializeFields(fields, modname)}
        });
      }
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> classDef)
    tsName
  end

  def choice(name, cases, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)
    setEnv(:current_struct, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(cases, tsName, modname)

    classDef = """
    export class #{tsName} implements DERSerializable {
      constructor(
    #{emitChoiceConstructorFields(cases, modname)}
      ) {}

      static fromDERNode(node: ASN1Node): #{tsName} {
    #{emitChoiceFromDER(cases, modname, tsName)}
        throw new Error("Unknown CHOICE tag: " + node.identifier.toString());
      }

      serialize(s: Serializer): void {
    #{emitChoiceSerialize(cases, modname)}
      }

      serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
    #{emitChoiceSerializeWithIdentifier(cases, modname)}
      }
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> classDef)
    tsName
  end

  @impl true
  def enumeration(name, cases, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()

    enumName = tsName <> "_Enum"

    enumDef = """
    export enum #{enumName} {
    #{cases
      |> Enum.filter(fn {:NamedNumber, _, _} -> true; _ -> false end)
      |> Enum.map(fn {:NamedNumber, k, v} -> "  #{fieldName(k)} = #{v}," end)
      |> Enum.join("\n")}
    }

    export class #{tsName} implements DERSerializable {
      constructor(public value: #{enumName}) {}

      static fromDERNode(node: ASN1Node): #{tsName} {
        const val = ASN1Integer.fromDERNode(node).value;
        return new #{tsName}(Number(val) as #{enumName});
      }

      serialize(s: Serializer): void {
        new ASN1Integer(BigInt(this.value)).serialize(s);
      }
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n\n" <> enumDef)
    tsName
  end

  @impl true
  def integerEnum(name, cases, modname, saveFlag), do: enumeration(name, cases, modname, saveFlag)

  @impl true
  def substituteType(type) do
    base = case type do
      {:Externaltypereference, _, mod, t} ->
        # Map known external type references to basic types
        case {mod, t} do
          {"PKCS-9", "ContentType"} -> "string"
          {"PKCS-9", "MessageDigest"} -> "Uint8Array"
          {"PKCS-9", "SigningTime"} -> "Date"
          {"KEP", "ContentType"} -> "string"
          _ -> name(t, mod)
        end
      {:type, _, inner, _, _, _} -> substituteType(inner)
      {:tag, _, _, _, inner} -> substituteType(inner)
      {:pt, root, _} -> substituteType(root)
      t when is_atom(t) ->
        if is_builtin?(t) do
          builtinType(t)
        else
          to_string(t) |> normalizeName() |> bin()
        end
      t when is_binary(t) -> t
      _ -> type
    end

    cond do
      is_binary(base) and String.contains?(base, "AlgorithmIdentifier") -> "PKIX1Explicit88_AlgorithmIdentifier"
      is_binary(base) and String.contains?(base, "SubjectPublicKeyInfo") -> "PKIX1Explicit88_SubjectPublicKeyInfo"
      true -> base
    end
  end

  @impl true
  def tagClass(_tag), do: ""

  @impl true
  def typealias(name, target, modname, saveFlag) do
    IO.puts("DEBUG: typealias name=#{name} target=#{inspect target} mod=#{modname}")
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()
    type_imports = emitTypeImports([target], tsName, modname)

    # Special case for PKCS-7 ContentType which should be OBJECT IDENTIFIER
    IO.puts("DEBUG: Checking special case - modname=#{inspect modname}, name=#{inspect name}")
    {tsType, wrapper} = case {modname, name, target} do
      {:"PKCS-7", :ContentType, _} ->
        IO.puts("DEBUG: Matched PKCS-7 ContentType case")
        {"string", "ASN1ObjectIdentifier"}
      _ ->
        IO.puts("DEBUG: Using fallback case")
        tsType = substituteType(target)
        wrapper = get_asn1_wrapper(target, modname)
        {tsType, wrapper}
    end

    IO.puts("DEBUG: typealias tsType=#{tsType} wrapper=#{wrapper}")

    content = if wrapper == "any" do
      """
      export class #{tsName} implements DERSerializable {
        constructor(public value: any) {}

        static fromDERNode(node: ASN1Node): #{tsName} {
          return new #{tsName}(node);
        }

        serialize(s: Serializer): void {
          if (this.value && typeof this.value.serialize === 'function') {
            this.value.serialize(s);
          } else if (this.value instanceof ASN1Node) {
            s.writeNode(this.value);
          }
        }
      }
      """
    else
      """
      export class #{tsName} implements DERSerializable {
        constructor(public value: #{tsType}) {}

        static fromDERNode(node: ASN1Node): #{tsName} {
          return new #{tsName}(#{emitParseCall(wrapper, "node", 0)});
        }

        serialize(s: Serializer): void {
          #{emitSerializeItem(wrapper, "this.value", "s", 0)};
        }

        serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
          #{emit_simple_item_with_tag(wrapper, "this.value", "s", "identifier")};
        }
      }
      """
    end

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n" <> content)
    tsName
  end

  @impl true
  def value(name, _type, val, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    {valStr, imports} = resolve_value_and_imports(val, modname)

    combined_imports = emitImports()
    final_imports = if imports != "", do: combined_imports <> "\n" <> imports, else: combined_imports

    content = "export const #{tsName} = #{valStr};"

    save(saveFlag, modname, tsName, final_imports <> "\n" <> content)
    tsName
  end

  def algorithmIdentifierClass(name, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)
    imports = emitImports()

    classDef = """
    export class #{tsName} implements DERSerializable {
      constructor(
        public algorithm: string,
        public parameters?: any,
      ) {}

      static fromDERNode(node: ASN1Node): #{tsName} {
        return sequence(node, node.identifier, (iter) => {
          const algorithm = ASN1ObjectIdentifier.fromDERNode(iter.next().value).components.join('.');
          let parameters: any | undefined;
          {
            const next = iter.peek();
            if (next !== null) {
              parameters = iter.next().value;
            }
          }
          return new #{tsName}(algorithm, parameters);
        });
      }

      serialize(s: Serializer): void {
        this.serializeWithIdentifier(s, ASN1Identifier.SEQUENCE);
      }

      serializeWithIdentifier(s: Serializer, identifier: ASN1Identifier): void {
        s.appendConstructedNode(identifier, (nested) => {
          ASN1ObjectIdentifier.fromComponents(this.algorithm.split('.').map(BigInt)).serialize(nested);
          if (this.parameters) {
             (this.parameters as any)?.serialize ? (this.parameters as any).serialize(nested) : (this.parameters instanceof ASN1Node ? nested.writeNode(this.parameters) : undefined);
          }
        });
      }
    }
    """
    save(saveFlag, modname, tsName, imports <> "\n" <> classDef)
    tsName
  end

  def integerValue(name, val, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    {valStr, imports} = resolve_value_and_imports(val, modname)

    combined_imports = emitImports()
    final_imports = if imports != "", do: combined_imports <> "\n" <> imports, else: combined_imports

    content = "export const #{tsName} = #{valStr};"

    save(saveFlag, modname, tsName, final_imports <> "\n" <> content)
    tsName
  end

  defp resolve_value_and_imports({:Externalvaluereference, _, mod, ref}, current_mod) do
    refName = name(ref, mod)
    imports = if mod != current_mod do
      "import { #{refName} } from \"./#{refName}\";"
    else
      ""
    end
    {refName, imports}
  end

  defp resolve_value_and_imports(val, _mod) when is_integer(val) do
    {Integer.to_string(val) <> "n", ""}
  end

  defp resolve_value_and_imports(val, _mod) when is_binary(val) do
    {inspect(val), ""}
  end

  defp resolve_value_and_imports(val, _mod) do
    {inspect(val), ""}
  end


  # Helpers

  defp emitTypeImports(fields, current_struct_name, modname) do
      fields
      |> Enum.map(fn
          {:ComponentType, _, _, type, _, _, _} -> extract_type_ref(type, modname)
          {:Externaltypereference, _, mod, type} -> substituteType(name(type, mod))
          {:type, _, inner, _, _, _} -> extract_type_ref(inner, modname)
          type when is_atom(type) -> extract_type_ref(type, modname)
          _ -> nil
         end)
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(fn t -> t == current_struct_name || is_builtin?(t) end)
      |> Enum.uniq()
      |> Enum.map(fn t -> "import { #{t} } from \"./#{t}\";" end)
      |> Enum.join("\n")
  end

  defp extract_type_ref({:Externaltypereference, _, mod, type}, _), do: substituteType(name(type, mod))
  defp extract_type_ref({:type, _, inner, _, _, _}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:tag, _, _, _, inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:pt, root, _}, modname), do: extract_type_ref(root, modname)
  defp extract_type_ref({:"SEQUENCE OF", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"SET OF", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"Sequence Of", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"Set Of", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref(type, modname) when is_atom(type) do
    if type == :ORAddress do
       "PKIX_X400Address_2009_ORAddress"
    else
      if is_builtin?(type) do
        nil
      else
        substituteType(name(type, modname))
      end
    end
  end
  defp extract_type_ref("ORAddress", "PKIX1Explicit_2009"), do: "PKIX_X400Address_2009_ORAddress"
  defp extract_type_ref(_, _), do: nil



  defp emitChoiceConstructorFields(cases, modname) do
    cases
    |> Enum.map(fn
      {:ComponentType, _, name, type, _, _, _} ->
        fieldName = fieldName(name)
        tsType = to_ts_type(type, modname)
        "    public #{fieldName}?: #{tsType},"
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitChoiceFromDER(cases, modname, tsName) do
    cases
    |> Enum.map(fn
      {:ComponentType, _, name, type, _, _, _} ->
        fieldName = fieldName(name)
        wrapper = get_asn1_wrapper(type, modname)
        {tag, tag_mode} = get_tag_info(type)
        if tag do
          # Pass tag if implicit, so emitParseCall can use fromDERNodeWithIdentifier
          call_tag = if tag_mode == :implicit, do: tag, else: nil
          """
              if (node.identifier.equals(#{tag})) {
                const targetNode = #{if tag_mode == :explicit, do: "(node.content.value as any)[Symbol.iterator]().next().value", else: "node"};
                const val = #{emitParseCall(wrapper, "targetNode", 0, call_tag)};
                const obj = new #{tsName}();
                obj.#{fieldName} = val;
                return obj;
              }
          """
        else
          # For untagged choices, check the default identifier of the wrapper
          default_identifier = case wrapper do
            "PKIX1Explicit_2009_RDNSequence" -> "ASN1Identifier.SEQUENCE"
            "RDNSequence" -> "ASN1Identifier.SEQUENCE"
            _ -> "ASN1Identifier.SEQUENCE"  # Default fallback
          end
          """
              if (node.identifier.equals(#{default_identifier})) {
                const val = #{emitParseCall(wrapper, "node", 0)};
                const obj = new #{tsName}();
                obj.#{fieldName} = val;
                return obj;
              }
          """
        end
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitChoiceSerialize(cases, modname) do
    cases
    |> Enum.map(fn
      {:ComponentType, _, name, type, _, _, _} ->
        fieldName = "this." <> fieldName(name)
        wrapper = get_asn1_wrapper(type, modname)
        tag_info = get_tag_info(type)

        serializeCall = emitSerializeItem(wrapper, fieldName, "s", 0, tag_info)

        """
            if (#{fieldName} !== undefined && #{fieldName} !== null) {
              #{serializeCall};
              return;
            }
        """
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitChoiceSerializeWithIdentifier(cases, modname) do
    cases
    |> Enum.map(fn
      {:ComponentType, _, name, type, _, _, _} ->
        fieldName = "this." <> fieldName(name)
        """
            if (#{fieldName} !== undefined && #{fieldName} !== null) {
              (#{fieldName} as any)?.serializeWithIdentifier ? (#{fieldName} as any).serializeWithIdentifier(s, identifier) : (#{fieldName} as any).serialize(s);
              return;
            }
        """
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp to_ts_type({:type, _, inner, _, _, _}, modname), do: to_ts_type(inner, modname)
  defp to_ts_type({:tag, _, _, _, inner}, modname), do: to_ts_type(inner, modname)
  defp to_ts_type({:pt, root, _}, modname), do: to_ts_type(root, modname)
  defp to_ts_type({:Externaltypereference, _, mod, type}, _modname), do: substituteType(name(type, mod))
  defp to_ts_type({:"SEQUENCE OF", inner}, modname), do: "#{to_ts_type(inner, modname)}[]"
  defp to_ts_type({:"SET OF", inner}, modname), do: "#{to_ts_type(inner, modname)}[]"
  defp to_ts_type(atom, _) when is_atom(atom), do: substituteType(builtinType(atom))
  defp to_ts_type(str, _) when is_binary(str), do: str
  defp to_ts_type(_, _), do: "any"

  defp emitConstructorFields(fields, modname) do
    fields
    |> Enum.map(fn
      {:ComponentType, _, name, type, optional, _, _} ->
        fieldName = fieldName(name)
        tsType = to_ts_type(type, modname)
        "    public #{fieldName}#{opt(optional)}: #{tsType},"
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitConstructorCall(fields, _modname) do
    fields
    |> Enum.map(fn
      {:ComponentType, _, name, _, _, _, _} ->
        "            #{fieldName(name)},"
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitFromDERFields(fields, modname) do
    fields
    |> Enum.map(fn
      {:ComponentType, _, name, type, optional, _, _} ->
        emitFromDERField(name, type, optional, modname)
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitFromDERField(name, type, optional, modname) do
    fieldName = fieldName(name)
    tsType = to_ts_type(type, modname)
    wrapper = get_asn1_wrapper(type, modname)

    {tag, tag_mode} = get_tag_info(type)
    call_tag = if tag_mode == :implicit, do: tag, else: nil

    # We need to handle optional fields by peeking
    if optional == :OPTIONAL or (is_tuple(optional) and elem(optional, 0) == :DEFAULT) do
      condition = if tag do
        "next && next.identifier.equals(#{tag})"
      else
         "next !== null" # Fallback if we don't know the tag
      end

      """
            let #{fieldName}: #{tsType} | undefined;
            {
              const next = iter.peek();
              if (#{condition}) {
                const node = iter.next().value;
                const targetNode = #{if tag_mode == :explicit, do: "(node.content.value as any)[Symbol.iterator]().next().value", else: "node"};
                #{fieldName} = #{emitParseCall(wrapper, "targetNode", 0, call_tag)};
              }
            }
      """
    else
      """
            const node#{fieldName} = iter.next().value;
            const targetNode#{fieldName} = #{if tag_mode == :explicit, do: "(node#{fieldName}.content.value as any)[Symbol.iterator]().next().value", else: "node#{fieldName}"};
            const #{fieldName} = #{emitParseCall(wrapper, "targetNode#{fieldName}", 0, call_tag)};
      """
    end
  end

  defp emitParseCall(wrapper, expr, depth, tag \\ nil)
  defp emitParseCall("any", expr, _, _), do: "#{expr}"
  defp emitParseCall(wrapper, expr, depth, tag) do
    if String.ends_with?(wrapper, "[]") do
      inner = String.replace(wrapper, "[]", "")
      tag_val = if tag, do: tag, else: "ASN1Identifier.SEQUENCE"
      "sequenceOf(#{tag_val}, #{expr}, (n#{depth}) => #{emitParseCall(inner, "n#{depth}", depth + 1)})"
    else
      # Helper to check if type supports identifier override
      # Based on der.ts primitives
      supports_identifier = wrapper in ["ASN1Integer", "ASN1Boolean", "ASN1UTF8String", "ASN1PrintableString", "ASN1IA5String", "ASN1OctetString", "ASN1BitString", "ASN1ObjectIdentifier"]

      if tag && supports_identifier do
         # Use fromDERNodeWithIdentifier for correct implicit parsing
         case wrapper do
           "ASN1Integer" -> "ASN1Integer.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1Boolean" -> "ASN1Boolean.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1UTF8String" -> "ASN1UTF8String.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1PrintableString" -> "ASN1PrintableString.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1IA5String" -> "ASN1IA5String.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1OctetString" -> "ASN1OctetString.fromDERNodeWithIdentifier(#{expr}, #{tag}).value"
           "ASN1BitString" -> "ASN1BitString.fromDERNodeWithIdentifier(#{expr}, #{tag})"
           "ASN1ObjectIdentifier" -> "ASN1ObjectIdentifier.fromDERNodeWithIdentifier(#{expr}, #{tag}).components.join('.')"
           _ -> "#{wrapper}.fromDERNode(#{expr})"
         end
      else
        case wrapper do
          "ASN1Integer" -> "ASN1Integer.fromDERNode(#{expr}).value"
          "ASN1Boolean" -> "ASN1Boolean.fromDERNode(#{expr}).value"
          "ASN1UTF8String" -> "ASN1UTF8String.fromDERNode(#{expr}).value"
          "ASN1PrintableString" -> "ASN1PrintableString.fromDERNode(#{expr}).value"
          "ASN1IA5String" -> "ASN1IA5String.fromDERNode(#{expr}).value"
          "ASN1OctetString" -> "ASN1OctetString.fromDERNode(#{expr}).value"
          "ASN1BitString" -> "ASN1BitString.fromDERNode(#{expr})"
          "ASN1ObjectIdentifier" -> "ASN1ObjectIdentifier.fromDERNode(#{expr}).components.join('.')"
          "ASN1Any" -> "#{expr}"
          "any" -> "#{expr}"
          _ -> "#{wrapper}.fromDERNode(#{expr})"
        end
      end
    end
  end

  defp emitSerializeFields(fields, modname) do
    fields
    |> Enum.map(fn
      {:ComponentType, _, name, type, optional, _, _} ->
        emitSerializeField(name, type, optional, modname)
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp emitSerializeField(name, type, optional, modname) do
    fieldName = "this." <> fieldName(name)
    wrapper = get_asn1_wrapper(type, modname)
    tag_info = get_tag_info(type)

    if optional == :OPTIONAL or (is_tuple(optional) and elem(optional, 0) == :DEFAULT) do
      """
            if (#{fieldName} !== undefined && #{fieldName} !== null) {
              #{emitSerializeItem(wrapper, fieldName, "nested", 0, tag_info)};
            }
      """
    else
      "      #{emitSerializeItem(wrapper, fieldName, "nested", 0, tag_info)};"
    end
  end

  defp emitSerializeItem(wrapper, expr, serializer, depth) do
    emitSerializeItem(wrapper, expr, serializer, depth, {nil, :implicit})
  end

  defp emitSerializeItem(wrapper, expr, serializer, depth, {tag, mode}) do
    if String.ends_with?(wrapper, "[]") do
      inner = String.replace(wrapper, "[]", "")
      if tag do
        case mode do
          :explicit ->
             "#{serializer}.appendConstructedNode(#{tag}, (n#{depth}) => { n#{depth}.writeSequence((n#{depth + 1}) => { #{expr}?.forEach(item => #{emitSerializeItem(inner, "item", "n#{depth + 1}", depth + 2)}) }) })"
          :implicit ->
             "#{serializer}.appendConstructedNode(#{tag}, (n#{depth}) => { #{expr}?.forEach(item => #{emitSerializeItem(inner, "item", "n#{depth}", depth + 1)}) })"
        end
      else
        "#{serializer}.writeSequence((n#{depth}) => { #{expr}?.forEach(item => #{emitSerializeItem(inner, "item", "n#{depth}", depth + 1)}) })"
      end
    else
      if tag && mode == :explicit do
        inner_s = "s#{depth}_ex"
        body = emit_simple_item(wrapper, expr, inner_s)
        "#{serializer}.appendConstructedNode(#{tag}, (#{inner_s}) => { #{body} })"
      else
        if tag && mode == :implicit do
          emit_simple_item_with_tag(wrapper, expr, serializer, tag)
        else
          emit_simple_item(wrapper, expr, serializer)
        end
      end
    end
  end

  defp emit_simple_item(wrapper, expr, serializer) do
      case wrapper do
        "ASN1Integer" -> "new ASN1Integer(#{expr} as bigint).serialize(#{serializer})"
        "ASN1Boolean" -> "new ASN1Boolean(#{expr} as boolean).serialize(#{serializer})"
        "ASN1UTF8String" -> "new ASN1UTF8String(#{expr} as string).serialize(#{serializer})"
        "ASN1PrintableString" -> "new ASN1PrintableString(#{expr} as string).serialize(#{serializer})"
        "ASN1IA5String" -> "new ASN1IA5String(#{expr} as string).serialize(#{serializer})"
        "ASN1OctetString" -> "new ASN1OctetString(#{expr} as Uint8Array).serialize(#{serializer})"
        "ASN1BitString" -> "(#{expr} as ASN1BitString).serialize(#{serializer})"
        "ASN1ObjectIdentifier" -> "ASN1ObjectIdentifier.fromComponents((#{expr} as string).split('.').map(BigInt)).serialize(#{serializer})"
        "ASN1Any" -> "#{serializer}.writeNode(#{expr} as ASN1Node)"
        "any" -> "(#{expr} as any)?.serialize ? (#{expr} as any).serialize(#{serializer}) : (#{expr} instanceof ASN1Node ? #{serializer}.writeNode(#{expr}) : undefined)"
        _ -> "(#{expr} as any).serialize(#{serializer})"
      end
  end

  defp emit_simple_item_with_tag(wrapper, expr, serializer, tag) do
      case wrapper do
        "ASN1Integer" -> "new ASN1Integer(#{expr} as bigint).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1Boolean" -> "new ASN1Boolean(#{expr} as boolean).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1UTF8String" -> "new ASN1UTF8String(#{expr} as string).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1PrintableString" -> "new ASN1PrintableString(#{expr} as string).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1IA5String" -> "new ASN1IA5String(#{expr} as string).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1OctetString" -> "new ASN1OctetString(#{expr} as Uint8Array).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1BitString" -> "(#{expr} as ASN1BitString).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1ObjectIdentifier" -> "ASN1ObjectIdentifier.fromComponents((#{expr} as string).split('.').map(BigInt)).serializeWithIdentifier(#{serializer}, #{tag})"
        "ASN1Any" ->
             # For ANY, implicit tagging is ambiguous/hard because ANY preserves its own tag.
             # But if it's IMPLICIT ANY, it means the ANY's tag is REPLACED.
             # But ASN1Node usually has the tag built-in.
             # We might need to construct a new wrapper node.
             # For now, let's treat it as generic serialize, but we might encounter issues.
             # Actually, just use standard serialize for now? Or throw error?
             # Let's try to assume serializeWithIdentifier works if it exists.
             "(#{expr} as any)?.serializeWithIdentifier ? (#{expr} as any).serializeWithIdentifier(#{serializer}, #{tag}) : (#{expr} as any).serialize(#{serializer})"
        "any" -> "(#{expr} as any)?.serializeWithIdentifier ? (#{expr} as any).serializeWithIdentifier(#{serializer}, #{tag}) : (#{expr} instanceof ASN1Node ? #{serializer}.writeNode(#{expr}) : undefined)"
        _ -> "(#{expr} as any).serializeWithIdentifier(#{serializer}, #{tag})"
      end
  end

  defp get_tag_info({:tag, class, num, mode, _inner}) do
    classStr = case class do
      :UNIVERSAL -> "Universal"
      :APPLICATION -> "Application"
      :CONTEXT -> "ContextSpecific"
      :PRIVATE -> "Private"
      _ -> to_string(class) |> String.capitalize()
    end
    mode_norm = case mode do
      :EXPLICIT -> :explicit
      :IMPLICIT -> :implicit
      {:default, :EXPLICIT} -> :explicit
      {:default, :IMPLICIT} -> :implicit
      _ -> :implicit
    end
    {"new ASN1Identifier(#{num}n, TagClass.#{classStr})", mode_norm}
  end
  defp get_tag_info({:type, [tag | _], _inner, _, _, _}), do: get_tag_info(tag)
  defp get_tag_info({:type, [], inner, _, _, _}), do: get_tag_info(inner)
  defp get_tag_info({:pt, root, _}), do: get_tag_info(root)
  defp get_tag_info(type) when is_atom(type) do
    case type do
      :INTEGER -> {nil, :implicit}
      :BOOLEAN -> {nil, :implicit}
      :UTF8String -> {nil, :implicit}
      :PrintableString -> {nil, :implicit}
      :IA5String -> {nil, :implicit}
      :TeletexString -> {nil, :implicit}
      :BMPString -> {nil, :implicit}
      :UniversalString -> {nil, :implicit}
      :GraphicString -> {nil, :implicit}
      :VisibleString -> {nil, :implicit}
      :GeneralString -> {nil, :implicit}
      :NumericString -> {nil, :implicit}
      :T61String -> {nil, :implicit}
      :VideotexString -> {nil, :implicit}
      :"OCTET STRING" -> {nil, :implicit}
      :"BIT STRING" -> {nil, :implicit}
      :"OBJECT IDENTIFIER" -> {nil, :implicit}
      :OBJECT_IDENTIFIER -> {nil, :implicit}
      _ -> {nil, :implicit}
    end
  end
  defp get_tag_info({:"SEQUENCE OF", _}), do: {nil, :implicit}
  defp get_tag_info({:"SET OF", _}), do: {nil, :implicit}
  defp get_tag_info({:Externaltypereference, _, _mod, _type} = ref) do
    {nil, :implicit}
  end
  defp get_tag_info(_), do: {nil, :implicit}

  defp get_tag(type) do
    {tag, _} = get_tag_info(type)
    tag
  end

  defp get_asn1_wrapper({:type, _, inner, _, _, _}, modname), do: get_asn1_wrapper(inner, modname)
  defp get_asn1_wrapper({:tag, _, _, _, inner}, modname), do: get_asn1_wrapper(inner, modname)
  defp get_asn1_wrapper({:pt, root, _}, modname), do: get_asn1_wrapper(root, modname)
  defp get_asn1_wrapper({:"SEQUENCE OF", inner}, modname) do
    get_asn1_wrapper(inner, modname) <> "[]"
  end
  defp get_asn1_wrapper({:"SET OF", inner}, modname) do
    get_asn1_wrapper(inner, modname) <> "[]"
  end
  defp get_asn1_wrapper({:Externaltypereference, _, mod, type}, _) do
    # Map known external type references to basic ASN.1 types
    case {mod, type} do
      {"PKCS-9", "ContentType"} -> "ASN1ObjectIdentifier"
      {"PKCS-9", "MessageDigest"} -> "ASN1OctetString"
      {"PKCS-9", "SigningTime"} -> "ASN1UTCTime"
      {"KEP", "ContentType"} -> "ASN1ObjectIdentifier"
      _ -> substituteType(name(type, mod))
    end
  end
  defp get_asn1_wrapper(type, modname) do
    case type do
      :INTEGER -> "ASN1Integer"
      :BOOLEAN -> "ASN1Boolean"
      :UTF8String -> "ASN1UTF8String"
      :PrintableString -> "ASN1PrintableString"
      :IA5String -> "ASN1IA5String"
      :TeletexString -> "ASN1UTF8String"
      :BMPString -> "ASN1UTF8String"
      :UniversalString -> "ASN1UTF8String"
      :GraphicString -> "ASN1UTF8String"
      :VisibleString -> "ASN1UTF8String"
      :GeneralString -> "ASN1UTF8String"
      :NumericString -> "ASN1PrintableString"
      :T61String -> "ASN1UTF8String"
      :VideotexString -> "ASN1UTF8String"
      :"OCTET STRING" -> "ASN1OctetString"
      :"BIT STRING" -> "ASN1BitString"
      :"OBJECT IDENTIFIER" -> "ASN1ObjectIdentifier"
      :OBJECT_IDENTIFIER -> "ASN1ObjectIdentifier"
      :ANY -> "ASN1Any"
      :"ANY DEFINED BY" -> "ASN1Any"
      :ANY_DEFINED_BY -> "ASN1Any"
      :ENUMERATED -> "ASN1Integer"
      :NULL -> "ASN1Null"
      :GeneralizedTime -> "ASN1UTCTime"
      :UTCTime -> "ASN1UTCTime"
      _ ->
        if is_atom(type) do
          substituteType(name(type, modname))
        else
          "any"
        end
    end
  end

  defp get_asn1_wrapper(str, _) when is_binary(str) do
    case str do
      "Uint8Array" -> "ASN1OctetString"
      "ASN1BitString" -> "ASN1BitString"
      "bigint" -> "ASN1Integer"
      "boolean" -> "ASN1Boolean"
      "string" -> "ASN1UTF8String"
      _ -> str
    end
  end

  defp opt(:OPTIONAL), do: "?"
  defp opt({:DEFAULT, _}), do: "?"
  defp opt(_), do: ""

  defp normalize_ts_name(name, modname) do
    nname = bin(normalizeName(name))
    nmod = bin(normalizeName(modname))

    cond do
      nmod == "" -> nname
      String.starts_with?(nname, nmod <> "_") -> nname
      # If it already has an underscore, it's likely qualified by ANOTHER module
      String.contains?(nname, "_") and not String.starts_with?(nname, nmod) ->
         # Exception: some ASN.1 names have underscores from hyphens, but usually they are local.
         # For now, assume underscore = qualified unless it's the current module.
         nname
      # Hack for ORAddress module mapping issue
      nname == "ORAddress" && nmod == "PKIX1Explicit_2009" -> "PKIX_X400Address_2009_ORAddress"
      true -> nmod <> "_" <> nname
    end
  end

  defp normalize_field_name(name) do
    bin(normalizeName(name))
    |> String.downcase()
  end

end
