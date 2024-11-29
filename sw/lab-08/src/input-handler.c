#include <stdio.h>     /* for printf */
#include <stdlib.h>    /* for exit */
#include <getopt.h>    /* for getopt_long; POSIX standard getopt is in unistd.h */

//Input interrupt for ctrl-c
#include <signal.h>


//Supporting code
#include "input-struct.h"
#include "help-text.h"
#include "led-patterns.h"
#include "memory-addresser.h" //Needed for ctrl+c handler
#include "file-reader.h"        


void sigint_Handler(int);



//--- Main code --------------------------------------------------------
int main (int argc, char **argv) {

        //Signal handling
        signal(SIGINT, sigint_Handler); 
    
        //Input handler variables and flags
        int c;
        int digit_optind = 0;
        int fopt = 0, vopt = 0, popt = 0;
        char *copt = 0, *dopt = 0;
        bool verbose = false, very_verbose = false;
        int option_index = 0;

        //create pointer to the first pattern in the linked list
        //Used if fopt or popt
        struct led_pattern *HEAD = NULL;

        //Check for input arguments 
        while ((c = getopt_long(argc, argv, "hvpf:012", long_options, &option_index)) != -1) 
                {
                        int this_option_optind = optind ? optind : 1;
                        switch (c) {
                        case 0:
                        printf ("option %s", long_options[option_index].name);
                        if (optarg) {
                                printf (" with arg %s", optarg);
                        }
                        printf ("\n");
                        break;
                        case '0':
                        case '1':
                        case '2':
                                if (digit_optind != 0 && digit_optind != this_option_optind) {
                                        printf ("digits occur in two different argv-elements.\n");
                                }
                                digit_optind = this_option_optind;
                                printf ("option %c\n", c);
                                break;
                        //Print usage text (Help text)
                        case 'h':
                                print_help_text();
                                exit(0);
                                break;
                        //Put system into verbose mode
                        case 'v':
                                verbose = true;
                                break;
                        case 'z':
                                //This is extreme verbosity. This will print EVERYTHING
                                very_verbose = true;
                                verbose = true;
                                break;
                        //User has inputted specific patterns to display. 
                        //Set popt flag and handle pattern & duration input later
                        case 'p':
                                popt = 1;
                                break;
                        //User has provided a file to read for patterns
                        //Set fopt flag and handle file input later
                        case 'f':
                                fopt = 1;
                                break;
                        //Alias for help/usage text
                        case '?':
                                print_help_text();
                                break;
                        //Invalid or no input arguments. Print help/usage text
                        default:
                                print_help_text();
                                exit(0);
                                break;
                        }
                }
                //Check for file flag.
                //If file and pattern flag are provided only respond to file flag
                //Ignore patterns from command line
                if(fopt)
                {
                        if(very_verbose)
                        {
                                printf("File provided: %s ", argv[argc-1]);
                        }
                        FILE *pattern_file;
                        pattern_file = fopen(argv[argc-1], "r");
                        
                        //Check for success opening file
                        if(pattern_file == NULL)
                        {
                                fprintf(stderr, "Unable to open file.\n\r");
                                exit(1);
                        }
                        HEAD = pattern_reader(pattern_file, verbose, very_verbose);
                        
                        if(very_verbose)
                        {
                                printf("Starting pattern display\n\r");
                        }   
                        //Pattern display loop
                        //Iterate through the linked list of patterns.

                        //Display provided patterns in linked list
                        struct led_pattern *local_head = HEAD;
                        while(local_head != NULL){
                                display_pattern(*local_head, verbose, very_verbose);
                                //Sleep for duration equal to the pattern in milliseconds
                                usleep(local_head->duration * 1000);
                                local_head = local_head->next;
                        }
                        //only display through the LED-Pattern sequence once for a file
                        if(verbose)
                        {
                                printf("\n\r-------------------------------------------------------------------\n\r");
                                printf("Completed displaying all patterns in file: %s\n\r", argv[argc-1]);
                                printf("Program will now exit & return control to FPGA fabric.\n\r");
                                printf("-------------------------------------------------------------------\n\r");
                        }
                        //Return control to FPGA fabric
                        volatile uint32_t *enable_register = calculate_Memory_Offset(ENABLE_REGISTER_ADDR, false, false);
                        *enable_register = ~ENABLE_LED_CONTROL;
                        fflush(stdout);
                        //Exit successfully
                        exit(0);
                
                }
                //If no file flag display the patterns provided in the 
                //Input arguments
                else if(popt)
                {
                        //Means that the program was called with --pattern
                        //This shifts optind by one for some reason
                        if(optind == 4)
                        {
                                while(optind < argc + 1)
                                {
                                        HEAD = pattern_formatter(argv[(optind++)-1], argv[(optind++)-1], HEAD, very_verbose);
                                }
                        }
                        else
                        {
                                while(optind < argc)
                                {
                                        HEAD = pattern_formatter(argv[optind++], argv[optind++], HEAD, very_verbose);
                                }

                        }
                        
                        if(very_verbose)
                        {
                                printf("Starting pattern display\n\r");
                        }      
                        //pattern display loop.
                        //Iterate through the linked list of patterns.
                        while(1)
                        {
                                //Display provided patterns in linked list
                                struct led_pattern *local_head = HEAD;
                                while(local_head != NULL){
                                        display_pattern(*local_head, verbose, very_verbose);
                                        //Sleep for duration equal to the pattern in milliseconds
                                        usleep(local_head->duration * 1000);
                                        local_head = local_head->next;
                                }
                        }
                }
        //Should never be reached.
        fprintf(stderr, "Reached un-reachable state. Exiting.\n\r");
        exit (1);
}



//---------- Ctrl-c input handler -------------------------------------
void sigint_Handler(int sig)
{
        char c;
        signal(SIGINT, sigint_Handler);
        fflush(stdout);
        printf("\n\n\rSystem exiting... Reverting control to FPGA fabric... \n\r");
        volatile uint32_t *enable_register = calculate_Memory_Offset(ENABLE_REGISTER_ADDR, false, false);
        *enable_register = ~ENABLE_LED_CONTROL;
        fflush(stdout);
        exit(0);
}