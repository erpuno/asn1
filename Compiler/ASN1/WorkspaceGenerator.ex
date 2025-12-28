# ============================================================================
# WorkspaceGenerator - shared helper to build Cargo workspaces
# ============================================================================
defmodule WorkspaceGenerator do
  def generate_workspace(modules, output_dir, deps) do
    mod_to_crate =
      Enum.reduce(modules, %{}, fn modname, acc ->
        crate = ASN1.RustEmitter.module_crate(modname)
        Map.put(acc, modname, crate)
      end)

    crates =
      mod_to_crate
      |> Map.values()
      |> Enum.uniq()
      |> Enum.sort()

    crates_dir = Path.join(output_dir, "crates")

    IO.puts("\n=== Generating Cargo Workspace ===")
    IO.puts("Crates found: #{Enum.join(crates, ", ")}")

    generate_root_cargo_toml(output_dir, crates)

    Enum.each(crates, fn crate ->
      generate_crate_cargo_toml(crate, mod_to_crate, deps, crates_dir, crates)
      generate_crate_lib_rs(crate, mod_to_crate, crates_dir, crates)
    end)
  end

  defp generate_root_cargo_toml(output_dir, crates) do
    dep_lines =
      crates
      |> Enum.map(fn c -> "#{c} = { path = \"crates/#{c}\" }" end)
      |> Enum.join("\n")

    workspace_members =
      crates
      |> Enum.map(&"\"crates/#{&1}\"")
      |> Enum.join(",\n        ")

    content = """
    [package]
    name = "asn1_suite"
    version = "0.1.0"
    edition = "2021"

    [workspace]
    resolver = "2"
    members = [
            #{workspace_members}
    ]

    [dependencies]
    rust-asn1 = { git = "https://github.com/iho/rust-asn1.git" }
    #{dep_lines}

    [dev-dependencies]
    reqwest = { version = "0.12", features = ["json"] }
    tokio = { version = "1", features = ["macros", "rt-multi-thread"] }
    """

    File.mkdir_p!(output_dir)
    path = Path.join(output_dir, "Cargo.toml")
    IO.puts("Writing root Cargo.toml to #{path}")
    File.write!(path, content)

    lib_path = Path.join([output_dir, "src", "lib.rs"])

    if File.exists?(lib_path) do
      lib_content =
        crates
        |> Enum.map(&"pub use #{&1};")
        |> Enum.join("\n")

      full_lib = """
      //! Generated ASN.1 suite bindings
      #{lib_content}
      """

      File.write!(lib_path, full_lib)
    end
  end

  defp generate_crate_cargo_toml(crate, mod_to_crate, deps, crates_dir, existing_crates) do
    crate_modules =
      mod_to_crate
      |> Enum.filter(fn {_, c} -> c == crate end)
      |> Enum.map(fn {m, _} -> m end)

    # ASN.1 IMPORTS-based dependencies
    asn1_deps =
      crate_modules
      |> Enum.flat_map(fn mod -> Map.get(deps, mod, []) end)
      |> Enum.map(fn dep_mod -> Map.get(mod_to_crate, dep_mod) end)

    # Cross-crate dependencies tracked during code generation
    tracked_deps = ASN1.RustEmitter.get_crate_dependencies(crate)

    # Merge both sources and filter - only include crates that exist in the workspace
    crate_deps =
      (asn1_deps ++ tracked_deps)
      |> Enum.filter(fn dep_crate ->
        dep_crate != nil and dep_crate != crate and dep_crate in existing_crates
      end)
      |> Enum.uniq()
      |> Enum.sort()

    dep_section =
      crate_deps
      |> Enum.map(fn d -> "#{d} = { path = \"../#{d}\" }" end)
      |> Enum.join("\n")

    content = """
    [package]
    name = "#{crate}"
    version = "0.1.0"
    edition = "2021"

    [dependencies]
    rust-asn1 = { git = "https://github.com/iho/rust-asn1.git" }
    #{dep_section}
    """

    path = Path.join([crates_dir, crate, "Cargo.toml"])
    :filelib.ensure_dir(path)
    File.write!(path, content)
  end

  defp generate_crate_lib_rs(crate, mod_to_crate, crates_dir, existing_crates) do
    crate_modules =
      mod_to_crate
      |> Enum.filter(fn {_, c} -> c == crate end)
      |> Enum.map(fn {m, _} -> m end)
      |> Enum.sort()

    # Module declarations
    module_content =
      crate_modules
      |> Enum.map(fn mod ->
        snake = mod |> ASN1.normalizeName() |> ASN1.RustEmitter.fieldName()
        "pub mod #{snake};\npub use self::#{snake}::*;"
      end)
      |> Enum.join("\n")

    # Cross-crate re-exports for dependency types - only for crates that exist
    tracked_deps =
      ASN1.RustEmitter.get_crate_dependencies(crate)
      |> Enum.filter(fn dep -> dep in existing_crates end)

    reexport_content =
      if tracked_deps != [] do
        reexports =
          tracked_deps
          |> Enum.sort()
          |> Enum.map(fn dep_crate ->
            # Re-export all public items from each dependency crate
            "pub use ::#{dep_crate}::*;"
          end)
          |> Enum.join("\n")

        "\n// Re-export cross-crate dependencies\n#{reexports}"
      else
        ""
      end

    full_content = """
    #{module_content}#{reexport_content}
    """

    src_dir = Path.join([crates_dir, crate, "src"])
    File.mkdir_p!(src_dir)
    path = Path.join(src_dir, "lib.rs")
    File.write!(path, full_content)
  end
end
