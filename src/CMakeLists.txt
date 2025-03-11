find_package(cvc5)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(PROJ "tb")

add_executable(${PROJ}
    ${CMAKE_CURRENT_LIST_DIR}/aux.cpp
    ${CMAKE_CURRENT_LIST_DIR}/main.cpp)

target_include_directories(${PROJ} PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
    /home/stephen/diorama/deps/include/cppcoro)


# target flags
target_compile_features(${PROJ} PRIVATE cxx_std_20)
target_compile_options(${PROJ} PRIVATE -Wall -Wextra)

# link with cvc5
target_link_libraries(${PROJ} cvc5::cvc5)
