# Makefile for Kamiyu GameBoy projects - 19/09/2022

# ======= Check the OS calling this file =======

USED_OS := ERROR
P_SEP   := /
CLS     := clear

ifdef OS
    USED_OS := Windows
else 
    ifeq ($(shell uname), Linux)
        USED_OS := Linux
    endif
endif

ifeq ($(USED_OS), Windows)
    RM      := del 
    P_SEP   := \\
    CLS     := cls 
endif

# ========= Everything project related =========
MAKEFLAGS += --no-print-directory
PROJ    := runman
TARGET  := build/$(PROJ).gb
EXT     := asm
COMP    := rgbasm
LINK    := rgblink
PATCH   := rgbfix
CONVERT := rgbgfx

# ========== Everything files related ==========

SRC_DIR := src
GAME_DIR  := src/game
UTIL_DIR  := src/utilities
OBJ_DIR   := build
TILES_DIR := assets

SRC_FILES := $(wildcard $(SRC_DIR)/**/*.$(EXT))
OBJ_FILES := $(patsubst %.$(EXT),%.o,$(patsubst $(SRC_DIR)/%,$(OBJ_DIR)/%,$(SRC_FILES)))

PNG_FILES := $(wildcard $(TILES_DIR)/*.png)
BPP_FILES := $(patsubst $(TILES_DIR)/%.png,$(TILES_DIR)/%.2bpp,$(PNG_FILES))

# ========== Everything flags related ==========

O_FLAGS     := -Wall -Wextra -i include -i assets -h
PATCH_FLAGS := -v -p 0xFF
LINK_FLAGS  :=

# =========== Every usable functions ===========

# Basic Build

buildAll: 
	make convertTiles 
	make $(TARGET)

$(TARGET):$(OBJ_FILES)
	$(LINK) $^ -o $@ $(LINK_FLAGS) -n $(OBJ_DIR)/$(PROJ).sym -m $(OBJ_DIR)/$(PROJ).map
#   "tkt soeurette je m'occupe du patch"
	$(PATCH) $(PATCH_FLAGS) $(TARGET) 

# O files compiling

objects: $(OBJ_FILES)
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.$(EXT)
	$(COMP) -L $< -o $@ $(O_FLAGS)

# PNG converting

convertTiles: $(BPP_FILES)
$(TILES_DIR)/%.2bpp: $(TILES_DIR)/%.png
	$(CONVERT) $< -o $@

run: $(TARGET)
	sameboy $(TARGET)

# File Cleaner

clean: 
	$(RM) $(OBJ_FILES)
	$(RM) $(BPP_FILES)
	$(RM) $(TARGET)

debugPrint:
	@echo $(SRC_FILES)
	@echo $(OBJ_FILES)
	@echo $(PNG_FILES)
	@echo $(BPP_FILES)
	@echo end debugPrint