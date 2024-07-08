#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP

#include <string>
#include <map>
#include "parser.hpp"

#undef YY_DECL
#define YY_DECL                                             \
  yy::calcxx_parser::symbol_type yylex(calcxx_driver& driver)
YY_DECL;

class calcxx_driver
{
public:
  calcxx_driver();
  virtual ~calcxx_driver();

  void scan_begin();
  void scan_end();
  int parse(const std::string &f);
  void error(const yy::location &l, const std::string &m);
  void error(const std::string &m);
  
  std::map<std::string, int> variables;
  int result;
  std::string file;
  bool trace_scanning;
  bool trace_parsing;
};

#endif 
