org 100h;�������������ص��ڴ��еĳ�ʼƫ�Ƶ�ַΪ0A100h��
   Rt_ equ 1
   Dn_ equ 2
   Lt_ equ 3
   Up_ equ 4
   delay equ 50000
   ddelay equ 580

start:
    mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov ax,0B800H ;�ı�������ʼ��ַ
	mov gs,ax

;����int 10h��ʵ���崰�ڹ���
   ;��Ϊal=0hΪ�������ܣ���ʱ�����Ĵ�������������Ч
   mov ah,06h ;��ڲ��������ܺţ�ah=06h-���Ϲ�����ah=07h-���¹���
   mov al,0h ;����������0-�崰�ڣ�
   mov ch,0 ;���ڵ����Ͻ�λ�ã�x���꣩
   mov cl,0 ;���ڵ����Ͻ�λ�ã�y���꣩
   mov dh,12 ;���ڵ����½�λ�ã�x���꣩
   mov dl,39 ;���ڵ����½�λ�ã�y���꣩
   mov bh,7 ;�հ������ȱʡ����
   int 10h ;�жϺ�

;����int 10hʵ����ʾ�ַ�������
show:
   mov ax,cs
   mov es,ax
   mov ax,myName
   mov bp,ax;es:bp=������ַ:ƫ�Ƶ�ַ=����ַ
   mov cx,14;���ĳ���
   mov ax,1301h;ah=13h��ʾ�ַ���;al=01h���λ�ڴ�β
   mov bx,001dh;blΪ1dh ����ǳƷ������˸;bhΪ00h ҳ��Ϊ0
   mov dx,060Ah;��λ��
   int 10h;����10h���ж�
   mov ax,myNumber
   mov bp,ax;es:bp=������ַ:ƫ�Ƶ�ַ=����ַ
   mov cx,15;���ĳ���
   mov ax,1301h;ah=13h��ʾ�ַ���;al=01h���λ�ڴ�β
   mov bx,001dh;blΪ1dh����ǳƷ������˸;bhΪ00hҳ��Ϊ0
   mov dx,070Ah;��λ��
   int 10h;����10h���ж�

begin:
   xor ax,ax
   mov ax,cs
   mov ds,ax
   mov ax,ds
   mov es,ax
   mov ss,ax

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	inc word[count]
	mov al,1
	cmp al,byte[initial]
	    jz Rt
	mov al,2
	cmp al,byte[initial]
	    jz Dn
    mov al,3
	cmp al,byte[initial]
	    jz Lt
	mov al,4
	cmp al,byte[initial]
	    jz Up
	jmp $

Rt:
   inc word[y]
   mov bx,word[y]
   mov ax,36
   sub ax,bx
   jz Rt2Dn
   jmp display

Rt2Dn:
   mov word[y],35
   mov byte[initial],Dn_
   jmp display

Dn:
   inc word[x]
   mov bx,word[x]
   mov ax,11
   sub ax,bx
   jz Dn2Lt
   jmp display

Dn2Lt:
   mov word[x],10
   mov byte[initial],Lt_
   jmp display

Lt:
   dec word[y]
   mov bx,word[y]
   mov ax,3
   sub ax,bx
   jz Lt2Up
   jmp display

Lt2Up:
   mov word[y],4
   mov byte[initial],Up_
   jmp display

Up:
   dec word[x]
   mov bx,word[x]
   mov ax,1
   sub ax,bx
   jz Up2Rt
   jmp display

Up2Rt:
   mov word[x],2
   mov byte[initial],Rt_
   jmp display

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
   add byte[color],1
   add byte[char],1   ;����
   mov bl,8
   cmp byte[color],bl ;�ж��Ƿ����
   jz circle1         ;�������ת��circle1
   mov bl,90
   cmp byte[char],bl   ;�ж��Ƿ����
   jz circle2          ;�������ת��circle2
   jmp Judge

circle1:
   mov byte[color],1    ;����color������
   mov bl,90
   cmp byte[char],bl
   jz circle2
   jmp Judge

circle2:
   mov byte[char],65    ;����char������
   jmp Judge


;�������ֹ���û�����ո����ֹ
;����int 16h����һ���ַ��ж�
Judge:
  mov ah,01h
  int 16h
  mov bl,8
  cmp al,bl
  jz Quit
  mov bx,150
  mov ax,word[count]
  cmp ax,bx
  jz Quit
  jmp Loop

Quit:
    mov ah,20H
	mov al,0CDH
	mov word[es:0],ax
	mov ax,0
	push ax
    ret;retָ����ջ�е����ݣ��޸�IP�����ݣ��Ӷ�ʵ�ֽ�ת��

end:
   jmp $

datadef:
  num dw delay
  dnum dw ddelay
  count dw 0
  x dw 2
  y dw 4
  initial db Rt_
  char db 'A'
  color db 1
  myName: db "Name:Zhong Jie"
  myNumber: db "Number:18340225"


   