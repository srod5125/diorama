%skeleton "lalr1.cc"
%require "3.8.2"


%define api.parser.class { calcxx_parser }

%define api.token.constructor
%define api.value.type variant

%define parse.assert

%code requires
{
    class calcxx_driver;

    #include <string>
    #include <string_view>
    #include <vector>
    #include <iterator>
    #include <variant>
    #include <utility>


    #include "log.hpp"
    #include "aux.hpp"


    //since the parser is the root dependency
    //any global aliases are better placed here

    using vec_of_ints = std::vector< int >;

    using namespace spec;
}

%param { calcxx_driver& drv }

%locations

%initial-action
{
  @$.begin.filename = @$.end.filename = &drv.input_file;
}

%define parse.trace
%define parse.error verbose

%code
{
    #include "diorama_driver.hpp"

    // zom = zero or more
    // wom = one  or more
    // zow = zero or won
    // wom = one  or more

    void merge_vectors( vec_of_ints & a, vec_of_ints & b );
    void merge_vectors( std::vector<std::string> & a, std::vector<std::string> & b );

}

%define api.token.prefix {TOK_}

%token
EOF 0
H1
H2
H3
H4
H5
BLD
MEMBERS
ARE
END
ASSIGN
DASH
PLUS
STAR
SLASH
L_PAREN
R_PAREN
MODULE
IS
RECORD
COLON
COMMA
L_ANGLE_BRCKT
R_ANGLE_BRCKT
DOT
IN
ISSETOF
START
MAPS
TO
FOR
RULE
OR
WHEN
THEN
ANY
ALL
AT
MOST
LEAST
ALWAYS
NEVER
MUST
IF
ELSE
SOME
SUCH
THAT
TIC
TRUTHY
FALSEY
AND
ORRATHER
NOT
EQ
NOTEQ
UNION
INTERSECT
DIFF
ISIN
ISSUB
COMP
ISGT
ISLT
BTWN
XOR
DOTDOT
L_BRCKT
R_BRCKT
ARROW
L_BRACE
R_BRACE
;

%type < vec_of_ints > data body zom_assertions
%type < vec_of_ints > zom_schemes inits zom_rules
%type < vec_of_ints > zom_inits wom_word_to_structure_mapping
%type < vec_of_ints > wom_decleration basic_init
%type < std::vector< std::string > > wom_enums
%type < int > scheme record_def enum_def members_def
%type < int > assertion declaration named_decl init
%type < int > members_init word_to_structure rule
%type < spec::atom_var > atom structure
%type < std::string > name_sel
%type < vec_of_ints > wom_then_blocks
%type < int > when_block then_block
%type < spec::quant_int > quantifier
%type < vec_of_ints > zom_dash_exprs wom_dash_exprs
%type < vec_of_ints > wom_stmts zom_else_if
%type < int > dash_expr expr equality
%type < int > set_opers membership arithmetic term
%type < int > stmt if_stmt assignment else_if zow_else else
%type < bool > zow_or_equals
%type < int > never_assertion always_assertion


%token < std::string_view > WORD
%token < int > INT


/*
%printer { yyoutput << "TODO opt"; } <std::optional<Node>>;
%printer { yyoutput << $$.id << "TODO tos"; } <Node>;
%printer { yyoutput << $$; } <*>;
*/

%start spec

%%

spec : module

module :  MODULE WORD IS data body zom_assertions END WORD
{
    spec::token t = spec::token( node_kind::module );

    spec_parts sp;
    sp.data         = std::move( $4 );
    sp.body         = std::move( $5 );
    sp.assertions   = std::move( $6 );

    t.val = std::move( sp );
    drv.add_to_elements( std::move(t) );
}

// TODO: eventually test out of order decleration,
// TODO: mix data and body under univeral_block

data           : zom_schemes members_def { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }
body           : inits zom_rules { merge_vectors( $1 , $2 ); merge_vectors( $$ , $1 );  }
zom_assertions : %empty | zom_assertions assertion { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

    /* data & schemes */
zom_schemes : zom_schemes scheme { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }
            | scheme { $$.push_back( $1 ); }

scheme : record_def { $$ = $1; }
       | enum_def { $$ = $1; }

are_or_is : ARE | IS

record_def : RECORD WORD are_or_is wom_decleration END RECORD {
    spec::token t = spec::token( node_kind::record_def , std::string( $2 ) );
    t.children = std::move( $4 );

    $$ = drv.add_to_elements( std::move(t) );
}

members_def : MEMBERS ARE wom_decleration END MEMBERS {
    spec::token t = spec::token( node_kind::members_def );
    t.children = std::move( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}

enum_def : WORD are_or_is L_ANGLE_BRCKT wom_enums R_ANGLE_BRCKT {
    spec::token t = spec::token( node_kind::enum_def , std::string( $1 ) );
    t.val = std::move( $4 );

    $$ = drv.add_to_elements( std::move(t) );
}
wom_enums   : wom_enums COMMA WORD { $1.emplace_back( std::string($3) ); merge_vectors( $$ , $1 ); }
            | WORD { $$.emplace_back( std::string($1) ); }

wom_decleration : wom_decleration declaration { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }
                | declaration { $$.push_back( $1 ); }

declaration : named_decl DOT { $$ = $1; }
            // | set_decl DOT
            // | array_decl DOT
            // | tuple_decl DOT

// TODO: second word should be type not atom
named_decl : WORD in_or_is WORD {
    std::pair< std::string, std::string > var_val_pair;
    var_val_pair.first  = std::string( $1 );
    var_val_pair.second = std::string( $3 );

    spec::token t = spec::token( node_kind::named_decl );
    t.val  = std::move( var_val_pair );

    $$ = drv.add_to_elements( std::move(t) );
}
set_decl : WORD ISSETOF WORD
//TODO: second word can be expression
array_decl  : WORD MAPS WORD TO WORD
tuple_decl  : WORD in_or_is L_PAREN wom_types R_PAREN

wom_types  : wom_types COMMA WORD | WORD


//TODO: wom_elements -> wom_terms

in_or_is : IN | IS

inits : zom_inits members_init { $1.push_back( $2 ); merge_vectors( $$ , $1 );  }

zom_inits   : %empty | zom_inits init { $1.push_back( $2 ); merge_vectors( $$ , $1 );  }

init : struct_init | array_init
array_init   : START FOR WORD IS array_map_init END START
struct_init  : START FOR WORD IS basic_init END START

members_init : START FOR MEMBERS IS basic_init END START {
    spec::token t = spec::token( node_kind::members_init );
    t.name = "members";
    t.children = std::move( $5 );

    $$ = drv.add_to_elements( std::move(t) );
}

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping { $$ = std::move( $1 ); }

wom_structure_mapping  : wom_structure_mapping COMMA structure_mapping | structure_mapping
structure_mapping : structure ASSIGN structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping COMMA word_to_structure
                                    { $1.push_back( $3 ); merge_vectors( $$ , $1 ); }
                                | word_to_structure { $$.push_back( $1 ); }

word_to_structure :  WORD ASSIGN structure {
    spec::token t = spec::token( node_kind::word_to_struct , std::string( $1 ) );
    t.val = std::move( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}

structure : atom { $$ = std::move( $1 ); }

zom_rules   : %empty | zom_rules rule { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

rule : RULE WORD are_or_is when_block wom_then_blocks END RULE {
    spec::token t = spec::token( node_kind::rule , std::string( $2 ) );
    // first child is when block, rest are then blocks
    t.children.push_back( $4 );
    merge_vectors( t.children , $5 );

    $$ = drv.add_to_elements( std::move(t) );
}


when_block : WHEN quantifier COLON zom_dash_exprs {
    spec::token t = spec::token( node_kind::when_block );
    t.val = $2;
    t.children = std::move( $4 );

    $$ = drv.add_to_elements( std::move(t) );
}

zom_dash_exprs  : %empty
                | zom_dash_exprs dash_expr { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

dash_expr : DASH expr DOT { $$ = $2; }

wom_then_blocks : then_block { $$.push_back( $1 ); }
                | wom_then_blocks OR then_block { $1.push_back( $3 ); merge_vectors( $$ , $1 );  }


then_block : THEN COLON wom_stmts {
    spec::token t = spec::token( node_kind::then_block );
    t.next = drv.s_file.elems[ $3[0] ].id;
    drv.set_nexts( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}

wom_stmts : stmt { $$.push_back( $1 ); }
          | wom_stmts stmt { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

quantifier
  : ANY             { $$ = std::make_pair( quant::any, 0 ); }
  | ALL             { $$ = std::make_pair( quant::all, 0 ); }
  | ALWAYS          { $$ = std::make_pair( quant::always, 0 ); }
  | AT MOST INT     { $$ = std::make_pair( quant::at_most, $3 ); }
  | AT LEAST INT    { $$ = std::make_pair( quant::at_least, $3 ); }
//TODO: add or equal to to at most or at least

stmt : if_stmt { $$ = $1; }
     | assignment DOT { $$ = $1; }
     // | skip
     // | aborts
     // | selection_stmt DOT

if_stmt : IF expr THEN wom_stmts zom_else_if zow_else END IF {

    spec::token t = spec::token( node_kind::if_stmt );
    t.val = $2;
    t.next = drv.s_file.elems[ $4[0] ].id;
    drv.set_nexts( $4 );
    merge_vectors( t.children, $5 );
    if ( $6 != -1 ) { t.children.push_back( $6 ); }

    $$ = drv.add_to_elements( std::move(t) );
}
zom_else_if : %empty
            | zom_else_if else_if { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

else_if : ELSE IF expr THEN COLON wom_stmts {

    spec::token t = spec::token( node_kind::else_if_stmt );
    t.val = $3;
    t.next = drv.s_file.elems[ $6[0] ].id;
    drv.set_nexts( $6 );

    $$ = drv.add_to_elements( std::move(t) );
}
zow_else : %empty { $$ = spec::undefined_id; }
         | else   { $$ = $1; }

else : ELSE COLON wom_stmts {

    spec::token t = spec::token( node_kind::else_stmt );
    t.val  = spec::undefined_id;
    t.next = drv.s_file.elems[ $3[0] ].id;
    drv.set_nexts( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}

selection_stmt : FOR WORD IN expr zow_filter
               | FOR SOME WORD IN expr zow_filter
               | FOR ALL WORD IN expr zow_filter
zow_filter : %empty | filter
filter : SUCH THAT expr

assignment : name_sel TIC ASSIGN expr {
    spec::token t = spec::token( node_kind::assignment , std::move( $1 ) );
    t.val = $4;

    $$ = drv.add_to_elements( std::move(t) );
}

    /* assertions & expressions */

assertion   : never_assertion { $$ = $1; }
            | always_assertion { $$ = $1; }

never_assertion  : MUST NEVER wom_dash_exprs END NEVER {
    spec::token t = spec::token( node_kind::never_assert );
    t.children = std::move( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}
always_assertion : MUST ALWAYS wom_dash_exprs END ALWAYS {
    spec::token t = spec::token( node_kind::always_assert );
    t.children = std::move( $3 );

    $$ = drv.add_to_elements( std::move(t) );
}

wom_dash_exprs : dash_expr { $$.push_back( $1 ); }
               | wom_dash_exprs dash_expr { $1.push_back( $2 ); merge_vectors( $$ , $1 ); }

expr  : equality { $$ = $1; }
      | expr AND equality { $$ = drv.add_binop( node_kind::t_and , { $1 , $3 } ); }
      | expr OR equality { $$ = drv.add_binop( node_kind::t_or , { $1 , $3 }); }
      | expr ORRATHER equality { $$ = drv.add_binop( node_kind::t_xor , { $1 , $3 }); }
      | NOT expr { $$ = drv.add_unop( node_kind::t_not , $2 ); }

equality  : set_opers { $$ = $1; }
          | equality EQ set_opers { $$ = drv.add_binop( node_kind::t_equal , { $1 , $3 } ); }
          | equality NOTEQ set_opers { $$ = drv.add_binop( node_kind::t_not_equal , { $1 , $3 } ); }

set_opers  : membership { $$ = $1; }
           | set_opers UNION membership { $$ = drv.add_binop( node_kind::t_union , { $1 , $3 } ); }
           | set_opers INTERSECT membership { $$ = drv.add_binop( node_kind::t_intersect , { $1 , $3 } ); }
           | set_opers DIFF membership { $$ = drv.add_binop( node_kind::t_diff , { $1 , $3 } ); }
           //TODO: rename is in into is member?
           | set_opers ISIN membership { $$ = drv.add_binop( node_kind::t_isin , { $1 , $3 } ); }
           | set_opers ISSUB membership { $$ = drv.add_binop( node_kind::t_issub , { $1 , $3 } ); }
           | COMP set_opers { $$ = drv.add_unop( node_kind::t_compliment , $2 ); }

membership  : arithmetic { $$ = $1; }
            | membership ISGT zow_or_equals arithmetic {
                if ( $3 )   { $$ = drv.add_binop( node_kind::t_gt , { $1 , $4 } ); }
                else        { $$ = drv.add_binop( node_kind::t_gtoe , { $1 , $4 } ); }
            }
            | membership ISLT zow_or_equals arithmetic {
                if ( $3 )   { $$ = drv.add_binop( node_kind::t_lt , { $1 , $4 } ); }
                else        { $$ = drv.add_binop( node_kind::t_ltoe , { $1 , $4 } ); }
            }
            // | membership zow_is BTWN range

zow_is : %empty  | IS
zow_or_equals : %empty { $$ = false; }
              | OR EQ  { $$ = true; }

//TODO: range within
range : arithmetic DOTDOT arithmetic
      | L_PAREN arithmetic DOTDOT arithmetic R_PAREN
      | L_PAREN arithmetic DOTDOT arithmetic R_BRCKT
      | L_BRCKT arithmetic DOTDOT arithmetic R_PAREN
      | L_BRCKT arithmetic DOTDOT arithmetic R_BRCKT

arithmetic  : term { $$ = $1; }
            | arithmetic PLUS term { $$ = drv.add_binop( node_kind::t_add , { $1 , $3 } ); }
            | arithmetic DASH term { $$ = drv.add_binop( node_kind::t_minus , { $1 , $3 } ); }
            | arithmetic STAR term { $$ = drv.add_binop( node_kind::t_multiply , { $1 , $3 } ); }
            | arithmetic SLASH term { $$ = drv.add_binop( node_kind::t_divide , { $1 , $3 } ); }
            | DASH term { $$ = drv.add_unop( node_kind::t_negative , $2 ); }

            // TODO: assert $3 cannot be 0 for div
// lhs & rhs name_sel

name_sel  : WORD { $$ = std::string( $1 ); }
    //    | WORD wom_sel

wom_sel : wom_sel ARROW WORD | ARROW WORD

term    : L_PAREN expr R_PAREN { $$ = $2; }
        | atom {
            spec::token t = spec::token( node_kind::atom );
            t.val = std::move( $1 );

            $$ = drv.add_to_elements( std::move(t) );
        }

/*TODO: struct map*/
/*
      | L_BRACE wom_structure_row R_BRACE {
          if(driver.p == phase2) {
          }
};
wom_structure_row : wom_structure_row COMMA structure_row | structure_row
structure_row : WORD COLON structure
*/

atom    : INT      { $$ = $1; }
        | FALSEY   { $$ = false; }
        | TRUTHY   { $$ = true; }
        | name_sel { $$ = std::move( $1 ); }
     // | FLOAT
     // | tuple_val
     // | enum_val

enum_val : name_sel L_ANGLE_BRCKT WORD R_ANGLE_BRCKT
tuple_val : L_PAREN wom_atom  R_PAREN
wom_atom : wom_atom COMMA atom | atom


//TODO: ensure members can only be declared once

//TODO: move vectors

%%

void yy::calcxx_parser::error(const location & loc, const std::string & err_msg)
{
    drv.error( loc, err_msg );
}
//  second vector is consumed
void merge_vectors( vec_of_ints & a, vec_of_ints & b )
{
    a.insert(
        a.end(),
        std::make_move_iterator(b.begin()),
        std::make_move_iterator(b.end())
    );
}
void merge_vectors( std::vector<std::string> & a, std::vector<std::string> & b )
{
    a.insert(
        a.end(),
        std::make_move_iterator(b.begin()),
        std::make_move_iterator(b.end())
    );
}
