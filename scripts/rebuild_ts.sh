rm -rf Languages/TypeScript/genereted
rm -rf Languages/TypeScript/generated   

ASN1_LANG=typescript ASN1_OUTPUT=Languages/TypeScript/generated elixir basic.ex
ASN1_LANG=typescript ASN1_OUTPUT=Languages/TypeScript/generated elixir x-series.ex
cd Languages/TypeScript
git clone https://github.com/iho/der.ts
