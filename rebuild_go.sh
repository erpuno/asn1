rm -rf chat
rm -rf chat_xseries

ASN1_LANG=go ASN1_OUTPUT=chat elixir basic.ex
ASN1_LANG=go ASN1_OUTPUT=chat_xseries elixir x-series.ex
