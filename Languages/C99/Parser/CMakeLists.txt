cmake_minimum_required(VERSION 3.14)
project(c99-asn1 C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Compiler warnings
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# Library
add_library(asn1
    src/asn1_parser.c
    src/asn1_serializer.c
    src/asn1_types.c
)

target_include_directories(asn1 PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Test executable
add_executable(test_asn1
    test/test_parser.c
)

target_link_libraries(test_asn1 PRIVATE asn1)

# Enable testing
enable_testing()
add_test(NAME test_asn1 COMMAND test_asn1)

# Golden file tests
add_executable(test_golden
    test/test_golden.c
)

target_link_libraries(test_golden PRIVATE asn1)
add_test(NAME test_golden COMMAND test_golden WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

# Example executable
add_executable(example_parse
    test/example_parse.c
)

target_link_libraries(example_parse PRIVATE asn1)
