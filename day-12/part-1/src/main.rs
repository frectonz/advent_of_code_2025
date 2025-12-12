use std::{
    collections::HashMap,
    fmt::{self, Display},
    str::FromStr,
};

#[derive(Debug, Hash, Eq, PartialEq, Clone)]
struct Present {
    index: u32,
    points: Vec<(i32, i32)>,
}

impl Display for Present {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let width = self.points.iter().map(|(x, _)| x).max().unwrap();
        let height = self.points.iter().map(|(_, y)| y).max().unwrap();

        for y in 0..=*height {
            for x in 0..=*width {
                write!(
                    f,
                    "{}",
                    if self.points.contains(&(x, y)) {
                        '#'
                    } else {
                        '.'
                    }
                )?;
            }
            writeln!(f)?;
        }

        Ok(())
    }
}

impl Present {
    /// Rotate the present 90 degrees clockwise
    /// In screen coordinates (y increases downward), 90° clockwise: (x, y) -> (y, max_x - x)
    fn rotate_90(&self) -> Present {
        let max_x = self.points.iter().map(|(x, _)| *x).max().unwrap_or(0);
        let rotated_points = self
            .points
            .iter()
            .map(|(x, y)| (*y, max_x - x))
            .collect();
        Present {
            index: self.index,
            points: rotated_points,
        }
    }

    /// Normalize points to start from (0, 0)
    fn normalize(&self) -> Present {
        let min_x = self.points.iter().map(|(x, _)| *x).min().unwrap_or(0);
        let min_y = self.points.iter().map(|(_, y)| *y).min().unwrap_or(0);
        let normalized_points = self
            .points
            .iter()
            .map(|(x, y)| (x - min_x, y - min_y))
            .collect();
        Present {
            index: self.index,
            points: normalized_points,
        }
    }

    /// Generate all unique rotations (0°, 90°, 180°, 270°)
    fn all_rotations(&self) -> Vec<Present> {
        let mut rotations = Vec::new();
        let mut current = self.normalize();
        let mut seen = std::collections::HashSet::new();

        for _ in 0..4 {
            let normalized = current.normalize();
            let points_sorted: Vec<_> = {
                let mut pts = normalized.points.clone();
                pts.sort();
                pts
            };

            if seen.insert(points_sorted) {
                rotations.push(normalized.clone());
            }
            current = current.rotate_90();
        }

        rotations
    }

    /// Get all valid placements (rotations + translations) within a region
    fn all_placements(&self, width: u32, height: u32) -> Vec<Vec<(i32, i32)>> {
        let mut placements = Vec::new();
        let mut seen = std::collections::HashSet::new();
        let rotations = self.all_rotations();

        for rotated in rotations {
            let max_x = rotated.points.iter().map(|(x, _)| *x).max().unwrap_or(0);
            let max_y = rotated.points.iter().map(|(_, y)| *y).max().unwrap_or(0);

            // Check if this rotation fits in the region at all
            if max_x >= width as i32 || max_y >= height as i32 {
                continue;
            }

            for offset_y in 0..=(height as i32 - max_y - 1) {
                for offset_x in 0..=(width as i32 - max_x - 1) {
                    let mut translated: Vec<(i32, i32)> = rotated
                        .points
                        .iter()
                        .map(|(x, y)| (x + offset_x, y + offset_y))
                        .collect();
                    translated.sort();
                    
                    // Deduplicate placements
                    if seen.insert(translated.clone()) {
                        placements.push(translated);
                    }
                }
            }
        }

        placements
    }
}

impl FromStr for Present {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (index, present) = s.split_once(":").unwrap();

        let index = index.trim().parse::<u32>().unwrap();

        let points = present
            .trim()
            .lines()
            .enumerate()
            .map(|(y, line)| {
                line.chars()
                    .enumerate()
                    .map(move |(x, ch)| (x as i32, y as i32, ch))
            })
            .flatten()
            .filter(|(_, _, ch)| *ch == '#')
            .map(|(x, y, _)| (x, y))
            .collect::<Vec<_>>();

        Ok(Present { index, points })
    }
}

#[derive(Debug)]
struct Region {
    width: u32,
    height: u32,
    present_counts: Vec<u32>,
}

impl FromStr for Region {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (width_height, present_counts) = s.split_once(':').unwrap();

        let (width, height) = width_height.trim().split_once('x').unwrap();
        let width = width.parse::<u32>().unwrap();
        let height = height.parse::<u32>().unwrap();

        let present_counts = present_counts
            .trim()
            .split_whitespace()
            .map(|x| x.parse().unwrap())
            .collect::<Vec<u32>>();

        Ok(Region {
            width,
            height,
            present_counts,
        })
    }
}

#[derive(Debug)]
struct Input {
    presents: HashMap<usize, Present>,
    regions: Vec<Region>,
}

impl FromStr for Input {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut chunks = s.split("\n\n").collect::<Vec<_>>();

        let regions = chunks.pop().unwrap();
        let regions = regions
            .trim()
            .lines()
            .map(|line| line.parse().unwrap())
            .collect::<Vec<Region>>();

        let presents = chunks
            .into_iter()
            .map(|chunk| chunk.trim().parse().unwrap())
            .enumerate()
            .collect::<HashMap<usize, Present>>();

        Ok(Input { presents, regions })
    }
}


/// Try to place all presents in a region using backtracking
fn can_fit_all_presents(
    region: &Region,
    presents: &HashMap<usize, Present>,
) -> bool {
    // Build list of presents to place: (present_index, count)
    // Sort by present size (smaller first) to reduce search space
    let mut to_place: Vec<(usize, u32)> = region
        .present_counts
        .iter()
        .enumerate()
        .filter_map(|(idx, &count)| {
            if count > 0 {
                Some((idx, count))
            } else {
                None
            }
        })
        .collect();
    
    // Sort by present size (number of points) - smaller presents first
    to_place.sort_by_key(|(idx, _)| {
        presents.get(idx).map(|p| p.points.len()).unwrap_or(usize::MAX)
    });

    // Early check: calculate total area needed
    let total_area_needed: u32 = to_place
        .iter()
        .map(|(idx, count)| {
            if let Some(present) = presents.get(idx) {
                present.points.len() as u32 * count
            } else {
                0
            }
        })
        .sum();
    let region_area = region.width * region.height;
    if total_area_needed > region_area {
        return false;
    }

    // Precompute all placements for each present
    let mut all_placements: HashMap<usize, Vec<Vec<(i32, i32)>>> = HashMap::new();
    for (idx, _) in &to_place {
        if let Some(present) = presents.get(idx) {
            let placements = present.all_placements(region.width, region.height);
            if placements.is_empty() {
                return false; // This present cannot be placed at all
            }
            all_placements.insert(*idx, placements);
        } else {
            return false; // Present not found
        }
    }

    // Backtracking function with optimizations
    fn backtrack(
        to_place: &[(usize, u32)],
        all_placements: &HashMap<usize, Vec<Vec<(i32, i32)>>>,
        occupied: &mut std::collections::HashSet<(i32, i32)>,
        present_idx: usize,
        remaining_count: u32,
    ) -> bool {
        // If we've placed all instances of current present, move to next
        if remaining_count == 0 {
            if present_idx + 1 >= to_place.len() {
                return true; // All presents placed!
            }
            let (_, next_count) = to_place[present_idx + 1];
            return backtrack(
                to_place,
                all_placements,
                occupied,
                present_idx + 1,
                next_count,
            );
        }

        // Try to place one more instance of current present
        let (current_present_idx, _) = to_place[present_idx];
        let placements = all_placements.get(&current_present_idx).unwrap();

        // Try placements - use a more efficient iteration
        for placement in placements {
            // Quick check: see if any point overlaps
            let mut has_overlap = false;
            for &point in placement {
                if occupied.contains(&point) {
                    has_overlap = true;
                    break;
                }
            }
            
            if !has_overlap {
                // Place it
                for &point in placement {
                    occupied.insert(point);
                }

                // Recurse
                if backtrack(
                    to_place,
                    all_placements,
                    occupied,
                    present_idx,
                    remaining_count - 1,
                ) {
                    return true;
                }

                // Backtrack: remove this placement
                for &point in placement {
                    occupied.remove(&point);
                }
            }
        }

        false
    }

    if to_place.is_empty() {
        return true;
    }

    let mut occupied = std::collections::HashSet::new();
    backtrack(&to_place, &all_placements, &mut occupied, 0, to_place[0].1)
}

fn main() {
    let input = include_str!("../inputs/input.txt");
    let input: Input = input.parse().unwrap();

    let mut valid_regions = Vec::new();
    for (region_idx, region) in input.regions.iter().enumerate() {
        println!("Checking region {}: {}x{} with counts {:?}", region_idx, region.width, region.height, region.present_counts);
        if can_fit_all_presents(region, &input.presents) {
            println!("  -> VALID");
            valid_regions.push(region_idx);
        } else {
            println!("  -> INVALID");
        }
    }

    println!("Valid regions: {:?}", valid_regions);
    // Calculate sum of region indices (0-indexed) for valid regions
    let count: usize = valid_regions.iter().count();
    println!("Count: {}", count);
}
