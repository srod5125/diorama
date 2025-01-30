#ifndef HASH_INFO_HPP
#define HASH_INFO_HPP

#include <cctype>
#include <string_view>
#include <algorithm>

/*
    This file contains hash info, mainly moved here because of clutter
*/


// CITATION: https://stackoverflow.com/questions/8627698/case-insensitive-stl-containers-e-g-stdunordered-set
struct sort_name_hash {
    std::size_t operator()(const std::string_view & key) const {
        const std::hash<char> hash_fn;
        std::size_t h = 0;
        for (const char & c : key) {
            h ^= hash_fn(c);
        }
        return h;
    }
};
struct sort_name_equal {
    bool operator()(const std::string_view & left, const std::string_view & right) const {
        // if( left.size() == right.size() ) {
        //     return strcmp(left.data(),right.data());
        // }
        // else {
        //     return false;
        // }
        return left.size() == right.size() &&
        std::equal ( left.begin() , left.end() , right.begin() ,
            []( char a , char b ) {
                return std::tolower(a) == std::tolower(b);
        }
        );
    }
};

#endif
