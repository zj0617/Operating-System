extern  macro %1    ;统一用extern导入外部标识符
  extrn %1
endm

extern _cmain:near ;声明一个外部函数cmain

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h  ;COM格式文件的内存起始偏移地址

start:
    ;定义向量中断表，内存地址为[0:1023]
	;低位为IP值，高字节为cs值
	;每个中断向量占32位，cs、ip各占两个字节！
	xor ax,ax
	mov es,ax;清零段地址，中断向量在内存：0~1023处
	mov word ptr es:[32],offset Timer
	mov word ptr es:[34],cs

	mov word ptr es:[33*4],offset int21h
	mov word ptr es:[33*4+2],cs

	mov word ptr es:[34*4],offset int22h
	mov word ptr es:[34*4+2],cs

	mov word ptr es:[35*4],offset int23h
	mov word ptr es:[35*4+2],cs

	mov word ptr es:[36*4],offset int24h
	mov word ptr es:[36*4+2],cs

	mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	mov sp, 0FFF0h ;栈顶指针
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	
	call _clear
	call near ptr _cmain ;从入口进入C语言cmain函数，开始运行OS内核部分
    jmp $	;无限循环
	include basic.asm

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS segment word public 'BSS'
_BSS ends
end start

