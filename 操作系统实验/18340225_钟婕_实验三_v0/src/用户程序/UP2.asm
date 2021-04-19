
    org 0A100h; �������������ص��ڴ��еĳ�ʼƫ�Ƶ�ַΪ0A100h��

    ;�������³���;D-Down\U-Up\R-Right\L-Left
    Dn_Rt equ 1         		;1-����
    Up_Rt equ 2         		;2-����
    Up_Lt equ 3         		;3-����
    Dn_Lt equ 4         		;4-����
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
   mov ch,0 ;���ڵ����Ͻ�λ�ã�x���꣩
   mov cl,40 ;���ڵ����Ͻ�λ�ã�y���꣩
   mov dh,12 ;���ڵ����½�λ�ã�x���꣩
   mov dl,79 ;���ڵ����½�λ�ã�y���꣩
   mov bh,7 ;�հ������ȱʡ����
   int 10h ;�жϺ�

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
	    jz DnRt
	mov al,2
	cmp al,byte[initial]
	    jz UpRt
    mov al,3
	cmp al,byte[initial]
	    jz UpLt
	mov al,4
	cmp al,byte[initial]
	    jz DnLt
	jmp $

DnRt:
    inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,13
	sub ax,bx
	jz dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp display

dr2ur:
   mov word[x],11
   mov byte[initial],Up_Rt
   jmp display

dr2dl:
   mov word[y],78
   mov byte[initial],Dn_Lt
   jmp display

UpRt:
   dec word[x]
   inc word[y]
   mov ax,word[x]
   mov bx,-1
   sub ax,bx
   jz ur2dr
   mov bx,word[y]
   mov ax,80
   sub ax,bx
   jz ur2ul
   jmp display

 ur2dr:
   mov word[x],1
   mov byte[initial],Dn_Rt
   jmp display

ur2ul:
   mov word[y],78
   mov byte[initial],Up_Lt
   jmp display

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,13
   sub ax,bx
   jz dl2ul
   mov bx,word[y]
   mov ax,39
   sub ax,bx
   jz dl2dr
   jmp display

dl2ul:
   mov word[x],11
   mov byte[initial],Up_Lt
   jmp display

dl2dr:
   mov word[y],41
   mov byte[initial],Dn_Rt
   jmp display

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,-1
   sub ax,bx
   jz ul2dl
   mov bx,word[y]
   mov ax,39
   sub ax,bx
   jz ul2ur
   jmp display

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp display

ul2ur:
   mov word[y],41
   mov byte[initial],Up_Rt
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
  mov ah,01h
  int 16h
  mov bl,8
  cmp al,bl
  jz Quit
  mov bx,200
  mov ax,word[count]
  cmp ax,bx
  jz Quit
  jmp Loop

 Quit:
   ret

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   count dw 0
   initial db Dn_Rt
   x dw 1
   y dw 40
   color db 1
   char db 'A'

   