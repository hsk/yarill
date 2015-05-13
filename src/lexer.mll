{
open Parser
}

let digit_charset = ['0' - '9']
let nondigit_charset = ['A' - 'Z' 'a'-'z' '_']
let brank = [' ' '\t' '\n' '\r']

rule token = parse
| brank+
    { token lexbuf }
| "/*" _ * "*/"
    { token lexbuf }
| "//" [^ '\r' '\n'] ('\r' | '\n')
    { token lexbuf }
| nondigit_charset (nondigit_charset | digit_charset)* as s
    { NORMAL_IDENTFIRE_SEQUENCE s }
| "op"
    { OP }
| "pre"
    { PRE }
| "post"
    { POST }
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
| _
    { failwith
      (Printf.sprintf "unknown token %s near characters %d-%d"
        (Lexing.lexeme lexbuf)
        (Lexing.lexeme_start lexbuf)
        (Lexing.lexeme_end lexbuf)) }
