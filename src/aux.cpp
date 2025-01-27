#include <unordered_map>

#include "aux.hpp"
#include "log.hpp"

// ----------

int Node::id_count = 0;


Node::Node() {

    this->id = id_count;
    id_count++;

    this->temp_tag = "xxx";
}

Node::Node(const std::string & tag) {
    this->id = id_count;
    id_count++;

    this->temp_tag = tag;
}


std::ostream & operator << (std::ostream & out, const Node & n) {

    out << n.id << "\t";

    for ( std::size_t i = 0; i < n.tos.size(); i+=1 ) {
        out << "-> " << n.tos[i];
    }

    out << "\t\t";
    out << "[ label = \"" << n.id << " " << n.temp_tag << "\"]";

    return out;
}

// ----------



int get_final_chain_id ( const int id_begining ) {

    const int undefined_node_id = -1;

    int node_iter    = id_begining;
    int curr_node_id = id_begining;

    while ( node_iter != 0 ) {

        if ( program_structure.find( node_iter ) == program_structure.end() ){
            return  undefined_node_id;
        }

        if ( program_structure[ node_iter ].tos.empty() ) {
            node_iter = 0;
        }
        else {
            node_iter    = *(program_structure[ node_iter ].tos.begin());
            curr_node_id = node_iter;
        }
    }

    return curr_node_id;

}


void chain( int from, int to ) {
    program_structure.at( from ).tos.push_back(to);
}

void chain(  int from, Node & to ) {
    // if ( program_structure.find(to.id) == graph.end() ) {
    //     graph[to.id] = to;
    // }
    program_structure.at( from ).tos.push_back(to.id);
}

void chain(  Node & from, Node & to ) {
    // if ( graph.find(from.id) == graph.end() ) {
    //     graph[from.id] = from;
    // }
    // if ( graph.find(to.id) == graph.end() ) {
    //     graph[to.id] = to;
    // }
    program_structure.at( from.id ).tos.push_back(to.id);
}



void print_graph( graph_type g ) {

    for ( const auto & [_, node] : g  ) {
        LOG( node );
    }

}


// ----------

void register_node(Node & n ) {
    program_structure[ n.id ] = n;
}

// ----------
