#include <string>
#include <filesystem>

#include "log.hpp"
#include "diorama_driver.hpp"
#include "aux.hpp"



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

    // take ownership of the current spec,
    // then potentially parse another
    spec::file s_file = std::move( drv.s_file );

    s_file.print_elements();
    s_file.initialize_spec();


    return status::ok;
}
