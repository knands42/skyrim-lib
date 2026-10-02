set shell := ["powershell.exe", "-NoProfile", "-Command"]

configure:
    cmake --preset ninja-windows

build: configure
    cmake --build --preset ninja-windows-debug

release: configure
    cmake --build --preset ninja-windows-release

stop-bg-process:
    Stop-Process -Name ninja,cmake,clang-cl -ErrorAction SilentlyContinue

clean: stop-bg-process
    Remove-Item -Recurse -Force build
    cmake --preset ninja-windows
    cmake --build --preset ninja-windows-debug

build-check-errors:
    cmake --build --preset ninja-windows-debug 2>&1 | Select-String "error:"

compiler-papyrus:
    PapyrusCompiler.exe "{{justfile_directory()}}\src\papyrus\heartbound.psc" \
      -f="$env:SKYRIM_SCRIPTS\TESV_Papyrus_Flags.flg" \
      -i="$env:SKYRIM_SCRIPTS;{{justfile_directory()}}\external\SkyUI\source\scripts;{{justfile_directory()}}\src\papyrus" \
      -o="{{justfile_directory()}}\build\papyrus" -op
