
let (@@) s1 s2 = s1 ^ "\n" ^ s2

let header =
  "BITS 64"                              @@
  "global    main"                       @@
  "section   .text"                      @@
  "main:"                                @@
  "    mov [args_ptr], rsp"              @@
  "    mov rax, ret_stack_end"           @@
  "    mov [ret_stack_rsp], rax"



let bss_segment mem_capacity =
  "segment .bss"          @@
  "args_ptr: resq 1"      @@
  "ret_stack_rsp: resq 1" @@
  "ret_stack: resb 8192"  @@
  "ret_stack_end:"        @@
  "mem: resb " ^ mem_capacity


(** Takes a string and returns another string with the decimal value of each
    of each character *)
let str_to_dec_val_list str =
  (String.to_seq str |> List.of_seq
  |> List.fold_left (fun res c -> Printf.sprintf "%s%d," res (int_of_char c)) "")
  ^ " 0"

let footer (strings: (int * string) list) (allocations: (int * string) list) mem_capacity =
  let str_to_asm (index, str) =
    "str_" ^ string_of_int index ^
    ": db " ^ str_to_dec_val_list str ^ "\n" in

  "    ret" @@
  "segment .data" @@
  List.fold_left (fun res (i, str) ->
    res ^ str_to_asm (i, str) ) "" strings
  @@
  List.fold_left (fun res (i, str) ->
    res ^ (Printf.sprintf "    %s: dq %d" str i) ) "" allocations
  @@ bss_segment mem_capacity


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