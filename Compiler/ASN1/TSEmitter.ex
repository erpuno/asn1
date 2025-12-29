defmodule ASN1.TSEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]

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

  @impl true
  def fileExtension, do: ".ts"

  @impl true
  def builtinType(type) do
    case type do
      :INTEGER -> "number"
      :BOOLEAN -> "boolean"
      :UTF8String -> "string"
      :PrintableString -> "string"
      :IA5String -> "string"
      :"OCTET STRING" -> "ArrayBuffer"
      :"BIT STRING" -> "ArrayBuffer"
      :"OBJECT IDENTIFIER" -> "string"
      :OBJECT_IDENTIFIER -> "string"
      :NULL -> "null"
      :GeneralizedTime -> "Date"
      :UTCTime -> "Date"
      _ -> "any"
    end
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
     t = sequenceOf(name, field, inner)
     "#{t}[]"
  end
  def fieldType(name, field, {:"SET OF", inner}) do
     t = sequenceOf(name, field, inner)
     "#{t}[]"
  end
  def fieldType(name, field, {:"Sequence Of", inner}) do
     t = sequenceOf(name, field, inner)
     "#{t}[]"
  end
  def fieldType(name, field, {:"Set Of", inner}) do
     t = sequenceOf(name, field, inner)
     "#{t}[]"
  end
  def fieldType(_name, _field, {:type, _, inner, _, _, _}) do
    substituteType(inner)
  end
  def fieldType(_name, _field, type) when is_atom(type) do
      substituteType(type)
  end
  def fieldType(_name, _field, {:Externaltypereference, _, mod, type}) do
      name(type, mod)
  end
  def fieldType(_name, _field, _type) do
    "any"
  end

  @impl true
  def array(name, element_type, _tag, level) when level == "top" do
    modname = getEnv(:current_module, "")
    # Force save=true for top-level array definitions because they are exported types
    # But strictly speaking we should check valid save flag from basic.ex pass 3.
    # SwiftEmitter uses save(true, ...). Let's stick to env but default true if missing?
    # Actually basic.ex sets "save" to true in pass 3.
    saveFlag = getEnv(:save, false)
    IO.puts("DEBUG: TSEmitter.array called for #{name} level=#{level} saveFlag=#{saveFlag} mod=#{modname}")

    tsName = name(name, modname)
    setEnv(name, tsName)
    imports = emitImports()

    # We must include the import for the element type if it's not builtin
    # element_type might be "AuthenticationFramework_Extension"
    # We need to extract that name and add import

    field_imports = if not is_builtin?(element_type) do
      "import { #{element_type} } from \"./#{element_type}\";"
    else
      ""
    end

    content = "export type #{tsName} = #{element_type}[];"

    save(saveFlag, modname, tsName, imports <> "\n" <> field_imports <> "\n\n" <> content)
    tsName
  end

  @impl true
  def array(_name, element_type, _tag, _level) do
     # Non-top level (inline) handling
     "#{element_type}[]"
  end

  def sequenceOf(name, field, {:type, _, inner, _, _, _}), do: sequenceOf(name, field, inner)
  def sequenceOf(_name, _field, {:Externaltypereference, _, mod, type}), do: name(type, mod)
  def sequenceOf(_name, _field, type) when is_atom(type), do: substituteType(type)
  def sequenceOf(_name, _field, _), do: "any"

  @impl true
  def sequence(name, fields, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)
    setEnv(:current_struct, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(fields, tsName, modname)

    interfaceDef = """
    export interface #{tsName} {
    #{emitFields(fields, modname)}
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> interfaceDef)
    tsName
  end

  @impl true
  def set(name, fields, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(fields, tsName, modname)

    interfaceDef = """
    export interface #{tsName} {
    #{emitFields(fields, modname)}
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> interfaceDef)
    tsName
  end

  @impl true
  def choice(name, cases, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()
    type_imports = emitTypeImports(cases, tsName, modname)

    # For CHOICE, we can just make a union of types with optional fields or a single object with all optional
    # For now, following the interface pattern where all fields are optional is the safest specific representation
    interfaceDef = """
    export interface #{tsName} {
    #{emitChoiceFields(cases, modname)}
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> type_imports <> "\n\n" <> interfaceDef)
    tsName
  end

  @impl true
  def enumeration(name, cases, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()

    entries = cases
    |> Enum.filter(fn
        {:NamedNumber, _, _} -> true
        _ -> false
       end)
    |> Enum.map(fn {:NamedNumber, ident, val} ->
        "  #{ident} = #{val},"
       end)
    |> Enum.join("\n")

    enumDef = """
    export enum #{tsName} {
    #{entries}
    }
    """

    save(saveFlag, modname, tsName, imports <> "\n" <> enumDef)
    tsName
  end

  @impl true
  def integerEnum(name, cases, modname, saveFlag), do: enumeration(name, cases, modname, saveFlag)

  @impl true
  def substituteType(type) do
     builtinType(type)
  end

  @impl true
  def tagClass(_tag), do: ""

  @impl true
  def typealias(name, target, modname, saveFlag) do
    tsName = name(name, modname)
    setEnv(name, tsName)

    imports = emitImports()

    content = "export type #{tsName} = #{substituteType(target)};"

    save(saveFlag, modname, tsName, imports <> "\n" <> content)
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

    interfaceDef = """
    export interface #{tsName} {
      algorithm: string;
      parameters?: ArrayBuffer;
    }
    """
    save(saveFlag, modname, tsName, imports <> "\n" <> interfaceDef)
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
    {Integer.to_string(val), ""}
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
          {:Externaltypereference, _, mod, type} -> name(type, mod)
          {:type, _, inner, _, _, _} -> extract_type_ref(inner, modname)
          _ -> nil
         end)
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(fn t -> t == current_struct_name || is_builtin?(t) end)
      |> Enum.uniq()
      |> Enum.map(fn t -> "import { #{t} } from \"./#{t}\";" end)
      |> Enum.join("\n")
  end

  defp extract_type_ref({:Externaltypereference, _, mod, type}, _), do: name(type, mod)
  defp extract_type_ref({:type, _, inner, _, _, _}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"SEQUENCE OF", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"SET OF", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"Sequence Of", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref({:"Set Of", inner}, modname), do: extract_type_ref(inner, modname)
  defp extract_type_ref(_, _), do: nil

  defp is_builtin?(name) do
      name in ["number", "boolean", "string", "ArrayBuffer", "Uint8Array", "any", "Date", "null"]
  end

  defp emitImports do
    ""
  end

  defp emitChoiceFields(fields, modname) do
    Enum.map(fields, fn
      {:ComponentType, _, name, type, _optional, _, _} ->
        fieldName = fieldName(name)
        tsType = to_ts_type(type, modname)

        # CHOICE fields are always optional in the interface because only one matches
        "  #{fieldName}?: #{tsType};"
      _ -> ""
    end)
    |> Enum.join("\n")
  end
  defp emitFields(fields, modname) do
    Enum.map(fields, fn
      {:ComponentType, _, name, type, optional, _, _} ->
        fieldName = fieldName(name)
        tsType = to_ts_type(type, modname)

        "  #{fieldName}#{opt(optional)}: #{tsType};"
      _ -> ""
    end)
    |> Enum.join("\n")
  end

  defp to_ts_type({:type, _, inner, _, _, _}, modname), do: to_ts_type(inner, modname)
  defp to_ts_type({:Externaltypereference, _, mod, type}, _), do: name(type, mod)
  defp to_ts_type({:"SEQUENCE OF", inner}, modname), do: "#{to_ts_type(inner, modname)}[]"
  defp to_ts_type({:"SET OF", inner}, modname), do: "#{to_ts_type(inner, modname)}[]"
  defp to_ts_type(atom, _) when is_atom(atom), do: builtinType(atom)
  defp to_ts_type(_, _), do: "any"

  defp opt(:OPTIONAL), do: "?"
  defp opt({:DEFAULT, _}), do: "?"
  defp opt(_), do: ""

  defp normalize_ts_name(name, modname) do
    nname = bin(normalizeName(name))
    nmod = bin(normalizeName(modname))
    if String.starts_with?(nname, nmod) do
      nname
    else
      nmod <> "_" <> nname
    end
  end

  defp normalize_field_name(name) do
    bin(normalizeName(name))
    |> String.downcase()
  end

end
