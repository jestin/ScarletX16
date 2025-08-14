#include "draw_tools_utils.h"
#include "../paint_canvas.h"
#include "../history_stack.h"
#include <stdio.h>
#include "../utils.h"
#include "../ui_utils.h"

#include "brush_tool.h"

void draw_pixel_line_h(u8 x0, u8 y0, u8 x1, u8 y1, u8 col, u8 brush_size, u8 brush_type){
    u8 dx;
    u8 dy;
    i16 D;
    u8 neg_y = 0;
    u8 y;
    u8 x;

    if(x0 > x1){
        u8 temp = x0;
        x0 = x1;
        x1 = temp;

        temp = y0;
        y0 = y1;
        y1 = temp;
    }

    dx = x1 - x0;
    dy = y1 - y0;

    if(y0 > y1){
        neg_y = 1;
        dy = y0 - y1;
    }

    D = (dy*2) - dx;
    x = x0;
    y = y0;

    for(x=x0; x<=x1; x++){
        draw_brush_to_sprite(x, y, col, brush_size, brush_type);

        if(D > 0){
            // _draw_row_to_screen(y);

            if(neg_y) y -= 1;
            else y += 1;
            
            D -= dx*2;
        }
        D += dy*2;
    }
    // _draw_row_to_screen(y);
}

void draw_pixel_line_v(u8 x0, u8 y0, u8 x1, u8 y1, u8 col, u8 brush_size, u8 brush_type){
    u8 dx;
    u8 dy;
    i16 D;
    u8 neg_y = 0;
    u8 y;
    u8 x;

    if(y0 > y1){
        u8 temp = x0;
        x0 = x1;
        x1 = temp;

        temp = y0;
        y0 = y1;
        y1 = temp;
    }

    dx = x1 - x0;
    dy = y1 - y0;

    if(x0 > x1){
        neg_y = 1;
        dx = x0 - x1;
    }

    D = (dx*2) - dy;
    x = x0;
    y = y0;

    for(y=y0; y<=y1; y++){
        draw_brush_to_sprite(x, y, col, brush_size, brush_type);
        // add_history_node_position(x,y,col);
        // _draw_row_to_sprite(col, 1, x, y);
        // _draw_row_to_screen(y);

        if(D > 0){
            if(neg_y) x -= 1;
            else x += 1;
            
            D -= dy*2;
        }
        D += dx*2;
    }
}

void draw_pixel_line(u8 x0, u8 y0, u8 x1, u8 y1, u8 col, u8 brush_size, u8 brush_type){
    u8 x_dis;
    u8 y_dis;

    if(x0 > x1) x_dis = x0 - x1;
    else x_dis = x1 - x0;

    if(y0 > y1) y_dis = y0 - y1;
    else y_dis = y1 - y0;

    if(x_dis > y_dis) draw_pixel_line_h(x0, y0, x1, y1, col, brush_size, brush_type);
    else draw_pixel_line_v(x0, y0, x1, y1, col, brush_size, brush_type);
}

u32 mouse_addrs[] = {0x13200, 0x13200, 0x13200, 0x13200, 0x13300, 0x13200, 0x13200, 0x13200};

u8 was_drawing_last_frame = 0;
u8 old_pix_x = 0;
u8 old_pix_y = 0;
u8 old_button = 0;

u8 brush_type;
u8 brush_size = 4;
void draw_pixel_to_sprite(u8 pix_x, u8 pix_y, u8 mouse_buttons){
    u8 col;

    if(mouse_buttons & M_LEFT_BUT) col = _primary_colour;
    else col = _secondary_colour;

    draw_brush_to_sprite(pix_x, pix_y, col, brush_size, brush_type);

    if(was_drawing_last_frame) draw_pixel_line(old_pix_x, old_pix_y, pix_x, pix_y, col, brush_size, brush_type);
    else draw_brush_to_sprite(pix_x, pix_y, col, brush_size, brush_type);

    _draw_canvas_to_screen();

    was_drawing_last_frame = 1;
}

// void draw_brush_to_sprite()
i8 fill_offset_arr_x[4] = {1,-1,-1, 1};
i8 fill_offset_arr_y[4] = {0, 1,-1,-1};
i8 flood_fill_queue_x[256] = {0};
i8 flood_fill_queue_y[256] = {0};
u8 queue_length = 0;
u8 selection_colour;
u8 fill_colour;
u8 abort_flood_fill = 0;
void flood_fill_pixel(){
    u8 i;
    i8 new_x = flood_fill_queue_x[queue_length];
    i8 new_y = flood_fill_queue_y[queue_length];
    u8 new_col;
    add_history_node_position(new_x, new_y, fill_colour);
    _draw_row_to_sprite(fill_colour, 1, new_x, new_y);

    for(i=0; i<4; i++){ 
        new_x += fill_offset_arr_x[i];
        new_y += fill_offset_arr_y[i];
        if(new_x>=0 && new_x<(*bmx_width) && new_y>=0 && new_y<(*bmx_height)){
            new_col = _get_pixel(new_x, new_y);
            if(new_col == selection_colour){
                flood_fill_queue_x[queue_length] = new_x;
                flood_fill_queue_y[queue_length] = new_y;
                queue_length += 1;

                if(queue_length == 255) abort_flood_fill = 1;
            }
        }
    }
}
void flood_fill(u8 pix_x, u8 pix_y, u8 mouse_buttons){
    selection_colour = _get_pixel(pix_x, pix_y);
    queue_length = 0;

    if(mouse_buttons & M_LEFT_BUT) fill_colour = _primary_colour;
    else fill_colour = _secondary_colour;
    
    if(fill_colour == selection_colour) return;

    flood_fill_queue_x[queue_length] = pix_x;
    flood_fill_queue_y[queue_length] = pix_y;
    queue_length += 1;

    while(queue_length > 0){
        queue_length -= 1;
        flood_fill_pixel();

        if(abort_flood_fill){
            abort_flood_fill = 0;
            break;
        }
    }
    add_new_history_node();
    _draw_canvas_to_screen();
}

u8 line_brush_size = 2;
u8 line_brush_type;
u8 point_selected = 0;
u8 previous_point_x;
u8 previous_point_y;
void line_draw_tool(u8 pix_x, u8 pix_y, u8 mouse_buttons){
    u8 col;
    if(mouse_buttons & M_LEFT_BUT) col = _primary_colour;
    else col = _secondary_colour;

    if(point_selected == 0){
        point_selected = 1;
        previous_point_x = pix_x;
        previous_point_y = pix_y;
    }
    else{
        point_selected = 0;
        draw_pixel_line(previous_point_x, previous_point_y, pix_x, pix_y, col, line_brush_size, line_brush_type);
        add_new_history_node();
        _draw_canvas_to_screen();
    }
}

void set_colour(u8* addr, u8 new_col){
    *addr = new_col;
    set_pal_icon_sprites();
}

void eye_dropper_tool(u8 pix_x, u8 pix_y, u8 mouse_buttons){
    u8 col = _get_pixel(pix_x, pix_y);
    if(mouse_buttons & M_LEFT_BUT) set_colour(&_primary_colour, col);
    else set_colour(&_secondary_colour, col);
}

void handle_key_command(){
    if(_current_tool == LINE_TOOL) {
        if(keycode == 27) point_selected = 0;
    }
}

u16 icon_x = 0;
u16 icon_y = 0;
void get_sprite_position(u8 colour){
    icon_x = (colour%PAL_SPR_ROWS)*PAL_SPR_WIDTH;
    icon_y = (colour/PAL_SPR_ROWS)*PAL_SPR_HEIGHT;

    icon_x += 248;
    icon_y += 96;
}

void set_pal_icon_sprites(){
    #define icon_addr_1 (0xB20>>5)
    #define icon_addr_2 (0xB40>>5)
    get_sprite_position(_primary_colour);
    _set_sprite_attribute(5, icon_addr_1, 0, icon_x, icon_y, 0b00001100, 0b0000, 15);

    get_sprite_position(_secondary_colour);
    icon_x += PAL_SPR_WIDTH-8;
    icon_y += PAL_SPR_HEIGHT-8;
    _set_sprite_attribute(6, icon_addr_2, 0, icon_x, icon_y, 0b00001100, 0b0000, 15);
}

void palette_selection_handler(u16 mouse_x, u16 mouse_y, u8 mouse_buttons){
    u8 pal_x = (mouse_x-248)/PAL_SPR_WIDTH;
    u8 pal_y = (mouse_y-96)/PAL_SPR_HEIGHT;
    u8 col = pal_x + pal_y*PAL_SPR_ROWS;

    if(col < (*bmx_no_pals)){
        if(mouse_buttons & M_LEFT_BUT) set_colour(&_primary_colour, col);
        else set_colour(&_secondary_colour, col);
    }
}

void tool_handler(){
    u16 mouse_x = _mouse_data[MOUSE_X];
    u16 mouse_y = _mouse_data[MOUSE_Y];
    u8 pix_x;
    u8 pix_y;
    u8 mouse_buttons = _mouse_data[MOUSE_BUTTONS];

    handle_key_command();

    if(mouse_x >= 96 && mouse_x < 224 && mouse_y >= 40 && mouse_y < 168){
        _set_sprite_address((mouse_addrs[_current_tool]>>5)+0x8000, 0);
    }
    else _set_sprite_address((0x13000>>5)+0x8000, 0);

    if(mouse_buttons & M_LEFT_BUT || mouse_buttons & M_RIGHT_BUT){
        if(mouse_x >= 96 && mouse_x < 224 && mouse_y >= 40 && mouse_y < 168){
            mouse_x -= 96;
            mouse_y -= 40;

            pix_x = mouse_x >> (4-_canvas_pow_scale);
            pix_y = ((mouse_y) >> (4-_canvas_pow_scale));
            if(old_pix_x!=pix_x || old_pix_y!=pix_y || old_button!=mouse_buttons){
                if(_current_tool == DRAW_TOOL) draw_pixel_to_sprite(pix_x, pix_y, mouse_buttons);
                else if(_current_tool == BUCKET_TOOL) flood_fill(pix_x, pix_y, mouse_buttons);
                else if(_current_tool == LINE_TOOL) line_draw_tool(pix_x, pix_y, mouse_buttons);
                else if(_current_tool == EYEDROPPER_TOOL) eye_dropper_tool(pix_x, pix_y, mouse_buttons);
            }

            old_pix_x = pix_x;
            old_pix_y = pix_y;
        }
        else{
            if(was_drawing_last_frame) add_new_history_node();
            was_drawing_last_frame = 0;
            
            if(mouse_x >= 248 && mouse_x < 312 && mouse_y >= 96 && mouse_y < 192){
                palette_selection_handler(mouse_x, mouse_y, mouse_buttons);
            }
        }
    }
    else{
        if(was_drawing_last_frame) add_new_history_node();
        was_drawing_last_frame = 0;
    }

    old_button = mouse_buttons;
}