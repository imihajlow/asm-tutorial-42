    bits 64
    default rel
    
    global main           ; symbol main is exported
    extern write          ; symbol write is imported

    section .text
main:                     
    mov edi, 1            ;  first parameter in EDI - int fd           32 bits
    mov rsi, hello        ; second parameter in RSI - const void *buf  64 bits
    mov edx, hello_len    ;  third parameter in RDX - size_t count     64 bits
    call write

    xor eax, eax          ; main() return value in EAX                 32 bits
    ret

    section .rodata
hello:
    db "Hello from ASM main", 10

hello_len equ $ - hello
