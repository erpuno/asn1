#!/usr/bin/env elixir

# Load the compiler module
Code.require_file("Compiler/ASN1.ex", ".")
Code.require_file("Compiler/ASN1/Emitter.ex", ".")
Code.require_file("Compiler/ASN1/GoEmitter.ex", ".")
Code.require_file("Compiler/ASN1/SwiftEmitter.ex", ".")
Code.require_file("Compiler/ASN1/RustEmitter.ex", ".")
Code.require_file("Compiler/ASN1/C99Emitter.ex", ".")
Code.require_file("Compiler/ASN1/JavaEmitter.ex", ".")
Code.require_file("Compiler/ASN1/WorkspaceGenerator.ex", ".")

# ============================================================================
# DependencyAnalyzer - Handles import parsing, topological sort, and cycle detection
# ============================================================================
defmodule DependencyAnalyzer do
  @moduledoc """
  Analyzes ASN.1 module dependencies for:
  1. Import parsing - extracts IMPORTS to build module dependency graph
  2. Topological sort - orders files so dependencies compile first
  3. Cycle detection - identifies recursive types needing Box wrapper
  """

  @doc """
  Parse imports from a single ASN.1 file.
  Returns {module_name, [list of imported module names]}
  """
  def parse_imports(path) do
    tokens = :asn1ct_tok.file(path)

    case :asn1ct_parser2.parse(path, tokens) do
      {:ok, {:module, _pos, modname, _defid, _tagdefault, _exports, imports, _, _declarations}} ->
        imported_modules = extract_imported_modules(imports)
        {normalize_name(modname), imported_modules}

      {:error, reason} ->
        IO.puts("Warning: Failed to parse #{path}: #{inspect(reason)}")
        {Path.basename(path, ".asn1"), []}
    end
  end

  defp extract_imported_modules({:imports, imports_list}) when is_list(imports_list) do
    Enum.flat_map(imports_list, fn
      {:SymbolsFromModule, _, _symbols, module, _objid} ->
        [normalize_name(import_module_name(module))]

      _ ->
        []
    end)
    |> Enum.uniq()
  end

  defp extract_imported_modules(imports) when is_list(imports) do
    Enum.flat_map(imports, fn
      {:SymbolsFromModule, _, _symbols, module, _objid} ->
        [normalize_name(import_module_name(module))]

      _ ->
        []
    end)
    |> Enum.uniq()
  end

  defp extract_imported_modules(_), do: []

  defp import_module_name({:Externaltypereference, _, _, mod}), do: mod
  defp import_module_name(mod) when is_atom(mod), do: mod
  defp import_module_name(mod), do: mod

  @doc """
  Parse all imports from a list of files.
  Returns map of %{module_name => [imported_module_names]}
  """
  def parse_all_imports(files, base_dir) do
    Enum.reduce(files, %{}, fn filename, acc ->
      path = Path.join(base_dir, filename)

      if File.exists?(path) do
        {modname, imports} = parse_imports(path)
        Map.put(acc, modname, imports)
      else
        acc
      end
    end)
  end

  @doc """
  Topologically sort files based on import dependencies.
  Uses Kahn's algorithm. Returns sorted list of filenames.
  """
  def topological_sort(deps, files, base_dir) do
    # Build module name -> filename mapping
    mod_to_file =
      Enum.reduce(files, %{}, fn filename, acc ->
        path = Path.join(base_dir, filename)

        if File.exists?(path) do
          {modname, _} = parse_imports(path)
          Map.put(acc, modname, filename)
        else
          acc
        end
      end)

    # Build file -> file dependencies
    file_deps =
      Enum.reduce(deps, %{}, fn {modname, imported_mods}, acc ->
        filename = Map.get(mod_to_file, modname)

        if filename do
          dep_files =
            imported_mods
            |> Enum.map(&Map.get(mod_to_file, &1))
            |> Enum.filter(&(&1 != nil))

          Map.put(acc, filename, dep_files)
        else
          acc
        end
      end)

    # Ensure all files are in the map
    file_deps =
      Enum.reduce(files, file_deps, fn f, acc ->
        Map.put_new(acc, f, [])
      end)

    # Kahn's algorithm
    kahn_sort(file_deps, files)
  end

  defp kahn_sort(graph, all_nodes) do
    # Calculate in-degrees
    in_degree =
      Enum.reduce(all_nodes, %{}, fn node, acc ->
        Map.put(acc, node, 0)
      end)

    in_degree =
      Enum.reduce(graph, in_degree, fn {_node, deps}, acc ->
        Enum.reduce(deps, acc, fn dep, inner_acc ->
          Map.update(inner_acc, dep, 1, &(&1 + 1))
        end)
      end)

    # Find nodes with no incoming edges
    queue =
      Enum.filter(all_nodes, fn node -> Map.get(in_degree, node, 0) == 0 end)
      |> :queue.from_list()

    do_kahn_sort(graph, in_degree, queue, [], MapSet.new(all_nodes))
  end

  defp do_kahn_sort(_graph, _in_degree, {[], []}, result, remaining) do
    # If there are remaining nodes, we have a cycle
    remaining_list = MapSet.to_list(remaining)

    if remaining_list != [] do
      IO.puts("Warning: Cycle detected in module dependencies: #{inspect(remaining_list)}")
      # Return what we have plus remaining in original order
      Enum.reverse(result) ++ remaining_list
    else
      Enum.reverse(result)
    end
  end

  defp do_kahn_sort(graph, in_degree, queue, result, remaining) do
    case :queue.out(queue) do
      {:empty, _} ->
        remaining_list = MapSet.to_list(remaining)

        if remaining_list != [] do
          IO.puts("Warning: Cycle detected in module dependencies: #{inspect(remaining_list)}")
          Enum.reverse(result) ++ remaining_list
        else
          Enum.reverse(result)
        end

      {{:value, node}, new_queue} ->
        new_remaining = MapSet.delete(remaining, node)

        # For each node that depends on this one, reduce its in-degree
        # Note: we need reverse dependencies here
        deps = Map.get(graph, node, [])

        {new_in_degree, nodes_to_add} =
          Enum.reduce(deps, {in_degree, []}, fn dep, {deg_acc, add_acc} ->
            new_deg = Map.get(deg_acc, dep, 1) - 1
            new_deg_acc = Map.put(deg_acc, dep, new_deg)

            if new_deg == 0 do
              {new_deg_acc, [dep | add_acc]}
            else
              {new_deg_acc, add_acc}
            end
          end)

        final_queue = Enum.reduce(nodes_to_add, new_queue, fn n, q -> :queue.in(n, q) end)

        do_kahn_sort(graph, new_in_degree, final_queue, [node | result], new_remaining)
    end
  end

  @doc """
  Detect type cycles that require Box wrapper.
  Analyzes type definitions to find recursive references.
  Returns list of "ModuleName_TypeName.field_name" strings.
  """
  def detect_type_cycles(base_dir, files) do
    # First pass: collect all type definitions
    all_types =
      Enum.reduce(files, %{}, fn filename, acc ->
        path = Path.join(base_dir, filename)

        if File.exists?(path) do
          types = collect_type_definitions(path)
          Map.merge(acc, types)
        else
          acc
        end
      end)

    # Build type dependency graph
    type_graph = build_type_graph(all_types)

    # Find cycles using DFS with coloring
    find_cycles_dfs(type_graph, all_types)
  end

  defp collect_type_definitions(path) do
    tokens = :asn1ct_tok.file(path)

    case :asn1ct_parser2.parse(path, tokens) do
      {:ok, {:module, _pos, modname, _defid, _tagdefault, _exports, _imports, _, declarations}} ->
        normalized_mod = normalize_name(modname)

        Enum.reduce(declarations, %{}, fn decl, acc ->
          case decl do
            {:typedef, _, _pos, name, type} ->
              full_name = "#{normalized_mod}_#{normalize_name(name)}"
              Map.put(acc, full_name, {normalized_mod, name, type})

            {:ptypedef, _, _pos, name, _args, type} ->
              full_name = "#{normalized_mod}_#{normalize_name(name)}"
              Map.put(acc, full_name, {normalized_mod, name, type})

            _ ->
              acc
          end
        end)

      _ ->
        %{}
    end
  end

  defp build_type_graph(all_types) do
    Enum.reduce(all_types, %{}, fn {type_name, {mod, _name, type_def}}, acc ->
      refs = extract_type_refs(type_def, mod)
      Map.put(acc, type_name, refs)
    end)
  end

  defp extract_type_refs(type_def, current_mod) do
    extract_type_refs_acc(type_def, current_mod, [])
    |> Enum.uniq()
  end

  defp extract_type_refs_acc(
         {:type, _, {:Externaltypereference, _, ref_mod, ref_type}, _, _, _},
         current_mod,
         acc
       ) do
    mod =
      if ref_mod == current_mod or ref_mod == nil, do: current_mod, else: normalize_name(ref_mod)

    full_ref = "#{mod}_#{normalize_name(ref_type)}"
    [full_ref | acc]
  end

  defp extract_type_refs_acc({:type, _, {:SEQUENCE, _, _, _, fields}, _, _, _}, mod, acc) do
    extract_from_fields(fields, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:SET, _, _, _, fields}, _, _, _}, mod, acc) do
    extract_from_fields(fields, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:CHOICE, cases}, _, _, _}, mod, acc) do
    extract_from_fields(cases, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:"SEQUENCE OF", inner}, _, _, _}, mod, acc) do
    extract_type_refs_acc(inner, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:"SET OF", inner}, _, _, _}, mod, acc) do
    extract_type_refs_acc(inner, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:"Sequence Of", inner}, _, _, _}, mod, acc) do
    extract_type_refs_acc(inner, mod, acc)
  end

  defp extract_type_refs_acc({:type, _, {:"Set Of", inner}, _, _, _}, mod, acc) do
    extract_type_refs_acc(inner, mod, acc)
  end

  defp extract_type_refs_acc({:ComponentType, _, _name, type, _, _, _}, mod, acc) do
    extract_type_refs_acc(type, mod, acc)
  end

  defp extract_type_refs_acc(tuple, mod, acc) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.reduce(acc, fn elem, inner_acc -> extract_type_refs_acc(elem, mod, inner_acc) end)
  end

  defp extract_type_refs_acc(list, mod, acc) when is_list(list) do
    Enum.reduce(list, acc, fn elem, inner_acc -> extract_type_refs_acc(elem, mod, inner_acc) end)
  end

  defp extract_type_refs_acc(_, _, acc), do: acc

  defp extract_from_fields(fields, mod, acc) when is_list(fields) do
    Enum.reduce(fields, acc, fn field, inner_acc ->
      extract_type_refs_acc(field, mod, inner_acc)
    end)
  end

  defp extract_from_fields(_, _, acc), do: acc

  defp find_cycles_dfs(graph, all_types) do
    # DFS with coloring: :white (unvisited), :gray (in progress), :black (done)
    nodes = Map.keys(graph)
    initial_color = Enum.reduce(nodes, %{}, fn n, acc -> Map.put(acc, n, :white) end)

    {_, cycles} =
      Enum.reduce(nodes, {initial_color, []}, fn node, {colors, found_cycles} ->
        if Map.get(colors, node) == :white do
          dfs_visit(node, graph, all_types, colors, [], found_cycles)
        else
          {colors, found_cycles}
        end
      end)

    # Convert cycles to boxing format
    cycles
    |> List.flatten()
    |> Enum.uniq()
  end

  defp dfs_visit(node, graph, all_types, colors, path, found_cycles) do
    colors = Map.put(colors, node, :gray)
    neighbors = Map.get(graph, node, [])

    {new_colors, new_cycles} =
      Enum.reduce(neighbors, {colors, found_cycles}, fn neighbor, {c_acc, cy_acc} ->
        case Map.get(c_acc, neighbor, :white) do
          :gray ->
            # Found a cycle! Find the field that creates this reference
            cycle_entries = find_cycle_fields(path ++ [node], neighbor, all_types)
            {c_acc, cycle_entries ++ cy_acc}

          :white ->
            dfs_visit(neighbor, graph, all_types, c_acc, path ++ [node], cy_acc)

          :black ->
            {c_acc, cy_acc}
        end
      end)

    {Map.put(new_colors, node, :black), new_cycles}
  end

  defp find_cycle_fields(path, cycle_target, all_types) do
    # Find fields in the path that reference types in the cycle
    Enum.flat_map(path, fn type_name ->
      case Map.get(all_types, type_name) do
        {_mod, _name, type_def} ->
          find_fields_referencing(type_name, type_def, cycle_target)

        nil ->
          []
      end
    end)
  end

  defp find_fields_referencing(
         parent_type,
         {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, _},
         target
       ) do
    find_in_fields(parent_type, fields, target)
  end

  defp find_fields_referencing(parent_type, {:type, _, {:SET, _, _, _, fields}, _, _, _}, target) do
    find_in_fields(parent_type, fields, target)
  end

  defp find_fields_referencing(_, _, _), do: []

  defp find_in_fields(parent_type, fields, target) when is_list(fields) do
    Enum.flat_map(fields, fn
      {:ComponentType, _, field_name, field_type, _, _, _} ->
        refs = extract_type_refs(field_type, "")

        if Enum.member?(refs, target) do
          ["#{parent_type}.#{normalize_name(field_name)}"]
        else
          []
        end

      _ ->
        []
    end)
  end

  defp find_in_fields(_, _, _), do: []

  defp normalize_name(name) when is_atom(name), do: to_string(name) |> String.replace("-", "_")
  defp normalize_name(name) when is_binary(name), do: String.replace(name, "-", "_")
  defp normalize_name(name), do: to_string(name) |> String.replace("-", "_")
end

# Application.put_env(:asn1scg, :AuthenticationFramework_AlgorithmIdentigfier, "DSTU_AlgorithmIdentifier")

# Rust-specific type mappings - only apply for Rust code generation
if System.get_env("ASN1_LANG") == "rust" do
  Application.put_env(:asn1scg, :DSTU_AttributeValue, "ASN1Node")
  Application.put_env(:asn1scg, :DSTU_CertificateSerialNumber, "Vec<u8>")
end

ptypes = %{
  "SingleAttribute" =>
    {:sequence,
     [
       {:type, :oid, []},
       {:value, :any, []}
     ]},
  "AttributeSet" =>
    {:sequence,
     [
       {:type, :oid, []},
       {:values, {:set_of, :any}, []}
     ]},
  "Extension" =>
    {:sequence,
     [
       {:extnID, :oid, []},
       {:critical, :boolean, [optional: true]},
       {:extnValue, :octet_string, []}
     ]},
  "SecurityCategory" =>
    {:sequence,
     [
       {:type, :oid, [tag: {:context, 0, :implicit}]},
       {:value, :any, [tag: {:context, 1, :explicit}]}
     ]},
  "SecurityCategory-rfc3281" =>
    {:sequence,
     [
       {:type, :oid, [tag: {:context, 0, :implicit}]},
       {:value, :any, [tag: {:context, 1, :explicit}]}
     ]},
  "Attribute" =>
    {:sequence,
     [
       {:type, :oid, []},
       {:values, {:set_of, :any}, []}
     ]},
  "Attributes" => {:set_of, {:external, "Attribute"}},
  "Extensions" => {:sequence_of, {:external, "Extension"}},
  # "SubjectPublicKeyInfo" => {:sequence, [
  #   {:algorithm, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
  #   {:subjectPublicKey, :bit_string, []}
  # ]},
  "DirectoryString" =>
    {:choice,
     [
       {:teletexString, :TeletexString},
       {:printableString, :PrintableString},
       {:bmpString, :BMPString},
       {:universalString, :UniversalString},
       {:uTF8String, :UTF8String}
     ]},
  "FieldID" =>
    {:sequence,
     [
       {:fieldType, :oid, []},
       {:parameters, :any, []}
     ]},
  "PKCS9String" =>
    {:choice,
     [
       {:ia5String, :IA5String},
       {:directoryString, {:external, "DirectoryString"}}
     ]},
  "SMIMECapability" =>
    {:sequence,
     [
       {:algorithm, :oid, []},
       # Treating as optional to be safe
       {:parameters, :any, [optional: true]}
     ]},
  "SMIMECapabilities" => {:sequence_of, {:external, "SMIMECapability"}},
  "ENCRYPTED-HASH" => :bit_string,
  "ENCRYPTED" => :bit_string,
  # "HASH" => {:sequence, [
  #     {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
  #     {:hashValue, :bit_string, []}
  # ]},
  # "SIGNATURE" => {:sequence, [
  #     {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
  #     {:encrypted, :bit_string, []}
  # ]},
  # "SIGNED" => {:sequence, [
  #     {:toBeSigned, :any, []},
  #     {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
  #     {:encrypted, :bit_string, []}
  # ]},
  "Context" =>
    {:sequence,
     [
       {:contextType, :oid, []},
       {:contextValues, {:set_of, :any}, []},
       {:fallback, :boolean, [optional: true]}
     ]},
  "EncryptedContentInfo" =>
    {:sequence,
     [
       {:contentType, :oid, []},
       {:contentEncryptionAlgorithm, {:external, "AlgorithmInformation_2009_AlgorithmIdentifier"},
        []},
       {:encryptedContent, :octet_string, [optional: true, tag: {:context, 0, :implicit}]}
     ]}
}

Application.put_env(:asn1scg, :ptypes, ptypes)

# Manual boxing entries for known recursive types
# These are kept as overrides/supplements to automatic detection
manual_boxing = [
  # "Layout_Descriptors_Layout_Class_Descriptor_Body.generator_for_subordinates",
  # "Layout_Descriptors_Layout_Class_Descriptor_Body.content_generator",
  # "Layout_Descriptors_Layout_Class_Descriptor_Body.bindings",
  # "Layout_Descriptors_Layout_Object_Descriptor_Body.bindings",
  # "Layout_Descriptors_Layout_Class_Descriptor.descriptor_body",
  # "Layout_Descriptors_Layout_Object_Descriptor.descriptor_body",

  # # Reducing Layout Body Size
  # "Layout_Descriptors_Layout_Class_Descriptor_Body.presentation_attributes",
  # "Layout_Descriptors_Layout_Class_Descriptor_Body.default_value_lists",
  # "Layout_Descriptors_Layout_Object_Descriptor_Body.presentation_attributes",
  # "Layout_Descriptors_Layout_Object_Descriptor_Body.default_value_lists",

  # # Identifiers-and-Expressions Recursion
  # "Identifiers_and_Expressions_Construction_Factor.construction_type",
  # "Identifiers_and_Expressions_Object_Id_Expression.preceding_object_function",
  # "Identifiers_and_Expressions_Object_Id_Expression.superior_object_function",
  "Chat_message_CHATMessage.body",
  "CHATMessage.body"
]

# "Identifiers_and_Expressions_Numeric_Expression.increment_application",
# "Identifiers_and_Expressions_Numeric_Expression.decrement_application",
# "Identifiers_and_Expressions_Numeric_Expression_ordinal_application.expression",
# "Identifiers_and_Expressions_Binding_Selection_Function.preceding_function",
# "Identifiers_and_Expressions_Binding_Selection_Function.superior_function",
# "Identifiers_and_Expressions_Current_Instance_Function.second_parameter_expression"

lang = System.get_env("ASN1_LANG") || "swift"
Application.put_env(:asn1scg, :lang, lang)

default_output =
  case lang do
    "rust" -> "asn1_suite"
    _ -> "Languages/AppleSwift/Basic"
  end

output_dir = System.get_env("ASN1_OUTPUT") || default_output
File.mkdir_p!(output_dir)
output_env = if String.ends_with?(output_dir, "/"), do: output_dir, else: output_dir <> "/"
Application.put_env(:asn1scg, "output", output_env)

base_dir = "Specifications/basic"

# Get list of files
raw_files =
  case System.argv() do
    [arg] ->
      file = if String.ends_with?(arg, ".asn1"), do: arg, else: arg <> ".asn1"
      [file]

    _ ->
      base_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".asn1"))
      |> Enum.sort()
  end

IO.puts("=== Dependency Analysis ===")

# Parse imports and build dependency graph
IO.puts("Parsing imports...")
deps = DependencyAnalyzer.parse_all_imports(raw_files, base_dir)
IO.puts("Found #{map_size(deps)} modules with dependencies")

# Topologically sort files
IO.puts("Topologically sorting by dependencies...")
files = DependencyAnalyzer.topological_sort(deps, raw_files, base_dir)
IO.puts("Sorted order: #{length(files)} files")

if lang == "rust" do
  modules =
    files
    |> Enum.map(fn filename ->
      path = Path.join(base_dir, filename)

      if File.exists?(path) do
        {modname, _} = DependencyAnalyzer.parse_imports(path)
        modname
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()

  workspace_root = Path.expand("asn1_suite")
  File.mkdir_p!(Path.join(workspace_root, "crates"))
  WorkspaceGenerator.generate_workspace(modules, workspace_root, deps)
end

# Detect type cycles for Box wrapping
IO.puts("Detecting type cycles for Box wrapper...")
detected_cycles = DependencyAnalyzer.detect_type_cycles(base_dir, files)
IO.puts("Detected #{length(detected_cycles)} cyclic type references")

# Merge manual and detected boxing entries
all_boxing = (manual_boxing ++ detected_cycles) |> Enum.uniq()

IO.puts(
  "Total boxing entries: #{length(all_boxing)} (#{length(manual_boxing)} manual + #{length(detected_cycles)} detected)"
)

# Show newly detected cycles not in manual list
new_detections = detected_cycles -- manual_boxing

if new_detections != [] do
  IO.puts("\nNewly detected cycles (not in manual list):")
  Enum.each(new_detections, fn entry -> IO.puts("  - #{entry}") end)
end

Application.put_env(:asn1scg, :boxing, all_boxing)

IO.puts("\n=== Compilation ===")

# Pass 1: Collect types (save=false)
IO.puts("Pass 1: Collecting types...")
Application.put_env(:asn1scg, "save", false)

Enum.each(files, fn filename ->
  path = Path.join(base_dir, filename)

  if File.exists?(path) do
    ASN1.compile(false, path)
  else
    IO.puts("Error: File #{path} not found.")
    System.halt(1)
  end
end)

# Pass 2: Resolve references (save=false)
IO.puts("Pass 2: Resolving references...")
Application.put_env(:asn1scg, "save", false)

Enum.each(files, fn filename ->
  path = Path.join(base_dir, filename)
  ASN1.compile(false, path)
end)

# Pass 3: Generate code (save=true)
IO.puts("Pass 3: Generating code...")
Application.put_env(:asn1scg, "save", true)

Enum.each(files, fn filename ->
  path = Path.join(base_dir, filename)
  ASN1.compile(true, path)
end)

IO.puts("\n=== Complete ===")
