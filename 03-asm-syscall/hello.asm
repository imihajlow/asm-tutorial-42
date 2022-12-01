    bits 64
    default rel
    
    global _start           ; function main() is exported

    section .text
_start:                     
    ; syscall number 1 - write()
    mov eax, 1            ;   syscall number in RAX - long number      64 bits
    mov edi, 1            ;  first parameter in EDI - int fd           32 bits
    lea rsi, [hello]      ; second parameter in RSI - const void *buf  64 bits
    mov edx, hello_len    ;  third parameter in RDX - size_t count     64 bits
    syscall

    ; syscall number 60 - exit()
    mov eax, 60           ;   syscall number in RAX - long number      64 bits
    xor edi, edi          ;  first parameter in EDI - int status       32 bits
    syscall

    section .rodata
hello:
    db "Hello from pure ASM", 10
hello_end:

hello_len equ hello_end - hello
