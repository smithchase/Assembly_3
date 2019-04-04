;IDK HOW TO USE TEST LOL
title testsux
; CTRL F5
INCLUDE Irvine32.inc
.data
	NAMEOFFSET	EQU	0
	CONNOFFSET	EQU	1
	STARTQUEUE	EQU	2
	INOFFSET	EQU	6
	OUTOFFSET	EQU	10
	SIZEOFFIXED	EQU	14
	SIZEOFVAR	EQU	12
	CONNECTION	EQU	0
	XMTBUFFER	EQU	4
	RCVBUFFER	EQU	8
	PACKETSIZE	EQU	6		; how many chars
	QUEUESIZE	EQU 6
	;sourceoffset
	;destinationoffset
	;lastoffset
	;ttloffset

	AXMTB		label	byte
	BRCVA		byte	PacketSize dup(0)
	BXMTA		label	byte
	ARCVB		byte	PacketSize dup(0)

	AXMTE		label	byte
	ERCVA		byte	PacketSize dup(0)
	EXMTA		label	byte
	ARCVE		byte	PacketSize dup(0)

	CXMTB		label	byte
	BRCVC		byte	PacketSize dup(0)
	BXMTC		label	byte
	CRCVB		byte	PacketSize dup(0)

	CXMTE		label	byte
	ERCVC		byte	PacketSize dup(0)
	EXMTC		label	byte
	CRCVE		byte	PacketSize dup(0)
	
	CXMTD		label	byte
	DRCVC		byte	PacketSize dup(0)
	DXMTC		label	byte
	CRCVD		byte	PacketSize dup(0)

	FXMTE		label	byte
	ERCVF		byte	PacketSize dup(0)
	EXMTF		label	byte
	FRCVE		byte	PacketSize dup(0)

	FXMTB		label	byte
	BRCVF		byte	PacketSize dup(0)
	BXMTF		label	byte
	FRCVB		byte	PacketSize dup(0)

	FXMTD		label	byte
	DRCVF		byte	PacketSize dup(0)
	DXMTF		label	byte
	FRCVD		byte	PacketSize dup(0)

	Network		label	byte
	NodeA		byte	'A'
				byte	2
				dword	QueueA
				dword	QueueA
				dword	QueueA
				dword	NodeB
				dword	AXMTB
				dword	ARCVB
				dword	NodeE
				dword	AXMTE
				dword	ARCVE

	NodeB		byte	'B'
				byte	3
				dword	QUEUEB
				dword	QUEUEB
				dword	QUEUEB
				dword	NodeA
				dword	BXMTA
				dword	BRCVA
				dword	NodeC
				dword	BXMTC
				dword	BRCVC
				dword	NODEF
				dword	BXMTF
				dword	BRCVF

	NodeC		byte	'C'
				byte	3
				dword	QUEUEC
				dword	QUEUEC
				dword	QUEUEC
				dword	NodeB
				dword	CXMTB
				dword	CRCVB
				dword	NodeE
				dword	CXMTE
				dword	CRCVE
				dword	NodeD
				dword	CXMTD
				dword	CRCVD

	NodeD		byte	'D'
				byte	2
				dword	QUEUED
				dword	QUEUED
				dword	QUEUED
				dword	NodeC
				dword	DXMTC
				dword	DRCVC
				dword	NodeF
				dword	DXMTF
				dword	DRCVF

	NodeE		byte	'E'
				byte	3
				dword	QUEUEE
				dword	QUEUEE
				dword	QUEUEE
				dword	NodeA
				dword	EXMTA
				dword	ERCVA
				dword	NodeC
				dword	EXMTC
				dword	ERCVC
				dword	NodeF
				dword	EXMTF
				dword	ERCVF

	NodeF		byte	'F'
				byte	3
				dword	QUEUEF
				dword	QUEUEF
				dword	QUEUEF
				dword	NodeB
				dword	FXMTB
				dword	FRCVB
				dword	NodeD
				dword	FXMTD
				dword	FRCVD
				dword	NodeE
				dword	FXMTE
				dword	FRCVE

				;end of nodes


	QUEUEA		byte	QueueSize dup(0)
	QUEUEB		byte	QueueSize dup(0)
	QUEUEC		byte	QueueSize dup(0)
	QUEUED		byte	QueueSize dup(0)
	QUEUEE		byte	QueueSize dup(0)
	QUEUEF		byte	QueueSize dup(0)



				;end of network

.code
main PROC
	mov edi, offset Network
	mov ecx, 0
loop1:
	cmp ecx, 6		; number of nodes is 6
	je done
	push eax
	mov al, NAMEOFFSET[edi]
	call WriteChar
	pop eax
	mov eax, 0
	mov al, CONNOFFSET[edi]
	mov bl, SIZEOFVAR									;mul	SIZEOFVAR not work
	mul	bl												; product in ax....al*bl=ax
	add edi, eax
	add edi, SIZEOFFIXED
	inc ecx
	jmp loop1
done:
	call Crlf
main ENDP
end
