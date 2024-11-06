@echo off
setlocal

pushd examples
pushd shaders
jai -import_dir ../.. -x64 -plug Icon -icon ../raylib.ico shaders_texture_waves.jai || exit /b
popd
popd