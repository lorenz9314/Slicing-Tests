#!/usr/bin/env python3
from argparse import ArgumentParser
from sys import argv, exit

from dotparser import *
from depreader import *
from util import *

def main():
    parser = ArgumentParser()
    parser.add_argument("-i", "--input", help="The input file in " \
            "dot format.", type=str, required=True)
    parser.add_argument("-o", "--output", help="The output file in " \
            "json format.", type=str)
    parser.add_argument("-s", "--shift", help="The shift of the " \
            "debug symbols if present.", type=int, default=0)
    parser.add_argument("-d", "--deps", help="CSV containing top " \
            "level dependencies.", type=str, required=True)

    args = parser.parse_args()

    with open(args.input, "r") as f:
        # Use range to skip file header
        content = f.readlines()[3:-1]

    parsed = []
    for line in content:
        parsed.append(parse_top(line))

    print("Generating VFG from dot file.")
    vfg_nodes = list(filter(lambda x: isinstance(x, Node), parsed))
    vfg_edges = list(filter(lambda x: isinstance(x, Edge), parsed))

    print("Generating top level chains from deps file.")
    deps = open_csv(args.deps)
    dep_nodes, dep_edges = parse_deps(deps)

    nodes, edges  = merge_graphs(vfg_nodes, dep_nodes, vfg_edges,
            dep_edges)

    if not args.output:
        args.output = args.input.split(".")[0]

    print("writing to nodes_%s.csv and edges_%s.csv."
            % (args.output, args.output))

    generate_csv(nodes, edges, args.output, args.shift)

if __name__ == "__main__":
    main()
