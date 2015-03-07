;;;;
;;
;;  This program handles the BGC-8088's leds by using the status port.
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
name "bgc-leds"

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

; max iterations of leds operation.
MOV CX, 000AH

; start delay time (low frequency).
MOV BX, 0FFFH

; leds main loop process.
leds_loop:

; store the index iteration value to the stack.
PUSH CX

; leds are going to the highest frequency.
go_high_freq:

; on-off the leds sequentially and delay.
CALL leds_operation

; decrement the delay time.
DEC BX

; check if we are in the minimum delay time.
CMP BX, 0001H
JNE go_high_freq

; leds are going to the lowest frequency.
go_low_freq:

; on-off the leds sequentially and delay.
CALL leds_operation

; increment the delay time.
INC BX

; check if we are in the maximum delay time.
CMP BX, 0FFFH
JNE go_low_freq

; get the index iteration value from the stack.
POP CX

; loop the leds process.
LOOP leds_loop

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

; a routine which uses the leds sequentiallly.
leds_operation PROC

; leds status: on, off, off.
MOV AL, 06H

; perform the operation.
CALL delay_operation

; leds status: on, on, off.
MOV AL, 04H

; perform the operation.
CALL delay_operation

; leds status: on, on, on.
MOV AL, 00H

; perform the operation.
CALL delay_operation

; leds status: off, on, on.
MOV AL, 01H

; perform the operation.
CALL delay_operation

; leds status: off, off, on.
MOV AL, 03H

; perform the operation.
CALL delay_operation

; leds status: off, off, off.
MOV AL, 07H

; perform the operation.
CALL delay_operation

; return from routine.
RET

; end routine.
leds_operation ENDP

END
