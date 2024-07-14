
LEX_IN   := diorama_lexer.ll
PARSE_IN := diorama_parser.yy

LEX_OUT   := lexer.cpp
PARSE_OUT := parser.cpp

DRIVER := diorama_driver.cpp
MAIN   := main.cpp

CXX      := clang++
CXXFLAGS := -Wall -Wextra -std=c++20
#-ggdb

OBJ_DIR := ./objs
SRC_DIR := ./src
DEP_DIR := ./deps

objects := $(wildcard $(OBJ_DIR)/*.o)


.PHONY: clean all debug
.PRECIOUS: $(objects) $(OBJ_DIR)/main.o

# --- build recipe: ---
$(SRC_DIR)/$(LEX_OUT): $(LEX_IN)
	flex -o $(SRC_DIR)/$(LEX_OUT) $(LEX_IN)

$(SRC_DIR)/$(PARSE_OUT) : $(PARSE_IN)
	bison -o $(SRC_DIR)/$(PARSE_OUT) $(PARSE_IN) 

# o files:
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/main.o : $(SRC_DIR)/main.cpp
	$(CXX) -c $(CXXFLAGS) $^ -o $@


# --- user intsructions ---
debug: $(objects) $(OBJ_DIR)/main.o
	$(CXX) $(CXXFLAGS) \
		$^ \
		-I$(DEP_DIR)cvc5/ \
		-L$(DEP_DIR) -lcvc5 -lcvc5parser \
		-o tb


clean:
	find $(OBJ_DIR) -type f -delete && \
	rm src/lexer.cpp src/parser.cpp src/parser.hpp


#TODO: when in release link with static library,
#TODO: during dev, link with shared 


#TODO: touch .o file when one doesnt exists