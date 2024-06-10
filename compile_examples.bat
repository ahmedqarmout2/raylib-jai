@echo off
setlocal


pushd examples

pushd audio
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

pushd core
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b
popd

popd