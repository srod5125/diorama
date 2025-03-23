#ifndef CALCXX_DRIVER_HPP
#define CALCXX_DRIVER_HPP

#include <string>

#include "parser.hpp"
#include "aux.hpp"

#undef YY_DECL
#define YY_DECL yy::calcxx_parser::symbol_type yylex(calcxx_driver& drv)
YY_DECL;


class calcxx_driver
{
    public:

    std::string input_file;
    bool trace_scanning;
    bool trace_parsing;

    calcxx_driver();
    virtual ~calcxx_driver();

    void scan_begin();
    void scan_end();
    int  parse(const std::string &f);
    void error(const yy::location &l, const std::string &m);
    void error(const std::string &m);

    spec::file s_file;

    // helpers to construct "ast"
    int add_to_elements( spec::token && t );
    int add_binop( node_kind op, const vec_of_ints & params );
    int add_unop( node_kind op, int node );
    void set_nexts( vec_of_ints & series_of_nodes );
};


#endif
