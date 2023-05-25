PAGE_SIZE   equ 0x1000  ;4096
ENTRY_SIZE  equ 4
ENTRY_COUNTS    equ 0x400   ;1024
PDE_BASE    equ 0xC0300000  ; 页目录表的地址
PDE_SELF_REFERENCE  equ 0x300        ; 使用第768个表项作为自映射项

%define PG_PRESENT(x)          (x) << 0     ; 页表项的 Present 标志
%define PG_READ_WRITE(x)       (x) << 1     ; 页表项的 Read/Write 标志
%define PG_USER(x)             (x) << 2     ; 页表项的 User/Supervisor 标志
%define PG_WRITETHROUGH(x)     (x) << 3     ; 页表项的 Write-Through 标志
%define PG_CACHE_DISABLE(x)    (x) << 4     ; 页表项的 Cache-Disable 标志
%define PG_ACCESSED(x)         (x) << 5     ; 页表项的 Accessed 标志
%define PG_DIRTY(x)            (x) << 6     ; 页表项的 Dirty 标志
%define PG_SIZE_4MB(x)             (x) << 7     ; 页表项的 Page Size 标志

%define KERNEL_PAGE_FLAGS   (PG_PRESENT(1) | PG_READ_WRITE(1) | PG_SIZE_4MB(0))

%define PTE_BASE            0xFFC00000   ; 页表的地址，紧随在页目录后面
%define PTE_SELF_REFERENCE  (PDE_SELF_REFERENCE * 1024 + PTE_BASE >> 12)
                                        ; 自映射表项的页表项

; 宏定义一个用于填充页表项的宏
%macro FILL_PTE 2
    mov eax, %2
    or eax, %1
    mov [ebx], eax
%endmacro

; 宏定义一个用于填充页目录项的宏
%macro FILL_PDE 2
    mov eax, %2
    or eax, %1
    mov [ecx], eax
%endmacro