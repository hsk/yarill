let test_identifier_sequence expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.identifier_sequence Lexer.token lexbuf in
    if expected <> result
    then
      Printf.printf "error input %S expected %S result %S\n" input expected result;
  with
    | Parsing.Parse_error ->
      Printf.printf "parser error input %S expected %S\n" input expected
  end

let _ =
  Printf.printf "test_identifier_sequence start\n";
  test_identifier_sequence "a" "a";
  test_identifier_sequence "z" "z";
  test_identifier_sequence "A" "A";
  test_identifier_sequence "Z" "Z";
  test_identifier_sequence "_" "_";
  test_identifier_sequence "aa" "aa";
  test_identifier_sequence "zz" "zz";
  test_identifier_sequence "AA" "AA";
  test_identifier_sequence "ZZ" "ZZ";
  test_identifier_sequence "__" "__";
  test_identifier_sequence "a0" "a0";
  test_identifier_sequence "z0" "z0";
  test_identifier_sequence "A0" "A0";
  test_identifier_sequence "Z0" "Z0";
  test_identifier_sequence "_0" "_0";
  test_identifier_sequence "a9" "a9";
  test_identifier_sequence "z9" "z9";
  test_identifier_sequence "A9" "A9";
  test_identifier_sequence "Z9" "Z9";
  test_identifier_sequence "_9" "_9";

  test_identifier_sequence "==" "op ==";
  test_identifier_sequence "!=" "op !=";
  test_identifier_sequence "||" "op ||";
  test_identifier_sequence "&&" "op &&"; 
  test_identifier_sequence "<=" "op <=";
  test_identifier_sequence ">=" "op >=";
  test_identifier_sequence "<<" "op <<";
  test_identifier_sequence ">>" "op >>";
  test_identifier_sequence "()" "op ()";
  test_identifier_sequence "[]" "op []";
  test_identifier_sequence "|" "op |";
  test_identifier_sequence "^" "op ^";
  test_identifier_sequence "&" "op &";
  test_identifier_sequence "+" "op +";
  test_identifier_sequence "-" "op -";
  test_identifier_sequence "*" "op *";
  test_identifier_sequence "/" "op /";
  test_identifier_sequence "%" "op %";
  test_identifier_sequence "<" "op <";
  test_identifier_sequence ">" "op >";
  test_identifier_sequence "=" "op =";

  test_identifier_sequence "pre==" "op pre ==";
  test_identifier_sequence "pre!=" "op pre !=";
  test_identifier_sequence "pre||" "op pre ||";
  test_identifier_sequence "pre&&" "op pre &&"; 
  test_identifier_sequence "pre<=" "op pre <=";
  test_identifier_sequence "pre>=" "op pre >=";
  test_identifier_sequence "pre<<" "op pre <<";
  test_identifier_sequence "pre>>" "op pre >>";
  test_identifier_sequence "pre()" "op pre ()";
  test_identifier_sequence "pre[]" "op pre []";
  test_identifier_sequence "pre|" "op pre |";
  test_identifier_sequence "pre^" "op pre ^";
  test_identifier_sequence "pre&" "op pre &";
  test_identifier_sequence "pre+" "op pre +";
  test_identifier_sequence "pre-" "op pre -";
  test_identifier_sequence "pre*" "op pre *";
  test_identifier_sequence "pre/" "op pre /";
  test_identifier_sequence "pre%" "op pre %";
  test_identifier_sequence "pre<" "op pre <";
  test_identifier_sequence "pre>" "op pre >";
  test_identifier_sequence "pre=" "op pre =";

  test_identifier_sequence "post==" "op post ==";
  test_identifier_sequence "post!=" "op post !=";
  test_identifier_sequence "post||" "op post ||";
  test_identifier_sequence "post&&" "op post &&"; 
  test_identifier_sequence "post<=" "op post <=";
  test_identifier_sequence "post>=" "op post >=";
  test_identifier_sequence "post<<" "op post <<";
  test_identifier_sequence "post>>" "op post >>";
  test_identifier_sequence "post()" "op post ()";
  test_identifier_sequence "post[]" "op post []";
  test_identifier_sequence "post|" "op post |";
  test_identifier_sequence "post^" "op post ^";
  test_identifier_sequence "post&" "op post &";
  test_identifier_sequence "post+" "op post +";
  test_identifier_sequence "post-" "op post -";
  test_identifier_sequence "post*" "op post *";
  test_identifier_sequence "post/" "op post /";
  test_identifier_sequence "post%" "op post %";
  test_identifier_sequence "post<" "op post <";
  test_identifier_sequence "post>" "op post >";
  test_identifier_sequence "post=" "op post =";

  Printf.printf "test_identifier_sequence end\n";
