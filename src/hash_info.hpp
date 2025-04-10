#ifndef HASH_INFO_HPP
#define HASH_INFO_HPP

#include <cctype>
#include <string_view>
#include <algorithm>

/*
    This file contains hash info, mainly moved here because of clutter
*/


// CITATION: https://stackoverflow.com/questions/8627698/case-insensitive-stl-containers-e-g-stdunordered-set
struct case_insensitive_hash {
    std::size_t operator()(const std::string_view & key) const {
        return std::hash<std::string_view>()(key) ;
    }
};
struct case_insensitive_equal {
    bool operator()(const std::string_view & left, const std::string_view & right) const {
        return  left.size() == right.size() &&
                std::equal (
                    left.begin() , left.end() ,
                    right.begin() ,
                    []( char a , char b ) {
                        return std::tolower(a) == std::tolower(b);
                }
        );
    }
};

#endif
