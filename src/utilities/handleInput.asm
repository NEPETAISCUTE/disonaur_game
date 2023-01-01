SECTION "inputRAM", WRAM0
new_keys:: ds 1
cur_keys:: ds 1

SECTION "handleInput", ROM0

include "hardware.inc"

read_pad::
    ; Poll half the controller
    ld a,P1F_GET_BTN
    call .onenibble
    ld b,a  ; B7-4 = 1; B3-0 = unpressed buttons
  
    ; Poll the other half
    ld a,P1F_GET_DPAD
    call .onenibble
    swap a   ; A3-0 = unpressed directions; A7-4 = 1
    xor b    ; A = pressed buttons + directions
    ld b,a   ; B = pressed buttons + directions
  
    ; And release the controller
    ld a,P1F_GET_NONE
    ldh [rP1],a
  
    ; Combine with previous cur_keys to make new_keys
    ld a,[cur_keys]
    xor b    ; A = keys that changed state
    and b    ; A = keys that changed to pressed
    ld [new_keys],a
    ld a,b
    ld [cur_keys],a
    ret
  
  .onenibble:
    ldh [rP1],a     ; switch the key matrix
    call .knownret  ; burn 10 cycles calling a known ret
    ldh a,[rP1]     ; ignore value while waiting for the key matrix to settle
    ldh a,[rP1]
    ldh a,[rP1]     ; this read counts
    or $F0   ; A7-4 = 1; A3-0 = unpressed keys
  .knownret:
    ret