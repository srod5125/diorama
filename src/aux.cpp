
#include <cassert>
#include <string>
#include <variant>
#include <vector>
#include <utility>
#include <cstdlib>

#include "aux.hpp"
#include "log.hpp"

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


void spec::file::print_elements( void )
{
    using namespace spec;

    for ( const auto & e : this->elems ) {

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
                node_kind k =  this->elems[ std::get<int>( e.val ) ].kind;
                int id =  this->elems[ std::get<int>( e.val ) ].id;
                LOG_NNL( "expr: ", node_to_name.at( k ), "at", id );
            }; break;
            case else_if_stmt: {
                node_kind k =  this->elems[ std::get<int>( e.val ) ].kind;
                int id =  this->elems[ std::get<int>( e.val ) ].id;
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

        //print children
        if ( ! e.children.empty() ) {
            LOG_NNL("->");
            for ( const auto c : e.children )
            {
                LOG_NNL( this->elems[ c ].id );
            }
        }
        LOG();
    }
}



void spec::file::initialize_spec()
{
    this->tm  = std::make_unique< cvc5::TermManager >();
    this->slv = std::make_unique< cvc5::Solver >( *this->tm  );

    this->known_sorts["int"]  = this->tm->getIntegerSort();
    this->known_sorts["bool"] = this->tm->getBooleanSort();

    this->slv->setOption("produce-models", "true");
    this->slv->setOption("output", "incomplete");
    this->slv->setOption("incremental", "true");
    this->slv->setOption("sygus", "true");

    this->slv->setLogic("ALL");

}

void spec::file::process_primitives( void )
{

    std::vector< int > unkown_records;

    for( spec::token & e: this->elems )
    {
        if ( e.kind == atom )
        {
            if ( std::holds_alternative< int >( e.val ) )
            {
                int x = std::get< int >( e.val );
                e.term = this->tm->mkInteger( x );
            }
            else if ( std::holds_alternative< bool >( e.val ) )
            {
                bool x = std::get< bool >( e.val );
                e.term = this->tm->mkBoolean( x );
            }
        }
        else if ( e.kind == record_def )
        {
            bool all_sorts_known = true;
            for ( const int & decl : e.children  )
            {
                assert( this->elems[ decl ].kind == named_decl );
                //if "type" in named decl is known
                if( ! this->known_sorts.contains( std::get< string_pair >(this->elems[ decl ].val).second ) )
                {
                    all_sorts_known = false;
                    unkown_records.push_back( e.id );
                    break;
                }
            }
            if ( all_sorts_known )
            {
                std::vector< std::pair< std::string , cvc5::Sort > > fields;
                for ( const int & decl : e.children  )
                {
                    assert( this->elems[ decl ].kind == named_decl );

                    std::pair< std::string , cvc5::Sort > field;
                    field.first = std::move( std::get< string_pair >(this->elems[ decl ].val).first );
                    std::string temp_sort = std::move( std::get< string_pair >(this->elems[ decl ].val).second );
                    field.second = this->known_sorts[ temp_sort ];

                    fields.emplace_back( field );
                }

                this->known_sorts[ e.name ] = this->tm->mkRecordSort( fields );
            }
        }
        else if ( e.kind == members_def )
        {
            std::vector< std::pair< std::string , cvc5::Sort > > fields;
            for ( const int & decl : e.children  )
            {
                assert( this->elems[ decl ].kind == named_decl );

                std::pair< std::string , cvc5::Sort > field;
                field.first = std::move( std::get< string_pair >(this->elems[ decl ].val).first );
                std::string temp_sort = std::move( std::get< string_pair >(this->elems[ decl ].val).second );
                field.second = this->known_sorts[ temp_sort ];

                fields.emplace_back( field );
            }

            this->known_sorts[ "members_sort" ] = this->tm->mkRecordSort( fields );
        }
        else if ( e.kind == enum_def )
        {
            TODO("enum def datatype");
        }

    }

    TODO("solve unkown_records recursively for each unkown record, simply serach over all elems until record_def & name = unkown def, recusively");

}
