 org 100h; �������������ص��ڴ��еĳ�ʼƫ�Ƶ�ַΪ0A100h��

    ;�������³���;D-Down\U-Up\R-Right\L-Left
    Rt_ equ 1         		    ;1-��
    Dn_Lt equ 2         		;2-����
	Up_Lt equ 3                 ;3-����
    delay equ 50000 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�
    ddelay equ 580	 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�

;��ʼ���Ĵ�����ֵ
Begin:
    mov ax,cs                   ;csΪ����μĴ���
	mov es,ax                   ;��es=cs
	mov ds,ax                   ;ds=cs
	mov ss,ax
	mov ax,0B800h                ;B800hΪ�Դ滺��������ʼ��ַ
	mov gs,ax                   ;��ȫ�ֶμĴ�����ֵ=B800h

;����int 10h��ʵ���崰�ڹ���
   ;��Ϊal=0hΪ�������ܣ���ʱ�����Ĵ�������������Ч
   mov ah,06h ;��ڲ��������ܺţ�ah=06h-���Ϲ�����ah=07h-���¹���
   mov al,0h ;����������0-�崰�ڣ�
   mov ch,13 ;���ڵ����Ͻ�λ�ã�x���꣩
   mov cl,40 ;���ڵ����Ͻ�λ�ã�y���꣩
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
	    jz DnLt
    mov al,3
	cmp al,byte[initial]
	    jz UpLt
	jmp $


Rt:
   inc word[y]
   mov bx,word[y]
   mov ax,56
   sub ax,bx
   jz Rt2DnLt
   jmp display

Rt2DnLt:
   mov bx,word[x]
   mov ax,24
   sub ax,bx
   jz Rt2UpLt
   mov word[y],55
   mov byte[initial],Dn_Lt
   jmp display

Rt2UpLt:
   mov word[y],55
   mov byte[initial],Up_Lt
   jmp display

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,25
   sub ax,bx
   jz DnLt2Rt
   jmp display

DnLt2Rt:
   mov word[x],24
   mov word[y],45
   mov byte[initial],Rt_
   jmp display

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,13
   sub ax,bx
   jz UpLt2Rt
   jmp display

UpLt2Rt:
   mov word[x],14
   mov word[y],45
   mov byte[initial],Rt_
   jmp display

display:
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
   mov bx,500
   mov ax,word[count]
   cmp ax,bx
   jz Quit
   jmp Loop

 Quit:
    ;mov ah,20H
	;mov al,0CDH
	;mov word[es:0],ax
	;mov ax,0
	;push ax
    ;ret
	jmp $

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   count dw 0
   initial db Rt_
   x dw 14
   y dw 45
   color db 1
   char db 'A'
   