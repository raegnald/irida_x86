
open Types

module Out = struct
  let refbuf = ref ""
  let get () = !refbuf
  let append str =
    (* print_endline str *)
    refbuf := Printf.sprintf "%s\n%s" !refbuf str
end

module Program = struct
  let parse (source: string): op list =
    let lexbuf = Lexing.from_string source in
    let ast = Parser.prog Lexer.read lexbuf in
    ast
end

(** [comment s] takes a string [s] and returns that same string but adapted as
    an assembly language comment *)
let comment s =
  String.split_on_char '\n' s |> 
  List.fold_left (fun a b -> a ^ "\n; " ^ b) ""


module File = struct
  exception No_filename_specified

  let check_empty filename =
    if filename = "" then
      raise No_filename_specified

  let read_all filename =
    check_empty filename;
    let ch = open_in filename in
    let contents =
      in_channel_length ch |>
      really_input_string ch in
    close_in ch;
    contents

  let write filename contents =
    check_empty filename;
    let oc = open_out filename in
    Printf.fprintf oc "%s\n" contents;
    close_out oc

  (** [add_current_directory_if_implicit filename] prepens `./` to filename if it
      doesn't contain an explicit reference to the working directory  *)
  let add_current_directory_if_implicit filename =
    if Filename.is_implicit filename then
      "./" ^ filename
    else filename
end


(** Inform shows messages to users *)
module Inform = struct
  let red = "\027[31m"
  let green = "\027[32m"
  let yellow = "\027[33m"
  let blue = "\027[34m"
  let magenta = "\027[35m"
  let cyan = "\027[36m"

  let inform = ref true
  let inform_messages b =
    inform := b

  let message ?(title="Message") ?(color=blue) =
    Printf.eprintf "%s%15s\027[0m %s\n" color title

  let info msg =
    if !inform then
      message ~title:"Info" msg

  let success msg =
    if !inform then
      message ~title:"Success" ~color:green msg

  let error ?(title="Error") ?(halt=false) msg =
    message ~title:title ~color:red msg;
    if halt then exit 1

  let fatal ?(title="Fatal Error") msg =
    message ~title:title ~color:red msg;
    exit 1

end

module Command = struct
  exception Cannot_run of string
  open Unix
  let exec (command: string) =
    let status_code = system command in
    match status_code with
      | WEXITED _ -> ()
      | _ -> raise (Cannot_run command)
end

let open_and_parse source_file =
  source_file
    |> File.read_all
    |> Program.parse

let string_of_datatype dt =
    show_datatype dt |> String.lowercase_ascii