
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

; (Include "./std.iri")

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

; (Proc ("printi", [(Inline "pop rdi"); (Inline "call PRINTVAL")]))

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

; (PushStr "Welcome to this fantastic irida program\n")
    push str_1

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

; (PushInt 0)
    mov rax, 0
    push rax

; (Loop
;    [(PushInt 1); (Ident "add"); (Ident "dupl"); (Ident "dupl");
;      (Ident "printi"); (PushInt 10); (Ident "eq");
;      (If ([(PushInt 0); (Ident "exit")], [(Ident "nothing")]))])
label_loop_2:

; (PushInt 1)
    mov rax, 1
    push rax

; (Ident "add")
label_add_jump:
    jmp label_add_end
label_add_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_add:

; (Inline "pop rax")
    pop rax

; (Inline "pop rbx")
    pop rbx

; (Inline "add rax, rbx")
    add rax, rbx

; (Inline "push rax")
    push rax

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_add_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_add_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "dupl")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_dupl_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "dupl")
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_dupl_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (Ident "printi")
label_printi_jump:
    jmp label_printi_end
label_printi_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_printi:

; (Inline "pop rdi")
    pop rdi

; (Inline "call PRINTVAL")
    call PRINTVAL

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_printi_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_printi_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (PushInt 10)
    mov rax, 10
    push rax

; (Ident "eq")
label_eq_jump:
    jmp label_eq_end
label_eq_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_eq:

; (Inline "mov rcx, 0")
    mov rcx, 0

; (Inline "mov rdx, 1")
    mov rdx, 1

; (Inline "pop rax")
    pop rax

; (Inline "pop rbx")
    pop rbx

; (Inline "cmp rax, rbx")
    cmp rax, rbx

; (Inline "cmove rcx, rdx")
    cmove rcx, rdx

; (Inline "push rcx")
    push rcx

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_eq_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_eq_init
mov [ret_stack_rsp], rsp
mov rsp, rax

; (If ([(PushInt 0); (Ident "exit")], [(Ident "nothing")]))
label_3_if:
    pop rax
    test rax, rax
    jz label_3_else

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
    jmp label_3_ifend
label_3_else:

; (Ident "nothing")
label_nothing_jump:
    jmp label_nothing_end
label_nothing_init:
    sub rsp, 0
    mov [ret_stack_rsp], rsp
    mov rsp, rax
label_nothing:

; (Inline "nop")
    nop

    mov rax, rsp
    mov rsp, [ret_stack_rsp]
    add rsp, 0
    ret
label_nothing_end:
mov rax, rsp
mov rsp, [ret_stack_rsp]
call label_nothing_init
mov [ret_stack_rsp], rsp
mov rsp, rax
label_3_ifend:
    jmp label_loop_2
    mov rax, 60
    mov rdi, 0
    syscall
segment .data
    str_1: db 87,101,108,99,111,109,101,32,116,111,32,116,104,105,115,32,102,97,110,116,97,115,116,105,99,32,105,114,105,100,97,32,112,114,111,103,114,97,109,10, 0

segment .bss
args_ptr: resq 1
ret_stack_rsp: resq 1
ret_stack: resb 8192
ret_stack_end:
mem: resb 0
