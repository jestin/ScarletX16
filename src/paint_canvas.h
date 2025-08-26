#ifndef PAINT_CANVAS
#define PAINT_CANVAS

#include "utils.h"

#define DRAW_TOOL 0
#define BUCKET_TOOL 1
#define SELECTION_TOOL 2
#define LINE_TOOL 3
#define EYEDROPPER_TOOL 4
#define GRADIENT_TOOL 5
#define SPRAY_TOOL 6
#define SHAPE_TOOL 7

#define SPRITE_VRAM_DATA_ADDR 0x08000
#define DISPLAY_VRAM_ADDR 0x0C000

#define HIS_STACK_ADDR (*(u16 *)0x56)
#define HIS_STACK_BANK (*(u8 *)0x58)

#define PAL_SPR_ROWS (*(u8 *)0x59)
#define PAL_SPR_WIDTH (*(u8 *)0x60)
#define PAL_SPR_HEIGHT (*(u8 *)0x61)

extern u8 _primary_colour;
extern u8 _secondary_colour;
extern u8 _current_tool;

extern u8 original_tool;
extern u8 tool_timer;

extern u8* bmx_header;
extern u8* bmx_bit_depth;
extern u8* bmx_vera_bit_depth;
extern u16* bmx_width;
extern u16* bmx_height;
extern u8* bmx_no_pals;
extern u8* bmx_pal_start;
extern u16* bmx_data_start;

extern u8 _x_axis;
extern u8 _y_axis;
extern u8 _canvas_scale;
extern u8 _canvas_pow_scale;
extern u8 _canvas_paint_offset;
extern u8 _canvas_paint_width;
extern u8 _display_width;
extern u8 _display_height;
extern u16 _sprite_vram_size;
extern u16 _sprite_size;
extern u8 _display_row_pow;
extern u8 _display_has_columns;

extern void _initialize_bmx_data(void);
extern void _draw_canvas_to_screen(void);
extern void _render_palette_sprites(void);
extern void _draw_row_to_screen(u8 row);
extern void _transfer_pal_to_vera(void);
extern void _transfer_sprite_to_vram(u16 size, u16 addr, u8 ram_bank);

extern void handle_keyboard_input(void);

extern void _draw_row_to_sprite(u8 pal_col, u8 width, u8 x, u8 y);
extern void _draw_column_to_sprite(u8 pal_col, u8 height, u8 x, u8 y);
extern u8 _get_pixel(u8 x, u8 y);

extern u16 _image_data_size;

extern void init_canvas_vera_sprites(void);

#endif//PAINT_CANVAS