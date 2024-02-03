	BaseOfCode		equ		07e00h
	BaseOfStack		equ		07c00h

	org		BaseOfCode
	
	jmp		ENTRY
	db		"pmprepper"		; 懒得改了那你就暂时伪装一下LOADER吧
	
ENTRY:
	mov		ax, cs			; 常规初始化
	mov		es, ax
	mov		ds, ax
	mov		ss, ax
	mov		sp, BaseOfStack
	mov		dl, 0
	mov		si, MSG			; 开始时提示语
	int		22h

INTERCREAT:					; 所有这一时期的中断都在这里
	mov		si, 20h			; 经计算0:20H的表项是时钟中断
	mov		word[si], INT08H; 每个表项前2个字节是ip寄存器的值这里直接使用标签真方便(舒服了
	add		si, 0x02		; 偏移2准备写后两字节
	mov		word[si], cs	; 后2字节是cs寄存器的值
	jmp		PLAYERINIT

INT08H:
	mov		al, ds:[TIME]
	add		al, 01h
	mov		byte ds:[TIME], al
	mov		al, 30h			; 表示二进制方式0先后读写计数器0
	out		43h, al
	call	IODLY
	mov		al, 9ch			; 2E9CH就是定时10ms的计数初值
	out		40h, al
	call	IODLY
	mov		al, 2eh
	out		40h, al
	call	IODLY			; 设置好了以后应该会自动开始计时
	mov		al, 20h			; 要给8259A的EOI
	out		20h, al
	call	IODLY
	iret

PLAYERINIT:
	mov		al, 30h			; 表示二进制方式0先后读写计数器0
	out		43h, al
	call	IODLY
	mov		al, 9ch			; 2E9CH就是定时10ms的计数初值
	out		40h, al			; 启动一下系统时钟
	call	IODLY
	mov		al, 2eh
	out		40h, al
	call	IODLY			; 设置好了以后应该会自动开始计时
	mov		al, 0b6h		; 表示二进制方式3先后读写计数器2
	out		43h, al			; 43H是8254控制字寄存器
	call	IODLY
	mov		si, MUSIC		; 音乐数据地址
	in		al, 61h
	or		al, 01h			; 打开定时器
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
	je		DELAY
	mov		dx, 12h
	mov		ax, 34deh
	div		di				; 计算计数值
	out		42h, al			; 发送给定时器2
	call	IODLY
	mov		al, ah
	out		42h, al
	call	IODLY
	jmp		PLAYER

FIN:
	in		al, 61h			; 关闭扬声器和定时器
	and		al, 0fch
	out		61h, al
	call	IODLY
	mov		dl, 0
	mov		si, MSG + OffsetOfMsg
	int		22h				; 结束提示语
	hlt

DELAY:						; 这个函数用来延时10ms
	in		al, 61h
	and		al, 0fdh		; 关闭扬声器
	out		61h, al
	call	IODLY
	mov		al, 0			; 就先归零一下缓冲区
	mov		byte ds:[TIME], al

DLOOP:
	mov		al, ds:[TIME]
	cmp		al, 01h
	jae		PLAYER
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