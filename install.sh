#!/usr/bin/env bash
cd "$(dirname "$0")" 
export SCRIPT_DIR="$(pwd)"
export VERSION=1.1.2.0

cd $SCRIPT_DIR/target
echo Extract files to ~:
unzip -o LRKomoot$VERSION"_mac.zip" -d ~
echo done
