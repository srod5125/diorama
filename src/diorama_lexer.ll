%{
  #include <cerrno>
  #include <climits>
  #include <cstdlib>
  #include <string_view>
  #include <iostream>
  #include "parser.hpp"
  #include "diorama_driver.hpp"


  #undef yywrap
  #define yywrap() 1

  static yy::location loc;
%}

%option nodefault noyywrap nounput
%option batch debug noinput
%option caseless

comment [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]
word    [a-zA-Z][a-zA-Z_0-9]*
int     [0-9]+
float   {int}\.{int}
blank   [ \t]


/* ex: (* some comment *) */
/*   \(\*[\s\S]*?\*\)   */

%{
    #define YY_USER_ACTION loc.columns(yyleng);
%}

%%

%{
   loc.step();
%}

{comment} loc.lines(yyleng); loc.step();
{blank}+  loc.step();
[\n]+     loc.lines(yyleng); loc.step();




"#"           return yy::calcxx_parser::make_H1(loc);
"##"          return yy::calcxx_parser::make_H2(loc);
"###"         return yy::calcxx_parser::make_H3(loc);
"####"        return yy::calcxx_parser::make_H4(loc);
"#####"       return yy::calcxx_parser::make_H5(loc);
"**"          return yy::calcxx_parser::make_BLD(loc);


"-"  return yy::calcxx_parser::make_DASH(loc);
"+"  return yy::calcxx_parser::make_PLUS(loc);
"*"  return yy::calcxx_parser::make_STAR(loc);
"/"  return yy::calcxx_parser::make_SLASH(loc);
"("  return yy::calcxx_parser::make_L_PAREN(loc);
")"  return yy::calcxx_parser::make_R_PAREN(loc);

":="        return yy::calcxx_parser::make_ASSIGN(loc);
"is-set-to" return yy::calcxx_parser::make_ASSIGN(loc);

"module"  return yy::calcxx_parser::make_MODULE(loc);
"is"      return yy::calcxx_parser::make_IS(loc);
"end"     return yy::calcxx_parser::make_END(loc);

"record"          return yy::calcxx_parser::make_RECORD(loc);
"are"             return yy::calcxx_parser::make_ARE(loc);
":"               return yy::calcxx_parser::make_COLON(loc);
","               return yy::calcxx_parser::make_COMMA(loc);
"<"               return yy::calcxx_parser::make_L_ANGLE_BRCKT(loc);
">"               return yy::calcxx_parser::make_R_ANGLE_BRCKT(loc);
"members"         return yy::calcxx_parser::make_MEMBERS(loc);
"."               return yy::calcxx_parser::make_DOT(loc);
"in"              return yy::calcxx_parser::make_IN(loc);
"is-set-of"       return yy::calcxx_parser::make_ISSETOF(loc);
"start"           return yy::calcxx_parser::make_START(loc);
"maps"            return yy::calcxx_parser::make_MAPS(loc);
"to"              return yy::calcxx_parser::make_TO(loc);
"for"             return yy::calcxx_parser::make_FOR(loc);
"rule"            return yy::calcxx_parser::make_RULE(loc);
    /*consider adding the key word policy*/
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
"'"               return yy::calcxx_parser::make_TIC(loc);
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
"must"            return yy::calcxx_parser::make_MUST(loc);
"never"           return yy::calcxx_parser::make_NEVER(loc);
".."              return yy::calcxx_parser::make_DOTDOT(loc);
"["               return yy::calcxx_parser::make_L_BRCKT(loc);
"]"               return yy::calcxx_parser::make_R_BRCKT(loc);
"->"              return yy::calcxx_parser::make_ARROW(loc);
"{"               return yy::calcxx_parser::make_L_BRACE(loc);
"}"               return yy::calcxx_parser::make_R_BRACE(loc);
"false"           {
                    return yy::calcxx_parser::make_FALSE(false,loc);
                  }
"true"            {
                    return yy::calcxx_parser::make_TRUE(true,loc);
                  }


{int} {
  errno = 0;
  long n = strtol(yytext, NULL, 10);

  if(!(INT_MIN <= n && n<= INT_MAX && errno != ERANGE)){
    driver.error(loc, "integer is out of range");
  }

  return yy::calcxx_parser::make_INT(n, loc);
}

{float} {
  //float f = std::stof(yytext);
  //return yy::calcxx_parser::make_FLOAT(f,loc);
  yy::calcxx_parser::make_FLOAT(loc);
}

{word}  {
  //TODO: return word lowered
  return yy::calcxx_parser::make_WORD(std::string_view(yytext), loc);
}

.       { }

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
