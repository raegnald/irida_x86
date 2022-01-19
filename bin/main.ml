open Irida

open Utils
open Compile

open Stdlib

let () =
  let open Printf in
  let open Command in

  assert Sys.unix;

  let source_file = ref ""
  and output_file = ref ""
  and generate_asm = ref false
  and typecheck_program = ref false
  and assemble_and_link = ref true
  and only_build = ref false
  and show_parsing_result = ref false
  and activate_msgs = ref false in

  Arg.parse
    [ ("-o", Arg.String (fun name -> output_file := name),
        "Output executable name");
      ("-build", Arg.Set only_build,
        "Just build, elsewhere it will also run the executable");
      ("-asm", Arg.Set generate_asm,
        "Keep the assembly file");
      ("-inform", Arg.Set activate_msgs,
        "Give information messages. Silent by default");
      ("-parsed", Arg.Set show_parsing_result,
        "Show the result of parsing");
      ("-no-typecheck", Arg.Set typecheck_program,
        "Compiles unsafe code") ]
    (fun s -> source_file := s)
    "gligan [OPTIONS] <file>.iri\nOPTIONS:";

  try
    Inform.inform_messages !activate_msgs;

    let asm =
      compile ~show_parse:!show_parsing_result
              ~typecheck_program:(not !typecheck_program)
              !source_file in

    (** Filename without extension *)
    let filename = Filename.chop_extension !source_file in
    let basename = Filename.basename filename in
    let asm_filename = filename ^ ".asm" in
    let tmp_asm_filename = sprintf "/tmp/irida/%s.asm" basename in
    let obj_filename = sprintf "/tmp/irida/%s.o" basename in

    exec "mkdir -p /tmp/irida";

    if !generate_asm then begin
      Inform.info ("Assembly dumped into " ^ asm_filename);
      File.write asm_filename asm
    end;

    File.write tmp_asm_filename asm;

    (* If no output exec file name is set *)
    if String.length !output_file = 0 then
      output_file := filename;

    if !assemble_and_link then begin
      let assemble_command =
        sprintf "nasm -felf64 %s" tmp_asm_filename
      and link_command =
        sprintf "gcc -no-pie %s -o %s" obj_filename !output_file in

      Inform.info ("Assembling: " ^ assemble_command);
      exec assemble_command;
      Inform.info ("Linking: " ^ link_command);
      exec link_command;

      if !only_build then
        Inform.success ("Binary executable located at " ^ filename)
      else begin
        sprintf "Running %s" filename |> Inform.info;
        File.add_current_directory_if_implicit filename |> exec
      end
    end

  with
    | Sys_error e -> Inform.fatal e
    | Invalid_argument _ -> Inform.fatal "Not enough arguments"
    | File.No_filename_specified -> Inform.fatal "No filename specified"
    | Failure e -> Inform.fatal (e ^
        ". It is probable that the input file has malformed syntax")
    | Parser.Error -> Inform.fatal "Input file has bad syntax"
    | Typecheck.Typechecking_error e -> Inform.fatal ("Type checking: " ^ e)
    | Command.Cannot_run command -> Inform.fatal ("Cannot run " ^ command)
    | Not_found -> () (* No error in here *)