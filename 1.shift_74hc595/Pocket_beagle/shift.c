
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <stdbool.h>


 /****************************************************************
 * global
 ****************************************************************/
	unsigned int data,clk,latch;
	unsigned int  registers[8];
    int data1,clk1,latch1;

 /****************************************************************
 * Constants
 ****************************************************************/

#define SYSFS_GPIO_DIR "/sys/class/gpio"
#define POLL_TIMEOUT (3 * 100) /* 3 seconds */
#define MAX_BUF 64

/****************************************************************
 * gpio_export
 ****************************************************************/
int gpio_export(unsigned int gpio)
{
	int fd, len;
	char buf[MAX_BUF];

	fd = open(SYSFS_GPIO_DIR "/export", O_WRONLY);
	if (fd < 0) {
		perror("gpio/export");
		return fd;
	}

	len = snprintf(buf, sizeof(buf), "%d", gpio);
	write(fd, buf, len);
	close(fd);

	return 0;
}

/****************************************************************
 * gpio_unexport
 ****************************************************************/
int gpio_unexport(unsigned int gpio)
{
	int fd, len;
	char buf[MAX_BUF];

	fd = open(SYSFS_GPIO_DIR "/unexport", O_WRONLY);
	if (fd < 0) {
		perror("gpio/export");
		return fd;
	}

	len = snprintf(buf, sizeof(buf), "%d", gpio);
	write(fd, buf, len);
	close(fd);
	return 0;
}

/****************************************************************
 * gpio_set_dir
 ****************************************************************/
int gpio_set_dir(unsigned int gpio, unsigned int out_flag)
{
	int fd, len;
	char buf[MAX_BUF];

	len = snprintf(buf, sizeof(buf), SYSFS_GPIO_DIR  "/gpio%d/direction", gpio);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		perror("gpio/direction");
		return fd;
	}

	if (out_flag){


		write(fd, "out", 4);
	    printf("out written");
	}
	else
		write(fd, "in", 3);

	close(fd);
	return 0;
}

/****************************************************************
 * gpio_set_value
 ****************************************************************/
int gpio_set_value(unsigned int gpio, unsigned int value)
{
	int fd, len;
	char buf[MAX_BUF];

	len = snprintf(buf, sizeof(buf), SYSFS_GPIO_DIR "/gpio%d/value", gpio);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		perror("gpio/set-value");
		return fd;
	}

	if (value)
		write(fd, "1", 2);
	else
		write(fd, "0", 2);

	close(fd);
	return 0;
}

/****************************************************************
 * gpio_get_value
 ****************************************************************/
int gpio_get_value(unsigned int gpio, unsigned int *value)
{
	int fd, len;
	char buf[MAX_BUF];
	char ch;

	len = snprintf(buf, sizeof(buf), SYSFS_GPIO_DIR "/gpio%d/value", gpio);

	fd = open(buf, O_RDONLY);
	if (fd < 0) {
		perror("gpio/get-value");
		return fd;
	}

	read(fd, &ch, 1);

	if (ch != '0') {
		*value = 1;
	} else {
		*value = 0;
	}

	close(fd);
	return 0;
}


/****************************************************************
 * gpio_set_edge
 ****************************************************************/

int gpio_set_edge(unsigned int gpio, char *edge)
{
	int fd, len;
	char buf[MAX_BUF];

	len = snprintf(buf, sizeof(buf), SYSFS_GPIO_DIR "/gpio%d/edge", gpio);

	fd = open(buf, O_WRONLY);
	if (fd < 0) {
		perror("gpio/set-edge");
		return fd;
	}

	write(fd, edge, strlen(edge) + 1);
	close(fd);
	return 0;
}

/****************************************************************
 * gpio_fd_open
 ****************************************************************/

int gpio_fd_open(unsigned int gpio)
{
	int fd, len;
	char buf[MAX_BUF];

	len = snprintf(buf, sizeof(buf), SYSFS_GPIO_DIR "/gpio%d/value", gpio);

	fd = open(buf, O_RDONLY | O_NONBLOCK );
	if (fd < 0) {
		perror("gpio/fd_open");
	}
	return fd;
}

/****************************************************************
 * gpio_fd_close
 ****************************************************************/

int gpio_fd_close(int gpio)
{
	return close(gpio);
}

/****************************************************************
 * writing register values
 ****************************************************************/
int write_reg()
{
	   perror("pass5");
	latch1 = gpio_fd_open(latch);
	gpio_set_value(latch,0);
	   perror("pass6");
    close(latch1);
    perror("pass7");

	for (int i=7;i>=0;i--)
	{
		clk1 = gpio_fd_open(clk);
		gpio_set_value(clk,0);
		close(clk1);
	    perror("pass8");

		data1 = gpio_fd_open(data);
		gpio_set_value(data,registers[i]);
		close(data1);
//		sleep(1);
	    perror("pass9");
		clk1 = gpio_fd_open(clk);
		gpio_set_value(clk,1);
		close(clk1);
	}
    latch1 = gpio_fd_open(latch);
	gpio_set_value(latch,1);
	close(latch1);
    perror("pass10");
	return 0;
}

/****************************************************************
 * Main
 ****************************************************************/
int main(int argc, char **argv, char **envp)
{
	struct pollfd fdset[2];
	int nfds = 2;
	int gpio_fd, timeout, rc;
	char *buf[MAX_BUF];
	int len;


	if (argc < 2) {
		printf("Usage: gpio-int <data-pin><clk-pin><latch-out-pin>\n\n");
		printf("Waits for a change in the GPIO pin voltage level or input on stdin\n");
		exit(-1);
	}

	data = atoi(argv[1]);
	clk = atoi(argv[2]);
	latch = atoi(argv[3]);

	timeout = POLL_TIMEOUT;
    perror("pass1");

	gpio_export(data);

	gpio_export(clk);

	gpio_export(latch);

	gpio_set_dir(data, 1);
	gpio_set_dir(clk, 1);
	gpio_set_dir(latch, 1);
	   perror("pass1");
	while (1) {
		for (int i = 0;i<8;i++)
		{
			registers[i] = 1;
		    perror("pass2");
			sleep(1);
	        perror("pass3");
			write_reg();
			   perror("pass4");
		}
		for (int i = 0;i<9;i++)
		{
			registers[i] = 0;
			sleep(1);
			write_reg();

		}
	}

	return 0;
}
