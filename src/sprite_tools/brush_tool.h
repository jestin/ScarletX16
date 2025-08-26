#ifndef BRUSH_TOOL
#define BRUSH_TOOL

#include "../utils.h"
extern void draw_brush_to_sprite(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type, u8 redraw_screen);
extern void draw_brush_left_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type);
extern void draw_brush_right_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type);
extern void draw_brush_lower_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type);
extern void draw_brush_upper_hemisphere(u8 x, u8 y, u8 colour, u8 brush_size, u8 brush_type);

#endif//BRUSH_TOOL