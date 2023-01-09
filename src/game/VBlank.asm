INCLUDE "hardware.inc"
SECTION "VBlankRAM", WRAM0[$C000]
OAMMem:: ds OAM_COUNT * sizeof_OAM_ATTRS

playerY = OAMMem
playerX = OAMMem+1
playerTile = OAMMem+2
playerAttributes = OAMMem+3
export playerX
export playerY
export playerTile
export playerAttributes

SECTION "VBlank", ROM0
VBlankInterrupt::
    push af
    push bc
    push de
    push hl

    ld a, [backgroundX]
    ld [rSCX], a
    
    call StartOAMDMA

    pop hl
    pop de
    pop bc
    pop af
    reti

OAMDMACode::
LOAD "OAMDMA", HRAM
StartOAMDMA::
    ld a, HIGH(OAMMem)
    ldh [rDMA], a  
    ld a, OAM_COUNT        ; delay for a total of 4×40 = 160 cycles
.wait::
    dec a
    jr nz, .wait
    ret 
OAMDMACODELENGTH = @ - StartOAMDMA
EXPORT OAMDMACODELENGTH