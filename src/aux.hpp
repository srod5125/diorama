#include <iterator>
#include <ostream>
#include <vector>
#include <unordered_map>
#include <string>
#include <iostream>
#include <list>

#ifndef AUX_HPP
#define AUX_HPP


class Node {

private:
    static int id_count;

public:
    int id;
    std::vector<int> tos;
    std::string temp_tag;

    Node();
    Node(const std::string & tag);

    friend std::ostream & operator << (std::ostream & out, const Node & n);

};


using graph_type = std::unordered_map< int,  Node >;


int get_final_chain_id( const int id_begining );

void chain( int from, int to );
void chain( int from, Node & to );
void chain( Node & from, Node & to );


// Todo: wrap in name space
inline graph_type program_structure;
void register_node(Node & n);


void print_graph( graph_type g );


enum node_kind {
    node, //TODO: add all node tyes & replace tags with switch case
};


template <typename Arg>
void LOG_CHOP(Arg arg) {
   std::cout << arg << " ";
}
template <typename First, typename... Args>
void LOG_INNER(First first, Args... args) {
    LOG_CHOP(first);
    LOG_INNER(args...);
}
template <typename First, typename... Args>
void LOG(First first) {
   std::cout << "LOG: ";
   LOG_CHOP(first);
   std::cout << std::endl;
}
template <typename First, typename... Args>
void LOG(First first, Args... args) {
   std::cout << "LOG: ";
   LOG_CHOP(first);
   LOG_INNER(args...);
   std::cout << std::endl;
}


#endif
