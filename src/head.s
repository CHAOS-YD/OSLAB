%include "boot.inc"
%include "page.inc"
org (SYSSEG << 4)
USE32
_start:
    pusha
    xchg bx,bx
    xor cx,cx
    mov bl,0x0e
    mov dh,0x3
    mov dl,0x0
    mov esi,msg_head
    
    call print_cstr32
    popa
_setup_page:
    
    mov ecx,ENTRY_COUNTS
    xor eax,eax
    mov edi,page_dir
    cld
    rep stosw
.set_pt_self_ref:
    mov eax,page_dir + KERNEL_PAGE_FLAGS
    mov ebx,page_dir + (PDE_SELF_REFERENCE * ENTRY_SIZE)
    mov [ebx],eax
.set_page_32mb:
    
    mov ecx,ENTRY_COUNTS * 8
    xor eax,eax
    mov edi,page_tbl
    cld
    rep stosd
    
    ;xchg bx,bx
    
    mov dword [page_dir + (0 * ENTRY_SIZE)],page_tbl + (0 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (1 * ENTRY_SIZE)],page_tbl + (1 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (2 * ENTRY_SIZE)],page_tbl + (2 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (3 * ENTRY_SIZE)],page_tbl + (3 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (4 * ENTRY_SIZE)],page_tbl + (4 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (5 * ENTRY_SIZE)],page_tbl + (5 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (6 * ENTRY_SIZE)],page_tbl + (6 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    mov dword [page_dir + (7 * ENTRY_SIZE)],page_tbl + (7 * PAGE_SIZE) + KERNEL_PAGE_FLAGS
    
    mov edi,page_tbl + (7 * PAGE_SIZE) + 4092
    mov eax,0x1fff000 + USER_PAGE_FLAGS   ;32MB - 4KB
    std
l:  stosd
    sub eax,PAGE_SIZE
    jge l
    
.set_pdir:
    mov eax,page_dir
    and eax,0xfffff000
    mov cr3,eax
.enable_paging:    
    mov eax,cr0
    or eax,0x80000000
    mov cr0,eax

    
    jmp $


;BL arrtibute
;CX length of String
;DH row coordinate
;DL column ciirdubate
;DS:SI pointer to String
;ES:DI  pointer to write
print_cstr32:
    .get_len:
        ._backup:
            mov eax,esi
            mov ecx,esi
        ._nextchar:
            cmp word [ds:esi],'\0'
            je ._finished
            inc esi
            jmp ._nextchar
        ._finished:
            sub esi,ecx
            mov ecx,esi
        ._restore:
            mov esi,eax
            xor eax,eax
    .transform:
        mov ax,80
        mul dh
        xor dh,dh
        add ax,dx
        shl ax,1
        mov di,ax
        add edi,VIDEOSEG << 4
    .putchar:
        mov al,[ds:esi]
        mov ah,bl
        mov word [es:edi],ax
        inc esi
        add edi,2
        loop .putchar
    .end:
        ret

msg_head:    db "We are in head.bin!\0"

align (ENTRY_COUNTS * ENTRY_SIZE)
page_dir:   resb ENTRY_COUNTS * ENTRY_SIZE
page_tbl:   resb PAGE_SIZE * 8