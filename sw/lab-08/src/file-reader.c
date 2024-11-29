#include "file-reader.h"

struct led_pattern* pattern_reader(FILE *pattern_file, bool verbose, bool very_verbose){
        /*
        * General flow:
        * Read the file and create a linked list of the patterns 
        * Return the pointer to the head of the linked list
        */
       /*
       * Takes in an already verified to be open file pointer. This could be a risky decision.
       * However by passing the file by reference, it has been established the file is opened
       * correctly previously. As such there is no rigorous error handling for the file pointer. 
       */
        //Simple NULL check:
        if(pattern_file == NULL){
                fprintf(stderr, "Received bad file pointer.\n\r");
                exit(1);
        }

        //Create head for the linked list that will be returned
        struct led_pattern *local_head = NULL;

        //Read the file one line at a time and create a linked list of the lines as structs
        char line[MAX_LINE_LENGTH];
        unsigned int pattern_counter = 0;
        //Read one line
        while(fgets(line, sizeof(line), pattern_file) != NULL)
        {
                //Check for empty line and skip
                if(line[0] != '\n')
                {
                        //This will only grab two values per line. This requires the file to be formatted correctly. 
                        //If the file is incorrectly formatted bad patterns of durations will be read. 
                        char *pattern = NULL; //Create pointer for the token used to parse file. 
                        char *duration = NULL;
                        pattern = strtok(line, " ");
                        duration = strtok(NULL, " ");

                        //Some nicely formatted debugging information
                        if(very_verbose)
                        {
                                pattern_counter++;
                                printf("\n\r-------------------------------------------------------------------\n\r");
                                printf("Pattern: %d\n\r", pattern_counter);
                                printf("\tLine: %s\n\r", line);
                                printf("\tpattern: %s\n\r", pattern);
                                printf("\tDuration: %s\n\r", duration);
                                printf("-------------------------------------------------------------------\n\r");
                        }

                        //Populate linked list
                        local_head = pattern_formatter(pattern, duration, local_head, very_verbose);
                }

        }       

        //Close file in this function!
        fclose(pattern_file);

        //Return head of the linked list
        return(local_head);
}
