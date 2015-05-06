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
        {
            ($1, $2)
        }

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
    x3::attr( ADefault )
    >> ( ( t.decl_attribute[helper::make_merged_bitflag( ph::_1 )] % x3::lit( ',' ) )
       | x3::eps
       )

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
    {
        helper::make_templatable_node_ptr<ast::class_definition_statement>($3, $2, $4, $5, $6, $7)
    }

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
    {
        helper::make_templatable_node_ptr<ast::class_function_definition_statement>(
            ph::_2,
            ph::_1,
            ph::_3,
            ph::_4,
            ph::_5,
            ph::_6,
            ph::_7
            )
    }

class_virtual_function_definition_statement:
  | ( make_keyword( "virtual" ) > make_keyword( "def" )
    > ( ( t.identifier_relative
        >> t.parameter_variable_declaration_list
        >> t.decl_attribute_list
        >> t.type_specifier
        >> t.function_body_block
        )[
            helper::make_node_ptr<ast::class_virtual_function_definition_statement>(
                ph::_1,
                ph::_2,
                ph::_3,
                ph::_4,
                ph::_5
                )
            ]
      | ( t.identifier_relative
        >> t.parameter_variable_declaration_list
        >> t.decl_attribute_list
        >> t.type_specifier
        >> t.statement_termination
        )[
            helper::make_node_ptr<ast::class_virtual_function_definition_statement>(
                ph::_1,
                ph::_2,
                ph::_3,
                ph::_4
                )
            ]
      | ( t.identifier_relative
        > t.parameter_variable_declaration_list
        > t.decl_attribute_list
        > t.function_body_block
        )[
            helper::make_node_ptr<ast::class_virtual_function_definition_statement>(
                ph::_1,
                ph::_2,
                ph::_3,
                ph::_4
                )
            ]
      )
    )


class_variable_initializers:
  | ( x3::lit( "|" )
    > x3::attr(nullptr) /* work around to avoid this rule to be adapted to vector(pass type at random) */
    > t.class_variable_initializer_list
    )[
        helper::construct<ast::element::class_variable_initializers>(
            ph::_2
            )
        ]


class_variable_initializer_list:
  | class_variable_initializer_unit % x3::lit( ',' )


class_variable_initializer_unit:
  | identifier_relative value_initializer_unit_only_value {
        helper::construct<ast::variable_declaration_unit>( ph::_1, ADefault, ph::_2 )
  }



class_variable_declaration_statement:
  | variable_declaration statement_termination {
        helper::make_node_ptr<ast::class_variable_declaration_statement>( ph::_1 )
        }


/* ==================================================================================================== */
/* ==================================================================================================== */

extern_statement:
  | EXTERN
    > ( extern_function_declaration_statement
      | extern_class_declaration_statement
      )
    > statement_termination
    

extern_function_declaration_statement:
  | DEF
    > t.identifier_relative
    > -t.template_parameter_variable_declaration_list
    > t.parameter_variable_declaration_list
    > t.extern_decl_attribute_list
    > t.type_specifier
    > t.string_literal_sequence
    {
        helper::make_templatable_node_ptr<ast::extern_function_declaration_statement>(
            ph::_2,
            ph::_1,
            ph::_3,
            ph::_4,
            ph::_5,
            ph::_6
            )
    }

extern_class_declaration_statement:
  | CLASS
    > t.identifier_relative
    > -t.template_parameter_variable_declaration_list
    > t.extern_decl_attribute_list
    > t.string_literal_sequence
    {
        helper::make_templatable_node_ptr<ast::extern_class_declaration_statement>(
            ph::_2,
            ph::_1,
            ph::_3,
            ph::_4
            )
    }


extern_decl_attribute_list:
  | t.decl_attribute_list[helper::assign()] >> x3::eps{helper::make_merged_bitflag( Aextern )}



/* ==================================================================================================== */
/* ==================================================================================================== */

R( template_parameter_variable_declaration, ast::variable_declaration,
    ( t.template_parameter_variable_initializer_unit )[
        helper::construct<ast::variable_declaration>( attribute::holder_kind::k_ref, ph::_1 )
        ]
)

R( template_parameter_variable_initializer_unit, ast::variable_declaration_unit,
    ( t.identifier_relative > -t.value_initializer_unit )[
        helper::construct<ast::variable_declaration_unit>( ph::_1, ADefault, ph::_2 ) // TODO: decl::onlymeta?
        ]
)


R( template_parameter_variable_declaration_list, ast::parameter_list_t,
    ( ( x3::lit( '!' ) >> x3::lit( '(' ) >> x3::lit( ')' ) )
    | ( x3::lit( '!' ) >> x3::lit( '(' ) >> ( t.template_parameter_variable_declaration % x3::lit( ',' ) ) >> x3::lit( ')' ) )
    )
)


/* ==================================================================================================== */
/* ==================================================================================================== */
RN( variable_declaration_statement, ast::variable_declaration_statement_ptr,
    ( t.variable_declaration > t.statement_termination )[
        helper::make_node_ptr<ast::variable_declaration_statement>( ph::_1 )
        ]
)

R( variable_holder_kind_specifier, attribute::holder_kind,
    ( make_keyword( "val" )[helper::assign( attribute::holder_kind::k_val )]
    | make_keyword( "ref" )[helper::assign( attribute::holder_kind::k_ref )]
    )
)

R( variable_declaration, ast::variable_declaration,
    ( t.variable_holder_kind_specifier > t.variable_initializer_unit )[
        helper::construct<ast::variable_declaration>( ph::_1, ph::_2 )
        ]
)

R( variable_initializer_unit, ast::variable_declaration_unit,
    ( t.identifier_relative > t.decl_attribute_list > t.value_initializer_unit )[
        helper::construct<ast::variable_declaration_unit>( ph::_1, ph::_2, ph::_3 )
        ]
)


/* ==================================================================================================== */
/* ==================================================================================================== */
import_statement:
  | IMPORT
    x3::attr(nullptr) /* work around to avoid this rule to be adapted to vector(pass type at random) */
    import_decl_unit_list
    statement_termination
    {
        helper::make_node_ptr<ast::import_statement>( ph::_2 )
    }

import_decl_unit:
  | normal_identifier_sequence {
        helper::construct<ast::import_decl_unit>( $1 )
  }

import_decl_unit_list:
  | import_decl_unit % x3::lit( ',' ) { $1 }



/* ==================================================================================================== */
/* ==================================================================================================== */
R( control_flow_statement, ast::statement_ptr,
    ( t.while_statement
    | t.if_statement
    )
)


RN( while_statement, ast::while_statement_ptr,
    ( x3::lit( "while" )
    > ( x3::lit( "(" ) > t.expression > x3::lit( ")" ) )
    > t.program_body_statement
    )[
        helper::make_node_ptr<ast::while_statement>(
            ph::_1,
            ph::_2
            )
        ]
)


RN( if_statement, ast::if_statement_ptr,
    ( x3::lit( "if" )
    > ( x3::lit( "(" ) > t.expression > x3::lit( ")" ) )
    > t.program_body_statement
    > -( x3::lit( "else" ) > t.program_body_statement )
    )[
        helper::make_node_ptr<ast::if_statement>(
            ph::_1,
            ph::_2,
            ph::_3
            )
        ]
)


/* ==================================================================================================== */
/* ==================================================================================================== */
empty_statement:
  | statement_termination { Empty_statement }

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
RN( id_expression, ast::id_expression_ptr,
    ( t.conditional_expression
    )[
        helper::fun(
            []( auto&&... args ) {
                return ast::helper::make_id_expression( std::forward<decltype(args)>( args )... );
            },
            ph::_1
            )
        ]
)


/* ==================================================================================================== */
R( expression, ast::expression_ptr,
    t.assign_expression // NOT commma_expression
    )

//
R( commma_expression, ast::expression_ptr,
   t.assign_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( ',' ) >> t.assign_expression )[helper::make_left_assoc_binary_op_node_ptr( ",", ph::_1 )]
        )
)

//
RN( assign_expression, ast::expression_ptr,
   t.conditional_expression[helper::assign()]
    >> *( ( x3::lit( "=" ) >> t.conditional_expression )[helper::make_left_assoc_binary_op_node_ptr( "=", ph::_1 )]
        )

)

//
RN( conditional_expression, ast::expression_ptr,
    t.logical_or_expression[helper::assign()]
    // TODO: add conditional operator( ? : )
)

//
R( logical_or_expression, ast::expression_ptr,
    t.logical_and_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( "||" ) > t.logical_and_expression )[helper::make_left_assoc_binary_op_node_ptr( "||", ph::_1 )]
        )
)

//
R( logical_and_expression, ast::expression_ptr,
    t.bitwise_or_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( "&&" ) >> t.bitwise_or_expression )[helper::make_left_assoc_binary_op_node_ptr( "&&", ph::_1 )]
        )
)

//
R( bitwise_or_expression, ast::expression_ptr,
    t.bitwise_xor_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( "|" ) >> t.bitwise_xor_expression )[helper::make_left_assoc_binary_op_node_ptr( "|", ph::_1 )]
        )
)

//
R( bitwise_xor_expression, ast::expression_ptr,
    t.bitwise_and_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( "^" ) >> t.bitwise_and_expression )[helper::make_left_assoc_binary_op_node_ptr( "^", ph::_1 )]
        )
)

//
R( bitwise_and_expression, ast::expression_ptr,
    t.equality_expression[helper::assign()]
    >> *tagged(
        ( x3::lit( "&" ) >> t.equality_expression )[helper::make_left_assoc_binary_op_node_ptr( "&", ph::_1 )]
        )
)

//
R( equality_expression, ast::expression_ptr,
    t.relational_expression[helper::assign()]
    >> *tagged(
          ( x3::lit( "==" ) >> t.relational_expression )[helper::make_left_assoc_binary_op_node_ptr( "==", ph::_1 )]
        | ( x3::lit( "!=" ) >> t.relational_expression )[helper::make_left_assoc_binary_op_node_ptr( "!=", ph::_1 )]
        )
)

//
R( relational_expression, ast::expression_ptr,
    t.shift_expression[helper::assign()]
    >> *tagged(
          ( x3::lit( "<=" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( "<=", ph::_1 )]
        | ( x3::lit( "<" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( "<", ph::_1 )]
        | ( x3::lit( ">=" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( ">=", ph::_1 )]
        | ( x3::lit( ">" ) >> t.shift_expression )[helper::make_left_assoc_binary_op_node_ptr( ">", ph::_1 )]
        )
)

//
R( shift_expression, ast::expression_ptr,
    t.add_sub_expression[helper::assign()]
    >> *tagged(
          ( x3::lit( "<<" ) >> t.add_sub_expression )[helper::make_left_assoc_binary_op_node_ptr( "<<", ph::_1 )]
        | ( x3::lit( ">>" ) >> t.add_sub_expression )[helper::make_left_assoc_binary_op_node_ptr( ">>", ph::_1 )]
        )
)

//
R( add_sub_expression, ast::expression_ptr,
    t.mul_div_rem_expression[helper::assign()]
    >> *tagged(
          ( x3::lit( "+" ) >> t.mul_div_rem_expression )[helper::make_left_assoc_binary_op_node_ptr( "+", ph::_1 )]
        | ( x3::lit( "-" ) >> t.mul_div_rem_expression )[helper::make_left_assoc_binary_op_node_ptr( "-", ph::_1 )]
        )
)


//
R( mul_div_rem_expression, ast::expression_ptr,
    t.unary_expression[helper::assign()]
    >> *tagged(
          ( x3::lit( "*" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "*", ph::_1 )]
        | ( x3::lit( "/" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "/", ph::_1 )]
        | ( x3::lit( "%" ) >> t.unary_expression )[helper::make_left_assoc_binary_op_node_ptr( "%", ph::_1 )]
        )
)

//
R( unary_expression, ast::expression_ptr,
    ( t.postfix_expression[helper::assign()]
    | tagged(
        ( x3::lit( '-' ) >> t.unary_expression )[
            helper::make_unary_prefix_op_node_ptr( "-", ph::_1 )
            ])
    | tagged(
        ( x3::lit( '+' ) >> t.unary_expression )[
            helper::make_unary_prefix_op_node_ptr( "+", ph::_1 )
            ])
    | tagged(
        ( x3::lit( '*' ) >> t.unary_expression )[
            helper::make_node_ptr<ast::dereference_expression>( ph::_1 )
            ])
    | tagged(
        ( x3::lit( '&' ) >> t.unary_expression )[
            helper::make_node_ptr<ast::addressof_expression>( ph::_1 )
            ])
    | tagged(
        ( make_keyword( "new" ) >> t.unary_expression )[
            helper::make_node_ptr<ast::addressof_expression>( ph::_1 )
            ])
    )
)

//
R( postfix_expression, ast::expression_ptr,
    t.primary_expression[helper::assign()]
    >> *tagged(
            ( x3::lit( '.' ) >> t.identifier_value_set )[
                helper::make_assoc_node_ptr<ast::element_selector_expression>( ph::_1 )
                ]
          | ( x3::lit( '[' ) > -t.expression > x3::lit( ']' ) )[
                helper::make_assoc_node_ptr<ast::subscrpting_expression>( ph::_1 )
                ]
          | ( t.argument_list )[
                helper::make_assoc_node_ptr<ast::call_expression>( ph::_1 )
                ]
       )
)

RN( primary_expression, ast::expression_ptr,
    ( t.primary_value[
        helper::fun(
            []( auto&& val ) {
                auto p = std::make_shared<ast::term_expression>(
                    std::forward<decltype(val)>( val )
                    );
                p->value_->parent_expression = p;
                return p;
            },
            ph::_1
            )
        ]
    | ( x3::lit( '(' ) >> t.expression >> x3::lit( ')' ) )[helper::assign()]
    | t.lambda_expression[helper::assign()]
    )
)


R( argument_list, ast::expression_list,
    ( x3::lit( '(' ) >> x3::lit( ')' ) )
    | ( x3::lit( '(' ) >> ( t.assign_expression % ',' ) >> x3::lit( ')' ) )
)


/* ==================================================================================================== */
/* ==================================================================================================== */
RN( lambda_expression, ast::lambda_expression_ptr,
    ( t.lambda_introducer
    > -t.template_parameter_variable_declaration_list
    > t.parameter_variable_declaration_list
    > t.decl_attribute_list
    > -t.type_specifier
    > t.function_body_statements_list_for_lambda
    )[
        helper::make_node_ptr<ast::lambda_expression>(
            ph::_1,
            ph::_2,
            ph::_3,
            ph::_4,
            ph::_5
            )
        ]
)

R( lambda_introducer, x3::unused_type,
    x3::lit( "\\" )
)

/*
t.parameter_variable_declaration_list
    > t.decl_attribute_list
    > -t.type_specifier
    > t.function_body_block
*/

/* ==================================================================================================== */
/* ==================================================================================================== */
R( primary_value, ast::value_ptr,
    ( t.boolean_literal
    | t.identifier_value_set
    | t.numeric_literal
    | t.string_literal
    | t.array_literal
    )
)


/* ==================================================================================================== */
R( identifier_value_set, ast:: identifier_value_base_ptr,
    t.template_instance_identifier | t.identifier
)


R( identifier, ast::identifier_value_ptr,
    t.identifier_from_root | t.identifier_relative
)

RN( identifier_relative, ast::identifier_value_ptr,
    t.identifier_sequence[
        helper::make_node_ptr<ast::identifier_value>( ph::_1, false )
        ]
)

RN( identifier_from_root, ast::identifier_value_ptr,
    ( x3::lit( '.' ) >> t.identifier_sequence )[
        helper::make_node_ptr<ast::identifier_value>( ph::_1, true )
        ]
)


R( template_instance_identifier, ast::template_instance_value_ptr,
    t.template_instance_identifier_from_root | t.template_instance_identifier_relative
)

RN( template_instance_identifier_relative, ast::template_instance_value_ptr,
    ( t.identifier_sequence >> t.template_argument_list )[
        helper::make_node_ptr<ast::template_instance_value>( ph::_1, ph::_2, false )
        ]
)

RN( template_instance_identifier_from_root, ast::template_instance_value_ptr,
    ( x3::lit( '.' ) >> t.identifier_sequence >> t.template_argument_list )[
        helper::make_node_ptr<ast::template_instance_value>( ph::_1, ph::_2, true )
        ]
)

R( template_argument_list, ast::expression_list,
      ( x3::lit( '!' ) >> t.argument_list )[helper::assign()]
    | ( x3::lit( '!' ) >> t.primary_expression )[
        helper::fun(
            []( auto&&... args ) {
                return ast::expression_list{ std::forward<decltype(args)>( args )... };
            },
            ph::_1
            )
        ]
)

/* ==================================================================================================== */
R( numeric_literal, ast::value_ptr,
    ( t.float_literal
    | t.integer_literal
    )
)

RN( integer_literal, ast::intrinsic::int32_value_ptr,
    x3::uint_[
        helper::make_node_ptr<ast::intrinsic::int32_value>( ph::_1 )
        ]
)

/* TODO: check range */
RN( float_literal, ast::intrinsic::float_value_ptr,
    t.fp_[
        helper::make_node_ptr<ast::intrinsic::float_value>( ph::_1 )
        ]
)

/* 1.0 */
/* 1.e0 */
struct very_strict_fp_policies
    : public x3::strict_ureal_policies<long double>
{
    static bool const allow_leading_dot = false;
    static bool const allow_trailing_dot = false;
};
x3::real_parser<long double, very_strict_fp_policies> const fp_;

#if 0
/* TODO: */
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
#endif


/* ==================================================================================================== */
RN( boolean_literal, ast::intrinsic::boolean_value_ptr,
    x3::bool_[
        helper::make_node_ptr<ast::intrinsic::boolean_value>( ph::_1 )
        ]
)

/* ==================================================================================================== */
RN( array_literal, ast::intrinsic::array_value_ptr,
    ( ( x3::lit( '[' ) >> x3::lit( ']' ) )[
        helper::make_node_ptr<ast::intrinsic::array_value>()
        ] )
    | ( ( x3::lit( '[' ) >> ( t.assign_expression % ',' ) >> x3::lit( ']' ) )[
            helper::make_node_ptr<ast::intrinsic::array_value>( ph::_1 )
            ] )
)

/* ==================================================================================================== */
RN( string_literal, ast::intrinsic::string_value_ptr,
    t.string_literal_sequence[
        helper::make_node_ptr<ast::intrinsic::string_value>( ph::_1 )
        ]
)

R( string_literal_sequence, std::string,
    x3::lexeme[
        x3::lit( '"' ) >> *( ( t.escape_sequence | x3::char_ ) - x3::lit( '"' ) ) >> x3::lit( '"' )
        ]
)

// TODO: support some escape sequences
R( escape_sequence, char,
    x3::lit( "\\n" )[helper::construct<char>( '\n' )]
)


/* ==================================================================================================== */
/* ==================================================================================================== */
R( identifier_sequence, std::string,
    ( t.operator_identifier_sequence
    | t.normal_identifier_sequence
    )
)

R( operator_identifier_sequence, std::string,
    make_keyword( "op" )[helper::construct<std::string>( "%op_" )]
    > -( make_keyword( "pre" )[helper::append( "pre_" )]
       | make_keyword( "post" )[helper::append( "post_" )]
       )
    > ( x3::lit( "==" )[helper::append( "==" )]
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
      )
)

R( normal_identifier_sequence, std::string,
    x3::lexeme[
        ( t.nondigit_charset )
        >> *( t.nondigit_charset
            | t.digit_charset
            )
        ]
)

R( nondigit_charset, char,
      range( 'A', 'Z' )
    | range( 'a', 'z' )
    | x3::char_( '_' )
    )

R( digit_charset, char,
    range( '0', '9' )
    )

*/