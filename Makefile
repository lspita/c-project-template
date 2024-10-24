CC=clang
CFLAGS:=-Wall -Wextra -Wpedantic -std=c17

CFORMAT:=clang-format
CFORMAT_FLAGS:=-i

# source dir
SRC:=src
# include dir
INCLUDE:=include
# lib dir
LIB:=lib
# objects dir
OUT:=out
# binary dir
BIN:=bin

ifeq ($(OS),Windows_NT)
	SHELL=C:/Program Files/Git/bin/bash.exe
	MAIN:=main.exe
else
	MAIN:=main
endif

# 2>/dev/null: This redirects the standard error output (file descriptor 2) to /dev/null, silencing any error messages
SOURCEDIRS:=$(shell find $(SRC) -type d 2>/dev/null)
INCLUDEDIRS:=$(shell find $(INCLUDE) -type d 2>/dev/null)
LIBDIRS:=$(shell find $(LIB) -type d 2>/dev/null)
FIXPATH=$1
RM=rm -f
RD=rm -rf
MD:=mkdir -p

# C sources
SOURCES:=$(wildcard $(patsubst %,%/*.c, $(SOURCEDIRS)))
# include dirs
INCLUDES:=$(patsubst %,-I%, $(INCLUDEDIRS:%/=%))
# C libs
LIBS:=$(patsubst %,-L%, $(LIBDIRS:%/=%))
# C object files 
OBJECTS:=$(SOURCES:$(SRC)/%.c=$(OUT)/%.o)
# Makefile dependency files
DEPS:=$(OBJECTS:.o=.d)

BINMAIN:=$(call FIXPATH,$(BIN)/$(MAIN))

all: build run

.PHONY: init
init: clean
	bear -- make build

build: $(SOURCES) $(BIN) $(MAIN)

$(BIN):
	$(MD) $(BIN)

$(MAIN): $(OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDES) $(LIBS) -o $(BINMAIN) $(OBJECTS)

# include all .d files
-include $(DEPS)

# $<: prerequisite of the rule(a .c file)
# $@: target of the rule(a .o file)
# -MMD: generates dependency output files same name as the .o file
$(OUT)/%.o: $(SRC)/%.c
	$(CFORMAT) $(CFORMAT_FLAGS) $<
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDES) -c -MMD $< -o $@

.PHONY: clean
clean:
	$(RM) compile_commands.json
	$(RD) .cache
	$(RD) $(BIN)
	$(RD) $(OUT)

run:
	$(call FIXPATH,./$(BINMAIN))