INCLUDE "hardware.inc"

SECTION UNION "renderHRAM", HRAM
bcBackup: ds 2
SECTION "renderRAM", WRAM0

SECTION "render", ROM0
LCDOff::
    ldh a, [rLY]
    cp 144
    jr c, LCDOff
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ret
; @param de Source
; @param hl Destination
; @param c Length
LCDMemcpy::
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, LCDMemcpy
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, LCDMemcpy
    ret
;works only after LCD was turned off
; @param de Source
; @param hl Destination
; @param bc Length
Memcpy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, Memcpy
    ret 

; @param b Value
; @param hl Destination
; @param c Length
LCDMemset::
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, LCDMemset
    ld a, b
    ld [hli], a
    dec c
    jr nz, LCDMemset
    ret

; @param b Value
; @param hl Destination
; @param c Length
; a trashed
LCDMemsetV::
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, LCDMemsetV
    ld [hl], b
    ld a, SCRN_VX_B
    add a, l
    ld l, a
    jr nc, .nocarry
    inc h
.nocarry:
    dec c
    jr nz, LCDMemsetV
    ret
    
;works only after LCD was turned off
; @param a Value
; @param hl Destination
; @param bc Length
Memset::
    ld d, a
.BGClear:
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or a, c
    jr nz, .BGClear
    ret
; @param de Tiles
; @param hl Destination
; @param bc length
copyTiles::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc ;dec r16 doesn't set flags so we have to compare ourselves
    ld a, b 
    or a, c ;if b or c == 0 it means bc == 0
    jr nz, copyTiles
    ret