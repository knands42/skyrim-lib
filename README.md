# SkyrimLib
A template for quick bootstrapping of new Skyrim mods 

## Requirements

### Manual Steps

* [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
    * Desktop development with C++ workload (provides Windows SDK, MSVC headers and CRT — required even when using clang-cl)
* [scoop](https://scoop.sh/)
    * A package manager for windows

```ps1
scoop install cmake
scoop install llvm
scoop install ninja
scoop install vcpkg
scoop install just
```

### Set environment variables

Overwrite these environment values based on your own path locations...
```ps1
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:/path/to/vcpkg", "User")
[System.Environment]::SetEnvironmentVariable("CMAKE_MAKE_PROGRAM", $(where.exe ninja), "User")
[System.Environment]::SetEnvironmentVariable("PAPYRUS_COMPILER", "C:\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe", "User")
[System.Environment]::SetEnvironmentVariable("SKYRIM_SCRIPTS", "C:\Steam\steamapps\common\Skyrim Special Edition\Data\Source\Scripts", "User")
[System.Environment]::SetEnvironmentVariable("SkyrimSE_PATH", "C:\Steam\steamapps\common\Skyrim Special Edition", "User")

# Optional, only if working with a wabbajack modlist
[System.Environment]::SetEnvironmentVariable("SkyrimModlist_PATH", "D:\Modlists\Skyrim\WabajackModlist", "User")
```

> **Note:** Some of these environment variables needs also to be in your PATH, like `PAPYRUS_COMPILER`.

> **Note:** Try opening a new PowerShell session to run the next commands.
>
> CMake will make sure to capture these variables and re-export them in two different format (\$VARIABLE and \$env:VARIABLE).
> 
> If fails try **rebooting the machine**.

## Building

```ps1
just setup

# Configure (run once, or after CMakePresets.json changes)
just configure

# Build Debug
just build

# Build Release
just release
```

## Deploying

Copy the built `.dll` + `.pex` + `.esp` into your game's folder:

```ps1
just deploy
```

## Logs

After launching via SKSE, plugin logs appear at:
```
%USERPROFILE%\Documents\My Games\Skyrim Special Edition\SKSE\<YourPlugin>.log
```

SKSE's own load log (confirms your plugin loaded):
```
%USERPROFILE%\Documents\My Games\Skyrim Special Edition\SKSE\skse64.log
```

> Debug builds log to the MSVC output window only. Build Release to get a log file.

## Debug helper commands

```ps1
# Stop all pending background cpp processes
just stop-bg-process

# Build filtering only error messages
just build-check-errors

# Clean & rebuild
just rebuild
```

## Tips

* Set `DEPLOY_OUTPUT` to `true` to automatically copy the built dll to the game directory:
  `cmake --preset ninja-windows -DDEPLOY_OUTPUT=ON`
* Set `ZIP_MOD` to `true` to automatically zip into a copy and paste, mod manager ready mod format
  `cmake --preset ninja-windows -DZIP_MOD=ON`
* If `SkyrimModlist_PATH` is set, it will override the `SkyrimSE_PATH` environment
