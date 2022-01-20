
open Types

module Out = struct
  let refbuf = ref ""
  let get () = !refbuf
  let append str =
    (* print_endline str *)
    refbuf := Printf.sprintf "%s\n%s" !refbuf str
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

module TermColor = struct
  let reset = "\027[0m"
  let red = "\027[31m"
  let green = "\027[32m"
  let yellow = "\027[33m"
  let blue = "\027[34m"
  let magenta = "\027[35m"
  let cyan = "\027[36m"
end

(** Inform shows messages to users *)
module Inform = struct
  open Printf
  open TermColor

  let inform = ref true
  let inform_messages b =
    inform := b

  let to_color ?(color=blue) text =
    sprintf "%s%s%s" color text reset

  let message ?(title="Message") ?(color=blue) ?(channel=stdout) =
    fprintf channel "%s%15s%s %s\n" color title reset

  let info msg =
    if !inform then
      message ~title:"Info" msg

  let success msg =
    if !inform then
      message ~title:"Success" ~color:green msg

  let error ?(title="Error") ?(halt=false) msg =
    message ~title:title ~color:red ~channel:stderr msg;
    if halt then exit 1

  let fatal ?(title="Fatal") msg =
    message ~title:title ~color:red ~channel:stderr msg;
    exit 1

end


module Program = struct
  open Printf

  let print_position lexbuf filename =
    let open Lexing in
    let pos = lexbuf.lex_curr_p in
    sprintf "%s:%d:%d"
      filename pos.pos_lnum
      (pos.pos_cnum - pos.pos_bol + 1)

  let parse source filename =
    let lexbuf = Lexing.from_string source in
    try Parser.prog Lexer.read lexbuf with
      | Lexer.UnknownChar _c ->
          Inform.fatal ("Unknown character in " ^ print_position lexbuf filename)
      | Parser.Error ->
          Inform.fatal ("Syntactic error in " ^ print_position lexbuf filename)

  let open_and_parse source_filename =
    parse (File.read_all source_filename) source_filename
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

let string_of_datatype dt =
    show_datatype dt |> String.lowercase_ascii