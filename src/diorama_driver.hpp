
#include <string>
#include <memory>
#include <vector>
#include <unordered_map>

#include <cvc5/cvc5.h>

#include "parser.hpp"
#include "aux.hpp"
#include "hash_info.hpp"

#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP


#undef YY_DECL
#define YY_DECL \
  yy::calcxx_parser::symbol_type yylex(calcxx_driver& drv)
YY_DECL;

enum PHASE {
  collect_params,
  check_inv,
  end
};

struct Spec_File {
    std::vector<cvc5::Term> members;
    std::vector<cvc5::Term> next_members;
    cvc5::Term pre;
    cvc5::Term trans;
};

class calcxx_driver
{
public:

  std::string file;
  bool trace_scanning;
  bool trace_parsing;
  PHASE p;

  // constraint solver fields
  std::unique_ptr<cvc5::Solver>     slv;
  std::unique_ptr<cvc5::TermManager> tm;


  std::unordered_map<std::string_view, cvc5::Sort, sort_name_hash, sort_name_equal> known_sorts;

  Spec_File spec;
  cvc5::Term no_op;

  calcxx_driver();
  virtual ~calcxx_driver();

  void scan_begin();
  void scan_end();
  int  parse(const std::string &f);
  void error(const yy::location &l, const std::string &m);
  void error(const std::string &m);

  PHASE next_phase();


};
//access fields of records, for now
//all of our fields are records, we use this constant
//to denote univeral access to the cosntructors of our
//records, access fields
namespace acc {
  const std::string fields = "a";
};



#endif
