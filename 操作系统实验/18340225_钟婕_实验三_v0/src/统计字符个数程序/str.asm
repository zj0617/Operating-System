extern  macro %1    ;ͳһ��extern�����ⲿ��ʶ��
  extrn %1
endm

extern _count:near
extern _num:near

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h  ;.com�ļ��ڵ���ʼ�ڴ��ַ

start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0FFF0h
	mov bp,offset _str;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0007h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ��ڵװ���
	mov dx,0000h ;dhΪ�кţ�dlΪ�к�
	mov cx,13
	int 10h
	mov bp,offset Info;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0007h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ��ڵװ���
	mov dx,0100h ;dhΪ�кţ�dlΪ�к�
	mov cx,19
	int 10h
	mov ax,offset _str
	push ax
	call near ptr _count ;����C�����count����
	pop cx
	pop cx
	mov al,byte ptr [_num] ;������Cģ�麯���ķ���ֵ_num��ʾ����
	mov ah,0EH ;ahΪ���ܺ�
	mov bh,0h ;bhΪҳ��
	mov bl,0h ;ǰ��ɫ��ͼ��ģʽ��
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


