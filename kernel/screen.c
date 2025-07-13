
void clear_screen() {
    char* video = (char*) 0xB8000;
    // Clear the screen first (80x25 characters)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';         // Space character
        video[i + 1] = 0x07;    // Light gray on black
    }
};

void print(const char* str){
    char* video = (char*) 0XB8000;
    // Print our message
    for (int i = 0; str[i] != '\0'; i++) {
        video[i * 2] = str[i];
        video[i * 2 + 1] = 0x07;
    }
}