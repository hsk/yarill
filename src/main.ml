
let trans input =

  let inp = open_in input in
  let lexbuf = Lexing.from_channel inp in
  let ast = Parser.identifier_sequence Lexer.token lexbuf in
  close_in inp;
  ast

let _ =
  trans Sys.argv.(1)
