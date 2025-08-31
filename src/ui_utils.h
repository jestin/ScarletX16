#ifndef UI_RENDERER
#define UI_RENDERER

#include "utils.h"

#define MAX_UI_ELEMENTS 100

#define UI_EMPTY_ELEMENT 0
#define UI_TEXT 1
#define UI_BOX 2
#define UI_HLINE 3
#define UI_VLINE 4
#define UI_BUTTON 5

extern u8 create_ui_element(u8 parent_id, u8 type, u8 pos_x, u8 pos_y, u8 size_x, u8 size_y, u16 render_func, u16 mouse_func);
extern u8 delete_ui_element(u8 id);
extern void init_text_element(u8 ui_id, u16 text_ptr);
extern void init_icon_element(u8 ui_id, u8 icon_addr, u16 variable_addr, u8 variable_value);
extern void parse_mouse_input(void);
extern void get_keycode(void);
extern u8 check_mouse_over_ui(u8 ui_ind, u8 mouse_x, u8 mouse_y);

#define M_LEFT_BUT      0b00000001
#define M_RIGHT_BUT     0b00000010
#define M_MIDDLE_BUT    0b00000100
#define M_4_BUT         0b00010000
#define M_5_BUT         0b00100000

#define MOUSE_X 0
#define MOUSE_Y 1
#define MOUSE_BUTTONS 2
extern u16 _mouse_data[3];
extern u8 keycode;

extern u8 _ui_type[MAX_UI_ELEMENTS];
extern u8 _ui_position_x[MAX_UI_ELEMENTS];
extern u8 _ui_type[MAX_UI_ELEMENTS];
extern u8 _ui_global_pos_x[MAX_UI_ELEMENTS];
extern u8 _ui_global_pos_y[MAX_UI_ELEMENTS];
extern u8 _ui_position_x[MAX_UI_ELEMENTS]; 
extern u8 _ui_position_y[MAX_UI_ELEMENTS]; 
extern u8 _ui_size_x[MAX_UI_ELEMENTS];
extern u8 _ui_size_y[MAX_UI_ELEMENTS];
extern u8 _ui_palette[MAX_UI_ELEMENTS];
extern u8 _ui_var_1[MAX_UI_ELEMENTS];
extern u8 _ui_var_2[MAX_UI_ELEMENTS];
extern u8 _ui_var_3[MAX_UI_ELEMENTS];
extern u8 _ui_var_4[MAX_UI_ELEMENTS];

extern u8 _ui_rend_func_low[MAX_UI_ELEMENTS];
extern u8 _ui_rend_func_high[MAX_UI_ELEMENTS];
extern u16 _ui_on_mouse[MAX_UI_ELEMENTS];
extern u8 _ui_on_key_low[MAX_UI_ELEMENTS];
extern u8 _ui_on_key_high[MAX_UI_ELEMENTS];

extern u8 _ui_parent[MAX_UI_ELEMENTS];
extern u8 _ui_no_of_children[MAX_UI_ELEMENTS];
extern u8 _ui_first_child[MAX_UI_ELEMENTS];
extern u8 _ui_last_child[MAX_UI_ELEMENTS];
extern u8 _ui_next_sib[MAX_UI_ELEMENTS];
extern u8 _ui_prev_sib[MAX_UI_ELEMENTS];

extern void _initialize_mouse(void);
extern void _get_mouse_input(void);
extern void _draw_ui(void);
extern void _draw_ui_element(u8 id);
extern void _update_ui_element_position(u8 id);

extern void _clear_ui_layer(u16 address);
extern void _empty_draw_func(u8 id);
extern void _draw_ui_text(u8 id);
extern void _draw_ui_box(u8 id);
extern void _draw_ui_hline(u8 id);
extern void _draw_ui_vline(u8 id);
extern void _draw_ui_icon(u8 id);

extern void _test_on_mouse_func(u8 id);
extern void _press_toggle_button_mouse_func(u8 id);

#endif//UI_RENDERER