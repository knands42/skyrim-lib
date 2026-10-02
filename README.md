This is a basic plugin template for use with CommonLibSSE-NG

## Requirements

### Manual Steps

* [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
	* Desktop development with C++ workload (provides Windows SDK, MSVC headers and CRT — required even when using clang-cl)

* [The Elder Scrolls V: Skyrim Special Edition](https://store.steampowered.com/app/489830)
	* Add the environment variable `Skyrim64Path` to point to the root installation of your game directory (the one containing `SkyrimSE.exe`).

```ps1
scoop install cmake
scoop install llvm
scoop install ninja
scoop install vcpkg
```

### Set environment variables

Overwrite these environment values based on your own path locations...
```ps1
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:/path/to/vcpkg", "User")
[System.Environment]::SetEnvironmentVariable("CMAKE_MAKE_PROGRAM", $(where.exe ninja), "User")
[System.Environment]::SetEnvironmentVariable("PAPYRUS_COMPILER", "C:\Steam\steamapps\common\Skyrim Special Edition\Papyrus Compiler", "User")
```

> Open a fresh terminal after setting these so they are picked up.

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

```
<Skyrim root>\Data\SKSE\Plugins\<YourPlugin>.dll
```

For Wabbajack / MO2 modlists using a Stock Game folder, add the DLL as a mod in MO2:
1. Create `<modlist>\mods\<YourPlugin>\SKSE\Plugins\<YourPlugin>.dll`
2. Enable the mod in MO2's left panel
3. Launch the game via MO2's SKSE button

Or copy directly to `<modlist>\Stock Game\Data\SKSE\Plugins\` (bypasses MO2, harder to manage).

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
Stop-Process -Name ninja,cmake,clang-cl -ErrorAction SilentlyContinue

# Build filtering only error messages
cmake --build --preset ninja-windows-debug 2>&1 | Select-String "error:"

# Clean rebuild
Remove-Item -Recurse -Force build
cmake --preset ninja-windows
cmake --build --preset ninja-windows-debug
```

## Tips

* Set `COPY_OUTPUT` to `ON` to automatically copy the built dll to the game directory:
  `cmake --preset ninja-windows -DCOPY_OUTPUT=ON`
* Build the `package` target to automatically build and zip up your dll in a ready-to-distribute format.
* If CLion cannot find Ninja, launch CLion from a terminal that has Scoop on its PATH so it inherits the environment.
