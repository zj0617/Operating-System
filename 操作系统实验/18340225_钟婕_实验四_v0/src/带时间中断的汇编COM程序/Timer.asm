org 100h
;重写时钟中断08h，输出风火轮
;注意这个风火轮是一直执行的
    Dn_Rt equ 1         		;1-右下
    Up_Rt equ 2         		;2-右上
    Up_Lt equ 3         		;3-左上
    Dn_Lt equ 4         		;4-左下
    delay equ 500 			;计时器延迟计数;用于控制画框的速度
    ddelay equ 58	 			;计时器延迟计数;用于控制画框的速度

start:
   xor ax,ax
   mov es,ax
   mov word[es:32],Timer
   mov word[es:34],cs
   mov ax,cs
   mov es,ax
   mov ds,ax
   mov ss,ax
   mov ax,0B800H
   mov gs,ax

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

end:
   jmp $

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

  dec byte[tcount]
  jz tJudge
  jmp INTR

tJudge:
  mov byte[tcount],tdelay ;达到六个时间中断输出一次，此时计数器要重置
  cmp byte[state],1
  jz C1
  cmp byte[state],2
  jz C2
  cmp byte[state],3
  jz C3
  cmp byte[state],4
  jz C4
 
C1:
  mov al,byte[ch1]
  inc byte[state]
  jmp tshow

C2: 
  mov al,byte[ch2]
  inc byte[state]
  jmp tshow

C3:
  mov al,byte[ch3]
  inc byte[state]
  jmp tshow

C4: 
  mov al,byte[ch4]
  mov byte[state],1 ;状态在1~4变化，当当前状态为4时置为0
  jmp tshow

tshow:
   mov ah,0Fh		; 0000：黑底、1111：亮白字（默认值为07h）
   mov word[gs:((80*24+79)*2)],ax
   mov byte[tcount],tdelay

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
  num dw delay
  dnum dw ddelay
  initial db Dn_Rt
  x dw 2
  y dw 3
  color db 1
  char db 'A'
  myName db "Zhong Jie"
  myNumber db "18340225"
  tdelay equ 4
  tcount db tdelay
  state db 1
  ch1 db '|'
  ch2 db '/'
  ch3 db '-'
  ch4 db '\'
