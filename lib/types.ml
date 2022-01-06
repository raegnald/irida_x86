
type op =
  | Ident of string
  | PushInt of int
  | PushStr of string       (* The string itself *)
  | StrLoc of int           (* The location to a string *)
  | Loop of op list
  | Proc of string * op list
  | If of op list * op list
  | Inline of string
  | Include of string
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
