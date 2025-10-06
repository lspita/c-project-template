cmake_minimum_required(VERSION 3.24.0)

function(set_default var val)
    if(NOT DEFINED ${var})
        set(${var} ${val} PARENT_SCOPE)
    endif()
endfunction()

set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(PROJECT_LANGUAGES "C" "CXX")
set(SOURCES_EXTENSIONS "c" "cpp" "cc" "cxx")
set(MAIN_SOURCE_NAME main)
set(SRC_DIR src)
set(INCLUDE_DIR include)
set(LIB_DIR lib)
set(CMAKE_DIR cmake)
set(TEST_EXTRA_EXT "test")
set_default(CMAKE_BUILD_TYPE Debug)

include("${CMAKE_DIR}/setup.cmake")

set_default(ROOT_TARGET_NAME "${PROJECT_NAME}")

function(get_arg index outvar default _argn)
    set(opts ${_argn})
    list(LENGTH opts n)
    if (n GREATER ${index})
        list(GET opts ${index} val)
    else()
        set(val ${default})
    endif()
    set(${outvar} "${val}" PARENT_SCOPE)
endfunction()

set(MAIN_SOURCE_NAMES_LIST)
foreach(ext IN LISTS SOURCES_EXTENSIONS)
    list(APPEND MAIN_SOURCE_NAMES_LIST "${MAIN_SOURCE_NAME}.${ext}")
endforeach()

function(abs_path outvar path)
    set(${outvar} "${CMAKE_SOURCE_DIR}/${path}" PARENT_SCOPE)
endfunction()

function(remove_regex outvar reg value)
    string(REGEX REPLACE "${reg}" "" res "${value}")
    set(${outvar} "${res}" PARENT_SCOPE)
endfunction()

function(src_path outvar path)
    remove_regex(res "^${CMAKE_SOURCE_DIR}\\/?" "${path}")
    remove_regex(res "^${SRC_DIR}\\/?" "${res}")
    set(${outvar} "${res}" PARENT_SCOPE)
endfunction()

function(check_exists path)
    if (NOT EXISTS "${path}")
        message(FATAL_ERROR "Path ${path} does not exist")
    endif()
endfunction()

function(check_isdir path)
    if (NOT IS_DIRECTORY "${path}")
        message(FATAL_ERROR "Path ${path} is not a directory")
    endif()
endfunction()

function(sources_patterns outvar dir)
    set(patterns)
    foreach(ext IN LISTS SOURCES_EXTENSIONS)
        list(APPEND patterns "${dir}/*.${ext}")
    endforeach()
    set(${outvar} "${patterns}" PARENT_SCOPE)
endfunction()

function(tests_patterns outvar dir)
    set(patterns)
    foreach(ext IN LISTS SOURCES_EXTENSIONS)
        list(APPEND patterns "${dir}/*.${TEST_EXTRA_EXT}.${ext}")
    endforeach()
    set(${outvar} "${patterns}" PARENT_SCOPE)
endfunction()

function(main_sources outvar dir)
    set(val)
    foreach(main_source_name IN LISTS MAIN_SOURCE_NAMES_LIST)
        file(GLOB_RECURSE main_files "${dir}/${main_source_name}")
        list(LENGTH main_files n)
        if (n GREATER 0)
            list(APPEND val "${main_files}")
        endif()
    endforeach()
    set(${outvar} "${val}" PARENT_SCOPE)
endfunction()

# create project
project(
    "${PROJECT_NAME}"
    VERSION ${PROJECT_VERSION}
    DESCRIPTION "${PROJECT_DESCRIPTION}"
    HOMEPAGE_URL "${PROJECT_HOMEPAGE_URL}"
    LANGUAGES ${PROJECT_LANGUAGES}
)

# explicit includes needed for nix
foreach(lang IN LISTS PROJECT_LANGUAGES)
    set(CMAKE_${lang}_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_${lang}_IMPLICIT_INCLUDE_DIRECTORIES})
endforeach()

# generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# make dirs full-paths
abs_path(SRC_DIR_ABS ${SRC_DIR})
abs_path(INCLUDE_DIR_ABS ${INCLUDE_DIR})
abs_path(LIB_DIR_ABS ${LIB_DIR})
check_exists(${SRC_DIR_ABS})
check_isdir(${SRC_DIR_ABS})

# get source files
set(EXE_NAME ${PROJECT_NAME})
main_sources(MAIN_SOURCES ${SRC_DIR_ABS})
sources_patterns(CXX_PATTERNS ${SRC_DIR_ABS})
file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS ${CXX_PATTERNS})
tests_patterns(TESTS_PATTERNS ${SRC_DIR_ABS})
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS ${TESTS_PATTERNS})
list(REMOVE_ITEM CXX_SOURCES ${MAIN_SOURCES})
list(REMOVE_ITEM CXX_SOURCES ${TEST_SOURCES})

# create lib
set(PROJECT_LIB "${PROJECT_NAME}-lib")
add_library("${PROJECT_LIB}" STATIC)
target_sources("${PROJECT_LIB}" PRIVATE ${CXX_SOURCES})
target_include_directories("${PROJECT_LIB}" PRIVATE "${SRC_DIR_ABS}")
if (EXISTS "${INCLUDE_DIR_ABS}")
    check_isdir("${INCLUDE_DIR_ABS}")
    target_include_directories("${PROJECT_LIB}" PUBLIC "${INCLUDE_DIR_ABS}")
endif()
if (EXISTS "${LIB_DIR_ABS}")
    check_isdir("${LIB_DIR_ABS}")
    target_include_directories("${PROJECT_LIB}" PUBLIC "${LIB_DIR_ABS}")
    sources_patterns(LIB_CXX_PATTERNS "${LIB_DIR_ABS}")
    file(GLOB_RECURSE LIB_CXX_SOURCES CONFIGURE_DEPENDS ${LIB_CXX_PATTERNS})
    message(STATUS ${LIB_CXX_SOURCES})
    target_sources("${PROJECT_LIB}" PRIVATE ${LIB_CXX_SOURCES})
endif()
include("${CMAKE_DIR}/libraries.cmake" OPTIONAL)

function(make_executable outexe outid outpath filepath)
    get_filename_component(filename "${filepath}" NAME)
    get_filename_component(exename "${filepath}" NAME_WLE)
    get_filename_component(exedir "${filepath}" DIRECTORY)
    if (NOT IS_DIRECTORY "${filepath}" AND "${filename}" IN_LIST MAIN_SOURCE_NAMES_LIST)
        get_filename_component(exename "${exedir}" NAME)
        get_filename_component(exedir "${exedir}" DIRECTORY)
        if ("${exename}" STREQUAL "${SRC_DIR}" AND "${exedir}" STREQUAL "${CMAKE_SOURCE_DIR}")
            set(exename "${ROOT_TARGET_NAME}")
        endif()
    endif()
    src_path(exepath "${exedir}/${exename}")
    string(REPLACE "/" "_" exeid "${exepath}")

    add_executable("${exeid}" "${filepath}")
    get_arg(0 link_lib true "${ARGN}")
    if (${link_lib})
        target_link_libraries(${exeid} PRIVATE ${PROJECT_LIB})
    endif()
    # https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html#target-properties
    src_path(bindir "${exedir}")
    set(bindir "${CMAKE_BINARY_DIR}/out/${bindir}")
    set_target_properties(${exeid} PROPERTIES 
        RUNTIME_OUTPUT_DIRECTORY ${bindir}
        OUTPUT_NAME ${exename}
    )
    set(${outexe} ${${exeid}} PARENT_SCOPE) 
    set(${outid} ${exeid} PARENT_SCOPE)
    set(${outpath} ${exepath} PARENT_SCOPE) 
endfunction()

# create main executables
foreach(main_source IN LISTS MAIN_SOURCES)
    make_executable(mainexe mainid mainpath ${main_source})
endforeach()

# enable testing
include(CTest)
enable_testing()

# create test executables
foreach(test_file IN LISTS TEST_SOURCES)
    make_executable(testexe testid testpath ${test_file})
    remove_regex(testpath "\\.${TEST_EXTRA_EXT}$" "${testpath}")
    add_test(NAME "${testpath}" COMMAND ${testid})
endforeach()

# generate .clangd file
set(CLANGD_CONFIG_CONTENT 
"CompileFlags:
CompilationDatabase: ${CMAKE_BINARY_DIR}
")
file(WRITE ${CMAKE_SOURCE_DIR}/.clangd ${CLANGD_CONFIG_CONTENT})

include("${CMAKE_DIR}/overrides.cmake" OPTIONAL)
