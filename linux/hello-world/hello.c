#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_AUTHOR("Drew Currie");

MODULE_DESCRIPTION("EELE-467 HW-8 Hello World LKM");

//These are required for some reason
MODULE_LICENSE("GPL");

MODULE_VERSION("1.0");

static int __init print_hello(void)
{
	printk(KERN_INFO "Hello world\n\r");
	return(0);
}


static void __exit print_goodbye(void)
{
	printk(KERN_INFO "Goodbye, cruel world");
}


module_init(print_hello);
module_exit(print_goodbye);
