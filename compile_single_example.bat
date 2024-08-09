@echo off
setlocal

pushd examples
pushd audio
jai -import_dir ../.. -x64  -plug Icon -icon ../raylib.ico audio_mixed_processor.jai || exit /b
popd
popd