title testplace
; FIXED VERSION OF SHOWQUEUE
INCLUDE Irvine32.inc
.data
	cr			equ 13
	lf			equ 10
	space		equ ' '
	null		equ 0
jobsize	equ 14
numofjobs	equ 10
sizename	equ	8
jqtitle		byte	"STATUS    NAME      PRIORITY  RUNTIME   LOADTIME  ",cr,lf,null
jobq	byte	1,"jimmy   ",7,0,9,0,1
jobq1	byte	1,"pamela  ",1,5,0,0,2
jobq2	byte	1,"jacob   ",7,2,0,0,2
jobq3	byte	1,"billy   ",7,2,5,0,2
jobq4	byte	-1,"markus  ",7,3,2,0,2
jobq5	byte	1,"phillip ",7,4,4,0,2
jobq6	byte	1,"margie  ",7,3,3,0,2
jobq7	byte	1,"sam     ",7,2,1,0,3
jobq8	byte	1,"myron   ",6,5,4,0,2
jobq9	byte	1,"byron   ",6,0,1,0,1,	null
;buffer	byte	9 dup(0)	; if you resize, always leave room for a null at the end
buffer	byte	  "howdy   "
stackindex	dword	0

.code
main PROC
	call clearREG
	call SHOWQueue
	mov eax, 4
	call putinQUEUE

	call SHOWQueue

main ENDP

; call:		job# in eax
; return:	nothing (not even an error message..)
putinQUEUE PROC
	call jobnumtoADDR			; puts address in eax
	mov jobq[ebx], 0			; overwrite mode to hold mode

	inc eax
	mov edi, eax				; movsb destination is job# jobname field
	mov esi, offset buffer		; movsb source is buffer
	mov ecx, sizename			; movsb size is size of jobname field
	cld 
	rep movsb					; overwrite name

	; priority 
	add ebx, 9					; move past name
	mov jobq[ebx], 5			; 5 should be param1 or whatever in the big program

	; runtime
	inc ebx
	mov jobq[ebx], 5			; really param2
	inc ebx
	mov jobq[ebx], 5			; uh param3?

	; loadtime
	inc ebx
	mov jobq[ebx], 5			; param 4 byte
	inc ebx
	mov jobq[ebx], 5			; param 5 byte

	ret
putinQUEUE ENDP

clearREG PROC
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov edi, 0
	mov esi, 0
	ret
clearREG ENDP

SHOWQueue PROC					; ebx: index, edi: job number, ecx: 0-10 char count for field, edx: what field
	mov edx, offset jqtitle
	call WriteString
	mov ebx, 0					; status index
	mov edi, 0
	mov edx, 0
sq100:
	inc edx
	cmp edx, 9					; compare to 10 jobs written
	jg endsq100					; after 10, loop is done
	mov al, jobq[ebx]			; status
	call sq100minus				; handle the negative sign or lack thereof
	add al, 30h					; convert digit to ascii
	call WriteChar				; write it
	mov ecx, 9					; write spaces, 9 even if its negative todo
	call SPACEwriter
	
	inc ebx						; name index
	mov ecx, 8
	call WRITEjobchars
	mov ecx, 2					; name is always 8, write 2 more spaces
	call SPACEwriter
	
	;inc ebx
	mov al, jobq[ebx]
	add al, 30h
	Call WriteChar
	mov ecx, 9
	Call SPACEwriter

	mov ecx, 2					; three loops
tailTABLEwr:
	push ecx
	inc ebx						; digit 1 of PRIORITY  RUNTIME   LOADTIME  
	mov al, jobq[ebx]
	add al, 30h
	Call WriteChar
	inc ebx						; digit 2
	mov al, jobq[ebx]
	add al, 30h
	Call WriteChar
	mov ecx, 8
	call SPACEwriter
	pop ecx
	dec ecx
	cmp ecx, 0
	jg tailTABLEwr
	call Crlf
	inc ebx
	jmp sq100
endsq100:

	ret
SHOWQueue ENDP

sq100minus PROC
	cmp al, 255					; is it minus?
	jne sq100pos				; no, leave
	mov al, 02Dh
	call WriteChar				; yes, write minus
	mov al, 1				; load a 1 and let the caller take care of writing it
	;inc ebx						; get the digit
;	mov al, jobq[ebx]			; store the digit
sq100pos:
	ret
sq100minus ENDP

SPACEwriter PROC				; use ecx for number of spaces
beginspwr:
	cmp ecx,0
	je endspwr
	mov al, space
	call WriteChar
	dec ecx
	jmp beginspwr
endspwr:
	ret
SPACEwriter ENDP

WRITEjobchars PROC				; return when ecx==0 or char is not digit or letter. exits with ebx index of next char
loopwrjc:
	cmp ecx,0					; compare for maximum 10 iterations of 1 byte WriteChar
	je endwrjc
	cmp jobq[ebx], 20h			; compare for space
	je dowrjc
	cmp jobq[ebx], 30h			; two compares to see if jobq[ebx] is a digit
	jl endwrjc
	cmp jobq[ebx], 3Ah
	jl dowrjc
	cmp jobq[ebx], 41h			; four compares to see if jobq[ebx] is a letter
	jl endwrjc
	cmp jobq[ebx], 5Bh
	jl dowrjc
	cmp jobq[ebx], 97h
	jl endwrjc
	cmp jobq[ebx], 7Bh
	jl dowrjc
	jmp endwrjc
dowrjc:
	mov al, jobq[ebx]
	call WriteChar
	dec ecx
	inc ebx
	jmp loopwrjc
endwrjc:
	ret
WRITEjobchars ENDP

; call: job# in eax
; return: address in eax, index in ebx
jobnumtoADDR PROC
	mov bl, jobsize					; ax = job# * jobsize
	mul bl							; ax = product
	mov ebx, eax		; hopefully return index
	add eax, offset jobq			; jobq index 0 plus job number (so its an address..)
	ret
jobnumtoADDR ENDP
end