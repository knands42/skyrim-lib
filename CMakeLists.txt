cmake_minimum_required(VERSION 3.22)

project(
	ExampleProject
	VERSION 1.0.0
	LANGUAGES CXX
)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")
	message(FATAL_ERROR "in-source builds are not allowed")
endif()

macro(set_from_environment VARIABLE)
	if(NOT DEFINED ${VARIABLE} AND DEFINED ENV{${VARIABLE}})
		set(${VARIABLE} $ENV{${VARIABLE}})
	endif()
endmacro()

set_from_environment(VCPKG_ROOT)
if(NOT DEFINED VCPKG_ROOT)
	message(FATAL_ERROR "VCPKG_ROOT is not set")
endif()

set_from_environment(CMAKE_MAKE_PROGRAM)
if(NOT DEFINED CMAKE_MAKE_PROGRAM)
	message(FATAL_ERROR "CMAKE_MAKE_PROGRAM is not set")
endif()

set_from_environment(PAPYRUS_COMPILER)
if(NOT DEFINED PAPYRUS_COMPILER)
	message(FATAL_ERROR "PAPYRUS_COMPILER is not set")
endif()

set_from_environment(SKYRIM_SCRIPTS)
if(NOT DEFINED SKYRIM_SCRIPTS)
	message(FATAL_ERROR "SKYRIM_SCRIPTS is not set")
endif()

set_from_environment(SkyrimSE_PATH)
if(NOT DEFINED SkyrimSE_PATH)
	message(FATAL_ERROR "SkyrimSE_PATH is not set")
endif()

option(COPY_OUTPUT "copy the output of build operations to the game directory" OFF)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

add_subdirectory(src)
include(cmake/packaging.cmake)
