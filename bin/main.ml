open Irida

open Utils
open Compile

open Stdlib

let () =
  let open Printf in
  let open Command in

  let source_file = ref ""
  and generate_asm = ref false
  and assemble_and_link = ref true
  and only_build = ref false
  and show_parsing_result = ref false
  and activate_msgs = ref false in

  Arg.parse
    [ ("-build", Arg.Set only_build,
        "Just build, elsewhere it will also run the executable");
      ("-asm", Arg.Set generate_asm,
        "Keep the assembly file");
      ("-inform", Arg.Set activate_msgs,
        "Give information messages. Silent by default");
      ("-parsed", Arg.Set show_parsing_result,
        "Show the result of parsing") ]
    (fun s -> source_file := s)
    "gligan [OPTIONS] <file>.iri\nOPTIONS:";

  try
    Inform.inform_messages !activate_msgs;


    let asm = compile ~show_parse:!show_parsing_result (!source_file) in

    (** Filename without extension *)
    let filename = Filename.chop_extension !source_file in
    let basename = Filename.basename filename in
    let asm_filename = filename ^ ".asm" in
    let tmp_asm_filename = sprintf "/tmp/irida/%s.asm" basename in
    let obj_filename = sprintf "/tmp/irida/%s.o" basename in

    exec "mkdir -p /tmp/irida";

    if !generate_asm then
      sprintf "Assembly dumped into %s" asm_filename
        |> Inform.info;
      File.write asm_filename asm;

    File.write tmp_asm_filename asm;

    if !assemble_and_link then begin
      let assemble_command =
        sprintf "nasm -felf64 %s" tmp_asm_filename
      and link_command =
        sprintf "ld %s -o %s" obj_filename filename in

      sprintf "Assembling: %s" assemble_command |> Inform.info;
      exec assemble_command;
      sprintf "Linking: %s" link_command |> Inform.info;
      exec link_command;
      
      if !only_build then
        sprintf "Binary executable located at %s" filename
          |> Inform.success
      else begin
        sprintf "Running %s" filename |> Inform.info;
        exec filename
      end
    end

  with
    | Sys_error e -> Inform.fatal e
    | Invalid_argument _ -> Inform.fatal "Not enough arguments"
    | File.No_filename_specified -> Inform.fatal "No filename specified"
    | Failure e -> Inform.fatal (e ^
        ". It is probable that the input file has malformed syntax")
    | Parser.Error -> Inform.fatal "Input file has bad syntax" 
    | Command.Cannot_run command -> Inform.fatal ("Cannot run " ^ command)
    | Not_found -> () (* No error in here *)