 org 7c00h ;�������������ص��ڴ��еĳ�ʼƫ�Ƶ�ַΪ07C00h��

 OffsetofUP equ 8100h

start:
    mov ax,cs ;�������Ĵ�����cs��ͬ
	mov ds,ax
	mov ax,ds
	mov es,ax
	mov bx,0B800H ;�Դ滺������ʼ��ַ
	mov gs,bx

;��ʾ�����ʾ
showInfo:
     ;ʹ��int10h�����Ϲ������崰�ڹ���
    mov ah,06h ;��ڲ��������ܺţ�ah=06h-���Ϲ�����ah=07h-���¹���
    mov al,0h ;����������0-�崰�ڣ�
    mov ch,0 ;���ڵ����Ͻ�λ�ã�x���꣩
    mov cl,0 ;���ڵ����Ͻ�λ�ã�y���꣩
    mov dh,12 ;���ڵ����½�λ�ã�x���꣩
    mov dl,39 ;���ڵ����½�λ�ã�y���꣩
    mov bh,7 ;�հ������ȱʡ����
    int 10h ;�жϺ�
	;����int10h��ʾ����ϵͳ�����������ʾ��Ϣ
    mov bp,Message;ƫ�Ƶ�ַ�����öε�ַ��ƫ�Ƶ�ַ��ʽ��ʾ����ַ
	mov ax,1301h ;ah=13hΪ���ܺţ�al=01hָ���λ�ڴ�β
	mov bx,0007h ;bh=00hΪҳ�룬bl=07hΪ��ʾ���ԣ��ڵװ���
	mov dx,0000h ;dhΪ�кţ�dlΪ�к�
	mov cx,MessageLength
	int 10h

;����ѡ��
Input:
    mov ah,0h 
	int 16h ;����16h���ж�����һ���ַ���ahΪ���ܺţ�������ַ�����al��
	cmp al,'0'
	jz Run
	cmp al,'1'
	jz UP
	cmp al,'2'
	jz UP
	cmp al,'3'
	jz UP
	cmp al,'4'
	jz UP
	cmp al,'5'
	jz DIY
	cmp al,'6'
	jz UP
	jmp Input ;ȷ���������0��1��2��3��4��5��6�е�һ��

;����int 13h���������ص�һ���û��������ڴ���Ӧλ��
;Ϊ�˼�㣬����һ���û������������̵ĵڶ�������
UP:
    sub al,47
	mov cl,al  ;������ʼ�����ţ��������Ǵ�һ��ʼ��
    mov ax,cs
	mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ
	mov bx,OffsetofUP ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
	mov ah,02h ;���ܺ�02h������
	mov al,1   ;����������
	mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��λ80h
	mov dh,0   ;��ͷ��Ϊ0
	mov ch,0   ;�����Ϊ0
	int 13h    ;�жϺ�
	jmp 800h:100h ;��һ���û������Ѿ����ص��ڴ���Ӧλ�ã�Ҫ��ת���ڴ���Ӧλ�ã���ʼִ�и��û�����
	
;���һ�����������һ��������ָ��ĳ��˳��ִ�����ɸ��û����򡣿��Է����������
DIY:
    mov ah,0h 
	int 16h ;����16h���ж�����һ���ַ���ahΪ���ܺţ�������ַ�����al��
	mov byte[arr],al
	mov ah,0h 
	int 16h ;����16h���ж�����һ���ַ���ahΪ���ܺţ�������ַ�����al��
	mov byte[arr+1],al
	mov ah,0h 
	int 16h ;����16h���ж�����һ���ַ���ahΪ���ܺţ�������ַ�����al��
	mov byte[arr+2],al
	mov ah,0h 
	int 16h ;����16h���ж�����һ���ַ���ahΪ���ܺţ�������ַ�����al��
	mov byte[arr+3],al
	mov bh,0
	mov bl,byte[arr+3]
	push bx
	mov bl,byte[arr+2]
	push bx
	mov bl,byte[arr+1]
	push bx
	mov bl,byte[arr]
	push bx
	jmp Run

Run:
    pop ax
	jmp UP

datadef:
	 arr db '1','2','3','4'

Message:
    db "Hello, welcome to My OS!",0AH,0DH ;�ַ����飬���Ϊ���з�
    db "Here is the start Memu.",0AH,0DH,"Input ' ' to exit UP.",0AH,0DH,"Please Enter the number:",0AH,0DH
    db "1.square",0AH,0DH
    db "2.single stone",0AH,0DH
    db "3.double stone",0AH,0DH
    db "4.sand clock",0AH,0DH
	db "5.DIY a special route.",0AH,0DH,"Please input '0' after every run!",0AH,0DH
	db "6.display the table.",0AH,0DH
    MessageLength  equ ($-Message) ;���˼�س�����Ϊ��������������
    times 510-($-$$) db 0 ;�á�0������������ʣ��λ��
    db 0x55,0xaa ;��������־



