#ifndef HISTORY_STACK
#define HISTORY_STACK

#include "utils.h"

extern void _add_history_node_position(u8 x, u8 y);
extern u8 _get_history_byte(void);
extern u8 _get_history_redo_byte(void);
extern void add_history_node_position(u8 x, u8 y, u8 col);
extern void add_new_history_node(void);
extern void restore_last_history_node(void);
extern void undo_last_history_node(void);

#endif//HISTORY_STACK