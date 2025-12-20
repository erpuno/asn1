defmodule ASN1.GoEmitter do
  @behaviour ASN1.Emitter
  import ASN1,
    only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, setEnvGlobal: 2, print: 2, save: 4]

  @reserved_words ~w(break default func interface select case defer go map struct chan else goto package switch const fallthrough if range type continue for import return var)

  def fileExtension, do: ".go"

  defp registry_file, do: "priv/go_registry.etf"

  defp load_registry do
    case File.read(registry_file()) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> %{modules: %{}, packages: %{}}
    end
  end

  defp save_registry(reg) do
    File.write(registry_file(), :erlang.term_to_binary(reg))
  end

  defp register_module(mod, pkg, base) do
    reg = load_registry()
    modules = Map.put(reg.modules, bin(mod), base)
    # Note: simple package mapping might be ambiguous if multiple bases define same package
    # but we use it as fallback.
    packages = Map.put(reg.packages, pkg, base)
    save_registry(%{reg | modules: modules, packages: packages})
  end

  defp lookup_base(mod, pkg) do
    reg = load_registry()
    Map.get(reg.modules, bin(mod)) || Map.get(reg.packages, pkg)
  end

  defp add_import(pkg, mod \\ nil) do
    current_pkg = Process.get(:current_pkg, "")

    if pkg != "" do
      # If pkg contains a dot (e.g. "dstu.Type"), we only want "dstu"
      actual_pkg =
        case String.split(pkg, ".") do
          [p, _] -> p
          _ -> pkg
        end

      # Strip 'chat/' prefix if it's already there to avoid double prefix (legacy support)
      clean_pkg =
        if String.starts_with?(actual_pkg, "chat/") do
          String.replace_prefix(actual_pkg, "chat/", "")
        else
          actual_pkg
        end

      # Also normalize case for comparison if needed, though module_package does downcase
      clean_pkg = String.downcase(clean_pkg)
      current_pkg = String.downcase(current_pkg)

      if clean_pkg != "" and clean_pkg != current_pkg and not String.contains?(clean_pkg, "*") do
        # Resolve base
        base =
          if mod do
            lookup_base(mod, clean_pkg)
          else
            lookup_base(nil, clean_pkg)
          end

        # Fallback to current output or default "chat" if not found
        final_base = base || System.get_env("ASN1_OUTPUT") || "chat"

        imports = Process.get(:go_imports, MapSet.new())
        # Store {pkg, base} tuple
        Process.put(:go_imports, MapSet.put(imports, {clean_pkg, final_base}))
      else
        if clean_pkg == current_pkg and clean_pkg != "" do
          # IO.inspect({:skipping_self_import, clean_pkg, actual_pkg, pkg})
        end
      end
    end
  end

  defp get_imports do
    Process.get(:go_imports, MapSet.new()) |> MapSet.to_list() |> Enum.sort()
  end

  defp clear_imports do
    Process.put(:go_imports, MapSet.new())
  end

  # Go-specific type lookups - map ASN.1 type names to valid Go types
  defp go_lookup("ASN1ObjectIdentifier"), do: "asn1.ObjectIdentifier"
  defp go_lookup("DSTUAlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("ASN1Any"), do: "asn1.RawValue"
  defp go_lookup("PKIX1Implicit_2009_GeneralNames"), do: "asn1.RawValue"
  defp go_lookup("LDAPAttribute"), do: "asn1.RawValue"
  defp go_lookup("InformationFrameworkMAPPINGBASEDMATCHING"), do: "asn1.RawValue"
  defp go_lookup("X2009AttributeType"), do: "asn1.ObjectIdentifier"
  defp go_lookup("TeletexString"), do: "asn1.RawValue"
  defp go_lookup("VisibleString"), do: "asn1.RawValue"
  defp go_lookup("GeneralString"), do: "asn1.RawValue"
  defp go_lookup("REAL"), do: "float64"
  defp go_lookup("AuthenticationFramework_AlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("X62AlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("X2009AlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("X7AlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("PKIX1Explicit88Extensions"), do: "[]asn1.RawValue"
  defp go_lookup("PKIX1Explicit88CertificateList"), do: "asn1.RawValue"
  defp go_lookup("PKIX1Explicit88Certificate"), do: "asn1.RawValue"
  defp go_lookup("AttributesCharacterAttributes"), do: "asn1.RawValue"
  defp go_lookup("DescriptorDateAndTime"), do: "asn1.RawValue"
  defp go_lookup("X7Attribute"), do: "asn1.RawValue"
  defp go_lookup("UnitsTextUnit"), do: "asn1.RawValue"
  defp go_lookup("DescriptorsLayoutStyleDescriptor"), do: "asn1.RawValue"
  defp go_lookup("DescriptorsLinkClassDescriptor"), do: "asn1.RawValue"
  defp go_lookup("DescriptorsLinkDescriptor"), do: "asn1.RawValue"
  defp go_lookup("DescriptorsPresentationStyleDescriptor"), do: "asn1.RawValue"
  defp go_lookup("SubprofilesSubprofileDescriptor"), do: "asn1.RawValue"
  defp go_lookup("X2010Time"), do: "asn1.RawValue"
  defp go_lookup("X2009AttributeCertificate"), do: "asn1.RawValue"
  # Actual ASN.1 type names (before module prefix is added)
  defp go_lookup("AlgorithmIdentifier"), do: "asn1.RawValue"
  defp go_lookup("Attribute"), do: "asn1.RawValue"
  defp go_lookup("GeneralNames"), do: "asn1.RawValue"
  defp go_lookup("MAPPING-BASED-MATCHING"), do: "asn1.RawValue"
  defp go_lookup("AttributeType"), do: "asn1.ObjectIdentifier"
  defp go_lookup("AttributeSet"), do: "asn1.RawValue"
  defp go_lookup("SubjectPublicKeyInfo"), do: "asn1.RawValue"
  defp go_lookup("X2009SubjectPublicKeyInfo"), do: "asn1.RawValue"
  defp go_lookup("X2009CertificateList"), do: "asn1.RawValue"
  defp go_lookup("X2009Certificate"), do: "asn1.RawValue"
  defp go_lookup("DirectoryAbstractServiceTime"), do: "time.Time"
  defp go_lookup("DSTUCertificate"), do: "asn1.RawValue"
  defp go_lookup("AuthenticationFramework_IssuerSerial"), do: "asn1.RawValue"
  defp go_lookup("Certificate"), do: "asn1.RawValue"
  defp go_lookup("CertificateList"), do: "asn1.RawValue"
  defp go_lookup("Time"), do: "time.Time"
  defp go_lookup("IssuerSerial"), do: "asn1.RawValue"
  defp go_lookup(_), do: nil

  def emitHeader(modname) do
    pkg = module_package(modname)
    Process.put(:current_pkg, pkg)

    pkg_name = System.get_env("ASN1_OUTPUT")

    if pkg_name do
      register_module(modname, pkg, pkg_name)
    end

    extra_imports =
      get_imports()
      |> Enum.map(fn
        {p, base} -> "    \"tobirama/#{base}/#{p}\""
        p -> "    \"tobirama/#{pkg_name}/#{p}\""
      end)
      |> Enum.join("\n")

    """
    package #{pkg}

    import (
        "encoding/asn1"
        "time"
    #{extra_imports}
    )

    var _ = asn1.RawValue{}
    var _ = time.Time{}
    var _ = asn1.ObjectIdentifier{}

    """
  end

  def module_package(modname) do
    case bin(modname) do
      "AuthenticationFramework" ->
        "x500"

      "CertificateExtensions" ->
        "x500"

      "InformationFramework" ->
        "x500"

      "SelectedAttributeTypes" ->
        "x500"

      "DirectoryAbstractService" ->
        "x500"

      "UsefulDefinitions" ->
        "x500"

      "DSTU" ->
        "dstu"

      "ColourAttributes" ->
        "docprofile"

      "Colour-Attributes" ->
        "docprofile"

      "LayoutDescriptors" ->
        "docprofile"

      "Layout-Descriptors" ->
        "docprofile"

      "DocumentProfileDescriptor" ->
        "docprofile"

      "Document-Profile-Descriptor" ->
        "docprofile"

      "StyleDescriptors" ->
        "docprofile"

      "Style-Descriptors" ->
        "docprofile"

      "LogicalDescriptors" ->
        "docprofile"

      "Logical-Descriptors" ->
        "docprofile"

      _ ->
        modname
        |> normalizeName()
        |> String.replace(~r/[^a-zA-Z0-9]/, "")
        |> String.downcase()
    end
  end

  def name(name, modname) do
    mod = bin(modname)

    prefix =
      case mod |> normalizeName() |> String.split("_", trim: true) do
        [] -> ""
        parts -> List.last(parts)
      end

    n = bin(name) |> String.replace("-", "_")

    if prefix != "" and String.starts_with?(n, prefix) do
      pascal(n)
    else
      pascal(prefix <> "_" <> n)
    end
  end

  defp pascal(name) do
    res =
      name
      |> bin()
      |> normalizeName()
      |> String.split(["_", "-", " "], trim: true)
      |> Enum.map(fn s ->
        {first, rest} = String.split_at(s, 1)
        String.upcase(first) <> rest
      end)
      |> Enum.join("")

    if res != "" and String.match?(String.at(res, 0), ~r/[0-9]/) do
      "X" <> res
    else
      res
    end
  end

  def fieldName(name) do
    name
    |> pascal()
    |> escape_reserved()
  end

  defp escape_reserved(name) do
    if name in @reserved_words do
      name <> "_"
    else
      name
    end
  end

  def substituteType(type) do
    type_str = bin(type)

    case type_str do
      "OCTET STRING" -> mapBuiltin(:"OCTET STRING")
      "BIT STRING" -> mapBuiltin(:"BIT STRING")
      "INTEGER" -> mapBuiltin(:INTEGER)
      "BOOLEAN" -> mapBuiltin(:BOOLEAN)
      "OBJECT IDENTIFIER" -> mapBuiltin(:"OBJECT IDENTIFIER")
      "NULL" -> mapBuiltin(:NULL)
      "ANY" -> mapBuiltin(:ANY)
      "UTF8String" -> mapBuiltin(:UTF8String)
      "PrintableString" -> mapBuiltin(:PrintableString)
      "IA5String" -> mapBuiltin(:IA5String)
      "GeneralizedTime" -> mapBuiltin(:GeneralizedTime)
      "UTCTime" -> mapBuiltin(:UTCTime)
      "AlgorithmIdentifier" -> mapBuiltin(:AlgorithmIdentifier)
      _ -> type
    end
  end

  def fieldType(name, field, other) when is_tuple(other) do
    case other do
      {:type, _, inner, _, _, _} ->
        fieldType(name, field, inner)

      {:"SEQUENCE OF", type} ->
        "[]" <> fieldType(name, field, type)

      {:"SET OF", type} ->
        "[]" <> fieldType(name, field, type)

      {:CHOICE, _} ->
        # Inline CHOICE types are represented as asn1.RawValue
        "asn1.RawValue"

      {:SEQUENCE, _, _, _, _} ->
        # Inline SEQUENCE types are represented as asn1.RawValue
        "asn1.RawValue"

      {:SET, _, _, _, _} ->
        # Inline SET types are represented as asn1.RawValue
        "asn1.RawValue"

      {:ENUMERATED, _} ->
        # Inline ENUMERATED types are represented as int
        "int"

      {:"BIT STRING", _} ->
        "asn1.BitString"

      {:"OCTET STRING", _} ->
        "[]byte"

      {:INTEGER, _} ->
        "int64"

      {:ANY_DEFINED_BY, _} ->
        "asn1.RawValue"

      {:"INSTANCE OF", _, _} ->
        "asn1.RawValue"

      {:Externaltypereference, _, mod, type} ->
        # First check if go_lookup has a mapping for this type
        lookup_result = go_lookup(bin(type))

        if lookup_result do
          # go_lookup found a mapping - use it directly
          lookup_result
        else
          current_mod = getEnv(:current_module, "")

          if bin(mod) != "" and bin(mod) != bin(current_mod) do
            target_pkg = module_package(mod)
            current_pkg = module_package(current_mod)

            if target_pkg != current_pkg do
              add_import(target_pkg, mod)
              target_pkg <> "." <> name(type, mod)
            else
              name(type, mod)
            end
          else
            res = go_lookup(bin(type)) || ASN1.lookup(bin(type))

            if is_binary(res) do
              # If lookup returned a package-qualified name like "chat/dstu.Type",
              # we need to ensure the import is added and only the 'pkg.Type' part is used.
              case String.split(res, "/") do
                [pkg_with_type] ->
                  case String.split(pkg_with_type, ".") do
                    [pkg, t] ->
                      p = if String.starts_with?(pkg, "chat/"), do: pkg, else: "chat/" <> pkg
                      # But we only want to add_import with the part relative to tobirama/chat/
                      # So if pkg is already mapped, we should be careful.
                      add_import(pkg, mod)
                      pkg <> "." <> t

                    _ ->
                      res
                  end

                parts ->
                  # e.g ["chat", "dstu.Type"]
                  last = List.last(parts)

                  case String.split(last, ".") do
                    [pkg, t] ->
                      # Already has 'chat' in it?
                      full_pkg_path = parts |> Enum.drop(-1) |> Enum.join("/") |> Path.join(pkg)

                      import_path =
                        if String.starts_with?(full_pkg_path, "chat/") do
                          String.replace_prefix(full_pkg_path, "chat/", "")
                        else
                          full_pkg_path
                        end

                      add_import(import_path, mod)
                      pkg <> "." <> t

                    _ ->
                      res
                  end
              end
            else
              name(res, mod)
            end
          end
        end

      {:ObjectClassFieldType, _, _class, [{:valuefieldreference, :id}], _} ->
        "asn1.ObjectIdentifier"

      {:ObjectClassFieldType, _, _class, _field, _} ->
        "asn1.RawValue"

      {:CHOICE, _} ->
        name("#{field}_choice", name)

      {:SEQUENCE, _, _, _, _} ->
        name("#{field}_sequence", name)

      {:SET, _, _, _, _} ->
        name("#{field}_set", name)

      {:Externaltypereference, _, _mod, :"TYPE-IDENTIFIER"} ->
        "asn1.RawValue"

      {:type, _, :CHOICE, cases, _, _} ->
        # Generate CHOICE as asn1.RawValue for now
        "asn1.RawValue"

      {:type, _, :SEQUENCE, components, _, _} ->
        # Generate SEQUENCE as asn1.RawValue for now or try to yield it
        "asn1.RawValue"

      {:type, _, :SET, components, _, _} ->
        "asn1.RawValue"

      _ ->
        "asn1.RawValue"
    end
  end

  defp resolve_type_name(type_name) do
    # 1. Direct go_lookup (e.g. if type_name itself is mapped)
    case go_lookup(type_name) do
      nil ->
        # 2. Lookup original ASN.1 name
        orig = getEnv("meta_orig_" <> type_name, nil)

        mapped = if orig, do: go_lookup(orig), else: nil

        if mapped do
          mapped
        else
          # 3. Resolve module and qualify
          target_mod = getEnv("meta_mod_" <> type_name, nil)
          current_mod = getEnv(:current_module, "")

          if target_mod && target_mod != current_mod do
            target_pkg = module_package(target_mod)
            current_pkg = module_package(current_mod)

            if target_pkg != current_pkg do
              add_import(target_pkg, target_mod)
              # Use the type name (which is the Go name)
              target_pkg <> "." <> type_name
            else
              type_name
            end
          else
            type_name
          end
        end

      mapped ->
        mapped
    end
  end

  def fieldType(_name, _field, atom) when is_atom(atom) do
    res = mapBuiltin(atom)
    if is_binary(res), do: resolve_type_name(res), else: name(res, "")
  end

  def fieldType(_name, _field, other) when is_binary(other) do
    resolve_type_name(other)
  end

  def fieldType(name, field, other), do: inspect({name, field, other})

  def mapBuiltin(:"OBJECT IDENTIFIER"), do: "asn1.ObjectIdentifier"
  def mapBuiltin(:"OCTET STRING"), do: "[]byte"
  def mapBuiltin(:"BIT STRING"), do: "asn1.BitString"
  def mapBuiltin(:BOOLEAN), do: "bool"
  def mapBuiltin(:INTEGER), do: "int64"
  def mapBuiltin(:ENUMERATED), do: "int"
  def mapBuiltin(:NULL), do: "asn1.RawValue"
  def mapBuiltin(:ANY), do: "asn1.RawValue"
  def mapBuiltin(:UTF8String), do: "string"
  def mapBuiltin(:PrintableString), do: "string"
  def mapBuiltin(:NumericString), do: "string"
  def mapBuiltin(:IA5String), do: "string"
  def mapBuiltin(:GeneralizedTime), do: "time.Time"
  def mapBuiltin(:UTCTime), do: "time.Time"
  def mapBuiltin(:ASN1Any), do: "asn1.RawValue"
  def mapBuiltin(:AlgorithmIdentifier), do: "asn1.RawValue"
  def mapBuiltin(:TeletexString), do: "asn1.RawValue"
  def mapBuiltin(:VisibleString), do: "asn1.RawValue"
  def mapBuiltin(:GeneralString), do: "asn1.RawValue"
  def mapBuiltin(:REAL), do: "float64"
  def mapBuiltin(:EXTERNAL), do: "asn1.RawValue"
  def mapBuiltin(other) when is_atom(other), do: go_lookup(bin(other)) || ASN1.lookup(bin(other))
  def mapBuiltin(other), do: inspect(other)

  def array(name, type, tag, _level) do
    clear_imports()
    modname = getEnv(:current_module, "")
    goName = name(name, modname)
    setEnv(name, goName)
    if tag == :set, do: setEnv("#{name}_is_set", true)

    # Check go_lookup for the element type
    element_type = resolve_type_name(bin(type))

    body = "type #{goName} []#{element_type}"
    header = emitHeader(modname)

    save(true, modname, goName, header <> body <> "\n")
    goName
  end

  def sequence(name, fields, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)
    setEnv(name, goName)
    struct_body = emit_struct(goName, fields, modname)
    header = emitHeader(modname)

    save(saveFlag, modname, goName, header <> struct_body <> "\n")
  end

  defp emit_struct(goName, fields, modname) do
    body =
      fields
      |> Enum.map(fn
        {:ComponentType, _, field_name, type, _optional, _, _} = component ->
          maybe_emit_nested_type(goName, field_name, type, modname)
          go_field = fieldName(field_name)
          go_type = fieldType(goName, field_name, type)
          tags = emit_tags(component)
          tag_str = if tags != "", do: " `#{tags}`", else: ""
          "    #{go_field} #{go_type}#{tag_str}"

        _ ->
          ""
      end)
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

    "type #{goName} struct {\n#{body}\n}"
  end

  defp emit_tags({:ComponentType, _, _, type_ast, optional, _, _}) do
    {_type, attrs, inner, _, _, _} =
      case type_ast do
        {:type, _, _, _, _, _} -> type_ast
        _ -> {:type, [], type_ast, [], [], :no}
      end

    tags = []

    # Handle optional
    tags = if optional == :OPTIONAL, do: ["optional" | tags], else: tags

    # Handle SET
    tags =
      case inner do
        {:"SET OF", _} ->
          ["set" | tags]

        {:SET, _, _, _, _} ->
          ["set" | tags]

        {:Externaltypereference, _, _, ref_name} ->
          if getEnv("#{ref_name}_is_set", false), do: ["set" | tags], else: tags

        _ ->
          tags
      end

    # Handle tagging
    tags =
      Enum.reduce(attrs, tags, fn
        {:tag, class, num, mode, _}, acc ->
          acc = ["tag:#{num}" | acc]
          acc = if class == :APPLICATION, do: ["application" | acc], else: acc
          acc = if class == :PRIVATE, do: ["private" | acc], else: acc
          acc = if mode == :EXPLICIT, do: ["explicit" | acc], else: acc
          acc

        _, acc ->
          acc
      end)

    case tags do
      [] -> ""
      list -> "asn1:\"#{Enum.join(Enum.reverse(list), ",")}\""
    end
  end

  defp maybe_emit_nested_type(
         struct_name,
         field_name,
         {:SEQUENCE, _, _, _, fields} = seq,
         modname
       ) do
    nested_name = fieldType(struct_name, field_name, seq)
    sequence(nested_name, fields, modname, true)
  end

  defp maybe_emit_nested_type(struct_name, field_name, {:SET, _, _, _, fields} = set_def, modname) do
    nested_name = fieldType(struct_name, field_name, set_def)
    set(nested_name, fields, modname, true)
  end

  defp maybe_emit_nested_type(struct_name, field_name, {:CHOICE, cases} = choice_def, modname) do
    nested_name = fieldType(struct_name, field_name, choice_def)
    choice(nested_name, cases, modname, true)
  end

  defp maybe_emit_nested_type(struct_name, field_name, {:ENUMERATED, cases} = enum_def, modname) do
    nested_name = fieldType(struct_name, field_name, enum_def)
    enumeration(nested_name, cases, modname, true)
  end

  defp maybe_emit_nested_type(
         struct_name,
         field_name,
         {:"SEQUENCE OF", {:type, _, inner, _, _, _}},
         modname
       ) do
    maybe_emit_nested_type(struct_name, field_name, inner, modname)
  end

  defp maybe_emit_nested_type(
         struct_name,
         field_name,
         {:"SET OF", {:type, _, inner, _, _, _}},
         modname
       ) do
    maybe_emit_nested_type(struct_name, field_name, inner, modname)
  end

  defp maybe_emit_nested_type(_struct_name, _field_name, _type, _modname), do: :ok

  def set(name, fields, modname, saveFlag), do: sequence(name, fields, modname, saveFlag)

  def choice(name, _cases, modname, saveFlag) do
    clear_imports()
    # Go encoding/asn1 doesn't have a direct CHOICE representation.
    # Usually it's handled via asn1.RawValue or a struct where only one field is non-nil.
    # For now, let's use a struct with asn1.RawValue to keep it simple and safe.
    goName = name(name, modname)
    setEnv(name, goName)

    header = emitHeader(modname)
    body = "type #{goName} asn1.RawValue"

    save(saveFlag, modname, goName, header <> body <> "\n")
  end

  def enumeration(name, cases, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)
    setEnv(name, goName)

    variants =
      cases
      |> Enum.map(fn
        {:NamedNumber, n, v} ->
          var_name = goName <> pascal(n)
          "    #{var_name} #{goName} = #{v}"

        {n, v} ->
          var_name = goName <> pascal(n)
          "    #{var_name} #{goName} = #{v}"

        _ ->
          ""
      end)
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

    header = emitHeader(modname)

    body = """
    type #{goName} int

    const (
    #{variants}
    )
    """

    save(saveFlag, modname, goName, header <> body <> "\n")
  end

  def integerEnum(name, cases, modname, saveFlag), do: enumeration(name, cases, modname, saveFlag)

  def sequenceOf(_name, _field, type) do
    sub = substituteType(type)
    element_type = if sub != type, do: sub, else: resolve_type_name(bin(type))
    "[]" <> element_type
  end

  def tagClass(_tag), do: ""

  def typealias(name, target, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)
    setEnv(name, goName)

    # First check go_lookup for the target type
    resolved_target = resolve_type_name(bin(target))

    # Sanitize resolved_target - map ASN.1 class names to valid Go types
    sanitized_target =
      cond do
        resolved_target == "TYPE-IDENTIFIER" -> "asn1.RawValue"
        resolved_target == "AlgorithmIdentifier" -> "asn1.RawValue"
        String.ends_with?(resolved_target, "AlgorithmIdentifier") -> "asn1.RawValue"
        resolved_target == "ABSTRACT-SYNTAX" -> "asn1.RawValue"
        resolved_target == "ATTRIBUTE" -> "asn1.RawValue"
        resolved_target == "MATCHING-RULE" -> "asn1.RawValue"
        resolved_target == "OBJECT-CLASS" -> "asn1.RawValue"
        resolved_target == "OTHER-NAME" -> "asn1.RawValue"
        is_binary(resolved_target) and String.contains?(resolved_target, "-") -> "asn1.RawValue"
        true -> resolved_target
      end

    header = emitHeader(modname)
    body = "type #{goName} #{sanitized_target}"

    save(saveFlag, modname, goName, header <> body)
  end

  def value(name, {:type, _, :"OBJECT IDENTIFIER", _, _, _}, val, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)
    components = extractOIDList(val)
    oid_str = Enum.join(components, ", ")

    header = emitHeader(modname)
    body = "var #{goName} = asn1.ObjectIdentifier{#{oid_str}}"

    save(saveFlag, modname, goName, header <> body <> "\n")
  end

  def value(name, _type, val, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)

    header = emitHeader(modname)
    body = "const #{goName} = #{inspect(val)}"

    save(saveFlag, modname, goName, header <> body <> "\n")
  end

  defp extractOIDList(val) do
    list = if is_list(val), do: val, else: [val]

    Enum.flat_map(list, fn x ->
      resolveOIDComponent(x)
    end)
  end

  defp resolveOIDComponent({:NamedNumber, _, val}), do: resolveOIDComponent(val)

  defp resolveOIDComponent({tag, val}) when is_tuple(tag) do
    resolveOIDComponent(tag) ++ resolveOIDComponent(val)
  end

  defp resolveOIDComponent({:seqtag, _, _mod, _name}) do
    # For seqtag, we try to resolve it to its numeric value if possible
    # but based on the error, it seems 'inspect' was used.
    # We should avoid returning the raw tuple.
    []
  end

  defp resolveOIDComponent({:Externalvaluereference, _, _, :"joint-iso-itu-t"}), do: ["2"]
  defp resolveOIDComponent({:Externalvaluereference, _, _, :"joint-iso-ccitt"}), do: ["2"]
  defp resolveOIDComponent({:Externalvaluereference, _, _, :iso}), do: ["1"]
  defp resolveOIDComponent({:Externalvaluereference, _, _, :"itu-t"}), do: ["0"]
  defp resolveOIDComponent({:Externalvaluereference, _, _, :ccitt}), do: ["0"]

  defp resolveOIDComponent({:Externalvaluereference, _, _mod, name}) do
    val = to_string(name)
    # Only return the value if it's a pure integer, otherwise skip it
    case Integer.parse(val) do
      {_, ""} -> [val]
      # Skip non-numeric values like 'id-ce'
      _ -> []
    end
  end

  defp resolveOIDComponent(:"joint-iso-itu-t"), do: ["2"]
  defp resolveOIDComponent(:"joint-iso-ccitt"), do: ["2"]
  defp resolveOIDComponent(:iso), do: ["1"]
  defp resolveOIDComponent(:"itu-t"), do: ["0"]
  defp resolveOIDComponent(:ccitt), do: ["0"]

  defp resolveOIDComponent(val) when is_atom(val) do
    str = to_string(val)

    case Integer.parse(str) do
      {_, ""} -> [str]
      # Skip non-numeric values
      _ -> []
    end
  end

  defp resolveOIDComponent(val) when is_integer(val), do: [to_string(val)]

  defp resolveOIDComponent(val) do
    str = to_string(val)

    case Integer.parse(str) do
      {_, ""} -> [str]
      # Skip non-numeric values
      _ -> []
    end
  end

  def builtinType(type), do: mapBuiltin(type)

  def algorithmIdentifierClass(className, modname, saveFlag) do
    clear_imports()
    header = emitHeader(modname)

    body = """
    type #{className} struct {
        Algorithm asn1.ObjectIdentifier
        Parameters asn1.RawValue `asn1:"optional"`
    }
    """

    save(saveFlag, modname, className, header <> body <> "\n")
  end

  def integerValue(name, {:Externalvaluereference, _, ext_mod, ext_val}, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)
    valName = name(ext_val, ext_mod)

    header = emitHeader(modname)
    body = "const #{goName} = #{valName}"

    save(saveFlag, modname, goName, header <> body <> "\n")
  end

  def integerValue(name, val, modname, saveFlag) do
    clear_imports()
    goName = name(name, modname)

    header = emitHeader(modname)
    body = "const #{goName} = #{val}"

    save(saveFlag, modname, goName, header <> body <> "\n")
  end
end
