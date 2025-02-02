#include "diorama_driver.hpp"
#include "log.hpp"


int main(int argc, char **argv)
{
    int res = 0;
    calcxx_driver drv;


    //TODO: implement short arg acceptor later
    if (argc == 3) {

        if  (argv[1] == std::string("-p")){
            drv.trace_parsing = true;
        }
        else if (argv[1] == std::string("-s")) {
            drv.trace_scanning = true;
        }

    }
    else if (argc == 2){

        // do {
        //     drv.parse(argv[1]);
        // } while( drv.next_phase() != end );

        drv.parse(argv[1]);

    }
    else {
        LOG_ERR( "too little or too many args" );
        LOG_ERR( "args given: " , argc );
    }

    //std::cout << "res: " << driver.slv.checkSat() << std::endl;


  return res;
}
