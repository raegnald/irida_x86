
open Types
open Utils
open Utils.Out
open Templates

let mem_capacity = ref 0


let open_and_parse source_file =
  source_file
    |> File.read_all
    |> Program.parse


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

    | Proc (is_rec, name, ops) ->
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

    | Include f ->
        open_and_parse f |>
        List.iter compile_op



and compile ?(show_parse=false) (source_file) =
  let ops =  open_and_parse source_file in

  if show_parse then
    show_program ops |> print_endline;

  append header;
  List.iter compile_op ops;
  !mem_capacity
    |> string_of_int
    |> footer (!strings) (!allocations)
    |> append;
  get ()