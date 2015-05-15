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
  | ELambda of
    (e * a * (e option * e option) option) list option *
    (string * (e option * (e option * e option))) list *
    a list *
    e option *
    s list
and a =
  | AOnlymeta
  | AMeta
  | AIntrinsic
  | AOverride
  | ADefault
  | AExtern
and s =
  | SBlock of s list
  | SVariableDeclaration of (string * (e * a list * (e option * e option)))
  | SWhile of e * s
  | SIf of e * s * s
  | SEmpty
  | SReturn of e
  | SExpression of e
[@@deriving show]

type c =
  | CEmpty
  | CFunctionDefinition of
    (e * a * (e option * e option) option) list option *
    e *
    (string * (e option * (e option * e option))) list *
    a list  *
    (e * e) list *
    e option *
    s list
  | CVirtualFunctionDefinition of
    e *
    (string * (e option * (e option * e option))) list *
    a list  *
    e option *
    s list
  | CVariableDeclaration of
    (string * (e * a list * (e option * e option)))
[@@deriving show]

type ts =
  | TSFunctionDefinition of
    (e * a * (e option * e option) option) list option *
    e *
    (string * (e option * (e option * e option))) list *
    a list *
    e option *
    s list
  | TSExternFunctionDeclaration of
    (e * a * (e option * e option) option) list option *
    e *
    (string * (e option * (e option * e option))) list *
    a list *
    e *
    string
  | TSExternClassDeclaration of
    (e * a * (e option * e option) option) list option *
    e *
    a list *
    string
  | TSEmpty
  | TSExpression of s
  | TSImport of string list
  | TSClassDefinition of 
    (e * a * (e option * e option) option) list option *
    e *
    e option *
    e list *
    a list *
    c list
[@@deriving show]

type program = ts list
[@@deriving show]

