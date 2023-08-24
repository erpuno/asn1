#!/usr/bin/env elixir

defmodule CHAT.ASN1 do

  def dir(), do: :application.get_env(:asn1scg, :input, "priv/apple/")

  def fieldName({:contentType, {:Externaltypereference,_,_mod, name}}), do: normalizeName("#{name}")
  def fieldName(name), do: normalizeName("#{name}")
  def fieldType(name,field,{:ComponentType,_,_,{:type,_,oc,_,[],:no},_opt,_,_}), do: fieldType(name, field, oc)
  def fieldType(name,field,{:SEQUENCE, _, _, _, _}), do: bin(name) <> "_" <> bin(field) <> "_Sequence"
  def fieldType(name,field,{:CHOICE,_}), do: bin(name) <> "_" <> bin(field) <> "_Choice"
  def fieldType(name,field,{:ENUMERATED,_}), do: bin(name) <> "_" <> bin(field) <> "_Enum"
  def fieldType(_,_,{:pt, {_,_,_,type}, _}) when is_atom(type), do: "#{type}"
  def fieldType(_,_,{:ANY_DEFINED_BY, type}) when is_atom(type), do: "ASN1Any"
  def fieldType(_,_,{:contentType, {:Externaltypereference,_,_,type}}), do: "#{type}"
  def fieldType(_,_,{:Externaltypereference,_,_,type}), do: "#{type}"
  def fieldType(_,_,{:ObjectClassFieldType,_,_,[{_,type}],_}), do: "#{type}"
  def fieldType(_,_,{:"BIT STRING", _}), do: "ASN1BitString"
  def fieldType(name,field,{:"SEQUENCE OF", type}), do: sequenceOf(name,field,type)
  def fieldType(name,field,{:"SET OF",{:type,_,{:"SEQUENCE", _, _, _,types},_,_,_}}), do: 
      Enum.join(:lists.map(fn x -> fieldType(name, field, x) end, types), "->")
  def fieldType(name,field,{:"SET OF",{:type,_,external,_,_,_}}), do: fieldType(name, field, external)
  def fieldType(_,_,type) when is_atom(type), do: "#{type}"
  def fieldType(name,_,_), do: "#{name}"

  def sequenceOf(name,field,{:type,_,{:Externaltypereference,_,_,type},_,_,_}), do: "[#{sequenceOf(name,field,type)}]"
  def sequenceOf(name,field,{:type,_,{:CHOICE, cases} = sum,_,_,_}) do
      choice(fieldType(name,field,sum), cases, [], true) ; "[" <> bin(name) <> "_" <> bin(field) <> "_Choice]" end
  def sequenceOf(name,field,{:type,_,{:SEQUENCE, _, _, _, fields} = product,_,_,_}) do
      sequence(fieldType(name,field,product), fields, [], true) ; "[" <> bin(name) <> "_" <> bin(field) <> "_Sequence]" end
  def sequenceOf(name,field,{:type,_,type,_,_,_}), do: "[#{sequenceOf(name,field,type)}]"
  def sequenceOf(_,_,{:Externaltypereference, _, _, name}), do: :application.get_env(:asn1scg, bin(name), bin(name))
  def sequenceOf(_,_,x) when is_tuple(x), do: substituteType(bin(:erlang.element(1, x)))
  def sequenceOf(_,_,x) when is_atom(x), do: substituteType("#{x}")
  def sequenceOf(_,_,x) when is_binary(x), do: substituteType("#{x}")

  def substituteType("INTEGER"),           do: "ArraySlice<UInt8>"
  def substituteType("OCTET STRING"),      do: "ASN1OctetString"
  def substituteType("BIT STRING"),        do: "ASN1BitString"
  def substituteType("OBJECT IDENTIFIER"), do: "ASN1Identifier"
  def substituteType("BOOLEAN"),           do: "Bool"
  def substituteType("pt"),                do: "ASN1Any"
  def substituteType("NULL"),              do: "ASN1Null"
  def substituteType("URI"),               do: "ASN1OctetString"
  def substituteType(t),                   do: t

  def emitGenerated(), do: "// This file is autogenerated by ASN1.ERP.UNO. Do not edit.\n"
  def emitArg(name), do: "#{name}: #{name}"
  def emitCtor(params,fields), do: "    @inlinable init(#{params}) {\n#{fields}\n    }\n"
  def emitCtorBodyElement(name), do: "self.#{name} = #{name}"
  def emitCtorParam(name, type), do: "#{name}: #{normalizeName(type)}"
  def emitSequenceElement(name, type), do: "@usableFromInline var #{name}: #{normalizeName(type)}\n"
  def emitSequenceEncoderBodyElement(name), do: "try coder.serialize(self.#{name})"
  def emitSequenceEncoderBodyElementArray(name), do: "try coder.serializeSequenceOf(#{name})"
  def emitSequenceEncoderBodyElementArrayOptional(name), do: "if let #{name} = self.#{name} { try coder.serializeSequenceOf(#{name}) }"
  def emitSequenceDecoderBodyElement(name, type), do: "let #{name} = try #{type}(derEncoded: &nodes)"
  def emitSequenceDecoderBodyElementForSequence(name, type), do: "let #{name} = try DER.sequence(of: #{type}.self, identifier: .sequence, nodes: &nodes)"
  def emitChoiceElement(name, type), do: "case #{name}(#{type})\n"
  def emitChoiceEncoderBodyElement(pad, name), do: String.duplicate(" ", pad) <> "case .#{name}(let #{name}): try coder.serialize(#{name})"
  def emitChoiceEncoderBodyElement(pad, no, name), do:
      String.duplicate(" ", pad) <> "case .#{name}(let #{name}):\n" <>
      String.duplicate(" ", pad+4) <> "try coder.appendConstructedNode(\n" <>
      String.duplicate(" ", pad+4) <> "identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific),\n" <>
      String.duplicate(" ", pad+4) <> "{ coder in try coder.serialize(#{name}) })"
  def emitChoiceDecoderBodyElement(pad, name, type), do:
      String.duplicate(" ", pad) <> "case #{type}.defaultIdentifier:\n" <>
      String.duplicate(" ", pad+4) <> "self = .#{name}(try #{type}(derEncoded: rootNode))"
  def emitChoiceDecoderBodyElement(pad, no,  name, type), do:
      String.duplicate(" ", pad) <> "case ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific):\n" <>
      String.duplicate(" ", pad+4) <> "self = .#{name}(try #{type}(derEncoded: rootNode))"
  def emitEnumElement(type, field, value), do: "    static let #{field} = #{type}(rawValue: #{value})\n"
  def emitIntegerEnumElement(field, value), do: "    public static let #{field} = Self(rawValue: #{value})\n"

  def emitSequenceDefinition(name,fields,ctor,decoder,encoder), do:
"""
#{emitGenerated()}
import ASN1SCG\nimport SwiftASN1\nimport Crypto\nimport Foundation\n
@usableFromInline struct #{name}: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }\n#{fields}#{ctor}#{decoder}#{encoder}}
"""


  def emitChoiceDefinition(name,cases,decoder,encoder), do:
"""
#{emitGenerated()}
import ASN1SCG\nimport SwiftASN1\nimport Crypto\nimport Foundation\n
@usableFromInline indirect enum #{name}: DERParseable, DERSerializable, Hashable, Sendable {
#{cases}#{decoder}#{encoder}
}
"""

  def emitEnumerationDefinition(name,cases), do:
"""
#{emitGenerated()}
import ASN1SCG\nimport SwiftASN1\nimport Crypto\nimport Foundation\n
public struct #{name}: DERImplicitlyTaggable, Hashable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
#{cases}
}
"""

  def emitIntegerEnumDefinition(name,cases), do:
"""
#{emitGenerated()}
public struct #{name} {
    @usableFromInline  var rawValue: Int
    @inlinable init(rawValue: Int) { self.rawValue = rawValue }
#{cases}
}
"""

  def emitChoiceDecoder(cases), do:
"""
    @inlinable init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {\n#{cases}
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
"""

  def emitChoiceEncoder(cases), do:
"""
    @inlinable func serialize(into coder: inout DER.Serializer) throws {
        switch self {\n#{cases}
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
           emitIntegerEnumElement(fieldName, fieldValue)
         _ -> ""
      end, cases), "")
  end

  def emitEnums(name, cases) when is_list(cases) do
      Enum.join(:lists.map(fn 
        {:NamedNumber, fieldName, fieldValue} ->
           emitEnumElement(name, fieldName(fieldName), fieldValue)
         _ -> ""
      end, cases), "")
  end

  def emitCases(name, pad, cases) when is_list(cases) do
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,fieldType,_elementSet,[],:no},_optional,_,_} ->
           field = fieldType(name, fieldName, fieldType)
           String.duplicate(" ", pad) <> emitChoiceElement(fieldName(fieldName), substituteType(lookup(field)))
         _ -> ""
      end, cases), "")
  end

  def emitFields(name, pad, fields, modname) when is_list(fields) do
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,fieldType,_elementSet,[],:no},_optional,_,_} ->
           field = fieldType(name, fieldName, fieldType)
           case fieldType do
              {:SEQUENCE, _, _, _, fields} ->
                 sequence(fieldType(name,fieldName,fieldType), fields, modname, true)
              {:CHOICE, cases} ->
                 choice(fieldType(name,fieldName,fieldType), cases, modname, true)
              {:ENUMERATED, cases} ->
                 enumeration(fieldType(name,fieldName,fieldType), cases, modname, true)
              {:"SEQUENCE OF", {:type, [], {:SEQUENCE, _, _, _, fields} = product, _, _, _}} ->
                 sequence(fieldType(name,fieldName,product), fields, [], true)
              {:"SEQUENCE OF", {:type, [], {:CHOICE, cases}, _, _, _} = sum} ->
                 choice(fieldType(name,fieldName,sum), cases, [], true)
              _ -> :skip
           end
           String.duplicate(" ", pad) <> emitSequenceElement(fieldName(fieldName), substituteType(lookup(field)))
        {:ComponentType,_,fieldName,fieldType,_optional,_,_} when is_binary(fieldType) or is_atom(fieldType) ->
           field = fieldType(name, fieldName, bin(fieldType))
           String.duplicate(" ", pad) <> emitSequenceElement(fieldName(fieldName), substituteType(lookup(field)))
         _ -> ""
      end, fields), "")
  end

  def emitCtorBody(fields), do:
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           String.duplicate(" ", 8) <> emitCtorBodyElement(fieldName(fieldName))
         _ -> ""
      end, fields), "\n")

  def emitChoiceEncoderBody(cases), do:
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,tag,_type,_elementSet,[],:no},_optional,_,_} ->
           case tag do
                [] -> emitChoiceEncoderBodyElement(12, fieldName(fieldName))
                [{:tag,:CONTEXT,no,_explicit,_}] -> emitChoiceEncoderBodyElement(12, no, fieldName(fieldName))
           end
         _ -> ""
      end, cases), "\n")

  def emitChoiceDecoderBody(cases), do:
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,tag,type,_elementSet,[],:no},_optional,_,_} ->
           case tag do
                [] -> emitChoiceDecoderBodyElement(12, fieldName(fieldName), substituteType(lookup(fieldType("", fieldName, type))))
                [{:tag,:CONTEXT,no,_explicit,_}] -> emitChoiceDecoderBodyElement(12, no, fieldName(fieldName), substituteType(lookup(fieldType("", fieldName, type))))
           end
         _ -> ""
      end, cases), "\n")

  def emitSequenceEncoderBody(_name, fields), do:
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,{_,_,_,x},_elementSet,[],:no},_optional,_,_} ->
           body = case :binary.part(lookup(bin(x)),0,1) do
                "[" -> emitSequenceEncoderBodyElementArray(fieldName(fieldName))
                _ -> emitSequenceEncoderBodyElement(fieldName(fieldName))
           end
           String.duplicate(" ", 12) <> body
        {:ComponentType,_,fieldName,{:type,_,{:"SEQUENCE OF", {:type, [], {:CHOICE, _cases}, _, _, _}},_elementSet,[],:no},_optional,_,_} ->
           body = emitSequenceEncoderBodyElementArray(fieldName(fieldName))
           String.duplicate(" ", 12) <> body
        {:ComponentType,_,fieldName,{:type,_,{:"SEQUENCE OF", {:type, [], {:SEQUENCE, _, _, _, _fields}, _, _, _}},_elementSet,[],:no},_optional,_,_} ->
           body = emitSequenceEncoderBodyElementArray(fieldName(fieldName))
           String.duplicate(" ", 12) <> body
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           String.duplicate(" ", 12) <> emitSequenceEncoderBodyElement(fieldName(fieldName))
         _ -> ""
      end, fields), "\n")

  def emitSequenceDecoderBody(name,fields), do:
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,type,_elementSet,[],:no},_optional,_,_} ->
           case type do
                {:"SEQUENCE OF", {:type, _, innerType, _, _, _}} ->
                    String.duplicate(" ", 12) <>
                    emitSequenceDecoderBodyElementForSequence(fieldName(fieldName),
                       substituteType(lookup(fieldType(name,fieldName,innerType))))
                {:Externaltypereference,_,_,inner} ->
                    bin = lookup(fieldType(name,fieldName,inner))
                    body = case :binary.part(bin,0,1) do
                       "[" -> emitSequenceDecoderBodyElementForSequence(fieldName(fieldName), :binary.part(bin,1,:erlang.size(bin)-2))
                         _ -> emitSequenceDecoderBodyElement(fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,type))))
                    end
                    String.duplicate(" ", 12) <> body
              _ ->  String.duplicate(" ", 12) <> emitSequenceDecoderBodyElement(fieldName(fieldName), substituteType(lookup(fieldType(name,fieldName,type))))

          end
         _z -> ""
      end, fields), "\n")

  def emitParams(name,fields) when is_list(fields) do
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,type,_elementSet,[],:no},_optional,_,_} ->
           emitCtorParam(fieldName(fieldName),
              substituteType(lookup(fieldType(name,fieldName,type))))
         _ -> ""
      end, fields), ", ")
  end

  def emitArgs(fields) when is_list(fields) do
      Enum.join(:lists.map(fn 
        {:ComponentType,_,fieldName,{:type,_,_type,_elementSet,[],:no},_optional,_,_} ->
           emitArg(fieldName(fieldName))
         _ ->  ""
      end, fields), ", ")
  end

  def compile_all() do
      {:ok, files} = :file.list_dir dir()
      :lists.map(fn file -> compile(false, dir() <> :erlang.list_to_binary(file))  end, files)
      :lists.map(fn file -> compile(true,  dir() <> :erlang.list_to_binary(file))  end, files)
      :ok
  end

  def save(true, _, name, res) do
      dir = :application.get_env(:asn1scg, :output, "Sources/ASN1SCG/")
      :filelib.ensure_dir(dir)
      fileName = dir <> normalizeName(name) <> ".swift"
      :file.write_file(fileName,res)
  end
  def save(_, _, _, _), do: []

  def sequence(name, fields, modname, saveFlag) do
      save(saveFlag, modname, name, emitSequenceDefinition(normalizeName(name),
          emitFields(name, 4, fields, modname), emitCtor(emitParams(name,fields), emitCtorBody(fields)),
          emitSequenceDecoder(emitSequenceDecoderBody(name, fields), name, emitArgs(fields)),
          emitSequenceEncoder(emitSequenceEncoderBody(name, fields))))
  end

  def choice(name, cases, modname, saveFlag) do
      save(saveFlag, modname, name, emitChoiceDefinition(normalizeName(name),
          emitCases(name, 4, cases),
          emitChoiceDecoder(emitChoiceDecoderBody(cases)),
          emitChoiceEncoder(emitChoiceEncoderBody(cases))))
  end

  def enumeration(name, cases, modname, saveFlag) do
      save(saveFlag, modname, "#{name}",
           emitEnumerationDefinition(normalizeName(name),
           emitEnums(name, cases)))
  end

  def integerEnum(name, cases, modname, saveFlag) do
      save(saveFlag, modname, name,
           emitIntegerEnumDefinition(normalizeName(name),
           emitIntegerEnums(cases)))
  end

  def compileType(_, name, typeDefinition, modname, save \\ true) do
      res = case typeDefinition do
          {:type, _, {:ENUMERATED, cases}, [], [], :no} -> enumeration(name, cases, modname, save)
          {:type, _, {:SEQUENCE, _, _, _, fields}, _, _, :no} -> sequence(name, fields, modname, save)
          {:type, _, {:CHOICE, cases}, [], [], :no} -> choice(name, cases, modname, save)
          {:type, _, :INTEGER, _set, [], :no} -> :application.set_env(:asn1scg, bin(name), "INTEGER")
          {:type, _, :NULL, _set, [], :no} -> :application.set_env(:asn1scg, bin(name), "NULL")
          {:type, _, {:INTEGER, cases}, [], [], :no} -> integerEnum(name, cases, modname, save)
          {:type, _, {:"SEQUENCE OF", {:type, _, {_, _, _, type}, _, _, _}}, _, _, _} ->
                     :application.set_env(:asn1scg, bin(name), "[" <> substituteType(lookup(type)) <> "]")
          {:type, _, :"OCTET STRING", [], [], :no} -> :application.set_env(:asn1scg, bin(name), "OCTET STRING")
          {:type, _, :"BIT STRING", [], [], :no} -> :application.set_env(:asn1scg, bin(name), "BIT STRING")
          {:type, _, {:"BIT STRING",_}, [], [], :no} -> :application.set_env(:asn1scg, bin(name), "BIT STRING")
          {:type, _, {:"SET OF", _type}, _elementSet, [], :no} -> :ok
          {:type, _, :"OBJECT IDENTIFIER", _, _, :no} -> :ok
          {:type, _, {:ObjectClassFieldType, _, _, _, _fields}, _, _, :no} -> :skip
          {:type, _, {:Externaltypereference, _, _, ext}, _set, [], _} -> :application.set_env(:asn1scg, bin(name), bin(ext))
          {:type, _, {:pt, _, _}, [], [], _} -> :skip
          {:ObjectSet, _, _, _, _elementSet} -> :ok
          {:Object, _, _val} -> :skip
          {:Object, _, _, _} -> :ok
          _ -> :skip
      end
      case res do
           :skip -> :io.format 'Unhandled type definition ~p: ~p~n', [name, typeDefinition]
               _ -> :skip
      end 
  end

  def normalizeName(name), do: Enum.join(String.split("#{name}", "-"), "_")
  def lookup(name) do
      b = bin(name)
      case :application.get_env(:asn1scg, b, b) do
           a when a == b -> bin(b)
           x -> lookup(x)
      end
  end
           
  def bin(x) when is_atom(x), do: :erlang.atom_to_binary x
  def bin(x) when is_list(x), do: :erlang.list_to_binary x
  def bin(x), do: x

  def dumpValue(_pos, _name, _type, _value, _mod), do: []
  def dumpClass(_pos, _name, _mod, _type), do: []
  def dumpPType(_pos, _name, _args, _type), do: []
  def dumpModule(_pos, _name, _defid, _tagdefault, _exports, _imports), do: []

  def compile(save, file) do
      tokens = :asn1ct_tok.file file
      {:ok, mod} = :asn1ct_parser2.parse file, tokens
      {:module, pos, modname, defid, tagdefault, exports, imports, _, typeorval} = mod
      :lists.map(fn
         {:typedef,  _, pos, name, type} -> compileType(pos, name, type, modname, save)
         {:ptypedef, _, pos, name, args, type} -> dumpPType(pos, name, args, type)
         {:classdef, _, pos, name, mod, type} -> dumpClass(pos, name, mod, type)
         {:valuedef, _, pos, name, type, value, mod} -> dumpValue(pos, name, type, value, mod)
      end, typeorval)
      dumpModule(pos, modname, defid, tagdefault, exports, imports)
  end

end

case System.argv() do
     ["compile"] ->
        CHAT.ASN1.compile_all
     ["compile",input] ->
        :application.set_env(:asn1scg, :input, input <> "/")
        CHAT.ASN1.compile_all
     ["compile",input,output] ->
        :application.set_env(:asn1scg, :input, input <> "/")
        :application.set_env(:asn1scg, :output, output)
        CHAT.ASN1.compile_all
     _ ->
        :io.format('ASN.1 Swift Code Generation Compiler © SYNRC~n')
        :io.format('Usage: ./asn1scg.ex compile [input-dir] [output-dir]~n')
end

