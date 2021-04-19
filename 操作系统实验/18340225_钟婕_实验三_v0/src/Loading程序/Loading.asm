org 0A100H

   delay equ 50000
   ddelay equ 1580

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
	mov ch,2 ;���Ͻ�X����
	mov cl,10 ;���Ͻ�Y����
	mov dh,21 ;���½�X����
	mov dl,70 ;���½�Y����
	mov bh,0x10;�հ��������ʾ���ԣ����׺��֣�����˸�޼���
	int 10h ;BIOS���ܵ���

showInfo:
    ;����int10h��ʾ����ϵͳ�����������ʾ��Ϣ
	mov ax,cs
	mov es,ax
    mov bp,Message;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,00deh ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ���׻��֣�����˸
	mov dx,0a19h ;dhΪ�кţ�dlΪ�к�,��10�У�25��
	mov cx,MessageLength
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str0
	mov ax,1301h
	mov bx,00deh
	mov dx,0c13h
	mov cx,42
	int 10h
	mov ax,cs
	mov es,ax
	mov bp,str
	mov ax,1301h
	mov bx,001fh
	mov dx,1228h
	mov cx,11
	int 10h

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	jmp Rt

Rt:
    inc word[y]
	mov bx,word[y]
	mov ax,56
	cmp ax,bx
	jnz display
	jmp Quit

display:
    xor ax,ax
    mov ax,word[x]
    mov bx,80
    mul bx
    add ax,word[y]
    mov bx,2
    mul bx        ;�����Դ�ƫ�Ƶ�ַ
    mov bp,ax
    mov ah,[color] ;��ʾ����
    mov al,byte[char]  ;��ʾ�ַ�
    mov word[gs:bp],ax  ;����Ӧ�Դ��ַд��
    jmp Loop
	jmp Quit


Message:
      db  "     Welcome to my OS!     ",0DH,0AH
	  MessageLength equ ($-Message)

Quit:
    ret 

end:
    jmp $

datadef:	
    x  dw 19
    y  dw 30	
	num dw delay
	dnum dw ddelay
	color db 0x73
	char db 32
	str0: db "Author:Zhong Jie & Student Number:18340225"
	str: db "Loading...."

    times 512 - ($ - $$) db 0 
