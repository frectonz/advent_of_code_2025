use geo::{Contains, LineString};
use itertools::Itertools;

fn is_in_polygon(poly: &geo::Polygon<i64>, p: geo::Point<i64>) -> bool {
    if poly.contains(&p) {
        return true;
    }
    is_on_boundary(poly, &p)
}

fn is_on_boundary(poly: &geo::Polygon<i64>, p: &geo::Point<i64>) -> bool {
    let (px, py) = (p.x(), p.y());

    // Check exterior ring
    if line_string_contains_point(poly.exterior(), px, py) {
        return true;
    }

    false
}

fn line_string_contains_point(ls: &LineString<i64>, px: i64, py: i64) -> bool {
    for seg in ls.lines() {
        let (x1, y1) = (seg.start.x, seg.start.y);
        let (x2, y2) = (seg.end.x, seg.end.y);

        if point_on_segment(px, py, x1, y1, x2, y2) {
            return true;
        }
    }
    false
}

/// Check if (px, py) is on the closed segment [(x1, y1), (x2, y2)] in integer arithmetic.
fn point_on_segment(px: i64, py: i64, x1: i64, y1: i64, x2: i64, y2: i64) -> bool {
    // 1. Check colinearity via cross product:
    // (P - A) x (B - A) == 0
    let cross = (px - x1) * (y2 - y1) - (py - y1) * (x2 - x1);
    if cross != 0 {
        return false;
    }

    // 2. Check that P lies within the bounding box of the segment
    let (min_x, max_x) = if x1 <= x2 { (x1, x2) } else { (x2, x1) };
    let (min_y, max_y) = if y1 <= y2 { (y1, y2) } else { (y2, y1) };

    px >= min_x && px <= max_x && py >= min_y && py <= max_y
}

fn area((x1, y1): &(i64, i64), (x2, y2): &(i64, i64), poly: &geo::Polygon<i64>) -> Option<i64> {
    let (left, right) = if x1 <= x2 { (*x1, *x2) } else { (*x2, *x1) };
    let (top, bottom) = if y1 <= y2 { (*y1, *y2) } else { (*y2, *y1) };

    if left == right || top == bottom {
        return None;
    }

    let tl = geo::Point::new(left, top);
    let tr = geo::Point::new(right, top);
    let bl = geo::Point::new(left, bottom);
    let br = geo::Point::new(right, bottom);

    if [tl, tr, bl, br].iter().all(|p| is_in_polygon(poly, *p)) {
        let width = right - left;
        let height = bottom - top;
        Some((width + 1) * (height + 1))
    } else {
        None
    }
}

fn main() {
    let input = include_str!("../inputs/example.txt");

    let nodes: Vec<(i64, i64)> = input
        .lines()
        .flat_map(|line| line.split_once(','))
        .map(|(x, y)| (x.parse().unwrap(), y.parse().unwrap()))
        .collect();

    let exterior: LineString<i64> = nodes.iter().cloned().collect();
    let polygon = geo::Polygon::new(exterior, vec![]);

    let distances = nodes
        .iter()
        .tuple_combinations()
        .flat_map(|(a, b)| match area(a, b, &polygon) {
            Some(area) => Some((a, b, area)),
            None => None,
        })
        .sorted_by_key(|a| -a.2)
        .collect::<Vec<_>>();

    println!("Solution: {}", distances[0].2)
}
