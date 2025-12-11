use std::collections::HashMap;

use pathfinding::prelude::count_paths;

fn main() {
    let input = include_str!("../inputs/input.txt");

    let mut connections = input
        .lines()
        .flat_map(|line| {
            let (from, tos) = line.split_once(':')?;
            let tos = tos.trim().split_whitespace().collect::<Vec<_>>();
            Some((from.trim(), tos))
        })
        .collect::<HashMap<_, _>>();
    connections.insert("out", vec![]);

    let count = count_paths(
        ("svr", false, false),
        |&(name, fft, dac)| {
            connections[name].iter().map(move |&next_label| {
                (
                    next_label,
                    fft || next_label == "fft",
                    dac || next_label == "dac",
                )
            })
        },
        |&c| c == ("out", true, true),
    );

    dbg!(count);
}
