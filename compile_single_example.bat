@echo off
setlocal

pushd examples
pushd text
jai -import_dir ../.. -x64  -plug Icon -icon ../raylib.ico text_codepoints_loading.jai || exit /b
popd
popd