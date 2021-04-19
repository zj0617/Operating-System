
extern _getstr:near ;����һ���ⲿ����cmain
extern _putstr:near ;����һ���ⲿ����cmain
extern _scanfstr:near ;����һ���ⲿ����cmain

extern _segment
extern _sec

extrn _Current_PCB
extrn _Save_PCB
extrn _Process_Schedule
extrn _Fornew
extrn _process_num
extrn _cur_pnum
extrn _Save_PSP
extrn _Exchange


public _fst
_fst proc
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
	ret
_fst endp


public _cls
_cls proc
    mov ah,0
	int 21h
	ret
_cls endp

;�����жϺ�16h��0h���ܶ���һ���ַ�
public _getch
_getch proc
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    mov ah,1
	int 21h
	ret
_getch endp

;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _putch
_putch proc
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    mov ah,2
	int 21h
	ret
_putch endp

;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _puts
_puts proc
    mov ah,3
	int 21h
	ret
_puts endp

;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _gets
_gets proc
    mov ah,4
	int 21h
	ret
_gets endp

;�����жϺ�10h��0Eh���ܣ���Teletypeģʽ����ʾ�ַ�
public _scanf
_scanf proc
    mov ah,5
	int 21h
	ret
_scanf endp


Sche_num dw 0
Back dw 0
Sa dw 0
;*****************************************
;*                Save                   *
;*****************************************
Save:
    ;cmp word ptr[_process_num],0
	;jz None_process
	;inc word ptr [Sche_num]
	;cmp word ptr[Sche_num],500
	;jnz Goon
	;mov word ptr[_process_num],0
	;mov word ptr[_cur_pnum],0
	;mov word ptr[Sche_num],0
	;mov word ptr[_segment],2000h
	;jmp redone
;��Ϊcall save()�Ὣ����ֵѹջ�����ջ��Ϊpsw/ip1/cs1/ip2
;Goon:
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

	mov cx,cs;Ҫ�ǵ����¸��μĴ�����ֵ����������ô���
	mov es,cx
	mov ds,cx
	;������cģ���������֮��Ҫ�Լ���ջ������
	call near ptr _Save_PCB;�жϵ�����ģʽ�л���ʱ�������Ҫ�����жϵĽ��̵������ı����ڸý��̵Ľ��̿��ƿ���
	
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


	mov cx,cs;Ҫ�ǵ����¸��μĴ�����ֵ����������ô���
	mov es,cx
	mov ds,cx
	pop cx;����ջ�е�ip2,��ʱջ��psw/ip1/cs1
	;������ax��ax�ں����л�仯������
	push bp
	mov bp,offset Back
	mov word ptr [bp],cx
	mov bp,offset Sa
	mov word ptr [bp],ax
	pop bp

	call near ptr _Save_PSP

	;ջ�е�psw\cs\ip���Բ��ó�ջ
	push bp
	mov bp,offset Back
	mov cx,word ptr [bp]
	pop bp

	push cx;�ٰ�ip2��ջ����ʱջ��ip2
	call near ptr _Process_Schedule
	push bp
	mov bp,offset Sa
	mov ax,word ptr [bp]
	pop bp
	
	ret;����

;redone:

Restart:
    mov ax,cs;Ҫ�ǵ����¸��μĴ�����ֵ����������ô���
	mov es,ax
	mov ds,ax
	 
    call near ptr _Current_PCB;����ֵ������ax��
	mov bp,ax

    ;Ҫ�Ȼָ�ss\sp��ֵ����Ȼ�����ջ���󣡣�����
	mov ss,word ptr ds:[bp+0]
	mov sp,word ptr ds:[bp+16]

	cmp word ptr ds:[bp+32],0  ;�鿴��ǰ״̬�ǲ���new
	jnz Not_First_Time ;�����new״̬˵���ǵ�һ��


redone:
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

	iret
    
Not_First_Time:
     add sp,18 ;������ǵ�һ�����У���ʱ��PCB�еõ���sp��һ������ȷ��ֵ��Ϊ�˱������ȡ��һ�ε�ֵ
	 jmp redone







int21h:
  call near ptr Save
  cmp ah,0
  jnz Ch1
  jmp cls

Ch1:
  cmp ah,1
  jnz Ch2
  jmp getch

Ch2:
  cmp ah,2
  jnz Ch3
  jmp putch

Ch3:
  cmp ah,3
  jnz Ch4
  jmp puts

Ch4:
  cmp ah,4
  jnz Ch5
  jmp gets

Ch5:
  cmp ah,5
  jnz Q
  jmp scanf

Q:
  iret
  jmp $

getch:
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    push bp
	push bx
	mov bp,sp
	mov bx,[bp+12];char/ip1/ip2/cs/psw/bp/bx
    mov ah,0 ;���ܺ�
	int 16h
	mov byte ptr [bx],al ;��һ���ַ�ָ�뱣��������ַ�,InChΪCģ��ı���
	mov sp,bp
	pop bx
	pop bp
	jmp near ptr Restart
	iret

putch:
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
    push bp ;����bp��ֵ����Ϊ������Ҫ��bpȥ����ջ��������ջ�У�
	mov bp,sp ;ջ��ָ��sp����bp
	mov ax,[bp+10];char/ip1/ip2/cs/psw/bp
	mov ah,0EH ;ahΪ���ܺ�
	mov bl,0h ;ǰ��ɫ��ͼ��ģʽ��
	int 10h
	mov sp,bp
	pop bp ;�ָ�bp��ֵ
	jmp near ptr Restart
	iret   ;����


cls:
    mov ax,cs;�������Ĵ�����CS��ͬ
	mov ds,ax; DS = CS
	mov es,ax; ES = CS
	mov ss,ax; SS = CS
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
	jmp near ptr Restart
	iret

puts:
   mov ax,cs;�������Ĵ�����CS��ͬ
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10];����Ҫ��ʾ���ַ�������ʼ��ַ
   push [bp+10]
   call near ptr _putstr
   pop bp
   pop bp
   iret

gets:
   mov ax,cs;�������Ĵ�����CS��ͬ
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10]
   push [bp+10]
   call near ptr _getstr
   pop bp
   pop bp
   iret

scanf:
;%��ASCII��ֵΪ37
   mov ax,cs;�������Ĵ�����CS��ͬ
   mov ds,ax; DS = CS
   mov es,ax; ES = CS
   mov ss,ax; SS = CS
   push bp
   mov bp,sp
   mov bx,[bp+10];char/str/ip1/ip2/cs/psw/bp/bx/cx str
   mov cx,[bp+12];cģ����û���Ҳ�����ջ��char
   push [bp+12]
   push [bp+10]
   call near ptr _scanfstr
   pop bp
   pop bp
   pop bp
   iret
