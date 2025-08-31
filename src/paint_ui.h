#ifndef PAINT_UI
#define PAINT_UI

#include "utils.h"

extern void set_layer_config();
extern void initialize_paint_ui();
extern void change_tool(u8 new_tool);

extern u8 header_container_id;
extern u8 tool_container_id;
extern u8 palette_container_id;
extern u8 context_container_id;

#endif//PAINT_UI