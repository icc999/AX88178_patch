# Makefile для out-of-tree сборки ASIX USB Ethernet (AX88178)
# Сборка под headers текущего ядра: /usr/src/linux-headers-$(uname -r)

obj-m += asix.o

# ВАЖНО:
# - ax88172a.o нужен, иначе будет "ax88172a_info undefined"
# - ax88179_178a.o НЕЛЬЗЯ линковать сюда, т.к. он отдельный модуль со своим init/exit и usb_device_table
asix-y := asix_common.o asix_devices.o ax88172a.o

KDIR ?= /usr/src/linux-headers-$(shell uname -r)
PWD  := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install: all
	sudo mkdir -p /lib/modules/$(shell uname -r)/extra
	sudo cp -v asix.ko /lib/modules/$(shell uname -r)/extra/
	sudo depmod -a

uninstall:
	sudo rm -f /lib/modules/$(shell uname -r)/extra/asix.ko
	sudo depmod -a

reload: install
	- sudo modprobe -r asix
	sudo modprobe asix
	dmesg | tail -n 80

help:
	@echo "Targets:"
	@echo "  make            - build asix.ko"
	@echo "  make clean      - clean build artifacts"
	@echo "  make install    - install asix.ko to /lib/modules/<ver>/extra + depmod"
	@echo "  make reload     - install + reload module + show last dmesg"
	@echo "  make uninstall  - remove installed module from extra + depmod"
	@echo ""
	@echo "Vars:"
	@echo "  KDIR=/path/to/headers  (default: /usr/src/linux-headers-\`uname -r\`)"
