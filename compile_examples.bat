@echo off
setlocal


pushd examples
for %%i in (*.jai) do jai -import_dir .. -x64 %%i || exit /b

pushd core
for %%i in (*.jai) do jai -import_dir ../.. -x64 %%i || exit /b

popd
popd