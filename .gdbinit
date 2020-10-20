set architecture i8086
set disassembly-flavor intel
set disassemble-next-line on
target remote localhost:1234
b *0x7C00
b *0x7E00