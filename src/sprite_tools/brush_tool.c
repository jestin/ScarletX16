#include <stdio.h>

#include "brush_tool.h"

#include "../paint_canvas.h"
#include "../history_stack.h"
#include "../utils.h"
#include "../ui_utils.h"
#include "tool_ui.h"

u8 row_widths[] = {1, 1, 2, 2, 3, 3, 2, 3, 4, 4, 2, 3, 4, 5, 5, 3, 4, 5, 6, 6, 6, 3, 4, 5, 6, 7, 7, 7, 3, 5, 
    6, 7, 7, 8, 8, 8, 3, 5, 6, 7, 8, 8, 9, 9, 9, 3, 5, 6, 7, 8, 9, 9, 10, 10, 10, 4, 6, 7, 8, 9, 10, 10, 11, 
    11, 11, 11, 4, 6, 7, 8, 9, 10, 11, 11, 12, 12, 12, 12, 4, 6, 8, 9, 10, 11, 11, 12, 12, 13, 13, 13, 13, 4, 
    7, 8, 9, 10, 11, 12, 13, 13, 13, 14, 14, 14, 14, 4, 7, 9, 10, 11, 12, 13, 13, 14, 14, 14, 15, 15, 15, 15, 
    4, 7, 9, 10, 11, 12, 13, 14, 14, 15, 15, 15, 16, 16, 16, 16};
u8 brush_ptrs[17] = {0, 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120};

void draw_brush_to_sprite(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type, u8 redraw_screen){
    u8 radius = brush_size>>1;
    u8 width_index = brush_ptrs[radius];
    u8 width;
    u8 i;
    u8 j;
    for(i=0; i<radius; i++){
        width = row_widths[width_index];
        width_index += 1;

        // add_history_node_row((width<<1), x-width, y+i-radius, colour);
        // add_history_node_row((width<<1), x-width, y+radius-i-1, colour);

        _draw_row_to_sprite(colour, (width<<1), x-width, y+i-radius);
        _draw_row_to_sprite(colour, (width<<1), x-width, y+radius-i-1);

        if(redraw_screen){
            _draw_row_to_screen(y+i-radius);
            _draw_row_to_screen(y+radius-i-1);
        }
    }
}

void draw_brush_right_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type){
    u8 radius = brush_size>>1;
    u8 width_index = brush_ptrs[radius];
    u8 width;
    u8 i;
    u8 j;
    for(i=0; i<radius; i++){
        width = row_widths[width_index];
        width_index += 1;
        // add_history_node_row((width<<1), x-width, y+radius-i-1, colour);
        _draw_column_to_sprite(colour, (width<<1), x+radius-i-1, y-width);
    }
}

void draw_brush_left_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type){
    u8 radius = brush_size>>1;
    u8 width_index = brush_ptrs[radius];
    u8 width;
    u8 i;
    u8 j;
    for(i=0; i<radius; i++){
        width = row_widths[width_index];
        width_index += 1;

        // add_history_node_row((width<<1), x-width, y+i-radius, colour);
        _draw_column_to_sprite(colour, (width<<1), x+i-radius, y-width);
    }
}

void draw_brush_lower_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type){
    u8 radius = brush_size>>1;
    u8 width_index = brush_ptrs[radius];
    u8 width;
    u8 i;
    u8 j;
    for(i=0; i<radius; i++){
        width = row_widths[width_index];
        width_index += 1;
        // add_history_node_row((width<<1), x-width, y+radius-i-1, colour);
        _draw_row_to_sprite(colour, (width<<1), x-width, y+radius-i-1);
    }
}

void draw_brush_upper_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type){
    u8 radius = brush_size>>1;
    u8 width_index = brush_ptrs[radius];
    u8 width;
    u8 i;
    u8 j;
    for(i=0; i<radius; i++){
        width = row_widths[width_index];
        width_index += 1;

        // add_history_node_row((width<<1), x-width, y+i-radius, colour);
        _draw_row_to_sprite(colour, (width<<1), x-width, y+i-radius);
    }
}