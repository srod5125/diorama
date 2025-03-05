#include <fstream>
#include <sstream>
#include <filesystem>

#include "log.hpp"


int main(int argc, char **argv)
{
    if ( argc < 1 ) {
        LOG_ERR("too few arguments @-@");
        return status::err;
    }

    if ( ! std::filesystem::exists(argv[1]) ) {
        LOG_ERR("file does not exists ^_^");
        return status::err;
    }

    if ( ! std::filesystem::is_regular_file(argv[1]) ) {
        LOG_ERR("irregular file entered, only regular files permitted *-*");
        return status::err;
    }

    // note 1
    std::ifstream ifs( argv[1] );

    if ( ! ifs.is_open() ) {
        LOG_ERR( "cannot open file " , argv[1] , "0_0" );
        return status::err;
    }

    std::stringstream file;
    file << ifs.rdbuf();

    LOG( file.view() );




    return status::ok;
}



// Notes:
// Citation:
// https://stackoverflow.com/questions/13035674/
// how-to-read-a-file-line-by-line-or-a-whole-text-file-at-once
