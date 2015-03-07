;;;;
;;
;;  This program handles the BGC-8088's speaker by using the status port.
;;
;;  Copyright (C) 2009 Efstathios Chatzikyriakidis (contact@efxa.org)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program. If not, see <http://www.gnu.org/licenses/>.
;;
;;;;

;;
;; build options.
;;

; name of the bin.
name "bgc-speaker"

; bin is plain binary format similar to com
; format, but not limited to only 1 segment.
#make_bin#

; set loading address.
#LOAD_SEGMENT=0100H#
#LOAD_OFFSET=0000H#

;;
;; registers' initial value.
;;

; set entry point.

#CS=0100H# ; same as loading segment.
#IP=0000H# ; same as loading offset.

; set segment registers.

#DS=0100H# ; same as loading segment.
#ES=0100H# ; same as loading segment.

; set stack segments.
#SS=0100H# ; same as loading segment.
#SP=FFFEH# ; set to top of loading segment.

; set general registers.

#AX=0000H#
#BX=0000H#
#CX=0000H#
#DX=0000H#
#SI=0000H#
#DI=0000H#
#BP=0000H#

;;
;; program entry point.
;;

; load the address of the status port.
MOV DX, FF70H

; max iterations of speaker operation.
MOV CX, 000AH

; start delay time (low frequency).
MOV BX, 0FFFH

; speaker main loop process.
speaker_loop:

; store the index iteration value to the stack.
PUSH CX

; speaker is going to the highest frequency.
go_high_freq:

; produce a sound from the speaker and delay.
CALL speaker_operation

; decrement the delay time.
DEC BX

; check if we are in the minimum delay time.
CMP BX, 0001H
JNE go_high_freq

; leds status: on, off, off.
MOV AL, 06H

; delay time for the led.
MOV CX, 0F00H

; light up the led.
OUT DX, AL

; delay the operation.
led_delay: LOOP led_delay

; speaker is going to the lowest frequency.
go_low_freq:

; produce a sound from the speaker and delay.
CALL speaker_operation

; increment the delay time.
INC BX

; check if we are in the maximum delay time.
CMP BX, 0FFFH
JNE go_low_freq

; get the index iteration value from the stack.
POP CX

; loop the speaker process.
LOOP speaker_loop

; terminate the program.
JMP halt

; halt the program.
halt: HLT

;;
;; routines.
;;

; a routine which performs an operation by
; using BGC-8088's status port and delays.
delay_operation PROC

; store the delay time.
MOV CX, BX

; perform the operation.
OUT DX, AL

; delay the operation.
delay: LOOP delay

; return from routine.
RET

; end routine.
delay_operation ENDP

; routine which produces a
; speaker pulse and delays.
speaker_operation PROC

; store the first state value.
MOV AL, 0FH

; perform the operation.
CALL delay_operation

; store the second state value.
MOV AL, 07H

; perform the operation.
CALL delay_operation

; return from routine.
RET

; end routine.
speaker_operation ENDP

END
