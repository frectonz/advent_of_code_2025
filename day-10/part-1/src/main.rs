use std::collections::{HashSet, VecDeque};

use nom::{
    IResult, Parser,
    bytes::complete::take_while,
    character::{
        self,
        complete::{char, space1},
    },
    multi::separated_list1,
    sequence::delimited,
};

#[derive(Debug, Hash, Clone)]
struct Button {
    lights: Vec<u32>,
}

fn parse_button(i: &str) -> IResult<&str, Button> {
    let (i, presses) = delimited(
        char('('),
        separated_list1(char(','), character::complete::u32),
        char(')'),
    )
    .parse(i)?;

    Ok((i, Button { lights: presses }))
}

#[derive(Debug)]
struct Machine {
    lights: String,
    buttons: Vec<Button>,
    _junctions: Vec<u32>,
}

impl Machine {
    fn min_presses(&self) -> u32 {
        let target: u32 = self
            .lights
            .chars()
            .enumerate()
            .filter(|(_, c)| *c == '#')
            .map(|(i, _)| i as u32)
            .fold(0u32, |acc, idx| acc | (1u32 << idx));

        let button_masks: Vec<u32> = self
            .buttons
            .iter()
            .map(|btn| {
                btn.lights
                    .iter()
                    .fold(0u32, |acc, &idx| acc | (1u32 << idx))
            })
            .collect();

        let start: u32 = 0;

        if start == target {
            return 0;
        }

        let mut queue: VecDeque<(u32, u32)> = VecDeque::new();
        let mut visited: HashSet<u32> = HashSet::new();

        queue.push_back((start, 0));
        visited.insert(start);

        while let Some((state, steps)) = queue.pop_front() {
            for &bmask in &button_masks {
                let next = state ^ bmask;

                if next == target {
                    return steps + 1;
                }

                if visited.insert(next) {
                    queue.push_back((next, steps + 1));
                }
            }
        }

        unreachable!("should not be here")
    }
}

fn parse_lights(i: &str) -> IResult<&str, String> {
    let (i, lights) =
        delimited(char('['), take_while(|x| x == '.' || x == '#'), char(']')).parse(i)?;

    Ok((i, lights.to_owned()))
}

fn parse_junctions(i: &str) -> IResult<&str, Vec<u32>> {
    let (i, juctions) = delimited(
        char('{'),
        separated_list1(char(','), character::complete::u32),
        char('}'),
    )
    .parse(i)?;

    Ok((i, juctions))
}

fn parse_machine(i: &str) -> IResult<&str, Machine> {
    let (i, (lights, _, buttons, _, junctions)) = (
        parse_lights,
        space1,
        separated_list1(space1, parse_button),
        space1,
        parse_junctions,
    )
        .parse(i)?;

    Ok((
        i,
        Machine {
            lights,
            buttons,
            _junctions: junctions,
        },
    ))
}

fn main() {
    let input = include_str!("../inputs/example.txt");

    let machines: Vec<Machine> = input
        .trim()
        .lines()
        .flat_map(|line| parse_machine(line).map(|x| x.1).ok())
        .collect();

    let total: u32 = machines.iter().map(|m| m.min_presses()).sum();

    println!("Total minimum presses: {total}");
}
