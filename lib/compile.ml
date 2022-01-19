
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
        with
          | Not_found -> procCall x |> a )

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

    | Alloc (amount, name) ->
        let start = !mem_capacity in
        mem_capacity := !mem_capacity + amount;
        allocations := (start, name) :: !allocations

    | MemWrite name ->
        memWrite name |> a

    | MemRead name ->
        memRead name |> a

    | Inline line ->
        line |> a

    | _ -> failwith ("unknown " ^ show_op op)


let resolved_includes = ref []
let rec resolve_includes (program: op list): op list =
  match program with
    | [] -> []
    | Include f::rest ->
        if List.exists (fun el -> String.equal el f) !resolved_includes then
          resolve_includes rest
        else begin
          resolved_includes := List.append !resolved_includes [f];
          (open_and_parse f |> resolve_includes) @ resolve_includes rest
        end
    | op::rest ->
        op::resolve_includes rest

and compile ?(show_parse=false) ?(typecheck_program=true) source_file =
  let program = open_and_parse source_file in
  let program' = resolve_includes program in

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