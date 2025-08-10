.include "x16.inc"
.include "zeropage.inc"

.export __load_palette_from_file
.export __load_file_into_vram
.export __load_file_into_ram

.export __set_layer0_enable
.export __set_layer1_enable
.export __set_sprites_enable

.export __set_sprite_attribute
.export __offset_spr_position
.export __set_spr_x_position
.export __set_spr_y_position
.export __clear_sprite_attribute
.export __clear_spr_attributes
.export __set_sprite_address
.export __darken_palette
.export __lighten_palette
.export __darken_palette_sec
.export __lighten_palette_sec
.export __darken_palette_col
.export __lighten_palette_col

; _load_palette_from_file(int fname_ptr, char fname_size, char pal_off):
; fname_ptr: filename pointer - a pointer to the filename string
; fname_size: filename size - the size of the filename in bytes
; pal_off: palette offset - (must be from 0-15) the offset in the palette table 
;                           where the palette file will be loaded
__load_palette_from_file:
    stz VERA_ctrl

    ; storing the variables loaded
    ; by pushing them onto the stack
    tay

    lda RAM_BANK_SEL
    pha

    phy

    lda (sp)
    inc sp
    pha 
    
    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    ; reading the file into vram
    lda #1
    ldx #8
    ldy #0
    jsr SETLFS

    ply ; pulling filename start addr
    plx ; off of the stack
    pla ; pulling filename size off stack
    jsr SETNAM
    
    pla ; pulling the palette offset off stack
    asl ; shfiting the bits right to
    asl ; multiply the number of 32
    asl ; (size in bytes of 1 palette block)
    asl
    asl

    ; adding this value to palette address in vram
    php
    clc 
    adc #<VRAM_palette
    tax

    ; setting high byte of vram palette accounting for
    ; carry from last operation
    lda #>VRAM_palette
    plp
    adc #0
    tay

    lda #3
    jsr LOAD

    pla
    sta RAM_BANK_SEL
    rts
; _________________________________________________
; _load_file_into_vram(int fname_ptr, char fname_size, int ram_addr):
; fname_ptr: filename pointer - a pointer to the filename string
; fname_size: filename size - the size of the filename in bytes
; ram_addr: ram addreass - the location where the data is actually loaded
__load_file_into_ram:
    pha
    phx

    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    lda #1
    ldx #8
    ldy #0
    jsr SETLFS

    ply ; pulling filename start addr
    plx ; off of the stack
    pla ; pulling filename size off stack
    jsr SETNAM

    lda #0
    ply
    plx
    jsr LOAD

    rts

; _________________________________________________
; _load_file_into_vram(int fname_ptr, char fname_size, char vram_bank, int vram_addr):
; fname_ptr: filename pointer - a pointer to the filename string
; fname_size: filename size - the size of the filename in bytes
; vram_bank: vram bank - (must be from 0-1) the bank to load the data into
; vram_addr: vram addreass - the location where the data is actually loaded
__load_file_into_vram:
    stz VERA_ctrl
    
    ; storing the variables loaded
    ; by pushing them onto the stack
    pha 
    phx

    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    lda (sp)
    inc sp
    pha

    ; reading the file into vram
    lda #1
    ldx #8
    ldy #0
    jsr SETLFS

    ply ; pulling filename start addr
    plx ; off of the stack
    pla ; pulling filename size off stack
    jsr SETNAM

    pla 
    clc
    adc #02
    ply
    plx
    jsr LOAD

    rts

; _________________________________________________
; _set_layer0_enable(char enable)
; enable - 0 for diable, 1 for enable
__set_layer0_enable:
    bne @enable
    lda VERA_dc_video
    and #%11101111
    sta VERA_dc_video
    rts

    @enable:
    lda VERA_dc_video
    ora #%00010000
    sta VERA_dc_video
    rts
; _________________________________________________
__set_layer1_enable:
    bne @enable
    lda VERA_dc_video
    and #%11011111
    sta VERA_dc_video
    rts

    @enable:
    lda VERA_dc_video
    ora #%00100000
    sta VERA_dc_video
    rts
; _________________________________________________
__set_sprites_enable:
    bne @enable
    lda VERA_dc_video
    and #%10111111
    sta VERA_dc_video
    rts

    @enable:
    lda VERA_dc_video
    ora #%01000000
    sta VERA_dc_video
    rts
    brk
    rts
; _________________________________________________
; _set_sprite_attribute(char attr_num, int addr, char bpp_mode, int x, int y, char spr_attr, char size, char pal_off)
TEMP_ADDR = ZP_PTR_1
TEMP_SPR_ADDR = ZP_PTR_2
__set_sprite_attribute:
    pha

    ldy #9
    lda (sp), y
    sta TEMP_SPR_ADDR
    stz TEMP_SPR_ADDR+1

    .repeat 3
        asl TEMP_SPR_ADDR
        rol TEMP_SPR_ADDR+1
    .endrepeat

    stz VERA_ctrl
    lda TEMP_SPR_ADDR
    clc
    adc #<VRAM_sprattr
    sta VERA_addr_low
    
    lda TEMP_SPR_ADDR+1
    adc #>(VRAM_sprattr)
    sta VERA_addr_high

    lda #%00010001
    sta VERA_addr_bank

    ldy #7 ; setting the lower address
    lda (sp), y
    sta TEMP_ADDR
    iny 
    lda (sp), y
    sta TEMP_ADDR+1


    ldy #6 ; setting bpp mode
    lda (sp), y
    .repeat 7
        asl
    .endrepeat
    ora TEMP_ADDR+1
    sta TEMP_ADDR+1

    lda TEMP_ADDR
    sta VERA_data0

    lda TEMP_ADDR+1
    sta VERA_data0

    ; setting x and y position of sprite 
    ldy #4
    lda (sp),y
    sta VERA_data0
    iny
    lda (sp),y
    sta VERA_data0

    ldy #2
    lda (sp),y
    sta VERA_data0
    iny
    lda (sp),y
    sta VERA_data0
    ; ---------------------------------
    ldy #1
    lda (sp),y
    sta VERA_data0

    lda (sp)
    asl
    asl
    asl
    asl
    sta ZP_PTR_1
    pla
    ora ZP_PTR_1
    sta VERA_data0


    lda sp
    clc
    adc #10
    sta sp

    rts
; _________________________________________________
; _set_spr_x_position(int x_pos, char attr_num)
__set_spr_x_position:
    sta TEMP_SPR_ADDR
    stz TEMP_SPR_ADDR+1
    .repeat 3
        asl TEMP_SPR_ADDR
        rol TEMP_SPR_ADDR+1
    .endrepeat

    stz VERA_ctrl
    lda TEMP_SPR_ADDR
    clc
    adc #<(VRAM_sprattr+2)
    sta VERA_addr_low
    lda TEMP_SPR_ADDR+1
    adc #>(VRAM_sprattr+2)
    sta VERA_addr_high
    lda #%00010001
    sta VERA_addr_bank

    lda (sp)
    inc sp
    sta VERA_data0
    lda (sp)
    inc sp
    sta VERA_data0

    rts
; _________________________________________________
; _set_spr_y_position(int y_pos, char attr_num)
__set_spr_y_position:
    sta TEMP_SPR_ADDR
    stz TEMP_SPR_ADDR+1
    .repeat 3
        asl TEMP_SPR_ADDR
        rol TEMP_SPR_ADDR+1
    .endrepeat

    stz VERA_ctrl
    lda TEMP_SPR_ADDR
    clc
    adc #<(VRAM_sprattr+4)
    sta VERA_addr_low
    lda TEMP_SPR_ADDR+1
    adc #>(VRAM_sprattr+4)
    sta VERA_addr_high
    lda #%00010001
    sta VERA_addr_bank

    lda (sp)
    inc sp
    sta VERA_data0
    lda (sp)
    inc sp
    sta VERA_data0

    rts
; _________________________________________________
; _set_spr_position(char attr_num, int x_pos, int y_pos)
__set_spr_position:
    phx
    pha

    ldy #2
    lda (sp), y
    sta TEMP_SPR_ADDR
    stz TEMP_SPR_ADDR+1

    .repeat 3
        asl TEMP_SPR_ADDR
        rol TEMP_SPR_ADDR+1
    .endrepeat


    stz VERA_ctrl
    lda TEMP_SPR_ADDR
    clc
    adc #<(VRAM_sprattr+2)
    sta VERA_addr_low
    lda TEMP_SPR_ADDR+1
    adc #>(VRAM_sprattr+2)
    sta VERA_addr_high
    lda #%00010001
    sta VERA_addr_bank


    lda (sp)
    inc sp
    sta VERA_data0
    lda (sp)
    inc sp
    sta VERA_data0

    pla
    sta VERA_data0
    pla
    sta VERA_data0

    inc sp
    rts
; _________________________________________________
; _offset_spr_position(char attr_num, int x_pos, int y_pos)
__offset_spr_position:
    phx
    pha

    ldy #2
    lda (sp), y
    sta TEMP_SPR_ADDR
    stz TEMP_SPR_ADDR+1

    .repeat 3
        asl TEMP_SPR_ADDR
        rol TEMP_SPR_ADDR+1
    .endrepeat


    lda #1
    sta VERA_ctrl

    lda TEMP_SPR_ADDR
    clc
    adc #<(VRAM_sprattr+2)
    sta VERA_addr_low
    stz VERA_ctrl
    sta VERA_addr_low
    
    lda #1
    sta VERA_ctrl
    lda TEMP_SPR_ADDR+1
    adc #>(VRAM_sprattr+2)
    sta VERA_addr_high
    stz VERA_ctrl
    sta VERA_addr_high

    lda #1
    sta VERA_ctrl
    lda #%00010001
    sta VERA_addr_bank
    stz VERA_ctrl
    sta VERA_addr_bank

    clc
    lda VERA_data1
    adc (sp)
    inc sp
    sta VERA_data0
    
    lda VERA_data1
    adc (sp)
    inc sp
    sta VERA_data0

    clc
    pla
    adc VERA_data1 
    sta VERA_data0
    
    pla
    adc VERA_data1
    sta VERA_data0

    inc sp
    rts
; _________________________________________________
; _clear_sprite_attribute(char attr_num)
VERA_ADDR = ZP_PTR_1
__clear_sprite_attribute:
    stz VERA_ctrl

    clc
    asl
    sta VERA_ADDR
    lda #0
    rol 
    sta VERA_ADDR+1

    clc
    lda VERA_ADDR
    asl
    sta VERA_ADDR
    lda VERA_ADDR+1
    rol 
    sta VERA_ADDR+1

    clc
    lda VERA_ADDR
    asl
    sta VERA_ADDR
    lda VERA_ADDR+1
    rol 
    sta VERA_ADDR+1
    

    lda #<(VRAM_sprattr+6)
    clc
    adc VERA_ADDR
    sta VERA_addr_low
    
    lda VERA_ADDR+1
    adc #>(VRAM_sprattr+6)
    sta VERA_addr_high

    lda #%00000001
    sta VERA_addr_bank
    stz VERA_data0

    rts
    ; lda default_irq
    ; sta IRQVec
    ; lda default_irq+1
    ; sta IRQVec+1

    LDX #$42  ; System Management Controller
    LDY #$02  ; magic location for system reset
    LDA #$00  ; magic value for system poweroff/reset
    JSR $FEC9 ; reset the computer

    ; jmp SCINIT
    ; rts
; _________________________________________________
TEMP_SUB_VAL = ZP_PTR_1
TEMP_SUB_VAL2 = ZP_PTR_2
TEMP_COLOUR = ZP_PTR_3
; _darken_palette(u8 darken_value)
__darken_palette:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    ; set up VERA data port 0
        stz VERA_ctrl
        lda #(<VRAM_palette)
        sta VERA_addr_low
        lda #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda #(<VRAM_palette)
        sta VERA_addr_low
        lda #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldx #255
    ldy #2
    @reset_loop:
        @palette_colour_loop:
            lda VERA_data0
            pha
            and #(%00001111)
            sta TEMP_COLOUR

            pla

            .repeat 4
                lsr
            .endrepeat
            
            sec 
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow1
            lda #0
            @skip_sub_overflow1:

            .repeat 4
                asl
            .endrepeat

            pha

            lda TEMP_COLOUR
            sec
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow2
            lda #0
            @skip_sub_overflow2:
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    dey
    bne @reset_loop

    rts
; _________________________________________________
; _lighten_palette(u8 lighten_value)
__lighten_palette:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    ; set up VERA data port 0
        stz VERA_ctrl
        lda #(<VRAM_palette)
        sta VERA_addr_low
        lda #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda #(<VRAM_palette)
        sta VERA_addr_low
        lda #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldy #2
    @reset_loop:
        ldx #255
        @palette_colour_loop:
            lda VERA_data0
            pha
            .repeat 4
                asl
            .endrepeat
            sta TEMP_COLOUR

            pla

            clc 
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow1
            lda #$FF
            @skip_sub_overflow1:
            and #(%11110000)

            pha

            lda TEMP_COLOUR
            clc
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow2
            lda #$FF
            @skip_sub_overflow2:
            .repeat 4
                lsr
            .endrepeat
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    dey
    bne @reset_loop

    rts
; _________________________________________________
; _darken_palette_sec(u8 palette_ind, u8 darken_value)
TEMP_PAL_ADDR_OFF = ZP_PTR_4
__darken_palette_sec:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    lda (sp)
    inc sp
    sta TEMP_PAL_ADDR_OFF
    stz TEMP_PAL_ADDR_OFF+1
    .repeat 5
        asl TEMP_PAL_ADDR_OFF
        ror TEMP_PAL_ADDR_OFF+1
    .endrepeat


    ; set up VERA data port 0
        stz VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldx #32
        @palette_colour_loop:
            lda VERA_data0
            pha
            and #(%00001111)
            sta TEMP_COLOUR

            pla

            .repeat 4
                lsr
            .endrepeat
            
            sec 
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow1
            lda #0
            @skip_sub_overflow1:

            .repeat 4
                asl
            .endrepeat

            pha

            lda TEMP_COLOUR
            sec
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow2
            lda #0
            @skip_sub_overflow2:
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    rts
; _________________________________________________
; _lighten_palette_sec(u8 palette_ind, u8 lighten_value)
__lighten_palette_sec:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    lda (sp)
    inc sp
    sta TEMP_PAL_ADDR_OFF
    stz TEMP_PAL_ADDR_OFF+1
    .repeat 5
        asl TEMP_PAL_ADDR_OFF
        ror TEMP_PAL_ADDR_OFF+1
    .endrepeat


    ; set up VERA data port 0
        stz VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldx #32
        @palette_colour_loop:
            lda VERA_data0
            pha
            .repeat 4
                asl
            .endrepeat
            sta TEMP_COLOUR

            pla

            clc 
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow1
            lda #$FF
            @skip_sub_overflow1:
            and #(%11110000)

            pha

            lda TEMP_COLOUR
            clc
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow2
            lda #$FF
            @skip_sub_overflow2:
            .repeat 4
                lsr
            .endrepeat
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    rts
; _________________________________________________
; _darken_palette_col(u8 palette_ind, u8 darken_value)
__darken_palette_col:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    lda (sp)
    inc sp
    sta TEMP_PAL_ADDR_OFF
    stz TEMP_PAL_ADDR_OFF+1
    asl TEMP_PAL_ADDR_OFF
    ror TEMP_PAL_ADDR_OFF+1


    ; set up VERA data port 0
        stz VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldx #2
        @palette_colour_loop:
            lda VERA_data0
            pha
            and #(%00001111)
            sta TEMP_COLOUR

            pla

            .repeat 4
                lsr
            .endrepeat
            
            sec 
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow1
            lda #0
            @skip_sub_overflow1:

            .repeat 4
                asl
            .endrepeat

            pha

            lda TEMP_COLOUR
            sec
            sbc TEMP_SUB_VAL
            bcs @skip_sub_overflow2
            lda #0
            @skip_sub_overflow2:
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    rts
; _________________________________________________
; _lighten_palette_col(u8 palette_ind, u8 lighten_value)
__lighten_palette_col:
    sta TEMP_SUB_VAL
    .repeat 4
        asl
    .endrepeat
    sta TEMP_SUB_VAL2

    lda (sp)
    inc sp
    sta TEMP_PAL_ADDR_OFF
    stz TEMP_PAL_ADDR_OFF+1
    asl TEMP_PAL_ADDR_OFF
    ror TEMP_PAL_ADDR_OFF+1


    ; set up VERA data port 0
        stz VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

        lda #1
        sta VERA_ctrl
        lda TEMP_PAL_ADDR_OFF
        clc
        adc #(<VRAM_palette)
        sta VERA_addr_low
        lda TEMP_PAL_ADDR_OFF+1
        adc #(>VRAM_palette)
        sta VERA_addr_high
        lda #(%00010001)
        sta VERA_addr_bank

    ; loop through vera colours
    ldx #2
        @palette_colour_loop:
            lda VERA_data0
            pha
            .repeat 4
                asl
            .endrepeat
            sta TEMP_COLOUR

            pla

            clc 
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow1
            lda #$FF
            @skip_sub_overflow1:
            and #(%11110000)

            pha

            lda TEMP_COLOUR
            clc
            adc TEMP_SUB_VAL2
            bcc @skip_sub_overflow2
            lda #$FF
            @skip_sub_overflow2:
            .repeat 4
                lsr
            .endrepeat
            sta TEMP_COLOUR

            pla
            ora TEMP_COLOUR

            sta VERA_data1

        dex
        bne @palette_colour_loop

    rts
; _________________________________________________
; _set_sprite_address(u16 spr_attr, u8 attr_num)
__set_sprite_address:
    stz VERA_ctrl

    clc
    asl
    sta VERA_ADDR
    lda #0
    rol 
    sta VERA_ADDR+1

    clc
    lda VERA_ADDR
    asl
    sta VERA_ADDR
    lda VERA_ADDR+1
    rol 
    sta VERA_ADDR+1

    clc
    lda VERA_ADDR
    asl
    sta VERA_ADDR
    lda VERA_ADDR+1
    rol 
    sta VERA_ADDR+1
    

    lda #<(VRAM_sprattr)
    clc
    adc VERA_ADDR
    sta VERA_addr_low
    
    lda VERA_ADDR+1
    adc #>(VRAM_sprattr)
    sta VERA_addr_high

    lda #%00010001
    sta VERA_addr_bank

    lda (sp)
    inc sp
    sta VERA_data0

    lda (sp)
    inc sp
    sta VERA_data0

    rts

; ----------------------------------------------------
; _clear_spr_attributes(u8 no_of_sprs, u8 spr_offset)
TEMP_SPR_OFFSET = ZP_PTR_1
TEMP_SPR_NO = ZP_PTR_2
__clear_spr_attributes:
    pha
    stz VERA_ctrl 

    sta TEMP_SPR_OFFSET
    stz TEMP_SPR_OFFSET+1
    .repeat 3
        asl TEMP_SPR_OFFSET
        rol TEMP_SPR_OFFSET+1
    .endrepeat

    lda TEMP_SPR_OFFSET
    clc
    adc #(<(VRAM_sprattr+6))
    sta VERA_addr_low
    lda TEMP_SPR_OFFSET+1
    adc #(>(VRAM_sprattr+6))
    sta VERA_addr_high
    lda #(%01000001)
    sta VERA_addr_bank
    
    lda (sp)
    sta TEMP_SPR_NO
    inc sp
    plx
    @spr_clear_loop:
        stz VERA_data0    
    
    inx
    cpx TEMP_SPR_NO
    bne @spr_clear_loop

    rts
; ___________________________________________________