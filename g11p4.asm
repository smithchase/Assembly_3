; Program 4
; Broadcast Network Topology Simulator
; Group Number 11
; Robert Malone, Chase Smith, Luke Habetts
; mal2994@calu.edu smi8808@calu.edu hab6525@calu.edu
; CSC323
; Assembly, April 30, 2019
title g11p4
INCLUDE Irvine32.inc
.data
	; data access offsets for fixed portion of node ;
	NNAME		EQU	0		; offset value ; "name" is a reserved word so nname it is.
	CONNECTIONS	EQU	1
	STARTQUEUE	EQU	2
	INPTR		EQU	6
	OUTPTR		EQU	10
	SIZEOFFIXED	EQU	14
	; data access offsets for variable portion of node ;
	SIZEOFVAR	EQU	12
	CONNECTION	EQU	0
	XMTBUFFER	EQU	4
	RCVBUFFER	EQU	8
	PacketSize	EQU	6		; how many chars
	QUEUESIZE	EQU 6
	NUMOMSGS	EQU	6
	; packet offsets ;
	Dest		EQU	0		; byte
	Sender		EQU	1		; byte
	Orig		EQU	2		; byte
	TTL			EQU	3		; byte
	HopCounter	EQU	4		; byte
	RcvdTime	EQU	5		; word

	NULL		EQU	0
	TAB			EQU	9

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
	NodeA		byte	'A'			; name
				byte	2			; how many connections
				dword	QueueA		; startqueue (holds 6 chars)
				dword	QueueA		; inqueue pointer points to the input data in node's queue
				dword	QueueA		; outqueue pointer points to the output data in node's queue
			; end fixed portion, begin variable portion ;
				dword	NodeB		; connection1
				dword	AXMTB		; this node's xmtbuff1
				dword	ARCVB		; this node's rcvbuff1
				dword	NodeE		; connection2
				dword	AXMTE		; this node's xmtbuff2
				dword	ARCVE		; this node's rcvbuff2

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
	EndNetwork	byte	0

	QUEUEA		byte	3,3,3,3,3,3,(NUMOMSGS-1)*PacketSize dup(0)
	QUEUEB		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEC		byte	NUMOMSGS*PacketSize dup(0)
	QUEUED		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEE		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEF		byte	NUMOMSGS*PacketSize dup(0)

				;print msgs
	mProcSource	byte	TAB,				"Processing outgoing queue of #.",0
	mTimeIs		byte						"Time is #.",0
	mGotMsg		byte	TAB,TAB,			"At time # a message came from #.",0
	mMsgMade	byte	TAB,TAB,TAB,		"A message is generated for #.",0
	mMsgSent	byte	TAB,TAB,TAB,TAB,	"The message was sent.",0
	mMsgSentNot	byte	TAB,TAB,TAB,TAB,	"The message was not sent.",0
	mNewMsg		byte	TAB,TAB,			"There are # new messages.",0
	mMsgsAct	byte	TAB,TAB,			"There are # messages active and # messages have been generated.",0

	msgcnt		byte	0
	time		byte	0


.code
main PROC
	call clearreg
	mov edi, offset Network
	mov ecx, 0

	call PuttIt


main ENDP

;in:	edi points to beginning of a node
;out:	edi points to beginning of next node (alphabetically)
;todo:	error check
nextNode PROC
	mov eax, 0
	mov al, CONNECTIONS[edi]
	mov bl, SIZEOFVAR									;mul	SIZEOFVAR not work
	mul	bl												; product in ax....al*bl=ax
	add edi, eax
	add edi, SIZEOFFIXED
	ret
nextNode ENDP

cpQtoXMT PROC
	push edi											; dont lose node pointer
;;	mov esi, outqueue[edi]								; xmt
	; DID NOT FINISH
cpQtoXMT ENDP

XMTptrEDX PROC
	mov edx, 0
	mov al, sizeofvar
	mul bl
;;	mov edx, xmtoffsetwithfixed[edi+eax]
	; did not finish...?
	ret
XMTptrEDX ENDP

; in: AL: node#
pProcSource PROC
	push edx
	push ecx
	push eax
	mov edx, offset mProcSource
	add edx, sizeof mProcSource
	sub edx, 3
	mov [edx], al
	mov edx, offset mProcSource
	mov ecx, sizeof mProcSource		; get end of string
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pProcSource ENDP

; in: AL: time
pTimeIs PROC
	push edx
	push ecx
	push eax
	mov edx, offset mTimeIs
	add edx, sizeof mTimeIs			; get end of string
	sub edx, 3
	add al, 030h
	mov [edx], al
	mov edx, offset mTimeIs
	mov ecx, sizeof mTimeIs
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pTimeIs ENDP

clearreg PROC
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	mov edi, 0
	mov esi, 0
	ret
clearreg ENDP

; in: edi: node#
PuttIt PROC

	; copy from queue into xmtbuffer
	push edi
	mov esi, inptr[edi]
	mov edi, 22[edi];offset XMTBUFFER[edi]
	mov ecx, PacketSize
	cld
	rep movsb
	pop edi

	; increment the inptr
	mov edx, inptr[edi]
	add edx, 1
	;;;mov inptr[edi], edx
	
	mov eax, PacketSize			; get length to end of queue with multiplication NUMOMSGS*PacketSize
	mov bl, NUMOMSGS
	mul bl

	add edx, eax				; start the length here
	cmp edx, eax				; is ptr at the end of the circular queue allocation?
	jg NoWrapAround				; ...yes, dont wrap
	mov edx, STARTQUEUE[edi]			; ...no, wrap (move inptr to start address of queue)
NoWrapAround:
	mov inptr[edi], edx			; move inptr to either start address of queue or just increment by 1

	;debug
	mov edi, 0
	mov dl, AXMTB

	ret
PuttIt ENDP

end