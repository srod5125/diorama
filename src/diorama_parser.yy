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
  #include <variant>
  #include <vector>
  #include <unordered_map>
  #include <map>
  #include <queue>
  #include <optional>
  #include <tuple>

  #include "aux.hpp"
  #include "log.hpp"


  //since the parser is the root dependency
  //any global aliases are better placed here

  // using block = std::pair< token , std::optional >


  enum class quant { any, all, at_least, at_most, always };

}


%param { calcxx_driver& driver }

%locations

%initial-action
{
  @$.begin.filename = @$.end.filename = &driver.file;
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



%token <std::string_view> WORD
%token <int> INT
%token <bool> FALSE TRUE
%token FLOAT

/*
%type <Node> if_stmt selection_stmt assignment
%type <std::optional<Node>> zom_else_if zow_else
%type <Node> else_if else

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
members_decl : MEMBERS ARE wom_decleration END MEMBERS

enum_decl : WORD are_or_is L_ANGLE_BRCKT wom_enums R_ANGLE_BRCKT
wom_enums : wom_enums COMMA WORD | WORD


wom_decleration : wom_decleration declaration | declaration

declaration : named_decl DOT
            | set_decl DOT
            | array_decl DOT
            | tuple_decl DOT

named_decl : WORD in_or_is WORD
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
    /*TODO: basic init & array init should be unified*/
array_init   : START FOR WORD IS array_map_init END START
struct_init  : START FOR WORD IS basic_init END START
members_init : START FOR MEMBERS IS basic_init END START

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping

wom_structure_mapping  : wom_structure_mapping COMMA structure_mapping | structure_mapping
structure_mapping : structure ASSIGN structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping COMMA word_to_structure | word_to_structure

word_to_structure :  WORD ASSIGN structure


zom_rules : %empty | zom_rules rule
zow_word : %empty | WORD

rule : RULE zow_word are_or_is wom_when_blocks wom_then_blocks END RULE

wom_when_blocks : wom_when_blocks OR when_block | when_block
wom_then_blocks : wom_then_blocks OR then_block | then_block

when_block : WHEN zow_quantifier COLON zom_dash_exprs

zow_quantifier : %empty | quantifier
zom_dash_exprs : %empty | zom_dash_exprs dash_expr

dash_expr : DASH expr DOT

then_block : THEN COLON wom_stmts

wom_stmts : stmt |   wom_stmts stmt

quantifier
  : ANY
  | ALL
  | AT MOST INT
  | AT LEAST INT
  | ALWAYS
//TODO: add or equal to to at most or at least

stmt : if_stmt
     | selection_stmt DOT
     | assignment DOT

if_stmt : IF expr THEN wom_stmts zom_else_if zow_else END IF
zom_else_if : %empty | zom_else_if else_if
else_if : ELSE IF expr THEN COLON wom_stmts
zow_else : %empty | else
else    : ELSE COLON wom_stmts

selection_stmt : FOR WORD IN expr zow_filter
               | FOR SOME WORD IN expr zow_filter
               | FOR ALL WORD IN expr zow_filter
zow_filter : %empty | filter
filter : SUCH THAT expr

assignment : name_sel TIC ASSIGN expr

    /* assertions & expressions */

assertion : never_assertion | always_assertion

never_assertion  : MUST NEVER  wom_dash_exprs END NEVER
always_assertion : MUST ALWAYS wom_dash_exprs END ALWAYS

wom_dash_exprs : dash_expr | wom_dash_exprs dash_expr

expr  : equality
      | expr AND equality
      | expr OR equality
      | expr ORRATHER equality
      | NOT expr

equality  : set_opers
        | equality EQ set_opers
          | equality NOTEQ set_opers

set_opers  : membership
           | set_opers UNION membership
           | set_opers INTERSECT membership
           | set_opers DIFF membership
           | set_opers ISIN membership
           | set_opers ISSUB membership
           | COMP set_opers

membership  : arithmatic
            | membership ISGT zow_or_equals arithmatic
            | membership ISLT zow_or_equals arithmatic
            | membership zow_is BTWN range

zow_is : %empty  | IS
zow_or_equals : %empty  | XOR

range : arithmatic DOTDOT arithmatic
      | L_PAREN arithmatic DOTDOT arithmatic R_PAREN
      | L_PAREN arithmatic DOTDOT arithmatic R_BRCKT
      | L_BRCKT arithmatic DOTDOT arithmatic R_PAREN
      | L_BRCKT arithmatic DOTDOT arithmatic R_BRCKT

arithmatic  : term
            | arithmatic PLUS term  /*add*/
            | arithmatic DASH term  /*minus*/
            | arithmatic STAR term  /*mulitply*/
            | arithmatic SLASH term /*divide*/

// lhs & rhs name_sel

name_sel  : WORD | WORD wom_sel

wom_sel : wom_sel ARROW WORD | ARROW WORD

term  : atom | L_PAREN expr R_PAREN

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
    | FLOAT
    | name_sel
    | tuple_val
    | FALSE
    | TRUE
    | enum_val

enum_val : name_sel L_ANGLE_BRCKT WORD R_ANGLE_BRCKT
tuple_val : L_PAREN wom_atom  R_PAREN
wom_atom : wom_atom COMMA atom | atom


//TODO: ensure members can only be declared once

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location &l, const std::string &m)
{
  driver.error(l, m);
}
