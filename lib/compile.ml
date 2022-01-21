
open Types
open Utils
open Utils.Out
open Templates

let mem_capacity = ref 0
let procedures = ref (Hashtbl.create 0)
let macros = ref (Hashtbl.create 0)
let allocations = ref []
let strings: (int * string) list ref = ref []
let index = ref 0

let rec compile_op op =
  (* Debug info *)
  show_op op |> comment |> append;

  let advance_index () = index := !index + 1 in
  let a = append in

  match op with
    | PushInt i ->
        pushInt i |> a

    | PushStr s ->
        advance_index ();
        let i = !index in
        strings := (i, s) :: !strings;
        pushStr i |> a

    | Ident x ->
        (try
          let body = Hashtbl.find !procedures x in

          procHeader x |> a;
          List.iter compile_op body;
          procFooter x |> a;

          Hashtbl.remove !procedures x;
          procCall x |> a;
        with Not_found -> procCall x |> a )

    | MacroReplace x ->
        let body = Hashtbl.find !macros x in
        List.iter compile_op body

    | If (then_branch, else_branch) ->
        advance_index ();
        let i = !index in
        ifHeader i |> a;
        List.iter compile_op then_branch; (* Then *)
        jmpOp (string_of_int i ^ "_ifend") |> a;
        label (string_of_int i ^ "_else") |> a; (* Else *)
        List.iter compile_op else_branch;
        (* If end *)
        ifFooter i |> a

    | Loop ops ->
        advance_index ();
        let i = !index in
        "label_loop_" ^ (string_of_int i) ^ ":" |> a;
        List.iter compile_op ops;
        jmpOp ("loop_" ^ (string_of_int i)) |> a

    | Proc (name, is_rec, _inputs, _outputs, ops) ->
        if not is_rec then
          Hashtbl.add !procedures name ops
        else begin
          procHeader name |> a;
          List.iter compile_op ops;
          procFooter name |> a
        end
    
    | Macro (name, ops) ->
        Hashtbl.add !macros ("$" ^ name) ops

    | Alloc (_data_t, name) ->
        let start = !mem_capacity in
        mem_capacity := !mem_capacity + 8; (* amount; *)
        allocations := (start, name) :: !allocations

    | MemWrite name ->
        memWrite name |> a

    | MemRead name ->
        memRead name |> a

    | Inline line ->
        line |> a

    | While (cond_ops, body_ops) ->
        advance_index ();
        let i = !index in

        "label_while_cond_" ^ (string_of_int i) ^ ":" |> a;
        List.iter compile_op cond_ops;
        "pop rax"       @@
        "test rax, rax" @@
        "jz while_end_" ^ (string_of_int i) |> a;

        "label_while_body_" ^ (string_of_int i) ^ ":" |> a;
        List.iter compile_op body_ops;

        jmpOp ("while_cond_" ^ (string_of_int i)) |> a;

        "while_end_" ^ (string_of_int i) ^ ":" |> a;


    | _ -> failwith ("Cannot generate code for " ^ show_op op)


let resolved_includes = ref []
let rec resolve_includes (p: program) (file_name: string): program =
  match p with
    | [] -> []
    | Include f :: rest ->
        if List.exists (fun el -> String.equal el f) !resolved_includes then
          resolve_includes rest file_name
        else begin
          resolved_includes := List.append !resolved_includes [f];
          resolve_includes (Program.open_and_parse f) file_name @
          resolve_includes rest file_name
        end
    | op::rest ->
        op::resolve_includes rest file_name

and compile ?(show_parse=false) ?(typecheck_program=true) source_filename =
  let program = Program.open_and_parse source_filename in
  let program' = resolve_includes program source_filename in

  if show_parse then
    show_program program' |> print_endline;

  if typecheck_program then
    Typecheck.typecheck program';

  append header;
  List.iter compile_op program';
  !mem_capacity
    |> string_of_int
    |> footer (!strings) (!allocations)
    |> append;
  get ()