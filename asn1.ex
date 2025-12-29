#!/usr/bin/env elixir

Code.require_file("Compiler/ASN1/Emitter.ex")
Code.require_file("Compiler/ASN1.ex")
Code.require_file("Compiler/ASN1/SwiftEmitter.ex")
Code.require_file("Compiler/ASN1/GoEmitter.ex")
Code.require_file("Compiler/ASN1/RustEmitter.ex")
Code.require_file("Compiler/ASN1/C99Emitter.ex")
Code.require_file("Compiler/ASN1/TSEmitter.ex")


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
    :io.format("Copyright (c) 1994-2026 Namdak Tonpa.~n")
    :io.format("ISO 8824 ITU/IETF X.680-690 ERP/1 ASN.1 DER Compiler, version 31.1.1.~n")
    :io.format("Usage: ./asn1.ex help | compile [-v] [input [output]]~n")
end
