GSTATE_INTRO = 0
GSTATE_GAME = 1
GSTATE_GAMEOVER = 2
export GSTATE_INTRO
export GSTATE_GAME
export GSTATE_GAMEOVER


SECTION "mainRAM", WRAM0
mainFrameCnt:: ds 2
gamestate:: ds 1
firstStateFrame:: ds 1
backgroundX:: ds 1
SECTION "main", ROM0
main::
    call read_pad
    ld a, [gamestate]
    cp GSTATE_INTRO
    jr nz, .skipIntro
    call intro
    jr .endMain
.skipIntro:
    cp GSTATE_GAME
    jr nz, .skipGame
    call game
    jr .endMain
.skipGame:
    cp GSTATE_GAMEOVER
    jr nz, .endMain
    call gameOver
.endMain:

    ld a, [mainFrameCnt]
    ld b, a
    ld a, [mainFrameCnt+1]
    ld c, a
    inc bc
    ld a, b
    ld [mainFrameCnt], a
    ld a, c
    ld [mainFrameCnt+1], a

    halt 
    jr main
