
open Types
open Utils
open Utils.Out
open Templates

let mem_capacity = ref 640_000


let open_and_parse source_file =
  source_file
    |> File.read_all
    |> Program.parse


let procedures = ref (Hashtbl.create ~random:false 0)
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
        (* TODO: *)
        (* 1. Add them to the strings list *)
        (* 2. Replace the string with its unique label *)
        (* Continue... *)
        strings := (i, s) :: !strings;
        "    push str_" ^ string_of_int i |> a;

        ()

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

    | If (then_branch, else_branch) ->
        advance_index ();
        let i = !index in

        (* Comprobation *)
        label (string_of_int i ^ "_if") |> a;
        "    pop rax"       @@
        "    test rax, rax" @@
        "    jz label_" ^ string_of_int i ^ "_else"
        |> a;
        (* Then *)
        List.iter compile_op then_branch;
        jmpOp (string_of_int i ^ "_ifend") |> a;
        (* Else *)
        label (string_of_int i ^ "_else") |> a;
        List.iter compile_op else_branch;
        (* If end *)
        label (string_of_int i ^ "_ifend") |> a

    | Loop ops ->
        advance_index ();
        let i = !index in
        
        "label_loop_" ^ (string_of_int i) ^ ":" |> a;
        List.iter compile_op ops;
        jmpOp ("loop_" ^ (string_of_int i)) |> a

    | Proc (name, ops) ->
        Hashtbl.add !procedures name ops

    | Inline line ->
        (* "    " ^  *)
        line |> a
    
    | Include f ->
        open_and_parse f
          |> List.iter compile_op

    | _ -> ()


and compile ?(show_parse=false) (source_file) =
  let ops =  open_and_parse source_file in

  if show_parse then
    show_program ops |> print_endline;

  append header;
  List.iter compile_op ops;
  !mem_capacity
    |> string_of_int
    |> footer (!strings)
    |> append;
  get ()