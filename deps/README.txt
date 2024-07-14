compile cvc5

git clone 
https://github.com/cvc5/cvc5/tree/e10e66d375eea2adb8a00f5a5ccf925a82b93b3d

then run ./configure.sh --static

then copy libcvc5.so into deps

deps/libcvc5.so
deps/libcvc5parser.so

-L$(DEP_DIR) -lcvc5 -lcvc5parser \