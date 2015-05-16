
let trans input =

  let inp = open_in input in
  let lexbuf = Lexing.from_channel inp in
  let ast = Parser.program Lexer.token lexbuf in
  close_in inp;
  Format.printf "%a\n" Ast.pp_program ast

let _ =
  trans Sys.argv.(1)
