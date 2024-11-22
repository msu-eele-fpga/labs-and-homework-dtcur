SRC_DIR := src
OBJ_DIR := obj
BIN_DIR := bin
HEADER_DIR := include 

EXE := /srv/nfs/de10nano/ubuntu-rootfs/home/soc/labs/lab-08/led-patterns
#EXE := bin/led-patterns
SRC := $(wildcard $(SRC_DIR)/*.c)
OBJ := $(SRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
HEADERS := $(wildcard $(HEADER_DIR)/*.h)

CPPFLAGS := -Iinclude -MMD -MP	#C PreProcessor not C++ 

CC = arm-linux-gnueabihf-gcc
#CC = gcc
CFLAGS = -g -Iinclude
LIBS = -l wiringPi
I2C = -l i2c

.PHONY: all clean


#Create EXEcutable
all: $(EXE) $(OBJS) $(HEADERS)

$(EXE): $(OBJ) | $(BIN_DIR)
	$(CC) $(OBJ)  $ -o $@


#Make objects
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

#Ensure proper folder structure
$(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

