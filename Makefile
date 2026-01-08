# Имя модуля
obj-m += asix.o

# Из каких файлов состоит модуль
asix-y := asix_common.o asix_devices.o

# Путь к headers текущего ядра
KDIR := /usr/src/linux-headers-$(shell uname -r)
PWD  := $(shell pwd)

# Сборка
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

# Очистка
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
