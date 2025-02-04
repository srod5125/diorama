#include <string_view>
#include <vector>
#include <optional>

#include <cvc5/cvc5.h>


#ifndef AUX_HPP
#define AUX_HPP

std::optional<cvc5::Term> find_term( std::vector<cvc5::Term> term_vecs, const std::string_view & name );


#endif
