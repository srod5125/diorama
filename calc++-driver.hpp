#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP

#include <string>
#include <map>
#include "calc++-parser.hpp"

#undef YY_DECL
#define YY_DECL                                             \
  yy::calcxx_parser::symbol_type yylex(calcxx_driver& driver)
YY_DECL;

class calcxx_driver
{
public:
  calcxx_driver();
  virtual ~calcxx_driver();

  auto scan_begin() -> void;
  auto scan_end() -> void;
  auto parse(const std::string &f) -> int;
  auto error(const yy::location &l, const std::string &m) -> void;
  auto error(const std::string &m) -> void;
  
  std::map<std::string, int> variables;
  int result;
  std::string file;
  bool trace_scanning;
  bool trace_parsing;
};

#endif 
