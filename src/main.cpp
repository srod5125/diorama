#include <iostream>
#include "diorama_driver.hpp"



int main(int argc, char **argv)
{
  int res = 0;
  calcxx_driver driver;


  //TODO: implement short arg acceptor later
  if (argc == 3) {

    if  (argv[1] == std::string("-p")){
      driver.trace_parsing = true;
    }
    else if (argv[1] == std::string("-s")) {
      driver.trace_scanning = true;
    }


  }

  else if (argc == 2){

    //for ( ; driver.p != end ; driver.next_phase() ) {
    //}

    driver.parse(argv[1]);
    print_graph( program_structure );

  }
  else {
    std::cout << "too little or too many args" << std::endl;
    std::cout << "args given: " << argc << std::endl;

  }

  //std::cout << "res: " << driver.slv.checkSat() << std::endl;


  return res;
}
