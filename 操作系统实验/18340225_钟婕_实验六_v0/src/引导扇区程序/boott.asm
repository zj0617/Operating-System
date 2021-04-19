org 7C00H
;将操作系统内核加载到偏移量8100h处
OffsetofOS equ 100H
SegofOS equ 1000H

;调用int 13h读扇区加载操作系统内核至内存相应位置
LoadOS:
    mov ax,SegofOS
	mov es,ax ;置es与cs相等，为段地址
	mov bx,OffsetofOS ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
	mov ah,02h ;功能号02h读扇区
	mov al,10   ;读入扇区数,操作系统内核的程序数据量大，不止占用一个扇区，因此就分配十个扇区给OS内核
	mov dl,0   ;驱动器号，软盘为0，U盘和硬盘位80h
	mov dh,0   ;磁头号为0
	mov ch,0   ;柱面号为0
	mov cl,2   ;起始扇区号
	int 13h    ;中断号
	jmp SegofOS:OffsetofOS ;操作系统内核已经加载到内存相应位置，要跳转到内存相应位置，将控制权交给内核
	jmp $
    
    times 510-($-$$) db 0
	dw 0xAA55
