
open Types
open Utils

exception Typechecking_error of string

let s = Stack.create ()
let procedures = ref (Hashtbl.create 0)
let allocations = ref (Hashtbl.create 0)
let macros = ref (Hashtbl.create 0)


let check_type_consistency t stack_top err_msg =
  if not (equal_datatype t         Generic) &&
     not (equal_datatype stack_top Generic) &&
     not (equal_datatype t stack_top) then
    raise (Typechecking_error err_msg)


let populate_blocks = function
  | Proc (name, is_unsafe, _, inputs, outputs, body) ->
      Hashtbl.add !procedures name (inputs, is_unsafe, body, outputs)

  | Macro (name, body) ->
      Hashtbl.add !macros ("$" ^ name) body

  | Alloc (data_t, name) ->
      Hashtbl.add !allocations name data_t

  | _ -> ()


let rec typecheck_op ?(stack=s) = function
  | PushInt _ -> Stack.push Int s
  | PushStr _ -> Stack.push Str s

  | MemWrite name ->
      let t = Hashtbl.find !allocations name in
      let top = Stack.pop s in
      check_type_consistency t top
        (Printf.sprintf
        "Writing %s instead of %s to memory %s"
        (string_of_datatype top) (string_of_datatype t) name)

  | MemRead name ->
      let t = Hashtbl.find !allocations name in
      Stack.push t s

  | Ident name ->
      let open Stack in
      let inputs, unsafe, body, outputs = Hashtbl.find !procedures name in

      List.iter (fun t ->
        let top = pop s in
        check_type_consistency t top
          (Printf.sprintf
            "%s expects %s but passed %s" (name |> Inform.to_color)
            (string_of_datatype t |> Inform.to_color ~color:TermColor.red)
            (string_of_datatype top |> Inform.to_color ~color:TermColor.red)) ) inputs;

      if not unsafe then begin
        let len_before_checking = Stack.length s in
        List.iter (fun t -> push t s) inputs;
        List.iter typecheck_op body;
        let len_after_checking = Stack.length s in

        let out_len = len_after_checking - len_before_checking in
        if out_len != (List.length outputs) then begin
          raise (Typechecking_error (Printf.sprintf
            "In procedure definition, %s is returning %d elements but it should return %d"
            (name |> Inform.to_color) out_len (List.length outputs) ));
        end;

        List.iter (fun t ->
          let top = pop s in
          check_type_consistency t top
            (Printf.sprintf
            "In procedure definition, %s is returning a different amount of %d elements"
            (name |> Inform.to_color) (List.length outputs)) ) outputs;

      end;

      List.iter (fun t -> Stack.push t s) outputs

  | MacroReplace name ->
      let body = Hashtbl.find !macros name in
      List.iter typecheck_op body

  | _ -> ()


let typecheck (p: program) =
  List.iter populate_blocks p;
  List.iter (fun o -> typecheck_op o) p;

  if not (Stack.is_empty s) then
    raise (Typechecking_error "The stack contains unconsumed elements")