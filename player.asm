	BaseOfCode		equ		0100h
	BaseOfStack		equ		0100h

	org		BaseOfCode
	
ENTRY:
	mov		ax, cs			; 常规初始化
	mov		es, ax
	mov		ds, ax
	mov		ss, ax
	mov		sp, BaseOfStack

PLAYERINIT:
	mov		al, 0b6h		; 表示二进制方式3先后读写计数器2
	out		43h, al			; 43H是8254控制字寄存器
	call	IODLY
	mov		si, MUSIC		; 音乐数据地址
	in		al, 61h
	or		al, 01h			; 打开定时器 播放过程中不会关闭
	out		61h, al
	call	IODLY

PLAYER:
	in		al, 61h
	or		al, 02h			; 打开扬声器
	out		61h, al
	call	IODLY
	mov		di, word ds:[si]; 频率数据占两字节
	add		si, 02h
	cmp		di, 0aaaah		; 这个是结束符
	je		FIN
	cmp		di, 0ddddh		; 这个是延时符
	je		NOVOICE
	mov		dx, 12h
	mov		ax, 34deh
	div		di				; 计算计数值
	out		42h, al			; 发送给定时器2
	call	IODLY
	mov		al, ah
	out		42h, al
	call	IODLY
	jmp		DELAY

FIN:
	in		al, 61h			; 关闭扬声器和定时器
	and		al, 0fch
	out		61h, al
	call	IODLY
	mov		ah, 4ch
	int		21h				; 调用DOS中断返回DOS

NOVOICE:
	in		al, 61h
	and		al, 0fdh		; 关闭扬声器
	out		61h, al
	call	IODLY

DELAY:						; 这个函数用来延时10ms
	mov		ah, 2ch
	int		21h				; 调用DOS中断读取系统时间 DL返回秒
	mov		al, dl			; 先记录一下当前时间

DLOOP:
	mov		ah, 2ch
	int		21h
	cmp		al, dl
	jne		PLAYER
	jmp		DLOOP

IODLY:						; IO操作程序性延时
	nop
	nop
	nop
	nop
	ret

MSG:
	db		"Music playing start.", 0ah, 0dh, 0
	OffsetOfMsg		equ		$ - MSG
	db		"Music playing finish.", 0ah, 0dh, 0

TIME:
	db		0

MUSIC: