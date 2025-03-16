#include <fstream>
#include <string>
#include <filesystem>

#include "log.hpp"


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

    // cite 1
    std::ifstream ifs( argv[1] );

    if ( ! ifs.is_open() )
    {
        LOG_ERR( "cannot open file " , argv[1] , "0_0" );
        return status::err;
    }

    std::string tmp_str;
    std::string input_file;
    while (std::getline(ifs, tmp_str))
    {
      input_file += tmp_str + "\n";
    }

    return status::ok;
}



// CITATIONS:
// 1:
// https://stackoverflow.com/questions/13035674/
// how-to-read-a-file-line-by-line-or-a-whole-text-file-at-once
