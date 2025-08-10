.include "x16.inc"
.include "zeropage.inc"

.export __initialize_bmx_data
.export __transfer_sprite_to_vram
.export __draw_canvas_to_screen
.export __render_palette_sprites
.export __draw_row_to_screen 
.export __transfer_pal_to_vera
.export __image_data_size
.export __draw_row_to_sprite
.export __get_pixel

.export __add_history_node_position
.export __get_history_byte
.export __get_history_redo_byte

.export __x_axis
.export __y_axis
.export __canvas_scale
.export __canvas_pow_scale
.export __canvas_paint_offset
.export __canvas_paint_width
.export __display_width
.export __display_height
.export __sprite_size
.export __sprite_vram_size
.export __display_row_pow
.export __display_has_columns

.export __primary_colour
.export __secondary_colour
.export __current_tool

.export __history_stack_addr
.export __history_stack_bank

_bmx_header = GOLD_RAM
_bmx_bit_depth = GOLD_RAM+4
_bmx_vera_bit_depth = GOLD_RAM+5
_bmx_width = GOLD_RAM+6
_bmx_height = GOLD_RAM+8
_bmx_no_pals = GOLD_RAM+10
_bmx_pal_start = GOLD_RAM+11
_bmx_data_start = GOLD_RAM+12

__x_axis: .byte $00
__y_axis: .byte $00
__canvas_scale: .byte $00
__canvas_pow_scale: .byte $00
__canvas_paint_offset: .byte $00
__canvas_paint_width: .byte $00
__display_width: .byte $00
__display_height: .byte $00
__sprite_size: .byte $00, $00
__sprite_vram_size: .byte $00, $00
__display_row_pow: .byte $00
__display_has_columns: .byte $00

SPRITE_VRAM_DATA_ADDR = $08000
DISPLAY_VRAM_ADDR = $0C000
__image_data_size: .byte $00, $00

__primary_colour: .byte $01
__secondary_colour: .byte $00
__current_tool: .byte $00

DATA_ADDR = ZP_PTR_1
__initialize_bmx_data:
    ; lda bmx_data_start
    ; sta DATA_ADDR
    ; lda bmx_data_start+1
    ; sta DATA_ADDR+1
    rts

PIX_ADDR = ZP_PTR_1
__get_pixel:
    stz PIX_ADDR+1
    sta PIX_ADDR
    ldy __x_axis

    @multiply_height:
        asl PIX_ADDR
        rol PIX_ADDR+1
    dey
    bne @multiply_height

    lda PIX_ADDR
    clc
    adc (sp)
    sta PIX_ADDR
    lda PIX_ADDR+1
    adc #0
    sta PIX_ADDR+1
    inc sp

    stz VERA_ctrl
    lda PIX_ADDR
    clc
    adc #(<SPRITE_VRAM_DATA_ADDR)
    sta VERA_addr_low
    lda PIX_ADDR+1
    adc #(>SPRITE_VRAM_DATA_ADDR)
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank


    lda VERA_data0
    rts

__draw_row_to_sprite:
    stz PIX_ADDR+1
    sta PIX_ADDR
    ldy __x_axis

    @multiply_height:
        asl PIX_ADDR
        rol PIX_ADDR+1
    dey
    bne @multiply_height

    lda PIX_ADDR
    clc
    adc (sp)
    sta PIX_ADDR
    lda PIX_ADDR+1
    adc #0
    sta PIX_ADDR+1
    inc sp

    stz VERA_ctrl
    lda PIX_ADDR
    clc
    adc #(<SPRITE_VRAM_DATA_ADDR)
    sta VERA_addr_low
    lda PIX_ADDR+1
    adc #(>SPRITE_VRAM_DATA_ADDR)
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    lda (sp)
    inc sp
    tax
    lda (sp)
    inc sp
    @row_loop:
        sta VERA_data0
    dex
    bne @row_loop

    rts

SPR_ADDR = ZP_PTR_1
__transfer_sprite_to_vram:
    lda #(<RAM_WIN)
    sta SPR_ADDR
    lda #(>RAM_WIN)
    sta SPR_ADDR+1

    stz VERA_ctrl
    lda (sp)
    inc sp
    sta VERA_addr_low
    lda (sp)
    inc sp
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    lda (sp)
    tax
    inc sp
    lda (sp)
    tay
    inc sp

    @transfer_loop_1:
        @transfer_loop_2:
        lda (SPR_ADDR)
        sta VERA_data0
        
        lda SPR_ADDR
        clc
        adc #1
        sta SPR_ADDR
        lda SPR_ADDR+1
        adc #0
        sta SPR_ADDR+1

        dex
        bne @transfer_loop_2

    ldx #0
    dey
    bne @transfer_loop_1


    rts

PAL_PAGE2_OFFSET = RAM_WIN + 256
PAL_NO = ZP_PTR_1
PAL_READ_ADDR = ZP_PTR_2
__transfer_pal_to_vera:
    ; set data port to the start of vera palette
    stz VERA_ctrl
    lda #(<VRAM_palette)
    sta VERA_addr_low
    lda #(>VRAM_palette)
    sta VERA_addr_high
    lda #(%00010001)
    sta VERA_addr_bank

    lda #(<RAM_WIN)
    sta PAL_READ_ADDR
    lda #(>RAM_WIN)
    sta PAL_READ_ADDR+1

    lda #1
    sta RAM_BANK_SEL
    
    ldx _bmx_no_pals
    ; transferring the first page of the palette to VRAM 
    @add_palette_loop:
        lda (PAL_READ_ADDR)
        inc PAL_READ_ADDR
        sta VERA_data0
        lda (PAL_READ_ADDR)
        inc PAL_READ_ADDR
        sta VERA_data0
    dex
    bne @add_palette_loop

    rts

PIX_COL = ZP_PTR_1
ROW_START = ZP_PTR_2
__clear_canvas_screen:
    stz VERA_ctrl
    lda #(<DISPLAY_VRAM_ADDR)
    sta VERA_addr_low
    lda #(>DISPLAY_VRAM_ADDR)
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    lda #00
    ldx __display_width
    @row_loop:
        ldy __display_height
        @pix_loop:
            sta VERA_data0
        dey
        bne @pix_loop
    dex
    bne @row_loop

    rts


__draw_canvas_to_screen:
    ; jsr __clear_canvas_screen

    lda #(<SPRITE_VRAM_DATA_ADDR)
    sta ROW_START
    lda #(>SPRITE_VRAM_DATA_ADDR)
    sta ROW_START+1

    stz VERA_ctrl
    lda #(<DISPLAY_VRAM_ADDR)
    sta VERA_addr_low
    lda #(>DISPLAY_VRAM_ADDR)
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    ldy _bmx_height
    @column_loop:
        phy
        ldy __canvas_scale
        @scale_loop:
            lda #1
            sta VERA_ctrl
            lda ROW_START
            sta VERA_addr_low
            lda ROW_START+1
            sta VERA_addr_high
            lda #(%00010000)
            sta VERA_addr_bank
            
            ldx __canvas_paint_width
            @row_loop:
                lda VERA_data1
                phx
                ldx __canvas_scale
                @row_scale_loop:
                    sta VERA_data0
                dex
                bne @row_scale_loop
                plx
            dex
            bne @row_loop

        dey
        bne @scale_loop

    lda ROW_START
    clc
    adc _bmx_width
    sta ROW_START
    lda ROW_START+1
    adc #0
    sta ROW_START+1

    ply
    dey
    bne @column_loop

    lda __canvas_paint_offset
    beq @end_draw_loop

    lda #(<SPRITE_VRAM_DATA_ADDR)
    clc
    adc __canvas_paint_offset
    sta ROW_START
    lda #(>SPRITE_VRAM_DATA_ADDR)
    adc #0
    sta ROW_START+1

    ldy _bmx_height
    @column_loop2:
        phy
        ldy __canvas_scale
        @scale_loop2:
            lda #1
            sta VERA_ctrl
            lda ROW_START
            sta VERA_addr_low
            lda ROW_START+1
            sta VERA_addr_high
            lda #(%00010000)
            sta VERA_addr_bank
            
            ldx __canvas_paint_width
            @row_loop2:
                lda VERA_data1
                phx
                ldx __canvas_scale
                @row_scale_loop2:
                    sta VERA_data0
                dex
                bne @row_scale_loop2
                plx
            dex
            bne @row_loop2

        dey
        bne @scale_loop2

    lda ROW_START
    clc
    adc _bmx_width
    sta ROW_START
    lda ROW_START+1
    adc #0
    sta ROW_START+1

    ply
    dey
    bne @column_loop2

    @end_draw_loop:
    rts
palette_row_no_arr: .byte 16, 8, 8, 4, 4, 2, 2, 2
palette_width_arr: .byte 4, 8, 8, 16, 16, 32, 32, 32
palette_height_arr: .byte 8, 8, 16, 16, 32, 32, 64, 64
NO_OF_COLS = ZP_PTR_4
ROW_START_ADDR = ZP_PTR_5
COL_PLACE_ADDR = ZP_PTR_6
PALETTE_NO = ZP_PTR_7
ROW_COUNT = ZP_PTR_8
PAL_SPR_ADDR = $4000
__clear_palette_sprites:
    stz VERA_ctrl
    lda #(<PAL_SPR_ADDR)
    sta VERA_addr_low
    lda #(>PAL_SPR_ADDR)
    sta VERA_addr_high
    lda #(%00010001)
    sta VERA_addr_bank

    lda #00
    ldx #64

    @row_loop:
    ldy #128
        @column_loop:
            sta VERA_data0
        dey
        bne @column_loop
    dex
    bne @row_loop

    rts
__render_palette_sprites:
    ; get palette sizes
        ldx #0
        lda _bmx_no_pals
        dec
        sta NO_OF_COLS

        @get_pal_size_loop:
        asl NO_OF_COLS
        bcs @end_pal_size_loop

        inx
        jmp @get_pal_size_loop
        @end_pal_size_loop:

        lda palette_row_no_arr, x
        sta __pal_spr_rows
        lda palette_width_arr, x
        sta __pal_spr_width
        lda palette_height_arr, x
        sta __pal_spr_height

    ; render palette colours

    jsr __clear_palette_sprites

    stz PALETTE_NO
    lda #(<PAL_SPR_ADDR)
    sta COL_PLACE_ADDR
    sta ROW_START_ADDR
    lda #(>PAL_SPR_ADDR)
    sta COL_PLACE_ADDR+1
    sta ROW_START_ADDR+1

    stz ROW_COUNT

    @colour_loop:
        ldx __pal_spr_width
        @row_loop:
            stz VERA_ctrl
            lda COL_PLACE_ADDR
            sta VERA_addr_low
            lda COL_PLACE_ADDR+1
            sta VERA_addr_high
            lda #(%01110001)
            sta VERA_addr_bank
            
            inc COL_PLACE_ADDR

            ldy __pal_spr_height
            lda PALETTE_NO
            @column_loop:
                sta VERA_data0
            dey
            bne @column_loop
        dex
        bne @row_loop

    inc ROW_COUNT
    lda ROW_COUNT
    cmp __pal_spr_rows
    bne @skip_change_row

    stz COL_PLACE_ADDR+1
    lda __pal_spr_height
    sta COL_PLACE_ADDR
    .repeat 6
        asl COL_PLACE_ADDR
        rol COL_PLACE_ADDR+1
    .endrepeat
    lda COL_PLACE_ADDR
    clc
    adc ROW_START_ADDR
    sta ROW_START_ADDR
    sta COL_PLACE_ADDR
    lda COL_PLACE_ADDR+1
    adc ROW_START_ADDR+1
    sta ROW_START_ADDR+1
    sta COL_PLACE_ADDR+1

    stz ROW_COUNT

    @skip_change_row:

    inc PALETTE_NO
    lda PALETTE_NO
    cmp _bmx_no_pals
    bne @colour_loop

    rts
ROW_DISPLAY_ADDR = ZP_PTR_1
ROW_SPRITE_ADDR = ZP_PTR_2
__draw_row_to_screen:
    stz ROW_SPRITE_ADDR+1
    sta ROW_SPRITE_ADDR
    
    stz ROW_DISPLAY_ADDR+1
    sta ROW_DISPLAY_ADDR

    ldx __display_row_pow
    @row_asl:
        asl ROW_DISPLAY_ADDR
        rol ROW_DISPLAY_ADDR+1
    dex
    bne @row_asl

    stz VERA_ctrl
    lda #(<DISPLAY_VRAM_ADDR)
    clc
    adc ROW_DISPLAY_ADDR
    sta ROW_DISPLAY_ADDR
    sta VERA_addr_low
    lda ROW_DISPLAY_ADDR+1
    adc #(>DISPLAY_VRAM_ADDR)
    sta ROW_DISPLAY_ADDR+1
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    ldy __x_axis
    @multiply_height:
        asl ROW_SPRITE_ADDR
        rol ROW_SPRITE_ADDR+1
    dey
    bne @multiply_height

    lda #(<SPRITE_VRAM_DATA_ADDR)
    clc
    adc ROW_SPRITE_ADDR
    sta ROW_SPRITE_ADDR
    lda #(>SPRITE_VRAM_DATA_ADDR)
    adc ROW_SPRITE_ADDR+1
    sta ROW_SPRITE_ADDR+1

    ldx __canvas_scale
    @column_loop:
        lda #1
        sta VERA_ctrl
        lda ROW_SPRITE_ADDR
        sta VERA_addr_low
        lda ROW_SPRITE_ADDR+1
        sta VERA_addr_high
        lda #(%00010000)
        sta VERA_addr_bank

        phx
        ldx __canvas_paint_width
        @row_loop:
            lda VERA_data1
            ldy __canvas_scale
            @row_scale_loop:
                sta VERA_data0
            dey
            bne @row_scale_loop
        dex
        bne @row_loop

    plx
    dex
    bne @column_loop


    lda __canvas_paint_offset
    beq @end_draw_loop


    lda ROW_SPRITE_ADDR
    clc
    adc __canvas_paint_width
    sta ROW_SPRITE_ADDR
    lda ROW_SPRITE_ADDR+1
    adc #0
    sta ROW_SPRITE_ADDR+1

    stz VERA_ctrl
    lda ROW_DISPLAY_ADDR
    sta VERA_addr_low
    lda __sprite_size+1
    
    ldx __display_has_columns
    cpx #0
    beq @skip_asl

    asl
    @skip_asl:
    clc
    adc ROW_DISPLAY_ADDR+1
    sta VERA_addr_high
    lda #(%00010000)
    sta VERA_addr_bank

    ldx __canvas_scale
    @column_loop2:
        lda #1
        sta VERA_ctrl
        lda ROW_SPRITE_ADDR
        sta VERA_addr_low
        lda ROW_SPRITE_ADDR+1
        sta VERA_addr_high
        lda #(%00010000)
        sta VERA_addr_bank

        phx
        ldx __canvas_paint_width
        @row_loop2:
            lda VERA_data1
            ldy __canvas_scale
            @row_scale_loop2:
                sta VERA_data0
            dey
            bne @row_scale_loop2
        dex
        bne @row_loop2

    plx
    dex
    bne @column_loop2

    @end_draw_loop:

    rts

.macro inc_stack
        lda __history_stack_addr
        clc
        adc #1
        sta __history_stack_addr
        lda __history_stack_addr+1
        adc #0
        sta __history_stack_addr+1
.endmacro

__add_history_node_position:
    pha
    lda __history_stack_bank
    sta RAM_BANK_SEL
    pla

    pha 
    jsr __get_pixel
    sta (__history_stack_addr)
    inc_stack

    pla 
    sta (__history_stack_addr) 
    inc_stack

    dec sp
    lda (sp)
    sta (__history_stack_addr) 
    inc_stack

    inc sp
    rts

__get_history_byte:
    lda __history_stack_bank
    sta RAM_BANK_SEL

    lda __history_stack_addr
    sec
    sbc #1
    sta __history_stack_addr
    lda __history_stack_addr+1
    sbc #0
    sta __history_stack_addr+1

    lda (__history_stack_addr)
    rts

__get_history_redo_byte:
    lda __history_stack_bank
    sta RAM_BANK_SEL

    lda (__history_stack_addr)
    pha

    lda __history_stack_addr
    clc
    adc #1
    sta __history_stack_addr
    lda __history_stack_addr+1
    adc #0
    sta __history_stack_addr+1

    pla 
    rts