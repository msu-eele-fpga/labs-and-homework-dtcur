SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin

EXE := $(BIN_DIR)/led-patterns
SRC := $(wildcard $(SRC_DIR)/*.c)
OBJ := $(SRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

CPPFLAGS := -Iinclude -MMD -MP	#C PreProcessor not C++ 

C++ = g++ 
CC = gcc
CFLAGS = -g -Wall


.PHONY: all clean

#Create EXEcutable
all: $(EXE) $(OBJS)

$(EXE): $(OBJ) | $(BIN_DIR)
	$(CC) $(OBJ) $ -o $@


#Make objects
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

#Ensure proper folder structure
$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@
