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

public _UP
_UP proc
   push ds
   push es
   push bp ;�����ֳ�������ds��es��bp�Ĵ�����ֵ
   mov bp,sp;��bp����ջ�д���Ĳ�������ΪIP��ds��es��bpѹջ�����Բ�����bp+8��λ��
   mov ax,cs
   mov es,ax ;��es��cs��ȣ�Ϊ�ε�ַ,���ʱCSΪ0A00H
   mov bx,OffsetofUP ;���ݳ���������ƫ�Ƶ�ַ���ε�ַ:ƫ�Ƶ�ַΪ�ڴ���ʵ�ַ
   mov ah,02h ;���ܺ�02h������
   mov al,1   ;����������
   mov dl,0   ;�������ţ�����Ϊ0��U�̺�Ӳ��Ϊ80h
   mov dh,0   ;��ͷ��Ϊ0
   mov cx,[bp+8] ;��ʼ�����ţ���Ŵ�1��ʼ������Ĳ�����Ϊ��Ӧ�û�������������
   mov ch,0   ;�����Ϊ0
   sub cl,48
   int 13h    ;�жϺ�
   ;����Ӧ�û�������ص��ڴ�Ϊ0800H:8c00H��
   mov bx,OffsetofUP ;��ƫ�Ƶ�ַ��ֵ��bx
   call bx ;������ת����Ӧ�ڴ�λ��ִ���û�����
   pop bp
   pop es
   pop ds ;�ָ��ֳ��������ջ
   ret ;����ģ�鷵��
_UP endp

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

