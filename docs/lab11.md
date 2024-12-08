# lab 11 Platform Device Driver

## Overview
A device tree and driver were created to control the LEDs from user space. This provides a layer of translation through the kernel and into the hardware. 


### Questions 
> What is the purpose of the platform bus<br>
> The platform bus allows for connection between the processor and the hardware peripherals without the need for hard coding physical addresses. 

> Why is the device driver's compatible property important?<br>
> This is important as it links the driver with compatible devices. IE you wouldn't want a video driver controlling our LED banks. 

> What is the probe function's purpose?<br>
> Probe is the initialization functionality, this initializes devices and helps connect them appropriately with all the other information needed for proper function.

> How does your driver know what memory addresses are associated with your device?<br>
> This is brought through the device tree to know the physical addresses and then into virtual memory in teh kernel. 

>What are the two ways we can write to our device's registers? In other words, what subsystems do we use to write to our registers?<br>
>This can be done through the character buffer or through directly accessing the memory in C.

> What is the purpose of our ```struct led_patterns_dev``` state container?<br>
>This holds the basic memory addressing for the registers and provides an access point to the kernel to provide a path to these memory addresses. This also includes other useful device information such as the mutex lock and miscdev classification. 

