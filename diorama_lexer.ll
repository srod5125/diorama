%{
  #include <cerrno>
  #include <climits>
  #include <cstdlib>
  #include <string>
  #include "diorama_driver.hpp"
  #include "parser.hpp"
  
  #undef yywrap
  #define yywrap() 1

  static yy::location loc;
%}

%option nodefault
%option noyywrap nounput batch debug noinput

word  [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t]

%{
    #define YY_USER_ACTION loc.columns(yyleng);
%}

%%

%{
   loc.step();
%}

{blank}+ loc.step();
[\n]+ loc.lines(yyleng); loc.step();

"-"  return yy::calcxx_parser::make_MINUS(loc);
"+"  return yy::calcxx_parser::make_PLUS(loc);
"*"  return yy::calcxx_parser::make_STAR(loc);
"/"  return yy::calcxx_parser::make_SLASH(loc);
"("  return yy::calcxx_parser::make_LPAREN(loc);
")"  return yy::calcxx_parser::make_RPAREN(loc);
":=" return yy::calcxx_parser::make_ASSIGN(loc);

"module" return yy::calcxx_parser::make_MODULE(loc);
"is"     return yy::calcxx_parser::make_IS(loc);
"end"     return yy::calcxx_parser::make_END(loc);

{int} {
  errno = 0;
  long n = strtol(yytext, NULL, 10);

  if (!(INT_MIN <= n && n<= INT_MAX && errno != ERANGE))
    driver.error(loc, "integer is out of range");

  return yy::calcxx_parser::make_NUMBER(n, loc);
}
  
{word}    return yy::calcxx_parser::make_WORD(yytext, loc);

.       driver.error (loc, "invalid character");

<<EOF>> return yy::calcxx_parser::make_EOF(loc);

%%


void calcxx_driver::scan_begin()
{
  yy_flex_debug = trace_scanning;

  if (this->file.empty() || this->file == "-"){
    
    yyin = stdin;
 
  }
  else if (!(yyin = fopen(this->file.c_str(), "r"))) {

    error("cannot open " + this->file + ": " + strerror(errno));
    exit(EXIT_FAILURE);

  }
}

void calcxx_driver::scan_end()
{
  fclose(yyin);
}