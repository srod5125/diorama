#include <string>
#include <cassert>

#include "aux.hpp"
#include "log.hpp"

// ----------
std::optional<cvc5::Term> find_term( std::vector<cvc5::Term> term_vecs , const std::string_view & name ) {
    //TODO: handle almost match and report to user
    //TODO: handle case
    for (const auto & t : term_vecs ) {
        if ( t.getSymbol() == name ) {
            return t;
        }
    }
    return std::nullopt;
}
