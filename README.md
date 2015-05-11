# Yarill Programming Language

Yarill is yet another rill programming language.

## install

    $ make

## hello world

example/hello.rill


# grammer

## はじめに Foreword

このドキュメントは、Rill言語のリファレンスマニュアルです。言語構造を示し、正確な構文と意味論を提供します。

## 表記法 Notations

言語の構文はBNFのような記法で記述されています。終端記号はセミコロン''あるいはダブルクォーテーション""で括ってあります。非終端記号は小文字から始まる識別子によって記述します。
角カッコ[...]は、省略可能である事を示しています。
中括弧{...}は、囲まれた部分が0回以上の繰り返しを表します。プラスの記号+は1回以上の繰り返しを意味します。
括弧（...）はグループ表します。


## Lexing syntax

Rillのプログラムはソーステキストを読み込み、字句解析されたあと構文解析します。
字句(Token)を以下のEBNFで定義します。

### コメント

コメントは `/*` と `*/` で括られたブロックコメントと `//` から改行までの1ラインコメントがあります。

```
/* comment */
```

ブロックコメント

```
// comment
```

1ラインコメント

### Lexical Conventions

```
digit_charset ::= '0' | … | '9'
nondigit_charset ::= 'A' | … | 'Z' | 'a' | … | 'z' | '_'
normal_identifier_sequence ::= nondigit_charset (nondigit_charset | digit_charset)*
operator_identifier_sequence ::= "op" ["pre" | "post"] ("==" | "!=" | "||" | "&&" | "<=" | ">=" | "<<" | ">>" | "()" | "[]" | "|" | "^" | "&" | "+" | "-" | "*" | "/" | "%" | "<" | ">" | "=")
escape_sequence ::= '\\n'
string_literal_sequence ::= '"' ((escape_sequence | char) - '"')* '"'
string_literal ::= string_literal_sequence
boolean_literal ::= "true" | "false"
integer_literal ::=
float_literal ::= digit_charset+ '.' digit_charset+ [exponent_part] [float_type]
               |  '.' digit_charset+ [exponent_part] [float_type]
               |  digit_charset+ [exponent_part] [float_type]
               |  digit_charset+ [exponent_part] float_type
sign ::= '+' | '-'
exponent_part ::= ('e' | 'E') [sign] digit_charset+
floating_suffix ::= 'f' | 'l' | 'F' | 'L'
```

## Context-free Syntax

### literals

```
identifier_sequence ::= operator_identifier_sequence | normal_identifier_sequence
array_literal ::= '[' [assign_expression % ','] ']'
numeric_literal ::= float_literal | integer_literal
```

## reference

* http://askra.de/software/ocaml-doc/3.12/full-grammar.html
* http://scala-lang.org/files/archive/spec/2.11/13-syntax-summary.html
* http://qiita.com/esumii/items/0eeb30f35c2a9da4ab8a
* http://www.kmonos.net/alang/d/lex.html
* https://www.haskell.org/onlinereport/haskell2010/haskellch2.html#x7-140002
* http://docs.ruby-lang.org/ja/1.8.7/doc/spec=2fbnf.html
