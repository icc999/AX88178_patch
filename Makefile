# Makefile для out-of-tree сборки ASIX USB Ethernet (AX88178 и семейство)
# Проверено для сборки под headers: /usr/src/linux-headers-$(uname -r)

obj-m += asix.o

# Состав модуля asix.ko
# ВАЖНО: ax88172a.o нужен, иначе будет "ax88172a_info undefined"
# ax88179_178a.o можно подключать опционально (если ваш код/таблицы на него ссылаются)
asix-y := asix_common.o asix_devices.o ax88172a.o ax88179_178a.o

KDIR ?= /usr/src/linux-headers-$(shell uname -r)
PWD  := $(shell pwd)

# ----- build targets -----
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

# ----- install / uninstall -----
# Ставим модуль в /lib/modules/$(uname -r)/extra и обновляем зависимости
install: all
	sudo mkdir -p /lib/modules/$(shell uname -r)/extra
	sudo cp -v asix.ko /lib/modules/$(shell uname -r)/extra/
	sudo depmod -a

uninstall:
	sudo rm -f /lib/modules/$(shell uname -r)/extra/asix.ko
	sudo depmod -a

# ----- reload for testing -----
# Аккуратно перегрузить модуль (удобно для тестов)
reload: install
	- sudo modprobe -r asix
	sudo modprobe asix
	dmesg | tail -n 80

# ----- help -----
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
