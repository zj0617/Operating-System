org 100H

start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;�ı�������ʼ��ַ
	mov gs,ax

;��ʾ�����ʾ
clear:
    ;ʹ��int10h�����Ϲ������崰�ڹ���
    mov ah,06h ;��ڲ��������ܺţ�ah=06h-���Ϲ�����ah=07h-���¹���
    mov al,0h ;����������0-�崰�ڣ�
    mov ch,0 ;���ڵ����Ͻ�λ�ã�x���꣩
    mov cl,0 ;���ڵ����Ͻ�λ�ã�y���꣩
    mov dh,24 ;���ڵ����½�λ�ã�x���꣩
    mov dl,79 ;���ڵ����½�λ�ã�y���꣩
    mov bh,7 ;�հ������ȱʡ����
    int 10h ;�жϺ�

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax
   mov ss,ax

showInfo:
	;����int10h��ʾ����ϵͳ�����������ʾ��Ϣ
	inc word[count]
	mov ax,cs
    mov es,ax
    mov bp,Message;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽes:bp��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0007h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ��ڵװ���
	mov dx,0912h ;dhΪ�кţ�dlΪ�к�
	mov cx,MessageLength
	int 10h

Judge:
   mov bx,5000
   mov ax,word[count]
   cmp ax,bx
   jz Quit
   jmp showInfo

Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret

Message:
    Info:db 'There are four programs of user!',0Dh,0Ah,0Dh,0Ah;
    UP1name:db '     UP1:Square      '
    UP1addr:db '||addr:0E00h~1000h:eighth section||size:407Bytes',0DH,0AH
	UP2name:db '     UP2:Single stone'
    UP2addr:db '||addr:1000h~1200h:ninth  section||size:438Bytes',0DH,0AH
	UP3name:db '     UP3:Double stone'
    UP3addr:db '||addr:1200h~1400h:tenth  section||size:508Bytes',0DH,0AH
	UP4name:db '     UP4:Sand clock  '
    UP4addr:db '||addr:1400h~1600h:eleven section||size:326Bytes',0DH,0AH
	MessageLength equ ($-Message)

datadef:
   count dw 0
	