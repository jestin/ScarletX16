#include "utils.h"

u8 get_pressed(u16 joystick, u16 button){
    if((joystick & button) != 0){
        return(1);
    }
    return(0);
}

u16 old_joystick = 0;
u8 get_just_pressed(u16 joystick, u16 button){
    if((joystick & button) != 0 && (old_joystick & button) == 0){
        return(1);
    }
    return(0);
}