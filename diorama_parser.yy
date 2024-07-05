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
}

%define api.token.prefix {TOK_}
%token
END 0   "end of file"
ASSIGN  ":="
MINUS   "-"
PLUS    "+"
STAR    "*"
SLASH   "/"
LPAREN  "("
RPAREN  ")"
;

%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%type  <int> exp

%left "+" "-"
%left "*" "/"
                        
%printer { yyoutput << $$; } <*>;

%start unit;

%%

unit:           assignments exp
                {
                  driver.result = $2;
                }
        ;
assignments:    %empty
                {
                }
        |       assignments assignment
                {
                }
        ;

assignment:     "identifier" ":=" exp
                {
                  driver.variables[$1] = $3;
                }              
        ;

exp:            exp "+" exp
                {
                  $$ = $1 + $3;
                }
        |       exp "-" exp
                {
                  $$ = $1 - $3;
                }
        |       exp "*" exp
                {
                  $$ = $1 * $3;
                }
        |       exp "/" exp
                {
                  $$ = $1 / $3;
                }
        |       "(" exp ")"
                {
                  std::swap($$, $2);
                }
        |       "identifier"
                {
                  $$ =driver.variables[$1];
                }
        |       "number"
                {
                  std::swap($$, $1);
                }
        ;
%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
