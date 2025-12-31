defmodule ASN1.JavaEmitter do
  @behaviour ASN1.Emitter
  import ASN1, only: [bin: 1, normalizeName: 1, getEnv: 2, setEnv: 2, print: 2, save: 4, lookup: 1]

  @impl true

  def finalize do
    dir = ASN1.outputDir()
    # ASN1.outputDir returns deep source path (e.g. .../com/generated/asn1/)
    # We need to write build files to project root (Languages/Java)
    # Traversing up: asn1 -> generated -> com -> java -> main -> src -> Java (root) = 6 levels
    project_root = Path.expand("../../../../../..", dir)

    IO.puts("Generating Gradle build files in #{project_root}")

    # settings.gradle
    settings = """
rootProject.name = 'generated-asn1'
includeBuild '../der-java'
"""
    File.write!(Path.join(project_root, "settings.gradle"), settings)

    # build.gradle
    build = """
plugins {
    id 'java'
    id 'application'
}

group = 'com.generated.asn1'
version = '1.0.0'

application {
    mainClass = 'com.generated.asn1.Main'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.iho.asn1:der-java:1.0.0'
}
"""
    File.write!(Path.join(project_root, "build.gradle"), build)

    # Generate ASN1Utilities helper
    utilities = """
package com.iho.asn1;

import java.util.ArrayList;
import java.util.List;

public class ASN1Utilities {
    public interface NodeDecoder<T> {
        T decode(ASN1Node node) throws ASN1Exception;
    }

    public static void serializeNode(DERWriter writer, ASN1Node node) throws ASN1Exception {
        if (node.content instanceof ASN1Node.Primitive) {
             writer.writePrimitive(node.identifier, ((ASN1Node.Primitive) node.content).data);
        } else {
             writer.writeConstructed(node.identifier, nested -> {
                 // Constructed implements Iterable<ASN1Node>
                 for (ASN1Node child : (ASN1Node.Constructed) node.content) {
                     serializeNode(nested, child);
                 }
             });
        }
    }

    public static <T> List<T> parseList(ASN1Node node, NodeDecoder<T> decoder) throws ASN1Exception {
        if (!(node.content instanceof ASN1Node.Constructed)) {
             throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Expected constructed node for SEQUENCE OF/SET OF");
        }
        List<T> result = new ArrayList<>();
        for (ASN1Node child : (ASN1Node.Constructed) node.content) {
             result.add(decoder.decode(child));
        }
        return result;
    }
}
"""
    File.write!(Path.join(dir, "ASN1Utilities.java"), utilities)

    :ok
  end

  defp decoder_for(type, node) do
     cond do
         type == "ASN1Node" -> node
         String.starts_with?(type, "List<") ->
             t = String.slice(type, 5..-2)
             "ASN1Utilities.parseList(#{node}, n -> #{decoder_for(t, "n")})"
         String.starts_with?(type, "ASN1") ->
             case type do
                 "ASN1Integer" -> "new ASN1Integer(0L).fromDERNode(#{node})"
                 "ASN1Boolean" -> "new ASN1Boolean(false).fromDERNode(#{node})"
                 "ASN1BitString" -> "new ASN1BitString(new byte[0], 0).fromDERNode(#{node})"
                 "ASN1OctetString" -> "new ASN1OctetString(new byte[0]).fromDERNode(#{node})"
                 "ASN1Null" -> "ASN1Null.INSTANCE.fromDERNode(#{node})"
                 "ASN1ObjectIdentifier" -> "new ASN1ObjectIdentifier(\"0.0\").fromDERNode(#{node})"
                 "ASN1Real" -> "new ASN1Real(0.0).fromDERNode(#{node})"
                 "ASN1Time." <> sub -> "new ASN1Time.#{sub}(java.time.ZonedDateTime.now()).fromDERNode(#{node})"
                 "ASN1String." <> sub -> "new ASN1String.#{sub}(\"\").fromDERNode(#{node})"
                 _ -> "new #{type}().fromDERNode(#{node})"
             end
         true -> "new #{type}(#{node})"
     end
  end

  @impl true
  def fileExtension, do: ".java"

  @impl true
  def name(name, modname) do
    normalize_java_name(name, modname)
  end

  @impl true
  def builtinType(type) do
      case type do
        :INTEGER -> "ASN1Integer"
        :BOOLEAN -> "ASN1Boolean"
        :"BIT STRING" -> "ASN1BitString"
        :"OCTET STRING" -> "ASN1OctetString"
        :NULL -> "ASN1Null"
        :OBJECT_IDENTIFIER -> "ASN1ObjectIdentifier"
        :GeneralizedTime -> "ASN1Time.GeneralizedTime"
        :UTCTime -> "ASN1Time.UTCTime"
        :IA5String -> "ASN1String.IA5String"
        :PrintableString -> "ASN1String.PrintableString"
        :UTF8String -> "ASN1String.UTF8String"
        :TeletexString -> "ASN1String.TeletexString"
        :T61String -> "ASN1String.TeletexString"
        :VideotexString -> "ASN1String.VideotexString"
        :GraphicString -> "ASN1String.GraphicString"
        :VisibleString -> "ASN1String.VisibleString"
        :GeneralString -> "ASN1String.GeneralString"
        :UniversalString -> "ASN1String.UniversalString"
        :BMPString -> "ASN1String.BMPString"
        :NumericString -> "ASN1String.NumericString"
        :ObjectDescriptor -> "ASN1Node" # Fallback
        :External -> "ASN1Node" # Fallback
        :REAL -> "ASN1Real"
        :EmbeddedPDV -> "ASN1Node" # Fallback
        _ -> "ASN1Node"
      end
  end


  @impl true
  def typealias(name, type, modname, saveFlag) do
      javaName = name(name, modname)
      targetType = to_java_type(type, modname)

      instantiateFromNode = if targetType == "ASN1Node" do
          "node"
      else
        if String.starts_with?(targetType, "ASN1") do
             case targetType do
                 "ASN1Integer" -> "new ASN1Integer(0L).fromDERNode(node)"
                 "ASN1Boolean" -> "new ASN1Boolean(false).fromDERNode(node)"
                 "ASN1BitString" -> "new ASN1BitString(new byte[0], 0).fromDERNode(node)"
                 "ASN1OctetString" -> "new ASN1OctetString(new byte[0]).fromDERNode(node)"
                 "ASN1Null" -> "new ASN1Null().fromDERNode(node)"
                 "ASN1ObjectIdentifier" -> "new ASN1ObjectIdentifier(\"0.0\").fromDERNode(node)"
                 "ASN1Real" -> "new ASN1Real(0.0).fromDERNode(node)"
                 "ASN1Time." <> sub -> "new ASN1Time.#{sub}(java.time.ZonedDateTime.now()).fromDERNode(node)"
                 "ASN1String." <> sub -> "new ASN1String.#{sub}(\"\").fromDERNode(node)"
                 _ -> "new #{targetType}().fromDERNode(node)"
             end
        else
             "new #{targetType}(node)"
        end
      end

      extendsClause = "implements DERSerializable"
      serializeLogic = if targetType == "ASN1Node", do: "// ASN1Node serialization: rely on manual use or ASN1Utilities if exposed", else: "decorated.serialize(writer);"

      # Avoid duplicate constructor if targetType is ASN1Node
      constructors = if targetType == "ASN1Node" do
          """
    public #{javaName}(ASN1Node node) {
        this.decorated = node;
    }
          """
      else
          """
    public #{javaName}(#{targetType} decorated) {
        this.decorated = decorated;
    }

    public #{javaName}(ASN1Node node) throws ASN1Exception {
        this.decorated = #{instantiateFromNode};
    }
          """
      end

      serialize_implementation = if targetType == "ASN1Node" do
          "ASN1Utilities.serializeNode(writer, decorated);"
      else
          serializeLogic
      end

      content = """
package com.generated.asn1;

#{emitImports()}

public class #{javaName} #{extendsClause} {
    private final #{targetType} decorated;

#{constructors}

    public #{targetType} getValue() {
        return decorated;
    }

    public static #{javaName} parse(byte[] data) throws java.io.IOException, ASN1Exception {
        return new #{javaName}(DERParser.parse(data));
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
        #{serialize_implementation}
    }

    public byte[] serialize() throws java.io.IOException, ASN1Exception {
        DERWriter writer = new DERWriter();
        this.serialize(writer);
        return writer.toByteArray();
    }
}
"""
      save(saveFlag, modname, javaName, content)
      javaName
  end

  # ... (other functions) ...

  defp emitImports do
      """
import com.iho.asn1.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.io.IOException;
"""
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
    "ASN1Encodable"
  end

  @impl true
  def array(name, element_type, tag, level) when level == "top" do
    modname = getEnv(:current_module, "")
    javaName = name(name, modname)
    setEnv(name, javaName)
    saveFlag = getEnv(:save, false)

    elementType = to_java_type(element_type, modname)
    decoder_call = decoder_for(elementType, "child")

    method_name = if tag == :set, do: "writeSet", else: "writeSequence"
    constructor_check = if tag == :set, do: "17", else: "16"
    expected_type = if tag == :set, do: "SET OF", else: "SEQUENCE OF"

    content = """
package com.generated.asn1;

#{emitImports()}

public class #{javaName} implements DERSerializable {
    public final List<#{elementType}> elements;

    public #{javaName}(List<#{elementType}> elements) {
        this.elements = elements;
    }

    public #{javaName}(ASN1Node node) throws ASN1Exception {
        this.elements = new ArrayList<>();
        if (!(node.content instanceof ASN1Node.Constructed)) {
             throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Expected constructed type for #{expected_type}");
        }
        for (ASN1Node child : (ASN1Node.Constructed) node.content) {
             this.elements.add(#{decoder_call});
        }
    }

    public static #{javaName} parse(byte[] data) throws java.io.IOException, ASN1Exception {
        return new #{javaName}(DERParser.parse(data));
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
        writer.#{method_name}(nested -> {
            for (#{elementType} item : elements) {
                #{if elementType == "ASN1Node", do: "ASN1Utilities.serializeNode(nested, item);", else: "item.serialize(nested);"}
            }
        });
    }

    public byte[] serialize() throws java.io.IOException, ASN1Exception {
        DERWriter writer = new DERWriter();
        this.serialize(writer);
        return writer.toByteArray();
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

      # Analyze fields
      parsed_fields = fields
      |> Enum.with_index()
      |> Enum.map(fn {field, _idx} ->
          case field do
            {:ComponentType, _, fname, type, optional, tags, _} ->
              is_optional = optional in [:OPTIONAL, 'OPTIONAL']
              java_type_name = to_java_type(type, modname)
              base_decoder = decoder_for(java_type_name, "child")

              is_set_of = case type do
                  {:"SET OF", _} -> true
                  _ -> false
              end

              # Handle explicit tagging
              decoder_call = if match?([{:tag, :context, _, :explicit} | _], tags) do
                 # Extract inner
                 inner_expr = "((ASN1Node)((ASN1Node.Constructed)child.content).iterator().next())"
                 decoder_for(java_type_name, inner_expr)
              else
                 base_decoder
              end

              %{
                name: fieldName(fname),
                type: java_type_name,
                optional: is_optional,
                decoder: decoder_call,
                is_set_of: is_set_of,
                tags: tags
              }
            {:"COMPONENTS OF", _type} -> nil
            _ -> nil
          end
      end)
      |> Enum.filter(&(&1 != nil))

      # Generate Field Definitions
      java_fields = parsed_fields |> Enum.map(fn f ->
        "    public final #{f.type} #{f.name};"
      end) |> Enum.join("\n")

      # Generate Constructor Assignments
      ctor_args = parsed_fields |> Enum.map(fn f ->
        "#{f.type} #{f.name}"
      end) |> Enum.join(", ")

      ctor_assigns = parsed_fields |> Enum.map(fn f ->
        "        this.#{f.name} = #{f.name};"
      end) |> Enum.join("\n")

      # Generate Parsing Logic
      parsing_logic =
      """
        List<ASN1Node> children = new ArrayList<>();
        if (node.content instanceof ASN1Node.Constructed) {
            for (ASN1Node child : (ASN1Node.Constructed) node.content) {
                children.add(child);
            }
        }
        int idx = 0;
      """ <>
      (parsed_fields |> Enum.map(fn f ->
          if f.optional do
             """
        if (idx < children.size()) {
             // Optional logic
             ASN1Node child = children.get(idx);
             // Heuristic: assume match for now
             this.#{f.name} = #{f.decoder};
             idx++;
        } else {
             this.#{f.name} = null;
        }
             """
          else
             """
        if (idx >= children.size()) throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Missing required field #{f.name}");
        {
            ASN1Node child = children.get(idx);
            this.#{f.name} = #{f.decoder};
            idx++;
        }
             """
          end
      end) |> Enum.join("\n"))

      # Serialization Logic
      serialization_logic = parsed_fields |> Enum.map(fn f ->
           # Determine base serialization method for the field type
           base_write = cond do
               f.type == "ASN1Node" -> "ASN1Utilities.serializeNode(nested, #{f.name});"
               String.starts_with?(f.type, "List<") ->
                   t = String.slice(f.type, 5..-2)
                   method = if f.is_set_of, do: "writeSet", else: "writeSequence"
                   """
                   nested.#{method}(seqWriter -> {
                       for (#{t} item : #{f.name}) {
                           #{if t == "ASN1Node", do: "ASN1Utilities.serializeNode(seqWriter, item);", else: "item.serialize(seqWriter);"}
                       }
                   });
                   """
               true -> "#{f.name}.serialize(nested);"
           end

           # Apply tagging if present
           tagged_write = case f.tags do
               [{:tag, :context, num, :implicit} | _] ->
                   # Implicit tagging: Override the tag.
                   # For Lists (SEQUENCE/SET OF), this means replacing writeSequence/Set with writeConstructed([num])
                   # For objects, we rely on them implementing separate implicit write? No, DERSerializable writes everything.
                   # We need to capture the content and write it with new tag?
                   # Easiest way for Lists: Use writeConstructed directly.
                   if String.starts_with?(f.type, "List<") do
                       t = String.slice(f.type, 5..-2)
                       """
                       nested.writeConstructed(new ASN1Identifier(#{num}, TagClass.ContextSpecific), seqWriter -> {
                           for (#{t} item : #{f.name}) {
                               #{if t == "ASN1Node", do: "ASN1Utilities.serializeNode(seqWriter, item);", else: "item.serialize(seqWriter);"}
                           }
                       });
                       """
                   else
                       # For simple types, we can't easily re-tag without buffering.
                       # But wait, DERWriter writePrimitive takes identifier.
                       # If object provides 'serializeContent', we could use it.
                       # As a fallback for simple types wrapped in standard classes:
                       # We might need to write a helper or assume standard types.
                       # For now, let's focus on List types (attributes in PrivateKeyInfo) which are the blocker.
                       # Warning: Implicit tagging on objects is hard without API change.
                       # But for PrivateKeyInfo 'attributes' is SET OF, so it hits the List branch above.
                       base_write # Fallback for non-list implicit (potentially buggy if not handled)
                   end

               [{:tag, :context, num, :explicit} | _] ->
                   # Explicit tagging: Wrap in ContextSpecific Constructed
                   """
                   nested.writeConstructed(new ASN1Identifier(#{num}, TagClass.ContextSpecific), explicitWriter -> {
                       #{base_write.replace("nested", "explicitWriter")}
                   });
                   """

               _ -> base_write
           end

           if f.optional do
               """
            if (#{f.name} != null) {
                #{tagged_write}
            }
               """
           else
               tagged_write
           end
      end) |> Enum.join("\n")

      content = """
package com.generated.asn1;

#{emitImports()}

public class #{javaName} implements DERSerializable {
#{java_fields}

    public #{javaName}(#{ctor_args}) {
#{ctor_assigns}
    }

    public #{javaName}(ASN1Node node) throws ASN1Exception {
        if (!(node.content instanceof ASN1Node.Constructed) || node.identifier.tagNumber != 16) {
             throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Expected SEQUENCE, got " + node.identifier);
        }
#{parsing_logic}
    }

    public static #{javaName} parse(byte[] data) throws java.io.IOException, ASN1Exception {
        return new #{javaName}(DERParser.parse(data));
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
        writer.writeSequence(nested -> {
#{serialization_logic}
        });
    }

    public byte[] serialize() throws java.io.IOException, ASN1Exception {
        DERWriter writer = new DERWriter();
        this.serialize(writer);
        return writer.toByteArray();
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

public class #{javaName} implements DERSerializable {
    private final ASN1Node decorated;

    public #{javaName}(ASN1Node decorated) {
        this.decorated = decorated;
    }

    public ASN1Node getValue() {
        return decorated;
    }

    public static #{javaName} parse(byte[] data) throws java.io.IOException, ASN1Exception {
        return new #{javaName}(DERParser.parse(data));
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
        ASN1Utilities.serializeNode(writer, decorated);
    }

    public byte[] serialize() throws java.io.IOException, ASN1Exception {
        DERWriter writer = new DERWriter();
        this.serialize(writer);
        return writer.toByteArray();
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

       val_str = if val > 2147483647 or val < -2147483648 do
         "#{val}L"
       else
         "#{val}"
       end
       "#{sanitized}(#{val_str})"
    end)
    |> Enum.join(",\n        ")

    has_long = Enum.any?(cases, fn
      {:NamedNumber, _, val} -> val > 2147483647 or val < -2147483648
      _ -> false
    end)

    type = if has_long, do: "long", else: "int"

    content = """
package com.generated.asn1;

import com.iho.asn1.*;
import java.util.Iterator;
import java.math.BigInteger;

public class #{javaName} implements DERSerializable {
    public enum Value {
        #{entries};

        private final #{type} value;
        Value(#{type} value) { this.value = value; }
        public #{type} getValue() { return value; }

        public static Value fromInt(#{type} val) {
            for (Value v : values()) {
                if (v.value == val) return v;
            }
            throw new IllegalArgumentException("Unknown value: " + val);
        }
    }

    private final Value value;

    public #{javaName}(Value value) {
        this.value = value;
    }

    public #{javaName}(ASN1Node node) throws ASN1Exception {
        // Enums usually encoded as ENUMERATED (0x0A) or INTEGER (0x02).
        // If we get a ContextSpecific tag (e.g. [0]), we assume it's a tagged wrapper.
        ASN1Node effectiveNode = node;
        if (node.identifier.tagClass == TagClass.ContextSpecific) {
            if (node.isConstructed()) {
                // Explicit tagging: unwrap
                Iterator<ASN1Node> it = ((ASN1Node.Constructed)node.content).iterator();
                if (it.hasNext()) {
                    effectiveNode = it.next();
                } else {
                    throw new ASN1Exception(ErrorCode.TruncatedASN1Field, "Empty explicit tag");
                }
            } else {
                // Implicit tagging: rebrand to INTEGER
                effectiveNode = new ASN1Node(ASN1Identifier.INTEGER, node.content, node.encodedBytes);
            }
        }

        // Final check and robust rebrand
        // ASN1Integer.fromDERNode requires strict INTEGER tag (2, Universal).
        // If we have something else (ENUMERATED, ContextSpecific, etc) but it's primitive,
        // we force rebrand to INTEGER to allow parsing the value.
        if (!effectiveNode.identifier.equals(ASN1Identifier.INTEGER)) {
             if (effectiveNode.content instanceof ASN1Node.Primitive) {
                 effectiveNode = new ASN1Node(ASN1Identifier.INTEGER, effectiveNode.content, effectiveNode.encodedBytes);
             } else {
                 throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Expected Primitive node for Enum value, got " + effectiveNode.identifier);
             }
        }
        ASN1Integer val = new ASN1Integer(0L).fromDERNode(effectiveNode);
        this.value = Value.fromInt(val.value.#{if has_long, do: "longValue", else: "intValue" }());
    }

    public Value getValue() {
        return value;
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
         // Enum is serialized as ENUMERATED (0x0A)
         BigInteger val = BigInteger.valueOf(value.value);
         writer.writePrimitive(ASN1Identifier.ENUMERATED, val.toByteArray());
    }
}
"""
    save(saveFlag, modname, javaName, content)
    javaName
  end

  @impl true
  def integerEnum(name, cases, modname, saveFlag) do
    # INTEGER with named numbers - serialize as INTEGER (0x02) not ENUMERATED
    javaName = name(name, modname)
    setEnv(name, javaName)

    entries = cases
    |> Enum.filter(fn {:NamedNumber, _, _} -> true; _ -> false end)
    |> Enum.map(fn {:NamedNumber, ident, val} ->
       sanitized = ident
       |> to_string()
       |> String.replace("-", "_")
       |> String.upcase()

       val_str = if val > 2147483647 or val < -2147483648 do
         "#{val}L"
       else
         "#{val}"
       end
       "#{sanitized}(#{val_str})"
    end)
    |> Enum.join(",\n        ")

    has_long = Enum.any?(cases, fn
      {:NamedNumber, _, val} -> val > 2147483647 or val < -2147483648
      _ -> false
    end)

    type = if has_long, do: "long", else: "int"

    content = """
package com.generated.asn1;

import com.iho.asn1.*;
import java.util.Iterator;
import java.math.BigInteger;

public class #{javaName} implements DERSerializable {
    public enum Value {
        #{entries};

        private final #{type} value;
        Value(#{type} value) { this.value = value; }
        public #{type} getValue() { return value; }

        public static Value fromInt(#{type} val) {
            for (Value v : values()) {
                if (v.value == val) return v;
            }
            throw new IllegalArgumentException("Unknown value: " + val);
        }
    }

    private final Value value;

    public #{javaName}(Value value) {
        this.value = value;
    }

    public #{javaName}(ASN1Node node) throws ASN1Exception {
        ASN1Node effectiveNode = node;
        if (node.identifier.tagClass == TagClass.ContextSpecific) {
            if (node.isConstructed()) {
                Iterator<ASN1Node> it = ((ASN1Node.Constructed)node.content).iterator();
                if (it.hasNext()) {
                    effectiveNode = it.next();
                } else {
                    throw new ASN1Exception(ErrorCode.TruncatedASN1Field, "Empty explicit tag");
                }
            } else {
                effectiveNode = new ASN1Node(ASN1Identifier.INTEGER, node.content, node.encodedBytes);
            }
        }

        if (!effectiveNode.identifier.equals(ASN1Identifier.INTEGER)) {
             if (effectiveNode.content instanceof ASN1Node.Primitive) {
                 effectiveNode = new ASN1Node(ASN1Identifier.INTEGER, effectiveNode.content, effectiveNode.encodedBytes);
             } else {
                 throw new ASN1Exception(ErrorCode.UnexpectedFieldType, "Expected Primitive for Integer value");
             }
        }
        ASN1Integer val = new ASN1Integer(0L).fromDERNode(effectiveNode);
        this.value = Value.fromInt(val.value.#{if has_long, do: "longValue", else: "intValue" }());
    }

    public Value getValue() {
        return value;
    }

    @Override
    public void serialize(DERWriter writer) throws ASN1Exception {
         // INTEGER with named numbers is serialized as INTEGER (0x02)
         BigInteger val = BigInteger.valueOf(value.value);
         writer.writePrimitive(ASN1Identifier.INTEGER, val.toByteArray());
    }
}
"""
    save(saveFlag, modname, javaName, content)
    javaName
  end

  @impl true
  def substituteType(type) do
     builtinType(type)
  end

  @impl true
  def tagClass(_tag), do: ""

  defp emitImports do
      """
import com.iho.asn1.*;
import java.util.*;
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
                     "ASN1ObjectIdentifier.of(\"#{base_val}\")"
                 else
                     "ASN1ObjectIdentifier.of(\"#{base_val}.#{suffix_str}\")"
                 end
            :ref ->
                if suffix_str == "" do
                     # We assume base_val is a class having public static ASN1ObjectIdentifier VALUE
                     "ASN1ObjectIdentifier.of(#{base_val}.VALUE.toString())"
                 else
                     "ASN1ObjectIdentifier.of(#{base_val}.VALUE.toString() + \".#{suffix_str}\")"
                 end
         end

         """
package com.generated.asn1;

import com.iho.asn1.ASN1ObjectIdentifier;

public class #{javaName} {
    public static final ASN1ObjectIdentifier VALUE = #{value_expr};
}
"""

       isOID(val) ->
        oid_str = format_oid(val)
        """
package com.generated.asn1;

import com.iho.asn1.ASN1ObjectIdentifier;

public class #{javaName} {
    public static final ASN1ObjectIdentifier VALUE = ASN1ObjectIdentifier.of("#{oid_str}");
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

import com.iho.asn1.ASN1Integer;

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

import com.iho.asn1.ASN1Integer;

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

  defp to_java_type(t, modname) do
    str = inspect(t)
    cond do
      # Preserve PKIX override
      String.contains?(str, "PKIX1Explicit") and String.contains?(str, "AlgorithmIdentifier") ->
        "PKIX1Explicit88_AlgorithmIdentifier"

      # Force all other AlgorithmIdentifiers to AuthenticationFramework
      String.contains?(str, "AlgorithmIdentifier") ->
        "AuthenticationFramework_AlgorithmIdentifier"

      # Force generic Time to PKIX1Explicit88
      String.contains?(str, ":Time") and not String.contains?(str, "Signing") and not String.contains?(str, "Generalized") and not String.contains?(str, "UTC") and not String.contains?(str, "Day") ->
        "PKIX1Explicit88_Time"

      true ->
        case t do
           {:type, _, inner, _, _, _} -> to_java_type(inner, modname)
           {:Externaltypereference, _, mod, type} -> name(type, mod)
           {:"SEQUENCE OF", inner} -> "List<" <> to_java_type(inner, modname) <> ">"
           atom when is_atom(atom) -> builtinType(atom)
           _ -> "ASN1Node"
        end
    end
  end

  defp normalize_java_name(name, modname) do
    raw_name = bin(normalizeName(name))
    nname = if String.upcase(raw_name) == raw_name and String.downcase(raw_name) != raw_name do
       raw_name <> "_"
    else
       raw_name
    end

    nmod = bin(normalizeName(modname))

    # Avoid double prefixing for known modules
    if String.starts_with?(nname, nmod) or
       String.starts_with?(nname, "AuthenticationFramework_") or
       String.starts_with?(nname, "InformationFramework_") or
       String.starts_with?(nname, "CertificateExtensions_") or
       String.starts_with?(nname, "SelectedAttributeTypes_") or
       String.starts_with?(nname, "CryptographicMessageSyntax_") or
       String.starts_with?(nname, "AlgorithmInformation_") or
       String.starts_with?(nname, "AttributeCertificate") or
       String.starts_with?(nname, "Extension") or
       String.starts_with?(nname, "Tokenization") or
       String.starts_with?(nname, "ANSI_") or
       String.starts_with?(nname, "NIST_") or
       String.starts_with?(nname, "SEC_") or
       String.starts_with?(nname, "PKIX") do
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
