#include <stdio.h>

#include "history_stack.h"
#include "paint_canvas.h"
#include "utils.h"

u16 node_start_pos;
u8 starting_new_node = 1;

u8 last_x = 0;
u8 last_y = 0;
u8 length_counter = 0;
u8 curr_col;
void add_history_node_position(u8 x, u8 y, u8 colour){
    if(x<(*bmx_width) && y<(*bmx_height)){
        if(last_x!=x || last_y!=y){
            if(length_counter == 255) add_new_history_node();

            if(starting_new_node){
                curr_col = colour;
                node_start_pos = HIS_STACK_ADDR;
                starting_new_node = 0;
                HIS_STACK_ADDR += 2;
                length_counter = 0;
            }


            last_x = x;
            last_y = y;
            length_counter += 1;
            _add_history_node_position(x,y);
        }
    }
}

void add_history_node_row(u8 width, u8 x, u8 y, u8 colour){
    u8 i;
    for(i=0; i<width; i++){
        add_history_node_position(x+i,y,colour);
    }
}

void add_history_node_column(u8 height, u8 x, u8 y, u8 colour){
    u8 i;
    for(i=0; i<height; i++){
        add_history_node_position(x,y+i,colour);
    }
}

void add_new_history_node(){
    u8 *addr = HIS_STACK_ADDR;    
    *addr = length_counter;

    addr = node_start_pos;
    *addr = length_counter;

    addr += 1;
    *addr = curr_col;

    HIS_STACK_ADDR += 1;

    length_counter = 0;
    starting_new_node = 1;
}

void restore_last_history_node(){
    if(HIS_STACK_ADDR <= node_start_pos){
        u8 length = _get_history_redo_byte();
        u8 colour = _get_history_redo_byte();
        u8 i;

        for(i=0; i<length; i++){
            u8 col = _get_history_redo_byte();
            u8 y = _get_history_redo_byte();
            u8 x = _get_history_redo_byte();
            _draw_row_to_sprite(colour, 1, x, y);
        }
        _get_history_redo_byte();
        _draw_canvas_to_screen();
    }
}

void undo_last_history_node(){
    if(HIS_STACK_ADDR > 0xA000){
        u8 i = 0;
        u8 length = _get_history_byte();
        
        for(i=0; i<length; i++){
            u8 x = _get_history_byte();
            u8 y = _get_history_byte();
            u8 col = _get_history_byte();
            _draw_row_to_sprite(col, 1, x, y);
        }
        _get_history_byte();
        _get_history_byte();
        _draw_canvas_to_screen();
    }
}