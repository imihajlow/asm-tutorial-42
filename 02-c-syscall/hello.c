#include <unistd.h>

int main(void) {
    syscall(1, 1, "Hello 42!\n", 10);
    return 0;
}
