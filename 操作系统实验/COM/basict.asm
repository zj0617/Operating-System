;用来实现一些硬件上的需求
;包括BIOS的一些基本的系统调用

extern _InCh ;全局变量，可以在C语言与汇编之间“通信”，保存键盘输入的一个字符

extern _segment
extern _sec

extrn _Current_PCB
extrn _Save_PCB
extrn _Process_Schedule
extrn _Fornew
extrn _process_num
extrn _cur_pnum
extrn _Save_PSP
extrn _Exchange


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

;系统调用的功能号为0
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
	ret
_clear endp

;系统调用的功能号为1
;调用中断号16h的0h功能读入一个字符
public _scanfCh
_scanfCh proc
    mov ah,0 ;功能号
	int 16h
	mov byte ptr [_InCh],al ;用一个字符指针保存输入的字符,InCh为C模块的变量
	ret
_scanfCh endp

;系统调用得功能号为2
;实验要求有一个表存储用户程序相关信息，将之存放在第11个扇区，类似作为第五个用户程序
OffsetofUP equ 0A100H
;用户程序运行时，要响应自定义的键盘中断
;为了保证用户程序结束运行时，键盘恢复，需要保存原来的键盘中断
public _UP
_UP proc
   push ax
   push ds
   push es
   push bp ;保护现场，保护ds、es、bp寄存器的值
   xor ax,ax
   mov es,ax
   mov word ptr es:[32*4],offset int20h1
   mov word ptr es:[32*4+2],cs
   mov bp,sp;用bp访问栈中传入的参数，因为IP、ds、es、bp.ax压栈，所以参数在bp+10的位置
   mov ax,cs
   mov es,ax ;置es与cs相等，为段地址,入口时CS为0A00H
   mov bx,OffsetofUP ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
   mov ah,02h ;功能号02h读扇区
   mov al,1   ;读入扇区数
   mov dl,0   ;驱动器号，软盘为0，U盘和硬盘为80h
   mov dh,1   ;磁头号为1
   mov cx,[bp+10] ;起始扇区号，编号从1开始，传入的参数即为对应用户程序所在扇区，巨坑！！！！int\ip1\ax\ds\es\bp均在栈中！！！
   mov ch,0   ;柱面号为0
   sub cl,48
   int 13h    ;中断号
   ;将对应用户程序加载到内存为0800H:8c00H处
   mov word ptr [bx],100h
   mov word ptr 2[bx],1200h
   jmp dword ptr [bx]

int20h1:
   call near ptr Save
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   pop bp
   pop es
   pop ds
   pop bp
   pop es
   pop ds ;恢复现场，逆序出栈
   pop ax
   ret
   call near ptr Restart

_UP endp



public _RT
_RT proc
   push ax
   push ds
   push es
   push bp ;保护现场，保护ds、es、bp寄存器的值
   xor ax,ax
   mov es,ax
   mov word ptr es:[32*4],offset int20h2
   mov word ptr es:[32*4+2],cs
   mov bp,sp;用bp访问栈中传入的参数，因为IP、ds、es、bp.ax压栈，所以参数在bp+10的位置
   mov ax,cs
   mov es,ax ;置es与cs相等，为段地址,入口时CS为0A00H
   mov bx,0B100h ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
   mov ah,02h ;功能号02h读扇区
   mov al,4   ;读入扇区数
   mov dl,0   ;驱动器号，软盘为0，U盘和硬盘为80h
   mov dh,1   ;磁头号为1
   mov cx,[bp+10] ;起始扇区号，编号从1开始，传入的参数即为对应用户程序所在扇区，巨坑！！！！int\ip1\ax\ds\es\bp均在栈中！！！
   mov ch,0   ;柱面号为0
   sub cl,48
   int 13h    ;中断号
   ;将对应用户程序加载到内存为0800H:8c00H处
   mov word ptr [bx],100h
   mov word ptr 2[bx],1300h
   jmp dword ptr [bx]

int20h2:
   call near ptr Save
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   ret
   call near ptr Restart

_RT endp

;系统调用得功能号为4
;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _printfCh
_printfCh proc
    push bp ;保护bp的值，因为接下来要用bp去访问栈（参数在栈中）
	mov bp,sp ;栈顶指针sp赋给bp
	mov ax,[bp+4];巨坑！！！！！char\ip1\bp均在栈中
	mov ah,0EH ;ah为功能号
	mov bl,0h ;前景色（图形模式）
	int 10h
	mov sp,bp
	pop bp ;恢复bp的值
	ret
_printfCh endp

public _T22
_T22 proc
     int 22h
	 ret
_T22 endp

Sche_num dw 0
Back dw 0
;*****************************************
;*                Save                   *
;*****************************************
Save:
    ;cmp word ptr[_process_num],0
	;jz None_process
	;inc word ptr [Sche_num]
	;cmp word ptr[Sche_num],500
	;jnz Goon
	;mov word ptr[_process_num],0
	;mov word ptr[_cur_pnum],0
	;mov word ptr[Sche_num],0
	;mov word ptr[_segment],2000h
	;jmp redone
;因为call save()会将返回值压栈，因此栈中为psw/ip1/cs1/ip2
;Goon:
    push ss
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push si
	push di
	push ds
	push es
	.386
	push fs
	push gs
	.8086

	mov ax,cs;要记得重新给段寄存器赋值！！否则调用错误！
	mov es,ax
	mov ds,ax
	;汇编调用c模块参数传递之后要自己出栈！！！
	call near ptr _Save_PCB;中断调用是模式切换的时机，因此要将被中断的进程的上下文保存在该进程的进程控制块中
	
	.386
	pop gs
	pop fs
	.8086
	pop es
	pop ds
	pop di
	pop si
	pop bp
	pop sp
	pop dx
	pop cx
	pop bx
	pop ax
	pop ss


	mov ax,cs;要记得重新给段寄存器赋值！！否则调用错误！
	mov es,ax
	mov ds,ax
	pop ax;弹出栈中的ip2,此时栈中psw/ip1/cs1
	;不能用ax存ax在函数中会变化！！！
	push bp
	mov bp,offset Back
	mov word ptr [bp],ax
	pop bp

	call near ptr _Save_PSP

	;栈中的psw\cs\ip可以不用出栈
	push bp
	mov bp,offset Back
	mov ax,word ptr [bp]
	pop bp

	push ax;再把ip2入栈，此时栈中ip2
	call near ptr _Process_Schedule
	ret;返回

;redone:

Restart:
    mov ax,cs;要记得重新给段寄存器赋值！！否则调用错误！
	mov es,ax
	mov ds,ax
	 
    call near ptr _Current_PCB;返回值保存在ax中
	mov bp,ax

    ;要先恢复ss\sp的值，不然会出现栈错误！！！！
	mov ss,word ptr ds:[bp+0]
	mov sp,word ptr ds:[bp+16]

	cmp word ptr ds:[bp+32],0  ;查看当前状态是不是new
	jnz Not_First_Time ;如果是new状态说明是第一次


redone:
    call near ptr _Fornew
	call near ptr _Exchange
	; 没有push ss 和 sp的值因为已经赋值了
	;取出PCB中的值，恢复现场
	;flags,cs,ip依次入栈，iret时自动取出
	push word ptr ds:[bp+30]
	push word ptr ds:[bp+28]
	push word ptr ds:[bp+26]
	
	push word ptr ds:[bp+2]
	push word ptr ds:[bp+4]
	push word ptr ds:[bp+6]
	push word ptr ds:[bp+8]
	push word ptr ds:[bp+10]
	push word ptr ds:[bp+12]
	push word ptr ds:[bp+14]
	push word ptr ds:[bp+18]
	push word ptr ds:[bp+20]
	push word ptr ds:[bp+22]
	push word ptr ds:[bp+24]

	pop ax
	pop cx
	pop dx
	pop bx
	pop bp
	pop si
	pop di
	pop ds
	pop es
	.386
	pop fs
	pop gs
	.8086

	iret
    
Not_First_Time:
     add sp,18 ;如果不是第一次运行，此时从PCB中得到的sp不一定是正确的值，为了保险起见取第一次的值
	 jmp redone








;重写时钟中断08h，输出风火轮
;注意这个风火轮是一直执行的
Timer:
  ;保护寄存器
  ;下列寄存器在此过程会被改变，需要保护
  push ax
  push bx
  push cx
  push dx
  push bp
  push es
  push ds

  mov ax,cs
  mov es,ax
  dec byte ptr es:[count]
  jz Judge
  jmp INTR

Judge:
  mov byte ptr es:[count],delay ;达到六个时间中断输出一次，此时计数器要重置
  cmp byte ptr es:[state],1
  jz C1
  cmp byte ptr es:[state],2
  jz C2
  cmp byte ptr es:[state],3
  jz C3
  cmp byte ptr es:[state],4
  jz C4
 
C1:
  mov al,byte ptr es:[ch1]
  inc byte ptr es:[state]
  jmp show

C2: 
  mov al,byte ptr es:[ch2]
  inc byte ptr es:[state]
  jmp show

C3:
  mov al,byte ptr es:[ch3]
  inc byte ptr es:[state]
  jmp show

C4: 
  mov al,byte ptr es:[ch4]
  mov byte ptr es:[state],1 ;状态在1~4变化，当当前状态为4时置为0
  jmp show

show:
   mov ah,0Fh		; 0000：黑底、1111：亮白字（默认值为07h）
   push es
   mov bx,0B800h		; 文本窗口显存起始地址
   mov es,bx		; ES = B800h
   mov es:[((80*24+79)*2)],ax
   pop es
   mov byte ptr es:[count],delay

INTR:
  mov al,20h
  out 20h,al			;发送EOI到主8529A 
  out 0A0h,al           ;发送给从8529A

  pop ds
  pop es
  pop bp
  pop dx
  pop cx
  pop bx
  pop ax
  iret;

datadef:
  state db 1
  ch1 db '|'
  ch2 db '/'
  ch3 db '-'
  ch4 db '\'
  delay equ 6
  count db delay

int22h:
   ;下列寄存器在此过程会被改变，需要保护
  call near ptr Save
  push ax
  push bx
  push cx
  push dx
  push ds
  push es
  push bp

  mov ax,cs
  mov es,ax
  mov ah,13h 
  mov al,0    
  mov bl,byte ptr es:[color]	                      
  mov bh,0 	                    
  mov dh,12 	                      
  mov dl,35
  mov bp,offset Info
  mov cx,6
  int 10h 
  inc byte ptr es:[color]
  mov al,8
  cmp al,byte ptr es:[color]
  jz Reset
  jmp Dump

Reset:
  mov byte ptr es:[color],1
  jmp Dump

  ;BIOS延时调用，让字符串显示停留一会再清除
Dump:
  push ax
  push cx
  push dx
  mov ah,86h ;BIOS的15h中断号86h功能号的延时功能
  mov cx,0Fh ;CX：DX= 延时时间（单位是微秒），CX是高字，DX是低字
  mov dx,4240h ;1s=1000000us=0x0F4240
  int 15h
  pop dx;注意要恢复现场！
  pop cx
  pop ax

  pop bp
  pop es
  pop ds
  pop dx
  pop cx
  pop bx
  pop ax
  jmp near ptr Restart
  iret;

  Info db "INT22H"
  color db 1