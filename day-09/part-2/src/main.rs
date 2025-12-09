use geo::Covers;
use itertools::Itertools;

fn area((x1, y1): (f64, f64), (x2, y2): (f64, f64), poly: &geo::Polygon<f64>) -> Option<f64> {
    let (left, right) = if x1 <= x2 { (x1, x2) } else { (x2, x1) };
    let (top, bottom) = if y1 <= y2 { (y1, y2) } else { (y2, y1) };

    if left == right || top == bottom {
        return None;
    }

    let rect: geo::Rect<f64> = geo::Rect::new(
        geo::coord! {x: left, y:top},
        geo::coord! {x: right, y:bottom},
    );

    if poly.covers(&rect) {
        let width = right - left;
        let height = bottom - top;

        Some((width + 1.) * (height + 1.))
    } else {
        None
    }
}

fn main() {
    let input = include_str!("../inputs/input.txt");

    let nodes: Vec<(f64, f64)> = input
        .lines()
        .flat_map(|line| line.split_once(','))
        .map(|(x, y)| (x.parse().unwrap(), y.parse().unwrap()))
        .collect();

    let exterior: geo::LineString<f64> = nodes.iter().cloned().collect();
    let polygon = geo::Polygon::new(exterior, vec![]);

    let rectangles = nodes
        .into_iter()
        .tuple_combinations()
        .filter_map(|(a, b)| area(a, b, &polygon).map(|area| (a, b, area)))
        .sorted_by(|(_, _, area1), (_, _, area2)| area1.total_cmp(area2))
        .collect::<Vec<_>>();

    if let Some((_, _, best_area)) = rectangles.last() {
        println!("Solution: {}", best_area);
    } else {
        println!("No valid rectangle found");
    }
}
