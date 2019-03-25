title g11p3
; Group Number 11
; CSC323
; Robert Malone, Chase Smith, Luke Habetts
; mal2994@calu.edu smi8808@calu.edu hab6525@calu.edu
; March 26, 2019
; Program 3: Multitasking Operating System Simulator
; PRIORITY MUST BE 1 DIGIT, EVERY OTHER PARAMETER 2 OR IT WONT WORK
INCLUDE Irvine32.inc
.data
	buffersize	equ 49
	null		equ 0
	tab			equ 9
	cr			equ 13
	lf			equ 10
	space		equ ' '
	stacksize	equ 8
	;queuesize	equ 140
	numjobs		equ	10
	jobsize		equ 14
	numofjobs	equ 10
;	true		equ 0	"redefinition"
;	false		equ -1
	sizename	equ		8
	sizestatus	equ		1
	sizeprty	equ		1
	sizeloadt	equ		2
	sizerunt	equ		2

	casemask equ 0DFh

	buffer		byte	buffersize dup(0)
	buffer2		byte	buffersize dup(0)
	hellomess	byte	"hello",null
	errmess		byte	"error",null
	mtmess		byte	"empty received error",null
	quitmess	byte	"quit command received",null
	helpmess	byte	"help command received",null
	loadmess	byte	"load command received",null
	runmess		byte	"run command received",null
	holdmess	byte	"hold command received",null
	killmess	byte	"kill command received",null
	showmess	byte	"show command received",null
	stepmess	byte	"step command received",null
	changemess	byte	"change command received",null
	exitmess	byte	"exiting program",null
	promptmess	byte	"type a command or type HELP for help: ",null
	prtymess	byte	"type priority (1-7): ",null
	rtmess		byte	"type runtime (01-99): ",null
	helptext1	byte	"QUIT Terminates the program",cr,lf,null
	helptext2	byte	"HELP Provides help with the program",cr,lf,null
	helptext3	byte	"SHOW Shows the job queue",cr,lf,null
	helptext4	byte	"RUN job Changes the mode of a job from HOLD to RUN, a job must exist in the job queue to be placed in the RUN mode",cr,lf,null
	helptext5	byte	"HOLD job Changes the mode of a job from RUN to HOLD, a job must exist in the job queue to be placed in the HOLD mode",cr,lf,null
	helptext6	byte	"KILL job Removes a job from the job queue, the job must be in the HOLD mode",cr,lf,null
	helptext7	byte	"STEP n Processes n cycles of the simulation stepping the system clock, if n is omitted then one is defaulted and n is a positive integer",cr,lf,null
	helptext8	byte	"CHANGE job new_priority where job is the name of a job and new_priority is the new priority for the job from 0 - 7",cr,lf,null
	helptext9	byte	"LOAD job priority run_time where job is the name of a job, priority is the priority for the job from 0",cr,lf,null
	helptext10	byte	"through 7, and run_time is the amount of steps the job will take before it is",cr,lf,null
	helptext11	byte	"completed from 1 through 50. When a job is loaded it is placed in the",cr,lf,null
	helptext12	byte	"HOLD mode",cr,lf,null
	helptext13	byte	"PRIORITY MUST BE 1 DIGIT, EVERY OTHER PARAMETER 2 OR IT WONT WORK",cr,lf,cr,lf,null
	quitc		byte	4,"QUIT",null
	helpc		byte	4,"HELP",null
	loadc		byte	4,"LOAD",null
	runc		byte	3,"RUN",null
	holdc		byte	4,"HOLD",null
	killc		byte	4,"KILL",null
	showc		byte	4,"SHOW",null
	stepc		byte	4,"STEP",null
	changec		byte	6,"CHANGE",null
	jqtitle		byte	"STATUS    NAME      PRIORITY  RUNTIME   LOADTIME  ",cr,lf,null
	jobq		byte	numofjobs*jobsize dup(-1)
	;status, name, priority, runtime, loadtime
;	jobq		byte	-1,"jimmy   ",7,0,9,0,1	;no crlf neccessary											;1,jimmy,7,09,01;
;	jobq1		byte	1,"pamela  ",1,5,0,0,2
;	jobq2		byte	1,"jacob   ",7,2,0,0,2
;	jobq3		byte	1,"billy   ",7,2,5,0,2	
;	jobq4		byte	1,"markus  ",7,3,2,0,2
;	jobq5		byte	1,"phillip ",7,4,4,0,2
;	jobq6		byte	-1,"margie  ",7,3,3,0,2
;	jobq7		byte	1,"sam     ",7,2,1,0,3
;	jobq8		byte	1,"myron   ",6,5,4,0,2
;	jobq9		byte    1,"        ",0,0,0,0,0	
					   ;,null
	bytecount	dword	0
	stackindex	sdword	-1;-4
	numstack	dword	stacksize dup(0)
	startofword	dword	0
	endofword	dword	0
	jobparam	byte	0,0,0,0,0,0,0,0
	maybeleak	byte	0,0,0,0,0,0,0,0,0,0 ; a certain subroutine might be a little erroneous 
	makeitleak	byte	20,20,20,20,20,20,20,20 ;not actually used
	rtparam		byte	0,0
	prtyparam	byte	0
	sysclk		byte	0,0



.code
main PROC
	;mov ebx, 55
	mov edi, 0					; clear index reg

CLRLP:							; clear the input buffer
	mov buffer[edi], null
	inc edi
	cmp edi, buffersize
	jl CLRLP					; repeat for all indexes in buffer

; get byte array (command & parameters) from keyboard
PROMPT:	
 	Call CLEARbuffer
	call CLEARbuffer2
	mov edx, offset promptmess
	call WriteString

	mov edx, offset buffer		; address of buffer into edx
	mov ecx, buffersize
	call ReadString				; keyboard into buffer
	mov bytecount, eax			; store length of input
	mov edi, 0					; clear index reg
; get command and params from input byte array ;
	cmp edi, bytecount			; is input empty?
	jge EMPTYSTR				; input is empty, try again
	mov startofword, edi
	Call FindEndWord

; loop through the word and set case bit of each char in the word to upper case bit ;
	mov al, casemask			; casemask, used in DOUPPER
	mov esi, startofword
	mov edi, endofword
DOUPPER:
	cmp esi, endofword			; test that you still have more chars in word being upper-cased
	jg ITSUPPER					; no more chars in word being upper-cased, they're all upper cased
	and buffer[esi], al			; set the ASCII case bit LOW to get upper case chars
;	mov bl, buffer[esi]			; debug,
	inc esi						; update index of word being upper-cased
	jmp DOUPPER
	
ITSUPPER:
; compare each character of input to each character of each command ;
; set registers for cmpsb instruction (comparing to QUIT):
	mov eax, offset buffer		; "cannot add two relocatable labels" ie offset buffer[startofword], so do it manually
	add eax, startofword
	mov startofword, eax
	mov esi, startofword		; compare the buffer to...
	mov edi, offset quitc +1	; ...the quit command...
	mov cl, quitc[0]				;;sizeof quitc -2 	; ...which is of length sizeof quitc...
	stc							; ...compare forward and not backward
	repe cmpsb
	je QUITCOM
; compare to HELP ;
	mov esi, startofword
	mov edi, offset helpc +1
	mov ecx, sizeof helpc -2
	stc
	repe cmpsb
	je HELPCOM
; compare to LOAD ;
	mov esi, startofword
	mov edi, offset loadc +1
	mov ecx, sizeof loadc -2
	stc
	repe cmpsb
	je LOADCOM
; compare to RUN ;
	mov esi, startofword
	mov edi, offset runc +1
	mov ecx, sizeof runc -2
	stc
	repe cmpsb
	je RUNCOM
; compare to HOLD ;
	mov esi, startofword
	mov edi, offset holdc +1
	mov ecx, sizeof holdc -2
	stc
	repe cmpsb
	je HOLDCOM
; compare to KILL ;
	mov esi, startofword
	mov edi, offset killc +1
	mov ecx, sizeof killc -2
	stc
	repe cmpsb
	je KILLCOM
; compare to SHOW ;
	mov esi, startofword
	mov edi, offset showc +1
	mov ecx, sizeof showc -2
	stc
	repe cmpsb
	je SHOWCOM
; compare to STEP ;
	mov esi, startofword
	mov edi, offset stepc +1
	mov ecx, sizeof stepc -2
	stc
	repe cmpsb
	je STEPCOM
; compare to CHANGE ;
	mov esi, startofword
	mov edi, offset changec +1
	mov ecx, sizeof changec -2
	stc
	repe cmpsb
	je CHANGECOM
	jmp ERRCOM
EMPTYSTR:
	mov edx, offset mtmess
	call WriteString
	call Crlf
	jmp PROMPT
ERRCOM:
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp PROMPT
QUITCOM:
	mov edx, offset quitmess
	call WriteString
	call Crlf
	jmp ExitPr
HELPCOM:
	mov edx, offset helptext1
	call WriteString
	mov edx, offset helptext2
	call WriteString
	mov edx, offset helptext3
	call WriteString
	mov edx, offset helptext4
	call WriteString
	mov edx, offset helptext5
	call WriteString
	mov edx, offset helptext6
	call WriteString
	mov edx, offset helptext7
	call WriteString
	mov edx, offset helptext8
	call WriteString
	mov edx, offset helptext9
	call WriteString
	mov edx, offset helptext10
	call WriteString
	mov edx, offset helptext11
	call WriteString
	mov edx, offset helptext12
	call WriteString
	mov edx, offset helptext13
	call WriteString
	jmp PROMPT
LOADCOM:
	mov eax, 0
	mov edx, offset loadmess
	call WriteString
	call Crlf
;	mov ebx, 3
;	call LoCom									; you can get your additional parameters with number of flags in. need 3, got 1, youll have param2 & param3
	call haveSPACE
	jc loadnoerr
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp loadcomf
loadnoerr:
	call copyBUFFL								; copy buffer to param vars
	call copyBUFFLQ								; copy param vars to job queue
	jmp loadcomf
loadcomf:
	jmp PROMPT
RUNCOM:
	mov edx, offset runmess
	call WriteString
	call Crlf
	call clearREG
	call copyBUFFr								; copy the param from buffer
	call LOOKforit
	jc runnoerr
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp runcomf
runnoerr:
	call PutRun									; should have job# in eax at this point, because of LOOKforit
runcomf:
	jmp PROMPT
HOLDCOM:
	mov edx, offset holdmess
	call WriteString
	call Crlf
	call clearREG
	call copyBUFFhk
	call LOOKforit
	jc holdnoerr
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp holdcomf
holdnoerr:
	call PutHold
holdcomf:
	jmp PROMPT
KILLCOM:
	mov edx, offset killmess
	call WriteString
	call Crlf
	call clearREG
	call copyBUFFhk
	call LOOKforit
	jc killnoerr
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp killcomf
killnoerr:
	call PutKill
killcomf:
	jmp PROMPT
	jmp PROMPT
SHOWCOM:
	mov edx, offset showmess
	call WriteString
	call Crlf
	call SHOWQueue
	jmp PROMPT
STEPCOM:
	mov edx, offset stepmess
	call WriteString
	mov al, buffer[5]	; print n steps operand
	call WriteChar
	jmp PROMPT
CHANGECOM:
	mov edx, offset changemess
	call WriteString
	call Crlf
	call copyBUFFc		; the entire routine is in there
	jmp PROMPT
ExitPr:
	mov edx, offset exitmess
	call WriteString
	call Crlf
	exit
main ENDP

FindEndWord PROC				; starting at edi index of buffer
	mov bl, buffer[edi]		; debug
	cmp buffer[edi],' '
	je ENDWORD					; stop looping when space char
	cmp buffer[edi],9
	je ENDWORD					; stop looping when tab char
	cmp buffer[edi],0
	je ENDWORD					; stop looping when tab char
	cmp edi, sizeof buffer
	jg ENDWORD					; stop looping when youve looped through entire buffer
	inc edi						; update
	jmp FINDENDWORD				; loop iterate
ENDWORD:
	dec edi						; move index to last character of word
	mov endofword, edi			; store index to use later

	ret
FindEndWord ENDP

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
	mov al, 1					; load a 1 and let the caller take care of writing it
	add al, 30h					; convert digit to ascii
	call WriteChar				; write it (-1)
	mov ecx, 8					; write spaces, 9 even if its negative todo
	jmp endsq100s
sq100pos:
	mov al, jobq[ebx]			; status
	add al, 30h					; convert digit to ascii
	call WriteChar				; write it
	mov ecx, 9					; write spaces, 9 even if its negative todo
endsq100s:
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


CLEARbuffer PROC
	push edi
	mov edi, 49
cbloop:
	mov buffer[edi], null
	dec edi
	cmp edi, 0
	jg cbloop
	pop edi

	ret
CLEARbuffer ENDP

CLEARbuffer2 PROC
	push edi
	mov edi, 49
cb2loop:
	mov buffer2[edi], null
	dec edi
	cmp edi, 0
	jg cb2loop
	pop edi

	ret
CLEARbuffer2 ENDP

LoCom PROC					; ebx - params flag(caller function sets different ones)		INPUT ebx to how many parameters you need		; THIS SHOULD WORK FOR ANY FUNCTION THAT WASNT GIVEN ALL ITS PARAMS
	cmp ebx, 0
	je endLoCom				; if you came here and didnt even need parameters
	cmp ebx, 1				; how many do you need? if you need one, it'll be saved in byte param3
	je LCp2r
	cmp ebx, 2
	je LCp1r
		;cmp ebx 3 fall through
	cmp buffer[5], null																														; THIS DOESNT WORK FOR 2-PARAMETER FUNCTIONS :( 
	jne LCdecp1				; if not equal then decrement by one how many parameters you need because you discovered you have one
	jmp LCgetp1
LCp1r:
	cmp ebx, 0
	je endLoCom
	cmp buffer[7], null
	jne LCdecp2
	jmp LCgetp2
LCp2r:
	cmp ebx, 0
	je endLoCom
	cmp buffer[9], null
	jne LCdecp3
	jmp LCgetp3
LCp3r:
	jmp endLoCom

LCdecp1:
	dec ebx
	jmp LCp1r
LCdecp2:
	dec ebx
	jmp LCp2r
LCdecp3:
	dec ebx
	jmp LCp3r
LCgetp1:						; error check their parameters somewhere else
;	mov edx, offset parammess
	call WriteString
	call CLEARbuffer
	call CLEARbuffer2
	mov edx, offset buffer2		; address of buffer into edx
	mov ecx, buffersize
	call ReadString				; keyboard into buffer
	push eax
	mov al, buffer2[1]
	sub eax,30h
;	mov param1, al
	pop eax
	jmp LCp1r
LCgetp2:
;	mov edx, offset parammess
	call WriteString
	call CLEARbuffer
	call CLEARbuffer2
	mov edx, offset buffer2		; address of buffer into edx
	mov ecx, buffersize
	call ReadString				; keyboard into buffer
	push eax
	mov al, buffer2[1]
	sub eax,30h
	;mov param2, al
	pop eax
	jmp LCp2r
LCgetp3:
;	mov edx, offset parammess
	call WriteString
	call CLEARbuffer
	call CLEARbuffer2
	mov edx, offset buffer2		; address of buffer into edx
	mov ecx, buffersize
	call ReadString				; keyboard into buffer
	push eax
	mov al, buffer2[1]
	sub eax,30h
	;mov param3, al
	pop eax
	jmp LCp3r
	
endLoCom:
	ret

LoCom ENDP

IncEbx PROC
	dec ebx
	ret
IncEbx ENDP

;returns job#*jobsize in AL & also in stackindex
; carry means there is a space available for a job
haveSPACE PROC			; carry means there is a space available for a job
	stc
	call FindAVAILA
	cmp stackindex, 140
	je hsNOAVAILA
	jmp hsEND
hsNOAVAILA:
	;mov stackindex, 0
	clc
hsEND:
	ret
haveSPACE ENDP

findAVAILA PROC ;returns job#*jobsize in AL
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

; call:	job name in buffer variable, al is what job to check
; return:	carry flag set if job is found
haveJOB PROC
; calulate offset from jobq[0]
	mov bl, jobsize						; ax = job# * jobsize
	mul bl								; ax = product

; move address of job table to edi for cmpsb
	add eax, offset jobq			; jobq index 0 plus job number
	add eax, 1						; skip over status byte
	mov edi, eax					; cmpsb destination is each job name
; move address of keyboard input parameter to esi for cmpsb
	mov esi, offset jobparam		; cmpsb source is buffer
	mov ecx, sizename
	cld 
	repe cmpsb
	stc								; haveJOB will return carry high unless it gets cleared from here on out
	je endHJ						; z flag from cmpsb is set?
	clc
endHJ:
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

copyBUFFL PROC	;for load command
	; copy job name from buffer to jobparam
	mov esi, offset buffer[5]
	mov edi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb

	mov eax, 0
	; copy priority 
	mov al, buffer[14]
	sub al, 030h
cp1P1get:

	; validate
	cmp al, 7
	jg cp1err1
	cmp al, 1
	jl cp1err1
	jmp cp1P1good
cp1err1:
	mov edx, offset errmess
	call WriteString
	call Crlf
	mov edx, offset prtymess
	call WriteString
	mov edx, offset buffer2		; address of buffer into edx
	mov ecx, buffersize
	call ReadString				; keyboard into buffer
	mov ebx, eax
	mov al, buffer2[0]
	cmp ebx, 1
	jne cp1err1
	sub al, 030h
	jmp cp1P1get					; when we asked for 1 param, did they give us one char? validate it
	jmp cp1err1

cp1P1good:
	mov prtyparam, al
cp1p1d1get:	
	;call CLEARbuffer2
; copy run time digit 1
	mov al, buffer[16]
	sub al, 030h
;cp1p1d1get:
; validate
	cmp al, 9
	jg cp2err1
	cmp al, 0
	jl cp2err1
	jmp cp2P2d1good
cp2P2d1good:
	mov rtparam[0], al			; save valid digit 1
	mov al, buffer[17]
	;sub al, 030h
; validate
cp1p2d2get:
	sub al, 030h
	cmp al, 9
	jg cp2err1
	cmp al, 0
	jl cp2err1
	mov rtparam[1], al
	jmp cplend
cp2err1:
	mov edx, offset errmess
	call WriteString
	call Crlf
	mov edx, offset rtmess
	call WriteString
	mov edx, offset buffer2		; for ReadString
	mov ecx, buffersize			; for ReadString
	call ReadString				; keyboard into buffer2
	mov ebx, eax				; store byte count
	mov al, buffer2[0]
	cmp ebx, 2
	jne cp2err1					; when we asked for 1 param, did they give us 2 chars? validate them
;	call CLEARbuffer2
	; copy run time
	mov al, buffer2[0]
	;sub al, 030h
	mov buffer[16], al
	mov al, buffer2[1]
	;sub al, 030h
	mov buffer[17], al
	jmp cp1p1d1get
cplend:
	ret
copyBUFFL ENDP

copyBUFFLQ PROC
	; load it in hold mode
	mov ebx, stackindex
	mov jobq[ebx],0

	mov edi, 0
	mov ebx, 0
	; copy job name from jobparam to job queue
	mov ebx, stackindex
	add ebx, 1
	add ebx, offset jobq
	mov edi, ebx
	mov esi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb

	; copy priority
	mov ebx, stackindex
	add ebx, 1
	add ebx, 8
	mov dl, prtyparam
	mov jobq[ebx], dl

	; copy runtime
	mov ebx, stackindex
	add ebx, 1
	add ebx, 8
	add ebx, 1
	mov dl, rtparam[0]
	mov jobq[ebx],dl
	add ebx, 1
	mov dl, rtparam[1]
	mov jobq[ebx],dl

	; copy loadtime
	mov ebx, stackindex
	add ebx, 1
	add ebx, 8
	add ebx, 1
	add ebx, 2
	mov dl, sysclk[0]
	mov jobq[ebx],dl
	add ebx, 1
	mov dl, sysclk[1]
	mov jobq[ebx],dl


	ret
copyBUFFLQ ENDP

; be sure that buffer has the correct amount of spaces!
LOOKforit PROC ;eax returns job#
	clc
	mov eax, -1
	;push eax
lookloop:
	;pop eax
	inc eax
	cmp eax, 10
	je endlook
	push eax
	Call haveJOB
	pop eax
	jc endlook
	;;inc eax
	;sub eax, offset jobq		;haveJOB increments it and also adds this offset. so just take the offset off. but cant do it in the fn cuz sub sets c flag
	jmp lookloop
endlook:
	ret
	
LOOKforit ENDP

copyBUFFr PROC	;for run command. they only need a job param
	; copy job name from buffer to jobparam
	mov esi, offset buffer[4]
	mov edi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb
	cmp eax, 8
	je endcpr
; put in some spaces for them todo
endcpr:
	ret
copyBUFFr ENDP

copyBUFFhk PROC	;for hold and kill commands. they only need a job param
	; copy job name from buffer to jobparam
	mov esi, offset buffer[5]
	mov edi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb
	ret
copyBUFFhk ENDP

copyBUFFc PROC
	call clearREG
	mov dl, buffer[16]
	sub dl, 030h
	mov prtyparam, dl
	; dont have time to use endofword and all that happy crappy todo hm
; copy job name from buffer to jobparam
	mov esi, offset buffer[7]
	mov edi, offset jobparam
	mov ecx, sizename
	cld
	rep movsb
; look for job name
	call LOOKforit
	jc cbcnoerr
	mov edx, offset errmess
	call WriteString
	call Crlf
	jmp endcbc
cbcnoerr:
	mov bl, jobsize				; ax = job# * jobsize
	mul bl						; ax = product aka index
	add eax, 9					; offset to priority
	mov dl, prtyparam
	mov jobq[eax], dl
endcbc:
	ret
copyBUFFc ENDP

PutRun PROC
	mov bl, jobsize				; ax = job# * jobsize
	mul bl						; ax = product
	mov jobq[eax], 1
	ret
PutRun ENDP

PutHold PROC
	mov bl, jobsize				; ax = job# * jobsize
	mul bl						; ax = product
	mov jobq[eax], 0
	ret
PutHold ENDP

PutKill PROC
	mov bl, jobsize				; ax = job# * jobsize
	mul bl						; ax = product
	mov jobq[eax], -1
	ret
PutKill ENDP

end