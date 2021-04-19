org 0100H

start:
    mov ax,cs ;置其他寄存器与cs相同
	mov ds,ax
	mov ax,ds
	mov es,ax

;显示相关提示
clear:
     ;使用int10h的向上滚屏即清窗口功能
    mov ah,06h ;入口参数，功能号：ah=06h-向上滚屏，ah=07h-向下滚屏
    mov al,0h ;滚动行数（0-清窗口）
    mov ch,0 ;窗口的左上角位置（x坐标）
    mov cl,0 ;窗口的左上角位置（y坐标）
    mov dh,24 ;窗口的右下角位置（x坐标）
    mov dl,79 ;窗口的右下角位置（y坐标）
    mov bh,7 ;空白区域的缺省属性
    int 10h ;中断号

showInfo:
	;调用int10h显示操作系统启动的相关提示信息
    mov bp,Message;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0007h ;bh=00h为页码，bl=07h为显示属性：黑底白字
	mov dx,0000h ;dh为行号，dl为列号
	mov cx,MessageLength
	int 10h

Judge:
   mov ah,01h
   int 16h
   mov bl,20h
   cmp al,bl
   jz Quit
   jmp showInfo

Quit:
    jmp 0:7C00H

Message:
    Info:db 'There are four programs of user!',0Dh,0Ah;
    UP1name:db 'Square'
    UP1addr:db '  addr:0200h~0400h:second section',0DH,0AH
	UP2name:db 'Single stone'
    UP2addr:db '  addr:0400h~0600h:third section',0DH,0AH
	UP3name:db 'Double stone'
    UP3addr:db '  addr:0600h~0800h:fourth section',0DH,0AH
	UP4name:db 'Sand clock '
    UP4addr:db '  addr:0800h~0A00h:fifth section',0DH,0AH
	MessageLength equ ($-Message)
	