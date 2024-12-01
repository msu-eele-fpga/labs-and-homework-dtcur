# Lab 10 Device Trees

## Overview
In this lab, the device tree for the LED-hps0 was updated to match new standards and the linux kernel was modified to support the heartbeat trigger for LEDs. This was a change on compile of the kernel.

The basic functionality of creating a heartbeat LED that will flash twice and then increase flashing rate during more intensive use was achieved. 

### Questions 

> What is the purpose of a device tree?
The device tree creates an easily replicable and scalable solution for connecting to unique devices through the linux environment. despite being a bit difficult to learn up front, the benefit of standardized code that is easy to contribute to and work with out weights the learning curve. 