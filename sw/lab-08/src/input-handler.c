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
        bool verbose = false;
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
                                printf ("option: Verbose \n");
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
                        while(optind < argc)
                        {
                                printf("File provided: %s ", argv[optind++]);
                        }
                }
                //If no file flag display the patterns provided in the 
                //Input arguments
                else if(popt)
                {
                        //FOR TESTING! REMOVE!
                        verbose = true;

                        while(optind < argc)
                        {
                                HEAD = pattern_formatter(argv[optind++], argv[optind++], HEAD, verbose);
                        }
                }
                printf("Starting pattern display\n\r");
               
                while(1){
                        //Display provided patterns in linked list
                        struct led_pattern *local_head = HEAD;
                        while(local_head != NULL){
                                display_pattern(*local_head, true);
                                //Sleep for duration equal to the pattern in milliseconds
                                usleep(local_head->duration * 1000);
                                local_head = local_head->next;
                                
                        }

                        //For testing purposes display a static pattern
                        //display_pattern(*testPattern, true);
                        //usleep(testPattern->duration * 1000);
                }
        exit (0);
}



//---------- Ctrl-c input handler -------------------------------------
void sigint_Handler(int sig)
{
        char c;
        signal(SIGINT, sigint_Handler);
        fflush(stdout);
        printf("\n\n\rSystem exiting... Reverting control to FPGA fabric... \n\r");
        volatile uint32_t *enable_register = calculate_Memory_Offset(ENABLE_REGISTER_ADDR, false);
        *enable_register = ~ENABLE_LED_CONTROL;
        fflush(stdout);
        exit(0);
}