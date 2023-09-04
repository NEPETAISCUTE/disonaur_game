INCLUDE "hardware.inc"
INCLUDE "spriteAnim.inc"

GROUND_HEIGHT = $0E

SECTION "MainGameRAM", WRAM0
groundMap: ds SCRN_VX_B
mapPointer: ds 1
genPointer: ds 1
isJumping: ds 1

playerPosX: ds 2
playerPosY: ds 2
playerVelX: ds 2
playerVelY: ds 2
playerAccelX: ds 1
playerAccelY: ds 1

playerAnim:: ds 1

SECTION "MainGame", ROM0
game::
    ld a, [firstStateFrame]
    and a
    jr nz, .skipFirstFrameLoading

    call initFrame

.skipFirstFrameLoading:

    ld a, [new_keys]

    call handleAnim

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


    ld a, $00
    ld [playerPosX], a
    ld [playerPosY], a
    ld [playerVelX], a
    ld [playerVelY], a
    ld [playerAccelX], a
    ld [playerAccelY], a

    ld a, $20
    ld [playerPosX+1], a
    ld a, $78
    ld [playerPosY+1], a

    ld a, SCRN_VX_B-SCRN_X_B
    ld [mapPointer], a
    ld [genPointer], a

    ld a, 1
    ld [firstStateFrame], a
    ld [playerTile], a

    ret

handleAnim:
    ld a, [playerVelY]
    cp 0
    jr c, .setJumping
    jr nz, .setFalling

    ld a, [playerAccelX]
    cp 0
    jr z, .setIdle

    ld a, [playerAnim]
    cp 6
    jr nz, .skipAnimCnt
    ld a, 0
    ld [playerAnim], a
    ld hl, OAMMem+2
    inc [hl]
    ld a, 5
    cp [hl]
    jr nz, .skipAnimCnt
    ld a, 1
    ld [hl], a
.skipAnimCnt:
    ld hl, playerAnim
    inc [hl]
    ret

.setIdle:
    ld a, ANIM_PLAYER_IDLE
    ld [playerTile], a
    ret

.setJumping:
    ld a, ANIM_PLAYER_JUMP
    ld [playerTile], a
    ret 

.setFalling:
    ld a, ANIM_PLAYER_FALL
    ld [playerTile], a
    ret

PUSHS
SECTION UNION "mapGenRam", HRAM
    counter: ds 1
POPS

