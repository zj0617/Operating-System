org 0100H

start:
    mov ax,cs ;�������Ĵ�����cs��ͬ
	mov ds,ax
	mov ax,ds
	mov es,ax

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

showInfo:
	;����int10h��ʾ����ϵͳ�����������ʾ��Ϣ
    mov bp,Message;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0007h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ��ڵװ���
	mov dx,0000h ;dhΪ�кţ�dlΪ�к�
	mov cx,MessageLength
	int 10h

Judge:
   mov ah,01h
   int 16h
   mov bl,20h
   cmp al,bl
   jz Quit
   jmp showInfo

Quit:
    jmp 0:7C00H

Message:
    Info:db 'There are four programs of user!',0Dh,0Ah;
    UP1name:db 'Square'
    UP1addr:db '  addr:0200h~0400h:second section',0DH,0AH
	UP2name:db 'Single stone'
    UP2addr:db '  addr:0400h~0600h:third section',0DH,0AH
	UP3name:db 'Double stone'
    UP3addr:db '  addr:0600h~0800h:fourth section',0DH,0AH
	UP4name:db 'Sand clock '
    UP4addr:db '  addr:0800h~0A00h:fifth section',0DH,0AH
	MessageLength equ ($-Message)
	