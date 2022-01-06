
BITS 64
segment .text
label_PRINTVAL_init:
PRINTVAL:
    mov     r9, -3689348814741910323
    sub     rsp, 40
    mov     BYTE [rsp+31], 10
    lea     rcx, [rsp+30]
.L2:
    mov     rax, rdi
    lea     r8, [rsp+32]
    mul     r9
    mov     rax, rdi
    sub     r8, rcx
    shr     rdx, 3
    lea     rsi, [rdx+rdx*4]
    add     rsi, rsi
    sub     rax, rsi
    add     eax, 48
    mov     BYTE [rcx], al
    mov     rax, rdi
    mov     rdi, rdx
    mov     rdx, rcx
    sub     rcx, 1
    cmp     rax, 9
    ja      .L2
    lea     rax, [rsp+32]
    mov     edi, 1
    sub     rdx, rax
    xor     eax, eax
    lea     rsi, [rsp+32+rdx]
    mov     rdx, r8
    mov     rax, 1
    syscall
    add     rsp, 40
    ret
global _start
_start:
    mov [args_ptr], rsp
    mov rax, ret_stack_end
    mov [ret_stack_rsp], rax

; (Include "std.iri")

; (Inline "jmp _strlen_end")
jmp _strlen_end

; (Inline "_strlen:")
_strlen:

; (Inline "push  rcx            ; save and clear out counter")
push  rcx            ; save and clear out counter

; (Inline "xor   rcx, rcx")
xor   rcx, rcx

; (Inline "_strlen_next:")
_strlen_next:

; (Inline "cmp   [rdi], byte 0  ; null byte yet?")
cmp   [rdi], byte 0  ; null byte yet?

; (Inline "jz    _strlen_null   ; yes, get out")
jz    _strlen_null   ; yes, get out

; (Inline "inc   rcx            ; char is ok, count it")
inc   rcx            ; char is ok, count it

; (Inline "inc   rdi            ; move to next char")
inc   rdi            ; move to next char

; (Inline "jmp   _strlen_next   ; process again")
jmp   _strlen_next   ; process again

; (Inline "_strlen_null:")
_strlen_null:

; (Inline "mov   rax, rcx       ; rcx = the length (put in rax)")
mov   rax, rcx       ; rcx = the length (put in rax)

; (Inline "pop   rcx            ; restore rcx")
pop   rcx            ; restore rcx

; (Inline "ret                  ; get out")
ret                  ; get out

; (Inline "_strlen_end:")
_strlen_end:

; (Proc ("strlen",
;    [(Inline "pop rdi"); (Inline "call _strlen"); (Inline "push rax")]))

; (Proc ("printni", [(Inline "pop rdi"); (Inline "call PRINTVAL")]))

; (Proc ("prints",
;    [(Ident "dupl"); (Inline "pop rdi"); (Inline "call _strlen");
;      (Inline "mov rdx, rax"); (Inline "mov rax, 1"); (Inline "mov rdi, 1");
;      (Inline "pop rsi"); (Inline "syscall"); (Inline "push rax")]
;    ))

; (Proc ("add",
;    [(Inline "pop rax"); (Inline "pop rbx"); (Inline "add rax, rbx");
;      (Inline "push rax")]
;    ))

; (Proc ("sub",
;    [(Inline "pop rax"); (Inline "pop rbx"); (Inline "sub rax, rbx");
;      (Inline "push rax")]
;    ))

; (Proc ("mul",
;    [(Inline "pop rax"); (Inline "pop rbx"); (Inline "mul rbx");
;      (Inline "push rax")]
;    ))

; (Proc ("div",
;    [(Inline "pop rax"); (Inline "pop rbx"); (Inline "div rbx");
;      (Inline "push rax")]
;    ))

; (Proc ("eq",
;    [(Inline "mov rcx, 0"); (Inline "mov rdx, 1"); (Inline "pop rax");
;      (Inline "pop rbx"); (Inline "cmp rax, rbx"); (Inline "cmove rcx, rdx");
;      (Inline "push rcx")]
;    ))

; (Proc ("drop", [(Inline "pop rax")]))

; (Proc ("dupl", [(Inline "pop rax"); (Inline "push rax"); (Inline "push rax")]
;    ))

; (Proc ("ret", [(Inline "ret")]))

; (Proc ("nothing", [(Inline "nop")]))

; (Proc ("exit",
;    [(Inline "mov rax, 60"); (Inline "pop rdi"); (Inline "syscall")]))

; (PushStr "hola lola")
    push str_1

; (Ident "strlen")
label_strlen_jump:
    jmp label_strlen_end
label_strlen_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_strlen:

; (Inline "pop rdi")
pop rdi

; (Inline "call _strlen")
call _strlen

; (Inline "push rax")
push rax

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_strlen_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_strlen_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "printni")
label_printni_jump:
    jmp label_printni_end
label_printni_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_printni:

; (Inline "pop rdi")
pop rdi

; (Inline "call PRINTVAL")
call PRINTVAL

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_printni_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_printni_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "drop")
label_drop_jump:
    jmp label_drop_end
label_drop_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_drop:

; (Inline "pop rax")
pop rax

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_drop_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_drop_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (PushStr "The folling string has a length of ")
    push str_2

; (Ident "prints")
label_prints_jump:
    jmp label_prints_end
label_prints_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_prints:

; (Ident "dupl")
label_dupl_jump:
    jmp label_dupl_end
label_dupl_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_dupl:

; (Inline "pop rax")
pop rax

; (Inline "push rax")
push rax

; (Inline "push rax")
push rax

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_dupl_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_dupl_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Inline "pop rdi")
pop rdi

; (Inline "call _strlen")
call _strlen

; (Inline "mov rdx, rax")
mov rdx, rax

; (Inline "mov rax, 1")
mov rax, 1

; (Inline "mov rdi, 1")
mov rdi, 1

; (Inline "pop rsi")
pop rsi

; (Inline "syscall")
syscall

; (Inline "push rax")
push rax

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_prints_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_prints_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (PushStr "Irida is a great little (and kinda fast) language\n")
    push str_3

; (Ident "dupl")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_dupl_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "strlen")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_strlen_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "printni")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_printni_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (PushStr " characters\n")
    push str_4

; (Ident "prints")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_prints_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "drop")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_drop_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "prints")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_prints_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (PushInt 0)
    mov rax, 0
    push rax

; (Ident "exit")
label_exit_jump:
    jmp label_exit_end
label_exit_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_exit:

; (Inline "mov rax, 60")
mov rax, 60

; (Inline "pop rdi")
pop rdi

; (Inline "syscall")
syscall

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_exit_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_exit_init
mov [ret_stack_rsp], rsp
mov rsp, rax
    mov rax, 60
    mov rdi, 0
    syscall
segment .data
    str_4: db 32,99,104,97,114,97,99,116,101,114,115,10, 0
    str_3: db 73,114,105,100,97,32,105,115,32,97,32,103,114,101,97,116,32,108,105,116,116,108,101,32,40,97,110,100,32,107,105,110,100,97,32,102,97,115,116,41,32,108,97,110,103,117,97,103,101,10, 0
    str_2: db 84,104,101,32,102,111,108,108,105,110,103,32,115,116,114,105,110,103,32,104,97,115,32,97,32,108,101,110,103,116,104,32,111,102,32, 0
    str_1: db 104,111,108,97,32,108,111,108,97, 0

segment .bss
args_ptr: resq 1
ret_stack_rsp: resq 1
ret_stack: resb 8192
ret_stack_end:
mem: resb 0
