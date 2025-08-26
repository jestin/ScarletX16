#include <stdio.h>

#include "paint_canvas.h"
#include "paint_ui.h"
#include "ui_utils.h"
#include "utils.h"

#include "tool_ui.h"

#define LAYER_SIZE 0x2000

u32 tileset0_addr = 0x00000;
u32 tileset1_addr = 0x00000;
u32 tilemap0_addr = 0x10000;
u32 tilemap1_addr = 0x10000+LAYER_SIZE;

void set_layer_config(){
    _set_layer0_enable(1);
    _set_layer1_enable(0);
    _set_sprites_enable(1);

    VERA_dc_hscale = 64;
    VERA_dc_vscale = 64;

    L0_HSCROLL = 0;
    L0_VSCROLL = 0;
    L0_CONFIG = 0b00100010;
    L0_MAPBASE = (tilemap0_addr >> 9);
    L0_TILEBASE = 0b00000000 | ((tileset0_addr>>9)&0b11111100);

    // L1_HSCROLL = 0;
    // L1_VSCROLL = 0;
    // L1_CONFIG = 0b00000111;
    // L1_TILEBASE = 0b00000001 | ((tilemap1_addr>>9)&0b11111100);
}

u8 palette_container_id;
u8 tool_container_id;
u8 header_container_id;
u8 context_container_id;

char pal_text[] = "-palette"; 
initialize_palette_ui(){
    u8 pal_text_ui_id = create_ui_element(palette_container_id, UI_TEXT, 1, 1, 0, 1, _draw_ui_text, NULL);
    init_text_element(pal_text_ui_id, pal_text);
    
}

u8 original_tool = 0;
u8 tool_timer = 0;

void change_tool(u8 new_tool){
    u8 i;
    u8 x;
    _current_tool = new_tool;

    x = _ui_first_child[tool_container_id];
    for(i=0; i<9; i++){
        if(i == _current_tool+1) _ui_palette[x] = 0xE0;
        else _ui_palette[x] = 0xF0;

        x = _ui_next_sib[x];
    }

    // _ui_palette[x] = 0xE0;
    _draw_ui_element(tool_container_id);
}

char tool_text[] = "-tools";
initialize_tool_ui(){
    u8 i;
    u8 x=1;
    u8 y=2;
    u8 icon;
    u8 gfx_addr_offset = 0;
    u8 tool_text_ui_id = create_ui_element(tool_container_id, UI_TEXT, 1, 1, 0, 1, _draw_ui_text, NULL);
    init_text_element(tool_text_ui_id, tool_text);

    for(i=0; i<8; i++){
        icon = create_ui_element(tool_container_id, UI_BUTTON, x, y, 2, 2, _draw_ui_icon, _press_toggle_button_mouse_func);
        init_icon_element(icon, 144+gfx_addr_offset, &_current_tool, i);
        x += 2;

        if(i == 0) _ui_palette[icon] = 0xE0;

        gfx_addr_offset += 4;

        if(i == 3){
            x = 1;
            y += 2;
        }
    }
}

void initialize_paint_ui(){
    _ui_type[0] = UI_BOX;
    _ui_size_x[0] = 80;
    _ui_size_y[0] = 60;
    _ui_rend_func_low[0] = &_empty_draw_func;
    _ui_rend_func_high[0] = (int)(&_empty_draw_func)>>8;

    _load_file_into_vram("d0font.spr", 10, 0, 0x0000);
    _load_file_into_vram("d0mouse.spr", 12, 1, 0x3000);
    _load_palette_from_file("font.pal", 9, 14);

    header_container_id =   create_ui_element(0, UI_BOX, 0, 0, 40, 3, _draw_ui_box, NULL);
    // tool_container_id = create_ui_element(0, UI_BOX, 0, 4, 11, 4, _draw_ui_box, NULL);
    tool_container_id =     create_ui_element(0, UI_BOX, 30, 3, 10, 7, _draw_ui_box, NULL);
    palette_container_id =  create_ui_element(0, UI_BOX, 30, 10, 10, 20, _draw_ui_box, NULL);
    // context_container_id = create_ui_element(0, UI_BOX, 11, 22, 29, 8, _draw_ui_box, NULL);

    initialize_palette_ui();
    #define palette_spr_adrr_1 (0x14000>>5)
    #define palette_spr_adrr_2 (0x15000>>5)
    _set_sprite_attribute(7, palette_spr_adrr_1, 1, 248,96, 0b00001100, 0b1111, 0);
    _set_sprite_attribute(8, palette_spr_adrr_2, 1, 248,160, 0b00001100, 0b1111, 0);

    initialize_tool_ui();

    _update_ui_element_position(0);
    _clear_ui_layer(tilemap0_addr);
}
