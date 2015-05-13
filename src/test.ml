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

let test_string_literal expected input =
  begin try
    let lexbuf = Lexing.from_string input in
    let result = Parser.string_literal Lexer.token lexbuf in
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
  test_integer_literal (-0) "-0";
  test_integer_literal (-1) "-1";
  test_integer_literal (-19) "-19";
  test_integer_literal (-222) "-222";
  test_integer_literal (-3333) "-3333";
  test_integer_literal (-55555) "-55555";
  test_integer_literal (-55555) "-55_555";
  test_integer_literal (-55555) "-55_5__5_5_";
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
  test_integer_literal (-1) "-0x1";
  test_integer_literal (-0xff) "-0xFF";
  test_integer_literal (-1) "-0X1";
  test_integer_literal (-0xff) "-0XFF";
  test_integer_literal (-0xff) "-0XF_F_";

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
  test_integer_literal (-1) "-0o1";
  test_integer_literal (-0o77) "-0o77";
  test_integer_literal (-1) "-0O1";
  test_integer_literal (-0o77) "-0O77";
  test_integer_literal (-0o77) "-0O7_7_";

  test_integer_literal 0 "0b0";
  test_integer_literal 1 "0b1";
  test_integer_literal 0b10 "0b10";
  test_integer_literal 0b11 "0b11";
  test_integer_literal (-1) "-0b1";
  test_integer_literal (-0b10) "-0b10";
  test_integer_literal (-0b11) "-0b11";
  test_integer_literal (-0b111) "-0b111";
  test_integer_literal (-0b11111111) "-0b1111_1111_";

  test_float_literal 0.1 "0.100000";
  test_float_literal 9.9 "9.9";
  test_float_literal 1. "1.";
  test_float_literal 0.1 "0.100000e";
  test_float_literal 9.9 "9.9e";
  test_float_literal 1. "1.e";
  test_float_literal 0.1e2 "0.100000e2";
  test_float_literal 9.9e2 "9.9e2";
  test_float_literal 1.e2 "1.e2";
  test_float_literal 0.1e2 "0.100000E2";
  test_float_literal 9.9e2 "9.9E2";
  test_float_literal 1.e2 "1.E2";
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

  test_string_literal "" "\"\"";
  test_string_literal "a" "\"a\"";
  test_string_literal "aa" "\"aa\"";
  test_string_literal "\"" "\"\\\"\"";
  test_string_literal "\\" "\"\\\\\"";
  test_string_literal "\'" "\"\\'\"";
  test_string_literal "\n" "\"\\n\"";
  test_string_literal "\r" "\"\\r\"";
  test_string_literal "\t" "\"\\t\"";
  test_string_literal "\b" "\"\\b\"";
  test_string_literal " " "\"\\\ \"";
  test_string_literal "\000" "\"\\000\"";
  test_string_literal "\010" "\"\\010\"";
  test_string_literal "\020" "\"\\020\"";
  test_string_literal "\x40" "\"\\x40\"";


  Printf.printf "test_identifier_sequence end\n";
