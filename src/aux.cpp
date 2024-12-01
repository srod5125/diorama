#include <unordered_map>
#include "aux.hpp"


// ----------

int Node::id_count = 0;


Node::Node() {

    this->id = id_count;
    id_count++;

    this->temp_tag = "xxx";

}


std::ostream & operator << (std::ostream & out, const Node & n) {

    out << n.id << "\t";

    for ( std::size_t i = 0; i < n.tos.size(); i+=1 ) {
        out << "-> " << n.tos[i];
    }

    out << "\t";
    out << "[ label = \"" << n.id << " " << n.temp_tag << "\"]";

    return out;
}





// ----------



int get_final_chain_id (
    const int id_begining ,
    std::unordered_map< int, Node > & graph ) {

        const int undefined_node_id = -1;

        int node_iter    = id_begining;
        int curr_node_id = id_begining;

        while ( node_iter != 0 ) {

            if ( graph.find( node_iter ) == graph.end() ){
                return  undefined_node_id;
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

void chain(  std::unordered_map< int, Node > & graph, int from, Node & to ) {
    // if ( graph.find(to.id) == graph.end() ) {
    //     graph[to.id] = to;
    // }
    graph.at( from ).tos.push_back(to.id);
}

void chain(  std::unordered_map< int, Node > & graph, Node & from, Node & to ) {
    // if ( graph.find(from.id) == graph.end() ) {
    //     graph[from.id] = from;
    // }
    // if ( graph.find(to.id) == graph.end() ) {
    //     graph[to.id] = to;
    // }
    graph.at( from.id ).tos.push_back(to.id);
}



void print_graph( graph_type g ) {

    for ( const auto & [_, node] : g  ) {
        std::cout << node << std::endl;
    }

}


// ----------

void register_node(Node & n ) {

    program_structure[ n.id ] = n;

}


// ----------
