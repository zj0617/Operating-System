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
    ;���������жϱ��ڴ��ַΪ[0:1023]
	;��λΪIPֵ�����ֽ�Ϊcsֵ
	;ÿ���ж�����ռ32λ��cs��ip��ռ�����ֽڣ�
	xor ax,ax
	mov es,ax;����ε�ַ���ж��������ڴ棺0~1023��
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

	mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	mov sp, 0FFF0h ;ջ��ָ��
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	
	call _clear
	call near ptr _cmain ;����ڽ���C����cmain��������ʼ����OS�ں˲���
    jmp $	;����ѭ��
	include basic.asm

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS segment word public 'BSS'
_BSS ends
end start

