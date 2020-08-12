cmake_minimum_required (VERSION 3.0.2)
project (LTheory)
set (CMAKE_BUILD_TYPE Release)

if (WIN32)
  set (PLATFORM "win")
  set (WINDOWS TRUE)
elseif (UNIX AND NOT APPLE)
  set (PLATFORM "linux")
  set (LINUX TRUE)
else ()
  message (FATAL_ERROR "Unsupported Platform")
endif ()

if ("${CMAKE_SIZEOF_VOID_P}" EQUAL "4")
  set (ARCH "32")
elseif ("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
  set (ARCH "64")
else ()
  message (FATAL_ERROR "Unsupported CPU Architecture")
endif ()

set (PLATARCH "${PLATFORM}${ARCH}")

# ------------------------------------------------------------------------------

include_directories (libphx/include)
include_directories (libphx/ext)

link_directories ("libphx/ext/lib/${PLATARCH}")

add_subdirectory (libphx)

add_executable (lt "src/Main.cpp")

if ("${CMAKE_SIZEOF_VOID_P}" EQUAL "4")
  set_target_properties (lt PROPERTIES OUTPUT_NAME "lt32")
else ()
  set_target_properties (lt PROPERTIES OUTPUT_NAME "lt64")
endif ()

target_compile_definitions (lt PRIVATE DEBUG=0)
target_link_libraries (lt phx)
