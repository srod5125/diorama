#include <assert.h>

#include "diorama_driver.hpp"
#include <cvc5/cvc5.h>
#include <memory>

calcxx_driver::calcxx_driver()
  : trace_scanning{false},
    trace_parsing{false},
    p{phase1},
    members_declared{false}
{
  //logic options
  this->tm = std::make_unique<cvc5::TermManager>();
  this->slv = std::make_unique<cvc5::Solver>(*this->tm);

  this->slv->setLogic("ALL");
  this->slv->setOption("produce-models", "true");

  //adding known sorts
  this->string_sort_map["int"]  = this->tm->getIntegerSort();
  this->string_sort_map["bool"] = this->tm->getBooleanSort();

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

 void calcxx_driver::next_phase(){

    if ( this->p != end ){
        this->p = (PHASE)(this->p+1);
    }

    PHASE beyond_end = (PHASE)(end+1);
    assert(this->p != beyond_end);
 }
