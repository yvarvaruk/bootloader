AS = nasm
ASFLAGS = -Wall -fbin -O0

disk_image = disk.img

bootldr_main = boot/main.s
bootldr_srcs = $(wildcard boot/*.s)
bootldr_binary = boot.bin

hello_main = hello/main.s
hello_srcs = $(wildcard hello/*.s)
hello_binary = hello.bin

loaded_binary ?= $(hello_binary)

# Get file size in 512 byte blocks
# $(1) - filename
blocksize = $$((($(shell stat --printf='%s' $(1)) - 1) / 512 + 1))

all: $(disk_image)

$(disk_image): $(bootldr_binary) $(loaded_binary)
	dd if=/dev/zero of=$@ bs=512 count=$$(($(call blocksize,$(loaded_binary)) + 1))
	dd if=$(bootldr_binary) of=$@ count=1 conv=notrunc
	dd if=$(loaded_binary) of=$@ count=$(call blocksize,$(loaded_binary)) seek=1 conv=notrunc

$(hello_binary): $(hello_srcs)
	$(AS) $(ASFLAGS) -Ihello -o $@ $(hello_main)

$(bootldr_binary): $(loaded_binary) $(bootldr_srcs)
	$(AS) $(ASFLAGS) -Iboot -DEXECUTABLE_SIZE=$(call blocksize,$(loaded_binary)) -o $@ $(bootldr_main)

.PHONY: qemu qemu_debug
qemu: $(disk_image)
	qemu-system-i386 -drive format=raw,file=$< &
qemu_debug: $(disk_image)
	qemu-system-i386 -drive format=raw,file=$< -s -S & gdb --quiet

.PHONY: clean
clean:
	rm $(bootldr_binary) $(hello_binary) $(disk_image)
