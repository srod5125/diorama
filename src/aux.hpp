#ifndef AUX_HPP
#define AUX_HPP

#include <vector>
#include <unordered_map>
#include <string_view>
#include <variant>


namespace spec
{

    enum node_kind
    {
        module,
        add
    };

    struct spec_parts
    {
        std::vector< int > data;
        std::vector< int > body;
        std::vector< int > assertions;
    };

    struct token
    {
        int id;
        node_kind kind;
        std::vector<int> children;

        std::variant< spec_parts > val;
    };
}

const std::unordered_map< spec::node_kind , std::string_view > node_to_name = {
    { spec::node_kind::module , "module" },
    { spec::node_kind::add , "add" },
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
