%include "boot.inc"
%include "hd.inc"

jmp BOOTSEG:_start

_start:
    ;xchg bx,bx  ;;magic break point

    mov ax,BOOTSEG
    mov ds,ax
    mov ax,INITSEG
    mov es,ax
    mov cx,256
    xor si,si
    xor di,di
    rep movsw
    jmp INITSEG:go
go:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0xff00

    call clear_screen

    pusha 
    mov dl,0
    mov dh,0
    mov bx,0x0B
    mov bp,message
    call print_cstr
    popa
    
    pusha
    mov ax,SETUPSTART_LBA
    mov bx,SETUPOFFSET
    mov bp,SETUPSTART_LBA >> 16
    mov cx,SETUPSIZE
    call read_it
    popa

    mov ax,SYSSEG
    mov ds,ax
    mov es,ax

    mov ax,SYSSEGSTART_LBA
    mov bx,0
    mov bp,SYSSEGSTART_LBA >> 16
    mov cx,SYSSIZE
    call read_it

    jmp SETUPSEG:0
    
clear_screen:
    .setup:
        push es
        mov ax,VIDEOSEG
        mov es,ax
        mov ah,0x00
        mov al,''
        mov cx,2000
    .start_blank:
        mov bx,cx
        dec bx
        shl bx,1
        mov [es:bx],ax
        loop .start_blank
    .end:
        pop es
        ret

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
        

read_it:
    .backup:
        mov si,ax
        mov di,cx
    .set_sector_conunts:
        mov al,cl
        mov dx,SECTOR_COUNT_PORT
        out dx,al
        mov ax,si
    .set_lba_addr:
        mov dx,LBA_LOW_PROT
        out dx,al

        mov cl,8
        shr ax,cl
        mov dx,LBA_MID_PORT
        out dx,al

        mov ax,bp
        mov dx,LBA_HIGH_PORT
        out dx,al

        shr ax,cl
        and al,0x0f
        or al,0xe0
        mov dx,DEVICE_PORT
        out dx,al
    .set_read:
        mov al,0x20
        mov dx,COMMAND_PORT
        out dx,al
    .not_ready:
        nop
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz .not_ready
    .setup_read:
        mov ax,di
        mov cx,256
        mul cx
        mov cx,ax

        mov dx,DATA_PORT
    .go_on_read:
    ;xchg bx,bx
        in ax,dx
        mov [bx],ax
        add bx,2
        loop .go_on_read
        ret

message:    db  "Hello,World!\0"
times 510 - ($-$$)  db 0
boot_flag:  dw 0xAA55