@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_sprite_explosion.jai || exit /b
popd
popd