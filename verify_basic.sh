#!/bin/bash
set -e
rm -rf Sources/Suite/Basic
elixir gen_x509.exs
swift run -Xswiftc -suppress-warnings 