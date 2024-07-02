@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_bunnymark.jai || exit /b
popd
popd