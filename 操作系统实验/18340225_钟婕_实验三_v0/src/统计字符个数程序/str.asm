extern  macro %1    ;统一用extern导入外部标识符
  extrn %1
endm

extern _count:near
extern _num:near

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h  ;.com文件内的起始内存地址

start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0FFF0h
	mov bp,offset _str;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0007h ;bh=00h为页码，bl=07h为显示属性：黑底白字
	mov dx,0000h ;dh为行号，dl为列号
	mov cx,13
	int 10h
	mov bp,offset Info;偏移地址，采用段地址：偏移地址形式表示串地址
	mov ax,1301h ;ah=13h为功能号，al=01h指光标位于串尾
	mov bx,0007h ;bh=00h为页码，bl=07h为显示属性：黑底白字
	mov dx,0100h ;dh为行号，dl为列号
	mov cx,19
	int 10h
	mov ax,offset _str
	push ax
	call near ptr _count ;调用C程序的count函数
	pop cx
	pop cx
	mov al,byte ptr [_num] ;将调用C模块函数的返回值_num显示出来
	mov ah,0EH ;ah为功能号
	mov bh,0h ;bh为页码
	mov bl,0h ;前景色（图形模式）
	int 10h
    jmp $	
datadef:
    _str db "HappytoGooooo",0
	Info db "The number of o is "
	
_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS  segment word public 'BSS'
_BSS ends
end start


