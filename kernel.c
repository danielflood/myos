// kernel.c
void main() {
    const char *str = "Hello from C kernel!";
    char *video = (char*) 0xb8000;
    
    // Clear the screen first (80x25 characters)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';         // Space character
        video[i + 1] = 0x07;    // Light gray on black
    }
    
    // Print our message
    for (int i = 0; str[i] != '\0'; i++) {
        video[i * 2] = str[i];
        video[i * 2 + 1] = 0x07;
    }
    
    while (1);
}
