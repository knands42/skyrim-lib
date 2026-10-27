set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

set(SOURCE_DIR "${ROOT_DIR}/src")
set(SOURCE_FILES
	"${SOURCE_DIR}/main.cpp"
	"${SOURCE_DIR}/PCH.h"
	# Core
	"${SOURCE_DIR}/integrations/core/BusinessLogic.h"
	"${SOURCE_DIR}/integrations/core/BusinessLogic.cpp"
	# Integrations
	"${SOURCE_DIR}/integrations/IIntegration.h"
	"${SOURCE_DIR}/integrations/IntegrationChecker.h"
	"${SOURCE_DIR}/integrations/IntegrationChecker.cpp"
	"${SOURCE_DIR}/integrations/skyui/SkyUI.h"
	"${SOURCE_DIR}/integrations/skyui/SkyUI.cpp"
	# Papyrus
	"${SOURCE_DIR}/papyrus/IRegister.h"
	"${SOURCE_DIR}/papyrus/MCM.cpp"
)

source_group(TREE "${ROOT_DIR}" FILES ${SOURCE_FILES})

# ---------------------------------------------------------------------------
# Generated version header
# ---------------------------------------------------------------------------
set(VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/Plugin.h")
configure_file(
	"${ROOT_DIR}/cmake/Plugin.h.in"
	"${VERSION_HEADER}"
	@ONLY
)

source_group("src" FILES "${VERSION_HEADER}")

configure_file(
	"${ROOT_DIR}/cmake/version.rc.in"
	"${CMAKE_CURRENT_BINARY_DIR}/version.rc"
	@ONLY
)

# ---------------------------------------------------------------------------
# Papyrus compilation
# ---------------------------------------------------------------------------
set(PAPYRUS_OUTPUT_DIR "${CMAKE_BINARY_DIR}/papyrus")
set(PAPYRUS_OUTPUT "${PAPYRUS_OUTPUT_DIR}/${PROJECT_NAME}.pex")
set(SKSE_SCRIPTS_DIR "${ROOT_DIR}/external/SKSE64/scripts")
set(SKYUI_SCRIPTS_DIR "${ROOT_DIR}/external/SkyUI/source/scripts")

# Step 1: Merge SKSE vanilla + modified scripts into a merged directory
set(PAPYRUS_MERGE_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/merge_skse_scripts.ps1")
configure_file(
    "${ROOT_DIR}/cmake/merge_skse_scripts.ps1.in"
    "${PAPYRUS_MERGE_SCRIPT}"
    @ONLY
)

add_custom_command(
    OUTPUT "${SKSE_SCRIPTS_DIR}/merged/.merged"
    COMMAND powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${PAPYRUS_MERGE_SCRIPT}"
    COMMAND "${CMAKE_COMMAND}" -E touch "${SKSE_SCRIPTS_DIR}/merged/.merged"
    COMMENT "-- Merging SKSE scripts"
    VERBATIM
)

# Step 2: Compile Papyrus
set(PAPYRUS_INCLUDE_PATHS
    "${SKSE_SCRIPTS_DIR}/merged"
    "${SKYRIM_SCRIPTS}"
    "${SKYUI_SCRIPTS_DIR}"
    "${SOURCE_DIR}/papyrus"
)
list(JOIN PAPYRUS_INCLUDE_PATHS ";" PAPYRUS_INCLUDES_JOINED)

add_custom_command(
    OUTPUT "${PAPYRUS_OUTPUT}"
    DEPENDS "${SKSE_SCRIPTS_DIR}/merged/.merged"
            "${SOURCE_DIR}/papyrus/${PROJECT_NAME}.psc"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${PAPYRUS_OUTPUT_DIR}"
    COMMAND "${PAPYRUS_COMPILER}"
        "${SOURCE_DIR}/papyrus/${PROJECT_NAME}.psc"
        "-f=${SKYRIM_SCRIPTS}/TESV_Papyrus_Flags.flg"
        "-i=${PAPYRUS_INCLUDES_JOINED}"
        "-o=${PAPYRUS_OUTPUT_DIR}"
        "-op"
    COMMENT "-- Compiling Papyrus"
    VERBATIM
)

add_custom_target(
    "${PROJECT_NAME}_Papyrus"
    ALL
    DEPENDS "${PAPYRUS_OUTPUT}"
)

# ---------------------------------------------------------------------------
# DLL target
# ---------------------------------------------------------------------------
add_library(
	"${PROJECT_NAME}"
	SHARED
	${SOURCE_FILES}
	"${VERSION_HEADER}"
	"${CMAKE_CURRENT_BINARY_DIR}/version.rc"
	"${ROOT_DIR}/.clang-format"
	"${ROOT_DIR}/.editorconfig"
)

target_compile_features(
	"${PROJECT_NAME}"
	PRIVATE
		cxx_std_20
)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
	target_compile_options(
		"${PROJECT_NAME}"
		PRIVATE
			"/sdl"	# Enable Additional Security Checks
			"/utf-8"	# Set Source and Executable character sets to UTF-8
			"/Zi"	# Debug Information Format

			"/permissive-"	# Standards conformance
			"/Zc:preprocessor"	# Enable preprocessor conformance mode

			"/wd4200" # nonstandard extension used : zero-sized array in struct/union

			"$<$<CONFIG:DEBUG>:>"
			"$<$<CONFIG:RELEASE>:/Zc:inline;/JMC-;/Ob3>"
	)

	target_link_options(
		"${PROJECT_NAME}"
		PRIVATE
			"$<$<CONFIG:DEBUG>:/INCREMENTAL;/OPT:NOREF;/OPT:NOICF>"
			"$<$<CONFIG:RELEASE>:/INCREMENTAL:NO;/OPT:REF;/OPT:ICF;/DEBUG:FULL>"
	)
endif()

target_include_directories(
	"${PROJECT_NAME}"
	PRIVATE
		"${CMAKE_CURRENT_BINARY_DIR}/src"
		"${SOURCE_DIR}"
)

add_subdirectory("${ROOT_DIR}/external/CommonLibSSE-NG" CommonLibSSE EXCLUDE_FROM_ALL)

target_link_libraries(
	"${PROJECT_NAME}"
	PRIVATE
		CommonLibSSE::CommonLibSSE
)

target_precompile_headers(
	"${PROJECT_NAME}"
	PRIVATE
		"${SOURCE_DIR}/PCH.h"
)

add_dependencies("${PROJECT_NAME}" "${PROJECT_NAME}_Papyrus")

# ---------------------------------------------------------------------------
# Install: DLL + ESP + PEX
# ---------------------------------------------------------------------------
set(DLL_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>")
set(DLL_OUTPUT "${DLL_OUTPUT_DIR}/${PROJECT_NAME}.dll")


install(
    FILES
        "${DLL_OUTPUT}"
    DESTINATION "SKSE/Plugins"
    COMPONENT "main"
)

if("${DEPLOY_OUTPUT}")
    if(DEFINED SkyrimModlist_PATH)
        set(PLUGIN_DEPLOY_DIR "${SkyrimModlist_PATH}/mods/${PROJECT_NAME}/SKSE/Plugins")
        set(ESP_DEPLOY_DIR "${SkyrimModlist_PATH}/mods/${PROJECT_NAME}/")
        set(PEX_DEPLOY_DIR "${SkyrimModlist_PATH}/mods/${PROJECT_NAME}/Scripts/")
    else()
        set(PLUGIN_DEPLOY_DIR "${SkyrimSE_PATH}/Data/SKSE/Plugins")
        set(ESP_DEPLOY_DIR "${SkyrimSE_PATH}/Data/")
        set(PEX_DEPLOY_DIR "${SkyrimSE_PATH}/Data/Scripts/")
    endif()

    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E echo "-- Deploying"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${PLUGIN_DEPLOY_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${ESP_DEPLOY_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${PEX_DEPLOY_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${DLL_OUTPUT}"
            "${PLUGIN_DEPLOY_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${ROOT_DIR}/Heartstrings.esp"
            "${ESP_DEPLOY_DIR}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${CMAKE_BINARY_DIR}/papyrus/Heartstrings.pex"
            "${PEX_DEPLOY_DIR}"
        VERBATIM
    )
endif()

if("${ZIP_MOD}")
    set(ZIP_STAGING_DIR "${CMAKE_CURRENT_BINARY_DIR}/zip_staging")
    set(ZIP_OUTPUT "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.zip")

    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E echo "-- Packaging mod ZIP"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${ZIP_STAGING_DIR}/SKSE/Plugins"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${ZIP_STAGING_DIR}/Scripts"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${DLL_OUTPUT}"
            "${ZIP_STAGING_DIR}/SKSE/Plugins/"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${ROOT_DIR}/Heartstrings.esp"
            "${ZIP_STAGING_DIR}/"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${CMAKE_BINARY_DIR}/papyrus/Heartstrings.pex"
            "${ZIP_STAGING_DIR}/Scripts/"
        COMMAND 7z a "${ZIP_OUTPUT}" "${ZIP_STAGING_DIR}/*" -r
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${ZIP_STAGING_DIR}"
        VERBATIM
    )
endif()
