open Types
open Utils

let procedures = ref []

let populate_procedures_list = function
  | Proc (name, _, _, _, _, body) ->
      procedures := name :: !procedures
  | _ -> ()

let rec check_if_calling_undefined_proc op =
  let check = List.iter check_if_calling_undefined_proc in
  match op with
    | Ident name ->
        if not (List.mem name !procedures) then
          Inform.fatal (Printf.sprintf
            "Calling unbound procedure %s"
            (Inform.to_color name))
    | If (b1, b2) | While (b1, b2) ->
        check b1;
        check b2
    | Macro (_, body) | Loop body
    | Proc (_, _, _, _, _, body) ->
        check body
    | _ -> ()


let preconditions (p: program) =
  List.iter populate_procedures_list p;
  List.iter check_if_calling_undefined_proc p