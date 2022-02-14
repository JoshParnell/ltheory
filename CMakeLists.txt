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

add_subdirectory (libphx)

add_executable (lt "src/Main.cpp")

target_compile_definitions (lt PRIVATE DEBUG=0)
target_link_libraries (lt phx)

set_target_properties (lt PROPERTIES OUTPUT_NAME_DEBUG "lt${ARCH}d")
set_target_properties (lt PROPERTIES OUTPUT_NAME_RELEASE "lt${ARCH}r")
set_target_properties (lt PROPERTIES OUTPUT_NAME_RELWITHDEBINFO "lt${ARCH}")
set_target_properties (lt PROPERTIES OUTPUT_NAME_MINSIZEREL "lt${ARCH}rm")
