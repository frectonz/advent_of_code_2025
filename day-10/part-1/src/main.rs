use nom::{
    IResult, Parser,
    bytes::complete::take_while,
    character::{
        self,
        complete::{char, space1},
    },
    multi::{many1, separated_list1},
    sequence::delimited,
};

#[derive(Debug)]
struct Button {
    presses: Vec<u32>,
}

fn parse_button(i: &str) -> IResult<&str, Button> {
    let (i, presses) = delimited(
        char('('),
        separated_list1(char(','), character::complete::u32),
        char(')'),
    )
    .parse(i)?;

    Ok((i, Button { presses }))
}

#[derive(Debug)]
struct Machine {
    lights: String,
    buttons: Vec<Button>,
    junctions: Vec<u32>,
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
            junctions,
        },
    ))
}

fn main() {
    let input = include_str!("../inputs/example.txt");

    let machines = input
        .trim()
        .lines()
        .flat_map(|line| parse_machine(line).map(|x| x.1).ok())
        .collect::<Vec<_>>();

    dbg!(machines);
}
