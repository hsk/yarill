%{
open Ast
%}

%token <int> INT
%token <string> ID
%token DEF VAL
%token SEMI
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token COLON COMMA
%token ASSIGN
%token RETURN
%token EOF
%token ADD SUB
%token MUL DIV
%token ARROW
%token ONLYMETA
%token META
%token INTRINSIC
%token OVERRIDE
%token CLASS
%left ADD SUB
%left MUL DIV

%type <Ast.s list> decls
%start decls

%%

decls:
| decl { [$1] }
| decl decls { $1 :: $2 }

decl:
| DEF ID LPAREN RPAREN COLON TYPE LBRACE stms RBRACE
    { DFun($2, [], $6, $8) }

simple_exp:
| LPAREN exp RPAREN { $2 }
| INT { EInt($1) }
| STRING { EString($1) }
| ID { EVar($1)}

stms:
| { [] }
| stm stms { $1::$2 }

stm:
| VAL ID ASSIGN LBRACK lists RBRACK SEMI {  } 
exps:
| exp { [$1] }
| exp exps { $1::$2 }

exp:
| simple_exp { $1 }


/*
template<typename L>
auto make_keyword( L&& literal )
{
    return x3::lexeme[
        x3::lit( std::forward<L>( literal ) )
        >> !( range( 'A', 'Z' )
            | range( 'a', 'z' )
            | x3::char_( '_' )
            | range( '0', '9' )
            )
        ];
}

template<typename L>
decltype(auto) tagged( L&& rule )
{
    return x3::raw[std::forward<L>( rule )][helper::tagging()];
}
*/
            /* code grammar */

program: module eof { $1 }

module:
    | top_level_statements { $1 }

top_level_statements:
    | { [] }
    | top_level_statement top_level_statements { $1::$2 }

top_level_statement :
    | function_definition_statement { $1 }
    | class_definition_statement { $1 }
    | extern_statement  { $1 }
    | import_statement  { $1 }
    | empty_statement  { $1 }
    | expression_statement  { $1 }   /* this rule must be located at last */

function_definition_statement:
    | DEF identifier_relative
        -template_parameter_variable_declaration_list
        parameter_variable_declaration_list
        decl_attribute_list
        -type_specifier
        function_body_block
        { Function_definition_statement($3, $2, $4, $5, $6, $7) }

function_body_statements_list:
    | LBRACE program_body_statements_list RBRACE { $2 }
    | function_online_body_for_normal { $1 }

function_body_statements_list_for_lambda:
    | LBRACE program_body_statements_list RBRACE { $2 }
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

program_body_statements_list:
    | *program_body_statement { $1 }

program_body_statements:
    | program_body_statements_list { $1 }


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
    | LPAREN parameter_variable_declaration % x3::lit( ',' ) RPAREN { $2 }

/* value initializer unit
 * Ex.
 * :int = 5
 * = 5
 * :int
 */
value_initializer_unit:
    | value_initializer_unit_only_value { assign }
    | type_specifier -(ASSIGN expression)
        { ($1, $2) }

value_initializer_unit_only_value:
    | ASSIGN expression
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
  | decl_attribute[helper::make_merged_bitflag( $1 )] % x3::lit( ',' ) )
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
  | LBRACK  ( t.id_expression % ',' ) RBRACK { $2 }

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
  | class_variable_initializer_unit % x3::lit( ',' )
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
    {
        ExternFunctionDeclarationStatement($2, $1, $3, $4, $5, $6)
    }

extern_class_declaration_statement:
  | CLASS
    identifier_relative
    -template_parameter_variable_declaration_list
    extern_decl_attribute_list
    string_literal_sequence
    {
        ExternClassDeclarationStatement($2, $1, $3, $4)
    }

extern_decl_attribute_list:
  | decl_attribute_list >> x3::eps{helper::make_merged_bitflag( AExtern )}



/* ==================================================================================================== */
/* ==================================================================================================== */

template_parameter_variable_declaration:
  | template_parameter_variable_initializer_unit { VariableDeclaration(ARef, $1) }

template_parameter_variable_initializer_unit:
  | identifier_relative -value_initializer_unit
    { VariableDeclarationUnit($1, ADefault, $2) (* TODO: decl::onlymeta? *) }


template_parameter_variable_declaration_list:
  | x3::lit( '!' ) LPAREN RPAREN  { }
  | x3::lit( '!' ) LPAREN template_parameter_variable_declaration % x3::lit( ',' ) ) RPAREN { }


/* ==================================================================================================== */
/* ==================================================================================================== */
variable_declaration_statement:
  | variable_declaration statement_termination {
        VariableDeclarationStatement($1)
    }

variable_holder_kind_specifier:
  | VAL { "val" }
  | REF { "ref" }

variable_declaration:
  | variable_holder_kind_specifier variable_initializer_unit
    {
      VariableDeclaration($1, $2)
    }

variable_initializer_unit:
  | identifier_relative decl_attribute_list value_initializer_unit 
    { VariableDeclarationUnit($1, $2, $3) }


/* ==================================================================================================== */
/* ==================================================================================================== */
import_statement:
  | IMPORT
    x3::attr(nullptr) /* work around to avoid this rule to be adapted to vector(pass type at random) */
    import_decl_unit_list
    statement_termination
    { ImportStatement($2) }

import_decl_unit:
  | normal_identifier_sequence { ImportDeclUnit($1) }

import_decl_unit_list:
  | import_decl_unit % x3::lit( ',' ) { $1 }

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
  | assign_expression
    *tagged(
        ( x3::lit( ',' ) assign_expression ){ $1 }

assign_expression:
  | conditional_expression
    >> *( ( x3::lit( "=" ) >> t.conditional_expression )[helper::make_left_assoc_binary_op_node_ptr( "=", $1 )]
        )

conditional_expression:
    logical_or_expression
    /* TODO: add conditional operator( ? : ) */

logical_or_expression:
  | logical_and_expression
    >> *tagged(
        ( x3::lit( "||" ) > t.logical_and_expression )[helper::make_left_assoc_binary_op_node_ptr( "||", $1 )]
        )

logical_and_expression:
    t.bitwise_or_expression
    >> *tagged(
        ( x3::lit( "&&" ) >> t.bitwise_or_expression )[helper::make_left_assoc_binary_op_node_ptr( "&&", $1 )]
        )

bitwise_or_expression:
  | t.bitwise_xor_expression
    >> *tagged(
        ( x3::lit( "|" ) >> t.bitwise_xor_expression )[helper::make_left_assoc_binary_op_node_ptr( "|", $1 )]
        )

bitwise_xor_expression:
  | bitwise_and_expression
    >> *tagged(
        ( x3::lit( "^" ) >> t.bitwise_and_expression )[helper::make_left_assoc_binary_op_node_ptr( "^", $1 )]
        )

bitwise_and_expression:
  | t.equality_expression
    >> *tagged(
        ( x3::lit( "&" ) >> t.equality_expression )[helper::make_left_assoc_binary_op_node_ptr( "&", $1 )]
        )

equality_expression:
  | t.relational_expression
    >> *tagged(
          ( x3::lit( "==" ) >> t.relational_expression )[helper::make_left_assoc_binary_op_node_ptr( "==", $1 )]
        | ( x3::lit( "!=" ) >> t.relational_expression )[helper::make_left_assoc_binary_op_node_ptr( "!=", $1 )]
        )

relational_expression:
  | t.shift_expression
    >> *tagged(
          ( x3::lit( "<=" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( "<=", $1 )]
        | ( x3::lit( "<" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( "<", $1 )]
        | ( x3::lit( ">=" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( ">=", $1 )]
        | ( x3::lit( ">" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( ">", $1 )]
        )

shift_expression:
  | add_sub_expression
    >> *tagged(
          ( x3::lit( "<<" ) >> t.add_sub_expression )[helper::make_left_assoc_binary_op_node_ptr( "<<", $1 )]
        | ( x3::lit( ">>" ) >> t.add_sub_expression )[helper::make_left_assoc_binary_op_node_ptr( ">>", $1 )]
        )

add_sub_expression:
  | mul_div_rem_expression
    >> *tagged(
          ( x3::lit( "+" ) >> t.mul_div_rem_expression )[helper::make_left_assoc_binary_op_node_ptr( "+", $1 )]
        | ( x3::lit( "-" ) >> t.mul_div_rem_expression )[helper::make_left_assoc_binary_op_node_ptr( "-", $1 )]
        )
mul_div_rem_expression:
  | unary_expression
    >> *tagged(
          ( x3::lit( "*" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "*", $1 )]
        | ( x3::lit( "/" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "/", $1 )]
        | ( x3::lit( "%" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "%", $1 )]
        )

unary_expression:
    | postfix_expression { $1 }
    | tagged(
        ( x3::lit( '-' ) >> t.unary_expression )[
            helper::make_unary_prefix_op_node_ptr( "-", $1 )
            ])
    | tagged(
        ( x3::lit( '+' ) >> t.unary_expression )[
            helper::make_unary_prefix_op_node_ptr( "+", $1 )
            ])
    | tagged(
        ( x3::lit( '*' ) >> t.unary_expression )[
            dereference_expression>( $1 )
            ])
    | tagged(
        ( x3::lit( '&' ) >> t.unary_expression )[
            addressof_expression>( $1 )
            ])
    | tagged(
        ( make_keyword( "new" ) >> t.unary_expression )[
            addressof_expression>( $1 )
            ])
    

postfix_expression:
  | primary_expression
    >> *tagged(
            ( x3::lit( '.' ) >> t.identifier_value_set )[
                helper::make_assoc_node_ptr<ast::element_selector_expression>( $1 )
                ]
          | ( x3::lit( '[' ) > -t.expression > x3::lit( ']' ) )[
                helper::make_assoc_node_ptr<ast::subscrpting_expression>( $1 )
                ]
          | ( t.argument_list )[
                helper::make_assoc_node_ptr<ast::call_expression>( $1 )
                ]
       )

primary_expression:
    | primary_value { $1 }
    | LPAREN expression RPAREN { $2 }
    | lambda_expression { $1 }
    


argument_list:
  | LPAREN RPAREN { [] }
  | LPAREN (assign_expression % ',') RPAREN { $2 }


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
t.parameter_variable_declaration_list
    > t.decl_attribute_list
    > -t.type_specifier
    > t.function_body_block
*/

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
  | identifier_sequence
    { IdentifierValue($1, false) }

identifier_from_root:
  | DOT identifier_sequence
    { IdentifierValue($1, true) }


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
    | x3::lit( '!' ) argument_list { }
    | x3::lit( '!' ) primary_expression { ExpressionList($2) }

/* ==================================================================================================== */
numeric_literal:
  | float_literal { $1 }
  | integer_literal { $1 }

integer_literal:
  | x3::uint_
    { Int32Value($1) }

/* TODO: check range */
float_literal:
  | fp_
    { FloatValue($1) }

/* 1.0 */
/* 1.e0 */
struct very_strict_fp_policies
    : public x3::strict_ureal_policies<long double>
{
    static bool const allow_leading_dot = false;
    static bool const allow_trailing_dot = false;
};
x3::real_parser<long double, very_strict_fp_policies> const fp_;

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
    | ( x3::lit( '[' ) >> x3::lit( ']' ) )[
        intrinsic::array_value>()
        ] )
    | ( ( x3::lit( '[' ) >> ( t.assign_expression % ',' ) >> x3::lit( ']' ) )[
            intrinsic::array_value>( $1 )
            ] )

/* ==================================================================================================== */
string_literal:
  | string_literal_sequence
    { StringValue($1) }

string_literal_sequence:
  | x3::lexeme {
        x3::lit( '"' ) >> *( ( t.escape_sequence | x3::char_ ) - x3::lit( '"' ) ) >> x3::lit( '"' )
    }

/* TODO: support some escape sequences */
escape_sequence:
  | x3::lit( "\\n" ) { helper::construct<char>( '\n' )}


/* ==================================================================================================== */
/* ==================================================================================================== */
identifier_sequence:
  | operator_identifier_sequence { $1 }
  | normal_identifier_sequence { $1 }

operator_identifier_sequence:
  | OP pre_or_post_or_empty 
      ( x3::lit( "==" )[helper::append( "==" )]
      | x3::lit( "!=" )[helper::append( "!=" )]
      | x3::lit( "||" )[helper::append( "||" )]
      | x3::lit( "&&" )[helper::append( "&&" )]
      | x3::lit( "<=" )[helper::append( "<=" )]
      | x3::lit( ">=" )[helper::append( ">=" )]
      | x3::lit( "<<" )[helper::append( "<<" )]
      | x3::lit( ">>" )[helper::append( ">>" )]
      | x3::lit( "()" )[helper::append( "()" )]
      | x3::lit( "[]" )[helper::append( "[]" )]
      | x3::lit( "|" )[helper::append( "|" )]
      | x3::lit( "^" )[helper::append( "^" )]
      | x3::lit( "&" )[helper::append( "&" )]
      | x3::lit( "+" )[helper::append( "+" )]
      | x3::lit( "-" )[helper::append( "-" )]
      | x3::lit( "*" )[helper::append( "*" )]
      | x3::lit( "/" )[helper::append( "/" )]
      | x3::lit( "%" )[helper::append( "%" )]
      | x3::lit( "<" )[helper::append( "<" )]
      | x3::lit( ">" )[helper::append( ">" )]
      | x3::lit( "=" )[helper::append( "=" )]
      ) { }

pre_or_post_or_empty:
  | PRE { "pre" }
  | POST { "post" }
  | { "" }

normal_identifier_sequence:
  | x3::lexeme[
        nondigit_charset
        >> *( nondigit_charset
            | digit_charset
            )
        ]

nondigit_charset:
    | range( 'A', 'Z' )
    | range( 'a', 'z' )
    | x3::char_( '_' )

digit_charset:
  | range( '0', '9' )
