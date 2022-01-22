
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

let advance_index () = index := !index + 1
let a = append

let rec compile_op = function
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

  | Proc _ | Macro _ | Alloc _ -> ()

  | o -> failwith ("Cannot generate code for " ^ show_op o)


let populate_compilation_blocks = function
  | Proc (name, _, is_rec, _, _, ops) ->
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
  
  | _ -> ()

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


and compile ?(typecheck_program=true)
            ?(show_parse=false)
            ?(asm_debug_info=false)
            source_filename =
  let program = Program.open_and_parse source_filename in
  let program' = resolve_includes program source_filename in

  if show_parse then
    show_program program' |> print_endline;

  Macros.preconditions program';
  Procedures.preconditions program';

  if typecheck_program then
    Typecheck.typecheck program';

  append header;

  List.iter populate_compilation_blocks program';
  List.iter (fun op ->
               if asm_debug_info then
                 show_op op |> comment |> append;
               compile_op op ) program';

  !mem_capacity |> string_of_int 
                |> footer !strings !allocations 
                |> append;

  get ()