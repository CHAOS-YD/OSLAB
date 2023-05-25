BOOTSEG     equ 0x07c0
VIDEOSEG    equ 0xb800
INITSEG     equ 0x9000
SETUPSEG    equ 0x9020
SYSSEG      equ 0x1000

SETUPSTART_LBA  equ 0x0001  ;Start at the 2nd sector.
SETUPSIZE   equ 0x0004  ;Size of setup.bin is 2kb,4 sectors.
SETUPOFFSET equ 0x0200  ;Offset of setup.bin from INITSEG.
SETUPLOADADDR   equ 0x90200 
SYSSEGSTART_LBA equ 0x0005  ;Start at the 6th sector.
SYSSIZE equ 0x0006