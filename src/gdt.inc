%define SEG_DESCTYPE(x)  ((x) << 0x04) ;; Descriptor type (0 for system, 1 for code/data)
%define SEG_PRES(x)      ((x) << 0x07) ;; Present
%define SEG_SAVL(x)      ((x) << 0x0C) ;; Available for system use
%define SEG_LONG(x)      ((x) << 0x0D) ;; Long mode
%define SEG_SIZE(x)      ((x) << 0x0E) ;; Size (0 for 16-bit, 1 for 32)
%define SEG_GRAN(x)      ((x) << 0x10) ;; Granularity (0 for 1B - 1MB, 1 for 4KB - 4GB)
%define SEG_PRIV(x)     (((x) &  0x03) << 0x05)   ;; Set privilege level (0 - 3)

%define SEG_DATA_RD        0x00 ;; Read-Only
%define SEG_DATA_RDA       0x01 ;; Read-Only, accessed
%define SEG_DATA_RDWR      0x02 ;; Read/Write
%define SEG_DATA_RDWRA     0x03 ;; Read/Write, accessed
%define SEG_DATA_RDEXPD    0x04 ;; Read-Only, expand-down
%define SEG_DATA_RDEXPDA   0x05 ;; Read-Only, expand-down, accessed
%define SEG_DATA_RDWREXPD  0x06 ;; Read/Write, expand-down
%define SEG_DATA_RDWREXPDA 0x07 ;; Read/Wite, expand-down, accessed
%define SEG_CODE_EX        0x08 ;; Execute-Only
%define SEG_CODE_EXA       0x09 ;; Execute-Only, accessed
%define SEG_CODE_EXRD      0x0A ;; Execute/Read
%define SEG_CODE_EXRDA     0x0B ;; Execute/Read, accessed
%define SEG_CODE_EXC       0x0C ;; Execute-Only, conforming
%define SEG_CODE_EXCA      0x0D ;; Execute-Only, conforming, accessed
%define SEG_CODE_EXRDC     0x0E ;; Execute/Read, conforming
%define SEG_CODE_EXRDCA    0x0F ;; Execute/Read, conforming, accessed

%define GDT_CODE_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_CODE_EXRD

%define GDT_DATA_PL0 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(0)     | SEG_DATA_RDWR

%define GDT_CODE_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_CODE_EXRD

%define GDT_DATA_PL3 SEG_DESCTYPE(1) | SEG_PRES(1) | SEG_SAVL(0) | \
                     SEG_LONG(0)     | SEG_SIZE(1) | SEG_GRAN(1) | \
                     SEG_PRIV(3)     | SEG_DATA_RDWR

struc   descriptor
    ;descriptor_low32:
        .limit_low16    resw    1
        .base_low16     resw    1
    ;descriptor_high32:
        .base_mid8:     resb    1
        .flag:          resw    1
        .base_high8     resb    1
endstruc

%macro create_descriptor   3
    istruc  descriptor
        at descriptor.limit_low16,            dw  %2 & 0x0000ffff
        at descriptor.base_low16,             dw  %1 & 0x0000ffff
        at descriptor.base_mid8,              db  (%1 >> 16) & 0x00ff
        at descriptor.flag,                   dw  ((%2 >> 8) & 0x0f00) | (%3 & 0xf0ff)
        at descriptor.base_high8,             db  (%1 >> 24) & 0xff
    iend
%endmacro

%define SEG_SEL_RPL(x)      ((x) & 0x03)
%define SEG_SEL_TI(x)       (((x) & 0x1) << 2)
%define SEG_SEL_INDEX(x)    (((x) & 0x1fff) << 3)
%define SEG_SEL_INDEX_GEN(x,y)  (((x) - (y)) / 8)
%define SEG_SEL_GEN(x,y)    ((x) | (y))

%define SEG_SEL_GDT_RPL0 SEG_SEL_TI(0) | SEG_SEL_RPL(0)
%define SEG_SEL_GDT_RPL3 SEG_SEL_TI(0) | SEG_SEL_RPL(3) 


;%define SEG_SEL_GDT_RPL0 SEG_SEL_RPL(0) | SEG_SEL_TI(0)

;%define SEG_SEL_TI_GDT  0x0
;%define SEG_SEL_TI_LDT  0x1

;%define SEG_SEL_INDEX_GEN(gdt_entry,desc_addr)  ((desc_addr - gdt_entry) / 8)
;%define SEG_SEL_FALG_GEN(RPL,TI)    TI|RPL

;%define gen_selector(index,sel_flag)    index|sel_flag
;%define SEG_SEL_GEN(index,flag) index | flag

