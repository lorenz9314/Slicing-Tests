from graph import *

def match_ir(ir0, ir1):
    if not ir0 or not ir1:
        return False

    return ir0.strip() == ir1.strip()

def merge_graphs(vfg_nodes, dep_nodes, vfg_edges, dep_edges):
    for vnode in vfg_nodes:
        for dnode in dep_nodes:
            # The VFG node and the dependency node point to the same
            # LLVM IR instruction, so that:
            #   ->  The dependency node must be removed from the set
            #   ->  All dependency edges must be update to point to the
            #       n_id of the VFG node
            if match_ir(vnode._llvmir, dnode._llvmir):
                for edge in dep_edges:
                    if edge._start == dnode._n_id:
                        edge._start = vnode._n_id

                    if edge._end == dnode._n_id:
                        edge._end = vnode._n_id

                dep_nodes.remove(dnode)

    nodes = vfg_nodes + dep_nodes
    edges = vfg_edges + dep_edges

    return nodes, edges

def generate_csv(nodes, edges, basename, dbg_offset=0):
    with open("nodes_%s.csv" % basename, "w") as f:
        f.write("nid:ID,ir,dbg:int,vfg:int,:LABEL\n")

        for node in nodes:
            n_id = node._n_id
            llvmir = node._llvmir.strip() \
                    if node._llvmir \
                    else ""
            dbg_loc = int(node._dbg_loc) + dbg_offset \
                    if node._dbg_loc \
                    else -1
            vfg_id = node._vfg_id \
                    if node._vfg_id \
                    else -1
            label = node._node_type

            f.write("%s,\"%s\",%d,%s,%s\n" % (n_id, llvmir, dbg_loc,
                vfg_id, label))

    with open("edges_%s.csv" % basename, "w") as f:
        f.write(":START_ID,:END_ID,:TYPE\n")

        for edge in edges:
            f.write("%s,%s,%s\n" % (edge._start, edge._end,
                edge._props["style"]))
