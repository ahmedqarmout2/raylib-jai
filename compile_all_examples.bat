@echo off
setlocal

pushd examples

pushd audio
for %%i in (*.jai) do jai -import_dir ../.. -x64 -plug Icon -icon ../raylib.ico %%i || exit /b
popd

pushd core
for %%i in (*.jai) do jai -import_dir ../.. -x64 -plug Icon -icon ../raylib.ico %%i || exit /b
popd

pushd text
for %%i in (*.jai) do jai -import_dir ../.. -x64 -plug Icon -icon ../raylib.ico %%i || exit /b
popd

pushd textures
for %%i in (*.jai) do jai -import_dir ../.. -x64 -plug Icon -icon ../raylib.ico %%i || exit /b
popd

popd