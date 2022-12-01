    bits 64
    default rel
    
    global main           ; function main() is exported
    extern write          ; function write() is imported

    section .text
main:                     
    mov edi, 1            ;  first parameter in EDI - int fd           32 bits
    lea rsi, [hello]      ; second parameter in RSI - const void *buf  64 bits
    mov edx, hello_len    ;  third parameter in RDX - size_t count     64 bits
    call write

    xor eax, eax          ; main() return value in EDI                 32 bits
    ret

    section .rodata
hello:
    db "Hello from ASM main", 10
hello_end:

hello_len equ hello_end - hello
