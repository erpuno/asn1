defmodule ASN1.SwiftEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]

  # Check if fields contain ASN1Any (which is not Hashable)
  def containsNonHashableType(fields) when is_list(fields) do
      Enum.any?(fields, fn
          {:ComponentType, _, _, {:type, _, type, _, _, _}, _, _, _} ->
              fieldContainsASN1Any(type)
          {:ComponentType, _, _, type, _, _, _} ->
              fieldContainsASN1Any(type)
          _ -> false
      end)
  end
  def containsNonHashableType(_), do: false

  defp fieldContainsASN1Any(:ANY), do: true
  defp fieldContainsASN1Any(:"ANY"), do: true
  defp fieldContainsASN1Any({:ANY_DEFINED_BY, _}), do: true
  defp fieldContainsASN1Any({:ObjectClassFieldType, _, _, _, _}), do: true
  defp fieldContainsASN1Any({:Externaltypereference, _, _, _}), do: true
  defp fieldContainsASN1Any({:type, _, inner, _, _, _}), do: fieldContainsASN1Any(inner)
  defp fieldContainsASN1Any({:"SEQUENCE OF", inner}), do: fieldContainsASN1Any(inner)
  defp fieldContainsASN1Any({:"Sequence Of", inner}), do: fieldContainsASN1Any(inner)
  defp fieldContainsASN1Any({:"SET OF", inner}), do: fieldContainsASN1Any(inner)
  defp fieldContainsASN1Any({:"Set Of", inner}), do: fieldContainsASN1Any(inner)
  defp fieldContainsASN1Any({:"SEQUENCE", _, _, _, fields}), do: fieldContainsASN1Any(fields)
  defp fieldContainsASN1Any({:"SET", _, _, _, fields}), do: fieldContainsASN1Any(fields)
  defp fieldContainsASN1Any({:"CHOICE", fields}), do: fieldContainsASN1Any(fields)
  defp fieldContainsASN1Any(list) when is_list(list) do
      Enum.any?(list, fn
          {:ComponentType, _, _, {:type, _, type, _, _, _}, _, _, _} ->
              fieldContainsASN1Any(type)
          {:ComponentType, _, _, type, _, _, _} ->
              fieldContainsASN1Any(type)
          x -> fieldContainsASN1Any(x)
      end)
  end
  defp fieldContainsASN1Any(_), do: false

  def hashableConformance(fields) do
      if containsNonHashableType(fields), do: "Sendable", else: "Hashable, Sendable"
  end

  def name(name, modname) do
      nname = bin(normalizeName(name))
      nmod = bin(normalizeName(modname))
      cond do
        String.starts_with?(nname, nmod <> "_") -> nname
        String.starts_with?(nname, nmod) ->
           rest = String.slice(nname, String.length(nmod)..-1//1)
           if rest == "" do
               nname
           else
               nmod <> "_" <> rest
           end
        true -> nmod <> "_" <> nname
      end
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
       if n in ["associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "Any", "catch", "false", "is", "nil", "super", "self", "Self", "throw", "throws", "true", "try", "willSet", "didSet", "override", "convenience", "dynamic", "final", "indirect", "lazy", "mutating", "nonmutating", "optional", "required", "weak", "unowned", "Type", "Protocol", "print"] do
          "`#{n}`"
       else
          n
       end
     end
     end
  end

  def fieldType(name, field, {:tag, _, _, _, inner}), do: fieldType(name, field, inner)
  def fieldType(name,field,{:ComponentType,_,_,{:type,_,oc,_,[],:no},_opt,_,_}), do: fieldType(name, field, oc)
  def fieldType(name,field,{:"SEQUENCE", _, _, _, _}), do: bin(name) <> "_" <> bin(normalizeName(field)) <> "_Sequence"
  def fieldType(name,field,{:"SET", _, _, _, _}), do: bin(name) <> "_" <> bin(normalizeName(field)) <> "_Set"
  def fieldType(name,field,{:"CHOICE",_}), do: bin(name) <> "_" <> bin(normalizeName(field)) <> "_Choice"
  def fieldType(name,field,{:"ENUMERATED",_}), do: bin(name) <> "_" <> bin(normalizeName(field)) <> "_Enum"
  def fieldType(name,field,{:"INTEGER",_}), do: bin(name) <> "_" <> bin(normalizeName(field)) <> "_IntEnum"
  def fieldType(name,field,{:"SEQUENCE OF", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{fieldName(field)}")  end
  def fieldType(name,field,{:"Sequence Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :sequence, "pro #{name}.#{fieldName(field)}")  end
  def fieldType(name,field,{:"SET OF", {:type, _, {:"SET OF", inner}, _, _, _}}) do
    # Handle nested SET OF SET OF by generating wrapper type
    inner_type = case inner do
      {:type, _, t, _, _, _} -> t
      _ -> inner
    end
    element_name = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Element"
    array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
    element_swift = name(element_name, getEnv(:current_module, ""))
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
      element_name = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Element"
      array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
      element_swift = name(element_name, getEnv(:current_module, ""))
      "[#{element_swift}]"
    else
      bin = "[#{sequenceOf(name,field,type)}]"
      array("#{bin}", partArray(bin), :set, "pro #{name}.#{field}")
      bin
    end
  end
  def fieldType(name,field,{:"Set Of", type}) do bin = "[#{sequenceOf(name,field,type)}]" ; array("#{bin}", partArray(bin), :set, "pro #{name}.#{fieldName(field)}")  end
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
    element_name = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Element"
    array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
    element_swift = name(element_name, getEnv(:current_module, ""))
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
    bin(name) <> "_" <> bin(normalizeName(field)) <> "_Choice"
  end
  def sequenceOf2(name,field,{:type,_,{:SEQUENCE, _, _, _, fields} = product,_,_,_}) do
    saveFlag = getEnv("save", false)
    sequence(fieldType(name,field,product), fields, getEnv(:current_module, ""), saveFlag)
    bin(name) <> "_" <> bin(normalizeName(field)) <> "_Sequence"
  end
  def sequenceOf2(name,field,{:type,_,{:SET, _, _, _, fields} = product,_,_,_}) do
      saveFlag = getEnv("save", false)
      typeName = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Set"
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

@usableFromInline struct #{fullName}: DERImplicitlyTaggable, DERParseable, DERSerializable, Sendable {
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

  def sequence(name, fields, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      setEnv(:current_struct, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      conformance = hashableConformance(fields)

      save(saveFlag, modname, swiftName,
           emitSequenceDefinition(swiftName, conformance,
           emitFields(swiftName, 4, fields, modname),
           emitCtor(emitParams(swiftName, fields), emitCtorBody(fields)),
           emitSequenceDecoder(emitSequenceDecoderBody(swiftName, fields), swiftName, emitArgs(fields)),
           emitSequenceEncoder(emitSequenceEncoderBody(swiftName, fields))))
  end

  def set(name, fields, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      setEnv(:current_struct, swiftName)
      :application.set_env(:asn1scg, {:type,swiftName}, fields)
      conformance = hashableConformance(fields)

      save(saveFlag, modname, swiftName,
           emitSetDefinition(swiftName, conformance,
           emitFields(swiftName, 4, fields, modname),
           emitCtor(emitParams(swiftName, fields), emitCtorBody(fields)),
           emitSetDecoder(emitSequenceDecoderBody(swiftName, fields), swiftName, emitArgs(fields)),
           emitSequenceEncoder(emitSequenceEncoderBody(swiftName, fields))))
  end

  def choice(name, cases, modname, saveFlag) do
      swiftName = name(name, modname)
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
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      save(saveFlag, modname, swiftName,
           emitEnumerationDefinition(swiftName,
           emitEnums(swiftName, cases)))
  end

  def integerEnum(name, cases, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      save(saveFlag, modname, swiftName,
           emitIntegerEnumDefinition(swiftName,
           emitIntegerEnums(cases)))
  end

  def emitFields(swiftName, indent, fields, modname) do
      Enum.join(Enum.map(fields, fn
          {:ComponentType, _, fieldName, {:type, _, type, _, _, _}, optional, _, _} ->
              field = fieldType(swiftName, fieldName, type)
              case type do
                 {:SEQUENCE, _, _, _, fds} -> sequence(fieldType(swiftName,fieldName,type), fds, modname, true)
                 {:SET, _, _, _, fds} -> set(fieldType(swiftName,fieldName,type), fds, modname, true)
                 {:CHOICE, fds} -> choice(fieldType(swiftName,fieldName,type), fds, modname, true)
                 {:INTEGER, fds} -> integerEnum(fieldType(swiftName,fieldName,type), fds, modname, true)
                 {:ENUMERATED, fds} -> enumeration(fieldType(swiftName,fieldName,type), fds, modname, true)
                 _ -> :skip
              end
              pad(indent) <> emitSequenceElementOptional(fieldName, field, opt(optional))
          _ -> ""
      end), "")
  end

  def emitParams(swiftName, fields) do
      fields
      |> Enum.map(fn
          {:ComponentType, _, fieldName, {:type, _, type, _, _, _}, optional, _, _} ->
              field = fieldType(swiftName, fieldName, type)
              emitCtorParam(fieldName, field, opt(optional))
          _ -> ""
      end)
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.join(", ")
  end

  def emitCtorBody(fields) do
      Enum.join(Enum.map(fields, fn
          {:ComponentType, _, fieldName, _, _, _, _} ->
              pad(8) <> emitCtorBodyElement(fieldName) <> "\n"
          _ -> ""
      end), "")
  end

  def emitArgs(fields) do
      fields
      |> Enum.map(fn
          {:ComponentType, _, fieldName, _, _, _, _} ->
              emitArg(fieldName)
          _ -> ""
      end)
      |> Enum.filter(fn x -> x != "" end)
      |> Enum.join(", ")
  end

  def emitChoiceDecoderBody(swiftName, cases) do
      Enum.join(Enum.map(cases, fn
          {:ComponentType, _, name, {:type, attrs, type, _, _, _}, _optional, _, _} ->
              no = attrs
              case type do
                  {:"SEQUENCE OF", t} -> emitChoiceDecoderBodyElementForArray(8, no, name, sequenceOf(swiftName, name, t), "sequence")
                  {:"Sequence Of", t} -> emitChoiceDecoderBodyElementForArray(8, no, name, sequenceOf(swiftName, name, t), "sequence")
                  {:"SET OF", t} -> emitChoiceDecoderBodyElementForArray(8, no, name, sequenceOf(swiftName, name, t), "set")
                  {:"Set Of", t} -> emitChoiceDecoderBodyElementForArray(8, no, name, sequenceOf(swiftName, name, t), "set")
                   _ -> emitChoiceDecoderBodyElement(8, no, name, fieldType(swiftName, name, type), plicit(attrs))
              end
          _ -> ""
      end), "\n")
  end

  def emitChoiceEncoderBody(swiftName, cases) do
      Enum.join(Enum.map(cases, fn
          {:ComponentType, _, name, {:type, attrs, type, _, _, _}, _optional, _, _} ->
              no = attrs
              spec = case type do
                  {:"SEQUENCE OF", _} -> "SequenceOf"
                  {:"Sequence Of", _} -> "SequenceOf"
                  {:"SET OF", _} -> "SetOf"
                  {:"Set Of", _} -> "SetOf"
                  _ -> ""
              end
              emitChoiceEncoderBodyElement(8, no, name, type, spec, plicit(attrs)) <> "\n"
          _ -> ""
      end), "")
  end

  def emitSequenceDecoderBody(swiftName, fields) do
      Enum.join(Enum.map(fields, fn
          {:ComponentType, _, name, {:type, attrs, type, _, _, _}, optional, _, _} ->
              no = tagNo(attrs)
              case type do
                  {:"SEQUENCE OF", t} -> pad(12) <> emitSequenceDecoderBodyElementArray(optional, plicit(attrs), no, name, sequenceOf(swiftName, name, t), "sequence") <> "\n"
                  {:"Sequence Of", t} -> pad(12) <> emitSequenceDecoderBodyElementArray(optional, plicit(attrs), no, name, sequenceOf(swiftName, name, t), "sequence") <> "\n"
                  {:"SET OF", t} -> pad(12) <> emitSequenceDecoderBodyElementArray(optional, plicit(attrs), no, name, sequenceOf(swiftName, name, t), "set") <> "\n"
                  {:"Set Of", t} -> pad(12) <> emitSequenceDecoderBodyElementArray(optional, plicit(attrs), no, name, sequenceOf(swiftName, name, t), "set") <> "\n"
                  {:"INTEGER", _} -> pad(12) <> emitSequenceDecoderBodyElementIntEnum(name, fieldType(swiftName, name, type)) <> "\n"
                  _ -> pad(12) <> emitSequenceDecoderBodyElement(optional, plicit(attrs), no, name, fieldType(swiftName, name, type)) <> "\n"
              end
          _ -> ""
      end), "")
  end

  def emitSequenceEncoderBody(swiftName, fields) do
      Enum.join(Enum.map(fields, fn
          {:ComponentType, _, name, {:type, attrs, type, _, _, _}, optional, _, _} ->
              no = tagNo(attrs)
              field_swift_type = fieldType(swiftName, name, type)
              body = case type do
                  {:"SEQUENCE OF", _} -> emitGenEncoder(plicit(attrs), no, fieldName(name), "sequence")
                  {:"Sequence Of", _} -> emitGenEncoder(plicit(attrs), no, fieldName(name), "sequence")
                  {:"SET OF", _}      -> emitGenEncoder(plicit(attrs), no, fieldName(name), "set")
                  {:"Set Of", _}      -> emitGenEncoder(plicit(attrs), no, fieldName(name), "set")
                  {:"INTEGER", _}     -> emitSequenceEncoderBodyElementIntEnum(no, name)
                  :"ANY"              -> emitASN1AnyEncoder(plicit(attrs), no, fieldName(name))
                  {:ObjectClassFieldType, _, _, _, _} ->
                      emitASN1AnyEncoder(plicit(attrs), no, fieldName(name))
                  _ when field_swift_type == "ASN1Any" ->
                      emitASN1AnyEncoder(plicit(attrs), no, fieldName(name))
                  _                   -> emitGenEncoder(plicit(attrs), no, fieldName(name), "")
              end
              pad(12) <> emitOptional(optional, name, body) <> "\n"
          _ -> ""
      end), "")
  end

  def typealias(name, target, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      if target == "ASN1ObjectIdentifier" do
          setEnv({:is_oid, swiftName}, true)
      end
      save(saveFlag, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline typealias #{swiftName} = #{normalizeName(target)}
""")
  end

  def algorithmIdentifierClass(className, modname, saveFlag) do
      save(saveFlag, modname, className, """
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline struct #{className}: DERImplicitlyTaggable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var algorithm: ASN1ObjectIdentifier
    @usableFromInline var parameters: ASN1Any?
    @inlinable init(algorithm: ASN1ObjectIdentifier, parameters: ASN1Any? = nil) {
        self.algorithm = algorithm
        self.parameters = parameters
    }
    @inlinable init(derEncoded root: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let algorithm = try ASN1ObjectIdentifier(derEncoded: &nodes)
            var parameters: ASN1Any? = nil
            if let nextNode = nodes.next() {
                parameters = try ASN1Any(derEncoded: nextNode)
            }
            return #{className}(algorithm: algorithm, parameters: parameters)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(algorithm)
            if let parameters = parameters { try coder.serialize(parameters) }
        }
    }
}
""")
  end

  def fileExtension(), do: ".swift"

  def tagNo([]), do: []
  def tagNo(x) when is_integer(x), do: x
  def tagNo([{:tag,_,nox,_,_}]) do nox end

  def tagClass([]), do: []
  def tagClass(x) when is_integer(x), do: x
  def tagClass([{:tag,:CONTEXT,_,_,_}]),     do: ".contextSpecific"
  def tagClass([{:tag,:APPLICATION,_,_,_}]), do: ".application"
  def tagClass([{:tag,:PRIVATE,_,_,_}]),     do: ".private"
  def tagClass([{:tag,:UNIVERSAL,_,_,_}]),   do: ".universal"
  def tagClass([{:tag,class,_,_,_}]) do class end
  def tagClass([{:tag,:APPLICATION,_,_,_}]), do: ".application"
  def tagClass([{:tag,:PRIVATE,_,_,_}]),     do: ".private"
  def tagClass([{:tag,:UNIVERSAL,_,_,_}]),   do: ".universal"

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

  def tagClass([{:tag,:CONTEXT,_,_,_}]),     do: ".contextSpecific"
  def tagClass([{:tag,:APPLICATION,_,_,_}]), do: ".application"
  def tagClass([{:tag,:PRIVATE,_,_,_}]),     do: ".private"
  def tagClass([{:tag,:UNIVERSAL,_,_,_}]),   do: ".universal"
  def tagClass([]), do: []

  def value(name, _type, val, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)

      components = extractOIDList(val)

      {base, suffix} = case components do
          [h | t] ->
             if h |> to_string() |> (fn s -> Regex.match?(~r/^\d+$/, s) end).() do
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

  def integerValue(name, val, modname, saveFlag) do
      swiftName = name(name, modname)
      setEnv(name, swiftName)
      resolved_val = case val do
          {:Externalvaluereference, _, _ref_mod, ref_name} ->
              # Reference to another integer constant - look up the existing Swift name
              case lookup(ref_name) do
                  :undefined -> name(ref_name, getEnv(:current_module, ""))
                  found when is_binary(found) -> found
                  _ -> name(ref_name, getEnv(:current_module, ""))
              end
          _ when is_integer(val) -> val
          _ -> val
      end
      save(saveFlag, modname, swiftName, """
#{emitImprint()}
import SwiftASN1
import Foundation

public let #{swiftName}: Int = #{resolved_val}
""")
  end

  def extractOIDList(val) do
      list = if is_list(val), do: val, else: [val]
      Enum.flat_map(list, fn x ->
         resolveOIDComponent(x)
      end)
  end

  def resolveOIDComponent({:NamedNumber, _, val}), do: resolveOIDComponent(val)
  def resolveOIDComponent({:seqtag, _, mod, name}) do
      swift_name = case lookup(name) do
          val when is_binary(val) -> val
          _ -> name(name, mod)
      end
      [swift_name]
  end
  def resolveOIDComponent({{:seqtag, _, mod, name}, val}) do
      swift_name = case lookup(name) do
          found when is_binary(found) -> found
          _ -> name(name, mod)
      end
      [swift_name | resolveOIDComponent(val)]
  end

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
             _ -> name(name, mod)
          end
      else
          name(name, mod)
      end
      [res]
  end

  def resolveOIDComponent(:'joint-iso-itu-t'), do: ["2"]
  def resolveOIDComponent(:'joint-iso-ccitt'), do: ["2"]
  def resolveOIDComponent(:iso), do: ["1"]
  def resolveOIDComponent(:'itu-t'), do: ["0"]
  def resolveOIDComponent(:ccitt), do: ["0"]

  def resolveOIDComponent(val) when is_atom(val) do
      case lookup(val) do
          :undefined -> [val]
          found -> [found]
      end
  end

  def resolveOIDComponent(val), do: [val]

  def fieldName(name) do
      s = bin(normalizeName(name))
      if s in [
          "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
          "init", "inout", "internal", "let", "open", "operator", "private", "protocol", "public",
          "rethrows", "static", "struct", "subscript", "typealias", "var",
          "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for",
          "guard", "if", "in", "repeat", "return", "switch", "where", "while",
          "as", "Any", "catch", "false", "is", "nil", "super", "self", "Self", "throw", "throws",
          "true", "try"
      ] do
          "`#{s}`"
      else
          s
      end
  end

  def emitImprint(), do: "// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa."

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

  def emitASN1AnyEncoder(plicit, no, name) when no != [] and plicit == "Explicit", do:
      "try coder.serialize(explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific) { codec in try codec.serialize(#{name}) }"
  def emitASN1AnyEncoder(_plicit, _no, name), do:
      "try coder.serialize(#{name})"

  def emitSequenceEncoderBodyElementIntEnum(no, name) when no == [], do:
      "try #{fieldName(name)}.serialize(into: &coder, withIdentifier: identifier)"
  def emitSequenceEncoderBodyElementIntEnum(no, name), do:
      "try coder.serialize(#{fieldName(name)}.rawValue, explicitlyTaggedWithTagNumber: #{no}, tagClass: .contextSpecific)"

  def emitSequenceEncoderBodyElementAny(optional, name) do
      body = "try coder.serialize(#{name})"
      emitOptional(optional, name, body)
  end

  def emitOptional(:OPTIONAL, name, body) do
      n = fieldName(name)
      "if let #{n} = self.#{n} { #{body} }"
  end
  def emitOptional({:DEFAULT, _}, name, body), do: emitOptional(:OPTIONAL, name, body)
  def emitOptional(:mandatory, _, body), do: body
  def emitOptional([], _, body), do: body
  def array_element_type(binary) do
    if String.starts_with?(binary, "[") and String.ends_with?(binary, "]") do
      String.slice(binary, 1..-2//1)
    else
      nil
    end
  end

  def sequenceOf(name,field,type) do
      sequenceOf2(name,field,type)
  end

  def sequenceOf2(name,field,{:type,_,{:Externaltypereference,_,_,type},_,_,_}), do: "#{sequenceOf(name,field,type)}"
  def sequenceOf2(_,_,{:pt, {:Externaltypereference, _, _, type}, _}), do: substituteType("#{lookup(bin(type))}")
  def sequenceOf2(name,field,{:type,_,{:"SET OF", {:type, _, {:"SET OF", {:type, _, inner_type, _, _, _}}, _, _, _}},_,_,_}) do
    # Handle nested SET OF SET OF by generating wrapper type
    element_name = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Element"
    array(element_name, substituteType(lookup(bin(inner_type))), :set, "top")
    element_swift = name(element_name, getEnv(:current_module, ""))
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
    bin(name) <> "_" <> bin(normalizeName(field)) <> "_Choice"
  end
  def sequenceOf2(name,field,{:type,_,{:SEQUENCE, _, _, _, fields} = product,_,_,_}) do
    saveFlag = getEnv("save", false)
    sequence(fieldType(name,field,product), fields, getEnv(:current_module, ""), saveFlag)
    bin(name) <> "_" <> bin(normalizeName(field)) <> "_Sequence"
  end
  def sequenceOf2(name,field,{:type,_,{:SET, _, _, _, fields} = product,_,_,_}) do
    saveFlag = getEnv("save", false)
    typeName = bin(name) <> "_" <> bin(normalizeName(field)) <> "_Set"
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

  def pad(x), do: String.duplicate(" ", x)
  def part(look, 0, 1), do: String.slice(look, 0, 1)
  def part(look, start, length), do: String.slice(look, start, length)

  def trace(x), do: setEnv({:trace, x}, true)

  def emitSequenceDecoderBodyElementArray(:OPTIONAL, plicit, no, name, type, spec) when plicit == "Explicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]>? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }.map { Box($0) }"
      else
          "let #{n}: [#{element_type}]? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(:OPTIONAL, plicit, no, name, type, spec) when plicit == "Implicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]>? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: node.identifier, rootNode: node) }.map { Box($0) }"
      else
          "let #{n}: [#{element_type}]? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: node.identifier, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(_, plicit, no, name, type, spec) when plicit == "Implicit" and no != [] and (spec == "set" or spec == "sequence") do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
         "let #{n}: Box<[#{element_type}]> = Box(try DER.#{spec}(of: #{element_type}.self, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific), nodes: &nodes))"
      else
         "let #{n}: [#{element_type}] = try DER.#{spec}(of: #{element_type}.self, identifier: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific), nodes: &nodes)"
      end
  end
  def emitSequenceDecoderBodyElementArray(_, _, no, name, type, spec) when no != [] and (spec == "set" or spec == "sequence") do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      element_type = array_element_type(type) || type
      if boxed do
          "let #{n}: Box<[#{element_type}]> = Box(try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) })"
      else
          "let #{n}: [#{element_type}] = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in try DER.#{spec}(of: #{element_type}.self, identifier: .#{spec}, rootNode: node) }"
      end
  end
  def emitSequenceDecoderBodyElementArray(optional, _, no, name, type, spec) when no == [] do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<[#{type}]>#{opt(optional)} = Box(try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, nodes: &nodes))"
      else
          "let #{n}: [#{type}]#{opt(optional)} = try DER.#{spec}(of: #{type}.self, identifier: .#{spec}, nodes: &nodes)"
      end
  end

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, "ASN1Any") when plicit == "Implicit" and no != [] do
      n = fieldName(name)
      "let #{n}: ASN1Any? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in ASN1Any(derEncoded: node) }"
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, "ASN1Any") when plicit == "Implicit" and no != [] do
      n = fieldName(name)
      "let #{n}: ASN1Any = try DER.optionalImplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in ASN1Any(derEncoded: node) }!"
  end

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Implicit" do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>? = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))).map { Box($0) }"
      else
          "let #{n}: #{type}? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific))"
      end
  end

  def emitSequenceDecoderBodyElement(:OPTIONAL, plicit, no, name, type) when plicit == "Explicit" do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return Box(try #{type}(derEncoded: node)) }"
      else
          "let #{n}: #{type}? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
      end
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Explicit" do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}> = Box(try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) })"
      else
          "let #{n}: #{type} = try DER.explicitlyTagged(&nodes, tagNumber: #{no}, tagClass: .contextSpecific) { node in return try #{type}(derEncoded: node) }"
      end
  end
  def emitSequenceDecoderBodyElement(_, plicit, no, name, type) when plicit == "Implicit" do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}> = Box((try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific)))!)"
      else
          "let #{n}: #{type} = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: #{no}, tagClass: .contextSpecific)))!"
      end
  end
  def emitSequenceDecoderBodyElement(:OPTIONAL, _, _, name, "ASN1Any") do
      n = fieldName(name)
      "let #{n}: ASN1Any? = nodes.next().map { ASN1Any(derEncoded: $0) }"
  end
  def emitSequenceDecoderBodyElement(_, _, _, name, "Bool"), do:
      "let #{name}: Bool = try DER.decodeDefault(&nodes, defaultValue: false)"
  def emitSequenceDecoderBodyElement(:OPTIONAL, _, _, name, type) do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      peekVar = "peek_#{n}"
      if boxed do
          "var #{n}: Box<#{type}>? = nil\n" <>
          "var #{peekVar} = nodes\n" <>
          "if let next = #{peekVar}.next(), next.identifier == #{type}.defaultIdentifier {\n" <>
          "    #{n} = Box(try #{type}(derEncoded: &nodes))\n" <>
          "}"
      else
          "var #{n}: #{type}? = nil\n" <>
          "var #{peekVar} = nodes\n" <>
          "if let next = #{peekVar}.next(), next.identifier == #{type}.defaultIdentifier {\n" <>
          "    #{n} = try #{type}(derEncoded: &nodes)\n" <>
          "}"
      end
  end
  def emitSequenceDecoderBodyElement(optional, _, _, name, type) do
      n = fieldName(name)
      boxed = isBoxed(getEnv(:current_struct, ""), name)
      if boxed do
          "let #{n}: Box<#{type}>#{opt(optional)} = Box(try #{type}(derEncoded: &nodes))"
      else
          "let #{n}: #{type}#{opt(optional)} = try #{type}(derEncoded: &nodes)"
      end
  end

  def emitSequenceDecoderBodyElementIntEnum(name, type) do
      n = fieldName(name)
      "let #{n} = try #{type}(rawValue: Int(derEncoded: &nodes))"
  end

  def emitChoiceDecoderBodyElement(w, _no, name, "ASN1Any", _spec) do
      pad(w) <> "case ASN1Identifier(tagWithNumber: 9, tagClass: .universal):\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(ASN1Any(derEncoded: rootNode))"
  end
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec) when no == [], do:
      pad(w) <> "case #{normalizeName(type)}.defaultIdentifier:\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"
  def emitChoiceDecoderBodyElement(w, no, name, type, "Explicit") do
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "guard case .constructed(let nodes) = rootNode.content, var iterator = Optional(nodes.makeIterator()), let inner = iterator.next() else { throw ASN1Error.invalidASN1Object(reason: \"Invalid explicit tag content\") }\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try #{normalizeName(type)}(derEncoded: inner))"
  end
  def emitChoiceDecoderBodyElement(w, no, name, type, _spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try #{normalizeName(type)}(derEncoded: rootNode, withIdentifier: rootNode.identifier))"

  def emitChoiceDecoderBodyElementForArray(w, no, name, type, spec) when no == [], do:
      pad(w) <> "case ASN1Identifier.#{spec}:\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, rootNode: rootNode))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec) when spec == "", do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: .#{spec}, nodes: &nodes))"
  def emitChoiceDecoderBodyElementForArray(w, no,  name, type, spec), do:
      pad(w) <> "case ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)}):\n" <>
      pad(w+4) <> "self = .#{fieldName(name)}(try DER.#{spec}(of: #{normalizeName(type)}.self, identifier: rootNode.identifier, rootNode: rootNode))"

  def emitChoiceEncoderBodyElement(w, no, name, _type, spec, _plicit) when no == [] do
      n = fieldName(name)
      if spec == "" do
         pad(w) <> "case .#{n}(let #{n}):\n" <>
         pad(w+16) <> "if identifier != Self.defaultIdentifier {\n" <>
         pad(w+20) <> "try coder.appendConstructedNode(identifier: identifier) { coder in\n" <>
         pad(w+24) <> "try coder.serialize(#{n})\n" <>
         pad(w+20) <> "}\n" <>
         pad(w+16) <> "} else {\n" <>
         pad(w+20) <> "try coder.serialize(#{n})\n" <>
         pad(w+16) <> "}"
      else
         pad(w) <> "case .#{n}(let #{n}): try coder.serialize#{spec}(#{n})"
      end
  end
  def emitChoiceEncoderBodyElement(w, no, name, type, spec, plicit) do
      n = fieldName(name)
      tag = "ASN1Identifier(tagWithNumber: #{tagNo(no)}, tagClass: #{tagClass(no)})"
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

  def emitChoiceElement(name, type), do: "case #{fieldName(name)}(#{lookup(bin(normalizeName(type)))})\n"

  def emitCtorParam(name, type, opt \\ "") do
      n = fieldName(name)
      t = lookup(normalizeName(type))
      finalType = if isBoxed(getEnv(:current_struct, ""), name), do: "Box<#{t}>", else: t
      "#{n}: #{finalType}#{opt}"
  end

  def emitCtorBodyElement(name) do
      n = fieldName(name)
      "self.#{n} = #{n}"
  end

  def emitArg(name) do
      n = fieldName(name)
      "#{n}: #{n}"
  end

  def emitCtor(params,fields), do: pad(4) <> "@inlinable init(#{params}) {\n#{fields}\n    }\n"
  def emitEnumElement(_type, field, value), do: pad(4) <> "static let #{fieldName(field)} = Self(rawValue: #{value})\n"
  def emitIntegerEnumElement(field, value), do: pad(4) <> "public static let #{fieldName(field)} = Self(rawValue: #{value})\n"

  def emitSequenceElementOptional(name, type, opt \\ "") do
      n = fieldName(name)
      t = lookup(normalizeName(type))
      finalType = if isBoxed(getEnv(:current_struct, ""), name), do: "Box<#{t}>", else: t
      "@usableFromInline var #{n}: #{finalType}#{opt}\n"
  end

  def emitSequenceDefinition(name, _conformance, fields,ctor,decoder,encoder), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
@usableFromInline struct #{name}: DERImplicitlyTaggable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }\n#{fields}#{ctor}#{decoder}#{encoder}}
"""

  def emitSetDefinition(name, _conformance, fields,ctor,decoder,encoder), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
@usableFromInline struct #{name}: DERImplicitlyTaggable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .set }\n#{fields}#{ctor}#{decoder}#{encoder}}
"""

  def emitChoiceDefinition(name,cases,decoder,encoder,defId), do:
"""
#{emitImprint()}
import SwiftASN1
import Foundation

@usableFromInline indirect enum #{name}: DERImplicitlyTaggable, DERParseable, DERSerializable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { #{defId} }
    #{cases}#{decoder}#{encoder}
}
"""

  def emitEnumerationDefinition(name,cases), do:
"""
#{emitImprint()}
import SwiftASN1\nimport Foundation\n
public struct #{name}: DERImplicitlyTaggable, Sendable, RawRepresentable {
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
public struct #{name} : DERImplicitlyTaggable, DERParseable, DERSerializable, Sendable, Comparable {
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
        {:ComponentType,_,fieldName,{:type,_,fieldType_def,_elementSet,[],:no},_optional,_,_} ->
           trace(3)
           field = fieldType(name, fieldName, fieldType_def)
           case fieldType_def do
              {:SEQUENCE, _, _, _, fds} ->
                 sequence(fieldType(name,fieldName,fieldType_def), fds, modname, true)
              {:SET, _, _, _, fds} ->
                 set(fieldType(name,fieldName,fieldType_def), fds, modname, true)
              {:CHOICE, fds} ->
                 choice(fieldType(name,fieldName,fieldType_def), fds, modname, true)
              {:INTEGER, fds} ->
                 integerEnum(fieldType(name,fieldName,fieldType_def), fds, modname, true)
              {:ENUMERATED, fds} ->
                 enumeration(fieldType(name,fieldName,fieldType_def), fds, modname, true)
              _ ->
                 :skip
           end
           pad(w) <> emitChoiceElement(fieldName(fieldName), substituteType(lookup(field)))
          _ -> ""
      end, cases), "")
  end

  def isBoxed(structName, fieldName) do
      boxing = :application.get_env(:asn1scg, :boxing, [])
      key = "#{structName}.#{fieldName}"
      Enum.member?(boxing, key)
  end

  def pad(x), do: String.duplicate(" ", x)
  def part(look, 0, 1), do: String.slice(look, 0, 1)
  def part(look, start, length), do: String.slice(look, start, length)
  def partArray(bin), do: part(bin, 1, :erlang.size(bin) - 2)

  def trace(x), do: setEnv({:trace, x}, true)

  def builtinType(:'INTEGER'), do: "Int"
  def builtinType(:'BIT STRING'), do: "ASN1BitString"
  def builtinType(:'NULL'), do: "ASN1Null"
  def builtinType(:'ANY'), do: "ASN1Any"
  def builtinType(:'OBJECT IDENTIFIER'), do: "ASN1ObjectIdentifier"
  def builtinType(:'External'), do: "EXTERNAL"
  def builtinType(:'PrintableString'), do: "ASN1PrintableString"
  def builtinType(:'NumericString'), do: "ASN1PrintableString"
  def builtinType(:'IA5String'), do: "ASN1IA5String"
  def builtinType(:'TeletexString'), do: "ASN1TeletexString"
  def builtinType(:'UniversalString'), do: "ASN1UniversalString"
  def builtinType(:'UTF8String'), do: "ASN1UTF8String"
  def builtinType(:'VisibleString'), do: "ASN1UTF8String"
  def builtinType(:'BMPString'), do: "ASN1BMPString"
  def builtinType(:ASN1ObjectIdentifier), do: "ASN1ObjectIdentifier"
  def builtinType(:ASN1Any), do: "ASN1Any"
  def builtinType(other) when is_atom(other), do: Atom.to_string(other)
  def builtinType(other), do: other

end
