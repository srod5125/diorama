#include "aux.hpp"
#include "parser.hpp"
#include "diorama_driver.hpp"

calcxx_driver::calcxx_driver()
  : trace_scanning{ false },
    trace_parsing{ false }
{}

calcxx_driver::~calcxx_driver()
{}

int calcxx_driver::parse(const std::string & f)
{
    this->input_file = f;
    scan_begin();

    yy::calcxx_parser parser(*this);

    parser.set_debug_level(trace_parsing);

    int res = parser.parse();
    // 0 if parse succeful

    scan_end();
    return res;
}


void calcxx_driver::error(const yy::location & loc, const std::string & err_mes)
{
    LOG_ERR( loc , ": " , err_mes );
}

void calcxx_driver::error(const std::string & err_mes)
{
    LOG_ERR( "Error: " ,  err_mes );
}


int calcxx_driver::add_to_elements( spec::token && t )
{
    t.id = this->s_file.elems.size();
    this->s_file.elems.emplace_back( t );
    return t.id;
}
int calcxx_driver::add_binop( node_kind op, const vec_of_ints & params )
{
    spec::token t = spec::token( op );
    t.children = std::move( params );
    return add_to_elements( std::move(t) );
}
int calcxx_driver::add_unop( node_kind op, int node )
{
    spec::token t = spec::token( op );
    t.children.push_back( node );
    return add_to_elements( std::move(t) );
}
void calcxx_driver::set_nexts( vec_of_ints & series_of_nodes )
{
    const int curr_node = series_of_nodes[0];
    int curr_el = this->s_file.elems[ curr_node ].id;
    int next_node = 1;
    for(std::size_t i = 1 ; i < series_of_nodes.size(); i += 1, next_node += 1 )
    {
        int next_el = this->s_file.elems[ series_of_nodes[ next_node ] ].id;

        this->s_file.elems[ curr_el ].next = this->s_file.elems[ next_el ].id;

        curr_el = next_el;
    }
}
