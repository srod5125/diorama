%{
  #include <cerrno>
  #include <climits>
  #include <cstdlib>
  #include <string>
  #include <string>
  #include <iostream>
  #include "diorama_driver.hpp"
  #include "parser.hpp"
  
  #undef yywrap
  #define yywrap() 1

  static yy::location loc;
%}

%option nodefault
%option noyywrap nounput batch debug noinput

word    [a-zA-Z][a-zA-Z_0-9]*
int     [0-9]+
float   {int}\.{int}
blank   [ \t]

comment \(\*[\s\S]*?\*\)
/*     ex: (* some comment *) */

%{
    #define YY_USER_ACTION loc.columns(yyleng);
%}

%%

%{
   loc.step();
%}
  /*{comment} {loc.lines(yyleng); printf("x"); loc.step();}*/


{blank}+  loc.step();
[\n]+     loc.lines(yyleng); loc.step();



"-"  return yy::calcxx_parser::make_MINUS(loc);
"+"  return yy::calcxx_parser::make_PLUS(loc);
"*"  return yy::calcxx_parser::make_STAR(loc);
"/"  return yy::calcxx_parser::make_SLASH(loc);
"("  return yy::calcxx_parser::make_LPAREN(loc);
")"  return yy::calcxx_parser::make_RPAREN(loc);
":=" return yy::calcxx_parser::make_ASSIGN(loc);

"module"  return yy::calcxx_parser::make_MODULE(loc);
"is"      return yy::calcxx_parser::make_IS(loc);
"end"     return yy::calcxx_parser::make_END(loc);

"record"          return yy::calcxx_parser::make_RECORD(loc);
"are"             return yy::calcxx_parser::make_ARE(loc);
":"               return yy::calcxx_parser::make_COLON(loc);
","               return yy::calcxx_parser::make_COMMA(loc);
"<"               return yy::calcxx_parser::make_GT(loc);
">"               return yy::calcxx_parser::make_LT(loc);
"members"         return yy::calcxx_parser::make_MEMBERS(loc);
"."               return yy::calcxx_parser::make_PERIOD(loc);
"in"              return yy::calcxx_parser::make_IN(loc);
"is-set-of"       return yy::calcxx_parser::make_ISSETOF(loc);
"start"           return yy::calcxx_parser::make_START(loc);
"maps"            return yy::calcxx_parser::make_MAPS(loc);
"to"              return yy::calcxx_parser::make_TO(loc);
"for"             return yy::calcxx_parser::make_FOR(loc);
"rule"            return yy::calcxx_parser::make_RULE(loc);
"or"              return yy::calcxx_parser::make_OR(loc);
"when"            return yy::calcxx_parser::make_WHEN(loc);
"then"            return yy::calcxx_parser::make_THEN(loc);
"any"             return yy::calcxx_parser::make_ANY(loc);
"all"             return yy::calcxx_parser::make_ALL(loc);
"at"              return yy::calcxx_parser::make_AT(loc);
"most"            return yy::calcxx_parser::make_MOST(loc);
"least"           return yy::calcxx_parser::make_LEAST(loc);
"always"          return yy::calcxx_parser::make_ALWAYS(loc);
"if"              return yy::calcxx_parser::make_IF(loc);
"else"            return yy::calcxx_parser::make_ELSE(loc);
"some"            return yy::calcxx_parser::make_SOME(loc);
"such"            return yy::calcxx_parser::make_SUCH(loc);
"that"            return yy::calcxx_parser::make_THAT(loc);
"'"               return yy::calcxx_parser::make_TICK(loc);
"and"             return yy::calcxx_parser::make_AND(loc);
"or-rather"       return yy::calcxx_parser::make_ORRATHER(loc);
"not"             return yy::calcxx_parser::make_NOT(loc);
"equals"          return yy::calcxx_parser::make_EQ(loc);
"not-equals"      return yy::calcxx_parser::make_NOTEQ(loc);
"unions"          return yy::calcxx_parser::make_UNION(loc);
"intersects"      return yy::calcxx_parser::make_INTERSECT(loc);
"differences"     return yy::calcxx_parser::make_DIFF(loc);
"is-in"           return yy::calcxx_parser::make_ISIN(loc);
"is-subset"       return yy::calcxx_parser::make_ISSUB(loc);
"compliments"     return yy::calcxx_parser::make_COMP(loc);
"is-greater-than" return yy::calcxx_parser::make_ISGT(loc);
"is-less-than"    return yy::calcxx_parser::make_ISLT(loc);  
"between"         return yy::calcxx_parser::make_BTWN(loc);
"or-equals"       return yy::calcxx_parser::make_XOR(loc);
".."              return yy::calcxx_parser::make_DOTDOT(loc);
"]"               return yy::calcxx_parser::make_RBRCKT(loc);
"["               return yy::calcxx_parser::make_LBRCKT(loc);
"->"              return yy::calcxx_parser::make_ARROW(loc);
"{"               return yy::calcxx_parser::make_LBRACE(loc);
"}"               return yy::calcxx_parser::make_RBRACE(loc);
"false"           return yy::calcxx_parser::make_FALSE(loc);
"true"            return yy::calcxx_parser::make_TRUE(loc);

{int} {
  errno = 0;
  long n = strtol(yytext, NULL, 10);

  if(!(INT_MIN <= n && n<= INT_MAX && errno != ERANGE))
    driver.error(loc, "integer is out of range");

  std::cout << n << " n " << std::endl;

  return yy::calcxx_parser::make_INT(n, loc);
}

{float} {
  float f = std::stof(yytext);
  return yy::calcxx_parser::make_FLOAT(f,loc);
}
  
{word}  { return yy::calcxx_parser::make_WORD(yytext, loc); }

.       { driver.error(loc, "invalid character"); }

<<EOF>> { return yy::calcxx_parser::make_EOF(loc); }

%%


void calcxx_driver::scan_begin()
{
  yy_flex_debug = trace_scanning;

  if(this->file.empty() || this->file == "-"){
    
    yyin = stdin;
 
  }
  else if(!(yyin = fopen(this->file.c_str(), "r"))) {

    error("cannot open " + this->file + ": " + strerror(errno));
    exit(EXIT_FAILURE);

  }
}

void calcxx_driver::scan_end()
{
  fclose(yyin);
}