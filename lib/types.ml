
(* All the possible types that Irida can work with *)
type datatype =
  | Generic
  | Int
  | Str
[@@deriving eq, show
  { with_path = false }]

type op =
  | Ident of string
  | PushInt of int
  | PushStr of string
  | Loop of op list
  | Proc of string * bool * datatype list * datatype list * op list
  | Macro of string * op list
  | MacroReplace of string
  | If of op list * op list
  | Inline of string
  | Include of string
  | Alloc of int * string
  | MemWrite of string
  | MemRead of string
[@@deriving show
  { with_path = false }]

type program = op list
[@@deriving show
  { with_path = false }]


(* type memAddr = int
[@@deriving show
  { with_path = false }]

type contextOp =
  { op: op;
    address: int;
    body_size: int;
    operand: memAddr }
[@@deriving show
  { with_path = false }] *)
  
(* type contextProgram = contextOp list
[@@deriving show
  { with_path = false }] *)
  
(* asmOp:
      next instruction = address + body_size *)
