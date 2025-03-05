#include <assert.h>
#include <memory>
#include "diorama_driver.hpp"
#include "parser.hpp"
//#include <cvc5/cvc5.h>

calcxx_driver::calcxx_driver()
  : trace_scanning{ false },
    trace_parsing{ false },
    p{ PHASE(0) }
{
  // solver options
  this->tm  = std::make_unique<cvc5::TermManager>();
  this->slv = std::make_unique<cvc5::Solver>( *this->tm );

  this->slv->setOption("produce-models", "true");
  //this->slv->setOption("output", "incomplete");
  this->slv->setOption("incremental", "true");
  this->slv->setOption("sygus", "true");

  this->slv->setLogic("ALL");

  //adding known sorts
  this->known_sorts["int"]  = this->tm->getIntegerSort();
  this->known_sorts["bool"] = this->tm->getBooleanSort();

  this->spec.never_count  = 1;
  this->spec.always_count = 1;

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

void calcxx_driver::check( ) {
    LOG("123");
}


void calcxx_driver::error(const yy::location &l, const std::string &m)
{
    LOG_ERR( l , ": " , m );
}

void calcxx_driver::error(const std::string &m)
{
    LOG_ERR( "Error: " ,  m );
}

//TODO: phase 0 is syntax checking phase, if fail
//TODO: do not advance phase
const PHASE beyond_end = (PHASE)(end+1);
PHASE calcxx_driver::next_phase(){

    PHASE current_phase = this->p;
    if ( current_phase != end ){
       current_phase = (PHASE)(current_phase+1);
       this->p       = current_phase;
    }

   assert(current_phase != beyond_end);
   return current_phase;
}
