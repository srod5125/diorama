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
template <typename First>
void LOG_INNER(const First & first) {
    LOG_CHOP(first);
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

//--- err ---

template <typename Arg>
void LOG_ERR_CHOP(const Arg & arg) {
   std::cerr << arg << " ";
}
template <typename First>
void LOG_ERR_INNER(const First & first) {
    LOG_ERR_CHOP(first);
}
template <typename First, typename... Args>
void LOG_ERR_INNER(const First & first, const Args & ... args) {
    LOG_ERR_CHOP(first);
    LOG_ERR_INNER(args...);
}
template <typename First, typename... Args>
void LOG_ERR(const First & first) {
   std::cerr << "LOG: ";
   LOG_ERR_CHOP(first);
   std::cerr << "\n";
}
template <typename First, typename... Args>
void LOG_ERR(const First & first, const Args & ... args) {
   std::cerr << "LOG ERR: ";
   LOG_ERR_CHOP(first);
   LOG_ERR_INNER(args...);
   std::cerr << "\n";
}

template <typename T>
void LOG_ERR() {
   std::cerr << "LOG ERR: \n";
}


#endif
