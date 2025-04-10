#ifndef AUX_HPP
#define AUX_HPP

#include <vector>
#include <unordered_map>
#include <string_view>
#include <string>
#include <variant>
#include <utility>
#include <memory>

#include <cvc5/cvc5.h>

#include "hash_info.hpp"

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
        rule,
        when_block, then_block,
        t_and, t_or, t_xor, t_not,
        t_equal, t_not_equal,
        t_union, t_intersect, t_diff, t_isin, t_issub, t_compliment,
        t_gt, t_gtoe, t_lt, t_ltoe,
        t_add , t_minus , t_multiply, t_divide , t_negative,
        atom,
        if_stmt, else_if_stmt, else_stmt,
        assignment,
        never_assert, always_assert,
        assertions
    };

    struct spec_parts
    {
        int inits;
        std::vector< int > rules;
        int assertions;
    };

    using string_pair = std::pair< std::string, std::string >;
    using quant_int   =  std::pair< quant, int >;

    using atom_var = std::variant<
        string_pair,
        spec_parts,
        std::vector< std::string >,
        int,
        bool,
        std::string,
        quant_int
    > ;

    struct token
    {
        //the id is its position in elements
        int id;
        node_kind kind = unkown;
        std::vector< int > children;
        std::string name;

        atom_var val;
        int next;
        int prev;

        // TODO: maybe wrap in union
        cvc5::Term term;
        cvc5::Sort sort;

        token( void );
        token( node_kind kind );
        token( node_kind kind , std::string & name );
        token( node_kind kind , std::string && name );

    };

    const int undefined_id = -1;

    using case_insensitive_string_term_map =
    std::unordered_map<
        std::string, cvc5::Term,
        case_insensitive_hash, case_insensitive_equal
    >;
    using case_insensitive_string_sort_map =
    std::unordered_map<
        std::string, cvc5::Sort,
        case_insensitive_hash, case_insensitive_equal
    >;
    struct file
    {
        std::vector< token > elems;

        std::unique_ptr< cvc5::TermManager > tm;
        std::unique_ptr< cvc5::Solver > slv;

        case_insensitive_string_sort_map known_sorts;
        case_insensitive_string_term_map members;
        case_insensitive_string_term_map members_next;
        case_insensitive_string_term_map rule_inv;

        std::vector< cvc5::Term > members_as_vec;

        int rule_count;
        int assert_count;

        void print_elements( void ) const;
        void initialize_spec( void );
        void invariant_pass( void );
        void set_prevs( void );
        void wp_pass( void );


        int get_rule_count( void );

        //helpers
        cvc5::Term eval_atom( const spec::atom_var & val );
        std::vector< cvc5::Term > next_stmts( int id );
        cvc5::Term and_all( const std::vector<cvc5::Term> & vec_terms );
        cvc5::Term or_all( const std::vector<cvc5::Term> & vec_terms );
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
    { spec::node_kind::assignment , "assignment" },
    { spec::node_kind::never_assert , "never_assert" },
    { spec::node_kind::always_assert , "always_assert" },
    { spec::node_kind::assertions , "assertions" },
};

#endif
