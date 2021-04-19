;用来实现一些硬件上的需求
;包括BIOS的一些基本的系统调用

extern _InCh ;全局变量，可以在C语言与汇编之间“通信”，保存键盘输入的一个字符

;局部字符串带初始化作为实参问题补钉程序
public SCOPY@
SCOPY@ proc 
	arg_0 = dword ptr 6
	arg_4 = dword ptr 0ah
	push bp
	mov bp,sp
	push si
	push di
	push ds
	lds si,[bp+arg_0]
	les di,[bp+arg_4]
	cld
	shr cx,1
	rep movsw
	adc cx,cx
	rep movsb
	pop ds
	pop di
	pop si
	pop bp
	retf 8
SCOPY@ endp

public _clear ;为了方便C程序调用加上下划线
_clear proc 
; 清屏
	push ax ;保护各个寄存器的值，因为在BIOS调用会更改这些寄存器的值，所以需要保护现场
	push bx
	push cx
	push dx	
	;使用int10h的向上滚屏即清窗口功能
    mov ah,06h ;入口参数，功能号：ah=06h-向上滚屏，ah=07h-向下滚屏
    mov al,0h ;滚动行数（0-清窗口）
    mov ch,0 ;窗口的左上角位置（x坐标）
    mov cl,0 ;窗口的左上角位置（y坐标）
    mov dh,24 ;窗口的右下角位置（x坐标）
    mov dl,79 ;窗口的右下角位置（y坐标）
    mov bh,7 ;空白区域的缺省属性
	mov bl,0
    int 10h ;中断号
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	pop dx ;恢复寄存器的值，即恢复现场
	pop cx ;这样的操作有利于防止程序出现一些奇怪的错误，尽量减少在调用过程中对寄存器的破坏
	pop bx
	pop ax
	ret   ;返回，因为这些过程模块均是被调用执行的，需要返回主程序
_clear endp

;调用中断号16h的0h功能读入一个字符
public _scanfCh
_scanfCh proc
    mov ah,0 ;功能号
	int 16h
	mov byte ptr [_InCh],al ;用一个字符指针保存输入的字符,InCh为C模块的变量
	ret
_scanfCh endp

;实验要求有一个表存储用户程序相关信息，将之存放在第11个扇区，类似作为第五个用户程序
OffsetofUP equ 0A100H

public _UP
_UP proc
   push ds
   push es
   push bp ;保护现场，保护ds、es、bp寄存器的值
   mov bp,sp;用bp访问栈中传入的参数，因为IP、ds、es、bp压栈，所以参数在bp+8的位置
   mov ax,cs
   mov es,ax ;置es与cs相等，为段地址,入口时CS为0A00H
   mov bx,OffsetofUP ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
   mov ah,02h ;功能号02h读扇区
   mov al,1   ;读入扇区数
   mov dl,0   ;驱动器号，软盘为0，U盘和硬盘为80h
   mov dh,0   ;磁头号为0
   mov cx,[bp+8] ;起始扇区号，编号从1开始，传入的参数即为对应用户程序所在扇区
   mov ch,0   ;柱面号为0
   sub cl,48
   int 13h    ;中断号
   ;将对应用户程序加载到内存为0800H:8c00H处
   mov bx,OffsetofUP ;将偏移地址赋值给bx
   call bx ;程序跳转到对应内存位置执行用户程序
   pop bp
   pop es
   pop ds ;恢复现场，逆序出栈
   ret ;函数模块返回
_UP endp

;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _printfCh
_printfCh proc
    push bp ;保护bp的值，因为接下来要用bp去访问栈（参数在栈中）
	mov bp,sp ;栈顶指针sp赋给bp
	mov ax,[bp+4]
	mov ah,0EH ;ah为功能号
	mov bl,0h ;前景色（图形模式）
	int 10h
	mov sp,bp
	pop bp ;恢复bp的值
	ret   ;返回
_printfCh endp

