#!/bin/bash

sh clean.sh
sh rebuild_go.sh

cd Languages/Go
go build -buildvcs=false
./tobirama
cd ../..

