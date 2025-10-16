#[[
Required:
- PROJECT_NAME (string) project name

Variables:
- SRC_DIR (string, default=src) sources directory
- INCLUDE_DIR (string, default=include) public include directory
- LIB_DIR (string, default=lib) external lib files
- EXEC_PATTERNS (list, default=main) list of patterns matching sources that are executables (without last file extension)
- TEST_PATTERNS (list, default=*.test) list of patterns matching sources that are tests (without last file extension)
- TARGETS_DIR (string, default=targets) binary directory relative path containing all targets
- CMAKE_DIR (string, default=cmake) cmake config files directory
- CMAKE_TEMPLATES_DIR (string, default=cmake) CMAKE_DIR subdirectory containing template files
- CLANG_TIDY (string, default=clang-tidy) clang tidy executable, unset to stop using clang tidy
]]#

set(PROJECT_NAME cxx-project-template)
set(PROJECT_VERSION 0.1.0)
set(PROJECT_DESCRIPTION "C/C++ project template")
set(PROJECT_HOMEPAGE_URL https://github.com/lspita/cxx-project-template)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

if (MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()
