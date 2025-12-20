defmodule ASN1.GoEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]

  def fileExtension, do: ".go"

  def emitHeader(modname) do
    pkg = module_package(modname)
    """
package #{pkg}

import (
    \"encoding/asn1\"
    \"fmt\"
)

"""
  end

  def module_package(modname) do
    modname
    |> normalizeName()
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
    |> String.downcase()
  end

  def name(name, modname) do
    mod_prefix = mod_prefix(modname)
    normalized = normalizeName(name)
    cap = capitalize(normalized)
    mod_prefix <> cap
  end

  defp mod_prefix(modname) do
    modname
    |> normalizeName()
    |> capitalize()
  end

  def capitalize(name) do
    <<first::utf8, rest::binary>> = name
    String.upcase(<<first>>) <> rest
  end

  def fieldName(name) do
    name
    |> normalizeName()
    |> camel()
  end

  def camel(name) do
    name
    |> String.split("_", trim: true)
    |> Enum.map(&capitalize_part/1)
    |> Enum.join()
  end

  defp capitalize_part(<<first::utf8, rest::binary>>) do
    String.upcase(<<first>>) <> String.downcase(rest)
  end

  defp capitalize_part(<<>>), do: ""

  def substituteType(type) do
    type
  end

  def fieldType(name, field, {:type, _, inner, _, _, _}), do: fieldType(name, field, inner)
  def fieldType(_name, _field, {:"SEQUENCE OF", type}), do: "[]" <> fieldType("", "", type)
  def fieldType(_name, _field, {:"SET OF", type}), do: "[]" <> fieldType("", "", type)
  def fieldType(_name, _field, {:"SEQUENCE", _, _, _, _}), do: name(field, name)
  def fieldType(_name, _field, atom) when is_atom(atom), do: mapBuiltin(atom)
  def fieldType(_name, _field, {:Externaltypereference, _, _, type}), do: lookup(bin(type))
  def fieldType(_name, _field, other) when is_binary(other), do: other
  def fieldType(name, field, other), do: inspect({name, field, other})

  def mapBuiltin(:"OBJECT IDENTIFIER"), do: "asn1.ObjectIdentifier"
  def mapBuiltin(:"OCTET STRING"), do: "[]byte"
  def mapBuiltin(:"BIT STRING"), do: "asn1.BitString"
  def mapBuiltin(:BOOLEAN), do: "bool"
  def mapBuiltin(:INTEGER), do: "int"
  def mapBuiltin(:ENUMERATED), do: "int"
  def mapBuiltin(:NULL), do: "asn1.RawValue"
  def mapBuiltin(:ANY), do: "asn1.RawValue"
  def mapBuiltin(other) when is_atom(other), do: lookup(bin(other))
  def mapBuiltin(other), do: inspect(other)

  def array(_name, _type, _tag, _level), do: []

  def sequence(name, fields, modname, saveFlag) do
    goName = name(name, modname)
    setEnv(name, goName)
    struct_body = emit_struct_fields(fields)
    decoder = emit_sequence_decoder(goName, fields)

    save(saveFlag, modname, goName, """
#{emitHeader(modname)}
#{struct_body}
#{decoder}
""")
  end

  defp emit_struct_fields(fields) do
    body =
      fields
      |> Enum.map(fn
        {:ComponentType, _, field_name, type, optional, _, _} ->
          go_field = fieldName(field_name)
          go_type = fieldType("", field_name, type)
          "    #{go_field} #{go_type} `asn1:\"...\"`"
        _ ->
          ""
      end)
      |> Enum.join("\n")

    "type struct {
#{body}
}"
  end

  defp emit_sequence_decoder(name, fields) do
    "func (s *#{name}) UnmarshalASN1(b []byte) error {
    _, err := asn1.Unmarshal(b, s)
    if err != nil {
        return fmt.Errorf(\"decode #{name}: %w\", err)
    }
    return nil
}"
  end

  def set(name, fields, modname, saveFlag), do: sequence(name, fields, modname, saveFlag)
  def choice(name, cases, modname, saveFlag), do: sequence(name, cases, modname, saveFlag)
  def enumeration(_name, _cases, _modname, _saveFlag), do: []
  def integerEnum(_name, _cases, _modname, _saveFlag), do: []
  def sequenceOf(_name, _field, _type), do: "[]interface{}"

  def tagClass(_tag), do: ""
  def typealias(_name, _target, _modname, _save), do: []
  def value(_name, _type, _val, _modname, _saveFlag), do: []
  def builtinType(type), do: mapBuiltin(type)
  def fileExtension(), do: ".go"

  def algorithmIdentifierClass(_className, _modname, _saveFlag), do: []
  def integerValue(_name, _val, _mod, _saveFlag), do: []
end
