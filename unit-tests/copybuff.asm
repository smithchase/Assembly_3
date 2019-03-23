title testhavejob
; F11 F11
INCLUDE Irvine32.inc
.data
person sbyte 1
jobsize	equ 14
numofjobs	equ 10
sizename	equ	8
jobq	byte	1,"jimmy   ",7,0,9,0,1	;no crlf neccessary	;1,jimmy,7,09,01
jobq1	byte	1,"pamela  ",1,5,0,0,2
jobq2	byte	1,"jacob   ",7,2,0,0,2
jobq3	byte	1,"billy   ",7,2,5,0,2
jobq4	byte	1,"markus  ",7,3,2,0,2
jobq5	byte	1,"phillip ",7,4,4,0,2
jobq6	byte	-1,"margie ",7,3,3,0,2
jobq7	byte	1,"sam     ",7,2,1,0,3
jobq8	byte	1,"myron   ",6,5,4,0,2
jobq9	byte	1,"byron   ",0,0,0,0,0	,null
buffer	byte	"load tyrone  1 10"
jobparam	byte	0,0,0,0,0,0,0,0
rtparam		byte	0,0
prtyparam	byte	0
stackindex	dword	0

.code
main PROC
	call copyBUFFL		;THIS ONLY WORKS FOR LOAD COMMAND
	mov eax, 0
	mov ebx, 0
	; print name
BUFFP1:							; shouldve used write string. this is all debug code. all you need is in copyBUFF
	cmp ebx, sizename
	je endBUFFP1
	mov al, jobparam[ebx]
	Call WriteChar
	inc ebx
	jmp BUFFP1
endBUFFP1:

	; print priority
	mov al, prtyparam
	Call WriteInt

	; print runtime
	mov al, rtparam[0]
	Call WriteInt
	mov al, rtparam[1]
	Call WriteInt
	Call Crlf
	exit
main ENDP

copyBUFFL PROC
	; copy job name from buffer to jobparam
	mov esi, offset buffer[5]
	mov edi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb

	mov eax, 0
	; copy priority 
	mov al, buffer[13]
	sub al, 030h
	mov prtyparam, al

	; copy run time
	mov al, buffer[15]
	sub al, 030h
	mov rtparam[0], al
	mov al, buffer[16]
	sub al, 030h
	mov rtparam[1], al

	ret
copyBUFFL ENDP


end