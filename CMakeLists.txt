#*******************************************************************************
#  Copyright (c) 2019 Instantiations, Inc
#
#  Distributed under the MIT License (see License.txt file)
#
#  Contributors:
#     Seth Berman - initial version
#
#  Description:
#     This file covers the build instructions for the entire project.
#     In the future as complexity grows, a nested CMakeLists.txt approach
#     may be taken.
#
#     The layout of this file is logically organized as follows
#     - Versioning
#     - Options (i.e. Tests, Docs...)
#     - Platform/Compiler related settings
#     - Common Project Source directory prefixes
#     - 3rd-party modules
#     - Common build instructions
#     - Per-platform build instructions
#     - Per-app build instructions
#     - Unit testing
#     - Documentation
#
#  Build Instrutions:
#
#     Mingw-w64 (Windows) (included some example build switches)
#     >mkdir build && cd build
#     >cmake .. -G"MinGW Makefiles" -DBUILD_DOCUMENTATION=ON -DBUILD_TESTING=ON
#     >mingw32-make
#     >mingw32-make test
#     >mingw32-make docs
#
#     Linux 64-bit (or Linux 32-bit on a 32-bit Linux OS)
#     >mkdir build && cd build
#     >cmake .. -G"Unix Makefiles"
#     >make
#     >make test
#     >make docs
#
#     Linux 32-bit (cross-compile on 64-bit machine)
#     >mkdir build && cd build
#     >cmake .. -DES_64BIT=OFF -G"Unix Makefiles"
#     >make
#     >make test
#     >make docs
#
#*******************************************************************************/
cmake_minimum_required(VERSION 3.0..3.13)
project(paho-mqtt-vast)
message(STATUS "CMake version: " ${CMAKE_VERSION})
message(STATUS "CMake system name: " ${CMAKE_SYSTEM_NAME})

if (POLICY CMP0075)
    cmake_policy(SET CMP0075 NEW)
endif ()

include(ExternalProject)

set(VAST_PAHO_SYNC_CB_LIBNAME paho-mqtt3c-vacallbacks)

#-- RelWithDebInfo (None Debug Release RelWithDebInfo MinSizeRel)
if (CMAKE_BUILD_TYPE STREQUAL "")
    set(DEFAULT_BUILD_TYPE "Debug")
    message(STATUS "CMake build type not specified. DEFAULT: ${DEFAULT_BUILD_TYPE}")
    set(CMAKE_BUILD_TYPE ${DEFAULT_BUILD_TYPE}
            CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel" FORCE)
else ()
    message(STATUS "CMake build type: " ${CMAKE_BUILD_TYPE})
endif ()

#-- Do not allow in-source builds.
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR)
    message(FATAL_ERROR
            "Please create a separate folder called 'build' and do the builds in there.\n"
            "Git/Mercurial will ignore $ROOT/build and we can keep things clean\n"
            "Example:\n"
            "  rm -rf CMakeFiles CMakeCache.txt\n"
            "  mkdir build\n"
            "  cd build\n"
            "  cmake ..")
endif ()

#------------------------------------------------------------------
# Version Settings
#------------------------------------------------------------------
#-- Today
string(TIMESTAMP VASTPAHO_DATE "%m/%d/%y")
string(TIMESTAMP VASTPAHO_YEAR "%Y")

#-- Copyright
set(VASTPAHO_SHORT_COPYRIGHT "(C) Copyright Instantiations 1994, ${VASTPAHO_YEAR}")
set(VASTPAHO_LONG_COPYRIGHT "${VASTPAHO_SHORT_COPYRIGHT}. All rights reserved.")

#-- Define Product ID settings
set(VASTPAHO_PRODUCT_VERSION_MAJOR 0)
set(VASTPAHO_PRODUCT_VERSION_MINOR 1)
set(VASTPAHO_PRODUCT_VERSION_MOD 0)
#-- The period-delimited 3 position format (1.0.0)
set(VASTPAHO_PRODUCT_VERSION "${VASTPAHO_PRODUCT_VERSION_MAJOR}.${VASTPAHO_PRODUCT_VERSION_MINOR}.${VASTPAHO_PRODUCT_VERSION_MOD}")
#-- The comma-delimited 3 position format (1,0,0)
set(VASTPAHO_PRODUCT_VERSION_FOR_WINDOWS_DEF "${VASTPAHO_PRODUCT_VERSION_MAJOR},${VASTPAHO_PRODUCT_VERSION_MINOR},${VASTPAHO_PRODUCT_VERSION_MOD}")
#-- The 2 digit format (85)
set(VASTPAHO_PRODUCT_SUFFIX "${VASTPAHO_PRODUCT_VERSION_MAJOR}${VASTPAHO_PRODUCT_VERSION_MINOR}")
#-- The period-delimited 2 position format (8.5)
set(VASTPAHO_PRODUCT_SUBDIR "${VASTPAHO_PRODUCT_VERSION_MAJOR}.${VASTPAHO_PRODUCT_VERSION_MINOR}")

#------------------------------------------------------------------
# Option Settings
#------------------------------------------------------------------
option(BUILD_TESTING "Build testsuite" ON)
option(BUILD_DOCUMENTATION "Build documentation" ON)

#------------------------------------------------------------------
# Output Settings
#------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#------------------------------------------------------------------
# Bitness Settings
#------------------------------------------------------------------
if (CMAKE_SIZEOF_VOID_P MATCHES 8)
    if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        set(ES_64BIT TRUE CACHE BOOL "Build 64-bit binaries")
    else ()
        set(ES_64BIT TRUE INTERNAL)
    endif ()
endif ()

#------------------------------------------------------------------
# GCC Settings
#------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libgcc")
    if (UNIX AND NOT APPLE)
        if (ES_64BIT AND (${CMAKE_SYSTEM_NAME} STREQUAL "Linux"))
            set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -fPIC")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
        elseif (CMAKE_SIZEOF_VOID_P MATCHES 8)
            # 32-bit binaries on 64-bit platform
            # Command for prepare platform eviropment:
            # sudo apt-get install g++-multilib libc6-dev-i386
            set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -m32")
            set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -m32")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
            set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -m32")
        endif ()
    endif ()
endif ()

#------------------------------------------------------------------
# MINGW Settings
#------------------------------------------------------------------
if (MINGW)
    #-- Do not rely on this being defined in mingw...it just happens to be defined when using
    #-- gnu standard...but not c standard
    add_definitions(-DWIN32)
    if (NOT VM_64BIT)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--enable-stdcall-fixup")
    endif ()
endif ()

#------------------------------------------------------------------
# Microsoft Visual Studio Settings
#------------------------------------------------------------------
if (MSVC)
    list(APPEND VAST_PAHO_DEFS -D_CRT_SECURE_NO_WARNINGS)
    list(APPEND VAST_PAHO_DEFS -D_WINSOCK_DEPRECATED_NO_WARNINGS)
    list(APPEND VAST_PAHO_DEFS -D_CRT_NONSTDC_NO_DEPRECATE)

    #-- If using Microsoft's compiler, then replace the "/MD" flag for each
    #-- build type with "/MT" so we get static compilation
    foreach (flag_var
            CMAKE_C_FLAGS
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_MINSIZEREL
            CMAKE_C_FLAGS_RELWITHDEBINFO)
        if (${flag_var} MATCHES "/MD")
            string(REGEX REPLACE "/MD" "/MT" msvc_flag_var "${${flag_var}}")
            set(${flag_var} ${msvc_flag_var})
        endif (${flag_var} MATCHES "/MD")

        #-- Disable generation of embedded manifest file...which is now the default
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /MANIFEST:NO")

        #-- Disable incremental linking...which is now the default
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /INCREMENTAL:NO")

        # Mark 32 bit executables large address aware so they can use > 2GB address space
        if ((CMAKE_SIZEOF_VOID_P MATCHES 4) OR (NOT ES_64BIT))
            set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /LARGEADDRESSAWARE")
        endif ()

    endforeach ()
endif ()

#------------------------------------------------------------------
# DEP & ASLR Settings
#------------------------------------------------------------------
if (MSVC)
    message(STATUS "Enabling DEP & ASLR")
    # All of these options are on by default for the latest MS compiler versions; still it's worth to keep them here.
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /DYNAMICBASE /NXCOMPAT")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /DYNAMICBASE /NXCOMPAT")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /DYNAMICBASE /NXCOMPAT")
    if (ES_64BIT)
        message(STATUS "Enabling high entropy ASLR")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /HIGHENTROPYVA")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /HIGHENTROPYVA")
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} /HIGHENTROPYVA")
    endif ()
elseif (MINGW)
    message(STATUS "Enabling DEP & ASLR")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--dynamicbase -Wl,--nxcompat")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--dynamicbase -Wl,--nxcompat")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,--dynamicbase -Wl,--nxcompat")
    if (ES_64BIT)
        message(STATUS "Enabling high entropy ASLR")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--high-entropy-va")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--high-entropy-va")
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,--high-entropy-va")
    endif ()
elseif (WIN32)
    message(WARNING "****** DEP & ASLR are not enabled for this windows build system")
endif ()

#------------------------------------------------------------------
# C Source Variables
#------------------------------------------------------------------
set(ES_C_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/source)
set(ES_C_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/source)
set(ES_C_THIRDPARTY_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/thirdparty)
set(ES_C_THIRDPARTY_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/thirdparty)
set(ES_C_INC_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/include)
set(ES_C_INC_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/include)
set(ES_C_LIB_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/lib)
set(ES_C_LIB_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/lib)
set(ES_C_TEST_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/test)
set(ES_C_TEST_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/test)
set(ES_C_DOCS_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/c/docs)
set(ES_C_DOCS_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/c/docs)

#------------------------------------------------------------------
# 3rd Party Module: Plibsys
#------------------------------------------------------------------
#-- Add threading lib
find_package(Threads)
option(PLIBSYS_BUILD_DOC "Build plibsys documentation" OFF)
option(PLIBSYS_TESTS "Build plibsys tests" OFF)
set(PLIBSYS_PROJ_NAME plibsys)
set(PLIBSYS_SRC_ROOT ${ES_C_THIRDPARTY_SRC_DIR}/plibsys)
set(PLIBSYS_BIN_ROOT ${ES_C_THIRDPARTY_BIN_DIR}/plibsys)
#-- Raspbian Check and Fix
if (NOT DEFINED ${CMAKE_C_COMPILER_ID} AND ${CMAKE_SYSTEM_PROCESSOR} MATCHES "^arm")
    set(PLIBSYS_COMPILER_ID GNU)
else ()
    set(PLIBSYS_COMPILER_ID ${CMAKE_C_COMPILER_ID})
endif ()
ExternalProject_Add(
        ${PLIBSYS_PROJ_NAME}
        GIT_REPOSITORY https://github.com/saprykin/plibsys.git
        GIT_TAG tags/0.0.4
        GIT_SHALLOW true
        GIT_PROGRESS true
        SOURCE_DIR ${PLIBSYS_SRC_ROOT}
        BINARY_DIR ${PLIBSYS_BIN_ROOT}
        EXCLUDE_FROM_ALL 1
        UPDATE_DISCONNECTED 1
        STEP_TARGETS build
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${PLIBSYS_BIN_ROOT}
        -DPLIBSYS_BUILD_DOC=${PLIBSYS_BUILD_DOC}
        -DPLIBSYS_TESTS=${PLIBSYS_TESTS}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_C_COMPILER_ID=${PLIBSYS_COMPILER_ID}
)
set(VAST_PAHO_INCLUDES ${VAST_PAHO_INCLUDES}
        ${PLIBSYS_SRC_ROOT}/src
        ${PLIBSYS_BIN_ROOT})
if (MSVC)
    set(PLIBSYS_LIBRARY ${PLIBSYS_BIN_ROOT}/lib/plibsysstatic.lib)
else ()
    set(PLIBSYS_LIBRARY ${PLIBSYS_BIN_ROOT}/lib/libplibsysstatic.a)
endif ()
set(VAST_PAHO_LIBS ${VAST_PAHO_LIBS}
        ${PLIBSYS_LIBRARY}
        ${CMAKE_THREAD_LIBS_INIT}
        ${CMAKE_DL_LIBS})
set(VAST_PAHO_DEPS ${VAST_PAHO_DEPS} ${PLIBSYS_PROJ_NAME})

#------------------------------------------------------------------
# 3rd Party Module: MQTT-Paho
#------------------------------------------------------------------
set(MQTT_PAHO_PROJ_NAME mqtt-paho)
set(MQTT_PAHO_SRC_ROOT ${ES_C_THIRDPARTY_SRC_DIR}/mqtt-paho-c)
set(MQTT_PAHO_BIN_ROOT ${ES_C_THIRDPARTY_BIN_DIR}/mqtt-paho-c)
ExternalProject_Add(
        ${MQTT_PAHO_PROJ_NAME}
        GIT_REPOSITORY https://github.com/eclipse/paho.mqtt.c.git
        GIT_TAG tags/v1.3.0
        GIT_SHALLOW true
        GIT_PROGRESS true
        SOURCE_DIR ${MQTT_PAHO_SRC_ROOT}
        BINARY_DIR ${MQTT_PAHO_BIN_ROOT}
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ""
        LOG_DOWNLOAD ON
)
set(VAST_PAHO_INCLUDES ${VAST_PAHO_INCLUDES} ${MQTT_PAHO_SRC_ROOT}/src)
set(VAST_PAHO_DEPS ${VAST_PAHO_DEPS} ${MQTT_PAHO_PROJ_NAME})

#------------------------------------------------------------------
# Module: VA Smalltalk Virtual Machine
#------------------------------------------------------------------
set(ES_INCLUDES ${ES_C_INC_SRC_DIR}/es CACHE PATH "ES: Includes")
if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm.*|ARM.*)")
    if (ES_64BIT)
        set(ES_LIB_SUBFOLDER arm64)
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "/usr/local/VASmalltalk/9.2x64/bin")
    else ()
        set(ES_LIB_SUBFOLDER arm)
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "/usr/local/VASmalltalk/9.2x86/bin")
    endif ()
elseif (ES_64BIT)
    set(ES_LIB_SUBFOLDER x86_64)
    if (WIN32)
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "C:/Program Files/Instantiations/VA Smalltalk/9.2x64")
    else ()
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "/usr/local/VASmalltalk/9.2x64/bin")
    endif ()
else ()
    set(ES_LIB_SUBFOLDER x86)
    if (WIN32)
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "C:/Program Files (x86)/Instantiations/VA Smalltalk/9.2x86")
    else ()
        set(ES_LIB_DEFAULT_INSTALL_LOCATION "/usr/local/VASmalltalk/9.2x86/bin")
    endif ()
endif ()


#-- Find VM dll and copy to bin dir
find_library(ESVM_LIBRARY
        NAMES esvm40 esvm40.so
        PATHS
        ${ES_LIB_CUSTOM_LOCATION}
        "${ES_C_LIB_SRC_DIR}/es/${ES_LIB_SUBFOLDER}"
        "${ES_LIB_DEFAULT_INSTALL_LOCATION}"
        NO_DEFAULT_PATH)
message(STATUS "Found VA Smalltalk VM Library: ${ESVM_LIBRARY}")
if (WIN32)
    configure_file(${ESVM_LIBRARY} ${CMAKE_BINARY_DIR}/bin/esvm40.dll COPYONLY)
else ()
    configure_file(${ESVM_LIBRARY} ${CMAKE_BINARY_DIR}/bin/esvm40.so COPYONLY)
endif ()

#-- On Windows, find VM dll dependency (esae40.dll) and copy to bin dir
if (WIN32)
    configure_file(${ESVM_LIBRARY} ${CMAKE_BINARY_DIR}/bin/esvm40.dll COPYONLY)
    find_library(ESAE_LIBRARY
            NAMES esae40
            PATHS
            ${ES_LIB_CUSTOM_LOCATION}
            "${ES_C_LIB_SRC_DIR}/es/${ES_LIB_SUBFOLDER}"
            "${ES_LIB_DEFAULT_INSTALL_LOCATION}"
            NO_DEFAULT_PATH)
    message(STATUS "Found VA Smalltalk EBCDIC Library: ${ESAE_LIBRARY}")
    configure_file(${ESAE_LIBRARY} ${CMAKE_BINARY_DIR}/bin/esae40.dll COPYONLY)
endif ()

set(VAST_PAHO_INCLUDES ${VAST_PAHO_INCLUDES} ${ES_INCLUDES})
set(VAST_PAHO_LIBS ${VAST_PAHO_LIBS} ${ESAE_LIBRARY} ${ESVM_LIBRARY})

#------------------------------------------------------------------
# Build Instructions: Common
#------------------------------------------------------------------

#-- Add common defs
add_definitions(${VAST_PAHO_DEFS})

#-- Configure headers
configure_file(
        ${ES_C_SRC_DIR}/EsMqttVersionInfo.h.in
        ${ES_C_BIN_DIR}/EsMqttVersionInfo.h)

set(VAST_PAHO_INCLUDES ${VAST_PAHO_INCLUDES}
        ${ES_C_INC_SRC_DIR}
        ${ES_C_INC_BIN_DIR}
        ${ES_C_SRC_DIR}
        ${ES_C_BIN_DIR}
        CACHE PATH "VAST PAHO: Headers")

set(VAST_SOURCES
        ${ES_C_SRC_DIR}/EsProperties.h
        ${ES_C_SRC_DIR}/EsProperties.c
        ${ES_C_SRC_DIR}/EsWorkQueue.h
        ${ES_C_SRC_DIR}/EsWorkQueue.c
        ${ES_C_SRC_DIR}/EsWorkTask.h
        ${ES_C_SRC_DIR}/EsWorkTask.c)

set(VAST_PAHO_SOURCES
        ${VAST_SOURCES}
        ${ES_C_SRC_DIR}/EsMqttAsyncArguments.h
        ${ES_C_SRC_DIR}/EsMqttAsyncArguments.c
        ${ES_C_SRC_DIR}/EsMqttAsyncMessages.h
        ${ES_C_SRC_DIR}/EsMqttAsyncMessages.c
        ${ES_C_SRC_DIR}/EsMqttCallbacks.h
        ${ES_C_SRC_DIR}/EsMqttCallbacks.c
        ${ES_C_SRC_DIR}/EsMqttLibrary.h
        ${ES_C_SRC_DIR}/EsMqttLibrary.c
        ${ES_C_BIN_DIR}/EsMqttVersionInfo.h)

#-- Platform Flags
if (WIN32 AND NOT CYGWIN)
    add_definitions(-DWINDOWS)
elseif (UNIX AND NOT APPLE)
    #-- Add unix flavor build defs
    if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "(i686)|(i386)|(x86)|(X86)|(amd64)|(AMD64)")
            add_definitions(-DLINUX_386)
        elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "^arm")
            add_definitions(-DLINUX_ARM)
        else ()
            message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR} is not supported")
        endif ()
        #-- Add Linux compiler definition
        add_definitions(-DLINUX_ANY)
    elseif (${CMAKE_SYSTEM_NAME} STREQUAL "AIX")
        #-- Add AIX compiler definition
        add_definitions(-DAIXPPC -DRS6000)
    elseif (${CMAKE_SYSTEM_NAME} MATCHES "(Solaris|SunOS)")
        #-- Add Solaris compiler definition
        add_definitions(-DSOLARIS)
    else ()
        message(FATAL_ERROR "Unsupported Unix Platform")
    endif ()
else ()
    message(FATAL_ERROR "Unsupported Platform")
endif ()

include_directories(${VAST_PAHO_INCLUDES})

#----------------------------------------------------------------------------
# Build Instructions: C Library for VA Smalltalk Eclipse Paho Sync Callbacks
#----------------------------------------------------------------------------
set(VAST_PAHO_SYNC_CB_SOURCES
        ${VAST_PAHO_SOURCES}
        ${ES_C_SRC_DIR}/EsMqttUserPrims.h
        ${ES_C_SRC_DIR}/EsMqttUserPrims.c)

#-- Add the platform specific subdirectory
if (WIN32 AND NOT CYGWIN)
    #-- Configure sources
    configure_file(
            ${ES_C_SRC_DIR}/os/windows/vast_paho_sync_callbacks.def.in
            ${ES_C_BIN_DIR}/os/windows/vast_paho_sync_callbacks.def)
    configure_file(
            ${ES_C_SRC_DIR}/os/windows/vast_paho_sync_callbacks.rc.in
            ${ES_C_BIN_DIR}/os/windows/vast_paho_sync_callbacks.rc)

    #-- Add windows sources
    set(VAST_PAHO_SYNC_CB_SOURCES ${VAST_PAHO_SYNC_CB_SOURCES}
            ${ES_C_BIN_DIR}/os/windows/vast_paho_sync_callbacks.def
            ${ES_C_BIN_DIR}/os/windows/vast_paho_sync_callbacks.rc)

    set(VAST_PAHO_LIBS ${VAST_PAHO_LIBS} ws2_32)
endif ()

#------------------------------------------------------------------
# Generate C Library for VA Smalltalk Eclipse Paho Sync Callbacks
#------------------------------------------------------------------
set(VAST_PAHO_SYNC_CB_DEPS ${VAST_PAHO_DEPS})
set(VAST_PAHO_SYNC_CB_LIBS ${VAST_PAHO_LIBS})

add_library(${VAST_PAHO_SYNC_CB_LIBNAME} SHARED ${VAST_PAHO_SYNC_CB_SOURCES})
add_dependencies(${VAST_PAHO_SYNC_CB_LIBNAME} ${VAST_PAHO_SYNC_CB_DEPS})
target_link_libraries(${VAST_PAHO_SYNC_CB_LIBNAME} PRIVATE ${VAST_PAHO_SYNC_CB_LIBS})

#-- Don't prefix with 'lib' on gcc
#-- This is for backwards compatibility
if (UNIX OR CMAKE_COMPILER_IS_GNUCC)
    set_target_properties(${VAST_PAHO_SYNC_CB_LIBNAME} PROPERTIES PREFIX "")
endif ()

#------------------------------------------------------------------
# UNIT TEST SUITES
#------------------------------------------------------------------
if (BUILD_TESTING)
    enable_testing()
    include_directories(${ES_C_TEST_SRC_DIR} ${ES_C_TEST_SRC_DIR}/esunit)

    #-- Tests: EsProperties
    add_executable(tests_esproperties
            ${ES_C_TEST_SRC_DIR}/TestEsProperties.c
            ${VAST_SOURCES})
    add_dependencies(tests_esproperties ${PLIBSYS_PROJ_NAME})
    target_link_libraries(tests_esproperties ${VAST_PAHO_SYNC_CB_LIBS})
    add_test(NAME tests_esproperties COMMAND tests_esproperties)
    set_property(TARGET tests_esproperties PROPERTY PROJECT_LABEL "Tests_EsProperties")

    #-- Tests: EsWorkTask
    add_executable(tests_esworktask
            ${ES_C_TEST_SRC_DIR}/TestEsWorkTask.c
            ${VAST_SOURCES})
    add_dependencies(tests_esworktask ${PLIBSYS_PROJ_NAME})
    target_link_libraries(tests_esworktask ${VAST_PAHO_SYNC_CB_LIBS})
    add_test(NAME tests_esworktask COMMAND tests_esworktask)
    set_property(TARGET tests_esworktask PROPERTY PROJECT_LABEL "Tests_EsWorkTask")

    #-- Tests: EsWorkQueue
    add_executable(tests_esworkqueue
            ${ES_C_TEST_SRC_DIR}/TestEsWorkQueue.c
            ${VAST_SOURCES})
    add_dependencies(tests_esworkqueue ${PLIBSYS_PROJ_NAME})
    target_link_libraries(tests_esworkqueue ${VAST_PAHO_SYNC_CB_LIBS})
    add_test(NAME tests_esworkqueue COMMAND tests_esworkqueue)
    set_property(TARGET tests_esworkqueue PROPERTY PROJECT_LABEL "Tests_EsWorkQueue")

    #-- Tests: EsMqttLibrary
    add_executable(tests_esmqttlibrary
            ${ES_C_TEST_SRC_DIR}/TestEsMqttLibrary.c
            ${VAST_PAHO_SOURCES})
    add_dependencies(tests_esmqttlibrary ${VAST_PAHO_DEPS})
    target_link_libraries(tests_esmqttlibrary ${VAST_PAHO_SYNC_CB_LIBS})
    add_test(NAME tests_esmqttlibrary COMMAND tests_esmqttlibrary)
    set_property(TARGET tests_esmqttlibrary PROPERTY PROJECT_LABEL "Tests_EsMqttLibrary")
endif ()

#------------------------------------------------------------------
# C SOURCE DOCUMENTATION (DOXYGEN)
#------------------------------------------------------------------
if (BUILD_DOCUMENTATION)
    find_package(Doxygen)
    if (DOXYGEN_FOUND)
        #-- Configure the Template Doxyfile for our specific project
        configure_file(${ES_C_DOCS_SRC_DIR}/Doxyfile.in ${ES_C_DOCS_BIN_DIR}/Doxyfile @ONLY IMMEDIATE)
        configure_file(${ES_C_DOCS_SRC_DIR}/vast_paho_mainpage.dox.in
                ${ES_C_DOCS_BIN_DIR}/vast_paho_mainpage.dox @ONLY IMMEDIATE)

        #-- Add a custom target to run Doxygen when ever the project is built
        #-- IF we do want the documentation to be generated EVERY time we build the project
        #-- then include the 'ALL' keyword after the target below i.e. ..._target (docs ALL).
        add_custom_target(docs
                COMMAND ${DOXYGEN_EXECUTABLE} ${ES_C_DOCS_BIN_DIR}/Doxyfile
                SOURCES ${ES_C_DOCS_BIN_DIR}/Doxyfile)
    else ()
        message(STATUS "Doxygen is needed to build the documentation. Skipping docs target generation")
    endif ()
endif ()
