
LEX_IN   := diorama_lexer.ll
PARSE_IN := diorama_parser.yy

LEX_OUT   := d_lex.cpp
PARSE_OUT := d_parse.cpp

DRIVER := diorama_driver.cpp

LEX_O   := lexer.o 
PARSE_O := parser.o

ALL := $(LEX_OUT) $(PARSE_OUT) $(DRIVER)


#build recipe:

$(LEX_OUT): $(LEX_IN)
	flex -o $(LEX_OUT) $(LEX_IN)

$(PARSE_OUT) : $(PARSE_IN)
	bison -o $(PARSE_OUT) $(PARSE_IN)


all: $(ALL)
	clang++ -g calc++.cpp \
			$(LEX_OUT) $(PARSE_OUT) \
			$(DRIVER) \
			-o grammar
