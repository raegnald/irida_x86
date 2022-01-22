open Types
open Utils

let rec check_if_macro_calls_itself ?(cannot_be="") = function
  | MacroReplace name ->
      if String.equal name ("$" ^ cannot_be) then
        Inform.fatal (Printf.sprintf
          "Macros cannot call themselves, %s is used recursively"
          (Inform.to_color name))
  | Macro (name, body) ->
      List.iter (check_if_macro_calls_itself ~cannot_be:name) body
  | _ -> ()


let preconditions (p: program) =
  List.iter check_if_macro_calls_itself p