
LEX_IN   := diorama_lexer.ll
PARSE_IN := diorama_parser.yy

LEX_OUT   := lexer.cpp
PARSE_OUT := parser.cpp

DRIVER_CPP := diorama_driver.cpp
DRIVER_HPP := diorama_driver.hpp

MAIN   := main.cpp

CXX      := clang++-19
CXXFLAGS := -Wall -Wextra -std=c++20 -ggdb
#-ggdb

OBJ_DIR := ./objs
SRC_DIR := ./src
DEP_DIR := ./deps

objects :=  $(wildcard $(OBJ_DIR)/*.o)
# ./objs/main.o  \
# ./objs/parser.o  \
# ./objs/lexer.o \
# ./objs/diorama_driver.o 


.PHONY: clean all debug
.PRECIOUS: $(objects) $(OBJ_DIR)/main.o

# helper function
create_file = $([ ! -f $(1) ] && touch $(1))


# --- build recipe: ---
$(SRC_DIR)/$(LEX_OUT): $(LEX_IN)
	flex -o $(SRC_DIR)/$(LEX_OUT) $(LEX_IN)

$(SRC_DIR)/$(PARSE_OUT) : $(PARSE_IN)
	bison -o $(SRC_DIR)/$(PARSE_OUT) $(PARSE_IN) 

# o files:
#$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
#	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/lexer.o : $(SRC_DIR)/$(LEX_OUT)
	$(call create_file,$@)
	$(CXX) $(CXXFLAGS) -c $(SRC_DIR)/$(LEX_OUT) \
					   -o $(OBJ_DIR)/lexer.o

$(OBJ_DIR)/parser.o : $(SRC_DIR)/$(PARSE_OUT)
	$(call create_file,$@)
	$(CXX) $(CXXFLAGS) -c $(SRC_DIR)/$(PARSE_OUT) \
					   -o $(OBJ_DIR)/parser.o

$(OBJ_DIR)/diorama_driver.o : $(SRC_DIR)/$(DRIVER_CPP) $(SRC_DIR)/$(DRIVER_HPP)
	$(call create_file,$@)
	$(CXX) $(CXXFLAGS) -c $(SRC_DIR)/$(DRIVER_CPP) \
					   -o $(OBJ_DIR)/diorama_driver.o

$(OBJ_DIR)/main.o : $(SRC_DIR)/main.cpp
	$(call create_file,$@)
	$(CXX) $(CXXFLAGS) -c  $(SRC_DIR)/main.cpp \
					   -o $(OBJ_DIR)/main.o


# --- user intsructions ---
debug: $(objects) 
	$(CXX) $(CXXFLAGS) -Wcounterexamples \
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