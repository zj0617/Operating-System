
    org 7c00h; 将引导扇区加载到内存中物理地址为7c00h处

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
	mov ax,0B800h                ;B800h为显存缓冲区的起始地址
	mov gs,ax                   ;令全局段寄存器的值=B800h

;显示个人姓名 学号
PersonnalInf:
    mov ax,myName
	mov bp,ax;es:bp=串基地址:偏移地址=串地址
	mov cx,9;串的长度
	mov ax,1301h;ah=13h显示字符串;al=01h光标位于串尾
	mov bx,001dh;bl为1dh 蓝底浅品红无闪烁;bh为00h 页号为0
	mov dx,00h;dh行号=0h;dl列号=0h
	int 10h;调用10h号中断
    mov ax,myNumber
	mov bp,ax;es:bp=串基地址:偏移地址=串地址
	mov cx,8;串的长度
	mov ax,1301h;ah=13h显示字符串;al=01h光标位于串尾
	mov bx,001dh;bl为1dh蓝底浅品红无闪烁;bh为00h页号为0
	mov dx,0100h;dh行号=01h;dl列号=00h
	int 10h;调用10h号中断

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
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
	mov bx,word[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp display

dr2ur:
   mov word[x],23
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
   mov ax,25
   sub ax,bx
   jz dl2ul
   mov bx,word[y]
   mov ax,-1
   sub ax,bx
   jz dl2dr
   jmp display

dl2ul:
   mov word[x],23
   mov byte[initial],Up_Lt
   jmp display

dl2dr:
   mov word[y],1
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
   mov ax,-1
   sub ax,bx
   jz ul2ur
   jmp display

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp display

ul2ur:
   mov word[y],1
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
   jmp Loop

circle1:
   mov byte[color],1    ;重置color的内容
   mov bl,90
   cmp byte[char],bl
   jz circle2
   jmp Loop

circle2:
   mov byte[char],65    ;重置char的内容
   jmp Loop

datadef:
   num dw delay
   dnum dw ddelay
   initial db Dn_Rt
   x dw 2
   y dw 3
   color db 1
   char db 'A'
   myName db "Zhong Jie"
   myNumber db "18340225"
end:
   jmp $
   times 510-($-$$) db 0
   dw 0xaa55
