CC=clang
CFLAGS:=-Wall -Wextra -Wpedantic -std=c89

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
	MAIN:=main.exe
	SOURCEDIRS:=$(SRC)
	INCLUDEDIRS:=$(INCLUDE)
	LIBDIRS:=$(LIB)
	FIXPATH=$(subst /,\,$1)
	RM:=del /q /f
	RD:=rd /q /s /f
	MD:=mkdir
else
	MAIN:=main
	SOURCEDIRS:=$(shell find $(SRC) -type d)
	INCLUDEDIRS:=$(shell find $(INCLUDE) -type d)
	LIBDIRS:=$(shell find $(LIB) -type d)
	FIXPATH=$1
	RM=rm -f
	RD=rm -rf
	MD:=mkdir -p
endif

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
	$(RD) $(BIN)
	$(RD) $(OUT)

run:
	$(call FIXPATH,./$(BINMAIN))