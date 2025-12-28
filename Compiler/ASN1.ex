defmodule ASN1 do
  def emitter() do
    case :application.get_env(:asn1scg, :lang, "swift") do
      "swift" -> ASN1.SwiftEmitter
      "go" -> ASN1.GoEmitter
      "rust" -> ASN1.RustEmitter
      "kotlin" -> ASN1.KotlinEmitter
      "c99" -> ASN1.C99Emitter
      _ -> ASN1.SwiftEmitter
    end
  end

  def name(n, m), do: emitter().name(n, m)
  def fieldName(n), do: emitter().fieldName(n)
  def fieldType(name, field, type), do: emitter().fieldType(name, field, type)
  def array(name, type, tag, level \\ ""), do: emitter().array(name, type, tag, level)
  def sequence(name, fields, modname, save), do: emitter().sequence(name, fields, modname, save)
  def set(name, fields, modname, save), do: emitter().set(name, fields, modname, save)
  def choice(name, cases, modname, save), do: emitter().choice(name, cases, modname, save)

  def enumeration(name, cases, modname, save),
    do: emitter().enumeration(name, cases, modname, save)

  def integerEnum(name, cases, modname, save),
    do: emitter().integerEnum(name, cases, modname, save)

  def substituteType(type), do: emitter().substituteType(type)
  def tagClass(tag), do: emitter().tagClass(tag)

  def value(name, type, val, modname, saveFlag),
    do: emitter().value(name, type, val, modname, saveFlag)

  def typealias(name, target, modname, save), do: emitter().typealias(name, target, modname, save)
  def builtinType(type), do: emitter().builtinType(type)

  def print(format, params) do
    if getEnv(:verbose, false), do: :io.format(format, params)
  end

  def sequenceOf(name, field, type), do: emitter().sequenceOf(name, field, type)

  def dump() do
    :lists.foldl(
      fn
        {{:array, x}, {tag, y}}, _ -> print("env array: ~ts = [~ts] ~tp ~n", [x, y, tag])
        {x, y}, _ when is_binary(x) -> print("env alias: ~ts = ~ts ~n", [x, y])
        {{:type, x}, _}, _ -> print("env type: ~ts = ... ~n", [x])
        _, _ -> :ok
      end,
      [],
      :lists.sort(:application.get_all_env(:asn1scg))
    )
  end

  def compile() do
    {:ok, f} = :file.list_dir(inputDir())
    :io.format("F: ~p~n", [f])
    files = :lists.filter(fn x -> String.ends_with?(to_string(x), ".asn1") end, f)
    setEnv(:save, false)
    :lists.map(fn file -> compile(false, inputDir() <> to_string(file)) end, files)
    setEnv(:save, false)
    :lists.map(fn file -> compile(false, inputDir() <> to_string(file)) end, files)
    setEnv(:save, true)
    :lists.map(fn file -> compile(true, inputDir() <> to_string(file)) end, files)
    print("inputDir: ~ts~n", [inputDir()])
    print("outputDir: ~ts~n", [outputDir()])
    print("coverage: ~tp~n", [coverage()])
    dump()
    emitter().finalize()
    :ok
  end

  def coverage() do
    :lists.map(
      fn x -> :application.get_env(:asn1scg, {:trace, x}, []) end,
      :lists.seq(1, 30)
    )
  end

  def compile(save, file) do
    tokens = :asn1ct_tok.file(file)
    {:ok, mod} = :asn1ct_parser2.parse(file, tokens)
    {:module, pos, modname, defid, tagdefault, exports, imports, _, declarations} = mod
    setEnv(:current_module, modname)

    # Store TagDefault for emitters
    case tagdefault do
      {:DefaultTag, :EXPLICIT} -> setEnv(:current_module_tag_default, :EXPLICIT)
      {:DefaultTag, :IMPLICIT} -> setEnv(:current_module_tag_default, :IMPLICIT)
      {:DefaultTag, :AUTOMATIC} -> setEnv(:current_module_tag_default, :AUTOMATIC)
      _ -> setEnv(:current_module_tag_default, :EXPLICIT) # Default to Explicit if not specified
    end

    # Pre-pass: Register all defined types to support forward references
    :lists.map(
      fn
        {:typedef, _, _, name, _} ->
          swiftName = name(name, modname)
          setEnv(name, swiftName)
          # Metadata for resolution
          setEnvGlobal("meta_mod_" <> swiftName, modname)
          setEnvGlobal("meta_orig_" <> swiftName, bin(name))

        {:ptypedef, _, _, name, _args, _} ->
          swiftName = name(name, modname)
          setEnv(name, swiftName)
          # Metadata for resolution
          setEnvGlobal("meta_mod_" <> swiftName, modname)
          setEnvGlobal("meta_orig_" <> swiftName, bin(name))

        {:valuedef, _, _, name, _, _, _} ->
          swiftName = name(name, modname)
          setEnv(name, swiftName)

        _ ->
          :ok
      end,
      declarations
    )

    # Process imports to register external types
    real_imports =
      case imports do
        {:imports, i} -> i
        i when is_list(i) -> i
        _ -> []
      end

    :io.format("Processing imports for ~p: ~p~n", [modname, real_imports])

    :lists.map(
      fn import_def ->
        case import_def do
          {:SymbolsFromModule, _, symbols, module, _objid} ->
            :io.format("Import: module=~p symbols=~p~n", [module, symbols])
            modName = normalizeName(importModuleName(module))

            :lists.map(
              fn
                {:Externaltypereference, _, _, type} ->
                  swiftName = name(type, modName)
                  setEnvGlobal(type, swiftName)
                  setEnvGlobal("meta_mod_" <> swiftName, modName)
                  setEnvGlobal("meta_orig_" <> swiftName, bin(type))

                {:Externalvaluereference, _, _, val} ->
                  swiftName = name(val, modName)
                  :io.format("Import Value: ~p (~p) -> ~ts~n", [val, is_atom(val), swiftName])
                  setEnvGlobal(val, swiftName)

                _ ->
                  :ok
              end,
              symbols
            )

          _ ->
            :ok
        end
      end,
      real_imports
    )

    :lists.map(
      fn
        {:typedef, _, pos, name, type} ->
          # Check if there's a ptype definition for this type (e.g. Context)
          sname = to_string(name)
          ptypes = Application.get_env(:asn1scg, :ptypes, %{})

          case Map.get(ptypes, sname) do
            nil ->
              compileType(pos, name, type, modname, save)

            definition ->
              gen_type = build_ptype_ast(pos, definition, modname)
              compileType(pos, name, gen_type, modname, save)
          end

        {:ptypedef, _, pos, name, args, type} ->
          compilePType(pos, name, args, type)

        {:classdef, _, pos, name, mod, type} ->
          compileClass(pos, name, mod, type)

        {:valuedef, _, pos, name, type, value, mod} ->
          compileValue(pos, name, type, value, mod)
      end,
      declarations
    )
  end

  # Convert uppercase-only names to TitleCase for IOC class names
  # e.g., EXTENSION -> Extension, ALGORITHM-ID -> Algorithm_id
  defp normalizeClassName(name) do
    normalized = normalizeName(name)
    # Check if name is fully uppercase (IOC class names like EXTENSION)
    if String.upcase(normalized) == normalized and String.length(normalized) > 1 and
         not String.contains?(normalized, "_") do
      String.capitalize(String.downcase(normalized))
    else
      normalized
    end
  end

  def compileClass(_pos, name, modname, type) do
    # Normalize the class name (convert UPPERCASE to TitleCase for IOCs)
    normalizedName = normalizeClassName(name)
    className = emitter().name(normalizedName, modname)
    setEnv(name, className)

    # Generate AlgorithmIdentifier-style struct for IOCs with &id and &Type
    # This covers ALGORITHM-ID, ALGORITHM-IDENTIFIER, TYPE-IDENTIFIER, etc.
    emitter().algorithmIdentifierClass(className, modname, true)
  end

  def compileType(pos, name, typeDefinition, modname, save \\ true) do
    IO.puts("DEBUG: compileType name=#{inspect(name)} mod=#{modname}")

    res =
      case typeDefinition do
        {:type, _, {:INTEGER, cases}, _, _, :no} ->
          setEnv(name, builtinType(:INTEGER))
          integerEnum(name, cases, modname, save)

        {:type, _, {:ENUMERATED, cases}, _, _, :no} ->
          enumeration(name, cases, modname, save)

        {:type, _, {:CHOICE, cases}, _, _, :no} ->
          choice(name, cases, modname, save)

        {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no} ->
          sequence(name, fields, modname, save)

        {:type, _, {:Sequence, _, _, _, fields}, _, _, :no} ->
          sequence(name, fields, modname, save)

        {:type, _, {:SET, _, _, _, fields}, _, _, :no} ->
          set(name, fields, modname, save)

        {:type, _, {:Set, _, _, _, fields}, _, _, :no} ->
          set(name, fields, modname, save)

        {:type, _, {:"SEQUENCE OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) ->
          array(name, substituteType(lookup(bin(type))), :sequence, "top")

        {:type, _, {:"Sequence Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) ->
          array(name, substituteType(lookup(bin(type))), :sequence, "top")

        {:type, _,
         {:"SEQUENCE OF",
          {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} ->
          array(name, substituteType(lookup(bin(pt_type))), :sequence, "top")

        {:type, _,
         {:"Sequence Of",
          {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} ->
          array(name, substituteType(lookup(bin(pt_type))), :sequence, "top")

        {:type, _, {:"SEQUENCE OF", {:type, _, {:INTEGER, cases}, _, _, :no}}, _, _, _} ->
          # e.g. PreferredDeliveryMethod ::= SEQUENCE OF INTEGER { ... }
          element_name = bin(name) <> "_Element"
          integerEnum(element_name, cases, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :sequence, "top")

        {:type, _, {:"SEQUENCE OF", {:type, _, {:CHOICE, cases}, _, _, :no}}, _, _, _} ->
          # e.g. SubstringAssertion ::= SEQUENCE OF CHOICE { ... }
          element_name = bin(name) <> "_Element"
          choice(element_name, cases, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :sequence, "top")

        {:type, _, {:"SEQUENCE OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          array(name, substituteType(lookup(bin(type))), :sequence, "top")

        {:type, _, {:"Sequence Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          array(name, substituteType(lookup(bin(type))), :sequence, "top")

        {:type, _, {:"SET OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) ->
          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _, {:"Set Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) ->
          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _,
         {:"SET OF", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _,
         _, _} ->
          array(name, substituteType(lookup(bin(pt_type))), :set, "top")

        {:type, _,
         {:"Set Of", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _,
         _, _} ->
          array(name, substituteType(lookup(bin(pt_type))), :set, "top")

        {:type, _, {:"SET OF", {type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _, {:"SEQUENCE OF", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          # e.g. PollReqContent ::= SEQUENCE OF SEQUENCE { ... }
          element_name = bin(name) <> "_Element"
          sequence(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :sequence, "top")

        {:type, _, {:"Sequence Of", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          element_name = bin(name) <> "_Element"
          sequence(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :sequence, "top")

        {:type, _, {:"Set Of", {type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _, {:"SET OF", {:type, _, {:SET, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          # e.g. Local-File-References ::= SET OF SET { ... }
          element_name = bin(name) <> "_Element"
          set(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"Set Of", {:type, _, {:SET, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          element_name = bin(name) <> "_Element"
          set(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"Set Of", {:type, _, {:"Set Of", inner_type}, _, _, :no}}, _, _, _} ->
          # e.g. alternative-feature-sets ::= Set Of Set Of OBJECT IDENTIFIER
          element_name = bin(name) <> "_Element"
          array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"SET OF", {:type, _, {:"SET OF", inner_type}, _, _, :no}}, _, _, _} ->
          # e.g. alternative-feature-sets ::= SET OF SET OF OBJECT IDENTIFIER
          element_name = bin(name) <> "_Element"
          array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"SET OF", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          # e.g. Sealed-Doc-Bodyparts ::= SET OF SEQUENCE { ... }
          element_name = bin(name) <> "_Element"
          sequence(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"Set Of", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
          element_name = bin(name) <> "_Element"
          sequence(element_name, fields, modname, save)
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"SET OF", {:type, _, {:"SET OF", inner_type}, _, _, :no}}, _, _, _} ->
          # e.g. alternative-feature-sets ::= SET OF SET OF OBJECT IDENTIFIER
          element_name = bin(name) <> "_Element"
          array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
          element_swift = name(element_name, modname)
          array(name, element_swift, :set, "top")

        {:type, _, {:"SET OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          if bin(name) == "alternative-feature-sets" do
            :io.format("DEBUG alternative-feature-sets matched general SET OF: type=~p~n", [type])
          end

          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _, {:"Set Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
          array(name, substituteType(lookup(bin(type))), :set, "top")

        {:type, _, {:pt, {:Externaltypereference, _, _pt_mod, :SIGNED}, [innerType]}, _, [], :no} ->
          tbsName = bin(name) <> "_toBeSigned"
          compileType(pos, tbsName, innerType, modname, save)

          fields = [
            {:ComponentType, pos, :toBeSigned,
             {:type, [], {:Externaltypereference, pos, modname, tbsName}, [], [], :no}, [], [],
             []},
            {:ComponentType, pos, :algorithmIdentifier,
             {:type, [], {:Externaltypereference, pos, modname, :AlgorithmIdentifier}, [], [],
              :no}, [], [], []},
            {:ComponentType, pos, :encrypted, {:type, [], :"BIT STRING", [], [], :no}, [], [], []}
          ]

          sequence(name, fields, modname, save)

        {:type, _, {:pt, {:Externaltypereference, _, pt_mod, pt_type}, args}, _, [], :no} ->
          # Force AlgorithmIdentifier to be treated as a simple type (RawValue)
          force_simple = pt_type == :AlgorithmIdentifier or pt_type == "AlgorithmIdentifier"

          # Look up parameterized type definition for expansion
          ptype_def = :application.get_env(:asn1scg, {:ptype_def, pt_mod, pt_type}, nil)
          # Check if this is a simple type parameter (not IOC-based)
          has_simple_params =
            case ptype_def do
              nil ->
                false

              {param_names, _} ->
                # Only expand if we have simple type parameters (single Externaltypereference)
                Enum.all?(param_names, fn
                  {:Externaltypereference, _, _, _} -> true
                  _ -> false
                end)
            end

          case ptype_def do
            _ when force_simple ->
              # Force fallback for AlgorithmIdentifier
              target = substituteType(lookup(bin(pt_type)))
              typealias(name, target, modname, save)

            nil ->
              # Fallback: create typealias to substituted type
              target = substituteType(lookup(bin(pt_type)))
              typealias(name, target, modname, save)

            {_param_names, _template_type} when not has_simple_params ->
              # Complex IOC-based type - fallback to typealias
              target = substituteType(lookup(bin(pt_type)))

              typealias(name, target, modname, save)

            {param_names, template_type} ->
              # Expand parameterized type with actual arguments
              expanded_type = expand_ptype(template_type, param_names, args)
              compileType(pos, name, expanded_type, modname, save)
          end

        {:type, _, :"BIT STRING", _, [], :no} ->
          typealias(name, builtinType(:"BIT STRING"), modname, save)

        {:type, _, {:"BIT STRING", _}, _, [], :no} ->
          typealias(name, builtinType(:"BIT STRING"), modname, save)

        {:type, _, :"OCTET STRING", _, [], :no} ->
          typealias(name, builtinType(:"OCTET STRING"), modname, save)

        {:type, _, {:"OCTET STRING", _}, _, [], :no} ->
          typealias(name, builtinType(:"OCTET STRING"), modname, save)

        {:type, _, :INTEGER, _set, [], :no} ->
          typealias(name, builtinType(:INTEGER), modname, save)

        {:type, _, :NULL, _set, [], :no} ->
          typealias(name, builtinType(:NULL), modname, save)

        {:type, _, :ANY, _set, [], :no} ->
          typealias(name, builtinType(:ANY), modname, save)

        {:type, _, :"OBJECT IDENTIFIER", _set, _constraints, :no} ->
          typealias(name, builtinType(:"OBJECT IDENTIFIER"), modname, save)

        {:type, _, :External, _set, [], :no} ->
          setEnv(name, builtinType(:External))

        {:type, _, :PrintableString, _set, [], :no} ->
          typealias(name, builtinType(:PrintableString), modname, save)

        {:type, _, :PrintableString, _set, _constraints, :no} ->
          typealias(name, builtinType(:PrintableString), modname, save)

        {:type, _, :NumericString, _set, [], :no} ->
          typealias(name, builtinType(:NumericString), modname, save)

        {:type, _, :NumericString, _set, _constraints, :no} ->
          typealias(name, builtinType(:NumericString), modname, save)

        {:type, _, :IA5String, _set, [], :no} ->
          typealias(name, builtinType(:IA5String), modname, save)

        {:type, _, :TeletexString, _set, [], :no} ->
          typealias(name, builtinType(:TeletexString), modname, save)

        {:type, _, :UniversalString, _set, [], :no} ->
          typealias(name, builtinType(:UniversalString), modname, save)

        {:type, _, :UTF8String, _set, [], :no} ->
          typealias(name, builtinType(:UTF8String), modname, save)

        {:type, _, :VisibleString, _set, [], :no} ->
          typealias(name, builtinType(:VisibleString), modname, save)

        {:type, _, :BMPString, _set, [], :no} ->
          typealias(name, builtinType(:BMPString), modname, save)

        {:type, _, {:Externaltypereference, _, _, ext}, _set, [], :no} ->
          target = substituteType(lookup(bin(ext)))
          typealias(name, target, modname, save)

        {:type, _, {:Externaltypereference, _, _, ext}, _set, _constraints, :no} ->
          target = substituteType(lookup(bin(ext)))
          typealias(name, target, modname, save)

        {:type, _, type, _set, [], :no} when is_atom(type) ->
          target = substituteType(lookup(bin(type)))
          typealias(name, target, modname, save)

        {:type, _, type, _set, [], :no} when is_list(type) ->
          target = substituteType(lookup(bin(type)))
          typealias(name, target, modname, save)

        {:Object, _, _} ->
          :ignore

        {:Object, _, _, _} ->
          :ignore

        {:Object, _, _, _, _} ->
          :ignore

        {:ObjectSet, _, _} ->
          :ignore

        {:ObjectSet, _, _, _} ->
          :ignore

        {:ObjectSet, _, _, _, _} ->
          :ignore

        {:type, _, type, _set, _constraints, :no} when is_list(type) ->
          target = substituteType(lookup(bin(type)))
          typealias(name, target, modname, save)

        {:type, _, {:ObjectClassFieldType, _, _class, [{:valuefieldreference, :id}], _}, _, _,
         :no} ->
          typealias(name, builtinType(:ASN1ObjectIdentifier), modname, save)

        {:type, _, {:ObjectClassFieldType, _, _class, _field, _}, _, _, :no} ->
          # TYPE-IDENTIFIER.&Type patterns -> treat as generic ANY RawValue
          typealias(name, builtinType(:ANY), modname, save)

        {:type, _, {:pt, _, _}, _, [], _} ->
          :skip

        {:Object, _, _val} ->
          :skip

        {:Object, _, _, _} ->
          :skip

        {:ObjectSet, _, _, _, _} ->
          :skip

        _ ->
          :skip
      end

    case res do
      :ignore -> :skip
      :skip -> :io.format("Unhandled type definition ~p: ~p~n", [name, typeDefinition])
      _ -> :skip
    end
  end

  def compileValue(_pos, name, {:type, _, :INTEGER, _, _, :no}, val, mod) do
    emitter().integerValue(name, val, mod, true)
  end

  def compileValue(_pos, name, {:type, [], :"OBJECT IDENTIFIER", [], [], :no} = type, val, mod),
    do: emitter().value(name, type, val, mod, true)

  def compileValue(
        _pos,
        name,
        {:type, _, {:Externaltypereference, _, _, ref}, _, _, _} = type,
        val,
        mod
      ) do
    resolved = lookup(bin(ref))

    if resolved == builtinType(:ASN1ObjectIdentifier) or resolved == "OBJECT IDENTIFIER" or
         getEnv({:is_oid, resolved}, false) do
      emitter().value(name, type, val, mod, true)
    else
      # Complex IOC-based value definitions - silently skip
      []
    end
  end

  def compileValue(_pos, _name, _type, _val, _mod), do: []

  def compileClass(_pos, name, _mod, type),
    do:
      (
        print("Unhandled class definition ~p : ~p~n", [name, type])
        []
      )

  def compilePType(pos, name, args, type) do
    sname = to_string(name)
    ptypes = Application.get_env(:asn1scg, :ptypes, %{})

    # Store parameterized type definition for later expansion
    if args != [] do
      modname = getEnv(:current_module, "")
      key = {:ptype_def, modname, name}
      :application.set_env(:asn1scg, key, {args, type})
    end

    case Map.get(ptypes, sname) do
      nil ->
        cond do
          # Handle Parameterized Classes (e.g. MAPPING-BASED-MATCHING)
          # We treat them as regular classes to generate the base struct.
          is_tuple(type) and elem(type, 0) == :objectclass ->
            compileClass(pos, name, getEnv(:current_module, ""), type)

          args != [] ->
            :skip

          true ->
            compileType(pos, name, type, getEnv(:current_module, ""), true)
        end

      definition ->
        modname = getEnv(:current_module, "")
        gen_type = build_ptype_ast(pos, definition, modname)
        compileType(pos, name, gen_type, modname, true)
    end
  end

  defp build_ptype_ast(pos, {:sequence, fields}, mod) do
    new_fields =
      Enum.map(fields, fn {name, type, opts} ->
        build_component(pos, name, type, opts, mod)
      end)

    {:type, [], {:SEQUENCE, [], [], [], new_fields}, [], [], :no}
  end

  defp build_ptype_ast(pos, {:choice, cases}, mod) do
    new_cases =
      Enum.map(cases, fn {name, type} ->
        type_ast = build_type_ast(pos, type, [], mod)
        {:ComponentType, pos, name, type_ast, [], [], []}
      end)

    {:type, [], {:CHOICE, new_cases}, [], [], :no}
  end

  defp build_ptype_ast(pos, {:set_of, type}, mod) do
    type_ast = build_type_ast(pos, type, [], mod)
    {:type, [], {:"SET OF", type_ast}, [], [], :no}
  end

  defp build_ptype_ast(pos, {:sequence_of, type}, mod) do
    type_ast = build_type_ast(pos, type, [], mod)
    {:type, [], {:"SEQUENCE OF", type_ast}, [], [], :no}
  end

  defp build_ptype_ast(pos, type_atom, mod) when is_atom(type_atom) do
    build_type_ast(pos, type_atom, [], mod)
  end

  defp build_component(pos, name, type, opts, mod) do
    tags = Keyword.get(opts, :tag)

    attrs =
      if tags do
        {cls, num, method} = tags
        cls_atom = cls |> to_string |> String.upcase() |> String.to_atom()
        method_atom = method |> to_string |> String.upcase() |> String.to_atom()
        [{:tag, cls_atom, num, method_atom, nil}]
      else
        []
      end

    optional = if Keyword.get(opts, :optional), do: :OPTIONAL, else: []

    type_ast = build_type_ast(pos, type, attrs, mod)
    {:ComponentType, pos, name, type_ast, optional, [], []}
  end

  defp build_type_ast(_pos, :oid, attrs, _mod),
    do: {:type, attrs, :"OBJECT IDENTIFIER", [], [], :no}

  defp build_type_ast(_pos, :any, attrs, _mod), do: {:type, attrs, :ANY, [], [], :no}
  defp build_type_ast(_pos, :boolean, attrs, _mod), do: {:type, attrs, :BOOLEAN, [], [], :no}

  defp build_type_ast(_pos, :octet_string, attrs, _mod),
    do: {:type, attrs, :"OCTET STRING", [], [], :no}

  defp build_type_ast(_pos, :bit_string, attrs, _mod),
    do: {:type, attrs, :"BIT STRING", [], [], :no}

  defp build_type_ast(pos, {:set_of, type}, attrs, mod),
    do: {:type, attrs, {:"SET OF", build_type_ast(pos, type, [], mod)}, [], [], :no}

  defp build_type_ast(pos, {:sequence_of, type}, attrs, mod),
    do: {:type, attrs, {:"SEQUENCE OF", build_type_ast(pos, type, [], mod)}, [], [], :no}

  defp build_type_ast(pos, {:external, ref_name}, attrs, mod),
    do: {:type, attrs, {:Externaltypereference, pos, mod, String.to_atom(ref_name)}, [], [], :no}

  defp build_type_ast(_pos, atom, attrs, _mod) when is_atom(atom),
    do: {:type, attrs, atom, [], [], :no}

  # Parameterized type expansion helpers
  defp expand_ptype(template_type, param_names, args) do
    # Extract parameter name atoms from various structures
    param_name_atoms =
      Enum.map(param_names, fn
        # Simple type parameter with external reference
        {:Externaltypereference, _, _, pname} ->
          pname

        # Parameter wrapped in Parameter node
        {:Parameter, _, {:Externaltypereference, _, _, pname}} ->
          pname

        {:Parameter, _, pname} when is_atom(pname) ->
          pname

        # IOC pattern: {ClassType, IOSet} - extract the IOSet name
        {{:type, _, {:Externaltypereference, _, _, _class}, _, _, _},
         {:Externaltypereference, _, _, ioset_name}} ->
          ioset_name

        # IOC pattern with INTEGER type (for SIZE constraints)
        {{:type, _, :INTEGER, _, _, _}, {:Externalvaluereference, _, _, value_name}} ->
          value_name

        other ->
          other
      end)

    # Extract argument types from args (could be keyword list or list of types)
    arg_types =
      Enum.map(args, fn
        # Handle valueset patterns
        {:valueset, {:element_set, type, _}} -> type
        # Handle direct type references
        {:Externaltypereference, _, _, _} = t -> t
        {:type, _, _, _, _, _} = t -> t
        # Handle keyword list entries
        {_key, value} when is_tuple(value) -> value
        other -> other
      end)

    substitutions = Enum.zip(param_name_atoms, arg_types) |> Map.new()

    # Recursively substitute parameter references in the template
    substitute_params(template_type, substitutions)
  end

  defp substitute_params({:type, attrs, inner, a, b, c}, subs) do
    {:type, attrs, substitute_params(inner, subs), a, b, c}
  end

  defp substitute_params({:Externaltypereference, pos, mod, ref}, subs) do
    case Map.get(subs, ref) do
      nil -> {:Externaltypereference, pos, mod, ref}
      replacement -> replacement
    end
  end

  defp substitute_params({tag, elements}, subs) when is_list(elements) and is_atom(tag) do
    {tag, Enum.map(elements, &substitute_params(&1, subs))}
  end

  defp substitute_params({:SEQUENCE, a, b, c, elements}, subs) do
    {:SEQUENCE, a, b, c, Enum.map(elements, &substitute_params(&1, subs))}
  end

  defp substitute_params({:ComponentType, pos, name, type, opt, a, b}, subs) do
    {:ComponentType, pos, name, substitute_params(type, subs), opt, a, b}
  end

  defp substitute_params(other, _subs), do: other

  def inputDir(), do: :application.get_env(:asn1scg, "input", "priv/apple/")
  def outputDir(), do: :application.get_env(:asn1scg, "output", "Sources/ASN1SCG/Suite/")
  def exceptions(), do: :application.get_env(:asn1scg, "exceptions", ["Name"])

  def save(true, modname, name, res) do
    dir = outputDir()
    lang = :application.get_env(:asn1scg, :lang, "swift")

    final_dir =
      if lang == "go" do
        pkg = ASN1.GoEmitter.module_package(modname)
        d = Path.join(dir, pkg)
        :filelib.ensure_dir(Path.join(d, "stub"))
        d <> "/"
      else
        if lang == "rust" do
          crate = ASN1.RustEmitter.module_crate(modname)
          d = Path.join([dir,  "src"])
          :filelib.ensure_dir(Path.join(d, "stub"))
          d <> "/"
        else
          d = if String.ends_with?(dir, "/"), do: dir, else: dir <> "/"
          :filelib.ensure_dir(d)
          d
        end
      end

    norm = normalizeName(bin(name))
    ext = emitter().fileExtension()

    # Case-insensitive collision detection for Go
    final_norm =
      if lang == "go" do
        generated_files = Process.get(:generated_files, %{})
        path_key = String.downcase(Path.join(final_dir, norm <> ext))

        case Map.get(generated_files, path_key) do
          nil ->
            Process.put(:generated_files, Map.put(generated_files, path_key, norm))
            norm

          existing_norm when existing_norm != norm ->
            # Collision! Append suffix
            new_norm = norm <> "_caps"
            new_path_key = String.downcase(Path.join(final_dir, new_norm <> ext))
            Process.put(:generated_files, Map.put(generated_files, new_path_key, new_norm))
            new_norm

          _ ->
            norm
        end
      else
        if lang == "rust" do
          ASN1.RustEmitter.fieldName(norm)
        else
          norm
        end
      end

    final_dir_with_mod = final_dir

    fileName = final_dir_with_mod <> final_norm <> ext
    verbose = getEnv(:verbose, false)

    case :lists.member(norm, exceptions()) do
      true ->
        print("skipping: ~ts~ts~n", [norm, ext])
        setEnv(:verbose, verbose)

      false ->
        :ok = :file.write_file(fileName, res)
        # For Rust, we also need to register this type in the module's mod.rs
        setEnv(:verbose, true)
        print("compiled: ~ts~n", [fileName])
        setEnv(:verbose, verbose)
    end
  end

  def save(_, _, _, _), do: []

  def lookup("IssuerSerial"), do: "AuthenticationFramework_IssuerSerial"
  def lookup("GeneralNames"), do: "PKIX1Implicit_2009_GeneralNames"

  def lookup(name) do
    b = bin(name)

    if b == "id-at" do
      :io.format("DEBUG lookup id-at: mod=~p~n", [getEnv(:current_module, "")])
    end

    if String.starts_with?(b, "[") and String.ends_with?(b, "]") and String.length(b) > 2 do
      inner = String.slice(b, 1..-2//1)
      "[" <> lookup(inner) <> "]"
    else
      mod = getEnv(:current_module, "")

      val =
        if mod != "" and is_binary(b) do
          full = bin(normalizeName(mod)) <> "_" <> b

          key =
            try do
              String.to_existing_atom(full)
            rescue
              _ -> nil
            end

          v = if key, do: :application.get_env(:asn1scg, key, :undefined), else: :undefined

          if b == "id-at" do
            :io.format("DEBUG lookup id-at local: ~p -> ~p~n", [full, v])
          end

          v
        else
          :undefined
        end

      res =
        case val do
          :undefined ->
            v = :application.get_env(:asn1scg, b, b)

            if b == "id-at" do
              :io.format("DEBUG lookup id-at global: ~p -> ~p~n", [b, v])
            end

            v

          v ->
            v
        end

      case res do
        a when a == b -> bin(a)
        x -> lookup(x)
      end
    end
  end

  def trace(x), do: setEnv({:trace, x}, x)

  def normalizeName(name) do
    "#{name}"
    |> String.replace("-", "_")
    |> String.replace(".", "_")
  end

  def importModuleName({:Externaltypereference, _, _, mod}), do: mod
  def importModuleName(mod), do: mod

  def setEnv(x, y) when is_tuple(x) do
    # For tuple keys like {:is_oid, name}, use directly without string conversion
    :application.set_env(:asn1scg, x, y)
  end

  def setEnv(x, y) do
    mod = getEnv(:current_module, "")
    bx = bin(x)

    if mod != "" and is_binary(bx) do
      full = bin(normalizeName(mod)) <> "_" <> bx
      # Use atoms for keys
      full_atom = String.to_atom(full)
      :application.set_env(:asn1scg, full_atom, y)
      nxb = normalizeName(bx)
      nfull = bin(normalizeName(mod)) <> "_" <> nxb

      if nfull != full do
        nfull_atom = String.to_atom(nfull)
        :application.set_env(:asn1scg, nfull_atom, y)
      end
    end

    # Also set unscoped key as atom? Or keep binary as fallback?
    # `lookup` fallback uses `bin(b)` key.
    # `v = :application.get_env(:asn1scg, b, b)` where b is binary.
    # So we MUST keep binary key setter for existing fallback logic, OR update lookup fallback.
    # Updating setter to set BOTH string and atom keys for unscoped might be safer/robust.
    # But warnings say binary keys deprecated.
    # So we should switch to atoms everywhere.

    # Unscoped
    bx_atom =
      try do
        String.to_atom(bx)
      rescue
        _ -> String.to_atom("gen_" <> bx)
      end

    :application.set_env(:asn1scg, bx_atom, y)
    # Also keep binary for backward compatibility if `lookup` relies on it
    :application.set_env(:asn1scg, bx, y)

    if is_binary(bx) do
      nxb = normalizeName(bx)

      if nxb != bx do
        nxb_atom = String.to_atom(nxb)
        :application.set_env(:asn1scg, nxb_atom, y)
        :application.set_env(:asn1scg, nxb, y)
      end
    end
  end

  def setEnvGlobal(x, y) do
    bx = bin(x)
    bx_atom = String.to_atom(bx)
    :application.set_env(:asn1scg, bx_atom, y)
    :application.set_env(:asn1scg, bx, y)

    if is_binary(bx) do
      nx = normalizeName(bx)

      if nx != bx do
        nx_atom = String.to_atom(nx)
        :application.set_env(:asn1scg, nx_atom, y)
        :application.set_env(:asn1scg, nx, y)
      end
    end
  end

  def getEnv(x, y), do: :application.get_env(:asn1scg, bin(x), y)

  def bin(x) when is_atom(x), do: :erlang.atom_to_binary(x)
  def bin(x) when is_list(x), do: :erlang.list_to_binary(x)
  def bin(x), do: x
end
