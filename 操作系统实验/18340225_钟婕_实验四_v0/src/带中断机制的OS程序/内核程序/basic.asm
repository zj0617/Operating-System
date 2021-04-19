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
;用户程序运行时，要响应自定义的键盘中断
;为了保证用户程序结束运行时，键盘恢复，需要保存原来的键盘中断
public _UP
_UP proc
   push ax
   push bx
   push cx
   push dx
   push ds
   push es
   push bp ;保护现场，保护ds、es、bp寄存器的值

   ;保护正常的09h键盘输入
   xor ax,ax
   mov es,ax
   mov bp,offset normal
   ;测试ptr作用！和es:[]用途
   mov ax,word ptr es:[36] ;保存IP值
   mov word ptr [bp],ax
   mov ax,word ptr es:[38] ;保存cs值
   mov word ptr [bp+2],ax

   ;修改键盘中断为自定义中断int09h
   mov word ptr es:[36],offset int09h
   mov word ptr es:[38],cs

   mov bp,sp;用bp访问栈中传入的参数，因为IP、ds、es、bp.ax压栈，所以参数在bp+10的位置
   mov ax,cs
   mov es,ax ;置es与cs相等，为段地址,入口时CS为0A00H
   mov bx,OffsetofUP ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
   mov ah,02h ;功能号02h读扇区
   mov al,1   ;读入扇区数
   mov dl,0   ;驱动器号，软盘为0，U盘和硬盘为80h
   mov dh,0   ;磁头号为0
   mov cx,[bp+16] ;起始扇区号，编号从1开始，传入的参数即为对应用户程序所在扇区
   mov ch,0   ;柱面号为0
   sub cl,48
   int 13h    ;中断号
   ;将对应用户程序加载到内存为0800H:8c00H处
   mov bx,OffsetofUP ;将偏移地址赋值给bx
   call bx ;程序跳转到对应内存位置执行用户程序
   
   ;恢复正常的键盘中断
   xor ax,ax
   mov es,ax
   mov bp,offset normal
   mov ax,word ptr [bp] ;类型+ptr指明数据类型！ptr可以取内存地址的值也可以作为指明数据类型！
   mov word ptr es:[36],ax
   mov ax,word ptr [bp+2]
   mov word ptr es:[38],ax

   pop bp
   pop es
   pop ds ;恢复现场，逆序出栈
   pop dx
   pop cx
   pop bx
   pop ax
   ret ;函数模块返回
_UP endp


OffsetofINT equ 0B100H
;实验要求一个用户程序调用21h、22h、23h、24h中断
;中断即调用程序
public _RunInt
_RunInt proc
   push ds
   push es;保护现场，保护ds、es寄存器的值
   push ax
   push bx
   push cx
   push dx
   mov ax,cs
   mov es,ax ;置es与cs相等，为段地址,入口时CS为0A00H
   mov bx,OffsetofINT ;数据常量，代表偏移地址，段地址:偏移地址为内存访问地址
   mov ah,02h ;功能号02h读扇区
   mov al,1   ;读入扇区数
   mov dl,0   ;驱动器号，软盘为0，U盘和硬盘为80h
   mov dh,0   ;磁头号为0
   mov ch,0   ;柱面号为0
   mov cl,14   ;起始扇区号
   int 13h    ;中断号
   ;将对应用户程序加载到内存为0800H:0B100H处
   mov bx,OffsetofINT ;将偏移地址赋值给bx
   call bx ;程序跳转到对应内存位置执行用户程序
   pop dx
   pop cx
   pop bx
   pop ax
   pop es
   pop ds ;恢复现场，逆序出栈
   ret ;函数模块返回
_RunInt endp




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

;09h号键盘中断
;要求在用户程序运行时响应
;不运行用户程序时不能干扰正常键盘输入
;中断号15h
;功能86H 
;功能描述：延迟 
;入口参数：AH＝86H 
;CX:DX＝千分秒 
;出口参数：CF＝0——操作成功，AH＝00H 
int09h:
   ;保护寄存器
  ;下列寄存器在此过程会被改变，需要保护
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
  mov cx,11
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

  ;利用10h的中断号实现清屏
  ;显示的位置是从（12，35）开始的，一行显示
  ;清除该ouch位置的字符串
  mov ah,6
  mov al,0
  mov ch,12 ;清屏的左上角坐标
  mov cl,35
  mov dh,12 ;清屏的右下角坐标
  mov dl,45
  mov bh,7 ;默认属性，黑底
  int 10H
    
  in al,60h
  mov al,20h					    ; AL = EOI
  out 20h,al						; 发送EOI到主8529A
  out 0A0h,al					    ; 发送EOI到从8529A

  pop bp
  pop es
  pop ds
  pop dx
  pop cx
  pop bx
  pop ax
  iret;

  Info db "OUCH! OUCH!"
  color db 1

;编写21h~24h中断服务程序，分别执行四个用户程序
int21h:
   mov ax,56
   push ax
   call _UP
   pop ax
   iret

int22h:
   mov ax,57
   push ax
   call _UP
   pop ax
   iret

int23h:
   mov ax,58
   push ax
   call _UP
   pop ax
   iret

int24h:
   mov ax,59
   push ax
   call _UP
   pop ax
   iret

Data:
  normal dw 0,0