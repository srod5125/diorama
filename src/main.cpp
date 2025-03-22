#include <string>
#include <filesystem>
#include <vector>

#include "log.hpp"
#include "diorama_driver.hpp"
#include "aux.hpp"


extern std::vector<spec::token> elements;

int main(int argc, char **argv)
{
    if ( argc < 1 )
    {
        LOG_ERR("too few arguments @-@");
        return status::err;
    }

    if ( ! std::filesystem::exists(argv[1]) )
    {
        LOG_ERR("file does not exists ^_^");
        return status::err;
    }

    if ( ! std::filesystem::is_regular_file(argv[1]) )
    {
        LOG_ERR("irregular file entered, only regular files permitted *-*");
        return status::err;
    }


    calcxx_driver drv;
    drv.parse( argv[1] );

    print_elements();


    return status::ok;
}
