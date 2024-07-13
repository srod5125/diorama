#include <iostream>
#include "diorama_driver.hpp"

#include "cvc5/cvc5.h"


int main(int argc, char **argv)
{
  int res = 0;
  calcxx_driver driver;

  cvc5::Term t;

  for (int i = 1; i < argc; ++i) {

    if (argv[i] == std::string("-p")){

      driver.trace_parsing = true;
    
    }
    else if (argv[i] == std::string("-s")) {
    
      driver.trace_scanning = true;
    
    } 
    else if (!driver.parse(argv[i])) {
    
      std::cout << driver.result << std::endl;
    }
    else {
      res = 1;
    }

  }
  return res;
}
