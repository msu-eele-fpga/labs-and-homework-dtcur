#ifndef LED_PATTERNS_H
#define LED_PATTERNS_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
//Packages below may be redundant. Needs checked but this 
//code should no longer do direct memory access
//that has been moved to memory-addresser
#include <sys/mman.h>   //For mmap
#include <fcntl.h>      //For file open flags
#include <unistd.h>     //For page size

//Bring in the memory addresser code
//This contains the functions for accessing the memory
//and constants for interfacing with the memory
#include "memory-addresser.h"


//Struct to hold the LED patterns
typedef struct led_pattern
{
        unsigned long pattern;
        unsigned long duration;
} led_pattern;

//Constructor 
inline struct led_pattern* pattern_formatter(char *pattern_input, char *duration_input);
//Function to display an led_pattern on the FPGA leds
int display_pattern(led_pattern pattern, bool verbose);

#endif