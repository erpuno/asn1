#!/bin/bash

sh scripts/clean.sh
sh scripts/rebuild_c99.sh

printf '\n: running C99 Test Roundtrip\n'
./Languages/C99/test_roundtrip
printf '\n: running C99 Test Suite\n'
./Languages/C99/test_suite
printf '\n: running C99 CMP Client\n'
./Languages/C99/c99_client

