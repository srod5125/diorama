cmake_minimum_required(VERSION 3.27.2)

project(diorama_tb
       DESCRIPTION "informal model chechker"
       LANGUAGES CXX)


# settings
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# TODO: add if statment for release mode to compiler flags
# set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_BUILD_TYPE Debug)


add_subdirectory(src)


# include(CMakePrintHelpers)
# cmake_print_variables(PROJECT_SOURCE_DIR)
