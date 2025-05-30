#!/bin/bash
cd examples

cd audio
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd core
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd models
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd shaders
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd shapes
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd text
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd textures
for i in *.jai; do jai-macos -import_dir ../.. -x64 "$i" || break; done
cd ..

cd ..