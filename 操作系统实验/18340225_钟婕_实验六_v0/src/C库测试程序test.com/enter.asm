extern  macro %1    ;ͳһ��extern�����ⲿ��ʶ��
  extrn %1
endm

extern _main:near ;����һ���ⲿ����cmain


.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h  ;COM��ʽ�ļ����ڴ���ʼƫ�Ƶ�ַ

start:
    ;���������жϱ��ڴ��ַΪ[0:1023]
	;��λΪIPֵ�����ֽ�Ϊcsֵ
	;ÿ���ж�����ռ32λ��cs��ip��ռ�����ֽڣ�
	mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	xor ax,ax
	mov es,ax;����ε�ַ���ж��������ڴ棺0~1023��

	mov word ptr es:[33*4],offset int21h
	mov word ptr es:[33*4+2],cs

	mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	mov sp, 0FFFFh ;ջ��ָ�룬���ܲ���
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	
	mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	call near ptr _main ;����ڽ���C����cmain��������ʼ����OS�ں˲���
    jmp $	;����ѭ��
	include libs.asm

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS segment word public 'BSS'
_BSS ends
end start

