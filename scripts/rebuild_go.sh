rm -rf Languages/Go/chat
rm -rf Languages/Go/chat_xseries

ASN1_LANG=go ASN1_OUTPUT=Languages/Go/chat elixir basic.ex
ASN1_LANG=go ASN1_OUTPUT=Languages/Go/chat_xseries elixir x-series.ex

