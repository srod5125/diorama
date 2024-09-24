#include <vector>
#include <unordered_map>


#ifndef AUX_HPP
#define AUX_HPP


class Node {

private:
    int id_count = 0;

public:
    int id;
    std::vector<int> tos;

    Node(): id(id_count++)
    {}

};

int get_final_chain_id( const int id_begining, std::unordered_map< int, Node > & graph );

void chain(  std::unordered_map< int, Node > & graph, int from, int to );
void chain(  std::unordered_map< int, Node > & graph, int from, Node to );
void chain(  std::unordered_map< int, Node > & graph, Node from, Node to );




#endif
