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
;buffer	byte	9 dup(0)	; if you resize, always leave room for a null at the end
buffer	byte	"jacob     ",0
stackindex	dword	0

.code
main PROC
	; copy job name (particularly the fourth job) to buffer FOR UNIT TEST (command handler should get us something to pass to haveJOB)
	mov eax, 4*jobsize+1
	mov stackindex, eax

	mov esi, offset buffer
	mov eax, dword ptr jobq[eax]

	mov edi, eax;offset eax
	mov ecx, sizeof buffer
	cld
	;rep movsb	; i left the stuff there but instead of copying it at runtime, just initialize it for testing
	call clearREG
	call LOOKforit

	jc mainTRUE
	mov al, 'F'
	Call WriteChar
	jmp endMAIN
mainTRUE:
	Call WriteInt	; print job#
	mov al, 'T'
	Call WriteChar
	;add al, 030h
endMAIN:
	Call Crlf

main ENDP

; call:	job name in buffer variable, al is what job to check
; return:	carry flag set if job is found
haveJOB PROC
	; calulate offset from jobq[0]
	push eax
	;mov al, 4						; remove this. this should be set by caller	
		mov bl, jobsize						; ax = job# * jobsize
		mul bl							; ax = product

	; move address of job table to edi for cmpsb
		add eax, offset jobq			; jobq index 0 plus job number
		add eax, 1						; skip over status byte
	mov edi, eax					; cmpsb destination is each job name
	; move address of keyboard input parameter to esi for cmpsb
	mov esi, offset buffer			; cmpsb source is buffer
	mov ecx, sizename
	cld 
	repe cmpsb

	stc								; haveJOB will return carry high unless it gets cleared from here on out
	je endHJ						; z flag from cmpsb is set?
	clc
endHJ:
	pop eax
	ret
haveJOB ENDP

clearREG PROC
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov edi, 0
	mov esi, 0
	ret
clearREG ENDP

; be sure that buffer has the correct amount of spaces!
LOOKforit PROC ;eax returns job#
	clc
	mov eax, 0
lookloop:
	cmp eax, 10
	je endlook
	Call haveJOB
	jc endlook
	inc eax
	jmp lookloop
endlook:
	ret
	
LOOKforit ENDP

end