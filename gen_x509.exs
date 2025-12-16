
# Load the compiler module
Code.require_file("asn1.ex", ".")

# Set up environment variables for the compilation
# Target ONLY the AuthenticationFramework file
File.mkdir_p!("Sources/Suite/XSeries")
Application.put_env(:asn1scg, "output", "Sources/Suite/XSeries/")

# List of files to compile in order of dependency (though multi-pass handles cycles)
files = [
  "UsefulDefinitions.asn1",
  "UpperBounds.asn1",
  "InformationFramework.asn1",
  "BasicAccessControl.asn1",
  "SelectedAttributeTypes.asn1",
  "CertificateExtensions.asn1",
  "AuthenticationFramework.asn1",
  "Layout-Descriptors.asn1",
  "Logical-Descriptors.asn1",
  "Identifiers-and-Expressions.asn1"
]

# Pass 1: Collect types (save=false)
IO.puts("Pass 1: Collecting types...")
Application.put_env(:asn1scg, "save", false)
Enum.each(files, fn filename ->
  path = "priv/x-series/#{filename}"
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
  path = "priv/x-series/#{filename}"
  ASN1.compile(false, path)
end)

# Pass 3: Generate code (save=true)
IO.puts("Pass 3: Generating code...")
Application.put_env(:asn1scg, "save", true)
Enum.each(files, fn filename ->
  path = "priv/x-series/#{filename}"
  ASN1.compile(true, path)
end)
