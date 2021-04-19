 org 100h; 将引导扇区加载到内存中的初始偏移地址为0A100h处

    ;定义以下常量;D-Down\U-Up\R-Right\L-Left
    Rt_ equ 1         		    ;1-右
    Dn_Lt equ 2         		;2-左下
	Up_Lt equ 3                 ;3-左上
    delay equ 50000 			;计时器延迟计数;用于控制画框的速度
    ddelay equ 580	 			;计时器延迟计数;用于控制画框的速度

;初始化寄存器的值
Begin:
    mov ax,cs                   ;cs为代码段寄存器
	mov es,ax                   ;令es=cs
	mov ds,ax                   ;ds=cs
	mov ss,ax
	mov ax,0B800h                ;B800h为显存缓冲区的起始地址
	mov gs,ax                   ;令全局段寄存器的值=B800h

;调用int 10h的实现清窗口功能
   ;因为al=0h为清屏功能，此时其他寄存器参数功能无效
   mov ah,06h ;入口参数，功能号：ah=06h-向上滚屏，ah=07h-向下滚屏
   mov al,0h ;滚动行数（0-清窗口）
   mov ch,13 ;窗口的左上角位置（x坐标）
   mov cl,40 ;窗口的左上角位置（y坐标）
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

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	inc word[count]
	mov al,1
	cmp al,byte[initial]
	    jz Rt
	mov al,2
	cmp al,byte[initial]
	    jz DnLt
    mov al,3
	cmp al,byte[initial]
	    jz UpLt
	jmp $


Rt:
   inc word[y]
   mov bx,word[y]
   mov ax,56
   sub ax,bx
   jz Rt2DnLt
   jmp display

Rt2DnLt:
   mov bx,word[x]
   mov ax,24
   sub ax,bx
   jz Rt2UpLt
   mov word[y],55
   mov byte[initial],Dn_Lt
   jmp display

Rt2UpLt:
   mov word[y],55
   mov byte[initial],Up_Lt
   jmp display

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,25
   sub ax,bx
   jz DnLt2Rt
   jmp display

DnLt2Rt:
   mov word[x],24
   mov word[y],45
   mov byte[initial],Rt_
   jmp display

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,13
   sub ax,bx
   jz UpLt2Rt
   jmp display

UpLt2Rt:
   mov word[x],14
   mov word[y],45
   mov byte[initial],Rt_
   jmp display

display:
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
   add byte[color],1
   add byte[char],1   ;递增
   mov bl,8
   cmp byte[color],bl ;判断是否相等
   jz circle1         ;相等则跳转到circle1
   mov bl,90
   cmp byte[char],bl   ;判断是否相等
   jz circle2          ;相等则跳转到circle2
   jmp Judge

circle1:
   mov byte[color],1    ;重置color的内容
   mov bl,90
   cmp byte[char],bl
   jz circle2
   jmp Judge

circle2:
   mov byte[char],65    ;重置char的内容
   jmp Judge

;程序的终止由用户输入空格键终止
;调用int 16h输入一个字符判断
Judge:
   mov bx,500
   mov ax,word[count]
   cmp ax,bx
   jz Quit
   jmp Loop

 Quit:
    ;mov ah,20H
	;mov al,0CDH
	;mov word[es:0],ax
	;mov ax,0
	;push ax
    ;ret
	jmp $

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   count dw 0
   initial db Rt_
   x dw 14
   y dw 45
   color db 1
   char db 'A'
   