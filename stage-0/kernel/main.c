// main.c
#include "screen.h"

void main() {
    const char *str = "Hello from C kernel!";
    clear_screen();
    print(str);
    
    while (1);
}
