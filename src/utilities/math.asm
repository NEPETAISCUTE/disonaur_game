SECTION "MATH", ROM0
;Mul 8: a=d*b
;@param a val1
;@param d val2
;@return a result (modulo'd by 256)
Mul8::
    ld a, 0
    or a    ;clear flags
.Loop
    jr z, .End
    add b
    dec d
    jr .Loop
.End:
    ret

;Mul 16: hl+=b*c
;yes, if hl is non-zero, the result of the multiplication is added, nice little quirk right there
;@param hl initVal
;@param b val1
;@param c val2
; a,b trashed
AMul16::
    ld a, b
	ld b, 0
	or a ; clears carry
.loop
	rra ; check bit 0, shift a, carry must be reset
	jr nc, :+
	add hl, bc ; add if carry set
:	sla c ; shift bc left
	rl b
	and a ; end as soon as out of bits, also clears carry
	jr nz, .loop
	ret
    

;Div 8: d=a/d, remain a
;@param a dividend
;@param d divisor
;@return a remain
;@return d result
;e trashed
Div8::
    ld e, d
    ld d, 0      
    cp a, e
    jr c, .End
.loop:
    inc d
    sub a, e
    cp a, e
    jr nc, .loop
.End:
    ret 


;Div16: bc=hl/a, remain hl
;Div16::
;    ld bc, 0
;    ld d, a
;    cp a, l
;    jr nc, .loop
;    ld a, 0
;    or a, h
;    jr z, .End
;.loop:
;    ld a, l
;    sub a, d
;    ld l, a
;    jr z, .skipCarryHandler
;    call c, carryHandler
;    jr z, .End
;    dec h
;.skipCarryHandler:
;    inc bc
;    jr .loop
;.End:
;    ret
;
;carryHandler:
;    ld a, 0
;    or a, h
;    ret
Div16::
    ; input: hl = dividend, a = divisor
    ; output: hl = quotient, a = remainder
        push bc  ; preserve scratch registers
        ld b, a  ; b = divisor
        ld c, 16 ; c = counter
        xor a
    .loop
        add hl, hl
        adc a
        jr c, .subtract
        cp b
        jr c, .no_subtract
    .subtract
        sub b
        inc l
    .no_subtract
        dec c
        jr nz, .loop
        pop bc
    .end:
        ret