INCLUDE "hardware.inc"

SECTION "VBlankVector", ROM0[$40]
    jp VBlankInterrupt

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

SECTION "Init", ROM0
EntryPoint:
    di
VBlankWait:
    ld a, [rLY]
    cp 144
    jr c, VBlankWait

    ld a, LCDCF_OFF ;turn off screen
    ld [rLCDC], a

    ld de, TileData
    ld hl, _VRAM8000
    ld bc, SPRITESIZE
    call copyTiles

    ld de, bgData
    ld hl, _VRAM9000
    ld bc, BGSIZE
    call copyTiles
    
    ld a, 0
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * SCRN_VY_B
    call Memset

    ;set DMA code
    ld de, OAMDMACode
    ld hl, StartOAMDMA
    ld bc, OAMDMACODELENGTH
    call Memcpy

    ;clear oam
    ld a, 0
    ld hl, OAMMem
    ld bc, OAM_COUNT * sizeof_OAM_ATTRS
    call Memset



    ld hl, _OAMRAM
    ld bc, OAM_COUNT * sizeof_OAM_ATTRS
OAMClear:
    ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or a, c
    jr nz, OAMClear

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a
    ld a, %11100100
    ld [rBGP], a
    xor %11111111
    ld [rOBP0], a

    ld a, IEF_VBLANK ;let's enable VBlank interrupt
    ld [rIE], a

    ld a, 0
    ld [gamestate], a
    ld [firstIntroFrame], a
    ld [introFrameCnt], a

    ld hl, OAMMem
    ld c, OAM_COUNT
.clearOAM:
    ld [hli], a
    dec c
    jr nz, .clearOAM

    ei
    jp main

SECTION "gfxData", ROM0

TileData:
INCBIN "sprite.2bpp"
SPRITESIZE = @ - TileData
bgData:
INCBIN "bg.2bpp"
BGSIZE = @ - bgData
TILEDATASIZE = @ - TileData