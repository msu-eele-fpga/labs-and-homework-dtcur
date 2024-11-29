#ifndef FILE_READER_H
#define FILE_READER_H

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#include "led-patterns.h"

//Useful constants
#define MAX_LINE_LENGTH 12

struct led_pattern* pattern_reader(FILE *pattern_file, bool verbose, bool very_verbose);

#endif