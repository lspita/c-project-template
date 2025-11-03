#[[
Functions
- abs_path(outvar path) prefix path with absolute project directory
- src_path(outvar path) prefix path with absolute source directory
- remove_regex(outvar reg value) remove what matches `reg` from `value`
- check_exists(path) error if path doesn't exist
- check_isdir(path) error if path is not a directory
- check_isnotdir(path) error if path is a directory

Variables:
- PROJECT_LIB (library) library with all source files
- SRC_SOURCES (list) list of all sources in SRC_DIR
- EXEC_SOURCES (list) list of all sources that are executables
- TEST_SOURCES (list) list of all sources that are tests
- SRC_DIR_ABS (string) abs path of SRC_DIR
- INCLUDE_DIR_ABS (string) abs path of INCLUDE_DIR
- LIB_DIR_ABS (string) abs path of LIB_DIR

Every test is named after the relative path from SRC_DIR.
Targets are located under bin/<preset>/targets
]]#

if (MSVC)
    target_compile_options(${PROJECT_LIB} PRIVATE /W4)
else()
    target_compile_options(${PROJECT_LIB} PRIVATE -Wall -Wextra -Wpedantic)
    target_link_libraries(${PROJECT_LIB} PUBLIC m) # add math library
endif()
