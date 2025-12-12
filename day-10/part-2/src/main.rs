use std::collections::HashSet;

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
use rayon::prelude::*;

fn parse_button(i: &str) -> IResult<&str, Vec<usize>> {
    let (i, presses) = delimited(
        char('('),
        separated_list1(char(','), character::complete::usize),
        char(')'),
    )
    .parse(i)?;

    Ok((i, presses))
}

#[derive(Debug)]
struct Machine {
    state: Vec<usize>,
    buttons: Vec<Vec<usize>>,
    junctions: Vec<usize>,
}

fn parse_lights(i: &str) -> IResult<&str, String> {
    let (i, lights) =
        delimited(char('['), take_while(|x| x == '.' || x == '#'), char(']')).parse(i)?;

    Ok((i, lights.to_owned()))
}

fn parse_junctions(i: &str) -> IResult<&str, Vec<usize>> {
    let (i, juctions) = delimited(
        char('{'),
        separated_list1(char(','), character::complete::usize),
        char('}'),
    )
    .parse(i)?;

    Ok((i, juctions))
}

fn parse_machine(i: &str) -> IResult<&str, Machine> {
    let (i, (_, _, buttons, _, junctions)) = (
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
            state: vec![0; junctions.len()],
            buttons,
            junctions,
        },
    ))
}

fn push_button(mut state: Vec<usize>, button: &[usize]) -> Vec<usize> {
    for bit in button {
        state[*bit] += 1;
    }
    state
}

fn main() {
    let input = include_str!("../inputs/input.txt");

    let machines: Vec<Machine> = input
        .trim()
        .lines()
        .flat_map(|line| parse_machine(line).map(|x| x.1).ok())
        .collect();

    let total = machines
        .par_iter()
        .enumerate()
        .map(|(_, machine)| {
            let mut set = HashSet::<Vec<usize>>::new();
            set.insert(machine.state.clone());
            let mut i = 0;
            loop {
                set = set
                    .into_iter()
                    .flat_map(|state| {
                        machine
                            .buttons
                            .iter()
                            .map(move |button| push_button(state.clone(), &button))
                    })
                    .filter(|state| {
                        state
                            .iter()
                            .zip(machine.junctions.iter())
                            .all(|(a, b)| a <= b)
                    })
                    .collect();
                i += 1;
                if set.contains(&machine.junctions) {
                    break;
                }
            }

            i
        })
        .sum::<usize>();

    println!("Total minimum presses: {total}");
}
