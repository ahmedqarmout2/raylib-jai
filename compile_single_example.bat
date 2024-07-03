@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_draw_tiled.jai || exit /b
popd
popd