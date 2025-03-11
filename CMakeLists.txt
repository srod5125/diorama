cmake_minimum_required(VERSION 3.27.2)

project(diorama_tb
       DESCRIPTION "informal model chechker"
       LANGUAGES CXX)



add_subdirectory(src)

# citation: https://stackoverflow.com/questions/9160335/
#           os-specific-instructions-in-cmake-how-to

# settings
if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

# TODO: target all other os's,
if(LINUX)
    message(STATUS ">>> Linux")
    # TODO: add find clang
    # find_package(clang REQUIRED)
    # find_package(clang++ REQUIRED)

    set(CMAKE_C_COMPILER /usr/bin/clang)
    set(CMAKE_CXX_COMPILER /usr/bin/clang++)
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()


# TODO: add if statment for release mode to compiler flags
# set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_BUILD_TYPE Debug)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)



# include(CMakePrintHelpers)
# cmake_print_variables(PROJECT_SOURCE_DIR)
