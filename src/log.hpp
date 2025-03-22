#include <cmath>
#include <iostream>

#ifndef LOG_HPP
#define LOG_HPP

// TODO: add colors

//CITATION: https://stackoverflow.com/questions/7230621/how-can-i-iterate-over-a-packed-variadic-template-argument-list
template <class ... Ts>
void LOG (Ts && ... inputs) {
    ([&]
    {
        std::cout << inputs << ' ';
    } (), ...);
    std::cout << '\n';
}


// log no new line
template <class ... Ts>
void LOG_NNL (Ts && ... inputs) {
    ([&]
    {
        std::cout << inputs << ' ';
    } (), ...);
}

//--- err ---

template <class ... Ts>
void LOG_ERR (Ts && ... inputs) {
    std::cerr << "ERR: ";
    ([&]
    {
        std::cerr << inputs << ' ';
    } (), ...);
    std::cerr << '\n';
}


enum status { ok = 0, err = 1};

#endif
