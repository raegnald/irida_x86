
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
%token THEN
%token ELSE

%token EOF


%start <Types.program> prog

%%

prog:
  | o1 = op; COLON; o2 = op; r = prog
      { o2 :: o1 :: r }
  | o1 = op; PERCENT_SIGN; o2 = semicolon_block; r = prog
      { o2 @ o1 :: r }
  // Ternary operator-like syntax support
  | INTERROGATION; then_op = op; COLON; else_op = op; SEMICOLON; r = prog
      { (Types.If ([then_op], [else_op])) :: r }

  | o = op; o2 = prog
      { o::o2 }
  | EOF
      { [] }
  ;

block:
  | o = op; o2 = block
      { o::o2 }
  | o1 = op; COLON; o2 = op; r = block
      { o2 :: o1 :: r }
  | o1 = op; PERCENT_SIGN; o2 = semicolon_block; r = block
      { o2 @ o1 :: r }
  | INTERROGATION; then_op = op; COLON; else_op = op; SEMICOLON; r = block
      { (Types.If ([then_op], [else_op])) :: r }
  | END
      { [] }
  ;

semicolon_block:
  | o = op; o2 = semicolon_block
      { o::o2 }
  | o1 = op; COLON; o2 = op; r = semicolon_block
      { o2 :: o1 :: r }
  | INTERROGATION; then_op = op; COLON; else_op = op; SEMICOLON; r = semicolon_block
      { (Types.If ([then_op], [else_op])) :: r }
  | SEMICOLON
      { [] }

then_block:
  | o = op; o2 = then_block
      { o::o2 }
  | o1 = op; COLON; o2 = op; r = then_block
      { o2 :: o1 :: r }
  | o1 = op; PERCENT_SIGN; o2 = semicolon_block; r = then_block
      { o2 @ o1 :: r }
  | INTERROGATION; then_op = op; COLON; else_op = op; SEMICOLON; r = then_block
      { (Types.If ([then_op], [else_op])) :: r }
  | ELSE
      { [] }
  ;


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

  | ALLOC; i = INT; x = IDENT
        { Types.Alloc (i, x) }

  | EXCLAMATION; x = IDENT
        { Types.MemWrite x }
  | AT_SIGN; x = IDENT
        { Types.MemRead x }



  // .. then .. end
  | THEN; then_branch = block
      { Types.If (then_branch, []) }
  // .. then .. else .. end  definitions
  | THEN; then_branch = then_block; else_branch = block
      { Types.If (then_branch, else_branch) }


  // Non-recursive procedure definitions
  | PROC; name = IDENT; ops = block
      { Types.Proc (false, name, ops) }
  // Recursive procedures definitions
  | PROC; REC; name = IDENT; ops = block
      { Types.Proc (true, name, ops) }

  // Macro definitions
  | MACRO; name = IDENT; ops = block
      { Types.Macro (name, ops) }


  | LOOP; ops = block
      { Types.Loop ops }

  | line = INLINE_ASM
      { Types.Inline line }

  ;