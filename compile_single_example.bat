@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_raw_data.jai || exit /b
popd
popd