;IDK HOW TO USE TEST LOL
title testsux
; CTRL F5
INCLUDE Irvine32.inc
.data
	person sbyte 1

.code
main PROC
	mov person, 100
	cmp person, 0		;test person, 0
	jg GREATER
	je EQUAL
	jl LESS
LESS:
	mov al, 'l'
	jmp DONE
EQUAL:
	mov al, 'e'
	jmp DONE
GREATER:
	mov al, 'g'
	jmp DONE
DONE:
	call WriteChar
	call Crlf

main ENDP
end