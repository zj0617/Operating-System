org 100H

start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;文本窗口起始地址
	mov gs,ax

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

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax
   mov ss,ax

showInfo:
	;调用int10h显示操作系统启动的相关提示信息
	inc word[count]
	mov ax,cs
    mov es,ax
    mov bp,Message;偏移地址，采用段地址：偏移地址形式es:bp表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0007h ;bh=00h为页码，bl=07h为显示属性：黑底白字
	mov dx,0912h ;dh为行号，dl为列号
	mov cx,MessageLength
	int 10h

Judge:
   mov bx,5000
   mov ax,word[count]
   cmp ax,bx
   jz Quit
   jmp showInfo

Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret

Message:
    Info:db 'There are four programs of user!',0Dh,0Ah,0Dh,0Ah;
    UP1name:db '     UP1:Square      '
    UP1addr:db '||addr:0E00h~1000h:eighth section||size:407Bytes',0DH,0AH
	UP2name:db '     UP2:Single stone'
    UP2addr:db '||addr:1000h~1200h:ninth  section||size:438Bytes',0DH,0AH
	UP3name:db '     UP3:Double stone'
    UP3addr:db '||addr:1200h~1400h:tenth  section||size:508Bytes',0DH,0AH
	UP4name:db '     UP4:Sand clock  '
    UP4addr:db '||addr:1400h~1600h:eleven section||size:326Bytes',0DH,0AH
	MessageLength equ ($-Message)

datadef:
   count dw 0
	