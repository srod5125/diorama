%skeleton "lalr1.cc"
%require "3.8.2"
%defines
%define api.parser.class {calcxx_parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert

%code requires
{
  #include <string>
  class calcxx_driver;
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
EOF 0       "end of file"
H1          "#"
H2          "##"
H3          "###"
H4          "####"
H5          "#####"
BLD         "**"
MEMBERS     "members" 
ARE         "are"
END         "end"
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
FALSE      "false"
TRUE       "true"

;

%token <std::string> WORD
%token <int> INT 
%token <float> FLOAT

                        
%printer { yyoutput << $$; } <*>;

%start spec_module;

%%
spec_module :  "module" WORD "is" data body "end" WORD

data : wom_schemes members
body : inits zom_rules

wom_schemes : wom_schemes scheme | scheme
scheme : record_decl
       | enum_decl

record_decl : "record" WORD "are" wom_record_row "end" "record"
wom_record_row : wom_record_row "," record_row | record_row
record_row :  WORD ":" WORD

enum_decl : WORD "are" "<" wom_enums ">"
wom_enums : wom_enums "," WORD | WORD



members : "members" "are" wom_decleration "end" "members"
wom_decleration : wom_decleration declaration | declaration
declaration : named_decl "."
            | set_decl "."
            | array_decl "."
            | tuple_decl "."

named_decl  : WORD either_in_or_is WORD
set_decl    : WORD "is-set-of" WORD
array_decl  : WORD "maps" WORD "to" WORD //TODO: second word can be expression
tuple_decl  : WORD either_in_or_is "(" WORD wom_tuples ")"
wom_tuples  : wom_tuples "," WORD | WORD

either_in_or_is : "in" | "is"

inits : zom_inits member_init

zom_inits : %empty | zom_inits init
init : struct_init | array_init
array_init  : "start" "for" WORD "is" array_map_init "end" "start"
struct_init : "start" "for" WORD "is" basic_init "end" "start"
member_init : "start" "for" "members" "is" basic_init "end" "start"

array_map_init : wom_structure_mapping
wom_structure_mapping 
  : wom_structure_mapping "," structure ":=" structure 
  | structure ":=" structure
wom_word_to_structure_mapping 
  : wom_word_to_structure_mapping "," WORD ":=" structure 
  | WORD ":=" structure
basic_init : wom_word_to_structure_mapping

zom_rules : %empty | zom_rules rule
optional_word : %empty | WORD
rule : "rule" optional_word "is" when_blocks then_blocks "end" "rule"
when_blocks : wom_when_blocks
wom_when_blocks : wom_when_blocks "or" when_block | when_block
then_blocks : wom_then_blocks
wom_then_blocks : wom_then_blocks "or" then_block | then_block
when_block : "when" zow_quantifier ":" zom_determining_exprs
zow_quantifier : %empty | quantifier
zom_determining_exprs : %empty | zom_determining_exprs determining_exprs
then_block : "then" ":" wom_stmts
wom_stmts : wom_stmts stmt | stmt

determining_exprs : "-" expr "."

quantifier : "any"        
           | "all"        
           | "at" "most"  
           | "at" "least" 
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

assignment : lhs_member "'" ":=" expr

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
zow_is : %empty | "is"
zow_or_equals : %empty | "or-equals"


range  :     arithmatic ".." arithmatic
       | "(" arithmatic ".." arithmatic ")"
       | "(" arithmatic ".." arithmatic "]"
       | "[" arithmatic ".." arithmatic ")"
       | "[" arithmatic ".." arithmatic "]"

arithmatic  : term
            | arithmatic "+" term
            | arithmatic "-" term
            | arithmatic "*" term
            | arithmatic "/" term


name_sel  : WORD               
          | WORD wom_sel
lhs_member  : WORD               
            | WORD wom_sel
wom_sel : wom_sel "->" WORD | "->" WORD

term  : atom
      | "(" expr ")"

structure : atom | "{" wom_structure_row "}"
wom_structure_row : wom_structure_row "," structure_row | structure_row
structure_row : WORD ":" structure
atom : INT | FLOAT | name_sel | tuple_val | FALSE | TRUE | enum_val
enum_val : name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once

%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
