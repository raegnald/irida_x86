
open Types
open Utils

exception Typechecking_error of string

let s = Stack.create ()
let procedures = ref (Hashtbl.create 0)
let allocations = ref (Hashtbl.create 0)

let typecheck_op op =
  let open Stack in
  let open Printf in
  match op with
    | PushInt _ -> push Int s
    | PushStr _ -> push Str s

    | MemWrite name ->
      (try
        let t = Hashtbl.find !allocations name in
        let top = pop s in
        if not (equal_datatype t   Generic) &&
           not (equal_datatype top Generic) &&
           not (equal_datatype t top) then
          raise (Typechecking_error (sprintf
            "Writing %s instead of %s to memory %s"
            (string_of_datatype top) (string_of_datatype t) name))
      with
        | Empty -> raise (Typechecking_error
            "Insufficient elements in the stack, cannot write to memory") )

    | MemRead name ->
        let t = Hashtbl.find !allocations name in
        push t s

    | Ident name ->
        (try
          let inputs, outputs = Hashtbl.find !procedures name in

          List.iter (fun t ->
            let top = pop s in
            if not (equal_datatype t   Generic) &&
               not (equal_datatype top Generic) &&
               not (equal_datatype top t) then
              raise (Typechecking_error (
                sprintf "Defintion expects %s, passed %s in %s call"
                    (string_of_datatype t) (string_of_datatype top) name))
          ) inputs;

          List.iter (fun t -> push t s) outputs
        with
          | Empty -> raise (Typechecking_error
              "Insufficient elements in the stack, canot call procedure") )

    | Proc (name, _, inputs, outputs, _) ->
        Hashtbl.add !procedures name (inputs, outputs)

    | Alloc (data_t, name) ->
        Hashtbl.add !allocations name data_t

    | _ -> ()
      (* print_endline ("typechecking: unkown " ^ show_op op) *)

let typecheck program =
  List.iter typecheck_op program;
  if not (Stack.is_empty s) then
    raise (Typechecking_error "The stack contains unconsumed elements")