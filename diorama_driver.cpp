#include "diorama_driver.hpp"

calcxx_driver::calcxx_driver()
  : trace_scanning(false)
  , trace_parsing(false)
{
  variables["one"] = 1;
  variables["two"] = 2;
}

calcxx_driver::~calcxx_driver()
{
}

auto calcxx_driver::parse(const std::string &f) -> int
{
  file = f;
  scan_begin();
  yy::calcxx_parser parser(*this);
  parser.set_debug_level(trace_parsing);
  int res = parser.parse();
  scan_end();
  return res;
}

auto calcxx_driver::error(const yy::location &l, const std::string &m) -> void
{
  std::cerr << l << ": " << m << std::endl;
}

auto calcxx_driver::error(const std::string &m) -> void
{
  std::cerr << m << std::endl;
}
