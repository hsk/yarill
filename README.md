# Yarill Programming Language

Yarill is yet another rill programming language.

## install

    $ make

## hello world

example/hello.rill


# grammer

## はじめに Foreword

このドキュメントは、Rill言語のリファレンスマニュアルとなる事を目指しています。
言語構造を示し、正確な構文と意味論を提供したいと考えています。しかし全然、出来上がっていません。

## 表記法 Notations

言語の構文はBNFのような記法で記述されています。終端記号はセミコロン''あるいはダブルクォーテーション""で括ってあります。非終端記号は小文字から始まる識別子によって記述します。
角カッコ`[…]`は、省略可能である事を示しています。
中括弧`{…}`は、囲まれた部分が0回以上の繰り返しを表します。プラスの記号+は1回以上の繰り返しを意味します。
括弧`(…)`はグループ表します。


## 字句解析 Lexical Conventions

プログラムはソーステキストを読み込み、字句解析されたあと構文解析します。
字句(Token)を以下のEBNFで定義します。

### 空白

スペース' ' 、改行'\n'、水平タブ'\n'、キャリッジリターン'\r'、ラインフィード、フォーム·フィードの文字はブランクです。
ブランクは無視されますが、それらは隣接する識別子、リテラルおよびそれ以外の場合は、単一の識別子、リテラルまたはキーワードとして混同されることになるキーワードを区切ります。

### コメント

コメントは以下の例のように `/*` と `*/` で括られたブロックコメントと `//` から改行までの1ラインコメントがあります。

```
/* comment */
```

ブロックコメント

```
// comment
```

1ラインコメント

コメントをネストする事は出来ません。コメントは空白文字として扱われます。文字列リテラルの内部で`/*`や`//`があってもコメントにはなりません。

### 識別子 Identifier

```
digit_charset ::= '0' | … | '9'
nondigit_charset ::= 'A' | … | 'Z' | 'a' | … | 'z' | '_'
normal_identifier_sequence ::= nondigit_charset (nondigit_charset | digit_charset)*
operator_identifier_sequence ::= "op" ["pre" | "post"] ("==" | "!=" | "||" | "&&" | "<=" | ">=" | "<<" | ">>" | "()" | "[]" | "|" | "^" | "&" | "+" | "-" | "*" | "/" | "%" | "<" | ">" | "=")
identifier_sequence ::= operator_identifier_sequence | normal_identifier_sequence
```

Rillの識別子は、演算子識別子と普通識別子の２種類から成り立ちます。

普通識別子は文字または_（アンダースコア文字）で始まり、文字、アンダースコア、数字が０個以上連続したものです。文字はASCIIセットから少なくとも52大文字と小文字が含まれています。
演算子識別子は `op` キーワードから始まり、前置演算子を表す `pre` あるいは後置演算子を表す `post` をオプションとして記述し、その後に演算子記号を記述します。 `pre` または `post` が無い場合は2項演算子を表します。

### 整数リテラル

整数リテラルは、必要に応じてマイナス符号が前についた、一つ以上の数字の列です。
デフォルトでは、整数リテラルは基数10の整数です。次の接頭辞で異なる基数を選択出来ます。

| 接頭辞  | 基数          |
| ------ | ------------ |
| 0x, 0X | 16進数(基数16) |
| 0o, 0O |  8進数 (基数8) |
| 0b, 0B |  2進数 (基数2) |

(最初の0は数字のゼロであり、8進数のOは文字 'O' である)の表現可能な整数値の範囲外の整数リテラルの解釈は未定義です。
利便性と可読性のために、文字(アンダースコア '_' を)整数リテラル内に記述する事が出来ます。アンダースコアは無視されます。

```
integer_literal ::= [ '-' ]（'0' … '9'）{  '0' … '9' |  '_'  }  
  | [ '-' ] (0x | 0X) ('0' … '9' | 'A' … 'F' | 'a' … 'f'){ '0' … '9' | 'A' … 'F' | 'a' … 'a' |  '_' }
  | [ '-' ] ("0o" | "0O") ('0' … '7'){ '0' … '7' | '_' }  
  | [ '-' ] ("0b" | "0B") ('0' … '1'){ '0' … '1' | '_' }
```

### 浮動小数点数リテラル

```
float_literal ::= digit_charset+ '.' digit_charset+ [exponent_part] [float_type]
               |  '.' digit_charset+ [exponent_part] [float_type]
               |  digit_charset+ [exponent_part] [float_type]
               |  digit_charset+ [exponent_part] float_type
sign ::= '+' | '-'
exponent_part ::= ('e' | 'E') [sign] digit_charset+
floating_suffix ::= 'f' | 'l' | 'F' | 'L'
```

### 文字列リテラル

文字列リテラルは、'"'(二重引用符)文字で括られます。
2つの二重引用符は異なるいずれかの文字列を囲む'"'と'\'、または文字リテラルの上に与えられたテーブルからエスケープシーケンスです。
二重引用符を文字列に含みたい場合はエスケープシーケンスを使い"\""と記述します。

複数行渡って文字列リテラルを記述する事も可能です。

現在の実装では、文字列リテラルの長さに実質的に制限がありません。

```
escape_sequence ::= '\n'
string_literal_sequence ::= '"' ((escape_sequence | char) - '"')* '"'
string_literal ::= string_literal_sequence
```

エスケープシーケンスは以下の通りです:

| シーケンス | 文字表記                 |
| -------- | ---------------------- |
| \\\\     | バックスラッシュ (\\)     |
| \"       | 二重引用符（"）           |
| \'       | 単一引用符（'）           |
| \n       | 改行（LF）               |
| \r       | キャリッジリターン（CR）    |
| \t       | 水平タブ（TAB）           |
| \b       | バックスペース（BS）       |
| \ スペース | スペース（SPC）           |
| \DDD     | 文字DDDはASCIIコードの8進数 |
| \x HH    | 文字HHはASCIIコードの16進数 |


## Context-free Syntax

## プライマリ値 Primary value

```
primary_value:
  | boolean_literal { $1 }
  | identifier_value_set { $1 }
  | numeric_literal { $1 }
  | string_literal { $1 }
  | array_literal { $1 }
```

### ブーリアンリテラル

ブーリアンリテラルはtrue又はfalseを記述します。

```
boolean_literal ::= "true" | "false"
```

### 配列リテラル

配列リテラルを使う事で、配列の初期化を行う事が出来ます。

```
array_literal ::= '[' [assign_expression % ','] ']'
```

### 数値リテラル

数値を表すリテラルは、浮動小数点リテラルと整数リテラルがあります。

```
numeric_literal ::= float_literal | integer_literal
```

## 式 Expression

```
expression ::= assign_expression
```

## 二項演算子式

```
commma_expression ::= assign_expression
  | assign_expression { ',' comma_expression }

assign_expression ::= conditional_expression { '=' conditional_expression }

conditional_expression ::= logical_or_expression
    /* TODO: add conditional operator( ? : ) */

logical_or_expression ::= logical_and_expression { "||" logical_and_expression }
logical_and_expression ::= bitwise_or_expression { "&&" bitwise_or_expression }
bitwise_or_expression ::= bitwise_xor_expression { "|" bitwise_xor_expression }
bitwise_xor_expression ::= bitwise_and_expression { '^' bitwise_and_expression }
bitwise_and_expression ::= equality_expression { '&' equality_expression }
equality_expression ::= relational_expression { ("==" | "!=") relational_expression }
relational_expression ::= shift_expression { ("<=" | "<" | ">=" | ">") shift_expression }
shift_expression ::= add_sub_expression { ("<<" | ">>") add_sub_expression }

add_sub_expression ::= mul_div_rem_expression { '+' mul_div_rem_expression }
                     | unary_expression { '-' mul_div_rem_expression }
mul_div_rem_expression ::= unary_expression { ('*' | '/' | '%') unary_expression }
```

## 前置演算子式

```
unary_expression ::= postfix_expression
  | { '-' | '+' | '*' | '&' | "new" } unary_expression
```

## 後置演算子式

```
postfix_expression ::= primary_expression
  | primary_expression { '.' identifier_value_set }
  | primary_expression '[' [ expression ] ']'
  | primary_expression argument_list

argument_list ::= | '(' ')' | '(' [ assign_expression { ',' assign_expression } ] ')'
```

## プライマリ式

```
primary_expression ::= primary_value | '(' expression ')' | lambda_expression
```

## ラムダ式

```
lambda_expression ::= lambda_introducer
    [template_parameter_variable_declaration_list]
    parameter_variable_declaration_list
    decl_attribute_list
    [type_specifier]
    function_body_statements_list_for_lambda

lambda_introducer ::= '\'
```

## 文 Statements

文鳥言語には文鳥なだけに文が沢山あります。
よくあるプログラミング言語の文は文鳥言語ではプログラム本体文(program body statement)といいます。

### プログラム本体文 program body statement

```
/* executable scope, such as function, block, lambda, ... */
program_body_statement:
  | block_statement { $1 }
  | variable_declaration_statement { $1 }
  | control_flow_statement { $1 }
  | return_statement { $1 }
  | empty_statement { $1 }
  | expression_statement { $1 }   /* NOTE: this statement must be set at last */
```

### ブロック文 block statement

ブロック分はプログラム本体文を複数まとめて記述したものです。

```
block_statement ::= '{' program_body_statements '}'
program_body_statements ::= { program_body_statement }
```

### 値宣言文 variable declaration statement

値宣言文 variable declaration statement は値の宣言を行います。
値を宣言する際には、valまたはrefを使って保存する種別を指定します。

```
variable_declaration_statement ::= variable_declaration statement_termination

variable_holder_kind_specifier ::= "val" | "ref"

variable_declaration ::= variable_holder_kind_specifier variable_initializer_unit

variable_initializer_unit ::= identifier_relative decl_attribute_list value_initializer_unit 
```


## reference

* http://askra.de/software/ocaml-doc/3.12/full-grammar.html
* http://scala-lang.org/files/archive/spec/2.11/13-syntax-summary.html
* http://qiita.com/esumii/items/0eeb30f35c2a9da4ab8a
* http://www.kmonos.net/alang/d/lex.html
* https://www.haskell.org/onlinereport/haskell2010/haskellch2.html#x7-140002
* http://docs.ruby-lang.org/ja/1.8.7/doc/spec=2fbnf.html
