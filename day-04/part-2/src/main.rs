use miette::{IntoDiagnostic, Result};
use std::str::FromStr;

#[derive(Debug)]
struct Grid {
    cells: Vec<Cell>,
    width: usize,
    height: usize,
}

impl Grid {
    fn get(&self, row: i64, col: i64) -> Option<Cell> {
        let valid_width = col >= 0 && col < self.width as i64;
        let valid_height = row >= 0 && row <= self.height as i64;

        if !valid_height || !valid_width {
            None
        } else {
            self.cells
                .get((row as usize * self.width) + col as usize)
                .copied()
        }
    }

    fn get_adjacent(&self, idx: i64) -> Vec<Option<Cell>> {
        let width = self.width as i64;

        let row = idx / width;
        let col = idx % width;

        let top_left = self.get(row - 1, col - 1);
        let top_middle = self.get(row - 1, col);
        let top_right = self.get(row - 1, col + 1);

        let middle_left = self.get(row, col - 1);
        let middle_right = self.get(row, col + 1);

        let bottom_left = self.get(row + 1, col - 1);
        let bottom_middle = self.get(row + 1, col);
        let bottom_right = self.get(row + 1, col + 1);

        vec![
            top_left,
            top_middle,
            top_right,
            middle_left,
            middle_right,
            bottom_left,
            bottom_middle,
            bottom_right,
        ]
    }

    fn removable_paper_rolls(&self) -> Vec<usize> {
        self.cells
            .iter()
            .enumerate()
            .filter(|(_, cell)| cell.is_paper())
            .filter(|(idx, _)| {
                self.get_adjacent(*idx as i64)
                    .iter()
                    .filter(|x| x.is_some_and(|c| c.is_paper()))
                    .count()
                    < 4
            })
            .map(|(idx, _)| idx)
            .collect()
    }

    fn remove_paper_rolls(&self) -> Option<(usize, Grid)> {
        let rolls = self.removable_paper_rolls();

        if rolls.len() == 0 {
            None
        } else {
            let cells = self
                .cells
                .iter()
                .enumerate()
                .map(|(idx, cell)| {
                    if rolls.contains(&idx) {
                        Cell::Empty
                    } else {
                        *cell
                    }
                })
                .collect::<Vec<_>>();

            Some((
                rolls.len(),
                Self {
                    cells,
                    width: self.width,
                    height: self.height,
                },
            ))
        }
    }
}

impl FromStr for Grid {
    type Err = miette::Error;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        let mut lines = s.lines();

        let width = lines.next().map(|line| line.len()).unwrap();

        let height = lines.count();

        let cells = s
            .lines()
            .map(|line| line.chars().flat_map(|x| Cell::from_char(x).ok()))
            .flatten()
            .collect::<Vec<_>>();

        Ok(Self {
            cells,
            width,
            height,
        })
    }
}

#[derive(Debug, Clone, Copy)]
enum Cell {
    PaperRoll,
    Empty,
}

impl Cell {
    fn is_paper(&self) -> bool {
        match self {
            Cell::PaperRoll => true,
            Cell::Empty => false,
        }
    }

    fn from_char(s: char) -> Result<Self, miette::Error> {
        match s {
            '.' => Ok(Self::Empty),
            '@' => Ok(Self::PaperRoll),
            _ => miette::bail!("unknown cell"),
        }
    }
}

fn main() -> miette::Result<()> {
    let contents = std::fs::read_to_string("inputs/input.txt").into_diagnostic()?;
    let mut grid: Grid = contents.parse()?;

    let mut count = 0;

    while let Some((removed, new_grid)) = grid.remove_paper_rolls() {
        count += removed;
        grid = new_grid;
    }

    dbg!(count);

    Ok(())
}
