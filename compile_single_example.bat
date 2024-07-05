@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_mouse_painting.jai || exit /b
popd
popd