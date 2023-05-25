%include "boot.inc"
%include "page.inc"
USE32
_start:
    pusha
    xchg bx,bx
    xor cx,cx
    mov bl,0x0e
    mov dh,0x3
    mov dl,0x0
    mov esi,msg_head + (SYSSEG << 4)
    
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
    xchg bx,bx
    mov ecx,ENTRY_COUNTS * 8
    xor eax,eax
    mov edi,page_tbl
    cld
    rep stosw

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