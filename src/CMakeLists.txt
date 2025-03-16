set(PROJ "tb")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)



find_package(BISON 3.8.2)
bison_target(parser
    ${CMAKE_CURRENT_LIST_DIR}/diorama_parser.yy
    ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
    DEFINES_FILE
    ${CMAKE_CURRENT_BINARY_DIR}/parser.hpp)

#TODO: -Wcounterexamples add option to generate bison counterexamples

find_package(FLEX 2.6.4)
flex_target(lexer
    ${CMAKE_CURRENT_LIST_DIR}/diorama_lexer.ll
    ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)

add_flex_bison_dependency(lexer parser)

add_executable( ${PROJ}
    ${CMAKE_CURRENT_LIST_DIR}/aux.cpp
    ${CMAKE_CURRENT_LIST_DIR}/main.cpp
    ${CMAKE_CURRENT_LIST_DIR}/diorama_driver.cpp
    ${BISON_parser_OUTPUTS}
    ${FLEX_lexer_OUTPUTS})


target_include_directories(${PROJ} PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_BINARY_DIR})


# target flags
target_compile_features(${PROJ} PRIVATE cxx_std_20)
target_compile_options(${PROJ} PRIVATE -Wall -Wextra)

# link with cvc5
find_package(cvc5)
target_link_libraries(${PROJ} PUBLIC
    cvc5::cvc5)
