cmake_minimum_required(VERSION 3.21.0)
include(config.cmake)

# create project
project(
    ${PROJECT_NAME}
    VERSION ${PROJECT_VERSION}
    DESCRIPTION ${PROJECT_DESCRIPTION}
    HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL}
    LANGUAGES ${LANGUAGE}
)
# generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# set names
set(EXE_NAME ${PROJECT_NAME})
set(LIB_NAME ${PROJECT_NAME}_lib)
set(TEST_NAME ${PROJECT_NAME}_test)
set(TEST_LIB_NAME ${TEST_NAME}_lib)

# make dirs full-paths
set(SRC_DIR ${CMAKE_SOURCE_DIR}/${SRC_DIR})
set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/${INCLUDE_DIR})
set(TEST_DIR ${CMAKE_SOURCE_DIR}/${TEST_DIR})

# split sources into main executable and lib files
set(MAIN_SOURCE ${SRC_DIR}/${MAIN_FILE})
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS ${SRC_DIR}/*.c)
list(REMOVE_ITEM SOURCES ${MAIN_SOURCE})

# create lib
add_library(${LIB_NAME} STATIC ${SOURCES})
target_link_libraries(${LIB_NAME} PUBLIC ${EXTRA_LIBRARIES})
target_include_directories(${LIB_NAME}
    PUBLIC
        ${INCLUDE_DIR}
    PRIVATE
        ${SRC_DIR}
)

# create main executable
add_executable(${EXE_NAME} ${MAIN_SOURCE})
target_link_libraries(${EXE_NAME} PRIVATE ${LIB_NAME})

# enable testing
include(CTest)
enable_testing()

# create test library
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS ${TEST_DIR}/*.c)
file(GLOB_RECURSE TESTS CONFIGURE_DEPENDS ${TEST_DIR}/${TEST_EXECUTABLES})
list(REMOVE_ITEM TEST_SOURCES ${TESTS})

add_library(${TEST_LIB_NAME} STATIC ${TEST_SOURCES})
target_include_directories(${TEST_LIB_NAME}
    PRIVATE 
        ${SRC_DIR}
        ${TEST_DIR}
)
target_link_libraries(${TEST_LIB_NAME}
    PRIVATE
        ${LIB_NAME}
)

# create test executables
foreach(test_file IN LISTS TESTS)
    get_filename_component(test_name ${test_file} NAME_WE)
    add_executable(${test_name} ${test_file})
    target_include_directories(${test_name}
        PRIVATE
            ${TEST_DIR}
            ${SRC_DIR}
            ${INCLUDE_DIR}
    )
    target_link_libraries(${test_name}
        PRIVATE
            ${TEST_LIB_NAME}
    )
    add_test(NAME ${test_name} COMMAND ${test_name})
endforeach()

# generate .clangd file
set(CLANGD_CONFIG_CONTENT 
"CompileFlags:
    CompilationDatabase: ${CMAKE_BINARY_DIR}
")
file(WRITE ${CMAKE_SOURCE_DIR}/.clangd ${CLANGD_CONFIG_CONTENT})
