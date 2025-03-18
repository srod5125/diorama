
#include <string>

#include "parser.hpp"

#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP


#undef YY_DECL
#define YY_DECL yy::calcxx_parser::symbol_type yylex(calcxx_driver& drv)
YY_DECL;


class calcxx_driver
{
public:

  std::string file;
  bool trace_scanning;
  bool trace_parsing;

  calcxx_driver();
  virtual ~calcxx_driver();

  void scan_begin();
  void scan_end();
  int  parse(const std::string &f);
  void error(const yy::location &l, const std::string &m);
  void error(const std::string &m);

};


#endif
