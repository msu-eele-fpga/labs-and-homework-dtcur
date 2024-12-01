ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
obj-m := hello.o

else 
# normal makefile

# Path to kernel directory
KDIR ?= /lib/modules/'uname -r/build

default: 
	$(make) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

endif
