
// %token <string> IDENT

%token <int> INT
%token <string> STR
%token <string> IDENT
%token <string> INLINE_ASM

// %token SEMICOLON
%token COLON

%token END

%token INCLUDE

%token PROC
%token REC

%token LOOP
%token THEN
%token ELSE

%token EOF


// Precedence & Associativity
// %nonassoc IN
// %nonassoc ELSE
// %left MINUS
// %left PLUS
// %left ASTERISK

%start <Types.program> prog

%%

prog:
  | o = op; o2 = prog
      { o::o2 }
  | o1 = op; COLON; o2 = op; rest = prog
      { o2::o1::rest }
//   | o = op; COLON; b = block; rest = prog
//       { b @ o::rest }

  | EOF
      { [] }
  ;

block:
  | o = op; o2 = block
      { o::o2 }
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

//   | o1 = op; COLON; o2 = op
//       { o1 o2 }
//     Cool feature [known as "the colon syntax"]
//          instead of `5 3 add`,
//          you could alternatively write
//          `5 add: 3`


//   | BEGIN; o = op;
//       { o }

  | INCLUDE; s = STR
       { Types.Include s }
  | INCLUDE; s = IDENT
       { Types.Include ("/usr/local/irida/libraries/" ^ s ^ ".iri") }
  // TOOD: add rules to parse things such as
  //              INCLUDE; IDENT "std"
  //              INCLUDE; IDENT "http"


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


  | LOOP; ops = block
      { Types.Loop ops }

  | line = INLINE_ASM
      { Types.Inline line }

  ;