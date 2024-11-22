#ifndef LED_PATTERNS_H
#define LED_PATTERNS_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>   //For mmap
#include <fcntl.h>      //For file open flags
#include <unistd.h>     //For page size


//Some useful constants

#define BASE_ADDRESS 0xFF200000u
#define ENABLE_ADDRESS BASE_ADDRESS + 0x4u
#define LED_OFFSET BASE_ADDRESS + 0x8u
#define DURATION_OFFSET BASE_ADDRESS + 0x12u

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