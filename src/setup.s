%include "boot.inc"
%include "gdt.inc"

USE16
jmp SETUPSEG:_start

gdt_table_start:
    gdt_null:
        dd  0x00000000
        dd  0x00000000
    ;;-------------------------------------------------------------
    ; gdt_data_addr   equ $ - gdt_table_start
    ; gdt_data:
    ;     create_descriptor   SETUPSEG*16, 0x000fffff, GDT_DATA_PL0
    ; gdt_video_addr  equ $ - gdt_table_start
    ; gdt_video:
    ;     create_descriptor   VIDEOSEG*16, 0x000fffff, GDT_DATA_PL0
    ; gdt_code_addr   equ $ - gdt_table_start
    ; gdt_code:
    ;     create_descriptor   SETUPSEG*16, 0x000fffff, GDT_CODE_PL0
    ;;--------------------------------------------------------------
    gdt_sys_data_addr   equ $ - gdt_table_start
    gdt_sys_data:
        create_descriptor   0x00000000, 0x000fffff, GDT_DATA_PL0
    gdt_sys_code_addr   equ $ - gdt_table_start
    gdt_sys_code:
        create_descriptor   0x00000000, 0x000fffff, GDT_CODE_PL0
    gdt_usr_data_addr   equ $ - gdt_table_start
    gdt_usr_data:
        create_descriptor   0x00000000, 0x000c0000, GDT_DATA_PL3
    gdt_usr_code_addr   equ $ - gdt_table_start
    gdt_usr_code:
        create_descriptor   0x00000000, 0x000c0000, GDT_CODE_PL3

gdt_table_end:
gdt_addr:
    dw  gdt_table_end - gdt_table_start -1
    dd  gdt_table_start + (SETUPSEG << 4)
_start:
    ;xchg bx,bx
    mov ax,SETUPSEG
    mov ds,ax
    mov es,ax
    mov gs,ax
    
    pusha
    mov bl,0x0a
    mov dh,0x01
    mov dl,0
    mov bp,msg
    call print_cstr
    popa

    

_init_pm:
    load_gdt:
        cli
        lgdt [gdt_addr]
    enable_A20:
        mov dx,0x92
        in al,dx
        or al,0x02
        out dx,al
        cli
    enter_pmode:
        mov eax,cr0
        or eax,0x1
        mov cr0,eax
        
        jmp dword gdt_sys_code_addr:_pm_start + (SETUPSEG << 4)

;BL arrtibute
;CX length of String
;DH row coordinate
;DL column ciirdubate
;ES:BP pointer to String
print_cstr:
    .setup:
        push es
        push fs
        push gs
        mov ax,VIDEOSEG
        mov fs,ax
    .getlen:
        ._setup:
          mov ax,es
          mov gs,ax
          mov si,bp
        ._nextchar:
          cmp word [gs:si],'\0'
          je ._finished
          inc si
          jmp ._nextchar
        ._finished:
          sub si,bp
          mov cx,si
    .transform:
        mov ax,80
        mul dh
        xor dh,dh
        add ax,dx
        shl ax,1
        mov di,ax
    .putchar:
        mov al,[es:bp]
        mov ah,bl
        mov word [fs:di],ax
        inc bp
        add di,2
        loop .putchar
    .end:
        pop gs
        pop fs
        pop es
        ret
msg:    db  "We are in Setup.bin!\0"

USE32
_pm_start:
    ;xchg bx,bx
    mov ax,gdt_sys_data_addr
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax
    mov esp,0x9ff00

    pusha
    mov bx,0x0d
    mov dh,0x2
    mov dl,0x0
    mov esi,msg_mbr + (SETUPSEG << 4)
    xor cx,cx
    
    call print_cstr32
    popa
    
    jmp dword gdt_sys_code_addr:(SYSSEG << 4)
    
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

msg_mbr:    db "We are in Protected Mode!\0"