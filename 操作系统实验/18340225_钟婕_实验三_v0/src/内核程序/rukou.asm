extern  macro %1    ;ͳһ��extern�����ⲿ��ʶ��
  extrn %1
endm

extern _cmain:near ;����һ���ⲿ����cmain

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h  ;COM��ʽ�ļ����ڴ���ʼƫ�Ƶ�ַ

start:
	mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	mov sp, 0FFF0h ;ջ��ָ��
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	call near ptr _cmain ;����ڽ���C����cmain��������ʼ����OS�ں˲���
    jmp $	;����ѭ��
	include basic.asm

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS segment word public 'BSS'
_BSS ends
end start

