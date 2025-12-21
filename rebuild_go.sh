rm -rf go_project/chat
rm -rf go_project/chat_xseries

ASN1_LANG=go ASN1_OUTPUT=go_project/chat elixir basic.ex
ASN1_LANG=go ASN1_OUTPUT=go_project/chat_xseries elixir x-series.ex
