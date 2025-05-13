# project
set(PROJECT_NAME c-project-template)
set(PROJECT_VERSION 0.1.0)
set(PROJECT_DESCRIPTION "C project template")
set(PROJECT_HOMEPAGE_URL https://github.com/lspita/c-project-template)

# language
set(LANGUAGE C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# directories
set(SRC_DIR src) # sources dir
set(MAIN_FILE main.c) # main source of the executable
set(INCLUDE_DIR include) # public headers location
set(TEST_DIR test) # tests dir
set(TEST_EXECUTABLES *.test.c) # test sources treated as executables
set(EXTRA_LIBRARIES m) # libraries to link
