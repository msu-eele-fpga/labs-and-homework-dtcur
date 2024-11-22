#include "led-patterns.h" // Include header file because I forget to do this all the time

//Constructor 
struct led_pattern* pattern_formatter(char *pattern_input, char *duration_input)
{
        //Take string of pattern and time in as an input and convert to an unsigned long int
        printf("now mapping struct \n\r");
        printf("Pattern: %s Duration %s\n\r", pattern_input, duration_input);
        fflush(stdout);
        //Construct the struct
        struct led_pattern *pattern = (struct led_pattern*)malloc(sizeof(led_pattern));
        //Check for failed pointer creation
        if(!pattern)
        {
                return(NULL);
        }
        //Set values
        pattern->pattern = strtoul(pattern_input, NULL, 16);
        pattern->duration=strtoul(duration_input, NULL, 10);
        return(pattern);
}

/*
* This function is heavily based on the work of Trevor Vannoy 
* written for EELE-467 SoC FPGAs at Montana State University Fall 2024
* Code written by Drew Currie
*/
int display_pattern(led_pattern pattern, bool verbose)
{
                //Display the pattern provided in the struct on the LED bank
                
                //Calculate memory size of the system 
                const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
                if(verbose)
                {
                        printf("Memory size calculated to %d\n\r", PAGE_SIZE);
                }
                //Assume always in write mode to the avalon buffer for the patterns
                /*
                * Open memory location of the avalon bus
                * Use synchronous write and open with read and write access
                */
                int fd = open("/dev/mem", O_RDWR | O_SYNC);
                if(fd == -1)
                {
                        if(verbose){
                                printf("Unable to open /dev/mem. Are you able to access the hardware?\n\r");
                                printf("System will now exit on a failed open\n\r");
                        }
                        fprintf(stderr, "Unable to open /dev/mem \n\r");
                        exit(1);
                }

                uint32_t page_aligned_addr = BASE_ADDRESS & ~(PAGE_SIZE -1);
                if(verbose)
                {
                        printf("memory addresses: \n\r");
                        printf("-------------------------------------------------------------------\n\r");
                        printf("\tpage aligned address = 0x%x\n\r", page_aligned_addr);

                }

                /*
                * Calculate the map of the physical memory desired to the virtual memory
                * Done with mmap
                */

        uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
        if(page_virtual_addr == MAP_FAILED)
        {
                        if(verbose){
                                printf("Unable to map physical memory to virtual memory.\n\r");
                                printf("System will now exit, check the BASE_ADDRESS offset in the led-patterns.h file\n\r");

                        }
                        fprintf(stderr, "Failed to map memory \n\r");
                        exit(1);
        }
        if(verbose)
        {
                        printf("\tpage_virtual_addr = %p\n\r", page_virtual_addr);
        }
        
        /*
        * Calculate virtual address related to the required offset
        * This may not be page aligned and as such needs to made 
        * in reference to the page boundary
        */
        uint32_t offset_in_page = BASE_ADDRESS & (PAGE_SIZE - 1);
        if(verbose)
        {
                printf("\tOffset in page = 0x%x\n\r", offset_in_page);
        }

        volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);
        if(verbose)
        {
                printf("\ttarget_virtual_addr = %p\n\r", target_virtual_addr);
                printf("-------------------------------------------------------------------\n\r");
        }

        const uint32_t write_value = pattern.pattern;
        *target_virtual_addr = write_value;

        return(0);

}