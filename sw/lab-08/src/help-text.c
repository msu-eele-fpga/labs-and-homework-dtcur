#include "help-text.h"

void print_help_text(void)
{
        //Big print for the usage text
        printf("usage: led-patterns [options] [patterns] [duration]\n\r");
        printf("File and pattern inputs are mutally exclusive.\n\r");
        printf("Display provided patterns on the LED bank on the FGPA\n\r");
        printf("\n\r");
        printf("Mandatory arguments to long options are mandatory for short options too.\n\r");
        printf("options:\n\r");
        printf("\t -h, --help                    Display this text and exit\n\r");
        printf("\t -v, --verbose                 Print what LED patterns is as a binary string,\n\r");
        printf("\t                               and how long each pattern will be displayed for\n\r");
        printf("\t     --veryverbos              Print all debugging information. Also sets verbose.\n\r");
        printf("\t -p, --pattern PATTERN         Display the provided pattern for the provided\n\r");
        printf("\t                               duration, loops for as long as the code is running\n\r");
        printf("\t -f, --file FILE.txt           Display the patterns in the provided file for the \n\r");
        printf("\t                               provided duration. Loops patterns while code is running\n\r");

}