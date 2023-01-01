SECTION "MATH", ROM0


;Div 8: d=a/d, remain a
;a = dividend
;d = divisor
;a = remain
;d = result
;e's contents are destroyed
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