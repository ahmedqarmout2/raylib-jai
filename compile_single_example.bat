@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_fog_of_war.jai || exit /b
popd
popd