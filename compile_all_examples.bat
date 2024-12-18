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

pushd text
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd textures
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

popd