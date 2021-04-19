
    org 7c00h; �������������ص��ڴ��������ַΪ7c00h��

    ;�������³���;D-Down\U-Up\R-Right\L-Left
    Dn_Rt equ 1         		;1-����
    Up_Rt equ 2         		;2-����
    Up_Lt equ 3         		;3-����
    Dn_Lt equ 4         		;4-����
    delay equ 50000 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�
    ddelay equ 580	 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�

Start:
	mov ax, cs    			;�������μĴ���ֵ��CS��ͬ
	mov ds, ax    			;���ݶ�ds
	mov bp, Message 		;BP=��ǰ����ƫ�Ƶ�ַ
	mov ax, ds 				;ES:BP=������ַ:��ƫ�Ƶ�ַ=����ַ
	mov es, ax 				;��ES=DS
	mov cx, MessageLength 	;CX=������ 
	mov ax, 01301H 			;AH=13h(���ܺ�;��ʾ�ַ���);AL=01h(������ڴ�β)
	mov bx, 001FH 			;ҳ��Ϊ0(BH=0);���װ��ָ�������˸(BL=1Fh)
	mov dx, 0				;�к�dh=0;�к�dl=0
	int 10H 				;10h���ж�

Load:
	;��ȡ����������ES:BX��
	mov ax, cs        		;�ε�ַ
	mov es, ax        		;ES=�ε�ַ
	mov bx, 7E00H 			;BX=ƫ�Ƶ�ַ
	mov ah, 02H         	;���ܺ�02H;������
	mov al, 01H         	;AL=������
	mov ch, 00H         	;CH=�����;��ʼ���Ϊ0
	mov cl, 02H         	;CL=��ʼ������;��ʼ���Ϊ1
	mov dh, 00H         	;DH=��ͷ��;��ʼ���Ϊ0
	mov dl, 00H        		;DL=��������;����������
	int 13H 				;���ö�����BIOS��13h����
	;�������������Ѽ��ص�ָ���ڴ�������
	jmp 7E00H

After:
   jmp $           			;����ѭ��	
	
Message:
    db '18340225', 0DH, 0AH
    db 'Zhong Jie'
	MessageLength equ ($-Message)
	times 510-($-$$) db 0 	;���ʣ�µĿռ�;ʹ���ɵĶ����ƴ���ǡ��Ϊ512�ֽ�
	dw 0xaa55 				;������־


;��ʼ���Ĵ�����ֵ
Begin:
    mov ax,cs                   ;csΪ����μĴ���
	mov es,ax                   ;��es=cs
	mov ds,ax                   ;ds=cs
	mov ax,0B800h                ;B800hΪ�Դ滺��������ʼ��ַ
	mov gs,ax                   ;��ȫ�ֶμĴ�����ֵ=B800h

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
	mov ax,0
	cmp ax,word[standard]
	    jz ch1
	jmp ch0

ch0:
    mov word[standard],0
	mov ax,[arr+2]
	mov word[y],ax
	jmp Swi

ch1:
    mov word[standard],2
	mov ax,[arr]
	mov word[y],ax
	jmp Swi

Swi:
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
	mov ax,25
	sub ax,bx
	jz dr2ur
	mov bx,[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp WB

dr2ur:
   mov word[x],23
   mov byte[initial],Up_Rt
   jmp WB 

dr2dl:
   mov word[y],78
   mov byte[initial],Dn_Lt
   jmp WB

UpRt:
   dec word[x]
   inc word[y]
   mov ax,word[x]
   mov bx,-1
   sub ax,bx
   jz ur2dr
   mov bx,[y]
   mov ax,80
   sub ax,bx
   jz ur2ul
   jmp WB

 ur2dr:
   mov word[x],1
   mov byte[initial],Dn_Rt
   jmp WB

ur2ul:
   mov word[y],78
   mov byte[initial],Up_Lt
   jmp WB

DnLt:
   inc word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,25
   sub ax,bx
   jz dl2ul
   mov bx,[y]
   mov ax,-1
   sub ax,bx
   jz dl2dr
   jmp WB

dl2ul:
   mov word[x],23
   mov byte[initial],Up_Lt
   jmp WB

dl2dr:
   mov word[y],1
   mov byte[initial],Dn_Rt
   jmp WB

UpLt:
   dec word[x]
   dec word[y]
   mov bx,word[x]
   mov ax,-1
   sub ax,bx
   jz ul2dl
   mov bx,[y]
   mov ax,-1
   sub ax,bx
   jz ul2ur
   jmp WB

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp WB

ul2ur:
   mov word[y],1
   mov byte[initial],Up_Rt
   jmp WB

WB:
   mov ax,0
   cmp ax,word[standard]
       jz WB1
   mov ax,word[y]
   mov word[arr],ax
   jmp display

WB1:
   mov ax,word[y]
   mov word[arr+2],ax
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
   jz c1         ;�������ת��circle1
   mov bl,90
   cmp byte[char],bl   ;�ж��Ƿ����
   jz c2          ;�������ת��circle2
   jmp Loop


c1:
   mov byte[color],1    ;����color������
   mov bl,90
   cmp byte[char],bl
   jz c2
   jmp Loop

c2:
   mov byte[char],65    ;����char������
   jmp Loop

end:
   jmp $

datadef:
   num dw delay
   dnum dw ddelay
   initial db Dn_Rt
   x dw 2
   y dw 3
   arr dw 3 ,8
   standard dw 0
   color db 1
   char db 'A'
 

