.include "x16.inc"
.include "zeropage.inc"

.export __wait_for_nmi
.export __init_irq_handler
.export __init_screen_mode
.export __force_halt
.export __get_joystick_state

.export __return_to_command_prompt

VSYNC_FLAG = $70
__wait_for_nmi:
    lda VSYNC_FLAG
    beq __wait_for_nmi

    stz VSYNC_FLAG
    rts
; _________________________________________________

SET_SCREEN_MODE = $FF5F
__init_screen_mode:
    clc
    lda #3     
    jsr SET_SCREEN_MODE
    rts

default_irq: .addr 0
__init_irq_handler:
    lda IRQVec
    sta default_irq
    lda IRQVec+1
    sta default_irq+1

    sei

    lda #<custom_irq
    sta IRQVec
    lda #>custom_irq
    sta IRQVec+1

    ; lda VERA_ien
    ; ora #%10000011

    cli
    rts

custom_irq:
    lda VERA_isr
    bit #%00000001
    beq @run_default_irq

    lda #1
    sta VSYNC_FLAG

    @run_default_irq:
    jmp (default_irq)


; _________________________________________________
joystick_get = $FF56
__get_joystick_state:
    lda #0
    jsr joystick_get

    pha
    txa
    eor #$FF
    tax

    pla
    eor #$FF

    rts
; _________________________________________________
__force_halt:
    brk
    rts
; _________________________________________________
__return_to_command_prompt:
    LDX #$42  ; System Management Controller
    LDY #$02  ; magic location for system reset
    LDA #$00  ; magic value for system poweroff/reset
    JSR $FEC9 ; reset the computer