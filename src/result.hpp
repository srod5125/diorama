#ifndef RESULT_HPP
#define RESULT_HPP

#include <variant>

// CITATION: https://yegor.pomortsev.com/post/result-type/

template <typename T>
struct Ok {
    T value;
    explicit constexpr Ok(T value) : value(std::move(value)) {}
    constexpr T&& take_value() { return std::move(value); }
};

template <typename T>
struct Err {
    T value;
    explicit constexpr Err(T value) : value(std::move(value)) {}
    constexpr T&& take_value() { return std::move(value); }
};

template <typename OkType, typename ErrType>
struct Result {
    using VariantT = std::variant<Ok <OkType>, Err <ErrType> >;
    VariantT res;

    constexpr Result(Ok<OkType> value) : res(std::move(value)) {}
    constexpr Result(Err<ErrType> value) : res(std::move(value)) {}

    constexpr bool is_ok() const { return std::holds_alternative<Ok<OkType>>(res); }
    constexpr bool is_err() const { return std::holds_alternative<Err<ErrType>>(res); }

    constexpr OkType ok_value() const { return std::get<Ok<OkType>>(res).value; }
    constexpr ErrType err_value() const { return std::get<Err<ErrType>>(res).value; }

    constexpr OkType&& take_ok_value() { return std::get<Ok<OkType>>(res).take_value(); }
    constexpr ErrType&& take_err_value() { return std::get<Err<ErrType>>(res).take_value(); }

};

#endif
