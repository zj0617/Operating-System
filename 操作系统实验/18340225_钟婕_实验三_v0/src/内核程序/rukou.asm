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
	mov ax,cs;置其它寄存器与CS相同
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	mov sp, 0FFF0h ;栈顶指针
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	call near ptr _cmain ;从入口进入C语言cmain函数，开始运行OS内核部分
    jmp $	;无限循环
	include basic.asm

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS segment word public 'BSS'
_BSS ends
end start

