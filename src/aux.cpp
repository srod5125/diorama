#include <unordered_map>
#include "aux.hpp"

int get_final_chain_id (
    const int id_begining , std::unordered_map< int, Node > & graph ) {

        int node_iter    = id_begining;
        int curr_node_id = id_begining;

        while ( node_iter != 0 ) {

            if ( graph.find( node_iter ) == graph.end() ){
                return  -1;
            }

            if ( graph[ node_iter ].tos.empty() ) {
                node_iter = 0;
            }
            else {
                node_iter    = *(graph[ node_iter ].tos.begin());
                curr_node_id = node_iter;
            }
        }

        return curr_node_id;

}


void chain(  std::unordered_map< int, Node > & graph, int from, int to ) {
    graph.at( from ).tos.push_back(to);
}

void chain(  std::unordered_map< int, Node > & graph, int from, Node to ) {
    if ( graph.find(to.id) == graph.end() ) {
        graph[to.id] = to;
    }
    graph.at( from ).tos.push_back(to.id);
}

void chain(  std::unordered_map< int, Node > & graph, Node from, Node to ) {
    if ( graph.find(from.id) == graph.end() ) {
        graph[from.id] = from;
    }
    if ( graph.find(to.id) == graph.end() ) {
        graph[to.id] = to;
    }
    graph.at( from.id ).tos.push_back(to.id);
}
