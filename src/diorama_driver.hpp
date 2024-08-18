
#include <string>
#include <unordered_map>
#include <memory>
#include <variant>
#include <vector>

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
  phase2,
  phase3,
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
  std::unique_ptr<cvc5::Solver>      slv;
  std::unique_ptr<cvc5::TermManager> tm;
  
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
  std::unordered_map<std::string,cvc5::Sort>  string_sort_map;

  std::unordered_map<std::string,cvc5::Term> module_fns;

  //TODO: struct map
  //std::unordered_map<std::vector<std::string>,std::string> record_members_map;

  //auxillary & helper member
  std::queue<pair_string_rec> aux_string_rec_map;

  
};
//access fields of records, for now
//all of our fields are records, we use this constant
//to denote univeral access to the cosntructors of our
//records, access fields
namespace acc {
  const std::string fields = "a";
};


//helper struct
/*
struct VecStrHash {
    std::size_t operator()(const std::vector<std::string>& v) const {
        
        std::size_t hash1;

        for (const auto& s: v) {
          hash1 ^= std::hash<std::string>{}(s) << 1;
        }

        return hash1;

    }
    bool VecStrHash::operator==(const std::vector<std::string>& b) {
        return false;
    }
};
*/


#endif 
