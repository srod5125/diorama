
#include <string>
#include <unordered_map>
#include <memory>
#include <variant>

#include "parser.hpp"
#include <cvc5/cvc5.h>

#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP


#undef YY_DECL
#define YY_DECL \
  yy::calcxx_parser::symbol_type yylex(calcxx_driver& driver)
YY_DECL;

enum PHASE {
  phase1,
  end
};



class calcxx_driver
{
public:


  std::string file;
  bool trace_scanning;
  bool trace_parsing;
  PHASE p;


  // constrain solver fields
  std::unique_ptr<cvc5::Solver> slv;
  cvc5::Term members; 

  bool members_declared;
  

  calcxx_driver();
  virtual ~calcxx_driver();

  void scan_begin();
  void scan_end();
  int  parse(const std::string &f);
  void error(const yy::location &l, const std::string &m);
  void error(const std::string &m);

  void next_phase();



  // known sort into
  std::unordered_map<std::string,cvc5::Sort>    string_sort_map;
  std::unordered_map<std::string,record_map>    string_rec_map;


  //auxillary & helper member
  std::queue<pair_string_rec> aux_string_rec_map;

  
};
//access fields of records, for now
//all of our fields are records, we use this constant
//to denote univeral access to the cosntructors of our
//records, access fields
namespace acc {
  const std::string fields = "a";
}


#endif 
