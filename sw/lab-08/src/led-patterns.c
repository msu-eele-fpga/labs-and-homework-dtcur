#include "led-patterns.h" // Include header file because I forget to do this all the time

//Constructor 
struct led_pattern* pattern_formatter(char *pattern_input, char *duration_input, led_pattern *head, bool very_verbose)
{
        //Take string of pattern and time in as an input and convert to an unsigned long int


  
        //Construct the struct
        struct led_pattern *pattern = (struct led_pattern*)malloc(sizeof(led_pattern));
        //Check for failed pointer creation
        if(!pattern)
        {
                return(NULL);
        }

        //Populate next struct with provided data
        pattern->next = head;
        pattern->pattern = strtoul(pattern_input, NULL, 16);
        pattern->duration = strtoul(duration_input, NULL, 10);
        if(very_verbose){
                printf("-------------------------------------------------------------------\n\r");
                printf("Creating linked list \n\r");
                printf("Pattern data:\n=\r");
                printf("Pattern: %s Duration %s\n\r", pattern_input, duration_input);
                printf("Linked list information:\n\r");
                printf("pattern ptr: 0x%8lx\n\r", pattern);
                printf("HEAD: 0x%8lx\n\r", head);
                printf("-------------------------------------------------------------------\n\r");
                fflush(stdout);
        }
        //return pointer to the new pattern
        return(pattern);
}

/*
* This function is heavily based on the work of Trevor Vannoy 
* written for EELE-467 SoC FPGAs at Montana State University Fall 2024
* Code written by Drew Currie
*/
int display_pattern(led_pattern pattern, bool verbose, bool very_verbose)
{
                //Display the pattern provided in the struct on the LED bank
                
               
        /*
        * Order of operations:
        *       1. At base address with offset of 0, is LED-Control
        *               LED control 1 is SW 0 is HW
        *       2. At base address with offset of 4, is pattern register
        *               32 bit register that takes in the pattern to be displayed
        *               NOTE: this is static with only 8 LEDs
        *       3. Set the base period for changing the pattern
        *               NOTE: This doesn't do much as the software handles the changing of patterns
        *               when multiple are applied since there is no way to handle multiple
        *               in the avalon bus interface
        */

        //1. Set into SW control mode

        if(verbose)
        {
                printf("-------------------------------------------------------------------\n\r");
                printf("Values being written:\n\r");
                printf("\tControl: 0x%04x (bool)\n\r", ENABLE_LED_CONTROL);
                printf("\tPattern: 0x%04x \n\r", pattern.pattern);
                printf("\tDuration: %lu ms\n\r", pattern.duration);
                printf("-------------------------------------------------------------------\n\r");

        }
        
        volatile uint32_t *enable_register = calculate_Memory_Offset(ENABLE_REGISTER_ADDR, verbose, very_verbose);
        *enable_register = ENABLE_LED_CONTROL;

        //2. Set pattern
        volatile uint32_t *pattern_register = calculate_Memory_Offset(LED_REGISTER_ADDR, verbose, very_verbose);
        *pattern_register = pattern.pattern;
        

        //3. set duration
        volatile uint32_t *duration_register = calculate_Memory_Offset(DURATION_REGISTER_ADDR, verbose, very_verbose);
        *duration_register = pattern.duration;

        return(0);

}