#include <stdio.h>

#include "tool_ui.h"
#include "../paint_canvas.h"
#include "../paint_ui.h"
#include "../utils.h"
#include "../ui_utils.h"
#include "tool_globals.h"

char shape_text[] = "shape";
void brush_ui_handler(){
    u8 icon;
    u8 shape_text_ui_id;
    // shape_text_ui_id = create_ui_element(context_container_id, UI_TEXT, 21, 1, 0, 1, _draw_ui_text, NULL);
    // init_text_element(shape_text_ui_id, shape_text);

    // #define ROUND_BRUSH_ADDR 144
    icon = create_ui_element(context_container_id, UI_BUTTON, 24, 4, 2, 2, _draw_ui_box, NULL);
    // init_icon_element(icon, 0, &brush_type, 1);

    _update_ui_element_position(context_container_id);
    _draw_ui_element(context_container_id);
}
u8 old_tool;
void tool_ui_handler(){
    // if(_ui_first_child[context_container_id] != 0){
    //     delete_ui_element(_ui_first_child[context_container_id]);
    // }

    if(old_tool != _current_tool){
        if(_current_tool == DRAW_TOOL){
            brush_ui_handler();
        }
    }
    old_tool = _current_tool;
}