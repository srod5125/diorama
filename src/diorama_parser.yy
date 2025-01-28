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
EOF 0      "end of file"
H1         "#"
H2         "##"
H3         "###"
H4         "####"
H5         "#####"
BLD        "**"
MEMBERS    "members"
ARE        "are"
END        "end"
ASSIGN     ":="
MINUS      "-"
PLUS       "+"
STAR       "*"
SLASH      "/"
LPAREN     "("
RPAREN     ")"
MODULE     "module"
IS         "is"
RECORD     "record"
COLON      ":"
COMMA      ","
GT         "<"
LT         ">"
PERIOD     "."
IN         "in"
ISSETOF    "is-set-of"
START      "start"
MAPS       "maps"
TO         "to"
FOR        "for"
RULE       "rule"
OR         "or"
WHEN       "when"
THEN       "then"
ANY        "any"
ALL        "all"
AT         "at"
MOST       "most"
LEAST      "least"
ALWAYS     "always"
NEVER      "never"
MUST       "must"
IF         "if"
ELSE       "else"
SOME       "some"
SUCH       "such"
THAT       "that"
TICK       "'"
AND        "and"
ORRATHER   "or-rather"
NOT        "not"
EQ         "equals"
NOTEQ      "not-equals"
UNION      "unions"
INTERSECT  "intersects"
DIFF       "differences"
ISIN       "is-in"
ISSUB      "is-subset"
COMP       "compliments"
ISGT       "is-greater-than"
ISLT       "is-less-than"
BTWN       "between"
XOR        "or-equals"
DOTDOT     ".."
RBRCKT     "]"
LBRCKT     "["
ARROW      "->"
LBRACE     "{"
RBRACE     "}"
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

module :  "module" WORD "is" data body zom_assertions "end" WORD


// TODO: eventually test out of order decleration,
// TODO: mix data and body under univeral_block

data           : zom_schemes members_decl
body           : inits zom_rules
zom_assertions : %empty | zom_assertions assertion

    /* data & schemes */
zom_schemes : zom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

are_or_is : "are" | "is"

record_decl : "record" WORD are_or_is wom_decleration "end" "record"
members_decl : "members" ARE wom_decleration "end" "members"

enum_decl : WORD are_or_is "<" wom_enums ">"
wom_enums : wom_enums "," WORD | WORD


wom_decleration : wom_decleration declaration | declaration

declaration : named_decl "."
            | set_decl "."
            | array_decl "."
            | tuple_decl "."

named_decl : WORD either_in_or_is WORD
set_decl : WORD "is-set-of" WORD
//TODO: second word can be expression
array_decl  : WORD "maps" WORD "to" WORD
tuple_decl  : WORD either_in_or_is "(" wom_types ")"

wom_types  : wom_types "," WORD | WORD


//TODO: wom_elements -> wom_terms

either_in_or_is : "in" | "is"

    /* rules & statments */
inits : zom_inits members_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
    /*TODO: basic init & array init should be unified*/
array_init   : "start" "for" WORD "is" array_map_init "end" "start"
struct_init  : "start" "for" WORD "is" basic_init "end" "start"
members_init : "start" "for" "members" "is" basic_init "end" "start"

array_map_init : wom_structure_mapping
basic_init : wom_word_to_structure_mapping

wom_structure_mapping  : wom_structure_mapping "," structure_mapping | structure_mapping
structure_mapping : structure ":=" structure

wom_word_to_structure_mapping : wom_word_to_structure_mapping "," word_to_structure | word_to_structure

word_to_structure :  WORD ":=" structure


zom_rules : %empty | zom_rules rule
zow_word : %empty | WORD

rule : "rule" zow_word are_or_is wom_when_blocks wom_then_blocks "end" "rule"

wom_when_blocks : wom_when_blocks "or" when_block | when_block
wom_then_blocks : wom_then_blocks "or" then_block | then_block

when_block : "when" zow_quantifier ":" zom_dash_exprs

zow_quantifier : %empty | quantifier
zom_dash_exprs : %empty | zom_dash_exprs dash_expr

dash_expr : "-" expr "."

then_block : "then" ":" wom_stmts

wom_stmts : stmt |   wom_stmts stmt

quantifier
  : "any"
  | "all"
  | "at" "most" INT
  | "at" "least" INT
  | "always"
//TODO: add or equal to to at most or at least

stmt : if_stmt
     | selection_stmt "."
     | assignment "."

if_stmt : "if" expr "then" wom_stmts zom_else_if zow_else "end" "if"
zom_else_if : %empty | zom_else_if else_if
else_if : "else" "if" expr "then" ":" wom_stmts
zow_else : %empty | else
else    : "else" ":" wom_stmts

selection_stmt : "for" WORD "in" expr zow_filter
               | "for" "some" WORD "in" expr zow_filter
               | "for" "all" WORD "in" expr zow_filter
zow_filter : %empty | filter
filter : "such" "that" expr

assignment : name_sel "'" ":=" expr

    /* assertions & expressions */

assertion : never_assertion | always_assertion

never_assertion  : MUST NEVER  wom_dash_exprs END NEVER
always_assertion : MUST ALWAYS wom_dash_exprs END ALWAYS

wom_dash_exprs : dash_expr | wom_dash_exprs dash_expr

expr  : equality
      | expr "and" equality
      | expr "or" equality
      | expr "or-rather" equality
      | "not" expr

equality  : set_opers
          | equality "equals" set_opers
          | equality "not-equals" set_opers

set_opers  : membership
           | set_opers "unions" membership
           | set_opers "intersects" membership
           | set_opers "differences" membership
           | set_opers "is-in" membership
           | set_opers "is-subset" membership
           | "compliments" set_opers

membership  : arithmatic
            | membership "is-greater-than" zow_or_equals arithmatic
            | membership "is-less-than" zow_or_equals arithmatic
            | membership zow_is "between" range

zow_is : %empty  | "is"
zow_or_equals : %empty  | "or-equals"

range : arithmatic ".." arithmatic
      | "(" arithmatic ".." arithmatic ")"
      | "(" arithmatic ".." arithmatic "]"
      | "[" arithmatic ".." arithmatic ")"
      | "[" arithmatic ".." arithmatic "]"

arithmatic  : term
            | arithmatic "+" term
            | arithmatic "-" term
            | arithmatic "*" term
            | arithmatic "/" term

// lhs & rhs name_sel

name_sel  : WORD | WORD wom_sel

wom_sel : wom_sel "->" WORD | "->" WORD

term  : atom | "(" expr ")"

structure : atom

/*TODO: struct map*/
/*
      | "{" wom_structure_row "}" {
          if(driver.p == phase2) {
          }
};
wom_structure_row : wom_structure_row "," structure_row | structure_row
structure_row : WORD ":" structure
*/

atom : INT
    | FLOAT
    | name_sel
    | tuple_val
    | FALSE
    | TRUE
    | enum_val

enum_val : name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location &l, const std::string &m)
{
  driver.error(l, m);
}
