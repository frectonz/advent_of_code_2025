use std::{
    collections::{HashMap, HashSet},
    hash::RandomState,
};

use petgraph::{
    algo::all_simple_paths,
    graph::{DiGraph, NodeIndex},
};

fn main() {
    let input = include_str!("../inputs/example.txt");

    let connections = input
        .lines()
        .flat_map(|line| {
            let (from, tos) = line.split_once(':')?;
            let tos = tos.trim().split_whitespace().collect::<Vec<_>>();
            Some((from.trim(), tos))
        })
        .collect::<Vec<_>>();

    let edges = connections
        .into_iter()
        .map(|(from, tos)| tos.into_iter().map(|to| (from.to_owned(), to.to_owned())))
        .flatten()
        .collect::<Vec<_>>();

    let unique_nodes = edges
        .clone()
        .into_iter()
        .map(|(from, to)| vec![from, to].into_iter())
        .flatten()
        .collect::<HashSet<_>>();

    let mut map: HashMap<String, NodeIndex> = HashMap::new();

    let mut graph = DiGraph::<String, ()>::new();

    for node in unique_nodes {
        let idx = graph.add_node(node.to_owned());
        map.insert(node, idx);
    }

    for (from, to) in edges {
        let from = map[&from];
        let to = map[&to];

        graph.add_edge(from, to, ());
    }

    let paths = all_simple_paths::<Vec<_>, _, RandomState>(&graph, map["svr"], map["out"], 0, None)
        .collect::<Vec<_>>();

    let valid_paths = paths
        .into_iter()
        .filter(|path| path.contains(&map["fft"]) && path.contains(&map["dac"]))
        .count();

    dbg!(valid_paths);
}
