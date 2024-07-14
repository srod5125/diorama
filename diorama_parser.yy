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
ASSIGN   ":="
MINUS    "-"
PLUS     "+"
STAR     "*"
SLASH    "/"
LPAREN   "("
RPAREN   ")"
MODULE   "module"
IS       "is"
END      "end"
EOF 0    "end of file"
;

%token <std::string> WORD
%token <int> NUMBER 

%left "+" "-"
%left "*" "/"
                        
%printer { yyoutput << $$; } <*>;

%start spec_module;

%%
spec_module : "module" WORD "is" "end" WORD
%%

void yy::calcxx_parser::error(const location_type &l, const std::string &m)
{
  driver.error(l, m);
}
