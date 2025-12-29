defmodule ASN1.JavaEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]

  @impl true
  def finalize do
    dir = ASN1.outputDir()
    IO.puts("Generating Gradle build files in #{dir}")

    # settings.gradle
    settings = """
rootProject.name = 'generated-asn1'
includeBuild '/Users/ihor/asn1/asn-one'
"""
    File.write!(Path.join(dir, "settings.gradle"), settings)

    # build.gradle
    build = """
plugins {
    id 'java'
    id 'application'
}

application {
    mainClass = 'com.generated.asn1.Main'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.hierynomus:asn-one:0.6.0'
    implementation 'org.bouncycastle:bcprov-jdk15on:1.70'
    implementation 'org.bouncycastle:bcpkix-jdk15on:1.70'
}
"""
    File.write!(Path.join(dir, "build.gradle"), build)

    :ok
  end

  @impl true
  def fileExtension, do: ".java"

  @impl true
  def name(name, modname) do
    normalize_java_name(name, modname)
  end

  @impl true
  def builtinType(type) do
      # IO.inspect(type, label: "To Java Builtin")
      case type do
        :INTEGER -> "ASN1Integer"
        :BOOLEAN -> "ASN1Boolean"
        :"BIT STRING" -> "ASN1BitString"
        :"OCTET STRING" -> "ASN1OctetString"
        :NULL -> "ASN1Null"
        :OBJECT_IDENTIFIER -> "ASN1ObjectIdentifier"
        :GeneralizedTime -> "ASN1Object" # Fallback
        :UTCTime -> "ASN1Object" # Fallback
        :IA5String -> "ASN1Object" # Fallback
        :PrintableString -> "ASN1Object"
        :UTF8String -> "ASN1Object"
        :TeletexString -> "ASN1Object"
        :T61String -> "ASN1Object"
        :VideotexString -> "ASN1Object"
        :GraphicString -> "ASN1Object"
        :VisibleString -> "ASN1Object"
        :GeneralString -> "ASN1Object"
        :UniversalString -> "ASN1Object"
        :BMPString -> "ASN1Object"
        :NumericString -> "ASN1Object"
        :ObjectDescriptor -> "ASN1Object"
        :External -> "ASN1Object"
        :REAL -> "ASN1Object"
        :EmbeddedPDV -> "ASN1Object"
        _ -> "ASN1Object"
      end
  end

  @impl true
  def typealias(name, target, modname, saveFlag) do
      javaName = name(name, modname)
      # Wrapper approach
      content = """
package com.generated.asn1;

#{emitImports()}

public class #{javaName} extends ASN1Object<Object> {
    private final ASN1Object decorated;

    public #{javaName}(ASN1Object decorated) {
        super(decorated.getTag());
        this.decorated = decorated;
    }

    @Override
    public Object getValue() {
        return decorated.getValue();
    }
}
"""
    save(saveFlag, modname, javaName, content)
    javaName
  end

  @impl true
  def name(name, modname) do
    normalize_java_name(name, modname)
  end

  @impl true
  def fieldName(name) do
    normalize_field_name(name)
  end

  @impl true
  def fieldType(name, field, {:"SEQUENCE OF", inner}) do
      "List<" <> to_java_type(inner, "") <> ">"
  end
  def fieldType(name, field, {:"SET OF", inner}) do
      "List<" <> to_java_type(inner, "") <> ">"
  end
  def fieldType(_name, _field, {:type, _, inner, _, _, _}) do
    substituteType(inner)
  end
  def fieldType(_name, _field, type) when is_atom(type) do
      substituteType(type)
  end
  def fieldType(_name, _field, {:Externaltypereference, _, mod, type}) do
      name(type, mod)
  end
  def fieldType(_name, _field, _) do
    "ASN1Object"
  end

  @impl true
  def array(name, element_type, _tag, level) when level == "top" do
    modname = getEnv(:current_module, "")
    javaName = name(name, modname)
    setEnv(name, javaName)
    saveFlag = getEnv(:save, false)

    imports = emitImports()

    content = """
package com.generated.asn1;

#{imports}

import java.util.List;
import java.util.ArrayList;

public class #{javaName} extends ASN1Sequence {
    public #{javaName}(List<ASN1Object> objects) {
        super(objects);
    }
}
"""
    save(saveFlag, modname, javaName, content)
    javaName
  end

  @impl true
  def array(_name, element_type, _tag, _level) do
     "List<#{element_type}>"
  end

  @impl true
  def sequence(name, fields, modname, saveFlag) do
    javaName = name(name, modname)
    setEnv(name, javaName)
    setEnv(:current_struct, javaName)

    imports = emitImports()

    # Analyze fields - separate required vs optional
    parsed_fields = fields
    |> Enum.with_index()
    |> Enum.map(fn {field, idx} ->
        case field do
          {:ComponentType, _, fname, type, optional, _, _} ->
            is_optional = optional in [:OPTIONAL, 'OPTIONAL']
            tag_info = extract_tag_info(type)
            %{
              name: fieldName(fname),
              java_name: fieldName(fname),
              type: to_java_type(type, modname),
              idx: idx,
              optional: is_optional,
              tag: tag_info
            }
          {:"COMPONENTS OF", _type} ->
            nil
          _ ->
            nil
        end
    end)
    |> Enum.filter(&(&1 != nil))

    required_fields = Enum.filter(parsed_fields, &(!&1.optional))
    optional_fields = Enum.filter(parsed_fields, &(&1.optional))

    # Generate getters
    field_accessors = parsed_fields
    |> Enum.map(fn f ->
        """
        public ASN1Object get#{capitalize(f.java_name)}() {
            return this.size() > #{f.idx} ? this.get(#{f.idx}) : null;
        }
        """
    end)
    |> Enum.join("\n")

    # Generate Builder class
    builder_fields = parsed_fields
    |> Enum.map(fn f ->
        "    private ASN1Object #{f.java_name};"
    end)
    |> Enum.join("\n")

    builder_setters = parsed_fields
    |> Enum.map(fn f ->
        """
            public Builder #{f.java_name}(ASN1Object value) {
                this.#{f.java_name} = value;
                return this;
            }
        """
    end)
    |> Enum.join("\n")

    # Build method - assembles the list
    build_items = parsed_fields
    |> Enum.map(fn f ->
        if f.optional do
          "        if (#{f.java_name} != null) list.add(#{f.java_name});"
        else
          "        list.add(#{f.java_name});"
        end
    end)
    |> Enum.join("\n")

    content = """
package com.generated.asn1;

#{imports}
import java.util.List;
import java.util.ArrayList;

public class #{javaName} extends ASN1Sequence {
    public #{javaName}(List<ASN1Object> objects) {
        super(objects);
    }

#{field_accessors}

    // Builder for ergonomic construction
    public static class Builder {
#{builder_fields}

#{builder_setters}

        public #{javaName} build() {
            List<ASN1Object> list = new ArrayList<>();
#{build_items}
            return new #{javaName}(list);
        }
    }

    public static Builder builder() {
        return new Builder();
    }
}
"""

    save(saveFlag, modname, javaName, content)
    javaName
  end

  # Extract tag info from type for optional field tagging
  defp extract_tag_info(type) do
    case type do
      {:tag, _loc, :CONTEXT, tag_num, _, inner_type} -> {:context, tag_num, inner_type}
      _ -> nil
    end
  end

  @impl true
  def set(name, fields, modname, saveFlag) do
     # Similar to Sequence but extends ASN1Set?
     sequence(name, fields, modname, saveFlag)
  end

  @impl true
  def choice(name, _cases, modname, saveFlag) do
      javaName = name(name, modname)
      content = """
package com.generated.asn1;

#{emitImports()}

public class #{javaName} extends ASN1Object<Object> {
    private final ASN1Object decorated;

    public #{javaName}(ASN1Object decorated) {
        super(decorated.getTag());
        this.decorated = decorated;
    }

    @Override
    public Object getValue() {
        return decorated.getValue();
    }
}
"""
      save(saveFlag, modname, javaName, content)
      javaName
  end

  @impl true
  def enumeration(name, cases, modname, saveFlag) do
    javaName = name(name, modname)
    setEnv(name, javaName)

    entries = cases
    |> Enum.filter(fn {:NamedNumber, _, _} -> true; _ -> false end)
    |> Enum.map(fn {:NamedNumber, ident, val} ->
       sanitized = ident
       |> to_string()
       |> String.replace("-", "_")
       |> String.upcase()

       # Check value range for int vs long
       val_str = if val > 2147483647 or val < -2147483648 do
         "#{val}L"
       else
         "#{val}"
       end

       "#{sanitized}(#{val_str})"
    end)
    |> Enum.join(",\n  ")

    # Determine backing type based on max value
    has_long = Enum.any?(cases, fn
      {:NamedNumber, _, val} -> val > 2147483647 or val < -2147483648
      _ -> false
    end)

    type = if has_long, do: "long", else: "int"
    method_type = if has_long, do: "long", else: "int"

    content = """
package com.generated.asn1;

public enum #{javaName} {
  #{entries};

  private final #{type} value;
  #{javaName}(#{type} value) { this.value = value; }
  public #{method_type} getValue() { return value; }
}
"""
    save(saveFlag, modname, javaName, content)
    javaName
  end

  @impl true
  def integerEnum(name, cases, modname, saveFlag), do: enumeration(name, cases, modname, saveFlag)

  @impl true
  def substituteType(type) do
     builtinType(type)
  end

  @impl true
  def tagClass(_tag), do: ""

  defp emitImports do
      """
import com.hierynomus.asn1.types.*;
import com.hierynomus.asn1.types.constructed.*;
import com.hierynomus.asn1.types.primitive.*;
import com.hierynomus.asn1.types.string.*;
import java.util.List;
"""
  end

  @impl true
  def value(name, _type, val, modname, saveFlag) do
     # Constants
     javaName = name(name, modname)

     content = cond do
       is_nested_oid(val) ->
         {ref_mod, ref_name, suffix_str} =
           case val do
             [{{:seqtag, _, m, n}, s}] -> {m, n, format_oid([s])}
             [{:Externalvaluereference, _, m, n} | tail] -> {m, n, format_oid(tail)}
             {:Externalvaluereference, _, m, n} -> {m, n, ""}
           end

         # Resolve Java name for mod and ref using global lookup to handle imports
         resolved = lookup(to_string(ref_name))

         {resolution_type, base_val} = case to_string(ref_name) do
             root when root in ["iso", "isu"] -> {:literal, "1"}
             root when root in ["itu-t", "ccitt"] -> {:literal, "0"}
             root when root in ["joint-iso-itu-t", "joint-iso-ccitt"] -> {:literal, "2"}
             _ ->
                 p = if resolved != to_string(ref_name), do: resolved, else: name(ref_name, ref_mod)
                 {:ref, p}
         end

         value_expr = case resolution_type do
            :literal ->
                if suffix_str == "" do
                    "new ASN1ObjectIdentifier(\"#{base_val}\")"
                else
                    "new ASN1ObjectIdentifier(\"#{base_val}.#{suffix_str}\")"
                end
            :ref ->
                if suffix_str == "" do
                    "#{base_val}.VALUE"
                else
                    "new ASN1ObjectIdentifier(#{base_val}.VALUE.getValue() + \".#{suffix_str}\")"
                end
         end

         """
package com.generated.asn1;

import com.hierynomus.asn1.types.primitive.ASN1ObjectIdentifier;

public class #{javaName} {
    public static final ASN1ObjectIdentifier VALUE = #{value_expr};
}
"""

       isOID(val) ->
        oid_str = format_oid(val)
        """
package com.generated.asn1;

import com.hierynomus.asn1.types.primitive.ASN1ObjectIdentifier;

public class #{javaName} {
    public static final ASN1ObjectIdentifier VALUE = new ASN1ObjectIdentifier("#{oid_str}");
}
"""
       true ->
        "public class #{javaName} { /* val=#{inspect(val)} */ }"
     end

     save(saveFlag, modname, javaName, content)
     javaName
  end

  defp is_nested_oid([{{:seqtag, _, _, _}, suffix}]) when is_integer(suffix), do: true
  defp is_nested_oid([{:Externalvaluereference, _, _, _} | _]), do: true
  defp is_nested_oid({:Externalvaluereference, _, _, _}), do: true
  defp is_nested_oid(_), do: false

  defp isOID(list) when is_list(list) do
      Enum.all?(list, fn
          {:NamedNumber, _, _} -> true
          x when is_integer(x) -> true
          _ -> false
      end)
  end
  defp isOID(_), do: false


  defp format_oid(list) do
      list
      |> Enum.map(fn
          {:NamedNumber, _, val} -> "#{val}"
          val -> "#{val}"
      end)
      |> Enum.join(".")
  end


  @impl true
  def algorithmIdentifierClass(name, modname, saveFlag), do: sequence(name, [], modname, saveFlag) # Mock

  @impl true
  def integerValue(name, val, modname, saveFlag) do
    javaName = name(name, modname)
    content = cond do
       is_integer(val) ->
         """
package com.generated.asn1;

import com.hierynomus.asn1.types.primitive.ASN1Integer;

public class #{javaName} {
    public static final ASN1Integer VALUE = new ASN1Integer(#{val}L);
}
"""
       # Handle references (single tuple or list)
       is_list(val) or is_tuple(val) ->
         # Resolve reference
         {ref_mod, ref_name} = case val do
             [{:Externalvaluereference, _, m, n} | _] -> {m, n}
             {:Externalvaluereference, _, m, n} -> {m, n}
             _ -> {nil, nil}
         end

         if ref_name == nil do
             "public class #{javaName} { /* val=#{inspect(val)} */ }"
         else
             resolved = lookup(to_string(ref_name))
             parent_class = if resolved != to_string(ref_name), do: resolved, else: name(ref_name, ref_mod)

             """
package com.generated.asn1;

import com.hierynomus.asn1.types.primitive.ASN1Integer;

public class #{javaName} {
    public static final ASN1Integer VALUE = #{parent_class}.VALUE;
}
"""
         end

       true ->
         "public class #{javaName} { /* val=#{inspect(val)} */ }"
    end

    save(saveFlag, modname, javaName, content)
    javaName
  end

  # Helpers. Imported at top.

  defp to_java_type({:type, _, inner, _, _, _}, modname), do: to_java_type(inner, modname)
  defp to_java_type({:Externaltypereference, _, :"PKIX1Explicit-2009", :AlgorithmIdentifier}, _), do: "PKIX1Explicit88_AlgorithmIdentifier"
  defp to_java_type({:Externaltypereference, _, mod, type}, _), do: name(type, mod)
  defp to_java_type({:"SEQUENCE OF", inner}, modname), do: "List<" <> to_java_type(inner, modname) <> ">"
  defp to_java_type(atom, _) when is_atom(atom), do: builtinType(atom)
  defp to_java_type(_, _), do: "ASN1Object"

  defp normalize_java_name(name, modname) do
    raw_name = bin(normalizeName(name))
    nname = if String.upcase(raw_name) == raw_name and String.downcase(raw_name) != raw_name do
       raw_name <> "_"
    else
       raw_name
    end

    nmod = bin(normalizeName(modname))
    if String.starts_with?(nname, nmod) do
       nname
    else
       nmod <> "_" <> nname
    end
  end

  defp normalize_field_name(name) do
    n = bin(normalizeName(name)) |> String.downcase()
    # Escape Java reserved keywords
    case n do
      "value" -> "valueField"
      "tag" -> "tagField"
      "length" -> "lengthField"
      "default" -> "defaultField"
      "class" -> "classField"
      "public" -> "publicField"
      "private" -> "privateField"
      "static" -> "staticField"
      "final" -> "finalField"
      "new" -> "newField"
      "return" -> "returnField"
      "void" -> "voidField"
      "null" -> "nullField"
      "true" -> "trueField"
      "false" -> "falseField"
      "abstract" -> "abstractField"
      "package" -> "packageField"
      "import" -> "importField"
      "enum" -> "enumField"
      "interface" -> "interfaceField"
      "extends" -> "extendsField"
      "implements" -> "implementsField"
      "instanceof" -> "instanceofField"
      "super" -> "superField"
      "this" -> "thisField"
      "native" -> "nativeField"
      "strictfp" -> "strictfpField"
      "synchronized" -> "synchronizedField"
      "transient" -> "transientField"
      "volatile" -> "volatileField"
      "assert" -> "assertField"
      "case" -> "caseField"
      "catch" -> "catchField"
      "do" -> "doField"
      "else" -> "elseField"
      "finally" -> "finallyField"
      "for" -> "forField"
      "if" -> "ifField"
      "goto" -> "gotoField"
      "switch" -> "switchField"
      "throw" -> "throwField"
      "throws" -> "throwsField"
      "try" -> "tryField"
      "while" -> "whileField"
      "break" -> "breakField"
      "continue" -> "continueField"
      "const" -> "constField"
      other -> other
    end
  end

  defp capitalize(str) do
      {head, tail} = String.split_at(str, 1)
      String.upcase(head) <> tail
  end
end
