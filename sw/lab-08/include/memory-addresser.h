#ifndef MEMORY_ADDRESSER_H
#define MEMORY_ADDRESSER_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>   //For mmap
#include <fcntl.h>      //For file open flags
#include <unistd.h>     //For page size
#include <stdint.h> //Standard ints
#include <stdbool.h> //Booleans
/*
* Functions and constants to handle the creation of page aligned memory access for the avalon bus
*/


//Memory offset constants for the LED-Patterns specifically
#define BASE_ADDRESS 0xFF200000u
#define ENABLE_REGISTER_ADDR BASE_ADDRESS + 0x0u
#define DURATION_REGISTER_ADDR BASE_ADDRESS + 0x4u
#define LED_REGISTER_ADDR BASE_ADDRESS + 0x8u


//Bit masks for enabling control
#define ENABLE_LED_CONTROL 0x00000001


//Functions
//Calculate the pointer to the virtual memory location from the physical address provided
uint32_t* calculate_Memory_Offset(uint32_t physical_Address, bool verbose);


#endif