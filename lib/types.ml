
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
  | While of op list * op list
  | Proc of string * bool * bool * datatype list * datatype list *
            op list (* 1st bool: unsafe, 2nd: rec *)
  | Macro of string * op list
  | MacroReplace of string
  | If of op list * op list
  | Inline of string
  | Include of string
  | Alloc of datatype * string
  | MemWrite of string
  | MemRead of string
[@@deriving show
  { with_path = false }]

type program = op list
[@@deriving show
  { with_path = false }]
