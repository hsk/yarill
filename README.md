# Yarill Programming Language

Yarill is yet another rill programming language.

今はまだ開発中です。

オリジナルのrill言語はこちらです: https://github.com/yutopp/rill

## requipments

* OCaml 4.0.0 or leter
* OMake
* ppx_deriving

## build

    $ make

## test

    $ make test

## clean

    $ make clean

# 文法 grammer

## はじめに Foreword

このドキュメントは、Rill言語のリファレンスマニュアルとなる事を目指しています。
言語構造を示し、正確な構文を提供します。

## 表記法 Notations

言語の構文はBNFのような記法で記述されています。終端記号はセミコロン''あるいはダブルクォーテーション""で括ってあります。非終端記号は小文字から始まる識別子によって記述します。
角カッコ `[…]` は、省略可能である事を示しています。
中括弧 `{…}` は、囲まれた部分が0回以上の繰り返しを表します。プラスの記号 `+` は1回以上の繰り返しを意味します。
括弧 `(…)` はグループを表します。


## 字句解析 Lexical Conventions

コンパイラはプログラムのソーステキストを読み込み、字句解析したあと構文解析します。
字句(Token)を以下に定義します。

### ブランク blank

スペース' '、水平タブ'\t'、キャリッジリターン'\r'、ラインフィード'\n'の文字はブランクです。
ブランクは無視されますが、それらは隣接する識別子、リテラルおよびそれ以外の場合は、単一の識別子、リテラルまたはキーワードとして混同されることになるキーワードを区切ります。

### コメント

コメントは `/*` と `*/` で括られたブロックコメントと `//` から改行までの1ラインコメントがあります。

```
/* ブロックコメント */
```

ブロックコメントはネストする事が出来ません。

```
// 1ラインコメント
```

コメントは空白文字としてコンパイラによって扱われます。文字列リテラルの内部で `/*` や `//` があってもコメントにはなりません。

### キーワード Keyword

```
op pre post true false val ref onlymeta meta intrinsic override while if else return def extern import class virtual
```

### 識別子 Identifier

```
digit_charset ::= '0' | … | '9'
nondigit_charset ::= 'A' | … | 'Z' | 'a' | … | 'z' | '_'
normal_identifier_sequence ::= nondigit_charset { nondigit_charset | digit_charset }
operator_identifier_sequence ::= "op" ["pre" | "post"] ("==" | "!=" | "||" | "&&" | "<=" | ">=" | "<<" | ">>" | '(' ')' | '[' ']' | "|" | "^" | "&" | "+" | "-" | "*" | "/" | "%" | "<" | ">" | "=") | "op"
identifier_sequence ::= operator_identifier_sequence | normal_identifier_sequence
```

識別子は、標準識別子と演算子識別子の２種類あります。

標準識別子は文字または _ (アンダースコア文字) で始まり、文字、アンダースコア、数字の0個以上のシーケンスです。
文字はASCIIセットから少なくとも52大文字と小文字が含まれています。
演算子識別子は `op` を書き、前置演算子を表す `pre` あるいは後置演算子を表す `post` をオプションで、演算子記号(例えば `==`)を記述します。 `pre` または `post` が無い場合は2項演算子を表します。`op` 単体では、標準識別子として扱える。

TODO: 演算子識別子は字句解析で扱うわけではないので、分離する。

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
    [ '-' ] digit_charset { digit_charset | '_' }  
  | [ '-' ] (0x | 0X) (digit_charset | 'A' … 'F' | 'a' … 'f') { digit_charset | 'A' … 'F' | 'a' … 'a' |  '_' }
  | [ '-' ] ("0o" | "0O") ('0' … '7') { '0' … '7' | '_' }  
  | [ '-' ] ("0b" | "0B") ('0' … '1') { '0' … '1' | '_' }
```

TODO: この仕様でよいか確認する。

### 浮動小数点数リテラル

浮動小数点リテラルは浮動小数点数を表します。例えば `1.0` のような文字列です。
`1.toString()` のようなことを可能にする為に、小数点数を省略出来なくなっています。
`1.` は浮動小数点数ではない事に注意してください。

```
float_literal ::=
    digit_charset+ '.' digit_charset+ [exponent_part] [float_type]
  | '.' digit_charset+ [exponent_part] [float_type]
  | digit_charset+ exponent_part [float_type]
  | digit_charset+ float_type
sign ::= '+' | '-'
exponent_part ::= ('e' | 'E') [sign] digit_charset+
float_type ::= 'f' | 'l' | 'F' | 'L'
```

### 文字列リテラル

文字列リテラルは、'"'(二重引用符)文字で括られます。
2つの二重引用符は異なるいずれかの文字列を囲む'"'と'\'、または文字リテラルの上に与えられたテーブルからエスケープシーケンスです。
二重引用符を文字列に含みたい場合はエスケープシーケンスを使い"\""と記述します。

複数行渡って文字列リテラルを記述する事も可能です。

現在の実装では、文字列リテラルの長さに実質的に制限がありません。

```
escape_sequence ::= "\\" | '\"' | "\'" | "\n" | "\r" | "\t" | "\b" | "\ " | "\DDD" | "\xHH"
string_literal_sequence ::= '"' { (escape_sequence | char - '"') } '"'
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
| \DDD     | 文字DDDはASCIIコードの10進数 |
| \x HH    | 文字HHはASCIIコードの16進数 |

## 文脈自由文法 context-free syntax

## プライマリ値 primary value

```
primary_value ::=
    boolean_literal
  | numeric_literal
  | string_literal
  | array_literal
  | identifier_value_set
```

### ブーリアンリテラル boolean literal

ブーリアンリテラルはブール値の真を `true` 、偽を `false` で表します。

```
boolean_literal ::= "true" | "false"
```

### 数値リテラル numeric literal

数値を表すリテラルは、浮動小数点リテラルと整数リテラルがあります。

```
numeric_literal ::= integer_literal | float_literal
```

### 文字列リテラル string literal

文字列を表すリテラルは文字列シーケンスそのものです。

```
string_literal ::= string_literal_sequence
```

### 配列リテラル array literal

配列リテラルで配列の初期化が出来ます。

```
array_literal ::= '[' [ assign_expression { ',' assign_expression }] ']'
```

### 識別子値集合 indentifier value set

```
identifier_value_set ::=
    template_instance_identifier | identifier

identifier ::=
    identifier_from_root | identifier_relative

identifier_relative ::= identifier_sequence

identifier_from_root ::= '.' identifier_sequence

template_instance_identifier ::=
    template_instance_identifier_from_root
  | template_instance_identifier_relative

template_instance_identifier_relative ::=
    identifier_sequence template_argument_list

template_instance_identifier_from_root ::=
    '.' identifier_sequence template_argument_list

template_argument_list ::=
    '!' (argument_list | primary_expression)

argument_list ::=
    '(' [ assign_expression { ',' assign_expression } ] ')'
```

## 式 expression

式(expression)は代入式(assign\_expression)です。C言語のようなカンマ区切の式は書けません。

```
expression ::= assign_expression
```

### 二項演算子式 binary operator expression

二項演算子は "," "=" "||" "&&" "|" "^" "&" "==" "!=" "<=" "<" ">=" ">" "<<" ">>" "+" "-" "*" "/" "%" があります。

```
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

優先順位は表のようになります。

| 優先順位 | 演算子 | 結合性 |
| ------ | ----- | ----- |
| 1 | "="   | なし |
| 2 | "||"  | 左 |
| 3 | "&&"  | 左 |
| 4 | "|"  | 左 |
| 5 | "^"  | 左 |
| 6 | "&"  | 左 |
| 7 | "==" "!=" | 左 |
| 8 | "<=" "<" ">=" ">" | 左 |
| 9 | "<<" ">>" | 左 |
| 10 | "+" | 左 |
| 11 | "-" | 左 |
| 12 | "*" "/" "%" | 左 |

### 前置演算子式 unary expression

前置演算子は '-' '+' '*' '&' "new"があります。

```
unary_expression ::= postfix_expression
  | ('-' | '+' | '*' | '&' | "new") unary_expression
```

### 後置演算子式 postfix expression

 '.' は、構造体やクラスのメンバにアクセスする為に用いる２項演算子です。
 '[' ']'は配列アクセスをするために用います。
 '(' ')'は関数を呼び出す式で、','で区切ってパラメータを複数指定出来ます。

```
postfix_expression ::= primary_expression
  | postfix_expression '.' identifier_value_set
  | postfix_expression '[' [ expression ] ']'
  | postfix_expression argument_list
```

### プライマリ式 primary expression

プライマリ式はプライマリ値か、括弧 '(' ')' で括った式か、ラムダ式です。

```
primary_expression ::= primary_value | '(' expression ')' | lambda_expression
```

ラムダ式は、名前のない関数を作成出来る機能ですが、関数本体の定義が必要になるため、後述します。

## 型指定子 type specifier

型の指定は':'の後ろに識別子式を書きます。
id\_expressionはconditional\_expression なので、様々な演算を行う事が可能です。

```
type_specifier ::= ':' id_expression
id_expression ::= conditional_expression
```

## 属性宣言 declare attribute

属性宣言 decl\_attribute は "onlymeta" "meta" "intrinsic" "override" のいずれかを指定します。
属性宣言リストは属性宣言を',' で区切ったシーケンスです。

```
decl_attribute ::= "onlymeta" | "meta" | "intrinsic" | "override"
decl_attribute_list ::= [ decl_attribute { ',' decl_attribute } ]
```

## プログラム本体文 program body statement

文鳥言語には文鳥なだけに文が沢山あります。
よくあるプログラミング言語の文は文鳥言語ではプログラム本体文(program body statement)といいます。

```
program_body_statement ::=
    variable_declaration_statement
  | empty_statement
  | return_statement
  | expression_statement
  | block_statement
  | control_flow_statement

```

### 分担端末子 statement termination

セミコロンは文の終わりを表します。

```
statement_termination ::= ';'
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

### 値初期化 value initializer unit

 `:int = 5`、`= 5`、 `:int` のような式を値を初期化する為に使います。

```
value_initializer_unit ::=
    type_specifier '=' expression
  | '=' expression
  | type_specifier
```

### empty 文 empty statement

`empty` 文は ';' だけを記述した物で何も行いません。

```
empty_statement ::= statement_termination
```

### return 文 return statement

`return` 文は関数から値を返します。

```
return_statement ::= "return" expression statement_termination
```

### 式文 expression statement

式文は式の評価のみ行います。

```
expression_statement ::= expression statement_termination
```

### ブロック文 block statement

ブロック分はプログラム本体文を複数まとめて記述したものです。

```
block_statement ::= '{' program_body_statements '}'
program_body_statements ::= { program_body_statement }
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

### テンプレートパラメータ値宣言 template parameter variable declaration

```
template_parameter_variable_declaration ::=
    template_parameter_variable_initializer_unit

template_parameter_variable_initializer_unit ::=
    identifier_relative [ value_initializer_unit ]

template_parameter_variable_declaration_list ::=
    '!' '(' ')'
  | '!' '(' template_parameter_variable_declaration
            { ',' template_parameter_variable_declaration }
        ')'
```

### パラメータ値宣言 parameter variable declaration

```
parameter_variable_declaration ::=
    parameter_variable_holder_kind_specifier
    parameter_variable_initializer_unit

parameter_variable_holder_kind_specifier ::= [ "val" | "ref" ]
parameter_variable_initializer_unit ::=
    value_initializer_unit
  | identifier_relative value_initializer_unit

parameter_variable_declaration_list ::=
    '(' ')'
  | '(' parameter_variable_declaration { ',' parameter_variable_declaration } ')'
```

## 関数定義文 function definition statement

```
function_definition_statement ::=
    "def" identifier_relative
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    decl_attribute_list
    [ type_specifier ]
    function_body_block

function_body_block ::=
    '{' program_body_statements '}'
  | "=>" expression statement_termination

```

### ラムダ式 lambda expression

ラムダ式は、名前のない関数を定義して用いる事が出来ます。

```
lambda_expression ::= '\'
    [ template_parameter_variable_declaration_list ]
    parameter_variable_declaration_list
    decl_attribute_list
    [ type_specifier ]
    lambda_of_function_body_statements_list

lambda_of_function_body_statements_list ::=
    '{' program_body_statements '}'
  | "=>" expression
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

class_body_block ::= '{' { class_body_statements } '}'
```

#### クラス本体文 class body statement

```
class_body_statement ::=
    empty_statement
  | class_function_definition_statement
  | class_virtual_function_definition_statement
  | class_variable_declaration_statement

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
    [ type_specifier ]
    (function_body_block | statement_termination)

class_variable_initializers ::=
    '|' class_variable_initializer_list

class_variable_initializer_list ::=
    class_variable_initializer_unit { ',' class_variable_initializer_unit }

class_variable_initializer_unit ::=
    identifier_relative value_initializer_unit_only_value

class_variable_declaration_statement ::=
    variable_declaration statement_termination
```

## プログラム program

```
program ::= top_level_statements eof
top_level_statements ::= { top_level_statement }
```

## 参考URL reference

* http://askra.de/software/ocaml-doc/3.12/full-grammar.html
* http://scala-lang.org/files/archive/spec/2.11/13-syntax-summary.html
* http://qiita.com/esumii/items/0eeb30f35c2a9da4ab8a
* http://www.kmonos.net/alang/d/lex.html
* https://www.haskell.org/onlinereport/haskell2010/haskellch2.html#x7-140002
* http://docs.ruby-lang.org/ja/1.8.7/doc/spec=2fbnf.html
