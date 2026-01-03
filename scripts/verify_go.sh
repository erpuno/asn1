#!/bin/bash

sh scripts/clean.sh
sh scripts/rebuild_go.sh

cd Languages/Go
go build -buildvcs=false
./tobirama
cd ../..

