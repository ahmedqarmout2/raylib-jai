@echo off
setlocal

pushd examples

pushd audio
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd core
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd models
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd shaders
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd shapes
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd text
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd textures
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

popd

pushd games

pushd cat_vs_roomba

jai -import_dir ../../.. -x64 src/cat_vs_roomba.jai

popd

pushd classics

jai -import_dir ../../.. -x64 src/snake.jai

jai -import_dir ../../.. -x64 src/space_invaders.jai

popd

popd