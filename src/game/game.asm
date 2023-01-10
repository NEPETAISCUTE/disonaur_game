INCLUDE "hardware.inc"

GROUND_HEIGHT = $0E

SECTION "MainGameRAM", WRAM0
groundMap: ds SCRN_VX_B
mapPointer: ds 1
genPointer: ds 1

animFrameCnt:: ds 1

jumpStart: ds 1
isDescent: ds 1
SECTION "MainGame", ROM0
game::
    ld a, [firstStateFrame]
    and a
    jr nz, .skipFirstFrameLoading

    call initFrame

.skipFirstFrameLoading:

    ld a, [jumpStart]
    cp a, $FF
    jr nz, .jumpCheck

    ld a, [isDescent]
    and a
    jr nz, .doDescent

    ld a, [new_keys]
    and PADF_A
    jr z, .endJump

    ld a, [playerY]
    ld [jumpStart], a

    ld hl, playerY
    dec [hl]

    jp .endJump

.jumpCheck:
    ld a, [cur_keys]
    and PADF_A
    jr z, .startDescent

    ld hl, playerY
    dec [hl]

    ld a, [jumpStart]
    sub [hl]
    cp $2F
    jr c, .endJump

.startDescent:
    ld a, $FF
    ld [jumpStart], a
    ld a, 1
    ld [isDescent], a
    jr .endJump
.doDescent:
    ld hl, playerY
    inc [hl]

    ld a, [playerY]
    cp $78
    jr c, .endJump

    ld a, [playerX]
    ld b, a
    ld a, [backgroundX]
    add b
    ld d, 8
    call Div8
    ld e, d
    ld d, 0
    jr z, .skipLastTileCheck

    inc e
    ld a, e
    cp SCRN_VX_B
    jr nz, .skipWrapAround
    ld de, 0
.skipWrapAround:
    add hl, de
    ld a, 0
    cp [hl]
    jr nz, .stopDescent
    dec e

.skipLastTileCheck:
    ld a, $ff
    cp e
    jr nz, .skipWrapAround2
    ld de, SCRN_VX_B-1
.skipWrapAround2:
    add hl, de
    ld a, 0
    cp [hl]
    jr nz, .stopDescent
    jr .endJump

.stopDescent
    ld a, 0
    ld [isDescent], a
    ld a, $78
    ld [playerY], a

.endJump:

    call handleAnim

    ld hl, backgroundX
    inc [hl]

    ld a, [hl]
    ld d, 8
    call Div8
    and a
    call z, updateMap

    ld hl, mapPointer
    ld a, [genPointer]
    cp [hl]
    jr nz, .skipMapGen

    call mapGen
    ld a, [genPointer]
    add SCRN_VX_B - SCRN_X_B
    cp $19
    jr nc, .skipMapGen

    sub $20
    ld [genPointer], a

.skipMapGen:

    ret


initFrame:
    call LCDOff
    
    ld a, 0
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * (SCRN_Y_B-4)
    call Memset

    ld a, $01
    ld hl, _SCRN0 + (SCRN_VX_B * $0E)
    ld bc, SCRN_VX_B
    call Memset

    ld d, $02
    ld hl, _SCRN0 + (SCRN_VX_B * $0F)
    ld e, 0
.groundLoop:
    ld a, d
    ld bc, SCRN_VX_B
    call Memset
    ld a, d
    ld d, 0
    add hl, de
    ld d, a
    ld a, $40
    cp l
    jr nz, .groundLoop

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ld a, 0
    ld [backgroundX], a
    ld [isDescent], a

    ld a, $FF
    ld [jumpStart], a

    ld a, $78
    ld [playerY], a

    ld b, b
    ld a, $15
    ld [mapPointer], a
    ld [genPointer], a

    ld a, 1
    ld [firstStateFrame], a
    ld [playerTile], a

    ret

handleAnim:
    ld a, [animFrameCnt]
    cp 6
    jr nz, .skipAnimCnt
    ld a, 0
    ld [animFrameCnt], a
    ld hl, OAMMem+2
    inc [hl]
    ld a, 5
    cp [hl]
    jr nz, .skipAnimCnt
    ld a, 1
    ld [hl], a
.skipAnimCnt:
    ld hl, animFrameCnt
    inc [hl]

    ld a, [jumpStart]
    cp $FF
    jr z, .skipJumpUpFrame

    ld a, $12
    ld [playerTile], a
.skipJumpUpFrame:

    ld a, [isDescent]
    and a
    jr z, .skipFallDownFrame

    ld a, $13
    ld [playerTile], a
.skipFallDownFrame:
    ret

PUSHS
SECTION UNION "mapGenRam", HRAM
    counter: ds 1
POPS

mapGen:

    ld hl, groundMap
    ld a, [genPointer]
    ld c, a
    ld b, 0

    add hl, bc
    ld c, SCRN_VX_B - SCRN_X_B
.loop:
    ld d, h
    ld e, l
    ld a, c
    ld [counter], a
    call rand
    ld b, a
    ld a, [counter]
    ld c, a
    ld a, b
    and a
    jr z, .handleHole

    ld h, d
    ld l, e
    ld [hli], a
    ld a, h
    cp HIGH(groundMap+$20)
    jr nz, .skipWrapAround
    ld a, l
    cp LOW(groundMap+$20)
    jr nz, .skipWrapAround

    ld hl, groundMap
.skipWrapAround:

    dec c
    jr nz, .loop

    ld a, [genPointer]
    add SCRN_VX_B - SCRN_X_B
    cp SCRN_VX_B
    jr nc, .skipWrapAroundPointer

    sub SCRN_VX_B
.skipWrapAroundPointer:
    ld [genPointer], a
    ret

.handleHole:
    ld a, c
    ld [counter], a
    call rand
    ld h, d
    ld l, e
    ld d, 3
    call Div8
    inc a
    ld c, a
    ld a, [counter]
    sub c
    ld [counter], a
    ld b, 0
.writeLoop:
    ld a, b
    ld [hli], a
    dec c
    ld a, h
    cp HIGH(groundMap+$20)
    jr nz, .skipWrapAround2
    ld a, l
    cp LOW(groundMap+$20)
    jr nz, .skipWrapAround2

    ld hl, groundMap
.skipWrapAround2:
    ld a, c
    and a
    jr nz, .writeLoop

    ld a, [counter]
    ld c, a
    jr .loop

updateMap:
    ld a, [mapPointer]
    ld e, a
    ld d, 0
    ld hl, groundMap
    add hl, de
    ld a, 0
    cp [hl]
    ld hl, _SCRN0 + (SCRN_VX_B * GROUND_HEIGHT)
    jr nz, .drawGround

    add hl, de
    ld b, 0
    ld c, 4
    call LCDMemsetV

    jr .End

.drawGround
    add hl, de
    ld b, 1
    ld c, 1
    call LCDMemset

    ld hl, _SCRN0 + (SCRN_VX_B * GROUND_HEIGHT+1)
    add hl, de
    ld b, 2
    ld c, 4
    call LCDMemsetV

.End:
    ld hl, mapPointer
    inc [hl]
    ld a, $20
    cp [hl]
    jr nz, .skipWrap

    ld a, 0
    ld [mapPointer], a

.skipWrap:
    ret