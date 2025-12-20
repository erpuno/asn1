rm -rf Sources/Suite/Basic
rm -rf Sources/Suite/XSeries
ASN1_LANG=swift ASN1_OUTPUT=Sources/Suite/Basic elixir basic.ex
ASN1_LANG=swift ASN1_OUTPUT=Sources/Suite/XSeries elixir x-series.ex