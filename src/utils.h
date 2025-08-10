#ifndef X16_UTILS
#define X16_UTILS

#include <stdint.h>

#define u8 uint8_t
#define u16 uint16_t
#define u32 uint32_t
#define u64 uint64_t

#define i8 int8_t
#define i16 int16_t
#define i32 int32_t
#define i64 int64_t

// Assembly Function Definitions:
extern void _load_palette_from_file(u16 fname_ptr, u8 fname_size, u8 pal_off);
extern void _load_file_into_vram(u16 fname_ptr, u8 fname_size, u8 vram_bank, int vram_addr);
extern void _load_file_into_ram(u16 fname_ptr, u8 fname_size, u16 ram_addr);

extern void _set_layer0_enable(u8 enable);
extern void _set_layer1_enable(u8 enable);
extern void _set_sprites_enable(u8 enable);

extern void _set_sprite_attribute(char attr_num, int addr, char bpp_mode, int x, int y, char spr_attr, char size, char pal_off);
// spr_attr: col-mask:7-4, z-depth:3-2, v-flip, h-flip
extern void _offset_spr_position(char attr_num, int x_pos, int y_pos);
extern void _set_spr_position(char attr_num, int x_pos, int y_pos);
extern void _set_spr_x_position(int x_pos, u8 attr_num);
extern void _set_spr_y_position(int y_pos, u8 attr_num);
extern void _clear_sprite_attribute(u8 attr_num);
extern void _set_sprite_address(u16 spr_attr, u8 attr_num);
extern void _darken_palette(u8 darken_value);
extern void _lighten_palette(u8 lighten_value);
extern void _darken_palette_sec(u8 palette_ind, u8 darken_value);
extern void _lighten_palette_sec(u8 palette_ind, u8 lighten_value);
extern void _darken_palette_col(u8 palette_ind, u8 darken_value);
extern void _lighten_palette_col(u8 palette_ind, u8 lighten_value);

extern void _wait_for_nmi(void);
extern void _init_irq_handler(void);
extern void _init_screen_mode(void);
extern void _force_halt(void);
extern u16 _get_joystick_state(void);
extern void _return_to_command_prompt(void);

extern void _clear_spr_attributes(u8 spr_end, u8 spr_start);
extern void _set_spr_zindex(u8 no_of_sprs, u8 spr_offset);

// Assembly Array Definitions:
extern u16 _X_SCROLL;
extern u16 _Y_SCROLL;

// X16 Address Defintions:
#define VERA_dc_hscale (*(u8 *)0x9F2A)
#define VERA_dc_vscale (*(u8 *)0x9F2B)

#define L0_CONFIG (*(u8 *)0x9F2D)
#define L0_MAPBASE (*(u8 *)0x9F2E)
#define L0_TILEBASE (*(u8 *)0x9F2F)

#define L0_HSCROLL (*(u16 *)0x9F30)
#define L0_VSCROLL (*(u16 *)0x9F32)

#define L1_CONFIG (*(u8 *)0x9F34)
#define L1_MAPBASE (*(u8 *)0x9F35)
#define L1_TILEBASE (*(u8 *)0x9F36)

#define L1_HSCROLL (*(u16 *)0x9F37)
#define L1_VSCROLL (*(u16 *)0x9F39)

#define VERA_ctrl (*(u8 *)0x9F25)
#define VERA_addr_low  (*(u8 *)0x9F20)
#define VERA_addr_high (*(u8 *)0x9F21)
#define VERA_addr_bank (*(u8 *)0x9F22)
#define VERA_data0     (*(u8 *)0x9F23)
#define VERA_data1     (*(u8 *)0x9F24)

#define DC_HSTART (*(u8 *)0x9F29)
#define DC_HSTOP (*(u8 *)0x9F2A)
#define DC_VSTART (*(u8 *)0x9F2B)
#define DC_VSTOP (*(u8 *)0x9F2C)

#define DC_HSCALE (*(u8 *)0x9F2A)
#define DC_VSCALE (*(u8 *)0x9F2B)
#define DC_BORDER (*(u8 *)0x9F2C)

#define VRAM_sprattr 0x1FC00
#define VRAM_palette 0x1FA00

#define L0_HSCROLL (*(u16 *)0x9F30)
#define L0_VSCROLL (*(u16 *)0x9F32)
#define L1_HSCROLL (*(u16 *)0x9F37)
#define L1_VSCROLL (*(u16 *)0x9F39)

#define RAM_BANK_SEL (*(u8 *)0x0000)
#define ROM_BANK_SEL (*(u8 *)0x0001)

#define RAM_BANK_ADDR 0xA000
#define GOLD_RAM_ADDR 0x0400

// _____________________________________________________
u8 get_pressed(u16 joystick, u16 button);
u8 get_just_pressed(u16 joystick, u16 button);
extern u16 old_joystick;
#define JOY_A           0b1000000000000000
#define JOY_X           0b0100000000000000
#define JOY_L           0b0010000000000000
#define JOY_R           0b0001000000000000

#define JOY_B           0b0000000010000000
#define JOY_Y           0b0000000001000000
#define JOY_SEL         0b0000000000100000
#define JOY_SRT         0b0000000000010000
#define JOY_UP          0b0000000000001000
#define JOY_DOWN        0b0000000000000100
#define JOY_LEFT        0b0000000000000010
#define JOY_RIGHT       0b0000000000000001

#endif //X16_UTILS