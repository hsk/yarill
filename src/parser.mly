%{

(*
/* code grammar */

program:
  | module eof { $1 }

module:
  | top_level_statements { $1 }

top_level_statements:
  | { [] }
  | top_level_statement top_level_statements { $1::$2 }

top_level_statement :
  | function_definition_statement { $1 }
  | class_definition_statement { $1 }
  | extern_statement { $1 }
  | import_statement { $1 }
  | empty_statement { $1 }
  | expression_statement { $1 (* this rule must be located at last *) }

function_definition_statement:
  | DEF identifier_relative
    -template_parameter_variable_declaration_list
    parameter_variable_declaration_list
    decl_attribute_list
    -type_specifier
    function_body_block
    { Function_definition_statement($3, $2, $4, $5, $6, $7) }

function_body_statements_list:
  | LBRACE program_body_statements RBRACE { $2 }
  | function_online_body_for_normal { $1 }

function_body_statements_list_for_lambda:
  | LBRACE program_body_statements RBRACE { $2 }
  | function_online_body_for_lambda { $1 }

function_online_body_for_normal:
  | ARROW expression statement_termination { $2 }

function_online_body_for_lambda:
  | ARROW expression { $2 }

function_body_block:
  | function_body_statements_list { $1 }

/* executable scope, such as function, block, lambda, ... */
program_body_statement:
  | block_statement { $1 }
  | variable_declaration_statement { $1 }
  | control_flow_statement { $1 }
  | return_statement { $1 }
  | empty_statement { $1 }
  | expression_statement { $1 }   /* NOTE: this statement must be set at last */

program_body_statements:
  | { [] }
  | program_body_statement program_body_statements { $1::$2 }

block_statement:
  | LBRACE program_body_statements RBRACE { $1 }

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
  | -identifier_relative value_initializer_unit { ($1,$2) }

parameter_variable_declaration_list:
  | LPAREN RPAREN { [] }
  | LPAREN parameter_variable_declaration % x3::lit( COMMA ) RPAREN { $2 }

/* value initializer unit
 * Ex.
 * :int = 5
 * = 5
 * :int
 */
value_initializer_unit:
  | value_initializer_unit_only_value { assign }
  | type_specifier -(EQ expression)
      { ($1, $2) }

value_initializer_unit_only_value:
  | EQ expression
      { $2 }

/* ==================================================================================================== */
type_specifier:
  | COLON id_expression { $2 }

decl_attribute:
  | ONLYMETA { AOnlymeta }
  | META { AMeta }
  | INTRINSIC { AIntrinsic }
  | OVERRIDE { AOverride }

decl_attribute_list:
  | decl_attribute[merged_bitflag( $1 )] % COMMA
  | x3::eps

/* ==================================================================================================== */
/* ==================================================================================================== */
class_definition_statement:
  | CLASS
    identifier_relative
    -template_parameter_variable_declaration_list
    -base_class_type
    -mixin_traits_list
    decl_attribute_list
    class_body_block
    { ClassDefinitionStatement($3, $2, $4, $5, $6, $7) }

base_class_type:
  | LT id_expression { $2 }

mixin_traits_list:
  | LBRACK  (id_expression % COMMA) RBRACK { $2 }

class_body_block:
  | LBRACE class_body_statements RBRACE { $2 }


/* ==================================================================================================== */

class_body_statement:
  | class_virtual_function_definition_statement { $1 }
  | class_function_definition_statement { $1 }
  | class_variable_declaration_statement { $1 }
  | empty_statement { $1 }

class_body_statements:
  | *class_body_statement { $1 }


class_function_definition_statement:
  | DEF
    identifier_relative
    -template_parameter_variable_declaration_list
    parameter_variable_declaration_list
    decl_attribute_list
    -class_variable_initializers
    -type_specifier
    function_body_block
    { ClassFunctionDefinitionStatement($2, $1, $3, $4, $5, $6, $7) }

class_virtual_function_definition_statement:
  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier
    function_body_block
    { ClassVirtualFunctionDefinitionStatement($1, $2, $3, $4, $5) }

  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    type_specifier
    statement_termination
    { ClassVirtualFunctionDefinitionStatement($1, $2, $3, $4) }

  | VIRTUAL DEF
    identifier_relative
    parameter_variable_declaration_list
    decl_attribute_list
    function_body_block
    { ClassVirtualFunctionDefinitionStatement($1, $2, $3, $4) }

class_variable_initializers:
  | BAR /* work around to avoid this rule to be adapted to vector(pass type at random) */
    class_variable_initializer_list
    { ClassVariableInitializers($2) }


class_variable_initializer_list:
  | class_variable_initializer_unit % COMMA
    { }


class_variable_initializer_unit:
  | identifier_relative value_initializer_unit_only_value
    { VariableDeclarationUnit($1, ADefault, $2) }



class_variable_declaration_statement:
  | variable_declaration statement_termination
    { ClassVariableDeclarationStatement($1) }


/* ==================================================================================================== */
/* ==================================================================================================== */

extern_statement:
  | EXTERN extern_function_declaration_statement statement_termination { }
  | EXTERN extern_class_declaration_statement statement_termination { }
    

extern_function_declaration_statement:
  | DEF
    identifier_relative
    -template_parameter_variable_declaration_list
    parameter_variable_declaration_list
    extern_decl_attribute_list
    type_specifier
    string_literal_sequence
    { ExternFunctionDeclarationStatement($2, $1, $3, $4, $5, $6) }

extern_class_declaration_statement:
  | CLASS
    identifier_relative
    -template_parameter_variable_declaration_list
    extern_decl_attribute_list
    string_literal_sequence
    { ExternClassDeclarationStatement($2, $1, $3, $4) }

extern_decl_attribute_list:
  | decl_attribute_list { AExtern :: $1 }


/* ==================================================================================================== */
/* ==================================================================================================== */

template_parameter_variable_declaration:
  | template_parameter_variable_initializer_unit { VariableDeclaration(ARef, $1) }

template_parameter_variable_initializer_unit:
  | identifier_relative -value_initializer_unit
    { VariableDeclarationUnit($1, ADefault, $2) (* TODO: decl::onlymeta? *) }


template_parameter_variable_declaration_list:
  | NOT LPAREN RPAREN  { }
  | NOT LPAREN (template_parameter_variable_declaration % COMMA) RPAREN { }

/* ==================================================================================================== */
/* ==================================================================================================== */
import_statement:
  | IMPORT import_decl_unit_list statement_termination
    { ImportStatement($2) }

import_decl_unit:
  | normal_identifier_sequence { ImportDeclUnit($1) }

import_decl_unit_list:
  | (import_decl_unit % COMMA) { $1 }

/* ==================================================================================================== */
/* ==================================================================================================== */
variable_declaration_statement:
  | variable_declaration statement_termination
    { VariableDeclarationStatement($1) }

variable_holder_kind_specifier:
  | VAL { "val" }
  | REF { "ref" }

variable_declaration:
  | variable_holder_kind_specifier variable_initializer_unit
    { VariableDeclaration($1, $2) }

variable_initializer_unit:
  | identifier_relative decl_attribute_list value_initializer_unit 
    { VariableDeclarationUnit($1, $2, $3) }

/* ==================================================================================================== */
/* ==================================================================================================== */
control_flow_statement:
  | while_statement { $1 }
  | if_statement { $1 }

while_statement:
  | WHILE LPAREN expression RPAREN program_body_statement
    { WhileStatement($1, $2) }

if_statement:
  | IF LPAREN expression RPAREN program_body_statement
    { IfStatement($1, $2, $3) }
  | IF LPAREN expression RPAREN program_body_statement ELSE program_body_statement
    { IfStatement($1, $2, $3) }

/* ==================================================================================================== */
/* ==================================================================================================== */
empty_statement:
  | statement_termination { EmptyStatement }

/* ==================================================================================================== */
/* ==================================================================================================== */
return_statement:
  | RETURN expression statement_termination { $1 }

/* ==================================================================================================== */
/* ==================================================================================================== */
expression_statement:
  | expression statement_termination
    { $1 }

/* ==================================================================================================== */
statement_termination:
  | SEMI { () }

/* ==================================================================================================== */
/* TODO: make id_expression */
id_expression:
  | conditional_expression
    { $1 }

/* ==================================================================================================== */
expression:
  | assign_expression /* NOT commma_expression */ { $1 }

commma_expression:
  | assign_expression { $1 }
  | assign_expression COMMA comma_expression { $1 }

assign_expression:
  | conditional_expression EQ conditional_expression { Bin($1, "=", $3) }

conditional_expression:
  | logical_or_expression { $1 }
    /* TODO: add conditional operator( ? : ) */

logical_or_expression:
  | logical_and_expression { $1 }
  | logical_and_expression BARBAR logical_and_expression { Bin($1, "||", $2) }

logical_and_expression:
  | bitwise_or_expression { $1 }
  | bitwise_or_expression AMPAMP bitwise_or_expression { Bin($1, "&&", $2) }

bitwise_or_expression:
  | bitwise_xor_expression { $1 }
  | bitwise_xor_expression BAR bitwise_xor_expression { Bin($1, "|", $2) }

bitwise_xor_expression:
  | bitwise_and_expression { $1 }
  | bitwise_and_expression XOR bitwise_and_expression { Bin($1, "^", $2) }

bitwise_and_expression:
  | equality_expression { $1 }
  | equality_expression AMP equality_expression { Bin($1, "&", $2) }

equality_expression:
  | relational_expression { $1 }
  | relational_expression EQEQ relational_expression { Bin($1, "==", $2) }
  | relational_expression NE relational_expression { Bin($1, "!=", $2) }

relational_expression:
  | shift_expression { $1 }
  | shift_expression LE shift_expression { Bin($1, "<=", $2 ) }
  | shift_expression LT shift_expression { Bin($1, "<",  $2 ) }
  | shift_expression GE shift_expression { Bin($1, ">=", $2 ) }
  | shift_expression GT shift_expression { Bin($1, ">",  $2 ) }

shift_expression:
  | add_sub_expression { $1 }
  | add_sub_expression LSHIFT add_sub_expression { Bin($1, "<<", $2) }
  | add_sub_expression RSHIFT add_sub_expression { Bin($1, ">>", $2) }

add_sub_expression:
  | mul_div_rem_expression { $1 }
  | mul_div_rem_expression ADD mul_div_rem_expression { Bin($1, "+", $2) }
  | unary_expression SUB mul_div_rem_expression { Bin($1, "-", $2) }
mul_div_rem_expression:
  | unary_expression { $1 }
  | unary_expression MUL unary_expression { Bin($1, "*", $2) }
  | unary_expression DIV unary_expression { Bin($1, "/", $2) }
  | unary_expression REM unary_expression { Bin($1, "%", $2) }

unary_expression:
  | postfix_expression { $1 }
  | SUB unary_expression { Unary("-", $2) }
  | ADD unary_expression { Unary("+", $2) }
  | MUL unary_expression { Unary("*", $2) }
  | AMP unary_expression { Unary("&", $2) }
  | NEW unary_expression { Unary("new", $2) }
    
postfix_expression:
  | primary_expression { $1 }
  | primary_expression DOT identifier_value_set { ElementSelectorExpression($1) }
  | primary_expression LBRACK -expression RBRACK { SubscrptingExpression($1) }
  | primary_expression argument_list { CallExpression ($1) }

primary_expression:
  | primary_value { $1 }
  | LPAREN expression RPAREN { $2 }
  | lambda_expression { $1 }
    
argument_list:
  | LPAREN RPAREN { [] }
  | LPAREN (assign_expression % COMMA) RPAREN { $2 }

/* ==================================================================================================== */
/* ==================================================================================================== */
lambda_expression:
  | lambda_introducer
    -template_parameter_variable_declaration_list
    parameter_variable_declaration_list
    decl_attribute_list
    -type_specifier
    function_body_statements_list_for_lambda
    { LambdaExpression($1, $2, $3, $4, $5) }

lambda_introducer:
  | BACKBACK { () }

/*
parameter_variable_declaration_list
    > decl_attribute_list
    > -type_specifier
    > function_body_block
*/


  *)
(*

/* ==================================================================================================== */
/* ==================================================================================================== */
primary_value:
  | boolean_literal { $1 }
  | identifier_value_set { $1 }
  | numeric_literal { $1 }
  | string_literal { $1 }
  | array_literal { $1 }

/* ==================================================================================================== */
identifier_value_set:
  | template_instance_identifier { $1 }
  | identifier { $1 }

identifier:
  | identifier_from_root { $1 }
  | identifier_relative { $1 }

identifier_relative:
  | identifier_sequence { IdentifierValue($1, false) }

identifier_from_root:
  | DOT identifier_sequence { IdentifierValue($1, true) }

template_instance_identifier:
  | template_instance_identifier_from_root { $1 }
  | template_instance_identifier_relative { $1 }

template_instance_identifier_relative:
  | identifier_sequence template_argument_list
    { TemplateInstanceValue($1, $2, false) }

template_instance_identifier_from_root:
  | DOT identifier_sequence template_argument_list
    { TemplateInstanceValue($1, $2, true) }

template_argument_list:
  | NOT argument_list { }
  | NOT primary_expression { ExpressionList($2) }

/* ==================================================================================================== */
numeric_literal:
  | float_literal { $1 }
  | integer_literal { $1 }

integer_literal:
  | INT { Int32Value($1) }

/* TODO: check range */
float_literal:
  | FLOAT { FloatValue($1) }

/* TODO: */
/*
fp <-
( fractional_constant >> -exponent_part>> -floating_suffix )
| ( +digit_charset >> exponent_part >> -floating_suffix )

fractional_constant <-
    +digit_charset >> x3::lit( '.' ) >> +digit_charset

sign <-
    lit('+') | lit('-')

exponent_part <-
    (lit('e') | 'E') >> -sign >> +digit_charset

floating_suffix <-
    lit('f') | 'l' | 'F' | 'L'
*/


/* ==================================================================================================== */
boolean_literal:
  | TRUE { true }
  | FALSE { false }

/* ==================================================================================================== */
array_literal:
  | LBRACK RBRACK { ArrayValue [] }
  | LBRACK ( assign_expression % COMMA ) RBRACK { ArrayValue $2 }

/* ==================================================================================================== */
string_literal:
  | string_literal_sequence
    { StringValue($1) }

string_literal_sequence:
  | STRING_LITERAL_SEQUENCE { $1 }
    

escape_sequence:
  | "\\n" { '\n' }
*)

%}

%token <string> NORMAL_IDENTFIRE_SEQUENCE
%token OP PRE POST
%token EQ NE LOR LAND LE GE LSHIFT RSHIFT
%token LPAREN RPAREN LBRACKET RBRACKET
%token OR XOR AND ADD SUB MUL DIV REM LT GT ASSIGN
%token EOF
%type <string> identifier_sequence
%start identifier_sequence

%%

/* ==================================================================================================== */
/* ==================================================================================================== */
identifier_sequence:
  | operator_identifier_sequence { $1 }
  | normal_identifier_sequence { $1 }

normal_identifier_sequence:
  | NORMAL_IDENTFIRE_SEQUENCE { $1 }

operator_identifier_sequence:
  | OP op_assoc EQ { $2 ^ "==" }
  | OP op_assoc NE { $2 ^ "!=" }
  | OP op_assoc LOR { $2 ^ "||" }
  | OP op_assoc LAND { $2 ^ "&&" }
  | OP op_assoc LE { $2 ^ "<=" }
  | OP op_assoc GE { $2 ^ ">=" }
  | OP op_assoc LSHIFT { $2 ^ "<<" }
  | OP op_assoc RSHIFT { $2 ^ ">>" }
  | OP op_assoc LPAREN RPAREN { $2 ^ "()" }
  | OP op_assoc LBRACKET RBRACKET { $2 ^ "[]" }
  | OP op_assoc OR { $2 ^ "|" }
  | OP op_assoc XOR { $2 ^ "^" }
  | OP op_assoc AND { $2 ^ "&" }
  | OP op_assoc ADD { $2 ^ "+" }
  | OP op_assoc SUB { $2 ^ "-" }
  | OP op_assoc MUL { $2 ^ "*" }
  | OP op_assoc DIV { $2 ^ "/" }
  | OP op_assoc REM { $2 ^ "%" }
  | OP op_assoc LT { $2 ^ "<" }
  | OP op_assoc GT { $2 ^ ">" }
  | OP op_assoc ASSIGN { $2 ^ "=" }

op_assoc:
  | PRE { "pre" }
  | POST { "post" }
  | { "" }

