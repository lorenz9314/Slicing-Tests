class Edge(object):

    def __init__(self, start, end, props):
        self._start = start
        self._end = end
        self._props = props

    def __str__(self):
        return "(%s) -[%s]-> (%s)" % (self._start, self._props,
                self._end)

    def __repr__(self):
        return self.__str__()

class Node(object):

    def __init__(self, n_id, props, node_type, vfg_id, llvmir,
            dbg_loc):
        self._n_id = n_id
        self._props = props
        self._node_type = node_type
        self._vfg_id = vfg_id
        self._llvmir = llvmir
        self._dbg_loc = dbg_loc

    def __str__(self):
        return "(%s: %s, %s, %s, %s, %s)" % (self._n_id, self._props,
                self._node_type, self._vfg_id, self._llvmir,
                self._dbg_loc)

    def __repr__(self):
        return self.__str__()


