#ifndef DRAW_TOOLS
#define DRAW_TOOLS

#include "../utils.h"

extern void draw_pixel_to_sprite(u8 pix_x, u8 pix_y, u8 mouse_buttons);
extern void draw_pixel_line(u8 x0, u8 y0, u8 x1, u8 y1, u8 col, u8 brush_size, u8 brush_type);
extern void tool_handler();
extern void set_pal_icon_sprites();

#endif//DRAW_TOOLS