Code.require_file("lib/ASN1/Emitter.ex")
Code.require_file("lib/ASN1.ex")
Code.require_file("lib/ASN1/SwiftEmitter.ex")
Code.require_file("lib/ASN1/GoEmitter.ex")
IO.puts("Requiring RustEmitter...")
Code.require_file("lib/ASN1/RustEmitter.ex")

case System.argv() do
  ["compile"] ->
    ASN1.compile()

  ["compile", "-v"] ->
    ASN1.setEnv(:verbose, true)
    ASN1.compile()

  ["compile", i] ->
    ASN1.setEnv(:input, i <> "/")
    ASN1.compile()

  ["compile", "-v", i] ->
    ASN1.setEnv(:input, i <> "/")
    ASN1.setEnv(:verbose, true)
    ASN1.compile()

  ["compile", i, o] ->
    ASN1.setEnv(:input, i <> "/")
    ASN1.setEnv(:output, o <> "/")
    ASN1.compile()

  ["compile", "-v", i, o] ->
    ASN1.setEnv(:input, i <> "/")
    ASN1.setEnv(:output, o <> "/")
    ASN1.setEnv(:verbose, true)
    ASN1.compile()

  _ ->
    :io.format("Copyright © 1994—2024 Namdak Tönpa.~n")
    :io.format("ISO 8824 ITU/IETF X.680-690 ERP/1 ASN.1 DER Compiler, version 30.10.7.~n")
    :io.format("Usage: ./asn1.ex help | compile [-v] [input [output]]~n")
end
