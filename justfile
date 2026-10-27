set shell := ["powershell.exe", "-NoProfile", "-Command"]
set script-interpreter := ["powershell.exe", "-NoProfile", "-Command"]

export PROJECT_NAME := "MyPlugin"

[script]
setup:
    git submodule update --init --recursive
    cd external
    cmake -B Common/build -S Common -DCMAKE_INSTALL_PREFIX=extern Common
    cmake --build Common/build --config Release --target install
    cmake -B SKSE64/build -S SKSE64 -DCMAKE_INSTALL_PREFIX=extern SKSE64
    cmake --build SKSE64/build --config Release

configure:
    cmake --preset ninja-windows

build: configure
    cmake --build --preset ninja-windows-debug

release: configure
    cmake --build --preset ninja-windows-release

stop-bg-process:
    Stop-Process -Name ninja,cmake,clang-cl -ErrorAction SilentlyContinue

rebuild: stop-bg-process
    Remove-Item -Recurse -Force build
    cmake --preset ninja-windows
    cmake --build --preset ninja-windows-debug

build-check-errors:
    cmake --build --preset ninja-windows-debug 2>&1 | Select-String "error:"

zip-mod:
    cmake --preset ninja-windows -DZIP_MOD=true
    cmake --build --preset ninja-windows-release

[script]
deploy-to-modlist:
    cmake --preset ninja-windows -DDEPLOY_OUTPUT=true
    cmake --build --preset ninja-windows-release

[script]
deploy-to-vanilla:
    cmake --preset ninja-windows -DDEPLOY_OUTPUT=true
    cmake --build --preset ninja-windows-release


# ------------- scripts already managed by CMAKE, but kept here for alternative build paths

[script]
merge-skse-scripts:
    $skse = "{{justfile_directory()}}\external\SKSE64"
    $vanilla = "$skse\scripts\vanilla"
    $modified = "$skse\scripts\modified"
    $merged = "$skse\scripts\merged"
    New-Item -ItemType Directory -Path $merged -Force | Out-Null
    Copy-Item "$vanilla\*" "$merged\" -Force
    Get-ChildItem "$modified\*.psc" | ForEach-Object {
        $name = $_.Name
        $mContent = Get-Content $_.FullName -Raw
        $mFirst = ($mContent -split "`n")[0].Trim()
        if ($mFirst -notmatch '^Scriptname') {
            $vFile = Join-Path $merged $name
            if (Test-Path $vFile) {
                Add-Content $vFile "`n$mContent" -NoNewline
            }
        } else {
            Copy-Item $_.FullName "$merged\" -Force
        }
    }
    Write-Host "SKSE scripts merged successfully"

compiler-papyrus: merge-skse-scripts
    PapyrusCompiler.exe "{{justfile_directory()}}\src\papyrus\{{PROJECT_NAME}}.psc" \
      -f="$env:SKYRIM_SCRIPTS\TESV_Papyrus_Flags.flg" \
      -i="{{justfile_directory()}}\external\SKSE64\scripts\merged;$env:SKYRIM_SCRIPTS;{{justfile_directory()}}\external\SkyUI\source\scripts;{{justfile_directory()}}\src\papyrus" \
      -o="{{justfile_directory()}}\build\papyrus" -op

[script]
post-build-modlist-deploy:
    $modlist = $env:SkyrimModlist_PATH
    if (-not $modlist) { throw "SkyrimModlist_PATH is not set" }
    $modFolder = Join-Path $modlist "mods\{{PROJECT_NAME}}"
    New-Item -ItemType Directory -Force -Path "$modFolder\SKSE\Plugins", "$modFolder\Scripts" | Out-Null
    Copy-Item "{{justfile_directory()}}\build\src\Release\{{PROJECT_NAME}}.dll" "$modFolder\SKSE\Plugins\" -Force
    Copy-Item "{{justfile_directory()}}\build\papyrus\{{PROJECT_NAME}}.pex" "$modFolder\Scripts\" -Force
    Copy-Item "{{justfile_directory()}}\<YourPlugin>.exp" "$modFolder\" -Force
    Write-Host "Deployed to $modFolder"
    Write-Host "Enable '{{PROJECT_NAME}}' in MO2's left panel, then launch with the SKSE button."

[script]
post-build-vanilla-deploy:
    $baseGame = $env:SkyrimSE_PATH
    if (-not $baseGame) { throw "SkyrimSE_PATH is not set" }
    New-Item -ItemType Directory -Force -Path "$baseGame\Data\SKSE\Plugins", "$baseGame\Data\Scripts" | Out-Null
    Copy-Item "{{justfile_directory()}}\build\src\Release\{{PROJECT_NAME}}.dll" "$baseGame\Data\SKSE\Plugins\" -Force
    Copy-Item "{{justfile_directory()}}\build\papyrus\{{PROJECT_NAME}}.pex" "$baseGame\Data\Scripts\" -Force
    Copy-Item "{{justfile_directory()}}\<YourPlugin>.esp" "$baseGame\Data\" -Force
    
    # For PRISMA_UI
    # Copy-Item "{{justfile_directory()}}\src\integrations\prismaui\views\<YourPlugin>\*" "$baseGame\Data\PrismaUI\views\<YourPlugin>\" -Recurse -Force
    
    Write-Host "Deployed to $baseGame"
    Write-Host "Launch with the SKSE executable."

