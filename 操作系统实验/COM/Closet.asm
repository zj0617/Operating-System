org 100H


start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;文本窗口起始地址
	mov gs,ax

clear:
    mov ah,06h; 向上滚屏
	mov al,0h ;滚动行数（0-清窗口）
	mov ch,0 ;左上角X坐标
	mov cl,0 ;左上角Y坐标
	mov dh,24 ;右下角X坐标
	mov dl,79 ;右下角Y坐标
	mov bh,0x10;空白区域的显示属性：蓝底黑字，无闪烁无加亮
	int 10h ;BIOS功能调用

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax
   mov ss,ax

showInfo:
    ;调用int10h显示操作系统关机的相关提示信息
	inc word[count]
	mov ax,cs
	mov es,ax
    mov bp,Message;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0014h ;bh=00h为页码，bl=07h为显示属性：蓝底红字
	mov dx,0407h ;dh为行号，dl为列号,第8行，7列
	mov cx,MessageLength
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str0
	mov ax,1301h
	mov bx,001eh
	mov dx,0C13h
	mov cx,42
	int 10h
	jmp Judge


Judge:
    mov bx,4000
	mov ax,word[count]
	cmp ax,bx
	jz Quit
	jmp showInfo

Message:
    db "       *  *   *  *    ",0AH,0DH
    db "            *             *  ",0AH,0DH
	db "          *   ——    ——  *",0AH,0DH
	db " BYE!     *                 *",0AH,0DH
	db " BYE!     *                 *",0AH,0DH
	db "           *    \_____/    * ",0AH,0DH
	db "            *             *  ",0AH,0DH
	db "              *  *   *  *    ",0AH,0DH
	MessageLength equ ($-Message)
Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret

end:
    jmp $

datadef:	
	str0: db "Author:Zhong Jie & Student Number:18340225"
	count dw 0
