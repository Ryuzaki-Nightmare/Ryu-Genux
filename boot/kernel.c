/*
 *  This arquive is archive c test, just print Hello World!
 * */

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;
typedef unsigned long long uint64_t;
enum vga_color {
    VGA_BLACK = 0x0,
    VGA_BLUE = 0x1,
    VGA_GREEN = 0x2,
    VGA_CYAN = 0x3,
    VGA_RED = 0x4,
    VGA_MAGENTA = 0x5,
    VGA_BROWN = 0x6,
    VGA_LIGHT_GREY = 0x7,
    VGA_DARK_GREY = 0x8,
    VGA_LIGHT_BLUE = 0x9,
    VGA_LIGHT_GREEN = 0xA,
    VGA_LIGHT_CYAN = 0xB,
    VGA_LIGHT_RED = 0xC,
    VGA_LIGHT_MAGENTA = 0xD,
    VGA_YELLOW = 0xE,
    VGA_WHITE = 0xF,
};

static volatile uint16_t* const vga = (uint16_t*)0xB8000;
static uint8_t current_color = (VGA_RED | (VGA_BLACK << 4));

static uint16_t cursor;

void vga_set_color(uint8_t fg, uint8_t bg) {
    current_color = fg | (bg << 4);
}

void vga_putchar(char c) {
    vga[cursor++] = (current_color << 8) | c;

    if (cursor >= VGA_WIDTH * VGA_HEIGHT) {
        cursor = 0;     }
}

void vga_print(const char* s) {
    for (int i = 0; s[i]; i++) {
        vga_putchar(s[i]);
    }
}

void  kernel_main(){
    vga_set_color(VGA_WHITE,VGA_BLACK);
    vga_print("Hello World!");
    while(1);
}
