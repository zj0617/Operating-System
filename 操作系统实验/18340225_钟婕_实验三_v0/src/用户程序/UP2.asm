
    org 0A100h; 将引导扇区加载到内存中的初始偏移地址为0A100h处

    ;定义以下常量;D-Down\U-Up\R-Right\L-Left
    Dn_Rt equ 1         		;1-右下
    Up_Rt equ 2         		;2-右上
    Up_Lt equ 3         		;3-左上
    Dn_Lt equ 4         		;4-左下
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
   mov ch,0 ;窗口的左上角位置（x坐标）
   mov cl,40 ;窗口的左上角位置（y坐标）
   mov dh,12 ;窗口的右下角位置（x坐标）
   mov dl,79 ;窗口的右下角位置（y坐标）
   mov bh,7 ;空白区域的缺省属性
   int 10h ;中断号

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
	    jz DnRt
	mov al,2
	cmp al,byte[initial]
	    jz UpRt
    mov al,3
	cmp al,byte[initial]
	    jz UpLt
	mov al,4
	cmp al,byte[initial]
	    jz DnLt
	jmp $

DnRt:
    inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,13
	sub ax,bx
	jz dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp display

dr2ur:
   mov word[x],11
   mov byte[initial],Up_Rt
   jmp display

dr2dl:
   mov word[y],78
   mov byte[initial],Dn_Lt
   jmp display

UpRt:
   dec word[x]
   inc word[y]
   mov ax,word[x]
   mov bx,-1
   sub ax,bx
   jz ur2dr
   mov bx,word[y]
   mov ax,80
   sub ax,bx
   jz ur2ul
   jmp display

 ur2dr:
   mov word[x],1
   mov byte[initial],Dn_Rt
   jmp display

ur2ul:
   mov word[y],78
   mov byte[initial],Up_Lt
   jmp display

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,13
   sub ax,bx
   jz dl2ul
   mov bx,word[y]
   mov ax,39
   sub ax,bx
   jz dl2dr
   jmp display

dl2ul:
   mov word[x],11
   mov byte[initial],Up_Lt
   jmp display

dl2dr:
   mov word[y],41
   mov byte[initial],Dn_Rt
   jmp display

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,-1
   sub ax,bx
   jz ul2dl
   mov bx,word[y]
   mov ax,39
   sub ax,bx
   jz ul2ur
   jmp display

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp display

ul2ur:
   mov word[y],41
   mov byte[initial],Up_Rt
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
  mov ah,01h
  int 16h
  mov bl,8
  cmp al,bl
  jz Quit
  mov bx,200
  mov ax,word[count]
  cmp ax,bx
  jz Quit
  jmp Loop

 Quit:
   ret

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   count dw 0
   initial db Dn_Rt
   x dw 1
   y dw 40
   color db 1
   char db 'A'

   