use itertools::Itertools;

fn dist((x1, y1): &(i64, i64), (x2, y2): &(i64, i64)) -> i64 {
    ((y2 - y1).abs() + 1) * ((x2 - x1).abs() + 1)
}

fn main() {
    let input = include_str!("../inputs/input.txt");
    let nodes: Vec<(i64, i64)> = input
        .lines()
        .flat_map(|line| line.split_once(','))
        .map(|(x, y)| (x.parse().unwrap(), y.parse().unwrap()))
        .collect();

    let distances = nodes
        .iter()
        .tuple_combinations()
        .map(|(a, b)| (a, b, dist(a, b)))
        .sorted_by_key(|a| -a.2)
        .collect::<Vec<_>>();

    println!("Solution: {}", distances[0].2);
}
