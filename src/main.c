#include <stdio.h>
#include <cbm.h>

#include "utils.h"
#include "ui_utils.h"
#include "paint_ui.h"
#include "paint_canvas.h"
#include "history_stack.h"
#include "draw_tools_utils.h"

#define LFN 15
#define DEVICE 8
#define SA 2
#define MODE 0
char filename[] = "fruit.bmx";
void load_bmx_file(){
    u16 vram_addr = SPRITE_VRAM_DATA_ADDR;
    u8 ram_bank = 2;
    cbm_open(LFN, DEVICE, SA, filename);
    cbm_read(LFN, GOLD_RAM_ADDR, 32);

    // load palette --------------------------------------------------
    RAM_BANK_SEL = 1;
    if((*bmx_no_pals) != 0) cbm_read(LFN, RAM_BANK_ADDR, ((u16)(*bmx_no_pals))*2);
    else cbm_read(LFN, RAM_BANK_ADDR, 256*2);
    _transfer_pal_to_vera();

    // load sprite data --------------------------------------------------
    RAM_BANK_SEL = ram_bank;
    _image_data_size = ((*bmx_width)*(*bmx_height)) >> (3- (*bmx_vera_bit_depth));
    while(_image_data_size > 0x2000){
        cbm_read(LFN, RAM_BANK_ADDR, 0x2000);
        _transfer_sprite_to_vram(0x2000, vram_addr, 0);
        vram_addr += 0x2000;
        ram_bank += 1;
        RAM_BANK_SEL = ram_bank;
        if(_image_data_size > 0x2000){ 
            _image_data_size -= 0x2000;
        }
        else{ 
            break;
        }
    }

    cbm_read(LFN, RAM_BANK_ADDR, _image_data_size);
    _transfer_sprite_to_vram(_image_data_size, vram_addr, 0);

    cbm_close(LFN);

    HIS_STACK_ADDR = 0xA000;
    HIS_STACK_BANK = 4;
}

void save_bmx_file(){
    cbm_open(LFN, DEVICE, SA, filename);


    cbm_close(LFN);
}

void handle_keyboard_input(){
    if (keycode) {
        if(keycode == 26) undo_last_history_node();
        else if(keycode == 25) restore_last_history_node();

        else if(keycode == 73) change_tool(EYEDROPPER_TOOL);
        else if(keycode == 66) change_tool(DRAW_TOOL);

        else if(keycode == 83) save_bmx_file();
        // printf("PETSCII Code %u\n", keycode);
    }
}

int main(){
    u8 ui_index = 0;

    _init_irq_handler();
    _init_screen_mode();
    set_layer_config();
    _initialize_mouse();
    initialize_paint_ui();
    
    load_bmx_file();
    init_canvas_vera_sprites();
    _render_palette_sprites();

    _draw_ui_element(0);
    _draw_canvas_to_screen();
    set_pal_icon_sprites();

    while(1){
        _wait_for_nmi();

        _get_mouse_input();
        parse_mouse_input();
        get_keycode();
        handle_keyboard_input();
        tool_handler();
        // _draw_ui_element(0);
    }
}

// #include <stdio.h>

// unsigned char keycode;

// void main() {
//     while(1) {
//         asm("jsr $FFE4");
//         asm("sta %v", keycode);

//         if (keycode) {
//             printf("PETSCII Code %u\n", keycode);
//         }
//     }
// }