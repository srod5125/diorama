%skeleton "lalr1.cc"
%require "3.8.2"
%defines
%define api.parser.class {calcxx_parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
  class calcxx_driver;

  #include <string>
  #include <utility>
  #include <variant>
  #include <vector>
  #include <unordered_map>
  #include <map>
  #include <queue>
  #include <optional>
  #include <tuple>
  #include <cvc5/cvc5.h>


  //since the parser is the root dependency
  //any global aliases are better placed here

  using pair_of_strings = std::pair<std::string,std::string>;
  using sort_or_string = std::variant<cvc5::Sort,std::string>;


  struct SortString {
      std::string value;
      SortString(const std::string& s) : value{s} {}
      SortString() = default;
  };

  struct SetString {
      std::string value;
      SetString(const std::string& s) : value{s} {}
      SetString() = default;
  };



  using sort_or_aux = std::variant<
      SortString,
      SetString,
      pair_of_strings,
      std::vector<sort_or_string>,
      cvc5::Sort
    >;
  using pair_string_sort = std::pair<std::string,sort_or_aux>;

  // we use map since insertions are odered
  using record_map_aux = std::map<std::string,sort_or_aux>;

  using pair_string_term = std::pair<std::string,cvc5::Term>;

  using pair_string_rec = std::pair<std::string,record_map_aux>;

  using vec_pair_strings = std::vector<pair_of_strings>;



  enum class quant { any, all, at_least, at_most, always };

  using cond_op_and_limit = std::pair<quant,int>;

  using range_type = std::tuple<
    cvc5::Kind,cvc5::Kind,
    cvc5::Term,cvc5::Term
  >;

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



%token <std::string> WORD
%token <int> INT
%token <cvc5::Term> FALSE
%token <cvc5::Term> TRUE
%token FLOAT

%type <cvc5::Term> tuple_val
%type <cvc5::Term> enum_val
%type <cvc5::Term> lhs_name_sel rhs_name_sel

%type <cvc5::Term> atom term structure expr
%type <cvc5::Term> equality
%type <cvc5::Term> set_opers
%type <cvc5::Term> membership
%type <cvc5::Term> arithmatic
%type <cvc5::Term> determining_exprs
%type <cvc5::Term> stmt
%type <cvc5::Term> if_stmt
%type <cvc5::Term> selection_stmt
%type <cvc5::Term> assignment

%type <range_type> range

%type <pair_string_sort> declaration
%type <pair_string_sort> named_decl
%type <pair_string_sort> set_decl
%type <pair_string_sort> array_decl
%type <pair_string_sort> tuple_decl
%type <pair_string_sort> enum_decl

%type <pair_string_term> word_to_structure

%type <std::vector<std::string>> wom_enums wom_types wom_sel
%type <std::vector<pair_string_sort>> wom_decleration
%type <std::vector<pair_string_term>> wom_word_to_structure_mapping basic_init
%type <std::vector<cvc5::Term>> wom_stmts zom_determining_exprs wom_when_blocks
%type <std::vector<std::vector<cvc5::Term>>> wom_then_blocks
%type <std::vector<cvc5::Term>> then_block
%type <cvc5::Term> when_block


%type <cond_op_and_limit> quantifier
%type <std::optional<cond_op_and_limit>> zow_quantifier
%type <std::optional<bool>> zow_or_equals
%type <std::string> word_or_members
%type <std::optional<std::string>> zow_word

%printer { yyoutput << "todo"; } <cvc5::Term>;
%printer { yyoutput << "todo"; } <std::vector<pair_string_sort>>;
%printer { yyoutput << "todo"; } <std::vector<pair_string_term>>;
%printer { yyoutput << "todo"; } <std::vector<std::string>>;
%printer { yyoutput << "todo"; } <std::vector<cvc5::Term>>;
%printer { yyoutput << "todo"; } <std::vector<std::vector<cvc5::Term>>>;
%printer { yyoutput << "todo"; } <pair_string_term>;
%printer { yyoutput << "todo"; } <std::optional<bool>>;
%printer { yyoutput << "todo"; } <std::optional<cond_op_and_limit>>;
%printer { yyoutput << "todo"; } <range_type>;
%printer { yyoutput << "todo"; } <std::optional<std::string>>;
%printer { yyoutput << "todo"; } <cond_op_and_limit>;
%printer { yyoutput << "todo"; } <pair_string_sort>;
%printer { yyoutput << $$; } <*>;

%start spec

%%

spec : module

module :  "module" WORD "is" data body "end" WORD


// todo: eventually test out of order decleration,
// todo: mix data and body under univeral_block

data : wom_schemes
body : inits zom_rules

wom_schemes : wom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

word_or_members : WORD | "members"

record_decl : "record" word_or_members "are" wom_decleration "end" "record"


enum_decl : WORD "are" "<" wom_enums ">"
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

inits : zom_inits members_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
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

rule : "rule" zow_word "is" wom_when_blocks wom_then_blocks "end" "rule"

wom_when_blocks : wom_when_blocks "or" when_block | when_block
wom_then_blocks : wom_then_blocks "or" then_block | then_block

when_block : "when" zow_quantifier ":" zom_determining_exprs

zow_quantifier : %empty | quantifier
zom_determining_exprs : %empty | zom_determining_exprs determining_exprs

determining_exprs : "-" expr "."

then_block : "then" ":" wom_stmts
wom_stmts : wom_stmts stmt | stmt


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

if_stmt : "if" expr "then" ":" wom_stmts zom_else_if zow_else "end" "if"
zom_else_if : %empty | zom_else_if else_if
else_if : "else" "if" expr "then" ":" wom_stmts
zow_else : %empty | else
else    : "else" ":" wom_stmts

selection_stmt : "for" WORD "in" expr zow_filter
               | "for" "some" WORD "in" expr zow_filter
               | "for" "all" WORD "in" expr zow_filter
zow_filter : %empty | filter
filter : "such" "that" expr

assignment : lhs_name_sel "'" ":=" expr

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

rhs_name_sel  : WORD | WORD wom_sel

lhs_name_sel  : WORD | WORD wom_sel


wom_sel : wom_sel "->" WORD | "->" WORD

term  : atom
      | "(" expr ")"

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
    | rhs_name_sel
    | tuple_val {}
    | FALSE
    | TRUE
    | enum_val {}

enum_val : rhs_name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
