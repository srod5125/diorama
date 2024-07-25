#include "diorama_driver.hpp"
#include <cvc5/cvc5.h>

calcxx_driver::calcxx_driver()
  : trace_scanning{false},
    trace_parsing{false},
    PHASE{1}
{
  this->slv = std::make_unique<cvc5::Solver>();
  this->slv->setLogic("ALL");
  this->slv->setOption("produce-models", "true");
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
