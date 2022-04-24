;;;;
;;
;;  This program solves the equation: ax+b=0.
;;
;;  Copyright (C) 2009 Efstathios Chatzikyriakidis (stathis.chatzikyriakidis@gmail.com)
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
name "equation-solver"

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

; set general registers.

#AX=0000H#
#BX=0000H#
#CX=0000H#
#DX=0000H#
#SI=0000H#
#DI=0000H#
#BP=0000H#

;;
;; library includes.
;;

; include macro definitions
; library for input/output.
INCLUDE "emu8086.inc"

;;
;; working point.
;;

; clear the screen.
CALL CLEAR_SCREEN

; print header message.
CALL print_header_msg

; input data offset.
CALL input_data_offset

; store the data offset.
MOV DI, CX

;;
;; data memory initial values.
;;

; init with zero values the data region.

MOV [0600H+DI], 00H ; 1st byte data offset.
MOV [0601H+DI], 00H ; 2nd byte ^
MOV [0602H+DI], 00H ; 1st byte value a.
MOV [0603H+DI], 00H ; 2nd byte ^
MOV [0604H+DI], 00H ; 1st byte value b.
MOV [0605H+DI], 00H ; 2nd byte ^
MOV [0606H+DI], 00H ; 1st byte quotient.
MOV [0607H+DI], 00H ; 2nd byte ^
MOV [0608H+DI], 00H ; 1st byte remainder.
MOV [0609H+DI], 00H ; 2nd byte ^

; sign flag.
MOV [060AH+DI], 00H

; print new line.
PRINTN

; input equation value a.
CALL input_value_a

; store the value a.
MOV AX, CX

; print new line.
PRINTN

; input equation value b.
CALL input_value_b

; store the value b.
MOV BX, CX

; store a, b values and data
; offset to the data region.

MOV [0600H+DI], DI ; store data offset.
MOV [0602H+DI], AX ; store value a.
MOV [0604H+DI], BX ; store value b.

; print new lines.
PRINTN
PRINTN

; if the value a is zero then the
; equation is probably impossible.
CMP AX, 0000H
JE maybe_impossible

; if the value b is zero then
; the equation has no meaning.
CMP BX, 0000H
JE meaningless

; print calculation message.
PRINT 'Calculating...'

; print new lines.
PRINTN
PRINTN

; do the division and return both
; the quotient and the remainder.
CALL signed_division

; store both the quotient and the
; remainder value to data region.

MOV [0606H+DI], DX ; store the quotient.
MOV [0608H+DI], BX ; store the remainder.

; have the root of the equation by
; doing the complement of quotient.
NEG DX

; print the result message.
PRINT 'The result is: x='

; print the root value.
MOV AX, DX
CALL PRINT_NUM

; print start remainder message.
PRINT ' (Remainder: '

; print the remainder value.
MOV AX, BX
CALL PRINT_NUM

; print end remainder message.
PRINT ').'

; jump to halt and terminate.
JMP halt

;;
;; the following jump regions are used in order to find
;; if the equation is impossible, vague or meaningless.
;;

; equation maybe is impossible. we must
; check also the value of b to be sure.
maybe_impossible:

; if the value b is zero
; the equation is vague.
CMP BX, 0000H
JE vague

; print impossible equation message.
PRINT 'The equation is impossible.'

; jump to halt and terminate.
JMP halt

; equation is vague.
vague:

; print vague equation message.
PRINT 'The equation is vague.'

; jump to halt and terminate.
JMP halt

; equation is meaningless.
meaningless:

; print meaningless equation message.
PRINT 'The equation has no meaning.'

; jump to halt and terminate.
JMP halt

; halt the program.
halt: HLT

;;
;; routines.
;;

; routine which prints header info.
print_header_msg:

; print the header message of the program.
PRINT 'Solving Equation: [ax+b=0].'

; print new line.
PRINTN

; return.
RET

; routine which inputs value a.
input_value_a:

; print input message.
PRINT 'Input value for 'a' (dec): '

; input value from user.
CALL SCAN_NUM

; return.
RET

; routine which inputs value b.
input_value_b:

; print input message.
PRINT 'Input value for 'b' (dec): '

; input value from user.
CALL SCAN_NUM

; return.
RET

; routine which inputs data offset.
input_data_offset:

; loop until the user gets a positive
; decimal value for the data address.
positive_data_offset:

; print new line.
PRINTN

; print input message.
PRINT 'Input data offset (dec>=0): '

; input value from user.
CALL SCAN_NUM

; check if the input is negative.
CMP CX, 0000H
JL positive_data_offset

; return.
RET

; routine which does signed division.
signed_division:

; if value b is negative
; then make it positive.
CMP BX, 0000H
JL complement_b

; key position a.
temp_a:

; if value a is negative
; then make it positive.
CMP AX, 0000H
JL complement_a

; key position b.
temp_b:

; if value b is less than value a.
CMP BX, AX
JL b_less_than_a

; perform divisions using substracts and
; return the quotient and the remainder.
substracts:

; increase quotient by one.
INC DX

; substact b and a values.
SUB BX, AX

; if the result of the substraction is
; above or equal to value a then loop.
CMP BX, AX
JAE substracts

; store to the register the sign flag.
MOV CL, [060AH+DI]

; if sign flag is zero alt
; the sign of the quotient.
CMP CL, 00H
JE complement_quotient

; if sign flag is one change
; the sign of the remainder.
CMP CL, 01H
JE complement_remainder

; if sign flag is three alt
; the sign of both values.
CMP CL, 03H
JE complement_div_vals

; here the division ends.
end_div:

; complement the quotient.
NEG DX

; return the routine.
RET

;;
;; signed division jump regions.
;;

; value b is less than value a.
b_less_than_a:

; store to the register the sign flag.
MOV CL, [060AH+DI]

; if sign flag is one change
; the sign of the remainder.
CMP CL, 01H
JE complement_remainder

; if sign flag is three alt
; the sign of the remainder.
CMP CL, 03H
JE complement_remainder

; end the process.
JMP end_div

; return the complement of remainder.
complement_remainder:

; get the complement of it.
NEG BX

; end the process.
JMP end_div

; return the complement of quotient.
complement_quotient:

; get the complement of it.
NEG DX

; end the process.
JMP end_div

; return the complement of div values.
complement_div_vals:

; get the complement of them.
NEG BX
NEG DX

; end the process.
JMP end_div

; we are in the initial
; state of sign values.
initial_sign_state:

; store to the sign flag value three.
MOV [060AH+DI], 03H

; jump to key position b.
JMP temp_b

; return the complement of value b.
complement_b:

; store to the sign flag value one.
MOV [060AH+DI], 01H

; get the complement of it.
NEG BX

; jump to key position a.
JMP temp_a

; return the complement of value a.
complement_a:

; get the complement of it.
NEG AX

; store to the register the sign flag.
MOV CL, [060AH+DI]

; if sign flag is one then
; go to initial sign state.
CMP CL, 01H
JE initial_sign_state

; store to the sign flag value two.
MOV [060AH+DI], 02H

; jump to key position b.
JMP temp_b

;;
;; i/o routines' defines.
;;

; routine for input signed nums.
DEFINE_SCAN_NUM

; routine for printing signed nums.
DEFINE_PRINT_NUM

; routine for printing unsigned nums.
DEFINE_PRINT_NUM_UNS

; routine to clear the screen.
DEFINE_CLEAR_SCREEN

END
