
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
%token LOOP

%token IF
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


op:
  | i = INT
      { Types.PushInt i }
  | x = IDENT
    { Types.Ident x }
  | s = STR
    { Types.PushStr s }

//   | o1 = op; COLON; o2 = op
//       { o1 o2 }
//     Cool feature
//          instead of `5 3 add`,
//          you could alternatively write
//          `5 add: 3`


//   | BEGIN; o = op;
//       { o }

  | INCLUDE; s = STR
       { Types.Include s }

  | IF; THEN; then_branch = block; ELSE; else_branch = block
      { Types.If (then_branch, else_branch) }

  | PROC; name = IDENT; ops = block
      { Types.Proc (name, ops) }

  | LOOP; ops = block
      { Types.Loop ops }

  | line = INLINE_ASM
      { Types.Inline line }

  ;