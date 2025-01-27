#include <iostream>

#ifndef LOG_HPP
#define LOG_HPP

template <typename Arg>
void LOG_CHOP(const Arg & arg) {
   std::cout << arg << " ";
}
template <typename First, typename... Args>
void LOG_INNER(const First & first, const Args & ... args) {
    LOG_CHOP(first);
    LOG_INNER(args...);
}
template <typename First, typename... Args>
void LOG(const First & first) {
   std::cout << "LOG: ";
   LOG_CHOP(first);
   std::cout << "\n";
}
template <typename First, typename... Args>
void LOG(const First & first, const Args & ... args) {
   std::cout << "LOG: ";
   LOG_CHOP(first);
   LOG_INNER(args...);
   std::cout << "\n";
}

template <typename T>
void LOG() {
   std::cout << "LOG: \n";
}

#endif
