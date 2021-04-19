org 100h
;��дʱ���ж�08h����������
;ע������������һֱִ�е�
    Dn_Rt equ 1         		;1-����
    Up_Rt equ 2         		;2-����
    Up_Lt equ 3         		;3-����
    Dn_Lt equ 4         		;4-����
    delay equ 500 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�
    ddelay equ 58	 			;��ʱ���ӳټ���;���ڿ��ƻ�����ٶ�

start:
   xor ax,ax
   mov es,ax
   mov word[es:32],Timer
   mov word[es:34],cs
   mov ax,cs
   mov es,ax
   mov ds,ax
   mov ss,ax
   mov ax,0B800H
   mov gs,ax

;��ʾ�������� ѧ��
PersonnalInf:
    mov ax,myName
	mov bp,ax;es:bp=������ַ:ƫ�Ƶ�ַ=����ַ
	mov cx,9;���ĳ���
	mov ax,1301h;ah=13h��ʾ�ַ���;al=01h���λ�ڴ�β
	mov bx,001dh;blΪ1dh ����ǳƷ������˸;bhΪ00h ҳ��Ϊ0
	mov dx,00h;dh�к�=0h;dl�к�=0h
	int 10h;����10h���ж�
    mov ax,myNumber
	mov bp,ax;es:bp=������ַ:ƫ�Ƶ�ַ=����ַ
	mov cx,8;���ĳ���
	mov ax,1301h;ah=13h��ʾ�ַ���;al=01h���λ�ڴ�β
	mov bx,001dh;blΪ1dh����ǳƷ������˸;bhΪ00hҳ��Ϊ0
	mov dx,0100h;dh�к�=01h;dl�к�=00h
	int 10h;����10h���ж�

Loop:
    dec word[num]
	jnz Loop
	mov word[num],delay
	dec word[dnum]
	jnz Loop
	mov word[num],delay
	mov word[dnum],ddelay
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
	mov bx,word[y]
	mov ax,80
	sub ax,bx
	jz dr2dl
	jmp display

dr2ur:
   mov word[x],23
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
   mov ax,25
   sub ax,bx
   jz dl2ul
   mov bx,word[y]
   mov ax,-1
   sub ax,bx
   jz dl2dr
   jmp display

dl2ul:
   mov word[x],23
   mov byte[initial],Up_Lt
   jmp display

dl2dr:
   mov word[y],1
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
   mov ax,-1
   sub ax,bx
   jz ul2ur
   jmp display

ul2dl:
   mov word[x],1
   mov byte[initial],Dn_Lt
   jmp display

ul2ur:
   mov word[y],1
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
   jmp Loop

circle1:
   mov byte[color],1    ;����color������
   mov bl,90
   cmp byte[char],bl
   jz circle2
   jmp Loop

circle2:
   mov byte[char],65    ;����char������
   jmp Loop

end:
   jmp $

Timer:
  ;�����Ĵ���
  ;���мĴ����ڴ˹��̻ᱻ�ı䣬��Ҫ����
  push ax
  push bx
  push cx
  push dx
  push bp
  push es
  push ds

  dec byte[tcount]
  jz tJudge
  jmp INTR

tJudge:
  mov byte[tcount],tdelay ;�ﵽ����ʱ���ж����һ�Σ���ʱ������Ҫ����
  cmp byte[state],1
  jz C1
  cmp byte[state],2
  jz C2
  cmp byte[state],3
  jz C3
  cmp byte[state],4
  jz C4
 
C1:
  mov al,byte[ch1]
  inc byte[state]
  jmp tshow

C2: 
  mov al,byte[ch2]
  inc byte[state]
  jmp tshow

C3:
  mov al,byte[ch3]
  inc byte[state]
  jmp tshow

C4: 
  mov al,byte[ch4]
  mov byte[state],1 ;״̬��1~4�仯������ǰ״̬Ϊ4ʱ��Ϊ0
  jmp tshow

tshow:
   mov ah,0Fh		; 0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
   mov word[gs:((80*24+79)*2)],ax
   mov byte[tcount],tdelay

INTR:
  mov al,20h
  out 20h,al			;����EOI����8529A 
  out 0A0h,al           ;���͸���8529A

  pop ds
  pop es
  pop bp
  pop dx
  pop cx
  pop bx
  pop ax
  iret;

datadef:
  num dw delay
  dnum dw ddelay
  initial db Dn_Rt
  x dw 2
  y dw 3
  color db 1
  char db 'A'
  myName db "Zhong Jie"
  myNumber db "18340225"
  tdelay equ 4
  tcount db tdelay
  state db 1
  ch1 db '|'
  ch2 db '/'
  ch3 db '-'
  ch4 db '\'
