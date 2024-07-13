
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

objects := $(wildcard $(OBJ_DIR)/*.o)


.PHONY: clean all

#build recipe:

$(SRC_DIR)/$(LEX_OUT): $(LEX_IN)
	flex -o $(SRC_DIR)/$(LEX_OUT) $(LEX_IN)

$(SRC_DIR)/$(PARSE_OUT) : $(PARSE_IN)
	bison -o $(SRC_DIR)/$(PARSE_OUT) $(PARSE_IN) 

# o files:
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PRECIOUS: $(objects) $(OBJ_DIR)/main.o
# 

all: $(objects)
	$(CXX) $(CXXFLAGS) \
		$^ \
		-I./deps/cvc5/ \
		-L./deps/ \
		-lcvc5 \
		-lcvc5parser \
		-o tb


clean:
	find $(OBJ_DIR) -type f -delete


#TODO: when in release link with static library,
#TODO: during dev, link with shared 


#TODO: touch .o file when one doesnt exists