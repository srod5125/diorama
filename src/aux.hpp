#include <vector>
#include <unordered_map>
#include <string>
#include <iostream>


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


    friend std::ostream & operator << (std::ostream & out, const Node & n);

};


using graph_type = std::unordered_map< int,  Node >;


int get_final_chain_id( const int id_begining, graph_type & graph );

void chain(  graph_type & graph, int from, int to );
void chain(  graph_type & graph, int from, Node to );
void chain(  graph_type & graph, Node from, Node to );


// Todo: wrap in name space
inline graph_type program_structure;
void register_node(Node & n);


void print_graph( graph_type g );



#endif
