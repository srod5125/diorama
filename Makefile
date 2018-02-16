all:
	flex -o calc++-lexer.cpp calc++-lexer.ll
	bison -o calc++-parser.cpp calc++-parser.yy
	g++ -g calc++.cpp calc++-lexer.cpp calc++-parser.cpp calc++-driver.cpp -o a.out
