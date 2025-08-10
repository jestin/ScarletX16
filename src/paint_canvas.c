#include "paint_canvas.h"
#include <stdio.h>
#include "utils.h"
#include "ui_utils.h"

u8* bmx_header = GOLD_RAM_ADDR;
u8* bmx_bit_depth = GOLD_RAM_ADDR+4;
u8* bmx_vera_bit_depth = GOLD_RAM_ADDR+5;
u16* bmx_width = GOLD_RAM_ADDR+6;
u16* bmx_height = GOLD_RAM_ADDR+8;
u8* bmx_no_pals = GOLD_RAM_ADDR+10;
u8* bmx_pal_start = GOLD_RAM_ADDR+11;
u16* bmx_data_start = GOLD_RAM_ADDR+12;

u8 x_axis = 0;
u8 y_axis = 0;
u8 scale = 0;

u8 get_axis_scale(u16 size){
    u8 axis = 0;
    size = size >> 4;
    while(size > 0){
        axis += 1;
        size = size >> 1;
    }
    return(axis);
}

void init_canvas_vera_sprites(){
    u16 sprite_addr = DISPLAY_VRAM_ADDR>>5;
    u8 sprite_attr_width_height = 0;
    _canvas_scale = 0;
    _canvas_pow_scale = 0;
    _canvas_paint_offset = 0;
    _display_has_columns = 0x00;
    _x_axis = get_axis_scale(*bmx_width);
    _y_axis = get_axis_scale(*bmx_height);

    // TODO: fix

    _canvas_pow_scale = _y_axis;
    if(_x_axis >= _canvas_pow_scale){ 
        _canvas_pow_scale = _x_axis;
        _canvas_paint_offset = (*bmx_width)>>1;
        _canvas_paint_width = (*bmx_width)>>1;
    }
    else{
        _canvas_paint_width = *bmx_width;
    }
    _canvas_scale = 4 - _canvas_pow_scale;
    _canvas_scale = 1 << _canvas_scale;

    if(_x_axis == _y_axis){ 
        _sprite_size = (64*64);
        sprite_attr_width_height = 0b1111;
        _display_row_pow = 6+(4-_canvas_pow_scale);
    }
    else if(_x_axis < _y_axis){ 
        u8 display_width = (_canvas_scale*(*bmx_width));
        _sprite_size = (64*display_width); 
        sprite_attr_width_height = 0b1100;
        _display_row_pow = (4-_canvas_pow_scale);

        if(display_width == 8) _display_row_pow += 3;
        if(display_width == 16) {
            sprite_attr_width_height = sprite_attr_width_height | 0b0001;
            _display_row_pow += 4; 
        }
        if(display_width == 32) {
            sprite_attr_width_height = sprite_attr_width_height | 0b0010;
            _display_row_pow += 5; 
        }
        if(display_width == 64) {
            sprite_attr_width_height = sprite_attr_width_height | 0b0011;
            _display_row_pow += 6; 
        }
    }
    else{ 
        u8 display_height = (_canvas_scale*(*bmx_height));
        _sprite_size = (64*display_height); 
        sprite_attr_width_height = 0b0011;
        _display_row_pow = (4-_canvas_pow_scale)+6;

        if(display_height == 16) sprite_attr_width_height = sprite_attr_width_height | 0b0100;
        if(display_height == 32) sprite_attr_width_height = sprite_attr_width_height | 0b1000;
        if(display_height == 64) sprite_attr_width_height = sprite_attr_width_height | 0b1100;
    }

    _sprite_vram_size = _sprite_size >> 5;

    _x_axis += 3;
    _y_axis += 3;

    _display_width = (*bmx_width) * _canvas_scale;
    _display_height = (*bmx_height) * _canvas_scale;

    _set_sprite_attribute(1, sprite_addr, 1, 96,40, 0b00001100, sprite_attr_width_height, 0);
    sprite_addr += _sprite_vram_size;
    if(_x_axis <= _y_axis){
        _set_sprite_attribute(2, sprite_addr, 1, 96,104, 0b00001100, sprite_attr_width_height, 0);
        sprite_addr += _sprite_vram_size;
        _display_has_columns = 0xFF;
    }
    if(_canvas_paint_offset > 0){
        _set_sprite_attribute(3, sprite_addr, 1, 160,40, 0b00001100, sprite_attr_width_height, 0);
        sprite_addr += _sprite_vram_size;
        if(_display_has_columns){
            _set_sprite_attribute(4, sprite_addr, 1, 160,104, 0b00001100, sprite_attr_width_height, 0);
            sprite_addr += _sprite_vram_size;
        }
    }
}