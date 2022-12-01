#include <unistd.h>

int main(void) {
    write(1, "Hello 42!\n", 10);
    return 0;
}
