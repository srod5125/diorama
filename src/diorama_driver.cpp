#include "parser.hpp"
#include "diorama_driver.hpp"

calcxx_driver::calcxx_driver()
  : trace_scanning{ false },
    trace_parsing{ false }
{}

calcxx_driver::~calcxx_driver()
{}

int calcxx_driver::parse(const std::string & f)
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


void calcxx_driver::error(const yy::location & loc, const std::string & err_mes)
{
    LOG_ERR( loc , ": " , err_mes );
}

void calcxx_driver::error(const std::string & err_mes)
{
    LOG_ERR( "Error: " ,  err_mes );
}
