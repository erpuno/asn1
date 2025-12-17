#!/usr/bin/env elixir

defmodule ASN1 do

  def print(format, params) do
      case :application.get_env(:asn1scg, "save", true) and :application.get_env(:asn1scg, "verbose", false) do
           true -> :io.format(format, params)
              _ -> []
      end
  end
  def array_element_type(type_name) when is_binary(type_name) do
    if String.starts_with?(type_name, "[") and String.ends_with?(type_name, "]") do
      String.slice(type_name, 1, String.length(type_name) - 2)
    else
      nil
    end
  end
  def array_element_type(_), do: nil

  def array(name,type,tag,level \\ "")
  def array(name,type,tag,level) when level == "top" do
       name1 = bin(normalizeName(name))
       type1 = bin(type)
       mod = getEnv(:current_module, "")
       fullName = if mod != "" and not String.starts_with?(name1, "["), do: bin(normalizeName(mod)) <> "_" <> name1, else: name1

       setEnv(name1, fullName)
       setEnv({:array, fullName}, {tag, type1})
       setEnv({:array, "[#{type1}]"}, {tag, type1})

       print "array: #{level} : ~ts = [~ts] ~p (Struct Generated)~n", [name1, type1, tag]

       decoder = case tag do
           :set -> "DER.set(of: #{type1}.self, identifier: identifier, rootNode: rootNode)"
           _ -> "DER.sequence(of: #{type1}.self, identifier: identifier, rootNode: rootNode)"
       end

       encoder = case tag do
           :set -> "serializeSetOf"
           _ -> "serializeSequenceOf"
       end

       structDef = """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline struct #{fullName}: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .#{tag} }
    @usableFromInline var value: [#{type1}]
    @inlinable public init(_ value: [#{type1}]) { self.value = value }
    @inlinable public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.value = try #{decoder}
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.#{encoder}(value, identifier: identifier)
    }
}
"""
       save(true, mod, fullName, structDef)
       name1
  end

  def array(name,type,tag,level) when tag == :sequence or tag == :set do
      name1 = bin(normalizeName(name))
      type1 = bin(type)
      case level do
           "" -> []
            _ -> print "array: #{level} : ~ts = [~ts] ~p ~n", [name1, type1, tag]
      end
      setEnv(name1, "[#{type1}]")
      mod = getEnv(:current_module, "")
      prefixed = if mod != "" and not String.starts_with?(name1, "["), do: bin(normalizeName(mod)) <> "_" <> name1, else: name1
      setEnv({:array, prefixed}, {tag, type1})
      setEnv({:array, "[#{type1}]"}, {tag, type1})
      name1
  end

  def fieldName({:contentType, {:Externaltypereference,_,_mod, name}}), do: escape_kw(normalizeName("#{name}"))
  def fieldName(name), do: escape_kw(normalizeName("#{name}"))

  def escape_kw(n) do
     # hashValue conflicts with Hashable protocol - must be renamed, not escaped
     if n == "hashValue" do
        "hash_value"
     else if n == "identifier" do
        # 'identifier' shadows parameter in serialize(into:withIdentifier identifier:)
        "ident"
     else
       if n in ["default", "class", "struct", "enum", "protocol", "extension", "func", "var", "let", "if", "else", "switch", "case", "for", "in", "while", "do", "return", "throw", "throws", "try", "catch", "where", "defer", "guard", "repeat", "import", "typealias", "init", "deinit", "subscript", "static", "public", "private", "internal", "fileprivate", "open", "operator", "break", "continue", "fallthrough", "inout", "willSet", "didSet", "override", "convenience", "dynamic", "final", "indirect", "lazy", "mutating", "nonmutating", "optional", "required", "weak", "unowned", "self", "super", "Type", "Any", "Protocol", "print"] do
          "`#{n}`"
       else
          n
       end
     end
     end
  end


  def fieldType(name, field, {:tag, _, _, _, inner}), do: fieldType(name, field, inner)
  def fieldType(name,field,{:ComponentType,_,_,{:type,_,oc,_,[],:no},_opt,_,_}), do: fieldType(name, field, oc)
  def fieldType(name,field,{:"SEQUENCE", _, _, _, _}), do: bin(name) <> "_" <> bin(field) <> "_Sequence"
  def fieldType(name,field,{:"SET", _, _, _, _}), do: bin(name) <> "_" <> bin(field) <> "_Set"
  def fieldType(name,field,{:"CHOICE",_}), do: bin(name) <> "_" <> bin(field) <> "_Choice"
  def fieldType(name,field,{:"ENUMERATED",_}), do: bin(name) <> "_" <> bin(field) <> "_Enum"
  def fieldType(name,field,{:"INTEGER",_}), do: bin(name) <> "_" <> bin(field) <> "_IntEnum"
  def fieldType(name,field,{:"SEQUENCE OF", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{field}")  end
  def fieldType(name,field,{:"Sequence Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{field}")  end
  def fieldType(name,field,{:"SET OF", {:type, _, {:"SET OF", inner}, _, _, _}}) do
    # Handle nested SET OF SET OF by generating wrapper type
    inner_type = case inner do
      {:type, _, t, _, _, _} -> t
      _ -> inner
    end
    element_name = bin(name) <> "_" <> bin(field) <> "_Element"
    array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
    element_swift = getSwiftName(element_name, getEnv(:current_module, ""))
    "[#{element_swift}]"
  end
  def fieldType(name,field,{:"SET OF", type}) do
    # Check if type contains nested SET OF
    is_nested = case type do
      {:type, _, third, _, _, _} when is_tuple(third) ->
        elem(third, 0) == :"SET OF" or elem(third, 0) == ~c"SET OF"
      _ -> false
    end
    if is_nested do
      {:type, _, {_, inner}, _, _, _} = type
      inner_type = case inner do
        {:type, _, t, _, _, _} -> t
        _ -> inner
      end
      element_name = bin(name) <> "_" <> bin(field) <> "_Element"
      array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
      element_swift = getSwiftName(element_name, getEnv(:current_module, ""))
      "[#{element_swift}]"
    else
      bin = "[#{sequenceOf(name,field,type)}]"
      array("#{bin}", partArray(bin), :set, "pro #{name}.#{field}")
      bin
    end
  end
  def fieldType(name,field,{:"Set Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "pro #{name}.#{field}")  end
  def fieldType(_,_,{:contentType, {:Externaltypereference,_,_,type}}), do: "#{type}"
  def fieldType(_,_,{:"BIT STRING", _}), do: "ASN1BitString"
  def fieldType(_,_,{:pt, {_,_,_,type}, _}) when is_atom(type), do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(_,_,{:ANY_DEFINED_BY, type}) when is_atom(type), do: "ASN1Any"
  def fieldType(_name,_field,{:Externaltypereference,_,_,type}) when type == :OrganizationalUnitNames, do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(_name,_field,{:Externaltypereference,_,_,type}), do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(_,_,{:ObjectClassFieldType,_,_,[{:valuefieldreference, :id}],_}), do: "ASN1ObjectIdentifier"
  def fieldType(_,_,{:ObjectClassFieldType,_,_,_field,_}), do: "ASN1Any"
  def fieldType(_,_,type) when is_atom(type), do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(name,_,type) when is_tuple(type) do
    case type do
      {:pt, {:Externaltypereference, _, _, actual_type}, _} ->
        "#{substituteType(lookup(bin(actual_type)))}"
      {:SelectionType, _, {_, _, {:Externaltypereference, _, _, actual_type}, _, _, _}} ->
        "#{substituteType(lookup(bin(actual_type)))}"
      _ ->
        "#{name}"
    end
  end

  def sequenceOf(name,field,type) do
      sequenceOf2(name,field,type)
  end

  def sequenceOf2(name,field,{:type,_,{:Externaltypereference,_,_,type},_,_,_}), do: "#{sequenceOf(name,field,type)}"
  def sequenceOf2(_,_,{:pt, {:Externaltypereference, _, _, type}, _}), do: substituteType("#{lookup(bin(type))}")
  def sequenceOf2(name,field,{:type,_,{:"SET OF", {:type, _, {:"SET OF", {:type, _, inner_type, _, _, _}}, _, _, _}},_,_,_}) do
    # Handle nested SET OF SET OF by generating wrapper type
    element_name = bin(name) <> "_" <> bin(field) <> "_Element"
    array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
    element_swift = getSwiftName(element_name, getEnv(:current_module, ""))
    "[#{element_swift}]"
  end
  def sequenceOf2(name,field,{:type,_,{:"SET OF", type},_,_,_}) do
    bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "arr #{name}.#{field}")
  end
  def sequenceOf2(name,field,{:type,_,{:"Set Of", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "arr #{name}.#{field}")  end
  def sequenceOf2(name,field,{:type,_,{:"SEQUENCE OF", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "arr #{name}.#{field}") end
  def sequenceOf2(name,field,{:type,_,{:"Sequence Of", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "arr #{name}.#{field}") end
  def sequenceOf2(name,field,{:type,_,{:CHOICE, cases} = sum,_,_,_}) do
    saveFlag = getEnv("save", false)
    choice(fieldType(name,field,sum), cases, getEnv(:current_module, ""), saveFlag)
    bin(name) <> "_" <> bin(field) <> "_Choice"
  end
  def sequenceOf2(name,field,{:type,_,{:SEQUENCE, _, _, _, fields} = product,_,_,_}) do
    saveFlag = getEnv("save", false)
    sequence(fieldType(name,field,product), fields, getEnv(:current_module, ""), saveFlag)
    bin(name) <> "_" <> bin(field) <> "_Sequence"
  end
  def sequenceOf2(name,field,{:type,_,{:SET, _, _, _, fields} = product,_,_,_}) do
      saveFlag = getEnv("save", false)
      typeName = bin(name) <> "_" <> bin(field) <> "_Set"
      set(typeName, fields, getEnv(:current_module, ""), saveFlag)
      typeName
  end
  def sequenceOf2(name,field,{:type,_,type,_,_,_}) do "#{sequenceOf(name,field,type)}" end
  def sequenceOf2(name,_,{:Externaltypereference, _, _, type}) do :application.get_env(:asn1scg, bin(name), bin(type)) end
  def sequenceOf2(_,_,{:ObjectClassFieldType,_,_,[{:valuefieldreference, :id}],_}), do: "ASN1ObjectIdentifier"
  def sequenceOf2(_,_,{:ObjectClassFieldType,_,_,_field,_}), do: "ASN1Any"
  def sequenceOf2(_,_,x) when is_tuple(x), do: substituteType("#{bin(:erlang.element(1, x))}")
  def sequenceOf2(_,_,x) when is_atom(x), do: substituteType("#{lookup(x)}")
  def sequenceOf2(_,_,x) when is_binary(x), do: substituteType("#{lookup(x)}")

  def substituteType("IssuerSerial"), do: "AuthenticationFramework_IssuerSerial"
  def substituteType("GeneralNames"), do: "PKIX1Implicit_2009_GeneralNames"
  def substituteType("TeletexString"),     do: "ASN1TeletexString"
  def substituteType("UniversalString"),   do: "ASN1UniversalString"
  def substituteType("IA5String"),         do: "ASN1IA5String"
  def substituteType("VisibleString"),     do: "ASN1UTF8String"
  def substituteType("UTF8String"),        do: "ASN1UTF8String"
  def substituteType("PrintableString"),   do: "ASN1PrintableString"
  def substituteType("NumericString"),     do: "ASN1PrintableString"
  def substituteType("BMPString"),         do: "ASN1BMPString"
  def substituteType("VideotexString"),    do: "ASN1UTF8String"
  def substituteType("GraphicString"),     do: "ASN1UTF8String"
  def substituteType("INTEGER"),           do: "ArraySlice<UInt8>"
  def substituteType("OCTET STRING"),      do: "ASN1OctetString"
  def substituteType("BIT STRING"),        do: "ASN1BitString"
  def substituteType("OBJECT IDENTIFIER"), do: "ASN1ObjectIdentifier"
  def substituteType("BOOLEAN"),           do: "Bool"
  def substituteType("pt"),                do: "ASN1Any"
  def substituteType("ANY"),               do: "ASN1Any"
  def substituteType("NULL"),              do: "ASN1Null"
  def substituteType("EXTERNAL"),          do: "EXTERNAL"
  def substituteType("External"),          do: "EXTERNAL"
  def substituteType("GeneralString"),     do: "ASN1UTF8String"
  def substituteType("REAL"),              do: "ASN1Any"
  def substituteType("TYPE-IDENTIFIER"),   do: "ASN1Any"
  def substituteType("ABSTRACT-SYNTAX"),   do: "ASN1Any"

  def substituteType(t) do
    key = try do
      String.to_existing_atom(t)
    rescue
      _ -> nil
    end

    case key do
      nil -> t
      k -> :application.get_env(:asn1scg, k, t)
    end
  end

  def swiftEsc(name) do
      s = bin(name)
      if s in [
          "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
          "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public",
          "rethrows", "static", "struct", "subscript", "typealias", "var",
          "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for",
          "guard", "if", "in", "repeat", "return", "switch", "where", "while",
          "as", "Any", "catch", "false", "is", "nil", "super", "self", "Self", "throw", "throws",
          "true", "try"
      ] do
          "`" <> s <> "`"
      else
          s
      end
  end

  def emitImprint(), do: "// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa."
  def emitArg(name) do
      n = swiftEsc(name)
      "#{n}: #{n}"
  end
  def emitCtorBodyElement(name) do
      n = swiftEsc(name)
      "self.#{n} = #{n}"
  end
  def emitCtorParam(name, type, opt \\ "") do
      n = swiftEsc(name)
      t = normalizeName(type)
      finalType = if isBoxed(getEnv(:current_struct, ""), name), do: "Box<#{t}>", else: t
      "#{n}: #{finalType}#{opt}"
  end
  def emitCtor(params,fields), do: pad(4) <> "@inlinable init(#{params}) {\n#{fields}\n    }\n"
  def emitEnumElement(_type, field, value), do: pad(4) <> "static let #{swiftEsc(field)} = Self(rawValue: #{value})\n"
  def emitIntegerEnumElement(field, value), do: pad(4) <> "public static let #{swiftEsc(field)} = Self(rawValue: #{value})\n"
  def emitOptional(:OPTIONAL, name, body) do
      n = swiftEsc(name)
      "if let #{n} = self.#{n} { #{body} }"
  end
  def emitOptional({:DEFAULT, _}, name, body), do: emitOptional(:OPTIONAL, name, body)
  def emitOptional(_, _, body), do: "#{body}"
  def emitSequenceElementOptional(name, type, opt \\ "") do
      n = swiftEsc(name)
      t = lookup(normalizeName(type))
      finalType = if isBoxed(getEnv(:current_struct, ""), name), do: "Box<#{t}>", else: t
      "@usableFromInline var #{n}: #{finalType}#{opt}\n"
  end

  # Vector Decoder

  # Special handling for implicitly tagged ASN1Any (ASN1Any doesn't conform to DERImplicitlyTaggable)
  # These MUST come before the generic Implicit handlers to match first
  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, "ASN1Any") when plicit == "Implicit" and no != [] do
      n = swiftEsc(name)
      "let #{n}: ASN1Any? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in ASN1Any(derEncoded: node) }"
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, "ASN1Any") when plicit == "Implicit" and no != [] do
      n = swiftEsc(name)
      "let #{n}: ASN1Any = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in ASN1Any(derEncoded: node) }!"
  end

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Implicit" do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>? = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))).map { Box($0) }"
      else
          "let #{n}: #{type}? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
      end
  end

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Explicit" do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return Box(try #{type}(derEncoded: node)) }"
      else
          "let #{n}: #{type}? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
      end
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Explicit" do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}> = Box(try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) })"
      else
          "let #{n}: #{type} = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
      end
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Implicit" do

      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}> = Box((try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific)))!)"
      else
          "let #{n}: #{type} = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific)))!"
      end
  end
  def emitSequenceDecoderBodyElement(:OPTIONAL, _, _, name, "ASN1Any") do
      n = swiftEsc(name)
      # ASN1Any not usually boxed
      "let #{n}: ASN1Any? = nodes.next().map { ASN1Any(derEncoded: $0) }"
  end
  def emitSequenceDecoderBodyElement(_, _, _, name, "Bool"), do:
      "let #{name}: Bool = try DER.decodeDefault(&nodes, defaultValue: false)"
  def emitSequenceDecoderBodyElement(optional, _, _, name, type) do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>#{opt(optional)} = Box(try #{type}(derEncoded: &nodes))"
      else
          "let #{n}: #{type}#{opt(optional)} = try #{type}(derEncoded: &nodes)"
      end
  end

  def emitSequenceDecoderBodyElementArray(:OPTIONAL, plicit, no, name, type, spec) when plicit == "Explicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]>? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }.map { Box($0) }"
      else
          "let #{n}: [#{element_type}]? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(:OPTIONAL, plicit, no, name, type, spec) when plicit == "Implicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]>? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: node.identifier, rootNode: node) }.map { Box($0) }"
      else
          "let #{n}: [#{element_type}]? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: node.identifier, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(_, plicit, no, name, type, spec) when plicit == "Implicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
         "let #{n}: Box<[#{element_type}]> = Box(try DER.#{spec}(of: #{element_type}.self, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific), nodes: &nodes))"
      else
         "let #{n}: [#{element_type}] = try DER.#{spec}(of: #{element_type}.self, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific), nodes: &nodes)"
      end
  end
  def emitSequenceDecoderBodyElementArray(_, _, no, name, type, spec) when no != [] and (spec == "set" or spec == "sequence") do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]> = Box(try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) })"
      else
          "let #{n}: [#{element_type}] = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(optional, _, no, name, type, spec) when no == [] do
      n = swiftEsc(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<[#{type}]>#{opt(optional)} = Box(try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, nodes: &nodes))"
      else
          "let #{n}: [#{type}]#{opt(optional)} = try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, nodes: &nodes)"
      end
  end
  def emitSequenceDecoderBodyElementIntEnum(name, type), do:
      "let #{name} = try #{type}(rawValue: Int(derEncoded: &nodes))"

  # Vector Encoder

  def emitSequenceEncoderBodyElement(optional, plicit, no, name, s) do
      structName = getEnv(:current_struct, "")
      boxed = isBoxed(structName, name)
      n = if boxed, do: "#{name}.value", else: name

      body = emitGenEncoder(plicit, no, n, s)
      emitOptional(optional, name, body)
  end

  def isBoxed(structName, fieldName) do
      boxing = :application.get_env(:asn1scg, :boxing, [])
      key = "#{structName}.#{fieldName}"
      Enum.member?(boxing, key)
  end

  def emitGenEncoder(plicit, no, name, s) when plicit == "Explicit" and no != [] and (s == "set" or s == "sequence"), do:
      "try coder.serialize(explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific) { codec in try codec.serialize#{spec(s)}(#{name}) }"
  def emitGenEncoder(plicit, no, name, s) when plicit == "Implicit" and no != [] and (s == "set" or s == "sequence"), do:
      "try coder.serialize#{spec(s)}(#{name}, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
  def emitGenEncoder(plicit, no, name, _) when no != [] and plicit == "Implicit", do:
      "try coder.serializeOptionalImplicitlyTagged(#{name}, withIdentifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
  def emitGenEncoder(plicit, no, name, _) when no != [] and plicit == "Explicit", do:
      "try coder.serialize(explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific) { codec in try codec.serialize(#{name}) }"
  def emitGenEncoder(_, no, name, spec) when spec == "sequence" and no == [], do:
      "try coder.serializeSequenceOf(#{name})"
  def emitGenEncoder(_, no, name, spec) when spec == "set" and no == [], do:
      "try coder.serializeSetOf(#{name})"
  def emitGenEncoder(_, no, name, _) when no == [], do:
      "try coder.serialize(#{name})"
  def emitSequenceEncoderBodyElementIntEnum(no, name) when no == [], do:
      "try coder.serialize(#{name}.rawValue)"
  def emitSequenceEncoderBodyElementIntEnum(no, name), do:
      "try coder.serialize(#{swiftEsc(name)}.rawValue, explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific)"

  # Special encoder for ASN1Any - doesn't conform to DERImplicitlyTaggable
  def emitSequenceEncoderBodyElementAny(optional, name) do
      body = "try coder.serialize(#{name})"
      emitOptional(optional, name, body)
  end

  # Scalar Sum Component

  def emitChoiceElement(name, type), do: "case #{swiftEsc(name)}(#{lookup(bin(normalizeName(type)))})\n"
  def emitChoiceEncoderBodyElement(w, no, name, _type, spec, _plicit) when no == [] do
      n = swiftEsc(name)
      pad(w) <> "case .#{n}(let #{n}): try coder.serialize#{spec}(#{n})"
  end
  def emitChoiceEncoderBodyElement(w, no, name, type, spec, plicit) do
      n = swiftEsc(name)
      tag = "ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)})"
      # Resolve the Swift type name to check for ASN1Any
      resolved_type = case type do
          :REAL -> "ASN1Any"
          {:Externaltypereference, _, _, t} -> substituteType(lookup(bin(t)))
          t when is_atom(t) -> substituteType(lookup(bin(t)))
          _ -> ""
      end
      is_any_type = resolved_type == "ASN1Any" or type == "ASN1Any"
      if plicit == "Explicit" do
         if spec == "SetOf" or spec == "SequenceOf" do
            pad(w) <> "case .#{n}(let #{n}): try coder.appendConstructedNode(identifier: #{tag}) { coder in try coder.serialize#{spec}(#{n}) }"
         else
            if is_any_type do
               pad(w) <> "case .#{n}(let #{n}): try coder.appendConstructedNode(identifier: #{tag}) { coder in try coder.serialize(#{n}) }"
            else
               pad(w) <> "case .#{n}(let #{n}): try coder.appendConstructedNode(identifier: #{tag}) { coder in try #{n}.serialize(into: &coder) }"
            end
         end
      else
          if spec == "" do
            if is_any_type do
              pad(w) <> "case .#{n}(let #{n}): try coder.serialize(#{n})"
            else
              pad(w) <> "case .#{n}(let #{n}): try #{n}.serialize(into: &coder, withIdentifier: #{tag})"
            end
          else
            pad(w) <> "case .#{n}(let #{n}): try coder.serialize#{spec}(#{n}, identifier: #{tag})"
          end
      end
  end
  # Special case for ASN1Any (REAL maps to ASN1Any - use REAL tag identifier)
  def emitChoiceDecoderBodyElement(w, _no, name, "ASN1Any", _spec) do
      # REAL type has tag 9; ASN1Any wraps arbitrary types
      pad(w) <> "case ASN1Identifier(tagWithNumber: 9, tagClass: .universal):\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(ASN1Any(derEncoded: rootNode))"
  end
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec) when no == [], do:
      pad(w) <> "case #{normalizeName(type)}.defaultIdentifier:\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"

  # Vector Sum Component

  def emitChoiceDecoderBodyElementForArray(w, no, name, type, spec) when no == [], do:
      pad(w) <> "case ASN1Identifier.#{spec}:\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, rootNode: rootNode))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec) when spec == "", do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, nodes: &nodes))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{swiftEsc(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: rootNode.identifier, rootNode: rootNode))"

  def emitSequenceDefinition(name,fields,ctor,decoder,encoder), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
@usableFromInline struct #{name}: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }\n#{fields}#{ctor}#{decoder}#{encoder}}
"""

  def emitSetDefinition(name,fields,ctor,decoder,encoder), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
@usableFromInline struct #{name}: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .set }\n#{fields}#{ctor}#{decoder}#{encoder}}
"""

  def emitChoiceDefinition(name,cases,decoder,encoder,defId), do:
"""
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline indirect enum #{name}: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { #{defId} }
    #{cases}#{decoder}#{encoder}
}
"""

  def emitEnumerationDefinition(name,cases), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
public struct #{name}: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
#{cases}}
"""

  def emitIntegerEnumDefinition(name,cases), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
public struct #{name} : DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable, Comparable {
    public static var defaultIdentifier: ASN1Identifier { .integer }
    @usableFromInline  var rawValue: Int
    @inlinable public static func < (lhs: #{name}, rhs: #{name}) -> Bool { lhs.rawValue < rhs.rawValue }
    @inlinable init(rawValue: Int) { self.rawValue = rawValue }
    @inlinable public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try Int(derEncoded: rootNode, withIdentifier: identifier)
    }
    @inlinable public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
#{cases}}
"""

  def emitChoiceDecoder(body, name, cases) do
     fallback = if length(cases) == 1 do
         case hd(cases) do
            {:ComponentType,_,fieldName,{:type,_tag,type,_elementSet,[],:no},_optional,_,_} ->
                typeName = substituteType(lookup(fieldType(name, fieldName(fieldName), type)))
                caseName = fieldName(fieldName)
                """
                default:
                    if identifier == rootNode.identifier {
                        if case .constructed(let nodes) = rootNode.content {
                            var iterator = nodes.makeIterator()
                            if let first = iterator.next(), iterator.next() == nil {
                                if first.identifier == #{typeName}.defaultIdentifier {
                                    self = .#{caseName}(try #{typeName}(derEncoded: first, withIdentifier: #{typeName}.defaultIdentifier))
                                    return
                                }
                            }
                        }
                        self = .#{caseName}(try #{typeName}(derEncoded: rootNode, withIdentifier: identifier))
                    } else {
                        throw ASN1Error.unexpectedFieldType(rootNode.identifier)
                    }
                """
            _ -> "            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)"
         end
     else
         "            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)"
     end
"""
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        switch rootNode.identifier {
#{body}
#{fallback}
        }
    }
"""
  end

  def emitChoiceEncoder(cases), do:
"""
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        switch self {
#{cases}
        }
    }
"""

  def emitSetDecoder(fields, name, args), do:
"""
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.set(root, identifier: identifier) { nodes in\n#{fields}
            return #{normalizeName(name)}(#{args})
        }
    }
"""

  def emitSequenceDecoder(fields, name, args), do:
"""
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in\n#{fields}
            return #{normalizeName(name)}(#{args})
        }
    }
"""

  def emitSequenceEncoder(fields), do:
"""
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in\n#{fields}
        }
    }
"""

  def emitIntegerEnums(cases) when is_list(cases) do
      Enum.join(:lists.map(fn
        {:NamedNumber, fieldName, fieldValue} ->
           trace(1)
           emitIntegerEnumElement(fieldName(fieldName), fieldValue)
         _ -> ""
      end, cases), "")
  end

  def emitEnums(name, cases) when is_list(cases) do
      Enum.join(:lists.map(fn
        {:NamedNumber, fieldName, fieldValue} ->
           trace(2)
           emitEnumElement(name, fieldName(fieldName), fieldValue)
         _ -> ""
      end, cases), "")
  end

  def emitCases(name, w, cases, modname) when is_list(cases) do
      Enum.join(:lists.map(fn
        {:ComponentType,_,fieldName,{:type,_,fieldType,_elementSet,[],:no},_optional,_,_} ->
           trace(3)
           field = fieldType(name, fieldName, fieldType)
           case fieldType do
              {:SEQUENCE, _, _, _, fields} ->
                 sequence(fieldType(name,fieldName,fieldType), fields, modname, true)
              {:SET, _, _, _, fields} ->
                 set(fieldType(name,fieldName,fieldType), fields, modname, true)
              {:CHOICE, cases} ->
                 choice(fieldType(name,fieldName,fieldType), cases, modname, true)
              {:INTEGER, cases} ->
                 integerEnum(fieldType(name,fieldName,fieldType), cases, modname, true)
              {:ENUMERATED, cases} ->
                 enumeration(fieldType(name,fieldName,fieldType), cases, modname, true)
              _ ->
                 :skip
           end
           pad(w) <> emitChoiceElement(fieldName(fieldName), substituteType(lookup(field)))
          _ -> ""
      end, cases), "")
  end

  def emitFields(name, w, fields, modname) when is_list(fields) do
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(4)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitFields(n, w, inclusion, modname)
        {:ComponentType,_,fieldName,{:type,_,fieldType,_elementSet,[],:no},optional,_,_} ->
           trace(5)
           field = fieldType(name, fieldName, fieldType)
           case fieldType do
              {:SEQUENCE, _, _, _, fields} ->
                 sequence(fieldType(name,fieldName,fieldType), fields, modname, true)
              {:SET, _, _, _, fields} ->
                 set(fieldType(name,fieldName,fieldType), fields, modname, true)
              {:CHOICE, cases} ->
                 zip = :lists.zip(cases, :lists.seq(0, :erlang.length(cases)-1))
                 casesTagged = :lists.flatten(:lists.map(fn {line,newNo} ->
                  case line do
                   {:'ComponentType',l,name,{:type,tag,ref,x,y,no},opt,z,w} ->
                        tagNew = case tag do [] -> [{:tag,:APPLICATION,newNo,:'IMPLICIT',32}] ; x -> x end
                        {:'ComponentType',l,name,{:type,tagNew,ref,x,y,no},opt,z,w}
                   _ -> []
                   end
                 end, zip))
                 choice(fieldType(name,fieldName,fieldType), casesTagged, modname, true)
              {:INTEGER, cases} ->
                 integerEnum(fieldType(name,fieldName,fieldType), cases, modname, true)
              {:ENUMERATED, cases} ->
                 enumeration(fieldType(name,fieldName,fieldType), cases, modname, true)
              _ ->
                 :skip
           end
           print "field: ~ts.~ts : ~ts ~n", [name,fieldName(fieldName), substituteType(lookup(field))]
           pad(w) <>
                emitSequenceElementOptional(fieldName(fieldName), substituteType(lookup(field)), opt(optional))
         _ -> ""
      end, fields), "")
  end


  def emitCtorBody(fields), do:
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(6)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitCtorBody(inclusion)
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           trace(7)
           pad(8) <> emitCtorBodyElement(fieldName(fieldName))
        _ -> ""
      end, fields), "\n")


  def emitChoiceEncoderBody(name,cases), do:
      Enum.join(:lists.map(fn
        {:ComponentType,_,fieldName,{:type,tag,{:"SEQUENCE OF", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(8)
           emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SequenceOf", plicit(tag))
        {:ComponentType,_,fieldName,{:type,tag,{:"Sequence Of", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(8)
           emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SequenceOf", plicit(tag))
        {:ComponentType,_,fieldName,{:type,tag,{:"SET OF", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(9)
           emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SetOf", plicit(tag))
        {:ComponentType,_,fieldName,{:type,tag,{:"Set Of", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(9)
           emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SetOf", plicit(tag))
        {:ComponentType,_,fieldName,{:type,tag,type,_elementSet,[],:no},_optional,_,_} ->
           trace(10)
           case {part(lookup(fieldType(name,fieldName,type)),0,1),
                 :application.get_env(:asn1scg, {:array, lookup(fieldType(name,fieldName(fieldName),type))}, [])} do
                {"[", {:set, _}} -> emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SetOf", plicit(tag))
                {"[", {:sequence, _}} -> emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "SequenceOf", plicit(tag))
                _ -> emitChoiceEncoderBodyElement(12, tag, fieldName(fieldName), type, "", plicit(tag))
           end
         _ -> ""
      end, cases), "\n")

  def emitChoiceDecoderBody(name,cases), do:
      Enum.join(:lists.map(fn
        {:ComponentType,_,fieldName,{:type,tag,{:"SEQUENCE OF", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(11)
           emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName),
               substituteType(lookup(fieldType(name, fieldName(fieldName), type))), "sequence")
        {:ComponentType,_,fieldName,{:type,tag,{:"Sequence Of", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(11)
           emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName),
               substituteType(lookup(fieldType(name, fieldName(fieldName), type))), "sequence")
        {:ComponentType,_,fieldName,{:type,tag,{:"SET OF", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(12)
           emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName),
               substituteType(lookup(fieldType(name, fieldName(fieldName), type))), "set")
        {:ComponentType,_,fieldName,{:type,tag,{:"Set Of", {_,_,type,_,_,_}},_,_,_},_,_,_} ->
           trace(12)
           emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName),
               substituteType(lookup(fieldType(name, fieldName(fieldName), type))), "set")
        {:ComponentType,_,fieldName,{:type,tag,type,_elementSet,[],:no},_optional,_x,_y} ->
           trace(13)
           case {part(lookup(fieldType(name,fieldName,type)),0,1),
                 :application.get_env(:asn1scg, {:array, lookup(fieldType(name,fieldName(fieldName),type))}, [])} do
                {"[", {:set, inner}} -> emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName), inner, "set")
                {"[", {:sequence, inner}} -> emitChoiceDecoderBodyElementForArray(12, tag, fieldName(fieldName), inner, "sequence")
                _ -> emitChoiceDecoderBodyElement(12, tag, fieldName(fieldName),
                        substituteType(lookup(fieldType(name, fieldName(fieldName), type))), "")
           end
         _ -> ""
      end, cases), "\n")

  def emitSequenceDecoderBody(name,fields), do:
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(14)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitSequenceDecoderBody(n, inclusion)
        {:ComponentType,_,fieldName,{:type,tag,type,_elementSet,[],:no},optional,_,_} ->
           look = substituteType(normalizeName(lookup(fieldType(name,fieldName,type))))
           res = case type do
                {:"SEQUENCE OF", {:type, _, inner, _, _, _}} ->
                    trace(15)
                    emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,inner))), "sequence")
                {:"Sequence Of", {:type, _, inner, _, _, _}} ->
                    trace(15)
                    emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,inner))), "sequence")
                {:"SET OF", {:type, _, inner, _, _, _}} ->
                    trace(16)
                    if bin(fieldName(fieldName)) == "alternative-feature-sets" do
                      :io.format("DEBUG decoder SET OF field=~p inner=~p~n", [fieldName(fieldName), inner])
                    end
                    emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,inner))), "set")
                {:"Set Of", {:type, _, inner, _, _, _}} ->
                    trace(16)
                    emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,inner))), "set")
                {:"INTEGER", _} ->
                    trace(17)
                    emitSequenceDecoderBodyElementIntEnum(fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName(fieldName),type))))
                {:Externaltypereference,_,_,inner} ->
                    trace(18)
                     innerName = lookup(bin(inner))
                     resName = if String.starts_with?(innerName, "["), do: part(look,1,:erlang.size(look)-2), else: look
                     is_struct = not String.starts_with?(innerName, "[")
                     case :application.get_env(:asn1scg, {:array, innerName}, []) do
                        {:sequence, _} when is_struct -> emitSequenceDecoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), look)
                        {:sequence, _} -> emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), resName, "sequence")
                        {:set, _} when is_struct -> emitSequenceDecoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), look)
                        {:set, _} -> emitSequenceDecoderBodyElementArray(optional, plicit(tag), tagNo(tag), fieldName(fieldName), resName, "set")
                         _ -> emitSequenceDecoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), look)
                     end
              _ ->  trace(19)
                    emitSequenceDecoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), look)
          end
          pad(12) <> res
         _ -> ""
      end, fields), "\n")

  def emitSequenceEncoderBody(_name, fields), do:
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,name}, _, _, :no}} ->
           trace(20)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(name)}, [])
           emitSequenceEncoderBody(name, inclusion)
        {:ComponentType,_,fieldName,{:type,tag,type,_elementSet,[],:no},optional,_,_} ->
           res = case type do
                {:"SEQUENCE OF", {:type, _, _innerType, _, _, _}} ->
                    trace(21)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "sequence")
                {:"Sequence Of", {:type, _, _innerType, _, _, _}} ->
                    trace(21)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "sequence")
                {:"SET OF", {:type, _, _innerType, _, _, _}} ->
                    trace(22)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "set")
                {:"Set Of", {:type, _, _innerType, _, _, _}} ->
                    trace(22)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "set")
                {:"INTEGER", _} ->
                    trace(23)
                    emitSequenceEncoderBodyElementIntEnum(tagNo(tag), fieldName(fieldName))
                :BOOLEAN ->
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
                {:Externaltypereference,_,_,inner} ->
                    trace(24)
                     innerName = lookup(bin(inner))
                     is_struct = not String.starts_with?(innerName, "[")
                     case :application.get_env(:asn1scg, {:array, innerName}, []) do
                        {:sequence, _} when is_struct -> emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
                        {:sequence, _} -> emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "sequence")
                        {:set, _} when is_struct -> emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
                        {:set, _} -> emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "set")
                         _ -> emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
                     end
                :ANY ->
                    # ASN1Any doesn't conform to DERImplicitlyTaggable - use simple serialize
                    emitSequenceEncoderBodyElementAny(optional, fieldName(fieldName))
                :REAL ->
                    # REAL maps to ASN1Any which doesn't conform to DERImplicitlyTaggable
                    emitSequenceEncoderBodyElementAny(optional, fieldName(fieldName))
              _ ->  trace(25)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
           end
           pad(12) <> emitOptional(optional, fieldName(fieldName), res)
         _ -> ""
      end, fields), "\n")

  def emitParams(name,fields) when is_list(fields) do
      list = :lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(26)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitParams(n,inclusion)
        {:ComponentType,_,fieldName,{:type,_,type,_elementSet,[],:no},optional,_,_} ->
           trace(27)
           emitCtorParam(fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,type))), opt(optional))
         _ -> ""
      end, fields)
      Enum.join(Enum.filter(list, fn x -> x != "" end), ", ")
  end

  def emitArgs(fields) when is_list(fields) do
      list = :lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(28)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitArgs(inclusion)
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           trace(29)
           emitArg(fieldName(fieldName))
         _ ->  ""
      end, fields)
      Enum.join(Enum.filter(list, fn x -> x != "" end), ", ")
  end

  def dump() do
      :lists.foldl(fn {{:array,x},{tag,y}}, _ -> print "env array: ~ts = [~ts] ~tp ~n", [x,y,tag]
                      {x,y}, _  when is_binary(x) -> print "env alias: ~ts = ~ts ~n", [x,y]
                      {{:type,x},_}, _ -> print "env type: ~ts = ... ~n", [x]
                      _, _ -> :ok
      end, [], :lists.sort(:application.get_all_env(:asn1scg)))
  end

  def compile() do
      {:ok, f} = :file.list_dir inputDir()
      :io.format "F: ~p~n", [f]
      files = :lists.filter(fn x -> String.ends_with?(to_string(x), ".asn1") end, f)
      setEnv(:save, false) ; :lists.map(fn file -> compile(false, inputDir() <> to_string(file))  end, files)
      setEnv(:save, false) ; :lists.map(fn file -> compile(false, inputDir() <> to_string(file))  end, files)
      setEnv(:save, true)  ; :lists.map(fn file -> compile(true,  inputDir() <> to_string(file))  end, files)
      print "inputDir: ~ts~n", [inputDir()]
      print "outputDir: ~ts~n", [outputDir()]
      print "coverage: ~tp~n", [coverage()]
      dump()
      :ok
  end

  def coverage() do
         :lists.map(fn x -> :application.get_env(:asn1scg,
              {:trace, x}, []) end,:lists.seq(1,30)) end

  def compile(save, file) do
      tokens = :asn1ct_tok.file file
      {:ok, mod} = :asn1ct_parser2.parse file, tokens
      {:module, pos, modname, defid, tagdefault, exports, imports, _, declarations} = mod
      setEnv(:current_module, modname)

      # Pre-pass: Register all defined types to support forward references
      :lists.map(fn
         {:typedef,  _, _, name, _} ->
             swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
             setEnv(name, swiftName)
         {:ptypedef, _, _, name, _args, _} ->
             swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
             setEnv(name, swiftName)
         {:valuedef, _, _, name, _, _, _} ->
             swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
             setEnv(name, swiftName)
          _ -> :ok
      end, declarations)

      # Process imports to register external types
      real_imports = case imports do
          {:imports, i} -> i
          i when is_list(i) -> i
          _ -> []
      end

      :io.format("Processing imports for ~p: ~p~n", [modname, real_imports])

      :lists.map(fn import_def ->
          case import_def do
              {:SymbolsFromModule, _, symbols, module, _objid} ->
                  :io.format("Import: module=~p symbols=~p~n", [module, symbols])
                  modName = normalizeName(importModuleName(module))
                  :lists.map(fn
                      {:Externaltypereference, _, _, type} ->
                          swiftName = bin(modName) <> "_" <> bin(normalizeName(type))
                          setEnvGlobal(type, swiftName)
                      {:Externalvaluereference, _, _, val} ->
                          swiftName = bin(modName) <> "_" <> bin(normalizeName(val))
                          :io.format("Import Value: ~p (~p) -> ~ts~n", [val, is_atom(val), swiftName])
                          setEnvGlobal(val, swiftName)
                      _ -> :ok
                  end, symbols)
              _ -> :ok
          end
      end, real_imports)

      :lists.map(fn
         {:typedef,  _, pos, name, type} ->
             # Check if there's a ptype definition for this type (e.g. Context)
             sname = to_string(name)
             ptypes = Application.get_env(:asn1scg, :ptypes, %{})
             case Map.get(ptypes, sname) do
                 nil -> compileType(pos, name, type, modname, save)
                 definition ->
                     gen_type = build_ptype_ast(pos, definition, modname)
                     compileType(pos, name, gen_type, modname, save)
             end
         {:ptypedef, _, pos, name, args, type} -> compilePType(pos, name, args, type)
         {:classdef, _, pos, name, mod, type} -> compileClass(pos, name, mod, type)
         {:valuedef, _, pos, name, type, value, mod} -> compileValue(pos, name, type, value, mod)
      end, declarations)

  end

  def compileClass(_pos, name, modname, _type) do
      # Add _Class suffix to avoid collision with regular types (e.g., CONTEXT class vs Context type)
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name)) <> "_Class"
      setEnv(name, swiftName)
      save(true, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1Any
""")
  end


  def compileType(pos, name, typeDefinition, modname, save \\ true) do
      res = case typeDefinition do
          {:type, _, {:"INTEGER", cases}, _, _, :no} ->  setEnv(name, "Int") ; integerEnum(name, cases, modname, save)
          {:type, _, {:"ENUMERATED", cases}, _, _, :no} -> enumeration(name, cases, modname, save)
          {:type, _, {:"CHOICE", cases}, _, _, :no} -> choice(name, cases, modname, save)
          {:type, _, {:"SEQUENCE", _, _, _, fields}, _, _, :no} -> sequence(name, fields, modname, save)
          {:type, _, {:"Sequence", _, _, _, fields}, _, _, :no} -> sequence(name, fields, modname, save)
          {:type, _, {:"SET", _, _, _, fields}, _, _, :no} -> set(name, fields, modname, save)
          {:type, _, {:"Set", _, _, _, fields}, _, _, :no} -> set(name, fields, modname, save)
          {:type, _, {:"SEQUENCE OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"Sequence Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"SEQUENCE OF", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} -> array(name, substituteType(lookup(bin(pt_type))), :sequence, "top")
          {:type, _, {:"Sequence Of", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} -> array(name, substituteType(lookup(bin(pt_type))), :sequence, "top")
          {:type, _, {:"SEQUENCE OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"Sequence Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"SET OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"Set Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"SET OF", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} -> array(name, substituteType(lookup(bin(pt_type))), :set, "top")
          {:type, _, {:"Set Of", {:type, _, {:pt, {:Externaltypereference, _, _, pt_type}, _}, _, _, :no}}, _, _, _} -> array(name, substituteType(lookup(bin(pt_type))), :set, "top")
          {:type, _, {:"SET OF", {type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"SEQUENCE OF", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              # e.g. PollReqContent ::= SEQUENCE OF SEQUENCE { ... }
              element_name = bin(name) <> "_Element"
              sequence(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :sequence, "top")
          {:type, _, {:"Sequence Of", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              element_name = bin(name) <> "_Element"
              sequence(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :sequence, "top")
          {:type, _, {:"Set Of", {type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"SET OF", {:type, _, {:SET, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              # e.g. Local-File-References ::= SET OF SET { ... }
              element_name = bin(name) <> "_Element"
              set(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"Set Of", {:type, _, {:SET, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              element_name = bin(name) <> "_Element"
              set(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"Set Of", {:type, _, {:"Set Of", inner_type}, _, _, :no}}, _, _, _} ->
              # e.g. alternative-feature-sets ::= Set Of Set Of OBJECT IDENTIFIER
              element_name = bin(name) <> "_Element"
              array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"SET OF", {:type, _, {:"SET OF", inner_type}, _, _, :no}}, _, _, _} ->
              # e.g. alternative-feature-sets ::= SET OF SET OF OBJECT IDENTIFIER
              element_name = bin(name) <> "_Element"
              array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"SET OF", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              # e.g. Sealed-Doc-Bodyparts ::= SET OF SEQUENCE { ... }
              element_name = bin(name) <> "_Element"
              sequence(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"Set Of", {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no}}, _, _, _} ->
              element_name = bin(name) <> "_Element"
              sequence(element_name, fields, modname, save)
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"SET OF", {:type, _, {:"SET OF", inner_type}, _, _, :no}}, _, _, _} ->
              # e.g. alternative-feature-sets ::= SET OF SET OF OBJECT IDENTIFIER
              element_name = bin(name) <> "_Element"
              array(element_name, substituteType(lookup(bin(inner_type))), :set, "nested")
              element_swift = getSwiftName(element_name, modname)
              array(name, element_swift, :set, "top")
          {:type, _, {:"SET OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
              if bin(name) == "alternative-feature-sets" do
                :io.format("DEBUG alternative-feature-sets matched general SET OF: type=~p~n", [type])
              end
              array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"Set Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:set,"top")

          {:type, _, {:pt, {:Externaltypereference, _, _pt_mod, :'SIGNED'}, [innerType]}, _, [], :no} ->
              tbsName = bin(name) <> "_toBeSigned"
              compileType(pos, tbsName, innerType, modname, save)

              fields = [
                  {:ComponentType, pos, :toBeSigned, {:type, [], {:Externaltypereference, pos, modname, tbsName}, [], [], :no}, [], [], []},
                  {:ComponentType, pos, :algorithmIdentifier, {:type, [], {:Externaltypereference, pos, modname, :'AlgorithmIdentifier'}, [], [], :no}, [], [], []},
                  {:ComponentType, pos, :encrypted, {:type, [], :'BIT STRING', [], [], :no}, [], [], []}
              ]
              sequence(name, fields, modname, save)

          {:type, _, {:pt, {:Externaltypereference, _, pt_mod, pt_type}, args}, _, [], :no} ->
              # Look up parameterized type definition for expansion
              ptype_def = :application.get_env(:asn1scg, {:ptype_def, pt_mod, pt_type}, nil)
              # Check if this is a simple type parameter (not IOC-based)
              has_simple_params = case ptype_def do
                  nil -> false
                  {param_names, _} ->
                      # Only expand if we have simple type parameters (single Externaltypereference)
                      Enum.all?(param_names, fn
                          {:Externaltypereference, _, _, _} -> true
                          _ -> false
                      end)
              end

              case ptype_def do
                  nil ->
                      # Fallback: create typealias to substituted type
                      swiftName = getSwiftName(name, modname)
                      setEnv(name, swiftName)
                      target = substituteType(lookup(bin(pt_type)))
                      save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
                  {_param_names, _template_type} when not has_simple_params ->
                      # Complex IOC-based type - fallback to typealias
                      swiftName = getSwiftName(name, modname)
                      setEnv(name, swiftName)
                      target = substituteType(lookup(bin(pt_type)))
                      save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
                  {param_names, template_type} ->
                      # Expand parameterized type with actual arguments
                      expanded_type = expand_ptype(template_type, param_names, args)
                      compileType(pos, name, expanded_type, modname, save)
              end


          {:type, _, {:"BIT STRING",_}, _, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1BitString
""")
          {:type, _, :'BIT STRING', _, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1BitString
""")
          {:type, _, :'INTEGER', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = Int
""")
          {:type, _, :'NULL', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1Null
""")
          {:type, _, :'ANY', _set, [], :no} -> setEnv(name, "ANY")
          {:type, _, :'OBJECT IDENTIFIER', _set, _constraints, :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              setEnv({:is_oid, swiftName}, true)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1ObjectIdentifier
""")
          {:type, _, :'External', _set, [], :no} -> setEnv(name, "EXTERNAL")
          {:type, _, :'PrintableString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1PrintableString
""")
          {:type, _, :'PrintableString', _set, _constraints, :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1PrintableString
""")
          {:type, _, :'NumericString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1PrintableString
""")
          {:type, _, :'NumericString', _set, _constraints, :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1PrintableString
""")
          {:type, _, :'IA5String', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1IA5String
""")
          {:type, _, :'TeletexString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1TeletexString
""")
          {:type, _, :'UniversalString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1UniversalString
""")
          {:type, _, :'UTF8String', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1UTF8String
""")
          {:type, _, :'VisibleString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1UTF8String
""")
          {:type, _, :'BMPString', _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1BMPString
""")
          {:type, _, {:Externaltypereference, _, _, ext}, _set, [], :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              target = substituteType(lookup(bin(ext)))
              if getEnv({:is_oid, target}, false) or target == "ASN1ObjectIdentifier" do
                 setEnv({:is_oid, swiftName}, true)
              end
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
          {:type, _, {:Externaltypereference, _, _, ext}, _set, _constraints, :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              target = substituteType(lookup(bin(ext)))
              if getEnv({:is_oid, target}, false) or target == "ASN1ObjectIdentifier" do
                 setEnv({:is_oid, swiftName}, true)
              end
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
          {:type, _, type, _set, [], :no} when is_atom(type) ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              target = substituteType(lookup(bin(type)))
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
          {:type, _, type, _set, [], :no} when is_list(type) ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              target = substituteType(lookup(bin(type)))
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
          {:type, _, type, _set, _constraints, :no} when is_list(type) ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              target = substituteType(lookup(bin(type)))
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{target}
""")
          {:type, _, {:ObjectClassFieldType, _, _class, [{:valuefieldreference, :id}], _}, _, _, :no} ->
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              setEnv({:is_oid, swiftName}, true)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1ObjectIdentifier
""")
          {:type, _, {:ObjectClassFieldType, _, _class, field, _} = _type_def, _, _, :no} ->
              # TYPE-IDENTIFIER.&Type patterns -> ASN1Any typealias
              swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
              setEnv(name, swiftName)
              save(save, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = ASN1Any
""")

          {:type, _, {:pt, _, _}, _, [], _} -> :skip
          {:Object, _, _val} -> :skip
          {:Object, _, _, _} -> :skip
          {:ObjectSet, _, _, _, _} -> :skip
          _ -> :skip
      end
      case res do
           :skip -> :io.format("Unhandled type definition ~p: ~p~n", [name, typeDefinition])
               _ -> :skip
      end
  end

  def extractOIDList(val) do
      # :io.format("DEBUG extractOIDList: ~p~n", [val])
      list = if is_list(val), do: val, else: [val]
      Enum.flat_map(list, fn x ->
         if x == :'id-at' or (is_tuple(x) and elem(x, 0) == :Externalvaluereference and elem(x, 3) == :'id-at') do
             :io.format("DEBUG extractOIDList id-at component: ~p~n", [x])
         end
         resolveOIDComponent(x)
      end)
  end

  def resolveOIDComponent({:NamedNumber, _, val}), do: resolveOIDComponent(val)
  def resolveOIDComponent({:seqtag, _, _, _} = val), do: extractOIDList([val])
  def resolveOIDComponent({{:seqtag, _, _, _}, val}), do: resolveOIDComponent(val)

  def resolveOIDComponent({:Externalvaluereference, _, _, :'joint-iso-itu-t'}), do: ["2"]
  def resolveOIDComponent({:Externalvaluereference, _, _, :'joint-iso-ccitt'}), do: ["2"]
  def resolveOIDComponent({:Externalvaluereference, _, _, :iso}), do: ["1"]
  def resolveOIDComponent({:Externalvaluereference, _, _, :'itu-t'}), do: ["0"]
  def resolveOIDComponent({:Externalvaluereference, _, _, :ccitt}), do: ["0"]
  def resolveOIDComponent({:Externalvaluereference, _, mod, name}) do
      current = getEnv(:current_module, "")
      res = if normalizeName(mod) == normalizeName(current) do
          case lookup(name) do
             val when is_binary(val) -> val
             _ -> bin(normalizeName(mod)) <> "_" <> bin(normalizeName(name))
          end
      else
          bin(normalizeName(mod)) <> "_" <> bin(normalizeName(name))
      end
      [res]
  end

  def resolveOIDComponent(:'joint-iso-itu-t'), do: ["2"]
  def resolveOIDComponent(:'joint-iso-ccitt'), do: ["2"]
  def resolveOIDComponent(:iso), do: ["1"]
  def resolveOIDComponent(:'itu-t'), do: ["0"]
  def resolveOIDComponent(:ccitt), do: ["0"]

  def resolveOIDComponent(val) when is_atom(val) do
      res = case lookup(val) do
          :undefined -> val
          found -> found
      end
      if val == :'id-at' do
         :io.format("DEBUG resolveOIDComponent id-at: ~p -> ~p~n", [val, res])
      end
      [res]
  end

  def resolveOIDComponent(val), do: [val]

  def value(name, _type, val, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
      setEnv(name, swiftName)

      components = extractOIDList(val)

      # Check if first component is likely a variable (starts with letter)
      # We rely on the fact that variables in our generation start with uppercase or are atoms resolved to strings.
      # Integers are strings of digits.

      {base, suffix} = case components do
          [h | t] ->
             # If h is a variable name (like "UsefulDefinitions_module"), it won't be numeric.
             # If h is "2", it is numeric.
             if Regex.match?(~r/^\d+$/, to_string(h)) do
                 {nil, components}
             else
                 {h, t}
             end
          [] -> {nil, []}
      end

      definition = cond do
        base && suffix == [] ->
            "public let #{swiftName}: ASN1ObjectIdentifier = #{base}"
        base ->
            suffix_str = Enum.join(suffix, ", ")
            "public let #{swiftName}: ASN1ObjectIdentifier = #{base} + [#{suffix_str}]"
        true ->
            oid_str = Enum.join(components, ", ")
            "public let #{swiftName}: ASN1ObjectIdentifier = [#{oid_str}]"
    end

      save(saveFlag, modname, swiftName <> "_oid", """
#{emitImprint()}
import SwiftASN1
import Foundation

#{definition}
""")
  end

  def compileValue(_pos, name, {:type, [], :'OBJECT IDENTIFIER', [], [], :no} = type, val, mod), do: value(name, type, val, mod, true)
  def compileValue(_pos, name, {:type, _, {:Externaltypereference, _, _, ref}, _, _, _} = type, val, mod) do
      resolved = lookup(bin(ref))
      if resolved == "ASN1ObjectIdentifier" or resolved == "OBJECT IDENTIFIER" or getEnv({:is_oid, resolved}, false) do
          value(name, type, val, mod, true)
      else
          :io.format("Unhandled value definition ~p : ~p = ~p ~n", [name, type, val])
          []
      end
  end
  def compileValue(_pos, name, type, val, _mod), do: (:io.format("Unhandled value definition ~p : ~p = ~p ~n", [name, type, val]) ; [])
  def compileClass(_pos, name, _mod, type),        do: (print "Unhandled class definition ~p : ~p~n", [name, type] ; [])
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
             if args != [], do: :skip, else: compileType(pos, name, type, getEnv(:current_module, ""), true)
         definition ->
             modname = getEnv(:current_module, "")
             gen_type = build_ptype_ast(pos, definition, modname)
             compileType(pos, name, gen_type, modname, true)
      end
  end

  defp build_ptype_ast(pos, {:sequence, fields}, mod) do
      new_fields = Enum.map(fields, fn {name, type, opts} ->
          build_component(pos, name, type, opts, mod)
      end)
      {:type, [], {:SEQUENCE, [], [], [], new_fields}, [], [], :no}
  end

  defp build_ptype_ast(pos, {:choice, cases}, mod) do
      new_cases = Enum.map(cases, fn {name, type} ->
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
      attrs = if tags do
           {cls, num, method} = tags
           cls_atom = cls |> to_string |> String.upcase |> String.to_atom
           method_atom = method |> to_string |> String.upcase |> String.to_atom
           [{:tag, cls_atom, num, method_atom, nil}]
      else
           []
      end

      optional = if Keyword.get(opts, :optional), do: :OPTIONAL, else: []

      type_ast = build_type_ast(pos, type, attrs, mod)
      {:ComponentType, pos, name, type_ast, optional, [], []}
  end

  defp build_type_ast(_pos, :oid, attrs, _mod), do: {:type, attrs, :'OBJECT IDENTIFIER', [], [], :no}
  defp build_type_ast(_pos, :any, attrs, _mod), do: {:type, attrs, :'ANY', [], [], :no}
  defp build_type_ast(_pos, :boolean, attrs, _mod), do: {:type, attrs, :'BOOLEAN', [], [], :no}
  defp build_type_ast(_pos, :octet_string, attrs, _mod), do: {:type, attrs, :'OCTET STRING', [], [], :no}
  defp build_type_ast(_pos, :bit_string, attrs, _mod), do: {:type, attrs, :'BIT STRING', [], [], :no}
  defp build_type_ast(pos, {:set_of, type}, attrs, mod), do: {:type, attrs, {:"SET OF", build_type_ast(pos, type, [], mod)}, [], [], :no}
  defp build_type_ast(pos, {:sequence_of, type}, attrs, mod), do: {:type, attrs, {:"SEQUENCE OF", build_type_ast(pos, type, [], mod)}, [], [], :no}
  defp build_type_ast(pos, {:external, ref_name}, attrs, mod), do: {:type, attrs, {:Externaltypereference, pos, mod, String.to_atom(ref_name)}, [], [], :no}
  defp build_type_ast(_pos, atom, attrs, _mod) when is_atom(atom), do: {:type, attrs, atom, [], [], :no}

  # Parameterized type expansion helpers
  defp expand_ptype(template_type, param_names, args) do
      # Extract parameter name atoms from various structures
      param_name_atoms = Enum.map(param_names, fn
          # Simple type parameter with external reference
          {:Externaltypereference, _, _, pname} -> pname

          # Parameter wrapped in Parameter node
          {:Parameter, _, {:Externaltypereference, _, _, pname}} -> pname
          {:Parameter, _, pname} when is_atom(pname) -> pname

          # IOC pattern: {ClassType, IOSet} - extract the IOSet name
          {{:type, _, {:Externaltypereference, _, _, _class}, _, _, _}, {:Externaltypereference, _, _, ioset_name}} ->
              ioset_name

          # IOC pattern with INTEGER type (for SIZE constraints)
          {{:type, _, :INTEGER, _, _, _}, {:Externalvaluereference, _, _, value_name}} ->
              value_name

          other -> other
      end)

      # Extract argument types from args (could be keyword list or list of types)
      arg_types = Enum.map(args, fn
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

  def getSwiftName(name, modname) do

      nname = bin(normalizeName(name))
      nmod = bin(normalizeName(modname))
      if String.starts_with?(nname, nmod <> "_") do
          nname
      else
          nmod <> "_" <> nname
      end
  end

  def sequence(name, fields, modname, saveFlag) do
      swiftName = getSwiftName(name, modname)
      setEnv(name, swiftName)
      setEnv(:current_struct, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      save(saveFlag, modname, swiftName, emitSequenceDefinition(swiftName,
          emitFields(swiftName, 4, fields, modname), emitCtor(emitParams(swiftName,fields), emitCtorBody(fields)),
          emitSequenceDecoder(emitSequenceDecoderBody(swiftName, fields), swiftName, emitArgs(fields)),
          emitSequenceEncoder(emitSequenceEncoderBody(swiftName, fields))))
  end

  def set(name, fields, modname, saveFlag) do
      swiftName = getSwiftName(name, modname)
      setEnv(name, swiftName)
      setEnv(:current_struct, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      save(saveFlag, modname, swiftName, emitSetDefinition(swiftName,
          emitFields(swiftName, 4, fields, modname), emitCtor(emitParams(swiftName,fields), emitCtorBody(fields)),
          emitSetDecoder(emitSequenceDecoderBody(swiftName, fields), swiftName, emitArgs(fields)),
          emitSequenceEncoder(emitSequenceEncoderBody(swiftName, fields))))
  end

  def choice(name, cases, modname, saveFlag) do
      swiftName = getSwiftName(name, modname)
      setEnv(name, swiftName)

      defId = case cases do
          [{:ComponentType,_,fieldName,{:type,_,type,_,_,_},_,_,_}] ->
               field = fieldType(swiftName, fieldName(fieldName), type)
               t = substituteType(lookup(field))
               "#{t}.defaultIdentifier"
          _ -> ".enumerated"
      end

      save(saveFlag, modname, swiftName, emitChoiceDefinition(swiftName,
          emitCases(swiftName, 4, cases, modname),
          emitChoiceDecoder(emitChoiceDecoderBody(swiftName,cases), swiftName, cases),
          emitChoiceEncoder(emitChoiceEncoderBody(swiftName,cases)), defId))
  end

  def enumeration(name, cases, modname, saveFlag) do
      swiftName = getSwiftName(name, modname)
      setEnv(name, swiftName)
      save(saveFlag, modname, swiftName,
           emitEnumerationDefinition(swiftName,
           emitEnums(swiftName, cases)))
  end

  def integerEnum(name, cases, modname, saveFlag) do
      swiftName = getSwiftName(name, modname)
      setEnv(name, swiftName)
      save(saveFlag, modname, swiftName,
           emitIntegerEnumDefinition(swiftName,
           emitIntegerEnums(cases)))
  end

  def inputDir(),   do: :application.get_env(:asn1scg, "input", "priv/apple/")
  def outputDir(),  do: :application.get_env(:asn1scg, "output", "Sources/ASN1SCG/Suite/")
  def exceptions(), do: :application.get_env(:asn1scg, "exceptions", ["Name"])

  def save(true, _, name, res) do
      dir = outputDir()
      :filelib.ensure_dir(dir)
      norm = normalizeName(bin(name))
      fileName = dir <> norm <> ".swift"
      verbose = getEnv(:verbose, false)
      case :lists.member(norm,exceptions()) do
           true ->  print "skipping: ~ts.swift~n", [fileName] ; setEnv(:verbose, verbose)
           false -> :ok = :file.write_file(fileName,res)      ; setEnv(:verbose, true)
                    print "compiled: ~ts~n", [fileName] ; setEnv(:verbose, verbose) end
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
        val = if mod != "" and is_binary(b) do
           full = bin(normalizeName(mod)) <> "_" <> b
           key = try do String.to_existing_atom(full) rescue _ -> nil end
           v = if key, do: :application.get_env(:asn1scg, key, :undefined), else: :undefined
           if b == "id-at" do
              :io.format("DEBUG lookup id-at local: ~p -> ~p~n", [full, v])
           end
           v
        else :undefined end

        res = case val do
             :undefined ->
                 v = :application.get_env(:asn1scg, b, b)
                 if b == "id-at" do
                    :io.format("DEBUG lookup id-at global: ~p -> ~p~n", [b, v])
                 end
                 v
             v -> v
        end
        case res do
             a when a == b -> bin(a)
             x -> lookup(x)
        end
      end
  end

  def plicit([]), do: ""
  def plicit([{:tag,:CONTEXT,_,{:default,:IMPLICIT},_}]), do: "Implicit"
  def plicit([{:tag,:CONTEXT,_,{:default,:EXPLICIT},_}]), do: "Explicit"
  def plicit([{:tag,:CONTEXT,_,:IMPLICIT,_}]), do: "Implicit"
  def plicit([{:tag,:CONTEXT,_,:EXPLICIT,_}]), do: "Explicit"
  def plicit(_), do: ""

  def opt(:OPTIONAL), do: "?"
  def opt({:DEFAULT, _}), do: "?"
  def opt(_), do: ""
  def spec("sequence"), do: "SequenceOf"
  def spec("set"), do: "SetOf"
  def spec(_), do: ""
  def trace(x), do: setEnv({:trace, x}, x)
  def normalizeName(name) do
    "#{name}"
    |> String.replace("-", "_")
    |> String.replace(".", "_")
  end

  def importModuleName({:Externaltypereference, _, _, mod}), do: mod
  def importModuleName(mod), do: mod
  def setEnv(x,y) do
      mod = getEnv(:current_module, "")
      bx = bin(x)

      if is_binary(bx) and (String.contains?(bx, "subordinate_nodes") or String.contains?(bx, "subordinate-nodes")) do
          :io.format("DEBUG setEnv subordinate: key=~p val=~p~n", [bx, y])
      end

      if bx == "id-ce" or bx == "id_ce" do
          :io.format("DEBUG setEnv for id-ce: mod=~p key=~p val=~p~n", [mod, bx, y])
      end

      if mod != "" and is_binary(bx) do
         full = bin(normalizeName(mod)) <> "_" <> bx
         :application.set_env(:asn1scg, full, y)
         # Also store a normalized variant for lookups that normalize symbols (e.g. replace '-' with '_').
         nxb = normalizeName(bx)
         nfull = bin(normalizeName(mod)) <> "_" <> nxb
         if nfull != full do
            :application.set_env(:asn1scg, nfull, y)
         end
         # :io.format("setEnv: ~ts -> ~ts~n", [full, y])
      end
      :application.set_env(:asn1scg, bx, y)
      if is_binary(bx) do
         nxb = normalizeName(bx)
         if nxb != bx do
            :application.set_env(:asn1scg, nxb, y)
         end
      end
      # :io.format("setEnv: ~ts -> ~ts~n", [bx, y])
  end
  def setEnvGlobal(x, y) do
      bx = bin(x)
      :application.set_env(:asn1scg, bx, y)
      if is_binary(bx) do
         nx = normalizeName(bx)
         if nx != bx do
            :application.set_env(:asn1scg, nx, y)
         end
      end
  end
  def getEnv(x,y), do: :application.get_env(:asn1scg, bin(x), y)
  def bin(x) when is_atom(x), do: :erlang.atom_to_binary x
  def bin(x) when is_list(x), do: :erlang.list_to_binary x
  def bin(x), do: x
  def tagNo([]), do: []
  def tagNo([{:tag,_,nox,_,_}]) do nox end
  def tagClass([]), do: []
  def tagClass([{:tag,:CONTEXT,_,_,_}]),     do: ".contextSpecific" # https://github.com/erlang/otp/blob/master/lib/asn1/src/asn1ct_parser2.erl#L2011
  def tagClass([{:tag,:APPLICATION,_,_,_}]), do: ".application"
  def tagClass([{:tag,:PRIVATE,_,_,_}]),     do: ".private"
  def tagClass([{:tag,:UNIVERSAL,_,_,_}]),   do: ".universal"
  def pad(x), do: String.duplicate(" ", x)
  def partArray(bin), do: part(bin, 1, :erlang.size(bin) - 2)
  def part(a, x, y) do
      case :erlang.size(a) > y - x do
           true -> :binary.part(a, x, y)
              _ -> ""
      end
  end

end

case System.argv() do
  ["compile"]          -> ASN1.compile
  ["compile","-v"]     -> ASN1.setEnv(:verbose, true) ; ASN1.compile
  ["compile",i]        -> ASN1.setEnv(:input, i <> "/") ; ASN1.compile
  ["compile","-v",i]   -> ASN1.setEnv(:input, i <> "/") ; ASN1.setEnv(:verbose, true) ; ASN1.compile
  ["compile",i,o]      -> ASN1.setEnv(:input, i <> "/") ; ASN1.setEnv(:output, o <> "/") ; ASN1.compile
  ["compile","-v",i,o] -> ASN1.setEnv(:input, i <> "/") ; ASN1.setEnv(:output, o <> "/") ; ASN1.setEnv(:verbose, true) ; ASN1.compile
  _ -> :io.format("Copyright © 1994—2024 Namdak Tönpa.~n")
       :io.format("ISO 8824 ITU/IETF X.680-690 ERP/1 ASN.1 DER Compiler, version 30.10.7.~n")
       :io.format("Usage: ./asn1.ex help | compile [-v] [input [output]]~n")
end
