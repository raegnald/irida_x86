
// %token <string> IDENT

%token <int> INT
%token <string> STR
%token <string> IDENT
%token <string> INLINE_ASM
%token <string> MACRO_REPLACE

%token COLON
%token SEMICOLON
%token PERCENT_SIGN
%token EXCLAMATION
%token INTERROGATION
%token AT_SIGN

%token END

%token INCLUDE

%token ALLOC

%token PROC
%token REC

%token MACRO

%token LOOP
%token WHILE
%token DO
%token THEN
%token ELSE

%token LPAREN
%token RPAREN

%token COMMA

%token TILDE
%token INTT
%token STRT

%token EOF


%start <Types.program> prog

%%

prog:
  | p = block(EOF) { p }
  ;

block(fin):
  | o = op; o2 = block(fin)
      { o::o2 }
  | o1 = op; COLON; o2 = op; r = block(fin)
      { o2 :: o1 :: r }
  | o1 = op; PERCENT_SIGN; o2 = block(SEMICOLON); r = block(fin)
      { o2 @ o1 :: r }
  | INTERROGATION; then_op = op; COLON; else_op = op; SEMICOLON; r = block(fin)
      { (Types.If ([then_op], [else_op])) :: r }
  | fin
      { [] }
  ;

datatype:
  | TILDE { Types.Generic }
  | INTT { Types.Int }
  | STRT { Types.Str }

comma_sep_type_lst:
  | t = datatype; COMMA; rest = comma_sep_type_lst
      { t::rest }
  | t = datatype; RPAREN
      { [t] }
  | RPAREN
      { [] }

proc_type_list:
  | LPAREN; l = comma_sep_type_lst
      { l }
  | t = datatype
      { [t] }

op:
  | i = INT
      { Types.PushInt i }
  | x = IDENT
      { Types.Ident x }
  | s = STR
      { Types.PushStr s }
  | m = MACRO_REPLACE
      { Types.MacroReplace m }


  | INCLUDE; s = STR
      { Types.Include s }
  | INCLUDE; s = IDENT
      { Types.Include ("/usr/local/irida/libraries/" ^ s ^ ".iri") }

  | ALLOC; i = datatype; x = IDENT
      { Types.Alloc (i, x) }

  | EXCLAMATION; x = IDENT
      { Types.MemWrite x }
  | AT_SIGN; x = IDENT
      { Types.MemRead x }



  // .. then .. end
  | THEN; then_branch = block(END)
      { Types.If (then_branch, []) }
  // .. then .. else .. end
  | THEN; then_branch = block(ELSE); else_branch = block(END)
      { Types.If (then_branch, else_branch) }

  | WHILE; cond = block(DO); loop_body = block(END)
      { Types.While (cond, loop_body) }

  // Non-recursive procedure definitions
  | PROC; name = IDENT;
    inputs = proc_type_list; outputs = proc_type_list;
    ops = block(END)
      { Types.Proc (name, false, inputs, outputs, ops) }


  // Recursive procedures definitions
  | PROC; REC name = IDENT;
    inputs = proc_type_list; outputs = proc_type_list;
    ops = block(END)
      { Types.Proc (name, true, inputs, outputs, ops) }

  // Macro definitions
  | MACRO; name = IDENT; ops = block(END)
      { Types.Macro (name, ops) }


  | LOOP; ops = block(END)
      { Types.Loop ops }

  | line = INLINE_ASM
      { Types.Inline line }

  ;