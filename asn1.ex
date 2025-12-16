#!/usr/bin/env elixir

defmodule ASN1 do

  def print(format, params) do
      case :application.get_env(:asn1scg, "save", true) and :application.get_env(:asn1scg, "verbose", false) do
           true -> :io.format(format, params)
              _ -> []
      end
  end

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

       structDef = """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline struct #{fullName}: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .#{tag} }
    @usableFromInline var value: [#{type1}]
    @inlinable public init(_ value: [#{type1}]) { self.value = value }
    @inlinable public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.value = try DER.sequence(of: #{type1}.self, identifier: identifier, rootNode: rootNode)
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.serializeSequenceOf(value, identifier: identifier)
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

  def fieldName({:contentType, {:Externaltypereference,_,_mod, name}}), do: normalizeName("#{name}")
  def fieldName(name), do: normalizeName("#{name}")

  def fieldType(name,field,{:ComponentType,_,_,{:type,_,oc,_,[],:no},_opt,_,_}), do: fieldType(name, field, oc)
  def fieldType(name,field,{:"SEQUENCE", _, _, _, _}), do: bin(name) <> "_" <> bin(field) <> "_Sequence"
  def fieldType(name,field,{:"CHOICE",_}), do: bin(name) <> "_" <> bin(field) <> "_Choice"
  def fieldType(name,field,{:"ENUMERATED",_}), do: bin(name) <> "_" <> bin(field) <> "_Enum"
  def fieldType(name,field,{:"INTEGER",_}), do: bin(name) <> "_" <> bin(field) <> "_IntEnum"
  def fieldType(name,field,{:"SEQUENCE OF", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{field}")  end
  def fieldType(name,field,{:"Sequence Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{field}")  end
  def fieldType(name,field,{:"SET OF", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "pro #{name}.#{field}")  end
  def fieldType(name,field,{:"Set Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "pro #{name}.#{field}")  end
  def fieldType(_,_,{:contentType, {:Externaltypereference,_,_,type}}), do: "#{type}"
  def fieldType(_,_,{:"BIT STRING", _}), do: "ASN1BitString"
  def fieldType(_,_,{:pt, {_,_,_,type}, _}) when is_atom(type), do: "#{type}"
  def fieldType(_,_,{:ANY_DEFINED_BY, type}) when is_atom(type), do: "ASN1Any"
  def fieldType(_name,_field,{:Externaltypereference,_,_,type}) when type == :OrganizationalUnitNames, do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(_name,_field,{:Externaltypereference,_,_,type}), do: "#{substituteType(lookup(bin(type)))}"
  def fieldType(_,_,{:ObjectClassFieldType,_,_,[{_,type}],_}), do: "#{type}"
  def fieldType(_,_,type) when is_atom(type), do: "#{type}"
  def fieldType(name,_,_), do: "#{name}"

  def sequenceOf(name,field,type) do
      sequenceOf2(name,field,type)
  end

  def sequenceOf2(name,field,{:type,_,{:Externaltypereference,_,_,type},_,_,_}), do: "#{sequenceOf(name,field,type)}"
  def sequenceOf2(name,field,{:type,_,{:"SET OF", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "arr #{name}.#{field}")  end
  def sequenceOf2(name,field,{:type,_,{:"Set Of", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "arr #{name}.#{field}")  end
  def sequenceOf2(name,field,{:type,_,{:"SEQUENCE OF", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "arr #{name}.#{field}") end
  def sequenceOf2(name,field,{:type,_,{:"Sequence Of", type},_,_,_}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "arr #{name}.#{field}") end
  def sequenceOf2(name,field,{:type,_,{:CHOICE, cases} = sum,_,_,_}) do choice(fieldType(name,field,sum), cases, getEnv(:current_module, ""), true) ; bin(name) <> "_" <> bin(field) <> "_Choice" end
  def sequenceOf2(name,field,{:type,_,{:SEQUENCE, _, _, _, fields} = product,_,_,_}) do sequence(fieldType(name,field,product), fields, getEnv(:current_module, ""), true) ; bin(name) <> "_" <> bin(field) <> "_Sequence" end
  def sequenceOf2(name,field,{:type,_,type,_,_,_}) do "#{sequenceOf(name,field,type)}" end
  def sequenceOf2(name,_,{:Externaltypereference, _, _, type}) do :application.get_env(:asn1scg, bin(name), bin(type)) end
  def sequenceOf2(_,_,x) when is_tuple(x), do: substituteType("#{bin(:erlang.element(1, x))}")
  def sequenceOf2(_,_,x) when is_atom(x), do: substituteType("#{lookup(x)}")
  def sequenceOf2(_,_,x) when is_binary(x), do: substituteType("#{lookup(x)}")

  def substituteType("TeletexString"),     do: "ASN1TeletexString"
  def substituteType("UniversalString"),   do: "ASN1UniversalString"
  def substituteType("IA5String"),         do: "ASN1IA5String"
  def substituteType("VisibleString"),     do: "ASN1UTF8String"
  def substituteType("UTF8String"),        do: "ASN1UTF8String"
  def substituteType("PrintableString"),   do: "ASN1PrintableString"
  def substituteType("NumericString"),     do: "ASN1PrintableString"
  def substituteType("BMPString"),         do: "ASN1BMPString"
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
  def substituteType(t),                   do: t

  def emitImprint(), do: "// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa."
  def emitArg(name), do: "#{name}: #{name}"
  def emitCtorBodyElement(name), do: "self.#{name} = #{name}"
  def emitCtorParam(name, type, opt \\ ""), do: "#{name}: #{normalizeName(type)}#{opt}"
  def emitCtor(params,fields), do: pad(4) <> "@inlinable init(#{params}) {\n#{fields}\n    }\n"
  def emitEnumElement(_type, field, value), do: pad(4) <> "static let #{field} = Self(rawValue: #{value})\n"
  def emitIntegerEnumElement(field, value), do: pad(4) <> "public static let #{field} = Self(rawValue: #{value})\n"
  def emitOptional(:OPTIONAL, name, body), do: "if let #{name} = self.#{name} { #{body} }"
  def emitOptional(_, _, body), do: "#{body}"
  def emitSequenceElementOptional(name, type, opt \\ ""), do: "@usableFromInline var #{name}: #{lookup(normalizeName(type))}#{opt}\n"

  # Vector Decoder

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Implicit", do:
      "let #{name}: #{type}? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Explicit", do:
      "let #{name}: #{type}? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Explicit", do:
      "let #{name}: #{type} = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Implicit", do:
      "let #{name}: #{type} = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific)))!"
  def emitSequenceDecoderBodyElement(:OPTIONAL, _, _, name, "ASN1Any"), do:
      "let #{name}: ASN1Any? = nodes.next().map { ASN1Any(derEncoded: $0) }"
  def emitSequenceDecoderBodyElement(_, _, _, name, "Bool"), do:
      "let #{name}: Bool = try DER.decodeDefault(&nodes, defaultValue: false)"
  def emitSequenceDecoderBodyElement(optional, _, _, name, type), do:
      "let #{name}: #{type}#{opt(optional)} = try #{type}(derEncoded: &nodes)"

  def emitSequenceDecoderBodyElementArray(:OPTIONAL, plicit, no, name, type, spec) when plicit == "Explicit" and no != [] and (spec == "set" or spec == "sequence"), do:
      "let #{name}: [#{type}]? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, rootNode: node) }"
  def emitSequenceDecoderBodyElementArray(_, plicit, no, name, type, spec) when plicit == "Implicit" and no != [] and (spec == "set" or spec == "sequence"), do:
      "let #{name}: [#{type}] = try DER.#{spec}(of: #{type}.self, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific), nodes: &nodes)"
  def emitSequenceDecoderBodyElementArray(_, _, no, name, type, spec) when no != [] and (spec == "set" or spec == "sequence"), do:
      "let #{name}: [#{type}] = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, rootNode: node) }"
  def emitSequenceDecoderBodyElementArray(optional, _, no, name, type, spec) when no == [], do:
      "let #{name}: [#{type}]#{opt(optional)} = try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, nodes: &nodes)"
  def emitSequenceDecoderBodyElementIntEnum(name, type), do:
      "let #{name} = try #{type}(rawValue: Int(derEncoded: &nodes))"

  # Vector Encoder

  def emitSequenceEncoderBodyElement(_, plicit, no, name, s) when plicit == "Explicit" and no != [] and (s == "set" or s == "sequence"), do:
      "try coder.serialize(explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific) { codec in try codec.serialize#{spec(s)}(#{name}) }"
  def emitSequenceEncoderBodyElement(_, plicit, no, name, s) when plicit == "Implicit" and no != [] and (s == "set" or s == "sequence"), do:
      "try coder.serialize#{spec(s)}(#{name}, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
  def emitSequenceEncoderBodyElement(_, plicit, no, name, _) when no != [] and plicit == "Implicit", do:
      "try coder.serializeOptionalImplicitlyTagged(#{name}, withIdentifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
  def emitSequenceEncoderBodyElement(_, plicit, no, name, _) when no != [] and plicit == "Explicit", do:
      "try coder.serialize(explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific) { codec in try codec.serialize(#{name}) }"
  def emitSequenceEncoderBodyElement(_, _, no, name, spec) when spec == "sequence" and no == [], do:
      "try coder.serializeSequenceOf(#{name})"
  def emitSequenceEncoderBodyElement(_, _, no, name, spec) when spec == "set" and no == [], do:
      "try coder.serializeSetOf(#{name})"
  def emitSequenceEncoderBodyElement(_, _, no, name, _) when no == [], do:
      "try coder.serialize(#{name})"
  def emitSequenceEncoderBodyElementIntEnum(no, name) when no == [], do:
      "try coder.serialize(#{name}.rawValue)"
  def emitSequenceEncoderBodyElementIntEnum(no, name), do:
      "try coder.serialize(#{name}.rawValue, explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific)"

  # Scalar Sum Component

  def emitChoiceElement(name, type), do: "case #{name}(#{lookup(bin(normalizeName(type)))})\n"
  def emitChoiceEncoderBodyElement(w, no, name, _type, spec, _plicit) when no == [], do:
      pad(w) <> "case .#{name}(let #{name}): try coder.serialize#{spec}(#{name})"
  def emitChoiceEncoderBodyElement(w, no, name, _type, spec, plicit) do
      tag = "ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)})"
      if plicit == "Explicit" do
         pad(w) <> "case .#{name}(let #{name}): try coder.appendConstructedNode(identifier: #{tag}) { coder in try #{name}.serialize(into: &coder) }"
      else
          if spec == "" do
            pad(w) <> "case .#{name}(let #{name}): try #{name}.serialize(into: &coder, withIdentifier: #{tag})"
          else
            pad(w) <> "case .#{name}(let #{name}): try coder.serialize#{spec}(#{name}, identifier: #{tag})"
          end
      end
  end
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec) when no == [], do:
      pad(w) <> "case #{normalizeName(type)}.defaultIdentifier:\n" <>
      pad(w+4) <> "self = .#{name}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{name}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"

  # Vector Sum Component

  def emitChoiceDecoderBodyElementForArray(w, no, name, type, spec) when no == [], do:
      pad(w) <> "case ASN1Identifier.#{spec}:\n" <>
      pad(w+4) <> "self = .#{name}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, rootNode: rootNode))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec) when spec == "", do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{name}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, nodes: &nodes))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{name}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: rootNode.identifier, rootNode: rootNode))"

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
                    # DER: Do not encode fields with DEFAULT values when they match the default
                    "if #{fieldName(fieldName)} { try coder.serialize(#{fieldName(fieldName)}) }"
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
              _ ->  trace(25)
                    emitSequenceEncoderBodyElement(optional, plicit(tag), tagNo(tag), fieldName(fieldName), "")
           end
           pad(12) <> emitOptional(optional, fieldName(fieldName), res)
         _ -> ""
      end, fields), "\n")

  def emitParams(name,fields) when is_list(fields) do
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(26)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitParams(n,inclusion)
        {:ComponentType,_,fieldName,{:type,_,type,_elementSet,[],:no},optional,_,_} ->
           trace(27)
           emitCtorParam(fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,type))), opt(optional))
         _ -> ""
      end, fields), ", ")
  end

  def emitArgs(fields) when is_list(fields) do
      Enum.join(:lists.map(fn
        {:"COMPONENTS OF", {:type, _, {_,_,_,n}, _, _, :no}} ->
           trace(28)
           inclusion = :application.get_env(:asn1scg, {:type,lookup(n)}, [])
           emitArgs(inclusion)
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           trace(29)
           emitArg(fieldName(fieldName))
         _ ->  ""
      end, fields), ", ")
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
                  # :io.format("Import: module=~p symbols=~p~n", [module, symbols])
                  modName = normalizeName(module)
                  :lists.map(fn
                      {:Externaltypereference, _, _, type} ->
                          swiftName = bin(modName) <> "_" <> bin(normalizeName(type))
                          setEnv(type, swiftName)
                      {:Externalvaluereference, _, _, val} ->
                          swiftName = bin(modName) <> "_" <> bin(normalizeName(val))
                          :io.format("Import Value: ~p (~p) -> ~ts~n", [val, is_atom(val), swiftName])
                          setEnv(val, swiftName)
                      _ -> :ok
                  end, symbols)
              _ -> :ok
          end
      end, real_imports)

      :lists.map(fn
         {:typedef,  _, pos, name, type} -> compileType(pos, name, type, modname, save)
         {:ptypedef, _, pos, name, args, type} -> compilePType(pos, name, args, type)
         {:classdef, _, pos, name, mod, type} -> compileClass(pos, name, mod, type)
         {:valuedef, _, pos, name, type, value, mod} -> compileValue(pos, name, type, value, mod)
      end, declarations)
      compileModule(pos, modname, defid, tagdefault, exports, imports)
  end

  def compileType(pos, name, typeDefinition, modname, save \\ true) do
      res = case typeDefinition do
          {:type, _, {:"INTEGER", cases}, _, [], :no} ->  setEnv(name, "Int") ; integerEnum(name, cases, modname, save)
          {:type, _, {:"ENUMERATED", cases}, _, [], :no} -> enumeration(name, cases, modname, save)
          {:type, _, {:"CHOICE", cases}, _, [], :no} -> choice(name, cases, modname, save)
          {:type, _, {:"SEQUENCE", _, _, _, fields}, _, _, :no} -> sequence(name, fields, modname, save)
          {:type, _, {:"Sequence", _, _, _, fields}, _, _, :no} -> sequence(name, fields, modname, save)
          {:type, _, {:"SET", _, _, _, fields}, _, _, :no} -> set(name, fields, modname, save)
          {:type, _, {:"Set", _, _, _, fields}, _, _, :no} -> set(name, fields, modname, save)
          {:type, _, {:"SEQUENCE OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"Sequence Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"SEQUENCE OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"Sequence Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:sequence,"top")
          {:type, _, {:"SET OF", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"Set Of", {:type, _, type, _, _, :no}}, _, _, _} when is_atom(type) -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"SET OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:"Set Of", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} -> array(name,substituteType(lookup(bin(type))),:set,"top")
          {:type, _, {:pt, {:Externaltypereference, _, _, :'SIGNED'}, [innerType]}, _, [], :no} ->
              tbsName = bin(name) <> "_toBeSigned"
              compileType(pos, tbsName, innerType, modname, save)

              fields = [
                  {:ComponentType, pos, :toBeSigned, {:type, [], {:Externaltypereference, pos, modname, tbsName}, [], [], :no}, [], [], []},
                  {:ComponentType, pos, :algorithmIdentifier, {:type, [], {:Externaltypereference, pos, modname, :'AlgorithmIdentifier'}, [], [], :no}, [], [], []},
                  {:ComponentType, pos, :encrypted, {:type, [], :'BIT STRING', [], [], :no}, [], [], []}
              ]
              sequence(name, fields, modname, save)
          {:type, _, {:"BIT STRING",_}, _, [], :no} -> setEnv(name, "BIT STRING")
          {:type, _, :'BIT STRING', _, [], :no} -> setEnv(name, "BIT STRING")
          {:type, _, :'INTEGER', _set, [], :no} -> setEnv(name, "INTEGER")
          {:type, _, :'NULL', _set, [], :no} -> setEnv(name, "NULL")
          {:type, _, :'ANY', _set, [], :no} -> setEnv(name, "ANY")
          {:type, _, :'EXTERNAL', _set, [], :no} -> setEnv(name, "EXTERNAL")
          {:type, _, :'External', _set, [], :no} -> setEnv(name, "EXTERNAL")
          {:type, _, :'PrintableString', _set, [], :no} -> setEnv(name, "PrintableString")
          {:type, _, :'NumericString', _set, [], :no} -> setEnv(name, "PrintableString")
          {:type, _, :'IA5String', _set, [], :no} -> setEnv(name, "IA5String")
          {:type, _, :'TeletexString', _set, [], :no} -> setEnv(name, "TeletexString")
          {:type, _, :'UniversalString', _set, [], :no} -> setEnv(name, "UniversalString")
          {:type, _, :'OBJECT IDENTIFIER', _, _, :no} -> setEnv(name, "OBJECT IDENTIFIER")
          {:type, _, :'OCTET STRING', [], [], :no} -> setEnv(name, "OCTET STRING")
          {:type, _, {:Externaltypereference, _, _, ext}, _set, [], _} -> setEnv(name, ext)
          {:type, _, {:pt, _, _}, _, [], _} -> :skip
          {:type, _, {:ObjectClassFieldType, _, _, _, _fields}, _, _, :no} -> :skip
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
      list = if is_list(val), do: val, else: [val]
      Enum.flat_map(list, &resolveOIDComponent/1)
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
      res = bin(normalizeName(mod)) <> "_" <> bin(normalizeName(name))
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

      save(saveFlag, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

#{definition}
""")
  end

  def compileValue(_pos, name, {:type, [], :'OBJECT IDENTIFIER', [], [], :no} = type, val, mod), do: value(name, type, val, mod, true)
  def compileValue(_pos, name, {:type, _, {:Externaltypereference, _, _, ref}, _, _, _} = type, val, mod) do
      resolved = lookup(bin(ref))
      if resolved == "ASN1ObjectIdentifier" or resolved == "OBJECT IDENTIFIER" do
          value(name, type, val, mod, true)
      else
          :io.format("Unhandled value definition ~p : ~p = ~p ~n", [name, type, val])
          []
      end
  end
  def compileValue(_pos, name, type, val, _mod), do: (:io.format("Unhandled value definition ~p : ~p = ~p ~n", [name, type, val]) ; [])
  def compileClass(_pos, name, _mod, type),        do: (print "Unhandled class definition ~p : ~p~n", [name, type] ; [])
  def compilePType(_pos, name, args, type),        do: (print "Unhandled PType definition ~p : ~p(~p)~n", [name, type, args] ; [])
  def compileModule(_pos, _name, _defid, _tagdefault, _exports, _imports), do: []

  def sequence(name, fields, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
      setEnv(name, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      save(saveFlag, modname, swiftName, emitSequenceDefinition(swiftName,
          emitFields(name, 4, fields, modname), emitCtor(emitParams(name,fields), emitCtorBody(fields)),
          emitSequenceDecoder(emitSequenceDecoderBody(name, fields), swiftName, emitArgs(fields)),
          emitSequenceEncoder(emitSequenceEncoderBody(name, fields))))
  end

  def set(name, fields, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
      setEnv(name, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      save(saveFlag, modname, swiftName, emitSetDefinition(swiftName,
          emitFields(name, 4, fields, modname), emitCtor(emitParams(name,fields), emitCtorBody(fields)),
          emitSetDecoder(emitSequenceDecoderBody(name, fields), swiftName, emitArgs(fields)),
          emitSequenceEncoder(emitSequenceEncoderBody(name, fields))))
  end

  def choice(name, cases, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
      setEnv(name, swiftName)

      defId = case cases do
          [{:ComponentType,_,fieldName,{:type,_,type,_,_,_},_,_,_}] ->
               field = fieldType(name, fieldName(fieldName), type)
               t = substituteType(lookup(field))
               "#{t}.defaultIdentifier"
          _ -> ".enumerated"
      end

      save(saveFlag, modname, swiftName, emitChoiceDefinition(swiftName,
          emitCases(name, 4, cases, modname),
          emitChoiceDecoder(emitChoiceDecoderBody(name,cases), name, cases),
          emitChoiceEncoder(emitChoiceEncoderBody(name,cases)), defId))
  end

  def enumeration(name, cases, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
      setEnv(name, swiftName)
      save(saveFlag, modname, swiftName,
           emitEnumerationDefinition(swiftName,
           emitEnums(swiftName, cases)))
  end

  def integerEnum(name, cases, modname, saveFlag) do
      swiftName = bin(normalizeName(modname)) <> "_" <> bin(normalizeName(name))
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

  def lookup(name) do
      b = bin(name)
      if String.starts_with?(b, "[") and String.ends_with?(b, "]") and String.length(b) > 2 do
         inner = String.slice(b, 1..-2//1)
         "[" <> lookup(inner) <> "]"
      else
        mod = getEnv(:current_module, "")
        val = if mod != "" and is_binary(b) do
           full = bin(normalizeName(mod)) <> "_" <> b
           :application.get_env(:asn1scg, full, :undefined)
        else :undefined end

        res = case val do
             :undefined -> :application.get_env(:asn1scg, b, b)
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
  def setEnv(x,y) do
      mod = getEnv(:current_module, "")
      bx = bin(x)

      if bx == "id-ce" or bx == "id_ce" do
          :io.format("DEBUG setEnv for id-ce: mod=~p key=~p val=~p~n", [mod, bx, y])
      end

      if mod != "" and is_binary(bx) do
         full = bin(normalizeName(mod)) <> "_" <> bx
         :application.set_env(:asn1scg, full, y)
         # :io.format("setEnv: ~ts -> ~ts~n", [full, y])
      end
      :application.set_env(:asn1scg, bx, y)
      # :io.format("setEnv: ~ts -> ~ts~n", [bx, y])
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
