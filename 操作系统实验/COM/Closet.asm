org 100H


start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;�ı�������ʼ��ַ
	mov gs,ax

clear:
    mov ah,06h; ���Ϲ���
	mov al,0h ;����������0-�崰�ڣ�
	mov ch,0 ;���Ͻ�X����
	mov cl,0 ;���Ͻ�Y����
	mov dh,24 ;���½�X����
	mov dl,79 ;���½�Y����
	mov bh,0x10;�հ��������ʾ���ԣ����׺��֣�����˸�޼���
	int 10h ;BIOS���ܵ���

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax
   mov ss,ax

showInfo:
    ;����int10h��ʾ����ϵͳ�ػ��������ʾ��Ϣ
	inc word[count]
	mov ax,cs
	mov es,ax
    mov bp,Message;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0014h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ����׺���
	mov dx,0407h ;dhΪ�кţ�dlΪ�к�,��8�У�7��
	mov cx,MessageLength
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str0
	mov ax,1301h
	mov bx,001eh
	mov dx,0C13h
	mov cx,42
	int 10h
	jmp Judge


Judge:
    mov bx,4000
	mov ax,word[count]
	cmp ax,bx
	jz Quit
	jmp showInfo

Message:
    db "       *  *   *  *    ",0AH,0DH
    db "            *             *  ",0AH,0DH
	db "          *   ����    ����  *",0AH,0DH
	db " BYE!     *                 *",0AH,0DH
	db " BYE!     *                 *",0AH,0DH
	db "           *    \_____/    * ",0AH,0DH
	db "            *             *  ",0AH,0DH
	db "              *  *   *  *    ",0AH,0DH
	MessageLength equ ($-Message)
Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret

end:
    jmp $

datadef:	
	str0: db "Author:Zhong Jie & Student Number:18340225"
	count dw 0
