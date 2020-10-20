AS = nasm
ASFLAGS = -Wall -fbin -O0

disk_image = disk.img

bootldr_main = boot/main.s
bootldr_srcs = $(wildcard boot/*.s)
bootldr_binary = boot.bin

hello_main = hello/main.s
hello_srcs = $(wildcard hello/*.s)
hello_binary = hello.bin

# Get file size in 512 byte blocks
# $(1) - filename
blocksize = $$((($(shell stat --printf='%s' $(1)) - 1) / 512 + 1))

all: $(disk_image)

$(disk_image): $(bootldr_binary) $(hello_binary)
	dd if=/dev/zero of=$(disk_image) bs=512 count=$$(($(call blocksize,$(hello_binary)) + 1))
	dd if=$(bootldr_binary) of=$(disk_image) count=1 conv=notrunc
	dd if=$(hello_binary) of=$(disk_image) count=$(call blocksize,$(hello_binary)) seek=1 conv=notrunc

$(hello_binary): $(hello_srcs)
	$(AS) $(ASFLAGS) -o $@ $(hello_main)

$(bootldr_binary): $(hello_binary) $(bootldr_srcs)
	$(AS) $(ASFLAGS) -Iboot -DEXECUTABLE_SIZE=$(call blocksize,$(hello_binary)) -o $@ $(bootldr_main)

.PHONY: qemu qemu_debug
qemu: $(disk_image)
	qemu-system-i386 -drive format=raw,file=$< &
qemu_debug: $(disk_image)
	qemu-system-i386 -drive format=raw,file=$< -s -S & gdb --quiet
