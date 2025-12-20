defmodule ModGenerator do
  def run do
    output_dir = "asn1_suite/src/generated"

    if File.exists?(output_dir) do
      files =
        File.ls!(output_dir)
        |> Enum.filter(&String.ends_with?(&1, ".rs"))
        |> Enum.reject(&(&1 == "mod.rs"))
        |> Enum.sort()

      content =
        files
        |> Enum.map(fn file ->
          mod = Path.basename(file, ".rs")
          "pub mod #{mod};\npub use #{mod}::*;\n"
        end)
        |> Enum.join("")

      File.write!(Path.join(output_dir, "mod.rs"), content)
      IO.puts("Generated mod.rs with #{length(files)} modules.")
    else
      IO.puts("Directory #{output_dir} does not exist.")
    end
  end
end

ModGenerator.run()
