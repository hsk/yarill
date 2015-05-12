# Yarill Programming Language

Yarill is yet another rill programming language.

今はまだ開発中です。

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
角カッコ `[…]` は、省略可能である事を示しています。
中括弧 `{…}` は、囲まれた部分が0回以上の繰り返しを表します。プラスの記号 `+` は1回以上の繰り返しを意味します。
括弧 `(…)` はグループを表します。


## 字句解析 Lexical Conventions

プログラムはソーステキストを読み込み、字句解析されたあと構文解析します。
字句(Token)を以下に定義します。

### 空白

スペース' '、改行'\n'、水平タブ'\t'、キャリッジリターン'\r'、ラインフィード'\n'、フォーム·フィード'\f'の文字はブランクです。
ブランクは無視されますが、それらは隣接する識別子、リテラルおよびそれ以外の場合は、単一の識別子、リテラルまたはキーワードとして混同されることになるキーワードを区切ります。

### コメント

コメントは以下の例のように `/*` と `*/` で括られたブロックコメントと `//` から改行までの1ラインコメントがあります。

```
/* ブロックコメント */
```

ブロックコメントをネストする事は出来ません。

```
// 1ラインコメント
```

コメントは空白文字として扱われます。文字列リテラルの内部で `/*` や `//` があってもコメントにはなりません。

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

| 接頭辞 | 基数          |
| ------ | ------------ |
| 0x, 0X | 16進数(基数16) |
| 0o, 0O |  8進数 (基数8) |
| 0b, 0B |  2進数 (基数2) |

(最初の0は数字のゼロであり、8進数のOは文字 'O' である)の表現可能な整数値の範囲外の整数リテラルの解釈は未定義です。
利便性と可読性のために、文字(アンダースコア '_' を)整数リテラル内に記述する事が出来ます。アンダースコアは無視されます。

```
integer_literal ::=
    [ '-' ]（'0' … '9'）{  '0' … '9' |  '_'  }  
  | [ '-' ] (0x | 0X) ('0' … '9' | 'A' … 'F' | 'a' … 'f') { '0' … '9' | 'A' … 'F' | 'a' … 'a' |  '_' }
  | [ '-' ] ("0o" | "0O") ('0' … '7') { '0' … '7' | '_' }  
  | [ '-' ] ("0b" | "0B") ('0' … '1') { '0' … '1' | '_' }
```

### 浮動小数点数リテラル

```
float_literal ::=
    digit_charset+ '.' digit_charset+ [exponent_part] [float_type]
  | '.' digit_charset+ [exponent_part] [float_type]
  | digit_charset+ [exponent_part] [float_type]
  | digit_charset+ [exponent_part] float_type
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


## 型スペシファイア type specifier

```
type_specifier ::= ':' id_expression

decl_attribute ::= "onlymeta" | "meta" | "intrinsic" | "override"

decl_attribute_list ::= decl_attribute { ',' decl_attribute } | x3::eps
```

## プライマリ値 Primary value

```
primary_value ::=
    boolean_literal
  | identifier_value_set
  | numeric_literal
  | string_literal
  | array_literal
```

### ブーリアンリテラル

ブーリアンリテラルはtrue又はfalseを記述します。

```
boolean_literal ::= "true" | "false"
```

### 配列リテラル

配列リテラルを使う事で、配列の初期化を行う事が出来ます。

```
array_literal ::= '[' assign_expression { ',' assign_expression } ']'
```

### 数値リテラル

数値を表すリテラルは、浮動小数点リテラルと整数リテラルがあります。

```
numeric_literal ::= float_literal | integer_literal
```

## 式 expression

```
expression ::= assign_expression
```

### 二項演算子式 binary operator expression

```
commma_expression ::=
    assign_expression
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

add_sub_expression ::=
	mul_div_rem_expression { '+' mul_div_rem_expression }
  | unary_expression { '-' mul_div_rem_expression }
mul_div_rem_expression ::= unary_expression { ('*' | '/' | '%') unary_expression }
```

### 前置演算子式 unary expression

```
unary_expression ::= postfix_expression
  | { '-' | '+' | '*' | '&' | "new" } unary_expression
```

### 後置演算子式 postfix expression

```
postfix_expression ::= primary_expression
  | primary_expression { '.' identifier_value_set }
  | primary_expression '[' [ expression ] ']'
  | primary_expression argument_list

argument_list ::= | '(' ')' | '(' [ assign_expression { ',' assign_expression } ] ')'
```

### プライマリ式 primary expression

```
primary_expression ::= primary_value | '(' expression ')' | lambda_expression
```

### ラムダ式 lambda expression

```
lambda_expression ::= lambda_introducer
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    decl_attribute_list
    [ type_specifier ]
    function_body_statements_list_for_lambda

lambda_introducer ::= '\'
```

## 文 statements

文鳥言語には文鳥なだけに文が沢山あります。
よくあるプログラミング言語の文は文鳥言語ではプログラム本体文(program body statement)といいます。

### プログラム本体文 program body statement

```
/* executable scope, such as function, block, lambda, ... */
program_body_statement ::=
    block_statement
  | variable_declaration_statement
  | control_flow_statement
  | return_statement
  | empty_statement
  | expression_statement /* NOTE: this statement must be set at last */
```

### ブロック文 block statement

ブロック分はプログラム本体文を複数まとめて記述したものです。

```
block_statement ::= '{' program_body_statements '}'
program_body_statements ::= { program_body_statement }
```

### 値宣言文 variable declaration statement

値宣言文 variable declaration statement は値の宣言を行います。
値を宣言する際には、 `val` または `ref` を使って保存する種別を指定します。

```
variable_declaration_statement ::= variable_declaration statement_termination

variable_holder_kind_specifier ::= "val" | "ref"

variable_declaration ::= variable_holder_kind_specifier variable_initializer_unit

variable_initializer_unit ::= identifier_relative decl_attribute_list value_initializer_unit 
```

### コントロールフロー文 control flow statement

コントロールフロー文には `while` 文と `if` 文があります。

```
control_flow_statement ::= while_statement | if_statement
```

#### while 文 while statement

while文は `expression` の評価した値が `true` なら `program_body_statement` を評価し、再度 `expression`を評価します。
`expression` の評価値が `false` なら `program_body_statement` を評価しません。
`break` , `continue` はありません。

```
while_statement ::= "while" '(' expression ')' program_body_statement
```

#### if 文 if statement

`if` 文はよくあるC言語と同様です。 `expression` を評価し `true` なら `program_body_statement` を評価し `false` なら何もしません。`if` `else` 文は `expression` を評価し `true` なら `else` の手前の `program_body_statement` を評価し、 `false` なら `else` の後ろの `program_body_statement` を評価します。
`if` `else` 文は連続して記述する事が出来ます。

```
if_statement ::=
	"if" '(' expression ')' program_body_statement
  | "if" '(' expression ')' program_body_statement "else" program_body_statement
```

### return 文 return statement

`return` 文は関数から値を返します。

```
statement_termination ::= ';'
return_statement ::= "return" expression statement_termination
```

### empty 文 empty statement

`empty` 文は ';' だけを記述した物で何も行いません。

```
empty_statement ::= statement_termination
```

### 式文 expression statement

式文は式の評価のみ行います。

```
expression_statement ::= expression statement_termination
```

## テンプレートパラメータ値宣言 template parameter variable declaration

```
template_parameter_variable_declaration ::=
    template_parameter_variable_initializer_unit

template_parameter_variable_initializer_unit ::=
    identifier_relative [ value_initializer_unit ]

template_parameter_variable_declaration_list ::=
    '!' '(' ')'
  | '!' '(' template_parameter_variable_declaration
            { ','  template_parameter_variable_declaration }
        ')'
```

## トップレベル文 top level statement

```
top_level_statement ::=
    function_definition_statement
  | class_definition_statement
  | extern_statement
  | import_statement
  | empty_statement
  | expression_statement /* this rule must be located at last */
```

トップレベルではトップレベル文シーケンス中の最後にのみ式の記述が出来ます。

## 関数定義文 function definition statement

```
function_definition_statement ::=
    "def" identifier_relative
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    decl_attribute_list
    [ type_specifier ]
    function_body_block

function_body_statements_list ::=
    '{' program_body_statements '}'
  | function_online_body_for_normal

function_body_statements_list_for_lambda ::=
    '{' program_body_statements '}'
  | function_online_body_for_lambda

function_online_body_for_normal ::= "=>" expression statement_termination

function_online_body_for_lambda ::= "=>" expression

function_body_block ::= function_body_statements_list
```

### extern文 extern statement

```
extern_statement ::=
    "extern" extern_function_declaration_statement statement_termination
  | "extern" extern_class_declaration_statement statement_termination

extern_function_declaration_statement ::=
    "def"
    identifier_relative
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    extern_decl_attribute_list
    type_specifier
    string_literal_sequence

extern_class_declaration_statement ::=
    "class"
    identifier_relative
    [ template_parameter_variable_declaration_list ]
    extern_decl_attribute_list
    string_literal_sequence

extern_decl_attribute_list ::= decl_attribute_list
```

### import文 import statement

```
import_statement ::=
    "import" import_decl_unit_list statement_termination

import_decl_unit ::= normal_identifier_sequence

import_decl_unit_list ::= import_decl_unit { ',' import_decl_unit }
```

### クラス定義文 class definition statement

```
class_definition_statement ::=
    "class"
    identifier_relative
    [ template_parameter_variable_declaration_list ]
    [ base_class_type ]
    [ mixin_traits_list ]
    decl_attribute_list
    class_body_block

base_class_type ::= '>' id_expression

mixin_traits_list ::= '[' [ id_expression { ',' id_expression } ] ']'

class_body_block ::= '{' class_body_statements '}'
```

#### クラス本体文 class body statement

```
class_body_statement ::=
    class_virtual_function_definition_statement
  | class_function_definition_statement
  | class_variable_declaration_statement
  | empty_statement

class_body_statements ::= { class_body_statement }

class_function_definition_statement ::=
    "def"
    identifier_relative
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    decl_attribute_list
    [ class_variable_initializers ]
    [ type_specifier ]
    function_body_block

class_virtual_function_definition_statement ::=
    "virtual" "def"
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier
    function_body_block

  | "virtual" "def"
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier
    statement_termination

  | "virtual" "def"
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    function_body_block

class_variable_initializers ::=
    '|' /* work around to avoid this rule to be adapted to vector(pass type at random) */
    class_variable_initializer_list


class_variable_initializer_list ::=
    class_variable_initializer_unit { ',' class_variable_initializer_unit }


class_variable_initializer_unit ::=
    identifier_relative value_initializer_unit_only_value

class_variable_declaration_statement ::=
    variable_declaration statement_termination
```

## プログラム program

```
program ::= module eof

module ::= top_level_statements

top_level_statements ::= { top_level_statement }
```

## 参考URL reference

* http://askra.de/software/ocaml-doc/3.12/full-grammar.html
* http://scala-lang.org/files/archive/spec/2.11/13-syntax-summary.html
* http://qiita.com/esumii/items/0eeb30f35c2a9da4ab8a
* http://www.kmonos.net/alang/d/lex.html
* https://www.haskell.org/onlinereport/haskell2010/haskellch2.html#x7-140002
* http://docs.ruby-lang.org/ja/1.8.7/doc/spec=2fbnf.html
