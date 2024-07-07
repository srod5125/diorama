
LEX_IN   := diorama_lexer.ll
PARSE_IN := diorama_parser.yy

LEX_OUT   := d_lex.cpp
PARSE_OUT := d_parse.cpp

DRIVER := diorama_driver.cpp
MAIN   := main.cpp

LEX_O    := lexer.o 
PARSE_O  := parser.o
DRIVER_O := driver.o
MAIN_O   := main.o


CXXFLAGS := -Wall -Wextra -ggdb

OBJ_DIR := ./objs
SRC_DIR := ./src

objects := $(wildcard $(OBJ_DIR)/*.o)

#build recipe:

$(SRC_DIR)/$(LEX_OUT): $(LEX_IN)
	flex $(LEX_IN) -o $(SRC_DIR)/$(LEX_OUT)

$(SRC_DIR)/$(PARSE_OUT) : $(PARSE_IN)
	bison $(PARSE_IN) -o $(SRC_DIR)/$(PARSE_OUT)

# o files:
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	clang++ -c $^ -o $@


all: $(objects)
	clang++ $(CXXFLAGS) \
		$^ \
		-o grammar
