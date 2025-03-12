find_package(cvc5)

set(PROJ "tb")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable( ${PROJ}
    ${CMAKE_CURRENT_LIST_DIR}/aux.cpp
    ${CMAKE_CURRENT_LIST_DIR}/main.cpp)

target_include_directories(${PROJ} PUBLIC
    ${CMAKE_CURRENT_LIST_DIR})

# fetch lexy
include(FetchContent)
FetchContent_Declare(lexy URL https://lexy.foonathan.net/download/lexy-src.zip)
FetchContent_MakeAvailable(lexy)


# target flags
target_compile_features(${PROJ} PRIVATE cxx_std_20)
target_compile_options(${PROJ} PRIVATE -Wall -Wextra)

# link with cvc5
target_link_libraries(${PROJ} PUBLIC
    cvc5::cvc5
    foonathan::lexy)
