cmake_minimum_required(VERSION 3.27.2)

project(diorama_tb
       DESCRIPTION "informal model chechker"
       LANGUAGES CXX)


# bison & flex
find_package(BISON 3.8.2)
bison_target(parser
    ${CMAKE_SOURCE_DIR}/diorama_parser.yy
    ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
    DEFINES_FILE
    ${CMAKE_CURRENT_BINARY_DIR}/parser.hpp)

#TODO: -Wcounterexamples add option to generate bison counterexamples

find_package(FLEX 2.6.4)
flex_target(lexer
    ${CMAKE_SOURCE_DIR}/diorama_lexer.ll
    ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)

add_flex_bison_dependency(lexer parser)

# todo add if not defined for both flex & bison files


# target definition
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

add_executable(tb
    ${CMAKE_SOURCE_DIR}/diorama_driver.cpp
    ${CMAKE_SOURCE_DIR}/diorama_driver.hpp
    ${CMAKE_SOURCE_DIR}/main.cpp
    ${CMAKE_SOURCE_DIR}/aux.cpp
    ${BISON_parser_OUTPUTS}
    ${FLEX_lexer_OUTPUTS})


# settings
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# TODO: add if statment for release mode to compiler flags
# set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_BUILD_TYPE Debug)

# target flags
target_compile_features(tb PRIVATE cxx_std_20)
target_compile_options(tb PRIVATE -Wall -Wextra)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# include(CMakePrintHelpers)
# cmake_print_variables(CMAKE_SOURCE_DIR)


# cmake -S src -B build
