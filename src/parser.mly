%{

open Ast

%}

%token <string> NORMAL_IDENTFIRE_SEQUENCE
%token <int> INTEGER_LITERAL
%token <float> FLOAT_LITERAL
%token <string> STRING_LITERAL_SEQUENCE
%token OP PRE POST
%token EQ NE LOR LAND LE GE LSHIFT RSHIFT
%token LPAREN RPAREN LBRACKET RBRACKET
%token OR XOR AND ADD SUB MUL DIV REM LT GT ASSIGN
%token TRUE FALSE
%token NOT NEW
%token DOT COMMA 
%token LBRACE RBRACE
%token SEMI
%token VAL REF
%token COLON
%token ONLYMETA META INTRINSIC OVERRIDE
%token IF ELSE WHILE RETURN
%token ARROW DEF
%token EXTERN IMPORT CLASS VIRTUAL
%token BACKSLASH
%token EOF
%type <string> identifier_sequence
%start identifier_sequence
%type <int> integer_literal
%start integer_literal
%type <float> float_literal
%start float_literal
%type <string> string_literal_sequence
%start string_literal_sequence
%type <Ast.e> expression
%start expression
%type <Ast.s> program_body_statement
%start program_body_statement
%type <Ast.ts list> program
%start program

%%

identifier_sequence:
  | operator_identifier_sequence { $1 }
  | normal_identifier_sequence { $1 }

normal_identifier_sequence:
  | NORMAL_IDENTFIRE_SEQUENCE { $1 }

operator_identifier_sequence:
  | OP op_assoc EQ { "%op_" ^ $2 ^ "==" }
  | OP op_assoc NE { "%op_" ^ $2 ^ "!=" }
  | OP op_assoc LOR { "%op_" ^ $2 ^ "||" }
  | OP op_assoc LAND { "%op_" ^ $2 ^ "&&" }
  | OP op_assoc LE { "%op_" ^ $2 ^ "<=" }
  | OP op_assoc GE { "%op_" ^ $2 ^ ">=" }
  | OP op_assoc LSHIFT { "%op_" ^ $2 ^ "<<" }
  | OP op_assoc RSHIFT { "%op_" ^ $2 ^ ">>" }
  | OP op_assoc LPAREN RPAREN { "%op_" ^ $2 ^ "()" }
  | OP op_assoc LBRACKET RBRACKET { "%op_" ^ $2 ^ "[]" }
  | OP op_assoc OR { "%op_" ^ $2 ^ "|" }
  | OP op_assoc XOR { "%op_" ^ $2 ^ "^" }
  | OP op_assoc AND { "%op_" ^ $2 ^ "&" }
  | OP op_assoc ADD { "%op_" ^ $2 ^ "+" }
  | OP op_assoc SUB { "%op_" ^ $2 ^ "-" }
  | OP op_assoc MUL { "%op_" ^ $2 ^ "*" }
  | OP op_assoc DIV { "%op_" ^ $2 ^ "/" }
  | OP op_assoc REM { "%op_" ^ $2 ^ "%" }
  | OP op_assoc LT { "%op_" ^ $2 ^ "<" }
  | OP op_assoc GT { "%op_" ^ $2 ^ ">" }
  | OP op_assoc ASSIGN { "%op_" ^ $2 ^ "=" }

op_assoc:
  | PRE { "pre_" }
  | POST { "post_" }
  | { "" }

integer_literal:
  | INTEGER_LITERAL { $1 }

float_literal:
  | FLOAT_LITERAL { $1 }

string_literal_sequence:
  | STRING_LITERAL_SEQUENCE { $1 }

/* ==================================================================================================== */
primary_value:
  | boolean_literal { $1 }
  | array_literal { $1 }
  | numeric_literal { $1 }
  | string_literal { $1 }
  | identifier_value_set { $1 }

boolean_literal:
  | TRUE { EBool true }
  | FALSE { EBool false }

numeric_literal:
  | float_literal { EFloat $1 }
  | integer_literal { EInt $1 }

string_literal:
  | string_literal_sequence
    { EString($1) }

array_literal:
  | LBRACKET RBRACKET { EArray [] }
  | LBRACKET assign_expression_list RBRACKET { EArray $2 }

assign_expression_list:
  | assign_expression { [$1] }
  | assign_expression COMMA assign_expression_list { $1 :: $3 }

/* ==================================================================================================== */
identifier_value_set:
  | template_instance_identifier { $1 }
  | identifier { $1 }

identifier:
  | identifier_from_root { $1 }
  | identifier_relative { $1 }

identifier_relative:
  | identifier_sequence { EIdentifier($1, false) }

identifier_from_root:
  | DOT identifier_sequence { EIdentifier($2, true) }

template_instance_identifier:
  | template_instance_identifier_from_root { $1 }
  | template_instance_identifier_relative { $1 }

template_instance_identifier_relative:
  | identifier_sequence template_argument_list
    { ETemplateInstance($1, $2, false) }

template_instance_identifier_from_root:
  | DOT identifier_sequence template_argument_list
    { ETemplateInstance($2, $3, true) }

template_argument_list:
  | NOT argument_list { $2 }
  | NOT primary_expression { [$2] }

/* ==================================================================================================== */
expression:
  | assign_expression /* NOT commma_expression */ { $1 }

expression_opt:
  | { None }
  | expression { Some $1 }

/*
comma_expression:
  | assign_expression { $1 }
  | assign_expression COMMA comma_expression { $1 }
*/
assign_expression:
  | conditional_expression { $1 }
  | conditional_expression ASSIGN conditional_expression { EBin($1, "=", $3) }

conditional_expression:
  | logical_or_expression { $1 }
    /* TODO: add conditional operator( ? : ) */

logical_or_expression:
  | logical_and_expression { $1 }
  | logical_or_expression LOR logical_and_expression { EBin($1, "||", $3) }

logical_and_expression:
  | bitwise_or_expression { $1 }
  | logical_and_expression LAND bitwise_or_expression { EBin($1, "&&", $3) }

bitwise_or_expression:
  | bitwise_xor_expression { $1 }
  | bitwise_or_expression OR bitwise_xor_expression { EBin($1, "|", $3) }

bitwise_xor_expression:
  | bitwise_and_expression { $1 }
  | bitwise_xor_expression XOR bitwise_and_expression { EBin($1, "^", $3) }

bitwise_and_expression:
  | equality_expression { $1 }
  | bitwise_and_expression AND equality_expression { EBin($1, "&", $3) }

equality_expression:
  | relational_expression { $1 }
  | equality_expression EQ relational_expression { EBin($1, "==", $3) }
  | equality_expression NE relational_expression { EBin($1, "!=", $3) }

relational_expression:
  | shift_expression { $1 }
  | relational_expression LE shift_expression { EBin($1, "<=", $3) }
  | relational_expression LT shift_expression { EBin($1, "<",  $3) }
  | relational_expression GE shift_expression { EBin($1, ">=", $3) }
  | relational_expression GT shift_expression { EBin($1, ">",  $3) }

shift_expression:
  | add_sub_expression { $1 }
  | shift_expression LSHIFT add_sub_expression { EBin($1, "<<", $3) }
  | shift_expression RSHIFT add_sub_expression { EBin($1, ">>", $3) }

add_sub_expression:
  | mul_div_rem_expression { $1 }
  | add_sub_expression ADD mul_div_rem_expression { EBin($1, "+", $3) }
  | add_sub_expression SUB mul_div_rem_expression { EBin($1, "-", $3) }
mul_div_rem_expression:
  | unary_expression { $1 }
  | mul_div_rem_expression MUL unary_expression { EBin($1, "*", $3) }
  | mul_div_rem_expression DIV unary_expression { EBin($1, "/", $3) }
  | mul_div_rem_expression REM unary_expression { EBin($1, "%", $3) }

unary_expression:
  | postfix_expression   { $1 }
  | SUB unary_expression { EUnary("-", $2) }
  | ADD unary_expression { EUnary("+", $2) }
  | MUL unary_expression { EUnary("*", $2) }
  | AND unary_expression { EUnary("&", $2) }
  | NEW unary_expression { EUnary("new", $2) }

postfix_expression:
  | primary_expression { $1 }
  | primary_expression DOT identifier_value_set { EElementSelector($1, $3) }
  | primary_expression LBRACKET expression_opt RBRACKET { ESubscrpting($1, $3) }
  | primary_expression argument_list { ECall($1, $2) }

primary_expression:
  | primary_value            { $1 }
  | LPAREN expression RPAREN { $2 }
/*  | lambda_expression        { $1 } */

argument_list:
  | LPAREN RPAREN                        { [] }
  | LPAREN assign_expression_list RPAREN { $2 }

/* ==================================================================================================== */
type_specifier:
  | COLON id_expression { $2 }

id_expression:
  | conditional_expression { $1 }

type_specifier_opt:
  |                { None }
  | type_specifier { Some $1 }

/* ==================================================================================================== */
decl_attribute:
  | ONLYMETA  { AOnlymeta }
  | META      { AMeta }
  | INTRINSIC { AIntrinsic }
  | OVERRIDE  { AOverride }

decl_attribute_list:
  |                          { [] }
  | decl_attribute_list_impl { $1 }

decl_attribute_list_impl:
  | decl_attribute                                { [$1] }
  | decl_attribute COMMA decl_attribute_list_impl { $1 :: $3 }

/* ==================================================================================================== */
/* executable scope, such as function, block, lambda, ... */
program_body_statement:
  | variable_declaration_statement { $1 }
  | empty_statement { $1 }
  | return_statement { $1 }
  | expression_statement { $1 }
  | block_statement { SBlock $1 }
  | control_flow_statement { $1 }

statement_termination:
  | SEMI { () }

/* ==================================================================================================== */
variable_declaration_statement:
  | variable_declaration statement_termination
    { SVariableDeclaration $1 }

variable_holder_kind_specifier:
  | VAL { "val" }
  | REF { "ref" }

variable_declaration:
  | variable_holder_kind_specifier variable_initializer_unit
    { ($1, $2) }

variable_initializer_unit:
  | identifier_relative decl_attribute_list value_initializer_unit
    { ($1, $2, $3) }

/* value initializer unit
 * Ex.
 * :int = 5
 * = 5
 * :int
 */

value_initializer_unit:
  | type_specifier ASSIGN expression { (Some $1, Some $3) }
  | ASSIGN expression                { (None,    Some $2) }
  | type_specifier                   { (Some $1, None   ) }

value_initializer_unit_opt:
  | value_initializer_unit { Some $1 }
  | { None }

/* ==================================================================================================== */
empty_statement:
  | statement_termination { SEmpty }

return_statement:
  | RETURN expression statement_termination { SReturn $2 }

expression_statement:
  | expression statement_termination
    { SExpression $1 }

/* ==================================================================================================== */
block_statement:
  | LBRACE program_body_statements RBRACE { $2 }

program_body_statements:
  | { [] }
  | program_body_statement program_body_statements { $1::$2 }

/* ==================================================================================================== */
control_flow_statement:
  | while_statement { $1 }
  | if_statement { $1 }

while_statement:
  | WHILE LPAREN expression RPAREN program_body_statement
    { SWhile($3, $5) }

if_statement:
  | IF LPAREN expression RPAREN program_body_statement
    { SIf($3, $5, SEmpty) }
  | IF LPAREN expression RPAREN program_body_statement ELSE program_body_statement
    { SIf($3, $5, $7) }

/* ==================================================================================================== */
top_level_statement :
  | function_definition_statement { $1 }
  | extern_statement { $1 }
  | empty_statement { TSEmpty }
  | import_statement { $1 }
  | expression_statement { TSExpression $1 }
  | class_definition_statement { $1 }
/* ==================================================================================================== */
template_parameter_variable_declaration:
  | template_parameter_variable_initializer_unit { $1 }

template_parameter_variable_initializer_unit:
  | identifier_relative value_initializer_unit_opt
    { ($1, ADefault, $2) }

template_parameter_variable_declaration_list:
  | NOT LPAREN RPAREN  { [] }
  | NOT LPAREN template_parameter_variable_declaration_list_impl RPAREN { $3 }

template_parameter_variable_declaration_list_impl:
  | template_parameter_variable_declaration { [$1] }
  | template_parameter_variable_declaration COMMA
    template_parameter_variable_declaration_list_impl { $1 :: $3 }

template_parameter_variable_declaration_list_opt:
  | { None }
  | template_parameter_variable_declaration_list { Some($1) }

/* ==================================================================================================== */
parameter_variable_holder_kind_specifier:
  | VAL { "val" }
  | REF { "ref" }
  | { "ref" }

parameter_variable_declaration:
  | parameter_variable_holder_kind_specifier
    parameter_variable_initializer_unit
    { ($1, $2) }

parameter_variable_initializer_unit:
  |                     value_initializer_unit { (None , $1) }
  | identifier_relative value_initializer_unit { (Some $1, $2) }

parameter_variable_declaration_list:
  | LPAREN RPAREN { [] }
  | LPAREN parameter_variable_declaration_list_impl RPAREN { $2 }

parameter_variable_declaration_list_impl:
  | parameter_variable_declaration { [$1] }
  | parameter_variable_declaration COMMA parameter_variable_declaration_list_impl { $1::$3 }
/* ==================================================================================================== */

function_definition_statement:
  | DEF identifier_relative
    template_parameter_variable_declaration_list_opt
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier_opt
    function_body_block
    { TSFunctionDefinition($3, $2, $4, $5, $6, $7) }

function_body_block:
  | LBRACE program_body_statements RBRACE { $2 }
  | ARROW expression statement_termination { [SExpression $2] }

/* ==================================================================================================== */
lambda_expression:
  | lambda_introducer
    template_parameter_variable_declaration_list_opt
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier_opt
    function_body_statements_list_for_lambda
    { ELambda($2, $3, $4, $5, $6) }

lambda_introducer:
  | BACKSLASH { () }

function_body_statements_list_for_lambda:
  | LBRACE program_body_statements RBRACE { $2 }
  | function_online_body_for_lambda { $1 }

function_online_body_for_lambda:
  | ARROW expression { [SExpression $2] }

/* ==================================================================================================== */
extern_statement:
  | EXTERN extern_function_declaration_statement statement_termination { $2 }
  | EXTERN extern_class_declaration_statement statement_termination { $2 }

extern_function_declaration_statement:
  | DEF
    identifier_relative
    template_parameter_variable_declaration_list_opt
    parameter_variable_declaration_list
    extern_decl_attribute_list
    type_specifier
    string_literal_sequence
    { TSExternFunctionDeclaration($3, $2, $4, $5, $6, $7) }

extern_class_declaration_statement:
  | CLASS
    identifier_relative
    template_parameter_variable_declaration_list_opt
    extern_decl_attribute_list
    string_literal_sequence
    { TSExternClassDeclaration($3, $2, $4, $5) }

extern_decl_attribute_list:
  | decl_attribute_list { AExtern :: $1 }

/* ==================================================================================================== */
import_statement:
  | IMPORT import_decl_unit_list statement_termination
    { TSImport($2) }

import_decl_unit:
  | normal_identifier_sequence { $1 }

import_decl_unit_list:
  | import_decl_unit { [$1] }
  | import_decl_unit COMMA import_decl_unit_list { $1 :: $3 }

/* ==================================================================================================== */
class_definition_statement:
  | CLASS
    identifier_relative
    template_parameter_variable_declaration_list_opt
    base_class_type_opt
    mixin_traits_list_opt
    decl_attribute_list
    class_body_block
    { TSClassDefinition($3, $2, $4, $5, $6, $7) (* ) *) }

base_class_type_opt:
  | { None }
  | LT id_expression { Some $2 }

mixin_traits_list_opt:
  | { [] }
  | LBRACKET mixin_traits_list RBRACKET { $2 }

mixin_traits_list:
  | id_expression { [$1] }
  | id_expression COMMA mixin_traits_list { $1 :: $3 }

class_body_block:
  | LBRACE RBRACE { [] }
  | LBRACE class_body_statements RBRACE { $2 }

/* ==================================================================================================== */

class_body_statement:
  | empty_statement { CEmpty }
  | class_function_definition_statement { $1 }
  | class_virtual_function_definition_statement { $1 }
  | class_variable_declaration_statement { $1 }

class_body_statements:
  | class_body_statement { [$1] }
  | class_body_statement class_body_statements { $1 :: $2 }

class_function_definition_statement:
  | DEF
    identifier_relative
    template_parameter_variable_declaration_list_opt
    parameter_variable_declaration_list
    decl_attribute_list
    class_variable_initializers
    type_specifier_opt
    function_body_block
    { CFunctionDefinition($3, $2, $4, $5, $6, $7, $8) }

class_virtual_function_definition_statement:
  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier_opt
    function_body_block
    { CVirtualFunctionDefinition($3, $4, $5, $6, $7) }

  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier_opt
    statement_termination
    { CVirtualFunctionDefinition($3, $4, $5, $6, []) }

  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    function_body_block
    { CVirtualFunctionDefinition($3, $4, $5, None, $6) }

class_variable_initializers:
  | OR class_variable_initializer_list { $2 }

class_variable_initializer_list:
  | class_variable_initializer_unit { [$1] }
  | class_variable_initializer_unit COMMA class_variable_initializer_list { $1 :: $3 }

class_variable_initializer_unit:
  | identifier_relative ASSIGN expression
    { ($1, $3) }

class_variable_declaration_statement:
  | variable_declaration statement_termination
    { CVariableDeclaration($1) }

/* ==================================================================================================== */
program:
  | top_level_statement_list EOF { $1 }

top_level_statement_list:
  | { [] }
  | top_level_statement top_level_statement_list { $1::$2 }
