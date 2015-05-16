{
open Parser

let float_of_string s =
    let len = String.length s in
    match String.get s (len - 1) with
    | 'f' | 'F' | 'l' | 'L' -> float_of_string (String.sub s 0 (len - 1))
    | _ -> float_of_string s

let buf = ref ""

}

let brank = [' ' '\t' '\n' '\r']
let nondigit_charset = ['A' - 'Z' 'a' - 'z' '_']
let digit_charset = ['0' - '9']
let hex_charset = ['0' - '9' 'A' - 'Z' 'a' - 'z']
let oct_charset = ['0' - '7']
let bin_charset = ['0' - '1']
let sign = ['+' '-']
let exponent_part = ['e' 'E'] sign? digit_charset+
let float_type = ['f' 'l' 'F' 'L']
rule token = parse
| brank+
    { token lexbuf }
| "/*" _ * "*/"
    { token lexbuf }
| "//" [^ '\r' '\n']* ('\r' | '\n')
    { token lexbuf }
| "op"
    { OP }
| "pre"
    { PRE }
| "post"
    { POST }
| "true"
    { TRUE }
| "false"
    { FALSE }
| "val"
    { VAL }
| "ref"
    { REF }
| "onlymeta"
    { ONLYMETA }
| "meta"
    { META }
| "intrinsic"
    { INTRINSIC }
| "override"
    { OVERRIDE }
| "while"
    { WHILE }
| "if"
    { IF }
| "else"
    { ELSE }
| "return"
    { RETURN }
| "def"
    { DEF }
| "extern"
    { EXTERN }
| "import"
    { IMPORT }
| "class" 
    { CLASS }
| "virtual"
    { VIRTUAL }

| digit_charset+ '.' digit_charset* exponent_part? float_type? as f { FLOAT_LITERAL(float_of_string f) }
| '.' digit_charset+ as f { FLOAT_LITERAL(float_of_string f) }
| digit_charset+ exponent_part float_type? as f { FLOAT_LITERAL(float_of_string f) }
| digit_charset+ float_type as f { FLOAT_LITERAL(float_of_string f) }
| '-'? digit_charset (digit_charset | '_')* as i { INTEGER_LITERAL (int_of_string i) }
| '-'? ("0x" | "0X") hex_charset (hex_charset | '_')* as i { INTEGER_LITERAL (int_of_string i) }
| '-'? ("0o" | "0O") oct_charset (oct_charset | '_')* as i { INTEGER_LITERAL (int_of_string i) }
| '-'? ("0b" | "0B") bin_charset (bin_charset | '_')* as i { INTEGER_LITERAL (int_of_string i) }
| eof
    { EOF }
| "=="
    { EQ }
| "!="
    { NE }
| "||"
    { LOR }
| "&&"
    { LAND }
| "<="
    { LE }
| ">="
    { GE }
| "<<"
    { LSHIFT }
| ">>"
    { RSHIFT }
| "=>"
    { ARROW }
| '('
    { LPAREN }
| ')'
    { RPAREN }
| '['
    { LBRACKET }
| ']'
    { RBRACKET }
| '|'
    { OR }
| '^'
    { XOR }
| '&'
    { AND }
| '+'
    { ADD }
| '-'
    { SUB }
| '*'
    { MUL }
| '/'
    { DIV }
| '%'
    { REM }
| '<'
    { LT }
| '>'
    { GT }
| '='
    { ASSIGN }
| ','
    { COMMA }
| '.'
    { DOT }
| '{'
    { LBRACE }
| '}'
    { RBRACE }
| '!'
    { NOT }
| ':'
    { COLON }
| ';'
    { SEMI }
| '\\'
    { BACKSLASH }

| nondigit_charset (nondigit_charset | digit_charset)* as s
    { NORMAL_IDENTFIRE_SEQUENCE s }

| '"' { buf := ""; strings lexbuf }
| _
    { failwith
      (Printf.sprintf "unknown token %s near characters %d-%d"
        (Lexing.lexeme lexbuf)
        (Lexing.lexeme_start lexbuf)
        (Lexing.lexeme_end lexbuf)) }

and strings = parse
| "\\\\" { buf := !buf ^ "\\" ; strings lexbuf }
| "\\\"" { buf := !buf ^ "\"" ; strings lexbuf }
| "\\\'" { buf := !buf ^ "'" ; strings lexbuf }
| "\\n"  { buf := !buf ^ "\n" ; strings lexbuf }
| "\\r"  { buf := !buf ^ "\r" ; strings lexbuf }
| "\\t"  { buf := !buf ^ "\t" ; strings lexbuf }
| "\\b"  { buf := !buf ^ "\b" ; strings lexbuf }
| "\\ "  { buf := !buf ^ " " ; strings lexbuf }
| '\\' (oct_charset oct_charset oct_charset as s)
    { buf := !buf ^ (String.make 1 (Char.chr(int_of_string(s)))); strings lexbuf }
| "\\x" (hex_charset hex_charset as s)
    { buf := !buf ^ (String.make 1 (Char.chr(int_of_string("0x" ^ s)))); strings lexbuf }
| '"'
    { STRING_LITERAL_SEQUENCE !buf }
| eof
    { Format.eprintf "warning: unterminated string@." ; STRING_LITERAL_SEQUENCE !buf}
| _
    { buf := !buf ^ (Lexing.lexeme lexbuf); strings lexbuf }
