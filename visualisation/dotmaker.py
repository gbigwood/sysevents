import networkx
from networkx.drawing.nx_pydot import write_dot
import requests
import sys


def graph_from_json(chain, primary_uuid):
    edges = []
    nodes = []
    for link in chain:
        nodes.append((link['id'], "{}\n{}".format(link['id'], link['type'])))
        if link['parent_id']:
            edges.append((
                link['parent_id'],
                link['id']
                ))

    graph = networkx.DiGraph()
    for node in nodes:
        #graph.add_node(node[0], label=node[1], shape='octagon' if node[0] == primary_uuid else 'oval')
        #graph.add_node(node[0], label=node[1], color='red' if node[0] == primary_uuid else 'black')
        graph.add_node(node[0], label=node[1], penwidth=3 if node[0] == primary_uuid else 1)
    graph.add_edges_from(edges)
    return graph


def chain_for_url(url):
    headers = {"Content-Type": "application/json"}
    result = requests.get(url, headers=headers)
    return result.json()


def main(uuid, outputfilename):
    chain = chain_for_url("http://localhost:4000/chain/{}".format(uuid))
    graph = graph_from_json(chain, uuid)
    write_dot(graph, outputfilename)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
