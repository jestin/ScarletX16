.include "x16.inc"
.include "zeropage.inc"

.export __focus_id
.export __mouse_data

.export __ui_type
.export __ui_global_pos_x
.export __ui_global_pos_y
.export __ui_position_x 
.export __ui_position_y 
.export __ui_size_x
.export __ui_size_y
.export __ui_palette
.export __ui_var_1
.export __ui_var_2
.export __ui_var_3
.export __ui_var_4
.export __ui_rend_func_low
.export __ui_rend_func_high
.export __ui_on_mouse
.export __ui_on_key_low
.export __ui_on_key_high

.export __ui_parent
.export __ui_no_of_children
.export __ui_first_child
.export __ui_last_child
.export __ui_next_sib
.export __ui_prev_sib

.export __initialize_mouse
.export __get_mouse_input

.export __clear_ui_layer
.export __draw_ui
.export __draw_ui_element
.export __update_ui_element_position

.export __empty_draw_func
.export __draw_ui_text
.export __draw_ui_box
.export __draw_ui_hline
.export __draw_ui_vline
.export __draw_ui_icon

.export __test_on_mouse_func
.export __press_toggle_button_mouse_func

__MAX_UI_ELEMENTS = 100

__focus_id: .byte $00
__mouse_data = ZP_MOUSE

__ui_type: .res __MAX_UI_ELEMENTS, $00
__ui_global_pos_x: .res __MAX_UI_ELEMENTS, $00
__ui_global_pos_y: .res __MAX_UI_ELEMENTS, $00
__ui_position_x: .res __MAX_UI_ELEMENTS, $00 
__ui_position_y: .res __MAX_UI_ELEMENTS, $00 
__ui_size_x: .res __MAX_UI_ELEMENTS, $00
__ui_size_y: .res __MAX_UI_ELEMENTS, $00
__ui_palette: .res __MAX_UI_ELEMENTS, $F0
__ui_var_1: .res __MAX_UI_ELEMENTS, $00
__ui_var_2: .res __MAX_UI_ELEMENTS, $00
__ui_var_3: .res __MAX_UI_ELEMENTS, $00
__ui_var_4: .res __MAX_UI_ELEMENTS, $00
__ui_rend_func_low: .res __MAX_UI_ELEMENTS, $00
__ui_rend_func_high: .res __MAX_UI_ELEMENTS, $00
__ui_on_mouse: .res __MAX_UI_ELEMENTS*2, $00
__ui_on_key_low: .res __MAX_UI_ELEMENTS, $00
__ui_on_key_high: .res __MAX_UI_ELEMENTS, $00

__ui_parent: .res __MAX_UI_ELEMENTS, $00
__ui_no_of_children: .res __MAX_UI_ELEMENTS, $00
__ui_first_child: .res __MAX_UI_ELEMENTS, $00
__ui_last_child: .res __MAX_UI_ELEMENTS, $00
__ui_next_sib: .res __MAX_UI_ELEMENTS, $00
__ui_prev_sib: .res __MAX_UI_ELEMENTS, $00

__initialize_mouse:
    lda #1
    ldx #(320/8)
    ldy #(240/8)
    sec
    jsr MOUSE_CONFIG
    rts

__get_mouse_input:
    ldx #ZP_MOUSE
    jsr MOUSE_GET
    sta ZP_MOUSE+4
    rts

LAYER_WIDTH = 64
LAYER_HEIGHT = 64
RENDER_FUNC_ADDR = ZP_PTR_7
__clear_ui_layer:
    stz VERA_ctrl
    sta VERA_addr_low
    stx VERA_addr_high
    lda #(%00010001)
    sta VERA_addr_bank

    lda #$F0
    ldx #LAYER_WIDTH
    @row_loop:
        ldy #LAYER_HEIGHT
        @column_loop:
        sta VERA_data0
        stz VERA_data0

        dey
        bne @column_loop

    dex
    bne @row_loop

    rts




__indirect_jump:
    jmp (RENDER_FUNC_ADDR)

__draw_ui:
    ldx #0
    @ui_element_loop:
    lda __ui_type,x
    beq @continue_element_loop

    lda __ui_rend_func_low,x
    sta RENDER_FUNC_ADDR
    lda __ui_rend_func_high,x
    sta RENDER_FUNC_ADDR+1
    txa
    phx
    jsr __indirect_jump
    plx

    @continue_element_loop:
    inx
    cpx #__MAX_UI_ELEMENTS
    bne @ui_element_loop

    rts

__empty_draw_func:
    rts

.macro set_ui_vera_data_port
    stz VERA_ctrl
    lda BOX_POS_X
    asl
    sta VERA_addr_low
    lda BOX_POS_Y
    sta VERA_addr_high
    lda #(%00010001)
    sta VERA_addr_bank 
.endmacro

.macro init_draw_ui
    tax

    lda __ui_palette, x
    sta PAL

    lda __ui_global_pos_x, x
    sta BOX_POS_X
    lda __ui_global_pos_y, x
    sta BOX_POS_Y

    set_ui_vera_data_port
.endmacro

.macro execute_draw_func
    lda __ui_rend_func_low,x
    sta RENDER_FUNC_ADDR
    lda __ui_rend_func_high,x
    sta RENDER_FUNC_ADDR+1
    phx
    txa
    jsr __indirect_jump
    plx
.endmacro

X_POS_STACK = GOLD_RAM+32
Y_POS_STACK = GOLD_RAM+$200+32
__update_ui_element_position:
    tay

    lda __ui_type,y
    beq __end_position_loop
    
    lda __ui_parent,x
    tax
    lda __ui_global_pos_x,x
    sta X_POS_STACK
    lda __ui_global_pos_y,x
    sta Y_POS_STACK

    tya
    tax
    ldy #0

    __set_global_position:
        lda __ui_type,x
        beq __end_position_loop

        lda X_POS_STACK,y
        clc
        adc __ui_position_x,x
        sta __ui_global_pos_x,x
        
        lda Y_POS_STACK,y
        clc
        adc __ui_position_y,x
        sta __ui_global_pos_y,x

        iny
        lda __ui_global_pos_x,x
        sta X_POS_STACK,y
        lda __ui_global_pos_y,x
        sta Y_POS_STACK,y

        lda __ui_first_child,x
        beq @__end_set_pos_loop

        @set_child_pos_loop:
            pha
            tax
            jsr __set_global_position
            plx
            lda __ui_next_sib,x
            beq @__end_set_pos_loop
            jmp @set_child_pos_loop

        @__end_set_pos_loop:
            dey
            rts

    __end_position_loop:
        rts

__draw_ui_element:
    tax ;transfer the ui element id to x 
    
    lda __ui_type,x
    beq @end_render_loop
    
    ; render parent element
        lda __ui_rend_func_low,x
        sta RENDER_FUNC_ADDR
        lda __ui_rend_func_high,x
        sta RENDER_FUNC_ADDR+1
        phx
        txa
        jsr __indirect_jump
        plx

    lda __ui_first_child,x
    beq @end_render_loop

    @child_render_loop:
        pha
        jsr __draw_ui_element
        plx
        lda __ui_next_sib,x
        beq @end_render_loop

    jmp @child_render_loop
    
    @end_render_loop:
    rts

CHAR_PTR = ZP_PTR_4
CURR_CHAR = ZP_PTR_5
VERA_ADDR_OFF = ZP_PTR_6  
__draw_ui_text:
    ldy #0
    init_draw_ui

    ; get a pointer to the text from ui variables
    lda __ui_var_1, x
    sta CHAR_PTR
    lda __ui_var_2, x
    sta CHAR_PTR+1

    @text_render_loop:
    ; getting character
    lda (CHAR_PTR),y
    beq @end_text_render_loop
    sec
    sbc #32
    sta CURR_CHAR

    ; setting character onto layer
    lda CURR_CHAR
    sta VERA_data0
    lda PAL
    sta VERA_data0

    iny
    jmp @text_render_loop
    @end_text_render_loop:

    rts

BOX_POS_X = ZP_PTR_1
BOX_POS_Y = ZP_PTR_1+1
BOX_SIZE_X = ZP_PTR_2
BOX_SIZE_Y = ZP_PTR_2+1
PAL = ZP_PTR_3
TOP_LEFT_CORNER = 96
TOP_EDGE = 97
TOP_RIGHT_CORNER = 98
LEFT_EDGE = 99
RIGHT_EDGE = 100
BOT_LEFT_CORNER = 101
BOT_EDGE = 102
BOT_RIGHT_CORNER = 103
__draw_ui_box:
    tax
    ; save ui position and size data
    lda __ui_palette, x
    sta PAL

    lda __ui_global_pos_x, x
    sta BOX_POS_X
    lda __ui_global_pos_y, x
    sta BOX_POS_Y 
    lda __ui_size_y, x
    dec
    dec
    tay 
    lda __ui_size_x, x
    dec
    dec 
    sta BOX_SIZE_X

    stz VERA_ctrl
    lda BOX_POS_X
    asl
    sta VERA_addr_low
    lda BOX_POS_Y
    sta VERA_addr_high
    inc
    sta BOX_POS_Y
    lda #(%00010001)
    sta VERA_addr_bank 

    lda #TOP_LEFT_CORNER
    sta VERA_data0
    lda PAL
    sta VERA_data0

    ldx BOX_SIZE_X
    beq @skip_top_loop
    @top_loop:
        lda #TOP_EDGE
        sta VERA_data0
        lda PAL
        sta VERA_data0
    dex
    bne @top_loop
    @skip_top_loop:

    lda #TOP_RIGHT_CORNER
    sta VERA_data0
    lda PAL
    sta VERA_data0
    
    tya
    beq @skip_column_loop
    @box_column_loop:
        ; set up the data port position based on the text position
        stz VERA_ctrl
        lda BOX_POS_X
        asl
        sta VERA_addr_low
        lda BOX_POS_Y
        sta VERA_addr_high
        inc 
        sta BOX_POS_Y
        lda #(%00010001)
        sta VERA_addr_bank 

        lda #LEFT_EDGE
        sta VERA_data0
        lda PAL
        sta VERA_data0

        ldx BOX_SIZE_X
        beq @skip_row_loop
        lda PAL
        @box_row_loop:
            stz VERA_data0
            sta VERA_data0
        dex
        bne @box_row_loop
        @skip_row_loop:

        lda #RIGHT_EDGE
        sta VERA_data0
        lda PAL
        sta VERA_data0

    dey
    bne @box_column_loop
    @skip_column_loop:


    stz VERA_ctrl
    lda BOX_POS_X
    asl
    sta VERA_addr_low
    lda BOX_POS_Y
    sta VERA_addr_high
    inc
    sta BOX_POS_Y
    lda #(%00010001)
    sta VERA_addr_bank 

    lda #BOT_LEFT_CORNER
    sta VERA_data0
    lda PAL
    sta VERA_data0

    ldx BOX_SIZE_X
    beq @skip_bottom_loop
    @bot_loop:
        lda #BOT_EDGE
        sta VERA_data0
        lda PAL
        sta VERA_data0
    dex
    bne @bot_loop
    @skip_bottom_loop:

    lda #BOT_RIGHT_CORNER
    sta VERA_data0
    lda PAL
    sta VERA_data0

    rts

ICON_ADDR = ZP_PTR_4

__draw_ui_icon:
    init_draw_ui

    lda __ui_var_1, x
    sta ICON_ADDR

    lda ICON_ADDR
    sta VERA_data0
    lda PAL
    sta VERA_data0
    inc ICON_ADDR

    lda ICON_ADDR
    sta VERA_data0
    lda PAL
    sta VERA_data0
    inc ICON_ADDR

    inc BOX_POS_Y
    set_ui_vera_data_port

    lda ICON_ADDR
    sta VERA_data0
    lda PAL
    sta VERA_data0
    inc ICON_ADDR

    lda ICON_ADDR
    sta VERA_data0
    lda PAL
    sta VERA_data0

    rts

__draw_ui_hline:
    tax
    lda __ui_size_x, x
    beq @end_hline
    tay

    stz VERA_ctrl
    lda __ui_global_pos_x, x
    asl
    sta VERA_addr_low
    lda __ui_global_pos_y, x
    sta VERA_addr_high
    lda #(%00010001)
    sta VERA_addr_bank

    lda #105
    @hline_loop:
        sta VERA_data0
        stz VERA_data0
    dey
    bne @hline_loop

    @end_hline:
    rts

__draw_ui_vline:
    tax
    lda __ui_size_y, x
    beq @end_vline
    tay

    stz VERA_ctrl
    lda __ui_global_pos_x, x
    asl
    sta VERA_addr_low
    lda __ui_global_pos_y, x
    sta VERA_addr_high
    lda #(%10010001)
    sta VERA_addr_bank

    lda #106
    @first_vline_loop:
        sta VERA_data0
    dey
    bne @first_vline_loop
    
    stz VERA_ctrl
    lda __ui_global_pos_x, x
    asl
    inc
    sta VERA_addr_low
    lda __ui_global_pos_y, x
    sta VERA_addr_high
    lda #(1 + (9<<4))
    sta VERA_addr_bank

    lda __ui_size_x, x
    tay
    @second_vline_loop:
        stz VERA_data0
    dey
    bne @second_vline_loop

    @end_vline:
    rts

__test_on_mouse_func:
    brk
    rts

__update_toggle_button_container:
    rts

VAR_PTR = ZP_PTR_1
__press_toggle_button_mouse_func:
    tax

    lda __ui_var_2,x
    sta VAR_PTR
    lda __ui_var_3,x
    sta VAR_PTR+1

    lda __ui_var_4,x
    sta (VAR_PTR)

    lda __ui_parent,x
    phx
    tax
    lda __ui_first_child,x
    @toggle_off_button_loop:
        tax
        lda #$F0
        sta __ui_palette,x
        lda __ui_next_sib,x
        bne @toggle_off_button_loop
    plx

    lda #$E0
    sta __ui_palette,x
    
    lda __ui_parent,x
    jsr __draw_ui_element

    rts