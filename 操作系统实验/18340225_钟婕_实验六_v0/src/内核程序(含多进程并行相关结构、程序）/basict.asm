;����ʵ��һЩӲ���ϵ�����
;����BIOS��һЩ������ϵͳ����

extern _InCh ;ȫ�ֱ�����������C��������֮�䡰ͨ�š���������������һ���ַ�

extrn _segment
extrn _sec

extrn _Current_PCB
extrn _Save_PCB
extrn _Process_Schedule
extrn _Fornew
extrn _process_num
extrn _cur_pnum


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

;ϵͳ���õĹ��ܺ�Ϊ0
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
	ret
_clear endp

;ϵͳ���õĹ��ܺ�Ϊ1
;�����жϺ�16h��0h���ܶ���һ���ַ�
public _scanfCh
_scanfCh proc
    mov ah,0 ;���ܺ�
	int 16h
	mov byte ptr [_InCh],al ;��һ���ַ�ָ�뱣��������ַ�,InChΪCģ��ı���
	ret
_scanfCh endp

;ϵͳ���õù��ܺ�Ϊ2
;ʵ��Ҫ����һ����洢�û����������Ϣ����֮����ڵ�11��������������Ϊ������û�����
OffsetofUP equ 0A100H
;�û���������ʱ��Ҫ��Ӧ�Զ���ļ����ж�
;Ϊ�˱�֤�û������������ʱ�����ָ̻�����Ҫ����ԭ���ļ����ж�
public _UP
_UP proc
   push ax
   push ds
   push es
   push bp ;�����ֳ�������ds��es��bp�Ĵ�����ֵ
   xor ax,ax
   mov es,ax
   mov word ptr es:[32*4],offset int20h1
   mov word ptr es:[32*4+2],cs
   mov bp,sp;��bp����ջ�д���Ĳ�������ΪIP��ds��es��bp.axѹջ�����Բ�����bp+10��λ��
   mov ax,cs
   mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
   mov bx,OffsetofUP ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
   mov ah,02h ;���ܺ�02h������
   mov al,1   ;����������
   mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
   mov dh,1   ;��ͷ��Ϊ1
   mov cx,[bp+10] ;��ʼ�����ţ���Ŵ�1��ʼ������Ĳ�����Ϊ��Ӧ�û����������������޿ӣ�������int\ip1\ax\ds\es\bp����ջ�У�����
   mov ch,0   ;�����Ϊ0
   sub cl,48
   int 13h    ;�жϺ�
   ;����Ӧ�û�������ص��ڴ�Ϊ0800H:8c00H��
   mov word ptr [bx],100h
   mov word ptr 2[bx],1200h
   jmp dword ptr [bx]

int20h1:
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   pop bp
   pop es
   pop ds
   pop bp
   pop es
   pop ds ;�ָ��ֳ��������ջ
   pop ax
   ret

_UP endp



public _RT
_RT proc
   push ax
   push ds
   push es
   push bp ;�����ֳ�������ds��es��bp�Ĵ�����ֵ
   xor ax,ax
   mov es,ax
   mov word ptr es:[32*4],offset int20h2
   mov word ptr es:[32*4+2],cs
   mov bp,sp;��bp����ջ�д���Ĳ�������ΪIP��ds��es��bp.axѹջ�����Բ�����bp+10��λ��
   mov ax,cs
   mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
   mov bx,0B100h ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
   mov ah,02h ;���ܺ�02h������
   mov al,4   ;����������
   mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
   mov dh,1   ;��ͷ��Ϊ1
   mov cx,[bp+10] ;��ʼ�����ţ���Ŵ�1��ʼ������Ĳ�����Ϊ��Ӧ�û����������������޿ӣ�������int\ip1\ax\ds\es\bp����ջ�У�����
   mov ch,0   ;�����Ϊ0
   sub cl,48
   int 13h    ;�жϺ�
   ;����Ӧ�û�������ص��ڴ�Ϊ0800H:8c00H��
   mov word ptr [bx],100h
   mov word ptr 2[bx],1300h
   jmp dword ptr [bx]

int20h2:
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   ret

_RT endp

;ϵͳ���õù��ܺ�Ϊ4
;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _printfCh
_printfCh proc
    push bp ;����bp��ֵ����Ϊ������Ҫ��bpȥ����ջ��������ջ�У�
	mov bp,sp ;ջ��ָ��sp����bp
	mov ax,[bp+4];�޿ӣ���������char\ip1\bp����ջ��
	mov ah,0EH ;ahΪ���ܺ�
	mov bl,0h ;ǰ��ɫ��ͼ��ģʽ��
	int 10h
	mov sp,bp
	pop bp ;�ָ�bp��ֵ
	ret
_printfCh endp

public _T22
_T22 proc
     int 22h
	 ret
_T22 endp

;*****************************************
;*           _LoadPro                    *
;*         �����û�����                  *
;*****************************************
public _LoadPro
_LoadPro proc
    push ax
	push bp;ջ��sec/seg/ip/ax/bp

	mov bp,sp
	mov ax,[bp+6]
    mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
    mov bx,100h ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
    mov ah,02h ;���ܺ�02h������
    mov al,1   ;����������
    mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
    mov dh,1   ;��ͷ��Ϊ1
    mov cl,[bp+8] ;��ʼ�����ţ���Ŵ�1��ʼ������Ĳ�����Ϊ��Ӧ�û����������������޿ӣ�������int\ip1\ax\ds\es\bp����ջ�У�����
	cmp cl,8
	jz Par
    mov ch,0   ;�����Ϊ0
    int 13h    ;�жϺ�

	pop bp
	pop ax
	
	ret

Par:
    mov al,4
    mov ch,0   ;�����Ϊ0
    int 13h    ;�жϺ�
	pop bp
	pop ax
	ret

_LoadPro endp

;*****************************************
;*           _SetTimer                   *
;*      ����ʱ���жϵ�Ƶ��               *
;*****************************************
;ͨ�����˿� 0x43 д������������ù�����ʽ�����˿� 0x40 д�������ֵ��
public _SetTimer
_SetTimer proc
    push ax
    mov al,34h   ; ���ÿ����� 
    out 43h,al   ; ����outָ���д������д�������ּĴ��� 
    mov ax,29830 ; ����ÿ�� 20 ���жϣ�50ms һ�Σ��������жϵ��ٶȣ�ax��Ϊ��������ֵ 
    out 40h,al   ; ��ax��������λ��ֵд������� 0 �ĵ��ֽ� 
    mov al,ah    ; AL=AH 
    out 40h,al   ; ��ax��������λ��ֵд������� 0 �ĸ��ֽ� 
	pop ax
	ret
_SetTimer endp

;��ʱ�����ʱ�����û����������Ҫ�л�ʱ���жϴ������
public _ChangeTimer
_ChangeTimer proc
    push ax
	push es
	
	;����ʱ���ж�Ƶ�ʣ�ԭ����18.206Hz,�ĳ�ÿ��20��
    call near ptr _SetTimer
    xor ax,ax
	mov es,ax
	mov word ptr es:[20h],offset TimerPro ;��ʱ���ж�
	mov word ptr es:[22h],cs
	
	pop ax
	mov es,ax
	pop ax
	ret
_ChangeTimer endp

;�趨һ����������¼��ʱ�����ǵ��ܵĵ��ȴ���
Sche_num dw 0
;*****************************************
;*           ʱ���ж��л��û�����        *
;*****************************************
TimerPro:
    cmp word ptr[_process_num],0
	jnz PreSave
	jmp None_Program
PreSave:
	inc word ptr [Sche_num]
	cmp word ptr[Sche_num],500
	jnz Save
	mov word ptr[_process_num],0
	mov word ptr[_cur_pnum],0
	mov word ptr[Sche_num],0
	mov word ptr[_segment],2000H
	jmp redone
Save:
    push ss
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push si
	push di
	push ds
	push es
	.386
	push fs
	push gs
	.8086

	mov ax,cs;Ҫ�ǵ����¸��μĴ�����ֵ����������ô���
	mov es,ax
	mov ds,ax
	;������cģ���������֮��Ҫ�Լ���ջ������
	call near ptr _Save_PCB;�жϵ�����ģʽ�л���ʱ�������Ҫ�����жϵĽ��̵������ı����ڸý��̵Ľ��̿��ƿ���
	call near ptr _Process_Schedule

	.386
	pop gs
	pop fs
	.8086
	pop es
	pop ds
	pop di
	pop si
	pop bp
	pop sp
	pop dx
	pop cx
	pop bx
	pop ax
	pop ss

redone:
    mov ax,cs
	mov es,ax
	mov ds,ax
	call near ptr Timer;������Ҫ��ʾ�޵з����

    mov ax,cs
	mov es,ax
	mov ds,ax

	call near ptr _Current_PCB
	mov bp,ax

	mov ss, word ptr ds:[bp]
	mov sp, word ptr ds:[bp+16]

	cmp word ptr ds:[bp+32],0  ;�鿴��ǰ״̬�ǲ���new
	jnz Not_First_Time ;�����new״̬˵���ǵ�һ��

Restart:
    call near ptr _Fornew

	; û��push ss �� sp��ֵ��Ϊ�Ѿ���ֵ��
	;ȡ��PCB�е�ֵ���ָ��ֳ�
	;flags,cs,ip������ջ��iretʱ�Զ�ȡ��
	push word ptr ds:[bp+30]
	push word ptr ds:[bp+28]
	push word ptr ds:[bp+26]
	
	push word ptr ds:[bp+2]
	push word ptr ds:[bp+4]
	push word ptr ds:[bp+6]
	push word ptr ds:[bp+8]
	push word ptr ds:[bp+10]
	push word ptr ds:[bp+12]
	push word ptr ds:[bp+14]
	push word ptr ds:[bp+18]
	push word ptr ds:[bp+20]
	push word ptr ds:[bp+22]
	push word ptr ds:[bp+24]

	pop ax
	pop cx
	pop dx
	pop bx
	pop bp
	pop si
	pop di
	pop ds
	pop es
	.386
	pop fs
	pop gs
	.8086

	;ʱ���жϽ���ʱ��Ҫ����EOI�źŸ�����8259A
	push ax         
	mov al,20h
	out 20h,al
	out 0A0h,al
	pop ax

	iret
    
Not_First_Time:
     add sp,16 ;������ǵ�һ�����У���ʱ��PCB�еõ���sp��һ������ȷ��ֵ��Ϊ�˱������ȡ��һ�ε�ֵ
	 jmp Restart


None_Program:
    call near ptr Timer
	push ax
	mov al,20h
    out 20h,al			;����EOI����8529A 
    out 0A0h,al           ;���͸���8529A
	pop ax

	iret







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

  mov ax,cs
  mov es,ax
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

  pop ds
  pop es
  pop bp
  pop dx
  pop cx
  pop bx
  pop ax

  ret;

datadef:
  state db 1
  ch1 db '|'
  ch2 db '/'
  ch3 db '-'
  ch4 db '\'
  delay equ 6
  count db delay

int22h:
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
  mov cx,6
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

  pop bp
  pop es
  pop ds
  pop dx
  pop cx
  pop bx
  pop ax
  iret;

  Info db "INT22H"
  color db 1