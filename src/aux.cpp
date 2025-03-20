
#include "aux.hpp"
#include "log.hpp"

// init for global store
std::vector<spec::token> elements {};


spec::token::token( node_kind kind )
{
    this->kind = kind;
}

spec::token::token( node_kind kind , std::string && name )
{
    this->kind = kind;
    this->name = name;
}

spec::token::token( node_kind kind , std::string & name )
{
    this->kind = kind;
    this->name = std::move( name );
}
