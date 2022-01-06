
let (@@) s1 s2 = s1 ^ "\n" ^ s2


let header =
  "BITS 64"                              @@
  "segment .text"                        @@
  "label_PRINTVAL_init:"                 @@
  "PRINTVAL:"                            @@
  "    mov     r9, -3689348814741910323" @@
  "    sub     rsp, 40"                  @@
  "    mov     BYTE [rsp+31], 10"        @@
  "    lea     rcx, [rsp+30]"            @@
  ".L2:"                                 @@
  "    mov     rax, rdi"                 @@
  "    lea     r8, [rsp+32]"             @@
  "    mul     r9"                       @@
  "    mov     rax, rdi"                 @@
  "    sub     r8, rcx"                  @@
  "    shr     rdx, 3"                   @@
  "    lea     rsi, [rdx+rdx*4]"         @@
  "    add     rsi, rsi"                 @@
  "    sub     rax, rsi"                 @@
  "    add     eax, 48"                  @@
  "    mov     BYTE [rcx], al"           @@
  "    mov     rax, rdi"                 @@
  "    mov     rdi, rdx"                 @@
  "    mov     rdx, rcx"                 @@
  "    sub     rcx, 1"                   @@
  "    cmp     rax, 9"                   @@
  "    ja      .L2"                      @@
  "    lea     rax, [rsp+32]"            @@
  "    mov     edi, 1"                   @@
  "    sub     rdx, rax"                 @@
  "    xor     eax, eax"                 @@
  "    lea     rsi, [rsp+32+rdx]"        @@
  "    mov     rdx, r8"                  @@
  "    mov     rax, 1"                   @@
  "    syscall"                          @@
  "    add     rsp, 40"                  @@
  "    ret"                              @@
  "global _start"                        @@
  "_start:"                              @@
  "    mov [args_ptr], rsp"              @@
  "    mov rax, ret_stack_end"           @@
  "    mov [ret_stack_rsp], rax"


let exit_syscall =
  "    mov rax, 60"       @@
  "    mov rdi, 0"        @@
  "    syscall"

let bss_segment _mem_capacity =
  "segment .bss"          @@
  "args_ptr: resq 1"      @@
  "ret_stack_rsp: resq 1" @@
  "ret_stack: resb 8192"  @@
  "ret_stack_end:"        @@
  "mem: resb 0"
  (* "mem: resb " ^ mem_capacity *)

(** Takes a string and returns another string with the decimal value of each
    of each character *)
let str_to_dec_val_list str =
  (String.to_seq str |> List.of_seq
  |> List.fold_left (fun res c -> Printf.sprintf "%s%d," res (int_of_char c)) "")
  ^ " 0"


let footer (strings: (int * string) list) _mem_capacity =
  let str_to_asm (index, str) =
    "    str_" ^ string_of_int index ^
    ": db " ^ str_to_dec_val_list str ^ "\n" in

  exit_syscall            @@
  "segment .data"         @@
  List.fold_left (fun res (i, str) ->
    res ^ str_to_asm (i, str) ) "" strings @@
  bss_segment _mem_capacity

let pushInt i =
  let i' = Int.to_string i in
  "    mov rax, " ^ i' @@
  "    push rax"


let cmpOp =
  "    pop rax" @@
  "    pop rbx" @@
  "    cmp rax, rbx"

(** Jump if greater *)
let jgOp loc =
  cmpOp @@
  "    jg " ^ loc

let label name =
  "label_" ^ name ^ ":"


let jmpOp name =
  "    jmp label_" ^ name

(* Procedures *)

let procJump name =
  label (name ^ "_jump") @@
  jmpOp (name ^ "_end")

let procInit name =
  label (name ^ "_init")         @@
  "    sub rsp, 0"               @@
  "    mov [ret_stack_rsp], rsp" @@
  "    mov rsp, rax"

let procRet _name =
  (* label (name ^ "_ret")      @@ *)
  "" @@
  "    mov rax, rsp"             @@
  "    mov rsp, [ret_stack_rsp]" @@
  "    add rsp, 0"               @@
  "    ret"

let procEnd name =
  label (name ^ "_end")


let procHeader name =
  procJump name @@
  procInit name @@
  label name

let procFooter name =
  procRet name @@
  procEnd name



let procCall name =
  "mov rax, rsp"                   @@
  "mov rsp, [ret_stack_rsp]"       @@
  "call " ^ "label_" ^ (name ^ "_init") @@
  "mov [ret_stack_rsp], rsp"       @@
  "mov rsp, rax"