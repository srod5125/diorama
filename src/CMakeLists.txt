cmake_minimum_required(VERSION 3.27.2)

project(diorama_tb
       DESCRIPTION "informal model chechker"
       LANGUAGES CXX)


# todo add if not defined for both flex & bison files

find_package(cvc5)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(PROJ "tb")

add_executable(${PROJ}
    ${CMAKE_SOURCE_DIR}/aux.cpp
    ${CMAKE_SOURCE_DIR}/main.cpp)

target_include_directories(${PROJ} PUBLIC
    ${CMAKE_SOURCE_DIR}
    /home/stephen/diorama/deps/include/cppcoro)


# settings
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# TODO: add if statment for release mode to compiler flags
# set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_BUILD_TYPE Debug)

# target flags
target_compile_features(${PROJ} PRIVATE cxx_std_20)
target_compile_options(${PROJ} PRIVATE -Wall -Wextra)

# link with cvc5
target_link_libraries(${PROJ} cvc5::cvc5)



include(CMakePrintHelpers)
cmake_print_variables(PROJECT_SOURCE_DIR)


# cmake -S src -B build
