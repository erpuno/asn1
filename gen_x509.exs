
# Load the compiler module
Code.require_file("asn1.ex", ".")

# Set up environment variables for the compilation
# Target ONLY the AuthenticationFramework file
Application.put_env(:asn1scg, :SelectedAttributeTypes_DirectoryString, "PKIX1Explicit88_DirectoryString")
Application.put_env(:asn1scg, :InformationFramework_MAPPING_BASED_MATCHING, "ASN1Any")
Application.put_env(:asn1scg, :Attribute, "InformationFramework_Attribute")
Application.put_env(:asn1scg, :ANSI_X9_42_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :ANSI_X9_62_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :ANSI_X9_62_FieldID, "ASN1Any")
Application.put_env(:asn1scg, :PKCS_7_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :PKCS_7_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :PKCS_5_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :ANSI_X9_42_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :ANSI_X9_62_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :AlgorithmInformation_2009_AlgorithmIdentifier, "AuthenticationFramework_AlgorithmIdentifier")
Application.put_env(:asn1scg, :PKIX1Explicit88_AttributeValue, "ASN1Any")
Application.put_env(:asn1scg, :PKCS_9_AttributeValue, "ASN1Any") # Defensive
Application.put_env(:asn1scg, :PKCS_7_AttributeValue, "ASN1Any") # Defensive

ptypes = %{
  "SingleAttribute" => {:sequence, [
    {:type, :oid, []},
    {:value, :any, []}
  ]},
  "AttributeSet" => {:sequence, [
    {:type, :oid, []},
    {:values, {:set_of, :any}, []}
  ]},
  "Extension" => {:sequence, [
    {:extnID, :oid, []},
    {:critical, :boolean, [optional: true]},
    {:extnValue, :octet_string, []}
  ]},
  "SecurityCategory" => {:sequence, [
    {:type, :oid, [tag: {:context, 0, :implicit}]},
    {:value, :any, [tag: {:context, 1, :explicit}]}
  ]},
  "SecurityCategory-rfc3281" => {:sequence, [
    {:type, :oid, [tag: {:context, 0, :implicit}]},
    {:value, :any, [tag: {:context, 1, :explicit}]}
  ]},
  "Attribute" => {:sequence, [
    {:type, :oid, []},
    {:values, {:set_of, :any}, []}
  ]},
  "Attributes" => {:set_of, {:external, "Attribute"}},
  "Extensions" => {:sequence_of, {:external, "Extension"}},
  "SubjectPublicKeyInfo" => {:sequence, [
    {:algorithm, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
    {:subjectPublicKey, :bit_string, []}
  ]},
  "DirectoryString" => {:choice, [
    {:teletexString, :TeletexString},
    {:printableString, :PrintableString},
    {:bmpString, :BMPString},
    {:universalString, :UniversalString},
    {:uTF8String, :UTF8String}
  ]},
  "FieldID" => {:sequence, [
    {:fieldType, :oid, []},
    {:parameters, :any, []}
  ]},
  "PKCS9String" => {:choice, [
      {:ia5String, :IA5String},
      {:directoryString, {:external, "DirectoryString"}}
  ]},
  "SMIMECapability" => {:sequence, [
      {:algorithm, :oid, []},
      {:parameters, :any, [optional: true]} # Treating as optional to be safe
  ]},
  "SMIMECapabilities" => {:sequence_of, {:external, "SMIMECapability"}},
  "ENCRYPTED-HASH" => :bit_string,
  "ENCRYPTED" => :bit_string,
  "HASH" => {:sequence, [
      {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
      {:hashValue, :bit_string, []}
  ]},
  "SIGNATURE" => {:sequence, [
      {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
      {:encrypted, :bit_string, []}
  ]},
  "SIGNED" => {:sequence, [
      {:toBeSigned, :any, []},
      {:algorithmIdentifier, {:external, "AuthenticationFramework_AlgorithmIdentifier"}, []},
      {:encrypted, :bit_string, []}
  ]}
}
Application.put_env(:asn1scg, :ptypes, ptypes)

File.mkdir_p!("Sources/Suite/XSeries")
Application.put_env(:asn1scg, "output", "Sources/Suite/XSeries/")

# List of files to compile in order of dependency (though multi-pass handles cycles)
files =
  case System.argv() do
    [arg] ->
      file = if String.ends_with?(arg, ".asn1"), do: arg, else: arg <> ".asn1"
      [file]

    _ ->
      "priv/x-series"
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".asn1"))
      |> Enum.sort()
  end

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
