import networkx
from networkx.drawing.nx_pydot import write_dot
import requests
import sys


def graph_from_json(url):
    chain = chain_for_url(url)
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
        graph.add_node(node[0], label=node[1])
    graph.add_edges_from(edges)
    return graph


def chain_for_url(url):
    headers = {"Content-Type": "application/json"}
    result = requests.get(url, headers=headers)
    return result.json()


def main(uuid):
    graph = graph_from_json("http://localhost:4000/chain/{}".format(uuid))
    write_dot(graph, "/tmp/grid.dot")


if __name__ == "__main__":
    main(sys.argv[1])
