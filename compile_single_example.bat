@echo off
setlocal

pushd examples
pushd textures
jai -import_dir ../.. -x64 textures_gif_player.jai || exit /b
popd
popd