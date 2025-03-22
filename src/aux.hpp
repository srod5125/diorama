#ifndef AUX_HPP
#define AUX_HPP

#include <vector>
#include <unordered_map>
#include <string_view>
#include <string>
#include <variant>
#include <utility>


namespace spec
{

    enum class quant { any, all, at_least, at_most, always };

    enum node_kind
    {
        unkown,
        module,
        named_decl,
        record_def,
        members_def,
        enum_def,
        members_init,
        word_to_struct,
        int_val,
        rule,
        when_block, then_block,
        t_and, t_or, t_xor, t_not,
        t_equal, t_not_equal,
        t_union, t_intersect, t_diff, t_isin, t_issub, t_compliment,
        t_gt, t_gtoe, t_lt, t_ltoe,
        t_add , t_minus , t_multiply, t_divide , t_negative,
        atom,
        if_stmt, else_if_stmt, else_stmt
    };

    struct spec_parts
    {
        std::vector< int > data;
        std::vector< int > body;
        std::vector< int > assertions;
    };

    using atom_var = std::variant<
        spec_parts,
        std::pair< std::string, std::string >,
        std::vector< std::string >,
        int,
        bool,
        std::string,
        std::pair< quant, int >
    > ;

    struct token
    {
        int id;
        node_kind kind = unkown;
        std::vector< int > children;
        std::string name;

        atom_var val;
        int next;

        token( );
        token( node_kind kind );
        token( node_kind kind , std::string & name );
        token( node_kind kind , std::string && name );

    };
}

const std::unordered_map< spec::node_kind , std::string_view > node_to_name = {
    { spec::node_kind::unkown , "unkown" },
    { spec::node_kind::module , "module" },
    { spec::node_kind::named_decl , "named_decl" },
    { spec::node_kind::members_def , "members_def" },
    { spec::node_kind::record_def , "record_def" },
    { spec::node_kind::enum_def , "enum_def" },
    { spec::node_kind::members_init , "members_init" },
    { spec::node_kind::word_to_struct , "word_to_struct" },
    { spec::node_kind::int_val , "int_val" },
    { spec::node_kind::rule , "rule" },
    { spec::node_kind::when_block , "when_block" },
    { spec::node_kind::then_block , "then_block" },
    { spec::node_kind::t_and , "and" },
    { spec::node_kind::t_or , "or" },
    { spec::node_kind::t_xor , "xor" },
    { spec::node_kind::t_not , "not" },
    { spec::node_kind::t_equal , "equal" },
    { spec::node_kind::t_not_equal , "not_equal" },
    { spec::node_kind::t_union , "union" },
    { spec::node_kind::t_intersect , "intersect" },
    { spec::node_kind::t_diff , "diff" },
    { spec::node_kind::t_isin , "isin" },
    { spec::node_kind::t_issub , "issub" },
    { spec::node_kind::t_compliment , "compliment" },
    { spec::node_kind::t_gt , "greater than" },
    { spec::node_kind::t_gtoe , "greater than or equal" },
    { spec::node_kind::t_lt , "less than" },
    { spec::node_kind::t_ltoe , "less than or equal" },
    { spec::node_kind::t_add , "t_add" },
    { spec::node_kind::t_minus , "t_minus" },
    { spec::node_kind::t_multiply , "t_multiply" },
    { spec::node_kind::t_divide , "t_divide" },
    { spec::node_kind::t_negative , "t_negative" },
    { spec::node_kind::atom , "atom" },
    { spec::node_kind::if_stmt , "if_stmt" },
    { spec::node_kind::else_if_stmt , "else_if_stmt" },
    { spec::node_kind::else_stmt , "else_stmt" },
};

extern std::vector<spec::token> elements;

/*

#include <memory>
#include <vector>
#include <unordered_map>
#include "hash_info.hpp"

enum PHASE {
  generate_invariants,
  hoare_checks,
  end
};

struct Spec_File {
    std::vector<cvc5::Term> members;
    std::vector<cvc5::Term> next_members;
    cvc5::Term pre;
    cvc5::Term trans;
    cvc5::Term post;

    int never_count;
    int always_count;
};


// constraint solver fields
  std::unique_ptr<cvc5::Solver>     slv;
  std::unique_ptr<cvc5::TermManager> tm;

std::unordered_map<std::string_view, cvc5::Sort, sort_name_hash, sort_name_equal> known_sorts;


this->slv->setOption("produce-models", "true");
//this->slv->setOption("output", "incomplete");
this->slv->setOption("incremental", "true");
this->slv->setOption("sygus", "true");

this->slv->setLogic("ALL");

//adding known sorts
this->known_sorts["int"]  = this->tm->getIntegerSort();
this->known_sorts["bool"] = this->tm->getBooleanSort();

this->spec.never_count  = 1;
this->spec.always_count = 1;

*/

#endif
