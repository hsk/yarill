type e =
  | EInt of int
  | EFloat of float
  | EBool of bool
  | EString of string
  | EIdentifier of string * bool
  | EArray of e list
  | EBin of e * string * e
  | EUnary of string * e
  | ESubscrpting of e * e option
  | ECall of e * e list
  | ETemplateInstance of string * e list * bool
  | EElementSelector of e * e
[@@deriving show]

type a =
  | AOnlymeta
  | AMeta
  | AIntrinsic
  | AOverride
  | ADefault
[@@deriving show]
