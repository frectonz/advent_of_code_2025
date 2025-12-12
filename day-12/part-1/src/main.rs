use std::{collections::HashMap, str::FromStr};

#[derive(Debug)]
struct Present {
    index: u32,
    points: Vec<(i32, i32)>,
}

impl FromStr for Present {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (index, present) = s.split_once(":").unwrap();

        let index = index.trim().parse::<u32>().unwrap();

        dbg!(&present);

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

fn main() {
    let input = include_str!("../inputs/example.txt");
    let input: Input = input.parse().unwrap();

    dbg!(input);
}
