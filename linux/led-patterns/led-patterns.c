/*
 * EELE-467 Fall 2024 Montana State University
 * Drew currie Lab-11 12/3/2024
 * Published under the Gnu Public License.
 * Work derived from Trevor Venvoy Montana State University
 * and contributors to the Linux Kernel.
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/types.h>
#include <linux/fs.h>

// Memory offsets for the LED control registers
#define BASE_ADDRESS 0xFF200000u
#define HPS_LED_CONTROL_OFFSET 0x0u
#define BASE_PERIOD_OFFSET 0x4u
#define LED_REG_OFFSET 0x8u
#define SPAN 16

/**
 * struct led_patterns_dev - Private led patterns device struct.
 * @base_addr: Pointer to the component's base address
 * @hps_led_control: Address of the hps_led_control register
 * @base_period: Address of the base_period register
 * @led_reg: Address of the led_reg register
 *
 * An led_patterns_dev struct gets created for each led patterns component.
 */
struct led_patterns_dev
{
    void __iomem *base_addr;
    void __iomem *hps_led_control;
    void __iomem *base_period;
    void __iomem *led_reg;
    struct miscdevice miscdev;
    struct mutex lock;
};

/**
 * led_patterns_read() - Read method for the led_patterns char device
 * @file: Pointer to the char device file struct.
 * @buf: User-space buffer to read the value into.
 * @count: The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */

static ssize_t led_patterns_read(struct file *file, char __user *buf,
                                 size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;
    /*
     * Get the device's private data from the file struct's private_data
     * field. The private_data field is equal to the miscdev field in the
     * led_patterns_dev struct. container_of returns the
     * led_patterns_dev struct that contains the miscdev in private_data.
     */
    struct led_patterns_dev *priv = container_of(file->private_data,
                                                 struct led_patterns_dev, miscdev);
    // Check file offset to make sure we are reading from a valid location.
    if (*offset < 0)
    {
        // We can't read from a negative file position.
        return -EINVAL;
    }
    if (*offset >= SPAN)
    {
        // We can't read from a position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0)
    {
        // Prevent unaligned access.
        pr_warn("led_patterns_read: unaligned access\n");
        return -EFAULT;
    }
    val = ioread32(priv->base_addr + *offset);
    // Copy the value to userspace.
    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val))
    {
        pr_warn("led_patterns_read: nothing copied\n");
        return -EFAULT;
    }
    // Increment the file offset by the number of bytes we read.
    *offset = *offset + sizeof(val);
    return sizeof(val);
}

/**
* led_patterns_write() - Write method for the led_patterns char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value from.
* @count: The number of bytes being written.
* @offset: The byte offset in the file being written to.
*
 Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t led_patterns_write(struct file *file, const char __user *buf,
                                  size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;
    struct led_patterns_dev *priv = container_of(file->private_data,
                                                 struct led_patterns_dev, miscdev);
    if (*offset < 0)
    {
        return -EINVAL;
    }
    if (*offset >= SPAN)
    {
        return 0;
    }
    if ((*offset % 0x4) != 0)
    {
        pr_warn("led_patterns_write: unaligned access\n");
        return -EFAULT;
    }
    mutex_lock(&priv->lock);
    // Get the value from userspace.
    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val))
    {
        iowrite32(val, priv->base_addr + *offset);
        // Increment the file offset by the number of bytes we wrote.
        *offset = *offset + sizeof(val);
        // Return the number of bytes we wrote.
        ret = sizeof(val);
    }
    else
    {
        pr_warn("led_patterns_write: nothing copied from user space\n");
        ret = -EFAULT;
    }
    mutex_unlock(&priv->lock);
    return ret;
}

/**
 * led_patterns_fops - File operations supported by the
 * led_patterns driver
 * @owner: The led_patterns driver owns the file operations; this
 * ensures that the driver can't be removed while the
 * character device is still in use.
 * @read: The read function.
 * @write: The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows
 * users to change what position they are writing/reading to/from.
 */

static const struct file_operations led_patterns_fops = {
    .owner = THIS_MODULE,
    .read = led_patterns_read,
    .write = led_patterns_write,
    .llseek = default_llseek,
};

/**
 * led_patterns_probe() - Initialize device when a match is found
 * @pdev: Platform device structure associated with our led patterns device;
 * pdev is automatically created by the driver core based upon our
 * led patterns device tree node.
 *
 * When a device that is compatible with this led patterns driver is found, the
 * driver's probe function is called. This probe function gets called by the
 * kernel when an led_patterns device is found in the device tree.
 */

static int led_patterns_probe(struct platform_device *pdev)
{
    size_t ret;
    struct led_patterns_dev *priv;
    /*
     * Allocate kernel memory for the led patterns device and set it to 0.
     * GFP_KERNEL specifies that we are allocating normal kernel RAM;
     * see the kmalloc documentation for more info. The allocated memory
     * is automatically freed when the device is removed.
     */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct led_patterns_dev),
                        GFP_KERNEL);
    if (!priv)
    {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }
    /*
     * Request and remap the device's memory region. Requesting the region
     * make sure nobody else can use that memory. The memory is remapped
     * into the kernel's virtual address space because we don't have access
     * to physical memory locations.
     */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr))
    {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }
    // Set the memory addresses for each register.
    priv->hps_led_control = priv->base_addr + HPS_LED_CONTROL_OFFSET;
    priv->base_period = priv->base_addr + BASE_PERIOD_OFFSET;
    priv->led_reg = priv->base_addr + LED_REG_OFFSET;

    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "led_patterns";
    priv->miscdev.fops = &led_patterns_fops;
    priv->miscdev.parent = &pdev->dev;

    // Register the misc device; this creates a char dev at /dev/led_patterns
    ret = misc_register(&priv->miscdev);
    if (ret)
    {
        pr_err("Failed to register misc device");
        return ret;
    }
    // Enable software-control mode and turn all the LEDs on, just for fun.
    iowrite32(1, priv->hps_led_control);
    iowrite32(0xff, priv->led_reg);
    iowrite32(0xFF, priv->base_period);
    /* Attach the led patterns's private data to the platform device's struct.
     * This is so we can access our state container in the other functions.
     */
    platform_set_drvdata(pdev, priv);
    pr_info("led_patterns_probe successful\n");
    return (0);
}
/**
 * led_patterns_probe() - Remove an led patterns device.
 * @pdev: Platform device structure associated with our led patterns device.
 *
 * This function is called when an led patterns devicee is removed or
 * the driver is removed.
 */
static int led_patterns_remove(struct platform_device *pdev)
{
    // Get the led patterns's private data from the platform device.
    struct led_patterns_dev *priv = platform_get_drvdata(pdev);

    // Disable software-control mode, just for kicks.
    iowrite32(0, priv->hps_led_control);
    misc_deregister(&priv->miscdev);
    pr_info("led_patterns_remove successful\n");

    return 0;
}

/*
 * Define the compatible property used for matching devices to this driver,
 * then add our device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same
 * compatible string as defined here.
 */

static const struct of_device_id led_patterns_of_match[] = {
    {
        .compatible = "currie,led_patterns",
    },
    {}};
MODULE_DEVICE_TABLE(of, led_patterns_of_match);

/*
 * struct led_patterns_driver - Platform driver struct for the led_patterns driver
 * @probe: Function that's called when a device is found
 * @remove: Function that's called when a device is removed
 * @driver.owner: Which module owns this driver
 * @driver.name: Name of the led_patterns driver
 * @driver.of_match_table: Device tree match table
 */

static struct platform_driver led_patterns_driver = {
    .probe = led_patterns_probe,
    .remove = led_patterns_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "led_patterns",
        .of_match_table = led_patterns_of_match,
    },
};

module_platform_driver(led_patterns_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Drew Currie");
MODULE_DESCRIPTION("led_patterns driver");