from graph import *

import re
import csv

def get_ir_id(n_id):
    return "IRNode" + "0x{:016x}".format(n_id)

def open_csv(path):
    with open(path) as csv_file:
        reader = csv.reader(csv_file, delimiter=',',
                quotechar="\"")
        return list(reader)

def parse_deps(deps):
    nodes = []
    edges = []
    dep_dict = {}
    dep_count = 0

    for dep in deps:
        fun, dfn, typ, use = dep

        dfn_id = -1
        use_id = -1

        # Create all dominating nodes, i.e., nodes that are the origin
        # of a directed edge towards another node that depends on the
        # result of this one.
        if dfn not in dep_dict:
            dep_dict.update({dfn: dep_count})
            dfn_id = dep_count

            nodes.append(Node(get_ir_id(dfn_id), "", "TopNode", "",
                dfn, ""))
            dep_count += 1

        # Create all nodes that depend on another one. Nodes may be,
        # and likely are, dominating as well as being dominated by
        # another node, thus they are defined several times. We must
        # make sure not to insert a node twice.
        if use not in dep_dict:
            dep_dict.update({use: dep_count})
            use_id = dep_count

            nodes.append(Node(get_ir_id(use_id), "", "TopNode", "",
                use, ""))
            dep_count += 1

        # If the dnf_id has not been set by now, then the node being
        # referenced in the CSV file has already been processed.
        # However, we must still generate the according edge in the
        # graph, that connects the node. Hence, we look up the missing
        # node by its LLVM IR code.
        if dfn_id == -1:
            dfn_id = dep_dict.get(dfn)

        # Vice versa, we do the same for any other node that is a user
        # of another statement, that has already been processed. Then,
        # we finally draw the edge between the two nodes.
        if use_id == -1:
            use_id = dep_dict.get(use)

        edges.append(Edge(get_ir_id(use_id), get_ir_id(dfn_id),
            {"style": "toplevel"}))

    return nodes, edges
