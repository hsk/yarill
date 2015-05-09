# Yarill Programming Language

Yarill is yet another rill programming language.

## install

    $ make

## hello world

example/hello.rill

## Lexing syntax

```
digit_charset ::= '0' | … | '9'
nondigit_charset ::= 'A' | … | 'Z' | 'a' | … | 'z' | '_'
normal_identifier_sequence ::= nondigit_charset (nondigit_charset | digit_charset)*
operator_identifier_sequence ::= "op" ("pre" | "post")? ("==" | "!=" | "||" | "&&" | "<=" | ">=" | "<<" | ">>" | "()" | "[]" | "|" | "^" | "&" | "+" | "-" | "*" | "/" | "%" | "<" | ">" | "=")
identifier_sequence ::= operator_identifier_sequence | normal_identifier_sequence
escape_sequence ::= '\\n'
string_literal_sequence ::= '"' ((escape_sequence | char) - '"')* '"'
string_literal ::= string_literal_sequence
boolean_literal ::= "true" | "false"
integer_literal ::=
float_literal ::= digit_charset+ '.' digit_charset+ exponent_part? float_type?
               |  '.' digit_charset+ exponent_part? float_type?
               |  digit_charset+ exponent_part? float_type?
               |  digit_charset+ exponent_part? float_type
exponent_part ::= ('e' | 'E') sign? digit_charset+
floating_suffix ::= 'f' | 'l' | 'F' | 'L'
```

## Context-free Syntax

### literals

```
array_literal ::= '[' (assign_expression % ',')? ']'
numeric_literal ::= float_literal | integer_literal
```
