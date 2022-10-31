open Types
open Utils

let rec check_macro_recursiveness ?(cannot_be="") = function
  | MacroReplace name ->
      if String.equal name cannot_be then
        Inform.fatal (Printf.sprintf
          "Macros cannot call themselves, %s is used recursively"
          (Inform.to_color name))
  | Macro (name, body) ->
      List.iter (check_macro_recursiveness ~cannot_be:name) body
  | _ -> ()


let preconditions (p: program) =
  List.iter check_macro_recursiveness p