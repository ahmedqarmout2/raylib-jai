@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_npatch_drawing.jai || exit /b
popd
popd