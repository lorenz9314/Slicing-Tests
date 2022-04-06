from graph import *
import json
import re

DEBUG=True

def dbg(head, tail):
    if DEBUG:
        print("Consumed: %s", str(head))
        print("Trailing: %s\n", str(tail))

def check(token, line):
    if token:
        return

    print("Could not parse line: \n\t%s" % str(line))
    print("Aborting!")

    exit(1)

class R:
    n_id = re.compile(r"(Node0x[a-z0-9]+)[:a-z0-9]*(.*)")
    props = re.compile(r"\[(.+)\](.*)")
    edge = re.compile(r"( -> )(.*)")
    simple_props = re.compile(r"([a-z0-9]+)=([a-z0-9]+)")
    node_label = re.compile(r"label=\"{(.*)}\"")
    node_type = re.compile(r"([A-Z][A-Za-z]+Node)(.*)")
    vfg_id = re.compile(r"ID: (\d+)(.*)")
    llvmir = re.compile(r"\\n   (.*=?[\w,]+) ($|\\{.*)")
    dbg_loc = re.compile(r"!dbg !(\d+)(.*)")

def consume(rule, line):
    result = rule.findall(line)

    if not result:
        return None, line

    return result[0][0], result[0][1]

def parse_simple_props(props):
    properties = R.simple_props.findall(props)
    check(properties, props)

    prop_map = {}
    for prop in properties:
        prop_map.update({prop[0]: prop[1]})

    return prop_map

def parse_label(props):
    label = R.node_label.findall(props)
    check(label, props)
    label = label[0]

    node_type, label = consume(R.node_type, label)
    vfg_id, label = consume(R.vfg_id, label)

    llvmir = ""
    if node_type in ["AddrVFGNode", "LoadVFGNode", "StoreVFGNode",
            "ActualParmVFGNode", "FormalParmVFGNode", "'CopyVFGNode",
            "ActualRetVFGNode", "FormalRetVFGNode"]:
        llvmir, label = consume(R.llvmir, label)

    dbg_loc = ""
    if llvmir:
        dbg_loc, _ = consume(R.dbg_loc, llvmir)

    return node_type, vfg_id, llvmir, dbg_loc

def parse_top(line):
    line = line.strip()

    # Retrieve first node identifier, at this point we could have
    # either a node definition or an edge definition.
    n0, line = consume(R.n_id, line)
    check(n0, line)

    # If the next token is an arrow operator we have an edge, else
    # the line defines a new node.
    op, line = consume(R.edge, line)
    if (op):

        # If we found an arrow operator we proceed by retrieving the
        # second node n1 and the properties.
        n1, line = consume(R.n_id, line)
        check(n1,line)

        # Next we must parse the properties.
        props, _ = consume(R.props, line)
        check(props, line)

        # Generate the property map.
        props = parse_simple_props(props)

        return Edge(n0, n1, props)

    else:
        # Otherwise we retrieve only the properties of the node n0.
        props, _ = consume(R.props, line)
        check(props, line)

        # And the label
        label = parse_label(line)
        props = parse_simple_props(props)

        return Node(n0, props, label[0], label[1], label[2], label[3])
