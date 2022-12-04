    bits 64
    default rel
    
    global _start           ; symbol _start is exported - program entry point

    section .text
_start:                     

    ; At program start, Linux supplies us with program arguments on stack
    
    mov eax, [rsp]      ; Number of arguments on top of the stack
    cmp eax, 1
    jle no_args

    ; Convert the string supplied as an argument to integer
    ; pointers to the arguments start from [rsp + 8]
    mov rdi, [rsp + 16]  ; rdi = pointer to the first argument (argv[1])
    call atol

    ; Do something interesting with the number
    inc rax          

    ; Convert the number to string
    sub rsp, 32      ; allocate 32 bytes on stack
    mov rdi, rax     ; first parameter - number to convert
    mov rsi, rsp     ; second parameter - pointer to buffer
    call ltoa


    ; Print the string
    mov rdx, rax     ; third parameter - length
    mov eax, 1       ; syscall number 1 - write
    mov edi, 1       ; first parameter - file descriptor 1 - stdout
    mov rsi, rsp     ; second parameter - string buffer
    syscall
    add rsp, 32      ; free the buffer


    ; syscall number 60 - exit()
    mov eax, 60           ;   syscall number in RAX - long number      64 bits
    xor edi, edi          ;  first parameter in EDI - int status       32 bits
    syscall

    ; Error handlers
no_args:
    mov rsi, str_no_args        ; second parameter - string buffer
    mov edx, str_no_args_len    ;  third parameter - string length
    jmp write_and_die

overflow:
    mov rsi, str_overflow        ; second parameter - string buffer
    mov edx, str_overflow_len    ;  third parameter - string length

    ; Common code for printing a message and exiting with code 1
write_and_die:
    ; syscall number 1 - write()
    mov eax, 1            ;   syscall number in RAX - long number      64 bits
    mov edi, 1            ;  first parameter in EDI - int fd           32 bits
    syscall

    ; syscall number 60 - exit()
    mov eax, 60           ;   syscall number in RAX - long number      64 bits
    mov edi, 1            ;  first parameter in EDI - int status       32 bits
    syscall


    ; ==========================================================================
    ; atol - convert a null-terminated string to a 64-bit unsigned integer
    ; 
    ; parameters:
    ;   RDI - pointer to the string
    ;
    ; return value:
    ;   RAX - the converted value
atol:
    xor rax, rax  ; RAX will contain the result, zero it out
    xor rcx, rcx  ; RCX will hold current digit
    mov esi, 10   ; RSI holds 10 - a constant base

.loop_begin:
    mov cl, [rdi] ; Load the character from the string
    inc rdi       ; Advance string pointer
    sub cl, '0'   ; Convert ASCII digit to its numeric value
    jl  .loop_end ; Jump to the end if the char was below '0'
    cmp cl, 9
    jg  .loop_end ; Finish if CL > 9
    
    mul rsi       ; RDX:RAX = RAX * RSI
    jc  overflow  ; Flag C is set if there was an overflow - jump to the error handler
    add rax, rcx  ; Add the digit to the multiplication result
    jc  overflow  ; Check for overflow again

    jmp .loop_begin

.loop_end:
    ret
    ; end of function
    ; ==========================================================================


    ; ==========================================================================
    ; ltoa - convert a 64-bit unsigned integer to a null-terminated string
    ;
    ; parameters:
    ;   RDI - the number to convert
    ;   RSI - pointer to buffer to hold the result
    ;
    ; return value:
    ;   RAX - length of the resulting string (excluding the terminating zero)
ltoa:
    test rdi, rdi
    jz  .zero                  ; Handle special case if the number is zero

    mov rax, rdi               ; DIV instruction requires the dividend to be in RAX
    mov ecx, 10                ; RCX will hold the constant base 10
    mov r8, rsi                ; Save original buffer pointer to R8
.loop_begin:
    xor rdx, rdx               ; Zero the upper 64 bits of the dividend
    div rcx                    ; Divide RDX:RAX by RCX. RDX - remainder, RAX - quotient.
    add dl, '0'                ; Convert remainder to ASCII
    mov [rsi], dl              ; Store it in the buffer
    inc rsi                    ; Advance buffer pointer
    test rax, rax              ; Check the quotient for zero
    jnz .loop_begin            ; Not zero - repeat the loop

    mov [rsi], byte 0          ; Save the terminating zero to the string

    ; Now we have the converted number backwards.
    ; Let's reverse it in place.
    sub rsi, r8                ; RSI = the resulting length of the string
    mov rax, rsi               ; Duplicate the length in RAX
    shr rsi, 1                 ; RSI /= 2  - the number of iterations
    jz  .reverse_loop_end      ; Nothing to do - jump to the end
    lea r9, [r8 + rax - 1]     ; R9 is the pointer to the end of the buffer

    ; R8 - pointer to the start of the buffer
    ; R9 - pointer to the end of the buffer
.reverse_loop_begin:
    mov cl, [r8]               ; Load the byte from the start
    xchg cl, [r9]              ; Exchange it with the byte in the end
    mov [r8], cl               ; Store the exchanged byte to the start
    
    ; Advance the pointers
    inc r8
    dec r9
    ; Decrement the iterations count
    dec rsi
    jnz .reverse_loop_begin    ; If not done - repeat
.reverse_loop_end:
    ret

.zero:
    mov [rsi], word 0x0030      ; Store two bytes - 0x30 and 0x00 to the buffer
    mov eax, 1                 ; Return 1 - the length of the string
    ret
    ; end of function
    ; ==========================================================================


    section .rodata
str_overflow: db "Overflow!", 10
str_overflow_len equ $ - str_overflow


str_no_args: db "No arguments are given", 10
str_no_args_len equ $ - str_no_args
