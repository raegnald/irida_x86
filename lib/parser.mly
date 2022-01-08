
// %token <string> IDENT

%token <int> INT
%token <string> STR
%token <string> IDENT
%token <string> INLINE_ASM
%token <string> MACRO_REPLACE

// %token SEMICOLON
%token COLON
%token EXCLAMATION
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
  | o = op; o2 = prog
      { o::o2 }
  | o1 = op; COLON; o2 = op; rest = prog
      { o2::o1::rest }
  | EOF
      { [] }
  ;

block:
  | o = op; o2 = block
      { o::o2 }
  | o1 = op; COLON; o2 = op; rest = block
      { o2::o1::rest }
  | END
      { [] }
  ;

then_block:
  | o = op; o2 = then_block
      { o::o2 }
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

//   | o1 = op; COLON; o2 = op
//       { o1 o2 }
//     Cool feature [known as "the colon syntax"]
//          instead of `5 3 add`,
//          you could alternatively write
//          `5 add: 3`

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