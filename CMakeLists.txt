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

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")

foreach (config ${CMAKE_CONFIGURATION_TYPES})
  string (TOUPPER ${config} config)
  set (CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")
  set (CMAKE_LIBRARY_OUTPUT_DIRECTORY_${config} "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")
  set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${config} "${CMAKE_SOURCE_DIR}/bin/${PLATARCH}")
endforeach (config)

add_executable (lt "src/Main.cpp")

target_compile_definitions (lt PRIVATE DEBUG=0)
target_link_libraries (lt phx)

set_target_properties (lt PROPERTIES OUTPUT_NAME_DEBUG "lt${ARCH}d")
set_target_properties (lt PROPERTIES OUTPUT_NAME_RELEASE "lt${ARCH}r")
set_target_properties (lt PROPERTIES OUTPUT_NAME_RELWITHDEBINFO "lt${ARCH}")
set_target_properties (lt PROPERTIES OUTPUT_NAME_MINSIZEREL "lt${ARCH}rm")
