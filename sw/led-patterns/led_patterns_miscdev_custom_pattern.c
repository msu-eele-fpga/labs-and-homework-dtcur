#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

// TODO: update these offsets if your address are different
#define HPS_LED_CONTROL_OFFSET 0x0
#define BASE_PERIOD_OFFSET 0x4
#define LED_REG_OFFSET 0x08

// Signal handling
void sigint_Handler(int);

int main()
{

	// Signal handling
	signal(SIGINT, sigint_Handler);

	// Custom pattern array
	uint8_t pattern_array[] = {0x81, 0x42, 0x24, 0x18, 0x00, 0x18, 0x24, 0x42, 0x81};
	FILE *file;
	size_t ret;
	uint32_t val;

	file = fopen("/dev/led_patterns", "rb+");
	if (file == NULL)
	{
		printf("failed to open file\n");
		exit(1);
	}

	// Test reading the registers sequentially
	printf("\n************************************\n*");
	printf("* read initial register values\n");
	printf("************************************\n\n");

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("base period = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);

	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);
	printf("fseek ret = %d\n", ret);
	printf("errno =%s\n", strerror(errno));

	printf("\n************************************\n*");
	printf("* write values\n");
	printf("************************************\n\n");
	// Turn on software-control mode
	val = 0x01;
	ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	// We need to "flush" so the OS finishes writing to the file before our code continues.
	fflush(file);

	// Write some values to the LEDs
	printf("writing custom pattern to LEDs....\n");
	printf("\tOperating in infinite loop\n");
	while (1)
	{
		for (uint8_t pattern_tracker = 0;
		     pattern_tracker < sizeof(pattern_array) / sizeof(pattern_array[0]);
		     pattern_tracker++)
		{
			// Assign val and write to the file
			val = pattern_array[pattern_tracker];
			ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
			ret = fwrite(&val, 4, 1, file);
			fflush(file);
			// Sleep for 1 second so the pattern is visible
			sleep(1);
		}
	}

	return 1;
}

//---------- Ctrl-c input handler -------------------------------------
void sigint_Handler(int sig)
{
	// Duplicate variables into a local
	size_t ret;
	uint32_t val;
	FILE *file;

	file = fopen("/dev/led_patterns", "rb+");
	if (file == NULL)
	{
		printf("failed to open file\n");
		exit(1);
	}

	signal(SIGINT, sigint_Handler);
	printf("\n\n\rSystem exiting... Reverting control to FPGA fabric... \n\r");
	val = 0x1F;
	ret = fseek(file, BASE_PERIOD_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);

	// Turn on hardware-control mode
	val = 0x00;
	ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
	fflush(file);
	fclose(file);
	exit(0);
}