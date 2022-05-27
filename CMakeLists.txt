# CMake>=3.2, build cURL at least 3.2 version
# CMake>=3.8, to support VS2017
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMake;${CMAKE_MODULE_PATH}")
include(Macros)
include(CMakeDependentOption)
include(CheckCCompilerFlag)

# Project
project(C-PROJECT-LAYOUT C)

# Target option
option(CPROJECT_BUILD_SHARED_LIBS "Build shared libraries" ON)
option(CPROJECT_BUILD_STATIC_LIBS "Build static libraries" ON)
option(CPROJECT_BUILD_TESTS "Build tests" ON)
option(CPROJECT_BUILD_EXAMPLES "Build examples" ON)

# Compiler option
option(PICKY_COMPILER "Enable picky compiler options" ON)
if(WIN32)
  option(CPROJECT_STATIC_CRT "Set to ON to build with static CRT on Windows (/MT)." ON)
  option(CMAKE_ENABLE_UNICODE "Set to ON to use the Unicode version of the Windows API functions" OFF)
endif()

# Compiler
if(WIN32)
  # _WIN32_WINNT_WINXP (0x0501)
  add_definitions(-D_WIN32_WINNT=0x0501)
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_WIN32_WINNT=0x0501")

  if(CPROJECT_STATIC_CRT)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
  endif()

  if(CMAKE_ENABLE_UNICODE)
    add_definitions(-DUNICODE -D_UNICODE)
    if(MINGW)
      add_compile_options(-municode)
    endif()
  endif()

  # Disable default manifest added by CMake
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /MANIFEST:NO")

  add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
  if(CMAKE_C_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W4")
  endif()

  # Use multithreaded compilation on VS 2008+
  if(MSVC_VERSION GREATER_EQUAL 1500)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP")
  endif()
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_CLANG)
  if(PICKY_COMPILER)
    foreach(_CCOPT -pedantic -Wall -W -Wpointer-arith -Wwrite-strings -Wunused -Wshadow -Winline -Wnested-externs -Wmissing-declarations -Wmissing-prototypes -Wfloat-equal -Wsign-compare -Wundef -Wendif-labels -Wstrict-prototypes -Wdeclaration-after-statement -Wstrict-aliasing=3 -Wcast-align -Wtype-limits -Wold-style-declaration -Wmissing-parameter-type -Wempty-body -Wclobbered -Wignored-qualifiers -Wconversion -Wvla -Wdouble-promotion -fstack-protector-all -Wno-variadic-macros)
      # surprisingly, CHECK_C_COMPILER_FLAG needs a new variable to store each new
      # test result in.
      string(MAKE_C_IDENTIFIER "OPT${_CCOPT}" _optvarname)
      check_c_compiler_flag(${_CCOPT} ${_optvarname})
      if(${_optvarname})
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${_CCOPT}")
      endif()
    endforeach()
    foreach(_CCOPT long-long multichar format-nonliteral sign-conversion system-headers pedantic-ms-format)
      # GCC only warns about unknown -Wno- options if there are also other diagnostic messages,
      # so test for the positive form instead
      string(MAKE_C_IDENTIFIER "OPT${_CCOPT}" _optvarname)
      check_c_compiler_flag("-W${_CCOPT}" ${_optvarname})
      if(${_optvarname})
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-${_CCOPT}")
      endif()
    endforeach()
  endif()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0")
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--exclude-libs,ALL -Wl,-Bsymbolic -Wl,-z,noexecstack -Wl,-z,relro")
endif()

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS off)
include(SymbolHiding)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CPROJECT_CFLAG_SYMBOLS_HIDE}")

# If we are on AIX, do the _ALL_SOURCE magic
if(${CMAKE_SYSTEM_NAME} MATCHES AIX)
  set(_ALL_SOURCE 1)
endif()

# Include all the necessary files for macros
include(CMakePushCheckState)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckCSourceCompiles)

# depends options

# initialize depends
add_custom_target(cproject_build_info
  COMMAND ${CMAKE_COMMAND} -E echo "--------------------------------------------------------------------------------"
  COMMAND ${CMAKE_COMMAND} -E echo "System   : ${CMAKE_SYSTEM_NAME}"
  COMMAND ${CMAKE_COMMAND} -E echo "Processor: ${CMAKE_SYSTEM_PROCESSOR}"
  COMMAND ${CMAKE_COMMAND} -E echo "Build    : ${CMAKE_BUILD_TYPE}"
  COMMAND ${CMAKE_COMMAND} -E echo "CC       : ${CMAKE_C_COMPILER}"
  COMMAND ${CMAKE_COMMAND} -E echo "CFLAGS   : ${CMAKE_C_FLAGS}"
  COMMAND ${CMAKE_COMMAND} -E echo "--------------------------------------------------------------------------------"
)

find_package(Threads REQUIRED)
set(CPROJECT_DEPS_TARGETS "cproject_build_info")
set(CPROJECT_DEPS_LIBS ${CMAKE_DL_LIBS} ${CMAKE_THREAD_LIBS_INIT})

include(${CMAKE_CURRENT_LIST_DIR}/deps/CMakeLists.txt)

# Include
include_directories(${CMAKE_CURRENT_LIST_DIR}/include)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/include/ DESTINATION include FILES_MATCHING PATTERN "*.h")

# Source
include(${CMAKE_CURRENT_LIST_DIR}/src/CMakeLists.txt)

# Tests
if(CPROJECT_BUILD_TESTS)
  add_subdirectory(tests)
endif()

# Examples
if(CPROJECT_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

