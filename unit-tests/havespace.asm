title havespace
; CTRL F5
INCLUDE Irvine32.inc
.data
	person sbyte 1
	jobsize		equ 14
	numofjobs	equ 10
	jobq		byte	1,"jimmy   ",7,0,9,0,1	;no crlf neccessary											;1,jimmy,7,09,01
	jobq1		byte	1,"pamela  ",1,5,0,0,2
	jobq2		byte	1,"jacob   ",7,2,0,0,2
	jobq3		byte	1,"billy   ",7,2,5,0,2	
	jobq4		byte	1,"markus  ",7,3,2,0,2
	jobq5		byte	1,"phillip ",7,4,4,0,2
	jobq6		byte	-1,"margie  ",7,3,3,0,2
	jobq7		byte	1,"sam     ",7,2,1,0,3
	jobq8		byte	1,"myron   ",6,5,4,0,2
	jobq9		byte    1,"        ",0,0,0,0	
					   ;,null
	stackindex	dword	0
.code
main PROC
	call haveSPACE
	jc mainTRUE
	mov al, 'F'
	Call WriteChar
	jmp endMAIN
mainTRUE:
	mov al, 'T'
	Call WriteChar
endMAIN:
	Call Crlf
main ENDP

haveSPACE PROC			; carry means there is a space available for a job
	stc
	call FindAVAILA
	cmp stackindex, 140
	je hsNOAVAILA
	jmp hsEND
hsNOAVAILA:
	mov stackindex, 0
	clc
hsEND:
	ret
haveSPACE ENDP

findAVAILA PROC
	mov eax, 0
	mov stackindex, 0
	mov edi, 0

	mov ebx, stackindex					; terminate condition
	add ebx, numofjobs*jobsize			; terminate condition
faLOOP:
	cmp stackindex, ebx					; gone too far?
	je faEND							; yes
	mov edi, stackindex
	mov al, byte ptr jobq[edi]	; is available?
	cmp al,0
	jl faEND							; it is available
	mov edx, jobsize
	add stackindex, edx
	jmp faLOOP
faEND:
	ret
findAVAILA ENDP


findAVAILAold PROC
	mov eax, 0
	mov edi, offset jobq
	mov stackindex, edi

	mov ebx, stackindex
	add ebx, numofjobs*jobsize			; terminate condition
faLOOP:
	cmp stackindex, ebx
	je faEND
	mov al, byte ptr stackindex[0]
	cmp stackindex[0],0
	jl faEND
	mov eax, jobsize
	add stackindex, eax
	jmp faLOOP
faEND:
	ret
findAVAILAold ENDP
end