This is a basic plugin template for use with CommonLibSSE

## Requirements

### Manual Steps

* [Visual Studio Community 2026](https://visualstudio.microsoft.com/)
	* Desktop development with C++

* [The Elder Scrolls V: Skyrim Special Edition](https://store.steampowered.com/app/489830)
	* Add the environment variable `Skyrim64Path` to point to the root installation of your game directory (the one containing `SkyrimSE.exe`).


```ps1
scoop install cmake
scoop install llvm
scoop install ninja
scoop install vcpkg
```

### Now set some environment variables

```ps1
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:/path/to/root", "User")
[System.Environment]::SetEnvironmentVariable("CMAKE_MAKE_PROGRAM", $(where.exe ninja), "User")
```


## Building
```ps1
git submodule init --recursive
git submodule update
cmake --preset ninja-windows -DCMAKE_MAKE_PROGRAM=$env{CMAKE_MAKE_PROGRAM} -DVCPKG_ROOT=$env{VCPKG_ROOT} -DCMAKE_TOOLCHAIN_FILE=$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
cmake --build --preset ninja-windows-debug
```

## Debug helper commands
```ps1
# Stop all pending background cpp processes
Stop-Process -Name ninja,cmake,clang-cl -ErrorAction SilentlyContinue

# Build filtering only error messages
cmake --build --preset ninja-windows-debug 2>&1 | Select-String "error:"
```

## Tips
* Set `COPY_OUTPUT` to `ON` to automatically copy the built dll to the game directory, i.e. `cmake --preset vs2022-windows -DCOPY_OUTPUT=ON`
* Build the `package` target to automatically build and zip up your dll in a ready-to-distribute format.
