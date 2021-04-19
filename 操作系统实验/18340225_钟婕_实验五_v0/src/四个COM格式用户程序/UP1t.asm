org 100h;将引导扇区加载到内存中的初始偏移地址为0A100h处
   Rt_ equ 1
   Dn_ equ 2
   Lt_ equ 3
   Up_ equ 4
   delay equ 50000
   ddelay equ 580

start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;文本窗口起始地址
	mov gs,ax

;调用int 10h的实现清窗口功能
   ;因为al=0h为清屏功能，此时其他寄存器参数功能无效
   mov ah,06h ;入口参数，功能号：ah=06h-向上滚屏，ah=07h-向下滚屏
   mov al,0h ;滚动行数（0-清窗口）
   mov ch,0 ;窗口的左上角位置（x坐标）
   mov cl,0 ;窗口的左上角位置（y坐标）
   mov dh,12 ;窗口的右下角位置（x坐标）
   mov dl,39 ;窗口的右下角位置（y坐标）
   mov bh,7 ;空白区域的缺省属性
   int 10h ;中断号

;调用int 10h实现显示字符串功能
show:
   mov ax,cs
   mov es,ax
   mov ax,myName
   mov bp,ax;es:bp=串基地址:偏移地址=串地址
   mov cx,14;串的长度
   mov ax,1301h;ah=13h显示字符串;al=01h光标位于串尾
   mov bx,001dh;bl为1dh 蓝底浅品红无闪烁;bh为00h 页号为0
   mov dx,060Ah;列位置
   int 10h;调用10h号中断
   mov ax,myNumber
   mov bp,ax;es:bp=串基地址:偏移地址=串地址
   mov cx,15;串的长度
   mov ax,1301h;ah=13h显示字符串;al=01h光标位于串尾
   mov bx,001dh;bl为1dh蓝底浅品红无闪烁;bh为00h页号为0
   mov dx,070Ah;列位置
   int 10h;调用10h号中断

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
	    jz Dn
    mov al,3
	cmp al,byte[initial]
	    jz Lt
	mov al,4
	cmp al,byte[initial]
	    jz Up
	jmp $

Rt:
   inc word[y]
   mov bx,word[y]
   mov ax,36
   sub ax,bx
   jz Rt2Dn
   jmp display

Rt2Dn:
   mov word[y],35
   mov byte[initial],Dn_
   jmp display

Dn:
   inc word[x]
   mov bx,word[x]
   mov ax,11
   sub ax,bx
   jz Dn2Lt
   jmp display

Dn2Lt:
   mov word[x],10
   mov byte[initial],Lt_
   jmp display

Lt:
   dec word[y]
   mov bx,word[y]
   mov ax,3
   sub ax,bx
   jz Lt2Up
   jmp display

Lt2Up:
   mov word[y],4
   mov byte[initial],Up_
   jmp display

Up:
   dec word[x]
   mov bx,word[x]
   mov ax,1
   sub ax,bx
   jz Up2Rt
   jmp display

Up2Rt:
   mov word[x],2
   mov byte[initial],Rt_
   jmp display

display:
   xor ax,ax
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
  mov bx,150
  mov ax,word[count]
  cmp ax,bx
  jz Quit
  jmp Loop

Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret;ret指令用栈中的数据，修改IP的内容，从而实现近转移

end:
   jmp $

datadef:
  num dw delay
  dnum dw ddelay
  count dw 0
  x dw 2
  y dw 4
  initial db Rt_
  char db 'A'
  color db 1
  myName: db "Name:Zhong Jie"
  myNumber: db "Number:18340225"


   