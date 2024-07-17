#include <iostream>
#include "diorama_driver.hpp"

#include "cvc5/cvc5.h"


int main(int argc, char **argv)
{
  int res = 0;
  calcxx_driver driver;

  cvc5::Term t;

  //TODO: implement short arg acceptor later
  if (argc == 3) {

    if  (argv[1] == std::string("-p")){
      driver.trace_parsing = true;
    }
    else if (argv[1] == std::string("-s")) {
      driver.trace_scanning = true;
    } 

    driver.parse(argv[2]);
  }

  else if (argc == 2){

    driver.parse(argv[1]);

  }
  else {
    std::cout << "too little or too many args" << std::endl;
  }


  return res;
}
