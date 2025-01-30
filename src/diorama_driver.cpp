#include <assert.h>
#include <iostream>
#include <memory>
#include "diorama_driver.hpp"
//#include <cvc5/cvc5.h>

calcxx_driver::calcxx_driver()
  : trace_scanning{false},
    trace_parsing{false},
    p{collect_params},
    members_declared{false},
    stmt_count{0},
    rule_count{0}
{
  // solver options
  this->tm  = std::make_unique<cvc5::TermManager>();
  this->slv = std::make_unique<cvc5::Solver>( *this->tm );

  this->slv->setLogic("ALL");
  this->slv->setOption("produce-models", "true");
  this->slv->setOption("output", "incomplete");

  //adding known sorts
  // this->string_sort_map["int"]  = this->tm->getIntegerSort();
  // this->string_sort_map["bool"] = this-e>tm->getBooleanSort();

}

calcxx_driver::~calcxx_driver()
{}

int calcxx_driver::parse(const std::string &f)
{

  this->file = f;
  scan_begin();

  yy::calcxx_parser parser(*this);

  parser.set_debug_level(trace_parsing);

  int res = parser.parse();
  // 0 if parse succeful


  scan_end();
  return res;
}

void calcxx_driver::error(const yy::location &l, const std::string &m)
{
  std::cerr << l << ": " << m << std::endl;
}

void calcxx_driver::error(const std::string &m)
{
  std::cerr << "Error: " <<  m << std::endl;
}

//TODO: phase 0 is syntax checking phase, if fail
//TODO: do not advance phase

PHASE calcxx_driver::next_phase(){

    PHASE current_phase = this->p;
    if ( current_phase != end ){
       current_phase = (PHASE)(current_phase+1);
       this->p       = current_phase;
    }

   const PHASE beyond_end = (PHASE)(end+1);
   assert(current_phase != beyond_end);
   return current_phase;
}
