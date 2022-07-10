cmake_minimum_required (VERSION 3.0.2)
project (LTheory)
set (CMAKE_BUILD_TYPE Release)
include (libphx/script/build/Shared.cmake)

add_subdirectory (libphx)

add_executable (lt "src/Main.cpp")
phx_configure_output_dir (lt)

target_compile_definitions (lt PRIVATE DEBUG=0)
target_link_libraries (lt phx)

set_target_properties (lt PROPERTIES
  OUTPUT_NAME_DEBUG "lt${ARCH}d"
  OUTPUT_NAME_RELEASE "lt${ARCH}r"
  OUTPUT_NAME_RELWITHDEBINFO "lt${ARCH}"
  OUTPUT_NAME_MINSIZEREL "lt${ARCH}rm")
