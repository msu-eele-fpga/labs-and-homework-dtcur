ifneq ($(KERNELRELEASE),)

# kbuild part of makefile

obj-m := hello.o

else

# normal makefile

#Path to kernel directory

KDIR ?= /home/drew/Documents/EELE-467/EELE467-Repo/linux/linux-socfpga

default:
	$(MAKE) -C $(KDIR) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

endif
