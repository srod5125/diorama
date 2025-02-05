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
  #include <utility>
  #include <unordered_map>
  #include <algorithm>
  #include <optional>

  #include <cvc5/cvc5.h>

  #include "aux.hpp"
  #include "log.hpp"


  //since the parser is the root dependency
  //any global aliases are better placed here

  enum class quant { any, all, at_least, at_most, always };

  using name_term       = std::pair< std::string_view , cvc5::Term >;
  using record_type     = std::unordered_map< std::string_view , cvc5::Term >;
  using vec_of_terms    = std::vector< cvc5::Term >;
  using pair_of_terms   = std::pair< cvc5::Term , cvc5::Term >;
  using vec_of_pairs    = std::vector< pair_of_terms >;
  using opt_term        = std::optional< cvc5::Term > ;
  using quant_pair      = std::pair< quant , opt_term >;
  using opt_quant       = std::optional< quant_pair >;
  using opt_bool        = std::optional< bool >;
  using opt_string_view = std::optional< std::string_view >;
}

%param { calcxx_driver& drv }

%locations

%initial-action
{
  @$.begin.filename = @$.end.filename = &drv.file;
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



%token < std::string_view > WORD
%token < cvc5::Term > INT FALSEY TRUTHY
 // %token FLOAT

%type < name_term > named_decl declaration
%type < record_type > wom_decleration
%type < cvc5::Term > structure atom word_to_structure
%type < vec_of_terms > wom_word_to_structure_mapping basic_init
%type < cvc5::Term > wom_then_blocks then_block wom_stmts
%type < cvc5::Term > members_init expr else
%type < quant_pair > quantifier
%type < cvc5::Term > when_block name_sel
%type < cvc5::Term > stmt if_stmt selection_stmt assignment
%type < vec_of_pairs > zom_else_if
%type < pair_of_terms > else_if
%type < opt_term > zow_else
%type < opt_quant > zow_quantifier
%type < cvc5::Term > term arithmetic membership equality
%type < cvc5::Term > set_opers
%type < opt_bool > zow_or_equals
%type < opt_string_view > zow_word

/*
%printer { yyoutput << "TODO opt"; } <std::optional<Node>>;
%printer { yyoutput << $$.id << "TODO tos"; } <Node>;
%printer { yyoutput << $$; } <*>;
*/

%start spec

%%

spec : module

module :  MODULE WORD IS data body zom_assertions END WORD


// TODO: eventually test out of order decleration,
// TODO: mix data and body under univeral_block

data           : zom_schemes members_decl
body           : inits zom_rules
zom_assertions : %empty | zom_assertions assertion

    /* data & schemes */
zom_schemes : zom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

are_or_is : ARE | IS

record_decl : RECORD WORD are_or_is wom_decleration END RECORD

members_decl : MEMBERS ARE wom_decleration END MEMBERS {
    //TODO: refactor as vec, do move onto
    for ( const auto & [ _ , term ] : $3  ) {
        drv.spec.members.emplace_back( term );
    }
}

enum_decl : WORD are_or_is L_ANGLE_BRCKT wom_enums R_ANGLE_BRCKT
wom_enums : wom_enums COMMA WORD | WORD


wom_decleration : wom_decleration declaration {
    $$.insert($2);
}
    | declaration {
        $$.insert($1);
}

declaration : named_decl DOT
            // | set_decl DOT
            // | array_decl DOT
            // | tuple_decl DOT

named_decl : WORD in_or_is WORD {
    if ( drv.known_sorts.contains( $3 ) ) {
        const cvc5::Term t = drv.tm->mkVar( drv.known_sorts[$3] , std::string($1) );
        $$ = std::make_pair( $1 , t );
    }
}
set_decl : WORD ISSETOF WORD
//TODO: second word can be expression
array_decl  : WORD MAPS WORD TO WORD
tuple_decl  : WORD in_or_is L_PAREN wom_types R_PAREN

wom_types  : wom_types COMMA WORD | WORD


//TODO: wom_elements -> wom_terms

in_or_is : IN | IS

    /* rules & statments */
inits : zom_inits members_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
array_init   : START FOR WORD IS array_map_init END START
struct_init  : START FOR WORD IS basic_init END START

members_init : START FOR MEMBERS IS basic_init END START {

    cvc5::Term pre_body =  ( $5.size() > 1 )
        ?  drv.tm->mkTerm(cvc5::Kind::AND, $5)
        :  $5[0]; //TODO: move not copy

    if ( ! pre_body.isNull() ) {
        const cvc5::Term pre = drv.slv->defineFun(
            "pre-f",
            drv.spec.members,
            drv.known_sorts["bool"],
            pre_body
        );
        $$ = pre;
    }
    else {
        // TODO: handle if no pre defined
    }
}

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping {$$=$1;} //TODO: move not copy

wom_structure_mapping  : wom_structure_mapping COMMA structure_mapping | structure_mapping
structure_mapping : structure ASSIGN structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping COMMA word_to_structure  {
    $$.push_back($3);
}
    | word_to_structure {
    $$.push_back($1);
}

word_to_structure :  WORD ASSIGN structure {
    const std::string_view mem_name { $1 };
    const cvc5::Term curr_mem = find_term( drv.spec.members , mem_name ).value();
    $$ = drv.tm->mkTerm( cvc5::Kind::EQUAL, { curr_mem , $3 });
}

zom_rules : %empty | zom_rules rule
zow_word : %empty { $$ = std::nullopt; } | WORD { $$ = $1; }

rule : RULE zow_word are_or_is when_block wom_then_blocks END RULE {

    //TODO: create spec scpedific rule count when no name provided
    std::string_view rule_name = $2.value_or("");
    std::string func_name = "trans_" + std::string( rule_name );

    const cvc5::Term no_op { drv.tm->mkTrue() };

    const cvc5::Term trans_body = drv.tm->mkTerm(
        cvc5::Kind::ITE,
        { $4 , $5 , no_op }
    );

    vec_of_terms mems_and_mems_next = drv.spec.members;
    mems_and_mems_next.insert(
        mems_and_mems_next.begin() ,
        drv.spec.next_members.begin() ,
        drv.spec.next_members.end()
    );

    const cvc5::Term trans = drv.slv->defineFun(
        func_name,
        mems_and_mems_next,
        drv.known_sorts["bool"],
        trans_body
    );

    drv.spec.trans = trans;
}


when_block : WHEN zow_quantifier COLON zom_dash_exprs {

    quant q = quant::always;
    if ( $2.has_value() ) {
        q = $2.value().first;
    }

    //TODO: eval all quants
    switch (q) {
        case quant::any: {} break;
        case quant::all: {} break;
        case quant::at_least: {} break;
        case quant::at_most: {} break;
        case quant::always : {
            $$ = drv.tm->mkTrue();
        } break;

        default: break;
    }

}

zow_quantifier : %empty { $$ = std::nullopt; } | quantifier { $$ = $1; }
zom_dash_exprs : %empty | zom_dash_exprs dash_expr

dash_expr : DASH expr DOT

wom_then_blocks : then_block
                | wom_then_blocks OR then_block { $$ = drv.tm->mkTerm( cvc5::Kind::OR , { $1 , $3 } ); }


then_block : THEN COLON wom_stmts { $$=$3; }

wom_stmts : stmt | wom_stmts stmt { $$ = drv.tm->mkTerm(cvc5::Kind::AND, { $1 , $2 } ); }

quantifier
  : ANY     { $$ = std::make_pair( quant::any , std::nullopt ); }
  | ALL     { $$ = std::make_pair( quant::all , std::nullopt ); }
  | ALWAYS  { $$ = std::make_pair( quant::always , std::nullopt ); }
  | AT MOST INT  { $$ = std::make_pair( quant::at_most , $3 ); }
  | AT LEAST INT { $$ = std::make_pair( quant::at_least , $3 ); }
//TODO: add or equal to to at most or at least

stmt : if_stmt
     | selection_stmt DOT
     | assignment DOT

if_stmt : IF expr THEN wom_stmts zom_else_if zow_else END IF {

    // TODO: assert expr is bool sort, else throw user err
    // TODO: ensure zom_else_if is followed by zow_else,
    //         if zom_else_if & zow_else doesnt throw err
    // TODO: ensure wom_stmts exists

    const cvc5::Term no_op { drv.tm->mkTrue() };
    cvc5::Term last_else   { $6.value_or( no_op ) };

    const cvc5::Term statements_to_run { $4 };

    if ( $5.size() > 0 ) {
        cvc5::Term all_else_ifs;
        for ( std::size_t i = 1; i < $5.size(); i+=1  ) {
            all_else_ifs = drv.tm->mkTerm(
                cvc5::Kind::ITE,
                { $5[1].first , $5[1].second , all_else_ifs }
            );
        }
        $$ = drv.tm->mkTerm(
            cvc5::Kind::ITE,
            { $2, statements_to_run, all_else_ifs }
        );
    }
    else {
        $$ = drv.tm->mkTerm(
            cvc5::Kind::ITE,
            { $2, statements_to_run , last_else }
        );
    }

}
zom_else_if : %empty { $$={}; } | zom_else_if else_if {
    $$.push_back( $2 );
}
else_if : ELSE IF expr THEN COLON wom_stmts {
    $$ = std::make_pair( $3 , $6 );
}
zow_else : %empty { $$=std::nullopt; } | else { $$ = $1; }

else : ELSE COLON wom_stmts {
    $$ = $3;
}

selection_stmt : FOR WORD IN expr zow_filter
               | FOR SOME WORD IN expr zow_filter
               | FOR ALL WORD IN expr zow_filter
zow_filter : %empty | filter
filter : SUCH THAT expr

assignment : name_sel TIC ASSIGN expr {
    const std::string next_name = $1.getSymbol() + "_next";
    const cvc5::Sort var_sort = $1.getSort();
    const cvc5::Term next_mem = drv.tm->mkVar( var_sort , next_name );

    $$ = drv.tm->mkTerm( cvc5::Kind::EQUAL , { next_mem , $4 } );

    if ( ! find_term( drv.spec.next_members , next_name ).has_value() ) {
        drv.spec.next_members.push_back( next_mem );
    }
}

    /* assertions & expressions */

assertion : never_assertion | always_assertion

never_assertion  : MUST NEVER  wom_dash_exprs END NEVER
always_assertion : MUST ALWAYS wom_dash_exprs END ALWAYS

wom_dash_exprs : dash_expr | wom_dash_exprs dash_expr

expr  : equality
      | expr AND equality      { $$ = drv.tm->mkTerm(cvc5::Kind::AND , { $1 , $3 }); }
      | expr OR equality       { $$ = drv.tm->mkTerm(cvc5::Kind::OR , { $1 , $3 }); }
      | expr ORRATHER equality { $$ = drv.tm->mkTerm(cvc5::Kind::XOR , { $1 , $3 }); }
      | NOT expr               { $$ = drv.tm->mkTerm(cvc5::Kind::NOT , { $2 }); }

equality  : set_opers
          | equality EQ set_opers    { $$ = drv.tm->mkTerm(cvc5::Kind::EQUAL , { $1 , $3 }); }
          | equality NOTEQ set_opers { $$ = drv.tm->mkTerm(cvc5::Kind::DISTINCT , { $1 , $3 }); }

set_opers  : membership
           | set_opers UNION membership     { $$ = drv.tm->mkTerm(cvc5::Kind::SET_UNION , { $1 , $3 }); }
           | set_opers INTERSECT membership { $$ = drv.tm->mkTerm(cvc5::Kind::SET_INTER , { $1 , $3 }); }
           | set_opers DIFF membership      { $$ = drv.tm->mkTerm(cvc5::Kind::SET_MINUS , { $1 , $3 }); }
           | set_opers ISIN membership      { $$ = drv.tm->mkTerm(cvc5::Kind::SET_MEMBER , { $1 , $3 }); }
           | set_opers ISSUB membership     { $$ = drv.tm->mkTerm(cvc5::Kind::SET_SUBSET , { $1 , $3 }); }
           | COMP set_opers                 { $$ = drv.tm->mkTerm(cvc5::Kind::SET_COMPLEMENT ,{ $2 } ); }

membership  : arithmetic
            | membership ISGT zow_or_equals arithmetic {
                if ( $3.has_value() ) {
                    $$ = drv.tm->mkTerm( cvc5::Kind::GEQ , { $1 , $4 } );
                }
                else {
                    $$ = drv.tm->mkTerm( cvc5::Kind::GT , { $1 , $4 } );
                }
            }
            | membership ISLT zow_or_equals arithmetic {
                if ( $3.has_value() ) {
                    $$ = drv.tm->mkTerm( cvc5::Kind::LEQ , { $1 , $4 } );
                }
                else {
                    $$ = drv.tm->mkTerm( cvc5::Kind::LT , { $1 , $4 } );
                }
            }
            // | membership zow_is BTWN range

zow_is : %empty  | IS
zow_or_equals : %empty { $$ = std::nullopt; } | OR EQ { $$ = true; }

//TODO: range within
range : arithmetic DOTDOT arithmetic
      | L_PAREN arithmetic DOTDOT arithmetic R_PAREN
      | L_PAREN arithmetic DOTDOT arithmetic R_BRCKT
      | L_BRCKT arithmetic DOTDOT arithmetic R_PAREN
      | L_BRCKT arithmetic DOTDOT arithmetic R_BRCKT

arithmetic  : term
            | arithmetic PLUS term  { $$ = drv.tm->mkTerm(cvc5::Kind::ADD , { $1 , $3 } ); }
            | arithmetic DASH term  { $$ = drv.tm->mkTerm(cvc5::Kind::SUB , { $1 , $3 } ); }
            | arithmetic STAR term  { $$ = drv.tm->mkTerm(cvc5::Kind::MULT , { $1 , $3 } ); }
            | arithmetic SLASH term { $$ = drv.tm->mkTerm(cvc5::Kind::INTS_DIVISION , { $1 , $3 } ); }
            // TODO: assert $3 cannot be 0 for div
// lhs & rhs name_sel

name_sel  : WORD { $$ = find_term( drv.spec.members , $1 ).value(); }
    //    | WORD wom_sel

wom_sel : wom_sel ARROW WORD | ARROW WORD

term  : atom | L_PAREN expr R_PAREN { $$ = $2; }

structure : atom

/*TODO: struct map*/
/*
      | L_BRACE wom_structure_row R_BRACE {
          if(driver.p == phase2) {
          }
};
wom_structure_row : wom_structure_row COMMA structure_row | structure_row
structure_row : WORD COLON structure
*/

atom : INT
     | FALSEY
     | TRUTHY
     | name_sel
     // | FLOAT
     // | tuple_val
     // | enum_val

enum_val : name_sel L_ANGLE_BRCKT WORD R_ANGLE_BRCKT
tuple_val : L_PAREN wom_atom  R_PAREN
wom_atom : wom_atom COMMA atom | atom


//TODO: ensure members can only be declared once

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location &l, const std::string &m) {
    drv.error(l, m);
}
