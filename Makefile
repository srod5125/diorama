
LEX_IN   := diorama_lexer.ll
PARSE_IN := diorama_parser.yy

LEX_OUT   := lexer.cpp
PARSE_OUT := parser.cpp

DRIVER := diorama_driver.cpp
MAIN   := main.cpp


CXXFLAGS := -Wall -Wextra -ggdb

OBJ_DIR := ./objs
SRC_DIR := ./src

objects := $(wildcard $(OBJ_DIR)/*.o)

#build recipe:

$(SRC_DIR)/$(LEX_OUT): $(LEX_IN)
	flex -o $(SRC_DIR)/$(LEX_OUT) $(LEX_IN)

$(SRC_DIR)/$(PARSE_OUT) : $(PARSE_IN)
	bison -o $(SRC_DIR)/$(PARSE_OUT) $(PARSE_IN) 

# o files:
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	clang++ -c $< -o $@


all: $(objects)
	clang++ $(CXXFLAGS) \
		$^ \
		-o tb
