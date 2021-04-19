
    org 7c00h; 将引导扇区加载到内存中物理地址为7c00h处

    ;定义以下常量;D-Down\U-Up\R-Right\L-Left
    Dn_Rt equ 1         		;1-右下
    Up_Rt equ 2         		;2-右上
    Up_Lt equ 3         		;3-左上
    Dn_Lt equ 4         		;4-左下
    delay equ 50000 			;计时器延迟计数;用于控制画框的速度
    ddelay equ 580	 			;计时器延迟计数;用于控制画框的速度

Start:
	mov ax, cs    			;置其他段寄存器值与CS相同
	mov ds, ax    			;数据段ds
	mov bp, Message 		;BP=当前串的偏移地址
	mov ax, ds 				;ES:BP=串基地址:串偏移地址=串地址
	mov es, ax 				;置ES=DS
	mov cx, MessageLength 	;CX=串长度 
	mov ax, 01301H 			;AH=13h(功能号;显示字符串);AL=01h(光标置于串尾)
	mov bx, 001FH 			;页号为0(BH=0);蓝底白字高亮无闪烁(BL=1Fh)
	mov dx, 0				;行号dh=0;列号dl=0
	int 10H 				;10h号中断

Load:
	;读取扇区内容至ES:BX处
	mov ax, cs        		;段地址
	mov es, ax        		;ES=段地址
	mov bx, 7E00H 			;BX=偏移地址
	mov ah, 02H         	;功能号02H;读扇区
	mov al, 01H         	;AL=扇区数
	mov ch, 00H         	;CH=柱面号;起始编号为0
	mov cl, 02H         	;CL=起始扇区号;起始编号为1
	mov dh, 00H         	;DH=磁头号;起始编号为0
	mov dl, 00H        		;DL=驱动器号;这里是软盘
	int 13H 				;调用读磁盘BIOS的13h功能
	;引导扇区程序已加载到指定内存区域中
	jmp 7E00H

After:
   jmp $           			;无限循环	
	
Message:
    db '18340225', 0DH, 0AH
    db 'Zhong Jie'
	MessageLength equ ($-Message)
	times 510-($-$$) db 0 	;填充剩下的空间;使生成的二进制代码恰好为512字节
	dw 0xaa55 				;结束标志


;初始化寄存器的值
Begin:
    mov ax,cs                   ;cs为代码段寄存器
	mov es,ax                   ;令es=cs
	mov ds,ax                   ;ds=cs
	mov ax,0B800h                ;B800h为显存缓冲区的起始地址
	mov gs,ax                   ;令全局段寄存器的值=B800h

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	mov ax,0
	cmp ax,word[standard]
	    jz ch1
	jmp ch0

ch0:
    mov word[standard],0
	mov ax,[arr+2]
	mov word[y],ax
	jmp Swi

ch1:
    mov word[standard],2
	mov ax,[arr]
	mov word[y],ax
	jmp Swi

Swi:
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
	mov ax,25
	sub ax,bx
	jz dr2ur
	mov bx,[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp WB

dr2ur:
   mov word[x],23
   mov byte[initial],Up_Rt
   jmp WB 

dr2dl:
   mov word[y],78
   mov byte[initial],Dn_Lt
   jmp WB

UpRt:
   dec word[x]
   inc word[y]
   mov ax,word[x]
   mov bx,-1
   sub ax,bx
   jz ur2dr
   mov bx,[y]
   mov ax,80
   sub ax,bx
   jz ur2ul
   jmp WB

 ur2dr:
   mov word[x],1
   mov byte[initial],Dn_Rt
   jmp WB

ur2ul:
   mov word[y],78
   mov byte[initial],Up_Lt
   jmp WB

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,25
   sub ax,bx
   jz dl2ul
   mov bx,[y]
   mov ax,-1
   sub ax,bx
   jz dl2dr
   jmp WB

dl2ul:
   mov word[x],23
   mov byte[initial],Up_Lt
   jmp WB

dl2dr:
   mov word[y],1
   mov byte[initial],Dn_Rt
   jmp WB

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,-1
   sub ax,bx
   jz ul2dl
   mov bx,[y]
   mov ax,-1
   sub ax,bx
   jz ul2ur
   jmp WB

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp WB

ul2ur:
   mov word[y],1
   mov byte[initial],Up_Rt
   jmp WB

WB:
   mov ax,0
   cmp ax,word[standard]
       jz WB1
   mov ax,word[y]
   mov word[arr],ax
   jmp display

WB1:
   mov ax,word[y]
   mov word[arr+2],ax
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
   jz c1         ;相等则跳转到circle1
   mov bl,90
   cmp byte[char],bl   ;判断是否相等
   jz c2          ;相等则跳转到circle2
   jmp Loop


c1:
   mov byte[color],1    ;重置color的内容
   mov bl,90
   cmp byte[char],bl
   jz c2
   jmp Loop

c2:
   mov byte[char],65    ;重置char的内容
   jmp Loop

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   initial db Dn_Rt
   x dw 2
   y dw 3
   arr dw 3 ,8
   standard dw 0
   color db 1
   char db 'A'
 

