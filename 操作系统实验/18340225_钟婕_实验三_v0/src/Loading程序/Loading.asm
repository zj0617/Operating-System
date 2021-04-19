org 0A100H

   delay equ 50000
   ddelay equ 1580

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
	mov ch,2 ;左上角X坐标
	mov cl,10 ;左上角Y坐标
	mov dh,21 ;右下角X坐标
	mov dl,70 ;右下角Y坐标
	mov bh,0x10;空白区域的显示属性：蓝底黑字，无闪烁无加亮
	int 10h ;BIOS功能调用

showInfo:
    ;调用int10h显示操作系统启动的相关提示信息
	mov ax,cs
	mov es,ax
    mov bp,Message;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,00deh ;bh=00h为页码，bl=07h为显示属性：红底黄字，有闪烁
	mov dx,0a19h ;dh为行号，dl为列号,第10行，25列
	mov cx,MessageLength
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str0
	mov ax,1301h
	mov bx,00deh
	mov dx,0c13h
	mov cx,42
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str
	mov ax,1301h
	mov bx,001fh
	mov dx,1228h
	mov cx,11
	int 10h

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	jmp Rt

Rt:
    inc word[y]
	mov bx,word[y]
	mov ax,56
	cmp ax,bx
	jnz display
	jmp Quit

display:
    xor ax,ax
    mov ax,word[x]
    mov bx,80
    mul bx
    add ax,word[y]
    mov bx,2
    mul bx        ;计算显存偏移地址
    mov bp,ax
    mov ah,[color] ;显示属性
    mov al,byte[char]  ;显示字符
    mov word[gs:bp],ax  ;向相应显存地址写入
    jmp Loop
	jmp Quit


Message:
      db  "     Welcome to my OS!     ",0DH,0AH
	  MessageLength equ ($-Message)

Quit:
    ret 

end:
    jmp $

datadef:	
    x  dw 19
    y  dw 30	
	num dw delay
	dnum dw ddelay
	color db 0x73
	char db 32
	str0: db "Author:Zhong Jie & Student Number:18340225"
	str: db "Loading...."

    times 512 - ($ - $$) db 0 
