@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_to_image.jai || exit /b
popd
popd