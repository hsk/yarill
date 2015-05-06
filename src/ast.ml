type t =
  | Ty of string

type e =
  | EInt of int
  | EString of string
  | EVar of string

type d = 
  | DFun of string * (string * t) list * t * e list
