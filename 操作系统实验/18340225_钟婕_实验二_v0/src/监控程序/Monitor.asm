 org 7c00h ;将引导扇区加载到内存中的初始偏移地址为07C00h处

 OffsetofUP equ 8100h

start:
    mov ax,cs ;置其他寄存器与cs相同
	mov ds,ax
	mov ax,ds
	mov es,ax
	mov bx,0B800H ;显存缓冲区起始地址
	mov gs,bx

;显示相关提示
showInfo:
     ;使用int10h的向上滚屏即清窗口功能
    mov ah,06h ;入口参数，功能号：ah=06h-向上滚屏，ah=07h-向下滚屏
    mov al,0h ;滚动行数（0-清窗口）
    mov ch,0 ;窗口的左上角位置（x坐标）
    mov cl,0 ;窗口的左上角位置（y坐标）
    mov dh,12 ;窗口的右下角位置（x坐标）
    mov dl,39 ;窗口的右下角位置（y坐标）
    mov bh,7 ;空白区域的缺省属性
    int 10h ;中断号
	;调用int10h显示操作系统启动的相关提示信息
    mov bp,Message;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0007h ;bh=00h为页码，bl=07h为显示属性：黑底白字
	mov dx,0000h ;dh为行号，dl为列号
	mov cx,MessageLength
	int 10h

;输入选择
Input:
    mov ah,0h 
	int 16h ;调用16h号中断输入一个字符，ah为功能号，输入的字符存入al中
	cmp al,'0'
	jz Run
	cmp al,'1'
	jz UP
	cmp al,'2'
	jz UP
	cmp al,'3'
	jz UP
	cmp al,'4'
	jz UP
	cmp al,'5'
	jz DIY
	cmp al,'6'
	jz UP
	jmp Input ;确保输入的是0、1、2、3、4、5、6中的一个

;调用int 13h读扇区加载第一个用户程序至内存相应位置
;为了简便，将第一个用户程序存放在软盘的第二个扇区
UP:
    sub al,47
	mov cl,al  ;读的起始扇区号，扇区号是从一开始的
    mov ax,cs
	mov es,ax ;置es与cs相等，为段地址
	mov bx,OffsetofUP ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
	mov ah,02h ;功能号02h读扇区
	mov al,1   ;读入扇区数
	mov dl,0   ;驱动器号，软盘为0，U盘和硬盘位80h
	mov dh,0   ;磁头号为0
	mov ch,0   ;柱面号为0
	int 13h    ;中断号
	jmp 800h:100h ;第一个用户程序已经加载到内存相应位置，要跳转到内存相应位置，开始执行该用户程序
	
;设计一种命令，可以在一个命令中指定某种顺序执行若干个用户程序。可以反复接受命令。
DIY:
    mov ah,0h 
	int 16h ;调用16h号中断输入一个字符，ah为功能号，输入的字符存入al中
	mov byte[arr],al
	mov ah,0h 
	int 16h ;调用16h号中断输入一个字符，ah为功能号，输入的字符存入al中
	mov byte[arr+1],al
	mov ah,0h 
	int 16h ;调用16h号中断输入一个字符，ah为功能号，输入的字符存入al中
	mov byte[arr+2],al
	mov ah,0h 
	int 16h ;调用16h号中断输入一个字符，ah为功能号，输入的字符存入al中
	mov byte[arr+3],al
	mov bh,0
	mov bl,byte[arr+3]
	push bx
	mov bl,byte[arr+2]
	push bx
	mov bl,byte[arr+1]
	push bx
	mov bl,byte[arr]
	push bx
	jmp Run

Run:
    pop ax
	jmp UP

datadef:
	 arr db '1','2','3','4'

Message:
    db "Hello, welcome to My OS!",0AH,0DH ;字符数组，最后为换行符
    db "Here is the start Memu.",0AH,0DH,"Input ' ' to exit UP.",0AH,0DH,"Please Enter the number:",0AH,0DH
    db "1.square",0AH,0DH
    db "2.single stone",0AH,0DH
    db "3.double stone",0AH,0DH
    db "4.sand clock",0AH,0DH
	db "5.DIY a special route.",0AH,0DH,"Please input '0' after every run!",0AH,0DH
	db "6.display the table.",0AH,0DH
    MessageLength  equ ($-Message) ;将此监控程序作为首扇区引导程序
    times 510-($-$$) db 0 ;用‘0’填满首扇区剩余位置
    db 0x55,0xaa ;可引导标志



