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
	INPTR		EQU	6		; this is an offset into the node data structure!
	OUTPTR		EQU	10		; this is an offset into the node data structure!
	SIZEOFFIXED	EQU	14
	; data access offsets for variable portion of node ;
	SIZEOFVAR	EQU	12
	CONNECTION	EQU	0
	XMTOFFSET	EQU	4
	RCVOFFSET	EQU	8
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
	BRCVA		byte	PacketSize dup(0);51,51,51,51,51,51;PacketSize dup(0)
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

	nullPacket	byte	PacketSize dup(0)	; never to be changed

	Network		label	byte
	NodeA		byte	'A'			; 0  name
				byte	2			; 1  how many connections
				dword	QUEUEA		; 2  startqueue (holds 6 chars)
				dword	QUEUEA		; 6  inqueue pointer points to the input data in node's queue			; THIS IS THE INPTR HERE!!! IT CHANGES.
				dword	QUEUEA		; 10 outqueue pointer points to the output data in node's queue		; same but OUTPTR
			; end fixed portion, begin variable portion ;
				dword	NodeB		; 14 connection1
				dword	AXMTB		; 18 this node's xmtbuff1
				dword	ARCVB		; 22 this node's rcvbuff1
				dword	NodeE		; 26 connection2
				dword	AXMTE		; 30 this node's xmtbuff2
				dword	ARCVE		; 34 this node's rcvbuff2

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

	QUEUEA		byte	52,52,52,52,52,52,(NUMOMSGS-1)*PacketSize dup(0)
	QUEUEB		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEC		byte	NUMOMSGS*PacketSize dup(0)
	QUEUED		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEE		byte	NUMOMSGS*PacketSize dup(0)
	QUEUEF		byte	NUMOMSGS*PacketSize dup(0)

				;print msgs
	mProcSource	byte	TAB,				"Processing outgoing queue of #.",0										;main
	mProcRecv	byte	TAB,TAB,			"Processing receiver buffer of #.",0									;main
	mTimeIs		byte						"Time is #.",0															;main
	mGotMsg		byte	TAB,TAB,			"At time # a message came from #.",0											;puttit
	mMsgMade	byte	TAB,TAB,TAB,		"A message is generated for #.",0										;puttit
	mMsgRec		byte	TAB,TAB,			"A message was received from #.",0										;gettit
	mMsgSent	byte	TAB,TAB,TAB,TAB,	"The message was sent.",0												;puttit
	mMsgSentNot	byte	TAB,TAB,TAB,TAB,	"The message was not sent.",0											;dont
	mNewMsg		byte	TAB,TAB,			"There are # new messages.",0											;main
	mMsgsActGen	byte	TAB,TAB,			"There are # messages active and # messages have been generated.",0		;main
	mMsgsAct	byte	TAB,TAB,TAB,		"There are currently # messages active.",0								;main

	msgcnt		byte	0
	time		byte	1

	tempname	byte	0	; oof
	tempcount	byte	0

	maincount	byte	3
	numonodes	byte	0

.code
main PROC

mainloop:
	cmp maincount, 0
	je endmain
	mov eax, 0
	mov ebx, 0

sendloop:
		mov edi, offset Network
		mov al, numonodes
		push eax
		mov eax, 0
sendloop2:
			cmp numonodes,0		; current node * nodesize
			je endsendloop2
			mov al, CONNECTIONS[edi]
			mov bl, SIZEOFVAR
			mul bl
			add edi, eax
			add edi, SIZEOFFIXED
			dec numonodes
			jmp sendloop2
endsendloop2:
		pop eax
		mov numonodes, al
		mov eax, 0

		cmp numonodes, 6
		jg sendend
		mov eax, 0
		mov al, numonodes
		mov ebx, 0
		mov bl, SIZEOFVAR
		mul bl
		Call PuttIt
		inc numonodes
		jmp sendloop
sendend:
	mov numonodes, 0
	mov eax, 0
	mov edi, 0
	mov esi, 0
rcvloop:

		mov esi, offset Network
		mov al, numonodes
		push eax
		mov eax, 0
rcvloop2:
			cmp numonodes,0		; current node * nodesize
			je endrcvloop2
			mov al, CONNECTIONS[esi]
			mov bl, SIZEOFVAR
			mul bl
			add esi, eax
			add esi, SIZEOFFIXED
			dec numonodes
			jmp rcvloop2
endrcvloop2:
		pop eax
		mov numonodes, al
		mov eax, 0

		cmp numonodes, 6
		jg rcvend
		mov eax, 0
		mov al, numonodes
		Call GettIt
		inc numonodes
		jmp rcvloop
rcvend:
		dec maincount
		je mainloop
endmain:
	Call Crlf
	Call Crlf

main ENDP

; in:	edi: node# address that will xmt
;		eax: connection#	(0....step by sizeofvar)
PuttIt PROC	; put data in message
	push edi					; beginning of fixed portion of this node
	mov bl, SIZEOFVAR			; account for VARIABLE portion of node data structure
	mul bl
	add eax, SIZEOFFIXED		; account for FIXED porition of node data structure
	mov esi, OUTPTR[edi]		; SOURCE for movsb
	push esi					; push this for null packet later

	push eax					; print msg
	mov eax, 0
	mov al, byte ptr [edi]
	mov tempname, al			; connection name for printing
	pop eax

	add edi, eax				;;;;;;; IN THE MAIN LOOP STEP BY SIZEOFVAR OR IT WONT WORK
	mov edi, XMTOFFSET[edi]		; final destination
	push esi					; see if the queue is empty
	mov esi, [esi]
	cmp esi, 0					
	pop esi
	je puttitend				; is it empty? if not, copy it

	mov eax, 0
	mov al, tempname
	Call pMsgMade

	mov ecx, PacketSize
	cld
	rep movsb					; copy QUEUE at OUTPTR to XMTbuf
	
	Call pMsgSent

	pop esi						; overwrite QUEUE with Null
	push esi
	mov edi, esi
	mov esi, offset NullPacket
	mov ecx, PacketSize
	cld
	rep movsb
puttitend:
	pop esi						
	pop edi
	mov OUTPTR[edi], esi		; point outptr right before the null packet
	ret
PuttIt ENDP

; in:	esi: node# address that will rcv
;		eax: connection#
; do one connection of one node (1-based connections)
GettIt PROC
	;push esi						; ptr this node
	mov edi, esi					; ptr this node
	mov edi, INPTR[edi]				; ptr this node's QUEUE INPTR is DESTINATION
	add esi, SIZEOFFIXED			; ptr this node's var portion
gettit1:							; add SIZEOFVAR until you get the eax-specified connection rcvbuf
	cmp eax, 1				
	je gettitdone1
	add esi, SIZEOFVAR
	dec eax
	jmp gettit1
gettitdone1:
	mov esi, RCVOFFSET[esi]			; ptr to ptr to this node's eax-specified connection's rcvbuf

	;check empty
	push esi
	mov esi, [esi]
	cmp esi, 0
	pop esi
	je gettitend
	;print msg
	Call pMsgRec

	push esi						; for nulling out later
	mov ecx, PacketSize				; copy the whole packet and no more
	cld
	rep movsb						; copy rcvbuf packet to QUEUE at INPTR
	add byte ptr [edi], PacketSize	; increment INPTR
	
	pop esi							; write null packet
	mov edi, esi
	mov esi, offset NullPacket
	mov ecx, PacketSize
	cld
	rep movsb

gettitend:

	ret
GettIt ENDP

;in:	edi points to beginning of a node
;out:	edi points to beginning of next node (alphabetically)
nextNode PROC
	mov eax, 0
	mov al, CONNECTIONS[edi]
	mov bl, SIZEOFVAR									;mul	SIZEOFVAR not work
	mul	bl												; product in ax....al*bl=ax
	add edi, eax
	add edi, SIZEOFFIXED
	ret
nextNode ENDP

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

; in: AL: node#
pProcRecv PROC
	push edx
	push ecx
	push eax
	mov edx, offset mProcRecv
	add edx, sizeof mProcRecv
	sub edx, 3
	mov [edx], al
	mov edx, offset mProcRecv
	mov ecx, sizeof mProcRecv		; get end of string
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pProcRecv ENDP

; in: AL: node#
pMsgMade PROC
	push edx
	push ecx
	push eax
	mov edx, offset mMsgMade
	add edx, sizeof mMsgMade
	sub edx, 3
	mov [edx], al
	mov edx, offset mMsgMade
	mov ecx, sizeof mMsgMade		; get end of string
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pMsgMade ENDP

; in: AL: node#
pMsgRec PROC
	push edx
	push ecx
	push eax
	mov edx, offset mMsgRec
	add edx, sizeof mMsgRec
	sub edx, 3
	mov [edx], al
	mov edx, offset mMsgRec
	mov ecx, sizeof mMsgRec			; get end of string
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pMsgRec ENDP

; in: AL: node#
pMsgSent PROC
	mov edx, offset mMsgSent
	mov ecx, sizeof mMsgSent		; get end of string
	call WriteString
	call Crlf
	pop eax
	pop ecx
	pop edx
	ret
pMsgSent ENDP

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

end