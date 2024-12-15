@echo off
setlocal

pushd examples

pushd shaders
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

popd