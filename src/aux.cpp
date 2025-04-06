
#include <cassert>
#include <string>
#include <variant>
#include <vector>
#include <utility>
#include <cstdlib>

#include "aux.hpp"
#include "log.hpp"

spec::token::token( node_kind kind ) : next( spec::undefined_id )
{
    this->kind = kind;
}

spec::token::token( node_kind kind , std::string && name ) : next( spec::undefined_id )
{
    this->kind = kind;
    this->name = name;
}

spec::token::token( node_kind kind , std::string & name ) : next( spec::undefined_id )
{
    this->kind = kind;
    this->name = std::move( name );
}


void spec::file::print_elements( void ) const
{
    using namespace spec;

    for ( const auto & e : this->elems ) {

        LOG_NNL( e.id , node_to_name.at( e.kind ) );

        switch ( e.kind )
        {
            case module: {
                LOG_NNL( "inits size: ", std::get<spec::spec_parts>(e.val).inits.size() );
                LOG_NNL( "rules size: ", std::get<spec::spec_parts>(e.val).rules.size() );
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
                if ( std::holds_alternative<int>(e.val) ) { LOG_NNL( std::get<int>(e.val) ); }
                else if ( std::holds_alternative<bool>(e.val) ) { LOG_NNL( std::get<bool>(e.val) ); }
                else if ( std::holds_alternative<std::string>(e.val) ) { LOG_NNL( std::get<std::string>(e.val) ); }
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
                LOG_NNL( e.name, ":= " ,"@", std::get<int>(e.val) );
                TODO("get val ");
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


void spec::file::initialize_spec( void )
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

    this->rule_count    = 0;
    this->assert_count  = 0;
}

void spec::file::process_primitives( void )
{
    std::vector< int > unkown_records;

    for( spec::token & e: this->elems )
    {
        switch ( e.kind )
        {
            case module: {
                spec_parts sp = std::get< spec_parts >( e.val );
                this->slv->push();
                {
                    cvc5::Term inv_f = this->slv->synthFun(
                        "inv-f",
                        this->members_as_vec,
                        this->tm->getBooleanSort()
                    );

                    this->slv->addSygusInvConstraint(
                        inv_f,
                        this->elems[ sp.inits[0] ].term,
                        this->elems[ sp.rules[0] ].term,
                        this->elems[ sp.assertions[0] ].term
                    );

                }
                this->slv->pop();

            }; break;
            case named_decl: {

            }; break;
            case record_def: {
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
                        std::string sort_label = std::move( std::get< string_pair >(this->elems[ decl ].val).second );
                        field.second = this->known_sorts[ sort_label ];

                        fields.emplace_back( field );
                    }

                    this->known_sorts[ e.name ] = this->tm->mkRecordSort( fields );
                }
            }; break;
            case members_def: {
                for ( const int & decl : e.children  )
                {
                    assert( this->elems[ decl ].kind == named_decl );

                    std::string mem_name = std::move( std::get< string_pair >(this->elems[ decl ].val).first );
                    std::string sort_label = std::move( std::get< string_pair >(this->elems[ decl ].val).second );
                    cvc5::Sort sort = this->known_sorts[ sort_label ];

                    cvc5::Term mem      = this->tm->mkVar( sort , mem_name );
                    cvc5::Term mem_next = this->tm->mkVar( sort , mem_name + "next" );

                    this->members[ mem_name ] = mem;
                    this->members_next[ mem_name ] = mem_next;
                    this->members_as_vec.push_back( mem );
                }

            }; break;
            case enum_def: {
                TODO("enum def datatype");
            }; break;
            case members_init: {
                std::vector< cvc5::Term > init_terms;
                for ( const int c : e.children )
                {
                    assert( this->elems[ c ].kind == word_to_struct );

                    cvc5::Term mem_var = this->members[ this->elems[ c ].name ];
                    cvc5::Term val     = this->eval_atom( this->elems[ c ].val );

                    cvc5::Term t = this->tm->mkTerm(
                        cvc5::Kind::EQUAL,
                        { mem_var , val }
                    );
                    init_terms.emplace_back( t );
                }

                cvc5::Term init_term = this->and_all( init_terms );
                e.term = this->slv->defineFun(
                    "members_init",
                    this->members_as_vec,
                    this->tm->getBooleanSort(),
                    init_term
                );

            }; break;
            case word_to_struct: {

            }; break;
            case rule: {
                std::string rule_name;
                if ( e.name.empty() ) {
                    rule_name = "rule" + std::to_string( this->get_rule_count() );
                }
                else {
                    rule_name = std::move( e.name );
                }

                std::vector< cvc5::Term > or_thens;
                for ( std::size_t then_id = 1; then_id < e.children.size(); then_id += 1 ){
                    or_thens.push_back( this->elems[ e.children[ then_id ] ].term );
                }
                cvc5::Term when_block  = this->elems[ e.children[0] ].term;
                cvc5::Term then_blocks = this->or_all( or_thens );
                cvc5::Term no_op       = this->tm->mkTrue();

                cvc5::Term rule_block = this->tm->mkTerm(
                    cvc5::Kind::ITE,{
                        when_block,
                        then_blocks,
                        no_op
                    }
                );
                std::vector< cvc5::Term > temp_mems_and_mems_next = this->members_as_vec;
                for ( const auto & [ _ , mem_next ] : this->members_next ){
                    temp_mems_and_mems_next.push_back( mem_next );
                }

                e.term = this->slv->defineFun(
                    rule_name,
                    temp_mems_and_mems_next,
                    this->tm->getBooleanSort(),
                    rule_block
                );
            }; break;
            case when_block: {
                quant_int quantifier = std::get< quant_int >( e.val );

                std::vector< cvc5::Term > list_of_exprs;

                for ( const int c : e.children ) {
                    list_of_exprs.push_back( this->elems[ c ].term );
                }

                cvc5::Term when;
                switch ( quantifier.first )
                {
                    case quant::any: {
                        when = this->or_all( list_of_exprs );
                    } break;
                    case quant::all: {
                        when = this->and_all( list_of_exprs );
                    } break;
                    case quant::at_least: {
                        std::vector< cvc5::Term > if_true_one_else_zero;
                        cvc5::Term one  = this->tm->mkInteger( 1 );
                        cvc5::Term zero = this->tm->mkInteger( 0 );
                        for ( const cvc5::Term & expr : list_of_exprs ) {
                            if_true_one_else_zero.emplace_back(
                                this->tm->mkTerm( cvc5::Kind::ITE,{
                                    expr, one, zero
                                } )
                            );
                        }
                        cvc5::Term threshold = this->tm->mkInteger( quantifier.second );
                        cvc5::Term sum_of_trues = this->tm->mkTerm( cvc5::Kind::ADD, if_true_one_else_zero );

                        when = this->tm->mkTerm( cvc5::Kind::GEQ, { sum_of_trues, threshold } );
                    } break;
                    case quant::at_most: {
                        std::vector< cvc5::Term > if_true_one_else_zero;
                        cvc5::Term one  = this->tm->mkInteger( 1 );
                        cvc5::Term zero = this->tm->mkInteger( 0 );
                        for ( const cvc5::Term & expr : list_of_exprs ) {
                            if_true_one_else_zero.emplace_back(
                                this->tm->mkTerm( cvc5::Kind::ITE,{
                                    expr, one, zero
                                } )
                            );
                        }
                        cvc5::Term threshold = this->tm->mkInteger( quantifier.second );
                        cvc5::Term sum_of_trues = this->tm->mkTerm( cvc5::Kind::ADD, if_true_one_else_zero );

                        when = this->tm->mkTerm( cvc5::Kind::LEQ, { sum_of_trues, threshold } );
                    } break;
                    case quant::always: {
                        when = this->tm->mkTrue();
                    } break;
                    default: {
                        LOG_ERR("unkown quantifier");
                        assert(false);
                    }
                }
                e.term = when;
            }; break;
            case then_block: {
                std::vector< cvc5::Term > stmts = this->next_stmts( e.next );
                e.term = this->and_all( stmts );
            }; break;
            case t_and: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::AND,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_or: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::OR,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_xor: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::XOR,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_not: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::NOT,
                    { this->elems[ e.children[0] ].term } );
            }; break;
            case t_equal: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::EQUAL,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
                TODO("eventually add datatype equality");
            }; break;
            case t_not_equal: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::DISTINCT,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_union: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_UNION,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
                TODO("check sort then do union type");
            }; break;
            case t_intersect: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_INTER,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_diff: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_MINUS,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_isin: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_MEMBER,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_issub: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_SUBSET,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_compliment: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SET_COMPLEMENT,
                    { this->elems[ e.children[0] ].term } );
            }; break;
            case t_gt: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::GT,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_gtoe: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::GEQ,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_lt: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::LT,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_ltoe: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::LT,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_add: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::ADD,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_minus : {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::SUB,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_multiply: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::MULT,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_divide : {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::DIVISION,
                    { this->elems[ e.children[0] ].term , this->elems[ e.children[1] ].term  } );
            }; break;
            case t_negative: {
                e.term = this->tm->mkTerm(
                    cvc5::Kind::NEG,
                    { this->elems[ e.children[0] ].term  } );
            }; break;
            case atom: {
                if ( e.id == 20 ){
                    LOG_NNL("x");
                }
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
                else if ( std::holds_alternative< std::string >( e.val ) )
                {
                    // std::string_view mem = std::string_view( std::get< std::string >( e.val ) );
                    // LOG("auto mem:",mem);
                    e.term = this->members[ std::get< std::string >( e.val ) ];
                }
            }; break;
            case if_stmt: {
                std::vector< cvc5::Term > true_branch_stmts = this->next_stmts( e.next );
                // the last else for any branch can always be true since
                // the default would be x' := x, which is always true
                cvc5::Term else_branches = this->tm->mkTrue();

                // we must construct the else if in reverse
                for( auto rev_id = e.children.rbegin(); rev_id != e.children.rend(); rev_id = std::next(rev_id) ) {
                    int cond_expr_id = std::get<int>( this->elems[ *rev_id ].val );

                    cvc5::Term cond_term =  cond_expr_id != spec::undefined_id
                                        ?   this->elems[ cond_expr_id ].term
                                        :   this->tm->mkTrue();

                    else_branches = this->tm->mkTerm(
                        cvc5::Kind::ITE,{
                            cond_term,
                            this->elems[ *rev_id ].term,
                            else_branches
                        }
                    );
                }
                int cond_expr_id = std::get< int >( e.val );
                e.term = this->tm->mkTerm(
                    cvc5::Kind::ITE, {
                        this->elems[ cond_expr_id ].term,
                        this->and_all( true_branch_stmts  ),
                        else_branches
                    }
                );
            }; break;
            case else_if_stmt: {
                assert( e.next != spec::undefined_id );
                std::vector< cvc5::Term > true_branch_stmts = this->next_stmts( e.next );
                e.term = this->and_all( true_branch_stmts );
            }; break;
            case else_stmt: {
                assert( e.next != spec::undefined_id );
                std::vector< cvc5::Term > true_branch_stmts = this->next_stmts( e.next );
                e.term = this->and_all( true_branch_stmts );
            }; break;
            case assignment: {
                int expr_id = std::get<int>( e.val );
                e.term = this->tm->mkTerm(
                    cvc5::Kind::EQUAL,
                    { this->members_next[ e.name ] , this->elems[ expr_id ].term }
                );
            }; break;
            case never_assert: {
                std::vector< cvc5::Term > assertions;
                for ( const int & assert_id : e.children ) {
                    assertions.push_back( this->elems[ assert_id ].term );
                }
                cvc5::Term never_term = this->tm->mkTerm(
                    cvc5::Kind::NOT,
                    { this->and_all( assertions ) }
                );
                const std::string never_name = "never" + std::to_string( this->get_assert_count() );
                e.term = this->slv->defineFun(
                    never_name,
                    this->members_as_vec,
                    this->tm->getBooleanSort(),
                    never_term
                );
            }; break;
            case always_assert: {
                std::vector< cvc5::Term > assertions;
                for ( const int & assert_id : e.children ) {
                    assertions.push_back( this->elems[ assert_id ].term );
                }
                cvc5::Term always_term = this->and_all( assertions );
                const std::string always_name = "always" + std::to_string( this->get_assert_count() );
                e.term = this->slv->defineFun(
                    always_name,
                    this->members_as_vec,
                    this->tm->getBooleanSort(),
                    always_term
                );
            }; break;
            case unkown: {
                LOG_ERR("unkown node, cannot process"); assert(false);
            } break;
        }

    }

    TODO("solve unkown_records recursively for each unkown record\n, \
         simply serach over all elems until \nrecord_def & name = unkown def, recusively");

}

cvc5::Term spec::file::eval_atom( const spec::atom_var & val )
{
    if ( std::holds_alternative< int >( val ) )
    {
        return this->tm->mkInteger( std::get< int >(val) );
    }
    else if ( std::holds_alternative< bool >( val ) )
    {
        return this->tm->mkBoolean( std::get< bool >(val) );
    }
    // else if ( std::holds_alternative< std::string >( val ) )
    // {
    //     LOG( std::get<std::string>(val) );
    //     TODO("return user defined sort");
    // }
    else
    {
        LOG_ERR("unreachable node in eval");
        assert(false);
    }
}

std::vector< cvc5::Term > spec::file::next_stmts( int id )
{
    std::vector< cvc5::Term > stmts;
    int curr_el =  id;
    while( curr_el != spec::undefined_id )
    {
        stmts.push_back( this->elems[ curr_el ].term );
        curr_el = this->elems[ curr_el ].next;
    }
    return stmts;
}
cvc5::Term spec::file::and_all( const std::vector<cvc5::Term> & vec_terms )
{
    if ( vec_terms.size() > 1 ) {
        return this->tm->mkTerm( cvc5::Kind::AND, vec_terms );
    }
    else {
        return *vec_terms.begin();
    }
}
cvc5::Term spec::file::or_all( const std::vector<cvc5::Term> & vec_terms )
{
    if ( vec_terms.size() > 1 ) {
        return this->tm->mkTerm( cvc5::Kind::OR, vec_terms );
    }
    else {
        return *vec_terms.begin();
    }
}

int spec::file::get_rule_count( void )
{
    this->rule_count += 1;
    return this->rule_count;
}
int spec::file::get_assert_count( void )
{
    this->assert_count += 1;
    return this->assert_count;
}
