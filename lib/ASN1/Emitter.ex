defmodule ASN1.Emitter do
  @callback name(binary, binary) :: binary
  @callback fieldName(any) :: binary
  @callback fieldType(binary, binary, any) :: binary
  @callback array(binary, binary, atom, binary) :: binary
  @callback sequence(binary, any, binary, boolean) :: any
  @callback set(binary, any, binary, boolean) :: any
  @callback choice(binary, any, binary, boolean) :: any
  @callback enumeration(binary, any, binary, boolean) :: any
  @callback integerEnum(binary, any, binary, boolean) :: any
  @callback substituteType(binary) :: binary
  @callback tagClass(any) :: binary
  @callback typealias(binary, binary, binary, boolean) :: any
  @callback value(binary, any, any, binary, boolean) :: any
  @callback fileExtension() :: binary
  @callback builtinType(atom) :: binary
  @callback finalize() :: any
end
