RUNONCEPATH("lib/lib_stage").
RUNONCEPATH("lib/lib_mnv").

//set mm to node(mnv[0],mnv[1],mnv[2],mnv[3])
set exe_node to NEXTNODE.
execMnv(exe_node).
REMOVE exe_node.
