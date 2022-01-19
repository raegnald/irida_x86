
open Types
open Utils

exception Typechecking_error of string

let s = Stack.create ()
let procedures = ref (Hashtbl.create 0)

let typecheck_op op =
  let open Stack in
  match op with
    | PushInt _ -> push Int s
    | PushStr _ -> push Str s

    | Ident name ->
        (try
          let inputs, outputs = Hashtbl.find !procedures name in

          List.iter (fun t ->
            let top = pop s in
            if not (equal_datatype t   Generic) &&
               not (equal_datatype top Generic) &&
               not (equal_datatype top t) then
              raise (Typechecking_error (
                Printf.sprintf "Expected %s, instead got %s in procedure %s"
                    (string_of_datatype t) (string_of_datatype top) name))
          ) inputs;

          List.iter (fun t -> push t s) outputs
        with
          | Empty -> raise (Typechecking_error "Insufficient elements on the stack for procedure call") )

    | Proc (name, _, inputs, outputs, _) ->
        Hashtbl.add !procedures name (inputs, outputs)

    | _ -> ()
      (* print_endline ("typechecking: unkown " ^ show_op op) *)

let typecheck program =
  List.iter typecheck_op program;
  if not (Stack.is_empty s) then
    raise (Typechecking_error "The stack contains unconsumed elements")