
{
  open Parser

  (* Inline instructions list *)
  let instructions = ref ""

  (* Keywords *)
  let create_hashtable size init =
    let tbl = Hashtbl.create size in
    List.iter (fun (key, data) -> Hashtbl.add tbl key data) init;
    tbl

  let keyword_table = 
    create_hashtable 10 [
      ("end", END);

      ("include", INCLUDE);

      ("proc", PROC);
      ("rec", REC);
      ("macro", MACRO);

      ("alloc", ALLOC);

      ("loop", LOOP);

      ("then", THEN);
      ("else", ELSE);

      ("true", INT 1);
      ("false", INT 0);
    ]

    (* String literals *)
    let string_buff = Buffer.create 256
    let char_for_backslash = function
      | 'n' -> '\010'
      | 'r' -> '\013'
      | 'b' -> '\008'
      | 't' -> '\009'
      | c   -> c
}

(* Numbers *)
let digit = ['0'-'9']
let int = '-'? digit ['0'-'9' '_']*

(* Whitespace *)
let ws = [' ' '\t' '\r' '\n']

(* Identifiers *)
let letter = ['a'-'z' 'A'-'Z']
let ident = letter (letter | digit | '_')*

(* Escapes for string literals *)
let backslash_escapes =
  ['\\' '\'' '"' 'n' 't' 'b' 'r' ' ']


rule read = parse
  | ws+
      { read lexbuf }
  | "//"
      { comment lexbuf }
  | "|"
      { instructions := "";
        inline lexbuf;
        INLINE_ASM (String.trim !instructions) }
  | ":"
      { COLON }
  | "!"
      { EXCLAMATION }
  | "@"
      { AT_SIGN }

  | int
      { INT (Lexing.lexeme lexbuf
              |> int_of_string) }

  | '"'
      { Buffer.clear string_buff;
        string lexbuf;
        STR (Buffer.contents string_buff) }

  | "$" ident as m
      { MACRO_REPLACE m }

  | ident as word
      { try
          let token = Hashtbl.find keyword_table word in
          token
        with Not_found ->
          IDENT word }

  | eof
      { EOF }

and comment = parse
  | "\n" | eof
      { read lexbuf }
  | _
      { comment lexbuf }

and inline = parse
  | "\n" | eof
      { }
  | _ as c
      { instructions := !instructions ^ (String.make 1 c);
        inline lexbuf }

and string = parse
  | '"'
      { () }
  | '\\' (backslash_escapes as c)
      { Buffer.add_char string_buff (char_for_backslash c);
        string lexbuf }
  | _ as c
      { Buffer.add_char string_buff c;
        string lexbuf }