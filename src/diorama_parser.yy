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

  #include "aux.hpp"


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
%token <bool> FALSE TRUE
%token FLOAT

%type <Node> stmt wom_stmts
%type <Node> if_stmt selection_stmt assignment
%type <std::optional<Node>> zom_else_if zow_else
%type <Node> else_if else

%printer { yyoutput << "todo opt"; } <std::optional<Node>>;
%printer { yyoutput << $$.id << "todo tos"; } <Node>;
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

then_block : "then" ":" wom_stmts {

    // in node -> all statements in then block -> out node
    Node then_in = Node();
    then_in.temp_tag = "then in";
    register_node(then_in);

    int stmt_start = $3.id;
    then_in.tos.push_back( stmt_start );

    int last_node_id = get_final_chain_id( then_in.id , program_structure );

    Node then_out = Node();
    then_out.temp_tag = "then out";
    register_node(then_out);
    chain( program_structure, last_node_id, then_out.id );

    program_structure[ then_in.id ] = then_in;
    program_structure[ then_out.id ] = then_out;

}
wom_stmts : stmt
    |   wom_stmts stmt {
    chain( program_structure, $1 , $$ );
}


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

if_stmt : "if" expr "then" wom_stmts zom_else_if zow_else "end" "if" {

    Node if_start = Node();
    if_start.temp_tag = "if start";
    register_node( if_start );

    Node if_end = Node();
    if_end.temp_tag = "if end";
    register_node( if_end );


    int stmt_id = $4.id;
    if_start.tos.push_back( stmt_id );

    int last_node_id = get_final_chain_id( if_start.id , program_structure );

    auto else_ifs = $5;
    if ( else_ifs.has_value() ) {
        chain( program_structure, last_node_id, else_ifs.value() );
        last_node_id = get_final_chain_id( last_node_id , program_structure );
    }
    auto else_stmt = $6;
    if ( else_stmt.has_value() ) {
        chain( program_structure, last_node_id, else_stmt.value() );
        last_node_id = get_final_chain_id( last_node_id , program_structure );
    }

    chain( program_structure, last_node_id, if_end );
    if_start.tos.push_back( if_end.id );

    $$ = if_start;
}
zom_else_if : %empty { $$ = std::nullopt; }
    | zom_else_if else_if {
    if ( $1.has_value() ){
        chain( program_structure, $1.value(), $2 );
        $$ = $1;
    }
    else {
        $$ = $2;
    }
}

else_if : "else" "if" expr "then" ":" wom_stmts {
    $$ = $6;
}
zow_else : %empty { $$ = std::nullopt; }
    | else
else    : "else" ":" wom_stmts {
    $$ = $3;
}

selection_stmt : "for" WORD "in" expr zow_filter
               | "for" "some" WORD "in" expr zow_filter
               | "for" "all" WORD "in" expr zow_filter
zow_filter : %empty | filter
filter : "such" "that" expr

assignment : name_sel "'" ":=" expr {
    Node assign_node = Node();
    assign_node.temp_tag = "assignment";
    register_node( assign_node );
    $$ =  assign_node;
}

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
    | name_sel
    | tuple_val {}
    | FALSE
    | TRUE
    | enum_val {}

enum_val : name_sel "<" WORD ">"
tuple_val : "(" wom_atom  ")"
wom_atom : wom_atom "," atom | atom


//TODO: ensure members can only be declared once

//TODO: refactor $$ = $1, to more effecient move or insert

%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
