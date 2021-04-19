
extern _getstr:near ;声明一个外部函数cmain
extern _putstr:near ;声明一个外部函数cmain
extern _scanfstr:near ;声明一个外部函数cmain

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


public _fst
_fst proc
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	ret
_fst endp


public _cls
_cls proc
    mov ah,0
	int 21h
	ret
_cls endp

;调用中断号16h的0h功能读入一个字符
public _getch
_getch proc
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    mov ah,1
	int 21h
	ret
_getch endp

;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _putch
_putch proc
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    mov ah,2
	int 21h
	ret
_putch endp

;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _puts
_puts proc
    mov ah,3
	int 21h
	ret
_puts endp

;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _gets
_gets proc
    mov ah,4
	int 21h
	ret
_gets endp

;调用中断号10h的0Eh功能，在Teletype模式下显示字符
public _scanf
_scanf proc
    mov ah,5
	int 21h
	ret
_scanf endp


Sche_num dw 0
Back dw 0
Sa dw 0
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

	mov cx,cs;要记得重新给段寄存器赋值！！否则调用错误！
	mov es,cx
	mov ds,cx
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


	mov cx,cs;要记得重新给段寄存器赋值！！否则调用错误！
	mov es,cx
	mov ds,cx
	pop cx;弹出栈中的ip2,此时栈中psw/ip1/cs1
	;不能用ax存ax在函数中会变化！！！
	push bp
	mov bp,offset Back
	mov word ptr [bp],cx
	mov bp,offset Sa
	mov word ptr [bp],ax
	pop bp

	call near ptr _Save_PSP

	;栈中的psw\cs\ip可以不用出栈
	push bp
	mov bp,offset Back
	mov cx,word ptr [bp]
	pop bp

	push cx;再把ip2入栈，此时栈中ip2
	call near ptr _Process_Schedule
	push bp
	mov bp,offset Sa
	mov ax,word ptr [bp]
	pop bp
	
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







int21h:
  call near ptr Save
  cmp ah,0
  jnz Ch1
  jmp cls

Ch1:
  cmp ah,1
  jnz Ch2
  jmp getch

Ch2:
  cmp ah,2
  jnz Ch3
  jmp putch

Ch3:
  cmp ah,3
  jnz Ch4
  jmp puts

Ch4:
  cmp ah,4
  jnz Ch5
  jmp gets

Ch5:
  cmp ah,5
  jnz Q
  jmp scanf

Q:
  iret
  jmp $

getch:
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    push bp
	push bx
	mov bp,sp
	mov bx,[bp+12];char/ip1/ip2/cs/psw/bp/bx
    mov ah,0 ;功能号
	int 16h
	mov byte ptr [bx],al ;用一个字符指针保存输入的字符,InCh为C模块的变量
	mov sp,bp
	pop bx
	pop bp
	jmp near ptr Restart
	iret

putch:
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    push bp ;保护bp的值，因为接下来要用bp去访问栈（参数在栈中）
	mov bp,sp ;栈顶指针sp赋给bp
	mov ax,[bp+10];char/ip1/ip2/cs/psw/bp
	mov ah,0EH ;ah为功能号
	mov bl,0h ;前景色（图形模式）
	int 10h
	mov sp,bp
	pop bp ;恢复bp的值
	jmp near ptr Restart
	iret   ;返回


cls:
    mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
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
	jmp near ptr Restart
	iret

puts:
   mov ax,cs;置其它寄存器与CS相同
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10];保存要显示的字符串的起始地址
   push [bp+10]
   call near ptr _putstr
   pop bp
   pop bp
   iret

gets:
   mov ax,cs;置其它寄存器与CS相同
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10]
   push [bp+10]
   call near ptr _getstr
   pop bp
   pop bp
   iret

scanf:
;%的ASCII码值为37
   mov ax,cs;置其它寄存器与CS相同
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10];char/str/ip1/ip2/cs/psw/bp/bx/cx str
   mov cx,[bp+12];c模块调用汇编右参先入栈！char
   push [bp+12]
   push [bp+10]
   call near ptr _scanfstr
   pop bp
   pop bp
   pop bp
   iret
