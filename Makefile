CC:=clang
CFLAGS:=-Wall -Wextra -Wpedantic -std=c99

CFORMAT:=clang-format
CFORMAT_FLAGS:=-i

# source dir
SRC:=src
# include dir
INC:=inc
# lib dir
LIB:=lib
# output dir
OUT:=out
# build files dir
BUILD:=$(OUT)/build
# binary dir
BIN:=$(OUT)/bin

ifeq ($(OS),Windows_NT)
	SHELL=C:/Program Files/Git/bin/bash.exe
	MAIN:=main.exe
else
	MAIN:=main
endif

# 2>/dev/null: This redirects the standard error output (file descriptor 2) to /dev/null, silencing any error messages
SRC_DIRS:=$(shell find $(SRC) -type d 2>/dev/null)
INC_DIRS:=$(shell find $(INC) -type d 2>/dev/null)
LIB_DIRS:=$(shell find $(LIB) -type d 2>/dev/null)

# C sources
SRC_FILES:=$(wildcard $(patsubst %,%/*.c, $(SRC_DIRS)))
# include dirs
INC_FLAGS:=$(patsubst %,-I%, $(INC_DIRS:%/=%))
# C libs
LIB_FLAGS:=$(patsubst %,-L%, $(LIB_DIRS:%/=%))
# C object files 
OBJ_FILES:=$(SRC_FILES:$(SRC)/%.c=$(BUILD)/%.o)
# Makefile dependency files
DEP_FILES:=$(OBJ_FILES:%.o=%.d)

BINMAIN:=$(BIN)/$(MAIN)

all: init run

.PHONY: clean
init:
	bear -- make clean build

build: $(SRC_FILES) $(OUT) $(MAIN)

$(OUT):
	mkdir -p $(BUILD)
	mkdir -p $(BIN)

$(MAIN): $(OBJ_FILES)
	$(CC) $(CFLAGS) $(INC_FLAGS) $(LIB_FLAGS) -o $(BINMAIN) $(OBJ_FILES)

# include all .d files
-include $(DEP_FILES)

# $<: prerequisite of the rule (a .c file)
# $@: target of the rule (a .o file)
# -MMD: generates dependency output files same name as the .o file
$(BUILD)/%.o: $(SRC)/%.c
	$(CFORMAT) $(CFORMAT_FLAGS) $<
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC_FLAGS) -c -MMD $< -o $@

run: build
	./$(BINMAIN)

.PHONY: clean vars
clean:
	rm -f compile_commands.json
	rm -rf .cache/
	rm -rf $(OUT)

vars:
	@echo CC=$(CC)
	@echo CFLAGS=$(CFLAGS)
	@echo CFORMAT=$(CFORMAT)
	@echo CFORMAT_FLAGS=$(CFORMAT_FLAGS)
	@echo SRC=$(SRC)
	@echo INC=$(INC)
	@echo LIB=$(LIB)
	@echo OUT=$(OUT)
	@echo BUILD=$(BUILD)
	@echo BIN=$(BIN)
	@echo SHELL=$(SHELL)
	@echo MAIN=$(MAIN)
	@echo SRC_DIRS=$(SRC_DIRS)
	@echo INC_DIRS=$(INC_DIRS)
	@echo LIB_DIRS=$(LIB_DIRS)
	@echo SRC_FILES=$(SRC_FILES)
	@echo INC_FLAGS=$(INC_FLAGS)
	@echo LIB_FLAGS=$(LIB_FLAGS)
	@echo OBJ_FILES=$(OBJ_FILES)
	@echo DEP_FILES=$(DEP_FILES)
	@echo BINMAIN=$(BINMAIN)