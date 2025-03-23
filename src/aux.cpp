
#include "aux.hpp"
#include "log.hpp"
#include <cassert>
#include <string>
#include <variant>
#include <vector>

// init for global store
std::vector<spec::token> elements {};


spec::token::token( node_kind kind ) : next(0)
{
    this->kind = kind;
}

spec::token::token( node_kind kind , std::string && name ) : next(0)
{
    this->kind = kind;
    this->name = name;
}

spec::token::token( node_kind kind , std::string & name ) : next(0)
{
    this->kind = kind;
    this->name = std::move( name );
}

void print_children( const std::vector<int> & children )
{
    if ( ! children.empty() ) {
        LOG_NNL("->");
        for ( const auto e : children )
        {
            LOG_NNL( elements[ e ].id );
        }
    }
    LOG();
}

void print_elements( void )
{
    using namespace spec;

    for ( const auto & e : elements  ) {

        LOG_NNL( e.id , node_to_name.at( e.kind ) );

        switch ( e.kind )
        {
            case module: {
                LOG_NNL( "data size: ", std::get<spec::spec_parts>(e.val).data.size() );
                LOG_NNL( "body size: ", std::get<spec::spec_parts>(e.val).body.size() );
                LOG_NNL( "assert size: ", std::get<spec::spec_parts>(e.val).assertions.size() );
            }; break;
            case named_decl: {
                LOG_NNL( std::get<string_pair>(e.val).first, " = ", std::get<string_pair>(e.val).second);
            }; break;
            case record_def: {

            }; break;
            case members_def: {

            }; break;
            case enum_def: {
                for ( const std::string & v : std::get<std::vector<std::string>>(e.val) ) {
                    LOG_NNL( v );
                }
            }; break;
            case members_init: {

            }; break;
            case word_to_struct: {
                if ( std::holds_alternative<int>(e.val) ) { LOG_NNL("int"); }
                else if ( std::holds_alternative<bool>(e.val) ) { LOG_NNL("bool"); }
                else if ( std::holds_alternative<std::string>(e.val) ) { LOG_NNL("string"); }
            }; break;
            case int_val: {

            }; break;
            case rule: {

            }; break;
            case when_block: {
                switch ( std::get<spec::quant_int>(e.val).first )
                {
                    case quant::any: { LOG_NNL("any"); } break;
                    case quant::all: { LOG_NNL("all"); } break;
                    case quant::at_least: { LOG_NNL("at least", std::get<spec::quant_int>(e.val).second ); } break;
                    case quant::at_most: { LOG_NNL("at most", std::get<spec::quant_int>(e.val).second); } break;
                    case quant::always: { LOG_NNL("always"); } break;
                }
            }; break;
            case then_block: {

            }; break;
            case t_and: {

            }; break;
            case t_or: {

            }; break;
            case t_xor: {

            }; break;
            case t_not: {

            }; break;
            case t_equal: {

            }; break;
            case t_not_equal: {

            }; break;
            case t_union: {

            }; break;
            case t_intersect: {

            }; break;
            case t_diff: {

            }; break;
            case t_isin: {

            }; break;
            case t_issub: {

            }; break;
            case t_compliment: {

            }; break;
            case t_gt: {

            }; break;
            case t_gtoe: {

            }; break;
            case t_lt: {

            }; break;
            case t_ltoe: {

            }; break;
            case t_add: {

            }; break;
            case t_minus : {

            }; break;
            case t_multiply: {

            }; break;
            case t_divide : {

            }; break;
            case t_negative: {

            }; break;
            case atom: {
                if ( std::holds_alternative<int>(e.val) ) { LOG_NNL(std::get<int>(e.val)); }
                else if ( std::holds_alternative<bool>(e.val) ) { LOG_NNL(std::get<bool>(e.val)); }
                else if ( std::holds_alternative<std::string>(e.val) ) { LOG_NNL(std::get<std::string>(e.val)); }
            }; break;
            case if_stmt: {
                node_kind k =  elements[ std::get<int>( e.val ) ].kind;
                int id =  elements[ std::get<int>( e.val ) ].id;
                LOG_NNL( "expr: ", node_to_name.at( k ), "at", id );
            }; break;
            case else_if_stmt: {
                node_kind k =  elements[ std::get<int>( e.val ) ].kind;
                int id =  elements[ std::get<int>( e.val ) ].id;
                LOG_NNL( "expr: ", node_to_name.at( k ), "at", id );
            }; break;
            case else_stmt: {

            }; break;
            case assignment: {
                LOG_NNL( std::get<std::string>(e.val) );
            }; break;
            case never_assert: {

            }; break;
            case always_assert: {

            }; break;
            case unkown: {
                LOG_ERR("node i" , e.id , "does not exist");
                assert(false);
            } break;
        }
        if ( e.next != 0 ) LOG_NNL( "next:", e.next );
        print_children( e.children );
    }
}
