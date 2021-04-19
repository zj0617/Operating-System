;����ʵ��һЩӲ���ϵ�����
;����BIOS��һЩ������ϵͳ����

extern _InCh ;ȫ�ֱ�����������C��������֮�䡰ͨ�š���������������һ���ַ�

;�ֲ��ַ�������ʼ����Ϊʵ�����ⲹ������
public SCOPY@
SCOPY@ proc 
	arg_0 = dword ptr 6
	arg_4 = dword ptr 0ah
	push bp
	mov bp,sp
	push si
	push di
	push ds
	lds si,[bp+arg_0]
	les di,[bp+arg_4]
	cld
	shr cx,1
	rep movsw
	adc cx,cx
	rep movsb
	pop ds
	pop di
	pop si
	pop bp
	retf 8
SCOPY@ endp

public _clear ;Ϊ�˷���C������ü����»���
_clear proc 
; ����
	push ax ;���������Ĵ�����ֵ����Ϊ��BIOS���û������Щ�Ĵ�����ֵ��������Ҫ�����ֳ�
	push bx
	push cx
	push dx	
	;ʹ��int10h�����Ϲ������崰�ڹ���
    mov ah,06h ;��ڲ��������ܺţ�ah=06h-���Ϲ�����ah=07h-���¹���
    mov al,0h ;����������0-�崰�ڣ�
    mov ch,0 ;���ڵ����Ͻ�λ�ã�x���꣩
    mov cl,0 ;���ڵ����Ͻ�λ�ã�y���꣩
    mov dh,24 ;���ڵ����½�λ�ã�x���꣩
    mov dl,79 ;���ڵ����½�λ�ã�y���꣩
    mov bh,7 ;�հ������ȱʡ����
	mov bl,0
    int 10h ;�жϺ�
	mov ah,2
	mov bh,0
	mov dx,0
	int 10h
	pop dx ;�ָ��Ĵ�����ֵ�����ָ��ֳ�
	pop cx ;�����Ĳ��������ڷ�ֹ�������һЩ��ֵĴ��󣬾��������ڵ��ù����жԼĴ������ƻ�
	pop bx
	pop ax
	ret   ;���أ���Ϊ��Щ����ģ����Ǳ�����ִ�еģ���Ҫ����������
_clear endp

;�����жϺ�16h��0h���ܶ���һ���ַ�
public _scanfCh
_scanfCh proc
    mov ah,0 ;���ܺ�
	int 16h
	mov byte ptr [_InCh],al ;��һ���ַ�ָ�뱣��������ַ�,InChΪCģ��ı���
	ret
_scanfCh endp

;ʵ��Ҫ����һ����洢�û����������Ϣ����֮����ڵ�11��������������Ϊ������û�����
OffsetofUP equ 0A100H
;�û���������ʱ��Ҫ��Ӧ�Զ���ļ����ж�
;Ϊ�˱�֤�û������������ʱ�����ָ̻�����Ҫ����ԭ���ļ����ж�
public _UP
_UP proc
   push ax
   push bx
   push cx
   push dx
   push ds
   push es
   push bp ;�����ֳ�������ds��es��bp�Ĵ�����ֵ

   ;����������09h��������
   xor ax,ax
   mov es,ax
   mov bp,offset normal
   ;����ptr���ã���es:[]��;
   mov ax,word ptr es:[36] ;����IPֵ
   mov word ptr [bp],ax
   mov ax,word ptr es:[38] ;����csֵ
   mov word ptr [bp+2],ax

   ;�޸ļ����ж�Ϊ�Զ����ж�int09h
   mov word ptr es:[36],offset int09h
   mov word ptr es:[38],cs

   mov bp,sp;��bp����ջ�д���Ĳ�������ΪIP��ds��es��bp.axѹջ�����Բ�����bp+10��λ��
   mov ax,cs
   mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
   mov bx,OffsetofUP ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
   mov ah,02h ;���ܺ�02h������
   mov al,1   ;����������
   mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
   mov dh,0   ;��ͷ��Ϊ0
   mov cx,[bp+16] ;��ʼ�����ţ���Ŵ�1��ʼ������Ĳ�����Ϊ��Ӧ�û�������������
   mov ch,0   ;�����Ϊ0
   sub cl,48
   int 13h    ;�жϺ�
   ;����Ӧ�û�������ص��ڴ�Ϊ0800H:8c00H��
   mov bx,OffsetofUP ;��ƫ�Ƶ�ַ��ֵ��bx
   call bx ;������ת����Ӧ�ڴ�λ��ִ���û�����
   
   ;�ָ������ļ����ж�
   xor ax,ax
   mov es,ax
   mov bp,offset normal
   mov ax,word ptr [bp] ;����+ptrָ���������ͣ�ptr����ȡ�ڴ��ַ��ֵҲ������Ϊָ���������ͣ�
   mov word ptr es:[36],ax
   mov ax,word ptr [bp+2]
   mov word ptr es:[38],ax

   pop bp
   pop es
   pop ds ;�ָ��ֳ��������ջ
   pop dx
   pop cx
   pop bx
   pop ax
   ret ;����ģ�鷵��
_UP endp


OffsetofINT equ 0B100H
;ʵ��Ҫ��һ���û��������21h��22h��23h��24h�ж�
;�жϼ����ó���
public _RunInt
_RunInt proc
   push ds
   push es;�����ֳ�������ds��es�Ĵ�����ֵ
   push ax
   push bx
   push cx
   push dx
   mov ax,cs
   mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
   mov bx,OffsetofINT ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
   mov ah,02h ;���ܺ�02h������
   mov al,1   ;����������
   mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
   mov dh,0   ;��ͷ��Ϊ0
   mov ch,0   ;�����Ϊ0
   mov cl,14   ;��ʼ������
   int 13h    ;�жϺ�
   ;����Ӧ�û�������ص��ڴ�Ϊ0800H:0B100H��
   mov bx,OffsetofINT ;��ƫ�Ƶ�ַ��ֵ��bx
   call bx ;������ת����Ӧ�ڴ�λ��ִ���û�����
   pop dx
   pop cx
   pop bx
   pop ax
   pop es
   pop ds ;�ָ��ֳ��������ջ
   ret ;����ģ�鷵��
_RunInt endp




;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _printfCh
_printfCh proc
    push bp ;����bp��ֵ����Ϊ������Ҫ��bpȥ����ջ��������ջ�У�
	mov bp,sp ;ջ��ָ��sp����bp
	mov ax,[bp+4]
	mov ah,0EH ;ahΪ���ܺ�
	mov bl,0h ;ǰ��ɫ��ͼ��ģʽ��
	int 10h
	mov sp,bp
	pop bp ;�ָ�bp��ֵ
	ret   ;����
_printfCh endp

;��дʱ���ж�08h����������
;ע������������һֱִ�е�
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

  dec byte ptr es:[count]
  jz Judge
  jmp INTR

Judge:
  mov byte ptr es:[count],delay ;�ﵽ����ʱ���ж����һ�Σ���ʱ������Ҫ����
  cmp byte ptr es:[state],1
  jz C1
  cmp byte ptr es:[state],2
  jz C2
  cmp byte ptr es:[state],3
  jz C3
  cmp byte ptr es:[state],4
  jz C4
 
C1:
  mov al,byte ptr es:[ch1]
  inc byte ptr es:[state]
  jmp show

C2: 
  mov al,byte ptr es:[ch2]
  inc byte ptr es:[state]
  jmp show

C3:
  mov al,byte ptr es:[ch3]
  inc byte ptr es:[state]
  jmp show

C4: 
  mov al,byte ptr es:[ch4]
  mov byte ptr es:[state],1 ;״̬��1~4�仯������ǰ״̬Ϊ4ʱ��Ϊ0
  jmp show

show:
   mov ah,0Fh		; 0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
   push es
   mov bx,0B800h		; �ı������Դ���ʼ��ַ
   mov es,bx		; ES = B800h
   mov es:[((80*24+79)*2)],ax
   pop es
   mov byte ptr es:[count],delay

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
  state db 1
  ch1 db '|'
  ch2 db '/'
  ch3 db '-'
  ch4 db '\'
  delay equ 6
  count db delay

;09h�ż����ж�
;Ҫ�����û���������ʱ��Ӧ
;�������û�����ʱ���ܸ���������������
;�жϺ�15h
;����86H 
;�����������ӳ� 
;��ڲ�����AH��86H 
;CX:DX��ǧ���� 
;���ڲ�����CF��0���������ɹ���AH��00H 
int09h:
   ;�����Ĵ���
  ;���мĴ����ڴ˹��̻ᱻ�ı䣬��Ҫ����
  push ax
  push bx
  push cx
  push dx
  push ds
  push es
  push bp

  mov ax,cs
  mov es,ax
  mov ah,13h 
  mov al,0    
  mov bl,byte ptr es:[color]	                      
  mov bh,0 	                    
  mov dh,12 	                      
  mov dl,35
  mov bp,offset Info
  mov cx,11
  int 10h 
  inc byte ptr es:[color]
  mov al,8
  cmp al,byte ptr es:[color]
  jz Reset
  jmp Dump

Reset:
  mov byte ptr es:[color],1
  jmp Dump

  ;BIOS��ʱ���ã����ַ�����ʾͣ��һ�������
Dump:
  push ax
  push cx
  push dx
  mov ah,86h ;BIOS��15h�жϺ�86h���ܺŵ���ʱ����
  mov cx,0Fh ;CX��DX= ��ʱʱ�䣨��λ��΢�룩��CX�Ǹ��֣�DX�ǵ���
  mov dx,4240h ;1s=1000000us=0x0F4240
  int 15h
  pop dx;ע��Ҫ�ָ��ֳ���
  pop cx
  pop ax

  ;����10h���жϺ�ʵ������
  ;��ʾ��λ���Ǵӣ�12��35����ʼ�ģ�һ����ʾ
  ;�����ouchλ�õ��ַ���
  mov ah,6
  mov al,0
  mov ch,12 ;���������Ͻ�����
  mov cl,35
  mov dh,12 ;���������½�����
  mov dl,45
  mov bh,7 ;Ĭ�����ԣ��ڵ�
  int 10H
    
  in al,60h
  mov al,20h					    ; AL = EOI
  out 20h,al						; ����EOI����8529A
  out 0A0h,al					    ; ����EOI����8529A

  pop bp
  pop es
  pop ds
  pop dx
  pop cx
  pop bx
  pop ax
  iret;

  Info db "OUCH! OUCH!"
  color db 1

;��д21h~24h�жϷ�����򣬷ֱ�ִ���ĸ��û�����
int21h:
   mov ax,56
   push ax
   call _UP
   pop ax
   iret

int22h:
   mov ax,57
   push ax
   call _UP
   pop ax
   iret

int23h:
   mov ax,58
   push ax
   call _UP
   pop ax
   iret

int24h:
   mov ax,59
   push ax
   call _UP
   pop ax
   iret

Data:
  normal dw 0,0