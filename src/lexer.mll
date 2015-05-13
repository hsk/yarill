{
open Parser
}

let digit_charset = ['0' - '9']
let hex_charset = ['0' - '9' 'A' - 'Z' 'a' - 'z']
let oct_charset = ['0' - '7']
let bin_charset = ['0' - '1']
let nondigit_charset = ['A' - 'Z' 'a' - 'z' '_']
let brank = [' ' '\t' '\n' '\r']

rule token = parse
| brank+
    { token lexbuf }
| "/*" _ * "*/"
    { token lexbuf }
| "//" [^ '\r' '\n'] ('\r' | '\n')
    { token lexbuf }
| "op"
    { OP }
| "pre"
    { PRE }
| "post"
    { POST }
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
| nondigit_charset (nondigit_charset | digit_charset)* as s
    { NORMAL_IDENTFIRE_SEQUENCE s }
| _
    { failwith
      (Printf.sprintf "unknown token %s near characters %d-%d"
        (Lexing.lexeme lexbuf)
        (Lexing.lexeme_start lexbuf)
        (Lexing.lexeme_end lexbuf)) }
