This is a basic plugin template to use with CommonLibSSE-NG and other common integrations.

> **NOTE:** Overwrite all places that contains the string `MyPlugin` to your plugin name.

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
[System.Environment]::SetEnvironmentVariable("PAPYRUS_COMPILER", "C:\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler", "User")
[System.Environment]::SetEnvironmentVariable("SKYRIM_SCRIPTS", "C:\Steam\steamapps\common\Skyrim Special Edition\Data\Source\Scripts", "User")
[System.Environment]::SetEnvironmentVariable("SkyrimSE_PATH", "C:\Steam\steamapps\common\Skyrim Special Edition", "User")
[System.Environment]::SetEnvironmentVariable("SkyrimModlist_PATH", "D:\Modlists\Skyrim\WabajackModlist", "User")
```

Some of these environment variables needs also to be in your PATH, like `PAPYRUS_COMPILER`.

> **Note:** Try opening a new powershell session to run the next commands.
>
> CMake will make sure to capture these variables and re-export them in two different format (\$VARIABLE and \$env:VARIABLE).
> 
> If fails try **rebooting the machine**.


## Building

```ps1
# Clone submodules (CommonLibSSE-NG)
git submodule update --init --recursive

# Configure (run once, or after CMakePresets.json changes)
cmake --preset ninja-windows

# Build Debug
cmake --build --preset ninja-windows-debug

# Build Release
cmake --build --preset ninja-windows-release
```

## Deploying

Copy the built `.dll` to your game's SKSE plugins folder:

```ps1
just deploy-to-vanilla
```

For Wabbajack / MO2 modlists using a Stock Game folder:
```ps1
just deploy-to-modlist
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

* Set `COPY_OUTPUT` to `ON` to automatically copy the built dll to the game directory:
  `cmake --preset ninja-windows -DCOPY_OUTPUT=ON`
* Build the `package` target to automatically build and zip up your dll in a ready-to-distribute format.
* If CLion cannot find Ninja, launch CLion from a terminal that has Scoop on its PATH so it inherits the environment.
