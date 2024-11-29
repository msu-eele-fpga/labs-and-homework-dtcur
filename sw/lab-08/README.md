# <p style="text-align: center;">LED Pattern Display (LPD)</p>

<h3><p style="text-align: center;"> A way to connect to the LED bank on the de10nano SoC FPGA through the Linux system </p></h3>

LPD is a means to control the FPGA LED bank through the Avalon Memory Interface bus. This allows for a user to provide patterns to be displayed on the LED bank without requiring manual toggling of physical switches. Patterns can be provided in a formatted file or through the command line.


## Command-line options:
Command line arguments follow GNU long standards.

Mandatory arguments to long options are mandatory for short options too.
|Input                       |Response  |
|:---------------------------|:---------|
| **-h, --help:**            | Display usage text and exit|
| **-v, --verbose:**         | Display what LED pattern is being displayed as a hex string and display duration as a decimal number in milliseconds|
|**--veryverbose:**          |Display all debugging information, also sets verbose flag|
|**-p, --pattern PATTERN DURATION:** |MUST BE LAST ARGUMENT Displays the provided pattern for the provided duration. Multiple pattern and duration pairs can be provided.|
|**-f, --file FILE.txt:**   |MUST BE LAST ARGUMENT Displays the patterns for the provided duration in the pattern file.|
> [!NOTE] File and Pattern usage:
> Both file and pattern flags cannot be set at the same time.<br> 
> If a file is not properly formatted, the patterns will not display correctly. <br>
> Blank lines are OK in the file.<br>
> If using pattern, an equal number of patterns and durations must be provided <br>
> Each pattern must be followed by a duration for use.<br>

## Example usage:

./led-patterns -f testPatterns.txt

<details>
        <summary>verbose and pattern input:</summary>

        ```sh
                #./led-patterns -v --pattern 0xF0 1000 0x0F 500
                -------------------------------------------------------------------
                Values being written:                                                                                                                                                                                             
                        Control: 0x0001 (bool)
                        Pattern: 0x000f 
                        Duration: 500 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x00f0 
                        Duration: 1000 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x000f 
                        Duration: 500 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x00f0 
                        Duration: 1000 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x000f 
                        Duration: 500 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x00f0 
                        Duration: 1000 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x000f 
                        Duration: 500 ms
                -------------------------------------------------------------------
                -------------------------------------------------------------------
                Values being written:
                        Control: 0x0001 (bool)
                        Pattern: 0x00f0 
                        Duration: 1000 ms
                -------------------------------------------------------------------
        ```
</details>


## Building 
Clone the lab-08 directory and run make.<br>
Running make from the root of the lab-08 directory will build the project.<br>
This project uses the arm-linux-gnueabihf-gcc compiler to cross compile for ARM architecture. 
If building on an ARM computer, use the normal GCC compiler. 

the makefile has two options for build locations:
```makefile
#Directory from a virtual machine
EXE := /srv/nfs/de10nano/ubuntu-rootfs/home/soc/labs/lab-08/led-patterns
#Alternative build location
#EXE := bin/led-patterns
```

If building from the Ubuntu Virtual Machine as setup for EELE-467 SoC FPGA's I at Montana State University Fall 2024, the server directory can be used to automatically move the binary to the SOC. However, if not using this configuration change to the ```makefile EXE := bin/led-patterns``` and manually move the binary to the desired locations.



## Register map and interface for the LED-Patterns. 

### Usage disclaimer
This project depends on the included raw binary file. (led-patterns.rbf) this must be put on the FPGA fabric before use. This RBF lays out the register maps and defines how the hardware to process inputs from the software. 


### Register map
The base address of the avalon memory interface is 0XFF200000. This base address is used to determine the control of the LED bank. A 0 gives the FPGA fabric control of the LEDs while a value of 1 gives the software control of the LEDs. <br>

<br><br>
The LED control register takes in a single bit to enable control of the LED bank from Software. Setting this bit to a 1 enables the control of the LED bank in software. The physical address of this register is 0XFF200000
<p align="center">
        <img src="Resources/LEDControlRegister.svg">
</p>

<br><br>
The LED pattern register takes in 8 bits corresponding to the pattern to display on the LED bank. This requires software control of the LED bank. The physical address of this register is 0XFF200004
<p align="center">
        <img src="Resources/LEDPatternRegister.svg">
</p>

<br><br>
Although a duration register is provided in the RBF, the time for displaying patterns is handled through software delays. The duration register is not used in this program. 