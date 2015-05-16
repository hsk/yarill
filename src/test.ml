open Ast

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

let test_integer_literal expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.integer_literal Lexer.token lexbuf in
    if expected <> result
    then
      Printf.printf "error input %S expected %d result %d\n" input expected result;
  with
    | Parsing.Parse_error ->
      Printf.printf "parser error input %S expected %d\n" input expected
  end

let test_float_literal expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.float_literal Lexer.token lexbuf in
    if expected <> result
    then
      Printf.printf "error input %S expected %f result %f\n" input expected result;
  with
    | Parsing.Parse_error ->
      Printf.printf "parser error input %S expected %f\n" input expected
    | _ ->
      Printf.printf "fail float of string input %S expected %f\n" input expected

  end

let test_string_literal_sequence expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.string_literal_sequence Lexer.token lexbuf in
    if expected <> result
    then
      Printf.printf "error input %S expected %S result %S\n" input expected result;
  with
    | Parsing.Parse_error ->
      Printf.printf "parser error input %S expected %S\n" input expected
  end

let test_expression expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.expression Lexer.token lexbuf in
    if expected <> result
    then
      Format.fprintf Format.std_formatter
        "error input %S expected %a result %a\n"
        input Ast.pp_e expected Ast.pp_e result;
  with
    | Parsing.Parse_error ->
      Format.fprintf Format.std_formatter
        "parser error input %S expected %a\n"
        input Ast.pp_e expected
    | Failure msg ->
      Format.fprintf Format.std_formatter
        "%s input %S expected %a\n" msg
        input Ast.pp_e expected
  end

let test_program_body_statement expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.program_body_statement Lexer.token lexbuf in
    if expected <> result
    then
      Format.fprintf Format.std_formatter
        "error input %S expected %a result %a\n"
        input Ast.pp_s expected Ast.pp_s result;
  with
    | Parsing.Parse_error ->
      Format.fprintf Format.std_formatter
        "parser error input %S expected %a\n"
        input Ast.pp_s expected
    | Failure msg ->
      Format.fprintf Format.std_formatter
        "%s input %S expected %a\n" msg
        input Ast.pp_s expected
  end

let test_program expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.program Lexer.token lexbuf in
    if expected <> result
    then
      Format.fprintf Format.std_formatter
        "error input %S expected %a result %a\n"
        input Ast.pp_program expected Ast.pp_program result;
  with
    | Parsing.Parse_error ->
      Format.fprintf Format.std_formatter
        "parser error input %S expected %a\n"
        input Ast.pp_program expected
    | Failure msg ->
      Format.fprintf Format.std_formatter
        "%s input %S expected %a\n" msg
        input Ast.pp_program expected
  end

let test_file input =
  begin try
    let inp = open_in input in
    let lexbuf = Lexing.from_channel inp in
    let _ = Parser.program Lexer.token lexbuf in
    close_in inp;
    Format.fprintf Format.std_formatter
      "file %s ok\n"
      input;
  with
    | Parsing.Parse_error ->
      Format.fprintf Format.std_formatter
        "parser error input file %S\n" input
    | Failure msg ->
      Format.fprintf Format.std_formatter
        "%s input file %S\n" msg input
  end

let _ =
  Printf.printf "test_identifier_sequence start\n";
  test_identifier_sequence "a" "// \na";
  test_identifier_sequence "a" "// a\na";
  test_identifier_sequence "a" "/* */a";
  test_identifier_sequence "a" "/*\n*/a";
  test_identifier_sequence "a" "/*/*\n*/a";

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

  test_identifier_sequence "%op_==" "op ==";
  test_identifier_sequence "%op_!=" "op !=";
  test_identifier_sequence "%op_||" "op ||";
  test_identifier_sequence "%op_&&" "op &&"; 
  test_identifier_sequence "%op_<=" "op <=";
  test_identifier_sequence "%op_>=" "op >=";
  test_identifier_sequence "%op_<<" "op <<";
  test_identifier_sequence "%op_>>" "op >>";
  test_identifier_sequence "%op_()" "op ()";
  test_identifier_sequence "%op_[]" "op []";
  test_identifier_sequence "%op_|" "op |";
  test_identifier_sequence "%op_^" "op ^";
  test_identifier_sequence "%op_&" "op &";
  test_identifier_sequence "%op_+" "op +";
  test_identifier_sequence "%op_-" "op -";
  test_identifier_sequence "%op_*" "op *";
  test_identifier_sequence "%op_/" "op /";
  test_identifier_sequence "%op_%" "op %";
  test_identifier_sequence "%op_<" "op <";
  test_identifier_sequence "%op_>" "op >";
  test_identifier_sequence "%op_=" "op =";

  test_identifier_sequence "%op_pre_==" "op pre ==";
  test_identifier_sequence "%op_pre_!=" "op pre !=";
  test_identifier_sequence "%op_pre_||" "op pre ||";
  test_identifier_sequence "%op_pre_&&" "op pre &&"; 
  test_identifier_sequence "%op_pre_<=" "op pre <=";
  test_identifier_sequence "%op_pre_>=" "op pre >=";
  test_identifier_sequence "%op_pre_<<" "op pre <<";
  test_identifier_sequence "%op_pre_>>" "op pre >>";
  test_identifier_sequence "%op_pre_()" "op pre ()";
  test_identifier_sequence "%op_pre_[]" "op pre []";
  test_identifier_sequence "%op_pre_|" "op pre |";
  test_identifier_sequence "%op_pre_^" "op pre ^";
  test_identifier_sequence "%op_pre_&" "op pre &";
  test_identifier_sequence "%op_pre_+" "op pre +";
  test_identifier_sequence "%op_pre_-" "op pre -";
  test_identifier_sequence "%op_pre_*" "op pre *";
  test_identifier_sequence "%op_pre_/" "op pre /";
  test_identifier_sequence "%op_pre_%" "op pre %";
  test_identifier_sequence "%op_pre_<" "op pre <";
  test_identifier_sequence "%op_pre_>" "op pre >";
  test_identifier_sequence "%op_pre_=" "op pre =";

  test_identifier_sequence "%op_post_==" "op post ==";
  test_identifier_sequence "%op_post_!=" "op post !=";
  test_identifier_sequence "%op_post_||" "op post ||";
  test_identifier_sequence "%op_post_&&" "op post &&"; 
  test_identifier_sequence "%op_post_<=" "op post <=";
  test_identifier_sequence "%op_post_>=" "op post >=";
  test_identifier_sequence "%op_post_<<" "op post <<";
  test_identifier_sequence "%op_post_>>" "op post >>";
  test_identifier_sequence "%op_post_()" "op post ()";
  test_identifier_sequence "%op_post_[]" "op post []";
  test_identifier_sequence "%op_post_|" "op post |";
  test_identifier_sequence "%op_post_^" "op post ^";
  test_identifier_sequence "%op_post_&" "op post &";
  test_identifier_sequence "%op_post_+" "op post +";
  test_identifier_sequence "%op_post_-" "op post -";
  test_identifier_sequence "%op_post_*" "op post *";
  test_identifier_sequence "%op_post_/" "op post /";
  test_identifier_sequence "%op_post_%" "op post %";
  test_identifier_sequence "%op_post_<" "op post <";
  test_identifier_sequence "%op_post_>" "op post >";
  test_identifier_sequence "%op_post_=" "op post =";

  Printf.printf "test_identifier_sequence end\n";


  Printf.printf "test_integer_literal start\n";
  test_integer_literal 0 "0";
  test_integer_literal 1 "1";
  test_integer_literal 2 "2";
  test_integer_literal 3 "3";
  test_integer_literal 4 "4";
  test_integer_literal 5 "5";
  test_integer_literal 6 "6";
  test_integer_literal 7 "7";
  test_integer_literal 8 "8";
  test_integer_literal 9 "9";
  test_integer_literal 10 "10";
  test_integer_literal 99 "99";
  test_integer_literal 100 "100";
  test_integer_literal 9999 "9999";
  test_integer_literal 0 "0x0";
  test_integer_literal 1 "0x1";
  test_integer_literal 2 "0x2";
  test_integer_literal 3 "0x3";
  test_integer_literal 4 "0x4";
  test_integer_literal 5 "0x5";
  test_integer_literal 6 "0x6";
  test_integer_literal 7 "0x7";
  test_integer_literal 8 "0x8";
  test_integer_literal 9 "0x9";
  test_integer_literal 0xa "0xa";
  test_integer_literal 0xa "0xA";
  test_integer_literal 0xb "0xb";
  test_integer_literal 0xb "0xB";
  test_integer_literal 0xc "0xc";
  test_integer_literal 0xC "0xC";
  test_integer_literal 0xd "0xd";
  test_integer_literal 0xD "0xD";
  test_integer_literal 0xe "0xe";
  test_integer_literal 0xE "0xE";
  test_integer_literal 0xf "0xf";
  test_integer_literal 0xF "0xF";
  test_integer_literal 0xff "0xff";
  test_integer_literal 0x0 "0X0";
  test_integer_literal 0xff "0XFF";

  test_integer_literal 0 "0o0";
  test_integer_literal 1 "0o1";
  test_integer_literal 2 "0o2";
  test_integer_literal 3 "0o3";
  test_integer_literal 4 "0o4";
  test_integer_literal 5 "0o5";
  test_integer_literal 6 "0o6";
  test_integer_literal 7 "0o7";
  test_integer_literal 0o77 "0o77";
  test_integer_literal 0 "0O0";
  test_integer_literal 0o77 "0O77";

  test_integer_literal 0 "0b0";
  test_integer_literal 1 "0b1";
  test_integer_literal 0b10 "0b10";
  test_integer_literal 0b11 "0b11";
  Printf.printf "test_integer_literal end\n";

  Printf.printf "test_float_literal start\n";
  test_float_literal 0.1 "0.100000";
  test_float_literal 9.9 "9.9";
  test_float_literal 0.1e2 "0.100000e2";
  test_float_literal 9.9e2 "9.9e2";
  test_float_literal 0.1e2 "0.100000E2";
  test_float_literal 9.9e2 "9.9E2";
  test_float_literal 0.1e2 "0.100000e2f";
  test_float_literal 0.1e2 "0.100000E2f";
  test_float_literal 0.1e2 "0.100000e2F";
  test_float_literal 0.1e2 "0.100000E2F";
  test_float_literal 0.1e2 "0.100000e2l";
  test_float_literal 0.1e2 "0.100000E2l";
  test_float_literal 0.1e2 "0.100000e2L";
  test_float_literal 0.1e2 "0.100000E2L";
  test_float_literal 0.1e+2 "0.100000e+2f";
  test_float_literal 0.1e+2 "0.100000E+2f";
  test_float_literal 0.1e+2 "0.100000e+2F";
  test_float_literal 0.1e+2 "0.100000E+2F";
  test_float_literal 0.1e+2 "0.100000e+2l";
  test_float_literal 0.1e+2 "0.100000E+2l";
  test_float_literal 0.1e+2 "0.100000e+2L";
  test_float_literal 0.1e+2 "0.100000E+2L";

  test_float_literal 0.1e-2 "0.100000e-2f";
  test_float_literal 0.1e-2 "0.100000E-2f";
  test_float_literal 0.1e-2 "0.100000e-2F";
  test_float_literal 0.1e-2 "0.100000E-2F";
  test_float_literal 0.1e-2 "0.100000e-2l";
  test_float_literal 0.1e-2 "0.100000E-2l";
  test_float_literal 0.1e-2 "0.100000e-2L";
  test_float_literal 0.1e-2 "0.100000E-2L";
  Printf.printf "test_float_literal end\n";

  Printf.printf "test_string_literal_sequence start\n";
  test_string_literal_sequence "" "\"\"";
  test_string_literal_sequence "a" "\"a\"";
  test_string_literal_sequence "aa" "\"aa\"";
  test_string_literal_sequence "\"" "\"\\\"\"";
  test_string_literal_sequence "\\" "\"\\\\\"";
  test_string_literal_sequence "\'" "\"\\'\"";
  test_string_literal_sequence "\n" "\"\\n\"";
  test_string_literal_sequence "\r" "\"\\r\"";
  test_string_literal_sequence "\t" "\"\\t\"";
  test_string_literal_sequence "\b" "\"\\b\"";
  test_string_literal_sequence " " "\"\\\ \"";
  test_string_literal_sequence "\000" "\"\\000\"";
  test_string_literal_sequence "\010" "\"\\010\"";
  test_string_literal_sequence "\020" "\"\\020\"";
  test_string_literal_sequence "\x40" "\"\\x40\"";
  Printf.printf "test_string_literal_sequence end\n";

  Printf.printf "test_expression integer start\n";
  test_expression (EInt 0) "0";
  test_expression (EInt 1) "1";
  test_expression (EInt 2) "2";
  test_expression (EInt 3) "3";
  test_expression (EInt 4) "4";
  test_expression (EInt 5) "5";
  test_expression (EInt 6) "6";
  test_expression (EInt 7) "7";
  test_expression (EInt 8) "8";
  test_expression (EInt 9) "9";
  test_expression (EInt 10) "10";
  test_expression (EInt 99) "99";
  test_expression (EInt 100) "100";
  test_expression (EInt 9999) "9999";
  test_expression (EUnary ("-", EInt 0)) "-0";
  test_expression (EUnary ("-", EInt 1)) "-1";
  test_expression (EUnary ("-", EInt 19)) "-19";
  test_expression (EUnary ("-", EInt 222)) "-222";
  test_expression (EUnary ("-", EInt 3333)) "-3333";
  test_expression (EUnary ("-", EInt 55555)) "-55555";
  test_expression (EUnary ("-", EInt 55555)) "-55_555";
  test_expression (EUnary ("-", EInt 55555)) "-55_5__5_5_";
  test_expression (EInt 0) "0x0";
  test_expression (EInt 1) "0x1";
  test_expression (EInt 2) "0x2";
  test_expression (EInt 3) "0x3";
  test_expression (EInt 4) "0x4";
  test_expression (EInt 5) "0x5";
  test_expression (EInt 6) "0x6";
  test_expression (EInt 7) "0x7";
  test_expression (EInt 8) "0x8";
  test_expression (EInt 9) "0x9";
  test_expression (EInt 0xa) "0xa";
  test_expression (EInt 0xa) "0xA";
  test_expression (EInt 0xb) "0xb";
  test_expression (EInt 0xb) "0xB";
  test_expression (EInt 0xc) "0xc";
  test_expression (EInt 0xC) "0xC";
  test_expression (EInt 0xd) "0xd";
  test_expression (EInt 0xD) "0xD";
  test_expression (EInt 0xe) "0xe";
  test_expression (EInt 0xE) "0xE";
  test_expression (EInt 0xf) "0xf";
  test_expression (EInt 0xF) "0xF";
  test_expression (EInt 0xff) "0xff";
  test_expression (EInt 0x0) "0X0";
  test_expression (EInt 0xff) "0XFF";
  test_expression (EUnary ("-", EInt 1)) "-0x1";
  test_expression (EUnary ("-", EInt 0xff)) "-0xFF";
  test_expression (EUnary ("-", EInt 1)) "-0X1";
  test_expression (EUnary ("-", EInt 0xff)) "-0XFF";
  test_expression (EUnary ("-", EInt 0xff)) "-0XF_F_";

  test_expression (EInt 0) "0o0";
  test_expression (EInt 1) "0o1";
  test_expression (EInt 2) "0o2";
  test_expression (EInt 3) "0o3";
  test_expression (EInt 4) "0o4";
  test_expression (EInt 5) "0o5";
  test_expression (EInt 6) "0o6";
  test_expression (EInt 7) "0o7";
  test_expression (EInt 0o77) "0o77";
  test_expression (EInt 0) "0O0";
  test_expression (EInt 0o77) "0O77";
  test_expression (EUnary ("-", EInt 1)) "-0o1";
  test_expression (EUnary ("-", EInt 0o77)) "-0o77";
  test_expression (EUnary ("-", EInt 1)) "-0O1";
  test_expression (EUnary ("-", EInt 0o77)) "-0O77";
  test_expression (EUnary ("-", EInt 0o77)) "-0O7_7_";

  test_expression (EInt 0) "0b0";
  test_expression (EInt 1) "0b1";
  test_expression (EInt 0b10) "0b10";
  test_expression (EInt 0b11) "0b11";
  test_expression (EUnary ("-", EInt 1)) "-0b1";
  test_expression (EUnary ("-", EInt 0b10)) "-0b10";
  test_expression (EUnary ("-", EInt 0b11)) "-0b11";
  test_expression (EUnary ("-", EInt 0b111)) "-0b111";
  test_expression (EUnary ("-", EInt 0b11111111)) "-0b1111_1111_";
  Printf.printf "test_expression integer end\n";

  Printf.printf "test_expression float start\n";
  test_expression (EFloat 0.1) "0.100000";
  test_expression (EFloat 9.9) "9.9";
  test_expression (EFloat 0.1e2) "0.100000e2";
  test_expression (EFloat 9.9e2) "9.9e2";
  test_expression (EFloat 0.1e2) "0.100000E2";
  test_expression (EFloat 9.9e2) "9.9E2";
  test_expression (EFloat 0.1e2) "0.100000e2f";
  test_expression (EFloat 0.1e2) "0.100000E2f";
  test_expression (EFloat 0.1e2) "0.100000e2F";
  test_expression (EFloat 0.1e2) "0.100000E2F";
  test_expression (EFloat 0.1e2) "0.100000e2l";
  test_expression (EFloat 0.1e2) "0.100000E2l";
  test_expression (EFloat 0.1e2) "0.100000e2L";
  test_expression (EFloat 0.1e2) "0.100000E2L";
  test_expression (EFloat 0.1e+2) "0.100000e+2f";
  test_expression (EFloat 0.1e+2) "0.100000E+2f";
  test_expression (EFloat 0.1e+2) "0.100000e+2F";
  test_expression (EFloat 0.1e+2) "0.100000E+2F";
  test_expression (EFloat 0.1e+2) "0.100000e+2l";
  test_expression (EFloat 0.1e+2) "0.100000E+2l";
  test_expression (EFloat 0.1e+2) "0.100000e+2L";
  test_expression (EFloat 0.1e+2) "0.100000E+2L";

  test_expression (EFloat 0.1e-2) "0.100000e-2f";
  test_expression (EFloat 0.1e-2) "0.100000E-2f";
  test_expression (EFloat 0.1e-2) "0.100000e-2F";
  test_expression (EFloat 0.1e-2) "0.100000E-2F";
  test_expression (EFloat 0.1e-2) "0.100000e-2l";
  test_expression (EFloat 0.1e-2) "0.100000E-2l";
  test_expression (EFloat 0.1e-2) "0.100000e-2L";
  test_expression (EFloat 0.1e-2) "0.100000E-2L";
  Printf.printf "test_expression float end\n";

  Printf.printf "test_expression string start\n";
  test_expression (EString "") "\"\"";
  test_expression (EString "a") "\"a\"";
  test_expression (EString "aa") "\"aa\"";
  test_expression (EString "\"") "\"\\\"\"";
  test_expression (EString "\\") "\"\\\\\"";
  test_expression (EString "\'") "\"\\'\"";
  test_expression (EString "\n") "\"\\n\"";
  test_expression (EString "\r") "\"\\r\"";
  test_expression (EString "\t") "\"\\t\"";
  test_expression (EString "\b") "\"\\b\"";
  test_expression (EString " ") "\"\\\ \"";
  test_expression (EString "\000") "\"\\000\"";
  test_expression (EString "\010") "\"\\010\"";
  test_expression (EString "\020") "\"\\020\"";
  test_expression (EString "\x40") "\"\\x40\"";
  Printf.printf "test_expression string end\n";

  Printf.printf "test_expression bool start\n";
  test_expression (EBool true) "true";
  test_expression (EBool false) "false";
  Printf.printf "test_expression bool end\n";

  Printf.printf "test_expression array start\n";
  test_expression (EArray []) "[]";
  test_expression (EArray [EBool true]) "[true]";
  test_expression (EArray [EBool true; EBool false]) "[true, false]";
  test_expression (EArray [EInt 1; EInt 2; EInt 3]) "[1, 2, 3]";
  Printf.printf "test_expression array start\n";

  Printf.printf "test_expression identifier_value_set start\n";
  test_expression (EIdentifier ("a", false)) "a";
  test_expression (EIdentifier ("a1", false)) "a1";
  test_expression (EIdentifier ("a", true)) ".a";
  test_expression (ETemplateInstance ("a", [], false)) "a!()";
  test_expression (ETemplateInstance ("a1", [EIdentifier ("a", false)], false)) "a1!(a)";
  test_expression (ETemplateInstance ("a", [EIdentifier ("b", false)], true)) ".a!(b)";
  test_expression (ETemplateInstance ("a", [EIdentifier ("a", false)], true)) ".a!a";
  test_expression
    (EBin (
      ETemplateInstance ("a", [EIdentifier ("b", false)], true),
      "+",
      (EInt 1)))
    ".a!b+1";

  test_expression (EBin (EIdentifier ("b", false), "=", EInt 1)) "b = 1";
  test_expression (EBin (EIdentifier ("b", false), "||", EInt 1)) "b || 1";
  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "||", EIdentifier ("b", false)),
      "||",
      EIdentifier ("c", false)))
    "a || b || c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "&&", EIdentifier ("b", false)),
      "&&",
      EIdentifier ("c", false)))
    "a && b && c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "|", EIdentifier ("b", false)),
      "|",
      EIdentifier ("c", false)))
    "a | b | c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "^", EIdentifier ("b", false)),
      "^",
      EIdentifier ("c", false)))
    "a ^ b ^ c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "&", EIdentifier ("b", false)),
      "&",
      EIdentifier ("c", false)))
    "a & b & c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "==", EIdentifier ("b", false)),
      "==",
      EIdentifier ("c", false)))
    "a == b == c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "!=", EIdentifier ("b", false)),
      "!=",
      EIdentifier ("c", false)))
    "a != b != c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "<=", EIdentifier ("b", false)),
      "<=",
      EIdentifier ("c", false)))
    "a <= b <= c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "<", EIdentifier ("b", false)),
      "<",
      EIdentifier ("c", false)))
    "a < b < c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), ">=", EIdentifier ("b", false)),
      ">=",
      EIdentifier ("c", false)))
    "a >= b >= c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), ">", EIdentifier ("b", false)),
      ">",
      EIdentifier ("c", false)))
    "a > b > c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "<<", EIdentifier ("b", false)),
      "<<",
      EIdentifier ("c", false)))
    "a << b << c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), ">>", EIdentifier ("b", false)),
      ">>",
      EIdentifier ("c", false)))
    "a >> b >> c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "+", EIdentifier ("b", false)),
      "+",
      EIdentifier ("c", false)))
    "a + b + c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "-", EIdentifier ("b", false)),
      "-",
      EIdentifier ("c", false)))
    "a - b - c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "*", EIdentifier ("b", false)),
      "*",
      EIdentifier ("c", false)))
    "a * b * c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "/", EIdentifier ("b", false)),
      "/",
      EIdentifier ("c", false)))
    "a / b / c";

  test_expression
    (EBin (
      EBin (EIdentifier ("a", false), "%", EIdentifier ("b", false)),
      "%",
      EIdentifier ("c", false)))
    "a % b % c";

  test_expression
    (ECall (EIdentifier ("a", false), []))
    "a()";

  test_expression
    (ECall (EIdentifier ("a", false), [EIdentifier ("b", false)]))
    "a(b)";

  test_expression
    (ECall (
      ECall (EIdentifier ("a", false), [EIdentifier ("b", false)]),
      [EIdentifier ("c", false)]))
    "a(b)(c)";

  Printf.printf "test_expression identifier_value_set end\n";

  Printf.printf "test_program_body_statement start\n";
  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [],
      ((Some (EIdentifier ("int",false))), None))))
    "val a :int;";

  test_program_body_statement
    (SVariableDeclaration ("ref",
      (EIdentifier ("a", false),
      [],
      ((Some (EIdentifier ("int",false))), None))))
    "ref a :int;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [],
      (None, Some (EInt 1)))))
    "val a = 1;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [],
      (Some (EIdentifier ("int",false)), Some (EInt 1)))))
    "val a:int = 1;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [AOnlymeta],
      ((Some (EIdentifier ("int",false))), None))))
    "val a onlymeta :int;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [AMeta],
      ((Some (EIdentifier ("int",false))), None))))
    "val a meta :int;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [AIntrinsic],
      ((Some (EIdentifier ("int",false))), None))))
    "val a intrinsic :int;";

  test_program_body_statement
    (SVariableDeclaration ("val",
      (EIdentifier ("a", false),
      [AOverride],
      ((Some (EIdentifier ("int",false))), None))))
    "val a override :int;";

  test_program_body_statement
    (SReturn (EInt 10))
    "return 10;";

  test_program_body_statement
    SEmpty
    ";";

  test_program_body_statement
    (SExpression
      (EBin (EIdentifier ("a", false), "=", EInt 10)))
    "a = 10;";

  test_program_body_statement (SBlock []) "{}";

  test_program_body_statement
    (SWhile (
      EBin (EIdentifier ("a", false), "<", EInt 10),
      SBlock [
        SExpression (
          EBin (EIdentifier ("a", false), "=",
            EBin (EIdentifier ("a", false), "+", (EInt 1))))
      ]))
    "while(a < 10) { a = a + 1; }";

  test_program_body_statement
    (SIf (
      EBin (EIdentifier ("a", false), "<", EInt 10),
      SBlock [],
      SEmpty))
    "if(a < 10) {}";

  test_program_body_statement
    (SIf (
      EBin (EIdentifier ("a", false), "<", EInt 10),
      SBlock [SExpression (ECall (EIdentifier ("b", false), []))],
      SBlock [SExpression (ECall (EIdentifier ("c", false), []))]))
    "if(a < 10) {b();} else {c();}";

  test_program_body_statement
    (SIf (
      EBin (EIdentifier ("a", false), "<", EInt 10),
      SBlock [SExpression (ECall (EIdentifier ("b", false), []))],
      SIf (
        EIdentifier ("d", false),
        SExpression (ECall (EIdentifier ("c", false), [])),
        SEmpty)))
    "if(a < 10) {b();} else if (d) c();";

  Printf.printf "test_program_body_statement end\n";

  Printf.printf "test_program start\n";

  test_program [] "";
  test_program [TSEmpty] ";";
  test_program [TSEmpty; TSEmpty] ";;";
  test_program
    [TSFunctionDefinition (None, EIdentifier ("t", false), [], [], None, [])]
    "def t(){}";

  test_program
    [TSFunctionDefinition (
      None,
      EIdentifier ("main", false),
      [], [],
      (Some (EIdentifier ("int", false))),
      [(Ast.SReturn (Ast.EInt 0))])
    ]
    "def main(): int { return 0; }";

  test_program
    [(TSImport ["hoge"])]
    "import hoge;";

  test_program
    [TSExpression
       (SExpression
          (EBin (EInt 1, "+", EInt 2)))]
    "1+2;";

  test_program
    [TSClassDefinition (None, EIdentifier ("A", false), None,
      [], [],
      [CFunctionDefinition (None, EIdentifier ("ctor", false),
         [], [], [(EIdentifier ("a", false), (EInt 10))], None,
         []);
       (CVariableDeclaration
          ("val",
           (EIdentifier ("a", false), [],
            (Some (EIdentifier ("int", false)), None))))])]
    "class A { def ctor() | a = 10 {} val a: int; }";

  test_program
    [TSClassDefinition (None, EIdentifier ("I", false), None,
            [], [],
            [CFunctionDefinition (None, EIdentifier ("%op_+", false),
               [("ref",
                 (Some (EIdentifier ("v", false)),
                  (Some (EIdentifier ("int", false)), None)))], [
               ], [], Some (EIdentifier ("int", false)), [])])]
    "class I { def op +( v: int ): int {} }";


  Printf.printf "test_program end\n";

  Printf.printf "test_file start\n";

  test_file "../test/integration/hoge.rill";
  test_file "../test/integration/test1.rill";
  test_file "../test/integration/test10.rill";
  test_file "../test/integration/test11.rill";
  test_file "../test/integration/test12.rill";
  test_file "../test/integration/test13.rill";
  test_file "../test/integration/test13a.rill";
  test_file "../test/integration/test13b.rill";
  test_file "../test/integration/test13c.rill";
  test_file "../test/integration/test13d.rill";
  test_file "../test/integration/test13e.rill";
  test_file "../test/integration/test13f.rill";
  test_file "../test/integration/test14.rill";
  test_file "../test/integration/test15.rill";
  test_file "../test/integration/test16.rill";
  test_file "../test/integration/test17.rill";
  test_file "../test/integration/test18.rill";
  test_file "../test/integration/test19.rill";
  test_file "../test/integration/test1a.rill";
  test_file "../test/integration/test2.rill";
  test_file "../test/integration/test20.rill";
  test_file "../test/integration/test21.rill";
  test_file "../test/integration/test22.rill";
  test_file "../test/integration/test23.rill";
  test_file "../test/integration/test24.rill";
  test_file "../test/integration/test25.rill";
  test_file "../test/integration/test25a.rill";
  test_file "../test/integration/test25b.rill";
  test_file "../test/integration/test26.rill";
  test_file "../test/integration/test27.rill";
  test_file "../test/integration/test27a.rill";
  test_file "../test/integration/test27b.rill";
  test_file "../test/integration/test3.rill";
  test_file "../test/integration/test4.rill";
  test_file "../test/integration/test5.rill";
  test_file "../test/integration/test6.rill";
  test_file "../test/integration/test7.rill";
  test_file "../test/integration/test8.rill";
  test_file "../test/integration/test9.rill";
  test_file "../test/integration/test9a.rill";
  test_file "../test/integration/a.rill";

  Printf.printf "test_file end\n";
