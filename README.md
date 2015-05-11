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
| \\       | バックスラッシュ (\)      |
| \"       | 二重引用符（"）           |
| \'       | 単一引用符（'）           |
| \n       | 改行（LF）               |
| \r       | キャリッジリターン（CR）    |
| \t       | 水平タブ（TAB）           |
| \b       | バックスペース（BS）       |
| \ スペース | スペース（SPC）           |
| \DDD     | 文字DDDはASCIIコードの8進数 |
| \x HH    | 文字HHはASCIIコードの16進数 |

### ブーリアンリテラル

```
boolean_literal ::= "true" | "false"
```

## Context-free Syntax

### リテラル literals

```
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
