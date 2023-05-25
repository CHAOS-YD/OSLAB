.PHONY:build burn clean

mbr_source = bootsect.s
mbr_target = bootsect.bin

loader_source = setup.s
loader_target = setup.bin

head_source = head.s
head_target = head.bin

hard_disk = ../bochs/bin/hd60M.img

build:
	nasm $(mbr_source) -o $(mbr_target) 
	nasm $(loader_source) -o $(loader_target)
	nasm $(head_source) -o $(head_target)
	
burn:
	dd if=$(mbr_target) of=$(hard_disk) bs=512 count=1 conv=notrunc
	dd if=$(loader_target) of=$(hard_disk) bs=512 count=4 seek=1 conv=notrunc
	dd if=$(head_target) of=$(hard_disk) bs=512 count=6 seek=5 conv=notrunc