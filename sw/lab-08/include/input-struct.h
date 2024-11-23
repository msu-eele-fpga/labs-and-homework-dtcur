#ifndef INPUT_STRUCT_H
#define INPUT_STRUCT_H
#include <getopt.h>     /* for getopt_long; POSIX standard getopt is in unistd.h */
#include <stdio.h>      /*for NULL and printf*/

//Create struct for the input options passed in that are in long form IE GNU
    static struct option long_options[] = {
    /*   NAME       ARGUMENT           FLAG  SHORTNAME */
        {"help",        no_argument,        NULL, 'h'},
        {"verbose",     no_argument,        NULL, 'v'},
        {"veryverbose", no_argument,        NULL, 'z'},
        {"pattern",     required_argument,  NULL, 'p'},
        {"verbose",     no_argument,        NULL, 'p'},
        {"file",        required_argument,  NULL, 'f'},
        {NULL,          0,                  NULL,   0}
    };

#endif